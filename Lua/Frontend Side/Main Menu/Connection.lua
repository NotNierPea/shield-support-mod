--[[
		.\hksc.exe ".\Lua\Connection.Lua" -o "C:\Program Files (x86)\Call of Duty Black Ops 4\project-bo4\mods\T8ShieldSupport\Lua\Connection.luac"
]]

---------------------------

CoD.ShieldInitLuaFile()

---------------------------

-- Disconnected State
DataSources.ExtraButtonsDisconnectedState = ListHelper_SetupDataSource( "ExtraButtonsDisconnectedState", function ( f85_arg0, f85_arg1 )
	local listdisconnectedbuttons = {}
	table.insert( listdisconnectedbuttons, {
		models = {
			subtitle = @"shield/serverbrowser",
			iconBackground = @"ui_icon_blackmarket_store_tile_focus_05",
			iconBackgroundFocus = @"ui_icon_blackmarket_store_tile_focus_05",
			showOnLeft = true,
			small = false,
			locked = Engine[@"getdvarint"](@"shield_is_offline") == 1
		},
		properties = {
			action = CoD.DirectorUtility.DirectorSelectOpenPopup,
			actionParam = "ShieldServerBrowserOverlay"
		}
	} )

	return listdisconnectedbuttons
end )

---------------------------

-- Main Frontend Connection Screen
CoD.DirectorQuitButtonContainer = InheritFrom( LUI.UIElement )
CoD.DirectorQuitButtonContainer.__defaultWidth = 274
CoD.DirectorQuitButtonContainer.__defaultHeight = 36
CoD.DirectorQuitButtonContainer.new = function ( f1_arg0, f1_arg1, f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	local self = LUI.UIHorizontalList.new( f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9, 10, true )
	self:setAlignment( LUI.Alignment.Right )
	self:setClass( CoD.DirectorQuitButtonContainer )
	self.id = "DirectorQuitButtonContainer"
	self.soundSet = "default"
	f1_arg0:addElementToPendingUpdateStateList( self )
	
	local BG = LUI.UIImage.new( 0, 1, 0, 0, 0, 1, 0, 0 )
	BG:setAlpha( 0 )
	self:addElement( BG )
	self.BG = BG
	
	local Spacer = CoD.VerticalListSpacer.new( f1_arg0, f1_arg1, 0, 0, 266, 274, 0.5, 0.5, -25.5, 25.5 )
	self:addElement( Spacer )
	self.Spacer = Spacer
	
	local QuitText = LUI.UIText.new( 0, 0, 205, 255, 0.5, 0.5, -7.5, 10.5 )
	QuitText:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )
	QuitText:setAlpha( 0.35 )
	QuitText:setText( Engine[@"hash_4F9F1239CFD921FE"]( @"menu/desktop" ) )
	QuitText:setTTF( "default" )
	QuitText:setLetterSpacing( 6 )
	QuitText:setAlignment( Enum[@"luialignment"][@"lui_alignment_left"] )
	self:addElement( QuitText )
	self.QuitText = QuitText
	
	local QuitIcon = LUI.UIImage.new( 0, 0, 171, 196, 0.5, 0.5, -13.5, 11.5 )
	QuitIcon:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )
	QuitIcon:setAlpha( 0.55 )
	QuitIcon:setImage( RegisterImage( @"uie_director_main_quit_icon" ) )
	self:addElement( QuitIcon )
	self.QuitIcon = QuitIcon
	
	local Spacer2 = CoD.VerticalListSpacer.new( f1_arg0, f1_arg1, 0, 0, 153, 161, 0.5, 0.5, -25.5, 25.5 )
	self:addElement( Spacer2 )
	self.Spacer2 = Spacer2
	
	f1_arg0:AddButtonCallbackFunction( self, f1_arg1, Enum[@"luibutton"][@"lui_key_xba_pscross"], "ui_confirm", function ( element, menu, controller, model )
		OpenPCQuit( self, menu, self, controller )
		return true
	end, function ( element, menu, controller )
		CoD.Menu.SetButtonLabel( menu, Enum[@"luibutton"][@"lui_key_xba_pscross"], @"hash_0", nil, "ui_confirm" )
		return false
	end, false )
	LUI.OverrideFunction_CallOriginalSecond( self, "close", self.__onClose )
	
	if PostLoadFunc then
		PostLoadFunc( self, f1_arg1, f1_arg0 )
	end

	CoD.EnhPrintInfo("Called", "Director Quit Button")
	--self:setRGB(1, 0, 0)

	-- we can't override it so lets do it this way
	if f1_arg0.ConnectionLabel ~= nill then
		
		local FrontMain = f1_arg0
		local ConnectionLabel = FrontMain.ConnectionLabel

		CoD.EnhPrintInfo("Called", "Main Front")

		-- set style for connection text 
		ConnectionLabel.lblConnecting:setTTF("notosans_bold")
		ConnectionLabel:setRGB(0, 1, 0)
		--ConnectionLabel.lblConnecting:setText("Welcome to Shield Client, Connecting...")

		-- remove annoying backgrounds
		FrontMain.StartLabel:setAlpha(0)
		FrontMain.BGFill:setAlpha(0)
		FrontMain.PCBnetStoreKeyart:setAlpha(0)
		
		-- Add IPV4 Edit for Disconnected Servers
		local ServerBrowserButton = LUI.UIList.new( f1_arg0, f1_arg1, 15, 0, nil, false, false, false, false )
		ServerBrowserButton:setLeftRight( 0.5, 0.5, -725, -513 )
		ServerBrowserButton:setTopBottom( 0, 0, 265 + 460, 510 + 460 )
		ServerBrowserButton:setWidgetType( CoD.DirectorPreGameButtonLeftJustified )
		ServerBrowserButton:setVerticalCount( 4 )
		ServerBrowserButton:setSpacing( 15 )
		ServerBrowserButton:setFilter( function ( f3_arg0 )
			return f3_arg0.showOnLeft:get() == true
		end )
		
		ServerBrowserButton:setDataSource( "ExtraButtonsDisconnectedState" )
		ServerBrowserButton:linkToElementModel( ServerBrowserButton, "trialLocked", true, function ( model, f4_arg1 )
			CoD.Menu.UpdateButtonShownState( f4_arg1, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
		end )
		ServerBrowserButton:linkToElementModel( ServerBrowserButton, "locked", true, function ( model, f5_arg1 )
			CoD.Menu.UpdateButtonShownState( f5_arg1, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
		end )

		ServerBrowserButton:linkToElementModel( ServerBrowserButton, "showForAllClients", true, function ( model, f9_arg1 )
			CoD.Menu.UpdateButtonShownState( f9_arg1, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
		end )
		ServerBrowserButton:registerEventHandler( "list_item_gain_focus", function ( element, event )
			local f10_local0 = nil
			CoD.DirectorUtility.UpdateDescriptionTextFromSelectMenu( f1_arg1, element )
			return f10_local0
		end )
		ServerBrowserButton:registerEventHandler( "gain_focus", function ( element, event )
			local f11_local0 = nil
			if element.gainFocus then
				f11_local0 = element:gainFocus( event )
			elseif element.super.gainFocus then
				f11_local0 = element.super:gainFocus( event )
			end
			CoD.Menu.UpdateButtonShownState( element, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
			return f11_local0
		end )
		f1_arg0:AddButtonCallbackFunction( ServerBrowserButton, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], "ui_confirm", function ( element, menu, controller, model )
			if CoD.ModelUtility.IsSelfModelValueTrue( element, controller, "trialLocked" ) and AlwaysFalse() then
				OpenOverlay( f1_arg0, "Store", controller )
				PlaySoundAlias( "uin_toggle_generic" )
				return true
			elseif not CoD.ModelUtility.IsSelfModelValueTrue( element, controller, "locked" ) and not CoD.ModelUtility.IsSelfModelValueTrue( element, controller, "trialLocked" ) then
				ProcessListAction( f1_arg0, element, controller, menu )
				PlaySoundAlias( "uin_toggle_generic" )
				return true
			else
				
			end
		end, function ( element, menu, controller )
			if CoD.ModelUtility.IsSelfModelValueTrue( element, controller, "trialLocked" ) and AlwaysFalse() then
				CoD.Menu.SetButtonLabel( menu, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], @"hash_4191CDDA584B4408", nil, "ui_confirm" )
				return true
			elseif not CoD.ModelUtility.IsSelfModelValueTrue( element, controller, "locked" ) and not CoD.ModelUtility.IsSelfModelValueTrue( element, controller, "trialLocked" ) then
				CoD.Menu.SetButtonLabel( menu, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], @"hash_6D0BB36CD318F55F", nil, "ui_confirm" )
				return true
			else
				return false
			end
		end, false )
		f1_arg0:addElement( ServerBrowserButton )
		f1_arg0.ServerBrowserButton = ServerBrowserButton

		ServerBrowserButton.id = "ServerBrowserButton"

		local ReconnectedButton = CoD.DirectorSelectButtonMiniInternal.new( f1_arg0, f1_arg1, 0.5, 0.5, -725 + 250, -513 + 250, 0, 0, 265 + 460, 510 + 460 - 53.5 )
		
		ReconnectedButton.MiddleText:setTTF( "notosans_bold" )
		ReconnectedButton.MiddleText:setText("Reconnect")

		ReconnectedButton.MiddleTextFocus:setText("Reconnect")
		ReconnectedButton.MiddleTextFocus:setTTF( "notosans_bold" )

		ReconnectedButton:mergeStateConditions( {
			{
				stateName = "Locked",
				condition = function ( menu, element, event )
					return AlwaysFalse()
				end
			}
		} )

		ReconnectedButton:linkToElementModel( f1_arg0, nil, false, function ( model )
			ReconnectedButton:setModel( model, f1_arg0 )
		end )
		f1_arg0:addElement( ReconnectedButton )
		f1_arg0.ReconnectedButton = ReconnectedButton

		f1_arg0:AddButtonCallbackFunction( ReconnectedButton, f1_arg1, Enum[@"luibutton"][@"lui_key_xba_pscross"], "ui_confirm", function ( element, menu, controller, model )
			PlaySoundAlias( "uin_paint_image_flip_toggle" )
			CoD.EnhPrintInfo("ReconnectedButton")
			
			Engine[@"exec"](Engine[@"getprimarycontroller"](), "recoverDW")

		end, function ( element, menu, controller )
			if IsGamepad( controller ) then
				CoD.Menu.SetButtonLabel( menu, Enum[@"luibutton"][@"lui_key_xba_pscross"], @"menu/join", nil, "ui_confirm" )
				return true
			elseif IsMouseOrKeyboard( controller ) then
				CoD.Menu.SetButtonLabel( menu, Enum[@"luibutton"][@"lui_key_xba_pscross"], @"hash_0", nil, "ui_confirm" )
				return false
			else
				return false
			end
		end, false )
		
		ReconnectedButton.id = "ReconnectedButton"

		-- refresh in main init
		CoD.RefreshShieldShit()
	end

	return self
end

CoD.DirectorQuitButtonContainer.__resetProperties = function ( f4_arg0 )
	f4_arg0.QuitIcon:completeAnimation()
	f4_arg0.QuitText:completeAnimation()
	f4_arg0.QuitIcon:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )
	f4_arg0.QuitIcon:setAlpha( 0.55 )
	f4_arg0.QuitText:setAlpha( 0.35 )
end

CoD.DirectorQuitButtonContainer.__clipsPerState = {
	DefaultState = {
		DefaultClip = function ( f5_arg0, f5_arg1 )
			f5_arg0:__resetProperties()
			f5_arg0:setupElementClipCounter( 0 )
		end,
		Focus = function ( f6_arg0, f6_arg1 )
			f6_arg0:__resetProperties()
			f6_arg0:setupElementClipCounter( 2 )
			f6_arg0.QuitText:completeAnimation()
			f6_arg0.QuitText:setAlpha( 0.8 )
			f6_arg0.clipFinished( f6_arg0.QuitText )
			f6_arg0.QuitIcon:completeAnimation()
			f6_arg0.QuitIcon:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )
			f6_arg0.QuitIcon:setAlpha( 1 )
			f6_arg0.clipFinished( f6_arg0.QuitIcon )
		end,
		GainFocus = function ( f7_arg0, f7_arg1 )
			f7_arg0:__resetProperties()
			f7_arg0:setupElementClipCounter( 2 )
			local f7_local0 = function ( f8_arg0 )
				f7_arg0.QuitText:beginAnimation( 100 )
				f7_arg0.QuitText:setAlpha( 0.8 )
				f7_arg0.QuitText:registerEventHandler( "interrupted_keyframe", f7_arg0.clipInterrupted )
				f7_arg0.QuitText:registerEventHandler( "transition_complete_keyframe", f7_arg0.clipFinished )
			end
			
			f7_arg0.QuitText:completeAnimation()
			f7_arg0.QuitText:setAlpha( 0.35 )
			f7_local0( f7_arg0.QuitText )
			local f7_local1 = function ( f9_arg0 )
				f7_arg0.QuitIcon:beginAnimation( 100 )
				f7_arg0.QuitIcon:setAlpha( 1 )
				f7_arg0.QuitIcon:registerEventHandler( "interrupted_keyframe", f7_arg0.clipInterrupted )
				f7_arg0.QuitIcon:registerEventHandler( "transition_complete_keyframe", f7_arg0.clipFinished )
			end
			
			f7_arg0.QuitIcon:completeAnimation()
			f7_arg0.QuitIcon:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )
			f7_arg0.QuitIcon:setAlpha( 0.55 )
			f7_local1( f7_arg0.QuitIcon )
		end,
		LoseFocus = function ( f10_arg0, f10_arg1 )
			f10_arg0:__resetProperties()
			f10_arg0:setupElementClipCounter( 2 )
			local f10_local0 = function ( f11_arg0 )
				f10_arg0.QuitText:beginAnimation( 150 )
				f10_arg0.QuitText:setAlpha( 0.35 )
				f10_arg0.QuitText:registerEventHandler( "interrupted_keyframe", f10_arg0.clipInterrupted )
				f10_arg0.QuitText:registerEventHandler( "transition_complete_keyframe", f10_arg0.clipFinished )
			end
			
			f10_arg0.QuitText:completeAnimation()
			f10_arg0.QuitText:setAlpha( 0.8 )
			f10_local0( f10_arg0.QuitText )
			local f10_local1 = function ( f12_arg0 )
				f10_arg0.QuitIcon:beginAnimation( 150 )
				f10_arg0.QuitIcon:setAlpha( 0.55 )
				f10_arg0.QuitIcon:registerEventHandler( "interrupted_keyframe", f10_arg0.clipInterrupted )
				f10_arg0.QuitIcon:registerEventHandler( "transition_complete_keyframe", f10_arg0.clipFinished )
			end
			
			f10_arg0.QuitIcon:completeAnimation()
			f10_arg0.QuitIcon:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )
			f10_arg0.QuitIcon:setAlpha( 1 )
			f10_local1( f10_arg0.QuitIcon )
		end
	}
}

CoD.DirectorQuitButtonContainer.__onClose = function ( f13_arg0 )
	f13_arg0.Spacer:close()
	f13_arg0.Spacer2:close()
end