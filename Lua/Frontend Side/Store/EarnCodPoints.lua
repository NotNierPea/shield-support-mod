--[[
		.\hksc.exe ".\Lua\EarnCodPoints.Lua" -o "C:\Program Files (x86)\Call of Duty Black Ops 4\project-bo4\mods\T8ShieldSupport\Lua\EarnCodPoints.luac"
]]

---------------------------

CoD.ShieldInitLuaFile()

---------------------------

--[[
	The PURCHASE COD POINTS buttons of the black market, the item shop and the laboratory all open the popup
	PurchaseCodPoints, the store of the platform, which waits for a store that is not there. It is replaced by a
	popup that says how COD Points are earned here: the client gives one for every three minutes in a match, of any
	mode (codpoints.cpp). Drawn with the parts of the lobby browser, CoD.Shield.BrowserUI of LobbyBrowser.lua.
]]
local POPUP_WIDTH = 760
local POPUP_HEIGHT = 400

-- the colour of the COD Points of the game's menus
local PointsColor = { r = 1, g = 0.78, b = 0.2 }

-- the COD Points held, nil when the game does not say
local function PointsHeld( controller )
	local ok, held = pcall( Engine[@"hash_F40679B550DCCA2"], controller, CoD.Currencies.COD_POINTS )

	if ok and type( held ) == "number" then
		return held
	end

	return nil
end

CoD.ShieldEarnCodPointsBody = InheritFrom( LUI.UIElement )
CoD.ShieldEarnCodPointsBody.__defaultWidth = POPUP_WIDTH
CoD.ShieldEarnCodPointsBody.__defaultHeight = POPUP_HEIGHT
CoD.ShieldEarnCodPointsBody.new = function ( f1_arg0, f1_arg1, f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	local UI = CoD.Shield.BrowserUI

	local self = LUI.UIElement.new( f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	self:setClass( CoD.ShieldEarnCodPointsBody )
	self.id = "ShieldEarnCodPointsBody"
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
	Add( UI.NewBox( 0, POPUP_WIDTH, 0, 4, PointsColor.r, PointsColor.g, PointsColor.b, 1 ) )

	local Frame = LUI.UIImage.new( 0, 1, -1, 1, 0, 1, -1, 1 )
	Frame:setAlpha( 0.2 )
	Frame:setImage( RegisterImage( @"uie_ui_menu_store_common_frame" ) )
	Frame:setMaterial( LUI.UIImage.GetCachedMaterial( @"uie_nineslice_add" ) )
	Frame:setShaderVector( 0, 0, 0, 0, 0 )
	Frame:setupNineSliceShader( 12, 12 )
	Add( Frame )

	Add( UI.NewCaption( 40, POPUP_WIDTH - 40, 34, "NOT FOR SALE ON SHIELD", center ) )

	local Title = Add( UI.NewText( 40, POPUP_WIDTH - 40, 56, 40, "notosans_bold", center ) )
	Title:setRGB( PointsColor.r, PointsColor.g, PointsColor.b )
	Title:setText( "EARN COD POINTS BY PLAYING" )

	Add( UI.NewBox( 120, POPUP_WIDTH - 120, 122, 123, 1, 1, 1, 0.1 ) )

	local lines = {
		"COD Points can't be bought here, you earn them in game.",
		"Every 3 minutes in a match, in any mode, gives you 1 COD Point.",
		"Spend them in the Black Market, the item shop and the Laboratory."
	}

	for index, line in ipairs( lines ) do
		local Line = Add( UI.NewText( 40, POPUP_WIDTH - 40, 142 + ( index - 1 ) * 32, 20, "ttmussels_regular", center ) )
		Line:setRGB( 0.8, 0.8, 0.8 )
		Line:setText( line )
	end

	local Held = Add( UI.NewText( 40, POPUP_WIDTH - 40, 252, 22, "notosans_bold", center ) )
	local held = PointsHeld( f1_arg1 )
	Held:setRGB( 1, 1, 1 )
	Held:setText( held ~= nil and "YOU HAVE " .. held .. " COD POINTS" or "" )

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

CoD.ShieldEarnCodPointsBody.__onClose = function ( f9_arg0 )
	for _, element in ipairs( f9_arg0.Parts ) do
		element:close()
	end
	f9_arg0.CloseButton:close()
end

-- the popup, in the place of the store of the platform
CoD.ShieldEarnCodPoints = InheritFrom( CoD.Menu )
CoD.Shield.CreateEarnCodPoints = function ( f1_arg0, f1_arg1 )
	local self = CoD.Menu.NewForUIEditor( "PurchaseCodPoints", f1_arg0 )
	local f1_local1 = self

	self:setClass( CoD.ShieldEarnCodPoints )
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

	local Body = CoD.ShieldEarnCodPointsBody.new( f1_local1, f1_arg0, 0.5, 0.5, -POPUP_WIDTH / 2, POPUP_WIDTH / 2, 0.5, 0.5, -POPUP_HEIGHT / 2, POPUP_HEIGHT / 2 )
	self:addElement( Body )
	self.ShieldEarnCodPointsBody = Body

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

	Body.id = "ShieldEarnCodPointsBody"

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

CoD.ShieldEarnCodPoints.__onClose = function ( f8_arg0 )
	f8_arg0.FooterContainerFrontendRight:close()
	f8_arg0.ShieldEarnCodPointsBody:close()
end

-- Put in the place of the store. Done again whenever the overrides of the mod are: the file of the store can be
-- loaded after this one.
CoD.EarnCodPointsReload = function ()
	if LUI.createMenu.PurchaseCodPoints ~= CoD.Shield.CreateEarnCodPoints then
		LUI.createMenu.PurchaseCodPoints = CoD.Shield.CreateEarnCodPoints
	end
end

CoD.EarnCodPointsReload()
