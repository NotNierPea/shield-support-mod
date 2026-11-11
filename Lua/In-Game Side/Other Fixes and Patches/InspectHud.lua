--[[
		.\hksc.exe ".\Lua\In-Game Side\Other Fixes and Patches\InspectHud.lua" -o "C:\Program Files (x86)\Call of Duty Black Ops 4\project-bo4\internals\T8ShieldSupport\Lua\Game\InspectHud.luac"
]]

---------------------------

if CoD.isFrontend then
	return
end

CoD.ShieldInitLuaFile()

---------------------------

--[[
	The HUD away while the weapon is inspected, as newer games, in every mode and from any inspect (keyboard 7,
	multiplayer's D-pad, zombies' Back hub). shield-client sets the controller model shield.inspecting from the inspect's
	own weapon state (weapon_patches.cpp): faded out as it starts, back as it ends or is cut short, no timer.
	The HUDs: multiplayer's Hud_MP, Blackout's Hud_WZ (one each for every map), zombies' T7Hud_<map> (each map its own, all
	ending with CoD.ZombieUtility.CommonPostLoadHud), and the menus scripts open on their own (luielems: zombies' location
	name, hints, timers, trial and map widgets; not its game over). The crosshair is the engine's: cg_drawCrosshair 0
	meanwhile, its value put back after.
]]
local FADE_MS = 200
local OWN_MENUS = {
	"Hud_MP", "Hud_WZ",
	"zm_location", "zm_hint_text", "zm_tut_hint_text", "zm_game_timer", "zm_build_progress", "zm_trial_timer",
	"zm_trial_weapon_locked", "zm_arcade_keys", "zm_arcade_timer", "zm_red_challenges_hud", "zm_towers_challenges_hud",
	"zm_towers_crowd_meter", "zm_towers_pap_hud", "zm_zod_wonderweapon_quest"
}

local function Log( text )
	Engine[@"printinfo"]( 0, "[shield] inspect hud: " .. tostring( text ) .. "\n" )
end

-- the crosshair off while inspecting (once for all the watching menus), the player's setting back after
local crosshairSaved = nil
local function SetCrosshair( inspecting )
	if inspecting and crosshairSaved == nil then
		crosshairSaved = Engine[@"getdvarint"]( "cg_drawCrosshair" ) or 1
		Engine[@"setdvar"]( "cg_drawCrosshair", 0 )
	elseif not inspecting and crosshairSaved ~= nil then
		Engine[@"setdvar"]( "cg_drawCrosshair", crosshairSaved )
		crosshairSaved = nil
	end
end

local function WatchInspect( menu, controller )
	if not menu or menu.ShieldInspectHud then
		return
	end
	menu.ShieldInspectHud = true
	local model = Engine[@"createmodel"]( Engine[@"getmodelforcontroller"]( controller ), "shield.inspecting" )
	local hidden = false
	menu:subscribeToModel( model, function ( value )
		local inspecting = ( value:get() or 0 ) ~= 0
		if inspecting == hidden then
			return
		end
		hidden = inspecting
		menu:beginAnimation( FADE_MS )
		menu:setAlpha( inspecting and 0 or 1 )
		pcall( SetCrosshair, inspecting )
	end, false )
end

local function Watch( menu, controller )
	local ok, err = pcall( WatchInspect, menu, controller )
	if not ok then
		Log( "not watched: " .. tostring( err ) )
	end
end

local function WrapMenu( name )
	local create = LUI.createMenu[name]
	if type( create ) ~= "function" or CoD["ShieldInspectWrapped" .. name] == create then
		return
	end
	local wrapped = function ( controller, ... )
		local menu = create( controller, ... )
		if menu then
			Watch( menu, controller )
		end
		return menu
	end
	LUI.createMenu[name] = wrapped
	CoD["ShieldInspectWrapped" .. name] = wrapped
end

local function WrapZombies()
	local utility = CoD.ZombieUtility
	if not utility or not utility.CommonPostLoadHud or utility.CommonPostLoadHud == utility.shieldInspectHud then
		return
	end
	local game = utility.CommonPostLoadHud
	utility.CommonPostLoadHud = function ( hud, controller, menu, ... )
		local result = game( hud, controller, menu, ... )
		Watch( menu or hud, controller )
		return result
	end
	utility.shieldInspectHud = utility.CommonPostLoadHud
end

local function Hook()
	for _, name in ipairs( OWN_MENUS ) do
		WrapMenu( name )
	end
	WrapZombies()
end

Hook()

-- (ui/main's HUD_DelayLoadMenus requires the HUD files after this one: hooked once they are)
if not CoD.ShieldInspectHudRequire then
	CoD.ShieldInspectHudRequire = true
	local GameRequire = require
	require = function ( ... )
		local result = GameRequire( ... )
		Hook()
		return result
	end
end
