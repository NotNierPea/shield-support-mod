--[[
		.\hksc.exe ".\Lua\ServerORLobbyBrowserSelect.Lua" -o "C:\Program Files (x86)\Call of Duty Black Ops 4\project-bo4\mods\T8ShieldSupport\Lua\ServerORLobbyBrowserSelect.luac"
]]

---------------------------

CoD.ShieldInitLuaFile()

---------------------------

-- Filters for Server, both use it.
DataSources.ShieldServerBrowserFilters = DataSourceHelpers.ListSetup( "ShieldServerBrowserFilters", function ( f3_arg0, f3_arg1 )
	local f3_local0 = {
		{
			models = {
				name = @"shield/servers",
				filter = Enum[@"lobbymainmode"][@"lobby_mainmode_invalid"]
			}
		}
	}
	return f3_local0
end, true )

---------------------------

-- Servers SetUp
CoD.ShieldLobbyServerBrowserOverlay_Select = InheritFrom( CoD.Menu )
LUI.createMenu.ShieldLobbyServerBrowserOverlay_Select = function ( f1_arg0, f1_arg1 )
	local self = CoD.Menu.NewForUIEditor( "ShieldLobbyServerBrowserOverlay_Select", f1_arg0 )
	local f1_local1 = self
	
	self:setClass( CoD.ShieldLobbyServerBrowserOverlay_Select )
	self.soundSet = "default"
	self:setOwner( f1_arg0 )
	self:setLeftRight( 0, 1, 0, 0 )
	self:setTopBottom( 0, 1, 0, 0 )
	self:playSound( "menu_open", f1_arg0 )
	self.anyChildUsesUpdateState = true
	
	local Background = CoD.StartMenuOptionsBackground.new( f1_local1, f1_arg0, 0, 1, 0, 0, 0, 1, 0, 0 )
	self:addElement( Background )
	self.Background = Background

	-- select servers or lobbies browser
	local LobbyBrowser = CoD.DirectorSelectButtonMiniInternal.new( f1_local1, f1_arg0, 0.5, 0.5, -550, -100, 0.5, 0.5, -150, 150 )
	
	LobbyBrowser.MiddleText:setTTF( "notosans_bold" )
	LobbyBrowser.MiddleText:setText("Lobby Browser")

	LobbyBrowser.MiddleTextFocus:setText("Lobby Browser")
	LobbyBrowser.MiddleTextFocus:setTTF( "notosans_bold" )

	LobbyBrowser:mergeStateConditions( {
		{
			stateName = "Locked",
			condition = function ( menu, element, event )
				return AlwaysFalse()
			end
		}
	} )

	LobbyBrowser:linkToElementModel( self, nil, false, function ( model )
		LobbyBrowser:setModel( model, f1_arg0 )
	end )
	self:addElement( LobbyBrowser )
	self.LobbyBrowser = LobbyBrowser

	f1_local1:AddButtonCallbackFunction( LobbyBrowser, f1_arg0, Enum[@"luibutton"][@"lui_key_xba_pscross"], "ui_confirm", function ( element, menu, controller, model )
		PlaySoundAlias( "uin_paint_image_flip_toggle" )
		CoD.EnhPrintInfo("LobbyBrowser")
		
		OpenOverlay( self, "ShieldLobbyServerBrowserOverlay", controller )

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
	
	LobbyBrowser.id = "LobbyBrowser"

	-- server
	local ServerBrowser = CoD.DirectorSelectButtonMiniInternal.new( f1_local1, f1_arg0, 0.5, 0.5, 100, 550, 0.5, 0.5, -150, 150 )
	
	ServerBrowser.MiddleText:setTTF( "notosans_bold" )
	ServerBrowser.MiddleText:setText("Server Browser")

	ServerBrowser.MiddleTextFocus:setText("Server Browser")
	ServerBrowser.MiddleTextFocus:setTTF( "notosans_bold" )

	ServerBrowser:mergeStateConditions( {
		{
			stateName = "Locked",
			condition = function ( menu, element, event )
				return AlwaysFalse()
			end
		}
	} )

	ServerBrowser:linkToElementModel( self, nil, false, function ( model )
		ServerBrowser:setModel( model, f1_arg0 )
	end )
	self:addElement( ServerBrowser )
	self.ServerBrowser = ServerBrowser

	f1_local1:AddButtonCallbackFunction( ServerBrowser, f1_arg0, Enum[@"luibutton"][@"lui_key_xba_pscross"], "ui_confirm", function ( element, menu, controller, model )
		PlaySoundAlias( "uin_paint_image_flip_toggle" )
		CoD.EnhPrintInfo("ServerBrowser")
		
		OpenOverlay( self, "ShieldServerBrowserOverlay", controller )

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
	
	ServerBrowser.id = "ServerBrowser"
	
	local FooterContainerFrontendRight = nil
	
	FooterContainerFrontendRight = CoD.FooterContainer_Frontend_Right.new( f1_local1, f1_arg0, 0.5, 0.5, -960, 960, 1, 1, -48, 0 )
	self:addElement( FooterContainerFrontendRight )
	self.FooterContainerFrontendRight = FooterContainerFrontendRight
	
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

	self:processEvent( {
		name = "menu_loaded",
		controller = f1_arg0
	} )

	LUI.OverrideFunction_CallOriginalSecond( self, "close", self.__onClose )
	
	if PostLoadFunc then
		PostLoadFunc( self, f1_arg0 )
	end
	
	local f1_local19 = self
	--MenuHidesFreeCursor( f1_local1, f1_arg0 )

	CoD.EnhPrintInfo("Called", "Shield's Lobby Server Browser")

	--SizeToSafeArea(SafeAreaContainerLobbyServerBrwoserOverlay, f1_arg0)

	return self
end

CoD.ShieldLobbyServerBrowserOverlay_Select.__onClose = function ( f8_arg0 )
	f8_arg0.Background:close()
	f8_arg0.FooterContainerFrontendRight:close()
	f8_arg0.LobbyBrowser:close()
	f8_arg0.ServerBrowser:close()
	--f8_arg0.FooterContainerFrontendRight2:close()
	--f8_arg0.SafeAreaContainerLobbyServerBrwoserOverlay:close()
	--f8_arg0.ShieldServerListButtonList:close()
end