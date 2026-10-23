--[[
		.\hksc.exe ".\Lua\CustomCamos.Lua" -o "C:\Program Files (x86)\Call of Duty Black Ops 4\project-bo4\mods\T8ShieldSupport\Lua\CustomCamos.luac"
]]

---------------------------

CoD.ShieldInitLuaFile()

---------------------------

--[[
	The camos of our own, camo index 399 and up, a category of the Shield tab of a weapon's camos in every mode
	(ExtraCamos.lua adds them).
	They are assets of the support fastfile (support_ff: tables/weaponcamo/shield_camos.json), drawn by the client's
	custom_camos.cpp; the list is the fastfile's gamedata/shield/custom_camos.csv: camo index, name, picture, words.
]]
local CAMO_TABLE = "gamedata/shield/custom_camos.csv"

-- the words over the list and the line under them, as low as the Extra Camos ones: higher they are out of the menu
local CAPTION_TOP = 35
local CAPTION_LINE_TOP = 58

local TILE_WIDTH = 168
local TILE_HEIGHT = 96
local LIST_TOP = 70
local LIST_COLUMNS = 4
local LIST_ROWS = 3
local LIST_WIDTH = LIST_COLUMNS * TILE_WIDTH + ( LIST_COLUMNS - 1 ) * 10

local CARD_LEFT = 730
local CARD_RIGHT = 1214
local CARD_TEXT_LEFT = CARD_LEFT + 20
local CARD_TEXT_RIGHT = CARD_RIGHT - 20
local CARD_IMAGE_HEIGHT = 180
local CARD_BOTTOM = LIST_TOP + LIST_ROWS * TILE_HEIGHT + ( LIST_ROWS - 1 ) * 10

-- the camos of the table, nothing when the support fastfile is not there
local function ReadCamos()
	local camos = {}
	local rows = tonumber( Engine[@"gettablerowcount"]( CAMO_TABLE ) ) or 0

	for row = 0, rows - 1, 1 do
		local index = tonumber( Engine[@"tablelookupgetcolumnvalueforrow"]( CAMO_TABLE, row, 0 ) )

		if index ~= nil and index > 0 then
			table.insert( camos, {
				camoIndex = index,
				name = Engine[@"tablelookupgetcolumnvalueforrow"]( CAMO_TABLE, row, 1 ) or "",
				image = Engine[@"tablelookupgetcolumnvalueforrow"]( CAMO_TABLE, row, 2 ),
				description = Engine[@"tablelookupgetcolumnvalueforrow"]( CAMO_TABLE, row, 3 ) or ""
			} )
		end
	end

	return camos
end

-- the colour of the mode the menu is for, as the lobby browser has them
local function ModeColor( menu )
	local colors = CoD.Shield.BrowserUI.ModeColors
	local mode = CoD.BaseUtility.GetMenuSessionMode( menu )

	if mode == Enum[@"emodes"][@"mode_zombies"] then
		return colors.zm
	elseif mode == Enum[@"emodes"][@"mode_warzone"] then
		return colors.wz
	end
	return colors.mp
end

DataSources.ShieldCustomCamosList = DataSourceHelpers.ListSetup( "ShieldCustomCamosList", function ( f1_arg0, f1_arg1 )
	local list = {}

	for _, camo in ipairs( ReadCamos() ) do
		-- every field, the list keeps the models of a row by its place. Not "description": the game's info panel of
		-- the camo in focus (CoD.WeaponOptionInfoInternal) localizes that one, and plain words are no localize string
		table.insert( list, {
			models = {
				name = camo.name,
				shieldAbout = camo.description,
				image = camo.image,
				camoIndex = camo.camoIndex,
				weaponOptionSubIndex = camo.camoIndex,
				weaponOptionType = camo.camoIndex,
				unlockDescription = "",
				weaponOptionTypeName = "",
				weaponOptionCategory = ""
			},
			properties = {}
		} )
	end

	return list
end, true )

---------------------------

-- the tab: the camos on the left, the card of the one in focus on the right
CoD.ShieldCustomCamos = InheritFrom( LUI.UIElement )
CoD.ShieldCustomCamos.__defaultWidth = 1214
CoD.ShieldCustomCamos.__defaultHeight = 400
CoD.ShieldCustomCamos.new = function ( f1_arg0, f1_arg1, f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	local self = LUI.UIElement.new( f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	self:setClass( CoD.ShieldCustomCamos )
	self.id = "ShieldCustomCamos"
	self.soundSet = "none"
	self.onlyChildrenFocusable = true
	self.anyChildUsesUpdateState = true

	local UI = CoD.Shield.BrowserUI
	local color = ModeColor( f1_arg0 )

	self.Parts = {}

	local function Add( element )
		self:addElement( element )
		table.insert( self.Parts, element )
		return element
	end

	Add( UI.NewCaption( 0, LIST_WIDTH, CAPTION_TOP, "CUSTOM CAMOS" ) )
	Add( UI.NewBox( 0, LIST_WIDTH, CAPTION_LINE_TOP, CAPTION_LINE_TOP + 1, 1, 1, 1, 0.12 ) )

	local Camos = LUI.UIList.new( f1_arg0, f1_arg1, 10, 0, nil, false, false, false, false )
	Camos:mergeStateConditions( {
		{
			stateName = "Equipped",
			condition = function ( menu, element, event )
				return CoD.ShieldIsCamoEquipped( menu, element, f1_arg1, "camoIndex" )
			end
		}
	} )
	Camos:setLeftRight( 0, 0, 0, LIST_WIDTH )
	Camos:setTopBottom( 0, 0, LIST_TOP, CARD_BOTTOM )
	Camos:setWidgetType( CoD.ShieldCustomCamoTile )
	Camos:setHorizontalCount( LIST_COLUMNS )
	Camos:setVerticalCount( LIST_ROWS )
	Camos:setSpacing( 10 )
	Camos:setAlignment( Enum[@"luialignment"][@"lui_alignment_left"] )
	Camos:setDataSource( "ShieldCustomCamosList" )
	self:addElement( Camos )
	self.Camos = Camos

	-- the card: the picture under a line of the colour of the mode, the name on it, the rest under it
	local ImageClip = LUI.UIElement.new( 0, 0, CARD_LEFT, CARD_RIGHT, 0, 0, LIST_TOP, LIST_TOP + CARD_IMAGE_HEIGHT )
	ImageClip:setUseStencil( true )
	Add( ImageClip )

	local Image = LUI.UIImage.new( 0, 1, 0, 0, 0, 1, 0, 0 )
	Image:setAlpha( 0 )
	ImageClip:addElement( Image )
	self.Image = Image

	UI.AddBottomFade( ImageClip, CARD_IMAGE_HEIGHT, 120 )

	Add( UI.NewBox( CARD_LEFT, CARD_RIGHT, LIST_TOP, LIST_TOP + 4, color.r, color.g, color.b, 1 ) )

	local Title = Add( UI.NewText( CARD_TEXT_LEFT, CARD_TEXT_RIGHT, LIST_TOP + CARD_IMAGE_HEIGHT - 48, 36, "notosans_bold" ) )
	Title:setRGB( 1, 1, 1 )

	Add( UI.NewBox( CARD_LEFT, CARD_RIGHT, LIST_TOP + CARD_IMAGE_HEIGHT, CARD_BOTTOM, 0, 0, 0, 0.5 ) )

	Add( UI.NewCaption( CARD_TEXT_LEFT, CARD_TEXT_LEFT + 200, LIST_TOP + CARD_IMAGE_HEIGHT + 14, "CAMO INDEX" ) )

	local Index = Add( UI.NewText( CARD_TEXT_LEFT, CARD_TEXT_LEFT + 200, LIST_TOP + CARD_IMAGE_HEIGHT + 34, 26, "notosans_bold" ) )
	Index:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )

	-- EQUIPPED, dark on the colour of the mode, when the camo in focus is the weapon's
	local Pill = Add( UI.NewBox( CARD_TEXT_RIGHT - 120, CARD_TEXT_RIGHT, LIST_TOP + CARD_IMAGE_HEIGHT + 34, LIST_TOP + CARD_IMAGE_HEIGHT + 60, color.r, color.g, color.b, 0 ) )

	local PillText = Add( UI.NewText( CARD_TEXT_RIGHT - 120, CARD_TEXT_RIGHT, LIST_TOP + CARD_IMAGE_HEIGHT + 38, 18, "notosans_bold", Enum[@"luialignment"][@"lui_alignment_center"] ) )
	PillText:setRGB( 0.04, 0.04, 0.04 )
	PillText:setText( "EQUIPPED" )
	PillText:setAlpha( 0 )

	Add( UI.NewBox( CARD_TEXT_LEFT, CARD_TEXT_RIGHT, LIST_TOP + CARD_IMAGE_HEIGHT + 74, LIST_TOP + CARD_IMAGE_HEIGHT + 75, 1, 1, 1, 0.1 ) )

	local About = Add( UI.NewText( CARD_TEXT_LEFT, CARD_TEXT_RIGHT, LIST_TOP + CARD_IMAGE_HEIGHT + 86, 20, "ttmussels_regular" ) )
	About:setRGB( 0.7, 0.7, 0.7 )

	local CardFrame = LUI.UIImage.new( 0, 0, CARD_LEFT - 1, CARD_RIGHT + 1, 0, 0, LIST_TOP - 1, CARD_BOTTOM + 1 )
	CardFrame:setAlpha( 0.12 )
	CardFrame:setImage( RegisterImage( @"uie_ui_menu_store_common_frame" ) )
	CardFrame:setMaterial( LUI.UIImage.GetCachedMaterial( @"uie_nineslice_add" ) )
	CardFrame:setShaderVector( 0, 0, 0, 0, 0 )
	CardFrame:setupNineSliceShader( 12, 12 )
	Add( CardFrame )

	-- the card of a camo of the list, or what there is to say when there is none
	local function ShowCamo( element )
		local model = element and element:getModel()

		if model == nil or model.camoIndex == nil then
			Image:setAlpha( 0 )
			Title:setText( "NO CUSTOM CAMOS" )
			Index:setText( "-" )
			About:setText( "No custom camos installed" )
			Pill:setAlpha( 0 )
			PillText:setAlpha( 0 )
			return
		end

		UI.SetPreviewImage( Image, model.image:get(), CARD_RIGHT - CARD_LEFT, CARD_IMAGE_HEIGHT )
		Image:setAlpha( 1 )
		Title:setText( ToUpper( model.name:get() or "" ) )
		Index:setText( tostring( model.camoIndex:get() ) )
		About:setText( model.shieldAbout:get() or "" )

		local equipped = CoD.ShieldIsCamoEquipped( f1_arg0, element, f1_arg1, "camoIndex" ) and 1 or 0
		Pill:setAlpha( equipped )
		PillText:setAlpha( equipped )
	end
	self.ShowCamo = ShowCamo

	ShowCamo( nil )

	Camos:registerEventHandler( "list_item_gain_focus", function ( element, event )
		CoD.WeaponOptionsUtility.SetFocusedWeaponOptionModel( element, f1_arg1, f1_arg0 )
		CoD.CraftUtility.PreviewWeaponCamo( self, element, f1_arg1, f1_arg0 )
		ShowCamo( element )
		return nil
	end )
	Camos:registerEventHandler( "lose_list_focus", function ( element, event )
		CoD.WeaponOptionsUtility.SetBaseWeaponOptions( element, f1_arg0, f1_arg1 )
		CoD.WeaponOptionsUtility.ClearWeaponOptionInfoModel( f1_arg0, f1_arg1, element )
		return nil
	end )
	Camos:registerEventHandler( "gain_focus", function ( element, event )
		local f2_local0 = nil
		if element.gainFocus then
			f2_local0 = element:gainFocus( event )
		elseif element.super.gainFocus then
			f2_local0 = element.super:gainFocus( event )
		end
		CoD.Menu.UpdateButtonShownState( element, f1_arg0, f1_arg1, Enum[@"luibutton"][@"lui_key_xba_pscross"] )
		CoD.Menu.UpdateButtonShownState( element, f1_arg0, f1_arg1, Enum[@"luibutton"][@"hash_64D2505E19049444"] )
		return f2_local0
	end )

	-- after a camo is put on or taken off: the ticks of the tiles, the card, the prompts
	local function Changed( menu, controller, element )
		UpdateSelfState( self, controller )
		ShowCamo( element )
		UpdateAllMenuButtonPrompts( menu, controller )
	end

	f1_arg0:AddButtonCallbackFunction( Camos, f1_arg1, Enum[@"luibutton"][@"lui_key_xba_pscross"], nil, function ( element, menu, controller, model )
		local index = element:getModel( controller, "camoIndex" )

		if index ~= nil then
			PlaySoundAlias( "cac_equipment_add" )
			CoD.ShieldApplyExtraCamo( controller, index:get(), menu )
			Changed( menu, controller, element )
		end

		return true
	end, function ( element, menu, controller )
		CoD.Menu.SetButtonLabel( menu, Enum[@"luibutton"][@"lui_key_xba_pscross"], @"menu/select", nil, nil )
		return true
	end, false )

	f1_arg0:AddButtonCallbackFunction( Camos, f1_arg1, Enum[@"luibutton"][@"hash_64D2505E19049444"], "ui_remove", function ( element, menu, controller, model )
		if CoD.ShieldIsCamoEquipped( menu, element, controller, "camoIndex" ) then
			PlaySoundAlias( "cac_equipment_remove" )
			CoD.ShieldApplyExtraCamo( controller, 0, menu )
			Changed( menu, controller, element )
			return true
		end

		return false
	end, function ( element, menu, controller )
		if CoD.ShieldIsCamoEquipped( menu, element, controller, "camoIndex" ) then
			CoD.Menu.SetButtonLabel( menu, Enum[@"luibutton"][@"hash_64D2505E19049444"], @"menu/remove", Enum[@"luibuttonpromptflags"][@"bpf_contextual"], "ui_remove" )
			return true
		end

		return false
	end, false )

	Camos:subscribeToGlobalModel( f1_arg1, "PerController", "WeaponPersonalization.listUpdate", function ( model )
		CoD.GridAndListUtility.UpdateDataSource( Camos, true, false, true )
		UpdateSelfState( self, f1_arg1 )
	end )

	Camos.id = "Camos"
	self.__defaultFocus = Camos
	LUI.OverrideFunction_CallOriginalSecond( self, "close", self.__onClose )

	if PostLoadFunc then
		PostLoadFunc( self, f1_arg1, f1_arg0 )
	end

	return self
end

CoD.ShieldCustomCamos.__onClose = function ( f2_arg0 )
	f2_arg0.Camos:close()
	f2_arg0.Image:close()
	for _, element in ipairs( f2_arg0.Parts ) do
		element:close()
	end
end

---------------------------

-- a camo of the list: its picture, its name on it, a tick when the weapon has it on
CoD.ShieldCustomCamoTile = InheritFrom( LUI.UIElement )
CoD.ShieldCustomCamoTile.__defaultWidth = TILE_WIDTH
CoD.ShieldCustomCamoTile.__defaultHeight = TILE_HEIGHT
CoD.ShieldCustomCamoTile.new = function ( f1_arg0, f1_arg1, f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	local self = LUI.UIElement.new( f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	self:setClass( CoD.ShieldCustomCamoTile )
	self.id = "ShieldCustomCamoTile"
	self.soundSet = "default"
	f1_arg0:addElementToPendingUpdateStateList( self )

	local UI = CoD.Shield.BrowserUI
	local color = ModeColor( f1_arg0 )

	self.Parts = {}

	-- the parts a clip changes are children of the tile itself: they tell it when they are done
	local function Add( element )
		self:addElement( element )
		table.insert( self.Parts, element )
		return element
	end

	local BlackBar = Add( UI.NewBox( 0, TILE_WIDTH, 0, TILE_HEIGHT, 1, 1, 1, 0.05 ) )
	self.BlackBar = BlackBar

	local ThumbClip = LUI.UIElement.new( 0, 0, 0, TILE_WIDTH, 0, 0, 0, TILE_HEIGHT )
	ThumbClip:setUseStencil( true )
	Add( ThumbClip )

	local Thumb = LUI.UIImage.new( 0, 1, 0, 0, 0, 1, 0, 0 )
	Thumb:setAlpha( 0 )
	ThumbClip:addElement( Thumb )
	self.Thumb = Thumb

	UI.AddBottomFade( ThumbClip, TILE_HEIGHT, 48 )

	local ThumbDim = Add( UI.NewBox( 0, TILE_WIDTH, 0, TILE_HEIGHT, 0, 0, 0, 0.35 ) )
	self.ThumbDim = ThumbDim

	local Tint = Add( UI.NewBox( 0, TILE_WIDTH, 0, TILE_HEIGHT, color.r, color.g, color.b, 0 ) )
	self.Tint = Tint

	local Accent = LUI.UIImage.new( 0, 0, 0, 4, 0, 1, 0, 0 )
	Accent:setRGB( color.r, color.g, color.b )
	Add( Accent )
	self.Accent = Accent

	local Name = Add( UI.NewText( 12, TILE_WIDTH - 8, TILE_HEIGHT - 26, 18, "notosans_bold" ) )
	Name:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )

	local EquippedTick = LUI.UIImage.new( 1, 1, -30, -4, 0, 0, 4, 30 )
	EquippedTick:setAlpha( 0 )
	EquippedTick:setImage( RegisterImage( @"uie_ui_menu_cac_equipped_marker_tick" ) )
	Add( EquippedTick )
	self.EquippedTick = EquippedTick

	local FocusFrame = LUI.UIImage.new( 0, 1, -4, 4, 0, 1, -4, 4 )
	FocusFrame:setAlpha( 0 )
	FocusFrame:setRGB( color.r, color.g, color.b )
	FocusFrame:setImage( RegisterImage( @"uie_ui_menu_store_focus_frame" ) )
	FocusFrame:setMaterial( LUI.UIImage.GetCachedMaterial( @"uie_nineslice_add" ) )
	FocusFrame:setShaderVector( 0, 0, 0, 0, 0 )
	FocusFrame:setupNineSliceShader( 10, 10 )
	Add( FocusFrame )
	self.FocusFrame = FocusFrame

	Name:linkToElementModel( self, "name", true, function ( model )
		local name = model:get()
		if name ~= nil then
			Name:setText( UI.ShortenText( ToUpper( name ), 18 ) )
		end
	end )

	Thumb:linkToElementModel( self, "image", true, function ( model )
		local image = model:get()
		if image ~= nil then
			UI.SetPreviewImage( Thumb, image, TILE_WIDTH, TILE_HEIGHT )
			Thumb:setAlpha( 1 )
		end
	end )

	LUI.OverrideFunction_CallOriginalSecond( self, "close", self.__onClose )

	if PostLoadFunc then
		PostLoadFunc( self, f1_arg1, f1_arg0 )
	end

	return self
end

-- what of a tile changes with the focus, and with the camo being the weapon's
local TileFocusParts = {
	{ "BlackBar", function ( element, focus ) element:setAlpha( focus and 0.1 or 0.05 ) end },
	{ "Tint", function ( element, focus ) element:setAlpha( focus and 0.16 or 0 ) end },
	{ "FocusFrame", function ( element, focus ) element:setAlpha( focus and 1 or 0 ) end },
	{ "ThumbDim", function ( element, focus ) element:setAlpha( focus and 0 or 0.35 ) end },
	{ "Accent", function ( element, focus ) element:setLeftRight( 0, 0, 0, focus and 7 or 4 ) end },
	{ "EquippedTick", function ( element, focus ) element:setAlpha( 0 ) end }
}

local TileEquippedParts = {}
for _, part in ipairs( TileFocusParts ) do
	table.insert( TileEquippedParts, part )
end
TileEquippedParts[#TileEquippedParts] = { "EquippedTick", function ( element, focus ) element:setAlpha( 1 ) end }

CoD.ShieldCustomCamoTile.__resetProperties = function ( f3_arg0 )
	for _, part in ipairs( TileFocusParts ) do
		local element = f3_arg0[part[1]]
		element:completeAnimation()
		part[2]( element, false )
	end
end

-- the lobby browser's clip, looked up when it runs: this file may be read before it
local function TileClip( parts, focus, duration )
	return function ( self, event )
		return CoD.Shield.BrowserUI.FocusClip( parts, focus, duration )( self, event )
	end
end

CoD.ShieldCustomCamoTile.__clipsPerState = {
	DefaultState = {
		DefaultClip = TileClip( TileFocusParts, false ),
		Focus = TileClip( TileFocusParts, true ),
		GainFocus = TileClip( TileFocusParts, true, 120 ),
		LoseFocus = TileClip( TileFocusParts, false, 120 )
	},
	Equipped = {
		DefaultClip = TileClip( TileEquippedParts, false ),
		Focus = TileClip( TileEquippedParts, true ),
		GainFocus = TileClip( TileEquippedParts, true, 120 ),
		LoseFocus = TileClip( TileEquippedParts, false, 120 )
	}
}

CoD.ShieldCustomCamoTile.__onClose = function ( f4_arg0 )
	f4_arg0.Thumb:close()
	for _, element in ipairs( f4_arg0.Parts ) do
		element:close()
	end
end
