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
	CoD.Shield.CustomMapsList( { maps = { { map, image } } } ).
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
	The map select's info panel (UpdateZMPlaylistInfo) only writes the stats of a map the player has stats of, so a custom
	map kept the last map's: it gets empty ones. The pictures need nothing here, the client gives the custom map's
	playlists its "image" as their tile images. The game loads CoD.ZombieUtility again after the first boot
	(ReloadOverrides.lua), which drops the wrap: it is put back on the client's list, every fill of the map select and
	ReloadOverrides.
]]
local PlaylistInfoWrapper = nil

local function WrapPlaylistInfo()
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

	if original == nil or original == PlaylistInfoWrapper then
		return
	end

	PlaylistInfoWrapper = function ( controller, id, tab, difficulty, ... )
		original( controller, id, tab, difficulty, ... )

		local custom = CustomMapOfPlaylist( id )

		if not custom or tab ~= @"zclassic" then
			return
		end

		local stats = CoD.GetPlayerStats( controller )

		if stats == nil or not stats.PlayerStatsByMap[CoD.MapUtility.ConvertMapNameToXHash( custom.map )] then
			local info = Engine[@"getglobalmodel"]():create( "DirectorZMPlaylistInfo" )

			info.statInt1:set( 0 )
			info.statInt2:set( 0 )
			info.statInt3:set( 0 )
			info.statInt4:set( 0 )
			info.statTimeString1:set( Engine[@"toupper"]( Engine[@"hash_4F9F1239CFD921FE"]( @"hash_2791826DA0652E1A" ) ) )
		end
	end

	CoD.ZombieUtility.UpdateZMPlaylistInfo = PlaylistInfoWrapper
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

local source = DataSources[MapListName]

if source ~= nil and not source.shieldCustomMaps then
	local prepare = source.prepare
	source.shieldCustomMaps = true

	source.prepare = function ( controller, list, filter )
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
