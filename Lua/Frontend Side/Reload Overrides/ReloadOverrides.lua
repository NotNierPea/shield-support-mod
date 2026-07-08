--[[
		.\hksc.exe ".\Lua\ReloadOverrides.Lua" -o "C:\Program Files (x86)\Call of Duty Black Ops 4\project-bo4\mods\T8ShieldSupport\Lua\ReloadOverrides.luac"
]]

---------------------------

CoD.ShieldInitLuaFile()

---------------------------

-- First Game Boot Fixes (Hooks issues)
CoD.ReloadOverrides = function()
	CoD.EnhPrintInfo("Reload Overrides...")

	local f0_local0 = function ( f149_arg0, f149_arg1, f149_arg2 )
		if not CoD.isZombie and IsFirstTimeSetup( f149_arg1, Enum[@"emodes"][@"mode_multiplayer"] ) and (not Engine[@"iscampaigngame"]() or not IsFirstTimeSetup( f149_arg1, Enum[@"emodes"][@"mode_campaign"] )) then
			return 
		end
		local f149_local0 = f149_arg0.occludedBy
		while f149_local0 ~= nil do
			if f149_local0.occludedBy ~= nil then
				f149_local0 = f149_local0.occludedBy
			end
			if f149_arg2 == true and f149_local0.disableLeaderChangePopupShutdown ~= nil then
				return 
			end
			while f149_local0 and f149_local0.menuName ~= "Director" do
				f149_local0 = GoBack( f149_local0, f149_arg1 )
			end
			Engine[@"sendclientscriptnotify"]( f149_arg1, "menu_change" .. Engine[@"getlocalclientnum"]( f149_arg1 ), {
				menu = "Main",
				status = "closeToMenu"
			} )
			LuaUtils.MessageDialogForceSubscriptionFire()
			return 
		end
	end

	CoD.DirectorUtility.PostLoad = function ( f181_arg0, f181_arg1 )
		CoD.LobbyUtility.RegisterEventHandlers( f181_arg1 )
		f181_arg1:addMenuOpenedCallback( function ()
			if Engine[@"currentsessionmode"]() == Enum[@"emodes"][@"mode_invalid"] and not f181_arg1._openedEntitlementPopups then
				f181_arg1:registerEventHandler( "entitlement_popups_all_done", function ( element, event )
					if IsKoreaBonusXPSpecialEventActive( f181_arg0 ) then
						CoD.FTUEUtility.ShowFTUESequence( element, f181_arg0, "KoreaSpecialEvent" )
					end
				end )
				f181_arg1._openedEntitlementPopups = true
				CoD.EntitlementUtility.OpenEntitlementPopups( f181_arg0, f181_arg1 )
				CoD.ReloadOverrides()
			end
		end )
		local f181_local0 = DataSources.FreeCursor.getModel( f181_arg0 )
		f181_local0 = f181_local0.hidden
		local f181_local1 = DataSources.FreeCursor.getModel( f181_arg0 )
		f181_local1 = f181_local1.ignoreNextMenuHides
		if f181_local1 and f181_local1:get() then
			f181_local1:set( false )
			f181_local0:set( f181_local0:get() - 1 )
		end
		local f181_local2 = Engine[@"currentsessionmode"]()
		if f181_local2 ~= Enum[@"emodes"][@"mode_invalid"] and f181_local2 ~= Engine[@"getmostrecentplayedmode"]( f181_arg0 ) then
			Engine[@"setmostrecentplayedmode"]( f181_local2 )
			Engine[@"commitprofilechanges"]( f181_arg0 )
			CoD.ReloadOverrides()
		end
		local f181_local3 = Engine[@"getglobalmodel"]()
		f181_local3 = f181_local3:create( "lobbyRoot" )
		local f181_local4 = f181_local3:create( "lobbyList" )
		f181_local4 = f181_local4:create( "playerCount" )
		local f181_local5 = f181_local3:create( "playlistID" )
		local f181_local6 = IsLobbyNetworkModeLive()
		if f181_local6 then
			f181_local6 = CoD.DirectorUtility.GetPlaylists()
		end
		if f181_local6 then
			for f181_local13, f181_local14 in ipairs( CoD.DirectorUtility.MainScreenModes ) do
				if f181_local14.isVisible() then
					local f181_local10 = CoD.DirectorUtility.GetPreferredPlaylistForMainMode( f181_arg0, f181_local14.mainMode, f181_local14.arena )
					if not f181_local10 then
						local f181_local11 = CoD.DirectorUtility.GetFirstOrFeaturedPlaylistEntry( f181_arg0, f181_local6, f181_local14 )
						if f181_local11 and f181_local11.properties then
							local f181_local12 = f181_local11.properties.param.playlist
							if Engine[@"getplaylistinfobyid"]( f181_local12 ) then
								CoD.DirectorUtility.SetPreferredPlaylistForMainMode( f181_arg0, f181_local14.mainMode, f181_local12, f181_local14.arena )
							end
						end
					end
					if f181_local14.arena then
						CoD.DirectorUtility.SetPreferredPlaylistForMainMode( f181_arg0, f181_local14.mainMode, f181_local10, f181_local14.arena )
					end
				end
			end
		end
		local f181_local7 = Engine[@"getplaylistinfobyid"]( Engine[@"getplaylistid"]() )
		if f181_local7.hidden then
			Engine[@"setplaylistid"]( CoD.DirectorUtility.GetPreferredPlaylistForMainMode( f181_arg0, Engine[@"getlobbymainmode"](), LuaUtils.IsArenaMode() ) )
		end
		local f181_local8 = Engine[@"hash_632F6BF9B0A31ED5"]()
		if Engine[@"hash_23ADF2C70B61E0EF"]( f181_local8 ) then
			Engine[@"setplaylistid"]( f181_local8 )
		end
		local f181_local9 = {}
		local f181_local13 = f181_local3:create( "lobbyNav" )
		f181_arg1:subscribeToModel( f181_local13, function ( model )
			local f184_local0 = Engine[@"getmodelvalue"]( model )
			if f184_local0 == LobbyData.GetLobbyMenuIDByName( LuaEnum.UI.MAIN ) then
				local f184_local1 = CoD.Menu.safeCreateMenu( "Main", f181_arg0 )
				local f184_local2 = f181_arg1:getParent()
				f184_local2:addElement( f184_local1 )
				f181_arg1:close()
				f184_local1:menuOpened( f181_arg0, f184_local1 )
				return 
			end
			DisableAllMenuInput( f181_arg1, false )
			Engine[@"forcenotifymodelsubscriptions"]( Engine[@"createmodel"]( Engine[@"getglobalmodel"](), "pubstorageFilesChanged" ) )
			CoD.PlayFrontendMusicForLobby( f184_local0 )
			local f184_local2 = LobbyData.GetLobbyMenuByID( f184_local0 )
			local f184_local3 = LuaUtils.GetEModeForLobbyMainMode( f184_local2[@"mainmode"] )
			if f184_local3 ~= nil then
				if f184_local3 == Enum[@"emodes"][@"mode_multiplayer"] and f184_local2[@"id"] == LobbyData.GetLobbyMenuIDByName( LuaEnum.UI.DIRECTOR_ONLINE_MP_TRAINING ) then
					CoD.FTUEUtility.ShouldBlockMPFTUE = false
				elseif f184_local3 == Enum[@"emodes"][@"mode_multiplayer"] and CoD.FTUEUtility.ShouldBlockMPFTUE then
					CoD.FTUEUtility.ShouldBlockMPFTUE = false
				elseif f181_arg1:getParent() then
					if f184_local3 == Enum[@"emodes"][@"mode_multiplayer"] then
						if f184_local2[@"lobbymode"] == Enum[@"lobbymode"][@"lobby_mode_arena"] then
							if not CoD.FTUEUtility.ShowFTUESequenceIfNotSeen( f181_arg1, f181_arg0, "LeaguePlayIntroduction" ) then
								CoD.FTUEUtility.ShowFTUESequenceIfNotSeen( f181_arg1, f181_arg0, "GestureChanges" )
							end
						elseif not CoD.DirectorUtility.IsMPFirstTimeComplete( f181_arg0 ) and CoD.FTUEUtility.SetCurrentSequenceThroughMode( f181_arg1, f181_arg0, f184_local3 ) then
							OpenOverlay( f181_arg1, "FTUEInfoScreen", f181_arg0, nil )
							CoD.DirectorUtility.SetMPFirstTimeComplete( f181_arg0, true )
						else
							CoD.FTUEUtility.ShowFTUESequenceIfNotSeen( f181_arg1, f181_arg0, "GestureChanges" )
						end
					elseif not Engine[@"isfirsttimecomplete"]( f181_arg0, f184_local3 ) and CoD.FTUEUtility.SetCurrentSequenceThroughMode( f181_arg1, f181_arg0, f184_local3 ) then
						OpenOverlay( f181_arg1, "FTUEInfoScreen", f181_arg0, nil )
						Engine[@"setfirsttimecomplete"]( f181_arg0, f184_local3, true )
					elseif f184_local3 == Enum[@"emodes"][@"mode_warzone"] then
						CoD.FTUEUtility.ShowFTUESequenceIfNotSeen( f181_arg1, f181_arg0, "GestureChanges" )
					elseif f184_local3 == Enum[@"emodes"][@"mode_zombies"] then
						CoD.FTUEUtility.ShowFTUESequenceIfNotSeen( f181_arg1, f181_arg0, "ZMGestureChanges" )
					end
				end
				if f184_local3 ~= Enum[@"emodes"][@"mode_invalid"] then
					local f184_local4
					if f184_local0 ~= LobbyData.GetLobbyMenuIDByName( LuaEnum.UI.DIRECTOR_ONLINE_MP_PUBLIC ) and f184_local0 ~= LobbyData.GetLobbyMenuIDByName( LuaEnum.UI.DIRECTOR_ONLINE_MP_ARENA_MATCHMAKING ) then
						f184_local4 = false
					else
						f184_local4 = true
					end
					for f184_local5 = 0, Engine[@"getmaxcontrollercount"]() - 1, 1 do
						if Engine[@"iscontrollerbeingused"]( f184_local5 ) then
							CoD.PlayerRoleUtility[@"hash_12B307D12327547E"]( f184_local5 )
							CoD.PlayerRoleUtility[@"hash_4D150AB859D3C2D7"]( f184_local5 )
							CoD.PlayerRoleUtility[@"hash_718E8191AD006E3E"]( f184_local5 )
							CoD.CACUtility[@"hash_5E6E8B9715ECC201"]( f184_local5, f184_local4 )
						end
					end
				end
			end
			CoD.ReloadOverrides()
		end, true )
		local f181_local14, f181_local10, f181_local11 = nil
		local f181_local12 = function ()
			local f185_local0 = Engine[@"getglobalmodel"]()
			f185_local0 = f185_local0:create( "MapVote.mapVoteMapNext" )
			local f185_local1 = f185_local0 and f185_local0:get()
			if not f185_local1 or f185_local1 == @"hash_0" then
				local f185_local2 = Engine[@"getglobalmodel"]()
				f185_local2 = f185_local2.lobbyRoot.selectedMapId
				f185_local1 = f185_local2 and f185_local2:get()
			end
			local f185_local2 = Engine[@"getglobalmodel"]()
			f185_local2 = f185_local2.lobbyRoot.lobbyNav:get()
			if f185_local2 then
				local f185_local3 = LobbyData.GetLobbyMenuByID( f185_local2 )
				if f185_local3 then
					local f185_local4 = LuaUtils.GetEModeForLobbyMainMode( f185_local3[@"mainmode"] )
					if f185_local4 ~= nil and f185_local4 ~= f181_local14 then
						if f185_local3[@"lobbymode"] ~= Enum[@"lobbymode"][@"hash_3B3A1BBF18C0B176"] then
							CoD.DirectorUtility.ForceStreamDirectorImagesForMode( f181_arg0, f185_local4 )
							if CoD.DirectorUtility.IsGameTypeCombatTraining( Dvar[@"g_gametype"]:get() ) then
								local f185_local5 = LuaUtils.EModeData[f185_local4]
								if f185_local5 then
									SetMap( f181_arg0, f185_local5.DefaultMap, false )
									SetGameType( f181_arg0, f185_local5.DefaultGameType )
								end
							end
						end
					elseif f185_local3[@"mainmode"] == Enum[@"lobbymainmode"][@"lobby_mainmode_invalid"] then
						CoD.DirectorUtility.ForceStreamDirectorImagesForMode( f181_arg0, Enum[@"emodes"][@"mode_invalid"] )
					elseif CoD.DirectorUtility.IsLobbyMenu( f181_arg0, LuaEnum.UI.DIRECTOR_ONLINE_MP_PREGAME ) and CoD.HUDUtility.IsGameTypeBareBones() then
						SetGameType( f181_arg0, LuaUtils.EModeData[f185_local4].DefaultGameType )
					end
					f181_local14 = f185_local4
					if f185_local4 ~= nil and f185_local4 ~= Enum[@"emodes"][@"mode_invalid"] and (f181_local10 ~= f185_local3[@"name"] == LuaUtils.LobbyMainModeData[f185_local3[@"mainmode"]].OnlineCustomMenu or f181_local11 ~= f185_local3[@"name"] == LuaUtils.LobbyMainModeData[f185_local3[@"mainmode"]].OnlineArenaCustomMenu) then
						if f181_local10 or f181_local11 then
							local f185_local6 = Engine[@"getglobalmodel"]()
							f185_local6 = f185_local6.lobbyRoot:create( "closePopups" )
							f185_local6:forceNotifySubscriptions()
						end
						f181_local10 = f185_local3[@"name"] == LuaUtils.LobbyMainModeData[f185_local3[@"mainmode"]].OnlineCustomMenu
						f181_local11 = f185_local3[@"name"] == LuaUtils.LobbyMainModeData[f185_local3[@"mainmode"]].OnlineArenaCustomMenu
					end
				end
				if f185_local1 and CoD.mapsTable[f185_local1] then
					if (IsBooleanDvarSet( "use_wz_escape" ) or IsBooleanDvarSet( "use_wz_escape_alt" ) or IsBooleanDvarSet( "use_wz_alt" )) then
						if IsBooleanDvarSet( "use_wz_escape" ) or IsBooleanDvarSet( "use_wz_escape_alt" ) then
							if IsBooleanDvarSet( "use_wz_escape_alt" ) then
								SetMap( f181_arg0, @"wz_escape_alt", false )
							else
								SetMap( f181_arg0, @"wz_escape", false )
							end
							--SetGameType( f181_arg0, "warzone_duo" )
							--Engine[@"setgametypesetting"]( "killcamHistorySeconds", 1800 )
							--Engine[@"setgametypesetting"]( "allowKillcam", 1 )
							--Engine[@"setgametypesetting"]( "maxTeamPlayers", 4 )
							--Engine[@"setgametypesetting"]( "wzPlayerInsertionTypeIndex", 1 )
							--Engine[@"setgametypesetting"]( "wzAIZones", 0 )
							--Engine[@"setgametypesetting"]( "wzZombies", 0 )
						else
							SetMap( f181_arg0, @"wz_open_skyscrapers_alt", false )
						end
					elseif not Engine[@"ismapvalid"]( f185_local1 ) and not CoD.LobbyUtility.isMapFree( f185_local1 ) then
						local f185_local4 = LuaUtils.GetDefaultMap( f185_local3 )
						if f185_local4 then
							f185_local4 = Engine[@"converttoxhash"]( f185_local4 )
							if f185_local4 ~= @"hash_0" and CoD.mapsTable[f185_local4] then
								SetMap( f181_arg0, f185_local4, false )
							end
						end
					end
					if f185_local3[@"mainmode"] == Enum[@"lobbymainmode"][@"lobby_mainmode_zm"] then
						CoD.ZMStoryUtility.SetSelectedStoryToCurrentMapStory( f181_arg0 )
					end
				end
			end
			CoD.ReloadOverrides()
		end
		
		local f181_local15 = function ()
			if IsLobbyNetworkModeLive() then
				local f186_local0 = f181_local5:get()
				if f186_local0 ~= nil then
					local f186_local1 = Engine[@"getplaylistinfobyid"]( f186_local0 )
					if f186_local1 then
						local f186_local2 = f181_local4:get()
						local f186_local3 = DataSources.ZMLobbyExclusions.getModel()
						local f186_local4 = f186_local3:create( "PublicMatchExcluded" )
						f186_local4:set( f186_local1.excludePublicLobby )
						if f186_local2 ~= 1 then
							f186_local4 = f186_local3:create( "PrivateMatchName" )
							f186_local4:set( true )
						else
							f186_local4 = f186_local3:create( "PrivateMatchName" )
							f186_local4:set( false )
						end
						f186_local4 = Engine[@"getplaylistinfobyid"]( f186_local0 )
						local f186_local5 = f186_local3:create( "PrivateMatchExcluded" )
						local f186_local6 = f186_local5
						f186_local5 = f186_local5.set
						local f186_local7
						if #f186_local4.rotationList <= 1 then
							f186_local7 = not f186_local1.excludePublicLobby
						else
							f186_local7 = true
						end
						f186_local5( f186_local6, f186_local7 )
					end
				end
			end
			CoD.ReloadOverrides()
		end
		
		local f181_local16 = function ()
			if IsLobbyNetworkModeLive() and IsZombies() then
				CoD.DirectorUtility.InitQuickPlayModel( f181_arg0 )
			end
			CoD.ReloadOverrides()
		end
		
		local f181_local17 = function ()
			CoD.DirectorUtility.HideLoadoutPreview( f181_arg0 )
			CoD.ReloadOverrides()
		end
		
		f181_arg1:subscribeToModel( f181_local4, f181_local15, true )
		f181_arg1:subscribeToModel( f181_local5, f181_local15, true )
		f181_arg1:subscribeToModel( f181_local13, f181_local16, true )
		f181_arg1:subscribeToModel( f181_local13, f181_local17, true )
		f181_arg1:subscribeToModel( f181_local13, f181_local12, true )
		local f181_local18 = f181_local3:create( "selectedMapId" )
		local f181_local19 = Engine[@"getglobalmodel"]()
		f181_local19 = f181_local19:create( "MapVote.mapVoteMapNext" )
		f181_arg1:subscribeToModel( f181_local18, f181_local12, true )
		f181_arg1:subscribeToModel( f181_local19, f181_local12, true )
		f181_arg1:subscribeToModel( f181_local3:create( "lobbyMainMode" ), function ( model )
			f0_local0( f181_arg1, f181_arg0, true )
			Engine[@"markpsdatadirty"]( f181_arg0, true )
			if model:get() == Enum[@"lobbymainmode"][@"lobby_mainmode_zm"] then
				Engine[@"setdvar"]( "tu13_enableMPRankedItemPurchasedCheck", 0 )
			else
				Engine[@"setdvar"]( "tu13_enableMPRankedItemPurchasedCheck", 1 )
			end
			CoD.ReloadOverrides()
		end, false )
		f181_arg1:subscribeToModel( f181_local3.privateClient.count, function ( model )
			LuaUtils.ReloadOnlinePlaylists()
			CoD.ReloadOverrides()
		end, false )
		f181_arg1:subscribeToModel( f181_local3:create( "closePopups" ), function ( model )
			f0_local0( f181_arg1, f181_arg0, false )
			CoD.ReloadOverrides()
		end, false )
		f181_arg1.occluded = false
		f181_arg1:subscribeToModel( Engine[@"createmodel"]( Engine[@"getglobalmodel"](), "pubstorageFilesChanged" ), function ( model )
			if Engine[@"islobbyactive"]( Enum[@"lobbymodule"][@"lobby_module_client"], Enum[@"lobbytype"][@"lobby_type_game"] ) then
				return 
			elseif Engine[@"getmodelvalue"]( model ) == true and f181_arg1.occluded ~= nil and f181_arg1.occluded == false then
				CoD.OverlayUtility.OpenPublisherFilesChangedOverlay( f181_arg0, f181_arg1 )
			end
			CoD.ReloadOverrides()
		end, false )
		f181_arg1:registerEventHandler( "occlusion_change", function ( element, event )
			element.occluded = event.occluded
			if event.occluded == false then
				Engine[@"forcenotifymodelsubscriptions"]( Engine[@"createmodel"]( Engine[@"getglobalmodel"](), "pubstorageFilesChanged" ) )
			end
			local f193_local0 = f181_local3:create( "lobbyMenuOccluded" )
			f193_local0:set( event.occluded )
			CoD.DirectorUtility.ClearSelectedClient( event.controller )
			element:OcclusionChange( event )
			CoD.ReloadOverrides()
		end )
		f181_arg1:subscribeToModel( Engine[@"createmodel"]( Engine[@"getglobalmodel"](), "lobbyDebug.debugEnabled" ), function ( model )
			if Engine[@"getmodelvalue"]( model ) then
				if not f181_arg1.LobbyDebugyOverlay then
					local f194_local0 = CoD.LobbyDebugOverlay.new( f181_arg1, f181_arg0, 0, 0, 0, CoD.LobbyDebugOverlay.__defaultWidth, 0, 0, 0, CoD.LobbyDebugOverlay.__defaultHeight )
					f194_local0:setLeftRight( true, true, 0, 0 )
					f194_local0:setTopBottom( true, true, 0, 0 )
					f181_arg1:addElement( f194_local0 )
					f181_arg1:sendInitializationEvents( f181_arg0, f194_local0 )
					f181_arg1.LobbyDebugOverlay = f194_local0
				end
			elseif f181_arg1.LobbyDebugOverlay then
				f181_arg1.LobbyDebugOverlay:close()
			end
			CoD.ReloadOverrides()
		end )
		CoD.OptionsUtility.SetGameSettingValidateFunction( "maxPlayers", CoD.DirectorUtility.ValidateMaxPlayers )
		if CoD.isPC then
			CoD.PCUtility.SetupUIMenuShortcuts( f181_arg1, f181_arg0 )
		end
		if Engine[@"currentsessionmode"]() == Enum[@"emodes"][@"mode_invalid"] then
			Engine[@"execnow"]( f181_arg0, "exec gamedata/configs/common/frontend_gametype_settings.cfg" )
			if IsLobbyNetworkModeLive() and Dvar[@"hash_65ACE5F4E5F09824"]:exists() then
				local f181_local20 = Dvar[@"hash_65ACE5F4E5F09824"]:get()
				if IsGameTrial() then
					Engine[@"setclanname"]( f181_arg0, f181_local20 )
				elseif string.lower( Engine[@"getclanname"]( f181_arg0 ) ) == string.lower( f181_local20 ) then
					Engine[@"hash_267D4F08B41BB4DD"]( f181_arg0 )
				end
			end
		end
		if Engine[@"isdevelopmentbuild"]() then
			CoD.AARUtility.InitAARDevgui( f181_arg1, f181_arg0 )
		end

		CoD.EnhPrintInfo("calling postload reload overrides")
		CoD.ReloadOverrides()
	end

	CoD.WZRulesReloads()
	CoD.PlaylistsReload()
	CoD.MasterCraftReload()
	CoD.ShieldOptionsReload()
	CoD.CreateClassFixReload()
	CoD.MPExtraGamemodesReload()
	CoD.MiscReload()
	CoD.UnlockReload()
	CoD.DirectorSelectOverride()
	CoD.ChatOverride()
	CoD.ReactivesReload()
end

CoD.RefreshShieldShit = function()
	-- reset lock lobby lol
	Dvar[@"shield_lock_lobby"]:set(0)

	CoD.MatchmakingDvarsReload()
	CoD.RefreshRPCDvars()
	CoD.ReloadOverrides()
end