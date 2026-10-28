--[[
		.\hksc.exe ".\Lua\Frontend Side\Main Menu\ModManager.lua" -o "C:\Program Files (x86)\Call of Duty Black Ops 4\project-bo4\internals\T8ShieldSupport\Lua\Frontend\ModManager.luac"
]]

---------------------------

CoD.ShieldInitLuaFile()

---------------------------

-- custom maps: "link" its zip (one with shield_map.json); "asset" its name in the shield-MM-mods release, whose <asset>_<version>.zip is used when there
local MapsCatalog = {
	{
		id = "zm_park",
		asset = "zm_park",
		title = "Giddy Park",
		modes = { "zm" },
		author = "peawhatever",
		base = "zm_towers",
		image = "zm_park_preview",
		desc = "Come on down to Giddy Park! We got rides, booths, and water features/bathrooms! Located between Dave Manor and that zombie HQ-we-shall-not-name, Giddy Park is a place to go nuts with your friends.",
		link = "github.com/NotNierPea/shield-MM-mods/releases/download/release/zm_park.zip"
	},
	{
		id = "zm_room",
		asset = "zm_room",
		title = "First Room Challenge",
		modes = { "zm" },
		author = "peawhatever",
		base = "zm_towers",
		image = "zm_room_preview",
		desc = "One room, the zombies and the way out: hold the room, ride the ferris wheel and the carousel, mind the sawblade, and buy your ending.",
		link = "github.com/NotNierPea/shield-MM-mods/releases/download/release/zm_room.zip"
	}
}

-- "folder" is the one the zip puts in project-bo4/mods: how an installed mod is known; "link" its zip; "asset" its name in the shield-MM-mods release
local ModsCatalog = {
	{
		folder = "EnhancementModT8",
		title = "Enhancement Mod",
		modes = { "zm" },
		author = "peawhatever",
		icon = "ui_menu_ftue_zm_custom_mutations",
		desc = "Improves the zombies experience with a lot of mods and a config in a menu.",
		asset = "EnhancementModT8",
		link = "github.com/NotNierPea/shield-MM-mods/releases/download/release/EnhancementModT8.zip"
	},
	{
		folder = "RushModT8",
		title = "Rush Mod",
		modes = { "zm" },
		author = "peawhatever",
		icon = "mod_manager_rush",
		desc = "Chaos Mod like for zombies, a lot of ducks too.",
		asset = "RushModT8",
		link = "github.com/NotNierPea/shield-MM-mods/releases/download/release/RushModT8.zip"
	},
	{
		folder = "atianmenu",
		title = "Atian Mod Menu",
		modes = { "mp", "zm", "wz" },
		author = "ATE47",
		icon = "mod_manager_french",
		desc = "A really cool looking mod menu by a french man. Note: might randomly crash in long sessions..",
		link = "github.com/ate47/t8-atian-menu/releases/download/latest_build/BlackOps4_shield_atianmenu.zip"
	},
	{
		folder = "BlackOps4Menu",
		title = "Black Ops 4 Menu",
		modes = { "mp", "zm", "wz" },
		author = "Kam",
		icon = "mod_manager_kim",
		desc = "A menu made for Blackout, Multiplayer and Zombies. The code as easy to read as possible for devs.",
		asset = "BlackOps4Menu",
		link = "github.com/NotNierPea/shield-MM-mods/releases/download/release/BlackOps4Menu.zip"
	},
	{
		folder = "survival",
		title = "Survival Maps",
		modes = { "zm" },
		author = "GerardS0406",
		icon = "mod_manager_surv",
		desc = "Survival mod, first room only like.",
		asset = "survival",
		link = "github.com/NotNierPea/shield-MM-mods/releases/download/release/survival.zip"
	},
	{
		folder = "abdom",
		title = "Abomination Menu",
		modes = { "zm" },
		author = "SirCryptic",
		icon = "mod_manager_abom",
		desc = "Mod Menu made for zombies.",
		asset = "abdom",
		link = "github.com/NotNierPea/shield-MM-mods/releases/download/release/abdom.zip"
	},
	{
		folder = "Synergy",
		title = "Synergy Mod Menu",
		modes = { "mp", "zm" },
		author = "SyndiShanX",
		icon = "mod_manager_synergy",
		desc = "Mod Menu made for zombies and multiplayer.",
		link = "syndishanx.github.io/Synergy-GSC-Menu/BO4/Synergy.zip"
	},
	{
		folder = "Gun_Game",
		title = "Gun Game",
		modes = { "zm" },
		author = "SyndiShanX",
		icon = "ui_menu_ftue_zm_tutorial_mode",
		desc = "Gun Game mod for zombies.",
		link = "syndishanx.github.io/Synergy-GSC-Menu/BO4/Gun_Game.zip"
	},
	{
		folder = "TimersMod",
		title = "Round Timer",
		modes = { "zm" },
		author = "RealD4rk9",
		icon = "mod_manager_timers",
		desc = "Adds a round timer to zombies.",
		asset = "TimersMod",
		link = "github.com/NotNierPea/shield-MM-mods/releases/download/release/TimersMod.zip"
	}
}

---------------------------

-- what the client told: the mods folders, the maps it installed or found, the files waiting for a restart
local ModState = {
	mods = {},
	maps = {},
	pending = 0,
	-- by the release zip's lower case name: { name, version, url }; "loading", "ok" or "failed"
	releases = {},
	releasesState = "loading",
	-- the version each release zip was installed at, by its name
	versions = {},
	status = "Idle",
	tab = "maps",
	selected = {}
}

-- the rows of the tab, built again when the client tells something
local ManagerRows = {}

local function ModManagerModel( name )
	return Engine[@"createmodel"]( Engine[@"getglobalmodel"](), "ShieldModManager." .. name )
end

local function ShowManagerStatus()
	if CoD.Shield.OnModManagerStatus then
		CoD.Shield.OnModManagerStatus()
	end
end

CoD.Shield.ModManagerToastUpdate = function(event_name, event_table)
	-- Play a little sound
	Engine[@"playsound"]("uin_map_vote")

	-- Default values
	local message = event_name

	if type(event_table) == "table" and type(event_table.message) == "string" then
		message = event_table.message
	end

	-- debug
	CoD.EnhPrintInfo("Got Mod Toast", message)

	-- Show the toast
	if CoD.OverlayUtility.ShowToast then
		CoD.OverlayUtility.ShowToast("Mod Manager", "Update", message, "mm_icon")
	end
end

CoD.Shield.ModManagerPrecentUpdate = function(event_name, event_table)
	if type(event_table) == "table" and type(event_table.precent) == "string" then
		ModState.status = event_table.precent
		ShowManagerStatus()
	end
end

CoD.Shield.DownloadedModCallback = function(event_name, event_table)
	local message = "Download and Extraction Complete!"

	if type(event_table) == "table" and type(event_table.message) == "string" then
		message = event_table.message
	end

	ModState.status = "Idle"
	ShowManagerStatus()

	-- Show the toast, with sound
	CoD.Shield.ModManagerToastUpdate(message)
end

CoD.Shield.ModManagerModListUpdate = function(event_name, event_table)
	local raw = event_table.mods or ""
	ModState.mods = {}

	-- "Name" enabled, "^1Name" disabled
	for mod in string.gmatch(raw, "([^,]+)") do
		if string.sub(mod, 1, 2) == "^1" then
			table.insert(ModState.mods, { name = string.sub(mod, 3), enabled = false })
		else
			table.insert(ModState.mods, { name = mod, enabled = true })
		end
		CoD.EnhPrintInfo("Found mod: " .. mod)
	end

	-- an older client tells no maps
	ModState.maps = {}

	if type(event_table.maps) == "table" then
		for _, map in ipairs(event_table.maps) do
			if type(map) == "table" and type(map.id) == "string" then
				ModState.maps[map.id] = map
			end
		end
	end

	ModState.pending = tonumber(event_table.pending) or 0
	ModState.versions = {}

	if type(event_table.versions) == "table" then
		for name, version in pairs(event_table.versions) do
			ModState.versions[string.lower(name)] = version
		end
	end

	if CoD.Shield.OnModListChanged then
		CoD.Shield.OnModListChanged()
	end
end

-- the shield-MM-mods release's zips (MM_check_releases): the newest version of each and its link
CoD.Shield.ModManagerReleases = function(event_name, event_table)
	ModState.releases = {}

	if type(event_table.assets) == "table" then
		for _, asset in ipairs(event_table.assets) do
			if type(asset) == "table" and type(asset.name) == "string" then
				ModState.releases[string.lower(asset.name)] = asset
			end
		end
	end

	ModState.releasesState = event_table.ok and "ok" or "failed"

	if CoD.Shield.OnModListChanged then
		CoD.Shield.OnModListChanged()
	end
end

CoD.Shield.ModManagerModTestTable = function(event_name, event_table)
	local stuff = event_table.mods
	if stuff then
		for i, mod in ipairs(stuff) do
			CoD.EnhPrintInfo("test table: " .. i .. " - " .. mod.code .. " - " .. mod.str .. " - " .. mod.duration)
		end
	end
end

---------------------------

-- the colours of a tab and of a row's status
local TabColors = {
	maps = { r = 1, g = 0.38, b = 0.28 },
	mods = { r = 0.35, g = 0.75, b = 1 }
}

local StatusLooks = {
	get = { text = "NOT INSTALLED", r = 0.55, g = 0.55, b = 0.55 },
	installed = { text = "INSTALLED", r = 0.45, g = 0.9, b = 0.45 },
	update = { text = "UPDATE", r = 1, g = 0.8, b = 0.25 },
	restart = { text = "RESTART TO PLAY", r = 1, g = 0.8, b = 0.25 },
	disabled = { text = "DISABLED", r = 1, g = 0.4, b = 0.3 },
	manual = { text = "INSTALLED BY HAND", r = 0.75, g = 0.75, b = 0.75 }
}

-- a map the client loaded its zones of this session: its pictures are there
local function IsMapLoaded( id )
	return ShieldFuncs ~= nil and ShieldFuncs.IsCustomMap ~= nil and ShieldFuncs.IsCustomMap( id ) == true
end

local function ModeOfMap( mode )
	if mode == "mp" or mode == "wz" then
		return mode
	end
	return "zm"
end

-- "1.2.0" newer than "1.1.5"
local function IsNewerVersion( version, than )
	local a, b = {}, {}
	for part in string.gmatch( version, "%d+" ) do table.insert( a, tonumber( part ) ) end
	for part in string.gmatch( than, "%d+" ) do table.insert( b, tonumber( part ) ) end

	for i = 1, math.max( #a, #b ), 1 do
		local x, y = a[i] or 0, b[i] or 0
		if x ~= y then
			return x > y
		end
	end
	return false
end

-- a catalog entry's zip: its release's (the newest version) or its own link elsewhere
local function ReleaseOf( entry )
	if entry == nil or entry.asset == nil then
		return nil
	end
	return ModState.releases[string.lower( entry.asset )]
end

-- the zip of an entry: the release's newest <asset>_<version>.zip when the release has it, else its own link
local function LinkOf( entry, release )
	if release ~= nil then
		return release.url
	end
	return entry and entry.link
end

-- installed at an older version than the release's, or at none known while the release has one
local function NeedsUpdate( version, installedVersion )
	if version == "" then
		return false
	end
	return installedVersion == "" or IsNewerVersion( version, installedVersion )
end

-- a map row: the catalog's entry and what the client has of it, either can be missing
local function MapRow( entry, installed )
	local release = ReleaseOf( entry )
	local row = {
		kind = "map",
		key = entry and entry.id or installed.id,
		title = entry and entry.title or installed.name,
		author = entry and entry.author or installed.author or "",
		desc = entry and entry.desc or installed.description or "",
		modes = entry and entry.modes or { ModeOfMap( installed.mode ) },
		version = release and release.version or "",
		installedVersion = installed and installed.version or "",
		link = LinkOf( entry, release ),
		asset = entry and entry.asset,
		shared = entry and entry.shared or {},
		base = entry and entry.base or "zm_towers",
		image = entry and entry.image or ( ( entry and entry.id or installed.id ) .. "_preview" )
	}

	if installed == nil then
		row.status = "get"
	elseif installed.state == "manual" then
		row.status = "manual"
	elseif NeedsUpdate( row.version, row.installedVersion ) then
		row.status = "update"
	elseif not IsMapLoaded( row.key ) then
		row.status = "restart"
	else
		row.status = "installed"
	end

	if row.installedVersion == "" and installed ~= nil and installed.state == "manual" then
		row.installedVersion = "-"
	end

	return row
end

local function ModRow( entry, installed )
	local release = ReleaseOf( entry )
	local row = {
		kind = "mod",
		key = entry and entry.folder or installed.name,
		title = entry and entry.title or installed.name,
		author = entry and entry.author or "",
		desc = entry and entry.desc or "A mod in project-bo4\\mods that isn't in the list of downloads.",
		modes = entry and entry.modes or {},
		version = release and release.version or "",
		installedVersion = "",
		link = LinkOf( entry, release ),
		asset = entry and entry.asset,
		icon = entry and entry.icon,
		-- the folder as it is on disk, for remove and toggle
		target = installed and installed.name or ( entry and entry.folder )
	}

	if installed ~= nil and entry ~= nil and entry.asset ~= nil then
		row.installedVersion = ModState.versions[string.lower( entry.asset )] or ""
	end

	if installed == nil then
		row.status = "get"
	elseif NeedsUpdate( row.version, row.installedVersion ) then
		row.status = "update"
	elseif installed.enabled then
		row.status = "installed"
	else
		row.status = "disabled"
	end

	return row
end

-- the rows of the tab: the downloads first, then what is installed and isn't one of them
local function BuildManagerRows()
	ManagerRows = {}

	if ModState.tab == "maps" then
		local listed = {}

		for _, entry in ipairs( MapsCatalog ) do
			listed[entry.id] = true
			table.insert( ManagerRows, MapRow( entry, ModState.maps[entry.id] ) )
		end

		local others = {}
		for id, map in pairs( ModState.maps ) do
			if not listed[id] then
				table.insert( others, MapRow( nil, map ) )
			end
		end

		table.sort( others, function ( a, b ) return a.key < b.key end )

		for _, row in ipairs( others ) do
			table.insert( ManagerRows, row )
		end
	else
		local installed = {}
		for _, mod in ipairs( ModState.mods ) do
			installed[string.lower( mod.name )] = mod
		end

		for _, entry in ipairs( ModsCatalog ) do
			local mod = installed[string.lower( entry.folder )]
			installed[string.lower( entry.folder )] = nil
			table.insert( ManagerRows, ModRow( entry, mod ) )
		end

		-- T8ShieldSupport is this mod: not one to remove from here
		for _, mod in ipairs( ModState.mods ) do
			local name = string.lower( mod.name )
			if installed[name] ~= nil and name ~= "t8shieldsupport" then
				table.insert( ManagerRows, ModRow( nil, mod ) )
			end
		end
	end
end

local function FindManagerRow( key )
	for index, row in ipairs( ManagerRows ) do
		if row.key == key then
			return row, index
		end
	end
	return nil
end

-- "MP", "ZM", "WZ" of a row, "ALL" for none
local function RowTags( row )
	if #row.modes == 0 then
		return { { tag = "ALL", color = { r = 1, g = 1, b = 1 } } }
	end

	local tags = {}
	for _, mode in ipairs( row.modes ) do
		table.insert( tags, { tag = ToUpper( mode ), color = CoD.Shield.BrowserUI.ModeColors[mode] or CoD.Shield.BrowserUI.ModeColors.mp } )
	end
	return tags
end

-- the picture of a row: a map's own once its zones are loaded, its base map's before
local function RowImage( row )
	if row.kind == "map" then
		if IsMapLoaded( row.key ) then
			return row.image
		end
		return MapNameToMapImage( row.base )
	end

	return row.icon or "ui_menu_ftue_zm_custom_mutations"
end

DataSources.ShieldModManagerRowsEmpty = DataSourceHelpers.ListSetup( "ShieldModManagerRowsEmpty", function ( f3_arg0, f3_arg1 )
	return {}
end, true )

DataSources.ShieldModManagerRows = DataSourceHelpers.ListSetup( "ShieldModManagerRows", function ( f3_arg0, f3_arg1 )
	local items = {}

	for index, row in ipairs( ManagerRows ) do
		table.insert( items, {
			models = {
				Title = row.title,
				Key = row.key,
				Index = index
			},
			properties = {

			}
		} )
	end

	return items
end, true )

---------------------------

-- the body, 1744 by 800 in BrowserUI parts: tabs and rows on the left 1060, the picked row's card and buttons from 1084
local MM_CARD_LEFT = 1084
local MM_CARD_RIGHT = 1744
local MM_CARD_IMAGE_HEIGHT = 330
local MM_CARD_BOTTOM = 680
local MM_TEXT_LEFT = MM_CARD_LEFT + 24
local MM_TEXT_RIGHT = MM_CARD_RIGHT - 24
local MM_CARD_HALF = MM_CARD_LEFT + 330
local MM_LIST_TOP = 86
local MM_ROW_HEIGHT = 60
local MM_ROW_THUMB_WIDTH = 107
local MM_ROW_TEXT_LEFT = 127
local MM_ROW_STATUS_LEFT = 660
local MM_MAX_TAGS = 3

local function SetButtonWords( button, words )
	button.MiddleText:setText( words )
	button.MiddleTextFocus:setText( words )
end

-- the line under a button that is on, in that colour
local function AddActiveMark( button, color )
	local mark = LUI.UIImage.new( 0, 1, 0, 0, 1, 1, -3, 0 )
	mark:setRGB( color.r, color.g, color.b )
	mark:setAlpha( 0 )
	button:addElement( mark )
	button.ActiveMark = mark
end

-- what the card says of a map's or a mod's files
local function FilesText( row )
	if row.kind == "mod" then
		return "project-bo4\\mods\\" .. row.key
	end

	local text = "Map zone, UI zone, sounds, package index, zone_mods\\" .. row.key

	if #row.shared > 0 then
		text = text .. "  ^7+ shared: " .. table.concat( row.shared, ", " )
	end

	return text
end

CoD.ShieldModManagerBody = InheritFrom( LUI.UIElement )
CoD.ShieldModManagerBody.__defaultWidth = 1744
CoD.ShieldModManagerBody.__defaultHeight = 800
CoD.ShieldModManagerBody.new = function ( f1_arg0, f1_arg1, f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	local UI = CoD.Shield.BrowserUI

	local self = LUI.UIElement.new( f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	self:setClass( CoD.ShieldModManagerBody )
	self.id = "ShieldModManagerBody"
	self.soundSet = "default"
	self.onlyChildrenFocusable = true
	self.anyChildUsesUpdateState = true

	-- everything of the body that is only closed with it
	self.Parts = {}
	self.Buttons = {}

	local function Add( element )
		self:addElement( element )
		table.insert( self.Parts, element )
		return element
	end

	-- a button of the body: the menu finds what can take the focus as parent[id], so it is kept under its id
	local function AddButton( id, label, left, right, top, bottom, action )
		local button = UI.NewBrowserButton( self, f1_arg0, f1_arg1, label, left, right, top, bottom )
		self:addElement( button )
		button.id = id
		self[id] = button
		table.insert( self.Buttons, button )
		UI.OnBrowserButton( f1_arg0, f1_arg1, button, action )
		return button
	end

	---------------------------
	-- the list of the rows

	local Rows = LUI.UIList.new( f1_arg0, f1_arg1, 7, 0, nil, false, false, false, false )
	Rows:setLeftRight( 0, 0, 0, 1060 )
	Rows:setTopBottom( 0, 0, MM_LIST_TOP, MM_LIST_TOP + 654 )

	-- filled a moment after the menu is up, and when the client tells its mods
	Rows:setDataSource( "ShieldModManagerRowsEmpty" )

	Rows:setWidgetType( CoD.ShieldModManagerRow )
	Rows:setVerticalCount( 10 )
	Rows:setSpacing( 6 )

	Rows:setAlignment( Enum[@"luialignment"][@"lui_alignment_left"] )
	Rows:setVerticalCounter( CoD.verticalCounter )
	Rows:appendEventHandler( "input_source_changed", function ( f2_arg0, f2_arg1 )
		f2_arg1.menu = f2_arg1.menu or f1_arg0
		CoD.Menu.UpdateButtonShownState( f2_arg0, f1_arg0, f1_arg1, Enum[@"luibutton"][@"lui_key_xba_pscross"] )
	end )

	Rows:registerEventHandler( "gain_focus", function ( element, event )
		local f5_local0 = nil
		if element.gainFocus then
			f5_local0 = element:gainFocus( event )
		elseif element.super.gainFocus then
			f5_local0 = element.super:gainFocus( event )
		end
		CoD.Menu.UpdateButtonShownState( element, f1_arg0, f1_arg1, Enum[@"luibutton"][@"lui_key_xba_pscross"] )
		return f5_local0
	end )

	-- A list keeps the row it was scrolled to when its rows change: emptied, it is put back to its top before the new rows come.
	local function ReloadRows()
		Rows:setDataSource( "ShieldModManagerRowsEmpty" )
		Rows:updateDataSource()
		Rows:clearLayout()
		Rows:clearSavedActiveIndex()
		Rows:setDataSource( "ShieldModManagerRows" )
		Rows:updateDataSource()
	end

	---------------------------
	-- over the rows: the tabs, and how many there are

	self.TabButtons = {}

	local CountText = Add( UI.NewText( 520, 1060, 6, 16, "ttmussels_regular", Enum[@"luialignment"][@"lui_alignment_right"] ) )
	CountText:setRGB( 0.6, 0.6, 0.6 )

	local TabHint = Add( UI.NewText( 520, 1060, 28, 14, "ttmussels_regular", Enum[@"luialignment"][@"lui_alignment_right"] ) )
	TabHint:setRGB( 0.42, 0.42, 0.42 )
	TabHint:setLetterSpacing( 1 )

	-- the names of the columns, where the rows have them
	Add( UI.NewCaption( MM_ROW_TEXT_LEFT, MM_ROW_STATUS_LEFT - 20, 56, "NAME" ) )
	Add( UI.NewCaption( MM_ROW_STATUS_LEFT, 900, 56, "STATUS" ) )
	Add( UI.NewCaption( 900, 1040, 56, "VERSION", Enum[@"luialignment"][@"lui_alignment_right"] ) )
	Add( UI.NewBox( 0, 1060, 78, 79, 1, 1, 1, 0.12 ) )

	-- in the place of the rows while there is none
	local EmptyTitle = Add( UI.NewText( 0, 1060, MM_LIST_TOP + 250, 30, "notosans_bold", Enum[@"luialignment"][@"lui_alignment_center"] ) )
	EmptyTitle:setRGB( 0.75, 0.75, 0.75 )
	EmptyTitle:setText( "Nothing here yet" )
	EmptyTitle:setAlpha( 0 )

	---------------------------
	-- the card of the row picked: its picture, 660 by 330, which cuts what of the picture is over

	local ImageClip = LUI.UIElement.new( 0, 0, MM_CARD_LEFT, MM_CARD_RIGHT, 0, 0, 0, MM_CARD_IMAGE_HEIGHT )
	ImageClip:setUseStencil( true )
	Add( ImageClip )

	local CardImage = LUI.UIImage.new( 0, 1, 0, 0, 0, 1, 0, 0 )
	CardImage:setImage( RegisterImage( @"uie_ui_menu_emblem_grid" ) )
	ImageClip:addElement( CardImage )
	self.CardImage = CardImage

	UI.AddBottomFade( ImageClip, MM_CARD_IMAGE_HEIGHT, 170 )

	-- the parts of the card that change with the pick
	local Card = {}

	-- the line over the card, in the colour of the mode
	Card.Accent = Add( UI.NewBox( MM_CARD_LEFT, MM_CARD_RIGHT, 0, 4, 1, 1, 1, 0.25 ) )

	Card.Pills = {}

	for index = 1, MM_MAX_TAGS, 1 do
		local left = MM_TEXT_LEFT + ( index - 1 ) * 60

		local box = Add( UI.NewBox( left, left + 52, 222, 248, 1, 1, 1, 0 ) )

		local text = Add( UI.NewText( left, left + 52, 226, 18, "notosans_bold", Enum[@"luialignment"][@"lui_alignment_center"] ) )
		text:setRGB( 0.04, 0.04, 0.04 )

		Card.Pills[index] = { box = box, text = text }
	end

	Card.Kind = Add( UI.NewText( MM_TEXT_LEFT, MM_TEXT_RIGHT, 224, 22, "ttmussels_regular" ) )
	Card.Kind:setRGB( 0.86, 0.86, 0.86 )
	Card.Kind:setLetterSpacing( 2 )

	Card.Title = Add( UI.NewText( MM_TEXT_LEFT, MM_TEXT_RIGHT, 258, 48, "notosans_bold" ) )
	Card.Title:setRGB( 1, 1, 1 )

	-- under the picture: who made it, its version, what it is, its files and how the download goes
	Add( UI.NewBox( MM_CARD_LEFT, MM_CARD_RIGHT, MM_CARD_IMAGE_HEIGHT, MM_CARD_BOTTOM, 0, 0, 0, 0.5 ) )

	Add( UI.NewCaption( MM_TEXT_LEFT, MM_CARD_HALF - 20, 346, "MADE BY" ) )

	Card.Author = Add( UI.NewText( MM_TEXT_LEFT, MM_CARD_HALF - 20, 366, 26, "notosans_bold" ) )
	Card.Author:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )

	Add( UI.NewCaption( MM_CARD_HALF, MM_TEXT_RIGHT, 346, "STATUS" ) )

	Card.Status = Add( UI.NewText( MM_CARD_HALF, MM_TEXT_RIGHT, 368, 22, "ttmussels_regular" ) )

	Add( UI.NewBox( MM_TEXT_LEFT, MM_TEXT_RIGHT, 404, 405, 1, 1, 1, 0.1 ) )

	Add( UI.NewCaption( MM_TEXT_LEFT, MM_TEXT_RIGHT, 416, "ABOUT" ) )

	Card.Desc = Add( UI.NewText( MM_TEXT_LEFT, MM_TEXT_RIGHT, 438, 18, "ttmussels_regular" ) )
	Card.Desc:setRGB( 0.78, 0.78, 0.78 )

	Add( UI.NewCaption( MM_TEXT_LEFT, MM_TEXT_RIGHT, 556, "FILES" ) )

	Card.Files = Add( UI.NewText( MM_TEXT_LEFT, MM_TEXT_RIGHT, 576, 16, "ttmussels_regular" ) )
	Card.Files:setRGB( 0.55, 0.55, 0.55 )

	Add( UI.NewBox( MM_TEXT_LEFT, MM_TEXT_RIGHT, 614, 615, 1, 1, 1, 0.1 ) )

	Card.Progress = Add( UI.NewText( MM_TEXT_LEFT, MM_TEXT_RIGHT, 630, 20, "notosans_bold" ) )
	Card.Progress:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )

	-- the thin frame of the game around the card
	local CardFrame = LUI.UIImage.new( 0, 0, MM_CARD_LEFT - 1, MM_CARD_RIGHT + 1, 0, 0, -1, MM_CARD_BOTTOM + 1 )
	CardFrame:setAlpha( 0.12 )
	CardFrame:setImage( RegisterImage( @"uie_ui_menu_store_common_frame" ) )
	CardFrame:setMaterial( LUI.UIImage.GetCachedMaterial( @"uie_nineslice_add" ) )
	CardFrame:setShaderVector( 0, 0, 0, 0, 0 )
	CardFrame:setupNineSliceShader( 12, 12 )
	Add( CardFrame )

	---------------------------
	-- what the menu shows of the tab, the pick and the download

	local function PickedRow()
		return FindManagerRow( ModState.selected[ModState.tab] )
	end

	-- the download's words, or what waits for a restart
	local function ShowProgress()
		if ModState.status ~= "Idle" then
			Card.Progress:setRGB( 1, 0.8, 0.25 )
			Card.Progress:setText( ModState.status )
		elseif ModState.pending > 0 then
			Card.Progress:setRGB( 1, 0.8, 0.25 )
			Card.Progress:setText( "Restart the game to finish: some files were in use." )
		else
			Card.Progress:setRGB( 0.55, 0.55, 0.55 )
			Card.Progress:setText( "Ready" )
		end
	end

	local function ShowManager()
		local maps = ModState.tab == "maps"
		local row = PickedRow()
		local installed = 0

		for _, other in ipairs( ManagerRows ) do
			if other.status ~= "get" then
				installed = installed + 1
			end
		end

		CountText:setText( #ManagerRows .. ( maps and " MAPS" or " MODS" ) .. "  /  " .. installed .. " INSTALLED" )

		if maps then
			TabHint:setText( "A MAP LOADS WHEN THE GAME STARTS: RESTART AFTER INSTALLING" )
		else
			TabHint:setText( "MODS LOAD WITH RELOAD MODS" )
		end

		EmptyTitle:setAlpha( #ManagerRows == 0 and 1 or 0 )

		for _, button in ipairs( self.TabButtons ) do
			button.ActiveMark:setAlpha( button.Tab == ModState.tab and 1 or 0 )
		end

		ShowProgress()

		if row == nil then
			Card.Title:setText( maps and "No map" or "No mod" )
			Card.Kind:setText( "" )
			Card.Author:setText( "-" )
			Card.Status:setText( "-" )
			Card.Desc:setText( "" )
			Card.Files:setText( "" )
			Card.Accent:setAlpha( 0.25 )
			for _, pill in ipairs( Card.Pills ) do
				pill.box:setAlpha( 0 )
				pill.text:setText( "" )
			end
			return
		end

		local tags = RowTags( row )
		local color = tags[1].color
		local look = StatusLooks[row.status] or StatusLooks.get

		UI.SetPreviewImage( CardImage, RowImage( row ), MM_CARD_RIGHT - MM_CARD_LEFT, MM_CARD_IMAGE_HEIGHT )

		-- the new picture comes up out of the dark
		CardImage:completeAnimation()
		CardImage:setAlpha( 0.35 )
		CardImage:beginAnimation( 180 )
		CardImage:setAlpha( 1 )

		Card.Accent:setRGB( color.r, color.g, color.b )
		Card.Accent:setAlpha( 1 )

		for index, pill in ipairs( Card.Pills ) do
			local tag = tags[index]
			if tag ~= nil then
				pill.box:setRGB( tag.color.r, tag.color.g, tag.color.b )
				pill.box:setAlpha( 1 )
				pill.text:setText( tag.tag )
			else
				pill.box:setAlpha( 0 )
				pill.text:setText( "" )
			end
		end

		-- the kind of it, after the pills
		Card.Kind:setLeftRight( 0, 0, MM_TEXT_LEFT + #tags * 60 + 4, MM_TEXT_RIGHT )
		Card.Kind:setText( maps and "CUSTOM MAP" or "SHIELD MOD" )

		Card.Title:setText( UI.ShortenText( row.title, 26 ) )
		Card.Author:setText( row.author ~= "" and row.author or "Unknown" )

		local status = look.text
		if row.status == "update" then
			if row.installedVersion == "" then
				status = "UPDATE TO " .. row.version
			else
				status = "UPDATE: " .. row.installedVersion .. " -> " .. row.version
			end
		elseif row.installedVersion ~= "" and row.installedVersion ~= "-" then
			status = status .. "  " .. row.installedVersion
		end

		Card.Status:setRGB( look.r, look.g, look.b )
		Card.Status:setText( status )
		Card.Desc:setText( row.desc )
		Card.Files:setText( FilesText( row ) )

		-- what the buttons do with it
		if self.PrimaryButton ~= nil then
			if row.status == "update" then
				SetButtonWords( self.PrimaryButton, "UPDATE" )
			elseif row.status == "get" then
				SetButtonWords( self.PrimaryButton, "INSTALL" )
			else
				SetButtonWords( self.PrimaryButton, "REINSTALL" )
			end
			self.PrimaryButton:setAlpha( row.link ~= nil and 1 or 0.45 )
		end

		if self.RemoveButton ~= nil then
			local removable = row.status ~= "get" and row.status ~= "manual"
			self.RemoveButton:setAlpha( removable and 1 or 0.45 )
		end

		if self.ToggleButton ~= nil then
			SetButtonWords( self.ToggleButton, row.status == "disabled" and "ENABLE" or "DISABLE" )
			self.ToggleButton:setAlpha( ( row.kind == "mod" and row.status ~= "get" ) and 1 or 0.45 )
		end
	end

	-- the row picked: the one of before when it is still there, else the first
	local function PickRow( key )
		if FindManagerRow( key ) == nil then
			key = ManagerRows[1] and ManagerRows[1].key or nil
		end

		ModState.selected[ModState.tab] = key
		ModManagerModel( "selected" ):set( key or "" )
	end

	local function RefillManager()
		BuildManagerRows()
		PickRow( ModState.selected[ModState.tab] )
		ShowManager()

		Rows:addElement( LUI.UITimer.newElementTimer( 5, true, function ()
			ReloadRows()
		end ) )
	end

	---------------------------
	-- the tabs

	local Tabs = {
		{ tab = "maps", label = "CUSTOM MAPS", left = 0, right = 240 },
		{ tab = "mods", label = "SHIELD MODS", left = 248, right = 488 }
	}

	for index, info in ipairs( Tabs ) do
		local button = AddButton( "TabButton" .. index, info.label, info.left, info.right, 0, 44, function ()
			if ModState.tab == info.tab then
				return
			end

			PlaySoundAlias( "uin_paint_image_flip_toggle" )
			ModState.tab = info.tab
			RefillManager()
		end )

		button.Tab = info.tab
		AddActiveMark( button, TabColors[info.tab] )
		table.insert( self.TabButtons, button )
	end

	---------------------------
	-- the buttons under the card

	local function Refuse( message )
		PlaySoundAlias( "uin_unavailable_click" )
		CoD.Shield.ModManagerToastUpdate( message )
	end

	local PrimaryButton = AddButton( "PrimaryButton", "INSTALL", MM_CARD_LEFT, MM_CARD_HALF - 6, 692, 740, function ()
		local row = PickedRow()

		if row == nil then
			return Refuse( "Pick something in the list first." )
		elseif row.link == nil then
			return Refuse( "It isn't in the downloads: it was put there by hand." )
		end

		PlaySoundAlias( "uin_toggle_generic" )
		CoD.EnhPrintInfo( "MM_download_mod", row.link )

		ModState.status = "Starting the download.."
		ShowProgress()

		-- without the scheme: the client adds it back
		local link = string.gsub( row.link, "^https?://", "" )
		Engine[@"exec"]( Engine[@"getprimarycontroller"](), "MM_download_mod " .. link )
	end )
	self.PrimaryButton = PrimaryButton

	local RemoveButton = AddButton( "RemoveButton", "REMOVE", MM_CARD_HALF + 6, MM_CARD_RIGHT, 692, 740, function ()
		local row = PickedRow()

		if row == nil or row.status == "get" then
			return Refuse( "It isn't installed." )
		elseif row.status == "manual" then
			return Refuse( "Installed by hand: remove its files yourself." )
		end

		PlaySoundAlias( "uin_toggle_generic" )
		CoD.EnhPrintInfo( "Removing -> " .. row.key )

		if row.kind == "map" then
			Engine[@"exec"]( Engine[@"getprimarycontroller"](), "MM_remove_map " .. row.key )
		else
			Engine[@"exec"]( Engine[@"getprimarycontroller"](), "MM_remove_mod " .. row.target )
		end
	end )
	self.RemoveButton = RemoveButton

	local ToggleButton = AddButton( "ToggleButton", "DISABLE", MM_CARD_LEFT, MM_CARD_HALF - 6, 752, 800, function ()
		local row = PickedRow()

		if row == nil or row.kind ~= "mod" then
			return Refuse( "A map can't be turned off: remove it instead." )
		elseif row.status == "get" then
			return Refuse( "It isn't installed." )
		end

		PlaySoundAlias( "uin_paint_image_flip_toggle" )
		CoD.EnhPrintInfo( "Toggling Mod -> " .. row.target )
		Engine[@"exec"]( Engine[@"getprimarycontroller"](), "MM_toggle_mod " .. row.target )
	end )
	self.ToggleButton = ToggleButton

	AddButton( "ReloadButton", "RELOAD MODS", MM_CARD_HALF + 6, MM_CARD_RIGHT, 752, 800, function ()
		PlaySoundAlias( "uin_paint_image_flip_toggle" )
		CoD.EnhPrintInfo( "ReloadModsButton" )

		-- reload with killserver
		CoD.VM_ReloadMods()
	end )

	---------------------------
	-- the rows

	f1_arg0:AddButtonCallbackFunction( Rows, f1_arg1, Enum[@"luibutton"][@"lui_key_xba_pscross"], "ui_confirm", function ( element, menu, controller, model )
		if ( IsGamepad( controller ) or IsMouseOrKeyboard( controller ) ) and element.RowKey ~= nil then
			PlaySoundAlias( "uin_toggle_generic" )
			PickRow( element.RowKey )
			ShowManager()
			return true
		end
	end, function ( element, menu, controller )
		if IsGamepad( controller ) then
			CoD.Menu.SetButtonLabel( menu, Enum[@"luibutton"][@"lui_key_xba_pscross"], @"menu/select", nil, "ui_confirm" )
			return true
		elseif IsMouseOrKeyboard( controller ) then
			CoD.Menu.SetButtonLabel( menu, Enum[@"luibutton"][@"lui_key_xba_pscross"], @"hash_0", nil, "ui_confirm" )
			return false
		else
			return false
		end
	end, false )

	self:addElement( Rows )
	self.Rows = Rows
	Rows.id = "Rows"

	-- the client told its mods and maps: the rows a moment later, as the browser fills its own
	CoD.Shield.OnModListChanged = function ()
		RefillManager()
	end

	CoD.Shield.OnModManagerStatus = function ()
		ShowProgress()
	end

	RefillManager()

	-- and it is asked for them again: one can be new since the game started
	Engine[@"exec"]( Engine[@"getprimarycontroller"](), "MM_push_mods" )

	-- and the release's versions (an older client has no such command: the entries' own links are used)
	Engine[@"exec"]( Engine[@"getprimarycontroller"](), "MM_check_releases" )

	LUI.OverrideFunction_CallOriginalSecond( self, "close", self.__onClose )

	if PostLoadFunc then
		PostLoadFunc( self, f1_arg1, f1_arg0 )
	end

	return self
end

CoD.ShieldModManagerBody.__onClose = function ( f9_arg0 )
	CoD.Shield.OnModListChanged = nil
	CoD.Shield.OnModManagerStatus = nil

	for _, element in ipairs( f9_arg0.Parts ) do
		element:close()
	end
	for _, button in ipairs( f9_arg0.Buttons ) do
		button:close()
	end
	f9_arg0.CardImage:close()
	f9_arg0.Rows:close()
end

---------------------------

-- a row, 1060 by 60: picture, name over mode pills and author, status, version

-- what of a row changes with the focus
local ManagerRowFocusParts = {
	{ "BlackBar", function ( element, focus ) element:setAlpha( focus and 0.1 or 0.05 ) end },
	{ "Tint", function ( element, focus ) element:setAlpha( focus and 0.16 or 0 ) end },
	{ "FocusFrame", function ( element, focus ) element:setAlpha( focus and 1 or 0 ) end },
	{ "ThumbDim", function ( element, focus ) element:setAlpha( focus and 0 or 0.35 ) end },
	{ "Accent", function ( element, focus ) element:setLeftRight( 0, 0, 0, focus and 7 or 4 ) end }
}

-- the clip of the rows of the browser, looked up when it plays: that file may be loaded after this one
local function ManagerRowClip( focus, duration )
	return function ( self, event )
		return CoD.Shield.BrowserUI.FocusClip( ManagerRowFocusParts, focus, duration )( self, event )
	end
end

CoD.ShieldModManagerRow = InheritFrom( LUI.UIElement )
CoD.ShieldModManagerRow.__defaultWidth = 1060
CoD.ShieldModManagerRow.__defaultHeight = MM_ROW_HEIGHT
CoD.ShieldModManagerRow.new = function ( f1_arg0, f1_arg1, f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	local UI = CoD.Shield.BrowserUI

	local self = LUI.UIElement.new( f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	self:setClass( CoD.ShieldModManagerRow )
	self.id = "ShieldModManagerRow"
	self.soundSet = "default"
	f1_arg0:addElementToPendingUpdateStateList( self )

	self.Parts = {}

	local function Add( element )
		self:addElement( element )
		table.insert( self.Parts, element )
		return element
	end

	local BlackBar = LUI.UIImage.new( 0, 1, 0, 0, 0, 1, 0, 0 )
	BlackBar:setRGB( 1, 1, 1 )
	BlackBar:setAlpha( 0.05 )
	Add( BlackBar )
	self.BlackBar = BlackBar

	-- the colour of the mode over the row in focus
	local Tint = LUI.UIImage.new( 0, 1, 0, 0, 0, 1, 0, 0 )
	Tint:setAlpha( 0 )
	Add( Tint )
	self.Tint = Tint

	-- and over the row picked, which no clip touches
	local Chosen = LUI.UIImage.new( 0, 1, 0, 0, 0, 1, 0, 0 )
	Chosen:setAlpha( 0 )
	Add( Chosen )

	-- the picture, cut to its box
	local ThumbClip = LUI.UIElement.new( 0, 0, 0, MM_ROW_THUMB_WIDTH, 0, 0, 0, MM_ROW_HEIGHT )
	ThumbClip:setUseStencil( true )
	Add( ThumbClip )

	local Thumb = LUI.UIImage.new( 0, 1, 0, 0, 0, 1, 0, 0 )
	Thumb:setAlpha( 0 )
	ThumbClip:addElement( Thumb )
	self.Thumb = Thumb

	-- a little dark until the row is in focus, a part of the row: only the row counts the clip's parts
	local ThumbDim = Add( UI.NewBox( 0, MM_ROW_THUMB_WIDTH, 0, MM_ROW_HEIGHT, 0, 0, 0, 0.35 ) )
	self.ThumbDim = ThumbDim

	-- the bar at the start of the row
	local Accent = LUI.UIImage.new( 0, 0, 0, 4, 0, 1, 0, 0 )
	Add( Accent )
	self.Accent = Accent

	local Name = Add( UI.NewText( MM_ROW_TEXT_LEFT, MM_ROW_STATUS_LEFT - 20, 7, 24, "notosans_bold" ) )
	Name:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )

	-- MP, ZM or WZ, dark on the colour of the mode, as the lobby rows have them
	local Pills = {}

	for index = 1, MM_MAX_TAGS, 1 do
		local left = MM_ROW_TEXT_LEFT + ( index - 1 ) * 42

		local box = Add( UI.NewBox( left, left + 36, 36, 54, 1, 1, 1, 0 ) )

		local text = Add( UI.NewText( left, left + 36, 38, 14, "notosans_bold", Enum[@"luialignment"][@"lui_alignment_center"] ) )
		text:setRGB( 0.04, 0.04, 0.04 )

		Pills[index] = { box = box, text = text }
	end

	local Author = Add( UI.NewText( MM_ROW_TEXT_LEFT + 46, MM_ROW_STATUS_LEFT - 20, 36, 18, "ttmussels_regular" ) )
	Author:setRGB( 0.68, 0.68, 0.68 )
	Author:setLetterSpacing( 1 )

	local Status = Add( UI.NewText( MM_ROW_STATUS_LEFT, 900, 18, 22, "ttmussels_regular" ) )

	local Version = Add( UI.NewText( 900, 1040, 17, 26, "0arame_mono_stencil", Enum[@"luialignment"][@"lui_alignment_right"] ) )
	Version:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )

	-- the bar at the end of the row picked
	local ChosenMark = LUI.UIImage.new( 1, 1, -8, 0, 0, 1, 0, 0 )
	ChosenMark:setAlpha( 0 )
	Add( ChosenMark )

	-- the frame of the game around the row in focus, in the colour of the mode
	local FocusFrame = LUI.UIImage.new( 0, 1, -4, 4, 0, 1, -4, 4 )
	FocusFrame:setAlpha( 0 )
	FocusFrame:setImage( RegisterImage( @"uie_ui_menu_store_focus_frame" ) )
	FocusFrame:setMaterial( LUI.UIImage.GetCachedMaterial( @"uie_nineslice_add" ) )
	FocusFrame:setShaderVector( 0, 0, 0, 0, 0 )
	FocusFrame:setupNineSliceShader( 10, 10 )
	Add( FocusFrame )
	self.FocusFrame = FocusFrame

	local SelectedModel = ModManagerModel( "selected" )

	local function ShowChosen()
		local chosen = self.RowKey ~= nil and SelectedModel:get() == self.RowKey

		Chosen:setAlpha( chosen and 0.14 or 0 )
		ChosenMark:setAlpha( chosen and 1 or 0 )
	end

	-- everything of the row is read when its name is set: the list makes a row whole before it gives it
	Name:linkToElementModel( self, "Title", true, function ( model )
		if model:get() == nil then
			return
		end

		local row = ManagerRows[CoD.ModelUtility.GetSelfModelPathValue( self, "Index" ) or 0]
		if row == nil then
			return
		end

		local tags = RowTags( row )
		local color = tags[1].color
		local look = StatusLooks[row.status] or StatusLooks.get

		-- what the click reads of the row
		self.RowKey = row.key

		Accent:setRGB( color.r, color.g, color.b )
		Tint:setRGB( color.r, color.g, color.b )
		Chosen:setRGB( color.r, color.g, color.b )
		ChosenMark:setRGB( color.r, color.g, color.b )
		FocusFrame:setRGB( color.r, color.g, color.b )

		for index, pill in ipairs( Pills ) do
			local tag = tags[index]
			if tag ~= nil then
				pill.box:setRGB( tag.color.r, tag.color.g, tag.color.b )
				pill.box:setAlpha( 1 )
				pill.text:setText( tag.tag )
			else
				pill.box:setAlpha( 0 )
				pill.text:setText( "" )
			end
		end

		UI.SetPreviewImage( Thumb, RowImage( row ), MM_ROW_THUMB_WIDTH, MM_ROW_HEIGHT )
		Thumb:setAlpha( 1 )

		Name:setText( UI.ShortenText( row.title, 36 ) )

		Author:setLeftRight( 0, 0, MM_ROW_TEXT_LEFT + #tags * 42 + 4, MM_ROW_STATUS_LEFT - 20 )
		Author:setText( row.author ~= "" and ToUpper( UI.ShortenText( row.author, 30 ) ) or ( row.kind == "map" and "CUSTOM MAP" or "LOCAL MOD" ) )

		Status:setRGB( look.r, look.g, look.b )
		Status:setText( look.text )

		if row.status == "update" then
			Version:setText( row.version )
		elseif row.installedVersion ~= "" then
			Version:setText( row.installedVersion )
		elseif row.version ~= "" then
			Version:setText( row.version )
		else
			Version:setText( "-" )
		end

		ShowChosen()
	end )

	self:subscribeToModel( SelectedModel, function ( model )
		ShowChosen()
	end )

	LUI.OverrideFunction_CallOriginalSecond( self, "close", self.__onClose )

	if PostLoadFunc then
		PostLoadFunc( self, f1_arg1, f1_arg0 )
	end

	return self
end

CoD.ShieldModManagerRow.__resetProperties = function ( f7_arg0 )
	for _, part in ipairs( ManagerRowFocusParts ) do
		local element = f7_arg0[part[1]]
		element:completeAnimation()
		part[2]( element, false )
	end
end

CoD.ShieldModManagerRow.__clipsPerState = {
	DefaultState = {
		DefaultClip = ManagerRowClip( false ),
		Focus = ManagerRowClip( true ),
		GainFocus = ManagerRowClip( true, 120 ),
		LoseFocus = ManagerRowClip( false, 120 )
	}
}

CoD.ShieldModManagerRow.__onClose = function ( f10_arg0 )
	f10_arg0.Thumb:close()
	for _, element in ipairs( f10_arg0.Parts ) do
		element:close()
	end
end

---------------------------

-- Safe area of the menu: the header of the game over the body
CoD.Shield_SafeAreaContainer_ModManager = InheritFrom( LUI.UIElement )
CoD.Shield_SafeAreaContainer_ModManager.__defaultWidth = 1920
CoD.Shield_SafeAreaContainer_ModManager.__defaultHeight = 1080
CoD.Shield_SafeAreaContainer_ModManager.new = function ( f1_arg0, f1_arg1, f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	local self = LUI.UIElement.new( f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	self:setClass( CoD.Shield_SafeAreaContainer_ModManager )
	self.id = "Shield_SafeAreaContainer_ModManager"
	self.soundSet = "none"
	self.onlyChildrenFocusable = true
	self.anyChildUsesUpdateState = true

	local TabBacking = CoD.CommonTabBarBacking.new( f1_arg0, f1_arg1, -0.1, 1.1, 0, 0, 0, 0, 52, 89 )
	TabBacking.TabBackingBlur:setAlpha( 0 )
	self:addElement( TabBacking )
	self.TabBacking = TabBacking

	local CommonHeader = CoD.CommonHeader.new( f1_arg0, f1_arg1, 0, 1, 0, 0, 0, 0, 0, 67 )
	CommonHeader.subtitle.StageTitle:setText("^2Mod Manager")
	CommonHeader.subtitle.subtitle:setText("^3Custom Maps and Shield Mods")
	self:addElement( CommonHeader )
	self.CommonHeader = CommonHeader

	local HeaderStripe = CoD.header_container_frontend.new( f1_arg0, f1_arg1, 0, 1, 0, 0, 0, 0, 0, 42 )
	self:addElement( HeaderStripe )
	self.HeaderStripe = HeaderStripe

	-- the body: from 88 to 1832 of the 1920 across, from 140 to 940 down
	local ShieldModManagerBody = CoD.ShieldModManagerBody.new( f1_arg0, f1_arg1, 0.5, 0.5, -872, 872, 0, 0, 140, 940 )
	self:addElement( ShieldModManagerBody )
	self.ShieldModManagerBody = ShieldModManagerBody

	ShieldModManagerBody.id = "ShieldModManagerBody"

	LUI.OverrideFunction_CallOriginalSecond( self, "close", self.__onClose )

	if PostLoadFunc then
		PostLoadFunc( self, f1_arg1, f1_arg0 )
	end

	return self
end

CoD.Shield_SafeAreaContainer_ModManager.__onClose = function ( f5_arg0 )
	f5_arg0.TabBacking:close()
	f5_arg0.CommonHeader:close()
	f5_arg0.HeaderStripe:close()
	f5_arg0.ShieldModManagerBody:close()
end

---------------------------

-- the menu, opened from the main menu
CoD.ShieldModManager = InheritFrom( CoD.Menu )
LUI.createMenu.ShieldModManager = function ( f1_arg0, f1_arg1 )
	local self = CoD.Menu.NewForUIEditor( "ShieldModManager", f1_arg0 )
	local f1_local1 = self

	self:setClass( CoD.ShieldModManager )
	self.soundSet = "default"
	self:setOwner( f1_arg0 )
	self:setLeftRight( 0, 1, 0, 0 )
	self:setTopBottom( 0, 1, 0, 0 )
	self:playSound( "menu_open", f1_arg0 )
	self.anyChildUsesUpdateState = true

	local Background = CoD.StartMenuOptionsBackground.new( f1_local1, f1_arg0, 0, 1, 0, 0, 0, 1, 0, 0 )
	self:addElement( Background )
	self.Background = Background

	local FooterContainerFrontendRight = CoD.FooterContainer_Frontend_Right.new( f1_local1, f1_arg0, 0.5, 0.5, -960, 960, 1, 1, -48, 0 )
	self:addElement( FooterContainerFrontendRight )
	self.FooterContainerFrontendRight = FooterContainerFrontendRight

	local SafeAreaContainerModManager = CoD.Shield_SafeAreaContainer_ModManager.new( f1_local1, f1_arg0, 0, 0, 0, 1920, 0, 0, 0, 1080 )
	SafeAreaContainerModManager:registerEventHandler( "menu_loaded", function ( element, event )
		local f3_local0 = nil
		if element.menuLoaded then
			f3_local0 = element:menuLoaded( event )
		elseif element.super.menuLoaded then
			f3_local0 = element.super:menuLoaded( event )
		end
		if not IsPC() then
			SizeToSafeArea( element, f1_arg0 )
		end
		if not f3_local0 then
			f3_local0 = element:dispatchEventToChildren( event )
		end
		return f3_local0
	end )
	self:addElement( SafeAreaContainerModManager )
	self.SafeAreaContainerModManager = SafeAreaContainerModManager

	f1_local1:AddButtonCallbackFunction( self, f1_arg0, Enum[@"hash_3DD78803F918E9D"][@"hash_1805EFA15E9E7E5A"], nil, function ( element, menu, controller, model )
		GoBack( self, controller )
		return true
	end, function ( element, menu, controller )
		CoD.Menu.SetButtonLabel( menu, Enum[@"hash_3DD78803F918E9D"][@"hash_1805EFA15E9E7E5A"], @"hash_6A4032FB2AAB69F2", nil, nil )
		return true
	end, false )

	FooterContainerFrontendRight:setModel( self.buttonModel, f1_arg0 )
	if CoD.isPC then
		FooterContainerFrontendRight.id = "FooterContainerFrontendRight"
	end

	SafeAreaContainerModManager.id = "SafeAreaContainerModManager"

	self:processEvent( {
		name = "menu_loaded",
		controller = f1_arg0
	} )

	LUI.OverrideFunction_CallOriginalSecond( self, "close", self.__onClose )

	if PostLoadFunc then
		PostLoadFunc( self, f1_arg0 )
	end

	CoD.EnhPrintInfo("Called", "Shield's Mods")

	SizeToSafeArea(SafeAreaContainerModManager, f1_arg0)

	return self
end

CoD.ShieldModManager.__onClose = function ( f8_arg0 )
	f8_arg0.Background:close()
	f8_arg0.FooterContainerFrontendRight:close()
	f8_arg0.SafeAreaContainerModManager:close()
end
