--[[
		.\hksc.exe ".\Lua\Frontend Side\Custom Maps\CustomMaps.lua" -o "C:\Program Files (x86)\Call of Duty Black Ops 4\project-bo4\internals\T8ShieldSupport\Lua\Frontend\CustomMaps.luac"
]]

---------------------------

CoD.ShieldInitLuaFile()

---------------------------

--[[
	The classic tab of the zombies map select in two sections: the game's maps, then the custom maps. shield-client gives
	each custom map (a zone_mods fastfile with "map_info") a map table entry and playlists of its own, so the game's list
	has them already; here they are moved to a list of their own under it. The client names them: shield_custom_maps →
	CoD.Shield.CustomMapsList( { maps = { { map, image, aarImage, storyIndex, storyText } } } ).
]]
CoD.ShieldCustomMaps = CoD.ShieldCustomMaps or { byHash = {}, items = {}, baseCount = 0 }

CoD.Shield.CustomMapsList = function ( event_name, event_table )
	local byHash = {}

	if type( event_table ) == "table" and type( event_table.maps ) == "table" then
		for _, map in ipairs( event_table.maps ) do
			if type( map ) == "table" and type( map.map ) == "string" then
				byHash[CoD.MapUtility.ConvertMapNameToXHash( map.map )] = map
			end
		end
	end

	CoD.ShieldCustomMaps.byHash = byHash

	if CoD.ShieldWrapPlaylistInfo then
		CoD.ShieldWrapPlaylistInfo()
	end
end

Engine[@"exec"]( Engine[@"getprimarycontroller"](), "shield_custom_maps" )

---------------------------

-- the custom map a playlist plays, nil for another
local function CustomMapOfPlaylist( id )
	local info = id and Engine[@"getplaylistinfobyid"]( id )
	local rotations = info and info.rotationList

	if type( rotations ) ~= "table" or #rotations ~= 1 or rotations[1].map == nil then
		return nil
	end

	return CoD.ShieldCustomMaps.byHash[CoD.MapUtility.ConvertMapNameToXHash( rotations[1].map )]
end

--[[
	The stats of the custom maps. The game's per map stats (PlayerStatsByMap) only have room for its 8 maps, so shield-client
	keeps the custom maps' in a file of its own (custom_map_stats.cpp: the GSC's map stats of the local player) and gives
	them with ShieldFuncs.CustomMapStat( map, beforeMatch, <PlayerStatsByMap[map]'s path> ). Without it (an older client)
	a custom map's stats are 0.
]]
local function CustomMapStat( map, before, ... )
	if ShieldFuncs == nil or ShieldFuncs.CustomMapStat == nil then
		return 0
	end

	return ShieldFuncs.CustomMapStat( map, before, ... ) or 0
end

local function IsCustomMap( map )
	return map ~= nil and ShieldFuncs ~= nil and ShieldFuncs.IsCustomMap ~= nil and ShieldFuncs.IsCustomMap( map )
end

-- a time stat (ms) as the map select writes it, mm:ss or hh:mm:ss
local function TimeString( ms )
	local seconds = math.floor( ms / 1000 )
	local hours = math.floor( seconds / 3600 )
	seconds = seconds - hours * 3600
	local minutes = math.floor( seconds / 60 )
	seconds = seconds - minutes * 60

	if hours ~= 0 and hours < 10 then
		hours = "0" .. hours
	end

	if minutes < 10 then
		minutes = "0" .. minutes
	end

	if seconds < 10 then
		seconds = "0" .. seconds
	end

	if hours == 0 then
		return Engine[@"hash_4F9F1239CFD921FE"]( @"hash_5DA15869CF160D19", minutes, seconds )
	end

	return Engine[@"hash_4F9F1239CFD921FE"]( @"hash_407967DE7F4AADC1", hours, minutes, seconds )
end

--[[
	The map select's info panel (UpdateZMPlaylistInfo) only writes the stats of a map the game has stats of, so a custom
	map kept the last map's: it gets its own, the classic tab's best of its difficulty. The pictures need nothing here,
	the client gives the custom map's playlists its "image" as their tile images. The game loads CoD.ZombieUtility again
	after the first boot (ReloadOverrides.lua), which drops the wraps: they are put back on the client's list, every fill
	of the map select and ReloadOverrides.
]]
local PlaylistInfoWrapper = nil
local OfflineInfoWrapper = nil
local RoundStatsWrapper = nil
local AARImageWrapper = nil

--[[
	A custom map's story (the client's "story"): Chaos or Aether is the map entry's story value (0 or 1) in the menus' two
	maps tables, which the map select's story line and the story the menus pick read; a story of its own is a localize
	entry of the client (storyText) shown on the story line in their place.
]]
local StoryKey = @"hash_3A3627D705B66CDE"

local function ApplyStories()
	for hash, custom in pairs( CoD.ShieldCustomMaps.byHash ) do
		if type( custom.storyIndex ) == "number" and custom.storyIndex >= 0 then
			if CoD.MapUtility and CoD.MapUtility.MapsTable and CoD.MapUtility.MapsTable[hash] then
				CoD.MapUtility.MapsTable[hash][StoryKey] = custom.storyIndex
			end

			if CoD.mapsTable and CoD.mapsTable[hash] then
				CoD.mapsTable[hash][StoryKey] = custom.storyIndex
			end
		end
	end
end

-- the story line of a custom map with a story of its own
local function SetOwnStory( custom )
	if custom and type( custom.storyText ) == "string" and custom.storyText ~= "" then
		Engine[@"getglobalmodel"]():create( "DirectorZMPlaylistInfo" ).storyDesc:set( Engine[@"converttoxhash"]( custom.storyText ) )
	end
end

local function WrapPlaylistInfo()
	ApplyStories()

	-- ReloadOverrides.lua loads after this file
	if CoD.ReloadOverrides ~= nil and not CoD.ShieldCustomMapsReload then
		local reload = CoD.ReloadOverrides
		CoD.ShieldCustomMapsReload = true

		CoD.ReloadOverrides = function ( ... )
			reload( ... )
			CoD.ShieldWrapPlaylistInfo()
		end
	end

	local original = CoD.ZombieUtility and CoD.ZombieUtility.UpdateZMPlaylistInfo

	if original ~= nil and original ~= PlaylistInfoWrapper then
		PlaylistInfoWrapper = function ( controller, id, tab, difficulty, ... )
			original( controller, id, tab, difficulty, ... )

			local custom = CustomMapOfPlaylist( id )
			SetOwnStory( custom )

			if not custom or tab ~= @"zclassic" then
				return
			end

			local info = Engine[@"getglobalmodel"]():create( "DirectorZMPlaylistInfo" )
			local playlist = Engine[@"getplaylistinfobyid"]( id )
			local gametype = Engine[@"hash_1F2CD89B3C345FD3"]( playlist.rotationList[1].gametype ).gametype

			-- the difficulty's best, the gametype's without one
			local function stat( name )
				if type( difficulty ) ~= "number" then
					return CustomMapStat( custom.map, false, "statsByGameType", gametype, "stats", name, "statValue" )
				end

				return CustomMapStat( custom.map, false, "statsByGameType", gametype, "statsByDifficulty", difficulty, "stats", name, "statValue" )
			end

			info.statInt1:set( stat( "MOST_KILLS" ) )
			info.statInt2:set( stat( "MOST_HEADSHOTS" ) )
			info.statInt3:set( stat( "HIGHEST_ROUND_REACHED" ) )
			info.statInt4:set( stat( "MAIN_QUEST_COMPLETED" ) )

			local time = stat( "FASTEST_QUEST_COMPLETION_TIME" )

			if time == 0 then
				info.statTimeString1:set( Engine[@"toupper"]( Engine[@"hash_4F9F1239CFD921FE"]( @"hash_2791826DA0652E1A" ) ) )
			else
				info.statTimeString1:set( TimeString( time ) )
			end
		end

		CoD.ZombieUtility.UpdateZMPlaylistInfo = PlaylistInfoWrapper
	end

	-- the solo / offline map list's info panel (UpdateZMOfflineInfo: controller, map, gametype, difficulty, element)
	local offline = CoD.ZombieUtility and CoD.ZombieUtility.UpdateZMOfflineInfo

	if offline ~= nil and offline ~= OfflineInfoWrapper then
		OfflineInfoWrapper = function ( controller, map, ... )
			offline( controller, map, ... )

			if map ~= nil then
				SetOwnStory( CoD.ShieldCustomMaps.byHash[CoD.MapUtility.ConvertMapNameToXHash( map )] )
			end
		end

		CoD.ZombieUtility.UpdateZMOfflineInfo = OfflineInfoWrapper
	end

	--[[
		The end screen's all-time stats (GetZMRoundStats: allTimeKills, highestRound, averageRound, ...) read
		PlayerStatsByMap[map] and fall back to 1000000 for a map without: a custom map had 1000000 kills, headshots and
		highest round, average round 1. They are its own here, PlayerStatsByMap[map].statsByGameType[gametype].stats's as
		the game reads them; the match's stats (the AAR's) are the game's.
	]]
	local roundStats = CoD.ZombieUtility and CoD.ZombieUtility.GetZMRoundStats

	if roundStats ~= nil and roundStats ~= RoundStatsWrapper then
		RoundStatsWrapper = function ( controller, ... )
			local stats = roundStats( controller, ... )
			local map = CoD.AARUtility.GetCurrentMapName( controller ) or Engine[@"lobbygetmap"]()

			if type( stats ) ~= "table" or CoD.AARUtility.UseTestData() or not IsZombies() or not IsCustomMap( map ) then
				return stats
			end

			local gametype = CoD.AARUtility.GetCurrentGametype( controller ) or Engine[@"hash_36F8027A8BC75673"]()

			local function stat( name, before )
				return CustomMapStat( map, before == true, "statsByGameType", gametype, "stats", name, "statValue" )
			end

			local function time( name )
				return CoD.AARUtility.SecondsToHoursMinutesSecondsString( math.floor( stat( name ) / 1000 ) )
			end

			stats.allTimeKills = stat( "MOST_KILLS" )
			stats.allTimeHeadshots = stat( "MOST_HEADSHOTS" )
			stats.highestRound = stat( "HIGHEST_ROUND_REACHED" )
			stats.averageRound = math.ceil( stat( "TOTAL_ROUNDS_SURVIVED" ) / math.max( 1, stat( "TOTAL_GAMES_PLAYED" ) ) )
			stats.allTimeTeamScore = stat( "HIGHEST_TEAM_SCORE" )
			stats.allTimeHighestMultiplier = stat( "HIGHEST_MULTIPLIER" )
			stats.allTimeScore = stat( "HIGHEST_SCORE" )
			stats.fastestToRound10 = time( "FASTEST_TIME_TO_ROUND_10" )
			stats.fastestToRound20 = time( "FASTEST_TIME_TO_ROUND_20" )
			stats.fastestToCompletion = time( "FASTEST_TIME_TO_COMPLETE_ROUND_30" )

			-- round 30 completed: its best time, new when it beat the one before the match
			local completion = stat( "FASTEST_TIME_TO_COMPLETE_ROUND_30" )
			local completionBefore = stat( "FASTEST_TIME_TO_COMPLETE_ROUND_30", true )
			local highestBefore = stat( "HIGHEST_ROUND_REACHED", true )

			stats.highestRoundCompleted = completion ~= 0 and 30 or math.max( 0, stats.highestRound - 1 )
			stats.prevHighestRoundCompleted = completionBefore ~= 0 and 30 or math.max( 0, highestBefore - 1 )
			stats.isNewBestTime = completion ~= 0 and (completionBefore == 0 or completion < completionBefore) and 1 or ""
			stats.isNewHighestRound = highestBefore < stats.highestRound and 1 or ""
			stats.isTrialComplete = (tonumber( stats.roundsCompleted ) or 0) >= 30 and 1 or ""

			return stats
		end

		CoD.ZombieUtility.GetZMRoundStats = RoundStatsWrapper
	end

	-- the end screen's map picture (the map table's bigPreviewImage, the base map's): the client's "aar_image", its "image" without
	local aarImage = CoD.MapUtility and CoD.MapUtility.MapNameToMapAARImage

	if aarImage ~= nil and aarImage ~= AARImageWrapper then
		AARImageWrapper = function ( map, ... )
			local custom = map ~= nil and CoD.ShieldCustomMaps.byHash[CoD.MapUtility.ConvertMapNameToXHash( map )]

			if custom and type( custom.aarImage ) == "string" and custom.aarImage ~= "" then
				return custom.aarImage
			end

			return aarImage( map, ... )
		end

		CoD.MapUtility.MapNameToMapAARImage = AARImageWrapper
	end
end

CoD.ShieldWrapPlaylistInfo = WrapPlaylistInfo
WrapPlaylistInfo()

---------------------------

local MapListName = "DirectorPlaylistMapList"
local CustomListName = "ShieldCustomMapList"

-- the models of a map select entry (DirectorPlaylistMapList), copied for the custom list
local EntryModels = {
	"id", "playlistID", "text", "buttonText", "image", "imageLarge", "tileImage", "playlistDesc", "isFeatured",
	"playlist", "name", "icon", "iconBackground", "iconBackgroundFocus", "mode", "locked", "lockState", "featured",
	"maxPartySize", "hasDoubleXP", "hasDoubleWeaponXP", "hasDoubleNP", "showForAllClients", "trialVariant", "trialName"
}

-- the custom map an entry is, nil for a game map
local function CustomMapOf( item )
	local map = item.properties and item.properties.mapName

	if map == nil then
		return nil
	end

	return CoD.ShieldCustomMaps.byHash[CoD.MapUtility.ConvertMapNameToXHash( map )]
end

-- a row of the custom list from an entry of the game's list: its models and properties
local function CustomRow( item )
	local models = {}

	for _, name in ipairs( EntryModels ) do
		local model = Engine[@"getmodel"]( item.model, name )

		if model ~= nil then
			models[name] = model:get()
		end
	end

	local properties = {}

	for key, value in pairs( item.properties ) do
		properties[key] = value
	end

	properties.rowSpan = 1

	return { models = models, properties = properties }
end

-- the game's list without the custom maps, which go to CoD.ShieldCustomMaps.items
local function SplitCustomMaps( list )
	local items = list[MapListName]
	local tab = Engine[@"getglobalmodel"]():create( "ZMLobbyExclusions.ZMPlaylistTab" ):get()
	local base = {}
	local custom = {}

	if type( items ) ~= "table" then
		return
	end

	for _, item in ipairs( items ) do
		local map = tab == @"zclassic" and CustomMapOf( item ) or nil

		if map ~= nil then
			table.insert( custom, CustomRow( item ) )
		else
			table.insert( base, item )
		end
	end

	list[MapListName] = base
	CoD.ShieldCustomMaps.items = custom
	CoD.ShieldCustomMaps.baseCount = #base
end

--[[
	A vanilla bug: an entry's "locked" is nil when the map isn't locked, and the list's rows keep their models from the last
	fill, so a row keeps the lock of the entry it showed before. Beginners (locked above level 20) on the public tab locked
	the classic map that took its row (Dead of the Night). The rows are unlocked before every fill.
]]
local function UnlockRows( controller )
	local root = Engine[@"getmodel"]( Engine[@"getmodelforcontroller"]( controller ), MapListName )

	if root == nil then
		return
	end

	for index = 1, 100 do
		local row = Engine[@"getmodel"]( root, index )

		if row == nil then
			break
		end

		local locked = Engine[@"getmodel"]( row, "locked" )

		if locked ~= nil then
			locked:set( false )
		end
	end
end

local source = DataSources[MapListName]

if source ~= nil and not source.shieldCustomMaps then
	local prepare = source.prepare
	source.shieldCustomMaps = true

	source.prepare = function ( controller, list, filter )
		-- no list yet (asked at the boot, before the client could tell it): asked again, it comes for the next fill
		if next( CoD.ShieldCustomMaps.byHash ) == nil then
			Engine[@"exec"]( Engine[@"getprimarycontroller"](), "shield_custom_maps" )
		end

		UnlockRows( controller )
		prepare( controller, list, filter )
		SplitCustomMaps( list )
		CoD.ShieldWrapPlaylistInfo()

		-- the map select's own list: its custom section follows
		if list.shieldCustomSection then
			list.shieldCustomSection()
		end
	end
end

DataSources[CustomListName] = DataSourceHelpers.ListSetup( CustomListName, function ( controller, list )
	return CoD.ShieldCustomMaps.items
end, true )

---------------------------

-- the stock layout (3e8634856f115c55.lua): the maps from x 97 to 1141, rows of 104 with 20 between, the list at y 282
local LEFT = 97
local RIGHT = 1141
local MAPS_TOP = 282
local ROW = 104
local SPACING = 20
local COLUMNS = 4
-- the info panel ends there
local BOTTOM = 944
-- the game's maps and both titles move down this much while the sections show
local OFFSET = 30

local function Plural( count )
	return count == 1 and "1 MAP" or ( tostring( count ) .. " MAPS" )
end

-- a section's title: its name, its count on the right and a line under them
local function NewSectionTitle( parent, id )
	local UI = CoD.Shield.BrowserUI
	local title = {}

	title.Name = UI.NewText( LEFT, RIGHT, 0, 22, "notosans_bold" )
	title.Name:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )
	title.Count = UI.NewCaption( LEFT, RIGHT, 0, "", Enum[@"luialignment"][@"lui_alignment_right"] )
	title.Line = UI.NewBox( LEFT, RIGHT, 0, 1, 1, 1, 1, 0.12 )

	for name, element in pairs( title ) do
		parent:addElement( element )
		parent[id .. name] = element
	end

	-- the top of the title: its parts move together
	title.place = function ( top, alpha )
		title.Name:setTopBottom( 0, 0, top, top + 22 )
		title.Count:setTopBottom( 0, 0, top + 5, top + 20 )
		title.Line:setTopBottom( 0, 0, top + 26, top + 27 )
		title.Name:setAlpha( alpha )
		title.Count:setAlpha( alpha )
		title.Line:setAlpha( alpha * 0.12 )
	end

	return title
end

-- the custom list: the map select item of the game's list, with its focus, info panel and confirm
local function NewCustomList( self, menu, controller )
	local list = LUI.UIList.new( menu, controller, SPACING, 0, nil, false, false, false, false )
	list:setLeftRight( 0, 0, LEFT, RIGHT )
	list:setTopBottom( 0, 0, MAPS_TOP, MAPS_TOP + ROW )
	list:setAlpha( 0 )
	list:setWidgetType( CoD.DirectorZMMapSelectItem )
	list:setHorizontalCount( COLUMNS )
	list:setVerticalCount( 3 )
	list:setSpacing( SPACING )
	list:setAlignment( Enum[@"luialignment"][@"lui_alignment_left"] )
	list:setVerticalCounter( CoD.verticalCounter )
	list:setDataSource( CustomListName )

	list:registerEventHandler( "list_item_gain_focus", function ( element, event )
		CoD.ZombieUtility.UpdateFocusedPlaylistID( controller, element )
		return nil
	end )

	list:registerEventHandler( "gain_focus", function ( element, event )
		local result = nil

		if element.gainFocus then
			result = element:gainFocus( event )
		elseif element.super.gainFocus then
			result = element.super:gainFocus( event )
		end

		CoD.Menu.UpdateButtonShownState( element, menu, controller, Enum[@"luibutton"][@"lui_key_xba_pscross"] )
		return result
	end )

	menu:AddButtonCallbackFunction( list, controller, Enum[@"luibutton"][@"lui_key_xba_pscross"], "ui_confirm", function ( element, menu, controller, model )
		if IsLobbyHostOfCurrentMenu() and not IsElementPropertyValue( element, "purchasable", true ) and not CoD.ModelUtility.IsSelfModelValueTrue( element, controller, "locked" ) then
			CoD.DirectorUtility.SetPlaylist( controller, element )
			PlaySoundSetSound( self, "action" )
			GoBack( self, controller )
			return true
		end
	end, function ( element, menu, controller )
		-- a menu that closed has no buttons
		if not menu or not menu.buttonModel then
			return false
		end

		if IsLobbyHostOfCurrentMenu() and not IsElementPropertyValue( element, "purchasable", true ) and not CoD.ModelUtility.IsSelfModelValueTrue( element, controller, "locked" ) then
			CoD.Menu.SetButtonLabel( menu, Enum[@"luibutton"][@"lui_key_xba_pscross"], @"menu/select", nil, "ui_confirm" )
			return true
		end

		return false
	end, false )

	self:addElement( list )
	self.CustomMaps = list
	list.id = "CustomMaps"

	return list
end

-- the classic tab's two sections, put in the map select as it is made
local function AddCustomSection( self, menu, controller )
	if self.CustomMaps or not self.Maps or not CoD.Shield.BrowserUI then
		return
	end

	local baseTitle = NewSectionTitle( self, "BaseMaps" )
	local customTitle = NewSectionTitle( self, "CustomMapsTitle" )
	local list = NewCustomList( self, menu, controller )

	baseTitle.Name:setText( "BASE GAME MAPS" )
	customTitle.Name:setText( "CUSTOM MAPS" )

	-- after every fill of the game's list: the sections on the classic tab, nothing of them on the others
	local function Layout()
		local classic = Engine[@"getglobalmodel"]():create( "ZMLobbyExclusions.ZMPlaylistTab" ):get() == @"zclassic"
		local baseCount = CoD.ShieldCustomMaps.baseCount
		local customCount = #CoD.ShieldCustomMaps.items
		local sections = classic and customCount > 0

		list:updateDataSource()

		-- the game's maps move down under their title, back to their place on the other tabs
		local mapsTop = sections and MAPS_TOP + OFFSET or MAPS_TOP
		self.Maps:setTopBottom( 0, 0, mapsTop, mapsTop + 600 )

		baseTitle.Count:setText( Plural( baseCount ) )
		baseTitle.place( mapsTop - 34, sections and 1 or 0 )

		local baseRows = math.max( 1, math.ceil( baseCount / COLUMNS ) )
		local customTop = mapsTop + baseRows * ( ROW + SPACING ) + 10
		local rows = math.max( 1, math.min( math.ceil( customCount / COLUMNS ), math.floor( ( BOTTOM - customTop - 40 + SPACING ) / ( ROW + SPACING ) ) ) )

		customTitle.Count:setText( Plural( customCount ) )
		customTitle.place( customTop, sections and 1 or 0 )
		list:setTopBottom( 0, 0, customTop + 40, customTop + 40 + rows * ROW + ( rows - 1 ) * SPACING )
		list:setAlpha( sections and 1 or 0 )
	end

	self.Maps.shieldCustomSection = Layout
	Layout()

	-- closed with the map select, as it closes its own lists: else its buttons outlive the menu (UI error, nil buttonModel)
	LUI.OverrideFunction_CallOriginalSecond( self, "close", function ( element )
		if element.Maps then
			element.Maps.shieldCustomSection = nil
		end

		if element.CustomMaps then
			element.CustomMaps:close()
		end
	end )
end

local function WrapMapSelect()
	local class = CoD.DirectorGamemodeSelectionZMInternal

	if class == nil or class.shieldCustomMaps then
		return class ~= nil
	end

	local new = class.new
	class.shieldCustomMaps = true

	class.new = function ( menu, controller, ... )
		local self = new( menu, controller, ... )
		AddCustomSection( self, menu, controller )
		return self
	end

	return true
end

-- the map select may be loaded after this file: wrapped when its menu is defined
if not WrapMapSelect() then
	local menus = LUI.createMenu
	local meta = getmetatable( menus ) or {}
	local newindex = meta.__newindex

	meta.__newindex = function ( t, key, value )
		if newindex then
			newindex( t, key, value )
		else
			rawset( t, key, value )
		end

		if key == "DirectorGamemodeSelectionZM" then
			WrapMapSelect()
		end
	end

	setmetatable( menus, meta )
end
