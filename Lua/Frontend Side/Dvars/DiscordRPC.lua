--[[
		.\hksc.exe ".\Lua\DiscordRPC.Lua" -o "C:\Program Files (x86)\Call of Duty Black Ops 4\project-bo4\mods\T8ShieldSupport\Lua\DiscordRPC.luac"
]]

---------------------------

CoD.ShieldInitLuaFile()

---------------------------

CoD.SetRPCpDifficulty = function(Diff)
	if Diff == 0 then
		Engine[@"exec"](Engine[@"getprimarycontroller"](), "set shield_rpc_zm_difficulty " .. "Casual")
	elseif Diff == 1 then
		Engine[@"exec"](Engine[@"getprimarycontroller"](), "set shield_rpc_zm_difficulty " .. "Normal")
	elseif Diff == 2 then
		Engine[@"exec"](Engine[@"getprimarycontroller"](), "set shield_rpc_zm_difficulty " .. "Hardcore")
	elseif Diff == 3 then
		Engine[@"exec"](Engine[@"getprimarycontroller"](), "set shield_rpc_zm_difficulty " .. "Realistic")
	end
end

CoD.ZombieUtility.SelectTutorialMapDifficulty = function ( f167_arg0, f167_arg1 )
	local f167_local0 = Engine[@"getglobalmodel"]()
	f167_local0 = f167_local0:create( "lobbyRoot.selectedGameType" )
	if f167_local0 and f167_local0:get() == @"ztutorial" then
		local f167_local1 = Engine[@"getdvarint"]( "shield_zombies_difficulty" )

		CoD.SetRPCpDifficulty(f167_local1)

		if f167_local1 and f167_local1:get() then
			f167_local1 = f167_local1:get()
			if IsLobbyNetworkModeLAN() then
				Engine[@"setgametypesetting"]( "zmDifficulty", f167_local1 )
				CoD.ZombieUtility.SetLocalZMDifficultyModel( f167_local1 )
				local f167_local2 = Engine[@"lobbygetcontrollinglobbysession"]( Enum[@"lobbymodule"][@"lobby_module_host"] )
				Engine[@"lobbyevent"]( "OnGametypeSettingsChange", {
					lobbyModule = Enum[@"lobbymodule"][@"lobby_module_host"],
					lobbyType = f167_local2,
					fromUI = true
				} )
				Engine[@"lobbyhostsessionsetdirty"]( f167_local2, Enum[@"sessiondirty"][@"session_dirty_state"] )
			end
		end
	elseif f167_local0 and f167_local0:get() == @"ztrials" then
		local f167_local1 = CoD.SafeGetModelValue( f167_arg0:getModel(), "trialVariant" )
		if f167_local1 and IsLobbyNetworkModeLAN() then
			Engine[@"setgametypesetting"]( "zmTrialsVariant", f167_local1 )
			CoD.ZombieUtility.SetLocalZMTrialVariantModel( f167_local1 )
			local f167_local2 = Engine[@"lobbygetcontrollinglobbysession"]( Enum[@"lobbymodule"][@"lobby_module_host"] )
			Engine[@"lobbyevent"]( "OnGametypeSettingsChange", {
				lobbyModule = Enum[@"lobbymodule"][@"lobby_module_host"],
				lobbyType = f167_local2,
				fromUI = true
			} )
			Engine[@"lobbyhostsessionsetdirty"]( f167_local2, Enum[@"sessiondirty"][@"session_dirty_state"] )
		end
	end
end

CoD.ZombieUtility.SelectDifficulty = function ( f164_arg0, f164_arg1 )
	local f164_local0 = f164_arg0:getModel( f164_arg1, "difficultyID" )
	f164_local0 = f164_local0:get()
	local f164_local1 = Engine[@"getglobalmodel"]()
	f164_local1 = f164_local1:create( "ZMLobbyExclusions" )
	f164_local1 = f164_local1:create( "ZMPrivateDifficulty" )
	f164_local1:set( f164_local0 )

	-- zombies for diff fix
	local Diff = f164_local0

	if Diff ~= nil then
		Engine[@"exec"](Engine[@"getprimarycontroller"](), "set shield_zombies_difficulty " .. Diff)
	else
		Engine[@"exec"](Engine[@"getprimarycontroller"](), "set shield_zombies_difficulty " .. 1)
	end

	CoD.SetRPCpDifficulty(Diff)

	if IsLobbyNetworkModeLAN() then
		Engine[@"setgametypesetting"]("zmDifficulty", f164_local0 )
		CoD.ZombieUtility.SetLocalZMDifficultyModel( f164_local0 )
		local f164_local2 = Engine[@"lobbygetcontrollinglobbysession"]( Enum[@"lobbymodule"][@"lobby_module_host"] )
		Engine[@"lobbyevent"]( "OnGametypeSettingsChange", {
			lobbyModule = Enum[@"lobbymodule"][@"lobby_module_host"],
			lobbyType = f164_local2,
			fromUI = true
		} )
		Engine[@"lobbyhostsessionsetdirty"]( f164_local2, Enum[@"sessiondirty"][@"session_dirty_state"] )
	end
end

CoD.ZombieUtility.SetDefaultGameTypeZMDifficulty = function ( f94_arg0 )
	if f94_arg0 then
		local f94_local0 = Engine[@"getdvarint"]( "shield_zombies_difficulty" )

		--==if f94_arg0 == "ztutorial" then
		--	f94_local0 = 0
		--end

		CoD.SetRPCpDifficulty(f94_local0)

		Engine[@"setgametypesetting"]( "zmDifficulty", f94_local0 )
		CoD.ZombieUtility.SetLocalZMDifficultyModel( f94_local0 )
		local f94_local1 = Engine[@"lobbygetcontrollinglobbysession"]( Enum[@"lobbymodule"][@"lobby_module_host"] )
		Engine[@"lobbyevent"]( "OnGametypeSettingsChange", {
			lobbyModule = Enum[@"lobbymodule"][@"lobby_module_host"],
			lobbyType = f94_local1,
			fromUI = true
		} )
		Engine[@"lobbyhostsessionsetdirty"]( f94_local1, Enum[@"sessiondirty"][@"session_dirty_state"] )
	end
end

CoD.RefreshRPCDvars = function()
	CoD.SetRPCpDifficulty(Engine[@"getdvarint"]( "shield_zombies_difficulty" ))
end

---------------------------

-- discord rpc stuff, get mapname, gametype, etc. for c++ to use the dvars
-- mp rpc
CoD.MapVote = InheritFrom( LUI.UIElement )
CoD.MapVote.__defaultWidth = 911
CoD.MapVote.__defaultHeight = 215
CoD.MapVote.new = function ( f1_arg0, f1_arg1, f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	local self = LUI.UIElement.new( f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	self:setClass( CoD.MapVote )
	self.id = "MapVote"
	self.soundSet = "default"
	self.onlyChildrenFocusable = true
	self.anyChildUsesUpdateState = true
	f1_arg0:addElementToPendingUpdateStateList( self )
	
	local MapVoteItemVoteDecided = CoD.MapVoteItem.new( f1_arg0, f1_arg1, 0, 0, 0, 263, 0, 0, 37, 217 )
	MapVoteItemVoteDecided:mergeStateConditions( {
		{
			stateName = "Selected",
			condition = function ( menu, element, event )
				return AlwaysTrue()
			end
		}
	} )
	MapVoteItemVoteDecided:setAlpha( 0 )
	MapVoteItemVoteDecided.VoteType:setAlpha( 0 )
	MapVoteItemVoteDecided.VoteType:setText( "" )
	MapVoteItemVoteDecided.voteCount:setText( "" )
	MapVoteItemVoteDecided:subscribeToGlobalModel( f1_arg1, "MapVote", "mapVoteMapNext", function ( model )
		local f3_local0 = model:get()
		if f3_local0 ~= nil then
			MapVoteItemVoteDecided.MapImage:setImage( RegisterImage( MapNameToMapLoadingImage( f1_arg1, f3_local0 ) ) )

			local CleanString = string.sub(CoD.MapUtility.MapNameToLocalizedToUpperName( f3_local0 ), 2, #CoD.MapUtility.MapNameToLocalizedToUpperName( f3_local0 ) - 1)

			if CleanString ~= "" then
				Dvar[@"shield_rpc_Map"]:set(CleanString)
				Dvar[@"shield_rpc_Map_asset"]:set(Engine[@"lobbygetmap"]())
			end
		end
	end )
	MapVoteItemVoteDecided:subscribeToGlobalModel( f1_arg1, "MapVote", "mapVoteMapNext", function ( model )
		local f4_local0 = model:get()
		if f4_local0 ~= nil then
			MapVoteItemVoteDecided.MapVoteMapNameGameModeLayout.MapName:setText( CoD.MapUtility.MapNameToLocalizedToUpperName( f4_local0 ) )

			local CleanString = string.sub(CoD.MapUtility.MapNameToLocalizedToUpperName( f4_local0 ), 2, #CoD.MapUtility.MapNameToLocalizedToUpperName( f4_local0 ) - 1)

			if CleanString ~= "" then
				Dvar[@"shield_rpc_Map"]:set(CleanString)
				Dvar[@"shield_rpc_Map_asset"]:set(Engine[@"lobbygetmap"]())
			end
		end
	end )
	MapVoteItemVoteDecided:subscribeToGlobalModel( f1_arg1, "MapVote", "mapVoteGameModeNext", function ( model )
		local f5_local0 = model:get()
		if f5_local0 ~= nil then
			MapVoteItemVoteDecided.MapVoteMapNameGameModeLayout.GameMode:setText( CoD.GameTypeUtility.GameTypeToLocalizeToUpperName( f5_local0 ) )

			local CleanString = string.sub(CoD.GameTypeUtility.GameTypeToLocalizeToUpperName( f5_local0 ), 2, #CoD.GameTypeUtility.GameTypeToLocalizeToUpperName( f5_local0 ) - 1)

			Dvar[@"shield_rpc_Gametype"]:set(CleanString)

			-- if wz, no name for map
			if string.find( CleanString, "QUADS" ) or string.find( CleanString, "DUOS" ) or string.find( CleanString, "SOLO" ) then
				Dvar[@"shield_rpc_Map"]:set("Blackout")
			end

		end
	end )
	MapVoteItemVoteDecided:subscribeToGlobalModel( f1_arg1, "MapVote", "mapVoteGameModeNext", function ( model )
		local f6_local0 = model:get()
		if f6_local0 ~= nil then
			MapVoteItemVoteDecided.GameModeIcon:setImage( RegisterImage( CoD.GameTypeUtility.GameTypeToImage( f6_local0 ) ) )
		end
	end )
	self:addElement( MapVoteItemVoteDecided )
	self.MapVoteItemVoteDecided = MapVoteItemVoteDecided
	
	local MapVoteItemRandom = CoD.MapVoteItem.new( f1_arg0, f1_arg1, 0, 0, 538, 801, 0, 0, 37, 217 )
	MapVoteItemRandom.MapImage:setImage( RegisterImage( @"uie_lui_random_map_vote" ) )
	MapVoteItemRandom.MapVoteMapNameGameModeLayout.MapName:setText( LocalizeToUpperString( @"menu/classified" ) )
	MapVoteItemRandom.MapVoteMapNameGameModeLayout.GameMode:setText( LocalizeToUpperString( @"menu/mode_classified" ) )
	MapVoteItemRandom.GameModeIcon:setImage( RegisterImage( @"blacktransparent" ) )
	MapVoteItemRandom.VoteType:setText( LocalizeToUpperString( @"menu/random" ) )
	MapVoteItemRandom:subscribeToGlobalModel( f1_arg1, "MapVote", "mapVoteCountRandom", function ( model )
		local f7_local0 = model:get()
		if f7_local0 ~= nil then
			MapVoteItemRandom.voteCount:setText( f7_local0 )
		end
	end )
	MapVoteItemRandom:registerEventHandler( "lobby_map_vote_random_chosen", function ( element, event )
		local f8_local0 = nil
		PlayClip( self, "MapVoteChosenRandom", f1_arg1 )
		if not f8_local0 then
			f8_local0 = element:dispatchEventToChildren( event )
		end
		return f8_local0
	end )
	MapVoteItemRandom:registerEventHandler( "gain_focus", function ( element, event )
		local f9_local0 = nil
		if element.gainFocus then
			f9_local0 = element:gainFocus( event )
		elseif element.super.gainFocus then
			f9_local0 = element.super:gainFocus( event )
		end
		CoD.Menu.UpdateButtonShownState( element, f1_arg0, f1_arg1, Enum[@"luibutton"][@"lui_key_xba_pscross"] )
		return f9_local0
	end )
	f1_arg0:AddButtonCallbackFunction( MapVoteItemRandom, f1_arg1, Enum[@"luibutton"][@"lui_key_xba_pscross"], "ui_confirm", function ( element, menu, controller, model )
		CoD.LobbyUtility.LobbyMapVoteSelectRandom( self, controller )
		return true
	end, function ( element, menu, controller )
		CoD.Menu.SetButtonLabel( menu, Enum[@"luibutton"][@"lui_key_xba_pscross"], @"menu/select", nil, "ui_confirm" )
		return true
	end, false )
	self:addElement( MapVoteItemRandom )
	self.MapVoteItemRandom = MapVoteItemRandom
	
	local MapVoteItemPrevious = CoD.MapVoteItem.new( f1_arg0, f1_arg1, 0, 0, 269, 532, 0, 0, 37, 217 )
	MapVoteItemPrevious:mergeStateConditions( {
		{
			stateName = "Unselectable",
			condition = function ( menu, element, event )
				return not CoD.LobbyUtility.MapVotePreviousSelectable()
			end
		}
	} )
	local LobbyStatus = MapVoteItemPrevious
	local MapVoteItemNext = MapVoteItemPrevious.subscribeToModel
	local f1_local6 = Engine[@"getglobalmodel"]()
	MapVoteItemNext( LobbyStatus, f1_local6["lobbyRoot.mapVote"], function ( f13_arg0 )
		f1_arg0:updateElementState( MapVoteItemPrevious, {
			name = "model_validation",
			menu = f1_arg0,
			controller = f1_arg1,
			modelValue = f13_arg0:get(),
			modelName = "lobbyRoot.mapVote"
		} )
	end, false )
	LobbyStatus = MapVoteItemPrevious
	MapVoteItemNext = MapVoteItemPrevious.subscribeToModel
	f1_local6 = Engine[@"getglobalmodel"]()
	MapVoteItemNext( LobbyStatus, f1_local6["lobbyRoot.lobbyNav"], function ( f14_arg0 )
		f1_arg0:updateElementState( MapVoteItemPrevious, {
			name = "model_validation",
			menu = f1_arg0,
			controller = f1_arg1,
			modelValue = f14_arg0:get(),
			modelName = "lobbyRoot.lobbyNav"
		} )
	end, false )
	MapVoteItemPrevious.VoteType:setText( LocalizeToUpperString( @"menu/prev" ) )
	MapVoteItemPrevious:subscribeToGlobalModel( f1_arg1, "MapVote", "mapVoteMapPrevious", function ( model )
		local f15_local0 = model:get()
		if f15_local0 ~= nil then
			MapVoteItemPrevious.MapImage:setImage( RegisterImage( CoD.MapUtility.MapNameToMapImage( f15_local0 ) ) )
		end
	end )
	MapVoteItemPrevious:subscribeToGlobalModel( f1_arg1, "MapVote", "mapVoteMapPrevious", function ( model )
		local f16_local0 = model:get()
		if f16_local0 ~= nil then
			MapVoteItemPrevious.MapVoteMapNameGameModeLayout.MapName:setText( CoD.MapUtility.MapNameToLocalizedToUpperNameShort( f16_local0 ) )
		end
	end )
	MapVoteItemPrevious:subscribeToGlobalModel( f1_arg1, "MapVote", "mapVoteGameModePrevious", function ( model )
		local f17_local0 = model:get()
		if f17_local0 ~= nil then
			MapVoteItemPrevious.MapVoteMapNameGameModeLayout.GameMode:setText( CoD.GameTypeUtility.GameTypeToLocalizeToUpperName( f17_local0 ) )
		end
	end )
	MapVoteItemPrevious:subscribeToGlobalModel( f1_arg1, "MapVote", "mapVoteGameModePrevious", function ( model )
		local f18_local0 = model:get()
		if f18_local0 ~= nil then
			MapVoteItemPrevious.GameModeIcon:setImage( RegisterImage( CoD.GameTypeUtility.GameTypeToImage( f18_local0 ) ) )
		end
	end )
	MapVoteItemPrevious:subscribeToGlobalModel( f1_arg1, "MapVote", "mapVoteCountPrevious", function ( model )
		local f19_local0 = model:get()
		if f19_local0 ~= nil then
			MapVoteItemPrevious.voteCount:setText( f19_local0 )
		end
	end )
	LobbyStatus = MapVoteItemPrevious
	MapVoteItemNext = MapVoteItemPrevious.subscribeToModel
	f1_local6 = Engine[@"getglobalmodel"]()
	MapVoteItemNext( LobbyStatus, f1_local6["lobbyRoot.mapVote"], function ( f20_arg0, f20_arg1 )
		CoD.Menu.UpdateButtonShownState( f20_arg1, f1_arg0, f1_arg1, Enum[@"luibutton"][@"lui_key_xba_pscross"] )
	end, false )
	LobbyStatus = MapVoteItemPrevious
	MapVoteItemNext = MapVoteItemPrevious.subscribeToModel
	f1_local6 = Engine[@"getglobalmodel"]()
	MapVoteItemNext( LobbyStatus, f1_local6["lobbyRoot.lobbyNav"], function ( f21_arg0, f21_arg1 )
		CoD.Menu.UpdateButtonShownState( f21_arg1, f1_arg0, f1_arg1, Enum[@"luibutton"][@"lui_key_xba_pscross"] )
	end, false )
	MapVoteItemPrevious:registerEventHandler( "lobby_map_vote_previous_chosen", function ( element, event )
		local f22_local0 = nil
		PlayClip( self, "MapVoteChosenPrevious", f1_arg1 )
		if not f22_local0 then
			f22_local0 = element:dispatchEventToChildren( event )
		end
		return f22_local0
	end )
	MapVoteItemPrevious:registerEventHandler( "gain_focus", function ( element, event )
		local f23_local0 = nil
		if element.gainFocus then
			f23_local0 = element:gainFocus( event )
		elseif element.super.gainFocus then
			f23_local0 = element.super:gainFocus( event )
		end
		CoD.Menu.UpdateButtonShownState( element, f1_arg0, f1_arg1, Enum[@"luibutton"][@"lui_key_xba_pscross"] )
		return f23_local0
	end )
	f1_arg0:AddButtonCallbackFunction( MapVoteItemPrevious, f1_arg1, Enum[@"luibutton"][@"lui_key_xba_pscross"], "ui_confirm", function ( element, menu, controller, model )
		if CoD.LobbyUtility.MapVotePreviousSelectable() then
			CoD.LobbyUtility.LobbyMapVoteSelectPrevious( self, controller )
			return true
		else
			
		end
	end, function ( element, menu, controller )
		if CoD.LobbyUtility.MapVotePreviousSelectable() then
			CoD.Menu.SetButtonLabel( menu, Enum[@"luibutton"][@"lui_key_xba_pscross"], @"menu/select", nil, "ui_confirm" )
			return true
		else
			return false
		end
	end, false )
	self:addElement( MapVoteItemPrevious )
	self.MapVoteItemPrevious = MapVoteItemPrevious
	
	MapVoteItemNext = CoD.MapVoteItem.new( f1_arg0, f1_arg1, 0, 0, 0, 263, 0, 0, 37, 217 )
	MapVoteItemNext.VoteType:setText( LocalizeToUpperString( @"menu/next" ) )
	MapVoteItemNext:subscribeToGlobalModel( f1_arg1, "MapVote", "mapVoteMapNext", function ( model )
		local f26_local0 = model:get()
		if f26_local0 ~= nil then
			MapVoteItemNext.MapImage:setImage( RegisterImage( CoD.MapUtility.MapNameToMapImage( f26_local0 ) ) )
		end
	end )
	MapVoteItemNext:subscribeToGlobalModel( f1_arg1, "MapVote", "mapVoteMapNext", function ( model )
		local f27_local0 = model:get()
		if f27_local0 ~= nil then
			MapVoteItemNext.MapVoteMapNameGameModeLayout.MapName:setText( CoD.MapUtility.MapNameToLocalizedToUpperNameShort( f27_local0 ) )
		end
	end )
	MapVoteItemNext:subscribeToGlobalModel( f1_arg1, "MapVote", "mapVoteGameModeNext", function ( model )
		local f28_local0 = model:get()
		if f28_local0 ~= nil then
			MapVoteItemNext.MapVoteMapNameGameModeLayout.GameMode:setText( CoD.GameTypeUtility.GameTypeToLocalizeToUpperName( f28_local0 ) )
		end
	end )
	MapVoteItemNext:subscribeToGlobalModel( f1_arg1, "MapVote", "mapVoteGameModeNext", function ( model )
		local f29_local0 = model:get()
		if f29_local0 ~= nil then
			MapVoteItemNext.GameModeIcon:setImage( RegisterImage( CoD.GameTypeUtility.GameTypeToImage( f29_local0 ) ) )
		end
	end )
	MapVoteItemNext:subscribeToGlobalModel( f1_arg1, "MapVote", "mapVoteCountNext", function ( model )
		local f30_local0 = model:get()
		if f30_local0 ~= nil then
			MapVoteItemNext.voteCount:setText( f30_local0 )
		end
	end )
	MapVoteItemNext:registerEventHandler( "lobby_map_vote_next_chosen", function ( element, event )
		local f31_local0 = nil
		PlayClip( self, "MapVoteChosenNext", f1_arg1 )
		if not f31_local0 then
			f31_local0 = element:dispatchEventToChildren( event )
		end
		return f31_local0
	end )
	MapVoteItemNext:registerEventHandler( "gain_focus", function ( element, event )
		local f32_local0 = nil
		if element.gainFocus then
			f32_local0 = element:gainFocus( event )
		elseif element.super.gainFocus then
			f32_local0 = element.super:gainFocus( event )
		end
		CoD.Menu.UpdateButtonShownState( element, f1_arg0, f1_arg1, Enum[@"luibutton"][@"lui_key_xba_pscross"] )
		return f32_local0
	end )
	f1_arg0:AddButtonCallbackFunction( MapVoteItemNext, f1_arg1, Enum[@"luibutton"][@"lui_key_xba_pscross"], "ui_confirm", function ( element, menu, controller, model )
		CoD.LobbyUtility.LobbyMapVoteSelectNext( self, controller )
		return true
	end, function ( element, menu, controller )
		CoD.Menu.SetButtonLabel( menu, Enum[@"luibutton"][@"lui_key_xba_pscross"], @"menu/select", nil, "ui_confirm" )
		return true
	end, false )
	self:addElement( MapVoteItemNext )
	self.MapVoteItemNext = MapVoteItemNext
	
	LobbyStatus = LUI.UIText.new( 0, 0, 5, 384, 0, 0, 12, 32 )
	LobbyStatus:setRGB( 0.63, 0.62, 0.61 )
	LobbyStatus:setTTF( "ttmussels_regular" )
	LobbyStatus:setLetterSpacing( 6 )
	LobbyStatus:setAlignment( Enum[@"luialignment"][@"lui_alignment_left"] )
	LobbyStatus:setAlignment( Enum[@"luialignment"][@"lui_alignment_top"] )
	LobbyStatus:subscribeToGlobalModel( f1_arg1, "LobbyRoot", "lobbyStatus", function ( model )
		local f35_local0 = model:get()
		if f35_local0 ~= nil then
			LobbyStatus:setText( ToUpper( f35_local0 ) )
		end
	end )
	self:addElement( LobbyStatus )
	self.LobbyStatus = LobbyStatus
	
	self:mergeStateConditions( {
		{
			stateName = "MapVote",
			condition = function ( menu, element, event )
				return CoD.LobbyUtility.MapVoteInState( LuaEnum.MAP_VOTE_STATE.VOTING )
			end
		},
		{
			stateName = "MapVoteChosenNext",
			condition = function ( menu, element, event )
				return CoD.LobbyUtility.MapVoteInState( LuaEnum.MAP_VOTE_STATE.LOCKEDIN ) and CoD.ModelUtility.IsGlobalModelValueEqualToEnum( "MapVote.lobbyMapVoteType", Enum[@"lobbymapvote"][@"lobby_mapvote_next"] )
			end
		},
		{
			stateName = "MapVoteChosenPrevious",
			condition = function ( menu, element, event )
				return CoD.LobbyUtility.MapVoteInState( LuaEnum.MAP_VOTE_STATE.LOCKEDIN ) and CoD.ModelUtility.IsGlobalModelValueEqualToEnum( "MapVote.lobbyMapVoteType", Enum[@"lobbymapvote"][@"lobby_mapvote_previous"] )
			end
		},
		{
			stateName = "MapVoteChosenRandom",
			condition = function ( menu, element, event )
				return CoD.LobbyUtility.MapVoteInState( LuaEnum.MAP_VOTE_STATE.LOCKEDIN ) and CoD.ModelUtility.IsGlobalModelValueEqualToEnum( "MapVote.lobbyMapVoteType", Enum[@"lobbymapvote"][@"lobby_mapvote_random"] )
			end
		},
		{
			stateName = "SelectedMap",
			condition = function ( menu, element, event )
				return CoD.LobbyUtility.MapVoteInState( LuaEnum.MAP_VOTE_STATE.LOCKEDIN )
			end
		}
	} )
	local f1_local7 = self
	f1_local6 = self.subscribeToModel
	local f1_local8 = Engine[@"getglobalmodel"]()
	f1_local6( f1_local7, f1_local8["lobbyRoot.mapVote"], function ( f41_arg0 )
		f1_arg0:updateElementState( self, {
			name = "model_validation",
			menu = f1_arg0,
			controller = f1_arg1,
			modelValue = f41_arg0:get(),
			modelName = "lobbyRoot.mapVote"
		} )
	end, false )
	f1_local7 = self
	f1_local6 = self.subscribeToModel
	f1_local8 = Engine[@"getglobalmodel"]()
	f1_local6( f1_local7, f1_local8["lobbyRoot.lobbyNav"], function ( f42_arg0 )
		f1_arg0:updateElementState( self, {
			name = "model_validation",
			menu = f1_arg0,
			controller = f1_arg1,
			modelValue = f42_arg0:get(),
			modelName = "lobbyRoot.lobbyNav"
		} )
	end, false )
	f1_local7 = self
	f1_local6 = self.subscribeToModel
	f1_local8 = Engine[@"getglobalmodel"]()
	f1_local6( f1_local7, f1_local8["MapVote.lobbyMapVoteType"], function ( f43_arg0 )
		f1_arg0:updateElementState( self, {
			name = "model_validation",
			menu = f1_arg0,
			controller = f1_arg1,
			modelValue = f43_arg0:get(),
			modelName = "MapVote.lobbyMapVoteType"
		} )
	end, false )
	LUI.OverrideFunction_CallOriginalFirst( self, "setState", function ( element, controller, f44_arg2, f44_arg3, f44_arg4 )
		if CoD.LobbyUtility.ShouldSetMapVoteStateToSelectedMap( self ) then
			CoD.LobbyUtility.SetMapVoteSelectedStateOnClipOver( self, controller, "SelectedMap" )
		end
	end )
	MapVoteItemVoteDecided.id = "MapVoteItemVoteDecided"
	MapVoteItemRandom.id = "MapVoteItemRandom"
	MapVoteItemPrevious.id = "MapVoteItemPrevious"
	MapVoteItemNext.id = "MapVoteItemNext"
	LUI.OverrideFunction_CallOriginalSecond( self, "close", self.__onClose )
	
	if PostLoadFunc then
		PostLoadFunc( self, f1_arg1, f1_arg0 )
	end
	
	return self
end

CoD.MapVote.__resetProperties = function ( f45_arg0 )
	f45_arg0.MapVoteItemRandom:completeAnimation()
	f45_arg0.MapVoteItemPrevious:completeAnimation()
	f45_arg0.MapVoteItemNext:completeAnimation()
	f45_arg0.LobbyStatus:completeAnimation()
	f45_arg0.MapVoteItemVoteDecided:completeAnimation()
	f45_arg0.MapVoteItemRandom:setLeftRight( 0, 0, 538, 801 )
	f45_arg0.MapVoteItemRandom:setAlpha( 1 )
	f45_arg0.MapVoteItemPrevious:setLeftRight( 0, 0, 269, 532 )
	f45_arg0.MapVoteItemPrevious:setAlpha( 1 )
	f45_arg0.MapVoteItemNext:setAlpha( 1 )
	f45_arg0.MapVoteItemNext.VoteType:setAlpha( 0.95 )
	f45_arg0.LobbyStatus:setAlpha( 1 )
	f45_arg0.MapVoteItemVoteDecided:setLeftRight( 0, 0, 0, 263 )
	f45_arg0.MapVoteItemVoteDecided:setAlpha( 0 )
	f45_arg0.MapVoteItemVoteDecided.MapImage:setShaderVector( 0, 0, 0, 0, 0 )
	f45_arg0.MapVoteItemVoteDecided.MapImage:setShaderVector( 1, 1, 1, 0, 0 )
	f45_arg0.MapVoteItemVoteDecided.GameModeIcon:setAlpha( 0 )
	f45_arg0.MapVoteItemVoteDecided.CommonButtonOutlineThin:setAlpha( 1 )
end

CoD.MapVote.__clipsPerState = {
	DefaultState = {
		DefaultClip = function ( f46_arg0, f46_arg1 )
			f46_arg0:__resetProperties()
			f46_arg0:setupElementClipCounter( 4 )
			f46_arg0.MapVoteItemRandom:completeAnimation()
			f46_arg0.MapVoteItemRandom:setAlpha( 0 )
			f46_arg0.clipFinished( f46_arg0.MapVoteItemRandom )
			f46_arg0.MapVoteItemPrevious:completeAnimation()
			f46_arg0.MapVoteItemPrevious:setAlpha( 0 )
			f46_arg0.clipFinished( f46_arg0.MapVoteItemPrevious )
			f46_arg0.MapVoteItemNext:completeAnimation()
			f46_arg0.MapVoteItemNext:setAlpha( 0 )
			f46_arg0.clipFinished( f46_arg0.MapVoteItemNext )
			f46_arg0.LobbyStatus:completeAnimation()
			f46_arg0.LobbyStatus:setAlpha( 0 )
			f46_arg0.clipFinished( f46_arg0.LobbyStatus )
		end,
		MapVote = function ( f47_arg0, f47_arg1 )
			f47_arg0:__resetProperties()
			f47_arg0:setupElementClipCounter( 4 )
			local f47_local0 = function ( f48_arg0 )
				f47_arg0.MapVoteItemRandom:beginAnimation( 250 )
				f47_arg0.MapVoteItemRandom:setAlpha( 1 )
				f47_arg0.MapVoteItemRandom:registerEventHandler( "interrupted_keyframe", f47_arg0.clipInterrupted )
				f47_arg0.MapVoteItemRandom:registerEventHandler( "transition_complete_keyframe", f47_arg0.clipFinished )
			end
			
			f47_arg0.MapVoteItemRandom:completeAnimation()
			f47_arg0.MapVoteItemRandom:setAlpha( 0 )
			f47_local0( f47_arg0.MapVoteItemRandom )
			local f47_local1 = function ( f49_arg0 )
				f47_arg0.MapVoteItemPrevious:beginAnimation( 250 )
				f47_arg0.MapVoteItemPrevious:setAlpha( 1 )
				f47_arg0.MapVoteItemPrevious:registerEventHandler( "interrupted_keyframe", f47_arg0.clipInterrupted )
				f47_arg0.MapVoteItemPrevious:registerEventHandler( "transition_complete_keyframe", f47_arg0.clipFinished )
			end
			
			f47_arg0.MapVoteItemPrevious:completeAnimation()
			f47_arg0.MapVoteItemPrevious:setAlpha( 0 )
			f47_local1( f47_arg0.MapVoteItemPrevious )
			local f47_local2 = function ( f50_arg0 )
				f47_arg0.MapVoteItemNext:beginAnimation( 250 )
				f47_arg0.MapVoteItemNext:setAlpha( 1 )
				f47_arg0.MapVoteItemNext:registerEventHandler( "interrupted_keyframe", f47_arg0.clipInterrupted )
				f47_arg0.MapVoteItemNext:registerEventHandler( "transition_complete_keyframe", f47_arg0.clipFinished )
			end
			
			f47_arg0.MapVoteItemNext:completeAnimation()
			f47_arg0.MapVoteItemNext:setAlpha( 0 )
			f47_local2( f47_arg0.MapVoteItemNext )
			local f47_local3 = function ( f51_arg0 )
				f47_arg0.LobbyStatus:beginAnimation( 250 )
				f47_arg0.LobbyStatus:setAlpha( 1 )
				f47_arg0.LobbyStatus:registerEventHandler( "interrupted_keyframe", f47_arg0.clipInterrupted )
				f47_arg0.LobbyStatus:registerEventHandler( "transition_complete_keyframe", f47_arg0.clipFinished )
			end
			
			f47_arg0.LobbyStatus:completeAnimation()
			f47_arg0.LobbyStatus:setAlpha( 0 )
			f47_local3( f47_arg0.LobbyStatus )
		end,
		MapSelected = function ( f52_arg0, f52_arg1 )
			f52_arg0:__resetProperties()
			f52_arg0:setupElementClipCounter( 5 )
			f52_arg0.MapVoteItemVoteDecided:completeAnimation()
			f52_arg0.MapVoteItemVoteDecided:setAlpha( 0 )
			f52_arg0.clipFinished( f52_arg0.MapVoteItemVoteDecided )
			local f52_local0 = function ( f53_arg0 )
				f52_arg0.MapVoteItemRandom:beginAnimation( 400 )
				f52_arg0.MapVoteItemRandom:registerEventHandler( "interrupted_keyframe", f52_arg0.clipInterrupted )
				f52_arg0.MapVoteItemRandom:registerEventHandler( "transition_complete_keyframe", f52_arg0.clipFinished )
			end
			
			f52_arg0.MapVoteItemRandom:completeAnimation()
			f52_arg0.MapVoteItemRandom:setAlpha( 0 )
			f52_local0( f52_arg0.MapVoteItemRandom )
			local f52_local1 = function ( f54_arg0 )
				f52_arg0.MapVoteItemPrevious:beginAnimation( 400 )
				f52_arg0.MapVoteItemPrevious:registerEventHandler( "interrupted_keyframe", f52_arg0.clipInterrupted )
				f52_arg0.MapVoteItemPrevious:registerEventHandler( "transition_complete_keyframe", f52_arg0.clipFinished )
			end
			
			f52_arg0.MapVoteItemPrevious:completeAnimation()
			f52_arg0.MapVoteItemPrevious:setAlpha( 0 )
			f52_local1( f52_arg0.MapVoteItemPrevious )
			local f52_local2 = function ( f55_arg0 )
				f52_arg0.MapVoteItemNext:beginAnimation( 400 )
				f52_arg0.MapVoteItemNext:registerEventHandler( "interrupted_keyframe", f52_arg0.clipInterrupted )
				f52_arg0.MapVoteItemNext:registerEventHandler( "transition_complete_keyframe", f52_arg0.clipFinished )
			end
			
			f52_arg0.MapVoteItemNext:completeAnimation()
			f52_arg0.MapVoteItemNext:setAlpha( 0 )
			f52_local2( f52_arg0.MapVoteItemNext )
			local f52_local3 = function ( f56_arg0 )
				f52_arg0.LobbyStatus:beginAnimation( 400 )
				f52_arg0.LobbyStatus:setAlpha( 1 )
				f52_arg0.LobbyStatus:registerEventHandler( "interrupted_keyframe", f52_arg0.clipInterrupted )
				f52_arg0.LobbyStatus:registerEventHandler( "transition_complete_keyframe", f52_arg0.clipFinished )
			end
			
			f52_arg0.LobbyStatus:completeAnimation()
			f52_arg0.LobbyStatus:setAlpha( 0 )
			f52_local3( f52_arg0.LobbyStatus )
		end,
		MapVoteChosenNext = function ( f57_arg0, f57_arg1 )
			f57_arg0:__resetProperties()
			f57_arg0:setupElementClipCounter( 5 )
			f57_arg0.MapVoteItemVoteDecided:completeAnimation()
			f57_arg0.MapVoteItemVoteDecided:setAlpha( 0 )
			f57_arg0.clipFinished( f57_arg0.MapVoteItemVoteDecided )
			local f57_local0 = function ( f58_arg0 )
				f57_arg0.MapVoteItemRandom:beginAnimation( 400 )
				f57_arg0.MapVoteItemRandom:registerEventHandler( "interrupted_keyframe", f57_arg0.clipInterrupted )
				f57_arg0.MapVoteItemRandom:registerEventHandler( "transition_complete_keyframe", f57_arg0.clipFinished )
			end
			
			f57_arg0.MapVoteItemRandom:completeAnimation()
			f57_arg0.MapVoteItemRandom:setAlpha( 0 )
			f57_local0( f57_arg0.MapVoteItemRandom )
			local f57_local1 = function ( f59_arg0 )
				f57_arg0.MapVoteItemPrevious:beginAnimation( 400 )
				f57_arg0.MapVoteItemPrevious:registerEventHandler( "interrupted_keyframe", f57_arg0.clipInterrupted )
				f57_arg0.MapVoteItemPrevious:registerEventHandler( "transition_complete_keyframe", f57_arg0.clipFinished )
			end
			
			f57_arg0.MapVoteItemPrevious:completeAnimation()
			f57_arg0.MapVoteItemPrevious:setAlpha( 0 )
			f57_local1( f57_arg0.MapVoteItemPrevious )
			local f57_local2 = function ( f60_arg0 )
				f57_arg0.MapVoteItemNext:beginAnimation( 400 )
				f57_arg0.MapVoteItemNext:registerEventHandler( "interrupted_keyframe", f57_arg0.clipInterrupted )
				f57_arg0.MapVoteItemNext:registerEventHandler( "transition_complete_keyframe", f57_arg0.clipFinished )
			end
			
			f57_arg0.MapVoteItemNext:completeAnimation()
			f57_arg0.MapVoteItemNext:setAlpha( 0 )
			f57_local2( f57_arg0.MapVoteItemNext )
			local f57_local3 = function ( f61_arg0 )
				f57_arg0.LobbyStatus:beginAnimation( 400 )
				f57_arg0.LobbyStatus:setAlpha( 1 )
				f57_arg0.LobbyStatus:registerEventHandler( "interrupted_keyframe", f57_arg0.clipInterrupted )
				f57_arg0.LobbyStatus:registerEventHandler( "transition_complete_keyframe", f57_arg0.clipFinished )
			end
			
			f57_arg0.LobbyStatus:completeAnimation()
			f57_arg0.LobbyStatus:setAlpha( 0 )
			f57_local3( f57_arg0.LobbyStatus )
		end,
		MapVoteChosenPrevious = function ( f62_arg0, f62_arg1 )
			f62_arg0:__resetProperties()
			f62_arg0:setupElementClipCounter( 5 )
			f62_arg0.MapVoteItemVoteDecided:completeAnimation()
			f62_arg0.MapVoteItemVoteDecided:setAlpha( 0 )
			f62_arg0.clipFinished( f62_arg0.MapVoteItemVoteDecided )
			local f62_local0 = function ( f63_arg0 )
				f62_arg0.MapVoteItemRandom:beginAnimation( 400 )
				f62_arg0.MapVoteItemRandom:registerEventHandler( "interrupted_keyframe", f62_arg0.clipInterrupted )
				f62_arg0.MapVoteItemRandom:registerEventHandler( "transition_complete_keyframe", f62_arg0.clipFinished )
			end
			
			f62_arg0.MapVoteItemRandom:completeAnimation()
			f62_arg0.MapVoteItemRandom:setAlpha( 0 )
			f62_local0( f62_arg0.MapVoteItemRandom )
			local f62_local1 = function ( f64_arg0 )
				f62_arg0.MapVoteItemPrevious:beginAnimation( 400 )
				f62_arg0.MapVoteItemPrevious:registerEventHandler( "interrupted_keyframe", f62_arg0.clipInterrupted )
				f62_arg0.MapVoteItemPrevious:registerEventHandler( "transition_complete_keyframe", f62_arg0.clipFinished )
			end
			
			f62_arg0.MapVoteItemPrevious:completeAnimation()
			f62_arg0.MapVoteItemPrevious:setAlpha( 0 )
			f62_local1( f62_arg0.MapVoteItemPrevious )
			local f62_local2 = function ( f65_arg0 )
				f62_arg0.MapVoteItemNext:beginAnimation( 400 )
				f62_arg0.MapVoteItemNext:registerEventHandler( "interrupted_keyframe", f62_arg0.clipInterrupted )
				f62_arg0.MapVoteItemNext:registerEventHandler( "transition_complete_keyframe", f62_arg0.clipFinished )
			end
			
			f62_arg0.MapVoteItemNext:completeAnimation()
			f62_arg0.MapVoteItemNext:setAlpha( 0 )
			f62_local2( f62_arg0.MapVoteItemNext )
			local f62_local3 = function ( f66_arg0 )
				f62_arg0.LobbyStatus:beginAnimation( 400 )
				f62_arg0.LobbyStatus:setAlpha( 1 )
				f62_arg0.LobbyStatus:registerEventHandler( "interrupted_keyframe", f62_arg0.clipInterrupted )
				f62_arg0.LobbyStatus:registerEventHandler( "transition_complete_keyframe", f62_arg0.clipFinished )
			end
			
			f62_arg0.LobbyStatus:completeAnimation()
			f62_arg0.LobbyStatus:setAlpha( 0 )
			f62_local3( f62_arg0.LobbyStatus )
		end,
		MapVoteChosenRandom = function ( f67_arg0, f67_arg1 )
			f67_arg0:__resetProperties()
			f67_arg0:setupElementClipCounter( 5 )
			f67_arg0.MapVoteItemVoteDecided:completeAnimation()
			f67_arg0.MapVoteItemVoteDecided:setAlpha( 0 )
			f67_arg0.clipFinished( f67_arg0.MapVoteItemVoteDecided )
			local f67_local0 = function ( f68_arg0 )
				f67_arg0.MapVoteItemRandom:beginAnimation( 400 )
				f67_arg0.MapVoteItemRandom:registerEventHandler( "interrupted_keyframe", f67_arg0.clipInterrupted )
				f67_arg0.MapVoteItemRandom:registerEventHandler( "transition_complete_keyframe", f67_arg0.clipFinished )
			end
			
			f67_arg0.MapVoteItemRandom:completeAnimation()
			f67_arg0.MapVoteItemRandom:setAlpha( 0 )
			f67_local0( f67_arg0.MapVoteItemRandom )
			local f67_local1 = function ( f69_arg0 )
				f67_arg0.MapVoteItemPrevious:beginAnimation( 400 )
				f67_arg0.MapVoteItemPrevious:registerEventHandler( "interrupted_keyframe", f67_arg0.clipInterrupted )
				f67_arg0.MapVoteItemPrevious:registerEventHandler( "transition_complete_keyframe", f67_arg0.clipFinished )
			end
			
			f67_arg0.MapVoteItemPrevious:completeAnimation()
			f67_arg0.MapVoteItemPrevious:setAlpha( 0 )
			f67_local1( f67_arg0.MapVoteItemPrevious )
			local f67_local2 = function ( f70_arg0 )
				f67_arg0.MapVoteItemNext:beginAnimation( 400 )
				f67_arg0.MapVoteItemNext:registerEventHandler( "interrupted_keyframe", f67_arg0.clipInterrupted )
				f67_arg0.MapVoteItemNext:registerEventHandler( "transition_complete_keyframe", f67_arg0.clipFinished )
			end
			
			f67_arg0.MapVoteItemNext:completeAnimation()
			f67_arg0.MapVoteItemNext:setAlpha( 0 )
			f67_local2( f67_arg0.MapVoteItemNext )
			local f67_local3 = function ( f71_arg0 )
				f67_arg0.LobbyStatus:beginAnimation( 400 )
				f67_arg0.LobbyStatus:setAlpha( 1 )
				f67_arg0.LobbyStatus:registerEventHandler( "interrupted_keyframe", f67_arg0.clipInterrupted )
				f67_arg0.LobbyStatus:registerEventHandler( "transition_complete_keyframe", f67_arg0.clipFinished )
			end
			
			f67_arg0.LobbyStatus:completeAnimation()
			f67_arg0.LobbyStatus:setAlpha( 0 )
			f67_local3( f67_arg0.LobbyStatus )
		end
	},
	MapVote = {
		DefaultClip = function ( f72_arg0, f72_arg1 )
			f72_arg0:__resetProperties()
			f72_arg0:setupElementClipCounter( 3 )
			f72_arg0.MapVoteItemRandom:completeAnimation()
			f72_arg0.MapVoteItemRandom:setAlpha( 1 )
			f72_arg0.clipFinished( f72_arg0.MapVoteItemRandom )
			f72_arg0.MapVoteItemPrevious:completeAnimation()
			f72_arg0.MapVoteItemPrevious:setAlpha( 1 )
			f72_arg0.clipFinished( f72_arg0.MapVoteItemPrevious )
			f72_arg0.MapVoteItemNext:completeAnimation()
			f72_arg0.MapVoteItemNext:setAlpha( 1 )
			f72_arg0.clipFinished( f72_arg0.MapVoteItemNext )
		end,
		MapVoteChosenNext = function ( f73_arg0, f73_arg1 )
			f73_arg0:__resetProperties()
			f73_arg0:setupElementClipCounter( 4 )
			f73_arg0.MapVoteItemVoteDecided:completeAnimation()
			f73_arg0.MapVoteItemVoteDecided:setAlpha( 1 )
			f73_arg0.clipFinished( f73_arg0.MapVoteItemVoteDecided )
			local f73_local0 = function ( f74_arg0 )
				f73_arg0.MapVoteItemRandom:beginAnimation( 400 )
				f73_arg0.MapVoteItemRandom:setAlpha( 0 )
				f73_arg0.MapVoteItemRandom:registerEventHandler( "interrupted_keyframe", f73_arg0.clipInterrupted )
				f73_arg0.MapVoteItemRandom:registerEventHandler( "transition_complete_keyframe", f73_arg0.clipFinished )
			end
			
			f73_arg0.MapVoteItemRandom:completeAnimation()
			f73_arg0.MapVoteItemRandom:setAlpha( 1 )
			f73_local0( f73_arg0.MapVoteItemRandom )
			local f73_local1 = function ( f75_arg0 )
				f73_arg0.MapVoteItemPrevious:beginAnimation( 400 )
				f73_arg0.MapVoteItemPrevious:setAlpha( 0 )
				f73_arg0.MapVoteItemPrevious:registerEventHandler( "interrupted_keyframe", f73_arg0.clipInterrupted )
				f73_arg0.MapVoteItemPrevious:registerEventHandler( "transition_complete_keyframe", f73_arg0.clipFinished )
			end
			
			f73_arg0.MapVoteItemPrevious:completeAnimation()
			f73_arg0.MapVoteItemPrevious:setAlpha( 1 )
			f73_local1( f73_arg0.MapVoteItemPrevious )
			local f73_local2 = function ( f76_arg0 )
				local f76_local0 = function ( f77_arg0 )
					f77_arg0:beginAnimation( 200 )
					f77_arg0:setAlpha( 0 )
					f77_arg0:registerEventHandler( "transition_complete_keyframe", f73_arg0.clipFinished )
				end
				
				f73_arg0.MapVoteItemNext:beginAnimation( 200 )
				f73_arg0.MapVoteItemNext:registerEventHandler( "interrupted_keyframe", f73_arg0.clipInterrupted )
				f73_arg0.MapVoteItemNext:registerEventHandler( "transition_complete_keyframe", f76_local0 )
			end
			
			f73_arg0.MapVoteItemNext:completeAnimation()
			f73_arg0.MapVoteItemNext:setAlpha( 1 )
			f73_local2( f73_arg0.MapVoteItemNext )
		end,
		MapVoteChosenPrevious = function ( f78_arg0, f78_arg1 )
			f78_arg0:__resetProperties()
			f78_arg0:setupElementClipCounter( 4 )
			local f78_local0 = function ( f79_arg0 )
				local f79_local0 = function ( f80_arg0 )
					f80_arg0:beginAnimation( 99 )
					f80_arg0:setAlpha( 1 )
					f80_arg0:registerEventHandler( "transition_complete_keyframe", f78_arg0.clipFinished )
				end
				
				f78_arg0.MapVoteItemVoteDecided:beginAnimation( 400 )
				f78_arg0.MapVoteItemVoteDecided:registerEventHandler( "interrupted_keyframe", f78_arg0.clipInterrupted )
				f78_arg0.MapVoteItemVoteDecided:registerEventHandler( "transition_complete_keyframe", f79_local0 )
			end
			
			f78_arg0.MapVoteItemVoteDecided:completeAnimation()
			f78_arg0.MapVoteItemVoteDecided:setAlpha( 0 )
			f78_local0( f78_arg0.MapVoteItemVoteDecided )
			local f78_local1 = function ( f81_arg0 )
				f78_arg0.MapVoteItemRandom:beginAnimation( 200 )
				f78_arg0.MapVoteItemRandom:setAlpha( 0 )
				f78_arg0.MapVoteItemRandom:registerEventHandler( "interrupted_keyframe", f78_arg0.clipInterrupted )
				f78_arg0.MapVoteItemRandom:registerEventHandler( "transition_complete_keyframe", f78_arg0.clipFinished )
			end
			
			f78_arg0.MapVoteItemRandom:completeAnimation()
			f78_arg0.MapVoteItemRandom:setAlpha( 1 )
			f78_local1( f78_arg0.MapVoteItemRandom )
			local f78_local2 = function ( f82_arg0 )
				local f82_local0 = function ( f83_arg0 )
					local f83_local0 = function ( f84_arg0 )
						f84_arg0:beginAnimation( 99 )
						f84_arg0:setAlpha( 0 )
						f84_arg0:registerEventHandler( "transition_complete_keyframe", f78_arg0.clipFinished )
					end
					
					f83_arg0:beginAnimation( 200, Enum[@"luitween"][@"luitween_ease_both"] )
					f83_arg0:setLeftRight( 0, 0, 0, 263 )
					f83_arg0:registerEventHandler( "transition_complete_keyframe", f83_local0 )
				end
				
				f78_arg0.MapVoteItemPrevious:beginAnimation( 200 )
				f78_arg0.MapVoteItemPrevious:registerEventHandler( "interrupted_keyframe", f78_arg0.clipInterrupted )
				f78_arg0.MapVoteItemPrevious:registerEventHandler( "transition_complete_keyframe", f82_local0 )
			end
			
			f78_arg0.MapVoteItemPrevious:completeAnimation()
			f78_arg0.MapVoteItemPrevious:setLeftRight( 0, 0, 271, 534 )
			f78_arg0.MapVoteItemPrevious:setAlpha( 1 )
			f78_local2( f78_arg0.MapVoteItemPrevious )
			local f78_local3 = function ( f85_arg0 )
				f78_arg0.MapVoteItemNext:beginAnimation( 200 )
				f78_arg0.MapVoteItemNext:setAlpha( 0 )
				f78_arg0.MapVoteItemNext:registerEventHandler( "interrupted_keyframe", f78_arg0.clipInterrupted )
				f78_arg0.MapVoteItemNext:registerEventHandler( "transition_complete_keyframe", f78_arg0.clipFinished )
			end
			
			f78_arg0.MapVoteItemNext:completeAnimation()
			f78_arg0.MapVoteItemNext:setAlpha( 1 )
			f78_local3( f78_arg0.MapVoteItemNext )
		end,
		MapVoteChosenRandom = function ( f86_arg0, f86_arg1 )
			f86_arg0:__resetProperties()
			f86_arg0:setupElementClipCounter( 4 )
			local f86_local0 = function ( f87_arg0 )
				local f87_local0 = function ( f88_arg0 )
					f88_arg0:beginAnimation( 99 )
					f88_arg0:setAlpha( 1 )
					f88_arg0:registerEventHandler( "transition_complete_keyframe", f86_arg0.clipFinished )
				end
				
				f86_arg0.MapVoteItemVoteDecided:beginAnimation( 400 )
				f86_arg0.MapVoteItemVoteDecided:registerEventHandler( "interrupted_keyframe", f86_arg0.clipInterrupted )
				f86_arg0.MapVoteItemVoteDecided:registerEventHandler( "transition_complete_keyframe", f87_local0 )
			end
			
			f86_arg0.MapVoteItemVoteDecided:completeAnimation()
			f86_arg0.MapVoteItemVoteDecided:setAlpha( 0 )
			f86_local0( f86_arg0.MapVoteItemVoteDecided )
			local f86_local1 = function ( f89_arg0 )
				local f89_local0 = function ( f90_arg0 )
					local f90_local0 = function ( f91_arg0 )
						f91_arg0:beginAnimation( 99 )
						f91_arg0:setAlpha( 0 )
						f91_arg0:registerEventHandler( "transition_complete_keyframe", f86_arg0.clipFinished )
					end
					
					f90_arg0:beginAnimation( 200, Enum[@"luitween"][@"luitween_ease_both"] )
					f90_arg0:setLeftRight( 0, 0, 0, 263 )
					f90_arg0:registerEventHandler( "transition_complete_keyframe", f90_local0 )
				end
				
				f86_arg0.MapVoteItemRandom:beginAnimation( 200 )
				f86_arg0.MapVoteItemRandom:registerEventHandler( "interrupted_keyframe", f86_arg0.clipInterrupted )
				f86_arg0.MapVoteItemRandom:registerEventHandler( "transition_complete_keyframe", f89_local0 )
			end
			
			f86_arg0.MapVoteItemRandom:completeAnimation()
			f86_arg0.MapVoteItemRandom:setLeftRight( 0, 0, 538, 801 )
			f86_arg0.MapVoteItemRandom:setAlpha( 1 )
			f86_local1( f86_arg0.MapVoteItemRandom )
			local f86_local2 = function ( f92_arg0 )
				f86_arg0.MapVoteItemPrevious:beginAnimation( 200 )
				f86_arg0.MapVoteItemPrevious:setAlpha( 0 )
				f86_arg0.MapVoteItemPrevious:registerEventHandler( "interrupted_keyframe", f86_arg0.clipInterrupted )
				f86_arg0.MapVoteItemPrevious:registerEventHandler( "transition_complete_keyframe", f86_arg0.clipFinished )
			end
			
			f86_arg0.MapVoteItemPrevious:completeAnimation()
			f86_arg0.MapVoteItemPrevious:setAlpha( 1 )
			f86_local2( f86_arg0.MapVoteItemPrevious )
			local f86_local3 = function ( f93_arg0 )
				f86_arg0.MapVoteItemNext:beginAnimation( 200 )
				f86_arg0.MapVoteItemNext:setAlpha( 0 )
				f86_arg0.MapVoteItemNext:registerEventHandler( "interrupted_keyframe", f86_arg0.clipInterrupted )
				f86_arg0.MapVoteItemNext:registerEventHandler( "transition_complete_keyframe", f86_arg0.clipFinished )
			end
			
			f86_arg0.MapVoteItemNext:completeAnimation()
			f86_arg0.MapVoteItemNext:setAlpha( 1 )
			f86_local3( f86_arg0.MapVoteItemNext )
		end,
		DefaultState = function ( f94_arg0, f94_arg1 )
			f94_arg0:__resetProperties()
			f94_arg0:setupElementClipCounter( 4 )
			local f94_local0 = function ( f95_arg0 )
				f94_arg0.MapVoteItemRandom:beginAnimation( 400 )
				f94_arg0.MapVoteItemRandom:setAlpha( 0 )
				f94_arg0.MapVoteItemRandom:registerEventHandler( "interrupted_keyframe", f94_arg0.clipInterrupted )
				f94_arg0.MapVoteItemRandom:registerEventHandler( "transition_complete_keyframe", f94_arg0.clipFinished )
			end
			
			f94_arg0.MapVoteItemRandom:completeAnimation()
			f94_arg0.MapVoteItemRandom:setAlpha( 1 )
			f94_local0( f94_arg0.MapVoteItemRandom )
			local f94_local1 = function ( f96_arg0 )
				f94_arg0.MapVoteItemPrevious:beginAnimation( 400 )
				f94_arg0.MapVoteItemPrevious:setAlpha( 0 )
				f94_arg0.MapVoteItemPrevious:registerEventHandler( "interrupted_keyframe", f94_arg0.clipInterrupted )
				f94_arg0.MapVoteItemPrevious:registerEventHandler( "transition_complete_keyframe", f94_arg0.clipFinished )
			end
			
			f94_arg0.MapVoteItemPrevious:completeAnimation()
			f94_arg0.MapVoteItemPrevious:setAlpha( 1 )
			f94_local1( f94_arg0.MapVoteItemPrevious )
			local f94_local2 = function ( f97_arg0 )
				f94_arg0.MapVoteItemNext:beginAnimation( 400 )
				f94_arg0.MapVoteItemNext:setAlpha( 0 )
				f94_arg0.MapVoteItemNext:registerEventHandler( "interrupted_keyframe", f94_arg0.clipInterrupted )
				f94_arg0.MapVoteItemNext:registerEventHandler( "transition_complete_keyframe", f94_arg0.clipFinished )
			end
			
			f94_arg0.MapVoteItemNext:completeAnimation()
			f94_arg0.MapVoteItemNext:setAlpha( 1 )
			f94_local2( f94_arg0.MapVoteItemNext )
			local f94_local3 = function ( f98_arg0 )
				f94_arg0.LobbyStatus:beginAnimation( 400 )
				f94_arg0.LobbyStatus:setAlpha( 0 )
				f94_arg0.LobbyStatus:registerEventHandler( "interrupted_keyframe", f94_arg0.clipInterrupted )
				f94_arg0.LobbyStatus:registerEventHandler( "transition_complete_keyframe", f94_arg0.clipFinished )
			end
			
			f94_arg0.LobbyStatus:completeAnimation()
			f94_arg0.LobbyStatus:setAlpha( 1 )
			f94_local3( f94_arg0.LobbyStatus )
		end
	},
	MapVoteChosenNext = {
		DefaultClip = function ( f99_arg0, f99_arg1 )
			f99_arg0:__resetProperties()
			f99_arg0:setupElementClipCounter( 4 )
			f99_arg0.MapVoteItemVoteDecided:completeAnimation()
			f99_arg0.MapVoteItemVoteDecided:setAlpha( 1 )
			f99_arg0.clipFinished( f99_arg0.MapVoteItemVoteDecided )
			f99_arg0.MapVoteItemRandom:completeAnimation()
			f99_arg0.MapVoteItemRandom:setAlpha( 0 )
			f99_arg0.clipFinished( f99_arg0.MapVoteItemRandom )
			f99_arg0.MapVoteItemPrevious:completeAnimation()
			f99_arg0.MapVoteItemPrevious:setAlpha( 0 )
			f99_arg0.clipFinished( f99_arg0.MapVoteItemPrevious )
			f99_arg0.MapVoteItemNext:completeAnimation()
			f99_arg0.MapVoteItemNext:setAlpha( 0 )
			f99_arg0.clipFinished( f99_arg0.MapVoteItemNext )
		end
	},
	MapVoteChosenPrevious = {
		DefaultClip = function ( f100_arg0, f100_arg1 )
			f100_arg0:__resetProperties()
			f100_arg0:setupElementClipCounter( 4 )
			f100_arg0.MapVoteItemVoteDecided:completeAnimation()
			f100_arg0.MapVoteItemVoteDecided:setAlpha( 1 )
			f100_arg0.clipFinished( f100_arg0.MapVoteItemVoteDecided )
			f100_arg0.MapVoteItemRandom:completeAnimation()
			f100_arg0.MapVoteItemRandom:setAlpha( 0 )
			f100_arg0.clipFinished( f100_arg0.MapVoteItemRandom )
			f100_arg0.MapVoteItemPrevious:completeAnimation()
			f100_arg0.MapVoteItemPrevious:setLeftRight( 0, 0, 0, 250 )
			f100_arg0.MapVoteItemPrevious:setAlpha( 0 )
			f100_arg0.clipFinished( f100_arg0.MapVoteItemPrevious )
			f100_arg0.MapVoteItemNext:completeAnimation()
			f100_arg0.MapVoteItemNext:setAlpha( 0 )
			f100_arg0.clipFinished( f100_arg0.MapVoteItemNext )
		end
	},
	MapVoteChosenRandom = {
		DefaultClip = function ( f101_arg0, f101_arg1 )
			f101_arg0:__resetProperties()
			f101_arg0:setupElementClipCounter( 4 )
			f101_arg0.MapVoteItemVoteDecided:completeAnimation()
			f101_arg0.MapVoteItemVoteDecided:setAlpha( 1 )
			f101_arg0.clipFinished( f101_arg0.MapVoteItemVoteDecided )
			f101_arg0.MapVoteItemRandom:completeAnimation()
			f101_arg0.MapVoteItemRandom:setLeftRight( 0, 0, 0, 250 )
			f101_arg0.MapVoteItemRandom:setAlpha( 0 )
			f101_arg0.clipFinished( f101_arg0.MapVoteItemRandom )
			f101_arg0.MapVoteItemPrevious:completeAnimation()
			f101_arg0.MapVoteItemPrevious:setAlpha( 0 )
			f101_arg0.clipFinished( f101_arg0.MapVoteItemPrevious )
			f101_arg0.MapVoteItemNext:completeAnimation()
			f101_arg0.MapVoteItemNext:setAlpha( 0 )
			f101_arg0.clipFinished( f101_arg0.MapVoteItemNext )
		end
	},
	SelectedMap = {
		DefaultClip = function ( f102_arg0, f102_arg1 )
			f102_arg0:__resetProperties()
			f102_arg0:setupElementClipCounter( 4 )
			local f102_local0 = function ( f103_arg0 )
				f102_arg0.MapVoteItemVoteDecided:beginAnimation( 500, Enum[@"luitween"][@"luitween_ease_out"] )
				f102_arg0.MapVoteItemVoteDecided:setLeftRight( 0, 0, 0, 632 )
				f102_arg0.MapVoteItemVoteDecided:registerEventHandler( "interrupted_keyframe", f102_arg0.clipInterrupted )
				f102_arg0.MapVoteItemVoteDecided:registerEventHandler( "transition_complete_keyframe", f102_arg0.clipFinished )
			end
			
			f102_arg0.MapVoteItemVoteDecided:completeAnimation()
			f102_arg0.MapVoteItemVoteDecided.MapImage:completeAnimation()
			f102_arg0.MapVoteItemVoteDecided.GameModeIcon:completeAnimation()
			f102_arg0.MapVoteItemVoteDecided.CommonButtonOutlineThin:completeAnimation()
			f102_arg0.MapVoteItemVoteDecided:setLeftRight( 0, 0, 0, 263 )
			f102_arg0.MapVoteItemVoteDecided:setAlpha( 1 )
			f102_arg0.MapVoteItemVoteDecided.MapImage:setShaderVector( 0, 0, 0.5, 0, 0 )
			f102_arg0.MapVoteItemVoteDecided.MapImage:setShaderVector( 1, 1, 1, 0, 0 )
			f102_arg0.MapVoteItemVoteDecided.GameModeIcon:setAlpha( 1 )
			f102_arg0.MapVoteItemVoteDecided.CommonButtonOutlineThin:setAlpha( 0 )
			f102_local0( f102_arg0.MapVoteItemVoteDecided )
			f102_arg0.MapVoteItemRandom:completeAnimation()
			f102_arg0.MapVoteItemRandom:setAlpha( 0 )
			f102_arg0.clipFinished( f102_arg0.MapVoteItemRandom )
			f102_arg0.MapVoteItemPrevious:completeAnimation()
			f102_arg0.MapVoteItemPrevious:setAlpha( 0 )
			f102_arg0.clipFinished( f102_arg0.MapVoteItemPrevious )
			f102_arg0.MapVoteItemNext:completeAnimation()
			f102_arg0.MapVoteItemNext.VoteType:completeAnimation()
			f102_arg0.MapVoteItemNext:setAlpha( 0 )
			f102_arg0.MapVoteItemNext.VoteType:setAlpha( 0.95 )
			f102_arg0.clipFinished( f102_arg0.MapVoteItemNext )
		end,
		DefaultState = function ( f104_arg0, f104_arg1 )
			f104_arg0:__resetProperties()
			f104_arg0:setupElementClipCounter( 5 )
			local f104_local0 = function ( f105_arg0 )
				f104_arg0.MapVoteItemVoteDecided:beginAnimation( 400 )
				f104_arg0.MapVoteItemVoteDecided.GameModeIcon:beginAnimation( 400 )
				f104_arg0.MapVoteItemVoteDecided:setAlpha( 0 )
				f104_arg0.MapVoteItemVoteDecided.GameModeIcon:setAlpha( 0 )
				f104_arg0.MapVoteItemVoteDecided:registerEventHandler( "interrupted_keyframe", f104_arg0.clipInterrupted )
				f104_arg0.MapVoteItemVoteDecided:registerEventHandler( "transition_complete_keyframe", f104_arg0.clipFinished )
			end
			
			f104_arg0.MapVoteItemVoteDecided:completeAnimation()
			f104_arg0.MapVoteItemVoteDecided.MapImage:completeAnimation()
			f104_arg0.MapVoteItemVoteDecided.GameModeIcon:completeAnimation()
			f104_arg0.MapVoteItemVoteDecided.CommonButtonOutlineThin:completeAnimation()
			f104_arg0.MapVoteItemVoteDecided:setLeftRight( 0, 0, 0, 805 )
			f104_arg0.MapVoteItemVoteDecided:setAlpha( 1 )
			f104_arg0.MapVoteItemVoteDecided.MapImage:setShaderVector( 0, 0, 0.39, 0, 0 )
			f104_arg0.MapVoteItemVoteDecided.GameModeIcon:setAlpha( 1 )
			f104_arg0.MapVoteItemVoteDecided.CommonButtonOutlineThin:setAlpha( 0 )
			f104_local0( f104_arg0.MapVoteItemVoteDecided )
			f104_arg0.MapVoteItemRandom:completeAnimation()
			f104_arg0.MapVoteItemRandom:setAlpha( 0 )
			f104_arg0.clipFinished( f104_arg0.MapVoteItemRandom )
			f104_arg0.MapVoteItemPrevious:completeAnimation()
			f104_arg0.MapVoteItemPrevious:setAlpha( 0 )
			f104_arg0.clipFinished( f104_arg0.MapVoteItemPrevious )
			f104_arg0.MapVoteItemNext:completeAnimation()
			f104_arg0.MapVoteItemNext:setAlpha( 0 )
			f104_arg0.clipFinished( f104_arg0.MapVoteItemNext )
			local f104_local1 = function ( f106_arg0 )
				f104_arg0.LobbyStatus:beginAnimation( 400 )
				f104_arg0.LobbyStatus:setAlpha( 0 )
				f104_arg0.LobbyStatus:registerEventHandler( "interrupted_keyframe", f104_arg0.clipInterrupted )
				f104_arg0.LobbyStatus:registerEventHandler( "transition_complete_keyframe", f104_arg0.clipFinished )
			end
			
			f104_arg0.LobbyStatus:completeAnimation()
			f104_arg0.LobbyStatus:setAlpha( 1 )
			f104_local1( f104_arg0.LobbyStatus )
		end
	}
}

CoD.MapVote.__onClose = function ( f107_arg0 )
	f107_arg0.MapVoteItemVoteDecided:close()
	f107_arg0.MapVoteItemRandom:close()
	f107_arg0.MapVoteItemPrevious:close()
	f107_arg0.MapVoteItemNext:close()
	f107_arg0.LobbyStatus:close()
end

-- zm rpc
CoD.MapVoteZM = InheritFrom( LUI.UIElement )
CoD.MapVoteZM.__defaultWidth = 394
CoD.MapVoteZM.__defaultHeight = 355
CoD.MapVoteZM.new = function ( f1_arg0, f1_arg1, f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	local self = LUI.UIElement.new( f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	self:setClass( CoD.MapVoteZM )
	self.id = "MapVoteZM"
	self.soundSet = "default"
	self.onlyChildrenFocusable = true
	self.anyChildUsesUpdateState = true
	f1_arg0:addElementToPendingUpdateStateList( self )
	
	local DirectorMapGameTypeAndDifficulty = CoD.DirectorMapGameTypeAndDifficulty.new( f1_arg0, f1_arg1, 0, 0, 6, 388, 0, 0, 37, 143 )
	DirectorMapGameTypeAndDifficulty:mergeStateConditions( {
		{
			stateName = "Unselectable",
			condition = function ( menu, element, event )
				return AlwaysTrue()
			end
		}
	} )
	DirectorMapGameTypeAndDifficulty:setAlpha( 0 )
	DirectorMapGameTypeAndDifficulty.DirectorMapAndGameInternal.PlaylistHeader.GameModeText:setText( Engine[@"hash_4F9F1239CFD921FE"]( @"hash_1C95DCE378B96DFF" ) )
	DirectorMapGameTypeAndDifficulty.DirectorMapAndGameInternal.PlaylistHeaderNonHost.GameModeText:setText( Engine[@"hash_4F9F1239CFD921FE"]( @"hash_1C95DCE378B96DFF" ) )
	DirectorMapGameTypeAndDifficulty:subscribeToGlobalModel( f1_arg1, "MapVote", "mapVoteMapNext", function ( model )
		local f3_local0 = model:get()
		if f3_local0 ~= nil then
			DirectorMapGameTypeAndDifficulty.DirectorMapAndGameInternal.MapImage:setImage( RegisterImage( MapNameToMapImage( f3_local0 ) ) )
			Dvar[@"shield_rpc_Map"]:set(string.sub(CoD.MapUtility.MapNameToLocalizedToUpperName( f3_local0 ), 2, #CoD.MapUtility.MapNameToLocalizedToUpperName( f3_local0 ) - 1))
			Dvar[@"shield_rpc_Map_asset"]:set(Engine[@"lobbygetmap"]())
		end
	end )
	DirectorMapGameTypeAndDifficulty.DirectorMapAndGameInternal.GamemodeIcon.__GamemodeIcon_Image = function ( f4_arg0 )
		local f4_local0 = f4_arg0:get()
		if f4_local0 ~= nil then
			DirectorMapGameTypeAndDifficulty.DirectorMapAndGameInternal.GamemodeIcon:setImage( RegisterImage( CoD.ZombieUtility.GetLocalZMDifficultyImage( f4_local0 ) ) )
			Dvar[@"shield_rpc_Gametype"]:set(string.sub(CoD.GameTypeUtility.GameTypeToLocalizeToUpperName( f4_local0 ), 2, #CoD.GameTypeUtility.GameTypeToLocalizeToUpperName( f4_local0 ) - 1))
		end
	end
	
	DirectorMapGameTypeAndDifficulty:subscribeToGlobalModel( f1_arg1, "MapVote", "mapVoteGameModeNext", DirectorMapGameTypeAndDifficulty.DirectorMapAndGameInternal.GamemodeIcon.__GamemodeIcon_Image )
	DirectorMapGameTypeAndDifficulty.DirectorMapAndGameInternal.GamemodeIcon.__GamemodeIcon_Image_FullPath = function ()
		local f5_local0 = DataSources.MapVote.getModel( f1_arg1 )
		f5_local0 = f5_local0.mapVoteGameModeNext
		if f5_local0 then
			DirectorMapGameTypeAndDifficulty.DirectorMapAndGameInternal.GamemodeIcon.__GamemodeIcon_Image( f5_local0 )
		end
	end
	
	DirectorMapGameTypeAndDifficulty.DirectorMapAndGameInternal.DirectorMapAndGameTypeInternalTitles.Label.__Label_Desc = function ( f6_arg0 )
		local f6_local0 = f6_arg0:get()
		if f6_local0 ~= nil then
			DirectorMapGameTypeAndDifficulty.DirectorMapAndGameInternal.DirectorMapAndGameTypeInternalTitles.Label:setText( CoD.ZombieUtility.MapNameToZMOfflineLocalizedMapName( f6_local0 ) )
		end
	end
	
	DirectorMapGameTypeAndDifficulty:subscribeToGlobalModel( f1_arg1, "MapVote", "mapVoteMapNext", DirectorMapGameTypeAndDifficulty.DirectorMapAndGameInternal.DirectorMapAndGameTypeInternalTitles.Label.__Label_Desc )
	DirectorMapGameTypeAndDifficulty.DirectorMapAndGameInternal.DirectorMapAndGameTypeInternalTitles.Label.__Label_Desc_FullPath = function ()
		local f7_local0 = DataSources.MapVote.getModel( f1_arg1 )
		f7_local0 = f7_local0.mapVoteMapNext
		if f7_local0 then
			DirectorMapGameTypeAndDifficulty.DirectorMapAndGameInternal.DirectorMapAndGameTypeInternalTitles.Label.__Label_Desc( f7_local0 )
		end
	end
	
	DirectorMapGameTypeAndDifficulty:subscribeToGlobalModel( f1_arg1, "MapVote", "mapVoteGameModeNext", function ( model )
		local f8_local0 = model:get()
		if f8_local0 ~= nil then
			DirectorMapGameTypeAndDifficulty.DirectorMapAndGameInternal.DirectorMapAndGameTypeInternalTitles.SubTitle:setText( CoD.GameTypeUtility.GameTypeToLocalizeToUpperName( f8_local0 ) )
		end
	end )
	self:addElement( DirectorMapGameTypeAndDifficulty )
	self.DirectorMapGameTypeAndDifficulty = DirectorMapGameTypeAndDifficulty
	
	local MapVoteItemRandomZM = CoD.MapVoteItemZM.new( f1_arg0, f1_arg1, 0, 0, 0, 394, 0, 0, 249, 355 )
	MapVoteItemRandomZM.MapImage:setImage( RegisterImage( @"uie_lui_random_map_vote" ) )
	MapVoteItemRandomZM.GameMode:setText( LocalizeToUpperString( @"menu/mode_classified" ) )
	MapVoteItemRandomZM.MapName:setText( LocalizeToUpperString( @"menu/classified" ) )
	MapVoteItemRandomZM.GameModeIcon:setImage( RegisterImage( @"blacktransparent" ) )
	MapVoteItemRandomZM.VoteType:setText( LocalizeToUpperString( @"menu/random" ) )
	MapVoteItemRandomZM:subscribeToGlobalModel( f1_arg1, "MapVote", "mapVoteCountRandom", function ( model )
		local f9_local0 = model:get()
		if f9_local0 ~= nil then
			MapVoteItemRandomZM.voteCount:setText( f9_local0 )
		end
	end )
	MapVoteItemRandomZM:registerEventHandler( "lobby_map_vote_random_chosen", function ( element, event )
		local f10_local0 = nil
		PlayClip( self, "MapVoteChosenRandom", f1_arg1 )
		if not f10_local0 then
			f10_local0 = element:dispatchEventToChildren( event )
		end
		return f10_local0
	end )
	MapVoteItemRandomZM:registerEventHandler( "gain_focus", function ( element, event )
		local f11_local0 = nil
		if element.gainFocus then
			f11_local0 = element:gainFocus( event )
		elseif element.super.gainFocus then
			f11_local0 = element.super:gainFocus( event )
		end
		CoD.Menu.UpdateButtonShownState( element, f1_arg0, f1_arg1, Enum[@"luibutton"][@"lui_key_xba_pscross"] )
		return f11_local0
	end )
	f1_arg0:AddButtonCallbackFunction( MapVoteItemRandomZM, f1_arg1, Enum[@"luibutton"][@"lui_key_xba_pscross"], "ui_confirm", function ( element, menu, controller, model )
		CoD.LobbyUtility.LobbyMapVoteSelectRandom( self, controller )
		return true
	end, function ( element, menu, controller )
		CoD.Menu.SetButtonLabel( menu, Enum[@"luibutton"][@"lui_key_xba_pscross"], @"menu/select", nil, "ui_confirm" )
		return true
	end, false )
	self:addElement( MapVoteItemRandomZM )
	self.MapVoteItemRandomZM = MapVoteItemRandomZM
	
	local MapVoteItemPreviousZM = CoD.MapVoteItemZM.new( f1_arg0, f1_arg1, 0, 0, 0, 394, 0, 0, 143, 249 )
	MapVoteItemPreviousZM:mergeStateConditions( {
		{
			stateName = "Unselectable",
			condition = function ( menu, element, event )
				return not CoD.LobbyUtility.MapVotePreviousSelectable()
			end
		}
	} )
	local LobbyStatus = MapVoteItemPreviousZM
	local MapVoteItemNextZM = MapVoteItemPreviousZM.subscribeToModel
	local f1_local6 = Engine[@"getglobalmodel"]()
	MapVoteItemNextZM( LobbyStatus, f1_local6["lobbyRoot.mapVote"], function ( f15_arg0 )
		f1_arg0:updateElementState( MapVoteItemPreviousZM, {
			name = "model_validation",
			menu = f1_arg0,
			controller = f1_arg1,
			modelValue = f15_arg0:get(),
			modelName = "lobbyRoot.mapVote"
		} )
	end, false )
	LobbyStatus = MapVoteItemPreviousZM
	MapVoteItemNextZM = MapVoteItemPreviousZM.subscribeToModel
	f1_local6 = Engine[@"getglobalmodel"]()
	MapVoteItemNextZM( LobbyStatus, f1_local6["lobbyRoot.lobbyNav"], function ( f16_arg0 )
		f1_arg0:updateElementState( MapVoteItemPreviousZM, {
			name = "model_validation",
			menu = f1_arg0,
			controller = f1_arg1,
			modelValue = f16_arg0:get(),
			modelName = "lobbyRoot.lobbyNav"
		} )
	end, false )
	MapVoteItemPreviousZM.VoteType:setText( LocalizeToUpperString( @"menu/prev" ) )
	MapVoteItemPreviousZM:subscribeToGlobalModel( f1_arg1, "MapVote", "mapVoteMapPrevious", function ( model )
		local f17_local0 = model:get()
		if f17_local0 ~= nil then
			MapVoteItemPreviousZM.MapImage:setImage( RegisterImage( MapNameToMapImage( f17_local0 ) ) )
		end
	end )
	MapVoteItemPreviousZM:subscribeToGlobalModel( f1_arg1, "MapVote", "mapVoteGameModePrevious", function ( model )
		local f18_local0 = model:get()
		if f18_local0 ~= nil then
			MapVoteItemPreviousZM.GameMode:setText( CoD.GameTypeUtility.GameTypeToLocalizeToUpperName( f18_local0 ) )
		end
	end )
	MapVoteItemPreviousZM:subscribeToGlobalModel( f1_arg1, "MapVote", "mapVoteMapPrevious", function ( model )
		local f19_local0 = model:get()
		if f19_local0 ~= nil then
			MapVoteItemPreviousZM.MapName:setText( CoD.MapUtility.MapNameToLocalizedToUpperName( f19_local0 ) )
		end
	end )
	MapVoteItemPreviousZM:subscribeToGlobalModel( f1_arg1, "MapVote", "mapVoteGameModePrevious", function ( model )
		local f20_local0 = model:get()
		if f20_local0 ~= nil then
			MapVoteItemPreviousZM.GameModeIcon:setImage( RegisterImage( CoD.GameTypeUtility.GameTypeToImage( f20_local0 ) ) )
		end
	end )
	MapVoteItemPreviousZM:subscribeToGlobalModel( f1_arg1, "MapVote", "mapVoteCountPrevious", function ( model )
		local f21_local0 = model:get()
		if f21_local0 ~= nil then
			MapVoteItemPreviousZM.voteCount:setText( f21_local0 )
		end
	end )
	MapVoteItemPreviousZM:registerEventHandler( "lobby_map_vote_previous_chosen", function ( element, event )
		local f22_local0 = nil
		PlayClip( self, "MapVoteChosenPrevious", f1_arg1 )
		if not f22_local0 then
			f22_local0 = element:dispatchEventToChildren( event )
		end
		return f22_local0
	end )
	MapVoteItemPreviousZM:registerEventHandler( "gain_focus", function ( element, event )
		local f23_local0 = nil
		if element.gainFocus then
			f23_local0 = element:gainFocus( event )
		elseif element.super.gainFocus then
			f23_local0 = element.super:gainFocus( event )
		end
		CoD.Menu.UpdateButtonShownState( element, f1_arg0, f1_arg1, Enum[@"luibutton"][@"lui_key_xba_pscross"] )
		return f23_local0
	end )
	f1_arg0:AddButtonCallbackFunction( MapVoteItemPreviousZM, f1_arg1, Enum[@"luibutton"][@"lui_key_xba_pscross"], "ui_confirm", function ( element, menu, controller, model )
		CoD.LobbyUtility.LobbyMapVoteSelectPrevious( self, controller )
		return true
	end, function ( element, menu, controller )
		CoD.Menu.SetButtonLabel( menu, Enum[@"luibutton"][@"lui_key_xba_pscross"], @"menu/select", nil, "ui_confirm" )
		return true
	end, false )
	self:addElement( MapVoteItemPreviousZM )
	self.MapVoteItemPreviousZM = MapVoteItemPreviousZM
	
	MapVoteItemNextZM = CoD.MapVoteItemZM.new( f1_arg0, f1_arg1, 0, 0, 0, 394, 0, 0, 37, 143 )
	MapVoteItemNextZM.VoteType:setText( LocalizeToUpperString( @"menu/next" ) )
	MapVoteItemNextZM:subscribeToGlobalModel( f1_arg1, "MapVote", "mapVoteMapNext", function ( model )
		local f26_local0 = model:get()
		if f26_local0 ~= nil then
			MapVoteItemNextZM.MapImage:setImage( RegisterImage( MapNameToMapImage( f26_local0 ) ) )
		end
	end )
	MapVoteItemNextZM:subscribeToGlobalModel( f1_arg1, "MapVote", "mapVoteGameModeNext", function ( model )
		local f27_local0 = model:get()
		if f27_local0 ~= nil then
			MapVoteItemNextZM.GameMode:setText( CoD.GameTypeUtility.GameTypeToLocalizeToUpperName( f27_local0 ) )
		end
	end )
	MapVoteItemNextZM:subscribeToGlobalModel( f1_arg1, "MapVote", "mapVoteMapNext", function ( model )
		local f28_local0 = model:get()
		if f28_local0 ~= nil then
			MapVoteItemNextZM.MapName:setText( CoD.MapUtility.MapNameToLocalizedToUpperName( f28_local0 ) )
		end
	end )
	MapVoteItemNextZM:subscribeToGlobalModel( f1_arg1, "MapVote", "mapVoteGameModeNext", function ( model )
		local f29_local0 = model:get()
		if f29_local0 ~= nil then
			MapVoteItemNextZM.GameModeIcon:setImage( RegisterImage( CoD.GameTypeUtility.GameTypeToImage( f29_local0 ) ) )
		end
	end )
	MapVoteItemNextZM:subscribeToGlobalModel( f1_arg1, "MapVote", "mapVoteCountNext", function ( model )
		local f30_local0 = model:get()
		if f30_local0 ~= nil then
			MapVoteItemNextZM.voteCount:setText( f30_local0 )
		end
	end )
	MapVoteItemNextZM:registerEventHandler( "lobby_map_vote_next_chosen", function ( element, event )
		local f31_local0 = nil
		PlayClip( self, "MapVoteChosenNext", f1_arg1 )
		if not f31_local0 then
			f31_local0 = element:dispatchEventToChildren( event )
		end
		return f31_local0
	end )
	MapVoteItemNextZM:registerEventHandler( "gain_focus", function ( element, event )
		local f32_local0 = nil
		if element.gainFocus then
			f32_local0 = element:gainFocus( event )
		elseif element.super.gainFocus then
			f32_local0 = element.super:gainFocus( event )
		end
		CoD.Menu.UpdateButtonShownState( element, f1_arg0, f1_arg1, Enum[@"luibutton"][@"lui_key_xba_pscross"] )
		return f32_local0
	end )
	f1_arg0:AddButtonCallbackFunction( MapVoteItemNextZM, f1_arg1, Enum[@"luibutton"][@"lui_key_xba_pscross"], "ui_confirm", function ( element, menu, controller, model )
		CoD.LobbyUtility.LobbyMapVoteSelectNext( self, controller )
		return true
	end, function ( element, menu, controller )
		CoD.Menu.SetButtonLabel( menu, Enum[@"luibutton"][@"lui_key_xba_pscross"], @"menu/select", nil, "ui_confirm" )
		return true
	end, false )
	self:addElement( MapVoteItemNextZM )
	self.MapVoteItemNextZM = MapVoteItemNextZM
	
	LobbyStatus = LUI.UIText.new( 0, 0, 5, 384, 0, 0, 12, 32 )
	LobbyStatus:setRGB( 0.63, 0.62, 0.61 )
	LobbyStatus:setTTF( "ttmussels_regular" )
	LobbyStatus:setLetterSpacing( 6 )
	LobbyStatus:setAlignment( Enum[@"luialignment"][@"lui_alignment_left"] )
	LobbyStatus:setAlignment( Enum[@"luialignment"][@"lui_alignment_top"] )
	LobbyStatus:subscribeToGlobalModel( f1_arg1, "LobbyRoot", "lobbyStatus", function ( model )
		local f35_local0 = model:get()
		if f35_local0 ~= nil then
			LobbyStatus:setText( ToUpper( f35_local0 ) )
		end
	end )
	self:addElement( LobbyStatus )
	self.LobbyStatus = LobbyStatus
	
	local f1_local7 = DirectorMapGameTypeAndDifficulty
	f1_local6 = DirectorMapGameTypeAndDifficulty.subscribeToModel
	local f1_local8 = Engine[@"getglobalmodel"]()
	f1_local6( f1_local7, f1_local8.localZMDifficulty, DirectorMapGameTypeAndDifficulty.DirectorMapAndGameInternal.GamemodeIcon.__GamemodeIcon_Image_FullPath )
	f1_local7 = DirectorMapGameTypeAndDifficulty
	f1_local6 = DirectorMapGameTypeAndDifficulty.subscribeToModel
	f1_local8 = Engine[@"getglobalmodel"]()
	f1_local6( f1_local7, f1_local8.offlineScreenState, DirectorMapGameTypeAndDifficulty.DirectorMapAndGameInternal.GamemodeIcon.__GamemodeIcon_Image_FullPath )
	f1_local7 = DirectorMapGameTypeAndDifficulty
	f1_local6 = DirectorMapGameTypeAndDifficulty.subscribeToModel
	f1_local8 = Engine[@"getglobalmodel"]()
	f1_local6( f1_local7, f1_local8.localZMDifficulty, DirectorMapGameTypeAndDifficulty.DirectorMapAndGameInternal.DirectorMapAndGameTypeInternalTitles.Label.__Label_Desc_FullPath )
	f1_local7 = DirectorMapGameTypeAndDifficulty
	f1_local6 = DirectorMapGameTypeAndDifficulty.subscribeToModel
	f1_local8 = Engine[@"getglobalmodel"]()
	f1_local6( f1_local7, f1_local8.localZMTrialVariant, DirectorMapGameTypeAndDifficulty.DirectorMapAndGameInternal.DirectorMapAndGameTypeInternalTitles.Label.__Label_Desc_FullPath )
	f1_local7 = DirectorMapGameTypeAndDifficulty
	f1_local6 = DirectorMapGameTypeAndDifficulty.subscribeToModel
	f1_local8 = Engine[@"getglobalmodel"]()
	f1_local6( f1_local7, f1_local8["MapVote.mapVoteGameModeNext"], DirectorMapGameTypeAndDifficulty.DirectorMapAndGameInternal.DirectorMapAndGameTypeInternalTitles.Label.__Label_Desc_FullPath )
	self:mergeStateConditions( {
		{
			stateName = "MapVote",
			condition = function ( menu, element, event )
				return CoD.LobbyUtility.MapVoteInState( LuaEnum.MAP_VOTE_STATE.VOTING )
			end
		},
		{
			stateName = "MapVoteChosenNext",
			condition = function ( menu, element, event )
				return CoD.LobbyUtility.MapVoteInState( LuaEnum.MAP_VOTE_STATE.LOCKEDIN ) and CoD.ModelUtility.IsGlobalModelValueEqualToEnum( "MapVote.lobbyMapVoteType", Enum[@"lobbymapvote"][@"lobby_mapvote_next"] )
			end
		},
		{
			stateName = "MapVoteChosenPrevious",
			condition = function ( menu, element, event )
				return CoD.LobbyUtility.MapVoteInState( LuaEnum.MAP_VOTE_STATE.LOCKEDIN ) and CoD.ModelUtility.IsGlobalModelValueEqualToEnum( "MapVote.lobbyMapVoteType", Enum[@"lobbymapvote"][@"lobby_mapvote_previous"] )
			end
		},
		{
			stateName = "MapVoteChosenRandom",
			condition = function ( menu, element, event )
				return CoD.LobbyUtility.MapVoteInState( LuaEnum.MAP_VOTE_STATE.LOCKEDIN ) and CoD.ModelUtility.IsGlobalModelValueEqualToEnum( "MapVote.lobbyMapVoteType", Enum[@"lobbymapvote"][@"lobby_mapvote_random"] )
			end
		},
		{
			stateName = "SelectedMap",
			condition = function ( menu, element, event )
				return CoD.LobbyUtility.MapVoteInState( LuaEnum.MAP_VOTE_STATE.LOCKEDIN )
			end
		}
	} )
	f1_local7 = self
	f1_local6 = self.subscribeToModel
	f1_local8 = Engine[@"getglobalmodel"]()
	f1_local6( f1_local7, f1_local8["lobbyRoot.mapVote"], function ( f41_arg0 )
		f1_arg0:updateElementState( self, {
			name = "model_validation",
			menu = f1_arg0,
			controller = f1_arg1,
			modelValue = f41_arg0:get(),
			modelName = "lobbyRoot.mapVote"
		} )
	end, false )
	f1_local7 = self
	f1_local6 = self.subscribeToModel
	f1_local8 = Engine[@"getglobalmodel"]()
	f1_local6( f1_local7, f1_local8["lobbyRoot.lobbyNav"], function ( f42_arg0 )
		f1_arg0:updateElementState( self, {
			name = "model_validation",
			menu = f1_arg0,
			controller = f1_arg1,
			modelValue = f42_arg0:get(),
			modelName = "lobbyRoot.lobbyNav"
		} )
	end, false )
	f1_local7 = self
	f1_local6 = self.subscribeToModel
	f1_local8 = Engine[@"getglobalmodel"]()
	f1_local6( f1_local7, f1_local8["MapVote.lobbyMapVoteType"], function ( f43_arg0 )
		f1_arg0:updateElementState( self, {
			name = "model_validation",
			menu = f1_arg0,
			controller = f1_arg1,
			modelValue = f43_arg0:get(),
			modelName = "MapVote.lobbyMapVoteType"
		} )
	end, false )
	LUI.OverrideFunction_CallOriginalFirst( self, "setState", function ( element, controller, f44_arg2, f44_arg3, f44_arg4 )
		if CoD.LobbyUtility.ShouldSetMapVoteStateToSelectedMap( self ) then
			CoD.LobbyUtility.SetMapVoteSelectedStateOnClipOver( self, controller, "SelectedMap" )
		end
	end )
	DirectorMapGameTypeAndDifficulty.id = "DirectorMapGameTypeAndDifficulty"
	MapVoteItemRandomZM.id = "MapVoteItemRandomZM"
	MapVoteItemPreviousZM.id = "MapVoteItemPreviousZM"
	MapVoteItemNextZM.id = "MapVoteItemNextZM"
	LUI.OverrideFunction_CallOriginalSecond( self, "close", self.__onClose )
	
	if PostLoadFunc then
		PostLoadFunc( self, f1_arg1, f1_arg0 )
	end
	
	return self
end

CoD.MapVoteZM.__resetProperties = function ( f45_arg0 )
	f45_arg0.LobbyStatus:completeAnimation()
	f45_arg0.MapVoteItemNextZM:completeAnimation()
	f45_arg0.MapVoteItemPreviousZM:completeAnimation()
	f45_arg0.MapVoteItemRandomZM:completeAnimation()
	f45_arg0.DirectorMapGameTypeAndDifficulty:completeAnimation()
	f45_arg0.LobbyStatus:setTopBottom( 0, 0, 12, 32 )
	f45_arg0.LobbyStatus:setAlpha( 1 )
	f45_arg0.MapVoteItemNextZM:setAlpha( 1 )
	f45_arg0.MapVoteItemPreviousZM:setTopBottom( 0, 0, 143, 249 )
	f45_arg0.MapVoteItemPreviousZM:setAlpha( 1 )
	f45_arg0.MapVoteItemRandomZM:setTopBottom( 0, 0, 249, 355 )
	f45_arg0.MapVoteItemRandomZM:setAlpha( 1 )
	f45_arg0.DirectorMapGameTypeAndDifficulty:setTopBottom( 0, 0, 37, 143 )
	f45_arg0.DirectorMapGameTypeAndDifficulty:setAlpha( 0 )
end

CoD.MapVoteZM.__clipsPerState = {
	DefaultState = {
		DefaultClip = function ( f46_arg0, f46_arg1 )
			f46_arg0:__resetProperties()
			f46_arg0:setupElementClipCounter( 4 )
			f46_arg0.MapVoteItemRandomZM:completeAnimation()
			f46_arg0.MapVoteItemRandomZM:setAlpha( 0 )
			f46_arg0.clipFinished( f46_arg0.MapVoteItemRandomZM )
			f46_arg0.MapVoteItemPreviousZM:completeAnimation()
			f46_arg0.MapVoteItemPreviousZM:setAlpha( 0 )
			f46_arg0.clipFinished( f46_arg0.MapVoteItemPreviousZM )
			f46_arg0.MapVoteItemNextZM:completeAnimation()
			f46_arg0.MapVoteItemNextZM:setAlpha( 0 )
			f46_arg0.clipFinished( f46_arg0.MapVoteItemNextZM )
			f46_arg0.LobbyStatus:completeAnimation()
			f46_arg0.LobbyStatus:setAlpha( 0 )
			f46_arg0.clipFinished( f46_arg0.LobbyStatus )
		end,
		MapVote = function ( f47_arg0, f47_arg1 )
			f47_arg0:__resetProperties()
			f47_arg0:setupElementClipCounter( 4 )
			local f47_local0 = function ( f48_arg0 )
				f47_arg0.MapVoteItemRandomZM:beginAnimation( 250 )
				f47_arg0.MapVoteItemRandomZM:setAlpha( 1 )
				f47_arg0.MapVoteItemRandomZM:registerEventHandler( "interrupted_keyframe", f47_arg0.clipInterrupted )
				f47_arg0.MapVoteItemRandomZM:registerEventHandler( "transition_complete_keyframe", f47_arg0.clipFinished )
			end
			
			f47_arg0.MapVoteItemRandomZM:completeAnimation()
			f47_arg0.MapVoteItemRandomZM:setAlpha( 0 )
			f47_local0( f47_arg0.MapVoteItemRandomZM )
			local f47_local1 = function ( f49_arg0 )
				f47_arg0.MapVoteItemPreviousZM:beginAnimation( 250 )
				f47_arg0.MapVoteItemPreviousZM:setAlpha( 1 )
				f47_arg0.MapVoteItemPreviousZM:registerEventHandler( "interrupted_keyframe", f47_arg0.clipInterrupted )
				f47_arg0.MapVoteItemPreviousZM:registerEventHandler( "transition_complete_keyframe", f47_arg0.clipFinished )
			end
			
			f47_arg0.MapVoteItemPreviousZM:completeAnimation()
			f47_arg0.MapVoteItemPreviousZM:setAlpha( 0 )
			f47_local1( f47_arg0.MapVoteItemPreviousZM )
			local f47_local2 = function ( f50_arg0 )
				f47_arg0.MapVoteItemNextZM:beginAnimation( 250 )
				f47_arg0.MapVoteItemNextZM:setAlpha( 1 )
				f47_arg0.MapVoteItemNextZM:registerEventHandler( "interrupted_keyframe", f47_arg0.clipInterrupted )
				f47_arg0.MapVoteItemNextZM:registerEventHandler( "transition_complete_keyframe", f47_arg0.clipFinished )
			end
			
			f47_arg0.MapVoteItemNextZM:completeAnimation()
			f47_arg0.MapVoteItemNextZM:setAlpha( 0 )
			f47_local2( f47_arg0.MapVoteItemNextZM )
			local f47_local3 = function ( f51_arg0 )
				f47_arg0.LobbyStatus:beginAnimation( 250 )
				f47_arg0.LobbyStatus:setAlpha( 1 )
				f47_arg0.LobbyStatus:registerEventHandler( "interrupted_keyframe", f47_arg0.clipInterrupted )
				f47_arg0.LobbyStatus:registerEventHandler( "transition_complete_keyframe", f47_arg0.clipFinished )
			end
			
			f47_arg0.LobbyStatus:completeAnimation()
			f47_arg0.LobbyStatus:setAlpha( 0 )
			f47_local3( f47_arg0.LobbyStatus )
		end,
		MapSelected = function ( f52_arg0, f52_arg1 )
			f52_arg0:__resetProperties()
			f52_arg0:setupElementClipCounter( 4 )
			local f52_local0 = function ( f53_arg0 )
				f52_arg0.MapVoteItemRandomZM:beginAnimation( 400 )
				f52_arg0.MapVoteItemRandomZM:registerEventHandler( "interrupted_keyframe", f52_arg0.clipInterrupted )
				f52_arg0.MapVoteItemRandomZM:registerEventHandler( "transition_complete_keyframe", f52_arg0.clipFinished )
			end
			
			f52_arg0.MapVoteItemRandomZM:completeAnimation()
			f52_arg0.MapVoteItemRandomZM:setAlpha( 0 )
			f52_local0( f52_arg0.MapVoteItemRandomZM )
			local f52_local1 = function ( f54_arg0 )
				f52_arg0.MapVoteItemPreviousZM:beginAnimation( 400 )
				f52_arg0.MapVoteItemPreviousZM:registerEventHandler( "interrupted_keyframe", f52_arg0.clipInterrupted )
				f52_arg0.MapVoteItemPreviousZM:registerEventHandler( "transition_complete_keyframe", f52_arg0.clipFinished )
			end
			
			f52_arg0.MapVoteItemPreviousZM:completeAnimation()
			f52_arg0.MapVoteItemPreviousZM:setAlpha( 0 )
			f52_local1( f52_arg0.MapVoteItemPreviousZM )
			local f52_local2 = function ( f55_arg0 )
				f52_arg0.MapVoteItemNextZM:beginAnimation( 400 )
				f52_arg0.MapVoteItemNextZM:registerEventHandler( "interrupted_keyframe", f52_arg0.clipInterrupted )
				f52_arg0.MapVoteItemNextZM:registerEventHandler( "transition_complete_keyframe", f52_arg0.clipFinished )
			end
			
			f52_arg0.MapVoteItemNextZM:completeAnimation()
			f52_arg0.MapVoteItemNextZM:setAlpha( 0 )
			f52_local2( f52_arg0.MapVoteItemNextZM )
			local f52_local3 = function ( f56_arg0 )
				f52_arg0.LobbyStatus:beginAnimation( 400 )
				f52_arg0.LobbyStatus:setAlpha( 1 )
				f52_arg0.LobbyStatus:registerEventHandler( "interrupted_keyframe", f52_arg0.clipInterrupted )
				f52_arg0.LobbyStatus:registerEventHandler( "transition_complete_keyframe", f52_arg0.clipFinished )
			end
			
			f52_arg0.LobbyStatus:completeAnimation()
			f52_arg0.LobbyStatus:setAlpha( 0 )
			f52_local3( f52_arg0.LobbyStatus )
		end,
		MapVoteChosenNext = function ( f57_arg0, f57_arg1 )
			f57_arg0:__resetProperties()
			f57_arg0:setupElementClipCounter( 4 )
			local f57_local0 = function ( f58_arg0 )
				f57_arg0.MapVoteItemRandomZM:beginAnimation( 400 )
				f57_arg0.MapVoteItemRandomZM:registerEventHandler( "interrupted_keyframe", f57_arg0.clipInterrupted )
				f57_arg0.MapVoteItemRandomZM:registerEventHandler( "transition_complete_keyframe", f57_arg0.clipFinished )
			end
			
			f57_arg0.MapVoteItemRandomZM:completeAnimation()
			f57_arg0.MapVoteItemRandomZM:setAlpha( 0 )
			f57_local0( f57_arg0.MapVoteItemRandomZM )
			local f57_local1 = function ( f59_arg0 )
				f57_arg0.MapVoteItemPreviousZM:beginAnimation( 400 )
				f57_arg0.MapVoteItemPreviousZM:registerEventHandler( "interrupted_keyframe", f57_arg0.clipInterrupted )
				f57_arg0.MapVoteItemPreviousZM:registerEventHandler( "transition_complete_keyframe", f57_arg0.clipFinished )
			end
			
			f57_arg0.MapVoteItemPreviousZM:completeAnimation()
			f57_arg0.MapVoteItemPreviousZM:setAlpha( 0 )
			f57_local1( f57_arg0.MapVoteItemPreviousZM )
			local f57_local2 = function ( f60_arg0 )
				f57_arg0.MapVoteItemNextZM:beginAnimation( 400 )
				f57_arg0.MapVoteItemNextZM:registerEventHandler( "interrupted_keyframe", f57_arg0.clipInterrupted )
				f57_arg0.MapVoteItemNextZM:registerEventHandler( "transition_complete_keyframe", f57_arg0.clipFinished )
			end
			
			f57_arg0.MapVoteItemNextZM:completeAnimation()
			f57_arg0.MapVoteItemNextZM:setAlpha( 0 )
			f57_local2( f57_arg0.MapVoteItemNextZM )
			local f57_local3 = function ( f61_arg0 )
				f57_arg0.LobbyStatus:beginAnimation( 400 )
				f57_arg0.LobbyStatus:setAlpha( 1 )
				f57_arg0.LobbyStatus:registerEventHandler( "interrupted_keyframe", f57_arg0.clipInterrupted )
				f57_arg0.LobbyStatus:registerEventHandler( "transition_complete_keyframe", f57_arg0.clipFinished )
			end
			
			f57_arg0.LobbyStatus:completeAnimation()
			f57_arg0.LobbyStatus:setAlpha( 0 )
			f57_local3( f57_arg0.LobbyStatus )
		end,
		MapVoteChosenPrevious = function ( f62_arg0, f62_arg1 )
			f62_arg0:__resetProperties()
			f62_arg0:setupElementClipCounter( 4 )
			local f62_local0 = function ( f63_arg0 )
				f62_arg0.MapVoteItemRandomZM:beginAnimation( 400 )
				f62_arg0.MapVoteItemRandomZM:registerEventHandler( "interrupted_keyframe", f62_arg0.clipInterrupted )
				f62_arg0.MapVoteItemRandomZM:registerEventHandler( "transition_complete_keyframe", f62_arg0.clipFinished )
			end
			
			f62_arg0.MapVoteItemRandomZM:completeAnimation()
			f62_arg0.MapVoteItemRandomZM:setAlpha( 0 )
			f62_local0( f62_arg0.MapVoteItemRandomZM )
			local f62_local1 = function ( f64_arg0 )
				f62_arg0.MapVoteItemPreviousZM:beginAnimation( 400 )
				f62_arg0.MapVoteItemPreviousZM:registerEventHandler( "interrupted_keyframe", f62_arg0.clipInterrupted )
				f62_arg0.MapVoteItemPreviousZM:registerEventHandler( "transition_complete_keyframe", f62_arg0.clipFinished )
			end
			
			f62_arg0.MapVoteItemPreviousZM:completeAnimation()
			f62_arg0.MapVoteItemPreviousZM:setAlpha( 0 )
			f62_local1( f62_arg0.MapVoteItemPreviousZM )
			local f62_local2 = function ( f65_arg0 )
				f62_arg0.MapVoteItemNextZM:beginAnimation( 400 )
				f62_arg0.MapVoteItemNextZM:registerEventHandler( "interrupted_keyframe", f62_arg0.clipInterrupted )
				f62_arg0.MapVoteItemNextZM:registerEventHandler( "transition_complete_keyframe", f62_arg0.clipFinished )
			end
			
			f62_arg0.MapVoteItemNextZM:completeAnimation()
			f62_arg0.MapVoteItemNextZM:setAlpha( 0 )
			f62_local2( f62_arg0.MapVoteItemNextZM )
			local f62_local3 = function ( f66_arg0 )
				f62_arg0.LobbyStatus:beginAnimation( 400 )
				f62_arg0.LobbyStatus:setAlpha( 1 )
				f62_arg0.LobbyStatus:registerEventHandler( "interrupted_keyframe", f62_arg0.clipInterrupted )
				f62_arg0.LobbyStatus:registerEventHandler( "transition_complete_keyframe", f62_arg0.clipFinished )
			end
			
			f62_arg0.LobbyStatus:completeAnimation()
			f62_arg0.LobbyStatus:setAlpha( 0 )
			f62_local3( f62_arg0.LobbyStatus )
		end,
		MapVoteChosenRandom = function ( f67_arg0, f67_arg1 )
			f67_arg0:__resetProperties()
			f67_arg0:setupElementClipCounter( 4 )
			local f67_local0 = function ( f68_arg0 )
				f67_arg0.MapVoteItemRandomZM:beginAnimation( 400 )
				f67_arg0.MapVoteItemRandomZM:registerEventHandler( "interrupted_keyframe", f67_arg0.clipInterrupted )
				f67_arg0.MapVoteItemRandomZM:registerEventHandler( "transition_complete_keyframe", f67_arg0.clipFinished )
			end
			
			f67_arg0.MapVoteItemRandomZM:completeAnimation()
			f67_arg0.MapVoteItemRandomZM:setAlpha( 0 )
			f67_local0( f67_arg0.MapVoteItemRandomZM )
			local f67_local1 = function ( f69_arg0 )
				f67_arg0.MapVoteItemPreviousZM:beginAnimation( 400 )
				f67_arg0.MapVoteItemPreviousZM:registerEventHandler( "interrupted_keyframe", f67_arg0.clipInterrupted )
				f67_arg0.MapVoteItemPreviousZM:registerEventHandler( "transition_complete_keyframe", f67_arg0.clipFinished )
			end
			
			f67_arg0.MapVoteItemPreviousZM:completeAnimation()
			f67_arg0.MapVoteItemPreviousZM:setAlpha( 0 )
			f67_local1( f67_arg0.MapVoteItemPreviousZM )
			local f67_local2 = function ( f70_arg0 )
				f67_arg0.MapVoteItemNextZM:beginAnimation( 400 )
				f67_arg0.MapVoteItemNextZM:registerEventHandler( "interrupted_keyframe", f67_arg0.clipInterrupted )
				f67_arg0.MapVoteItemNextZM:registerEventHandler( "transition_complete_keyframe", f67_arg0.clipFinished )
			end
			
			f67_arg0.MapVoteItemNextZM:completeAnimation()
			f67_arg0.MapVoteItemNextZM:setAlpha( 0 )
			f67_local2( f67_arg0.MapVoteItemNextZM )
			local f67_local3 = function ( f71_arg0 )
				f67_arg0.LobbyStatus:beginAnimation( 400 )
				f67_arg0.LobbyStatus:setAlpha( 1 )
				f67_arg0.LobbyStatus:registerEventHandler( "interrupted_keyframe", f67_arg0.clipInterrupted )
				f67_arg0.LobbyStatus:registerEventHandler( "transition_complete_keyframe", f67_arg0.clipFinished )
			end
			
			f67_arg0.LobbyStatus:completeAnimation()
			f67_arg0.LobbyStatus:setAlpha( 0 )
			f67_local3( f67_arg0.LobbyStatus )
		end
	},
	MapVote = {
		DefaultClip = function ( f72_arg0, f72_arg1 )
			f72_arg0:__resetProperties()
			f72_arg0:setupElementClipCounter( 3 )
			f72_arg0.MapVoteItemRandomZM:completeAnimation()
			f72_arg0.MapVoteItemRandomZM:setAlpha( 1 )
			f72_arg0.clipFinished( f72_arg0.MapVoteItemRandomZM )
			f72_arg0.MapVoteItemPreviousZM:completeAnimation()
			f72_arg0.MapVoteItemPreviousZM:setAlpha( 1 )
			f72_arg0.clipFinished( f72_arg0.MapVoteItemPreviousZM )
			f72_arg0.MapVoteItemNextZM:completeAnimation()
			f72_arg0.MapVoteItemNextZM:setAlpha( 1 )
			f72_arg0.clipFinished( f72_arg0.MapVoteItemNextZM )
		end,
		MapVoteChosenNext = function ( f73_arg0, f73_arg1 )
			f73_arg0:__resetProperties()
			f73_arg0:setupElementClipCounter( 4 )
			f73_arg0.DirectorMapGameTypeAndDifficulty:completeAnimation()
			f73_arg0.DirectorMapGameTypeAndDifficulty:setAlpha( 1 )
			f73_arg0.clipFinished( f73_arg0.DirectorMapGameTypeAndDifficulty )
			local f73_local0 = function ( f74_arg0 )
				f73_arg0.MapVoteItemRandomZM:beginAnimation( 400 )
				f73_arg0.MapVoteItemRandomZM:setAlpha( 0 )
				f73_arg0.MapVoteItemRandomZM:registerEventHandler( "interrupted_keyframe", f73_arg0.clipInterrupted )
				f73_arg0.MapVoteItemRandomZM:registerEventHandler( "transition_complete_keyframe", f73_arg0.clipFinished )
			end
			
			f73_arg0.MapVoteItemRandomZM:completeAnimation()
			f73_arg0.MapVoteItemRandomZM:setAlpha( 1 )
			f73_local0( f73_arg0.MapVoteItemRandomZM )
			local f73_local1 = function ( f75_arg0 )
				f73_arg0.MapVoteItemPreviousZM:beginAnimation( 400 )
				f73_arg0.MapVoteItemPreviousZM:setAlpha( 0 )
				f73_arg0.MapVoteItemPreviousZM:registerEventHandler( "interrupted_keyframe", f73_arg0.clipInterrupted )
				f73_arg0.MapVoteItemPreviousZM:registerEventHandler( "transition_complete_keyframe", f73_arg0.clipFinished )
			end
			
			f73_arg0.MapVoteItemPreviousZM:completeAnimation()
			f73_arg0.MapVoteItemPreviousZM:setAlpha( 1 )
			f73_local1( f73_arg0.MapVoteItemPreviousZM )
			local f73_local2 = function ( f76_arg0 )
				local f76_local0 = function ( f77_arg0 )
					f77_arg0:beginAnimation( 200 )
					f77_arg0:setAlpha( 0 )
					f77_arg0:registerEventHandler( "transition_complete_keyframe", f73_arg0.clipFinished )
				end
				
				f73_arg0.MapVoteItemNextZM:beginAnimation( 200 )
				f73_arg0.MapVoteItemNextZM:registerEventHandler( "interrupted_keyframe", f73_arg0.clipInterrupted )
				f73_arg0.MapVoteItemNextZM:registerEventHandler( "transition_complete_keyframe", f76_local0 )
			end
			
			f73_arg0.MapVoteItemNextZM:completeAnimation()
			f73_arg0.MapVoteItemNextZM:setAlpha( 1 )
			f73_local2( f73_arg0.MapVoteItemNextZM )
		end,
		MapVoteChosenPrevious = function ( f78_arg0, f78_arg1 )
			f78_arg0:__resetProperties()
			f78_arg0:setupElementClipCounter( 4 )
			local f78_local0 = function ( f79_arg0 )
				local f79_local0 = function ( f80_arg0 )
					f80_arg0:beginAnimation( 99 )
					f80_arg0:setAlpha( 1 )
					f80_arg0:registerEventHandler( "transition_complete_keyframe", f78_arg0.clipFinished )
				end
				
				f78_arg0.DirectorMapGameTypeAndDifficulty:beginAnimation( 400 )
				f78_arg0.DirectorMapGameTypeAndDifficulty:registerEventHandler( "interrupted_keyframe", f78_arg0.clipInterrupted )
				f78_arg0.DirectorMapGameTypeAndDifficulty:registerEventHandler( "transition_complete_keyframe", f79_local0 )
			end
			
			f78_arg0.DirectorMapGameTypeAndDifficulty:completeAnimation()
			f78_arg0.DirectorMapGameTypeAndDifficulty:setAlpha( 0 )
			f78_local0( f78_arg0.DirectorMapGameTypeAndDifficulty )
			local f78_local1 = function ( f81_arg0 )
				f78_arg0.MapVoteItemRandomZM:beginAnimation( 200 )
				f78_arg0.MapVoteItemRandomZM:setAlpha( 0 )
				f78_arg0.MapVoteItemRandomZM:registerEventHandler( "interrupted_keyframe", f78_arg0.clipInterrupted )
				f78_arg0.MapVoteItemRandomZM:registerEventHandler( "transition_complete_keyframe", f78_arg0.clipFinished )
			end
			
			f78_arg0.MapVoteItemRandomZM:completeAnimation()
			f78_arg0.MapVoteItemRandomZM:setAlpha( 1 )
			f78_local1( f78_arg0.MapVoteItemRandomZM )
			local f78_local2 = function ( f82_arg0 )
				local f82_local0 = function ( f83_arg0 )
					local f83_local0 = function ( f84_arg0 )
						f84_arg0:beginAnimation( 99 )
						f84_arg0:setAlpha( 0 )
						f84_arg0:registerEventHandler( "transition_complete_keyframe", f78_arg0.clipFinished )
					end
					
					f83_arg0:beginAnimation( 200, Enum[@"luitween"][@"luitween_ease_both"] )
					f83_arg0:setTopBottom( 0, 0, 37, 143 )
					f83_arg0:registerEventHandler( "transition_complete_keyframe", f83_local0 )
				end
				
				f78_arg0.MapVoteItemPreviousZM:beginAnimation( 200 )
				f78_arg0.MapVoteItemPreviousZM:registerEventHandler( "interrupted_keyframe", f78_arg0.clipInterrupted )
				f78_arg0.MapVoteItemPreviousZM:registerEventHandler( "transition_complete_keyframe", f82_local0 )
			end
			
			f78_arg0.MapVoteItemPreviousZM:completeAnimation()
			f78_arg0.MapVoteItemPreviousZM:setTopBottom( 0, 0, 143, 249 )
			f78_arg0.MapVoteItemPreviousZM:setAlpha( 1 )
			f78_local2( f78_arg0.MapVoteItemPreviousZM )
			local f78_local3 = function ( f85_arg0 )
				f78_arg0.MapVoteItemNextZM:beginAnimation( 200 )
				f78_arg0.MapVoteItemNextZM:setAlpha( 0 )
				f78_arg0.MapVoteItemNextZM:registerEventHandler( "interrupted_keyframe", f78_arg0.clipInterrupted )
				f78_arg0.MapVoteItemNextZM:registerEventHandler( "transition_complete_keyframe", f78_arg0.clipFinished )
			end
			
			f78_arg0.MapVoteItemNextZM:completeAnimation()
			f78_arg0.MapVoteItemNextZM:setAlpha( 1 )
			f78_local3( f78_arg0.MapVoteItemNextZM )
		end,
		MapVoteChosenRandom = function ( f86_arg0, f86_arg1 )
			f86_arg0:__resetProperties()
			f86_arg0:setupElementClipCounter( 4 )
			local f86_local0 = function ( f87_arg0 )
				local f87_local0 = function ( f88_arg0 )
					f88_arg0:beginAnimation( 99 )
					f88_arg0:setAlpha( 1 )
					f88_arg0:registerEventHandler( "transition_complete_keyframe", f86_arg0.clipFinished )
				end
				
				f86_arg0.DirectorMapGameTypeAndDifficulty:beginAnimation( 400 )
				f86_arg0.DirectorMapGameTypeAndDifficulty:registerEventHandler( "interrupted_keyframe", f86_arg0.clipInterrupted )
				f86_arg0.DirectorMapGameTypeAndDifficulty:registerEventHandler( "transition_complete_keyframe", f87_local0 )
			end
			
			f86_arg0.DirectorMapGameTypeAndDifficulty:completeAnimation()
			f86_arg0.DirectorMapGameTypeAndDifficulty:setAlpha( 0 )
			f86_local0( f86_arg0.DirectorMapGameTypeAndDifficulty )
			local f86_local1 = function ( f89_arg0 )
				local f89_local0 = function ( f90_arg0 )
					local f90_local0 = function ( f91_arg0 )
						f91_arg0:beginAnimation( 99 )
						f91_arg0:setAlpha( 0 )
						f91_arg0:registerEventHandler( "transition_complete_keyframe", f86_arg0.clipFinished )
					end
					
					f90_arg0:beginAnimation( 200, Enum[@"luitween"][@"luitween_ease_both"] )
					f90_arg0:setTopBottom( 0, 0, 37, 143 )
					f90_arg0:registerEventHandler( "transition_complete_keyframe", f90_local0 )
				end
				
				f86_arg0.MapVoteItemRandomZM:beginAnimation( 200 )
				f86_arg0.MapVoteItemRandomZM:registerEventHandler( "interrupted_keyframe", f86_arg0.clipInterrupted )
				f86_arg0.MapVoteItemRandomZM:registerEventHandler( "transition_complete_keyframe", f89_local0 )
			end
			
			f86_arg0.MapVoteItemRandomZM:completeAnimation()
			f86_arg0.MapVoteItemRandomZM:setTopBottom( 0, 0, 249, 355 )
			f86_arg0.MapVoteItemRandomZM:setAlpha( 1 )
			f86_local1( f86_arg0.MapVoteItemRandomZM )
			local f86_local2 = function ( f92_arg0 )
				f86_arg0.MapVoteItemPreviousZM:beginAnimation( 200 )
				f86_arg0.MapVoteItemPreviousZM:setAlpha( 0 )
				f86_arg0.MapVoteItemPreviousZM:registerEventHandler( "interrupted_keyframe", f86_arg0.clipInterrupted )
				f86_arg0.MapVoteItemPreviousZM:registerEventHandler( "transition_complete_keyframe", f86_arg0.clipFinished )
			end
			
			f86_arg0.MapVoteItemPreviousZM:completeAnimation()
			f86_arg0.MapVoteItemPreviousZM:setAlpha( 1 )
			f86_local2( f86_arg0.MapVoteItemPreviousZM )
			local f86_local3 = function ( f93_arg0 )
				f86_arg0.MapVoteItemNextZM:beginAnimation( 200 )
				f86_arg0.MapVoteItemNextZM:setAlpha( 0 )
				f86_arg0.MapVoteItemNextZM:registerEventHandler( "interrupted_keyframe", f86_arg0.clipInterrupted )
				f86_arg0.MapVoteItemNextZM:registerEventHandler( "transition_complete_keyframe", f86_arg0.clipFinished )
			end
			
			f86_arg0.MapVoteItemNextZM:completeAnimation()
			f86_arg0.MapVoteItemNextZM:setAlpha( 1 )
			f86_local3( f86_arg0.MapVoteItemNextZM )
		end,
		DefaultState = function ( f94_arg0, f94_arg1 )
			f94_arg0:__resetProperties()
			f94_arg0:setupElementClipCounter( 4 )
			local f94_local0 = function ( f95_arg0 )
				f94_arg0.MapVoteItemRandomZM:beginAnimation( 400 )
				f94_arg0.MapVoteItemRandomZM:setAlpha( 0 )
				f94_arg0.MapVoteItemRandomZM:registerEventHandler( "interrupted_keyframe", f94_arg0.clipInterrupted )
				f94_arg0.MapVoteItemRandomZM:registerEventHandler( "transition_complete_keyframe", f94_arg0.clipFinished )
			end
			
			f94_arg0.MapVoteItemRandomZM:completeAnimation()
			f94_arg0.MapVoteItemRandomZM:setAlpha( 1 )
			f94_local0( f94_arg0.MapVoteItemRandomZM )
			local f94_local1 = function ( f96_arg0 )
				f94_arg0.MapVoteItemPreviousZM:beginAnimation( 400 )
				f94_arg0.MapVoteItemPreviousZM:setAlpha( 0 )
				f94_arg0.MapVoteItemPreviousZM:registerEventHandler( "interrupted_keyframe", f94_arg0.clipInterrupted )
				f94_arg0.MapVoteItemPreviousZM:registerEventHandler( "transition_complete_keyframe", f94_arg0.clipFinished )
			end
			
			f94_arg0.MapVoteItemPreviousZM:completeAnimation()
			f94_arg0.MapVoteItemPreviousZM:setAlpha( 1 )
			f94_local1( f94_arg0.MapVoteItemPreviousZM )
			local f94_local2 = function ( f97_arg0 )
				f94_arg0.MapVoteItemNextZM:beginAnimation( 400 )
				f94_arg0.MapVoteItemNextZM:setAlpha( 0 )
				f94_arg0.MapVoteItemNextZM:registerEventHandler( "interrupted_keyframe", f94_arg0.clipInterrupted )
				f94_arg0.MapVoteItemNextZM:registerEventHandler( "transition_complete_keyframe", f94_arg0.clipFinished )
			end
			
			f94_arg0.MapVoteItemNextZM:completeAnimation()
			f94_arg0.MapVoteItemNextZM:setAlpha( 1 )
			f94_local2( f94_arg0.MapVoteItemNextZM )
			local f94_local3 = function ( f98_arg0 )
				f94_arg0.LobbyStatus:beginAnimation( 400 )
				f94_arg0.LobbyStatus:setAlpha( 0 )
				f94_arg0.LobbyStatus:registerEventHandler( "interrupted_keyframe", f94_arg0.clipInterrupted )
				f94_arg0.LobbyStatus:registerEventHandler( "transition_complete_keyframe", f94_arg0.clipFinished )
			end
			
			f94_arg0.LobbyStatus:completeAnimation()
			f94_arg0.LobbyStatus:setAlpha( 1 )
			f94_local3( f94_arg0.LobbyStatus )
		end
	},
	MapVoteChosenNext = {
		DefaultClip = function ( f99_arg0, f99_arg1 )
			f99_arg0:__resetProperties()
			f99_arg0:setupElementClipCounter( 4 )
			f99_arg0.DirectorMapGameTypeAndDifficulty:completeAnimation()
			f99_arg0.DirectorMapGameTypeAndDifficulty:setAlpha( 1 )
			f99_arg0.clipFinished( f99_arg0.DirectorMapGameTypeAndDifficulty )
			f99_arg0.MapVoteItemRandomZM:completeAnimation()
			f99_arg0.MapVoteItemRandomZM:setAlpha( 0 )
			f99_arg0.clipFinished( f99_arg0.MapVoteItemRandomZM )
			f99_arg0.MapVoteItemPreviousZM:completeAnimation()
			f99_arg0.MapVoteItemPreviousZM:setAlpha( 0 )
			f99_arg0.clipFinished( f99_arg0.MapVoteItemPreviousZM )
			f99_arg0.MapVoteItemNextZM:completeAnimation()
			f99_arg0.MapVoteItemNextZM:setAlpha( 0 )
			f99_arg0.clipFinished( f99_arg0.MapVoteItemNextZM )
		end
	},
	MapVoteChosenPrevious = {
		DefaultClip = function ( f100_arg0, f100_arg1 )
			f100_arg0:__resetProperties()
			f100_arg0:setupElementClipCounter( 4 )
			f100_arg0.DirectorMapGameTypeAndDifficulty:completeAnimation()
			f100_arg0.DirectorMapGameTypeAndDifficulty:setAlpha( 1 )
			f100_arg0.clipFinished( f100_arg0.DirectorMapGameTypeAndDifficulty )
			f100_arg0.MapVoteItemRandomZM:completeAnimation()
			f100_arg0.MapVoteItemRandomZM:setAlpha( 0 )
			f100_arg0.clipFinished( f100_arg0.MapVoteItemRandomZM )
			f100_arg0.MapVoteItemPreviousZM:completeAnimation()
			f100_arg0.MapVoteItemPreviousZM:setAlpha( 0 )
			f100_arg0.clipFinished( f100_arg0.MapVoteItemPreviousZM )
			f100_arg0.MapVoteItemNextZM:completeAnimation()
			f100_arg0.MapVoteItemNextZM:setAlpha( 0 )
			f100_arg0.clipFinished( f100_arg0.MapVoteItemNextZM )
		end
	},
	MapVoteChosenRandom = {
		DefaultClip = function ( f101_arg0, f101_arg1 )
			f101_arg0:__resetProperties()
			f101_arg0:setupElementClipCounter( 4 )
			f101_arg0.DirectorMapGameTypeAndDifficulty:completeAnimation()
			f101_arg0.DirectorMapGameTypeAndDifficulty:setAlpha( 1 )
			f101_arg0.clipFinished( f101_arg0.DirectorMapGameTypeAndDifficulty )
			f101_arg0.MapVoteItemRandomZM:completeAnimation()
			f101_arg0.MapVoteItemRandomZM:setAlpha( 0 )
			f101_arg0.clipFinished( f101_arg0.MapVoteItemRandomZM )
			f101_arg0.MapVoteItemPreviousZM:completeAnimation()
			f101_arg0.MapVoteItemPreviousZM:setAlpha( 0 )
			f101_arg0.clipFinished( f101_arg0.MapVoteItemPreviousZM )
			f101_arg0.MapVoteItemNextZM:completeAnimation()
			f101_arg0.MapVoteItemNextZM:setAlpha( 0 )
			f101_arg0.clipFinished( f101_arg0.MapVoteItemNextZM )
		end
	},
	SelectedMap = {
		DefaultClip = function ( f102_arg0, f102_arg1 )
			f102_arg0:__resetProperties()
			f102_arg0:setupElementClipCounter( 5 )
			local f102_local0 = function ( f103_arg0 )
				f102_arg0.DirectorMapGameTypeAndDifficulty:beginAnimation( 500, Enum[@"luitween"][@"luitween_ease_out"] )
				f102_arg0.DirectorMapGameTypeAndDifficulty:setTopBottom( 0, 0, 175, 355 )
				f102_arg0.DirectorMapGameTypeAndDifficulty:registerEventHandler( "interrupted_keyframe", f102_arg0.clipInterrupted )
				f102_arg0.DirectorMapGameTypeAndDifficulty:registerEventHandler( "transition_complete_keyframe", f102_arg0.clipFinished )
			end
			
			f102_arg0.DirectorMapGameTypeAndDifficulty:completeAnimation()
			f102_arg0.DirectorMapGameTypeAndDifficulty:setTopBottom( 0, 0, 37, 143 )
			f102_arg0.DirectorMapGameTypeAndDifficulty:setAlpha( 1 )
			f102_local0( f102_arg0.DirectorMapGameTypeAndDifficulty )
			f102_arg0.MapVoteItemRandomZM:completeAnimation()
			f102_arg0.MapVoteItemRandomZM:setAlpha( 0 )
			f102_arg0.clipFinished( f102_arg0.MapVoteItemRandomZM )
			f102_arg0.MapVoteItemPreviousZM:completeAnimation()
			f102_arg0.MapVoteItemPreviousZM:setAlpha( 0 )
			f102_arg0.clipFinished( f102_arg0.MapVoteItemPreviousZM )
			f102_arg0.MapVoteItemNextZM:completeAnimation()
			f102_arg0.MapVoteItemNextZM:setAlpha( 0 )
			f102_arg0.clipFinished( f102_arg0.MapVoteItemNextZM )
			local f102_local1 = function ( f104_arg0 )
				f102_arg0.LobbyStatus:beginAnimation( 500, Enum[@"luitween"][@"luitween_ease_out"] )
				f102_arg0.LobbyStatus:setTopBottom( 0, 0, 150, 170 )
				f102_arg0.LobbyStatus:registerEventHandler( "interrupted_keyframe", f102_arg0.clipInterrupted )
				f102_arg0.LobbyStatus:registerEventHandler( "transition_complete_keyframe", f102_arg0.clipFinished )
			end
			
			f102_arg0.LobbyStatus:completeAnimation()
			f102_arg0.LobbyStatus:setTopBottom( 0, 0, 12, 32 )
			f102_local1( f102_arg0.LobbyStatus )
		end,
		DefaultState = function ( f105_arg0, f105_arg1 )
			f105_arg0:__resetProperties()
			f105_arg0:setupElementClipCounter( 5 )
			local f105_local0 = function ( f106_arg0 )
				f105_arg0.DirectorMapGameTypeAndDifficulty:beginAnimation( 400 )
				f105_arg0.DirectorMapGameTypeAndDifficulty:setAlpha( 0 )
				f105_arg0.DirectorMapGameTypeAndDifficulty:registerEventHandler( "interrupted_keyframe", f105_arg0.clipInterrupted )
				f105_arg0.DirectorMapGameTypeAndDifficulty:registerEventHandler( "transition_complete_keyframe", f105_arg0.clipFinished )
			end
			
			f105_arg0.DirectorMapGameTypeAndDifficulty:completeAnimation()
			f105_arg0.DirectorMapGameTypeAndDifficulty:setTopBottom( 0, 0, 175, 355 )
			f105_arg0.DirectorMapGameTypeAndDifficulty:setAlpha( 1 )
			f105_local0( f105_arg0.DirectorMapGameTypeAndDifficulty )
			f105_arg0.MapVoteItemRandomZM:completeAnimation()
			f105_arg0.MapVoteItemRandomZM:setAlpha( 0 )
			f105_arg0.clipFinished( f105_arg0.MapVoteItemRandomZM )
			f105_arg0.MapVoteItemPreviousZM:completeAnimation()
			f105_arg0.MapVoteItemPreviousZM:setAlpha( 0 )
			f105_arg0.clipFinished( f105_arg0.MapVoteItemPreviousZM )
			f105_arg0.MapVoteItemNextZM:completeAnimation()
			f105_arg0.MapVoteItemNextZM:setAlpha( 0 )
			f105_arg0.clipFinished( f105_arg0.MapVoteItemNextZM )
			local f105_local1 = function ( f107_arg0 )
				f105_arg0.LobbyStatus:beginAnimation( 400 )
				f105_arg0.LobbyStatus:setAlpha( 0 )
				f105_arg0.LobbyStatus:registerEventHandler( "interrupted_keyframe", f105_arg0.clipInterrupted )
				f105_arg0.LobbyStatus:registerEventHandler( "transition_complete_keyframe", f105_arg0.clipFinished )
			end
			
			f105_arg0.LobbyStatus:completeAnimation()
			f105_arg0.LobbyStatus:setTopBottom( 0, 0, 150, 170 )
			f105_arg0.LobbyStatus:setAlpha( 1 )
			f105_local1( f105_arg0.LobbyStatus )
		end
	}
}

CoD.MapVoteZM.__onClose = function ( f108_arg0 )
	f108_arg0.DirectorMapGameTypeAndDifficulty:close()
	f108_arg0.MapVoteItemRandomZM:close()
	f108_arg0.MapVoteItemPreviousZM:close()
	f108_arg0.MapVoteItemNextZM:close()
	f108_arg0.LobbyStatus:close()
end

-- client count (party and matchmaking)
CoD.FooterButton_PartyCount = InheritFrom( LUI.UIElement )
CoD.FooterButton_PartyCount.__defaultWidth = 240
CoD.FooterButton_PartyCount.__defaultHeight = 38
CoD.FooterButton_PartyCount.new = function ( f1_arg0, f1_arg1, f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	local self = LUI.UIHorizontalList.new( f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9, 0, false )
	self:setAlignment( LUI.Alignment.Left )
	self:setClass( CoD.FooterButton_PartyCount )
	self.id = "FooterButton_PartyCount"
	self.soundSet = "default"
	f1_arg0:addElementToPendingUpdateStateList( self )
	
	local Label = LUI.UIText.new( 0, 0, 0, 52, 0, 0, 9, 29 )
	Label:setRGB( 0.49, 0.49, 0.49 )
	Label:setText( LocalizeToUpperString( @"hash_756004A0B4E33CD8" ) )
	Label:setTTF( "ttmussels_regular" )
	Label:setLetterSpacing( 6 )
	Label:setAlignment( Enum[@"hash_67A5123B654282D2"][@"hash_558C8A85F2048829"] )
	self:addElement( Label )
	self.Label = Label
	
	local Spacer2 = LUI.UIImage.new( 0, 0, 58, 64, 0, 0, -4, 44 )
	Spacer2:setRGB( 0, 0, 0 )
	Spacer2:setMaterial( LUI.UIImage.GetCachedMaterial( @"hash_54E6CE42E0799F57" ) )
	self:addElement( Spacer2 )
	self.Spacer2 = Spacer2
	
	local Spacer = LUI.UIImage.new( 0, 0, 52, 58, 0, 0, 1, 49 )
	Spacer:setRGB( 0, 0, 0 )
	Spacer:setMaterial( LUI.UIImage.GetCachedMaterial( @"hash_54E6CE42E0799F57" ) )
	self:addElement( Spacer )
	self.Spacer = Spacer
	
	-- update rpc shit max clients
	local PartyCount = LUI.UIText.new( 0, 0, 64, 153, 0, 0, 9, 29 )
	PartyCount.__String_Reference = function ()
		PartyCount:setText( ToUpper( CoD.DirectorUtility.PrivateLobbyListPlayerCountAndMax() ) )

		--Dvar[@"shield_rpc_lobby_clients_max"]:set(string.sub(CoD.DirectorUtility.PrivateLobbyListPlayerCountAndMax(), 4, #CoD.DirectorUtility.PrivateLobbyListPlayerCountAndMax() - 1))
	end
	
	PartyCount.__String_Reference()
	PartyCount:setTTF( "ttmussels_regular" )
	PartyCount:setLetterSpacing( 6 )
	PartyCount:setAlignment( Enum[@"hash_67A5123B654282D2"][@"hash_558C8A85F2048829"] )
	self:addElement( PartyCount )
	self.PartyCount = PartyCount
	
	local MatchmakingCount = LUI.UIText.new( 0, 0, 64, 153, 0, 0, 9, 29 )
	MatchmakingCount:setAlpha( 0 )
	MatchmakingCount.__String_Reference = function ()
		MatchmakingCount:setText( CoD.DirectorUtility.LobbyListPlayerCountAndMax() )

		local f146_local0 = Engine[@"createmodel"]( Engine[@"getmodel"]( Engine[@"getglobalmodel"](), "lobbyRoot" ), "lobbyList" )
		local f146_local1 = Engine[@"createmodel"]( f146_local0, "playerCount" )
		local f146_local2 = Engine[@"createmodel"]( f146_local0, "maxPlayers" )
		local ClientsCount = Engine[@"getmodelvalue"]( f146_local1 ) or 0
		local MaxClients = Engine[@"getmodelvalue"]( f146_local2 ) or 0

		Dvar[@"shield_rpc_lobby_clients"]:set(ClientsCount)
		Dvar[@"shield_rpc_lobby_clients_max"]:set(MaxClients)
	end
	
	MatchmakingCount.__String_Reference()
	MatchmakingCount:setTTF( "ttmussels_regular" )
	MatchmakingCount:setLetterSpacing( 6 )
	MatchmakingCount:setAlignment( Enum[@"hash_67A5123B654282D2"][@"hash_558C8A85F2048829"] )
	self:addElement( MatchmakingCount )
	self.MatchmakingCount = MatchmakingCount
	
	local f1_local6 = PartyCount
	local f1_local7 = PartyCount.subscribeToModel
	local f1_local8 = Engine[@"hash_78DF2E5447F384B9"]()
	f1_local7( f1_local6, f1_local8["lobbyRoot.privateClient.update"], PartyCount.__String_Reference )
	f1_local6 = PartyCount
	f1_local7 = PartyCount.subscribeToModel
	f1_local8 = Engine[@"hash_78DF2E5447F384B9"]()
	f1_local7( f1_local6, f1_local8["lobbyRoot.gameClient.update"], PartyCount.__String_Reference )
	f1_local6 = MatchmakingCount
	f1_local7 = MatchmakingCount.subscribeToModel
	f1_local8 = Engine[@"hash_78DF2E5447F384B9"]()
	f1_local7( f1_local6, f1_local8["lobbyRoot.privateClient.update"], MatchmakingCount.__String_Reference )
	f1_local6 = MatchmakingCount
	f1_local7 = MatchmakingCount.subscribeToModel
	f1_local8 = Engine[@"hash_78DF2E5447F384B9"]()
	f1_local7( f1_local6, f1_local8["lobbyRoot.gameClient.update"], MatchmakingCount.__String_Reference )
	self:mergeStateConditions( {
		{
			stateName = "Matchmaking",
			condition = function ( menu, element, event )
				return not CoD.ModelUtility.IsGlobalModelValueEqualToEnum( "lobbyRoot.publicLobby.stage", LuaEnum.PUBLIC_LOBBY.INVALID )
			end
		}
	} )
	f1_local6 = self
	f1_local7 = self.subscribeToModel
	f1_local8 = Engine[@"hash_78DF2E5447F384B9"]()
	f1_local7( f1_local6, f1_local8["lobbyRoot.publicLobby.stage"], function ( f5_arg0 )
		f1_arg0:updateElementState( self, {
			name = "model_validation",
			menu = f1_arg0,
			controller = f1_arg1,
			modelValue = f5_arg0:get(),
			modelName = "lobbyRoot.publicLobby.stage"
		} )
	end, false )
	LUI.OverrideFunction_CallOriginalSecond( self, "close", self.__onClose )
	
	if PostLoadFunc then
		PostLoadFunc( self, f1_arg1, f1_arg0 )
	end
	
	return self
end

CoD.FooterButton_PartyCount.__resetProperties = function ( f6_arg0 )
	f6_arg0.Label:completeAnimation()
	f6_arg0.MatchmakingCount:completeAnimation()
	f6_arg0.PartyCount:completeAnimation()
	f6_arg0.Label:setText( LocalizeToUpperString( @"hash_756004A0B4E33CD8" ) )
	f6_arg0.MatchmakingCount:setAlpha( 0 )
	f6_arg0.PartyCount:setAlpha( 1 )
end

CoD.FooterButton_PartyCount.__clipsPerState = {
	DefaultState = {
		DefaultClip = function ( f7_arg0, f7_arg1 )
			f7_arg0:__resetProperties()
			f7_arg0:setupElementClipCounter( 0 )
		end
	},
	Matchmaking = {
		DefaultClip = function ( f8_arg0, f8_arg1 )
			f8_arg0:__resetProperties()
			f8_arg0:setupElementClipCounter( 3 )
			f8_arg0.Label:completeAnimation()
			f8_arg0.Label:setText( LocalizeToUpperString( @"hash_5E20D5225108123D" ) )
			f8_arg0.clipFinished( f8_arg0.Label )
			f8_arg0.PartyCount:completeAnimation()
			f8_arg0.PartyCount:setAlpha( 0 )
			f8_arg0.clipFinished( f8_arg0.PartyCount )
			f8_arg0.MatchmakingCount:completeAnimation()
			f8_arg0.MatchmakingCount:setAlpha( 1 )
			f8_arg0.clipFinished( f8_arg0.MatchmakingCount )
		end
	}
}

CoD.FooterButton_PartyCount.__onClose = function ( f9_arg0 )
	f9_arg0.PartyCount:close()
	f9_arg0.MatchmakingCount:close()
end