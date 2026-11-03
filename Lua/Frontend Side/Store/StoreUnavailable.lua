--[[
		.\hksc.exe ".\Lua\StoreUnavailable.Lua" -o "C:\Program Files (x86)\Call of Duty Black Ops 4\project-bo4\mods\T8ShieldSupport\Lua\StoreUnavailable.luac"
]]

---------------------------

CoD.ShieldInitLuaFile()

---------------------------

--[[
	The Battle.net store is not there on the Shield client, but menus still open it: the store overlay (OpenStore,
	the DLC prompts of a map), the PC store (the store shortcut) and the map packs store. Each of them is replaced by
	a popup that says so, with the backer of the COD Points one (EarnCodPoints.lua).
]]
local POPUP_WIDTH = 760
local POPUP_HEIGHT = 300

-- the colour of the COD Points popup
local AccentColor = { r = 1, g = 0.78, b = 0.2 }

CoD.ShieldStoreUnavailableBody = InheritFrom( LUI.UIElement )
CoD.ShieldStoreUnavailableBody.__defaultWidth = POPUP_WIDTH
CoD.ShieldStoreUnavailableBody.__defaultHeight = POPUP_HEIGHT
CoD.ShieldStoreUnavailableBody.new = function ( f1_arg0, f1_arg1, f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	local UI = CoD.Shield.BrowserUI

	local self = LUI.UIElement.new( f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	self:setClass( CoD.ShieldStoreUnavailableBody )
	self.id = "ShieldStoreUnavailableBody"
	self.soundSet = "default"
	self.onlyChildrenFocusable = true
	self.anyChildUsesUpdateState = true

	self.Parts = {}

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

	Add( UI.NewCaption( 40, POPUP_WIDTH - 40, 34, "STORE", center ) )

	local Title = Add( UI.NewText( 40, POPUP_WIDTH - 40, 56, 40, "notosans_bold", center ) )
	Title:setRGB( AccentColor.r, AccentColor.g, AccentColor.b )
	Title:setText( "NOT AVAILABLE ON SHIELD CLIENT" )

	Add( UI.NewBox( 120, POPUP_WIDTH - 120, 122, 123, 1, 1, 1, 0.1 ) )

	local Line = Add( UI.NewText( 40, POPUP_WIDTH - 40, 142, 20, "ttmussels_regular", center ) )
	Line:setRGB( 0.8, 0.8, 0.8 )
	Line:setText( "There is no Battle.net store here. COD Points are earned by playing." )

	-- the button that closes it
	local CloseButton = UI.NewBrowserButton( self, f1_arg0, f1_arg1, "GOT IT", POPUP_WIDTH / 2 - 140, POPUP_WIDTH / 2 + 140, POPUP_HEIGHT - 84, POPUP_HEIGHT - 36 )
	self:addElement( CloseButton )

	-- the menu finds what can take the focus as parent[id]: it is kept under its id
	CloseButton.id = "CloseButton"
	self.CloseButton = CloseButton

	UI.OnBrowserButton( f1_arg0, f1_arg1, CloseButton, function ()
		PlaySoundAlias( "uin_party_ease_slide_back" )
		GoBack( f1_arg0, f1_arg1 )
	end )

	LUI.OverrideFunction_CallOriginalSecond( self, "close", self.__onClose )

	if PostLoadFunc then
		PostLoadFunc( self, f1_arg1, f1_arg0 )
	end

	return self
end

CoD.ShieldStoreUnavailableBody.__onClose = function ( f9_arg0 )
	for _, element in ipairs( f9_arg0.Parts ) do
		element:close()
	end
	f9_arg0.CloseButton:close()
end

-- the popup, made under the name of the store menu it stands in for
CoD.ShieldStoreUnavailable = InheritFrom( CoD.Menu )
CoD.Shield.CreateStoreUnavailable = function ( menuName )
	return function ( f1_arg0, f1_arg1 )
		local self = CoD.Menu.NewForUIEditor( menuName, f1_arg0 )
		local f1_local1 = self

		self:setClass( CoD.ShieldStoreUnavailable )
		self.soundSet = "default"
		self:setOwner( f1_arg0 )
		self:setLeftRight( 0, 1, 0, 0 )
		self:setTopBottom( 0, 1, 0, 0 )
		self:playSound( "menu_open", f1_arg0 )
		self.anyChildUsesUpdateState = true

		local Blackfade = LUI.UIImage.new( 0, 1, 0, 0, 0, 1, 0, 0 )
		Blackfade:setRGB( 0, 0, 0 )
		Blackfade:setAlpha( 0.6 )
		self:addElement( Blackfade )
		self.Blackfade = Blackfade

		local FooterContainerFrontendRight = CoD.FooterContainer_Frontend_Right.new( f1_local1, f1_arg0, 0.5, 0.5, -960, 960, 1, 1, -48, 0 )
		self:addElement( FooterContainerFrontendRight )
		self.FooterContainerFrontendRight = FooterContainerFrontendRight

		local Body = CoD.ShieldStoreUnavailableBody.new( f1_local1, f1_arg0, 0.5, 0.5, -POPUP_WIDTH / 2, POPUP_WIDTH / 2, 0.5, 0.5, -POPUP_HEIGHT / 2, POPUP_HEIGHT / 2 )
		self:addElement( Body )
		self.ShieldStoreUnavailableBody = Body

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

		Body.id = "ShieldStoreUnavailableBody"

		self:processEvent( {
			name = "menu_loaded",
			controller = f1_arg0
		} )

		LUI.OverrideFunction_CallOriginalSecond( self, "close", self.__onClose )

		if PostLoadFunc then
			PostLoadFunc( self, f1_arg0 )
		end

		return self
	end
end

CoD.ShieldStoreUnavailable.__onClose = function ( f8_arg0 )
	f8_arg0.FooterContainerFrontendRight:close()
	f8_arg0.ShieldStoreUnavailableBody:close()
end

-- the store menus it stands in for, made once each
local StoreMenus = { "Store", "Store_DLC", "PC_BnetStore" }
local StoreCreators = {}
for _, name in ipairs( StoreMenus ) do
	StoreCreators[name] = CoD.Shield.CreateStoreUnavailable( name )
end

-- Put in the place of the stores. Done again whenever the overrides of the mod are: the files of the stores can be
-- loaded after this one.
CoD.StoreUnavailableReload = function ()
	for name, create in pairs( StoreCreators ) do
		if LUI.createMenu[name] ~= create then
			LUI.createMenu[name] = create
		end
	end
end

CoD.StoreUnavailableReload()
