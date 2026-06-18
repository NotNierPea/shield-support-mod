--[[
		.\hksc.exe ".\Lua\PreGameButtons.Lua" -o "C:\Program Files (x86)\Call of Duty Black Ops 4\project-bo4\mods\T8ShieldSupport\Lua\PreGameButtons.luac"
]]

---------------------------

CoD.ShieldInitLuaFile()

---------------------------

-- Pregame Buttons (checks for enhancement mod's)
if not DataSources.DirectorPregameButtonsCustom then
	DataSources.DirectorPregameButtonsCustom = ListHelper_SetupDataSource( "DirectorPregameButtonsCustom", function ( f115_arg0, f115_arg1 )
		local f115_local0 = {}
		local f115_local1 = Engine[@"createmodel"]( Engine[@"getglobalmodel"](), "lobbyRoot.lobbyMainMode" )
		f115_local1 = f115_local1:get()
		local f115_local2 = LuaUtils.GetEModeForLobbyMainMode( f115_local1 )
		local f115_local3 = CoD.BreadcrumbUtility.GetStorageLoadoutBufferForPlayer( f115_arg0, f115_local2 )
		local f115_local4 = function ( f116_arg0, f116_arg1 )
			local f116_local0 = {}
			local f116_local1 = f116_arg0.hintText
			local f116_local2 = false
			local f116_local3 = false
			if not f116_local1 and f116_arg0.featureItemIndex then
				f116_local1 = nil
				if CoD.CACUtility.IsFeatureItemLocked( f115_arg0, f116_arg0.featureItemIndex, f115_local2 ) then
					f116_local1 = CoD.GetUnlockStringForItemIndex( f115_arg0, f116_arg0.featureItemIndex, Enum[@"statindexoffset"][@"hash_13057ABF96AF8289"], f115_local2 )
				end
			end
			if f116_arg0.newBreadcrumbFunc then
				f116_local2 = f116_arg0.newBreadcrumbFunc( nil, f115_arg0, f115_local2 )
			end
			if f116_arg0.hasRestrictionsEquippedFunc then
				f116_local3 = f116_arg0.hasRestrictionsEquippedFunc( f115_arg0 )
			end
			local f116_local4 = table.insert
			local f116_local5 = f115_local0
			local f116_local6 = {}
			local f116_local7 = {
				name = f116_arg0.name,
				subtitle = f116_arg0.subtitle,
				iconBackground = f116_arg0.iconBackground,
				featureItemIndex = f116_arg0.featureItemIndex or -1,
				showPregameButton = f116_arg0.showPregameButton,
				hintText = f116_local1 or "",
				hasBreadcrumb = f116_local2,
				isRestricted = f116_local3,
				trialLocked = f116_arg0.trialLocked or false
			}
			local f116_local8 = f116_arg0.breadcrumbModel
			if not f116_local8 then
				f116_local8 = Engine[@"getglobalmodel"]()
			end
			f116_local7.breadcrumbModel = f116_local8
			f116_local6.models = f116_local7
			f116_local6.properties = {
				action = f116_arg1.action,
				actionParam = f116_arg1.actionParam,
				selectIndex = f116_arg1.selectIndex
			}
			f116_local4( f116_local5, f116_local6 )
		end
		
		if f115_local1 == Enum[@"lobbymainmode"][@"lobby_mainmode_mp"] then
			local f115_local5 = Engine[@"getglobalmodel"]()
			f115_local5 = f115_local5["lobbyRoot.selectedGameType"]
			local f115_local6 = true
			if f115_arg1:getParent() then
				local f115_local7 = f115_arg1:getParent()
				if f115_local7._preGameType == "custom" and CoD.DirectorUtility.HideCustomizationGametypes[f115_local5:get()] then
					f115_local6 = false
				end
			end
			if f115_arg1:getParent() then
				local f115_local7 = f115_arg1:getParent()
				if f115_local7._preGameType == "public" then
					f115_local7 = Engine[@"getglobalmodel"]()
					f115_local7 = f115_local7["lobbyRoot.playlistId"]
					if f115_local7 and f115_local7:get() then
						local f115_local8 = IsLobbyNetworkModeLive()
						if f115_local8 then
							f115_local8 = Engine[@"getplaylistinfobyid"]( f115_local7:get() )
						end
						if f115_local8 and #f115_local8.rotationList > 0 then
							f115_local6 = not CoD.DirectorUtility.HideCustomizationPlaylistGametypes[f115_local8.rotationList[1].gametype]
						end
					end
				end
			end
			if not CoDShared.IsInTheaterLobby() then
				if not IsLobbyNetworkModeLAN() and (not CoD.DirectorUtility.IsOfflineDemo() or Engine[@"hash_5CB675CA7856DA25"]()) then
					f115_local4( {
						name = @"menu/depot",
						subtitle = @"menu/depot",
						iconBackground = @"$blacktransparent",
						showPregameButton = true,
						breadcrumbModel = DataSources.DepotBreadcrumbs.getModel( f115_arg0 )
					}, {
						action = CoD.DirectorUtility.OpenDirectorPersonalizationMenu,
						actionParam = {
							_sessionMode = f115_local2,
							_storageLoadoutBuffer = f115_local3,
							_allowsQuickSelect = true
						}
					} )
					f115_local4( {
						name = @"hash_6FF94A9EB646C873",
						subtitle = @"hash_6FF94A9EB646C873",
						iconBackground = @"$blacktransparent",
						showPregameButton = true,
						breadcrumbModel = DataSources.CharacterBreadcrumbs.recreateCharacterBreadcrumbModelsIfNeeded( f115_arg0, f115_local2 )
					}, {
						action = CoD.DirectorUtility.OpenDirectorChangeCharacterMenu,
						actionParam = {
							_sessionMode = f115_local2,
							_storageLoadoutBuffer = f115_local3,
							_selectIndex = 1
						}
					} )
				end
				f115_local4( {
					name = @"menu/change",
					subtitle = @"hash_31A1B9A85C55950F",
					iconBackground = @"$blacktransparent",
					showPregameButton = f115_local6,
					newBreadcrumbFunc = CoD.BreadcrumbUtility.IsAnyScorestreaksNew,
					hasRestrictionsEquippedFunc = CoD.CACUtility.AnyEquippedScorestreaksBanned
				}, {
					action = CoD.DirectorUtility.DirectorOpenOverlayWithMenuSessionMode,
					actionParam = {
						menuName = "SupportSelection",
						eMode = f115_local2
					}
				} )
				f115_local4( {
					name = @"menu/edit",
					subtitle = @"hash_6C705394F8BCCCC9",
					iconBackground = @"$blacktransparent",
					featureItemIndex = CoD.CACUtility.GetFeatureCACItemIndex(),
					showPregameButton = f115_local6,
					newBreadcrumbFunc = CoD.BreadcrumbUtility.IsAnythingInCACNew,
					hasRestrictionsEquippedFunc = CoD.CACUtility.AnyClassContainsRestrictedItems
				}, {
					action = CoD.DirectorUtility.OpenCACWithMenuSessionMode,
					actionParam = {
						eMode = f115_local2
					},
					selectIndex = true
				} )
			end
		end
		if f115_local1 == Enum[@"lobbymainmode"][@"lobby_mainmode_zm"] then
			if not IsLobbyNetworkModeLAN() and (not CoD.DirectorUtility.IsOfflineDemo() or Engine[@"hash_5CB675CA7856DA25"]()) then
				f115_local4( {
					name = @"hash_249E353FB642CB3F",
					subtitle = @"hash_249E353FB642CB3F",
					iconBackground = @"$blacktransparent",
					showPregameButton = true,
					breadcrumbModel = DataSources.CharacterBreadcrumbs.recreateCharacterBreadcrumbModelsIfNeeded( f115_arg0, f115_local2 )
				}, {
					action = CoD.DirectorUtility.OpenDirectorChangeCharacterMenu,
					actionParam = {
						_sessionMode = f115_local2,
						_storageLoadoutBuffer = f115_local3,
						_selectIndex = 1
					}
				} )
			end
			f115_local4( {
				name = @"menu/armory",
				subtitle = @"menu/armory",
				iconBackground = @"$blacktransparent",
				showPregameButton = true
			}, {
				action = CoD.DirectorUtility.OpenArmoryMenu,
				actionParam = {
					_sessionMode = f115_local2,
					_loadoutSlot = "armory"
				}
			} )
			f115_local4( {
				name = @"menu/edit",
				subtitle = @"hash_43E876868767ECEB",
				iconBackground = @"$blacktransparent",
				showPregameButton = true
			}, {
				action = CoD.DirectorUtility.OpenCACWithMenuSessionMode,
				actionParam = {
					eMode = f115_local2
				},
				selectIndex = true
			} )
		end
		if f115_local1 == Enum[@"lobbymainmode"][@"lobby_mainmode_wz"] then
			if not IsLobbyNetworkModeLAN() and (not CoD.DirectorUtility.IsOfflineDemo() or Engine[@"hash_5CB675CA7856DA25"]()) then
				f115_local4( {
					name = @"menu/depot",
					subtitle = @"menu/depot",
					iconBackground = @"$blacktransparent",
					showPregameButton = true,
					breadcrumbModel = DataSources.DepotBreadcrumbs.getModel( f115_arg0 )
				}, {
					action = CoD.DirectorUtility.OpenDirectorPersonalizationMenu,
					actionParam = {
						_sessionMode = f115_local2,
						_storageLoadoutBuffer = f115_local3,
						_allowsQuickSelect = true
					}
				} )
			end
			f115_local4( {
				name = @"hash_249E353FB642CB3F",
				subtitle = @"hash_249E353FB642CB3F",
				iconBackground = @"$blacktransparent",
				showPregameButton = true,
				breadcrumbModel = DataSources.CharacterBreadcrumbs.recreateCharacterBreadcrumbModelsIfNeeded( f115_arg0, f115_local2 )
			}, {
				action = CoD.DirectorUtility.OpenDirectorChangeCharacterMenu,
				actionParam = {
					_sessionMode = f115_local2,
					_storageLoadoutBuffer = f115_local3
				}
			} )
			f115_local4( {
				name = @"menu/armory",
				subtitle = @"menu/armory",
				iconBackground = @"$blacktransparent",
				showPregameButton = true,
				trialLocked = IsGameTrial()
			}, {
				action = CoD.DirectorUtility.OpenWZPersonalizeWeaponMenu,
				actionParam = {
					_sessionMode = f115_local2,
					_loadoutSlot = "wzpersonalize"
				},
				selectIndex = true
			} )
		end
		local f115_local5 = CoD.DirectorUtility.CreateOfflineScreenState()
		if f115_arg1.offlineScreenStateSubscription == nil then
			f115_arg1.offlineScreenStateSubscription = f115_arg1:subscribeToModel( f115_local5, function ()
				f115_arg1:updateDataSource()
			end, false )
		end
		if not f115_arg1.occlusionChangeSubscription then
			f115_arg1.occlusionChangeSubscription = true
			f115_arg1.menu:appendEventHandler( "occlusion_change", function ( f118_arg0, f118_arg1 )
				if not f118_arg1.occluded then
					f115_arg1:updateDataSource()
				end
			end )
		end
		CoD.DirectorUtility.AddLobbyNavSubscriptionOnce( f115_arg1 )
		return f115_local0
	end )	
end

-- Pregame Lobby
CoD.DirectorCommonSafeAreaBottomAndLeft = InheritFrom( LUI.UIElement ) 
CoD.DirectorCommonSafeAreaBottomAndLeft.__defaultWidth = 1920
CoD.DirectorCommonSafeAreaBottomAndLeft.__defaultHeight = 1080
CoD.DirectorCommonSafeAreaBottomAndLeft.new = function ( f1_arg0, f1_arg1, f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	local self = LUI.UIElement.new( f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	self:setClass( CoD.DirectorCommonSafeAreaBottomAndLeft )
	self.id = "DirectorCommonSafeAreaBottomAndLeft"
	self.soundSet = "default"
	self.onlyChildrenFocusable = true
	self.anyChildUsesUpdateState = true
	f1_arg0:addElementToPendingUpdateStateList( self )

	local DirectorBlackMarketButton = CoD.DirectorBlackMarketButton.new( f1_arg0, f1_arg1, 0.5, 0.5, -896, -542, 1, 1, -218, -108 )
	DirectorBlackMarketButton:mergeStateConditions( {
		{
			stateName = "Hidden",
			condition = function ( menu, element, event )
				return not IsBooleanDvarSet( "loot_enableBlackMarket" )
			end
		},
		{
			stateName = "Contract",
			condition = function ( menu, element, event )
				return CoD.BaseUtility.IsDvarEnabled( "ui_enableContractsAndBounties" )
			end
		}
	} )
	self:addElement( DirectorBlackMarketButton )
	self.DirectorBlackMarketButton = DirectorBlackMarketButton
	
	local DirectorLaboratoryButton = CoD.DirectorLaboratoryButton.new( f1_arg0, f1_arg1, 0.5, 0.5, -896, -542, 1, 1, -218, -108 )
	DirectorLaboratoryButton:setAlpha( 0 )
	self:addElement( DirectorLaboratoryButton )
	self.DirectorLaboratoryButton = DirectorLaboratoryButton
	
	local DirectorContractsButton = CoD.DirectorContractsButton.new( f1_arg0, f1_arg1, 0.5, 0.5, -896, -542, 1, 1, -250, -108 )
	DirectorContractsButton:mergeStateConditions( {
		{
			stateName = "Hidden",
			condition = function ( menu, element, event )
				return not IsBooleanDvarSet( "loot_enableBlackMarket" )
			end
		}
	} )
	DirectorContractsButton:setAlpha( 0 )
	self:addElement( DirectorContractsButton )
	self.DirectorContractsButton = DirectorContractsButton
	
	local PreGameButtons = CoD.DirectorPreGameButtonContainer.new( f1_arg0, f1_arg1, 0.5, 0.5, -505, 478, 1, 1, -178, -108 )
	PreGameButtons.LobbyButtons:setFilter( function ( f5_arg0 )
		return f5_arg0.showPregameButton:get() == true
	end )
	PreGameButtons.LobbyButtons:setDataSource( "DirectorPregameButtonsCustom" )
	PreGameButtons.LobbyButtons:setHorizontalCount(4)
	PreGameButtons.LobbyButtons:setVerticalCount(1)
	PreGameButtons:registerEventHandler( "record_curr_focused_elem_id", function ( element, event )
		local f6_local0 = nil
		if element.RecordCurrFocusedElemID then
			f6_local0 = element:RecordCurrFocusedElemID( event )
		elseif element.super.RecordCurrFocusedElemID then
			f6_local0 = element.super:RecordCurrFocusedElemID( event )
		end
		UpdateElementState( self, "HintText", f1_arg1 )
		return f6_local0
	end )
	PreGameButtons:registerEventHandler( "list_item_lose_focus", function ( element, event )
		local f7_local0 = nil
		UpdateElementState( self, "HintText", f1_arg1 )
		return f7_local0
	end )
	self:addElement( PreGameButtons )
	self.PreGameButtons = PreGameButtons
	
	-- shield options button 1xp all modes
	local ShieldOptionsButton = CoD.DirectorPreGameButtonOption.new( f1_arg0, f1_arg1, 0.034, 0.034, 0, 353, 0.30, 0.30, -70, -20 ) 
	ShieldOptionsButton.DirectorSelectButtonMiniInternal.MiddleText:setText( "SHIELD OPTIONS" )
	ShieldOptionsButton.DirectorSelectButtonMiniInternal.MiddleTextFocus:setText( "SHIELD OPTIONS"  )
	
	ShieldOptionsButton:mergeStateConditions( {
		{
			stateName = "Visible",
			condition = function ( menu, element, event )
				if IsZombies() and Engine[@"hash_54D0EB832239B417"]() <= 1 then
				    return true
				elseif IsMultiplayer() then
				    return true
				elseif IsWarzone() then
					return true
			end
		end
		}
	} )

	ShieldOptionsButton:registerEventHandler( "gain_focus", function ( element, event )
		local f26_local0 = nil
		if element.gainFocus then
			f26_local0 = element:gainFocus( event )
		elseif element.super.gainFocus then
			f26_local0 = element.super:gainFocus( event )
		end
		CoD.Menu.UpdateButtonShownState( element, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
		return f26_local0
	end )
	
	f1_arg0:AddButtonCallbackFunction( ShieldOptionsButton, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], "ui_confirm", function ( element, menu, controller, model )
		PlaySoundAlias( "uin_paint_image_flip_toggle" )

		-- these args are treyarch's most braindead ones
		CoD.DirectorUtility.DirectorSelectOpenPopup(f1_arg0, nil, f1_arg1, "ShieldOptionsMenu")
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
	self:addElement( ShieldOptionsButton )
	self.ShieldOptionsButton = ShieldOptionsButton

	ShieldOptionsButton.id = "ShieldOptionsButton"

	--shield option button 2xp zm
	local ShieldOptionsButtonZM = CoD.DirectorPreGameButtonOption.new( f1_arg0, f1_arg1, 0.034, 0.034, 100, 353, 0.30, 0.30, -70, -20 )  
	ShieldOptionsButtonZM.DirectorSelectButtonMiniInternal.MiddleText:setText( "SHIELD OPTIONS" )
	ShieldOptionsButtonZM.DirectorSelectButtonMiniInternal.MiddleTextFocus:setText( "SHIELD OPTIONS"  )
	
	ShieldOptionsButtonZM:mergeStateConditions( {
		{
			stateName = "Visible",
			condition = function ( menu, element, event )
				if IsZombies() and Engine[@"hash_54D0EB832239B417"]() >= 2 then
				    return true
			    elseif IsMultiplayer() then
			        return false
				elseif IsWarzone() then
					return false	
		    end
		end
		}
	} )
	
	ShieldOptionsButtonZM:registerEventHandler( "gain_focus", function ( element, event )
		local f26_local0 = nil
		if element.gainFocus then
			f26_local0 = element:gainFocus( event )
		elseif element.super.gainFocus then
			f26_local0 = element.super:gainFocus( event )
		end
		CoD.Menu.UpdateButtonShownState( element, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
		return f26_local0
	end )
	
	f1_arg0:AddButtonCallbackFunction( ShieldOptionsButtonZM, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], "ui_confirm", function ( element, menu, controller, model )
		PlaySoundAlias( "uin_paint_image_flip_toggle" )
	
		-- these args are treyarch's most braindead ones
		CoD.DirectorUtility.DirectorSelectOpenPopup(f1_arg0, nil, f1_arg1, "ShieldOptionsMenu")
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
	self:addElement( ShieldOptionsButtonZM )
	self.ShieldOptionsButtonZM = ShieldOptionsButtonZM
	
	ShieldOptionsButtonZM.id = "ShieldOptionsButtonZM"

	local HintText = CoD.onOffTextImageBacking.new( f1_arg0, f1_arg1, 0.5, 0.5, 246, 707, 1, 1, -100, -79 )
	HintText:mergeStateConditions( {
		{
			stateName = "PC",
			condition = function ( menu, element, event )
				return IsPC()
			end
		},
		{
			stateName = "Invisible",
			condition = function ( menu, element, event )
				return not IsWidgetInFocus( self, "PreGameButtons", event )
			end
		}
	} )
	HintText:appendEventHandler( "record_curr_focused_elem_id", function ( f10_arg0, f10_arg1 )
		f10_arg1.menu = f10_arg1.menu or f1_arg0
		f1_arg0:updateElementState( HintText, f10_arg1 )
	end )
	HintText.TextBox:setTTF( "ttmussels_demibold" )
	HintText.TextBox:setBackingAlpha( 0.8 )
	HintText.TextBox:setBackingXPadding( 3 )
	self:addElement( HintText )
	self.HintText = HintText

	local DirectorAppLoadoutNotification = CoD.DirectorAppLoadoutNotification.new( f1_arg0, f1_arg1, 0.5, 0.5, 237, 487, 1, 1, -222, -192 )
	DirectorAppLoadoutNotification:mergeStateConditions( {
		{
			stateName = "Available",
			condition = function ( menu, element, event )
				return CoD.DirectorUtility.ShouldShowAppLoadoutAvailable( menu, f1_arg1 )
			end
		}
	} )
	local f1_local7 = DirectorAppLoadoutNotification
	local f1_local8 = DirectorAppLoadoutNotification.subscribeToModel
	local f1_local9 = Engine[@"getglobalmodel"]()
	f1_local8( f1_local7, f1_local9["lobbyRoot.lobbyNav"], function ( f12_arg0 )
		f1_arg0:updateElementState( DirectorAppLoadoutNotification, {
			name = "model_validation",
			menu = f1_arg0,
			controller = f1_arg1,
			modelValue = f12_arg0:get(),
			modelName = "lobbyRoot.lobbyNav"
		} )
	end, false )
	f1_local7 = DirectorAppLoadoutNotification
	f1_local8 = DirectorAppLoadoutNotification.subscribeToModel
	f1_local9 = Engine[@"getmodelforcontroller"]( f1_arg1 )
	f1_local8( f1_local7, f1_local9.extLoadoutReady, function ( f13_arg0 )
		f1_arg0:updateElementState( DirectorAppLoadoutNotification, {
			name = "model_validation",
			menu = f1_arg0,
			controller = f1_arg1,
			modelValue = f13_arg0:get(),
			modelName = "extLoadoutReady"
		} )
	end, false )
	self:addElement( DirectorAppLoadoutNotification )
	self.DirectorAppLoadoutNotification = DirectorAppLoadoutNotification
	
	HintText:linkToElementModel( PreGameButtons.LobbyButtons, "hintText", true, function ( model )
		local f14_local0 = model:get()
		if f14_local0 ~= nil then
			HintText.TextBox:setText( f14_local0 )
		end
	end )
	self:mergeStateConditions( {
		{
			stateName = "ContractsZombies",
			condition = function ( menu, element, event )
				return CoD.DirectorUtility.IsMainMode( f1_arg1, Enum[@"lobbymainmode"][@"lobby_mainmode_zm"] ) and CoD.LootContractsUtility.IsUIEnabled( f1_arg1 )
			end
		},
		{
			stateName = "Zombies",
			condition = function ( menu, element, event )
				return CoD.DirectorUtility.IsMainMode( f1_arg1, Enum[@"lobbymainmode"][@"lobby_mainmode_zm"] )
			end
		},
		{
			stateName = "Contracts",
			condition = function ( menu, element, event )
				return CoD.LootContractsUtility.IsUIEnabled( f1_arg1 )
			end
		}
	} )
	f1_local7 = self
	f1_local8 = self.subscribeToModel
	f1_local9 = Engine[@"getglobalmodel"]()
	f1_local8( f1_local7, f1_local9["lobbyRoot.lobbyMainMode"], function ( f18_arg0 )
		f1_arg0:updateElementState( self, {
			name = "model_validation",
			menu = f1_arg0,
			controller = f1_arg1,
			modelValue = f18_arg0:get(),
			modelName = "lobbyRoot.lobbyMainMode"
		} )
	end, false )
	f1_local7 = self
	f1_local8 = self.subscribeToModel
	f1_local9 = Engine[@"getglobalmodel"]()
	f1_local8( f1_local7, f1_local9["lobbyRoot.lobbyNav"], function ( f19_arg0 )
		f1_arg0:updateElementState( self, {
			name = "model_validation",
			menu = f1_arg0,
			controller = f1_arg1,
			modelValue = f19_arg0:get(),
			modelName = "lobbyRoot.lobbyNav"
		} )
	end, false )
	DirectorBlackMarketButton.id = "DirectorBlackMarketButton"
	DirectorLaboratoryButton.id = "DirectorLaboratoryButton"
	DirectorContractsButton.id = "DirectorContractsButton"
	PreGameButtons.id = "PreGameButtons"
	LUI.OverrideFunction_CallOriginalSecond( self, "close", self.__onClose )
	
	if PostLoadFunc then
		PostLoadFunc( self, f1_arg1, f1_arg0 )
	end
	
	f1_local8 = self
	SetElementProperty( PreGameButtons, "_preGameType", "public" )
	return self
end

CoD.DirectorCommonSafeAreaBottomAndLeft.__resetProperties = function ( f20_arg0 )
	f20_arg0.DirectorLaboratoryButton:completeAnimation()
	f20_arg0.DirectorBlackMarketButton:completeAnimation()
	f20_arg0.DirectorContractsButton:completeAnimation()
	f20_arg0.DirectorLaboratoryButton:setTopBottom( 1, 1, -218, -108 )
	f20_arg0.DirectorLaboratoryButton:setAlpha( 0 )
	f20_arg0.DirectorBlackMarketButton:setTopBottom( 1, 1, -218, -108 )
	f20_arg0.DirectorBlackMarketButton:setAlpha( 1 )
	f20_arg0.DirectorContractsButton:setTopBottom( 1, 1, -250, -108 )
	f20_arg0.DirectorContractsButton:setAlpha( 0 )
end

CoD.DirectorCommonSafeAreaBottomAndLeft.__clipsPerState = {
	DefaultState = {
		DefaultClip = function ( f21_arg0, f21_arg1 )
			f21_arg0:__resetProperties()
			f21_arg0:setupElementClipCounter( 0 )
		end
	},
	ContractsZombies = {
		DefaultClip = function ( f22_arg0, f22_arg1 )
			f22_arg0:__resetProperties()
			f22_arg0:setupElementClipCounter( 3 )
			f22_arg0.DirectorBlackMarketButton:completeAnimation()
			f22_arg0.DirectorBlackMarketButton:setAlpha( 0 )
			f22_arg0.clipFinished( f22_arg0.DirectorBlackMarketButton )
			f22_arg0.DirectorLaboratoryButton:completeAnimation()
			f22_arg0.DirectorLaboratoryButton:setTopBottom( 1, 1, -372, -262 )
			f22_arg0.DirectorLaboratoryButton:setAlpha( 1 )
			f22_arg0.clipFinished( f22_arg0.DirectorLaboratoryButton )
			f22_arg0.DirectorContractsButton:completeAnimation()
			f22_arg0.DirectorContractsButton:setTopBottom( 1, 1, -250, -108 )
			f22_arg0.DirectorContractsButton:setAlpha( 1 )
			f22_arg0.clipFinished( f22_arg0.DirectorContractsButton )
		end
	},
	Zombies = {
		DefaultClip = function ( f23_arg0, f23_arg1 )
			f23_arg0:__resetProperties()
			f23_arg0:setupElementClipCounter( 2 )
			f23_arg0.DirectorBlackMarketButton:completeAnimation()
			f23_arg0.DirectorBlackMarketButton:setAlpha( 0 )
			f23_arg0.clipFinished( f23_arg0.DirectorBlackMarketButton )
			f23_arg0.DirectorLaboratoryButton:completeAnimation()
			f23_arg0.DirectorLaboratoryButton:setAlpha( 1 )
			f23_arg0.clipFinished( f23_arg0.DirectorLaboratoryButton )
		end
	},
	Contracts = {
		DefaultClip = function ( f24_arg0, f24_arg1 )
			f24_arg0:__resetProperties()
			f24_arg0:setupElementClipCounter( 2 )
			f24_arg0.DirectorBlackMarketButton:completeAnimation()
			f24_arg0.DirectorBlackMarketButton:setTopBottom( 1, 1, -368, -258 )
			f24_arg0.clipFinished( f24_arg0.DirectorBlackMarketButton )
			f24_arg0.DirectorContractsButton:completeAnimation()
			f24_arg0.DirectorContractsButton:setAlpha( 1 )
			f24_arg0.clipFinished( f24_arg0.DirectorContractsButton )
		end
	}
}

CoD.DirectorCommonSafeAreaBottomAndLeft.__onClose = function ( f25_arg0 )
	f25_arg0.HintText:close()
	f25_arg0.DirectorBlackMarketButton:close()
	f25_arg0.DirectorLaboratoryButton:close()
	f25_arg0.DirectorContractsButton:close()
	f25_arg0.PreGameButtons:close()
	f25_arg0.DirectorAppLoadoutNotification:close()
	f25_arg0.ShieldOptionsButtonZM:close()
	f25_arg0.ShieldOptionsButton:close()
end