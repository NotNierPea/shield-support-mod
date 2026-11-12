if not CoD.isFrontend then
	return
end

CoD.ShieldInitLuaFile()

---------------------------

--[[
	Forced zombies character: F on a character of the zombies character list (StartMenu_Personalization_ZM) forces it, F
	on it again clears it. It is played on every map (the map casts without the support zone's MP / Blackout characters):
	saved as project-bo4.json lua.zm_character (dvar shield_zm_character, the role index, 0 none), the HUD sends it in a
	match (SprayGestureWheel.lua, zm_character) and the support GSC puts it on (ZombiesCharacter.gsc). The forced one has
	the equipped tick on its tile, as multiplayer's showcased character.
	The zombies loadout keeps its characters by story (the story of a map whose cast has them,
	ZMStoryUtility.CharacterIndexToStory): those in no cast (the MP / Blackout ones) get the IX crew's story, else the
	breadcrumbs index the whole loadout (UI error "attempt to index a nil value" in IsStatSpecialistOutfitItemNew).
]]
local DVAR = "shield_zm_character"

local function Log( text )
	Engine[@"printinfo"]( 0, "[shield] forced character: " .. text .. "\n" )
end

Engine[@"exec"]( Engine[@"getprimarycontroller"](), "readjson " .. DVAR .. " lua zm_character uint64_t 0" )

--[[
	The custom maps' crews (Freddy, Cortex, Crazy Dave...) can't be forced: no lines, and the ready-up screen has no spot
	for them. Theirs are the role slots custom_zones gives a map's crew (role 30 + slot: listed 0-2, hashed 12-32); the
	support zone's characters take 3-11 and 33 on.
]]
local function IsCustomCrew( characterIndex )
	local slot = ( characterIndex or 0 ) - 30
	return slot >= 0 and ( slot < 3 or ( slot >= 12 and slot < 33 ) )
end

local function Forced()
	local forced = Engine[@"getdvarint"]( DVAR ) or 0
	return IsCustomCrew( forced ) and 0 or forced
end

-- the forced role for the tiles' ticks
local function ForcedModel()
	return Engine[@"getglobalmodel"]():create( "shieldForcedZMCharacter" )
end

local function HeroOf( characterIndex )
	for _, hero in ipairs( Engine[@"getherolist"]( Enum[@"emodes"][@"mode_zombies"] ) or {} ) do
		if hero.bodyIndex == characterIndex then
			return hero
		end
	end
	return nil
end

-- the forced one's picture and name above the hint
local function UpdateText( self )
	local forced = Forced()
	ForcedModel():set( forced )
	local hero = forced > 0 and HeroOf( forced )
	if hero then
		self.ShieldForcedName:setText( Engine[@"hash_4F9F1239CFD921FE"]( hero.displayName ) )
		self.ShieldForcedIcon:setImage( RegisterImage( hero.positionDraftIcon ) )
		self.ShieldForcedIcon:setAlpha( 1 )
		self.ShieldForced:setText( "^3Forced on every map^7  (Clear Forced Character on it to clear)" )
	else
		self.ShieldForcedName:setText( "" )
		self.ShieldForcedIcon:setAlpha( 0 )
		self.ShieldForced:setText( "Force Character: played on every map (none: the map's own cast)" )
	end
end

local SendForcedPick
local function SetForced( self, value )
	Engine[@"setdvar"]( DVAR, value )
	Engine[@"exec"]( Engine[@"getprimarycontroller"](), "writejson lua zm_character " .. value .. " uint64_t" )
	Log( "set to " .. value )
	ForcedModel():set( value )
	UpdateText( self )
	-- the lobby's pick at once (the ready-up screen showed it only after going back into the map)
	local ok, err = pcall( SendForcedPick, Engine[@"getprimarycontroller"](), true )
	if not ok then
		Log( "lobby pick not sent: " .. tostring( err ) )
	end
end

local ZOMBIES = Enum[@"emodes"][@"mode_zombies"]

--[[
	The ready-up screen (the zombies pregame lobby) shows each player's lobby pick: the forced character is sent as the
	pick (the host lets it through outside the map's cast: HostTeamSwitch.lua, lobby VM), and the server's
	zm_characters starts with it too. Sent again whenever the lobby's draft models update and the pick isn't it, and
	checked every second while the ready-up screen is open: entering it, the host can put a cast character back (its
	InitializeLobby on the new lobby, before our pick came) within the 3 s a send waits, with no update after, and the
	pick stayed the cast's (IX's crew). A host that keeps refusing it (no support mod) is given up on after 5 sends,
	tried again a minute later.
]]
local RESEND_MS = 3000
local MAX_TRIES = 5
local RETRY_AFTER_MS = 60000
local LastSent = { value = 0, time = 0, tries = 0 }

-- the lobby map's cast (character indices as keys), nil when the map has none listed
local function MapCast()
	local map = LuaUtils.GetMapsTable()[Engine[@"converttoxhash"]( Engine[@"lobbygetmap"]() )]
	local cast = {}
	for _, character in ipairs( map and map.zmCharacters or {} ) do
		if character.characterIndex then
			cast[character.characterIndex] = true
		end
	end
	return next( cast ) and cast or nil
end

-- the map's cast character nobody else has (the pick back when none is forced)
local function FreeCastCharacter( controller, taken )
	local map = LuaUtils.GetMapsTable()[Engine[@"converttoxhash"]( Engine[@"lobbygetmap"]() )]
	for _, cast in ipairs( map and map.zmCharacters or {} ) do
		if cast.characterIndex and not taken[cast.characterIndex] then
			return cast.characterIndex
		end
	end
	return nil
end

--[[
	A splitscreen guest's pick stayed 0 (nothing picks one for it on PC): its draft character had no role, so the lobby's
	spots skipped it and it stood in the host's spot. A cast character nobody has, sent for its controller, at most every
	RESEND_MS.
]]
local GuestSent = 0
local GuestSeen = nil

-- a splitscreen guest's xuid (shield-client splitscreen.cpp): the host's with the controller in the high and low bytes
-- (bots have high bits too: the middle has to be the host's)
local function IsGuestXuid( xuid )
	local text = tostring( xuid )
	local own = tostring( Engine[@"getxuid64"]( Engine[@"getprimarycontroller"]() ) )
	return #text == 20 and #own == 20 and text ~= own and string.sub( text, 1, 4 ) == "x64:" and string.sub( text, 5, 6 ) ~= "00"
		and string.sub( text, 7, 18 ) == string.sub( own, 7, 18 )
end

--[[
	Found by its xuid (Engine.GetXUID64 of its controller isn't it on PC); a new pick when it has none or one somebody
	else has (a copy of the host's, the forced one): same character, same draft scene, same spot. A host does it itself
	(HostTeamSwitch.lua), this is for another host's lobby.
]]
local function PickForGuests()
	local primary = Engine[@"getprimarycontroller"]()
	local guest = primary == 0 and 1 or 0
	local current, taken = nil, {}
	local forced = Forced()
	if forced > 0 then
		taken[forced] = true
	end
	for _, client in pairs( CoD.LobbyUtility.GetClientList() or {} ) do
		if client.clientNum then
			local index = Engine[@"getcharacterindexforclientnum"]( primary, client.clientNum )
			if IsGuestXuid( client.xuid ) then
				current = index or 0
			elseif index and index > 0 then
				taken[index] = true
			end
		end
	end
	if current == nil then
		return
	end
	if GuestSeen ~= current then
		GuestSeen = current
		Log( "splitscreen guest's character: " .. tostring( current ) )
	end
	local now = Engine[@"milliseconds"]()
	if ( current <= 0 or taken[current] ) and now - GuestSent >= RESEND_MS then
		local pick = FreeCastCharacter( guest, taken )
		if pick then
			GuestSent = now
			Engine[@"sendcharacterdraftselection"]( guest, Engine[@"lobbygetcontrollinglobbysession"]( Enum[@"lobbymodule"][@"lobby_module_client"] ), pick )
			Log( "splitscreen guest (controller " .. guest .. ") " .. tostring( current ) .. " -> " .. pick )
		end
	end
end

SendForcedPick = function ( controller, changed )
	local forced = Forced()
	if Engine[@"currentsessionmode"]() ~= ZOMBIES or not CoD.LobbyUtility or not CoD.LobbyUtility.GetClientList then
		return
	end
	-- the forced character is this PC's player's: a splitscreen guest picks their own
	if controller ~= Engine[@"getprimarycontroller"]() then
		return
	end
	pcall( PickForGuests )
	-- this controller's own entry: a splitscreen guest is local too, and its pick is taken like anyone else's
	local mine = tostring( Engine[@"getxuid64"]( controller ) )
	local current, taken, locals, onlyLocal = nil, {}, 0, nil
	for _, client in pairs( CoD.LobbyUtility.GetClientList() or {} ) do
		if client.clientNum then
			local index = Engine[@"getcharacterindexforclientnum"]( controller, client.clientNum )
			if client.isLocal == 1 then
				locals = locals + 1
				onlyLocal = index
			end
			if client.isLocal == 1 and tostring( client.xuid ) == mine then
				current = index
			elseif index then
				taken[index] = true
			end
		end
	end
	-- no xuid match with one local player: that one (as before splitscreen)
	if current == nil and locals == 1 then
		current = onlyLocal
		if current then
			taken[current] = nil
		end
	end
	if current == nil then
		return
	end
	local now = Engine[@"milliseconds"]()
	--[[
		None forced: the pick back in the map's cast when it is outside it. Not only right after clearing: cleared while
		the lobby still had Voyage, the pick went to Voyage's Scarlett, and on Tag der Toten nothing put a cast one back
		(the host lets characters outside the cast through for forced ones).
	]]
	if forced <= 0 then
		local cast = current > 0 and MapCast()
		if not cast or cast[current] or ( not changed and now - LastSent.time < RESEND_MS ) then
			return
		end
		local back = FreeCastCharacter( controller, taken )
		if back then
			LastSent.value = 0
			LastSent.time = now
			Engine[@"sendcharacterdraftselection"]( controller, Engine[@"lobbygetcontrollinglobbysession"]( Enum[@"lobbymodule"][@"lobby_module_client"] ), back )
			Log( "lobby pick " .. tostring( current ) .. " -> " .. back .. " (none forced, back in the map's cast)" )
		end
		return
	end
	if current == forced then
		LastSent.tries = 0
		return
	end
	if changed or now - LastSent.time > RETRY_AFTER_MS then
		LastSent.tries = 0
	end
	if not changed and LastSent.value == forced and ( now - LastSent.time < RESEND_MS or LastSent.tries >= MAX_TRIES ) then
		return
	end
	LastSent.value = forced
	LastSent.time = now
	LastSent.tries = LastSent.tries + 1
	Engine[@"sendcharacterdraftselection"]( controller, Engine[@"lobbygetcontrollinglobbysession"]( Enum[@"lobbymodule"][@"lobby_module_client"] ), forced )
	Log( "lobby pick " .. tostring( current ) .. " -> " .. forced )
end

local function WrapDraftModels()
	local utility = CoD.PlayerRoleUtility
	if not utility or not utility.UpdatePositionDraftModels or utility.UpdatePositionDraftModels == utility.shieldDraftModels then
		return
	end
	local gameUpdate = utility.UpdatePositionDraftModels
	utility.UpdatePositionDraftModels = function ( controller, ... )
		local result = gameUpdate( controller, ... )
		local ok, err = pcall( SendForcedPick, controller or Engine[@"getprimarycontroller"]() )
		if not ok then
			Log( "lobby pick not sent: " .. tostring( err ) )
		end
		return result
	end
	utility.shieldDraftModels = utility.UpdatePositionDraftModels
	Log( "draft models wrapped" )
end

-- the ready-up screen's widgets subscribe to the draft's updates: a check every second while one is open
local function WrapDraftSubscribe()
	local utility = CoD.PlayerRoleUtility
	if not utility or not utility.SubscribeForPostionDraftUpdates or utility.SubscribeForPostionDraftUpdates == utility.shieldDraftSubscribe then
		return
	end
	local gameSubscribe = utility.SubscribeForPostionDraftUpdates
	utility.SubscribeForPostionDraftUpdates = function ( element, controller, ... )
		local result = gameSubscribe( element, controller, ... )
		pcall( function ()
			element:addElement( LUI.UITimer.newElementTimer( 1000, false, function ()
				pcall( SendForcedPick, controller or Engine[@"getprimarycontroller"]() )
			end ) )
		end )
		return result
	end
	utility.shieldDraftSubscribe = utility.SubscribeForPostionDraftUpdates
	Log( "draft subscriptions wrapped" )
end

-- characters in no map cast: the story of the IX crew (Scarlett IX, else Scarlett), else any
local function FillStories()
	local stories = CoD.ZMStoryUtility.CharacterIndexToStory
	local fallback = stories[15] or stories[1]
	if not fallback then
		for _, story in pairs( stories ) do
			fallback = story
			break
		end
	end
	if not fallback then
		return
	end
	for _, hero in ipairs( Engine[@"getherolist"]( ZOMBIES ) or {} ) do
		if hero.bodyIndex and not stories[hero.bodyIndex] then
			stories[hero.bodyIndex] = fallback
		end
	end
end

local function WrapStories()
	local utility = CoD.ZMStoryUtility
	if not utility or not utility.GenerateCharacterToStoryTable or utility.GenerateCharacterToStoryTable == utility.shieldGenerate then
		return
	end
	local gameGenerate = utility.GenerateCharacterToStoryTable
	utility.GenerateCharacterToStoryTable = function ( ... )
		local result = gameGenerate( ... )
		local ok, err = pcall( FillStories )
		if not ok then
			Log( "stories not filled: " .. tostring( err ) )
		end
		return result
	end
	utility.shieldGenerate = utility.GenerateCharacterToStoryTable
	-- (filled at once when the game made it already)
	if next( utility.CharacterIndexToStory or {} ) then
		pcall( FillStories )
	end
	Log( "stories wrapped" )
end

-- a breadcrumb check that still fails: no "new" mark rather than an error dialog
local function WrapBreadcrumbs()
	local utility = CoD.BreadcrumbUtility
	if not utility or not utility.IsStatSpecialistOutfitItemNew or utility.IsStatSpecialistOutfitItemNew == utility.shieldOutfitNew then
		return
	end
	local gameNew = utility.IsStatSpecialistOutfitItemNew
	utility.IsStatSpecialistOutfitItemNew = function ( ... )
		local ok, result = pcall( gameNew, ... )
		return ok and result or false
	end
	utility.shieldOutfitNew = utility.IsStatSpecialistOutfitItemNew
end

--[[
	The outfit breadcrumbs ("new" marks) make UI models for every outfit, preset and part of every character: the zombies
	copies of the MP specialists (roles 30 up, their MP outfits with presets) ran the fixed UI model pool out, a create
	gave nil and subscribing to it was a lua_panic (frozen game). None for any character of ours: past each mode's stock
	roles (zombies 30, multiplayer 17, Blackout 76); multiplayer's froze the same way going to its lobby.
]]
local STOCK_ROLES = {
	[Enum[@"emodes"][@"mode_zombies"]] = 30,
	[Enum[@"emodes"][@"mode_multiplayer"]] = 17,
	[Enum[@"emodes"][@"mode_warzone"]] = 76
}

local function WrapOutfitBreadcrumbs()
	local source = DataSources.SpecialistOutfitBreadcrumbs
	if not source or not source.updateAllSpecialistOutfitItems or source.updateAllSpecialistOutfitItems == source.shieldUpdate then
		return
	end
	local gameUpdate = source.updateAllSpecialistOutfitItems
	source.updateAllSpecialistOutfitItems = function ( task, controller, mode, characterIndex, ... )
		local stock = STOCK_ROLES[mode]
		if stock and characterIndex and characterIndex >= stock then
			return
		end
		local ok, err = pcall( gameUpdate, task, controller, mode, characterIndex, ... )
		if not ok then
			Log( "outfit breadcrumbs of character " .. tostring( characterIndex ) .. " not made: " .. tostring( err ) )
		end
	end
	source.shieldUpdate = source.updateAllSpecialistOutfitItems
	Log( "outfit breadcrumbs wrapped" )
end

-- a breadcrumb count link to a model the full pool didn't make: skipped (subscribing to nil is a lua_panic, pcall or not)
local function WrapChildCountLink()
	local utility = CoD.BreadcrumbUtility
	if not utility or not utility.AddChildCountLink or utility.AddChildCountLink == utility.shieldChildCountLink then
		return
	end
	local gameLink = utility.AddChildCountLink
	local skipped = 0
	utility.AddChildCountLink = function ( controller, parent, child, ... )
		if parent == nil or child == nil then
			skipped = skipped + 1
			if skipped == 1 or skipped % 500 == 0 then
				Log( "breadcrumb links without a model skipped: " .. skipped .. " (UI model pool full?)" )
			end
			return
		end
		return gameLink( controller, parent, child, ... )
	end
	utility.shieldChildCountLink = utility.AddChildCountLink
	Log( "breadcrumb links guarded" )
end

-- the equipped tick (multiplayer's showcased character mark) on the forced zombies character's tile
local function WrapTiles()
	local tile = CoD.HubSpecialist_character_internal
	if not tile or tile.shieldNew == tile.new then
		return
	end
	local gameNew = tile.new
	tile.new = function ( menu, controller, ... )
		local self = gameNew( menu, controller, ... )
		pcall( function ()
			local tick = LUI.UIImage.new( 0.85, 0.85, -45, -1, 0.17, 0.17, -0.5, 43.5 )
			tick:setAlpha( 0 )
			tick:setZoom( 4 )
			tick:setImage( RegisterImage( @"uie_ui_menu_cac_equipped_marker_tick" ) )
			self:addElement( tick )
			self.ShieldForcedTick = tick
			local function Refresh()
				local model = self:getModel()
				local index = model and CoD.SafeGetModelValue( model, "characterIndex" )
				local forced = Forced()
				local shown = forced > 0 and index == forced and CoD.SafeGetModelValue( model, "mode" ) == ZOMBIES
				tick:setAlpha( shown and 1 or 0 )
			end
			self:linkToElementModel( self, "characterIndex", true, Refresh )
			self:subscribeToModel( ForcedModel(), Refresh, false )
		end )
		return self
	end
	tile.shieldNew = tile.new
	Log( "tiles wrapped" )
end

--[[
	The select class widget stands in one of the 4 columns of DirectorLobbyPoseMembersZM, the one of the local player's
	button in DirectorCharacterButtonZMList, ordered by the stock crews' places (OrderCharacterButtonZMList: niko / scar /
	brig column 1, demp / brun / butl 2...). The lobby's spots are Support.csc's (ZombiesLobbyScenes): a character moved to
	another place, or a forced one of ours, got a column it doesn't stand in (column 1, the left). Support.csc puts in
	ShieldDraftSpotRole.<character> the stock role whose place that character stands at: the columns by them.
]]
local CrewColumns = {
	{ "niko", "Unik", "mist", "scar", "brig" },
	{ "demp", "Udem", "russ", "brun", "butl" },
	{ "rich", "Uric", "stuh", "shaw", "guns" },
	{ "take", "Utak", "marl", "dieg", "psyc" }
}

-- a lobby client's column: the crew place of the stock role whose place its character stands at (Support.csc)
local function SpotColumn( controller, client )
	local xuid = client and client.model and client.model.xuid and client.model.xuid:get()
	local draft = xuid and CoD.ZombieUtility.GetPositionDraftClient( controller, xuid )
	local character = draft and draft.characterIndex and draft.characterIndex:get()
	if not character or character <= 0 then
		return nil
	end
	local model = Engine[@"getmodel"]( Engine[@"getglobalmodel"](), "ShieldDraftSpotRole." .. character )
	local role = model and model:get()
	if not role or role <= 0 then
		return nil
	end
	local bundle = Engine[@"getherobundleinfo"]( Enum[@"emodes"][@"mode_zombies"], role )
	local name = bundle and bundle ~= 0 and bundle[@"chrname"]
	for column, names in ipairs( CrewColumns ) do
		for _, crewName in ipairs( names ) do
			if crewName == name then
				return column
			end
		end
	end
	return nil
end

local LastColumns = nil

local function WrapCharacterColumns()
	local utility = CoD.ZombieUtility
	-- (a flag: UnlockAll.lua wraps the ordering too, on top of this one or under it)
	if not utility or not utility.OrderCharacterButtonZMList or utility.shieldSpotColumnsWrapped then
		return
	end
	utility.shieldSpotColumnsWrapped = true
	local order = utility.OrderCharacterButtonZMList
	utility.OrderCharacterButtonZMList = function ( model, controller, clients, ... )
		local ok, result = pcall( function ()
			local columns, placed, any = {}, {}, false
			for index, client in ipairs( clients ) do
				local column = SpotColumn( controller, client )
				if column and not columns[column] then
					columns[column] = client
					placed[index] = true
					any = true
				end
			end
			if not any then
				return nil
			end
			-- the rest in the free columns, in the lobby's order (as the game fills its own blanks)
			local list, rest = {}, {}
			for index, client in ipairs( clients ) do
				if not placed[index] then
					table.insert( rest, client )
				end
			end
			for column = 1, #clients do
				list[column] = columns[column] or table.remove( rest, 1 ) or 0
			end
			local text = ""
			for column = 1, 4 do
				text = text .. " " .. column .. ":" .. tostring( columns[column] ~= nil )
			end
			if text ~= LastColumns then
				LastColumns = text
				Log( "select class columns placed by spot:" .. text )
			end
			return list
		end )
		if ok and result then
			return result
		end
		if not ok then
			Log( "columns not ordered: " .. tostring( result ) )
		end
		return order( model, controller, clients, ... )
	end

	-- the list again when the spots change
	if utility.SubscribeToLobbyClientInfo and utility.SubscribeToLobbyClientInfo ~= utility.shieldSpotSubscribe then
		local subscribe = utility.SubscribeToLobbyClientInfo
		utility.SubscribeToLobbyClientInfo = function ( menu, controller, ... )
			local result = subscribe( menu, controller, ... )
			pcall( function ()
				if not menu._shieldSpotSubscription then
					local changed = Engine[@"createmodel"]( Engine[@"createmodel"]( Engine[@"getglobalmodel"](), "ShieldDraftSpotRole" ), "changed" )
					menu._shieldSpotSubscription = menu:subscribeToModel( changed, function ()
						DataSourceHelperRecreate( controller, "DirectorCharacterButtonZMList" )
					end, false )
				end
			end )
			return result
		end
		utility.shieldSpotSubscribe = utility.SubscribeToLobbyClientInfo
	end
	Log( "select class columns by the lobby's spots" )
end

local function Wrap()
	WrapStories()
	WrapCharacterColumns()
	WrapBreadcrumbs()
	WrapOutfitBreadcrumbs()
	WrapChildCountLink()
	WrapDraftModels()
	WrapDraftSubscribe()
	WrapTiles()
	local widget = CoD.StartMenu_Personalization_ZM
	-- (a flag, not new itself: CharacterCategories.lua wraps new too, and each would wrap the other's again every require)
	if not widget or widget.shieldForcedWrapped then
		return
	end
	widget.shieldForcedWrapped = true
	local gameNew = widget.new
	widget.new = function ( menu, controller, ... )
		local self = gameNew( menu, controller, ... )
		local ok, err = pcall( function ()
			-- under the list, left of the page counter: picture, its name under it, the hint beside them
			local icon = LUI.UIImage.new( 0.5, 0.5, -589, -493, 0.5, 0.5, 276, 372 )
			icon:setAlpha( 0 )
			self:addElement( icon )
			self.ShieldForcedIcon = icon
			local name = LUI.UIText.new( 0.5, 0.5, -629, -453, 0.5, 0.5, 374, 400 )
			name:setTTF( "ttmussels_demibold" )
			name:setAlignment( Enum[@"luialignment"][@"lui_alignment_center"] )
			self:addElement( name )
			self.ShieldForcedName = name
			local text = LUI.UIText.new( 0.5, 0.5, -478, 420, 0.5, 0.5, 342, 372 )
			text:setTTF( "notosans_regular" )
			text:setAlignment( Enum[@"luialignment"][@"lui_alignment_left"] )
			self:addElement( text )
			self.ShieldForced = text
			UpdateText( self )

			-- multiplayer's "Showcase Specialist" button (square / F, ui_contextual_1) and its prompt by the tile
			local key = Enum[@"luibutton"][@"lui_key_xbx_pssquare"]
			menu:AddButtonCallbackFunction( self.specialists, controller, key, "ui_contextual_1", function ( element, menu, controller, model )
				local own = element:getModel()
				local index = own and own.characterIndex and own.characterIndex:get()
				-- (one press can come twice, even through two of these lists: forced then cleared in the same second, so the
				-- wait is kept for all of them, not per list)
				local now = Engine[@"milliseconds"]()
				if not index or ( CoD.ShieldForcedLastPress and now - CoD.ShieldForcedLastPress < 400 ) then
					return true
				end
				CoD.ShieldForcedLastPress = now
				if IsCustomCrew( index ) then
					Engine[@"playsound"]( "uin_bm_denied" )
					if CoD.OverlayUtility and CoD.OverlayUtility.ShowToast then
						CoD.OverlayUtility.ShowToast( "Characters", "Forced character", "Custom characters can't be forced", "uie_t7_icon_error_overlays" )
					end
					return true
				end
				PlaySoundAlias( "uin_start_char_select" )
				SetForced( self, Forced() == index and 0 or index )
				UpdateButtonPromptState( menu, element, controller, key )
				return true
			end, function ( element, menu, controller )
				local own = element:getModel()
				local index = own and own.characterIndex and own.characterIndex:get()
				if not index or IsCustomCrew( index ) then
					return false
				end
				CoD.Menu.SetButtonLabel( menu, key, Forced() == index and @"shield/unforce_character" or @"shield/force_character",
					Enum[@"luibuttonpromptflags"][@"bpf_contextual"], "ui_contextual_1" )
				return true
			end, false )
		end )
		if not ok then
			Log( "not added: " .. tostring( err ) )
		end
		return self
	end
	Log( "character list wrapped" )
end

ForcedModel():set( Forced() )
Wrap()

if not CoD.ShieldForcedCharacterRequire then
	CoD.ShieldForcedCharacterRequire = true
	local GameRequire = require
	require = function ( ... )
		local result = GameRequire( ... )
		Wrap()
		return result
	end
end
