if not CoD.isFrontend then
	return
end

CoD.ShieldInitLuaFile()

---------------------------

--[[
	Character menu categories: Zombies | Multiplayer | Blackout | Custom, in every mode's characters menu.
	A character's category: ours (the support zone's, the maps' crews) the client's ShieldFuncs.CharacterCategory (its config
	"category", else the game table its outfits come from, else custom: Wesker, Kagan, Jacket, Freddy...); the game's own
	the menu's mode, in Blackout its role bundle's modecategory (the game's own tabs go by that).
	- Multiplayer / zombies (StartMenu_Personalization_MP / _ZM in DirectorPersonalizeCharacterMP / ZMPersonalizeCharacterMain,
	  the PositionLoadoutList grid): Blackout's tab bar (Common_Tabbar_Center, Q / E and the bumpers) over the grid, the grid
	  filtered to the tab's category (its list filter, this list only).
	- Blackout (WZCharacterCategories: StartMenu_Personalization_WZ, WZPersonalizeCharacterMain, the lobby's change character):
	  the game's three tabs plus Custom (a copy of the Multiplayer tab). Each tab's characters come from the game's own list
	  makers (CreateCharacterCategoryDataSource, one per bundle category) given only the characters of that category.
]]

local ZOMBIES = Enum[@"emodes"][@"mode_zombies"]
local MULTIPLAYER = Enum[@"emodes"][@"mode_multiplayer"]
local WARZONE = Enum[@"emodes"][@"mode_warzone"]
-- (the client's number for custom: campaign's, which no character menu has)
local CUSTOM = 2

-- the tabs' order: multiplayer / zombies, Blackout
local ORDER = { ZOMBIES, MULTIPLAYER, WARZONE, CUSTOM }
local WZ_ORDER = { WARZONE, ZOMBIES, MULTIPLAYER, CUSTOM }

-- the tabs' names (Blackout's own)
local NAMES = {
	[ZOMBIES] = @"menu/zombies",
	[MULTIPLAYER] = @"menu/multiplayer",
	[WARZONE] = @"menu/warzone",
	[CUSTOM] = @"shield/character_category_custom"
}

-- the game's roles per mode (an older client without CharacterCategory: those after are ours, all custom)
local STOCK_ROLES = {
	[ZOMBIES] = 30,
	[MULTIPLAYER] = 17,
	[WARZONE] = 76
}

local function Log( text )
	Engine[@"printinfo"]( 0, "[shield] character categories: " .. text .. "\n" )
end

local function Category( mode, index )
	if index == nil then
		return mode
	end
	if ShieldFuncs ~= nil and ShieldFuncs.CharacterCategory ~= nil then
		local ours = ShieldFuncs.CharacterCategory( mode, index )
		if ours ~= nil then
			return ours
		end
	elseif STOCK_ROLES[mode] and index >= STOCK_ROLES[mode] then
		return CUSTOM
	end
	if mode == WARZONE then
		local bundle = Engine[@"getpositionrolebundleinfo"]( mode, index )
		local category = bundle and bundle[@"modecategory"]
		if category == ZOMBIES or category == MULTIPLAYER then
			return category
		end
		return WARZONE
	end
	return mode
end

-- the categories a mode has characters in, in order
local function UsedCategories( mode, order )
	local used = {}
	for _, hero in ipairs( Engine[@"getherolist"]( mode ) or {} ) do
		if hero.bodyIndex then
			used[Category( mode, hero.bodyIndex )] = true
		end
	end
	local list = {}
	for _, category in ipairs( order ) do
		if used[category] then
			table.insert( list, category )
		end
	end
	return list
end

-- the category a menu opens on (per mode, kept while the game runs): the last picked, else the equipped character's
CoD.ShieldCharacterCategory = CoD.ShieldCharacterCategory or {}

local function StartCategory( controller, mode, used )
	local wanted = CoD.ShieldCharacterCategory[mode]
	if wanted == nil then
		local ok, equipped = pcall( Engine[@"getequippedhero"], controller, mode )
		wanted = ok and equipped and Category( mode, equipped ) or mode
	end
	for _, category in ipairs( used ) do
		if category == wanted then
			return wanted
		end
	end
	for _, category in ipairs( used ) do
		if category == mode then
			return mode
		end
	end
	return used[1]
end

---------------------------
-- multiplayer / zombies: Blackout's tab bar over the grid

local TAB_SOURCE = "ShieldCharacterCategories"

-- the grids' edges (StartMenu_Personalization_ZM's, _MP's), the tab bar centred over them
local GRID_EDGES = {
	[ZOMBIES] = { -589, 55 },
	[MULTIPLAYER] = { -593, 215 }
}
-- Blackout's tab bar: 708 wide, from -340.5 to -279.5, its line under it
local TABS_HALF_WIDTH = 354
local TABS_TOP = -340.5
local TABS_BOTTOM = -279.5

-- the tabs of the grid being made (one character menu open at a time)
local function MakeTabSource()
	if DataSources[TAB_SOURCE] then
		return
	end
	DataSources[TAB_SOURCE] = DataSourceHelpers.ListSetup( TAB_SOURCE, function ( controller, list )
		local items = {}
		for _, category in ipairs( list.shieldCategories or {} ) do
			table.insert( items, {
				models = {
					name = NAMES[category],
					category = category
				},
				properties = {
					selectIndex = category == list.shieldStartCategory
				}
			} )
		end
		return items
	end )
end

-- the grid emptied and filled again with the category's characters, its first one active (focused when the grid was)
local function RefreshList( list )
	local focused = false
	pcall( function ()
		focused = list.activeWidget ~= nil and list.activeWidget:isInFocus()
	end )
	list:clearLayout()
	list:clearSavedActiveIndex()
	list:updateDataSource()
	pcall( function ()
		list:getFirstSelectableItem( true )
		if focused then
			list:giveFocusToActiveWidget()
		end
	end )
end

local function AddTabs( self, menu, controller )
	local list = self.specialists
	if not list or self.ShieldCategoryTabs or not CoD.Common_Tabbar_Center then
		return
	end
	local mode = CoD.BaseUtility.GetMenuSessionMode( menu ) or Engine[@"currentsessionmode"]()
	local edges = GRID_EDGES[mode]
	local used = UsedCategories( mode, ORDER )
	if not edges or #used < 2 then
		return
	end
	MakeTabSource()

	local current = StartCategory( controller, mode, used )

	-- the grid's own filter (zombies: characters with customization) and the category's
	local gameFilter = list.filter
	list.filter = function ( model )
		if gameFilter and not gameFilter( model ) then
			return false
		end
		local index = model.characterIndex and model.characterIndex:get()
		return Category( mode, index ) == current
	end

	local center = ( edges[1] + edges[2] ) / 2
	local tabs = CoD.Common_Tabbar_Center.new( menu, controller, 0.5, 0.5, center - TABS_HALF_WIDTH, center + TABS_HALF_WIDTH, 0.5, 0.5, TABS_TOP, TABS_BOTTOM )
	tabs.Tabs.grid.shieldCategories = used
	tabs.Tabs.grid.shieldStartCategory = current
	tabs.Tabs.grid:setHorizontalCount( #used )
	tabs.Tabs.grid:setDataSource( TAB_SOURCE )
	self:addElement( tabs )
	-- (the menu finds what takes the focus as parent[id])
	tabs.id = "ShieldCategoryTabs"
	self.ShieldCategoryTabs = tabs

	local line = LUI.UIImage.new( 0.5, 0.5, edges[1], edges[2], 0.5, 0.5, TABS_BOTTOM - 2, TABS_BOTTOM + 2 )
	line:setAlpha( 0.08 )
	line:setImage( RegisterImage( @"uie_ui_menu_common_tab_line_bottom" ) )
	self:addElement( line )
	self.ShieldCategoryTabLine = line

	-- the active tab's category: the grid shows its characters
	tabs:linkToElementModel( tabs.Tabs.grid, "category", true, function ( model )
		local category = model:get()
		if category == nil or category == current then
			return
		end
		current = category
		CoD.ShieldCharacterCategory[mode] = category
		RefreshList( list )
	end )

	-- (filled already when the widget came after the menu opened: again with the filter, keeping the game's pick)
	if list.prepared then
		list:updateDataSource()
	end
end

local function WrapWidget( widget )
	-- (a flag on the widget's table, not the function: another file wrapping new as well would wrap again each require)
	if not widget or widget.shieldCategories then
		return
	end
	widget.shieldCategories = true
	local gameNew = widget.new
	widget.new = function ( menu, controller, ... )
		local self = gameNew( menu, controller, ... )
		local ok, err = pcall( AddTabs, self, menu, controller )
		if not ok then
			Log( "tabs not added: " .. tostring( err ) )
		end
		return self
	end
	Log( "character list wrapped" )
end

---------------------------
-- Blackout: the game's tabs by category, and Custom

-- a hero list given out once with only some characters (the next GetHeroList call: a list maker's own)
local HeroFilter = nil

local function WrapHeroList()
	local utility = CoD.PlayerRoleUtility
	if not utility or not utility.GetHeroList or utility.shieldCategoryHeroes then
		return
	end
	utility.shieldCategoryHeroes = true
	local gameHeroes = utility.GetHeroList
	utility.GetHeroList = function ( mode, ... )
		local heroes = gameHeroes( mode, ... )
		local filter = HeroFilter
		if not filter or not heroes then
			return heroes
		end
		HeroFilter = nil
		local kept = {}
		for _, hero in ipairs( heroes ) do
			if filter( hero ) then
				table.insert( kept, hero )
			end
		end
		return kept
	end
end

-- the game's list maker of each bundle category (CreateCharacterCategoryDataSource's), caught as it makes its data source
local Builders = {}

-- the game's order in a tab: buyable first, then not disabled, then by sortIndex
local function SortTab( a, b )
	if a.properties.purchasable ~= b.properties.purchasable then
		if not a.models.disabled then
			return b.properties.purchasable and true or false
		end
		return a.properties.purchasable and true or false
	elseif a.models.disabled ~= b.models.disabled then
		return b.models.disabled and true or false
	end
	return ( a.properties.sortIndex or 0 ) < ( b.properties.sortIndex or 0 )
end

--[[
	The character grid (CharacterSelection_StandardFrameWidget's, anchored right) sizes itself to its items (setWidth), which
	keeps its right edge: a tab of fewer than a row (Custom's three) sat right with a gap before it. Its left edge kept at
	where a full row starts instead.
]]
local function KeepLeftEdge( list )
	if list.shieldLeftEdge ~= nil then
		return
	end
	list.shieldLeftEdge = false
	local leftAnchor, rightAnchor, _, right = list:getLocalLeftRight()
	local width = list.widgetType and list.widgetType.__defaultWidth
	if leftAnchor ~= 1 or rightAnchor ~= 1 or not width or not list.hCount then
		return
	end
	local edge = right - ( list.hCount * width + ( list.hCount - 1 ) * ( list.spacing or 0 ) )
	list.shieldLeftEdge = edge
	local setWidth = list.setWidth
	list.setWidth = function ( self, newWidth, ... )
		local result = setWidth( self, newWidth, ... )
		self:setLeftRight( 1, 1, edge, edge + newWidth )
		return result
	end
end

-- a tab's characters: every list maker's, given only the characters of its category
local function BuildTab( category, controller, list )
	local ok, err = pcall( KeepLeftEdge, list )
	if not ok then
		Log( "grid edge not kept: " .. tostring( err ) )
	end
	local items = {}
	for _, kind in ipairs( { WARZONE, ZOMBIES, MULTIPLAYER } ) do
		local build = Builders[kind]
		if build then
			HeroFilter = function ( hero )
				return Category( WARZONE, hero.bodyIndex ) == category
			end
			local ok, made = pcall( build, controller, list )
			HeroFilter = nil
			if ok then
				for _, item in ipairs( made or {} ) do
					table.insert( items, item )
				end
			else
				Log( "Blackout list " .. tostring( kind ) .. " not made: " .. tostring( made ) )
			end
		end
	end
	pcall( table.sort, items, SortTab )
	-- one selected: the first the makers marked
	local selected = false
	for _, item in ipairs( items ) do
		if item.properties then
			if item.properties.selectIndex and not selected then
				selected = true
			else
				item.properties.selectIndex = false
			end
		end
	end
	return items
end

local CUSTOM_SOURCE = "WZCharacters_custom"

local function WrapCreateSource()
	local wz = CoD.WZUtility
	if not wz or not wz.CreateCharacterCategoryDataSource or wz.shieldCategories then
		return
	end
	wz.shieldCategories = true
	local gameCreate = wz.CreateCharacterCategoryDataSource
	wz.CreateCharacterCategoryDataSource = function ( controller, mode, ... )
		local setup = DataSourceHelpers.ListSetup
		DataSourceHelpers.ListSetup = function ( name, build, ... )
			Builders[mode] = build
			return setup( name, function ( c, l )
				return BuildTab( mode, c, l )
			end, ... )
		end
		local ok, result = pcall( gameCreate, controller, mode, ... )
		DataSourceHelpers.ListSetup = setup
		if not ok then
			error( result )
		end
		return result
	end
	Log( "Blackout lists wrapped" )
end

local function CustomSource()
	DataSources[CUSTOM_SOURCE] = DataSourceHelpers.ListSetup( CUSTOM_SOURCE, function ( controller, list )
		list.persistSelectedIndex = true
		return BuildTab( CUSTOM, controller, list )
	end )
	return CUSTOM_SOURCE
end

-- the fields of a category entry (WZCharacterCategories' maker sets these)
local ENTRY_FIELDS = { "name", "frameWidget", "personalizeFrameWidget", "characterDatasource", "playRevealClip", "mode", "breadcrumb" }

local function ModeOf( entry )
	local mode = entry.model and entry.model.mode
	return mode and mode:get()
end

local function EntryCategory( entry )
	if entry.properties and entry.properties.shieldCustom then
		return CUSTOM
	end
	return ModeOf( entry )
end

-- the categories list (made by the game's maker): Custom added (the Multiplayer tab copied: its frame, mode and
-- breadcrumb, our name and characters), in WZ_ORDER, the selected character's category selected
local function AddCustomTab( controller, list )
	local name = list.customDataSourceHelper
	local entries = name and list[name]
	if not entries or #entries == 0 then
		return
	end

	local multiplayer = nil
	for _, entry in ipairs( entries ) do
		if ModeOf( entry ) == MULTIPLAYER then
			multiplayer = entry
		end
	end

	local hasCustom = false
	for _, hero in ipairs( Engine[@"getherolist"]( WARZONE ) or {} ) do
		if hero.bodyIndex and Category( WARZONE, hero.bodyIndex ) == CUSTOM then
			hasCustom = true
			break
		end
	end

	if hasCustom and multiplayer then
		local parent = ListHelper_GetListHelperModel( list, false )
		local model = parent and Engine[@"createmodel"]( parent, #entries + 1 )
		if model then
			local values = {}
			for _, field in ipairs( ENTRY_FIELDS ) do
				local from = multiplayer.model[field]
				if from then
					values[field] = from:get()
				end
			end
			values.name = NAMES[CUSTOM]
			values.characterDatasource = CustomSource()
			LuaUtils.CreateModelsFromTable( model, values )
			table.insert( entries, { model = model, properties = { selectIndex = false, shieldCustom = true } } )

			-- a list of three made for four (the start menu's options column, the tab bars), set without a relayout (inside prepare)
			if list.hCount == 1 and list.vCount == 3 then
				list.vCount = 4
				if list.id == "options" then
					list:setTopBottom( 0.5, 0.5, -336, -21 )
				end
			elseif list.vCount == 1 and list.hCount == 3 then
				list.hCount = 4
			end
		end
	end

	local rank = {}
	for i, category in ipairs( WZ_ORDER ) do
		rank[category] = i
	end
	table.sort( entries, function ( a, b )
		return ( rank[EntryCategory( a )] or 99 ) < ( rank[EntryCategory( b )] or 99 )
	end )

	local selectedCategory = Category( WARZONE, CoD.PlayerRoleUtility.GetSelectedCharacterIndex( controller ) )
	for _, entry in ipairs( entries ) do
		entry.properties = entry.properties or {}
		entry.properties.selectIndex = EntryCategory( entry ) == selectedCategory
	end
end

local function WrapCategories()
	local source = DataSources.WZCharacterCategories
	if not source or not source.prepare or source.shieldCategories then
		return
	end
	source.shieldCategories = true
	local gamePrepare = source.prepare
	source.prepare = function ( controller, list, filter, ... )
		local result = gamePrepare( controller, list, filter, ... )
		local ok, err = pcall( AddCustomTab, controller, list )
		if not ok then
			Log( "Custom tab not added: " .. tostring( err ) )
		end
		return result
	end
	Log( "Blackout tabs wrapped" )
end

---------------------------

local function Wrap()
	WrapWidget( CoD.StartMenu_Personalization_MP )
	WrapWidget( CoD.StartMenu_Personalization_ZM )
	WrapHeroList()
	WrapCreateSource()
	WrapCategories()
end

Wrap()

if not CoD.ShieldCharacterCategoriesRequire then
	CoD.ShieldCharacterCategoriesRequire = true
	local GameRequire = require
	require = function ( ... )
		local result = GameRequire( ... )
		local ok, err = pcall( Wrap )
		if not ok then
			Log( "not wrapped: " .. tostring( err ) )
		end
		return result
	end
end
