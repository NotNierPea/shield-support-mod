--[[
		.\hksc.exe ".\Lua\SystemOverlay.Lua" -o "C:\Program Files (x86)\Call of Duty Black Ops 4\project-bo4\mods\T8ShieldSupport\Lua\Game\SystemOverlay.luac"
]]

---------------------------

if CoD.isFrontend then
	return
end

CoD.ShieldInitLuaFile()

---------------------------

-- Overlays (Message Boxes)
-- Message Box
CoD.SystemOverlay_MessageDialog = InheritFrom( CoD.Menu )
LUI.createMenu.SystemOverlay_MessageDialog = function ( f1_arg0, f1_arg1 )
	local self = CoD.Menu.NewForUIEditor( "SystemOverlay_MessageDialog", f1_arg0 )
	local f1_local1 = self
	CoD.OverlayUtility.SystemOverlayPreLoad( self, f1_arg0 )
	self:setClass( CoD.SystemOverlay_MessageDialog )
	self.soundSet = "ChooseDecal"
	self:setOwner( f1_arg0 )
	self:setLeftRight( 0, 1, 0, 0 )
	self:setTopBottom( 0, 1, 0, 0 )
	self:playSound( "menu_open", f1_arg0 )
	self.anyChildUsesUpdateState = true
	
	local layout = CoD.systemOverlay_FreeCursor_Layout.new( f1_local1, f1_arg0, 0, 1, 0, 0, 0, 1, 0, 0 )
	layout:linkToElementModel( self, nil, false, function ( model )
		layout:setModel( model, f1_arg0 )
	end )
	self:addElement( layout )
	self.layout = layout

	local emptyFocusable = CoD.emptyFocusable.new( f1_local1, f1_arg0, 0, 1, 0, 0, 0, 1, 0, 0 )
	self:addElement( emptyFocusable )
	self.emptyFocusable = emptyFocusable

	local ErrorText = CoD.GetErrorText(f1_arg0)

	local error_text = LUI.UIText.new(0.1, 0, 64, 0, 0.25, 0.25, 20, 50)
	error_text:setText("Error -> " .. ErrorText)
	error_text:setTTF("ttmussels_demibold")
    self:addElement(error_text)
	self.error_text = error_text
	
	self:appendEventHandler( "input_source_changed", function ( f3_arg0, f3_arg1 )
		f3_arg1.menu = f3_arg1.menu or f1_local1
		CoD.Menu.UpdateButtonShownState( f3_arg0, f1_local1, f1_arg0, Enum[@"luibutton"][@"lui_key_xba_pscross"] )
	end )
	local f1_local4 = self
	local f1_local5 = self.subscribeToModel
	local f1_local6 = Engine[@"getmodelforcontroller"]( f1_arg0 )
	f1_local5( f1_local4, f1_local6.LastInput, function ( f4_arg0, f4_arg1 )
		CoD.Menu.UpdateButtonShownState( f4_arg1, f1_local1, f1_arg0, Enum[@"luibutton"][@"lui_key_xba_pscross"] )
	end, false )
	f1_local1:AddButtonCallbackFunction( self, f1_arg0, Enum[@"luibutton"][@"lui_key_xba_pscross"], "ui_confirm", function ( element, menu, controller, model )
		if not IsMouseOrKeyboard( controller ) and CoD.OverlayUtility.HasOverlayACrossAction( menu ) then
			CoD.OverlayUtility.PerformOverlayACrossAction( menu, controller )
			return true
		else
			
		end
	end, function ( element, menu, controller )
		if not IsMouseOrKeyboard( controller ) and CoD.OverlayUtility.HasOverlayACrossAction( menu ) then
			CoD.Menu.SetButtonLabel( menu, Enum[@"luibutton"][@"lui_key_xba_pscross"], @"hash_128080D5840E11B2", nil, "ui_confirm" )
			return true
		else
			return false
		end
	end, false )
	f1_local1:AddButtonCallbackFunction( self, f1_arg0, Enum[@"luibutton"][@"lui_key_xbb_pscircle"], nil, function ( element, menu, controller, model )
		if CoD.OverlayUtility.HasOverlayBCircleAction( menu ) then
			CoD.OverlayUtility.PerformOverlayBCircleAction( menu, controller )
			return true
		else
			
		end
	end, function ( element, menu, controller )
		if CoD.OverlayUtility.HasOverlayBCircleAction( menu ) then
			CoD.Menu.SetButtonLabel( menu, Enum[@"luibutton"][@"lui_key_xbb_pscircle"], @"hash_128080D5840E11B2", nil, nil )
			return true
		else
			return false
		end
	end, false )
	f1_local1:AddButtonCallbackFunction( self, f1_arg0, Enum[@"luibutton"][@"lui_key_xbx_pssquare"], "A", function ( element, menu, controller, model )
		if CoD.OverlayUtility.HasOverlayXSquareAction( menu ) then
			CoD.OverlayUtility.PerformOverlayXSquareAction( menu, controller )
			return true
		else
			
		end
	end, function ( element, menu, controller )
		if CoD.OverlayUtility.HasOverlayXSquareAction( menu ) then
			CoD.Menu.SetButtonLabel( menu, Enum[@"luibutton"][@"lui_key_xbx_pssquare"], @"hash_128080D5840E11B2", nil, "A" )
			return true
		else
			return false
		end
	end, false )
	f1_local1:AddButtonCallbackFunction( self, f1_arg0, Enum[@"luibutton"][@"lui_key_xby_pstriangle"], "S", function ( element, menu, controller, model )
		if CoD.OverlayUtility.HasOverlayYTriangleAction( menu ) then
			CoD.OverlayUtility.PerformOverlayYTriangleAction( menu, controller )
			return true
		else
			
		end
	end, function ( element, menu, controller )
		if CoD.OverlayUtility.HasOverlayYTriangleAction( menu ) then
			CoD.Menu.SetButtonLabel( menu, Enum[@"luibutton"][@"lui_key_xby_pstriangle"], @"hash_128080D5840E11B2", nil, "S" )
			return true
		else
			return false
		end
	end, false )
	layout.buttons:setModel( self.buttonModel, f1_arg0 )
	layout.id = "layout"
	emptyFocusable.id = "emptyFocusable"
	self:processEvent( {
		name = "menu_loaded",
		controller = f1_arg0
	} )
	self.__defaultFocus = layout
	if CoD.isPC and (IsKeyboard( f1_arg0 ) or self.ignoreCursor) then
		self:restoreState( f1_arg0 )
	end
	LUI.OverrideFunction_CallOriginalSecond( self, "close", self.__onClose )
	if PostLoadFunc then
		PostLoadFunc( self, f1_arg0 )
	end
	
	f1_local5 = self
	CoD.OverlayUtility.SystemOverlayPostLoad( self, f1_arg0 )
	DisableKeyboardNavigationByElement( emptyFocusable )
	
	self:setAlpha(0.75)

	if Engine[@"getdvarint"]("shield_ui_color") == 0 then
		self:setRGB(0, 1, 1)
	elseif Engine[@"getdvarint"]("shield_ui_color") == 1 then
		self:setRGB(1, 0, 0)
	elseif Engine[@"getdvarint"]("shield_ui_color") == 2 then
		self:setRGB(0, 1, 0)
	end

	CoD.EnhPrintInfo("Called - > " .. ErrorText, "System Overlay Message Box")

	--CoD.SystemOverlay_MessageDialog.__onClose(self)

	--DelayGoBack( f1_local1, f1_arg0, 1500 )

	return self
end

CoD.SystemOverlay_MessageDialog.__onClose = function ( f13_arg0 )
	f13_arg0.layout:close()
	f13_arg0.emptyFocusable:close()
end

-- Full One
CoD.SystemOverlay_MessageDialogFull = InheritFrom( CoD.Menu )
LUI.createMenu.SystemOverlay_MessageDialogFull = function ( f1_arg0, f1_arg1 )
	local self = CoD.Menu.NewForUIEditor( "SystemOverlay_MessageDialogFull", f1_arg0 )
	local f1_local1 = self
	self:setClass( CoD.SystemOverlay_MessageDialogFull )
	self.soundSet = "default"
	self:setOwner( f1_arg0 )
	self:setLeftRight( 0, 1, 0, 0 )
	self:setTopBottom( 0, 1, 0, 0 )
	self:playSound( "menu_open", f1_arg0 )
	self.anyChildUsesUpdateState = true
	
	local layout = CoD.systemOverlay_Full_Layout.new( f1_local1, f1_arg0, 0, 1, 0, 0, 0, 1, 0, 0 )
	layout:linkToElementModel( self, nil, false, function ( model )
		layout:setModel( model, f1_arg0 )
	end )
	self:addElement( layout )
	self.layout = layout
	
	local emptyFocusable = CoD.emptyFocusable.new( f1_local1, f1_arg0, 0, 1, 0, 0, 0, 1, 0, 0 )
	self:addElement( emptyFocusable )
	self.emptyFocusable = emptyFocusable
	
	local BTNQuit = nil
	
	BTNQuit = CoD.PC_SmallCloseButton.new( f1_local1, f1_arg0, 0.5, 0.5, 866, 900, 0.5, 0.5, -230, -198 )
	BTNQuit:registerEventHandler( "gain_focus", function ( element, event )
		local f3_local0 = nil
		if element.gainFocus then
			f3_local0 = element:gainFocus( event )
		elseif element.super.gainFocus then
			f3_local0 = element.super:gainFocus( event )
		end
		CoD.Menu.UpdateButtonShownState( element, f1_local1, f1_arg0, Enum[@"luibutton"][@"lui_key_xba_pscross"] )
		return f3_local0
	end )
	f1_local1:AddButtonCallbackFunction( BTNQuit, f1_arg0, Enum[@"luibutton"][@"lui_key_xba_pscross"], "ui_confirm", function ( element, menu, controller, model )
		PerformOverlayBack( menu, controller )
		return true
	end, function ( element, menu, controller )
		CoD.Menu.SetButtonLabel( menu, Enum[@"luibutton"][@"lui_key_xba_pscross"], @"hash_0", nil, "ui_confirm" )
		return false
	end, false )
	self:addElement( BTNQuit )
	self.BTNQuit = BTNQuit
	
	f1_local1:AddButtonCallbackFunction( self, f1_arg0, Enum[@"luibutton"][@"lui_key_xba_pscross"], "ui_confirm", function ( element, menu, controller, model )
		if CoD.OverlayUtility.HasOverlayACrossAction( menu ) then
			CoD.OverlayUtility.PerformOverlayACrossAction( menu, controller )
			return true
		else
			
		end
	end, function ( element, menu, controller )
		if CoD.OverlayUtility.HasOverlayACrossAction( menu ) then
			CoD.Menu.SetButtonLabel( menu, Enum[@"luibutton"][@"lui_key_xba_pscross"], @"hash_128080D5840E11B2", nil, "ui_confirm" )
			return true
		else
			return false
		end
	end, false )
	f1_local1:AddButtonCallbackFunction( self, f1_arg0, Enum[@"luibutton"][@"lui_key_xbb_pscircle"], "ESCAPE", function ( element, menu, controller, model )
		if CoD.OverlayUtility.HasOverlayBCircleAction( menu ) then
			CoD.OverlayUtility.PerformOverlayBCircleAction( menu, controller )
			return true
		else
			
		end
	end, function ( element, menu, controller )
		if CoD.OverlayUtility.HasOverlayBCircleAction( menu ) then
			CoD.Menu.SetButtonLabel( menu, Enum[@"luibutton"][@"lui_key_xbb_pscircle"], @"hash_128080D5840E11B2", nil, "ESCAPE" )
			return true
		else
			return false
		end
	end, false )
	f1_local1:AddButtonCallbackFunction( self, f1_arg0, Enum[@"luibutton"][@"lui_key_xbx_pssquare"], "A", function ( element, menu, controller, model )
		if CoD.OverlayUtility.HasOverlayXSquareAction( menu ) then
			CoD.OverlayUtility.PerformOverlayXSquareAction( menu, controller )
			return true
		else
			
		end
	end, function ( element, menu, controller )
		if CoD.OverlayUtility.HasOverlayXSquareAction( menu ) then
			CoD.Menu.SetButtonLabel( menu, Enum[@"luibutton"][@"lui_key_xbx_pssquare"], @"hash_128080D5840E11B2", nil, "A" )
			return true
		else
			return false
		end
	end, false )
	f1_local1:AddButtonCallbackFunction( self, f1_arg0, Enum[@"luibutton"][@"lui_key_xby_pstriangle"], "S", function ( element, menu, controller, model )
		if CoD.OverlayUtility.HasOverlayYTriangleAction( menu ) then
			CoD.OverlayUtility.PerformOverlayYTriangleAction( menu, controller )
			return true
		else
			
		end
	end, function ( element, menu, controller )
		if CoD.OverlayUtility.HasOverlayYTriangleAction( menu ) then
			CoD.Menu.SetButtonLabel( menu, Enum[@"luibutton"][@"lui_key_xby_pstriangle"], @"hash_128080D5840E11B2", nil, "S" )
			return true
		else
			return false
		end
	end, false )
	layout.buttons:setModel( self.buttonModel, f1_arg0 )
	layout.id = "layout"
	emptyFocusable.id = "emptyFocusable"
	if CoD.isPC then
		BTNQuit.id = "BTNQuit"
	end
	self:processEvent( {
		name = "menu_loaded",
		controller = f1_arg0
	} )
	self.__defaultFocus = layout
	if CoD.isPC and (IsKeyboard( f1_arg0 ) or self.ignoreCursor) then
		self:restoreState( f1_arg0 )
	end
	LUI.OverrideFunction_CallOriginalSecond( self, "close", self.__onClose )
	if PostLoadFunc then
		PostLoadFunc( self, f1_arg0 )
	end
	
	self:setAlpha(0.75)

	if Engine[@"getdvarint"]("shield_ui_color") == 0 then
		self:setRGB(0, 1, 1)
	elseif Engine[@"getdvarint"]("shield_ui_color") == 1 then
		self:setRGB(1, 0, 0)
	elseif Engine[@"getdvarint"]("shield_ui_color") == 2 then
		self:setRGB(0, 1, 0)
	end

	CoD.EnhPrintInfo("Called", "System Overlay Full Message Box")

	return self
end

CoD.SystemOverlay_MessageDialogFull.__onClose = function ( f14_arg0 )
	f14_arg0.layout:close()
	f14_arg0.emptyFocusable:close()
	f14_arg0.BTNQuit:close()
end

CoD.SystemOverlay_Compact = InheritFrom( CoD.Menu )
LUI.createMenu.SystemOverlay_Compact = function ( f1_arg0, f1_arg1 )
	local self = CoD.Menu.NewForUIEditor( "SystemOverlay_Compact", f1_arg0 )
	local f1_local1 = self
	DisableAutoButtonCallback( f1_local1, self, f1_arg0 )
	self:setClass( CoD.SystemOverlay_Compact )
	self.soundSet = "default"
	self:setOwner( f1_arg0 )
	self:setLeftRight( 0, 1, 0, 0 )
	self:setTopBottom( 0, 1, 0, 0 )
	self:playSound( "menu_open", f1_arg0 )
	self.anyChildUsesUpdateState = true
	
	local layout = CoD.systemOverlay_Compact_Layout.new( f1_local1, f1_arg0, 0, 1, 0, 0, 0, 1, 0, 0 )
	layout:setAlpha( 0.99 )
	layout:linkToElementModel( self, nil, false, function ( model )
		layout:setModel( model, f1_arg0 )
	end )
	self:addElement( layout )
	self.layout = layout
	
	local BTNQuit = nil
	
	BTNQuit = CoD.PC_SmallCloseButton.new( f1_local1, f1_arg0, 0.5, 0.5, 866, 900, 0.5, 0.5, -232, -198 )
	BTNQuit:registerEventHandler( "gain_focus", function ( element, event )
		local f3_local0 = nil
		if element.gainFocus then
			f3_local0 = element:gainFocus( event )
		elseif element.super.gainFocus then
			f3_local0 = element.super:gainFocus( event )
		end
		CoD.Menu.UpdateButtonShownState( element, f1_local1, f1_arg0, Enum[@"luibutton"][@"lui_key_xba_pscross"] )
		return f3_local0
	end )
	f1_local1:AddButtonCallbackFunction( BTNQuit, f1_arg0, Enum[@"luibutton"][@"lui_key_xba_pscross"], "ui_confirm", function ( element, menu, controller, model )
		if HasOverlayBackAction( menu ) then
			PerformOverlayBack( menu, controller )
			return true
		else
			
		end
	end, function ( element, menu, controller )
		if HasOverlayBackAction( menu ) then
			CoD.Menu.SetButtonLabel( menu, Enum[@"luibutton"][@"lui_key_xba_pscross"], @"hash_0", nil, "ui_confirm" )
			return false
		else
			return false
		end
	end, false )
	self:addElement( BTNQuit )
	self.BTNQuit = BTNQuit
	
	self:appendEventHandler( "input_source_changed", function ( f6_arg0, f6_arg1 )
		f6_arg1.menu = f6_arg1.menu or f1_local1
		CoD.Menu.UpdateButtonShownState( f6_arg0, f1_local1, f1_arg0, Enum[@"luibutton"][@"lui_key_xba_pscross"] )
		CoD.Menu.UpdateButtonShownState( f6_arg0, f1_local1, f1_arg0, Enum[@"luibutton"][@"lui_key_xbb_pscircle"] )
		CoD.Menu.UpdateButtonShownState( f6_arg0, f1_local1, f1_arg0, Enum[@"luibutton"][@"lui_key_xbx_pssquare"] )
		CoD.Menu.UpdateButtonShownState( f6_arg0, f1_local1, f1_arg0, Enum[@"luibutton"][@"lui_key_xby_pstriangle"] )
	end )
	local f1_local4 = self
	local f1_local5 = self.subscribeToModel
	local f1_local6 = Engine[@"getmodelforcontroller"]( f1_arg0 )
	f1_local5( f1_local4, f1_local6.LastInput, function ( f7_arg0, f7_arg1 )
		CoD.Menu.UpdateButtonShownState( f7_arg1, f1_local1, f1_arg0, Enum[@"luibutton"][@"lui_key_xba_pscross"] )
		CoD.Menu.UpdateButtonShownState( f7_arg1, f1_local1, f1_arg0, Enum[@"luibutton"][@"lui_key_xbb_pscircle"] )
		CoD.Menu.UpdateButtonShownState( f7_arg1, f1_local1, f1_arg0, Enum[@"luibutton"][@"lui_key_xbx_pssquare"] )
		CoD.Menu.UpdateButtonShownState( f7_arg1, f1_local1, f1_arg0, Enum[@"luibutton"][@"lui_key_xby_pstriangle"] )
	end, false )
	f1_local1:AddButtonCallbackFunction( self, f1_arg0, Enum[@"luibutton"][@"lui_key_xbx_pssquare"], nil, function ( element, menu, controller, model )
		if not IsPC() then
			return true
		elseif IsPC() and IsGamepad( controller ) and CoD.OverlayUtility.HasOverlayXSquareAction( menu ) then
			CoD.OverlayUtility.PerformOverlayXSquareAction( menu, controller )
			return true
		else
			
		end
	end, function ( element, menu, controller )
		if not IsPC() then
			CoD.Menu.SetButtonLabel( menu, Enum[@"luibutton"][@"lui_key_xbx_pssquare"], @"hash_0", nil, nil )
			return false
		elseif IsPC() and IsGamepad( controller ) and CoD.OverlayUtility.HasOverlayXSquareAction( menu ) then
			CoD.Menu.SetButtonLabel( menu, Enum[@"luibutton"][@"lui_key_xbx_pssquare"], @"hash_57E8A8BFFB7D0CD4", nil, nil )
			return true
		else
			return false
		end
	end, false )
	f1_local1:AddButtonCallbackFunction( self, f1_arg0, Enum[@"luibutton"][@"lui_key_xby_pstriangle"], nil, function ( element, menu, controller, model )
		if not IsPC() then
			return true
		elseif IsPC() and IsGamepad( controller ) and CoD.OverlayUtility.HasOverlayYTriangleAction( menu ) then
			CoD.OverlayUtility.PerformOverlayYTriangleAction( menu, controller )
			return true
		else
			
		end
	end, function ( element, menu, controller )
		if not IsPC() then
			CoD.Menu.SetButtonLabel( menu, Enum[@"luibutton"][@"lui_key_xby_pstriangle"], @"hash_0", nil, nil )
			return false
		elseif IsPC() and IsGamepad( controller ) and CoD.OverlayUtility.HasOverlayYTriangleAction( menu ) then
			CoD.Menu.SetButtonLabel( menu, Enum[@"luibutton"][@"lui_key_xby_pstriangle"], @"hash_57E8A8BFFB7D0CD4", nil, nil )
			return true
		else
			return false
		end
	end, false )
	f1_local1:AddButtonCallbackFunction( self, f1_arg0, Enum[@"luibutton"][@"lui_key_xba_pscross"], nil, function ( element, menu, controller, model )
		if not IsPC() and HasOverlayContinueAction( menu ) then
			PerformOverlayContinue( menu, controller )
			return true
		elseif IsPC() and IsGamepad( controller ) and CoD.OverlayUtility.HasOverlayACrossAction( menu ) then
			CoD.OverlayUtility.PerformOverlayACrossAction( menu, controller )
			return true
		else
			
		end
	end, function ( element, menu, controller )
		if not IsPC() and HasOverlayContinueAction( menu ) then
			CoD.Menu.SetButtonLabel( menu, Enum[@"luibutton"][@"lui_key_xba_pscross"], @"hash_66393FF34EA56966", nil, nil )
			return true
		elseif IsPC() and IsGamepad( controller ) and CoD.OverlayUtility.HasOverlayACrossAction( menu ) then
			CoD.Menu.SetButtonLabel( menu, Enum[@"luibutton"][@"lui_key_xba_pscross"], @"hash_57E8A8BFFB7D0CD4", nil, nil )
			return true
		else
			return false
		end
	end, false )
	f1_local1:AddButtonCallbackFunction( self, f1_arg0, Enum[@"luibutton"][@"lui_key_xbb_pscircle"], "ESCAPE", function ( element, menu, controller, model )
		if not IsPC() and HasOverlayBackAction( menu ) then
			PerformOverlayBack( menu, controller )
			return true
		elseif IsPC() and IsGamepad( controller ) and CoD.OverlayUtility.HasOverlayBCircleAction( menu ) then
			CoD.OverlayUtility.PerformOverlayBCircleAction( menu, controller )
			return true
		elseif IsPC() and IsMouseOrKeyboard( controller ) and HasOverlayBackAction( menu ) then
			PerformOverlayBack( menu, controller )
			return true
		else
			
		end
	end, function ( element, menu, controller )
		if not IsPC() and HasOverlayBackAction( menu ) then
			CoD.Menu.SetButtonLabel( menu, Enum[@"luibutton"][@"lui_key_xbb_pscircle"], @"menu/back", nil, "ESCAPE" )
			return true
		elseif IsPC() and IsGamepad( controller ) and CoD.OverlayUtility.HasOverlayBCircleAction( menu ) then
			CoD.Menu.SetButtonLabel( menu, Enum[@"luibutton"][@"lui_key_xbb_pscircle"], @"hash_57E8A8BFFB7D0CD4", nil, "ESCAPE" )
			return true
		elseif IsPC() and IsMouseOrKeyboard( controller ) and HasOverlayBackAction( menu ) then
			CoD.Menu.SetButtonLabel( menu, Enum[@"luibutton"][@"lui_key_xbb_pscircle"], @"hash_57E8A8BFFB7D0CD4", nil, "ESCAPE" )
			return true
		else
			return false
		end
	end, false )
	layout.buttons:setModel( self.buttonModel, f1_arg0 )
	layout.id = "layout"
	if CoD.isPC then
		BTNQuit.id = "BTNQuit"
	end
	self:processEvent( {
		name = "menu_loaded",
		controller = f1_arg0
	} )
	self.__defaultFocus = layout
	if CoD.isPC and (IsKeyboard( f1_arg0 ) or self.ignoreCursor) then
		self:restoreState( f1_arg0 )
	end
	LUI.OverrideFunction_CallOriginalSecond( self, "close", self.__onClose )
	if PostLoadFunc then
		PostLoadFunc( self, f1_arg0 )
	end
	f1_local5 = self
	SetProperty( self, "disablePopupOpenCloseAnim", true )
	MenuHidesFreeCursor( f1_local1, f1_arg0 )
	f1_local5 = BTNQuit
	if not HasOverlayBackAction( f1_local1 ) then
		ReplaceElementWithFake( self, "BTNQuit" )
	end

	self:setAlpha(0.75)

	if Engine[@"getdvarint"]("shield_ui_color") == 0 then
		self:setRGB(0, 1, 1)
	elseif Engine[@"getdvarint"]("shield_ui_color") == 1 then
		self:setRGB(1, 0, 0)
	elseif Engine[@"getdvarint"]("shield_ui_color") == 2 then
		self:setRGB(0, 1, 0)
	end

	CoD.EnhPrintInfo("Called", "System Overlay Compact")

	return self
end

CoD.SystemOverlay_Compact.__onClose = function ( f16_arg0 )
	f16_arg0.layout:close()
	f16_arg0.BTNQuit:close()
end

CoD.SystemOverlay_NoBG = InheritFrom( CoD.Menu )
LUI.createMenu.SystemOverlay_NoBG = function ( f1_arg0, f1_arg1 )
	local self = CoD.Menu.NewForUIEditor( "SystemOverlay_NoBG", f1_arg0 )
	local f1_local1 = self
	CoD.OverlayUtility.SystemOverlayPreLoad( self, f1_arg0 )
	self:setClass( CoD.SystemOverlay_NoBG )
	self.soundSet = "default"
	self:setOwner( f1_arg0 )
	self:setLeftRight( 0, 1, 0, 0 )
	self:setTopBottom( 0, 1, 0, 0 )
	self:playSound( "menu_open", f1_arg0 )
	self.anyChildUsesUpdateState = true
	
	local layout = CoD.systemOverlay_Compact_Layout.new( f1_local1, f1_arg0, 0.5, 0.5, -960, 960, 0.5, 0.5, -540, 540 )
	layout:setAlpha( 0.99 )
	layout.background:setAlpha( 0 )
	layout:linkToElementModel( self, nil, false, function ( model )
		layout:setModel( model, f1_arg0 )
	end )
	self:addElement( layout )
	self.layout = layout
	
	f1_local1:AddButtonCallbackFunction( self, f1_arg0, Enum[@"luibutton"][@"lui_key_xba_pscross"], nil, function ( element, menu, controller, model )
		return true
	end, function ( element, menu, controller )
		CoD.Menu.SetButtonLabel( menu, Enum[@"luibutton"][@"lui_key_xba_pscross"], @"hash_0", nil, nil )
		return false
	end, false )
	f1_local1:AddButtonCallbackFunction( self, f1_arg0, Enum[@"luibutton"][@"lui_key_xbb_pscircle"], nil, function ( element, menu, controller, model )
		if HasOverlayBackAction( menu ) then
			PerformOverlayBack( menu, controller )
			return true
		else
			
		end
	end, function ( element, menu, controller )
		if HasOverlayBackAction( menu ) then
			CoD.Menu.SetButtonLabel( menu, Enum[@"luibutton"][@"lui_key_xbb_pscircle"], @"menu/back", nil, nil )
			return true
		else
			return false
		end
	end, false )
	f1_local1:AddButtonCallbackFunction( self, f1_arg0, Enum[@"luibutton"][@"lui_key_xbx_pssquare"], nil, function ( element, menu, controller, model )
		return true
	end, function ( element, menu, controller )
		CoD.Menu.SetButtonLabel( menu, Enum[@"luibutton"][@"lui_key_xbx_pssquare"], @"hash_0", nil, nil )
		return false
	end, false )
	f1_local1:AddButtonCallbackFunction( self, f1_arg0, Enum[@"luibutton"][@"lui_key_xby_pstriangle"], nil, function ( element, menu, controller, model )
		return true
	end, function ( element, menu, controller )
		CoD.Menu.SetButtonLabel( menu, Enum[@"luibutton"][@"lui_key_xby_pstriangle"], @"hash_0", nil, nil )
		return false
	end, false )
	layout.buttons:setModel( self.buttonModel, f1_arg0 )
	layout.id = "layout"
	self:processEvent( {
		name = "menu_loaded",
		controller = f1_arg0
	} )
	self.__defaultFocus = layout
	if CoD.isPC and (IsKeyboard( f1_arg0 ) or self.ignoreCursor) then
		self:restoreState( f1_arg0 )
	end
	LUI.OverrideFunction_CallOriginalSecond( self, "close", self.__onClose )
	if PostLoadFunc then
		PostLoadFunc( self, f1_arg0 )
	end
	
	local f1_local3 = self
	CoD.OverlayUtility.SystemOverlayPostLoad( self, f1_arg0 )

	self:setAlpha(0.75)

	if Engine[@"getdvarint"]("shield_ui_color") == 0 then
		self:setRGB(0, 1, 1)
	elseif Engine[@"getdvarint"]("shield_ui_color") == 1 then
		self:setRGB(1, 0, 0)
	elseif Engine[@"getdvarint"]("shield_ui_color") == 2 then
		self:setRGB(0, 1, 0)
	end

	CoD.EnhPrintInfo("Called", "System Overlay No BG")

	return self
end

CoD.SystemOverlay_NoBG.__onClose = function ( f11_arg0 )
	f11_arg0.layout:close()
end

local PostLoadFuncOverlayFull = function ( f1_arg0 )
	f1_arg0.disablePopupOpenCloseAnim = true
	f1_arg0.disableBlur = true
end

CoD.SystemOverlay_Full = InheritFrom( CoD.Menu )
LUI.createMenu.SystemOverlay_Full = function ( f2_arg0, f2_arg1 )
	local self = CoD.Menu.NewForUIEditor( "SystemOverlay_Full", f2_arg0 )
	local f2_local1 = self
	self:setClass( CoD.SystemOverlay_Full )
	self.soundSet = "default"
	self:setOwner( f2_arg0 )
	self:setLeftRight( 0, 1, 0, 0 )
	self:setTopBottom( 0, 1, 0, 0 )
	self:playSound( "menu_open", f2_arg0 )
	self.anyChildUsesUpdateState = true
	
	local layout = CoD.systemOverlay_Full_Layout.new( f2_local1, f2_arg0, 0, 1, 0, 0, 0, 1, 0, 0 )
	layout:linkToElementModel( self, nil, false, function ( model )
		layout:setModel( model, f2_arg0 )
	end )
	self:addElement( layout )
	self.layout = layout
	
	local BTNQuit = nil
	
	BTNQuit = CoD.PC_SmallCloseButton.new( f2_local1, f2_arg0, 0.5, 0.5, 866, 900, 0.5, 0.5, -230, -198 )
	BTNQuit:registerEventHandler( "gain_focus", function ( element, event )
		local f4_local0 = nil
		if element.gainFocus then
			f4_local0 = element:gainFocus( event )
		elseif element.super.gainFocus then
			f4_local0 = element.super:gainFocus( event )
		end
		CoD.Menu.UpdateButtonShownState( element, f2_local1, f2_arg0, Enum[@"luibutton"][@"lui_key_xba_pscross"] )
		return f4_local0
	end )
	f2_local1:AddButtonCallbackFunction( BTNQuit, f2_arg0, Enum[@"luibutton"][@"lui_key_xba_pscross"], "ui_confirm", function ( element, menu, controller, model )
		PerformOverlayBack( menu, controller )
		return true
	end, function ( element, menu, controller )
		CoD.Menu.SetButtonLabel( menu, Enum[@"luibutton"][@"lui_key_xba_pscross"], @"hash_0", nil, "ui_confirm" )
		return false
	end, false )
	self:addElement( BTNQuit )
	self.BTNQuit = BTNQuit
	
	f2_local1:AddButtonCallbackFunction( self, f2_arg0, Enum[@"luibutton"][@"lui_key_xba_pscross"], "ui_confirm", function ( element, menu, controller, model )
		if HasOverlayContinueAction( menu ) then
			PerformOverlayContinue( menu, controller )
			return true
		else
			
		end
	end, function ( element, menu, controller )
		if HasOverlayContinueAction( menu ) then
			CoD.Menu.SetButtonLabel( menu, Enum[@"luibutton"][@"lui_key_xba_pscross"], @"hash_66393FF34EA56966", nil, "ui_confirm" )
			return true
		else
			return false
		end
	end, false )
	f2_local1:AddButtonCallbackFunction( self, f2_arg0, Enum[@"luibutton"][@"lui_key_xbb_pscircle"], nil, function ( element, menu, controller, model )
		if HasOverlayBackAction( menu ) then
			PerformOverlayBack( menu, controller )
			return true
		else
			
		end
	end, function ( element, menu, controller )
		if HasOverlayBackAction( menu ) then
			CoD.Menu.SetButtonLabel( menu, Enum[@"luibutton"][@"lui_key_xbb_pscircle"], @"menu/back", nil, nil )
			return true
		else
			return false
		end
	end, false )
	f2_local1:AddButtonCallbackFunction( self, f2_arg0, Enum[@"luibutton"][@"lui_key_xbx_pssquare"], nil, function ( element, menu, controller, model )
		return true
	end, function ( element, menu, controller )
		CoD.Menu.SetButtonLabel( menu, Enum[@"luibutton"][@"lui_key_xbx_pssquare"], @"hash_0", nil, nil )
		return false
	end, false )
	f2_local1:AddButtonCallbackFunction( self, f2_arg0, Enum[@"luibutton"][@"lui_key_xby_pstriangle"], nil, function ( element, menu, controller, model )
		return true
	end, function ( element, menu, controller )
		CoD.Menu.SetButtonLabel( menu, Enum[@"luibutton"][@"lui_key_xby_pstriangle"], @"hash_0", nil, nil )
		return false
	end, false )
	layout.buttons:setModel( self.buttonModel, f2_arg0 )
	layout.id = "layout"
	if CoD.isPC then
		BTNQuit.id = "BTNQuit"
	end
	self:processEvent( {
		name = "menu_loaded",
		controller = f2_arg0
	} )
	self.__defaultFocus = layout
	if CoD.isPC and (IsKeyboard( f2_arg0 ) or self.ignoreCursor) then
		self:restoreState( f2_arg0 )
	end
	LUI.OverrideFunction_CallOriginalSecond( self, "close", self.__onClose )
	if PostLoadFunc then
		PostLoadFuncOverlayFull( self, f2_arg0 )
	end
	
	self:setAlpha(0.75)

	if Engine[@"getdvarint"]("shield_ui_color") == 0 then
		self:setRGB(0, 1, 1)
	elseif Engine[@"getdvarint"]("shield_ui_color") == 1 then
		self:setRGB(1, 0, 0)
	elseif Engine[@"getdvarint"]("shield_ui_color") == 2 then
		self:setRGB(0, 1, 0)
	end

	CoD.EnhPrintInfo("Called", "System Overlay Full")

	return self
end

CoD.SystemOverlay_Full.__onClose = function ( f15_arg0 )
	f15_arg0.layout:close()
	f15_arg0.BTNQuit:close()
end

CoD.SystemOverlay_FreeCursor = InheritFrom( CoD.Menu )
LUI.createMenu.SystemOverlay_FreeCursor = function ( f1_arg0, f1_arg1 )
	local self = CoD.Menu.NewForUIEditor( "SystemOverlay_FreeCursor", f1_arg0 )
	local f1_local1 = self
	self:setClass( CoD.SystemOverlay_FreeCursor )
	self.soundSet = "default"
	self:setOwner( f1_arg0 )
	self:setLeftRight( 0, 1, 0, 0 )
	self:setTopBottom( 0, 1, 0, 0 )
	self:playSound( "menu_open", f1_arg0 )
	self.anyChildUsesUpdateState = true
	
	local layout = CoD.systemOverlay_FreeCursor_Layout.new( f1_local1, f1_arg0, 0, 1, 0, 0, 0, 1, 0, 0 )
	layout:setAlpha( 0.99 )
	layout:linkToElementModel( self, nil, false, function ( model )
		layout:setModel( model, f1_arg0 )
	end )
	self:addElement( layout )
	self.layout = layout
	
	local emptyFocusable = CoD.emptyFocusable.new( f1_local1, f1_arg0, 0, 1, 0, 0, 0, 1, 0, 0 )
	self:addElement( emptyFocusable )
	self.emptyFocusable = emptyFocusable
	
	f1_local1:AddButtonCallbackFunction( self, f1_arg0, Enum[@"luibutton"][@"lui_key_xba_pscross"], "ui_confirm", function ( element, menu, controller, model )
		if CoD.OverlayUtility.HasOverlayACrossAction( menu ) then
			CoD.OverlayUtility.PerformOverlayACrossAction( menu, controller )
			return true
		else
			
		end
	end, function ( element, menu, controller )
		if CoD.OverlayUtility.HasOverlayACrossAction( menu ) then
			CoD.Menu.SetButtonLabel( menu, Enum[@"luibutton"][@"lui_key_xba_pscross"], @"hash_128080D5840E11B2", nil, "ui_confirm" )
			return true
		else
			return false
		end
	end, false )
	f1_local1:AddButtonCallbackFunction( self, f1_arg0, Enum[@"luibutton"][@"lui_key_xbb_pscircle"], "ESCAPE", function ( element, menu, controller, model )
		if CoD.OverlayUtility.HasOverlayBCircleAction( menu ) then
			CoD.OverlayUtility.PerformOverlayBCircleAction( menu, controller )
			return true
		else
			
		end
	end, function ( element, menu, controller )
		if CoD.OverlayUtility.HasOverlayBCircleAction( menu ) then
			CoD.Menu.SetButtonLabel( menu, Enum[@"luibutton"][@"lui_key_xbb_pscircle"], @"hash_128080D5840E11B2", nil, "ESCAPE" )
			return true
		else
			return false
		end
	end, false )
	f1_local1:AddButtonCallbackFunction( self, f1_arg0, Enum[@"luibutton"][@"lui_key_xbx_pssquare"], "A", function ( element, menu, controller, model )
		if CoD.OverlayUtility.HasOverlayXSquareAction( menu ) then
			CoD.OverlayUtility.PerformOverlayXSquareAction( menu, controller )
			return true
		else
			
		end
	end, function ( element, menu, controller )
		if CoD.OverlayUtility.HasOverlayXSquareAction( menu ) then
			CoD.Menu.SetButtonLabel( menu, Enum[@"luibutton"][@"lui_key_xbx_pssquare"], @"hash_128080D5840E11B2", nil, "A" )
			return true
		else
			return false
		end
	end, false )
	f1_local1:AddButtonCallbackFunction( self, f1_arg0, Enum[@"luibutton"][@"lui_key_xby_pstriangle"], "S", function ( element, menu, controller, model )
		if CoD.OverlayUtility.HasOverlayYTriangleAction( menu ) then
			CoD.OverlayUtility.PerformOverlayYTriangleAction( menu, controller )
			return true
		else
			
		end
	end, function ( element, menu, controller )
		if CoD.OverlayUtility.HasOverlayYTriangleAction( menu ) then
			CoD.Menu.SetButtonLabel( menu, Enum[@"luibutton"][@"lui_key_xby_pstriangle"], @"hash_128080D5840E11B2", nil, "S" )
			return true
		else
			return false
		end
	end, false )
	layout.buttons:setModel( self.buttonModel, f1_arg0 )
	layout.id = "layout"
	emptyFocusable.id = "emptyFocusable"
	self:processEvent( {
		name = "menu_loaded",
		controller = f1_arg0
	} )
	self.__defaultFocus = layout
	if CoD.isPC and (IsKeyboard( f1_arg0 ) or self.ignoreCursor) then
		self:restoreState( f1_arg0 )
	end
	LUI.OverrideFunction_CallOriginalSecond( self, "close", self.__onClose )
	if PostLoadFunc then
		PostLoadFunc( self, f1_arg0 )
	end

	self:setAlpha(0.75)

	if Engine[@"getdvarint"]("shield_ui_color") == 0 then
		self:setRGB(0, 1, 1)
	elseif Engine[@"getdvarint"]("shield_ui_color") == 1 then
		self:setRGB(1, 0, 0)
	elseif Engine[@"getdvarint"]("shield_ui_color") == 2 then
		self:setRGB(0, 1, 0)
	end

	CoD.EnhPrintInfo("Called", "System Overlay Free Cursor")
	
	return self
end

CoD.SystemOverlay_FreeCursor.__onClose = function ( f11_arg0 )
	f11_arg0.layout:close()
	f11_arg0.emptyFocusable:close()
end

CoD.SystemOverlay_FreeCursor_Full = InheritFrom( CoD.Menu )
LUI.createMenu.SystemOverlay_FreeCursor_Full = function ( f1_arg0, f1_arg1 )
	local self = CoD.Menu.NewForUIEditor( "SystemOverlay_FreeCursor_Full", f1_arg0 )
	local f1_local1 = self
	self:setClass( CoD.SystemOverlay_FreeCursor_Full )
	self.soundSet = "default"
	self:setOwner( f1_arg0 )
	self:setLeftRight( 0, 1, 0, 0 )
	self:setTopBottom( 0, 1, 0, 0 )
	self:playSound( "menu_open", f1_arg0 )
	self.anyChildUsesUpdateState = true
	
	local layout = CoD.systemOverlay_FreeCursor_Full_Layout.new( f1_local1, f1_arg0, 0, 1, 0, 0, 0, 1, 0, 0 )
	layout:setAlpha( 0.99 )
	layout:linkToElementModel( self, nil, false, function ( model )
		layout:setModel( model, f1_arg0 )
	end )
	self:addElement( layout )
	self.layout = layout
	
	local emptyFocusable = CoD.emptyFocusable.new( f1_local1, f1_arg0, 0, 1, 0, 0, 0, 1, 0, 0 )
	self:addElement( emptyFocusable )
	self.emptyFocusable = emptyFocusable
	
	f1_local1:AddButtonCallbackFunction( self, f1_arg0, Enum[@"luibutton"][@"lui_key_xba_pscross"], "ui_confirm", function ( element, menu, controller, model )
		if CoD.OverlayUtility.HasOverlayACrossAction( menu ) then
			CoD.OverlayUtility.PerformOverlayACrossAction( menu, controller )
			return true
		else
			
		end
	end, function ( element, menu, controller )
		if CoD.OverlayUtility.HasOverlayACrossAction( menu ) then
			CoD.Menu.SetButtonLabel( menu, Enum[@"luibutton"][@"lui_key_xba_pscross"], @"hash_128080D5840E11B2", nil, "ui_confirm" )
			return true
		else
			return false
		end
	end, false )
	f1_local1:AddButtonCallbackFunction( self, f1_arg0, Enum[@"luibutton"][@"lui_key_xbb_pscircle"], "ESCAPE", function ( element, menu, controller, model )
		if CoD.OverlayUtility.HasOverlayBCircleAction( menu ) then
			CoD.OverlayUtility.PerformOverlayBCircleAction( menu, controller )
			return true
		else
			
		end
	end, function ( element, menu, controller )
		if CoD.OverlayUtility.HasOverlayBCircleAction( menu ) then
			CoD.Menu.SetButtonLabel( menu, Enum[@"luibutton"][@"lui_key_xbb_pscircle"], @"hash_128080D5840E11B2", nil, "ESCAPE" )
			return true
		else
			return false
		end
	end, false )
	f1_local1:AddButtonCallbackFunction( self, f1_arg0, Enum[@"luibutton"][@"lui_key_xbx_pssquare"], "A", function ( element, menu, controller, model )
		if CoD.OverlayUtility.HasOverlayXSquareAction( menu ) then
			CoD.OverlayUtility.PerformOverlayXSquareAction( menu, controller )
			return true
		else
			
		end
	end, function ( element, menu, controller )
		if CoD.OverlayUtility.HasOverlayXSquareAction( menu ) then
			CoD.Menu.SetButtonLabel( menu, Enum[@"luibutton"][@"lui_key_xbx_pssquare"], @"hash_128080D5840E11B2", nil, "A" )
			return true
		else
			return false
		end
	end, false )
	f1_local1:AddButtonCallbackFunction( self, f1_arg0, Enum[@"luibutton"][@"lui_key_xby_pstriangle"], "S", function ( element, menu, controller, model )
		if CoD.OverlayUtility.HasOverlayYTriangleAction( menu ) then
			CoD.OverlayUtility.PerformOverlayYTriangleAction( menu, controller )
			return true
		else
			
		end
	end, function ( element, menu, controller )
		if CoD.OverlayUtility.HasOverlayYTriangleAction( menu ) then
			CoD.Menu.SetButtonLabel( menu, Enum[@"luibutton"][@"lui_key_xby_pstriangle"], @"hash_128080D5840E11B2", nil, "S" )
			return true
		else
			return false
		end
	end, false )
	layout.buttons:setModel( self.buttonModel, f1_arg0 )
	layout.id = "layout"
	emptyFocusable.id = "emptyFocusable"
	self:processEvent( {
		name = "menu_loaded",
		controller = f1_arg0
	} )
	self.__defaultFocus = layout
	if CoD.isPC and (IsKeyboard( f1_arg0 ) or self.ignoreCursor) then
		self:restoreState( f1_arg0 )
	end
	LUI.OverrideFunction_CallOriginalSecond( self, "close", self.__onClose )
	if PostLoadFunc then
		PostLoadFunc( self, f1_arg0 )
	end

	self:setAlpha(0.75)

	if Engine[@"getdvarint"]("shield_ui_color") == 0 then
		self:setRGB(0, 1, 1)
	elseif Engine[@"getdvarint"]("shield_ui_color") == 1 then
		self:setRGB(1, 0, 0)
	elseif Engine[@"getdvarint"]("shield_ui_color") == 2 then
		self:setRGB(0, 1, 0)
	end

	CoD.EnhPrintInfo("Called", "System Overlay Free Cursor Full")
	
	return self
end

CoD.SystemOverlay_FreeCursor_Full.__onClose = function ( f11_arg0 )
	f11_arg0.layout:close()
	f11_arg0.emptyFocusable:close()
end
