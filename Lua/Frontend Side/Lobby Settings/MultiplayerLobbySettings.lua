--[[
		.\hksc.exe ".\Lua\MultiplayerLobbySettings.Lua" -o "C:\Program Files (x86)\Call of Duty Black Ops 4\project-bo4\mods\T8ShieldSupport\Lua\MultiplayerLobbySettings.luac"
]]

---------------------------

CoD.ShieldInitLuaFile()

---------------------------

CoD.LobbyUtility.OpenBotSettings = function ( f105_arg0, f105_arg1 )
	CoD.LobbyUtility.SetLeaderActivity( f105_arg1, CoD.LobbyUtility.LeaderActivity.SETTING_UP_BOTS )
	LUI.OverrideFunction_CallOriginalFirst( OpenOverlay( f105_arg0, "Shield_CustomGames_BotSettingsPopup", f105_arg1 ), "close", function ()
		CoD.LobbyUtility.ResetLeaderActivity( f105_arg1 )
	end )
end

CoD.DirectorUtility.GameTypeAllowsBots = function()
	return true
end

CoD.LobbyUtility.CanAddMoreBotsToLobby = function()
	return true
end

local function OnBotHardModeChange ( f137_arg0, f137_arg1, f137_arg2, f137_arg3, f137_arg4 )
	local dvar_name = f137_arg3
	local f137_local1 = Engine[@"getdvarint"]( dvar_name )
	local f137_local2 = f137_arg1.value
	CoD.OptionsUtility.UpdateInfoModels( f137_arg1 )
	if f137_local2 == f137_local1 then
		return 
	else
		Engine[@"setdvar"]( dvar_name, f137_local2 )
	end

	local DvarInt = Engine[@"getdvarint"]( dvar_name )

	if DvarInt == 1 then
		CoD.EnhPrintInfo("Setting Bots to Hard Mode..")
		Dvar[@"bot_maxAllies"]:set(9)
		Dvar[@"bot_maxAxis"]:set(9)
		Dvar[@"bot_maxFree"]:set(10)
		Dvar[@"bot_difficulty"]:set(3) --fix set bot difficulty very hard, the difficulty resets when you return to the lobby
	else
		CoD.EnhPrintInfo("Setting Bots to Normal Mode..")
		Dvar[@"bot_maxAllies"]:set(0)
		Dvar[@"bot_maxAxis"]:set(0)
		Dvar[@"bot_maxFree"]:set(0)
		Dvar[@"bot_difficulty"]:set(1)
	end
end

---------------------------

-- Bot Settings
DataSources.ShieldBotSettings = DataSourceHelpers.ListSetup( "ShieldBotSettings", function ( f138_arg0 )
	local f138_local0 = {}
	table.insert( f138_local0, CoD.OptionsUtility.CreateDvarSettings( f138_arg0, @"hash_40A95F72AAF581A9", @"hash_4CBD385CD19E9EFC", "BotOptions_Difficulty", "bot_difficulty", {
		{
			option = Engine[@"hash_4F9F1239CFD921FE"]( @"hash_2C59B321D25B5BDC" ),
			value = 0
		},
		{
			option = Engine[@"hash_4F9F1239CFD921FE"]( @"hash_248B9B4B38EF1C6B" ),
			value = 1,
			default = true
		},
		{
			option = Engine[@"hash_4F9F1239CFD921FE"]( @"hash_7849A68439C5A3AD" ),
			value = 2
		},
		{
			option = Engine[@"hash_4F9F1239CFD921FE"]( @"hash_28CB70A94994D5BD" ),
			value = 3
		}
	}, nil, CoD.OptionsUtility.OnBotSettingsChange ) )

	table.insert( f138_local0, CoD.OptionsUtility.CreateDvarSettings( f138_arg0, @"shield/bothard", @"shield/bothard_desc", "BotOptions_HardMode", "bot_hardmode", {
		{
			option = Engine[@"hash_4F9F1239CFD921FE"]( @"hash_94EB0E3329EDF5F" ),
			value = 0,
			default = true
		},
		{
			option = Engine[@"hash_4F9F1239CFD921FE"]( @"menu/enabled" ),
			value = 1
		}
	}, nil, OnBotHardModeChange ) )
	return f138_local0
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

-- Custom Settings MP
CoD.DirectorGameSettingList = InheritFrom( LUI.UIElement )
CoD.DirectorGameSettingList.__defaultWidth = 356
CoD.DirectorGameSettingList.__defaultHeight = 420
CoD.DirectorGameSettingList.new = function ( f1_arg0, f1_arg1, f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	local self = LUI.UIVerticalList.new( f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9, 53, false )
	self:setAlignment( LUI.Alignment.Top )
	self:setClass( CoD.DirectorGameSettingList )
	self.id = "DirectorGameSettingList"
	self.soundSet = "none"
	self.onlyChildrenFocusable = true
	self.anyChildUsesUpdateState = true
	f1_arg0:addElementToPendingUpdateStateList( self )
	
	local MapImage = CoD.DirectorMapAndGameType.new( f1_arg0, f1_arg1, 0, 0, 0, 356, 0, 0, 0, 200 )
	MapImage.MapImage.DirectorMapAndGameInternal.PlaylistHeaderBacking:setAlpha( 0 )
	MapImage.MapImage.DirectorMapAndGameInternal.PlaylistHeader:setAlpha( 0 )
	MapImage:subscribeToGlobalModel( f1_arg1, "MapVote", "mapVoteMapNext", function ( model )
		local f2_local0 = model:get()
		if f2_local0 ~= nil then
			MapImage.MapImage.DirectorMapAndGameInternal.GamemodeIcon:setImage( RegisterImage( CoD.GameTypeUtility.GameTypeToImage( f2_local0 ) ) )
		end
	end )
	MapImage:appendEventHandler( "on_session_start", function ( f3_arg0, f3_arg1 )
		f3_arg1.menu = f3_arg1.menu or f1_arg0
		CoD.Menu.UpdateButtonShownState( f3_arg0, f1_arg0, f1_arg1, Enum[@"luibutton"][@"lui_key_xba_pscross"] )
	end )
	MapImage:appendEventHandler( "on_session_end", function ( f4_arg0, f4_arg1 )
		f4_arg1.menu = f4_arg1.menu or f1_arg0
		CoD.Menu.UpdateButtonShownState( f4_arg0, f1_arg0, f1_arg1, Enum[@"luibutton"][@"lui_key_xba_pscross"] )
	end )
	local f1_local2 = MapImage
	local GameRules = MapImage.subscribeToModel
	local f1_local4 = Engine[@"getglobalmodel"]()
	GameRules( f1_local2, f1_local4["lobbyRoot.lobbyNav"], function ( f5_arg0, f5_arg1 )
		CoD.Menu.UpdateButtonShownState( f5_arg1, f1_arg0, f1_arg1, Enum[@"luibutton"][@"lui_key_xba_pscross"] )
	end, false )
	f1_local2 = MapImage
	GameRules = MapImage.subscribeToModel
	f1_local4 = Engine[@"getglobalmodel"]()
	GameRules( f1_local2, f1_local4["lobbyRoot.gameClient.update"], function ( f6_arg0, f6_arg1 )
		CoD.Menu.UpdateButtonShownState( f6_arg1, f1_arg0, f1_arg1, Enum[@"luibutton"][@"lui_key_xba_pscross"] )
	end, false )
	f1_local2 = MapImage
	GameRules = MapImage.subscribeToModel
	f1_local4 = Engine[@"getglobalmodel"]()
	GameRules( f1_local2, f1_local4["lobbyRoot.privateClient.update"], function ( f7_arg0, f7_arg1 )
		CoD.Menu.UpdateButtonShownState( f7_arg1, f1_arg0, f1_arg1, Enum[@"luibutton"][@"lui_key_xba_pscross"] )
	end, false )
	MapImage:registerEventHandler( "gain_focus", function ( element, event )
		local f8_local0 = nil
		if element.gainFocus then
			f8_local0 = element:gainFocus( event )
		elseif element.super.gainFocus then
			f8_local0 = element.super:gainFocus( event )
		end
		CoD.Menu.UpdateButtonShownState( element, f1_arg0, f1_arg1, Enum[@"luibutton"][@"lui_key_xba_pscross"] )
		return f8_local0
	end )
	f1_arg0:AddButtonCallbackFunction( MapImage, f1_arg1, Enum[@"luibutton"][@"lui_key_xba_pscross"], "ui_confirm", function ( element, menu, controller, model )
		if not IsPC() and IsLobbyHostOfCurrentMenu() then
			CoD.DirectorUtility.ClearSelectedClient( controller )
			CoD.LobbyUtility.SetLeaderActivityAndOpenOverlay( self, controller, CoD.LobbyUtility.LeaderActivity.CHOOSING_MAP, "DirectorChooseMapAndGameType" )
			PlaySoundAlias( "uin_toggle_generic" )
			return true
		elseif IsPC() and IsLobbyHostOfCurrentMenu() then
			CoD.DirectorUtility.ClearSelectedClient( controller )
			CoD.LobbyUtility.SetLeaderActivityAndOpenOverlay( self, controller, CoD.LobbyUtility.LeaderActivity.CHOOSING_MAP, "DirectorChooseMapAndGameType" )
			PlaySoundAlias( "uin_toggle_generic" )
			return true
		else
			
		end
	end, function ( element, menu, controller )
		if not IsPC() and IsLobbyHostOfCurrentMenu() then
			CoD.Menu.SetButtonLabel( menu, Enum[@"luibutton"][@"lui_key_xba_pscross"], @"menu/select", nil, "ui_confirm" )
			return true
		elseif IsPC() and IsLobbyHostOfCurrentMenu() then
			CoD.Menu.SetButtonLabel( menu, Enum[@"luibutton"][@"lui_key_xba_pscross"], @"hash_0", nil, "ui_confirm" )
			return false
		else
			return false
		end
	end, false )

	if not IsZombies() then
		self:addElement( MapImage )
	end

	self.MapImage = MapImage
	
	GameRules = CoD.DirectorGameRules.new( f1_arg0, f1_arg1, 0, 0, 0, 356, 0, 0, 253, 453 )
	GameRules:mergeStateConditions( {
		{
			stateName = "Invisible",
			condition = function ( menu, element, event )
				return CoD.DirectorUtility.IsLobbyMenu( f1_arg1, LuaEnum.UI.DIRECTOR_ONLINE_CP_STORY )
			end
		}
	} )
	f1_local4 = GameRules
	f1_local2 = GameRules.subscribeToModel
	local f1_local5 = Engine[@"getglobalmodel"]()
	f1_local2( f1_local4, f1_local5["lobbyRoot.lobbyNav"], function ( f12_arg0 )
		f1_arg0:updateElementState( GameRules, {
			name = "model_validation",
			menu = f1_arg0,
			controller = f1_arg1,
			modelValue = f12_arg0:get(),
			modelName = "lobbyRoot.lobbyNav"
		} )
	end, false )
	GameRules:appendEventHandler( "on_session_start", function ( f13_arg0, f13_arg1 )
		f13_arg1.menu = f13_arg1.menu or f1_arg0
		CoD.Menu.UpdateButtonShownState( f13_arg0, f1_arg0, f1_arg1, Enum[@"luibutton"][@"lui_key_xba_pscross"] )
	end )
	GameRules:appendEventHandler( "on_session_end", function ( f14_arg0, f14_arg1 )
		f14_arg1.menu = f14_arg1.menu or f1_arg0
		CoD.Menu.UpdateButtonShownState( f14_arg0, f1_arg0, f1_arg1, Enum[@"luibutton"][@"lui_key_xba_pscross"] )
	end )
	f1_local4 = GameRules
	f1_local2 = GameRules.subscribeToModel
	f1_local5 = Engine[@"getglobalmodel"]()
	f1_local2( f1_local4, f1_local5["lobbyRoot.lobbyNav"], function ( f15_arg0, f15_arg1 )
		CoD.Menu.UpdateButtonShownState( f15_arg1, f1_arg0, f1_arg1, Enum[@"luibutton"][@"lui_key_xba_pscross"] )
	end, false )
	f1_local4 = GameRules
	f1_local2 = GameRules.subscribeToModel
	f1_local5 = Engine[@"getglobalmodel"]()
	f1_local2( f1_local4, f1_local5["lobbyRoot.gameClient.update"], function ( f16_arg0, f16_arg1 )
		CoD.Menu.UpdateButtonShownState( f16_arg1, f1_arg0, f1_arg1, Enum[@"luibutton"][@"lui_key_xba_pscross"] )
	end, false )
	f1_local4 = GameRules
	f1_local2 = GameRules.subscribeToModel
	f1_local5 = Engine[@"getglobalmodel"]()
	f1_local2( f1_local4, f1_local5["lobbyRoot.privateClient.update"], function ( f17_arg0, f17_arg1 )
		CoD.Menu.UpdateButtonShownState( f17_arg1, f1_arg0, f1_arg1, Enum[@"luibutton"][@"lui_key_xba_pscross"] )
	end, false )
	GameRules:registerEventHandler( "gain_focus", function ( element, event )
		local f18_local0 = nil
		if element.gainFocus then
			f18_local0 = element:gainFocus( event )
		elseif element.super.gainFocus then
			f18_local0 = element.super:gainFocus( event )
		end
		CoD.Menu.UpdateButtonShownState( element, f1_arg0, f1_arg1, Enum[@"luibutton"][@"lui_key_xba_pscross"] )
		return f18_local0
	end )
	f1_arg0:AddButtonCallbackFunction( GameRules, f1_arg1, Enum[@"luibutton"][@"lui_key_xba_pscross"], "ui_confirm", function ( element, menu, controller, model )
		if not IsPC() and IsLobbyHostOfCurrentMenu() then
			CoD.DirectorUtility.ClearSelectedClient( controller )
			CoD.LobbyUtility.OpenEditGameRules( self, controller )
			PlaySoundAlias( "uin_toggle_generic" )
			return true
		elseif IsPC() and IsLobbyHostOfCurrentMenu() then
			CoD.DirectorUtility.ClearSelectedClient( controller )
			CoD.LobbyUtility.OpenEditGameRules( self, controller )
			PlaySoundAlias( "uin_toggle_generic" )
			return true
		else
			
		end
	end, function ( element, menu, controller )
		if not IsPC() and IsLobbyHostOfCurrentMenu() then
			CoD.Menu.SetButtonLabel( menu, Enum[@"luibutton"][@"lui_key_xba_pscross"], @"menu/select", nil, "ui_confirm" )
			return true
		elseif IsPC() and IsLobbyHostOfCurrentMenu() then
			CoD.Menu.SetButtonLabel( menu, Enum[@"luibutton"][@"lui_key_xba_pscross"], @"hash_0", nil, "ui_confirm" )
			return false
		else
			return false
		end
	end, false )
	self:addElement( GameRules )
	self.GameRules = GameRules
	
	self:mergeStateConditions( {
		{
			stateName = "Warzone",
			condition = function ( menu, element, event )
				return IsWarzone()
			end
		}
	} )
	f1_local4 = self
	f1_local2 = self.subscribeToModel
	f1_local5 = Engine[@"getglobalmodel"]()
	f1_local2( f1_local4, f1_local5["lobbyRoot.lobbyNav"], function ( f22_arg0 )
		f1_arg0:updateElementState( self, {
			name = "model_validation",
			menu = f1_arg0,
			controller = f1_arg1,
			modelValue = f22_arg0:get(),
			modelName = "lobbyRoot.lobbyNav"
		} )
	end, false )
	MapImage.id = "MapImage"
	GameRules.id = "GameRules"
	self.__defaultFocus = MapImage
	LUI.OverrideFunction_CallOriginalSecond( self, "close", self.__onClose )
	
	if PostLoadFunc then
		PostLoadFunc( self, f1_arg1, f1_arg0 )
	end
	
	CoD.EnhPrintInfo("Called", "DirectorGameSettingList")

	return self
end

CoD.DirectorGameSettingList.__resetProperties = function ( f23_arg0 )
	f23_arg0.GameRules:completeAnimation()
	f23_arg0.GameRules:setAlpha( 1 )
end

CoD.DirectorGameSettingList.__clipsPerState = {
	DefaultState = {
		DefaultClip = function ( f24_arg0, f24_arg1 )
			f24_arg0:__resetProperties()
			f24_arg0:setupElementClipCounter( 0 )
		end
	},
	Warzone = {
		DefaultClip = function ( f25_arg0, f25_arg1 )
			f25_arg0:__resetProperties()
			f25_arg0:setupElementClipCounter( 1 )
			f25_arg0.GameRules:completeAnimation()
			f25_arg0.GameRules:setAlpha( 0 )
			f25_arg0.clipFinished( f25_arg0.GameRules )
		end
	}
}

CoD.DirectorGameSettingList.__onClose = function ( f26_arg0 )
	f26_arg0.MapImage:close()
	f26_arg0.GameRules:close()
end

-- Add a random button + set 18 clients/bots button..
CoD.DirectorLobbySettingList = InheritFrom( LUI.UIElement )
CoD.DirectorLobbySettingList.__defaultWidth = 356
CoD.DirectorLobbySettingList.__defaultHeight = 200
CoD.DirectorLobbySettingList.new = function ( f1_arg0, f1_arg1, f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	local self = LUI.UIElement.new( f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	self:setClass( CoD.DirectorLobbySettingList )
	self.id = "DirectorLobbySettingList"
	self.soundSet = "none"
	self.onlyChildrenFocusable = true
	self.anyChildUsesUpdateState = true
	f1_arg0:addElementToPendingUpdateStateList( self )

	self:setTopBottom(0, 0, 734, 1300) -- fix launch button
	
	local DirectorCustomCodcaster = CoD.DirectorConfigButton.new( f1_arg0, f1_arg1, 0, 1, 0, 0, 0, 0, 0, 40 )
	DirectorCustomCodcaster:mergeStateConditions( {
		{
			stateName = "invisible",
			condition = function ( menu, element, event )
				return not CoD.CodCasterUtility.IsCodCasterEnabled()
			end
		}
	} )
	DirectorCustomCodcaster.ButtonName:setText( LocalizeToUpperString( @"hash_7700AE5902F5ECF7" ) )
	DirectorCustomCodcaster:appendEventHandler( "input_source_changed", function ( f3_arg0, f3_arg1 )
		f3_arg1.menu = f3_arg1.menu or f1_arg0
		CoD.Menu.UpdateButtonShownState( f3_arg0, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
	end )
	local BotSettingsButton = DirectorCustomCodcaster
	local DirectorCustomLobbySettings = DirectorCustomCodcaster.subscribeToModel
	local AddBotButton = Engine[@"hash_4DF5CFBC1771947"]( f1_arg1 )
	DirectorCustomLobbySettings( BotSettingsButton, AddBotButton.LastInput, function ( f4_arg0, f4_arg1 )
		CoD.Menu.UpdateButtonShownState( f4_arg1, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
	end, false )
	DirectorCustomCodcaster:registerEventHandler( "gain_focus", function ( element, event )
		local f5_local0 = nil
		if element.gainFocus then
			f5_local0 = element:gainFocus( event )
		elseif element.super.gainFocus then
			f5_local0 = element.super:gainFocus( event )
		end
		CoD.Menu.UpdateButtonShownState( element, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
		return f5_local0
	end )
	f1_arg0:AddButtonCallbackFunction( DirectorCustomCodcaster, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], "ui_confirm", function ( element, menu, controller, model )
		if IsMouseOrKeyboard( controller ) then
			SetCharacterModeToCurrentSessionMode( self, element, controller )
			CoD.DirectorUtility.ClearSelectedClient( controller )
			CoD.LobbyUtility.OpenDirectorCodcasterSettings( self, controller )
			PlaySoundAlias( "uin_toggle_generic" )
			return true
		else
			SetCharacterModeToCurrentSessionMode( self, element, controller )
			CoD.DirectorUtility.ClearSelectedClient( controller )
			CoD.LobbyUtility.OpenDirectorCodcasterSettings( self, controller )
			PlaySoundAlias( "uin_toggle_generic" )
			return true
		end
	end, function ( element, menu, controller )
		if IsMouseOrKeyboard( controller ) then
			CoD.Menu.SetButtonLabel( menu, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], @"hash_0", nil, "ui_confirm" )
			return false
		else
			CoD.Menu.SetButtonLabel( menu, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], @"hash_761333AE050EC552", nil, "ui_confirm" )
			return true
		end
	end, false )
	self:addElement( DirectorCustomCodcaster )
	self.DirectorCustomCodcaster = DirectorCustomCodcaster
	
	DirectorCustomLobbySettings = CoD.DirectorConfigButton.new( f1_arg0, f1_arg1, 0, 1, 0, 0, 0, 0, 48, 88 )
	DirectorCustomLobbySettings:mergeStateConditions( {
		{
			stateName = "invisible",
			condition = function ( menu, element, event )
				return CoD.DirectorUtility.IsLobbyMenu( f1_arg1, LuaEnum.UI.DIRECTOR_ONLINE_CP_STORY )
			end
		}
	} )
	AddBotButton = DirectorCustomLobbySettings
	BotSettingsButton = DirectorCustomLobbySettings.subscribeToModel
	local RemoveBotButton = Engine[@"hash_78DF2E5447F384B9"]()
	BotSettingsButton( AddBotButton, RemoveBotButton["lobbyRoot.lobbyNav"], function ( f9_arg0 )
		f1_arg0:updateElementState( DirectorCustomLobbySettings, {
			name = "model_validation",
			menu = f1_arg0,
			controller = f1_arg1,
			modelValue = f9_arg0:get(),
			modelName = "lobbyRoot.lobbyNav"
		} )
	end, false )
	DirectorCustomLobbySettings.ButtonName:setText( LocalizeToUpperString( @"hash_6D4B192986909843" ) )
	DirectorCustomLobbySettings:appendEventHandler( "on_session_start", function ( f10_arg0, f10_arg1 )
		f10_arg1.menu = f10_arg1.menu or f1_arg0
		CoD.Menu.UpdateButtonShownState( f10_arg0, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
	end )
	DirectorCustomLobbySettings:appendEventHandler( "on_session_end", function ( f11_arg0, f11_arg1 )
		f11_arg1.menu = f11_arg1.menu or f1_arg0
		CoD.Menu.UpdateButtonShownState( f11_arg0, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
	end )
	AddBotButton = DirectorCustomLobbySettings
	BotSettingsButton = DirectorCustomLobbySettings.subscribeToModel
	RemoveBotButton = Engine[@"hash_78DF2E5447F384B9"]()
	BotSettingsButton( AddBotButton, RemoveBotButton["lobbyRoot.lobbyNav"], function ( f12_arg0, f12_arg1 )
		CoD.Menu.UpdateButtonShownState( f12_arg1, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
	end, false )
	AddBotButton = DirectorCustomLobbySettings
	BotSettingsButton = DirectorCustomLobbySettings.subscribeToModel
	RemoveBotButton = Engine[@"hash_78DF2E5447F384B9"]()
	BotSettingsButton( AddBotButton, RemoveBotButton["lobbyRoot.gameClient.update"], function ( f13_arg0, f13_arg1 )
		CoD.Menu.UpdateButtonShownState( f13_arg1, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
	end, false )
	AddBotButton = DirectorCustomLobbySettings
	BotSettingsButton = DirectorCustomLobbySettings.subscribeToModel
	RemoveBotButton = Engine[@"hash_78DF2E5447F384B9"]()
	BotSettingsButton( AddBotButton, RemoveBotButton["lobbyRoot.privateClient.update"], function ( f14_arg0, f14_arg1 )
		CoD.Menu.UpdateButtonShownState( f14_arg1, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
	end, false )
	DirectorCustomLobbySettings:appendEventHandler( "input_source_changed", function ( f15_arg0, f15_arg1 )
		f15_arg1.menu = f15_arg1.menu or f1_arg0
		CoD.Menu.UpdateButtonShownState( f15_arg0, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
	end )
	AddBotButton = DirectorCustomLobbySettings
	BotSettingsButton = DirectorCustomLobbySettings.subscribeToModel
	RemoveBotButton = Engine[@"hash_4DF5CFBC1771947"]( f1_arg1 )
	BotSettingsButton( AddBotButton, RemoveBotButton.LastInput, function ( f16_arg0, f16_arg1 )
		CoD.Menu.UpdateButtonShownState( f16_arg1, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
	end, false )
	DirectorCustomLobbySettings:registerEventHandler( "gain_focus", function ( element, event )
		local f17_local0 = nil
		if element.gainFocus then
			f17_local0 = element:gainFocus( event )
		elseif element.super.gainFocus then
			f17_local0 = element.super:gainFocus( event )
		end
		CoD.Menu.UpdateButtonShownState( element, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
		return f17_local0
	end )
	f1_arg0:AddButtonCallbackFunction( DirectorCustomLobbySettings, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], "ui_confirm", function ( element, menu, controller, model )
		if IsLobbyHostOfCurrentMenu() and IsMouseOrKeyboard( controller ) then
			CoD.DirectorUtility.ClearSelectedClient( controller )
			OpenPopup( self, "CustomGames_LobbySettings", controller )
			PlaySoundAlias( "uin_toggle_generic" )
			return true
		elseif IsLobbyHostOfCurrentMenu() then
			CoD.DirectorUtility.ClearSelectedClient( controller )
			OpenPopup( self, "CustomGames_LobbySettings", controller )
			PlaySoundAlias( "uin_toggle_generic" )
			return true
		else
			
		end
	end, function ( element, menu, controller )
		if IsLobbyHostOfCurrentMenu() and IsMouseOrKeyboard( controller ) then
			CoD.Menu.SetButtonLabel( menu, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], @"hash_0", nil, "ui_confirm" )
			return false
		elseif IsLobbyHostOfCurrentMenu() then
			CoD.Menu.SetButtonLabel( menu, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], @"hash_761333AE050EC552", nil, "ui_confirm" )
			return true
		else
			return false
		end
	end, false )
	self:addElement( DirectorCustomLobbySettings )
	self.DirectorCustomLobbySettings = DirectorCustomLobbySettings
	
	BotSettingsButton = CoD.DirectorConfigButton.new( f1_arg0, f1_arg1, 0, 1, 0, 0, 0, 0, 96, 136 )
	BotSettingsButton:mergeStateConditions( {
		{
			stateName = "invisible",
			condition = function ( menu, element, event )
				return false
			end
		}
	} )
	RemoveBotButton = BotSettingsButton
	AddBotButton = BotSettingsButton.subscribeToModel
	local f1_local6 = Engine[@"hash_78DF2E5447F384B9"]()
	AddBotButton( RemoveBotButton, f1_local6["lobbyRoot.lobbyNav"], function ( f21_arg0 )
		f1_arg0:updateElementState( BotSettingsButton, {
			name = "model_validation",
			menu = f1_arg0,
			controller = f1_arg1,
			modelValue = f21_arg0:get(),
			modelName = "lobbyRoot.lobbyNav"
		} )
	end, false )
	RemoveBotButton = BotSettingsButton
	AddBotButton = BotSettingsButton.subscribeToModel
	f1_local6 = Engine[@"hash_78DF2E5447F384B9"]()
	AddBotButton( RemoveBotButton, f1_local6["MapVote.mapVoteGameModeNext"], function ( f22_arg0 )
		f1_arg0:updateElementState( BotSettingsButton, {
			name = "model_validation",
			menu = f1_arg0,
			controller = f1_arg1,
			modelValue = f22_arg0:get(),
			modelName = "MapVote.mapVoteGameModeNext"
		} )
	end, false )
	BotSettingsButton.ButtonName:setText( LocalizeToUpperString( @"hash_65025AFE42DB30DC" ) )
	BotSettingsButton:appendEventHandler( "on_session_start", function ( f23_arg0, f23_arg1 )
		f23_arg1.menu = f23_arg1.menu or f1_arg0
		CoD.Menu.UpdateButtonShownState( f23_arg0, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
	end )
	BotSettingsButton:appendEventHandler( "on_session_end", function ( f24_arg0, f24_arg1 )
		f24_arg1.menu = f24_arg1.menu or f1_arg0
		CoD.Menu.UpdateButtonShownState( f24_arg0, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
	end )
	RemoveBotButton = BotSettingsButton
	AddBotButton = BotSettingsButton.subscribeToModel
	f1_local6 = Engine[@"hash_78DF2E5447F384B9"]()
	AddBotButton( RemoveBotButton, f1_local6["lobbyRoot.lobbyNav"], function ( f25_arg0, f25_arg1 )
		CoD.Menu.UpdateButtonShownState( f25_arg1, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
	end, false )
	RemoveBotButton = BotSettingsButton
	AddBotButton = BotSettingsButton.subscribeToModel
	f1_local6 = Engine[@"hash_78DF2E5447F384B9"]()
	AddBotButton( RemoveBotButton, f1_local6["lobbyRoot.gameClient.update"], function ( f26_arg0, f26_arg1 )
		CoD.Menu.UpdateButtonShownState( f26_arg1, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
	end, false )
	RemoveBotButton = BotSettingsButton
	AddBotButton = BotSettingsButton.subscribeToModel
	f1_local6 = Engine[@"hash_78DF2E5447F384B9"]()
	AddBotButton( RemoveBotButton, f1_local6["lobbyRoot.privateClient.update"], function ( f27_arg0, f27_arg1 )
		CoD.Menu.UpdateButtonShownState( f27_arg1, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
	end, false )
	BotSettingsButton:appendEventHandler( "input_source_changed", function ( f28_arg0, f28_arg1 )
		f28_arg1.menu = f28_arg1.menu or f1_arg0
		CoD.Menu.UpdateButtonShownState( f28_arg0, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
	end )
	RemoveBotButton = BotSettingsButton
	AddBotButton = BotSettingsButton.subscribeToModel
	f1_local6 = Engine[@"hash_4DF5CFBC1771947"]( f1_arg1 )
	AddBotButton( RemoveBotButton, f1_local6.LastInput, function ( f29_arg0, f29_arg1 )
		CoD.Menu.UpdateButtonShownState( f29_arg1, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
	end, false )
	BotSettingsButton:registerEventHandler( "gain_focus", function ( element, event )
		local f30_local0 = nil
		if element.gainFocus then
			f30_local0 = element:gainFocus( event )
		elseif element.super.gainFocus then
			f30_local0 = element.super:gainFocus( event )
		end
		CoD.Menu.UpdateButtonShownState( element, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
		return f30_local0
	end )
	f1_arg0:AddButtonCallbackFunction( BotSettingsButton, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], "ui_confirm", function ( element, menu, controller, model )
		if IsLobbyHostOfCurrentMenu() and IsMouseOrKeyboard( controller ) then
			CoD.DirectorUtility.ClearSelectedClient( controller )
			OpenBotSettings( menu, controller )
			PlaySoundAlias( "uin_toggle_generic" )
			return true
		elseif IsLobbyHostOfCurrentMenu() then
			CoD.DirectorUtility.ClearSelectedClient( controller )
			OpenBotSettings( menu, controller )
			PlaySoundAlias( "uin_toggle_generic" )
			return true
		else
			
		end
	end, function ( element, menu, controller )
		if IsLobbyHostOfCurrentMenu() and IsMouseOrKeyboard( controller ) then
			CoD.Menu.SetButtonLabel( menu, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], @"hash_0", nil, "ui_confirm" )
			return false
		elseif IsLobbyHostOfCurrentMenu() then
			CoD.Menu.SetButtonLabel( menu, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], @"hash_761333AE050EC552", nil, "ui_confirm" )
			return true
		else
			return false
		end
	end, false )
	self:addElement( BotSettingsButton )
	self.BotSettingsButton = BotSettingsButton
	
	AddBotButton = CoD.DirectorConfigButton.new( f1_arg0, f1_arg1, 0, 0.48, 0, 0, 0, 0, 144, 184 )
	AddBotButton:mergeStateConditions( {
		{
			stateName = "invisible",
			condition = function ( menu, element, event )
				return false
			end
		}
	} )
	f1_local6 = AddBotButton
	RemoveBotButton = AddBotButton.subscribeToModel
	local f1_local7 = Engine[@"hash_78DF2E5447F384B9"]()
	RemoveBotButton( f1_local6, f1_local7["lobbyRoot.lobbyNav"], function ( f34_arg0 )
		f1_arg0:updateElementState( AddBotButton, {
			name = "model_validation",
			menu = f1_arg0,
			controller = f1_arg1,
			modelValue = f34_arg0:get(),
			modelName = "lobbyRoot.lobbyNav"
		} )
	end, false )
	f1_local6 = AddBotButton
	RemoveBotButton = AddBotButton.subscribeToModel
	f1_local7 = Engine[@"hash_78DF2E5447F384B9"]()
	RemoveBotButton( f1_local6, f1_local7["MapVote.mapVoteGameModeNext"], function ( f35_arg0 )
		f1_arg0:updateElementState( AddBotButton, {
			name = "model_validation",
			menu = f1_arg0,
			controller = f1_arg1,
			modelValue = f35_arg0:get(),
			modelName = "MapVote.mapVoteGameModeNext"
		} )
	end, false )
	AddBotButton.ButtonName:setText( LocalizeToUpperString( @"hash_141A80D9A928673E" ) )
	AddBotButton:appendEventHandler( "on_session_start", function ( f36_arg0, f36_arg1 )
		f36_arg1.menu = f36_arg1.menu or f1_arg0
		CoD.Menu.UpdateButtonShownState( f36_arg0, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
	end )
	AddBotButton:appendEventHandler( "on_session_end", function ( f37_arg0, f37_arg1 )
		f37_arg1.menu = f37_arg1.menu or f1_arg0
		CoD.Menu.UpdateButtonShownState( f37_arg0, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
	end )
	f1_local6 = AddBotButton
	RemoveBotButton = AddBotButton.subscribeToModel
	f1_local7 = Engine[@"hash_78DF2E5447F384B9"]()
	RemoveBotButton( f1_local6, f1_local7["lobbyRoot.lobbyNav"], function ( f38_arg0, f38_arg1 )
		CoD.Menu.UpdateButtonShownState( f38_arg1, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
	end, false )
	f1_local6 = AddBotButton
	RemoveBotButton = AddBotButton.subscribeToModel
	f1_local7 = Engine[@"hash_78DF2E5447F384B9"]()
	RemoveBotButton( f1_local6, f1_local7["lobbyRoot.gameClient.update"], function ( f39_arg0, f39_arg1 )
		CoD.Menu.UpdateButtonShownState( f39_arg1, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
	end, false )
	f1_local6 = AddBotButton
	RemoveBotButton = AddBotButton.subscribeToModel
	f1_local7 = Engine[@"hash_78DF2E5447F384B9"]()
	RemoveBotButton( f1_local6, f1_local7["lobbyRoot.privateClient.update"], function ( f40_arg0, f40_arg1 )
		CoD.Menu.UpdateButtonShownState( f40_arg1, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
	end, false )
	AddBotButton:appendEventHandler( "input_source_changed", function ( f41_arg0, f41_arg1 )
		f41_arg1.menu = f41_arg1.menu or f1_arg0
		CoD.Menu.UpdateButtonShownState( f41_arg0, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
	end )
	f1_local6 = AddBotButton
	RemoveBotButton = AddBotButton.subscribeToModel
	f1_local7 = Engine[@"hash_4DF5CFBC1771947"]( f1_arg1 )
	RemoveBotButton( f1_local6, f1_local7.LastInput, function ( f42_arg0, f42_arg1 )
		CoD.Menu.UpdateButtonShownState( f42_arg1, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
	end, false )
	AddBotButton:registerEventHandler( "gain_focus", function ( element, event )
		local f43_local0 = nil
		if element.gainFocus then
			f43_local0 = element:gainFocus( event )
		elseif element.super.gainFocus then
			f43_local0 = element.super:gainFocus( event )
		end
		CoD.Menu.UpdateButtonShownState( element, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
		return f43_local0
	end )
	f1_arg0:AddButtonCallbackFunction( AddBotButton, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], "ui_confirm", function ( element, menu, controller, model )
		if IsLobbyHostOfCurrentMenu() and IsBooleanDvarSet( "lobby_hostBots" ) and IsMouseOrKeyboard( controller ) then
			CoD.DirectorUtility.ClearSelectedClient( controller )
			AddLobbyBots( menu, controller )
			return true
		elseif IsLobbyHostOfCurrentMenu() and IsBooleanDvarSet( "lobby_hostBots" ) then
			CoD.DirectorUtility.ClearSelectedClient( controller )
			AddLobbyBots( menu, controller )
			return true
		else
			
		end
	end, function ( element, menu, controller )
		if IsLobbyHostOfCurrentMenu() and IsBooleanDvarSet( "lobby_hostBots" ) and IsMouseOrKeyboard( controller ) then
			CoD.Menu.SetButtonLabel( menu, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], @"hash_0", nil, "ui_confirm" )
			return false
		elseif IsLobbyHostOfCurrentMenu() and IsBooleanDvarSet( "lobby_hostBots" ) then
			CoD.Menu.SetButtonLabel( menu, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], @"hash_761333AE050EC552", nil, "ui_confirm" )
			return true
		else
			return false
		end
	end, false )
	self:addElement( AddBotButton )
	self.AddBotButton = AddBotButton
	
	RemoveBotButton = CoD.DirectorConfigButton.new( f1_arg0, f1_arg1, 0.52, 1, 0, 0, 0, 0, 144, 184 )
	RemoveBotButton:mergeStateConditions( {
		{
			stateName = "invisible",
			condition = function ( menu, element, event )
				return false
			end
		}
	} )
	f1_local7 = RemoveBotButton
	f1_local6 = RemoveBotButton.subscribeToModel
	local f1_local8 = Engine[@"hash_78DF2E5447F384B9"]()
	f1_local6( f1_local7, f1_local8["lobbyRoot.lobbyNav"], function ( f47_arg0 )
		f1_arg0:updateElementState( RemoveBotButton, {
			name = "model_validation",
			menu = f1_arg0,
			controller = f1_arg1,
			modelValue = f47_arg0:get(),
			modelName = "lobbyRoot.lobbyNav"
		} )
	end, false )
	f1_local7 = RemoveBotButton
	f1_local6 = RemoveBotButton.subscribeToModel
	f1_local8 = Engine[@"hash_78DF2E5447F384B9"]()
	f1_local6( f1_local7, f1_local8["MapVote.mapVoteGameModeNext"], function ( f48_arg0 )
		f1_arg0:updateElementState( RemoveBotButton, {
			name = "model_validation",
			menu = f1_arg0,
			controller = f1_arg1,
			modelValue = f48_arg0:get(),
			modelName = "MapVote.mapVoteGameModeNext"
		} )
	end, false )
	RemoveBotButton.ButtonName:setText( LocalizeToUpperString( @"hash_5FD88DBB329D1EC9" ) )  
	RemoveBotButton:appendEventHandler( "on_session_start", function ( f49_arg0, f49_arg1 )
		f49_arg1.menu = f49_arg1.menu or f1_arg0
		CoD.Menu.UpdateButtonShownState( f49_arg0, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
	end )
	RemoveBotButton:appendEventHandler( "on_session_end", function ( f50_arg0, f50_arg1 )
		f50_arg1.menu = f50_arg1.menu or f1_arg0
		CoD.Menu.UpdateButtonShownState( f50_arg0, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
	end )
	f1_local7 = RemoveBotButton
	f1_local6 = RemoveBotButton.subscribeToModel
	f1_local8 = Engine[@"hash_78DF2E5447F384B9"]()
	f1_local6( f1_local7, f1_local8["lobbyRoot.lobbyNav"], function ( f51_arg0, f51_arg1 )
		CoD.Menu.UpdateButtonShownState( f51_arg1, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
	end, false )
	f1_local7 = RemoveBotButton
	f1_local6 = RemoveBotButton.subscribeToModel
	f1_local8 = Engine[@"hash_78DF2E5447F384B9"]()
	f1_local6( f1_local7, f1_local8["lobbyRoot.gameClient.update"], function ( f52_arg0, f52_arg1 )
		CoD.Menu.UpdateButtonShownState( f52_arg1, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
	end, false )
	f1_local7 = RemoveBotButton
	f1_local6 = RemoveBotButton.subscribeToModel
	f1_local8 = Engine[@"hash_78DF2E5447F384B9"]()
	f1_local6( f1_local7, f1_local8["lobbyRoot.privateClient.update"], function ( f53_arg0, f53_arg1 )
		CoD.Menu.UpdateButtonShownState( f53_arg1, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
	end, false )
	RemoveBotButton:appendEventHandler( "input_source_changed", function ( f54_arg0, f54_arg1 )
		f54_arg1.menu = f54_arg1.menu or f1_arg0
		CoD.Menu.UpdateButtonShownState( f54_arg0, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
	end )
	f1_local7 = RemoveBotButton
	f1_local6 = RemoveBotButton.subscribeToModel
	f1_local8 = Engine[@"hash_4DF5CFBC1771947"]( f1_arg1 )
	f1_local6( f1_local7, f1_local8.LastInput, function ( f55_arg0, f55_arg1 )
		CoD.Menu.UpdateButtonShownState( f55_arg1, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
	end, false )
	RemoveBotButton:registerEventHandler( "gain_focus", function ( element, event )
		local f56_local0 = nil
		if element.gainFocus then
			f56_local0 = element:gainFocus( event )
		elseif element.super.gainFocus then
			f56_local0 = element.super:gainFocus( event )
		end
		CoD.Menu.UpdateButtonShownState( element, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
		return f56_local0
	end )
	f1_arg0:AddButtonCallbackFunction( RemoveBotButton, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], "ui_confirm", function ( element, menu, controller, model )
		if IsLobbyHostOfCurrentMenu() and IsBooleanDvarSet( "lobby_hostBots" ) and IsMouseOrKeyboard( controller ) then
			CoD.DirectorUtility.ClearSelectedClient( controller )
			RemoveLobbyBots( self, element, controller, "", menu )
			return true
		elseif IsLobbyHostOfCurrentMenu() and IsBooleanDvarSet( "lobby_hostBots" ) then
			CoD.DirectorUtility.ClearSelectedClient( controller )
			RemoveLobbyBots( self, element, controller, "", menu )
			return true
		else
			
		end
	end, function ( element, menu, controller )
		if IsLobbyHostOfCurrentMenu() and IsBooleanDvarSet( "lobby_hostBots" ) and IsMouseOrKeyboard( controller ) then
			CoD.Menu.SetButtonLabel( menu, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], @"hash_0", nil, "ui_confirm" )
			return false
		elseif IsLobbyHostOfCurrentMenu() and IsBooleanDvarSet( "lobby_hostBots" ) then
			CoD.Menu.SetButtonLabel( menu, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], @"hash_761333AE050EC552", nil, "ui_confirm" )
			return true
		else
			return false
		end
	end, false )
	self:addElement( RemoveBotButton )
	self.RemoveBotButton = RemoveBotButton

	-- not luanch now, random button
	local LaunchGameButton = CoD.DirectorConfigButton.new( f1_arg0, f1_arg1, 0, 1, 0, 0, 0, 0, 96 + 150, 136 + 150 )
	LaunchGameButton:mergeStateConditions( {
		{
			stateName = "invisible",
			condition = function ( menu, element, event )
				return false
			end
		}
	} )

	LaunchGameButton.ButtonName:setText( LocalizeToUpperString( @"hash_6a37c4ba570eedb" ) ) 

	LaunchGameButton:appendEventHandler( "on_session_start", function ( f23_arg0, f23_arg1 )
		f23_arg1.menu = f23_arg1.menu or f1_arg0
		CoD.Menu.UpdateButtonShownState( f23_arg0, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
	end )
	LaunchGameButton:appendEventHandler( "on_session_end", function ( f24_arg0, f24_arg1 )
		f24_arg1.menu = f24_arg1.menu or f1_arg0
		CoD.Menu.UpdateButtonShownState( f24_arg0, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
	end )
	LaunchGameButton:appendEventHandler( "input_source_changed", function ( f28_arg0, f28_arg1 )
		f28_arg1.menu = f28_arg1.menu or f1_arg0
		CoD.Menu.UpdateButtonShownState( f28_arg0, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
	end )

	LaunchGameButton:registerEventHandler( "gain_focus", function ( element, event )
		local f56_local5 = nil
		if element.gainFocus then
			f56_local5 = element:gainFocus( event )
		elseif element.super.gainFocus then
			f56_local5 = element.super:gainFocus( event )
		end
		CoD.Menu.UpdateButtonShownState( element, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
		return f56_local5
	end )
	
	f1_arg0:AddButtonCallbackFunction( LaunchGameButton, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], "ui_confirm", function ( element, menu, controller, model )
		if IsLobbyHostOfCurrentMenu() then
			-- ? select random map and gamemode ?
			-- ! gamemode
			local gamemode_table = {}
			
			for id, gamemode in pairs( CoD.GameTypeUtility.GameTypeTable ) do
				local is_bad = CoD.IsBadGameMode_MP(gamemode.baseGameType)
				if not is_bad then
					table.insert( gamemode_table, gamemode.name )
				end
			end

			if #gamemode_table > 0 then
				SetGameType( controller, gamemode_table[math.random(1, #gamemode_table)] )
			end

			-- ! map
			local map_table = {}
			for map_name, map_data in pairs( CoD.MapUtility.MapsTable ) do
				table.insert( map_table, map_name )
			end

			if #map_table > 0 then
				local map_to_use = map_table[math.random(1, #map_table)]
				SetMap( controller, map_to_use, false )
			end
			
			PlaySoundAlias( "uin_toggle_generic" )
		else
			-- no
		end
	end, function ( element, menu, controller )
		if IsLobbyHostOfCurrentMenu() and IsMouseOrKeyboard( controller ) then
			CoD.Menu.SetButtonLabel( menu, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], @"hash_0", nil, "ui_confirm" )
			return false
		elseif IsLobbyHostOfCurrentMenu()then
			CoD.Menu.SetButtonLabel( menu, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], @"hash_761333AE050EC552", nil, "ui_confirm" )
			return true
		else
			return false
		end
	end, false )
	self:addElement( LaunchGameButton )
	self.LaunchGameButton = LaunchGameButton

	local SetMaxHighClients = CoD.DirectorConfigButton.new( f1_arg0, f1_arg1, 0, 1, 0, 0, 0, 0, 96 + 100, 136 + 100 )
	SetMaxHighClients:mergeStateConditions( {
		{
			stateName = "invisible",
			condition = function ( menu, element, event )
				return false
			end
		}
	} )

	SetMaxHighClients.ButtonName:setText( LocalizeToUpperString( @"hash_39F579200DA477FE" ) ) 

	SetMaxHighClients:appendEventHandler( "on_session_start", function ( f23_arg0, f23_arg1 )
		f23_arg1.menu = f23_arg1.menu or f1_arg0
		CoD.Menu.UpdateButtonShownState( f23_arg0, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
	end )
	SetMaxHighClients:appendEventHandler( "on_session_end", function ( f24_arg0, f24_arg1 )
		f24_arg1.menu = f24_arg1.menu or f1_arg0
		CoD.Menu.UpdateButtonShownState( f24_arg0, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
	end )
	SetMaxHighClients:appendEventHandler( "input_source_changed", function ( f28_arg0, f28_arg1 )
		f28_arg1.menu = f28_arg1.menu or f1_arg0
		CoD.Menu.UpdateButtonShownState( f28_arg0, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
	end )

	SetMaxHighClients:registerEventHandler( "gain_focus", function ( element, event )
		local f56_local6 = nil
		if element.gainFocus then
			f56_local6 = element:gainFocus( event )
		elseif element.super.gainFocus then
			f56_local6 = element.super:gainFocus( event )
		end
		CoD.Menu.UpdateButtonShownState( element, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
		return f56_local6
	end )

	f1_arg0:AddButtonCallbackFunction( SetMaxHighClients, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], "ui_confirm", function ( element, menu, controller, model )
		if IsLobbyHostOfCurrentMenu() and IsMouseOrKeyboard( controller ) then
			-- set max clients
			PlaySoundAlias( "uin_toggle_generic" )
			Engine[@"setlobbymaxclients"](Enum[@"lobbytype"][@"lobby_type_game"], 18) 
			Engine[@"setlobbymaxclients"](Enum[@"lobbytype"][@"lobby_type_private"], 18)
			Engine[@"setlobbymaxclients"](Engine[@"getprimarycontroller"](), 18)
			Dvar[@"hash_4FF45B41C6046F8"]:set(18)
			Engine[@"setmodelvalue"](Engine[@"createmodel"]( Engine[@"createmodel"]( Engine[@"getglobalmodel"](), "PartyPrivacy" ), "maxPlayers" ), 18)
			return true
		elseif IsLobbyHostOfCurrentMenu() then
			-- set max clients
			PlaySoundAlias( "uin_toggle_generic" )
			Engine[@"setlobbymaxclients"](Enum[@"lobbytype"][@"lobby_type_game"], 18)
			Engine[@"setlobbymaxclients"](Enum[@"lobbytype"][@"lobby_type_private"], 18)
			Engine[@"setlobbymaxclients"](Engine[@"getprimarycontroller"](), 18)
			Dvar[@"hash_4FF45B41C6046F8"]:set(18)
			Engine[@"setmodelvalue"](Engine[@"createmodel"]( Engine[@"createmodel"]( Engine[@"getglobalmodel"](), "PartyPrivacy" ), "maxPlayers" ), 18)
			return true
		else
			-- no
		end
	end, function ( element, menu, controller )
		if IsLobbyHostOfCurrentMenu() and IsMouseOrKeyboard( controller ) then
			CoD.Menu.SetButtonLabel( menu, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], @"hash_0", nil, "ui_confirm" )
			return false
		elseif IsLobbyHostOfCurrentMenu()then
			CoD.Menu.SetButtonLabel( menu, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], @"hash_761333AE050EC552", nil, "ui_confirm" )
			return true
		else
			return false
		end
	end, false )
	self:addElement( SetMaxHighClients )
	self.SetMaxHighClients = SetMaxHighClients
	
	self:mergeStateConditions( {
		{
			stateName = "NoCodCaster",
			condition = function ( menu, element, event )
				return AlwaysFalse()
			end
		}
	} )

	DirectorCustomCodcaster.id = "DirectorCustomCodcaster"
	DirectorCustomLobbySettings.id = "DirectorCustomLobbySettings"
	BotSettingsButton.id = "BotSettingsButton"
	AddBotButton.id = "AddBotButton"
	RemoveBotButton.id = "RemoveBotButton"
	LaunchGameButton.id = "LaunchGameButton" 
	SetMaxHighClients.id = "SetMaxHighClients"

	LUI.OverrideFunction_CallOriginalSecond( self, "close", self.__onClose )
	
	if PostLoadFunc then
		PostLoadFunc( self, f1_arg1, f1_arg0 )
	end
	
	return self
end

CoD.DirectorLobbySettingList.__resetProperties = function ( f60_arg0 )
	f60_arg0.DirectorCustomCodcaster:completeAnimation()
	f60_arg0.RemoveBotButton:completeAnimation()
	f60_arg0.AddBotButton:completeAnimation()
	f60_arg0.DirectorCustomLobbySettings:completeAnimation()
	f60_arg0.BotSettingsButton:completeAnimation()
	f60_arg0.DirectorCustomCodcaster:setAlpha( 1 )
	f60_arg0.RemoveBotButton:setTopBottom( 0, 0, 144, 184 )
	f60_arg0.AddBotButton:setTopBottom( 0, 0, 144, 184 )
	f60_arg0.DirectorCustomLobbySettings:setTopBottom( 0, 0, 48, 88 )
	f60_arg0.BotSettingsButton:setTopBottom( 0, 0, 96, 136 )
end

CoD.DirectorLobbySettingList.__clipsPerState = {
	DefaultState = {
		DefaultClip = function ( f61_arg0, f61_arg1 )
			f61_arg0:__resetProperties()
			f61_arg0:setupElementClipCounter( 0 )
		end
	},
	NoCodCaster = {
		DefaultClip = function ( f62_arg0, f62_arg1 )
			f62_arg0:__resetProperties()
			f62_arg0:setupElementClipCounter( 5 )
			f62_arg0.DirectorCustomCodcaster:completeAnimation()
			f62_arg0.DirectorCustomCodcaster:setAlpha( 0 )
			f62_arg0.clipFinished( f62_arg0.DirectorCustomCodcaster )
			f62_arg0.DirectorCustomLobbySettings:completeAnimation()
			f62_arg0.DirectorCustomLobbySettings:setTopBottom( 0, 0, 1, 41 )
			f62_arg0.clipFinished( f62_arg0.DirectorCustomLobbySettings )
			f62_arg0.BotSettingsButton:completeAnimation()
			f62_arg0.BotSettingsButton:setTopBottom( 0, 0, 48, 88 )
			f62_arg0.clipFinished( f62_arg0.BotSettingsButton )
			f62_arg0.AddBotButton:completeAnimation()
			f62_arg0.AddBotButton:setTopBottom( 0, 0, 96, 136 )
			f62_arg0.clipFinished( f62_arg0.AddBotButton )
			f62_arg0.RemoveBotButton:completeAnimation()
			f62_arg0.RemoveBotButton:setTopBottom( 0, 0, 96, 136 )
			f62_arg0.clipFinished( f62_arg0.RemoveBotButton )
		end
	}
}

CoD.DirectorLobbySettingList.__onClose = function ( f63_arg0 )
	f63_arg0.DirectorCustomCodcaster:close()
	f63_arg0.DirectorCustomLobbySettings:close()
	f63_arg0.BotSettingsButton:close()
	f63_arg0.AddBotButton:close()
	f63_arg0.RemoveBotButton:close()
end

-- Custom Bots Settings..
CoD.Shield_CustomGames_BotSettingsPopup = InheritFrom( CoD.Menu )
LUI.createMenu.Shield_CustomGames_BotSettingsPopup = function ( f1_arg0, f1_arg1 )
	local self = CoD.Menu.NewForUIEditor( "Shield_CustomGames_BotSettingsPopup", f1_arg0 )
	local f1_local1 = self
	self:setClass( CoD.Shield_CustomGames_BotSettingsPopup )
	self.soundSet = "none"
	self:setOwner( f1_arg0 )
	self:setLeftRight( 0, 1, 0, 0 )
	self:setTopBottom( 0, 1, 0, 0 )
	self:playSound( "menu_open", f1_arg0 )
	self.anyChildUsesUpdateState = true
	f1_local1:addElementToPendingUpdateStateList( self )
	
	local CommomCenteredPopup = CoD.CommonCenteredPopup.new( f1_local1, f1_arg0, 0, 1, 0, 0, 0, 1, 0, 0 )
	CommomCenteredPopup.TitleText:setText( LocalizeToUpperString( @"hash_65025AFE42DB30DC" ) )
	CommomCenteredPopup.HeaderBackground:setAlpha( 0 )
	CommomCenteredPopup.HeaderTopBar:setAlpha( 0 )
	CommomCenteredPopup.HeaderBottomBar:setAlpha( 0 )
	self:addElement( CommomCenteredPopup )
	self.CommomCenteredPopup = CommomCenteredPopup
	
	local BotSettingsList = LUI.UIList.new( f1_local1, f1_arg0, 3, 3, nil, false, false, false, false )
	BotSettingsList:setLeftRight( 0.5, 0.5, -250, 250 )
	BotSettingsList:setTopBottom( 0.5, 0.5, -380 + 30, -320 + 30 )
	BotSettingsList:setAutoScaleContent( true )
	BotSettingsList:setVerticalCount(3) -- fix
	BotSettingsList:setHorizontalCount(1)
	BotSettingsList:setWidgetType( CoD.CustomGames_SettingSliderNoCustom )
	BotSettingsList:setAlignment( Enum[@"luialignment"][@"lui_alignment_left"] )
	BotSettingsList:setDataSource( "ShieldBotSettings" )
	self:addElement( BotSettingsList )
	self.BotSettingsList = BotSettingsList
	
	local SettingDescription = LUI.UIText.new( 0.5, 0.5, -250, 250, 0.5, 0.5, -284 + 75, -263 + 75 )
	SettingDescription:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )
	SettingDescription:setTTF( "dinnext_regular" )
	SettingDescription:setAlignment( Enum[@"luialignment"][@"lui_alignment_left"] )
	SettingDescription:setAlignment( Enum[@"luialignment"][@"lui_alignment_top"] )
	self:addElement( SettingDescription )
	self.SettingDescription = SettingDescription
	
	local PCSmallCloseButton = nil
	
	--[[
	PCSmallCloseButton = CoD.PC_SmallCloseButton.new( f1_local1, f1_arg0, 0.5, 0.5, 308, 342, 0.5, 0.5, -438.5, -404.5 )
	PCSmallCloseButton:registerEventHandler( "gain_focus", function ( element, event )
		local f2_local0 = nil
		if element.gainFocus then
			f2_local0 = element:gainFocus( event )
		elseif element.super.gainFocus then
			f2_local0 = element.super:gainFocus( event )
		end
		CoD.Menu.UpdateButtonShownState( element, f1_local1, f1_arg0, Enum[@"luibutton"][@"lui_key_none"] )
		return f2_local0
	end )
	f1_local1:AddButtonCallbackFunction( PCSmallCloseButton, f1_arg0, Enum[@"luibutton"][@"lui_key_none"], "MOUSE1", function ( element, menu, controller, model )
		GoBack( self, controller )
		return true
	end, function ( element, menu, controller )
		CoD.Menu.SetButtonLabel( menu, Enum[@"luibutton"][@"lui_key_none"], @"hash_0", nil, "MOUSE1" )
		return false
	end, false )
	f1_local1:AddButtonCallbackFunction( PCSmallCloseButton, f1_arg0, Enum[@"luibutton"][@"lui_key_none"], "ui_confirm", function ( element, menu, controller, model )
		GoBack( self, controller )
		return true
	end, function ( element, menu, controller )
		CoD.Menu.SetButtonLabel( menu, Enum[@"luibutton"][@"lui_key_none"], @"hash_0", nil, "ui_confirm" )
		return false
	end, false )
	self:addElement( PCSmallCloseButton )
	self.PCSmallCloseButton = PCSmallCloseButton
	]]
	
	SettingDescription:linkToElementModel( BotSettingsList, "desc", true, function ( model )
		local f7_local0 = model:get()
		if f7_local0 ~= nil then
			SettingDescription:setText( Engine[@"hash_4F9F1239CFD921FE"]( f7_local0 ) )
		end
	end )
	self:mergeStateConditions( {
		{
			stateName = "KBM",
			condition = function ( menu, element, event )
				return IsMouseOrKeyboard( f1_arg0 )
			end
		}
	} )
	self:appendEventHandler( "input_source_changed", function ( f9_arg0, f9_arg1 )
		f9_arg1.menu = f9_arg1.menu or f1_local1
		f1_local1:updateElementState( self, f9_arg1 )
	end )
	local f1_local6 = self
	local f1_local7 = self.subscribeToModel
	local f1_local8 = Engine[@"getmodelforcontroller"]( f1_arg0 )
	f1_local7( f1_local6, f1_local8.LastInput, function ( f10_arg0 )
		f1_local1:updateElementState( self, {
			name = "model_validation",
			menu = f1_local1,
			controller = f1_arg0,
			modelValue = f10_arg0:get(),
			modelName = "LastInput"
		} )
	end, false )
	f1_local1:AddButtonCallbackFunction( self, f1_arg0, Enum[@"luibutton"][@"lui_key_xbb_pscircle"], nil, function ( element, menu, controller, model )
		GoBack( self, controller )
		ClearMenuSavedState( menu )
		ForceNotifyGlobalModel( controller, "GametypeSettings.Update" )
		return true
	end, function ( element, menu, controller )
		CoD.Menu.SetButtonLabel( menu, Enum[@"luibutton"][@"lui_key_xbb_pscircle"], @"menu/back", nil, nil )
		return true
	end, false )
	CommomCenteredPopup.buttons:setModel( self.buttonModel, f1_arg0 )
	if CoD.isPC then
		CommomCenteredPopup.id = "CommomCenteredPopup"
	end
	BotSettingsList.id = "BotSettingsList"
	--if CoD.isPC then
	--	PCSmallCloseButton.id = "PCSmallCloseButton"
	--end
	self:processEvent( {
		name = "menu_loaded",
		controller = f1_arg0
	} )
	self.__defaultFocus = BotSettingsList
	if CoD.isPC and (IsKeyboard( f1_arg0 ) or self.ignoreCursor) then
		self:restoreState( f1_arg0 )
	end
	LUI.OverrideFunction_CallOriginalSecond( self, "close", self.__onClose )
	if PostLoadFunc then
		PostLoadFunc( self, f1_arg0 )
	end
	
	f1_local7 = self
	--MenuHidesFreeCursor( f1_local1, f1_arg0 )

	CoD.EnhPrintInfo("Called", "Shield's Bot Settings Menu")

	return self
end

CoD.Shield_CustomGames_BotSettingsPopup.__resetProperties = function ( f13_arg0 )
	f13_arg0.BotSettingsList:completeAnimation()
	f13_arg0.SettingDescription:completeAnimation()
	f13_arg0.BotSettingsList:setLeftRight( 0.5, 0.5, -250, 250 )
	f13_arg0.SettingDescription:setLeftRight( 0.5, 0.5, -250, 250 )
end

CoD.Shield_CustomGames_BotSettingsPopup.__clipsPerState = {
	DefaultState = {
		DefaultClip = function ( f14_arg0, f14_arg1 )
			f14_arg0:__resetProperties()
			f14_arg0:setupElementClipCounter( 0 )
		end
	},
	KBM = {
		DefaultClip = function ( f15_arg0, f15_arg1 )
			f15_arg0:__resetProperties()
			f15_arg0:setupElementClipCounter( 2 )
			f15_arg0.BotSettingsList:completeAnimation()
			f15_arg0.BotSettingsList:setLeftRight( 0.5, 0.5, -290, 290 )
			f15_arg0.clipFinished( f15_arg0.BotSettingsList )
			f15_arg0.SettingDescription:completeAnimation()
			f15_arg0.SettingDescription:setLeftRight( 0.5, 0.5, -290, 290 )
			f15_arg0.clipFinished( f15_arg0.SettingDescription )
		end
	}
}

CoD.Shield_CustomGames_BotSettingsPopup.__onClose = function ( f16_arg0 )
	f16_arg0.SettingDescription:close()
	f16_arg0.CommomCenteredPopup:close()
	f16_arg0.BotSettingsList:close()
	--f16_arg0.PCSmallCloseButton:close()
end