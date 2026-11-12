--[[
		.\hksc.exe ".\Lua\In-Game Side\Freerun\FreerunHud.lua" -o "C:\Program Files (x86)\Call of Duty Black Ops 4\project-bo4\internals\T8ShieldSupport\Lua\Game\FreerunHud.luac"
]]

---------------------------

if CoD.isFrontend then
	return
end

CoD.ShieldInitLuaFile()

---------------------------

--[[
	Freerun's HUD (Freerun.gsc), on the MP HUD of any map once hudItems.shieldFreerun.state is set: the bar top middle
	(TIME, CHECKPOINT, BEST), the countdown, its texts and what the buttons do. state 0 off, 1 countdown, 2 running,
	3 finished, 4 free roam, 5 editor. The clock counts here from the start of the run: the server sends the end time.
]]

local FONT = "ttmussels_regular"
local ACCENT = { 0.35, 0.85, 1 }

local MESSAGES = {
	[1] = "^2NEW BEST!",
	[2] = "FINISHED",
	[3] = "Back on the checkpoint",
	[4] = "Restart",
	[5] = "Start placed",
	[6] = "Checkpoint placed",
	[7] = "Point removed",
	[8] = "^2Course saved: it is in the Freerun menu now",
	[9] = "^1Not saved: place the start and at least one checkpoint",
	[10] = "Nothing to remove"
}

local HINTS = {
	[1] = "Hold ^3USE^7 for the last checkpoint, longer to restart",
	[2] = "Hold ^3USE^7 for the last checkpoint, longer to restart",
	[3] = "The next run starts in a moment",
	[4] = "Free roam: the grapple and the map",
	[5] = "Tap ^3USE^7 place a point   Tap ^3MELEE^7 remove the last   Hold ^3USE^7 save the course"
}

local COUNT = { [1] = "1", [2] = "2", [3] = "3", [4] = "GO!" }
local CATEGORY = { [1] = "VANILLA MOVEMENT", [2] = "SHIELD MOVEMENT" }

local function Log( text )
	Engine[@"printinfo"]( 0, "[FreerunHud] " .. tostring( text ) )
end

local function Value( controller, name )
	local root = Engine[@"getmodelforcontroller"]( controller )
	local model = root and Engine[@"getmodel"]( root, "hudItems.shieldFreerun." .. name )
	return model and Engine[@"getmodelvalue"]( model ) or 0
end

local function Clock( ms )
	if ms == nil or ms <= 0 then
		return "-:--.---"
	end
	return string.format( "%d:%02d.%03d", math.floor( ms / 60000 ), math.floor( ms / 1000 ) % 60, ms % 1000 )
end

local function Text( parent, xl, xr, left, right, yt, yb, top, bottom )
	local text = LUI.UIText.new( xl, xr, left, right, yt, yb, top, bottom )
	text:setTTF( FONT )
	text:setAlignment( Enum[@"luialignment"][@"lui_alignment_center"] )
	text:setRGB( 1, 1, 1 )
	parent:addElement( text )
	return text
end

local function AddFreerunHud( menu, controller )
	if menu.ShieldFreerunHud then
		return
	end

	local self = LUI.UIElement.new( 0, 1, 0, 0, 0, 1, 0, 0 )
	self.id = "ShieldFreerunHud"
	self:setAlpha( 0 )
	menu:addElement( self )
	menu.ShieldFreerunHud = self

	-- the bar: three columns over a dark box, a line of the accent on top
	local bar = LUI.UIImage.new( 0.5, 0.5, -270, 270, 0, 0, 92, 164 )
	bar:setRGB( 0, 0, 0 )
	bar:setAlpha( 0.5 )
	self:addElement( bar )
	local line = LUI.UIImage.new( 0.5, 0.5, -270, 270, 0, 0, 92, 95 )
	line:setRGB( ACCENT[1], ACCENT[2], ACCENT[3] )
	self:addElement( line )

	local values = {}
	for i, label in ipairs( { "TIME", "CHECKPOINT", "BEST" } ) do
		local x = ( i - 2 ) * 180
		local head = Text( self, 0.5, 0.5, x - 90, x + 90, 0, 0, 100, 120 )
		head:setText( label )
		head:setRGB( 0.6, 0.6, 0.6 )
		values[label] = Text( self, 0.5, 0.5, x - 90, x + 90, 0, 0, 122, 156 )
	end

	local category = Text( self, 0.5, 0.5, -270, 270, 0, 0, 168, 186 )
	category:setRGB( ACCENT[1], ACCENT[2], ACCENT[3] )

	local count = Text( self, 0.5, 0.5, -400, 400, 0.38, 0.38, -60, 60 )
	local msg = Text( self, 0.5, 0.5, -700, 700, 0.3, 0.3, -20, 20 )
	-- what the buttons do: big, under the screen's middle (over the weapon and gadget HUD)
	local hint = Text( self, 0.5, 0.5, -800, 800, 0.72, 0.72, -18, 18 )
	hint:setRGB( 0.95, 0.95, 0.95 )

	local started = nil
	local function Refresh()
		local state = Value( controller, "state" )
		self:setAlpha( state > 0 and 1 or 0 )
		if state == 0 then
			return
		end

		local onCourse = state >= 1 and state <= 3
		bar:setAlpha( onCourse and 0.5 or 0 )
		line:setAlpha( onCourse and 1 or 0 )
		for _, label in ipairs( { "TIME", "CHECKPOINT", "BEST" } ) do
			values[label]:setAlpha( onCourse and 1 or 0 )
		end

		-- the editor counts its points in cps
		local cps = Value( controller, "cps" )
		if state == 5 then
			category:setText( "COURSE EDITOR  -  " .. cps .. " CHECKPOINTS" )
		else
			category:setText( CATEGORY[Value( controller, "category" )] or "" )
		end

		values.CHECKPOINT:setText( Value( controller, "cp" ) .. "/" .. cps )
		values.BEST:setText( Clock( Value( controller, "best" ) ) )

		if state == 2 then
			started = started or Engine[@"currentgametime"]()
		elseif state == 3 then
			started = nil
			values.TIME:setText( Clock( Value( controller, "time" ) ) )
		else
			started = nil
			values.TIME:setText( Clock( 0 ) )
		end

		count:setText( COUNT[Value( controller, "count" )] or "" )
		msg:setText( MESSAGES[Value( controller, "msg" )] or "" )
		hint:setText( HINTS[state] or "" )
	end

	local root = Engine[@"getmodelforcontroller"]( controller )
	for _, name in ipairs( { "state", "count", "cp", "cps", "time", "best", "msg", "category" } ) do
		self:subscribeToModel( Engine[@"createmodel"]( root, "hudItems.shieldFreerun." .. name ), function ( model )
			Refresh()
		end, false )
	end

	self:addElement( LUI.UITimer.newElementTimer( 30, false, function ()
		if started and Value( controller, "state" ) == 2 then
			values.TIME:setText( Clock( Engine[@"currentgametime"]() - started ) )
		end
	end ) )

	-- what a run doesn't need, hidden as long as the HUD lives (its own clips would show it again): MP's health and
	-- character panel, the score under the minimap, the scorestreaks; zombies' below
	-- (zombies: the map's HUD menu, T7Hud_<map>, recorded as it's made (below); else looked for under the root)
	local function FindZombiesHud( element, depth )
		local child = element.getFirstChild and element:getFirstChild()
		while child do
			if child.SafeAreaContainer and ( child.SafeAreaContainer.Rounds or child.SafeAreaContainer.ScoreInfo ) then
				return child
			end
			if depth > 0 then
				local found = FindZombiesHud( child, depth - 1 )
				if found then
					return found
				end
			end
			child = child:getNextSibling()
		end
		return nil
	end

	local zombiesLogged = false
	local function ZombiesHud()
		local hud = CoD.ShieldFreerunZMHud
		if not hud or not hud.SafeAreaContainer then
			hud = FindZombiesHud( menu, 3 )
		end
		if not zombiesLogged and CoD.isZombie then
			zombiesLogged = true
			Log( hud and "zombies HUD found" or "zombies HUD not found yet" )
		end
		return hud
	end

	local function StockParts()
		local safe = menu.HudMPSafeAreaContainer
		if safe then
			return { safe.PlayerWidgetContainer, safe.ScoreInfo, safe.EMPScoreInfo, safe.ScrStkContainerWrapper, menu.MPScore }
		end
		-- zombies: the points, the round, the character and health panel, perk vapors, power-ups, the quest inventory
		local hud = ZombiesHud()
		local zsafe = hud and hud.SafeAreaContainer
		if not zsafe then
			return {}
		end
		if not CoD.ShieldFreerunZMFoundLogged then
			CoD.ShieldFreerunZMFoundLogged = true
			Log( "zombies HUD parts hidden" )
		end
		-- (the elixir: the ammo widget's ability slot, its swirl and glow; the grapple's slot, Equipment, stays)
		local ammo = zsafe.AmmoWidgetZMContainer and zsafe.AmmoWidgetZMContainer.AmmoWidgetZM
		-- (PC's ammo widget holds the elixirs: AmmoPC.ZmAmmo.ZmAmmoProp0.ZmAmmoBGBCarouselFactory)
		local pcAmmo = zsafe.AmmoPC and zsafe.AmmoPC.ZmAmmo
		local pcProp = pcAmmo and pcAmmo.ZmAmmoProp0
		return { zsafe.ScoreInfo, zsafe.PlayerWidget, zsafe.ScorePC, zsafe.ZMScrArcade, zsafe.Rounds, zsafe.ZMPerkVaporsContainer,
			zsafe.PowerUpsArea, zsafe.HudZMTrialsContainer, zsafe.HudZMRushContainer, zsafe.ZmNotifBGBContainerFactory,
			hud.ZMInventory, hud.MPScore, ammo and ammo.AmmoWidgetZMAbilityOrWeaponContainer, ammo and ammo.specialWeaponLevel,
			ammo and ammo.HudZMSpecialWeaponDisabledContainer, ammo and ammo.bgbAbilitySwirl, ammo and ammo.bgbGlowOrangeOver,
			pcProp and pcProp.ZmAmmoBGBCarouselFactory, zsafe.AmmoPC and zsafe.AmmoPC.bgbAbilitySwirl,
			zsafe.AmmoPC and zsafe.AmmoPC.bgbGlowOrangeOver }
	end

	local function HideStock()
		-- Discord's gametype: zombies' lobby wrote its playlist's (Classic)
		if Dvar[@"shield_rpc_Gametype"] and Dvar[@"shield_rpc_Gametype"]:get() ~= "FREERUN" then
			Dvar[@"shield_rpc_Gametype"]:set( "FREERUN" )
		end
		for _, element in pairs( StockParts() ) do
			if element and element.setAlpha then
				element:setAlpha( 0 )
			end
		end
	end
	self:addElement( LUI.UITimer.newElementTimer( 250, false, HideStock ) )
	HideStock()

	Refresh()
	Log( "added" )
end

local function WatchFreerun( menu, controller )
	local root = Engine[@"getmodelforcontroller"]( controller )
	if not root then
		return
	end
	-- (the category comes at the first spawn, the state only once the run goes: the stock HUD hidden from the spawn)
	local state = Engine[@"createmodel"]( root, "hudItems.shieldFreerun.state" )
	local category = Engine[@"createmodel"]( root, "hudItems.shieldFreerun.category" )
	local function Check()
		if ( Engine[@"getmodelvalue"]( state ) or 0 ) > 0 or ( Engine[@"getmodelvalue"]( category ) or 0 ) > 0 then
			local ok, err = pcall( AddFreerunHud, menu, controller )
			if not ok then
				Log( "failed: " .. tostring( err ) )
			end
		end
	end
	menu:subscribeToModel( state, function ( model )
		Check()
	end, false )
	menu:subscribeToModel( category, function ( model )
		Check()
	end, false )
	Check()
end

-- the game's prematch countdown says RACE STARTING IN in a freerun match (Freerun.gsc sets the dvar; its ticks are
-- ours there too)
if CoD.HUDUtility and CoD.HUDUtility.MatchOrRoundBeginsIn and CoD.HUDUtility.MatchOrRoundBeginsIn ~= CoD.ShieldFreerunBeginsInWrapper then
	local original = CoD.HUDUtility.MatchOrRoundBeginsIn
	CoD.HUDUtility.MatchOrRoundBeginsIn = function ( ... )
		if Engine[@"getdvarint"]( @"shield_freerun_match" ) == 1 then
			return @"shield/freerun_race_starting"
		end
		return original( ... )
	end
	CoD.ShieldFreerunBeginsInWrapper = CoD.HUDUtility.MatchOrRoundBeginsIn
end

-- CustomMapHud.lua wraps the HUD menus once and calls every watcher of this table with each new one
CoD.ShieldHudWatchers = CoD.ShieldHudWatchers or {}
CoD.ShieldHudWatchers.freerun = WatchFreerun

-- Zombies: its HUD is the map's own menu (T7Hud_<map>, or T7Hud_zm_factory), so the freerun HUD goes on the UI root
-- there. The root may come after this file: tried again after each require (as CustomMapHud.lua hooks the MP HUD).
local function WatchZombiesRoot()
	if not CoD.isZombie then
		return
	end
	local root = LUI.roots and LUI.roots.UIRoot0
	if not root or CoD.ShieldFreerunZMRoot == root then
		return
	end
	CoD.ShieldFreerunZMRoot = root
	local ok, err = pcall( WatchFreerun, root, 0 )
	if not ok then
		Log( "zombies root not watched: " .. tostring( err ) )
	end
end

-- the zombies map's HUD menu (T7Hud_<map>) kept as it's made: its parts are hidden in a freerun match
local function WrapZombiesHuds()
	if not CoD.isZombie or not LUI.createMenu then
		return
	end
	for name, create in pairs( LUI.createMenu ) do
		if type( create ) == "function" and type( name ) == "string" and string.sub( name, 1, 6 ) == "T7Hud_"
			and CoD["ShieldFreerunZMWrapped" .. name] ~= create then
			local wrapped = function ( ... )
				local hud = create( ... )
				if hud then
					CoD.ShieldFreerunZMHud = hud
				end
				return hud
			end
			LUI.createMenu[name] = wrapped
			CoD["ShieldFreerunZMWrapped" .. name] = wrapped
		end
	end
end

WatchZombiesRoot()
WrapZombiesHuds()

if not CoD.ShieldFreerunZMRequire then
	CoD.ShieldFreerunZMRequire = true
	local GameRequire = require
	require = function ( ... )
		local result = GameRequire( ... )
		WatchZombiesRoot()
		WrapZombiesHuds()
		return result
	end
end

-- a freerun match's map loads without its intro movie (Freerun.lua's Start sets the dvar), as the Enhancement mod's
-- StartingMovie.lua: the loading movie functions overridden and the movie stopped when this file loads
local function NoIntro()
	return Engine[@"getdvarint"]( "shield_freerun_nointro" ) == 1
end

local InZombies = not ( CoD.isFrontend or CoD.isMultiplayer or CoD.isWarzone )

if InZombies and CoD.HUDUtility and not CoD.ShieldFreerunNoIntro then
	CoD.ShieldFreerunNoIntro = true
	local IsMovieShowing = CoD.HUDUtility.IsMovieShowing
	CoD.HUDUtility.IsMovieShowing = function ( ... )
		if NoIntro() then
			return false
		end
		return IsMovieShowing( ... )
	end
	local InitLoadingImageOrMovie = CoD.HUDUtility.InitLoadingImageOrMovie
	CoD.HUDUtility.InitLoadingImageOrMovie = function ( image, controller, ... )
		if NoIntro() then
			Engine[@"setdvar"]( "ui_useloadingmovie", 0 )
			image:setImage( RegisterImage( MapNameToMapLoadingImage( controller, Engine[@"getcurrentmap"]() ) ) )
			image:setRGB( 1, 1, 1 )
			return
		end
		return InitLoadingImageOrMovie( image, controller, ... )
	end
	local StartPlay = CoD.HUDUtility.StartPlay
	CoD.HUDUtility.StartPlay = function ( ... )
		if NoIntro() then
			Engine[@"stop3dcinematic"]()
			Engine[@"setloadingmovieskippedstate"]( true )
			return
		end
		return StartPlay( ... )
	end
	local InitLoadingMovie = CoD.HUDUtility.InitLoadingMovie
	CoD.HUDUtility.InitLoadingMovie = function ( ... )
		if NoIntro() then
			return
		end
		return InitLoadingMovie( ... )
	end
end

if InZombies and NoIntro() then
	Engine[@"stop3dcinematic"]()
	Engine[@"setloadingmovieskippedstate"]( true )
end

-- the loading screen's gametype is the lobby's (zombies' private lobby: Classic); a freerun load says Freerun. A freerun
-- is loading once Freerun.lua's Start set shield_freerun_nointro (before the load), or g_gametype is one of ours
local function FreerunLoading( zombiesOnly )
	local gametype = Dvar[@"g_gametype"] and Dvar[@"g_gametype"]:get()
	return Engine[@"getdvarint"]( "shield_freerun_nointro" ) == 1 or gametype == "zfreerun" or ( not zombiesOnly and gametype == "freerun" )
end

if CoD.GameTypeUtility and CoD.GameTypeUtility.GetLocalizedGameTypeValue and CoD.GameTypeUtility.GetLocalizedGameTypeValue ~= CoD.ShieldFreerunNameWrapper then
	local getValue = CoD.GameTypeUtility.GetLocalizedGameTypeValue
	CoD.GameTypeUtility.GetLocalizedGameTypeValue = function ( gametype, field, ... )
		-- (zombies' only: a stale "freerun" from the main menu, the MP copy, named the lobby's Classic Freerun)
		if field == "nameRef" and ( gametype == "zclassic" or gametype == @"zclassic" ) and FreerunLoading( true ) then
			return getValue( "zfreerun", field, ... )
		end
		return getValue( gametype, field, ... )
	end
	CoD.ShieldFreerunNameWrapper = CoD.GameTypeUtility.GetLocalizedGameTypeValue
end

if DataSources.LoadingScreenTeamInfo and DataSources.LoadingScreenTeamInfo.getModel ~= CoD.ShieldFreerunLoadingWrapper then
	local getModel = DataSources.LoadingScreenTeamInfo.getModel
	DataSources.LoadingScreenTeamInfo.getModel = function ( controller, ... )
		local model = getModel( controller, ... )
		if model and FreerunLoading() then
			local name = CoD.GameTypeUtility.GetLocalizedGameTypeValue( "zfreerun", "nameRef", "" )
			if name and name ~= "" then
				Engine[@"setmodelvalue"]( Engine[@"createmodel"]( model, "gameType" ), name )
			end
		end
		return model
	end
	CoD.ShieldFreerunLoadingWrapper = DataSources.LoadingScreenTeamInfo.getModel
end

-- (the loading screen may be up before this file: its model filled again now)
if CoD.isZombie and FreerunLoading() and DataSources.LoadingScreenTeamInfo then
	pcall( DataSources.LoadingScreenTeamInfo.getModel, Engine[@"getprimarycontroller"]() )
end

-- the checkpoint's waypoint (Freerun.gsc's objective shield_freerun_waypoint, Waypoint_NoBackplate): its icon is the
-- objective's waypointImage as the engine names it, which drew nothing; ours, known by its minimap image, gets the
-- support zone's image by name
local WAYPOINT_ICON = @"shield_freerun_waypoint_icon"
local function IsFreerunWaypoint( objective )
	for _, value in ipairs( { objective[@"minimapimage"], objective.minimapimage } ) do
		if value == WAYPOINT_ICON or value == "shield_freerun_waypoint_icon" then
			return true
		end
	end
	return false
end
if CoD.HUDUtility and CoD.HUDUtility.ObjectiveUpdated and CoD.HUDUtility.ObjectiveUpdated ~= CoD.ShieldFreerunObjectiveWrapper then
	local updated = CoD.HUDUtility.ObjectiveUpdated
	local logged = false
	CoD.HUDUtility.ObjectiveUpdated = function ( menu, controller, objective, model, ... )
		local result = updated( menu, controller, objective, model, ... )
		if type( objective ) == "table" and model and model.icon and IsFreerunWaypoint( objective ) then
			if not logged then
				logged = true
				Log( "waypoint icon set (the engine's: " .. tostring( objective.waypoint_image ) .. ")" )
			end
			model.icon:set( WAYPOINT_ICON )
		end
		return result
	end
	CoD.ShieldFreerunObjectiveWrapper = CoD.HUDUtility.ObjectiveUpdated
end

--[[
	The checkpoint's waypoint widget, the objective shield_freerun_waypoint's (its bundle's "widget"; the HUD makes
	CoD[widget] for an objective, as the Enhancement mod's EnhObjective): the ring icon and the distance, hidden while
	the objective is invisible (between checkpoints, after the run). In every mode's HUD: escort's Waypoint_NoBackplate
	is MP's only, and the stock waypoints hid ours on their team check.
]]
CoD.ShieldFreerunWaypoint = InheritFrom( LUI.UIElement )
CoD.ShieldFreerunWaypoint.__defaultWidth = 120
CoD.ShieldFreerunWaypoint.__defaultHeight = 120
CoD.ShieldFreerunWaypoint.new = function ( menu, controller, f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	local self = LUI.UIElement.new( f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	self:setClass( CoD.ShieldFreerunWaypoint )
	self.id = "ShieldFreerunWaypoint"
	self.soundSet = "HUD"

	local icon = LUI.UIImage.new( 0.5, 0.5, -26, 26, 0.5, 0.5, -26, 26 )
	icon:setImage( RegisterImage( WAYPOINT_ICON ) )
	self:addElement( icon )
	self.icon = icon

	local distance = LUI.UIText.new( 0.5, 0.5, -60, 60, 0.5, 0.5, 30, 50 )
	distance:setTTF( "notosans_bold" )
	distance:setAlignment( Enum[@"luialignment"][@"lui_alignment_center"] )
	distance:setRGB( 1, 0.85, 0.2 )
	distance:setText( "" )
	self:addElement( distance )
	self.distance = distance

	distance:linkToElementModel( self, "distanceText", true, function ( model )
		local value = model:get()
		distance:setText( value ~= nil and LocalizeIntoStringIfNotEmpty( @"hash_37235825812D46C6", value ) or "" )
	end )
	self:linkToElementModel( self, "state", true, function ( model )
		local state = model:get()
		self:setAlpha( state == Enum[@"objectivestate_t"][@"objst_invisible"] and 0 or 1 )
	end )

	LUI.OverrideFunction_CallOriginalSecond( self, "close", function ( element )
		element.icon:close()
		element.distance:close()
	end )
	return self
end
