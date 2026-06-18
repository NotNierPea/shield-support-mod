--[[
		.\hksc.exe ".\Lua\LobbyBrowser.Lua" -o "C:\Program Files (x86)\Call of Duty Black Ops 4\project-bo4\mods\T8ShieldSupport\Lua\LobbyBrowser.luac"
]]

---------------------------

CoD.ShieldInitLuaFile()

---------------------------

-- dvars
Engine[@"exec"](Engine[@"getprimarycontroller"](), "readjson shield_server_style lua server_style uint64_t 0")
Engine[@"exec"](Engine[@"getprimarycontroller"](), "set shield_filter_server " .. 0)
Engine[@"setdvar"]( "shield_search_server", "" )

---------------------------

CoD.Shield.ShowServerToast = function(event_name, event_table)
	-- Play a little sound
	Engine[@"playsound"]("uin_map_vote")

	-- Default values
	local message = event_name

	if type(event_table) == "table" and type(event_table.message) == "string" then
		message = event_table.message
	end

	-- debug
	CoD.EnhPrintInfo("Got Toast", message)

	-- show some toast
	CoD.OverlayUtility.ShowToast( "Invite", "Server", message, "ui_icon_startmenu_option_network" )
end

CoD.Shield.OnServerLobbyListReceived = function(event_name, event_table)
	CoD.EnhPrintInfo("got servers from C++ side")

	if CoD.Menu.ServerLobbyBrowser ~= nil then
		CoD.Menu.ServerLobbyBrowser:addElement( LUI.UITimer.newElementTimer( 5, true, function ()
			CoD.Menu.ServerLobbyBrowser:setDataSource( "ShieldDWGameServersEmpty" )
			CoD.Menu.ServerLobbyBrowser:updateDataSource()
			CoD.Menu.ServerLobbyBrowser:setDataSource( "ShieldDWGameServers" )
			CoD.Menu.ServerLobbyBrowser:updateDataSource()
			end)
		)
	end
end

local function OnServerSettingChanged ( f137_arg0, f137_arg1, f137_arg2, f137_arg3, f137_arg4 )
	local dvar_name = f137_arg3
	local dvar_val = Engine[@"getdvarint"]( dvar_name )
	local current_val = f137_arg1.value
	CoD.OptionsUtility.UpdateInfoModels( f137_arg1 )

	if current_val == dvar_val then
		return 
	else
		Engine[@"setdvar"]( dvar_name, current_val )
	end

	if dvar_name == "shield_server_style" then
		Engine[@"exec"](Engine[@"getprimarycontroller"](), "writejson lua server_style " .. current_val .. " uint64_t")
	end
end

---------------------------

-- empty to fix weird bug
DataSources.ShieldDWGameServersEmpty = DataSourceHelpers.ListSetup( "ShieldDWGameServersEmpty", function ( f3_arg0, f3_arg1 )
	local InfoServers = {

	}

	return InfoServers
end, true )

-- Shield's DW Game Server Data
DataSources.ShieldDWGameServers = DataSourceHelpers.ListSetup( "ShieldDWGameServers", function ( f3_arg0, f3_arg1 )
	local InfoServers = {

	}

	local ServerRoot = Engine[@"getmodel"]( Engine[@"getglobalmodel"](), "serverListRoot" )
	local ActiveServers = Engine[@"getdvarint"](@"shield_active_lobbies")

	if ServerRoot == nil or ActiveServers == nil or ActiveServers <= 0 then
		return InfoServers
	end

	for times_servers = 0, ActiveServers - 1, 1 do

		if Engine[@"getmodel"]( ServerRoot, "server" .. times_servers) ~= nil then

			local TryPlaylistID = Engine[@"getmodelvalue"](Engine[@"getmodel"]( ServerRoot, "server" .. times_servers .. ".playlist"))
			local TryGetMap = Engine[@"getmodelvalue"](Engine[@"getmodel"]( ServerRoot, "server" .. times_servers .. ".mapName"))
			local TryGetGameType = Engine[@"getmodelvalue"](Engine[@"getmodel"]( ServerRoot, "server" .. times_servers .. ".gameType"))
			local TryHostName = Engine[@"getmodelvalue"](Engine[@"getmodel"]( ServerRoot, "server" .. times_servers .. ".gamertag"))
			local TryClientCount = Engine[@"getmodelvalue"](Engine[@"getmodel"]( ServerRoot, "server" .. times_servers .. ".clientCount"))
			local TryLobbyID = Engine[@"getmodelvalue"](Engine[@"getmodel"]( ServerRoot, "server" .. times_servers .. ".xuid"))

			if TryHostName == "" then
				TryHostName = "None, nil?"
			end

			-- get some info here
			local PlaylistInfo = Engine[@"getplaylistinfobyid"](TryPlaylistID)
			local PlaylistName = ""
			local PlaylistInfoRotation = ""
			local PlaylistMode = 1
			local PlaylistIsWZShit = false

			if TryPlaylistID ~= 0 then
				PlaylistName = ToUpper(Engine[@"hash_4F9F1239CFD921FE"](PlaylistInfo.name))
				PlaylistMode = PlaylistInfo.mainMode
				PlaylistInfoRotation = ToUpper(CoD.GameTypeUtility.GetLocalizedGameTypeValue( Engine[@"hash_1F2CD89B3C345FD3"]( PlaylistInfo.rotationList[1].gametype ).gametype, "nameRef", "" ))
				TryClientCount = TryClientCount .. "/" .. PlaylistInfo.maxPlayers
			else
				-- probablyyyy its quick play playlist
				PlaylistName = ""
				PlaylistInfoRotation = ""
				PlaylistMode = 1
				TryClientCount = TryClientCount .. "/" .. 10

				if TryGetMap == "UNK_MAP0" then
					PlaylistIsWZShit = true
					PlaylistMode = 3
				end
			end

			if Engine[@"getdvarstring"]("shield_search_server") ~= "" then
				-- try search logic
				if 
				string.find( ToUpper(TryGetMap), ToUpper(Engine[@"getdvarstring"]("shield_search_server")) ) or 
				string.find( PlaylistName, ToUpper(Engine[@"getdvarstring"]("shield_search_server")) ) or 
				string.find( PlaylistInfoRotation, ToUpper(Engine[@"getdvarstring"]("shield_search_server")) ) or
				string.find( ToUpper(TryGetGameType), ToUpper(Engine[@"getdvarstring"]("shield_search_server") )) then

				table.insert( InfoServers, {
					models = {
						ServerName = TryPlaylistID,
						HostedBy = TryHostName,
						ClientCount = TryClientCount,
						ConnectionIP = Engine[@"uint64tostring"](TryLobbyID),
						MapStatus = TryGetMap,
						GameTypeStatus = TryGetGameType
					},
					properties = {

					}
				} )

				end
			else
				if Engine[@"getdvarint"](@"shield_filter_server") ~= 0 and PlaylistMode ~= Engine[@"getdvarint"](@"shield_filter_server") then
					
				else
					-- add anyway
					table.insert( InfoServers, {
						models = {
							ServerName = TryPlaylistID,
							HostedBy = TryHostName,
							ClientCount = TryClientCount,
							ConnectionIP = Engine[@"uint64tostring"](TryLobbyID),
							MapStatus = TryGetMap,
							GameTypeStatus = TryGetGameType
						},
						properties = {

						}
					} )
				end
			end
		end
	end

	return InfoServers
end, true )

-- Server Settings
DataSources.ShieldServerSettings = DataSourceHelpers.ListSetup( "ShieldServerSettings", function ( f138_arg0 )
	local Settings = {}

	table.insert( Settings, CoD.OptionsUtility.CreateDvarSettings( f138_arg0, @"shield/server_filter", @"menu/enabled", "shield_filter_server", "shield_filter_server", {
		{
			option = Engine[@"hash_4F9F1239CFD921FE"]( @"hash_146513144F1265BA" ),
			value = 0,
			default = true
		},
		{
			option = Engine[@"hash_4F9F1239CFD921FE"]( @"hash_555D96CC762EABDD" ),
			value = 1
		},
		{
			option = Engine[@"hash_4F9F1239CFD921FE"]( @"hash_5B06081B8B4567F2" ),
			value = 2
		},
		{
			option = Engine[@"hash_4F9F1239CFD921FE"]( @"hash_7A2DD20750465431" ),
			value = 3
		}
	}, nil, OnServerSettingChanged ) )

	table.insert( Settings, CoD.OptionsUtility.CreateDvarSettings( f138_arg0, @"shield/server_style", @"menu/enabled", "shield_server_style", "shield_server_style", {
		{
			option = Engine[@"hash_4F9F1239CFD921FE"]( @"shield/server_style_0" ),
			value = 0,
			default = true
		},
		{
			option = Engine[@"hash_4F9F1239CFD921FE"]( @"shield/server_style_1" ),
			value = 1
		}
	}, nil, OnServerSettingChanged ) )

	return Settings

end, nil, nil, function ( f139_arg0, f139_arg1, f139_arg2 )
	local f139_local0 = Engine[@"createmodel"]( Engine[@"getglobalmodel"](), "GametypeSettings.Update" )
	if f139_arg1.updateSubscription then
		f139_arg1:removeSubscription( f139_arg1.updateSubscription )
	end
	f139_arg1.updateSubscription = f139_arg1:subscribeToModel( f139_local0, function ()
		f139_arg1:updateDataSource()
	end, false )
end )

---------------------------

-- LAN Servers
CoD.ShieldLobbyServerBrowserOverlay = InheritFrom( CoD.Menu )
LUI.createMenu.ShieldLobbyServerBrowserOverlay = function ( f1_arg0, f1_arg1 )
	local self = CoD.Menu.NewForUIEditor( "ShieldLobbyServerBrowserOverlay", f1_arg0 )
	local f1_local1 = self
	
	self:setClass( CoD.ShieldLobbyServerBrowserOverlay )
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
	
	local SafeAreaContainerLobbyServerBrwoserOverlay = CoD.Shield_SafeAreaContainer_LobbyServerBrwoserOverlay.new( f1_local1, f1_arg0, 0, 0, 0, 1920, 0, 0, 0, 1080 )
	SafeAreaContainerLobbyServerBrwoserOverlay:registerEventHandler( "menu_loaded", function ( element, event )
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
	self:addElement( SafeAreaContainerLobbyServerBrwoserOverlay )
	self.SafeAreaContainerLobbyServerBrwoserOverlay = SafeAreaContainerLobbyServerBrwoserOverlay
	
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

	SafeAreaContainerLobbyServerBrwoserOverlay.id = "SafeAreaContainerLobbyServerBrwoserOverlay"

	self:processEvent( {
		name = "menu_loaded",
		controller = f1_arg0
	} )

	LUI.OverrideFunction_CallOriginalSecond( self, "close", self.__onClose )
	
	if PostLoadFunc then
		PostLoadFunc( self, f1_arg0 )
	end
	
	local f1_local19 = self

	CoD.EnhPrintInfo("Called", "Shield's Lobby Server Browser")

	SizeToSafeArea(SafeAreaContainerLobbyServerBrwoserOverlay, f1_arg0)

	return self
end

CoD.ShieldLobbyServerBrowserOverlay.__onClose = function ( f8_arg0 )
	f8_arg0.Background:close()
	f8_arg0.FooterContainerFrontendRight:close()
	--f8_arg0.FooterContainerFrontendRight2:close()
	f8_arg0.SafeAreaContainerLobbyServerBrwoserOverlay:close()
	--f8_arg0.ShieldServerListButtonList:close()
end

-- Shield's In-game DW Server Lists
CoD.ShieldDWGameServerRowList = InheritFrom( LUI.UIElement )
CoD.ShieldDWGameServerRowList.__defaultWidth = 1600
CoD.ShieldDWGameServerRowList.__defaultHeight = 620
CoD.ShieldDWGameServerRowList.new = function ( f1_arg0, f1_arg1, f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	local self = LUI.UIElement.new( f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	self:setClass( CoD.ShieldDWGameServerRowList )
	self.id = "ShieldDWGameServerRowList"
	self.soundSet = "default"
	self.onlyChildrenFocusable = true
	self.anyChildUsesUpdateState = true
	
	local Servers = LUI.UIList.new( f1_arg0, f1_arg1, 7, 0, nil, false, false, false, false )
	Servers:setLeftRight( 0, 0, 0, 1070 )
	Servers:setTopBottom( 0, 0, 0, 609 )

	-- fix weird bug
	Servers:setDataSource( "ShieldDWGameServersEmpty" )

	if Engine[@"getdvarint"](@"shield_server_style") == 0 then
		Servers:setWidgetType( CoD.ShieldGameServerRow )
		Servers:setVerticalCount( 9 )
		Servers:setSpacing( 7 )
	else
		-- use other style ig
		Servers:setWidgetType( CoD.ShieldGameServerRow_PDAlt )
		Servers:setVerticalCount( 2 )
		Servers:setSpacing( 20 )	
	end

	Servers:setAlignment( Enum[@"luialignment"][@"lui_alignment_left"] )
	Servers:setVerticalCounter( CoD.verticalCounter )
	Servers:appendEventHandler( "input_source_changed", function ( f2_arg0, f2_arg1 )
		f2_arg1.menu = f2_arg1.menu or f1_arg0
		CoD.Menu.UpdateButtonShownState( f2_arg0, f1_arg0, f1_arg1, Enum[@"luibutton"][@"lui_key_xba_pscross"] )
	end )

	CoD.Menu.ServerLobbyBrowser = Servers

	CoD.ShowServerToast("Refreshing Servers...")
	Engine[@"exec"](Engine[@"getprimarycontroller"](), "getservers")

	local ShieldFilterGamemode = LUI.UIList.new( f1_arg0, f1_arg1, 3, 3, nil, false, false, false, false )

	if Engine[@"getdvarint"]("shield_ui_color") == 0 then
		ShieldFilterGamemode:setRGB(0, 1, 1)
	elseif Engine[@"getdvarint"]("shield_ui_color") == 1 then
		ShieldFilterGamemode:setRGB(1, 0, 0)
	elseif Engine[@"getdvarint"]("shield_ui_color") == 2 then
		ShieldFilterGamemode:setRGB(0, 1, 0)
	end

	ShieldFilterGamemode:setLeftRight( 0.5, 0.5, 10 + 200, 700 + 200 )
	ShieldFilterGamemode:setTopBottom( 0.5, 0.5, 0 + 60, 50 + 60 )
	ShieldFilterGamemode:setVerticalCount(2)
	ShieldFilterGamemode:setHorizontalCount(1)
	ShieldFilterGamemode:setSpacing(15)
	ShieldFilterGamemode:setScale(0.90, 0.90)
	ShieldFilterGamemode:setWidgetType( CoD.CustomGames_SettingSliderNoCustom )
	ShieldFilterGamemode:setAlignment( Enum[@"luialignment"][@"lui_alignment_left"] )
	ShieldFilterGamemode:setDataSource( "ShieldServerSettings" )
	self:addElement( ShieldFilterGamemode )
	self.ShieldFilterGamemode = ShieldFilterGamemode

	ShieldFilterGamemode.id = "ShieldFilterGamemode"

	ShieldFilterGamemode:registerEventHandler( "grid_item_changed", function ( element, event )
		local f19_local0 = nil
		Servers:setDataSource( "ShieldDWGameServersEmpty" )
		Servers:updateDataSource()
		Servers:setDataSource( "ShieldDWGameServers" )
		Servers:updateDataSource()
		return f19_local0
	end )

	-- Search
	local SearchServer = CoD.Shield_NameEditBox.new( f1_arg0, f1_arg1, 0.5, 0.5, 0 + 350, 370 + 350, 0.5, 0.5, 0 - 40, 50 - 40 )
	SearchServer:linkToElementModel( self, nil, false, function ( model )
		SearchServer:setModel( model, f1_arg1 )
	end )
	SearchServer.TextBox:setLeftRight(0, 0, 20 + 140, 320 + 140)
	SearchServer.RankHighlight:setText("^2Search for a Server: ")
	self:addElement( SearchServer )
	self.SearchServer = SearchServer

	local SearchServerModel = Engine[@"getmodel"]( Engine[@"getmodelforcontroller"]( f1_arg1 ), "Shield_Search_Server" )

	if SearchServerModel == nil then
		SearchServerModel = Engine[@"createmodel"]( Engine[@"getmodelforcontroller"]( f1_arg1 ), "Shield_Search_Server" )
	end

	if SearchServerModel:get() == nil then
		SearchServerModel:set("")
	end

	SearchServer.__editControlMaxChar = 16
	SearchServer.__editControlisInteger = 1
	SearchServer.__editControlMin = 0
	SearchServer.__editControlMax = 1000

	CoD.PCUtility.SetupEditControlWithModel( SearchServer, f1_arg1, f1_arg0, SearchServerModel, function ( f331_arg0, f331_arg1, f331_arg2 )
		if not f331_arg2.canceled and f331_arg2.name == "textbox_editdone" then
			local ServerData = f331_arg0:get()

			CoD.EnhPrintInfo("Server Search", ServerData)
			PlaySoundAlias( "uin_paint_image_flip_toggle" )

			Engine[@"setdvar"]( "shield_search_server", ServerData )
		else
			f331_arg0:set("") -- reset it
			Engine[@"setdvar"]( "shield_search_server", "" )
		end

		Servers:setDataSource( "ShieldDWGameServersEmpty" )
		Servers:updateDataSource()
		Servers:setDataSource( "ShieldDWGameServers" )
		Servers:updateDataSource()
	end )

	SearchServer.id = "SearchServer"

	local Mainframe = CoD.StartMenuOptionsMainFrame.new( f1_arg0, f1_arg1, 0, 0, 0 + 1080 - 3, 515 + 1230 + 3, 0, 0, 0 - 50 - 3, 292 - 50 + 3 )
	Mainframe:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )
	Mainframe:setAlpha( 0.05 )
	self:addElement( Mainframe )
	self.Mainframe = Mainframe

	local MapImage = LUI.UIImage.new( 0, 0, 0 + 1080, 515 + 1230, 0, 0, 0 - 50, 292 - 50 )
	MapImage:setImage( RegisterImage( @"uie_ui_menu_emblem_grid" ) )
	MapImage:setMaterial( LUI.UIImage.GetCachedMaterial( @"hash_1A02C44161370F6D" ) )
	MapImage:setShaderVector( 0, 0, 0, 0, 0 )
	MapImage:setShaderVector( 1, 1, 1, 0, 0 )
	MapImage:setShaderVector( 2, 0, 0, 0, 0 )
	self:addElement( MapImage )
	self.MapImage = MapImage
	
	local MapBackImage = LUI.UIImage.new( 0, 0, 0 + 1080, 515 + 1230, 0, 0, 218 - 50, 293 - 50 )
	MapBackImage:setRGB( 0, 0, 0 )
	MapBackImage:setAlpha( 0.6 )
	self:addElement( MapBackImage )
	self.MapBackImage = MapBackImage

	local ServerTextStuff = LUI.UIText.new( 0.5, 0.5, 320, 900, 0.5, 0.5, 0 - 66.5 - 50, 30 - 66.5 - 50 )
	ServerTextStuff:setRGB( 1, 1, 0 )
	ServerTextStuff:setTTF("notosans_bold")
	ServerTextStuff:setBackingType( 2 )
	ServerTextStuff:setBackingColor( 0.04, 0.81, 1 )
	ServerTextStuff:setBackingAlpha( 0.025 )
	ServerTextStuff:setBackingXPadding( 12 )
	ServerTextStuff:setBackingYPadding( 6 )
	ServerTextStuff:setAlignment( Enum[@"luialignment"][@"lui_alignment_left"] )
	ServerTextStuff:setAlignment( Enum[@"luialignment"][@"lui_alignment_top"] )
	self:addElement( ServerTextStuff )
	self.ServerTextStuff = ServerTextStuff

	--[[
	local f1_local2 = Servers
	local LANServerBrowserDetails = Servers.subscribeToModel
	local f1_local4 = Engine[@"getmodelforcontroller"]( f1_arg1 )
	LANServerBrowserDetails( f1_local2, f1_local4.LastInput, function ( f3_arg0, f3_arg1 )
		CoD.Menu.UpdateButtonShownState( f3_arg1, f1_arg0, f1_arg1, Enum[@"luibutton"][@"lui_key_xba_pscross"] )
	end, false )
	]]

	Servers:registerEventHandler( "list_item_gain_focus", function ( element, event )
		-- ????
		local f4_local0 = nil
		--LobbyLANServerPlayerListRefresh( self, element, f1_arg1 )
		--CoD.EnhPrintInfo(element.CurrentMapImage)


		if element.CurrentMapImage ~= nil then
			MapImage:setImage( RegisterImage( element.CurrentMapImage ) )
		else
			-- arena, hopefully
			MapImage:setImage( RegisterImage( @"uie_ui_menu_survey_arena" ) )
		end

		if element.CurrentGameTypeTranslated ~= "" then
			ServerTextStuff:setText(element.HostedUser .. " - " .. element.CurrentMapTranslated .. " - " .. element.CurrentGameTypeTranslated)
		else
			ServerTextStuff:setText(element.HostedUser .. " - " .. element.CurrentMapTranslated)
		end

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
		if IsGamepad( controller ) then
			PlaySoundAlias("uin_toggle_generic")
			CoD.EnhPrintInfo("Server Game Connect", element.CurrentLobbyID)
			CoD.ShowServerToast("Joining to Lobby " .. element.CurrentLobbyID .. "...")
			Engine[@"exec"](Engine[@"getprimarycontroller"](), "joinserver " .. element.CurrentLobbyID)

			--JoinSystemLinkServer( self, element, controller )
			--GoBack( self, controller )
			return true
		elseif IsMouseOrKeyboard( controller ) then
			PlaySoundAlias("uin_toggle_generic")
			CoD.EnhPrintInfo("Server Game Connect",  element.CurrentLobbyID)
			CoD.ShowServerToast("Joining to Lobby " .. element.CurrentLobbyID .. "...")
			Engine[@"exec"](Engine[@"getprimarycontroller"](), "joinserver " .. element.CurrentLobbyID)

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

	-- no need
	if Engine[@"getdvarint"](@"shield_server_style") == 1 then
		ServerTextStuff:setAlpha(0)
		MapBackImage:setAlpha(0)
		Mainframe:setAlpha(0)
		MapImage:setAlpha(0)
	end
	
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

CoD.ShieldDWGameServerRowList.__onClose = function ( f9_arg0 )
	--f9_arg0.LANServerBrowserDetails:close()
	f9_arg0.Mainframe:close()
	f9_arg0.SearchServer:close()
	f9_arg0.ShieldFilterGamemode:close()
	f9_arg0.ServerTextStuff:close()
	f9_arg0.MapImage:close()
	f9_arg0.MapBackImage:close()
	f9_arg0.Servers:close()
end

-- Server Widget Style
CoD.ShieldGameServerRow = InheritFrom( LUI.UIElement )
CoD.ShieldGameServerRow.__defaultWidth = 1070
CoD.ShieldGameServerRow.__defaultHeight = 37
CoD.ShieldGameServerRow.new = function ( f1_arg0, f1_arg1, f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	local self = LUI.UIElement.new( f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	self:setClass( CoD.ShieldGameServerRow )
	self.id = "ShieldGameServerRow"
	self.soundSet = "default"
	f1_arg0:addElementToPendingUpdateStateList( self )
	
	local BlackBar = LUI.UIImage.new( 0, 1, 0, 0, 0, 1, 1, 1 )
	BlackBar:setRGB( 0.78, 0.78, 0.78 )
	BlackBar:setAlpha( 0.01 )
	self:addElement( BlackBar )
	self.BlackBar = BlackBar
	
	local HostedBy = LUI.UIText.new( 0, 0, 240 + 310, 1031 + 310, 0, 0, 6.5, 30.5 )
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
	
	local ClientCount = LUI.UIText.new( 0, 0, 751 - 15, 1031 - 15, 0, 0, 6.5, 30.5 )
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
			self.HostedUser = f2_local0
		end
	end )

	self.ServerIP:linkToElementModel( self, "ConnectionIP", true, function ( model )
		local f3_local0 = model:get()
		if f3_local0 ~= nil then
			--ServerIP:setText(f3_local0)
			self.CurrentLobbyID = f3_local0
		end
	end )

	self.ClientCount:linkToElementModel( self, "ClientCount", true, function ( model )
		local f4_local0 = model:get()
		if f4_local0 ~= nil then
			ClientCount:setText( f4_local0 )
		end
	end )

	-- whole logic is here
	self.ServerName:linkToElementModel( self, "ServerName", true, function ( model )
		local f5_local0 = model:get()
		if f5_local0 ~= nil then
			self.CurrentPlaylistID = f5_local0

			self.CurrentMapTranslatedForMPWZ = CoD.ModelUtility.GetSelfModelPathValue(self, "MapStatus")
			self.CurrentGameTypeTranslatedForMPWZ = CoD.GameTypeUtility.GetLocalizedGameTypeValue( CoD.ModelUtility.GetSelfModelPathValue(self, "GameTypeStatus"), "nameRef", "" )

			-- fuck, prob quickplay in mp
			if self.CurrentPlaylistID == 0 then
				self.CurrentMapTranslated = 'Quick Play'
				self.CurrentGameTypeTranslated = ""
				self.CurrentMapImage = @"ui_icon_director_quickplay_large"

				-- for mp/wz if quickplay option
				if self.CurrentMapTranslatedForMPWZ ~= "UNK_MAP0" then
					self.CurrentGameTypeTranslated = self.CurrentGameTypeTranslatedForMPWZ
					self.CurrentMapTranslated = CoD.MapUtility.GetLocalizedMapValue( self.CurrentMapTranslatedForMPWZ, "mapName", "" )
					self.CurrentMapImage = MapNameToMapImage(self.CurrentMapTranslatedForMPWZ)

					ServerName:setText("[MP] " .. self.CurrentMapTranslated .. " - " .. self.CurrentGameTypeTranslated)
					return
				end

				ServerName:setText("[WZ] " .. self.CurrentMapTranslated)
				return
			end
			
			local PlaylistInfo = Engine[@"getplaylistinfobyid"](self.CurrentPlaylistID)
			local PlaylistInfoRotation = Engine[@"hash_1F2CD89B3C345FD3"]( PlaylistInfo.rotationList[1].gametype )

			local GameModeString = "??"

			if PlaylistInfo.mainMode == 1 then
				GameModeString = "MP"
			elseif PlaylistInfo.mainMode == 2 then
				GameModeString = "ZM"
			elseif PlaylistInfo.mainMode == 3 then
				GameModeString = "WZ"
			end

			self.CurrentGameModeTranslated = "[" .. GameModeString .. "] "
			self.CurrentMapTranslated = Engine[@"hash_4F9F1239CFD921FE"](PlaylistInfo.name)
			self.CurrentGameTypeTranslated = CoD.GameTypeUtility.GetLocalizedGameTypeValue( PlaylistInfoRotation.gametype, "nameRef", "" )

			self.CurrentMapImage = PlaylistInfo.imageTileSideInfo

			if not self.CurrentMapImage then
				self.CurrentMapImage = PlaylistInfo.imageBackground or @"blacktransparent"
			end

			self.CurrentSessionMode = GameModeString

			if string.len(self.CurrentGameTypeTranslated) < 3 or self.CurrentMapTranslated == self.CurrentGameTypeTranslated or self.CurrentSessionMode == "WZ" then
				-- try another way
				self.CurrentGameTypeTranslated = ""
			end

			-- for mp/wz
			if self.CurrentMapTranslatedForMPWZ ~= "UNK_MAP0" then

				if self.CurrentGameTypeTranslated == "" then
					self.CurrentGameTypeTranslated = self.CurrentGameTypeTranslatedForMPWZ
				end

				self.CurrentMapTranslated = CoD.MapUtility.GetLocalizedMapValue( self.CurrentMapTranslatedForMPWZ, "mapName", "" )
				self.CurrentMapImage = MapNameToMapImage(self.CurrentMapTranslatedForMPWZ)
			end

			if self.CurrentGameTypeTranslated ~= "" then
				ServerName:setText(self.CurrentGameModeTranslated .. self.CurrentMapTranslated .. " - " .. self.CurrentGameTypeTranslated)
			else
				ServerName:setText(self.CurrentGameModeTranslated .. self.CurrentMapTranslated)
			end

			-- lets see if someone notices this
			if self.CurrentPlaylistID == 409 then
				self.CurrentMapTranslated = "[ZM] An Icy Day in Fucking Hell"
				ServerName:setText(self.CurrentMapTranslated)
			end
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

CoD.ShieldGameServerRow.__resetProperties = function ( f7_arg0 )
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

CoD.ShieldGameServerRow.__clipsPerState = {
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

CoD.ShieldGameServerRow.__onClose = function ( f10_arg0 )
	f10_arg0.HostedBy:close()
	f10_arg0.ServerIP:close()
	f10_arg0.ClientCount:close()
	f10_arg0.ServerName:close()
	f10_arg0.BlackBar:close()
end

-- Server Alt Widget Style
CoD.ShieldGameServerRow_PDAlt = InheritFrom( LUI.UIElement )
CoD.ShieldGameServerRow_PDAlt.__defaultWidth = 1070
CoD.ShieldGameServerRow_PDAlt.__defaultHeight = 185
CoD.ShieldGameServerRow_PDAlt.new = function ( f1_arg0, f1_arg1, f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	local self = LUI.UIElement.new( f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	self:setClass( CoD.ShieldGameServerRow_PDAlt )
	self.id = "ShieldGameServerRow_PDAlt"
	self.soundSet = "default"
	f1_arg0:addElementToPendingUpdateStateList( self )
	
	local Mainframe = CoD.StartMenuOptionsMainFrame.new( f1_arg0, f1_arg1, 0, 0, 15 - 3, 413 + 640 + 3, 0, 0, 6.5 - 3, 30.5 + 200 + 3 - 47)
	Mainframe:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )
	Mainframe:setAlpha( 0.05 )
	self:addElement( Mainframe )
	self.Mainframe = Mainframe

	local MapImage = LUI.UIImage.new( 0, 0, 15, 413 + 640, 0, 0, 6.5, 30.5 + 200 - 47 )
	MapImage:setImage( RegisterImage( @"uie_ui_menu_emblem_grid" ) )
	MapImage:setMaterial( LUI.UIImage.GetCachedMaterial( @"hash_1A02C44161370F6D" ) )
	MapImage:setShaderVector( 0, 0, 0, 0, 0 )
	MapImage:setShaderVector( 1, 1, 1, 0, 0 )
	MapImage:setShaderVector( 2, 0, 0, 0, 0 )
	self:addElement( MapImage )
	self.MapImage = MapImage
	
	local MapBackImage = LUI.UIImage.new( 0, 0, 15, 413 + 640, 0, 0, 6.5, 30.5 + 200 - 47 )
	MapBackImage:setRGB( 0, 0, 0 )
	MapBackImage:setAlpha( 0.6 )
	self:addElement( MapBackImage )
	self.MapBackImage = MapBackImage
	
	local BlackBar = LUI.UIImage.new( 0, 1, 0, 0, 0, 1, 1 - 6.5, 1 - 6.5 - 47 )
	BlackBar:setRGB( 0.78, 0.78, 0.78 )
	BlackBar:setAlpha( 0 )
	self:addElement( BlackBar )
	self.BlackBar = BlackBar
	
	local HostedBy = LUI.UIText.new( 0, 0, 240 + 310, 1031 + 310, 0, 0, 6.5 + 180 - 47, 30.5 + 180 - 47 )
	HostedBy:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )
	HostedBy:setTTF( "notosans_bold" )
	HostedBy:setAlignment( Enum[@"hash_67A5123B654282D2"][@"hash_558C8A85F2048829"] )
	HostedBy:setAlignment( Enum[@"hash_67A5123B654282D2"][@"hash_3F41D595A2B0EDF3"] )
	HostedBy:setBackingType( 2 )
	HostedBy:setBackingColor( 0.04, 0.81, 1 )
	HostedBy:setBackingAlpha( 0.025 )
	HostedBy:setBackingXPadding( 12 )
	HostedBy:setBackingYPadding( 6 )
	self:addElement( HostedBy )
	self.HostedBy = HostedBy
	
	local ServerIP = LUI.UIText.new( 0, 0, 480, 824, 0, 0, 6.5 + 180 - 47, 30.5 + 180 - 47 )
	ServerIP:setRGB( 0.94, 0.94, 0.94 )
	ServerIP:setTTF( "notosans_bold" )
	ServerIP:setAlignment( Enum[@"hash_67A5123B654282D2"][@"hash_558C8A85F2048829"] )
	ServerIP:setAlignment( Enum[@"hash_67A5123B654282D2"][@"hash_3F41D595A2B0EDF3"] )
	ServerIP:setBackingType( 2 )
	ServerIP:setBackingColor( 0.04, 0.81, 1 )
	ServerIP:setBackingAlpha( 0.025 )
	ServerIP:setBackingXPadding( 12 )
	ServerIP:setBackingYPadding( 6 )
	self:addElement( ServerIP )
	self.ServerIP = ServerIP
	
	local ClientCount = LUI.UIText.new( 0, 0, 751 - 15, 1031 - 15, 0, 0, 6.5 + 180 - 47, 30.5 + 180 - 47 )
	ClientCount:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )
	ClientCount:setTTF( "0arame_mono_stencil" )
	ClientCount:setAlignment( Enum[@"hash_67A5123B654282D2"][@"hash_558C8A85F2048829"] )
	ClientCount:setAlignment( Enum[@"hash_67A5123B654282D2"][@"hash_3F41D595A2B0EDF3"] )
	ClientCount:setBackingType( 2 )
	ClientCount:setBackingColor( 0.04, 0.81, 1 )
	ClientCount:setBackingAlpha( 0.025 )
	ClientCount:setBackingXPadding( 12 )
	ClientCount:setBackingYPadding( 6 )
	self:addElement( ClientCount )
	self.ClientCount = ClientCount
	
	local ServerName = LUI.UIText.new( 0, 0, 15 + 20, 413 + 20, 0, 0, 6.5 + 180 - 47, 30.5 + 180 - 47 )
	ServerName:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )
	ServerName:setTTF( "notosans_bold" )
	ServerName:setLetterSpacing( 1 )
	ServerName:setAlignment( Enum[@"hash_67A5123B654282D2"][@"hash_558C8A85F2048829"] )
	ServerName:setAlignment( Enum[@"hash_67A5123B654282D2"][@"hash_3F41D595A2B0EDF3"] )
	ServerName:setBackingType( 2 )
	ServerName:setBackingColor( 0.04, 0.81, 1 )
	ServerName:setBackingAlpha( 0.025 )
	ServerName:setBackingXPadding( 12 )
	ServerName:setBackingYPadding( 6 )
	self:addElement( ServerName )
	self.ServerName = ServerName

	-- Link them to Get from DataSource!
	self.HostedBy:linkToElementModel( self, "HostedBy", true, function ( model )
		local f2_local0 = model:get()
		if f2_local0 ~= nil then
			HostedBy:setText(f2_local0)
			self.HostedUser = f2_local0
		end
	end )

	self.ServerIP:linkToElementModel( self, "ConnectionIP", true, function ( model )
		local f3_local0 = model:get()
		if f3_local0 ~= nil then
			--ServerIP:setText(f3_local0)
			self.CurrentLobbyID = f3_local0
		end
	end )

	self.ClientCount:linkToElementModel( self, "ClientCount", true, function ( model )
		local f4_local0 = model:get()
		if f4_local0 ~= nil then
			ClientCount:setText( "[ " .. f4_local0 .. " ]" )
		end
	end )

	-- whole logic is here
	self.ServerName:linkToElementModel( self, "ServerName", true, function ( model )
		local f5_local0 = model:get()
		if f5_local0 ~= nil then
			self.CurrentPlaylistID = f5_local0

			self.CurrentMapTranslatedForMPWZ = CoD.ModelUtility.GetSelfModelPathValue(self, "MapStatus")
			self.CurrentGameTypeTranslatedForMPWZ = CoD.ModelUtility.GetSelfModelPathValue(self, "GameTypeStatus")

			-- fuck, prob quickplay in mp
			if self.CurrentPlaylistID == 0 then
				self.CurrentMapTranslated = 'Quick Play'
				self.CurrentGameTypeTranslated = ""
				self.CurrentMapImage = @"ui_icon_director_quickplay_large"

				-- for mp/wz if quickplay option
				if self.CurrentMapTranslatedForMPWZ ~= "UNK_MAP0" then
					self.CurrentGameTypeTranslated = ToUpper(self.CurrentGameTypeTranslatedForMPWZ)
					self.CurrentMapTranslated = CoD.MapUtility.GetLocalizedMapValue( self.CurrentMapTranslatedForMPWZ, "mapName", "" )
					self.CurrentMapImage = MapNameToMapImage(self.CurrentMapTranslatedForMPWZ)

					MapImage:setImage(RegisterImage(self.CurrentMapImage))
					ServerName:setText("[MP] " .. self.CurrentMapTranslated .. " - " .. self.CurrentGameTypeTranslated)
					return
				end

				MapImage:setImage(RegisterImage(self.CurrentMapImage))
				ServerName:setText("[WZ] " .. self.CurrentMapTranslated)
				return
			end
			
			local PlaylistInfo = Engine[@"getplaylistinfobyid"](self.CurrentPlaylistID)
			local PlaylistInfoRotation = Engine[@"hash_1F2CD89B3C345FD3"]( PlaylistInfo.rotationList[1].gametype )

			local GameModeString = "??"

			if PlaylistInfo.mainMode == 1 then
				GameModeString = "MP"
			elseif PlaylistInfo.mainMode == 2 then
				GameModeString = "ZM"
			elseif PlaylistInfo.mainMode == 3 then
				GameModeString = "WZ"
			end

			self.CurrentGameModeTranslated = "[" .. GameModeString .. "] "
			self.CurrentMapTranslated = Engine[@"hash_4F9F1239CFD921FE"](PlaylistInfo.name)
			self.CurrentGameTypeTranslated = CoD.GameTypeUtility.GetLocalizedGameTypeValue( PlaylistInfoRotation.gametype, "nameRef", "" )

			self.CurrentMapImage = PlaylistInfo.imageTileSideInfo

			if not self.CurrentMapImage then
				self.CurrentMapImage = PlaylistInfo.imageBackground or @"blacktransparent"
			end

			self.CurrentSessionMode = GameModeString

			if string.len(self.CurrentGameTypeTranslated) < 3 or self.CurrentMapTranslated == self.CurrentGameTypeTranslated or self.CurrentSessionMode == "WZ" then
				-- try another way
				self.CurrentGameTypeTranslated = ""
			end

			-- for mp/wz
			if self.CurrentMapTranslatedForMPWZ ~= "UNK_MAP0" then

				if self.CurrentGameTypeTranslated == "" then
					self.CurrentGameTypeTranslated = ToUpper(self.CurrentGameTypeTranslatedForMPWZ)
				end

				self.CurrentMapTranslated = CoD.MapUtility.GetLocalizedMapValue( self.CurrentMapTranslatedForMPWZ, "mapName", "" )
				self.CurrentMapImage = MapNameToMapImage(self.CurrentMapTranslatedForMPWZ)
			end

			if self.CurrentGameTypeTranslated ~= "" then
				ServerName:setText(self.CurrentGameModeTranslated .. self.CurrentMapTranslated .. " - " .. self.CurrentGameTypeTranslated)
			else
				ServerName:setText(self.CurrentGameModeTranslated .. self.CurrentMapTranslated)
			end

			-- lets see if someone notices this
			if self.CurrentPlaylistID == 409 then
				self.CurrentMapTranslated = "[ZM] An Icy Day in Fucking Hell"
				ServerName:setText(self.CurrentMapTranslated)
			end

			MapImage:setImage(RegisterImage(self.CurrentMapImage))
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

CoD.ShieldGameServerRow_PDAlt.__resetProperties = function ( f7_arg0 )
	f7_arg0.BlackBar:completeAnimation()
	f7_arg0.ServerName:completeAnimation()
	f7_arg0.ClientCount:completeAnimation()
	f7_arg0.ServerIP:completeAnimation()
	f7_arg0.HostedBy:completeAnimation()
	f7_arg0.BlackBar:setRGB( 0.78, 0.78, 0.78 )
	f7_arg0.BlackBar:setAlpha( 0 )
	f7_arg0.ServerName:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )
	f7_arg0.ServerName:setAlpha( 1 )
	f7_arg0.ClientCount:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )
	f7_arg0.ServerIP:setRGB( 0.94, 0.94, 0.94 )
	f7_arg0.HostedBy:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )
	f7_arg0.Mainframe:completeAnimation()
	f7_arg0.Mainframe:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )
	f7_arg0.Mainframe:setAlpha( 0.05 )
end

CoD.ShieldGameServerRow_PDAlt.__clipsPerState = {
	DefaultState = {
		DefaultClip = function ( f8_arg0, f8_arg1 )
			f8_arg0:__resetProperties()
			f8_arg0:setupElementClipCounter( 2 )
			f8_arg0.BlackBar:completeAnimation()
			f8_arg0.BlackBar:setRGB( 0.71, 0.71, 0.71 )
			f8_arg0.BlackBar:setAlpha( 0 )
			f8_arg0.Mainframe:completeAnimation()
			f8_arg0.Mainframe:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )
			f8_arg0.Mainframe:setAlpha( 0.05 )
			f8_arg0.clipFinished( f8_arg0.BlackBar )
			f8_arg0.ServerName:completeAnimation()
			f8_arg0.ServerName:setAlpha( 1 )
			f8_arg0.clipFinished( f8_arg0.ServerName )
		end,
		Focus = function ( f9_arg0, f9_arg1 )
			f9_arg0:__resetProperties()
			f9_arg0:setupElementClipCounter( 5 )
			--f9_arg0.BlackBar:completeAnimation()
			--f9_arg0.BlackBar:setRGB( 0.82, 0.82, 0.82 )
			--f9_arg0.BlackBar:setAlpha( 0.05 )
			f9_arg0.Mainframe:completeAnimation()
			f9_arg0.Mainframe:setRGB( 0.93, 0.93, 0 )
			f9_arg0.Mainframe:setAlpha( 0.15 )
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

CoD.ShieldGameServerRow_PDAlt.__onClose = function ( f10_arg0 )
	f10_arg0.HostedBy:close()
	f10_arg0.ServerIP:close()
	f10_arg0.ClientCount:close()
	f10_arg0.ServerName:close()
	f10_arg0.BlackBar:close()
	f10_arg0.Mainframe:close()
	f10_arg0.MapBackImage:close()
	f10_arg0.MapImage:close()
end

-- Safe for Server
CoD.Shield_SafeAreaContainer_LobbyServerBrwoserOverlay = InheritFrom( LUI.UIElement )
CoD.Shield_SafeAreaContainer_LobbyServerBrwoserOverlay.__defaultWidth = 1920
CoD.Shield_SafeAreaContainer_LobbyServerBrwoserOverlay.__defaultHeight = 1080
CoD.Shield_SafeAreaContainer_LobbyServerBrwoserOverlay.new = function ( f1_arg0, f1_arg1, f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	local self = LUI.UIElement.new( f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	self:setClass( CoD.Shield_SafeAreaContainer_LobbyServerBrwoserOverlay )
	self.id = "Shield_SafeAreaContainer_LobbyServerBrwoserOverlay"
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

	local ShieldDWGameServerDetails = CoD.ShieldDWGameServerRowList.new( f1_arg0, f1_arg1, 0.5, 0.5, -800, 800, 0.20, 0.20, -310 + 325, 300 + 325 )
	self:addElement( ShieldDWGameServerDetails )
	self.ShieldDWGameServerDetails = ShieldDWGameServerDetails

	local RefreshServersButton = CoD.DirectorSelectButtonMiniInternal.new( f1_arg0, f1_arg1, 0.5, 0.5, 70 - 840, 370 - 840, 0.5, 0.5, 227.5 + 195, 277.5 + 195 )
	
	RefreshServersButton.MiddleText:setTTF( "notosans_bold" )
	RefreshServersButton.MiddleText:setText("Refresh Servers")

	RefreshServersButton.MiddleTextFocus:setText("Refresh Servers")
	RefreshServersButton.MiddleTextFocus:setTTF( "notosans_bold" )

	RefreshServersButton:mergeStateConditions( {
		{
			stateName = "Locked",
			condition = function ( menu, element, event )
				return AlwaysFalse()
			end
		}
	} )

	RefreshServersButton:linkToElementModel( self, nil, false, function ( model )
		RefreshServersButton:setModel( model, f1_arg1 )
	end )
	self:addElement( RefreshServersButton )
	self.RefreshServersButton = RefreshServersButton

	f1_arg0:AddButtonCallbackFunction( RefreshServersButton, f1_arg0, Enum[@"luibutton"][@"lui_key_xba_pscross"], "ui_confirm", function ( element, menu, controller, model )
		PlaySoundAlias( "uin_paint_image_flip_toggle" )
		CoD.EnhPrintInfo("RefreshServersButton")
		
		CoD.ShowServerToast("Refreshing Servers...")
		Engine[@"exec"](Engine[@"getprimarycontroller"](), "getservers")

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
	
	RefreshServersButton.id = "RefreshServersButton"

	local LobbyHeaderBackingL = LUI.UIImage.new( 0.5, 0.5, 160 - 975, 1229 - 975, 0.20, 0.20, 176 - 215, 216 - 215 )
	LobbyHeaderBackingL:setRGB( 0, 0, 0 )
	LobbyHeaderBackingL:setAlpha( 0.5 )
	self:addElement( LobbyHeaderBackingL )
	self.LobbyHeaderBackingL = LobbyHeaderBackingL

	-- desc for in-game servers
	local GameServersHint = LUI.UIText.new( 0.5, 0.5, -20 - 770, 850 - 770, 0.20, 0.20, 100 - 200, 140 - 200 )
	GameServersHint:setText("Lobbies")
	GameServersHint:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )
	GameServersHint:setTTF("notosans_bold")
	GameServersHint:setRGB(1, 1, 0)
	GameServersHint:setBackingType( 2 )
	GameServersHint:setBackingColor( 0.04, 0.81, 1 )
	GameServersHint:setBackingAlpha( 0.01 )
	GameServersHint:setBackingXPadding( 12 )
	GameServersHint:setBackingYPadding( 6 )
	GameServersHint:setAlignment( Enum[@"luialignment"][@"lui_alignment_left"] )
	GameServersHint:setAlignment( Enum[@"luialignment"][@"lui_alignment_top"] )
	self:addElement( GameServersHint )
	self.GameServersHint = GameServersHint

	-- descs for dw game servers
	local LobbyNameText = LUI.UIText.new( 0.5, 0.5, -783, -583, 0.20, 0.20, -353.5 + 325, -334.5 + 325 )
	LobbyNameText:setRGB( 0.59, 0.59, 0.59 )
	LobbyNameText:setScale( LanguageOverrideNumber( "japanese", 0.75, 1, 1 ) )
	LobbyNameText:setText("Lobby Name")
	LobbyNameText:setTTF( "ttmussels_regular" )
	LobbyNameText:setAlignment( Enum[@"hash_67A5123B654282D2"][@"hash_558C8A85F2048829"] )
	LobbyNameText:setAlignment( Enum[@"hash_67A5123B654282D2"][@"hash_3F41D595A2B0EDF3"] )
	self:addElement( LobbyNameText )
	self.LobbyNameText = LobbyNameText
	
	local LobbyPlayerCountText = LUI.UIText.new( 0.5, 0.5, -359 + 290, -188 + 290, 0.20, 0.20, -353.5 + 325, -334.5 + 325 )
	LobbyPlayerCountText:setRGB( 0.59, 0.59, 0.59 )
	LobbyPlayerCountText:setScale( LanguageOverrideNumber( "japanese", 0.75, 1, 1 ) )
	LobbyPlayerCountText:setText("Players")
	LobbyPlayerCountText:setTTF( "ttmussels_regular" )
	LobbyPlayerCountText:setLetterSpacing( 1 )
	LobbyPlayerCountText:setAlignment( Enum[@"hash_67A5123B654282D2"][@"hash_558C8A85F2048829"] )
	LobbyPlayerCountText:setAlignment( Enum[@"hash_67A5123B654282D2"][@"hash_3F41D595A2B0EDF3"] )
	self:addElement( LobbyPlayerCountText )
	self.LobbyPlayerCountText = LobbyPlayerCountText
	
	local LobbyIPText = LUI.UIText.new( 0.5, 0.5, -300, -31, 0.20, 0.20, -353.5 + 325, -334.5 + 325 )
	LobbyIPText:setRGB( 0.59, 0.59, 0.59 )
	LobbyIPText:setScale( LanguageOverrideNumber( "japanese", 0.75, 1, 1 ) )
	--LobbyIPText:setText("Lobby ID")
	LobbyIPText:setTTF( "ttmussels_regular" )
	LobbyIPText:setAlignment( Enum[@"hash_67A5123B654282D2"][@"hash_558C8A85F2048829"] )
	LobbyIPText:setAlignment( Enum[@"hash_67A5123B654282D2"][@"hash_3F41D595A2B0EDF3"] )
	self:addElement( LobbyIPText )
	self.LobbyIPText = LobbyIPText
	
	local LobbyHostedByText = LUI.UIText.new( 0.5, 0.5, -550 + 300, -1583 + 300, 0.20, 0.20, -353.5 + 325, -334.5 + 325 )
	LobbyHostedByText:setRGB( 0.59, 0.59, 0.59 )
	LobbyHostedByText:setScale( LanguageOverrideNumber( "japanese", 0.75, 1, 1 ) )
	LobbyHostedByText:setTTF( "ttmussels_regular" )
	LobbyHostedByText:setText("Hosted By")
	LobbyHostedByText:setAlignment( Enum[@"hash_67A5123B654282D2"][@"hash_558C8A85F2048829"] )
	LobbyHostedByText:setAlignment( Enum[@"hash_67A5123B654282D2"][@"hash_3F41D595A2B0EDF3"] )
	self:addElement( LobbyHostedByText )
	self.LobbyHostedByText = LobbyHostedByText
	
	local LobbyDetailsTextBox = LUI.UIText.new( 0.5, 0.5, 294, 514, 0.20, 0.20, -353.5 + 325, -334.5 + 325 )
	LobbyDetailsTextBox:setRGB( 0.59, 0.59, 0.59 )
	LobbyDetailsTextBox:setScale( LanguageOverrideNumber( "japanese", 0.75, 1, 1 ) )
	LobbyDetailsTextBox:setText("") -- not needed really..
	LobbyDetailsTextBox:setTTF( "ttmussels_regular" )
	LobbyDetailsTextBox:setAlpha(0)
	LobbyDetailsTextBox:setAlignment( Enum[@"hash_67A5123B654282D2"][@"hash_558C8A85F2048829"] )
	LobbyDetailsTextBox:setAlignment( Enum[@"hash_67A5123B654282D2"][@"hash_3F41D595A2B0EDF3"] )
	self:addElement( LobbyDetailsTextBox )
	self.LobbyDetailsTextBox = LobbyDetailsTextBox

	ShieldDWGameServerDetails.id = "ShieldDWGameServerDetails"
	FETabBar.id = "FETabBar"

	LUI.OverrideFunction_CallOriginalSecond( self, "close", self.__onClose )
	
	if PostLoadFunc then
		PostLoadFunc( self, f1_arg1, f1_arg0 )
	end
	
	return self
end

CoD.Shield_SafeAreaContainer_LobbyServerBrwoserOverlay.__onClose = function ( f5_arg0 )
	f5_arg0.TabBacking:close()
	f5_arg0.CommonHeader:close()
	f5_arg0.FETabBar:close()
	f5_arg0.HeaderStripe:close()

	f5_arg0.ShieldDWGameServerDetails:close()

	--f5_arg0.HeaderPixelGridTiledBackingL:close()
	f5_arg0.GameServersHint:close()
	f5_arg0.LobbyNameText:close()
	f5_arg0.LobbyPlayerCountText:close()
	f5_arg0.LobbyIPText:close()
	f5_arg0.LobbyHostedByText:close()
	f5_arg0.LobbyDetailsTextBox:close()
	--f5_arg0.LobbyHeaderPixelGridTiledBackingL:close()
	f5_arg0.LobbyHeaderBackingL:close()
end