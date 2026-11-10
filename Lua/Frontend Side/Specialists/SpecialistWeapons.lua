--[[
		.\hksc.exe ".\Lua\Frontend Side\Specialists\SpecialistWeapons.lua" -o "C:\Program Files (x86)\Call of Duty Black Ops 4\project-bo4\internals\T8ShieldSupport\Lua\Frontend\SpecialistWeapons.luac"
		.\hksc.exe ".\Lua\Frontend Side\Specialists\SpecialistWeapons.lua" -o "C:\Program Files (x86)\Call of Duty Black Ops 4\project-bo4\internals\T8ShieldSupport\Lua\Game\SpecialistWeapons.luac"
	(the same file in the frontend and in multiplayer games: both have the character select; it also locks our black
	market characters)
]]

---------------------------

if not CoD.isFrontend and not CoD.isMultiplayer then
	return
end

CoD.ShieldInitLuaFile()

---------------------------

--[[
	Specialist weapons of characters of ours (shield-client "specialist_weapon": Wesker's Samurai Edge, a copy of Seraph's
	Annihilator). The game gives the role's weapon, but the character select and Specialist HQ show the role's default class
	(GetPositionRoleDefaultInfo: its herogadget, the base role's: Ruin's Grav Spikes). For a character of these, found by its
	list picture (positionDraftIcon), the ability shown is the stock specialist's item whose weapon ours copies (its stats,
	its item index) with our name, description and icon.
]]
local MODE = Enum[@"emodes"][@"mode_multiplayer"]

local Weapons = {
	[@"wesker_portrait"] = {
		from = 9, -- Seraph (her Annihilator)
		displayName = @"wesker/weapons/samurai_edge",
		description = @"wesker/weapons/samurai_edge_desc",
		image = @"wesker_gun_icon"
	}
}

local function WeaponOf( mode, characterIndex )
	if mode ~= MODE then
		return nil
	end
	local info = CoD.PlayerRoleUtility.GetCachedHeroInfo( mode, characterIndex )
	return info and info.positionDraftIcon and Weapons[info.positionDraftIcon]
end

--[[
	Characters of ours sold in the black market (shield-client custom_loot: loot_items.csv's "character" rows): locked until
	their loot item is owned, as the game's black market characters (IsRoleBMLocked reads that from a role bundle key ours
	haven't). Found by their list picture, in every mode.
]]
local Locks = {
	[@"wesker_portrait"] = @"shield_wesker"
}

local function LockOf( mode, characterIndex )
	local info = CoD.PlayerRoleUtility.GetCachedHeroInfo( mode, characterIndex )
	return info and info.positionDraftIcon and Locks[info.positionDraftIcon]
end

local function InstallLocks()
	local utility = CoD.PlayerRoleUtility
	if not utility or not utility.IsRoleBMLocked or utility.ShieldLocks == utility.IsRoleBMLocked then
		return
	end
	local game = utility.IsRoleBMLocked
	utility.IsRoleBMLocked = function ( controller, mode, characterIndex, ... )
		local ok, loot = pcall( LockOf, mode, characterIndex )
		if ok and loot then
			return not CoDShared.IsLootItemOwnedByName( controller, loot )
		end
		return game( controller, mode, characterIndex, ... )
	end
	utility.ShieldLocks = utility.IsRoleBMLocked
end

local function Install()
	InstallLocks()
	local utility = CoD.PlayerRoleUtility
	if not utility or not utility.GetPositionRoleDefaultInfo or utility.ShieldWeapons == utility.GetPositionRoleDefaultInfo then
		return
	end
	local game = utility.GetPositionRoleDefaultInfo
	utility.GetPositionRoleDefaultInfo = function ( mode, characterIndex, ... )
		local info = game( mode, characterIndex, ... )
		local ok, ours = pcall( WeaponOf, mode, characterIndex )
		if info and ok and ours then
			local stock = game( mode, ours.from )
			local ability = {}
			for k, v in pairs( stock and stock.ability or info.ability or {} ) do
				ability[k] = v
			end
			ability.displayName = ours.displayName
			ability.description = ours.description
			ability.image = ours.image
			info.ability = ability
		end
		return info
	end
	utility.ShieldWeapons = utility.GetPositionRoleDefaultInfo
end

Install()

-- the player role utility may be read after this file: installed once it is
if not CoD.ShieldWeaponsRequire then
	CoD.ShieldWeaponsRequire = true
	local GameRequire = require
	require = function ( ... )
		local result = GameRequire( ... )
		Install()
		return result
	end
end
