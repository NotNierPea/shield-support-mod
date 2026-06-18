--[[
		.\hksc.exe ".\Lua\ServerBrowser.Lua" -o "C:\Program Files (x86)\Call of Duty Black Ops 4\project-bo4\mods\T8ShieldSupport\Lua\ServerBrowser.luac"
]]

---------------------------

CoD.ShieldInitLuaFile()

---------------------------

-- servers
local InfoServers = {
	{
		models = {
			ServerName = "^3Public Server 1",
			HostedBy = "WIZE",
			ClientCount = "Getting...",
			ConnectionIP = "70.55.126.7"
		},
		properties = {
			-- none yet
		}
	}
}

---------------------------

CoD.Shield.CheckServerStatus = function(event_name, event_table)
	local index = event_table.index
	local status = event_table.status
	local players = event_table.players

	CoD.EnhPrintInfo("Updating Server for " .. tostring(index))

	if InfoServers and InfoServers[index + 1] then
		local server = InfoServers[index + 1]

		local Status_STR = ""

		if status == true then
			Status_STR = "^2Online"
			server.models.ClientCount = tostring(Status_STR .. " (" .. (players or "?") .. ")")
		else
			-- no players
			Status_STR = "^1Offline"
			server.models.ClientCount = tostring(Status_STR)
		end

		--CoD.EnhPrintInfo(status)

		-- force model update, might not work that way???
		--DataSources.ShieldDWServers[index + 1] = server
	end
	
	if CoD.Menu.ServersStatusWidget ~= nil then 
		CoD.Menu.ServersStatusWidget:setDataSource("ShieldDWServers")
		CoD.Menu.ServersStatusWidget:updateDataSource()
	end
end

---------------------------

-- Shield's DW Server Data
DataSources.ShieldDWServers = DataSourceHelpers.ListSetup( "ShieldDWServers", function ( f3_arg0, f3_arg1 )
	CoD.EnhPrintInfo("Inserting servers..")

	local InfoServersGet = {
		
	}

	if InfoServers then
		for i = 1, #InfoServers do
			local server = InfoServers[i].models
			table.insert(InfoServersGet, {
				models = {
					ServerName = server.ServerName,
					HostedBy = server.HostedBy,
					ClientCount = server.ClientCount,
					ConnectionIP = server.ConnectionIP
				},
				properties = {}
			})
		end
	end

	return InfoServersGet
end, true )

CoD.OverlayUtility.Overlays.ShieldIPNotice = {
	menuName = "SystemOverlay_Compact",
	postCreateStep = function ( f155_arg0, f155_arg1 )
		f155_arg0.anyControllerAllowed = true
	end,
	title = @"menu/notice",
	description = @"shield/ip_notice",
	categoryType = CoD.OverlayUtility.OverlayTypes.Connection,
	[CoD.OverlayUtility.GoBackPropertyName] = CoD.OverlayUtility.DefaultGoBack,
	listDatasource = function ( f156_arg0 )
		DataSources.ShieldIPNoticeList = DataSourceHelpers.ListSetup( "ShieldIPNoticeList", function ( f157_arg0 )
			return {
				{
					models = {
						displayText = Engine[@"hash_4F9F1239CFD921FE"]( @"menu/ok" )
					},
					properties = {
						action = function ( f158_arg0, f158_arg1, f158_arg2, f158_arg3, f158_arg4 )
							GoBack( f158_arg4, f158_arg2 )
						end
					}
				},
				{
					models = {
						displayText = Engine[@"hash_4F9F1239CFD921FE"]( @"shield/disconnect" )
					},
					properties = {
						action = function ( f158_arg0, f158_arg1, f158_arg2, f158_arg3, f158_arg4 )
							Engine[@"exec"](Engine[@"getprimarycontroller"](), "fakedwdisconnect")
						end
					}
				}
			}
		end, true, nil )
		return "ShieldIPNoticeList"
	end
}

---------------------------

-- Servers
CoD.ShieldServerBrowserOverlay = InheritFrom( CoD.Menu )
LUI.createMenu.ShieldServerBrowserOverlay = function ( f1_arg0, f1_arg1 )
	local self = CoD.Menu.NewForUIEditor( "ShieldServerBrowserOverlay", f1_arg0 )
	local f1_local1 = self
	
	self:setClass( CoD.ShieldServerBrowserOverlay )
	self.soundSet = "default"
	self:setOwner( f1_arg0 )
	self:setLeftRight( 0, 1, 0, 0 )
	self:setTopBottom( 0, 1, 0, 0 )
	self:playSound( "menu_open", f1_arg0 )
	self.anyChildUsesUpdateState = true
	
	local Background = CoD.StartMenuOptionsBackground.new( f1_local1, f1_arg0, 0, 1, 0, 0, 0, 1, 0, 0 )
	self:addElement( Background )
	self.Background = Background
	
	local FooterContainerFrontendRight = nil
	
	FooterContainerFrontendRight = CoD.FooterContainer_Frontend_Right.new( f1_local1, f1_arg0, 0.5, 0.5, -960, 960, 1, 1, -48, 0 )
	self:addElement( FooterContainerFrontendRight )
	self.FooterContainerFrontendRight = FooterContainerFrontendRight
	
	local Shield_SafeAreaContainer_ServerBrowserOverlay = CoD.Shield_SafeAreaContainer_ServerBrowserOverlay.new( f1_local1, f1_arg0, 0, 0, 0, 1920, 0, 0, 0, 1080 )
	Shield_SafeAreaContainer_ServerBrowserOverlay:registerEventHandler( "menu_loaded", function ( element, event )
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
	self:addElement( Shield_SafeAreaContainer_ServerBrowserOverlay )
	self.Shield_SafeAreaContainer_ServerBrowserOverlay = Shield_SafeAreaContainer_ServerBrowserOverlay
	
	f1_local1:AddButtonCallbackFunction( self, f1_arg0, Enum[@"hash_3DD78803F918E9D"][@"hash_1805EFA15E9E7E5A"], nil, function ( element, menu, controller, model )
		GoBack( self, controller )
		return true
	end, function ( element, menu, controller )
		CoD.Menu.SetButtonLabel( menu, Enum[@"hash_3DD78803F918E9D"][@"hash_1805EFA15E9E7E5A"], @"hash_6A4032FB2AAB69F2", nil, nil )
		return true
	end, false )

	-- refresh button, not needed for now
	--[[
	f1_local1:AddButtonCallbackFunction( self, f1_arg0, Enum[@"hash_3DD78803F918E9D"][@"hash_1E6DB407A2AF8B09"], nil, function ( element, menu, controller, model )
		RefreshServerList( self, controller )
		PlaySoundAlias( "uin_paint_image_flip_toggle" )
		return true
	end, function ( element, menu, controller )
		CoD.Menu.SetButtonLabel( menu, Enum[@"hash_3DD78803F918E9D"][@"hash_1E6DB407A2AF8B09"], @"hash_3864802EE42E1E92", nil, nil )
		return true
	end, false )
	]]

	FooterContainerFrontendRight:setModel( self.buttonModel, f1_arg0 )
	if CoD.isPC then
		FooterContainerFrontendRight.id = "FooterContainerFrontendRight"
	end
	--FooterContainerFrontendRight2:setModel( self.buttonModel, f1_arg0 )
	--if CoD.isPC then
		--FooterContainerFrontendRight2.id = "FooterContainerFrontendRight2"
	--end

	Shield_SafeAreaContainer_ServerBrowserOverlay.id = "Shield_SafeAreaContainer_ServerBrowserOverlay"

	self:processEvent( {
		name = "menu_loaded",
		controller = f1_arg0
	} )

	LUI.OverrideFunction_CallOriginalSecond( self, "close", self.__onClose )
	
	if PostLoadFunc then
		PostLoadFunc( self, f1_arg0 )
	end
	
	local f1_local19 = self
	--RefreshServerList( self, f1_arg0 ) -- no need (only for lan)
	--MenuHidesFreeCursor( f1_local1, f1_arg0 )

	CoD.EnhPrintInfo("Called", "Shield's Lobby Server Browser")

	SizeToSafeArea(Shield_SafeAreaContainer_ServerBrowserOverlay, f1_arg0)

	return self
end

CoD.ShieldServerBrowserOverlay.__onClose = function ( f8_arg0 )
	f8_arg0.Background:close()
	f8_arg0.FooterContainerFrontendRight:close()
	--f8_arg0.FooterContainerFrontendRight2:close()
	f8_arg0.Shield_SafeAreaContainer_ServerBrowserOverlay:close()
	--f8_arg0.ShieldServerListButtonList:close()
end

-- Safe for Server
CoD.Shield_SafeAreaContainer_ServerBrowserOverlay = InheritFrom( LUI.UIElement )
CoD.Shield_SafeAreaContainer_ServerBrowserOverlay.__defaultWidth = 1920
CoD.Shield_SafeAreaContainer_ServerBrowserOverlay.__defaultHeight = 1080
CoD.Shield_SafeAreaContainer_ServerBrowserOverlay.new = function ( f1_arg0, f1_arg1, f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	local self = LUI.UIElement.new( f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	self:setClass( CoD.Shield_SafeAreaContainer_ServerBrowserOverlay )
	self.id = "Shield_SafeAreaContainer_ServerBrowserOverlay"
	self.soundSet = "none"
	self.onlyChildrenFocusable = true
	self.anyChildUsesUpdateState = true
	
	local TabBacking = CoD.CommonTabBarBacking.new( f1_arg0, f1_arg1, -0.1, 1.1, 0, 0, 0, 0, 52, 89 )
	TabBacking.TabBackingBlur:setAlpha( 0 )
	self:addElement( TabBacking )
	self.TabBacking = TabBacking
	
	local CommonHeader = CoD.CommonHeader.new( f1_arg0, f1_arg1, 0, 1, 0, 0, 0, 0, 0, 67 )
	CommonHeader.subtitle.StageTitle:setText("^2Server Browser")
	CommonHeader.subtitle.subtitle:setText("^3Official Shield Servers")
	self:addElement( CommonHeader )
	self.CommonHeader = CommonHeader
	
	local FETabBar = CoD.DirectorSelect_Tabbar_Center.new( f1_arg0, f1_arg1, 0.5, 0.5, -100.5, 100.5, 0, 0, 52.5, 113.5 )
	FETabBar:mergeStateConditions( {
		{
			stateName = "DimBumperIcons",
			condition = function ( menu, element, event )
				return IsLobbyNetworkModeLAN()
			end
		}
	} )
	local f1_local4 = FETabBar
	local HeaderStripe = FETabBar.subscribeToModel
	local f1_local6 = Engine[@"hash_78DF2E5447F384B9"]()
	HeaderStripe( f1_local4, f1_local6["lobbyRoot.lobbyNav"], function ( f3_arg0 )
		f1_arg0:updateElementState( FETabBar, {
			name = "model_validation",
			menu = f1_arg0,
			controller = f1_arg1,
			modelValue = f3_arg0:get(),
			modelName = "lobbyRoot.lobbyNav"
		} )
	end, false )
	FETabBar.Tabs.grid:setHorizontalCount( 5 )
	FETabBar.Tabs.grid:setDataSource( "ShieldServerBrowserFilters" )
	FETabBar:registerEventHandler( "list_active_changed", function ( element, event )
		local f4_local0 = nil
		CoD.LobbyUtility.LobbyLANServerBrowserSetMainModeFilter( self, element, f1_arg1 )
		--RefreshServerList( self, f1_arg1 )
		return f4_local0
	end )
	self:addElement( FETabBar )
	self.FETabBar = FETabBar
	
	HeaderStripe = CoD.header_container_frontend.new( f1_arg0, f1_arg1, 0, 1, 0, 0, 0, 0, 0, 42 )
	self:addElement( HeaderStripe )
	self.HeaderStripe = HeaderStripe

	local ShieldDWServerDetails = CoD.ShieldDWServerRowList.new( f1_arg0, f1_arg1, 0.5, 0.5, -800, 800, 0.5, 0.5, -310, 300 )
	self:addElement( ShieldDWServerDetails )
	self.ShieldDWServerDetails = ShieldDWServerDetails

	-- for updates
	CoD.Menu.ServersStatusWidget = ShieldDWServerDetails.Servers

	-- update servers
	Engine[@"exec"](Engine[@"getprimarycontroller"](), 'check_server_status "http://70.55.126.7:8080/" 0')

	local HeaderBackingL = LUI.UIImage.new( 0.5, 0.5, 160 - 975, 1229 - 975, 0.5, 0.5, 176 - 540, 216 - 540 )
	HeaderBackingL:setRGB( 0, 0, 0 )
	HeaderBackingL:setAlpha( 0.5 )
	self:addElement( HeaderBackingL )
	self.HeaderBackingL = HeaderBackingL

	-- desc for dw
	local DWHint = LUI.UIText.new( 0.5, 0.5, -20 - 770, 850 - 770, 0.5, 0.5, 100 - 525, 140 - 525 )
	DWHint:setText("Main Servers")
	DWHint:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )
	DWHint:setTTF("notosans_bold")
	DWHint:setRGB(1, 1, 0)
	DWHint:setBackingType( 2 )
	DWHint:setBackingColor( 0.04, 0.81, 1 )
	DWHint:setBackingAlpha( 0.01 )
	DWHint:setBackingXPadding( 12 )
	DWHint:setBackingYPadding( 6 )
	DWHint:setAlignment( Enum[@"luialignment"][@"lui_alignment_left"] )
	DWHint:setAlignment( Enum[@"luialignment"][@"lui_alignment_top"] )
	self:addElement( DWHint )
	self.DWHint = DWHint
	
	-- descs for dw servers
	local ServerNameText = LUI.UIText.new( 0.5, 0.5, -783, -583, 0.5, 0.5, -353.5, -334.5 )
	ServerNameText:setRGB( 0.59, 0.59, 0.59 )
	ServerNameText:setScale( LanguageOverrideNumber( "japanese", 0.75, 1, 1 ) )
	ServerNameText:setText("Server")
	ServerNameText:setTTF( "ttmussels_regular" )
	ServerNameText:setAlignment( Enum[@"hash_67A5123B654282D2"][@"hash_558C8A85F2048829"] )
	ServerNameText:setAlignment( Enum[@"hash_67A5123B654282D2"][@"hash_3F41D595A2B0EDF3"] )
	self:addElement( ServerNameText )
	self.ServerNameText = ServerNameText
	
	local PlayerCountText = LUI.UIText.new( 0.5, 0.5, -359 + 290, -188 + 290, 0.5, 0.5, -353, -334 )
	PlayerCountText:setRGB( 0.59, 0.59, 0.59 )
	PlayerCountText:setScale( LanguageOverrideNumber( "japanese", 0.75, 1, 1 ) )
	PlayerCountText:setText("Status (Players)")
	PlayerCountText:setTTF( "ttmussels_regular" )
	--PlayerCountText:setLetterSpacing( 1 )
	PlayerCountText:setAlignment( Enum[@"hash_67A5123B654282D2"][@"hash_558C8A85F2048829"] )
	PlayerCountText:setAlignment( Enum[@"hash_67A5123B654282D2"][@"hash_3F41D595A2B0EDF3"] )
	self:addElement( PlayerCountText )
	self.PlayerCountText = PlayerCountText
	
	local ServerIPText = LUI.UIText.new( 0.5, 0.5, -300, -31, 0.5, 0.5, -353.5, -334.5 )
	ServerIPText:setRGB( 0.59, 0.59, 0.59 )
	ServerIPText:setScale( LanguageOverrideNumber( "japanese", 0.75, 1, 1 ) )
	ServerIPText:setText("Server IP")
	ServerIPText:setTTF( "ttmussels_regular" )
	ServerIPText:setAlignment( Enum[@"hash_67A5123B654282D2"][@"hash_558C8A85F2048829"] )
	ServerIPText:setAlignment( Enum[@"hash_67A5123B654282D2"][@"hash_3F41D595A2B0EDF3"] )
	self:addElement( ServerIPText )
	self.ServerIPText = ServerIPText
	
	local HostedByText = LUI.UIText.new( 0.5, 0.5, -550, -1583, 0.5, 0.5, -353.5, -334.5 )
	HostedByText:setRGB( 0.59, 0.59, 0.59 )
	HostedByText:setScale( LanguageOverrideNumber( "japanese", 0.75, 1, 1 ) )
	HostedByText:setTTF( "ttmussels_regular" )
	HostedByText:setText("Hosted By")
	HostedByText:setAlignment( Enum[@"hash_67A5123B654282D2"][@"hash_558C8A85F2048829"] )
	HostedByText:setAlignment( Enum[@"hash_67A5123B654282D2"][@"hash_3F41D595A2B0EDF3"] )
	self:addElement( HostedByText )
	self.HostedByText = HostedByText
	
	local DetailsTextBox = LUI.UIText.new( 0.5, 0.5, 294, 514, 0.5, 0.5, -353.5, -334.5 )
	DetailsTextBox:setRGB( 0.59, 0.59, 0.59 )
	DetailsTextBox:setScale( LanguageOverrideNumber( "japanese", 0.75, 1, 1 ) )
	DetailsTextBox:setText("") -- not needed really..
	DetailsTextBox:setTTF( "ttmussels_regular" )
	DetailsTextBox:setAlpha(0)
	DetailsTextBox:setAlignment( Enum[@"hash_67A5123B654282D2"][@"hash_558C8A85F2048829"] )
	DetailsTextBox:setAlignment( Enum[@"hash_67A5123B654282D2"][@"hash_3F41D595A2B0EDF3"] )
	self:addElement( DetailsTextBox )
	self.DetailsTextBox = DetailsTextBox

	-- Custom IPV4 Edit
	local IPV4EditBox = CoD.Shield_NameEditBox.new( f1_arg0, f1_arg1, 0.5, 0.5, -20 - 770, 350 - 770, 0.75, 0.75, 100, 150 )
	IPV4EditBox:linkToElementModel( self, nil, false, function ( model )
		IPV4EditBox:setModel( model, f1_arg1 )
	end )
	IPV4EditBox.TextBox:setLeftRight(0, 0, 20 + 160, 320 + 160)
	IPV4EditBox.RankHighlight:setText("^2Set Custom Server IP: ")
	self:addElement( IPV4EditBox )
	self.IPV4EditBox = IPV4EditBox

	local IPV4EditBoxModel = Engine[@"getmodel"]( Engine[@"getmodelforcontroller"]( f1_arg1 ), "Shield_IPV4" )

	if IPV4EditBoxModel == nil then
		IPV4EditBoxModel = Engine[@"createmodel"]( Engine[@"getmodelforcontroller"]( f1_arg1 ), "Shield_IPV4" )
	end

	if IPV4EditBoxModel:get() == nil then
		IPV4EditBoxModel:set("")
	end

	IPV4EditBox.__editControlMaxChar = 16
	IPV4EditBox.__editControlisInteger = 1
	IPV4EditBox.__editControlMin = 0
	IPV4EditBox.__editControlMax = 1000

	--Engine[@"exec"](Engine[@"getprimarycontroller"](), "readjson shield_dw_ip demonware ipv4 string")
	--IPV4EditBoxModel:set(Engine[@"getdvarstring"]("shield_dw_ip"))

	CoD.PCUtility.SetupEditControlWithModel( IPV4EditBox, f1_arg1, f1_arg0, IPV4EditBoxModel, function ( f331_arg0, f331_arg1, f331_arg2 )
		if not f331_arg2.canceled and f331_arg2.name == "textbox_editdone" then
			local IPV4Data = f331_arg0:get()

			CoD.EnhPrintInfo("IP", IPV4Data)
			PlaySoundAlias( "uin_paint_image_flip_toggle" )
			
			if not CoD.IsIPAddress(IPV4Data) then
				f331_arg0:set("^1Invalid IP!")
				IPV4EditBox:addElement( LUI.UITimer.newElementTimer( 300, true, function ()
					f331_arg0:set("")
				end ) )
			else
				f331_arg0:set("^3IP Set!")
				IPV4EditBox:addElement( LUI.UITimer.newElementTimer( 300, true, function ()
					f331_arg0:set("")
				end ) )

				-- shield api here later..
				--Engine[@"exec"](Engine[@"getprimarycontroller"](), "writejson demonware ipv4 " .. IPV4Data .. " string")
				Engine[@"exec"](Engine[@"getprimarycontroller"](), "dw_ip " .. IPV4Data)
				Engine[@"exec"](Engine[@"getprimarycontroller"](), "dw_ip_browser " .. IPV4Data)
				Engine[@"exec"](Engine[@"getprimarycontroller"](), "chatip " .. IPV4Data)

				-- MIGHT ERROR!
				--CoD.OverlayUtility.CreateOverlay(f331_arg0, f331_arg1, "ShieldIPNotice")
			end
		else
			f331_arg0:set("") -- reset it
		end
	end )

	-- desc for ip
	local IPHint = LUI.UIText.new( 0.5, 0.5, -20 - 770, 850 - 770, 0.815, 0.815, 100, 120 )
	IPHint:setText("To apply IP change, Reconnect from main menu")
	IPHint:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )
	IPHint:setTTF("notosans_bold")
	IPHint:setBackingType( 2 )
	IPHint:setBackingColor( 0.04, 0.81, 1 )
	IPHint:setBackingAlpha( 0.01 )
	IPHint:setBackingXPadding( 12 )
	IPHint:setBackingYPadding( 6 )
	IPHint:setAlignment( Enum[@"luialignment"][@"lui_alignment_left"] )
	IPHint:setAlignment( Enum[@"luialignment"][@"lui_alignment_top"] )
	self:addElement( IPHint )
	self.IPHint = IPHint

	ShieldDWServerDetails.id = "ShieldDWServerDetails"
	IPV4EditBox.id = "IPV4EditBox"
	FETabBar.id = "FETabBar"

	LUI.OverrideFunction_CallOriginalSecond( self, "close", self.__onClose )
	
	if PostLoadFunc then
		PostLoadFunc( self, f1_arg1, f1_arg0 )
	end
	
	return self
end

CoD.Shield_SafeAreaContainer_ServerBrowserOverlay.__onClose = function ( f5_arg0 )
	f5_arg0.TabBacking:close()
	f5_arg0.CommonHeader:close()
	f5_arg0.FETabBar:close()
	f5_arg0.HeaderStripe:close()

	f5_arg0.ShieldDWServerDetails:close()

	f5_arg0.IPHint:close()
	f5_arg0.IPV4EditBox:close()
	f5_arg0.DetailsTextBox:close()
	f5_arg0.HostedByText:close()
	f5_arg0.ServerIPText:close()
	f5_arg0.PlayerCountText:close()
	f5_arg0.ServerNameText:close()
	f5_arg0.HeaderBackingL:close()
	f5_arg0.DWHint:close()
end

-- Shield's DW Server Lists
CoD.ShieldDWServerRowList = InheritFrom( LUI.UIElement )
CoD.ShieldDWServerRowList.__defaultWidth = 1600
CoD.ShieldDWServerRowList.__defaultHeight = 620
CoD.ShieldDWServerRowList.new = function ( f1_arg0, f1_arg1, f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	local self = LUI.UIElement.new( f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	self:setClass( CoD.ShieldDWServerRowList )
	self.id = "ShieldDWServerRowList"
	self.soundSet = "default"
	self.onlyChildrenFocusable = true
	self.anyChildUsesUpdateState = true

	local Servers = LUI.UIList.new( f1_arg0, f1_arg1, 7, 0, nil, false, false, false, false )
	Servers:setLeftRight( 0, 0, 0, 1070 )
	Servers:setTopBottom( 0, 0, 0, 609 )
	Servers:setWidgetType( CoD.ShieldServerRow )
	Servers:setVerticalCount( 14 )
	Servers:setSpacing( 7 )
	Servers:setAlignment( Enum[@"luialignment"][@"lui_alignment_left"] )
	Servers:setVerticalCounter( CoD.verticalCounter )
	Servers:setDataSource( "ShieldDWServers" ) -- Data Source
	Servers:appendEventHandler( "input_source_changed", function ( f2_arg0, f2_arg1 )
		f2_arg1.menu = f2_arg1.menu or f1_arg0
		CoD.Menu.UpdateButtonShownState( f2_arg0, f1_arg0, f1_arg1, Enum[@"luibutton"][@"lui_key_xba_pscross"] )
	end )

	--local f1_local2 = Servers
	--local LANServerBrowserDetails = Servers.subscribeToModel
	--local f1_local4 = Engine[@"getmodelforcontroller"]( f1_arg1 )
	--LANServerBrowserDetails( f1_local2, f1_local4.LastInput, function ( f3_arg0, f3_arg1 )
	--	CoD.Menu.UpdateButtonShownState( f3_arg1, f1_arg0, f1_arg1, Enum[@"luibutton"][@"lui_key_xba_pscross"] )
	--end, false )

	Servers:registerEventHandler( "list_item_gain_focus", function ( element, event )
		local f4_local0 = nil
		LobbyLANServerPlayerListRefresh( self, element, f1_arg1 )
		return f4_local0
	end )

	Servers:registerEventHandler( "gain_focus", function ( element, event )
		local f5_local0 = nil
		if element.gainFocus then
			f5_local0 = element:gainFocus( event )
		elseif element.super.gainFocus then
			f5_local0 = element.super:gainFocus( event )
		end
		CoD.Menu.UpdateButtonShownState( element, f1_arg0, f1_arg1, Enum[@"luibutton"][@"lui_key_xba_pscross"] )
		return f5_local0
	end )

	-- element is the current datasource being clicked..
	f1_arg0:AddButtonCallbackFunction( Servers, f1_arg1, Enum[@"luibutton"][@"lui_key_xba_pscross"], "ui_confirm", function ( element, menu, controller, model )
		if AlwaysTrue() then
			PlaySoundAlias("uin_toggle_generic")
			CoD.EnhPrintInfo("Server Connect", element.CurrentServerIP)
			--Engine[@"exec"](Engine[@"getprimarycontroller"](), "writejson demonware ipv4 " .. element.CurrentServerIP .. " string")
			-- DW main server, it will write json too for party
			Engine[@"exec"](Engine[@"getprimarycontroller"](), "dw_ip " .. element.CurrentServerIP)
			-- Server browser
			Engine[@"exec"](Engine[@"getprimarycontroller"](), "dw_ip_browser " .. element.CurrentServerIP)
			-- Chat
			Engine[@"exec"](Engine[@"getprimarycontroller"](), "chatip " .. element.CurrentServerIP)

			CoD.OverlayUtility.CreateOverlay(controller, menu, "ShieldIPNotice")
			--JoinSystemLinkServer( self, element, controller )
			--GoBack( self, controller )
			return true
		else
			
		end
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

	self:addElement( Servers )
	self.Servers = Servers
	
	--[[
	LANServerBrowserDetails = CoD.LANServerBrowserDetails.new( f1_arg0, f1_arg1, 0, 0, 1085, 1600, 0, 0, 0, 610 )
	self:addElement( LANServerBrowserDetails )
	self.LANServerBrowserDetails = LANServerBrowserDetails
	
	LANServerBrowserDetails:linkToElementModel( Servers, nil, false, function ( model )
		LANServerBrowserDetails:setModel( model, f1_arg1 )
	end )
	]]
	
	Servers.id = "Servers"

	--LANServerBrowserDetails.id = "LANServerBrowserDetails"
	LUI.OverrideFunction_CallOriginalSecond( self, "close", self.__onClose )
	
	if PostLoadFunc then
		PostLoadFunc( self, f1_arg1, f1_arg0 )
	end

	return self
end

CoD.ShieldDWServerRowList.__onClose = function ( f9_arg0 )
	--f9_arg0.LANServerBrowserDetails:close()
	f9_arg0.Servers:close()
end

-- Server Widget Style
CoD.ShieldServerRow = InheritFrom( LUI.UIElement )
CoD.ShieldServerRow.__defaultWidth = 1070
CoD.ShieldServerRow.__defaultHeight = 37
CoD.ShieldServerRow.new = function ( f1_arg0, f1_arg1, f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	local self = LUI.UIElement.new( f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	self:setClass( CoD.ShieldServerRow )
	self.id = "ShieldServerRow"
	self.soundSet = "default"
	f1_arg0:addElementToPendingUpdateStateList( self )
	
	local BlackBar = LUI.UIImage.new( 0, 1, 0, 0, 0, 1, 1, 1 )
	BlackBar:setRGB( 0.78, 0.78, 0.78 )
	BlackBar:setAlpha( 0.01 )
	self:addElement( BlackBar )
	self.BlackBar = BlackBar
	
	local HostedBy = LUI.UIText.new( 0, 0, 240, 1031, 0, 0, 6.5, 30.5 )
	HostedBy:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )
	HostedBy:setTTF( "ttmussels_regular" )
	HostedBy:setAlignment( Enum[@"hash_67A5123B654282D2"][@"hash_558C8A85F2048829"] )
	HostedBy:setAlignment( Enum[@"hash_67A5123B654282D2"][@"hash_3F41D595A2B0EDF3"] )
	self:addElement( HostedBy )
	self.HostedBy = HostedBy
	
	local ServerIP = LUI.UIText.new( 0, 0, 480, 824, 0, 0, 6.5, 30.5 )
	ServerIP:setRGB( 0.94, 0.94, 0.94 )
	ServerIP:setTTF( "ttmussels_regular" )
	ServerIP:setAlignment( Enum[@"hash_67A5123B654282D2"][@"hash_558C8A85F2048829"] )
	ServerIP:setAlignment( Enum[@"hash_67A5123B654282D2"][@"hash_3F41D595A2B0EDF3"] )
	self:addElement( ServerIP )
	self.ServerIP = ServerIP
	
	local ClientCount = LUI.UIText.new( 0, 0, 751 - 20, 1031 - 20, 0, 0, 6.5, 30.5 )
	ClientCount:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )
	ClientCount:setTTF( "0arame_mono_stencil" )
	ClientCount:setAlignment( Enum[@"hash_67A5123B654282D2"][@"hash_558C8A85F2048829"] )
	ClientCount:setAlignment( Enum[@"hash_67A5123B654282D2"][@"hash_3F41D595A2B0EDF3"] )
	self:addElement( ClientCount )
	self.ClientCount = ClientCount
	
	local ServerName = LUI.UIText.new( 0, 0, 15, 413, 0, 0, 6.5, 30.5 )
	ServerName:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )
	ServerName:setTTF( "ttmussels_regular" )
	ServerName:setLetterSpacing( 1 )
	ServerName:setAlignment( Enum[@"hash_67A5123B654282D2"][@"hash_558C8A85F2048829"] )
	ServerName:setAlignment( Enum[@"hash_67A5123B654282D2"][@"hash_3F41D595A2B0EDF3"] )
	self:addElement( ServerName )
	self.ServerName = ServerName
	
	-- Link them to Get from DataSource!
	self.HostedBy:linkToElementModel( self, "HostedBy", true, function ( model )
		local f2_local0 = model:get()
		if f2_local0 ~= nil then
			HostedBy:setText(f2_local0)
		end
	end )

	self.ServerIP:linkToElementModel( self, "ConnectionIP", true, function ( model )
		local f3_local0 = model:get()
		if f3_local0 ~= nil then
			ServerIP:setText(f3_local0)
			self.CurrentServerIP = f3_local0
		end
	end )

	self.ClientCount:linkToElementModel( self, "ClientCount", true, function ( model )
		local f4_local0 = model:get()
		if f4_local0 ~= nil then
			ClientCount:setText( f4_local0 )
		end
	end )

	self.ServerName:linkToElementModel( self, "ServerName", true, function ( model )
		local f5_local0 = model:get()
		if f5_local0 ~= nil then
			ServerName:setText( f5_local0 )
		end
	end )

	--[[
	HostName.__String_Reference = function ( f5_arg0 )
		local f5_local0 = f5_arg0:get()
		if f5_local0 ~= nil then
			HostName:setText( PrependClanTagToHostname( self:getModel(), f5_local0 ) )
		end
	end
	
	self.HostName:linkToElementModel( self, "gamertag", true, HostName.__String_Reference )
	HostName.__String_Reference_FullPath = function ()
		local f6_local0 = self.HostName:getModel()
		if f6_local0 then
			f6_local0 = self.HostName:getModel()
			f6_local0 = f6_local0.gamertag
		end
		if f6_local0 then
			HostName.__String_Reference( f6_local0 )
		end
	end
	]]
	
	--HostName:linkToElementModel( self, "clantag", true, HostName.__String_Reference_FullPath )
	LUI.OverrideFunction_CallOriginalSecond( self, "close", self.__onClose )
	
	if PostLoadFunc then
		PostLoadFunc( self, f1_arg1, f1_arg0 )
	end
	
	return self
end

CoD.ShieldServerRow.__resetProperties = function ( f7_arg0 )
	f7_arg0.BlackBar:completeAnimation()
	f7_arg0.ServerName:completeAnimation()
	f7_arg0.ClientCount:completeAnimation()
	f7_arg0.ServerIP:completeAnimation()
	f7_arg0.HostedBy:completeAnimation()
	f7_arg0.BlackBar:setRGB( 0.78, 0.78, 0.78 )
	f7_arg0.BlackBar:setAlpha( 0.01 )
	f7_arg0.ServerName:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )
	f7_arg0.ServerName:setAlpha( 1 )
	f7_arg0.ClientCount:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )
	f7_arg0.ServerIP:setRGB( 0.94, 0.94, 0.94 )
	f7_arg0.HostedBy:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )
end

CoD.ShieldServerRow.__clipsPerState = {
	DefaultState = {
		DefaultClip = function ( f8_arg0, f8_arg1 )
			f8_arg0:__resetProperties()
			f8_arg0:setupElementClipCounter( 2 )
			f8_arg0.BlackBar:completeAnimation()
			f8_arg0.BlackBar:setRGB( 0.71, 0.71, 0.71 )
			f8_arg0.BlackBar:setAlpha( 0.01 )
			f8_arg0.clipFinished( f8_arg0.BlackBar )
			f8_arg0.ServerName:completeAnimation()
			f8_arg0.ServerName:setAlpha( 1 )
			f8_arg0.clipFinished( f8_arg0.ServerName )
		end,
		Focus = function ( f9_arg0, f9_arg1 )
			f9_arg0:__resetProperties()
			f9_arg0:setupElementClipCounter( 5 )
			f9_arg0.BlackBar:completeAnimation()
			f9_arg0.BlackBar:setRGB( 0.82, 0.82, 0.82 )
			f9_arg0.BlackBar:setAlpha( 0.05 )
			f9_arg0.clipFinished( f9_arg0.BlackBar )
			f9_arg0.HostedBy:completeAnimation()
			f9_arg0.HostedBy:setRGB( 0.86, 0.86, 0.86 )
			f9_arg0.clipFinished( f9_arg0.HostedBy )
			--f9_arg0.ServerIP:completeAnimation()
			--f9_arg0.ServerIP:setRGB( 0.94, 0.94, 0.94 )
			--f9_arg0.clipFinished( f9_arg0.ServerIP )
			f9_arg0.ClientCount:completeAnimation()
			f9_arg0.ClientCount:setRGB( 0.94, 0.94, 0.94 )
			f9_arg0.clipFinished( f9_arg0.ClientCount )
			f9_arg0.ServerName:completeAnimation()
			f9_arg0.ServerName:setRGB( 0.93, 0.93, 0 )
			f9_arg0.clipFinished( f9_arg0.ServerName )
		end
	}
}

CoD.ShieldServerRow.__onClose = function ( f10_arg0 )
	f10_arg0.HostedBy:close()
	f10_arg0.ServerIP:close()
	f10_arg0.ClientCount:close()
	f10_arg0.ServerName:close()
	f10_arg0.BlackBar:close()
end