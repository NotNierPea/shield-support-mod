--[[
		.\hksc.exe ".\Lua\TeamChangeFixes.Lua" -o "C:\Program Files (x86)\Call of Duty Black Ops 4\project-bo4\mods\T8ShieldSupport\Lua\Game\TeamChangeFixes.luac"
]]

---------------------------

if CoD.isFrontend then
	return
end

CoD.ShieldInitLuaFile()

---------------------------

CoD.IsTeamChangeAllowed = function ( f35_arg0 )
	return true
end

local function LoadTeamChangeMenu()
	-- Team Change Notice (need to be added before datasource)
	local PostLoadFuncTeam = function ( self, controller )
		local f1_local0 = function ()
			self.buttonList:updateDataSource( true )
		end
		
		local f1_local1 = self
		local f1_local2 = self.subscribeToModel
		local f1_local3 = Engine[@"getmodelforcontroller"]( controller )
		f1_local2( f1_local1, f1_local3:create( "Clients.clientCount" ), function ( f3_arg0 )
			f1_local0()
		end )
		f1_local1 = self
		f1_local2 = self.subscribeToModel
		f1_local3 = Engine[@"getmodelforcontroller"]( controller )
		f1_local2( f1_local1, f1_local3:create( "Clients.clientChangedTeam" ), function ( f4_arg0 )
			f1_local0()
		end )
		f1_local1 = self
		f1_local2 = self.subscribeToModel
		f1_local3 = Engine[@"getmodelforcontroller"]( controller )
		f1_local2( f1_local1, f1_local3:create( "CharacterSelection.clientUpdated" ), function ( f5_arg0 )
			f1_local0()
		end )
	end

	CoD.StartMenu_ChangeTeam = InheritFrom( LUI.UIElement )
	CoD.StartMenu_ChangeTeam.__defaultWidth = 1725
	CoD.StartMenu_ChangeTeam.__defaultHeight = 780
	CoD.StartMenu_ChangeTeam.new = function ( f6_arg0, f6_arg1, f6_arg2, f6_arg3, f6_arg4, f6_arg5, f6_arg6, f6_arg7, f6_arg8, f6_arg9 )
		local self = LUI.UIElement.new( f6_arg2, f6_arg3, f6_arg4, f6_arg5, f6_arg6, f6_arg7, f6_arg8, f6_arg9 )
		self:setClass( CoD.StartMenu_ChangeTeam )
		self.id = "StartMenu_ChangeTeam"
		self.soundSet = "ChooseDecal"
		self.onlyChildrenFocusable = true
		self.anyChildUsesUpdateState = true
		
		local playerList = LUI.UIList.new( f6_arg0, f6_arg1, 2, 0, nil, false, false, false, false )
		playerList:setLeftRight( 0.5, 0.5, 50, 650 )
		playerList:setTopBottom( 0, 0, 150, 850 )
		playerList:setWidgetType( CoD.InGamePlayerListRow )
		playerList:setVerticalCount( 18 )
		playerList:setAlignment( Enum[@"luialignment"][@"lui_alignment_left"] )
		playerList:setDataSource( "InGamePlayerListRowData" )
		self:addElement( playerList )
		self.playerList = playerList
		
		local buttonList = LUI.UIList.new( f6_arg0, f6_arg1, 26, 0, nil, false, false, false, false )
		buttonList:setLeftRight( 0.5, 0.5, -644, 8 )
		buttonList:setTopBottom( 0, 0, 150, 576 )
		buttonList:setWidgetType( CoD.StartMenu_ChangeTeam_ListWidget )
		buttonList:setHorizontalCount( 3 )
		buttonList:setVerticalCount( 2 )
		buttonList:setSpacing( 26 )
		buttonList:setAlignment( Enum[@"luialignment"][@"lui_alignment_right"] )
		buttonList:setDataSource( "ChangeTeamOptions" )
		buttonList:linkToElementModel( buttonList, "disabled", true, function ( model, f7_arg1 )
			CoD.Menu.UpdateButtonShownState( f7_arg1, f6_arg0, f6_arg1, Enum[@"luibutton"][@"lui_key_xba_pscross"] )
		end )
		buttonList:registerEventHandler( "gain_focus", function ( element, event )
			local f8_local0 = nil
			if element.gainFocus then
				f8_local0 = element:gainFocus( event )
			elseif element.super.gainFocus then
				f8_local0 = element.super:gainFocus( event )
			end
			CoD.Menu.UpdateButtonShownState( element, f6_arg0, f6_arg1, Enum[@"luibutton"][@"lui_key_xba_pscross"] )
			return f8_local0
		end )
		f6_arg0:AddButtonCallbackFunction( buttonList, f6_arg1, Enum[@"luibutton"][@"lui_key_xba_pscross"], "ui_confirm", function ( element, menu, controller, model )
			if not CoD.ModelUtility.IsSelfModelValueTrue( element, controller, "disabled" ) then
				ProcessListAction( self, element, controller, menu )
				return true
			else
				
			end
		end, function ( element, menu, controller )
			if not CoD.ModelUtility.IsSelfModelValueTrue( element, controller, "disabled" ) then
				CoD.Menu.SetButtonLabel( menu, Enum[@"luibutton"][@"lui_key_xba_pscross"], @"hash_72641978FD3DC17A", nil, "ui_confirm" )
				return true
			else
				return false
			end
		end, false )
		self:addElement( buttonList )
		self.buttonList = buttonList

		local RespawnNote = LUI.UIText.new(0.20, 0.20, -100, 500, 0.80, 0.80, 0, 50)
		RespawnNote:setText("Note: You will need to wait at least 10 seconds before Respawning!")
		RespawnNote:setTTF("notosans_bold")
		RespawnNote:setBackingType(2)
		RespawnNote:setBackingColor(0.04, 0.81, 1)
		RespawnNote:setBackingAlpha(0.01)
		RespawnNote:setBackingXPadding(12)
		RespawnNote:setBackingYPadding(6)
		RespawnNote:setLetterSpacing(0.5)
		self:addElement(RespawnNote)
		self.RespawnNote = RespawnNote
		
		playerList.id = "playerList"
		buttonList.id = "buttonList"
		self.__defaultFocus = buttonList
		LUI.OverrideFunction_CallOriginalSecond( self, "close", self.__onClose )
		
		if PostLoadFunc then
			PostLoadFuncTeam( self, f6_arg1, f6_arg0 )
		end

		CoD.EnhPrintInfo("Called", "Team Change Menu")
		
		return self
	end

	CoD.StartMenu_ChangeTeam.__onClose = function ( f11_arg0 )
		f11_arg0.playerList:close()
		f11_arg0.buttonList:close()
		f11_arg0.RespawnNote:close()
	end
end

---------------------------

-- Team Fix
DataSources.StartMenuTabs = ListHelper_SetupDataSource( "StartMenuTabs", function ( f17_arg0, f17_arg1 )
	LoadTeamChangeMenu()

	local f17_local0 = {}
	local f17_local4
	local f17_local1 = CoD.StartMenuUtility.GetSessionModeFromLobby()
	local f17_local2 = Engine[@"getmodelforcontroller"]( f17_arg0 )
	if Engine[@"isdemoplaying"]() then
		table.insert( f17_local0, {
			models = {
				name = Engine[@"hash_4F9F1239CFD921FE"]( @"hash_74C78B93031D0F44" ),
				tabWidget = "CoD.StartMenu_Theater"
			},
			properties = {
				tabId = "theater"
			}
		} )
	elseif Engine[@"isingame"]() then
		if Engine[@"iszombiesgame"]() then
			table.insert( f17_local0, {
				models = {
					name = SessionModeToUnlocalizedSessionModeCaps( Engine[@"currentsessionmode"]() ),
					tabWidget = "CoD.StartMenu_GameOptions_ZM"
				},
				properties = {
					tabId = "gameOptions"
				}
			} )
			if CoD.BaseUtility.IsDvarEnabled( "ui_enableContractsAndBounties" ) and IsPublicOnlineGame() then
				table.insert( f17_local0, {
					models = {
						name = @"hash_6616EBD2B8F67E64",
						tabWidget = "CoD.StartMenu_Contracts"
					},
					properties = {
						tabId = "contracts"
					}
				} )
			end
		else
			if CoD.isWarzone then
				table.insert( f17_local0, {
					models = {
						name = @"hash_3315E0B90BD1F6DD",
						tabWidget = "CoD.StartMenu_WZTeamScoreboard"
					},
					properties = {
						tabId = "teamScoreboard"
					}
				} )
				local f17_local3 = f17_local2.deadSpectator.playerIndex
				local f17_local4
				if f17_local3:get() == Engine[@"getclientnum"]( f17_arg0 ) or f17_local3:get() == -1 then
					f17_local4 = false
				else
					f17_local4 = true
				end
				f17_arg1._isPlayerSpectating = f17_local4
				if not f17_arg1._isPlayerSpectating then
					f17_local4 = Engine[@"getmodelforcontroller"]( f17_arg0 )
					if f17_local4.hudItems.playerOnInfectedPlatoon:get() == 0 then
						table.insert( f17_local0, {
							models = {
								name = @"hash_61346019482BDC3C",
								tabWidget = "CoD.StartMenu_Inventory"
							},
							properties = {
								tabId = "inventory",
								selectIndex = true
							}
						} )
					end
				end
				if CoD.BaseUtility.IsDvarEnabled( "ui_enableContractsAndBounties" ) and IsPublicOnlineGame() then
					table.insert( f17_local0, {
						models = {
							name = @"hash_6616EBD2B8F67E64",
							tabWidget = "CoD.StartMenu_Contracts"
						},
						properties = {
							tabId = "contracts"
						}
					} )
				end
			elseif CoD.isCampaign then
				table.insert( f17_local0, {
					models = {
						name = SessionModeToUnlocalizedSessionModeCaps( Engine[@"currentsessionmode"]() ),
						tabWidget = "CoD.StartMenu_GameOptions_ZM"
					},
					properties = {
						tabId = "gameOptions"
					}
				} )
			elseif IsGameTypeCombatTraining() then
				table.insert( f17_local0, {
					models = {
						name = @"hash_18B0D8B4A861BBC5",
						tabWidget = "CoD.StartMenu_ChangeSpecialist_CT"
					},
					properties = {
						tabId = "changeSpecialist"
					}
				} )
			elseif not CoD.CodCasterUtility.IsCodCasterOrAssigned( f17_arg0 ) then
				local f17_local3 = Engine[@"getmodelforcontroller"]( f17_arg0 )
				if f17_local3.PositionDraft.stage:get() ~= CoD.PlayerRoleUtility.DraftStage.DRAFT_STAGE_DRAFT then
					table.insert( f17_local0, {
						models = {
							name = @"hash_18B0D8B4A861BBC5",
							tabWidget = "CoD.StartMenu_ChangeSpecialist"
						},
						properties = {
							tabId = "changeSpecialist"
						}
					} )
				end
				if CoD.BaseUtility.IsDvarEnabled( "ui_enableContractsAndBounties" ) and IsPublicOnlineGame() then
					table.insert( f17_local0, {
						models = {
							name = @"hash_6616EBD2B8F67E64",
							tabWidget = "CoD.StartMenu_Contracts"
						},
						properties = {
							tabId = "contracts"
						}
					} )
				end
			end

			if not CoD.isWarzone then
				table.insert( f17_local0, {
					models = {
						name = @"hash_4E3B1996EF83F7ED",
						tabWidget = "CoD.StartMenu_ChangeTeam"
					},
					properties = {
						tabId = "changeTeam"
					}
				} )
			end

		end
	elseif not LuaUtils.OfflineOnlyDemo() and not IsPlayerAGuest( f17_arg0 ) then
		local f17_local4 = LobbyData.GetCurrentMenuTarget()
		local f17_local5 = f17_local4[@"id"] == LobbyData.GetLobbyMenuIDByName( LuaEnum.UI.DIRECTOR_ONLINE_MP_TRAINING )
		local f17_local6 = DataSources.StartMenuBreadcrumbs.getModel( f17_arg0 )
		DataSources.StartMenuBreadcrumbs.recreateStartTabBreadcrumbModelsIfNeeded( f17_arg0, f17_local1, f17_local6 )
		if not IsLobbyNetworkModeLAN() and (not CoD.DirectorUtility.IsOfflineDemo() or Engine[@"hash_5CB675CA7856DA25"]()) and f17_local1 ~= Enum[@"emodes"][@"mode_invalid"] and not f17_local5 then
			local f17_local7 = "CoD.StartMenu_Barracks"
			if f17_local1 == Enum[@"emodes"][@"mode_zombies"] then
				f17_local7 = "CoD.StartMenu_Barracks_ZM"
			elseif f17_local1 == Enum[@"emodes"][@"mode_warzone"] then
				f17_local7 = "CoD.StartMenu_Barracks_WZ"
			elseif IsArenaMode() then
				f17_local7 = "CoD.StartMenu_Barracks_WL"
			end
			if not IsCustomLobby() then
				table.insert( f17_local0, {
					models = {
						name = @"hash_310B1AA71AB55844",
						tabWidget = f17_local7
					},
					properties = {
						tabId = "barracks"
					}
				} )
			end
		end
		if not CoD.DirectorUtility.DisableForCurrentMilestone( f17_arg0 ) or Engine[@"hash_5CB675CA7856DA25"]() then
			if not IsLobbyNetworkModeLAN() and (not IsCustomLobby() or f17_local5) then
				if f17_local1 == Enum[@"emodes"][@"mode_multiplayer"] then
					if f17_local5 then
						table.insert( f17_local0, {
							models = {
								name = @"hash_5E66423FDAAC9FBF",
								tabWidget = "CoD.Challenges_MP_Stickerbook_CombatTraining"
							},
							properties = {
								tabId = "challenges"
							}
						} )
					else
						table.insert( f17_local0, {
							models = {
								name = @"hash_5E66423FDAAC9FBF",
								tabWidget = "CoD.Challenges_MP_Summary"
							},
							properties = {
								tabId = "challenges"
							}
						} )
					end
				elseif f17_local1 == Enum[@"emodes"][@"mode_zombies"] then
					table.insert( f17_local0, {
						models = {
							name = @"hash_5E66423FDAAC9FBF",
							tabWidget = "CoD.Challenges_ZM_Summary"
						},
						properties = {
							tabId = "challenges"
						}
					} )
				elseif f17_local1 == Enum[@"emodes"][@"mode_warzone"] then
					table.insert( f17_local0, {
						models = {
							name = @"hash_5E66423FDAAC9FBF",
							tabWidget = "CoD.ChallengesWZSummary"
						},
						properties = {
							tabId = "challenges"
						}
					} )
				else
					table.insert( f17_local0, {
						models = {
							name = @"hash_5E66423FDAAC9FBF",
							tabWidget = "CoD.ChallengesGlobalStickerbook"
						},
						properties = {
							tabId = "challenges"
						}
					} )
				end
			end
			if not f17_local5 then
				table.insert( f17_local0, {
					models = {
						name = @"hash_20F635C8E33C499F",
						tabWidget = "CoD.StartMenu_Identity",
						breadcrumb = f17_local6.identity
					},
					properties = {
						tabId = "identity"
					}
				} )
			end
		end
	end
	if IsGameTypeDOA() and Engine[@"isingame"]() then
		local f17_local3 = table.insert
		local f17_local4 = f17_local0
		local f17_local5 = {
			models = {
				name = @"hash_1CD4D3B3B862F8C1",
				tabWidget = "CoD.StartMenu_Options_DOA"
			}
		}
		local f17_local6 = {
			tabId = "options"
		}
		local f17_local7 = Dvar[@"ui_execdemo"]:get()
		if f17_local7 then
			f17_local7 = not Engine[@"isingame"]()
		end
		f17_local6.selectIndex = f17_local7
		f17_local5.properties = f17_local6
		f17_local3( f17_local4, f17_local5 )
	elseif not CoD.isPC then
		local f17_local3 = table.insert
		local f17_local4 = f17_local0
		local f17_local5 = {
			models = {
				name = @"hash_1CD4D3B3B862F8C1",
				tabWidget = "CoD.StartMenu_Options"
			}
		}
		local f17_local6 = {
			tabId = "options"
		}
		local f17_local7 = Dvar[@"ui_execdemo_gamescom"]:get()
		if f17_local7 then
			f17_local7 = not Engine[@"isingame"]()
		end
		f17_local6.selectIndex = f17_local7
		f17_local5.properties = f17_local6
		f17_local3( f17_local4, f17_local5 )
	end
	local f17_local3 = false
	for f17_local7, f17_local8 in ipairs( f17_local0 ) do
		if f17_local8.properties and f17_local8.properties.selectIndex then
			f17_local3 = true
			break
		end
	end
	if not f17_local3 and #f17_local0 > 0 then
		if not f17_local0[1].properties then
			tablList[1].properties = {}
		end
		f17_local0[1].properties.selectIndex = true
	end
	if not f17_arg1._hasSubscriptions then
		f17_arg1._hasSubscriptions = true
		if Engine[@"isingame"]() and CoD.isMultiplayer then
			f17_local4 = f17_local2.PositionDraft.stage
			f17_arg1:subscribeToModel( f17_local4, function ()
				local f18_local0 = f17_local4:get() == CoD.PlayerRoleUtility.DraftStage.DRAFT_STAGE_DRAFT
				if f17_arg1._isPositionDraftStageDraft ~= f18_local0 then
					f17_arg1._isPositionDraftStageDraft = f18_local0
					f17_arg1:updateDataSource()
				end
			end, false )
		end
		if Engine[@"isingame"]() and CoD.isWarzone then
			f17_local4 = f17_local2.deadSpectator.playerIndex
			f17_arg1:subscribeToModel( f17_local4, function ()
				local f19_local0
				if f17_local4:get() == Engine[@"getclientnum"]( f17_arg0 ) or f17_local4:get() == -1 then
					f19_local0 = false
				else
					f19_local0 = true
				end
				if f17_arg1._isPlayerSpectating ~= f19_local0 then
					f17_arg1:updateDataSource()
				end
			end )
		end
	end

	return f17_local0
end, true )

-- make it not disabled
DataSources.ChangeTeamOptions = DataSourceHelpers.ListSetup( "ChangeTeamOptions", function ( f42_arg0 )
	local f42_local0 = function ( f43_arg0, f43_arg1, f43_arg2, f43_arg3, f43_arg4, f43_arg5 )
		local f43_local0 = 0
		local f43_local1 = f43_arg1
		if f43_arg4 ~= "" then
			f43_local0 = 1
			f43_local1 = @"hash_0"
		end
		return {
			models = {
				displayText = f43_local1,
				name = f43_arg1,
				desc = f43_arg3,
				disabled = false,
				icon = f43_arg4,
				iconVisible = f43_local0,
				action = function ( f44_arg0, f44_arg1, f44_arg2, f44_arg3, f44_arg4 )
					HUD_IngameMenuClosed()
					SendMenuResponse( f44_arg0, "ChangeTeam", f43_arg2, f44_arg2 )
					if f44_arg4.previousMenuId then
						LUI.savedMenuStates[f44_arg4.previousMenuId] = nil
					end
					local f44_local0 = Engine[@"createmodel"]( Engine[@"getmodelforcontroller"]( f44_arg2 ), "factions.isCoDCaster" )
					if f43_arg2 == "spectator" then
						Engine[@"lockinput"]( f44_arg2, false )
						Engine[@"setuiactive"]( f44_arg2, false )
						Engine[@"setmodelvalue"]( f44_local0, true )
					else
						Engine[@"setmodelvalue"]( f44_local0, false )
					end
					Engine[@"setmodelvalue"]( Engine[@"createmodel"]( Engine[@"createmodel"]( Engine[@"getmodelforcontroller"]( f44_arg2 ), "CodCaster" ), "showCodCasterScoreboard" ), false )
					SetControllerModelValue( f44_arg2, "forceScoreboard", 0 )
					if IsIntDvarNonZero( "mp_prototype" ) then
						StartMenuGoBack( f44_arg4, f44_arg2 )
					end
				end
				,
				param = {}
			},
			properties = {}
		}
	end
	
	local f42_local1 = function ( f45_arg0, f45_arg1 )
		local f45_local0 = CoD.PlayerRoleUtility.GetHeroList( Engine[@"currentsessionmode"]() )
		local f45_local1 = Engine[@"getgametypesettings"]()
		local f45_local2 = Engine[@"hash_4FCDE749B09C3D6"]( f45_arg0 )
		local f45_local3 = 1
		for f45_local7, f45_local8 in pairs( f45_local2 ) do
			if f45_local8 == f45_arg1 and Engine[@"getcharacterindexforclientnum"]( f45_arg0, f45_local7 ) == 0 then
				f45_local3 = f45_local3 + 1
			end
		end
		local f45_local4 = 0
		for f45_local8, f45_local9 in ipairs( f45_local0 ) do
			if Engine[@"getcharactercountforteam"]( f45_arg0, f45_local9.bodyIndex, f45_arg1 ) < f45_local1.maxUniqueRolesPerTeam[f45_local9.bodyIndex]:get() then
				f45_local4 = f45_local4 + 1
			end
		end
		return f45_local3 <= f45_local4
	end
	
	local f42_local2 = {}
	local f42_local3 = Engine[@"team"]( f42_arg0, "index" )
	local f42_local4
	if Engine[@"getgametypesetting"]( @"spectatetype" ) >= 1 and Engine[@"getgametypesetting"]( @"allowspectating" ) == 1 then
		f42_local4 = not Engine[@"issplitscreen"]()
	else
		f42_local4 = false
	end
	if f42_local4 then
		if CoD.DirectorUtility.IsOfflineOnlyDemo() then
			f42_local4 = IsLobbyHost()
		else
			f42_local4 = true
		end
	end
	if f42_local4 then
		f42_local4 = CoD.CodCasterUtility.IsCodCasterEnabled()
	end
	if f42_local4 then
		f42_local4 = Engine[@"getdvarint"]( "allow_shoutcaster_team_switch" ) == 1
	end
	local f42_local5 = function ( f46_arg0 )
		local f46_local0 = CoD.TeamUtility.GetTeamNameCaps( f46_arg0 )
		if f46_local0 == "" then
			f46_local0 = Engine[@"toupper"]( CoD.TeamUtility.GetDefaultTeamName( f46_arg0 ) )
		end
		return f46_local0
	end
	
	if f42_local3 ~= Enum[@"team_t"][@"team_allies"] then
		if f42_local1( f42_arg0, Enum[@"team_t"][@"team_allies"] ) then
			table.insert( f42_local2, f42_local0( f42_arg0, @"mpui/allies", "allies", @"hash_617E759991A40568", CoD.TeamUtility.GetTeamFactionIcon( Enum[@"team_t"][@"team_allies"] ), false ) )
		else
			table.insert( f42_local2, f42_local0( f42_arg0, @"mpui/allies", "allies", @"hash_6A3EE0239CF6265D", CoD.TeamUtility.GetTeamFactionIcon( Enum[@"team_t"][@"team_allies"] ), true ) )
		end
	end
	if f42_local3 ~= Enum[@"team_t"][@"team_axis"] then
		if f42_local1( f42_arg0, Enum[@"team_t"][@"team_axis"] ) then
			table.insert( f42_local2, f42_local0( f42_arg0, @"mpui/axis", "axis", @"hash_46838CD03F01BF13", CoD.TeamUtility.GetTeamFactionIcon( Enum[@"team_t"][@"team_axis"] ), false ) )
		else
			table.insert( f42_local2, f42_local0( f42_arg0, @"mpui/axis", "axis", @"hash_6A3EE0239CF6265D", CoD.TeamUtility.GetTeamFactionIcon( Enum[@"team_t"][@"team_axis"] ), true ) )
		end
	end

	table.insert( f42_local2, f42_local0( f42_arg0, @"hash_2AD8F376215AE5D7", "autoassign", @"hash_38BFAF5D14337A27", "" ) )

	if f42_local3 ~= Enum[@"team_t"][@"team_spectator"] and f42_local4 == true then
		table.insert( f42_local2, f42_local0( f42_arg0, @"hash_379A28BE744E24FB", "spectator", @"hash_6E6B92255B28A2BF", "", false ) )
	end
	if true == Dvar[@"ui_autocontrolledplayer"]:get() then
		table.insert( f42_local2, f42_local0( f42_arg0, "MENU_AUTO_CONTROL_PLAYER", "autocontrol", "MENU_AUTO_CONTROL_PLAYER_DESC", "", false ) )
	end

	return f42_local2
end, true )