--[[
		.\hksc.exe ".\Lua\DirectorPregameArena.Lua" -o "C:\Program Files (x86)\Call of Duty Black Ops 4\project-bo4\mods\T8ShieldSupport\Lua\DirectorPregameArena.luac"
]]

---------------------------

CoD.ShieldInitLuaFile()

---------------------------

-- Arena lobby offline
CoD.directorArenaMatchmaking = InheritFrom( LUI.UIElement )
CoD.directorArenaMatchmaking.__defaultWidth = 1920
CoD.directorArenaMatchmaking.__defaultHeight = 1080
CoD.directorArenaMatchmaking.new = function ( f1_arg0, f1_arg1, f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	local self = LUI.UIElement.new( f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	CoD.DirectorUtility.InitPublicLobbyModels( self, f1_arg1, f1_arg0 )
	CoD.PlayerRoleUtility.UpdatePositionDraftModels( f1_arg1 )
	self:setClass( CoD.directorArenaMatchmaking )
	self.id = "directorArenaMatchmaking"
	self.soundSet = "none"
	self.onlyChildrenFocusable = true
	self.anyChildUsesUpdateState = true
	f1_arg0:addElementToPendingUpdateStateList( self )
	
	local StageNotificationContainer = CoD.StageNotificationContainer.new( f1_arg0, f1_arg1, 0, 1, 0, 0, 0, 0, 0, 120 )
	StageNotificationContainer:subscribeToGlobalModel( f1_arg1, "Arena", "arenaEventName", function ( model )
		local f2_local0 = model:get()
		if f2_local0 ~= nil then
			StageNotificationContainer.CommonHeader.subtitle.StageTitle:setText( ToUpper( f2_local0 ) )
		end
	end )
	StageNotificationContainer:subscribeToGlobalModel( f1_arg1, "LobbyRoot", "publicLobby.stageDetails", function ( model )
		local f3_local0 = model:get()
		if f3_local0 ~= nil then
			StageNotificationContainer.CommonHeader.subtitle.subtitle:setText( ConvertToUpperString( CoD.BaseUtility.AlreadyLocalized( f3_local0 ) ) )
		end
	end )
	self:addElement( StageNotificationContainer )
	self.StageNotificationContainer = StageNotificationContainer
	
	local TopBar = CoD.header_container_frontend.new( f1_arg0, f1_arg1, 0, 1, 0, 0, 0, 0, 0, 42 )
	self:addElement( TopBar )
	self.TopBar = TopBar
	
	local f1_local3 = nil
	f1_local3 = LUI.UIElement.createFake()
	self.MapVote = f1_local3
	local MapVotePC = nil
	
	MapVotePC = CoD.MapVote.new( f1_arg0, f1_arg1, 0.5, 0.5, -505, 406, 1, 1, -399, -184 )
	MapVotePC:mergeStateConditions( {
		{
			stateName = "MapVote",
			condition = function ( menu, element, event )
				return CoD.LobbyUtility.MapVoteInState( LuaEnum.MAP_VOTE_STATE.VOTING ) and AlwaysFalse()
			end
		},
		{
			stateName = "MapVoteChosenNext",
			condition = function ( menu, element, event )
				local f5_local0 = CoD.LobbyUtility.MapVoteInState( LuaEnum.MAP_VOTE_STATE.LOCKEDIN )
				if f5_local0 then
					f5_local0 = CoD.ModelUtility.IsGlobalModelValueEqualToEnum( "MapVote.lobbyMapVoteType", Enum[@"lobbymapvote"][@"lobby_mapvote_next"] )
					if f5_local0 then
						f5_local0 = AlwaysFalse()
					end
				end
				return f5_local0
			end
		},
		{
			stateName = "MapVoteChosenPrevious",
			condition = function ( menu, element, event )
				local f6_local0 = CoD.LobbyUtility.MapVoteInState( LuaEnum.MAP_VOTE_STATE.LOCKEDIN )
				if f6_local0 then
					f6_local0 = CoD.ModelUtility.IsGlobalModelValueEqualToEnum( "MapVote.lobbyMapVoteType", Enum[@"lobbymapvote"][@"lobby_mapvote_previous"] )
					if f6_local0 then
						f6_local0 = AlwaysFalse()
					end
				end
				return f6_local0
			end
		},
		{
			stateName = "MapVoteChosenRandom",
			condition = function ( menu, element, event )
				local f7_local0 = CoD.LobbyUtility.MapVoteInState( LuaEnum.MAP_VOTE_STATE.LOCKEDIN )
				if f7_local0 then
					f7_local0 = CoD.ModelUtility.IsGlobalModelValueEqualToEnum( "MapVote.lobbyMapVoteType", Enum[@"lobbymapvote"][@"lobby_mapvote_random"] )
					if f7_local0 then
						f7_local0 = AlwaysFalse()
					end
				end
				return f7_local0
			end
		},
		{
			stateName = "SelectedMap",
			condition = function ( menu, element, event )
				local f8_local0 = CoD.LobbyUtility.MapVoteInState( LuaEnum.MAP_VOTE_STATE.LOCKEDIN )
				if f8_local0 then
					f8_local0 = CoD.ArenaUtility.ArenaMatchSet( self )
					if f8_local0 then
						f8_local0 = IsArenaMode()
					end
				end
				return f8_local0
			end
		}
	} )
	local overheadNameContainer = MapVotePC
	local DirectorReadyButton = MapVotePC.subscribeToModel
	local DirectorPreGameButton = Engine[@"getglobalmodel"]()
	DirectorReadyButton( overheadNameContainer, DirectorPreGameButton["lobbyRoot.mapVote"], function ( f9_arg0 )
		f1_arg0:updateElementState( MapVotePC, {
			name = "model_validation",
			menu = f1_arg0,
			controller = f1_arg1,
			modelValue = f9_arg0:get(),
			modelName = "lobbyRoot.mapVote"
		} )
	end, false )
	overheadNameContainer = MapVotePC
	DirectorReadyButton = MapVotePC.subscribeToModel
	DirectorPreGameButton = Engine[@"getglobalmodel"]()
	DirectorReadyButton( overheadNameContainer, DirectorPreGameButton["lobbyRoot.lobbyNav"], function ( f10_arg0 )
		f1_arg0:updateElementState( MapVotePC, {
			name = "model_validation",
			menu = f1_arg0,
			controller = f1_arg1,
			modelValue = f10_arg0:get(),
			modelName = "lobbyRoot.lobbyNav"
		} )
	end, false )
	overheadNameContainer = MapVotePC
	DirectorReadyButton = MapVotePC.subscribeToModel
	DirectorPreGameButton = Engine[@"getglobalmodel"]()
	DirectorReadyButton( overheadNameContainer, DirectorPreGameButton["MapVote.lobbyMapVoteType"], function ( f11_arg0 )
		f1_arg0:updateElementState( MapVotePC, {
			name = "model_validation",
			menu = f1_arg0,
			controller = f1_arg1,
			modelValue = f11_arg0:get(),
			modelName = "MapVote.lobbyMapVoteType"
		} )
	end, false )
	overheadNameContainer = MapVotePC
	DirectorReadyButton = MapVotePC.subscribeToModel
	DirectorPreGameButton = Engine[@"getglobalmodel"]()
	DirectorReadyButton( overheadNameContainer, DirectorPreGameButton["lobbyRoot.publicLobby.stage"], function ( f12_arg0 )
		f1_arg0:updateElementState( MapVotePC, {
			name = "model_validation",
			menu = f1_arg0,
			controller = f1_arg1,
			modelValue = f12_arg0:get(),
			modelName = "lobbyRoot.publicLobby.stage"
		} )
	end, false )
	self:addElement( MapVotePC )
	self.MapVotePC = MapVotePC
	
	DirectorReadyButton = CoD.DirectorReadyButton.new( f1_arg0, f1_arg1, 0.5, 0.5, 470, 896, 1, 1, -188, -108 )
	DirectorReadyButton:setAlpha( 0 )
	DirectorReadyButton.DirectorSelectButtonMiniInternal.MiddleText:setText( LocalizeToUpperString( @"menu/ready_up" ) )
	DirectorReadyButton.DirectorSelectButtonMiniInternal.MiddleTextFocus:setText( LocalizeToUpperString( @"menu/ready_up" ) )
	DirectorReadyButton.PlayText:setText( LocalizeToUpperString( @"menu/ready" ) )
	DirectorReadyButton:subscribeToGlobalModel( f1_arg1, "PerController", "ButtonBits." .. Enum[@"luibutton"][@"lui_key_xba_pscross"], function ( model )
		DirectorReadyButton:setModel( model, f1_arg1 )
	end )
	self:addElement( DirectorReadyButton )
	self.DirectorReadyButton = DirectorReadyButton
	
	overheadNameContainer = CoD.DynamicContainerWidget.new( f1_arg0, f1_arg1, 0.5, 0.5, -960, 960, 0, 0, 0, 1080 )
	self:addElement( overheadNameContainer )
	self.overheadNameContainer = overheadNameContainer
	
	DirectorPreGameButton = CoD.DirectorPreGameButton.new( f1_arg0, f1_arg1, 0, 0, 536.5, 766.5, 1, 1, -178, -108 )
	DirectorPreGameButton:mergeStateConditions( {
		{
			stateName = "Hidden",
			condition = function ( menu, element, event )
				return not IsBooleanDvarSet( "loot_enableBlackMarket" )
			end
		}
	} )
	DirectorPreGameButton:setAlpha( 0 )
	DirectorPreGameButton.DirectorCustomStartButton.MiddleText:setText( LocalizeToUpperString( @"menu/black_market" ) )
	DirectorPreGameButton.DirectorCustomStartButton.MiddleTextFocus:setText( LocalizeToUpperString( @"menu/black_market" ) )
	DirectorPreGameButton:registerEventHandler( "gain_focus", function ( element, event )
		local f15_local0 = nil
		if element.gainFocus then
			f15_local0 = element:gainFocus( event )
		elseif element.super.gainFocus then
			f15_local0 = element.super:gainFocus( event )
		end
		CoD.Menu.UpdateButtonShownState( element, f1_arg0, f1_arg1, Enum[@"luibutton"][@"lui_key_xba_pscross"] )
		return f15_local0
	end )
	f1_arg0:AddButtonCallbackFunction( DirectorPreGameButton, f1_arg1, Enum[@"luibutton"][@"lui_key_xba_pscross"], nil, function ( element, menu, controller, model )
		OpenQuarterMaster( self, element, controller, "", menu )
		return true
	end, function ( element, menu, controller )
		CoD.Menu.SetButtonLabel( menu, Enum[@"luibutton"][@"lui_key_xba_pscross"], @"menu/black_market", nil, nil )
		return true
	end, false )
	self:addElement( DirectorPreGameButton )
	self.DirectorPreGameButton = DirectorPreGameButton
	
	local ArenaEventButtons = CoD.ArenaEventButtons.new( f1_arg0, f1_arg1, 0.5, 0.5, 122, 322, 1, 1, -178, -108 )
	ArenaEventButtons:setAlpha( 0 )
	self:addElement( ArenaEventButtons )
	self.ArenaEventButtons = ArenaEventButtons
	
	local ArenaDailyBonus = CoD.ArenaDailyBonus.new( f1_arg0, f1_arg1, 0.5, 0.5, 122, 322, 1, 1, -258, -188 )
	ArenaDailyBonus:setAlpha( 0 )
	self:addElement( ArenaDailyBonus )
	self.ArenaDailyBonus = ArenaDailyBonus
	
	local ArenaEventProgressButton = CoD.ArenaEventProgressButton.new( f1_arg0, f1_arg1, 0.5, 0.5, 514, 896, 1, 1, -178, -108 )
	self:addElement( ArenaEventProgressButton )
	self.ArenaEventProgressButton = ArenaEventProgressButton

	-- host options
	local DirectorZMLobbySettingList = CoD.DirectorZMLobbySettingList.new(f1_arg0, f1_arg1, 0.5, 0.5, 514, 896, 1, 1, -443 + 125, -323 + 125)
	DirectorZMLobbySettingList:mergeStateConditions( {
		{
			stateName = "ShowGameRules",
			condition = function ( menu, element, event )
				return AlwaysTrue()
			end
		},
		{
			stateName = "ShowAddRemoveBots",
			condition = function ( menu, element, event )
				return AlwaysTrue()
			end
		}
	} )
	self:addElement( DirectorZMLobbySettingList )
	self.DirectorZMLobbySettingList = DirectorZMLobbySettingList

	DirectorZMLobbySettingList.id = "DirectorZMLobbySettingList"
	
	self:mergeStateConditions( {
		{
			stateName = "IsPC",
			condition = function ( menu, element, event )
				return IsPC()
			end
		}
	} )
	self:subscribeToGlobalModel( f1_arg1, "LobbyRoot", "gameClientDataUpdate", function ( model )
		local f19_local0 = self
		if CoD.DirectorUtility.ShowDirectorArenaMatchmaking( f1_arg1 ) then
			CoD.PlayerRoleUtility.UpdatePositionDraftModels( f1_arg1 )
		end
	end )
	self:subscribeToGlobalModel( f1_arg1, "CharacterSelection", "clientUpdated", function ( model )
		local f20_local0 = self
		if CoD.DirectorUtility.ShowDirectorArenaMatchmaking( f1_arg1 ) then
			CoD.PlayerRoleUtility.UpdatePositionDraftModels( f1_arg1 )
		end
	end )
	self:subscribeToGlobalModel( f1_arg1, "LobbyRoot", "lobbyNav", function ( model )
		local f21_local0 = self
		if CoD.DirectorUtility.ShowDirectorArenaMatchmaking( f1_arg1 ) then
			CoD.PlayerRoleUtility.UpdatePositionDraftModels( f1_arg1 )
		end
	end )
	f1_local3.id = "MapVote"
	if CoD.isPC then
		MapVotePC.id = "MapVotePC"
	end
	DirectorReadyButton.id = "DirectorReadyButton"
	DirectorPreGameButton.id = "DirectorPreGameButton"
	ArenaEventButtons.id = "ArenaEventButtons"
	ArenaEventProgressButton.id = "ArenaEventProgressButton"
	LUI.OverrideFunction_CallOriginalSecond( self, "close", self.__onClose )
	
	if PostLoadFunc then
		PostLoadFunc( self, f1_arg1, f1_arg0 )
	end
	
	local f1_local11 = self
	CoD.LobbyUtility.InitOverheadNamesPreLobby( f1_arg0, f1_arg1, overheadNameContainer )
	return self
end

CoD.directorArenaMatchmaking.__onClose = function ( f22_arg0 )
	f22_arg0.StageNotificationContainer:close()
	f22_arg0.TopBar:close()
	f22_arg0.MapVote:close()
	f22_arg0.MapVotePC:close()
	f22_arg0.DirectorReadyButton:close()
	f22_arg0.overheadNameContainer:close()
	f22_arg0.DirectorPreGameButton:close()
	f22_arg0.ArenaEventButtons:close()
	f22_arg0.ArenaDailyBonus:close()
	f22_arg0.ArenaEventProgressButton:close()
	f33_arg0.DirectorZMLobbySettingList:close()
end

CoD.directorArenaPregame = InheritFrom( LUI.UIElement ) 
CoD.directorArenaPregame.__defaultWidth = 1920 
CoD.directorArenaPregame.__defaultHeight = 1080 
CoD.directorArenaPregame.new = function ( f1_arg0, f1_arg1, f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	local self = LUI.UIElement.new( f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 ) 
	CoD.DirectorUtility.InitPublicLobbyModels( self, f1_arg1, f1_arg0 ) 
	CoD.PlayerRoleUtility.UpdatePositionDraftModels( f1_arg1 ) 
	CoD.DirectorUtility.InitQuickPlayModel( f1_arg1 ) 
	DataSourceHelperGetModel( f1_arg1, "Arena" ) 
	self:setClass( CoD.directorArenaPregame ) 
	self.id = "directorArenaPregame" 
	self.soundSet = "default" 
	self.onlyChildrenFocusable = true 
	self.anyChildUsesUpdateState = true 
	f1_arg0:addElementToPendingUpdateStateList( self ) 
	
	local Header = CoD.DirectorScreenHeader.new( f1_arg0, f1_arg1, 0.5, 0.5, -870, -227, 0, 0, 301, 401 ) 
	Header:setAlpha( 0 ) 
	Header:setZoom( 75 ) 
	Header.Header:setText( LocalizeToUpperString( @"hash_156CB4013028D74E" ) ) 
	self:addElement( Header ) 
	self.Header = Header 
	
	local pckeyboardNavigationRedirector2 = nil 
	
	pckeyboardNavigationRedirector2 = CoD.emptyFocusable.new( f1_arg0, f1_arg1, 0.5, 0.8, 384, 384, 0.27, 0.32, 0, 0 ) 
	self:addElement( pckeyboardNavigationRedirector2 ) 
	self.pckeyboardNavigationRedirector2 = pckeyboardNavigationRedirector2 
	
	local pckeyboardNavigationRedirector = nil 
	
	pckeyboardNavigationRedirector = CoD.emptyFocusable.new( f1_arg0, f1_arg1, 0.5, 0.8, 384, 384, 0.77, 0.82, 0, 0 ) 
	self:addElement( pckeyboardNavigationRedirector ) 
	self.pckeyboardNavigationRedirector = pckeyboardNavigationRedirector 

	local SetUpMatchButton = CoD.DirectorPreGameSetUpMatch.new( f1_arg0, f1_arg1, 0.5, 0.5, -505, 406, 1, 1, -399, -184 )
    SetUpMatchButton:mergeStateConditions( {
	    {
		    stateName = "Unselectable",
		    condition = function ( menu, element, event )
			    return not IsLobbyHostOfCurrentMenu()
		    end
	    },
	    {
		    stateName = "Visible",
		    condition = function ( menu, element, event )
				return AlwaysFalse()
		    end
	    }
    } ) 
    SetUpMatchButton:appendEventHandler( "on_session_start", function ( f25_arg0, f25_arg1 )
	    f25_arg1.menu = f25_arg1.menu or f1_arg0 
	    f1_arg0:updateElementState( SetUpMatchButton, f25_arg1 ) 
    end ) 
    SetUpMatchButton:appendEventHandler( "on_session_end", function ( f26_arg0, f26_arg1 )
	    f26_arg1.menu = f26_arg1.menu or f1_arg0 
	    f1_arg0:updateElementState( SetUpMatchButton, f26_arg1 ) 
    end ) 
    local ZMLoadoutPreviewInfo = SetUpMatchButton 
    local StartButton = SetUpMatchButton.subscribeToModel 
    local DirectorLobbyPoseMembersZM = Engine[@"hash_78DF2E5447F384B9"]() 
    StartButton( ZMLoadoutPreviewInfo, DirectorLobbyPoseMembersZM["lobbyRoot.lobbyNav"], function ( f27_arg0 )
	    f1_arg0:updateElementState( SetUpMatchButton, {
		    name = "model_validation",
		    menu = f1_arg0,
		    controller = f1_arg1,
		    modelValue = f27_arg0:get(),
		    modelName = "lobbyRoot.lobbyNav"
	    } ) 
    end, false ) 
    ZMLoadoutPreviewInfo = SetUpMatchButton 
    StartButton = SetUpMatchButton.subscribeToModel 
    DirectorLobbyPoseMembersZM = Engine[@"hash_78DF2E5447F384B9"]() 
    StartButton( ZMLoadoutPreviewInfo, DirectorLobbyPoseMembersZM["lobbyRoot.gameClient.update"], function ( f28_arg0 )
	    f1_arg0:updateElementState( SetUpMatchButton, {
		    name = "model_validation",
		    menu = f1_arg0,
		    controller = f1_arg1,
		    modelValue = f28_arg0:get(),
		    modelName = "lobbyRoot.gameClient.update"
	    } ) 
    end, false ) 
    ZMLoadoutPreviewInfo = SetUpMatchButton 
    StartButton = SetUpMatchButton.subscribeToModel 
    DirectorLobbyPoseMembersZM = Engine[@"hash_78DF2E5447F384B9"]() 
    StartButton( ZMLoadoutPreviewInfo, DirectorLobbyPoseMembersZM["lobbyRoot.privateClient.update"], function ( f29_arg0 )
	    f1_arg0:updateElementState( SetUpMatchButton, {
		    name = "model_validation",
		    menu = f1_arg0,
		    controller = f1_arg1,
		    modelValue = f29_arg0:get(),
		    modelName = "lobbyRoot.privateClient.update"
	    } ) 
    end, false ) 
        SetUpMatchButton.MapImage.PlaylistHeader.GameModeText:setText( Engine[@"hash_4F9F1239CFD921FE"]( @"hash_2FA47140D97F89D" ) ) 
        SetUpMatchButton.MapImage.PlaylistHeader.GameModeText:setTTF( "ttmussels_regular" ) 
        ZMLoadoutPreviewInfo = SetUpMatchButton 
        StartButton = SetUpMatchButton.subscribeToModel 
        DirectorLobbyPoseMembersZM = Engine[@"hash_78DF2E5447F384B9"]() 
        StartButton( ZMLoadoutPreviewInfo, DirectorLobbyPoseMembersZM["lobbyRoot.lobbyNav"], function ( f30_arg0, f30_arg1 )
	    CoD.Menu.UpdateButtonShownState( f30_arg1, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] ) 
    end, false ) 
        ZMLoadoutPreviewInfo = SetUpMatchButton 
        StartButton = SetUpMatchButton.subscribeToModel 
        DirectorLobbyPoseMembersZM = Engine[@"hash_78DF2E5447F384B9"]() 
        StartButton( ZMLoadoutPreviewInfo, DirectorLobbyPoseMembersZM["lobbyRoot.lobbyTimeRemaining"], function ( f31_arg0, f31_arg1 )
	    CoD.Menu.UpdateButtonShownState( f31_arg1, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] ) 
    end, false ) 
    SetUpMatchButton:appendEventHandler( "on_session_start", function ( f32_arg0, f32_arg1 )
	    f32_arg1.menu = f32_arg1.menu or f1_arg0 
	    CoD.Menu.UpdateButtonShownState( f32_arg0, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] ) 
    end ) 
    SetUpMatchButton:appendEventHandler( "on_session_end", function ( f33_arg0, f33_arg1 )
	    f33_arg1.menu = f33_arg1.menu or f1_arg0 
	    CoD.Menu.UpdateButtonShownState( f33_arg0, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] ) 
    end ) 
        ZMLoadoutPreviewInfo = SetUpMatchButton 
        StartButton = SetUpMatchButton.subscribeToModel 
        DirectorLobbyPoseMembersZM = Engine[@"hash_78DF2E5447F384B9"]() 
        StartButton( ZMLoadoutPreviewInfo, DirectorLobbyPoseMembersZM["lobbyRoot.gameClient.update"], function ( f34_arg0, f34_arg1 )
	    CoD.Menu.UpdateButtonShownState( f34_arg1, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] ) 
    end, false ) 
        ZMLoadoutPreviewInfo = SetUpMatchButton 
        StartButton = SetUpMatchButton.subscribeToModel 
        DirectorLobbyPoseMembersZM = Engine[@"hash_78DF2E5447F384B9"]() 
        StartButton( ZMLoadoutPreviewInfo, DirectorLobbyPoseMembersZM["lobbyRoot.privateClient.update"], function ( f35_arg0, f35_arg1 )
	    CoD.Menu.UpdateButtonShownState( f35_arg1, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] ) 
    end, false ) 
    SetUpMatchButton:registerEventHandler( "gain_focus", function ( element, event )
	    local f36_local0 = nil 
	    if element.gainFocus then
		    f36_local0 = element:gainFocus( event ) 
	    elseif element.super.gainFocus then
		    f36_local0 = element.super:gainFocus( event ) 
	    end
	    CoD.Menu.UpdateButtonShownState( element, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] ) 
	    return f36_local0
    end ) 
    f1_arg0:AddButtonCallbackFunction( SetUpMatchButton, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], "ui_confirm", function ( element, menu, controller, model )
	    if IsWarzone() and not CoD.ModelUtility.IsGlobalModelValueGreaterThan( "lobbyRoot.lobbyTimeRemaining", 0 ) and IsLobbyHostOfCurrentMenu() then
		    SetFocusToElement( self, "ShieldOfflineStartButton", controller ) 
		    SetLoseFocusToElement( self, "SetUpMatchButton", controller ) 
		    CoD.DirectorUtility.DirectorOpenOverlayWithCurrentMenuMode( menu, controller, "DirectorCustomGameSetUpWZ" ) 
		    PlaySoundAlias( "uin_toggle_generic" ) 
		    return true
	    elseif not CoD.ModelUtility.IsGlobalModelValueGreaterThan( "lobbyRoot.lobbyTimeRemaining", 0 ) and IsLobbyHostOfCurrentMenu() and not IsZombies() then
		    SetFocusToElement( self, "ShieldOfflineStartButton", controller ) 
		    SetLoseFocusToElement( self, "SetUpMatchButton", controller ) 
		    CoD.DirectorUtility.DirectorOpenOverlayWithCurrentMenuMode( menu, controller, "DirectorCustomGameSetUp" ) 
		    PlaySoundAlias( "uin_toggle_generic" ) 
			Engine[@"setlobbymaxclients"](Enum[@"lobbytype"][@"lobby_type_game"], 12)
			Engine[@"setlobbymaxclients"](Enum[@"lobbytype"][@"lobby_type_private"], 12)
			Engine[@"setlobbymaxclients"](Engine[@"getprimarycontroller"](), 12)
			Dvar[@"hash_4FF45B41C6046F8"]:set(12)
			Engine[@"setmodelvalue"](Engine[@"createmodel"]( Engine[@"createmodel"]( Engine[@"getglobalmodel"](), "PartyPrivacy" ), "maxPlayers" ), 12)
		    return true
		elseif IsZombies() then
		    --CoD.LobbyUtility.SetLeaderActivityAndOpenOverlay( self, controller, CoD.LobbyUtility.LeaderActivity.CHOOSING_MAP, "DirectorChooseMapAndGameType" ) 
            SetFocusToElement( self, "ShieldOfflineStartButton", controller ) 
		    SetLoseFocusToElement( self, "SetUpMatchButton", controller ) 
		    CoD.DirectorUtility.DirectorOpenOverlayWithCurrentMenuMode( menu, controller, "DirectorChooseMapAndGameType" ) 
		    PlaySoundAlias( "uin_toggle_generic" ) 
		    return true  

	    else
	    end
    end, function ( element, menu, controller )
	    if IsWarzone() and not CoD.ModelUtility.IsGlobalModelValueGreaterThan( "lobbyRoot.lobbyTimeRemaining", 0 ) and IsLobbyHostOfCurrentMenu() then
		    CoD.Menu.SetButtonLabel( menu, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], @"hash_6D0BB36CD318F55F", nil, "ui_confirm" ) 
		    return true
	    elseif not CoD.ModelUtility.IsGlobalModelValueGreaterThan( "lobbyRoot.lobbyTimeRemaining", 0 ) and IsLobbyHostOfCurrentMenu() then
		    CoD.Menu.SetButtonLabel( menu, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], @"hash_6D0BB36CD318F55F", nil, "ui_confirm" ) 
		    return true
	    else
		    return false
	    end
    end, false ) 
    --self:addElement( SetUpMatchButton ) 
    self.SetUpMatchButton = SetUpMatchButton 

    SetUpMatchButton.id = "SetUpMatchButton"

	-- lobby startgame button

	local ShieldOfflineStartButton = CoD.DirectorPreGameButtonOption.new( f1_arg0, f1_arg1, 0.5, 0.5, 514, 896, 1, 1, -178, -108 )
	ShieldOfflineStartButton.DirectorSelectButtonMiniInternal.MiddleText:setText( LocalizeToUpperString( @"hash_6DDDA371285672BD" ) )
	ShieldOfflineStartButton.DirectorSelectButtonMiniInternal.MiddleTextFocus:setText( LocalizeToUpperString( @"hash_6DDDA371285672BD" ) )

	
	ShieldOfflineStartButton:mergeStateConditions( {
		{
			stateName = "Visible",
			condition = function ( menu, element, event )
				return AlwaysFalse()
			end
		}
	} )

	ShieldOfflineStartButton:registerEventHandler( "gain_focus", function ( element, event )
		local f26_local0 = nil
		if element.gainFocus then
			f26_local0 = element:gainFocus( event )
		elseif element.super.gainFocus then
			f26_local0 = element.super:gainFocus( event )
		end
		CoD.Menu.UpdateButtonShownState( element, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
		return f26_local0
	end )
	
	f1_arg0:AddButtonCallbackFunction( ShieldOfflineStartButton, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], "ui_confirm", function ( element, menu, controller, model )
		if not IsZombies() then
			Dvar[@"bot_difficulty"]:set(3)
			CoD.LaunchGameFunction(controller)
			PlaySoundAlias( "uin_press_generic" )
			return true
		else
			
		end
	end, function ( element, menu, controller )
		if not IsZombies() and not CoD.DirectorUtility.IsNumClientsExceeded( controller ) and not CoD.DirectorUtility.ShouldLockFindMatchButton( controller ) then
			CoD.Menu.SetButtonLabel( menu, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], @"hash_6D0BB36CD318F55F", nil, "ui_confirm" )
			return true
		elseif not IsZombies() and CoD.DirectorUtility.IsNumClientsExceeded( controller ) then
			CoD.Menu.SetButtonLabel( menu, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], @"hash_6D0BB36CD318F55F", nil, "ui_confirm" )
			return true
		else
			return false
		end
	end, false )
	self:addElement( ShieldOfflineStartButton )
	self.ShieldOfflineStartButton = ShieldOfflineStartButton

	ShieldOfflineStartButton.id = "ShieldOfflineStartButton"

    -- lobby add bots button 

	local ShieldOfflineAddBot = CoD.DirectorPreGameButtonOption.new( f1_arg0, f1_arg1, 0.5, 0.5, 514, 896, 1, 1, -522, -476 ) 
	ShieldOfflineAddBot.DirectorSelectButtonMiniInternal.MiddleText:setText( LocalizeToUpperString( @"hash_141A80D9A928673E" ) )
	ShieldOfflineAddBot.DirectorSelectButtonMiniInternal.MiddleTextFocus:setText( LocalizeToUpperString( @"hash_141A80D9A928673E" ) )

	
	ShieldOfflineAddBot:mergeStateConditions( {
		{
			stateName = "Visible",
			condition = function ( menu, element, event )
				return AlwaysFalse()
			end
		}
	} )

	ShieldOfflineAddBot:registerEventHandler( "gain_focus", function ( element, event )
		local f26_local0 = nil
		if element.gainFocus then
			f26_local0 = element:gainFocus( event )
		elseif element.super.gainFocus then
			f26_local0 = element.super:gainFocus( event )
		end
		CoD.Menu.UpdateButtonShownState( element, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
		return f26_local0
	end )
	
	f1_arg0:AddButtonCallbackFunction( ShieldOfflineAddBot, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], "ui_confirm", function ( element, menu, controller, model )
		if not IsZombies() then
			CoD.DirectorUtility.ClearSelectedClient( controller )
			SetFocusToElement( self, "ShieldOfflineStartButton", controller ) 
			--AddLobbyBots( menu, controller )
			Engine[@"hash_1CBDED49058F1E19"]( f107_local1, 17, false, 0 )
			PlaySoundAlias( "uin_toggle_generic" )
			return true
		else
			
		end
	end, function ( element, menu, controller )
		if not IsZombies() and not CoD.DirectorUtility.IsNumClientsExceeded( controller ) and not CoD.DirectorUtility.ShouldLockFindMatchButton( controller ) then
			CoD.Menu.SetButtonLabel( menu, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], @"hash_6D0BB36CD318F55F", nil, "ui_confirm" )
			return true
		elseif not IsZombies() and CoD.DirectorUtility.IsNumClientsExceeded( controller ) then
			CoD.Menu.SetButtonLabel( menu, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], @"hash_6D0BB36CD318F55F", nil, "ui_confirm" )
			return true
		else
			return false
		end
	end, false )
	self:addElement( ShieldOfflineAddBot )
	self.ShieldOfflineAddBot = ShieldOfflineAddBot

	ShieldOfflineAddBot.id = "ShieldOfflineAddBot"

    -- lobby remove bots button 

	local ShieldOfflineRemoveBot = CoD.DirectorPreGameButtonOption.new( f1_arg0, f1_arg1, 0.5, 0.5, 514, 896, 1, 1, -522, -476 ) 
	ShieldOfflineRemoveBot.DirectorSelectButtonMiniInternal.MiddleText:setText( LocalizeToUpperString( @"hash_5FD88DBB329D1EC9" ) )
	ShieldOfflineRemoveBot.DirectorSelectButtonMiniInternal.MiddleTextFocus:setText( LocalizeToUpperString( @"hash_5FD88DBB329D1EC9" ) )

	
	ShieldOfflineRemoveBot:mergeStateConditions( {
		{
			stateName = "Visible",
			condition = function ( menu, element, event )
				return AlwaysFalse()
				--return Engine[@"hash_144FC97037CE42ED"]( Enum[@"hash_47CA2DE5266A94BF"][@"hash_40C46B73E8E18BA2"], f109_local1, Enum[@"hash_6575E471C039DBD6"][@"hash_17D6D125E5450799"] ) > 0
			end
		}
	} )

	ShieldOfflineRemoveBot:registerEventHandler( "gain_focus", function ( element, event )
		local f26_local0 = nil
		if element.gainFocus then
			f26_local0 = element:gainFocus( event )
		elseif element.super.gainFocus then
			f26_local0 = element.super:gainFocus( event )
		end
		CoD.Menu.UpdateButtonShownState( element, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
		return f26_local0
	end )
	
	f1_arg0:AddButtonCallbackFunction( ShieldOfflineRemoveBot, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], "ui_confirm", function ( element, menu, controller, model )
		if not IsZombies() then
			CoD.DirectorUtility.ClearSelectedClient( controller )
			SetFocusToElement( self, "ShieldOfflineAddBot", controller )
			SetLoseFocusToElement( self, "ShieldOfflineRemoveBot", controller )
			--RemoveLobbyBots( self, element, controller, "", menu )
			Engine[@"hash_1A468BF674010CE8"]( f108_local1, 17 )
			PlaySoundAlias( "uin_toggle_generic" )
			return true
		else
			
		end
	end, function ( element, menu, controller )
		if not IsZombies() and not CoD.DirectorUtility.IsNumClientsExceeded( controller ) and not CoD.DirectorUtility.ShouldLockFindMatchButton( controller ) then
			CoD.Menu.SetButtonLabel( menu, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], @"hash_6D0BB36CD318F55F", nil, "ui_confirm" )
			return true
		elseif not IsZombies() and CoD.DirectorUtility.IsNumClientsExceeded( controller ) then
			CoD.Menu.SetButtonLabel( menu, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], @"hash_6D0BB36CD318F55F", nil, "ui_confirm" )
			return true
		else
			return false
		end
	end, false )
	self:addElement( ShieldOfflineRemoveBot )
	self.ShieldOfflineRemoveBot = ShieldOfflineRemoveBot

	ShieldOfflineRemoveBot.id = "ShieldOfflineRemoveBot" 

    -- lobby offline button

	local ShieldOfflineButton = CoD.DirectorPreGameButtonOption.new( f1_arg0, f1_arg1, 0.5, 0.5, 724, 895, 1, 1, -178, -108 )
	ShieldOfflineButton.DirectorSelectButtonMiniInternal.MiddleText:setText( LocalizeToUpperString( @"hash_2968A794E7F44FAD" ) ) 
	ShieldOfflineButton.DirectorSelectButtonMiniInternal.MiddleTextFocus:setText( LocalizeToUpperString( @"hash_2968A794E7F44FAD" ) )

	ShieldOfflineButton:mergeStateConditions( {
		{
			stateName = "Visible",
			condition = function ( menu, element, event )
				-- not needed anymore, offline matchmaking.
				return AlwaysFalse()
				--return not IsZombies() and Engine[@"getdvarint"](@"hash_4FF45B41C6046F8") <= 11 and IsArenaMode()
			end
		}
	} )

	ShieldOfflineButton:registerEventHandler( "gain_focus", function ( element, event )
		local f26_local0 = nil
		if element.gainFocus then
			f26_local0 = element:gainFocus( event )
		elseif element.super.gainFocus then
			f26_local0 = element.super:gainFocus( event )
		end
		CoD.Menu.UpdateButtonShownState( element, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
		return f26_local0
	end )
	
	f1_arg0:AddButtonCallbackFunction( ShieldOfflineButton, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], "ui_confirm", function ( element, menu, controller, model )
		if not IsZombies() then
			Engine[@"setlobbymaxclients"](Enum[@"lobbytype"][@"lobby_type_game"], 12)
			Engine[@"setlobbymaxclients"](Enum[@"lobbytype"][@"lobby_type_private"], 12)
			Engine[@"setlobbymaxclients"](Engine[@"getprimarycontroller"](), 12)
			Dvar[@"hash_4FF45B41C6046F8"]:set(12)
			Engine[@"setmodelvalue"](Engine[@"createmodel"]( Engine[@"createmodel"]( Engine[@"getglobalmodel"](), "PartyPrivacy" ), "maxPlayers" ), 12)
			--Engine[@"hash_1CBDED49058F1E19"]( f107_local1, 11, false, 0 ) --populate lobby with bots at startup disable in arena
			PlaySoundAlias( "uin_press_generic" )
			SetFocusToElement( self, "SetUpMatchButton", controller )
			SetLoseFocusToElement( self, "ShieldOfflineButton", controller )
			return true
		else
			
		end
	end, function ( element, menu, controller )
		if not IsZombies() and not CoD.DirectorUtility.IsNumClientsExceeded( controller ) and not CoD.DirectorUtility.ShouldLockFindMatchButton( controller ) then
			CoD.Menu.SetButtonLabel( menu, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], @"hash_6D0BB36CD318F55F", nil, "ui_confirm" )
			return true
		elseif not IsZombies() and CoD.DirectorUtility.IsNumClientsExceeded( controller ) then
			CoD.Menu.SetButtonLabel( menu, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], @"hash_6D0BB36CD318F55F", nil, "ui_confirm" )
			return true
		else
			return false
		end
	end, false )
	self:addElement( ShieldOfflineButton )
	self.ShieldOfflineButton = ShieldOfflineButton

	ShieldOfflineButton.id = "ShieldOfflineButton"
	
	local FindMatchButton = CoD.DirectorPreGameButtonOption.new( f1_arg0, f1_arg1, 0.5, 0.5, 514, 896, 1, 1, -178, -108 ) 
	FindMatchButton:mergeStateConditions( {
		{
			stateName = "ArenaSuspended",
			condition = function ( menu, element, event )
				return CoD.ArenaLeaguePlayUtility.LeaverLockoutActive()
			end
		},
		{
			stateName = "Unselectable",
			condition = function ( menu, element, event )
				return not IsPartyLeader( f1_arg1 )
			end
		},
		{
			stateName = "Visible",
			condition = function ( menu, element, event )
				return IsPartyLeader( f1_arg1 )
			end
		}
	} ) 
	local CompetitiveOverviewRankBanner = FindMatchButton 
	local DirectorLobbyPoseMembers = FindMatchButton.subscribeToModel 
	local LeagueEventEndDelayMessageTitle = Engine[@"hash_78DF2E5447F384B9"]() 
	DirectorLobbyPoseMembers( CompetitiveOverviewRankBanner, LeagueEventEndDelayMessageTitle["Arena.lockoutTimeRemaining"], function ( f5_arg0 )
		f1_arg0:updateElementState( FindMatchButton, {
			name = "model_validation",
			menu = f1_arg0,
			controller = f1_arg1,
			modelValue = f5_arg0:get(),
			modelName = "Arena.lockoutTimeRemaining"
		} ) 
	end, false ) 
	CompetitiveOverviewRankBanner = FindMatchButton 
	DirectorLobbyPoseMembers = FindMatchButton.subscribeToModel 
	LeagueEventEndDelayMessageTitle = Engine[@"hash_78DF2E5447F384B9"]() 
	DirectorLobbyPoseMembers( CompetitiveOverviewRankBanner, LeagueEventEndDelayMessageTitle["lobbyRoot.lobbyNav"], function ( f6_arg0 )
		f1_arg0:updateElementState( FindMatchButton, {
			name = "model_validation",
			menu = f1_arg0,
			controller = f1_arg1,
			modelValue = f6_arg0:get(),
			modelName = "lobbyRoot.lobbyNav"
		} ) 
	end, false ) 
	CompetitiveOverviewRankBanner = FindMatchButton 
	DirectorLobbyPoseMembers = FindMatchButton.subscribeToModel 
	LeagueEventEndDelayMessageTitle = Engine[@"hash_78DF2E5447F384B9"]() 
	DirectorLobbyPoseMembers( CompetitiveOverviewRankBanner, LeagueEventEndDelayMessageTitle["lobbyRoot.privateClient.isHost"], function ( f7_arg0 )
		f1_arg0:updateElementState( FindMatchButton, {
			name = "model_validation",
			menu = f1_arg0,
			controller = f1_arg1,
			modelValue = f7_arg0:get(),
			modelName = "lobbyRoot.privateClient.isHost"
		} ) 
	end, false ) 
	CompetitiveOverviewRankBanner = FindMatchButton 
	DirectorLobbyPoseMembers = FindMatchButton.subscribeToModel 
	LeagueEventEndDelayMessageTitle = Engine[@"hash_78DF2E5447F384B9"]() 
	DirectorLobbyPoseMembers( CompetitiveOverviewRankBanner, LeagueEventEndDelayMessageTitle["lobbyRoot.gameClient.isHost"], function ( f8_arg0 )
		f1_arg0:updateElementState( FindMatchButton, {
			name = "model_validation",
			menu = f1_arg0,
			controller = f1_arg1,
			modelValue = f8_arg0:get(),
			modelName = "lobbyRoot.gameClient.isHost"
		} ) 
	end, false ) 
	FindMatchButton:appendEventHandler( "on_session_start", function ( f9_arg0, f9_arg1 )
		f9_arg1.menu = f9_arg1.menu or f1_arg0 
		f1_arg0:updateElementState( FindMatchButton, f9_arg1 ) 
	end ) 
	FindMatchButton:appendEventHandler( "on_session_end", function ( f10_arg0, f10_arg1 )
		f10_arg1.menu = f10_arg1.menu or f1_arg0 
		f1_arg0:updateElementState( FindMatchButton, f10_arg1 ) 
	end ) 
	CompetitiveOverviewRankBanner = FindMatchButton 
	DirectorLobbyPoseMembers = FindMatchButton.subscribeToModel 
	LeagueEventEndDelayMessageTitle = Engine[@"hash_78DF2E5447F384B9"]() 
	DirectorLobbyPoseMembers( CompetitiveOverviewRankBanner, LeagueEventEndDelayMessageTitle["lobbyRoot.gameClient.update"], function ( f11_arg0 )
		f1_arg0:updateElementState( FindMatchButton, {
			name = "model_validation",
			menu = f1_arg0,
			controller = f1_arg1,
			modelValue = f11_arg0:get(),
			modelName = "lobbyRoot.gameClient.update"
		} ) 
	end, false ) 
	CompetitiveOverviewRankBanner = FindMatchButton 
	DirectorLobbyPoseMembers = FindMatchButton.subscribeToModel 
	LeagueEventEndDelayMessageTitle = Engine[@"hash_78DF2E5447F384B9"]() 
	DirectorLobbyPoseMembers( CompetitiveOverviewRankBanner, LeagueEventEndDelayMessageTitle["lobbyRoot.privateClient.update"], function ( f12_arg0 )
		f1_arg0:updateElementState( FindMatchButton, {
			name = "model_validation",
			menu = f1_arg0,
			controller = f1_arg1,
			modelValue = f12_arg0:get(),
			modelName = "lobbyRoot.privateClient.update"
		} ) 
	end, false ) 
	CompetitiveOverviewRankBanner = FindMatchButton 
	DirectorLobbyPoseMembers = FindMatchButton.subscribeToModel 
	LeagueEventEndDelayMessageTitle = Engine[@"hash_78DF2E5447F384B9"]() 
	DirectorLobbyPoseMembers( CompetitiveOverviewRankBanner, LeagueEventEndDelayMessageTitle.offlineScreenState, function ( f13_arg0 )
		f1_arg0:updateElementState( FindMatchButton, {
			name = "model_validation",
			menu = f1_arg0,
			controller = f1_arg1,
			modelValue = f13_arg0:get(),
			modelName = "offlineScreenState"
		} ) 
	end, false ) 
	FindMatchButton.DirectorSelectButtonMiniInternal.MiddleText:setText( LocalizeToUpperString( @"hash_7A14B986BB3C650A" ) ) 
	FindMatchButton.DirectorSelectButtonMiniInternal.MiddleTextFocus:setText( LocalizeToUpperString( @"hash_7A14B986BB3C650A" ) ) 
	CompetitiveOverviewRankBanner = FindMatchButton 
	DirectorLobbyPoseMembers = FindMatchButton.subscribeToModel 
	LeagueEventEndDelayMessageTitle = Engine[@"hash_78DF2E5447F384B9"]() 
	DirectorLobbyPoseMembers( CompetitiveOverviewRankBanner, LeagueEventEndDelayMessageTitle["lobbyRoot.lobbyNav"], function ( f14_arg0, f14_arg1 )
		CoD.Menu.UpdateButtonShownState( f14_arg1, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] ) 
	end, false ) 
	CompetitiveOverviewRankBanner = FindMatchButton 
	DirectorLobbyPoseMembers = FindMatchButton.subscribeToModel 
	LeagueEventEndDelayMessageTitle = Engine[@"hash_78DF2E5447F384B9"]() 
	DirectorLobbyPoseMembers( CompetitiveOverviewRankBanner, LeagueEventEndDelayMessageTitle["lobbyRoot.privateClient.isHost"], function ( f15_arg0, f15_arg1 )
		CoD.Menu.UpdateButtonShownState( f15_arg1, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] ) 
	end, false ) 
	CompetitiveOverviewRankBanner = FindMatchButton 
	DirectorLobbyPoseMembers = FindMatchButton.subscribeToModel 
	LeagueEventEndDelayMessageTitle = Engine[@"hash_78DF2E5447F384B9"]() 
	DirectorLobbyPoseMembers( CompetitiveOverviewRankBanner, LeagueEventEndDelayMessageTitle["lobbyRoot.gameClient.isHost"], function ( f16_arg0, f16_arg1 )
		CoD.Menu.UpdateButtonShownState( f16_arg1, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] ) 
	end, false ) 
	CompetitiveOverviewRankBanner = FindMatchButton 
	DirectorLobbyPoseMembers = FindMatchButton.subscribeToModel 
	LeagueEventEndDelayMessageTitle = Engine[@"hash_78DF2E5447F384B9"]() 
	DirectorLobbyPoseMembers( CompetitiveOverviewRankBanner, LeagueEventEndDelayMessageTitle["lobbyRoot.playlistId"], function ( f17_arg0, f17_arg1 )
		CoD.Menu.UpdateButtonShownState( f17_arg1, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] ) 
	end, false ) 
	CompetitiveOverviewRankBanner = FindMatchButton 
	DirectorLobbyPoseMembers = FindMatchButton.subscribeToModel 
	LeagueEventEndDelayMessageTitle = Engine[@"hash_78DF2E5447F384B9"]() 
	DirectorLobbyPoseMembers( CompetitiveOverviewRankBanner, LeagueEventEndDelayMessageTitle["lobbyRoot.lobbyList.playerCount"], function ( f18_arg0, f18_arg1 )
		CoD.Menu.UpdateButtonShownState( f18_arg1, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] ) 
	end, false ) 
	FindMatchButton:registerEventHandler( "gain_focus", function ( element, event )
		local f19_local0 = nil 
		if element.gainFocus then
			f19_local0 = element:gainFocus( event ) 
		elseif element.super.gainFocus then
			f19_local0 = element.super:gainFocus( event ) 
		end
		CoD.Menu.UpdateButtonShownState( element, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] ) 
		return f19_local0
	end ) 
	f1_arg0:AddButtonCallbackFunction( FindMatchButton, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], "ui_confirm", function ( element, menu, controller, model )
		if IsPartyLeader( controller ) and not CoD.ArenaLeaguePlayUtility.ForceCheckLeaverLockoutActive() and not CoD.DirectorUtility.IsNumClientsExceeded( controller ) then
			CoD.DirectorUtility.NavigateToArenaMatchmakingLobby( self, menu, controller, element ) 
			PlaySoundAlias( "uin_press_generic" ) 
			return true
		elseif IsPartyLeader( controller ) and CoD.DirectorUtility.IsNumClientsExceeded( controller ) then
			PlaySoundAlias( "uin_toggle_generic" ) 
			CoD.DirectorUtility.OpenTooManyClientsPopup( self, controller ) 
			return true
		else
			
		end
	end, function ( element, menu, controller )
		if IsPartyLeader( controller ) and not CoD.ArenaLeaguePlayUtility.ForceCheckLeaverLockoutActive() and not CoD.DirectorUtility.IsNumClientsExceeded( controller ) then
			CoD.Menu.SetButtonLabel( menu, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], @"hash_6D0BB36CD318F55F", nil, "ui_confirm" ) 
			return true
		elseif IsPartyLeader( controller ) and CoD.DirectorUtility.IsNumClientsExceeded( controller ) then
			CoD.Menu.SetButtonLabel( menu, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], @"hash_6D0BB36CD318F55F", nil, "ui_confirm" ) 
			return true
		else
			return false
		end
	end, false ) 
	self:addElement( FindMatchButton ) 
	self.FindMatchButton = FindMatchButton 
	
	DirectorLobbyPoseMembers = CoD.DirectorLobbyPoseMembers.new( f1_arg0, f1_arg1, 0, 1, 0, 0, 0, 1, 0, 0 ) 
	self:addElement( DirectorLobbyPoseMembers ) 
	self.DirectorLobbyPoseMembers = DirectorLobbyPoseMembers 
	
	CompetitiveOverviewRankBanner = CoD.CompetitiveOverviewRankBanner.new( f1_arg0, f1_arg1, 0.5, 0.5, -881, -681, 0, 0, -111.5, 388.5 ) 
	CompetitiveOverviewRankBanner:mergeStateConditions( {
		{
			stateName = "Hidden",
			condition = function ( menu, element, event )
				return not CoD.ArenaUtility.IsArenaLeaguePlay( true )
			end
		},
		{
			stateName = "HiddenCopy",
			condition = function ( menu, element, event )
				local f23_local0 
				if not CoD.ArenaUtility.IsArenaLeaguePlay( false ) then
					f23_local0 = not CoD.ArenaLeaguePlayUtility.HasPoints( self, f1_arg1 ) 
				else
					f23_local0 = false 
				end
				return f23_local0
			end
		},
		{
			stateName = "Lobby",
			condition = function ( menu, element, event )
				return AlwaysTrue()
			end
		}
	} ) 
	local CustomGamesButton = CompetitiveOverviewRankBanner 
	LeagueEventEndDelayMessageTitle = CompetitiveOverviewRankBanner.subscribeToModel 
	local CommonHeader = Engine[@"hash_78DF2E5447F384B9"]() 
	LeagueEventEndDelayMessageTitle( CustomGamesButton, CommonHeader["lobbyRoot.lobbyNav"], function ( f25_arg0 )
		f1_arg0:updateElementState( CompetitiveOverviewRankBanner, {
			name = "model_validation",
			menu = f1_arg0,
			controller = f1_arg1,
			modelValue = f25_arg0:get(),
			modelName = "lobbyRoot.lobbyNav"
		} ) 
	end, false ) 
	CompetitiveOverviewRankBanner:subscribeToGlobalModel( f1_arg1, "LobbyRoot", "lobbyNav", function ( model )
		UpdateSelfElementState( f1_arg0, CompetitiveOverviewRankBanner, f1_arg1 ) 
	end ) 
	self:addElement( CompetitiveOverviewRankBanner ) 
	self.CompetitiveOverviewRankBanner = CompetitiveOverviewRankBanner 
	
	LeagueEventEndDelayMessageTitle = CoD.LeaguePlayEventEndDelayLobbyMessage.new( f1_arg0, f1_arg1, 0.5, 0.5, -691, -179, 0, 0, 55.5, 205.5 ) 
	self:addElement( LeagueEventEndDelayMessageTitle ) 
	self.LeagueEventEndDelayMessageTitle = LeagueEventEndDelayMessageTitle 
	
	CustomGamesButton = CoD.DirectorPreGameButtonOption.new( f1_arg0, f1_arg1, 0.5, 0.5, 514, 896, 1, 1, -522, -476 ) 
	CustomGamesButton:mergeStateConditions( {
		{
			stateName = "Visible",
			condition = function ( menu, element, event )
				local f27_local0 = IsLobbyHostOfCurrentMenu() 
				if f27_local0 then
					f27_local0 = IsArenaMode() 
					if f27_local0 then
						f27_local0 = CoD.DirectorUtility.ShowDirectorArena( f1_arg1 )  
					end
				end
				return f27_local0
			end
		}
	} ) 
	CustomGamesButton:appendEventHandler( "on_session_start", function ( f28_arg0, f28_arg1 )
		f28_arg1.menu = f28_arg1.menu or f1_arg0 
		f1_arg0:updateElementState( CustomGamesButton, f28_arg1 ) 
	end ) 
	CustomGamesButton:appendEventHandler( "on_session_end", function ( f29_arg0, f29_arg1 )
		f29_arg1.menu = f29_arg1.menu or f1_arg0 
		f1_arg0:updateElementState( CustomGamesButton, f29_arg1 ) 
	end ) 
	local DirectorLeaderActivitySelect = CustomGamesButton 
	CommonHeader = CustomGamesButton.subscribeToModel 
	local ArenaEventButtons = Engine[@"hash_78DF2E5447F384B9"]() 
	CommonHeader( DirectorLeaderActivitySelect, ArenaEventButtons["lobbyRoot.lobbyNav"], function ( f30_arg0 )
		f1_arg0:updateElementState( CustomGamesButton, {
			name = "model_validation",
			menu = f1_arg0,
			controller = f1_arg1,
			modelValue = f30_arg0:get(),
			modelName = "lobbyRoot.lobbyNav"
		} ) 
	end, false ) 
	DirectorLeaderActivitySelect = CustomGamesButton 
	CommonHeader = CustomGamesButton.subscribeToModel 
	ArenaEventButtons = Engine[@"hash_78DF2E5447F384B9"]() 
	CommonHeader( DirectorLeaderActivitySelect, ArenaEventButtons["lobbyRoot.gameClient.update"], function ( f31_arg0 )
		f1_arg0:updateElementState( CustomGamesButton, {
			name = "model_validation",
			menu = f1_arg0,
			controller = f1_arg1,
			modelValue = f31_arg0:get(),
			modelName = "lobbyRoot.gameClient.update"
		} ) 
	end, false ) 
	DirectorLeaderActivitySelect = CustomGamesButton 
	CommonHeader = CustomGamesButton.subscribeToModel 
	ArenaEventButtons = Engine[@"hash_78DF2E5447F384B9"]() 
	CommonHeader( DirectorLeaderActivitySelect, ArenaEventButtons["lobbyRoot.privateClient.update"], function ( f32_arg0 )
		f1_arg0:updateElementState( CustomGamesButton, {
			name = "model_validation",
			menu = f1_arg0,
			controller = f1_arg1,
			modelValue = f32_arg0:get(),
			modelName = "lobbyRoot.privateClient.update"
		} ) 
	end, false ) 
	DirectorLeaderActivitySelect = CustomGamesButton 
	CommonHeader = CustomGamesButton.subscribeToModel 
	ArenaEventButtons = Engine[@"hash_78DF2E5447F384B9"]() 
	CommonHeader( DirectorLeaderActivitySelect, ArenaEventButtons.offlineScreenState, function ( f33_arg0 )
		f1_arg0:updateElementState( CustomGamesButton, {
			name = "model_validation",
			menu = f1_arg0,
			controller = f1_arg1,
			modelValue = f33_arg0:get(),
			modelName = "offlineScreenState"
		} ) 
	end, false ) 
	CustomGamesButton.DirectorSelectButtonMiniInternal.MiddleText.__MiddleText_StringReference = function ()
		CustomGamesButton.DirectorSelectButtonMiniInternal.MiddleText:setText( LocalizeToUpperString( CoD.DirectorUtility.GetCustomGamesName( @"hash_685D9C7D7DDC8EE0" ) ) ) 
	end
	 
	CustomGamesButton.DirectorSelectButtonMiniInternal.MiddleText.__MiddleText_StringReference() 
	CustomGamesButton.DirectorSelectButtonMiniInternal.MiddleText:setTTF( "ttmussels_regular" ) 
	CustomGamesButton.DirectorSelectButtonMiniInternal.MiddleTextFocus.__MiddleTextFocus_String = function ()
		CustomGamesButton.DirectorSelectButtonMiniInternal.MiddleTextFocus:setText( LocalizeToUpperString( CoD.DirectorUtility.GetCustomGamesName( @"hash_685D9C7D7DDC8EE0" ) ) ) 
	end
	 
	CustomGamesButton.DirectorSelectButtonMiniInternal.MiddleTextFocus.__MiddleTextFocus_String() 
	CustomGamesButton.DirectorSelectButtonMiniInternal.MiddleTextFocus:setTTF( "ttmussels_regular" ) 
	CustomGamesButton:registerEventHandler( "gain_focus", function ( element, event )
		local f36_local0 = nil 
		if element.gainFocus then
			f36_local0 = element:gainFocus( event ) 
		elseif element.super.gainFocus then
			f36_local0 = element.super:gainFocus( event ) 
		end
		CoD.Menu.UpdateButtonShownState( element, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] ) 
		return f36_local0
	end ) 
	f1_arg0:AddButtonCallbackFunction( CustomGamesButton, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], "ui_confirm", function ( element, menu, controller, model )
		if IsPC() then
			PlaySoundAlias( "uin_press_generic" ) 
			OpenCustomGamesLobby( menu, controller ) 
			return true
		else
			PlaySoundAlias( "uin_press_generic" ) 
			OpenSystemOverlay( self, menu, controller, "CustomGamesNotification" ) 
			SetLoseFocusToSelf( self, controller ) 
			return true
		end
	end, function ( element, menu, controller )
		CoD.Menu.SetButtonLabel( menu, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], @"hash_6D0BB36CD318F55F", nil, "ui_confirm" ) 
		return true
	end, false ) 
	self:addElement( CustomGamesButton ) 
	self.CustomGamesButton = CustomGamesButton 
	
	CommonHeader = CoD.CommonHeader.new( f1_arg0, f1_arg1, 0, 1, 0, 0, 0, 0, 0, 67 ) 
	CommonHeader.subtitle.subtitle:setAlpha( 0 ) 
	CommonHeader.subtitle.subtitle:setText( "" ) 
	CommonHeader:subscribeToGlobalModel( f1_arg1, "Arena", "arenaTitle", function ( model )
		local f39_local0 = model:get() 
		if f39_local0 ~= nil then
			CommonHeader.subtitle.StageTitle:setText( LocalizeToUpperString( f39_local0 ) ) 
		end
	end ) 
	self:addElement( CommonHeader ) 
	self.CommonHeader = CommonHeader 
	
	DirectorLeaderActivitySelect = CoD.DirectorLeaderActivitySelect.new( f1_arg0, f1_arg1, 0.5, 0.5, 625, 930, 0, 0, 8, 57 ) 
	DirectorLeaderActivitySelect:mergeStateConditions( {
		{
			stateName = "Invisible",
			condition = function ( menu, element, event )
				return IsLobbyHostOfCurrentMenu()
			end
		}
	} ) 
	DirectorLeaderActivitySelect:appendEventHandler( "on_session_start", function ( f41_arg0, f41_arg1 )
		f41_arg1.menu = f41_arg1.menu or f1_arg0 
		f1_arg0:updateElementState( DirectorLeaderActivitySelect, f41_arg1 ) 
	end ) 
	DirectorLeaderActivitySelect:appendEventHandler( "on_session_end", function ( f42_arg0, f42_arg1 )
		f42_arg1.menu = f42_arg1.menu or f1_arg0 
		f1_arg0:updateElementState( DirectorLeaderActivitySelect, f42_arg1 ) 
	end ) 
	local ArenaEventProgressButton = DirectorLeaderActivitySelect 
	ArenaEventButtons = DirectorLeaderActivitySelect.subscribeToModel 
	local ArenaTeamDisplay = Engine[@"hash_78DF2E5447F384B9"]() 
	ArenaEventButtons( ArenaEventProgressButton, ArenaTeamDisplay["lobbyRoot.lobbyNav"], function ( f43_arg0 )
		f1_arg0:updateElementState( DirectorLeaderActivitySelect, {
			name = "model_validation",
			menu = f1_arg0,
			controller = f1_arg1,
			modelValue = f43_arg0:get(),
			modelName = "lobbyRoot.lobbyNav"
		} ) 
	end, false ) 
	ArenaEventProgressButton = DirectorLeaderActivitySelect 
	ArenaEventButtons = DirectorLeaderActivitySelect.subscribeToModel 
	ArenaTeamDisplay = Engine[@"hash_78DF2E5447F384B9"]() 
	ArenaEventButtons( ArenaEventProgressButton, ArenaTeamDisplay["lobbyRoot.gameClient.update"], function ( f44_arg0 )
		f1_arg0:updateElementState( DirectorLeaderActivitySelect, {
			name = "model_validation",
			menu = f1_arg0,
			controller = f1_arg1,
			modelValue = f44_arg0:get(),
			modelName = "lobbyRoot.gameClient.update"
		} ) 
	end, false ) 
	ArenaEventProgressButton = DirectorLeaderActivitySelect 
	ArenaEventButtons = DirectorLeaderActivitySelect.subscribeToModel 
	ArenaTeamDisplay = Engine[@"hash_78DF2E5447F384B9"]() 
	ArenaEventButtons( ArenaEventProgressButton, ArenaTeamDisplay["lobbyRoot.privateClient.update"], function ( f45_arg0 )
		f1_arg0:updateElementState( DirectorLeaderActivitySelect, {
			name = "model_validation",
			menu = f1_arg0,
			controller = f1_arg1,
			modelValue = f45_arg0:get(),
			modelName = "lobbyRoot.privateClient.update"
		} ) 
	end, false ) 
	DirectorLeaderActivitySelect:setAlpha( 0 ) 
	self:addElement( DirectorLeaderActivitySelect ) 
	self.DirectorLeaderActivitySelect = DirectorLeaderActivitySelect 
	
	ArenaEventButtons = CoD.ArenaEventButtons.new( f1_arg0, f1_arg1, 0.5, 0.5, 250, 450, 1, 1, -178, -108 ) 
	ArenaEventButtons:setAlpha( 0 ) 
	self:addElement( ArenaEventButtons ) 
	self.ArenaEventButtons = ArenaEventButtons 
	
	ArenaEventProgressButton = CoD.ArenaEventProgressButton.new( f1_arg0, f1_arg1, 0.5, 0.5, 514, 896, 1, 1, -279, -209 ) 
	self:addElement( ArenaEventProgressButton ) 
	self.ArenaEventProgressButton = ArenaEventProgressButton 
	
	ArenaTeamDisplay = CoD.ArenaTeamDisplay.new( f1_arg0, f1_arg1, 0, 0, 1170, 1420, 0, 0, 218.5, 518.5 ) 
	self:addElement( ArenaTeamDisplay ) 
	self.ArenaTeamDisplay = ArenaTeamDisplay 
	
	local ArenaDailyBonus = CoD.ArenaDailyBonus.new( f1_arg0, f1_arg1, 0.5, 0.5, 250, 450, 1, 1, -258, -188 ) 
	ArenaDailyBonus:setAlpha( 0 ) 
	self:addElement( ArenaDailyBonus ) 
	self.ArenaDailyBonus = ArenaDailyBonus 
	
	local ArenaMapAndGameType = CoD.ArenaMapAndGameType.new( f1_arg0, f1_arg1, 0.5, 0.5, 514, 896, 1, 1, -443, -293 ) 
	self:addElement( ArenaMapAndGameType ) 
	self.ArenaMapAndGameType = ArenaMapAndGameType 

	local f1_local16 = CustomGamesButton 
	local f1_local17 = CustomGamesButton.subscribeToModel 
	local f1_local18 = Engine[@"hash_78DF2E5447F384B9"]() 
	f1_local17( f1_local16, f1_local18["lobbyRoot.lobbyNav"], CustomGamesButton.DirectorSelectButtonMiniInternal.MiddleText.__MiddleText_StringReference ) 
	f1_local16 = CustomGamesButton 
	f1_local17 = CustomGamesButton.subscribeToModel 
	f1_local18 = Engine[@"hash_78DF2E5447F384B9"]() 
	f1_local17( f1_local16, f1_local18["lobbyRoot.lobbyNav"], CustomGamesButton.DirectorSelectButtonMiniInternal.MiddleTextFocus.__MiddleTextFocus_String ) 
	self:mergeStateConditions( {
		{
			stateName = "IsPC",
			condition = function ( menu, element, event )
				return IsPC()
			end
		}
	} ) 
	LUI.OverrideFunction_CallOriginalFirst( self, "setState", function ( element, controller, f47_arg2, f47_arg3, f47_arg4 )
		ForceCheckDefaultPCFocus( element, f1_arg0, controller ) 
	end ) 
	self:subscribeToGlobalModel( f1_arg1, "LobbyRoot", "gameClientDataUpdate", function ( model )
		local f48_local0 = self 
		if CoD.DirectorUtility.ShowDirectorArena( f1_arg1 ) then
			CoD.PlayerRoleUtility.UpdatePositionDraftModels( f1_arg1 ) 
		end
	end ) 
	self:subscribeToGlobalModel( f1_arg1, "CharacterSelection", "clientUpdated", function ( model )
		local f49_local0 = self 
		if CoD.DirectorUtility.ShowDirectorArena( f1_arg1 ) then
			CoD.PlayerRoleUtility.UpdatePositionDraftModels( f1_arg1 ) 
		end
	end ) 
	self:subscribeToGlobalModel( f1_arg1, "LobbyRoot", "lobbyNav", function ( model )
		local f50_local0 = self 
		if IsLobbyHost() and CoD.DirectorUtility.IsLobbyMenu( f1_arg1, LuaEnum.UI.DIRECTOR_ONLINE_MP_ARENA_PREGAME ) then
			CoD.PlayerRoleUtility.UpdatePositionDraftModels( f1_arg1 ) 
			UpdateElementState( self, "ArenaTeamDisplay", f1_arg1 ) 
			CoD.BaseUtility.SetDefaultFocusToElement( self, self.FindMatchButton ) 
		elseif not IsLobbyHost() and CoD.DirectorUtility.ShowDirectorArena( f1_arg1 ) then
			CoD.PlayerRoleUtility.UpdatePositionDraftModels( f1_arg1 ) 
			UpdateElementState( self, "ArenaTeamDisplay", f1_arg1 ) 
			CoD.BaseUtility.SetDefaultFocusToElement( self, self.HomeOrPlayList ) 
		end
	end ) 
	self:subscribeToGlobalModel( f1_arg1, "GlobalModel", "LobbyRoot.gameClient.isHost", function ( model )
		local f51_local0 = self 
		UpdateElementState( self, "FindMatchButton", f1_arg1 ) 
	end ) 
	self:subscribeToGlobalModel( f1_arg1, "GlobalModel", "LobbyRoot.privateClient.isHost", function ( model )
		local f52_local0 = self 
		UpdateElementState( self, "FindMatchButton", f1_arg1 ) 
	end ) 
	self:subscribeToGlobalModel( f1_arg1, "GlobalModel", "Arena.triggerEndOfEvent", function ( model )
		local f53_local0 = self 
		if CoD.ModelUtility.IsGlobalDataSourceModelValueTrue( f1_arg1, "Arena", "triggerEndOfEvent" ) and CoD.DirectorUtility.IsLobbyMenu( f1_arg1, LuaEnum.UI.DIRECTOR_ONLINE_MP_ARENA_PREGAME ) then
			OpenSystemOverlay( self, f1_arg0, f1_arg1, "ArenaEventDone", nil ) 
		end
	end ) 
	self:subscribeToGlobalModel( f1_arg1, "GlobalModel", "Arena.arenaLeaguePlayShowEndRankUp", function ( model )
		local f54_local0 = self 
		if CoD.ModelUtility.IsGlobalDataSourceModelValueTrue( f1_arg1, "Arena", "arenaLeaguePlayShowEndRankUp" ) and not CoD.ModelUtility.IsGlobalDataSourceModelValueTrue( f1_arg1, "Arena", "triggerEndOfEvent" ) and CoD.DirectorUtility.IsLobbyMenu( f1_arg1, LuaEnum.UI.DIRECTOR_ONLINE_MP_ARENA_PREGAME ) then
			CoD.ArenaLeaguePlayUtility.OpenLeaguePlayEndRankUp( self, f1_arg1 ) 
			SetGlobalModelValueFalse( "Arena.arenaLeaguePlayShowDelayedResultsPopup" ) 
		end
	end ) 
	self:subscribeToGlobalModel( f1_arg1, "GlobalModel", "Arena.arenaLeaguePlayShowDelayedResultsPopup", function ( model )
		local f55_local0 = self 
		if CoD.ModelUtility.IsGlobalDataSourceModelValueTrue( f1_arg1, "Arena", "arenaLeaguePlayShowDelayedResultsPopup" ) and not CoD.ModelUtility.IsGlobalDataSourceModelValueTrue( f1_arg1, "Arena", "arenaLeaguePlayShowEndRankUp" ) and not CoD.ModelUtility.IsGlobalDataSourceModelValueTrue( f1_arg1, "Arena", "triggerEndOfEvent" ) and CoD.DirectorUtility.IsLobbyMenu( f1_arg1, LuaEnum.UI.DIRECTOR_ONLINE_MP_ARENA_PREGAME ) then
			OpenSystemOverlay( self, f1_arg0, f1_arg1, "Arena_EventEndResultsDelay", nil ) 
			SetGlobalModelValueFalse( "Arena.arenaLeaguePlayShowDelayedResultsPopup" ) 
		end
	end ) 
	if CoD.isPC then
		pckeyboardNavigationRedirector2.id = "pckeyboardNavigationRedirector2" 
	end
	if CoD.isPC then
		pckeyboardNavigationRedirector.id = "pckeyboardNavigationRedirector" 
	end
	FindMatchButton.id = "FindMatchButton" 
	CustomGamesButton.id = "CustomGamesButton" 
	ArenaEventButtons.id = "ArenaEventButtons" 
	ArenaEventProgressButton.id = "ArenaEventProgressButton" 
	ArenaMapAndGameType.id = "ArenaMapAndGameType" 
	LUI.OverrideFunction_CallOriginalSecond( self, "close", self.__onClose ) 
	if PostLoadFunc then
		PostLoadFunc( self, f1_arg1, f1_arg0 ) 
	end
	f1_local17 = self 
	CoD.ArenaUtility.PostLoad( f1_arg1, self ) 
	f1_local17 = pckeyboardNavigationRedirector2 
	if IsPC() then
		CoD.PCUtility.SetAsRedirectItem( f1_local17 ) 
		CoD.BaseUtility.SetCustomNavDirection( CoD.BaseUtility.NavigationDirection.down, f1_local17, self.Loadouts ) 
	end
	f1_local17 = pckeyboardNavigationRedirector 
	if IsPC() then
		CoD.PCUtility.SetAsRedirectItem( f1_local17 ) 
		CoD.BaseUtility.SetCustomNavDirection( CoD.BaseUtility.NavigationDirection.up, f1_local17, self.Loadouts ) 
	end
	return self
end
 
CoD.directorArenaPregame.__onClose = function ( f56_arg0 )
	f56_arg0.Header:close() 
	f56_arg0.pckeyboardNavigationRedirector2:close() 
	f56_arg0.pckeyboardNavigationRedirector:close() 
	f56_arg0.FindMatchButton:close() 
	f56_arg0.DirectorLobbyPoseMembers:close() 
	f56_arg0.CompetitiveOverviewRankBanner:close() 
	f56_arg0.LeagueEventEndDelayMessageTitle:close() 
	f56_arg0.CustomGamesButton:close() 
	f56_arg0.CommonHeader:close() 
	f56_arg0.DirectorLeaderActivitySelect:close() 
	f56_arg0.ArenaEventButtons:close() 
	f56_arg0.ArenaEventProgressButton:close() 
	f56_arg0.ArenaTeamDisplay:close() 
	f56_arg0.ArenaDailyBonus:close() 
	f56_arg0.ArenaMapAndGameType:close() 
end