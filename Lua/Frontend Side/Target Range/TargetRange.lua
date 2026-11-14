--[[
		.\hksc.exe ".\Lua\Frontend Side\Target Range\TargetRange.lua" -o "C:\Program Files (x86)\Call of Duty Black Ops 4\project-bo4\internals\T8ShieldSupport\Lua\Frontend\TargetRange.luac"
]]

---------------------------

CoD.ShieldInitLuaFile()

---------------------------

--[[
	Target Range: a button of the multiplayer lobby (over Shield Options, PreGameButtons.lua) that goes straight into
	a free for all on the Firing Range, alone with bots that stand still (TargetRange.gsc). The player's class, no draft.

	The launch: shield-client's targetrange_start when the client has it (dvar shield_targetrange_client 1: gametype
	"targetrange", the streamer not waited for), else a custom game of dm through quickmap. Dvar shield_targetrange 1
	tells the scripts either way. While the lobby menus are walked a cover hides them.
	The map: dvar shield_targetrange_map, else BO4 Custom Maps' mp_targetrange when installed, else mp_firingrange2 (the day
	one, half the streamed data of _alt).
]]

local TR_ACCENT = { r = 1, g = 0.55, b = 0.2 }
local TR_DEFAULT_MAP = "mp_firingrange2"
local TR_RANGE_MAP = "mp_targetrange"
-- the cover gives up after this long in the menus (ms), or this long after the lobby walk ended: no match started
local TR_COVER_TIMEOUT = 90000
local TR_LAUNCH_GRACE = 20000

CoD.ShieldTargetRange = CoD.ShieldTargetRange or {}
local TargetRange = CoD.ShieldTargetRange

local function Log( text )
	Engine[@"printinfo"]( 0, "[shield] target range: " .. text .. "\n" )
end

local function DvarInt( name )
	local ok, value = pcall( Engine[@"getdvarint"], name )
	return ok and tonumber( value ) or 0
end

local function DvarString( dvar )
	local ok, value = pcall( function ()
		return dvar and dvar:get()
	end )
	return ok and type( value ) == "string" and value or ""
end

--[[
	Back from a target range the lobby is the custom game one it was launched through: one step back to multiplayer's
	(the pregame lobby, the Target Range button's). Waits for the custom lobby to come up after the match (18 s at most),
	steps back with OnGoBack, done on the pregame lobby. Freerun.lua's Reopen walks the same way.
]]
TargetRange.ReturnToMenu = function ()
	local root = LUI.roots.UIRootFull
	if not root then
		return false
	end
	if CoD.ShieldTargetRangeReturnTimer then
		CoD.ShieldTargetRangeReturnTimer:close()
		CoD.ShieldTargetRangeReturnTimer = nil
	end

	local walk = { ticks = 0, sent = false, wait = 0 }
	local timer = nil
	timer = LUI.UITimer.newElementTimer( 300, false, function ()
		walk.ticks = walk.ticks + 1
		local current = Engine[@"getlobbyuiscreen"]()
		local custom = LobbyData.GetLobbyMenuIDByName( "director_online_mp_custom" )
		local pregame = LobbyData.GetLobbyMenuIDByName( "director_online_mp_pregame" )
		local done = walk.ticks > 60 or ( walk.sent and current == pregame )
		if not done and current == custom and ( not walk.sent or walk.wait > 10 ) then
			Log( "back to the multiplayer lobby" )
			Engine[@"lobbyevent"]( "OnGoBack", { controller = Engine[@"getprimarycontroller"](), withParty = false } )
			walk.sent = true
			walk.wait = 0
		elseif walk.sent then
			walk.wait = walk.wait + 1
		end
		if done then
			timer:close()
			CoD.ShieldTargetRangeReturnTimer = nil
		end
	end )
	root:addElement( timer )
	CoD.ShieldTargetRangeReturnTimer = timer
	return true
end

-- a frontend that loads again after a target range: back out of its custom lobby, and the next custom game a plain one
if DvarInt( @"shield_targetrange" ) == 1 then
	pcall( TargetRange.ReturnToMenu )
end
Engine[@"exec"]( Engine[@"getprimarycontroller"](), "set shield_targetrange 0" )

local function IsSafeName( text )
	return type( text ) == "string" and text ~= "" and #text <= 64 and not string.find( text, "[^%w_]" )
end

-- a map in the game's maps table (ours are added by shield-client when installed)
local function HasMap( name )
	for _, info in pairs( CoD.MapUtility and CoD.MapUtility.MapsTable or {} ) do
		local id = info[@"hash_3E2D141CB22F2813"]
		if type( id ) ~= "string" or id == "" then
			id = info.mapToLoad
		end
		if id == name then
			return true
		end
	end
	return false
end

-- the dvar's, else the range map (BO4 Custom Maps' mp_targetrange) when installed, else the Firing Range
local function MapName()
	local map = DvarString( Dvar[@"shield_targetrange_map"] )
	if IsSafeName( map ) and string.sub( map, 1, 3 ) == "mp_" then
		return map
	end
	local ok, has = pcall( HasMap, TR_RANGE_MAP )
	if ok and has then
		return TR_RANGE_MAP
	end
	return TR_DEFAULT_MAP
end

-- the map's name as the menus show it
local function MapTitle()
	local map = MapName()
	local ok, title = pcall( CoD.MapUtility.GetLocalizedMapValue, map, "mapName", "" )
	if ok and type( title ) == "string" and string.find( title, "%S" ) then
		return title
	end
	return map
end

---------------------------
-- the cover over the lobby menus while they are walked

local function CloseCover()
	if TargetRange.Cover then
		TargetRange.Cover:close()
		TargetRange.Cover = nil
	end
end

local function NewCover()
	local UI = CoD.Shield and CoD.Shield.BrowserUI
	local root = LUI.roots.UIRootFull
	if not root or not UI then
		return nil
	end

	local cover = LUI.UIElement.new( 0, 1, 0, 0, 0, 1, 0, 0 )
	cover.id = "ShieldTargetRangeCover"
	cover:setPriority( 1000 )

	local back = LUI.UIImage.new( 0, 1, 0, 0, 0, 1, 0, 0 )
	back:setRGB( 0, 0, 0 )
	back:setAlpha( 0.96 )
	cover:addElement( back )

	-- the card, 720 x 190 in the middle
	local card = LUI.UIElement.new( 0.5, 0.5, -360, 360, 0.5, 0.5, -95, 95 )
	cover:addElement( card )

	card:addElement( UI.NewBox( 0, 720, 0, 190, 0.06, 0.06, 0.06, 0.9 ) )
	card:addElement( UI.NewBox( 0, 720, 0, 4, TR_ACCENT.r, TR_ACCENT.g, TR_ACCENT.b, 1 ) )
	card:addElement( UI.NewCaption( 32, 688, 30, "MULTIPLAYER" ) )

	local title = UI.NewText( 32, 688, 52, 48, "notosans_bold" )
	title:setRGB( 1, 1, 1 )
	title:setText( "TARGET RANGE" )
	card:addElement( title )

	card:addElement( UI.NewBox( 32, 688, 116, 117, 1, 1, 1, 0.12 ) )

	local status = UI.NewText( 32, 688, 132, 20, "ttmussels_regular" )
	status:setRGB( 0.62, 0.62, 0.62 )
	status:setLetterSpacing( 2 )
	local mapTitle = string.upper( MapTitle() )
	status:setText( "LOADING " .. mapTitle )
	card:addElement( status )
	cover.Status = status

	-- the dots after the status, the cover's own clock (a match that loads takes the whole frontend, cover too)
	local ticks = 0
	local doneTicks = 0
	cover:addElement( LUI.UITimer.newElementTimer( 250, false, function ()
		ticks = ticks + 1
		status:setText( "LOADING " .. mapTitle .. string.rep( ".", ticks % 4 ) )

		local q = CoD.ShieldQuickMap
		if q and q.done then
			doneTicks = doneTicks + 1
		end

		-- still in the menus long after the walk ended: no match, the menus again and the next custom game a plain one
		if ticks * 250 > TR_COVER_TIMEOUT or doneTicks * 250 > TR_LAUNCH_GRACE then
			Log( "the launch did not start a match, cover closed" )
			Engine[@"exec"]( Engine[@"getprimarycontroller"](), "set shield_targetrange 0" )
			CloseCover()
		end
	end ) )

	root:addElement( cover )
	return cover
end

---------------------------

TargetRange.Start = function ( controller )
	local q = CoD.ShieldQuickMap
	if q and not q.done then
		Log( "already on the way to a lobby" )
		return
	end

	local map = MapName()
	Log( "starting on " .. map )

	-- (the cover reads the walk's state: none from an older walk)
	CoD.ShieldQuickMap = nil
	CloseCover()
	local ok, cover = pcall( NewCover )
	if ok then
		TargetRange.Cover = cover
	else
		Log( "no cover: " .. tostring( cover ) )
	end

	Engine[@"exec"]( controller, "set shield_targetrange 1" )
	if DvarInt( @"shield_targetrange_client" ) == 1 then
		Engine[@"exec"]( controller, "targetrange_start " .. map )
	else
		Engine[@"exec"]( controller, "quickmap " .. map .. " dm director_online_mp_custom" )
	end
end

-- the button over Shield Options (PreGameButtons.lua): multiplayer's online lobbies, not a film
TargetRange.IsAvailable = function ()
	return not IsLobbyNetworkModeLAN() and not CoDShared.IsInTheaterLobby()
end
