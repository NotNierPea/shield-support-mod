--[[
		.\hksc.exe ".\Lua\In-Game Side\Characters\OutfitPortraits.lua" -o "C:\Program Files (x86)\Call of Duty Black Ops 4\project-bo4\internals\T8ShieldSupport\Lua\Game\OutfitPortraits.luac"
]]

---------------------------

if CoD.isFrontend or CoD.isZombie then
	return
end

CoD.ShieldInitLuaFile()

---------------------------

--[[
	Character pictures of outfits of ours in multiplayer and Blackout (zombies: SprayGestureWheel.lua): Peeks on Scarlett
	(Blackout's Scarlett roles, the support zone's MP Scarlett, crew_scarlett) has its own HUD portrait (the ammo widget's,
	GetPositionDraftStatePortraitByIndex) and icon (the scoreboard's and team lists', GetPositionDraftIconByIndex). The
	support GSC tells every HUD each player's character and outfit at their spawn (the notify shield_outfit: client,
	getspecialistindex, getcharacteroutfit); an outfit of these, by its name (shield-client
	"shield/outfits/<zone>/<mode>/<role>/name": the MP copy keeps the zombies one's), has its own pictures.
]]
local OUTFIT_NOTIFY = @"shield_outfit"
local PEEKS = { portrait = @"peaks_hud", icon = @"peaks_portrait" }
local OutfitPictures = {
	[@"shield/outfits/support/zm/1/name"] = PEEKS,
	[@"shield/outfits/support/zm/15/name"] = PEEKS,
	[@"shield/outfits/support/wz/22/name"] = PEEKS,
	[@"shield/outfits/support/wz/26/name"] = PEEKS
}

-- client number: { character, outfit }
local ClientOutfits = {}

local function PicturesOf( characterIndex, outfit )
	if not outfit or outfit <= 0 then
		return nil
	end
	local customization = CoD.PlayerRoleUtility.GetCachedHeroCustomization( Engine[@"currentsessionmode"](), characterIndex )
	local picked = customization and customization.outfits and customization.outfits[outfit + 1]
	return picked and OutfitPictures[picked.displayName]
end

-- the pictures of a player playing that character (before any notify: this player's own pick)
local function CharacterPictures( characterIndex )
	for _, worn in pairs( ClientOutfits ) do
		if worn.character == characterIndex then
			local pictures = PicturesOf( characterIndex, worn.outfit )
			if pictures then
				return pictures
			end
		end
	end
	local info = Engine[@"getequippedinfoforhero"]( Engine[@"getprimarycontroller"](), Engine[@"currentsessionmode"](), characterIndex )
	return PicturesOf( characterIndex, info and info[@"selectedoutfit"] )
end

local function PictureOf( characterIndex, field )
	local ok, pictures = pcall( CharacterPictures, characterIndex )
	return ok and pictures and pictures[field]
end

local function HookPortraits()
	if GetPositionDraftStatePortraitByIndex and CoD.ShieldPortraits ~= GetPositionDraftStatePortraitByIndex then
		local game = GetPositionDraftStatePortraitByIndex
		CoD.ShieldPortraits = function ( state, characterIndex )
			return PictureOf( characterIndex, "portrait" ) or game( state, characterIndex )
		end
		GetPositionDraftStatePortraitByIndex = CoD.ShieldPortraits
	end
	if GetPositionDraftIconByIndex and CoD.ShieldIcons ~= GetPositionDraftIconByIndex then
		local game = GetPositionDraftIconByIndex
		CoD.ShieldIcons = function ( characterIndex )
			return PictureOf( characterIndex, "icon" ) or game( characterIndex )
		end
		GetPositionDraftIconByIndex = CoD.ShieldIcons
	end
end

--[[
	Multiplayer characters past the loadout's 17 (the support zone's crews: shield-client mp_loadouts.cpp keeps their picks,
	read here as any): a match puts on a player's look from their public profile, which has no entry for them. When the
	server asks (shield_custom_request, at the connection) this sends their picks that aren't the default (the support GSC
	SetShieldCustomization): 16384 * character + 1024 * field + value, fields 0 outfit, 1 war paint outfit, then the items
	in the GSC's order, and field 15 at the end.
]]
local CUSTOM_REQUEST = @"shield_custom_request"
local MENU = "shield_support_menu"
local FIRST_EXTRA = 17
local ITEM_TYPES = {
	@"hash_37AD40A4111A72FE", -- head
	@"hash_4FF8573E011622F4", -- headgear
	@"hash_141B42F0A58AC50F", -- arms
	@"hash_19DDCEC39BA98B97", -- torso
	@"hash_283CBB806B732B11", -- legs
	@"hash_4922FE5C41D9EE8B", -- palette
	@"hash_48E3A65D78229DC1", -- warpaint
	@"hash_57852FCB3BFCC8D1" -- decal
}
local WARPAINT = 7

-- the end of the picks (field 15): the server stops asking
local DONE = 15
-- menu responses a tick, ticks apart (all at once overflowed the client's commands: "Client command overflow")
local PER_TICK = 4
local TICK_MS = 100
local sending = false

-- the picks that aren't the default (0) of every character past the 17: (character, field, value)
local function Picks( controller )
	local mode = Enum[@"emodes"][@"mode_multiplayer"]
	local types = Enum[@"characteritemtype"]
	local picks = {}
	for _, hero in ipairs( Engine[@"getherolist"]( mode ) or {} ) do
		local index = hero.bodyIndex
		local info = index and index >= FIRST_EXTRA and index < 128 and Engine[@"getequippedinfoforhero"]( controller, mode, index )
		if info then
			local outfit = info[@"selectedoutfit"] or 0
			local paintOutfit = info[@"hash_4D9FCEAC8FF24CBD"] or 0
			local outfits = info[@"outfits"] or {}
			local values = { outfit, paintOutfit }
			for i, name in ipairs( ITEM_TYPES ) do
				local items = outfits[i == WARPAINT and paintOutfit or outfit]
				values[i + 2] = items and items[types[name]] or 0
			end
			for field = 0, #values - 1 do
				local value = math.max( 0, math.min( 1023, values[field + 1] or 0 ) )
				if value > 0 then
					table.insert( picks, index * 16384 + field * 1024 + value )
				end
			end
		end
	end
	table.insert( picks, DONE * 1024 )
	return picks
end

-- sent a few at a time; a request while sending is the same one
local function SendCustomization( controller )
	local root = LUI.roots and LUI.roots.UIRoot0
	if sending or not root then
		return
	end
	local picks = Picks( controller )
	local next = 1
	sending = true
	local function tick()
		for _ = 1, PER_TICK do
			if next > #picks then
				break
			end
			CoD.BaseUtility.SendCustomMenuResponse( controller, MENU, "mp_custom", picks[next] )
			next = next + 1
		end
		if next > #picks then
			sending = false
			return
		end
		local timer
		timer = LUI.UITimer.newElementTimer( TICK_MS, true, function ()
			timer:close()
			local ok = pcall( tick )
			if not ok then
				sending = false
			end
		end )
		root:addElement( timer )
	end
	local ok = pcall( tick )
	if not ok then
		sending = false
	end
end

-- the notifies, on the root (no HUD hook needed: the root stays the whole game)
local function ListenOutfits()
	local root = LUI.roots and LUI.roots.UIRoot0
	if not root or root.ShieldOutfitPortraits then
		return
	end
	root.ShieldOutfitPortraits = true
	root:subscribeToGlobalModel( Engine[@"getprimarycontroller"](), "PerController", "scriptNotify", function ( model )
		local name = Engine[@"getmodelvalue"]( model )
		if name == CUSTOM_REQUEST then
			pcall( SendCustomization, Engine[@"getprimarycontroller"]() )
			return
		end
		if name ~= OUTFIT_NOTIFY then
			return
		end
		local data = CoD.GetScriptNotifyData( model )
		if data and data[1] then
			ClientOutfits[data[1]] = { character = data[2], outfit = data[3] }
		end
	end )
end

local function Install()
	HookPortraits()
	pcall( ListenOutfits )
end

Install()

-- the player role utility may be read after this file: hooked once it is
if not CoD.ShieldOutfitPortraitsRequire then
	CoD.ShieldOutfitPortraitsRequire = true
	local GameRequire = require
	require = function ( ... )
		local result = GameRequire( ... )
		Install()
		return result
	end
end
