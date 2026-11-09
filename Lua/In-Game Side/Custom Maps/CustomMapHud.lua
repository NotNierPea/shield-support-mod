--[[
		.\hksc.exe ".\Lua\In-Game Side\Custom Maps\CustomMapHud.lua" -o "C:\Program Files (x86)\Call of Duty Black Ops 4\project-bo4\mods\T8ShieldSupport\Lua\Game\CustomMapHud.luac"
]]

---------------------------

if CoD.isFrontend then
	return
end

CoD.ShieldInitLuaFile()

---------------------------

--[[
	The HUD widgets of an MP (or Blackout) map of ours. A zombies map has a HUD lua of its own (T7Hud_<map>, shield-client's
	custom_zones), MP and Blackout open the one Hud_MP / Hud_WZ for every map. A map of ours with HUD widgets carries
	ui/maps/<map>/hud_mp.lua in its zone, setting CoD.ShieldMapHud[<map>] = function ( menu, controller ), and sets the
	clientuimodel hudItems.shieldMapHud to 1 for its players (mp_bully's race bar): that file is required then and called
	with the HUD. A stock map never sets it, so nothing is tried there. (The client's shield_custom_maps list only answers
	while the frontend runs.)
]]
CoD.ShieldMapHud = CoD.ShieldMapHud or {}

local function Log( text )
	Engine[@"printinfo"]( 0, "[CustomMapHud] " .. tostring( text ) )
end

local tried = {}

local function AddMapHud( menu, controller )
	if menu.ShieldMapHudAdded then
		return
	end
	local map = Engine[@"getcurrentmap"]()
	if type( map ) ~= "string" then
		return
	end
	if not CoD.ShieldMapHud[map] and not tried[map] then
		tried[map] = true
		local ok, err = pcall( require, "ui/maps/" .. map .. "/hud_mp" )
		if not ok then
			Log( map .. ": no HUD lua (ui/maps/" .. map .. "/hud_mp): " .. tostring( err ) )
			return
		end
	end
	local add = CoD.ShieldMapHud[map]
	if type( add ) ~= "function" then
		return
	end
	menu.ShieldMapHudAdded = true
	local ok, err = pcall( add, menu, controller )
	if ok then
		Log( map .. ": its HUD widgets added" )
	else
		Log( map .. ": its HUD widgets failed: " .. tostring( err ) )
	end
end

-- (the map's flag: its value may come before or after the HUD opens)
local function WatchMapHud( menu, controller )
	local root = Engine[@"getmodelforcontroller"]( controller )
	if not root then
		return
	end
	local flag = Engine[@"createmodel"]( root, "hudItems.shieldMapHud" )
	local function Check()
		if Engine[@"getmodelvalue"]( flag ) == 1 then
			AddMapHud( menu, controller )
		end
	end
	menu:subscribeToModel( flag, function ( model )
		Check()
	end, false )
	Check()
end

local function Wrap( name )
	local create = LUI.createMenu[name]
	if type( create ) ~= "function" or CoD["ShieldMapHudWrapped" .. name] == create then
		return
	end
	local wrapped = function ( controller, ... )
		local menu = create( controller, ... )
		if menu then
			local ok, err = pcall( WatchMapHud, menu, controller )
			if not ok then
				Log( "not watched: " .. tostring( err ) )
			end
		end
		return menu
	end
	LUI.createMenu[name] = wrapped
	CoD["ShieldMapHudWrapped" .. name] = wrapped
end

local function Hook()
	Wrap( "Hud_MP" )
	Wrap( "Hud_WZ" )
end

Hook()

-- (ui/main's HUD_DelayLoadMenus requires the HUD files after this one: hooked once they are)
if not CoD.ShieldMapHudRequire then
	CoD.ShieldMapHudRequire = true
	local GameRequire = require
	require = function ( ... )
		local result = GameRequire( ... )
		Hook()
		return result
	end
end
