-- Pictures of the player's own as emblem stickers (shield-client emblem_import.cpp): an "Import Image" popup and an "Imported" decal tab

---------------------------

CoD.ShieldInitLuaFile()

---------------------------

-- our decal tab: no category of the game (the icon filter folds unknown ones into its own, our list never asks it)
local IMPORT_CATEGORY = 50
local FIRST_ICON = 1000

local function ImportOn()
	return ShieldFuncs ~= nil and ShieldFuncs.EmblemImport ~= nil and ShieldFuncs.EmblemImportFiles ~= nil
end

local function ImportLog( text )
	Engine[@"printinfo"]( Enum[@"consolelabel_e"][@"con_label_live"], "[emblem_import] " .. text .. "\n" )
end

-- the pictures of project-bo4/emblems as { file, name, icon, shared } (icon -1 while not imported, shared once uploaded)
local function ImportFiles()
	local files = {}
	if not ImportOn() then
		return files
	end
	local text = ShieldFuncs.EmblemImportFiles() or ""
	for line in string.gmatch( text, "[^\n]+" ) do
		local file, icon, id = string.match( line, "^(.*)\t(%-?%d+)\t(%d+)$" )
		if file == nil then
			file, icon = string.match( line, "^(.*)\t(%-?%d+)$" )
		end
		if file ~= nil then
			table.insert( files, {
				file = file,
				name = string.match( file, "^(.*)%.[^%.]*$" ) or file,
				icon = tonumber( icon ) or -1,
				shared = ( tonumber( id or "0" ) or 0 ) > 0
			} )
		end
	end
	return files
end

---------------------------

-- the "Imported" tab of the decal list, once
local function AddImportTab()
	local tabs = CoD.CraftUtility ~= nil and CoD.CraftUtility.EMBLEM_DECALTABS or nil
	if tabs == nil then
		return
	end
	for _, tab in ipairs( tabs ) do
		if tab.type == "SHIELDIMPORT" then
			return
		end
	end
	table.insert( tabs, {
		type = "SHIELDIMPORT",
		displayName = @"shield/emblem_import/tab",
		category = IMPORT_CATEGORY
	} )
end

if ImportOn() then
	AddImportTab()
end

-- the tab's list: the imported pictures, items as the game's own (AddStickersToDecalList)
if DataSources.EmblemIconList ~= nil and DataSources.EmblemIconList.ShieldStockPrepare == nil then
	DataSources.EmblemIconList.ShieldStockPrepare = DataSources.EmblemIconList.prepare
	DataSources.EmblemIconList.prepare = function ( controller, list, filter )
		if CoD.perController[controller].selectedDecalCategory ~= IMPORT_CATEGORY then
			return DataSources.EmblemIconList.ShieldStockPrepare( controller, list, filter )
		end
		list.emblemIconList = {}
		local parent = Engine[@"createmodel"]( Engine[@"getmodelforcontroller"]( controller ), "Emblems.DecalList" )
		local index = 1
		for _, entry in ipairs( ImportFiles() ) do
			if entry.icon >= FIRST_ICON then
				local model = Engine[@"createmodel"]( parent, "icon_" .. index )
				model:create( "iconID" ):set( entry.icon )
				model:create( "sortKey" ):set( entry.icon )
				model:create( "displayName" ):set( entry.name )
				model:create( "category" ):set( @"hash_684446BBFA84177E" )
				model:create( "owned" ):set( true )
				model:create( "skipDefaultTitle" ):set( false )
				model:create( "hideRarity" ):set( false )
				CoD.CraftUtility.Emblems.CopyLootModels( model, nil )
				table.insert( list.emblemIconList, model )
				index = index + 1
			end
		end
		list.selectIndex = 1
	end
end

---------------------------

-- the popup
local POPUP_WIDTH = 1240
local POPUP_HEIGHT = 680
local ROWS = 6
local COLUMNS = 2
local PAGE_SIZE = ROWS * COLUMNS
local ROW_TOP = 196
local ROW_STEP = 56
local ROW_HEIGHT = 46
local BUTTONS_TOP = 584
local AccentColor = { r = 0.4, g = 0.78, b = 1 }

CoD.ShieldEmblemImportBody = InheritFrom( LUI.UIElement )
CoD.ShieldEmblemImportBody.__defaultWidth = POPUP_WIDTH
CoD.ShieldEmblemImportBody.__defaultHeight = POPUP_HEIGHT
CoD.ShieldEmblemImportBody.new = function ( menu, controller, f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	local UI = CoD.Shield.BrowserUI

	local self = LUI.UIElement.new( f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	self:setClass( CoD.ShieldEmblemImportBody )
	self.id = "ShieldEmblemImportBody"
	self.soundSet = "default"
	self.onlyChildrenFocusable = true
	self.anyChildUsesUpdateState = true

	self.Parts = {}
	self.Buttons = {}
	self.files = {}
	self.page = 0
	self.selected = nil

	local function Add( element )
		self:addElement( element )
		table.insert( self.Parts, element )
		return element
	end

	local center = Enum[@"luialignment"][@"lui_alignment_center"]

	Add( UI.NewBox( 0, POPUP_WIDTH, 0, POPUP_HEIGHT, 0, 0, 0, 0.92 ) )
	Add( UI.NewBox( 0, POPUP_WIDTH, 0, 4, AccentColor.r, AccentColor.g, AccentColor.b, 1 ) )

	local Frame = LUI.UIImage.new( 0, 1, -1, 1, 0, 1, -1, 1 )
	Frame:setAlpha( 0.2 )
	Frame:setImage( RegisterImage( @"uie_ui_menu_store_common_frame" ) )
	Frame:setMaterial( LUI.UIImage.GetCachedMaterial( @"uie_nineslice_add" ) )
	Frame:setShaderVector( 0, 0, 0, 0, 0 )
	Frame:setupNineSliceShader( 12, 12 )
	Add( Frame )

	Add( UI.NewCaption( 40, POPUP_WIDTH - 40, 30, "EMBLEM EDITOR", center ) )

	local Title = Add( UI.NewText( 40, POPUP_WIDTH - 40, 52, 40, "notosans_bold", center ) )
	Title:setRGB( AccentColor.r, AccentColor.g, AccentColor.b )
	Title:setText( "IMPORT IMAGE" )

	local Help = Add( UI.NewText( 40, POPUP_WIDTH - 40, 112, 20, "ttmussels_regular", center ) )
	Help:setRGB( 0.8, 0.8, 0.8 )
	Help:setText( "Pictures (PNG, JPG, BMP, GIF) in project-bo4/emblems. Pick one: it becomes a sticker in the Imported tab of the decals." )

	self.Status = Add( UI.NewText( 40, POPUP_WIDTH - 40, 146, 22, "ttmussels_regular", center ) )
	self.Status:setRGB( AccentColor.r, AccentColor.g, AccentColor.b )

	Add( UI.NewBox( 120, POPUP_WIDTH - 120, 180, 181, 1, 1, 1, 0.1 ) )

	self.PageText = Add( UI.NewText( 40, POPUP_WIDTH - 40, ROW_TOP + ROWS * ROW_STEP + 6, 20, "ttmussels_regular", center ) )
	self.PageText:setRGB( 0.6, 0.6, 0.6 )

	-- a button of ours: kept on the body under its id (the menu finds focus by parent[id])
	local function NewButton( name, label, left, right, top, bottom, action )
		local button = UI.NewBrowserButton( self, menu, controller, label, left, right, top, bottom )
		button.id = name
		self[name] = button
		self:addElement( button )
		table.insert( self.Buttons, button )
		UI.OnBrowserButton( menu, controller, button, action )
		return button
	end

	local columnWidth = ( POPUP_WIDTH - 80 - 20 ) / COLUMNS
	self.Rows = {}
	for index = 1, PAGE_SIZE do
		local column = math.floor( ( index - 1 ) / ROWS )
		local row = ( index - 1 ) % ROWS
		local left = 40 + column * ( columnWidth + 20 )
		local top = ROW_TOP + row * ROW_STEP
		self.Rows[index] = NewButton( "Row" .. index, "", left, left + columnWidth, top, top + ROW_HEIGHT, function ()
			self:pick( index )
		end )
	end

	NewButton( "PrevPage", "< PREV", 40, 250, BUTTONS_TOP, BUTTONS_TOP + 48, function ()
		self:turnPage( -1 )
	end )
	NewButton( "NextPage", "NEXT >", 266, 476, BUTTONS_TOP, BUTTONS_TOP + 48, function ()
		self:turnPage( 1 )
	end )
	NewButton( "OpenFolder", "OPEN FOLDER", 492, 712, BUTTONS_TOP, BUTTONS_TOP + 48, function ()
		ShieldFuncs.EmblemImportOpenFolder()
		self:setStatus( "Put pictures in the folder, then press REFRESH" )
	end )
	NewButton( "Refresh", "REFRESH", 728, 918, BUTTONS_TOP, BUTTONS_TOP + 48, function ()
		self:refresh()
		self:setStatus( #self.files .. " picture(s) found" )
	end )
	-- the upload goes in the background: the rows follow it
	local Poll = LUI.UITimer.newElementTimer( 2000, false, function ()
		self:refresh()
	end )
	self:addElement( Poll )
	table.insert( self.Parts, Poll )
	NewButton( "Remove", "REMOVE", 934, 1094, BUTTONS_TOP, BUTTONS_TOP + 48, function ()
		self:removeSelected()
	end )
	NewButton( "Done", "DONE", 1110, POPUP_WIDTH - 40, BUTTONS_TOP, BUTTONS_TOP + 48, function ()
		PlaySoundAlias( "uin_party_ease_slide_back" )
		GoBack( menu, controller )
	end )

	self:refresh()
	if not ImportOn() then
		self:setStatus( "This Shield client has no image import: update it" )
	elseif #self.files == 0 then
		self:setStatus( "No pictures yet: press OPEN FOLDER and put some in" )
	else
		self:setStatus( "Pick a picture to import it" )
	end

	LUI.OverrideFunction_CallOriginalSecond( self, "close", self.__onClose )

	if PostLoadFunc then
		PostLoadFunc( self, controller, menu )
	end

	return self
end

CoD.ShieldEmblemImportBody.setStatus = function ( self, text )
	self.Status:setText( text )
end

-- the label of a row: the picture's name, marked once imported
CoD.ShieldEmblemImportBody.rowLabel = function ( self, entry )
	local label = CoD.Shield.BrowserUI.ShortenText ~= nil and CoD.Shield.BrowserUI.ShortenText( entry.name, 40 ) or entry.name
	if entry.icon >= FIRST_ICON and entry.shared then
		label = label .. "   (SHARED)"
	elseif entry.icon >= FIRST_ICON then
		label = label .. "   (IMPORTED, SHARING...)"
	end
	if self.selected ~= nil and self.selected == entry.file then
		label = "> " .. label
	end
	return label
end

CoD.ShieldEmblemImportBody.showPage = function ( self )
	local pages = math.max( 1, math.ceil( #self.files / PAGE_SIZE ) )
	self.page = math.max( 0, math.min( self.page, pages - 1 ) )
	for index = 1, PAGE_SIZE do
		local entry = self.files[self.page * PAGE_SIZE + index]
		local button = self.Rows[index]
		local label = entry ~= nil and self:rowLabel( entry ) or ""
		button.MiddleText:setText( label )
		button.MiddleTextFocus:setText( label )
		button:setAlpha( entry ~= nil and 1 or 0 )
	end
	local used = 0
	for _, entry in ipairs( self.files ) do
		if entry.icon >= FIRST_ICON then
			used = used + 1
		end
	end
	self.PageText:setText( "Page " .. ( self.page + 1 ) .. " / " .. pages .. "   ·   " .. #self.files .. " picture(s), " .. used .. " imported" )
end

CoD.ShieldEmblemImportBody.refresh = function ( self )
	self.files = ImportFiles()
	self:showPage()
end

CoD.ShieldEmblemImportBody.turnPage = function ( self, step )
	self.page = self.page + step
	self:showPage()
end

CoD.ShieldEmblemImportBody.pick = function ( self, index )
	local entry = self.files[self.page * PAGE_SIZE + index]
	if entry == nil or not ImportOn() then
		return
	end
	self.selected = entry.file
	local icon, text = ShieldFuncs.EmblemImport( entry.file )
	if icon ~= nil and icon >= FIRST_ICON then
		if entry.icon >= FIRST_ICON then
			self:setStatus( "Reloaded " .. entry.name .. ": its picture is up to date" )
		else
			self:setStatus( "Imported " .. entry.name .. ": in the Imported tab. Save your emblem once it says SHARED so others see it" )
		end
		ImportLog( entry.file .. " is icon " .. tostring( icon ) )
	else
		self:setStatus( "Can't import " .. entry.name .. ": " .. tostring( text ) )
	end
	self:refresh()
end

CoD.ShieldEmblemImportBody.removeSelected = function ( self )
	if self.selected == nil then
		self:setStatus( "Pick an imported picture first, then REMOVE" )
		return
	end
	local name = string.match( self.selected, "^(.*)%.[^%.]*$" ) or self.selected
	if ShieldFuncs.EmblemImportForget( self.selected ) then
		self:setStatus( "Removed " .. name .. ": emblems using it show nothing there now" )
		self.selected = nil
	else
		self:setStatus( name .. " isn't imported" )
	end
	self:refresh()
end

CoD.ShieldEmblemImportBody.__onClose = function ( self )
	for _, element in ipairs( self.Parts ) do
		element:close()
	end
	for _, button in ipairs( self.Buttons ) do
		button:close()
	end
end

CoD.ShieldEmblemImport = InheritFrom( CoD.Menu )
LUI.createMenu.ShieldEmblemImport = function ( controller, userData )
	local self = CoD.Menu.NewForUIEditor( "ShieldEmblemImport", controller )
	local menu = self

	self:setClass( CoD.ShieldEmblemImport )
	self.soundSet = "default"
	self:setOwner( controller )
	self:setLeftRight( 0, 1, 0, 0 )
	self:setTopBottom( 0, 1, 0, 0 )
	self:playSound( "menu_open", controller )
	self.anyChildUsesUpdateState = true

	local Blackfade = LUI.UIImage.new( 0, 1, 0, 0, 0, 1, 0, 0 )
	Blackfade:setRGB( 0, 0, 0 )
	Blackfade:setAlpha( 0.6 )
	self:addElement( Blackfade )
	self.Blackfade = Blackfade

	local FooterContainerFrontendRight = CoD.FooterContainer_Frontend_Right.new( menu, controller, 0.5, 0.5, -960, 960, 1, 1, -48, 0 )
	self:addElement( FooterContainerFrontendRight )
	self.FooterContainerFrontendRight = FooterContainerFrontendRight

	local Body = CoD.ShieldEmblemImportBody.new( menu, controller, 0.5, 0.5, -POPUP_WIDTH / 2, POPUP_WIDTH / 2, 0.5, 0.5, -POPUP_HEIGHT / 2, POPUP_HEIGHT / 2 )
	self:addElement( Body )
	self.ShieldEmblemImportBody = Body

	menu:AddButtonCallbackFunction( self, controller, Enum[@"hash_3DD78803F918E9D"][@"hash_1805EFA15E9E7E5A"], nil, function ( element, menu, controller, model )
		GoBack( self, controller )
		return true
	end, function ( element, menu, controller )
		CoD.Menu.SetButtonLabel( menu, Enum[@"hash_3DD78803F918E9D"][@"hash_1805EFA15E9E7E5A"], @"hash_6A4032FB2AAB69F2", nil, nil )
		return true
	end, false )

	FooterContainerFrontendRight:setModel( self.buttonModel, controller )
	if CoD.isPC then
		FooterContainerFrontendRight.id = "FooterContainerFrontendRight"
	end
	Body.id = "ShieldEmblemImportBody"

	self:processEvent( {
		name = "menu_loaded",
		controller = controller
	} )
	self.__defaultFocus = Body

	LUI.OverrideFunction_CallOriginalSecond( self, "close", self.__onClose )

	if PostLoadFunc then
		PostLoadFunc( self, controller )
	end

	return self
end

CoD.ShieldEmblemImport.__onClose = function ( self )
	self.FooterContainerFrontendRight:close()
	self.ShieldEmblemImportBody:close()
end

---------------------------

-- "Import Image" on the editor's PC side panel (browse mode), after the game's actions
if CoD.PCUtil ~= nil and CoD.PCUtil.Craft_GetEmblemEditorBrowseModeActions ~= nil and CoD.PCUtil.ShieldStockBrowseModeActions == nil then
	CoD.PCUtil.ShieldStockBrowseModeActions = CoD.PCUtil.Craft_GetEmblemEditorBrowseModeActions
	CoD.PCUtil.Craft_GetEmblemEditorBrowseModeActions = function ( controller )
		local actions = CoD.PCUtil.ShieldStockBrowseModeActions( controller )
		if ImportOn() and IsEmblemEditor( controller ) then
			table.insert( actions, {
				models = {
					actionName = @"shield/emblem_import/button",
					widgetType = "button",
					action = function ( button, element, controller, param, editorMenu )
						OpenOverlay( editorMenu or button, "ShieldEmblemImport", controller )
					end
				},
				properties = {}
			} )
		end
		return actions
	end
end
