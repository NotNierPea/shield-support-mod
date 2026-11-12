--[[
		.\hksc.exe ".\Lua\Frontend Side\Freerun\Freerun.lua" -o "C:\Program Files (x86)\Call of Duty Black Ops 4\project-bo4\internals\T8ShieldSupport\Lua\Frontend\Freerun.luac"
]]

---------------------------

CoD.ShieldInitLuaFile()

---------------------------

--[[
	The Freerun menu, a tile of the main menu (MainMenu.lua): a multiplayer map, a course of it (or free roam, or the
	course editor) and the movement it is run with. The client launches it (freerun_start, shield-client freerun.cpp):
	a custom game of free for all, the player's own mods off while it runs. The courses come from the client
	(freerun_list), each course's leaderboard from the master server (freerun_board). Drawn with CoD.Shield.BrowserUI.
]]

CoD.ShieldFreerun = CoD.ShieldFreerun or {}
CoD.ShieldFreerun.Courses = CoD.ShieldFreerun.Courses or {}

-- the movement categories: a time counts on the board of its category only
local FreerunCategories = {
	{ key = 1, label = "VANILLA", name = "Vanilla movement", hint = "The game's own movement. ^3Your Shield movement settings are put back after the run." },
	{ key = 2, label = "SHIELD", name = "Shield movement", hint = "Omni sprint, slide chaining and the rest of the Shield movement preset, the same for everyone." }
}

-- kept while the game runs: the menu opens on the last pick
local Freerun = {
	category = 1,
	map = "",
	course = "",
	mapRows = {},
	courseRows = {}
}

local FREERUN_ACCENT = { r = 0.35, g = 0.85, b = 1 }

local function FreerunModel( name )
	return Engine[@"createmodel"]( Engine[@"getglobalmodel"](), "ShieldFreerun." .. name )
end

local function RowOf( rows, id )
	for _, row in ipairs( rows ) do
		if row.id == id then
			return row
		end
	end
	return nil
end

local function IsPlainName( name )
	return type( name ) == "string" and string.len( name ) <= 64 and string.find( name, "^[%w_%-]+$" ) ~= nil
end

local function IsPicture( image )
	return image ~= nil and image ~= "" and image ~= @"hash_0" and image ~= @"blacktransparent"
end

-- 1:02.345, or - for none
local function Clock( ms )
	if ms == nil or ms <= 0 then
		return "-"
	end
	return string.format( "%d:%02d.%03d", math.floor( ms / 60000 ), math.floor( ms / 1000 ) % 60, ms % 1000 )
end

local function CoursesOf( map )
	local list = {}
	for _, course in ipairs( CoD.ShieldFreerun.Courses or {} ) do
		if course.map == map then
			table.insert( list, course )
		end
	end
	table.sort( list, function ( a, b )
		if a.shipped ~= b.shipped then
			return a.shipped
		end
		return a.name < b.name
	end )
	return list
end

-- the multiplayer and zombies maps (Blackout's are too big for a run), in the order of the game, ours among them
local function MapRows()
	local rows = {}
	local seen = {}
	for _, info in pairs( CoD.MapUtility.MapsTable ) do
		local id = info[@"hash_3E2D141CB22F2813"]
		if type( id ) ~= "string" or id == "" then
			id = info.mapToLoad
		end
		local listed = info.dlc_pack ~= nil and info.dlc_pack > -1
		local mp = info.session_mode == Enum[@"emodes"][@"mode_multiplayer"] and string.sub( id or "", 1, 3 ) == "mp_"
		local zm = info.session_mode == Enum[@"emodes"][@"mode_zombies"] and string.sub( id or "", 1, 3 ) == "zm_"
		if ( mp or zm ) and listed and IsPlainName( id ) and not seen[id] then
			seen[id] = true
			local name = CoD.MapUtility.GetLocalizedMapValue( id, "mapName", "" )
			if type( name ) ~= "string" or string.find( name, "%S" ) == nil then
				name = id
			end
			local count = #CoursesOf( id )
			table.insert( rows, {
				id = id,
				name = name,
				sub = ( zm and "Zombies  -  " or "Multiplayer  -  " ) .. ( count == 1 and "1 course" or ( count .. " courses" ) ),
				kind = "map",
				image = info.previewImage,
				count = count,
				sort = info.uniqueID or info.unique_id or 0
			} )
		end
	end
	-- maps with courses first
	table.sort( rows, function ( a, b )
		if ( a.count > 0 ) ~= ( b.count > 0 ) then
			return a.count > 0
		end
		if a.sort ~= b.sort then
			return a.sort < b.sort
		end
		return a.id < b.id
	end )
	return rows
end

local function CourseRows( map )
	local rows = {}
	for _, course in ipairs( CoursesOf( map ) ) do
		local best = Freerun.category == 2 and course.best2 or course.best1
		local sub = course.points .. " checkpoints"
		if course.author ~= nil and course.author ~= "" then
			sub = sub .. "  -  by " .. course.author
		end
		if best ~= nil and best > 0 then
			sub = sub .. "  -  best " .. Clock( best )
		end
		table.insert( rows, { id = course.id, name = course.name, sub = sub, kind = "course", course = course } )
	end
	table.insert( rows, { id = "-", name = "Free Roam", sub = "No course, no timer: the map and the grapple", kind = "roam" } )
	table.insert( rows, { id = "edit", name = "Course Editor", sub = "Lay a new course down on this map", kind = "edit" } )
	return rows
end

local function KeepOrFirst( rows, id )
	if RowOf( rows, id ) ~= nil then
		return id
	elseif rows[1] ~= nil then
		return rows[1].id
	end
	return ""
end

local function Rebuild()
	Freerun.mapRows = MapRows()
	Freerun.map = KeepOrFirst( Freerun.mapRows, Freerun.map )
	Freerun.courseRows = CourseRows( Freerun.map )
	Freerun.course = KeepOrFirst( Freerun.courseRows, Freerun.course )
	FreerunModel( "map" ):set( Freerun.map )
	FreerunModel( "course" ):set( Freerun.course )
end

local function RowsToItems( rows )
	local items = {}
	for _, row in ipairs( rows ) do
		table.insert( items, {
			models = {
				Name = row.name,
				Sub = row.sub,
				Id = row.id,
				Kind = row.kind,
				Image = row.image or ""
			},
			properties = {}
		} )
	end
	return items
end

DataSources.ShieldFreerunEmpty = DataSourceHelpers.ListSetup( "ShieldFreerunEmpty", function ( f3_arg0, f3_arg1 )
	return {}
end, true )

DataSources.ShieldFreerunMaps = DataSourceHelpers.ListSetup( "ShieldFreerunMaps", function ( f3_arg0, f3_arg1 )
	return RowsToItems( Freerun.mapRows )
end, true )

DataSources.ShieldFreerunCourses = DataSourceHelpers.ListSetup( "ShieldFreerunCourses", function ( f3_arg0, f3_arg1 )
	return RowsToItems( Freerun.courseRows )
end, true )

local function Toast( text )
	if CoD.ShowServerToast then
		CoD.ShowServerToast( text )
	end
end

---------------------------

--[[
	The body, 1744 by 740. Left, 1060 wide: the title with the categories, the maps and their courses. Right, from
	1084: the card of the pick (the map's picture, best time, the course's top ten) and the button that starts it.
]]
local FR_CARD_LEFT = 1084
local FR_CARD_RIGHT = 1744
local FR_CARD_IMAGE_HEIGHT = 260
local FR_CARD_BOTTOM = 680
local FR_CARD_TEXT_LEFT = FR_CARD_LEFT + 24
local FR_CARD_TEXT_RIGHT = FR_CARD_RIGHT - 24
local FR_CARD_HALF = FR_CARD_LEFT + 340
local FR_CHIPS_LEFT = 320
local FR_ROW_WIDTH = 520
local FR_ROW_HEIGHT = 44
local FR_ROW_THUMB_WIDTH = 78
local FR_LIST_TOP = 168
local FR_LIST_ROWS = 11
local FR_LIST_HEIGHT = FR_LIST_ROWS * FR_ROW_HEIGHT + ( FR_LIST_ROWS - 1 ) * 6
local FR_COURSES_LEFT = 540
local FR_BOARD_ROWS = 10
local FR_BOARD_TOP = 384
local FR_BOARD_LINE = 26

CoD.ShieldFreerunBody = InheritFrom( LUI.UIElement )
CoD.ShieldFreerunBody.__defaultWidth = 1744
CoD.ShieldFreerunBody.__defaultHeight = 740
CoD.ShieldFreerunBody.new = function ( f1_arg0, f1_arg1, f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	local UI = CoD.Shield.BrowserUI

	local self = LUI.UIElement.new( f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	self:setClass( CoD.ShieldFreerunBody )
	self.id = "ShieldFreerunBody"
	self.soundSet = "default"
	self.onlyChildrenFocusable = true
	self.anyChildUsesUpdateState = true

	self.Parts = {}
	self.Buttons = {}

	local function Add( element )
		self:addElement( element )
		table.insert( self.Parts, element )
		return element
	end

	-- the menu finds what can take the focus as parent[id]
	local function AddButton( id, label, left, right, top, bottom )
		local button = UI.NewBrowserButton( self, f1_arg0, f1_arg1, label, left, right, top, bottom )
		self:addElement( button )
		button.id = id
		self[id] = button
		table.insert( self.Buttons, button )
		return button
	end

	local function AddActiveMark( chip )
		local mark = LUI.UIImage.new( 0, 1, 0, 0, 1, 1, -3, 0 )
		mark:setRGB( FREERUN_ACCENT.r, FREERUN_ACCENT.g, FREERUN_ACCENT.b )
		mark:setAlpha( 0 )
		chip:addElement( mark )
		chip.ActiveMark = mark
	end

	Rebuild()

	---------------------------
	-- the two lists

	local function NewList( left )
		local list = LUI.UIList.new( f1_arg0, f1_arg1, 6, 0, nil, false, false, false, false )
		list:setLeftRight( 0, 0, left, left + FR_ROW_WIDTH )
		list:setTopBottom( 0, 0, FR_LIST_TOP, FR_LIST_TOP + FR_LIST_HEIGHT )
		list:setDataSource( "ShieldFreerunEmpty" )
		list:setWidgetType( CoD.ShieldFreerunRow )
		list:setVerticalCount( FR_LIST_ROWS )
		list:setSpacing( 6 )
		list:setAlignment( Enum[@"luialignment"][@"lui_alignment_left"] )
		list:setVerticalCounter( CoD.verticalCounter )
		list:appendEventHandler( "input_source_changed", function ( f2_arg0, f2_arg1 )
			f2_arg1.menu = f2_arg1.menu or f1_arg0
			CoD.Menu.UpdateButtonShownState( f2_arg0, f1_arg0, f1_arg1, Enum[@"luibutton"][@"lui_key_xba_pscross"] )
		end )
		list:registerEventHandler( "gain_focus", function ( element, event )
			local f5_local0 = nil
			if element.gainFocus then
				f5_local0 = element:gainFocus( event )
			elseif element.super.gainFocus then
				f5_local0 = element.super:gainFocus( event )
			end
			CoD.Menu.UpdateButtonShownState( element, f1_arg0, f1_arg1, Enum[@"luibutton"][@"lui_key_xba_pscross"] )
			return f5_local0
		end )
		return list
	end

	-- emptied and put back to its top before the new rows come (a list keeps the row it was scrolled to)
	local function ReloadList( list, source )
		list:setDataSource( "ShieldFreerunEmpty" )
		list:updateDataSource()
		list:clearLayout()
		list:clearSavedActiveIndex()
		list:setDataSource( source )
		list:updateDataSource()
	end

	local function OnListRow( list, action )
		f1_arg0:AddButtonCallbackFunction( list, f1_arg1, Enum[@"luibutton"][@"lui_key_xba_pscross"], "ui_confirm", function ( element, menu, controller, model )
			if IsGamepad( controller ) or IsMouseOrKeyboard( controller ) then
				action( element )
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
	end

	local MapList = NewList( 0 )
	local CourseList = NewList( FR_COURSES_LEFT )

	---------------------------
	-- over the lists

	local Title = Add( UI.NewText( 0, FR_CHIPS_LEFT - 12, -4, 32, "notosans_bold" ) )
	Title:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )
	Title:setText( "FREERUN" )

	Add( UI.NewCaption( 2, FR_CHIPS_LEFT - 12, 30, "MOVEMENT" ) )

	local Hint = Add( UI.NewText( 2, 1060, 110, 16, "ttmussels_regular" ) )
	Hint:setRGB( 0.62, 0.62, 0.62 )

	Add( UI.NewCaption( 18, FR_ROW_WIDTH, 138, "MAP" ) )
	Add( UI.NewCaption( FR_COURSES_LEFT + 18, FR_COURSES_LEFT + FR_ROW_WIDTH, 138, "COURSE" ) )
	Add( UI.NewBox( 0, 1060, 160, 161, 1, 1, 1, 0.12 ) )

	---------------------------
	-- the card

	local MapClip = LUI.UIElement.new( 0, 0, FR_CARD_LEFT, FR_CARD_RIGHT, 0, 0, 0, FR_CARD_IMAGE_HEIGHT )
	MapClip:setUseStencil( true )
	Add( MapClip )

	local MapImage = LUI.UIImage.new( 0, 1, 0, 0, 0, 1, 0, 0 )
	MapClip:addElement( MapImage )
	self.MapImage = MapImage

	UI.AddBottomFade( MapClip, FR_CARD_IMAGE_HEIGHT, 160 )

	local Card = {}
	Card.Accent = Add( UI.NewBox( FR_CARD_LEFT, FR_CARD_RIGHT, 0, 4, FREERUN_ACCENT.r, FREERUN_ACCENT.g, FREERUN_ACCENT.b, 1 ) )

	Card.Kind = Add( UI.NewText( FR_CARD_TEXT_LEFT, FR_CARD_TEXT_RIGHT, 160, 22, "ttmussels_regular" ) )
	Card.Kind:setRGB( 0.86, 0.86, 0.86 )
	Card.Kind:setLetterSpacing( 2 )

	Card.Title = Add( UI.NewText( FR_CARD_TEXT_LEFT, FR_CARD_TEXT_RIGHT, 190, 48, "notosans_bold" ) )
	Card.Title:setRGB( 1, 1, 1 )

	Add( UI.NewBox( FR_CARD_LEFT, FR_CARD_RIGHT, FR_CARD_IMAGE_HEIGHT, FR_CARD_BOTTOM, 0, 0, 0, 0.5 ) )

	Card.LeftCaption = Add( UI.NewCaption( FR_CARD_TEXT_LEFT, FR_CARD_HALF - 20, 278, "" ) )
	Card.LeftValue = Add( UI.NewText( FR_CARD_TEXT_LEFT, FR_CARD_HALF - 20, 300, 28, "notosans_bold" ) )
	Card.LeftValue:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )

	Card.RightCaption = Add( UI.NewCaption( FR_CARD_HALF, FR_CARD_TEXT_RIGHT, 278, "" ) )
	Card.RightValue = Add( UI.NewText( FR_CARD_HALF, FR_CARD_TEXT_RIGHT, 300, 28, "notosans_bold" ) )
	Card.RightValue:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )

	Add( UI.NewBox( FR_CARD_TEXT_LEFT, FR_CARD_TEXT_RIGHT, 342, 343, 1, 1, 1, 0.1 ) )
	Card.BoardCaption = Add( UI.NewCaption( FR_CARD_TEXT_LEFT, FR_CARD_TEXT_RIGHT, 356, "" ) )

	-- the board: ten lines of place, name and time; the words about free roam and the editor in their place
	Card.Lines = {}
	for i = 1, FR_BOARD_ROWS do
		local top = FR_BOARD_TOP + ( i - 1 ) * FR_BOARD_LINE
		local line = {}
		line.Place = Add( UI.NewText( FR_CARD_TEXT_LEFT, FR_CARD_TEXT_LEFT + 40, top, 20, "notosans_bold" ) )
		line.Name = Add( UI.NewText( FR_CARD_TEXT_LEFT + 44, FR_CARD_TEXT_RIGHT - 150, top, 20, "ttmussels_regular" ) )
		line.Time = Add( UI.NewText( FR_CARD_TEXT_RIGHT - 150, FR_CARD_TEXT_RIGHT, top, 20, "notosans_bold", Enum[@"luialignment"][@"lui_alignment_right"] ) )
		table.insert( Card.Lines, line )
	end

	Card.About = Add( UI.NewText( FR_CARD_TEXT_LEFT, FR_CARD_TEXT_RIGHT, FR_BOARD_TOP, 20, "ttmussels_regular" ) )
	Card.About:setRGB( 0.7, 0.7, 0.7 )

	local CardFrame = LUI.UIImage.new( 0, 0, FR_CARD_LEFT - 1, FR_CARD_RIGHT + 1, 0, 0, -1, FR_CARD_BOTTOM + 1 )
	CardFrame:setAlpha( 0.12 )
	CardFrame:setImage( RegisterImage( @"uie_ui_menu_store_common_frame" ) )
	CardFrame:setMaterial( LUI.UIImage.GetCachedMaterial( @"uie_nineslice_add" ) )
	CardFrame:setShaderVector( 0, 0, 0, 0, 0 )
	CardFrame:setupNineSliceShader( 12, 12 )
	Add( CardFrame )

	local function ClearBoard()
		for _, line in ipairs( Card.Lines ) do
			line.Place:setText( "" )
			line.Name:setText( "" )
			line.Time:setText( "" )
		end
	end

	-- the board the client sent, when it is still the one picked
	local function ShowBoard()
		local board = CoD.ShieldFreerun.Board
		ClearBoard()
		if board == nil or board.id ~= Freerun.course or board.category ~= Freerun.category then
			return
		end
		if not board.ok then
			Card.About:setText( "No leaderboard: the master server did not answer." )
			return
		end
		if #board.entries == 0 then
			Card.About:setText( "Nobody has a time here yet. Be the first." )
			return
		end
		Card.About:setText( "" )
		for i, entry in ipairs( board.entries ) do
			local line = Card.Lines[i]
			if line == nil then
				break
			end
			local r, g, b = 0.86, 0.86, 0.86
			if entry.mine then
				r, g, b = FREERUN_ACCENT.r, FREERUN_ACCENT.g, FREERUN_ACCENT.b
			end
			line.Place:setText( tostring( i ) )
			line.Name:setText( UI.ShortenText( entry.name or "?", 28 ) )
			line.Time:setText( Clock( entry.ms ) )
			line.Place:setRGB( r, g, b )
			line.Name:setRGB( r, g, b )
			line.Time:setRGB( r, g, b )
		end
	end

	local function AskBoard()
		local row = RowOf( Freerun.courseRows, Freerun.course )
		if row ~= nil and row.kind == "course" then
			Engine[@"exec"]( f1_arg1, "freerun_board " .. row.id .. " " .. Freerun.category )
		end
	end

	local function ShowPick()
		local map = RowOf( Freerun.mapRows, Freerun.map )
		local row = RowOf( Freerun.courseRows, Freerun.course )
		local category = FreerunCategories[Freerun.category]

		Hint:setText( category.hint )
		Card.Title:setText( row and row.name or "No course" )
		Card.Kind:setText( map and ToUpper( map.name ) or "" )
		ClearBoard()

		if row ~= nil and row.kind == "course" then
			local best = Freerun.category == 2 and row.course.best2 or row.course.best1
			Card.LeftCaption:setText( "CHECKPOINTS" )
			Card.LeftValue:setText( tostring( row.course.points ) )
			Card.RightCaption:setText( "YOUR BEST" )
			Card.RightValue:setText( Clock( best ) )
			Card.BoardCaption:setText( "LEADERBOARD  -  " .. ToUpper( category.name ) )
			Card.About:setText( "Asking the master server..." )
		elseif row ~= nil and row.kind == "edit" then
			Card.LeftCaption:setText( "MODE" )
			Card.LeftValue:setText( "Editor" )
			Card.RightCaption:setText( "SAVED TO" )
			Card.RightValue:setText( "freerun/courses" )
			Card.BoardCaption:setText( "HOW IT WORKS" )
			Card.About:setText( "Tap Use: the start where you stand, then each checkpoint after it. The last one is the finish.\n\nTap Melee: the last point off again.\n\nHold Use for two seconds: the course is saved and shows up here." )
		else
			Card.LeftCaption:setText( "MODE" )
			Card.LeftValue:setText( "Free Roam" )
			Card.RightCaption:setText( "TIMER" )
			Card.RightValue:setText( "None" )
			Card.BoardCaption:setText( "HOW IT WORKS" )
			Card.About:setText( "The map with the grapple and the knife, nothing else: nothing hurts, no time limit.\n\nIn a course: hold Use to go back to the last checkpoint, hold it longer to run again." )
		end

		UI.SetPreviewImage( MapImage, ( map ~= nil and IsPicture( map.image ) ) and map.image or @"uie_ui_menu_survey_arena", FR_CARD_RIGHT - FR_CARD_LEFT, FR_CARD_IMAGE_HEIGHT )
		MapImage:completeAnimation()
		MapImage:setAlpha( 0.35 )
		MapImage:beginAnimation( 180 )
		MapImage:setAlpha( 1 )

		AskBoard()
	end

	---------------------------
	-- the category chips

	self.CategoryChips = {}

	local function MarkChips()
		for _, chip in ipairs( self.CategoryChips ) do
			chip.ActiveMark:setAlpha( chip.FreerunCategory == Freerun.category and 1 or 0 )
		end
	end

	local function ShowAll()
		Rebuild()
		MarkChips()
		ReloadList( MapList, "ShieldFreerunMaps" )
		ReloadList( CourseList, "ShieldFreerunCourses" )
		ShowPick()
	end

	for index, info in ipairs( FreerunCategories ) do
		local left = FR_CHIPS_LEFT + ( index - 1 ) * 208
		local Chip = AddButton( "CategoryChip" .. index, info.label, left, left + 200, 0, 44 )
		Chip.FreerunCategory = info.key
		AddActiveMark( Chip )
		table.insert( self.CategoryChips, Chip )

		UI.OnBrowserButton( f1_arg0, f1_arg1, Chip, function ()
			PlaySoundAlias( "uin_paint_image_flip_toggle" )
			if Freerun.category ~= info.key then
				Freerun.category = info.key
				ShowAll()
			end
		end )
	end

	---------------------------
	-- start

	local StartButton = AddButton( "StartButton", "START", FR_CARD_LEFT, FR_CARD_RIGHT, 692, 740 )

	UI.OnBrowserButton( f1_arg0, f1_arg1, StartButton, function ()
		local row = RowOf( Freerun.courseRows, Freerun.course )
		if Freerun.map == "" or row == nil then
			PlaySoundAlias( "uin_unavailable_click" )
			Toast( "Pick a map first." )
			return
		end

		local course = row.kind == "course" and row.id or "-"
		local command = "freerun_start " .. Freerun.map .. " " .. course .. " " .. Freerun.category
		if row.kind == "edit" then
			command = command .. " edit"
		end

		PlaySoundAlias( "uin_toggle_generic" )
		CoD.EnhPrintInfo( "Freerun", command )
		Toast( "Starting freerun..." )
		-- Discord's presence (DiscordRPC.lua sets these from the lobby, zombies' launch has none) and no map intro movie
		local mapRow = RowOf( Freerun.mapRows, Freerun.map )
		Dvar[@"shield_rpc_Map"]:set( mapRow and mapRow.name or Freerun.map )
		Dvar[@"shield_rpc_Map_asset"]:set( Freerun.map )
		Dvar[@"shield_rpc_Gametype"]:set( "FREERUN" )
		Engine[@"exec"]( f1_arg1, "set shield_freerun_nointro 1" )
		GoBack( f1_arg0, f1_arg1 )
		Engine[@"exec"]( f1_arg1, command )
	end )

	---------------------------
	-- the rows

	OnListRow( MapList, function ( row )
		if row.RowId == nil or row.RowKind ~= "map" then
			return
		end
		PlaySoundAlias( "uin_toggle_generic" )
		Freerun.map = row.RowId
		FreerunModel( "map" ):set( Freerun.map )
		Freerun.courseRows = CourseRows( Freerun.map )
		Freerun.course = KeepOrFirst( Freerun.courseRows, "" )
		FreerunModel( "course" ):set( Freerun.course )
		ReloadList( CourseList, "ShieldFreerunCourses" )
		ShowPick()
	end )

	OnListRow( CourseList, function ( row )
		if row.RowId == nil or row.RowKind == "map" then
			return
		end
		PlaySoundAlias( "uin_toggle_generic" )
		Freerun.course = row.RowId
		FreerunModel( "course" ):set( Freerun.course )
		ShowPick()
	end )

	self:addElement( MapList )
	self.MapList = MapList
	MapList.id = "MapList"

	self:addElement( CourseList )
	self.CourseList = CourseList
	CourseList.id = "CourseList"

	-- the client's answers: the courses (freerun_list), a board (freerun_board)
	CoD.ShieldFreerun.OnCourses = function ()
		ShowAll()
	end
	CoD.ShieldFreerun.OnBoard = function ()
		ShowBoard()
	end

	MapList:addElement( LUI.UITimer.newElementTimer( 5, true, function ()
		ShowAll()
		Engine[@"exec"]( f1_arg1, "freerun_list" )
	end ) )

	MarkChips()

	LUI.OverrideFunction_CallOriginalSecond( self, "close", self.__onClose )

	if PostLoadFunc then
		PostLoadFunc( self, f1_arg1, f1_arg0 )
	end

	return self
end

CoD.ShieldFreerunBody.__onClose = function ( f9_arg0 )
	CoD.ShieldFreerun.OnCourses = nil
	CoD.ShieldFreerun.OnBoard = nil
	for _, element in ipairs( f9_arg0.Parts ) do
		element:close()
	end
	for _, button in ipairs( f9_arg0.Buttons ) do
		button:close()
	end
	f9_arg0.MapImage:close()
	f9_arg0.MapList:close()
	f9_arg0.CourseList:close()
end

---------------------------

-- a row of either list, 520 by 44: as the host lobby's (HostLobby.lua), the one picked marked
local FreerunRowFocusParts = {
	{ "BlackBar", function ( element, focus ) element:setAlpha( focus and 0.1 or 0.05 ) end },
	{ "Tint", function ( element, focus ) element:setAlpha( focus and 0.16 or 0 ) end },
	{ "FocusFrame", function ( element, focus ) element:setAlpha( focus and 1 or 0 ) end },
	{ "Accent", function ( element, focus ) element:setLeftRight( 0, 0, 0, focus and 7 or 4 ) end }
}

local function FreerunRowClip( focus, duration )
	return function ( self, event )
		return CoD.Shield.BrowserUI.FocusClip( FreerunRowFocusParts, focus, duration )( self, event )
	end
end

CoD.ShieldFreerunRow = InheritFrom( LUI.UIElement )
CoD.ShieldFreerunRow.__defaultWidth = FR_ROW_WIDTH
CoD.ShieldFreerunRow.__defaultHeight = FR_ROW_HEIGHT
CoD.ShieldFreerunRow.new = function ( f1_arg0, f1_arg1, f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	local UI = CoD.Shield.BrowserUI

	local self = LUI.UIElement.new( f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	self:setClass( CoD.ShieldFreerunRow )
	self.id = "ShieldFreerunRow"
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

	local Tint = LUI.UIImage.new( 0, 1, 0, 0, 0, 1, 0, 0 )
	Tint:setRGB( FREERUN_ACCENT.r, FREERUN_ACCENT.g, FREERUN_ACCENT.b )
	Tint:setAlpha( 0 )
	Add( Tint )
	self.Tint = Tint

	local Chosen = LUI.UIImage.new( 0, 1, 0, 0, 0, 1, 0, 0 )
	Chosen:setRGB( FREERUN_ACCENT.r, FREERUN_ACCENT.g, FREERUN_ACCENT.b )
	Chosen:setAlpha( 0 )
	Add( Chosen )

	local ThumbClip = LUI.UIElement.new( 0, 0, 0, FR_ROW_THUMB_WIDTH, 0, 0, 0, FR_ROW_HEIGHT )
	ThumbClip:setUseStencil( true )
	Add( ThumbClip )

	local Thumb = LUI.UIImage.new( 0, 1, 0, 0, 0, 1, 0, 0 )
	Thumb:setAlpha( 0 )
	ThumbClip:addElement( Thumb )
	self.Thumb = Thumb

	local Accent = LUI.UIImage.new( 0, 0, 0, 4, 0, 1, 0, 0 )
	Accent:setRGB( FREERUN_ACCENT.r, FREERUN_ACCENT.g, FREERUN_ACCENT.b )
	Add( Accent )
	self.Accent = Accent

	local Name = Add( UI.NewText( 18, FR_ROW_WIDTH - 20, 4, 21, "notosans_bold" ) )
	Name:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )

	local Sub = Add( UI.NewText( 18, FR_ROW_WIDTH - 20, 26, 14, "ttmussels_regular" ) )
	Sub:setRGB( 0.5, 0.5, 0.5 )
	Sub:setLetterSpacing( 1 )

	local ChosenMark = LUI.UIImage.new( 1, 1, -8, 0, 0, 1, 0, 0 )
	ChosenMark:setRGB( FREERUN_ACCENT.r, FREERUN_ACCENT.g, FREERUN_ACCENT.b )
	ChosenMark:setAlpha( 0 )
	Add( ChosenMark )

	local FocusFrame = LUI.UIImage.new( 0, 1, -4, 4, 0, 1, -4, 4 )
	FocusFrame:setRGB( FREERUN_ACCENT.r, FREERUN_ACCENT.g, FREERUN_ACCENT.b )
	FocusFrame:setAlpha( 0 )
	FocusFrame:setImage( RegisterImage( @"uie_ui_menu_store_focus_frame" ) )
	FocusFrame:setMaterial( LUI.UIImage.GetCachedMaterial( @"uie_nineslice_add" ) )
	FocusFrame:setShaderVector( 0, 0, 0, 0, 0 )
	FocusFrame:setupNineSliceShader( 10, 10 )
	Add( FocusFrame )
	self.FocusFrame = FocusFrame

	local MapModel = FreerunModel( "map" )
	local CourseModel = FreerunModel( "course" )

	local function ShowChosen()
		local chosen = false
		if self.RowId ~= nil then
			if self.RowKind == "map" then
				chosen = MapModel:get() == self.RowId
			else
				chosen = CourseModel:get() == self.RowId
			end
		end
		Chosen:setAlpha( chosen and 0.14 or 0 )
		ChosenMark:setAlpha( chosen and 1 or 0 )
	end

	Name:linkToElementModel( self, "Name", true, function ( model )
		if model:get() == nil then
			return
		end

		local image = CoD.ModelUtility.GetSelfModelPathValue( self, "Image" )
		local textLeft = 18

		self.RowId = CoD.ModelUtility.GetSelfModelPathValue( self, "Id" )
		self.RowKind = CoD.ModelUtility.GetSelfModelPathValue( self, "Kind" )

		if IsPicture( image ) then
			UI.SetPreviewImage( Thumb, image, FR_ROW_THUMB_WIDTH, FR_ROW_HEIGHT )
			Thumb:setAlpha( 1 )
			textLeft = FR_ROW_THUMB_WIDTH + 14
		else
			Thumb:setAlpha( 0 )
		end

		Name:setLeftRight( 0, 0, textLeft, FR_ROW_WIDTH - 20 )
		Sub:setLeftRight( 0, 0, textLeft, FR_ROW_WIDTH - 20 )
		Name:setText( model:get() )
		Sub:setText( CoD.ModelUtility.GetSelfModelPathValue( self, "Sub" ) or "" )

		ShowChosen()
	end )

	self:subscribeToModel( MapModel, function ( model )
		ShowChosen()
	end )

	self:subscribeToModel( CourseModel, function ( model )
		ShowChosen()
	end )

	LUI.OverrideFunction_CallOriginalSecond( self, "close", self.__onClose )

	if PostLoadFunc then
		PostLoadFunc( self, f1_arg1, f1_arg0 )
	end

	return self
end

CoD.ShieldFreerunRow.__resetProperties = function ( f7_arg0 )
	for _, part in ipairs( FreerunRowFocusParts ) do
		local element = f7_arg0[part[1]]
		element:completeAnimation()
		part[2]( element, false )
	end
end

CoD.ShieldFreerunRow.__clipsPerState = {
	DefaultState = {
		DefaultClip = FreerunRowClip( false ),
		Focus = FreerunRowClip( true ),
		GainFocus = FreerunRowClip( true, 120 ),
		LoseFocus = FreerunRowClip( false, 120 )
	}
}

CoD.ShieldFreerunRow.__onClose = function ( f10_arg0 )
	f10_arg0.Thumb:close()
	for _, element in ipairs( f10_arg0.Parts ) do
		element:close()
	end
end

---------------------------

CoD.Shield_SafeAreaContainer_Freerun = InheritFrom( LUI.UIElement )
CoD.Shield_SafeAreaContainer_Freerun.__defaultWidth = 1920
CoD.Shield_SafeAreaContainer_Freerun.__defaultHeight = 1080
CoD.Shield_SafeAreaContainer_Freerun.new = function ( f1_arg0, f1_arg1, f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	local self = LUI.UIElement.new( f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	self:setClass( CoD.Shield_SafeAreaContainer_Freerun )
	self.id = "Shield_SafeAreaContainer_Freerun"
	self.soundSet = "none"
	self.onlyChildrenFocusable = true
	self.anyChildUsesUpdateState = true

	local TabBacking = CoD.CommonTabBarBacking.new( f1_arg0, f1_arg1, -0.1, 1.1, 0, 0, 0, 0, 52, 89 )
	TabBacking.TabBackingBlur:setAlpha( 0 )
	self:addElement( TabBacking )
	self.TabBacking = TabBacking

	local CommonHeader = CoD.CommonHeader.new( f1_arg0, f1_arg1, 0, 1, 0, 0, 0, 0, 0, 67 )
	CommonHeader.subtitle.StageTitle:setText( "^2Freerun" )
	CommonHeader.subtitle.subtitle:setText( "^3Grapple, Run, Beat The Clock" )
	self:addElement( CommonHeader )
	self.CommonHeader = CommonHeader

	local HeaderStripe = CoD.header_container_frontend.new( f1_arg0, f1_arg1, 0, 1, 0, 0, 0, 0, 0, 42 )
	self:addElement( HeaderStripe )
	self.HeaderStripe = HeaderStripe

	local ShieldFreerunBody = CoD.ShieldFreerunBody.new( f1_arg0, f1_arg1, 0.5, 0.5, -872, 872, 0, 0, 140, 880 )
	self:addElement( ShieldFreerunBody )
	self.ShieldFreerunBody = ShieldFreerunBody
	ShieldFreerunBody.id = "ShieldFreerunBody"

	LUI.OverrideFunction_CallOriginalSecond( self, "close", self.__onClose )

	if PostLoadFunc then
		PostLoadFunc( self, f1_arg1, f1_arg0 )
	end

	return self
end

CoD.Shield_SafeAreaContainer_Freerun.__onClose = function ( f5_arg0 )
	f5_arg0.TabBacking:close()
	f5_arg0.CommonHeader:close()
	f5_arg0.HeaderStripe:close()
	f5_arg0.ShieldFreerunBody:close()
end

---------------------------

CoD.ShieldFreerunMenu = InheritFrom( CoD.Menu )
LUI.createMenu.ShieldFreerun = function ( f1_arg0, f1_arg1 )
	local self = CoD.Menu.NewForUIEditor( "ShieldFreerun", f1_arg0 )
	local f1_local1 = self

	self:setClass( CoD.ShieldFreerunMenu )
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

	local SafeAreaContainerFreerun = CoD.Shield_SafeAreaContainer_Freerun.new( f1_local1, f1_arg0, 0, 0, 0, 1920, 0, 0, 0, 1080 )
	SafeAreaContainerFreerun:registerEventHandler( "menu_loaded", function ( element, event )
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
	self:addElement( SafeAreaContainerFreerun )
	self.SafeAreaContainerFreerun = SafeAreaContainerFreerun

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

	SafeAreaContainerFreerun.id = "SafeAreaContainerFreerun"

	self:processEvent( {
		name = "menu_loaded",
		controller = f1_arg0
	} )

	LUI.OverrideFunction_CallOriginalSecond( self, "close", self.__onClose )

	if PostLoadFunc then
		PostLoadFunc( self, f1_arg0 )
	end

	CoD.EnhPrintInfo( "Called", "Shield's Freerun" )

	SizeToSafeArea( SafeAreaContainerFreerun, f1_arg0 )

	return self
end

CoD.ShieldFreerunMenu.__onClose = function ( f8_arg0 )
	f8_arg0.Background:close()
	f8_arg0.FooterContainerFrontendRight:close()
	f8_arg0.SafeAreaContainerFreerun:close()
end

---------------------------

--[[
	Back from a freerun match (shield-client freerun.cpp calls this once the menus and the player's mods are back): the
	lobby the match was started from is left, one step back at a time as its back button does, down to the main
	director, and the Freerun menu opens there. Ticked by a timer of the UI, as quickmap.cpp's walk is.
]]
local function FindOpenMenu( root )
	local found = nil
	local child = root and root:getFirstChild()
	while child do
		-- the main menu itself (the tile's menu), else the last menu
		if child.openOverlay and ( child.menuName == "Director" or child.id == "Menu.Director" ) then
			return child
		end
		if child.openOverlay then
			found = child
		end
		child = child:getNextSibling()
	end
	return found
end

CoD.ShieldFreerun.Reopen = function ()
	local root = LUI.roots.UIRootFull
	if not root then
		return
	end
	-- (a race's music left playing by the match: stopped by its alias)
	for _, alias in ipairs( { "shield_freerun_music", "shield_freerun_victory", "shield_freerun_failure" } ) do
		pcall( Engine[@"stopsound"], alias )
	end
	Engine[@"exec"]( Engine[@"getprimarycontroller"](), "set shield_freerun_nointro 0" )
	if CoD.ShieldFreerunReopenTimer then
		CoD.ShieldFreerunReopenTimer:close()
		CoD.ShieldFreerunReopenTimer = nil
	end

	local walk = { ticks = 0, sent = nil, wait = 0, settle = 0 }
	local timer = nil
	local function Done()
		if timer then
			timer:close()
		end
		CoD.ShieldFreerunReopenTimer = nil
	end

	timer = LUI.UITimer.newElementTimer( 300, false, function ()
		walk.ticks = walk.ticks + 1
		if walk.ticks > 60 then
			CoD.EnhPrintInfo( "Freerun", "could not get back to the main menu" )
			Done()
			return
		end

		local controller = Engine[@"getprimarycontroller"]()
		local current = Engine[@"getlobbyuiscreen"]()
		local home = LobbyData.GetLobbyMenuIDByName( LuaEnum.UI.DIRECTOR_ONLINE )
		if current ~= home then
			-- one step back, then wait for the screen to change (or try again after a while)
			if walk.sent ~= current or walk.wait > 10 then
				Engine[@"lobbyevent"]( "OnGoBack", { controller = controller, withParty = false } )
				walk.sent = current
				walk.wait = 0
			else
				walk.wait = walk.wait + 1
			end
			return
		end

		-- (the director builds its menu after the screen changes: opened too soon, it fought the popup for focus, the
		-- hover sounds repeating)
		walk.settle = walk.settle + 1
		if walk.settle < 4 then
			return
		end

		-- (one Freerun menu: a second under it stayed after ESC closed the top one)
		local child = root:getFirstChild()
		while child do
			if child.menuName == "ShieldFreerun" then
				CoD.EnhPrintInfo( "Freerun", "back: the Freerun menu is open already" )
				Done()
				return
			end
			child = child:getNextSibling()
		end

		-- opened as the main menu's tile does (DirectorSelectOpenPopup)
		local menu = FindOpenMenu( root )
		if menu then
			CoD.EnhPrintInfo( "Freerun", "back: the Freerun menu on " .. tostring( menu.menuName or menu.id ) )
			OpenPopup( menu, "ShieldFreerun", controller, "", "" )
		end
		Done()
	end )
	root:addElement( timer )
	CoD.ShieldFreerunReopenTimer = timer
end

-- a freerun match's map loads without its intro movie (Start sets the dvar, Reopen clears it; shield-client too)
if CoD.HUDUtility and CoD.HUDUtility.InitLoadingMovie and CoD.HUDUtility.InitLoadingMovie ~= CoD.ShieldFreerunNoIntroWrapper then
	local original = CoD.HUDUtility.InitLoadingMovie
	CoD.HUDUtility.InitLoadingMovie = function ( ... )
		if Engine[@"getdvarint"]( @"shield_freerun_nointro" ) == 1 then
			return
		end
		return original( ... )
	end
	CoD.ShieldFreerunNoIntroWrapper = CoD.HUDUtility.InitLoadingMovie
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

-- no after action report after a freerun match (still loading or just over: shield_freerun_nointro is 1 until Reopen):
-- zfreerun has no stats, its round stats errored (UI Error 80450)
if CoD.AARUtility and CoD.AARUtility.CanShowAAR and CoD.AARUtility.CanShowAAR ~= CoD.ShieldFreerunAARWrapper then
	local canShow = CoD.AARUtility.CanShowAAR
	CoD.AARUtility.CanShowAAR = function ( menu, controller, ... )
		local gametype = CoD.AARUtility.GetCurrentGametype and CoD.AARUtility.GetCurrentGametype( controller )
		if Engine[@"getdvarint"]( "shield_freerun_nointro" ) == 1 or gametype == "zfreerun" or gametype == "freerun" then
			for _, alias in ipairs( { "shield_freerun_music", "shield_freerun_victory", "shield_freerun_failure" } ) do
				pcall( Engine[@"stopsound"], alias )
			end
			return false
		end
		return canShow( menu, controller, ... )
	end
	CoD.ShieldFreerunAARWrapper = CoD.AARUtility.CanShowAAR
end
