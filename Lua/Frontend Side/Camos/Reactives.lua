--[[
		.\hksc.exe ".\Lua\Reactives.Lua" -o "C:\Program Files (x86)\Call of Duty Black Ops 4\project-bo4\mods\T8ShieldSupport\Lua\Reactives.luac"
]]

---------------------------

CoD.ShieldInitLuaFile()

---------------------------

Engine[@"exec"](Engine[@"getprimarycontroller"](), "readjson shield_active_camo_last lua active_camo_last uint64_t 0")

---------------------------

-- add our setting in camo menu
CoD.ReactivesReload = function()
	-- override datasource buttons to have 4
	CoD.CamoFilterButtonList = InheritFrom( LUI.UIElement )
	CoD.CamoFilterButtonList.__defaultWidth = 250
	CoD.CamoFilterButtonList.__defaultHeight = 233
	CoD.CamoFilterButtonList.new = function ( f1_arg0, f1_arg1, f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
		local self = LUI.UIElement.new( f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
		self:setClass( CoD.CamoFilterButtonList )
		self.id = "CamoFilterButtonList"
		self.soundSet = "default"
		self.onlyChildrenFocusable = true
		self.anyChildUsesUpdateState = true
		f1_arg0:addElementToPendingUpdateStateList( self )
		
		local CamoFilterList = LUI.UIList.new( f1_arg0, f1_arg1, 13, 0, nil, false, false, false, false )
		CamoFilterList:setLeftRight( 0, 0, 0, 250 )
		CamoFilterList:setTopBottom( 0, 0, 0, 233 )
		CamoFilterList:setWidgetType( CoD.CamoFilterButton )
		CamoFilterList:setVerticalCount( 4 ) -- we need 4
		CamoFilterList:setSpacing( 13 )
		CamoFilterList:setAlignment( Enum[@"luialignment"][@"lui_alignment_left"] )
		CamoFilterList:setDataSource( "WeaponOptionsCamoCategories" )
		CamoFilterList:appendEventHandler( "input_source_changed", function ( f2_arg0, f2_arg1 )
			f2_arg1.menu = f2_arg1.menu or f1_arg0
			CoD.Menu.UpdateButtonShownState( f2_arg0, f1_arg0, f1_arg1, Enum[@"luibutton"][@"lui_key_xba_pscross"] )
		end )
		local f1_local2 = CamoFilterList
		local f1_local3 = CamoFilterList.subscribeToModel
		local f1_local4 = Engine[@"getmodelforcontroller"]( f1_arg1 )
		f1_local3( f1_local2, f1_local4.LastInput, function ( f3_arg0, f3_arg1 )
			CoD.Menu.UpdateButtonShownState( f3_arg1, f1_arg0, f1_arg1, Enum[@"luibutton"][@"lui_key_xba_pscross"] )
		end, false )
		CamoFilterList:registerEventHandler( "input_source_changed", function ( element, event )
			local f4_local0 = nil
			CoD.GridAndListUtility.SetListActiveOnFocusPCBehavior( element, f1_arg1 )
			if not f4_local0 then
				f4_local0 = element:dispatchEventToChildren( event )
			end
			return f4_local0
		end )
		CamoFilterList:registerEventHandler( "gain_focus", function ( element, event )
			local f5_local0 = nil
			if element.gainFocus then
				f5_local0 = element:gainFocus( event )
			elseif element.super.gainFocus then
				f5_local0 = element.super:gainFocus( event )
			end
			CoD.Menu.UpdateButtonShownState( element, f1_arg0, f1_arg1, Enum[@"luibutton"][@"lui_key_xba_pscross"] )
			return f5_local0
		end )
		f1_arg0:AddButtonCallbackFunction( CamoFilterList, f1_arg1, Enum[@"luibutton"][@"lui_key_xba_pscross"], "ui_confirm", function ( element, menu, controller, model )
			if IsMouseOrKeyboard( controller ) then
				SetCurrentElementAsActive( self, element, controller )
				ProcessListAction( self, element, controller, menu )
				return true
			else
				ProcessListAction( self, element, controller, menu )
				return true
			end
		end, function ( element, menu, controller )
			CoD.Menu.SetButtonLabel( menu, Enum[@"luibutton"][@"lui_key_xba_pscross"], @"menu/select", nil, "ui_confirm" )
			return true
		end, false )
		self:addElement( CamoFilterList )
		self.CamoFilterList = CamoFilterList
		
		CamoFilterList.id = "CamoFilterList"
		self.__defaultFocus = CamoFilterList
		LUI.OverrideFunction_CallOriginalSecond( self, "close", self.__onClose )
		
		if PostLoadFunc then
			PostLoadFunc( self, f1_arg1, f1_arg0 )
		end
		
		f1_local3 = self
		f1_local3 = CamoFilterList
		CoD.GridAndListUtility.SetListActiveOnFocusPCBehavior( f1_local3, f1_arg1 )
		CoD.GridAndListUtility.ActivateListPCSelectionBehavior( f1_local3 )
		return self
	end

	CoD.CamoFilterButtonList.__resetProperties = function ( f8_arg0 )
		f8_arg0.CamoFilterList:completeAnimation()
		f8_arg0.CamoFilterList:setAlpha( 1 )
	end

	CoD.CamoFilterButtonList.__clipsPerState = {
		DefaultState = {
			DefaultClip = function ( f9_arg0, f9_arg1 )
				f9_arg0:__resetProperties()
				f9_arg0:setupElementClipCounter( 1 )
				f9_arg0.CamoFilterList:completeAnimation()
				f9_arg0.CamoFilterList:setAlpha( 0 )
				f9_arg0.clipFinished( f9_arg0.CamoFilterList )
			end
		},
		Visible = {
			DefaultClip = function ( f10_arg0, f10_arg1 )
				f10_arg0:__resetProperties()
				f10_arg0:setupElementClipCounter( 1 )
				f10_arg0.CamoFilterList:completeAnimation()
				f10_arg0.CamoFilterList:setAlpha( 1 )
				f10_arg0.clipFinished( f10_arg0.CamoFilterList )
			end
		}
	}

	CoD.CamoFilterButtonList.__onClose = function ( f11_arg0 )
		f11_arg0.CamoFilterList:close()
	end
end

local function PreviewReactiveWeaponCamo( camo_index, rob_stage, controller, menu )
	local f109_local0, f109_local1, f109_local2 = CoD.BaseUtility.GetMenuModelModeLoadoutSlot( menu )
	local f109_local3 = CoD.GetCustomization( controller, "weapon_index" )
	local f109_local4 = CoD.GetCustomization( controller, "weaponRefHash" )
	local f109_local5 = CoD.CraftUtility.GetLoadoutSlot( controller )
	local f109_local6 = "select01"
	local f109_local7 = ""
	local f109_local8 = ""
	if f109_local1 == Enum[@"emodes"][@"mode_zombies"] then
		f109_local8 = CoD.ZMLoadoutUtility.GetArmoryAttachmentStringForWeaponIndex( controller, f109_local3, f109_local1 )
	end
	local f109_local9 = camo_index
	if not f109_local9 then
		f109_local9 = f109_local0.weaponOptionSubIndex:get() or 0
	end
	local f109_local10 = menu._baseWeaponModelSlot or 0
	if menu._weaponOptionCategory == "theme" then
		f109_local10 = f109_local0.signatureWeaponModelSlot:get()
	end
	local f109_local11 = rob_stage
	local f109_local12 = 0
	if f109_local1 == Enum[@"emodes"][@"mode_zombies"] then
		f109_local12 = CoD.ZMLoadoutUtility.GetArmoryCharmItemFromWeapon( controller, f109_local3 )
	elseif f109_local1 == Enum[@"emodes"][@"mode_warzone"] then
		f109_local12 = CoD.WZUtility.GetArmoryCharmItemFromWeapon( controller, f109_local3 )
	else
		local f109_local13 = menu._classModel
		local f109_local14 = f109_local13 and f109_local13[f109_local5]
		local f109_local15 = f109_local14 and f109_local14.charmIndex
		if f109_local15 then
			local f109_local16 = f109_local15:get()
		end
		f109_local12 = f109_local16 or 0
	end
	Engine[@"sendclientscriptnotify"]( controller, "CustomClass_update" .. CoD.GetLocalClientAdjustedNum( controller ), {
		base_weapon_slot = f109_local5,
		weapon = f109_local4,
		attachments = f109_local8,
		camera = f109_local6,
		options = CoD.WeaponOptionsUtility.GetWeaponOptionsString( f109_local9, 0, 1, f109_local10, f109_local11, f109_local12 )
	} )
end

local function OnExtraDataChange ( f137_arg0, f137_arg1, f137_arg2, f137_arg3, f137_arg4 )
	local dvar_name = f137_arg3
	local dvar_val = Engine[@"getdvarint"]( dvar_name )
	local current_val = f137_arg1.value
	CoD.OptionsUtility.UpdateInfoModels( f137_arg1 )

	if current_val == dvar_val then
		return 
	else
		Engine[@"setdvar"]( dvar_name, current_val )
	end

	local dvar_val_new = Engine[@"getdvarint"]( dvar_name )

	if dvar_name == "shield_active_camo_last" then	
		Engine[@"exec"](Engine[@"getprimarycontroller"](), "writejson lua active_camo_last " .. dvar_val_new .. " uint64_t")
	end

	if CoD.CamosGlobalMenu == nil then
		return
	end

	-- preview it
	local dvar_to_view = (dvar_val_new - 1)
	local camo_index_get = 0
	local f61_local2, f61_local3, f61_local4 = CoD.BaseUtility.GetMenuModelModeLoadoutSlot( CoD.CamosGlobalMenu )
	local session_mode = CoD.BaseUtility.GetMenuSessionMode( CoD.CamosGlobalMenu )
	local f361_local1 = nil

	if session_mode == Enum[@"emodes"][@"mode_multiplayer"] then
		camo_index_get = f61_local2[f61_local4]["camoIndex"]:get()
	elseif session_mode == Enum[@"emodes"][@"mode_warzone"] then
		local f361_local0 = CoD.CamosGlobalMenu._model
		if f361_local0 then
			f361_local0 = CoD.CamosGlobalMenu._model.itemIndex:get()
		end

		local f361_local1 = CoD.WZUtility.GetVariantSlot( Controller, f361_local0, false )
		camo_index_get = f361_local1["camoIndex"]:get()
	elseif session_mode == Enum[@"emodes"][@"mode_zombies"] then
		local f361_local0 = CoD.CamosGlobalMenu._model
		if f361_local0 then
			f361_local0 = CoD.CamosGlobalMenu._model.itemIndex:get()
		end

		local f361_local1 = CoD.ZMLoadoutUtility.GetVariantSlot( Controller, f361_local0, false )
		camo_index_get = f361_local1["camoIndex"]:get()
	end

	local f42_local0 = {}
	local f42_local1 = CoD.BaseUtility.GetMenuSessionMode( CoD.CamosGlobalMenu )
	local f42_local2 = CoD.BaseUtility.GetMenuModel( CoD.CamosGlobalMenu )
	local f42_local4 = CoD.WeaponOptionsUtility.GetActiveCamoRefForBaseCamoIndex(Engine[@"currentsessionmode"](), camo_index_get)
	local b_found = false
	if f42_local4 and f42_local4 ~= @"hash_0" then
		local f42_local5 = Engine[@"hash_2E00B2F29271C60B"]( f42_local4 )
		if f42_local5 and f42_local5.stages then
			local f42_local6 = 0
			local f42_local7 = CoD.CACUtility.BaseUnwrappedStageForActiveCamo
			if CoD.CamosGlobalMenu._weaponOptionCategory == "theme" then
				f42_local7 = CoD.CACUtility.MastercraftCamoStartStage
			elseif CoD.CamosGlobalMenu._weaponOptionCategory == "mstr" then
				f42_local7 = CoD.CACUtility.MasteryCamoStartStage
			end

			if dvar_to_view >= (#f42_local5.stages - f42_local7) then
				dvar_to_view = (#f42_local5.stages - f42_local7)
			end

			for f42_local8 = f42_local7, #f42_local5.stages, 1 do
				local f42_local11
				if f42_local8 - 1 >= 0 then
					f42_local11 = f42_local5.stages[f42_local8 - 1]
				else
					f42_local11 = false
				end
				local f42_local12 = f42_local5.stages[f42_local8]
				if not f42_local12[@"disabled"] or f42_local12[@"disabled"] ~= 1 then
					local f42_local13 = Engine[@"tablelookup"]( CoD.CACUtility.CamoOptionsTable, Enum[@"hash_25DD5CC8AEA7314B"][@"hash_6A6342D60A0D5AAE"], Enum[@"hash_25DD5CC8AEA7314B"][@"hash_3AA94CABDA68EB21"], f42_local12[@"camooption"] )
					local f42_local14 = Engine[@"hash_4F9F1239CFD921FE"]( @"hash_455472550AF1CAB2" )
					if f42_local11 and f42_local7 < f42_local8 then
						if f42_local11[@"hash_2581C6C8958C02BB"] then
							local f42_local15 = Engine[@"hash_4F9F1239CFD921FE"]( f42_local11[@"hash_2581C6C8958C02BB"], f42_local6 )
						end
						f42_local14 = f42_local15 or ""
					end
					table.insert( f42_local0, {
						models = {
							displayText = f42_local14,
							stageCamoIndex = f42_local13,
							robStage = f42_local8 - 1
						}
					} )

					CoD.EnhPrintInfo("Compare: " .. f42_local8 .. " - " .. (dvar_to_view + f42_local7) .. " - " .. f42_local13 .. " - " .. (f42_local8 - 1))
					if f42_local8 == (dvar_to_view + f42_local7) then
						PreviewReactiveWeaponCamo(f42_local13, (f42_local8 - 1), Engine[@"getprimarycontroller"](), CoD.CamosGlobalMenu)
						b_found = true
					end

					f42_local6 = f42_local6 + f42_local12[@"hash_5181D2404B77545F"]
				end
			end
		end
	end

	if b_found == false then
		PreviewReactiveWeaponCamo(camo_index_get, 0, Engine[@"getprimarycontroller"](), CoD.CamosGlobalMenu) -- default
	end
end

---------------------------

-- check box for reactive last stage
DataSources.ReactiveSettings = DataSourceHelpers.ListSetup( "ReactiveSettings", function ( f138_arg0 )
	local Settings = {}

	table.insert( Settings, CoD.OptionsUtility.CreateDvarSettings( f138_arg0, @"shield/reactive_last_setting", @"shield/reactive_last_setting", "shield_active_camo_last", "shield_active_camo_last", {
		{
			option = Engine[@"hash_4F9F1239CFD921FE"]( @"shield/no_stage" ),
			value = 0,
			default = true
		},
		{
			option = Engine[@"hash_4F9F1239CFD921FE"]( @"shield/stage_1" ),
			value = 1
		},
		{
			option = Engine[@"hash_4F9F1239CFD921FE"]( @"shield/stage_2" ),
			value = 2
		},
		{
			option = Engine[@"hash_4F9F1239CFD921FE"]( @"shield/stage_3" ),
			value = 3
		},
		{
			option = Engine[@"hash_4F9F1239CFD921FE"]( @"shield/stage_4" ),
			value = 4
		},
		{
			option = Engine[@"hash_4F9F1239CFD921FE"]( @"shield/stage_5" ),
			value = 5
		},
		{
			option = Engine[@"hash_4F9F1239CFD921FE"]( @"shield/stage_6" ),
			value = 6
		},
		{
			option = Engine[@"hash_4F9F1239CFD921FE"]( @"shield/stage_7" ),
			value = 7
		},
		{
			option = Engine[@"hash_4F9F1239CFD921FE"]( @"shield/stage_8" ),
			value = 99
		}
	}, nil, OnExtraDataChange ) )

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

CoD.ShieldReativesSettingsTab = InheritFrom( LUI.UIElement )
CoD.ShieldReativesSettingsTab.__defaultWidth = 1214
CoD.ShieldReativesSettingsTab.__defaultHeight = 400
CoD.ShieldReativesSettingsTab.new = function ( f1_arg0, f1_arg1, f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	local self = LUI.UIElement.new( f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	self:setClass( CoD.ShieldReativesSettingsTab )
	self.id = "ShieldReativesSettingsTab"
	self.soundSet = "none"
	self.onlyChildrenFocusable = true
	self.anyChildUsesUpdateState = true
	f1_arg0:addElementToPendingUpdateStateList( self )
	
	CoD.CamosGlobalMenu = f1_arg0

	local Backing = LUI.UIImage.new( 0, 1, 0, 0, 0, 1, 0, 0 )
	Backing:setRGB( 0, 0, 0 )
	Backing:setAlpha( 0 )
	self:addElement( Backing )
	self.Backing = Backing

	local ShieldReactiveSettingsList = CoD.ShieldReactiveSettingsList.new( f1_arg0, f1_arg1, 0, 0, 0, 1214, 0, 0, 24, 374 )
	ShieldReactiveSettingsList:setAlpha( 0 )
	ShieldReactiveSettingsList.Label:setText( "REACTIVE STAGES SETTINGS" )
	self:addElement( ShieldReactiveSettingsList )
	self.ShieldReactiveSettingsList = ShieldReactiveSettingsList
	
	self:mergeStateConditions( {
		{
			stateName = "NotLive",
			condition = function ( menu, element, event )
				return not IsLive()
			end
		},
		{
			stateName = "BlackMarket",
			condition = function ( menu, element, event )
				return CoD.WeaponOptionsUtility.IsBlackMarketCamoFilter()
			end
		},
		{
			stateName = "NotCurrentModeFilter",
			condition = function ( menu, element, event )
				return not CoD.WeaponOptionsUtility.IsInCurrentModeFilter( menu, self, f1_arg1 )
			end
		},
		{
			stateName = "TempHideZMMastery",
			condition = function ( menu, element, event )
				return CoD.WeaponOptionsUtility.ShouldHideMasteryCamos( menu )
			end
		}
	} )
	local f1_local7 = self
	local f1_local8 = self.subscribeToModel
	local f1_local9 = Engine[@"getglobalmodel"]()
	f1_local8( f1_local7, f1_local9["lobbyRoot.lobbyNetworkMode"], function ( f7_arg0 )
		f1_arg0:updateElementState( self, {
			name = "model_validation",
			menu = f1_arg0,
			controller = f1_arg1,
			modelValue = f7_arg0:get(),
			modelName = "lobbyRoot.lobbyNetworkMode"
		} )
	end, false )
	f1_local7 = self
	f1_local8 = self.subscribeToModel
	f1_local9 = Engine[@"getglobalmodel"]()
	f1_local8( f1_local7, f1_local9["lobbyRoot.lobbyNav"], function ( f8_arg0 )
		f1_arg0:updateElementState( self, {
			name = "model_validation",
			menu = f1_arg0,
			controller = f1_arg1,
			modelValue = f8_arg0:get(),
			modelName = "lobbyRoot.lobbyNav"
		} )
	end, false )
	f1_local7 = self
	f1_local8 = self.subscribeToModel
	f1_local9 = Engine[@"getmodelforcontroller"]( f1_arg1 )
	f1_local8( f1_local7, f1_local9["WeaponPersonalization.listUpdate"], function ( f9_arg0 )
		f1_arg0:updateElementState( self, {
			name = "model_validation",
			menu = f1_arg0,
			controller = f1_arg1,
			modelValue = f9_arg0:get(),
			modelName = "WeaponPersonalization.listUpdate"
		} )
	end, false )
	LUI.OverrideFunction_CallOriginalFirst( self, "setState", function ( element, controller, f10_arg2, f10_arg3, f10_arg4 )
		if IsSelfInState( self, "BlackMarket" ) then
			CoD.BaseUtility.SetDefaultFocusToElement( self, self.ShieldReactiveSettingsList )
		end
	end )
	ShieldReactiveSettingsList.id = "ShieldReactiveSettingsList"
	self.__defaultFocus = ShieldReactiveSettingsList
	LUI.OverrideFunction_CallOriginalSecond( self, "close", self.__onClose )
	
	if PostLoadFunc then
		PostLoadFunc( self, f1_arg1, f1_arg0 )
	end
	
	return self
end

CoD.ShieldReativesSettingsTab.__resetProperties = function ( f11_arg0 )
	f11_arg0.ShieldReactiveSettingsList:completeAnimation()
	f11_arg0.ShieldReactiveSettingsList:setAlpha( 0 )
end

CoD.ShieldReativesSettingsTab.__clipsPerState = {
	DefaultState = {
		DefaultClip = function ( f12_arg0, f12_arg1 )
			f12_arg0:__resetProperties()
			f12_arg0:setupElementClipCounter( 0 )
		end
	},
	NotLive = {
		DefaultClip = function ( f13_arg0, f13_arg1 )
			f13_arg0:__resetProperties()
			f13_arg0:setupElementClipCounter( 2 )
		end
	},
	BlackMarket = {
		DefaultClip = function ( f14_arg0, f14_arg1 )
			f14_arg0:__resetProperties()
			f14_arg0:setupElementClipCounter( 5 )
			f14_arg0.ShieldReactiveSettingsList:completeAnimation()
			f14_arg0.ShieldReactiveSettingsList:setAlpha( 1 )
			f14_arg0.clipFinished( f14_arg0.ShieldReactiveSettingsList )
		end
	},
	NotCurrentModeFilter = {
		DefaultClip = function ( f15_arg0, f15_arg1 )
			f15_arg0:__resetProperties()
			f15_arg0:setupElementClipCounter( 2 )
		end
	},
	TempHideZMMastery = {
		DefaultClip = function ( f16_arg0, f16_arg1 )
			f16_arg0:__resetProperties()
			f16_arg0:setupElementClipCounter( 2 )
		end
	}
}

CoD.ShieldReativesSettingsTab.__onClose = function ( f18_arg0 )
	f18_arg0.ShieldReactiveSettingsList:close()
end

-- list of settings to avoid issues
CoD.ReactiveSettingContainer = InheritFrom( LUI.UIElement )
CoD.ReactiveSettingContainer.__defaultWidth = 1600
CoD.ReactiveSettingContainer.__defaultHeight = 620
CoD.ReactiveSettingContainer.new = function ( f1_arg0, f1_arg1, f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	local self = LUI.UIElement.new( f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	self:setClass( CoD.ReactiveSettingContainer )
	self.id = "ReactiveSettingContainer"
	self.soundSet = "default"
	self.onlyChildrenFocusable = true
	self.anyChildUsesUpdateState = true

	local SettingsList = LUI.UIList.new( f1_arg0, f1_arg1, 15, 0, nil, false, false, false, false )
	SettingsList:setLeftRight( 0.5, 0.5, -275, 275 )
	SettingsList:setTopBottom( 0, 0, 0, 400 )
	SettingsList:setAutoScaleContent( true )
	SettingsList:setVerticalCount(11)
	SettingsList:setHorizontalCount(1)
	SettingsList:setSpacing( 5 )
	SettingsList:setWidgetType( CoD.CustomGames_SettingSliderNoCustom_Enh )
	SettingsList:setVerticalCounter( CoD.verticalCounter )
	SettingsList:setDataSource( "ReactiveSettings" )
	SettingsList:setAlignment( Enum[@"luialignment"][@"lui_alignment_left"] )

	if Engine[@"getdvarint"]("shield_ui_color") == 0 then
		SettingsList:setRGB(0, 1, 1)
	elseif Engine[@"getdvarint"]("shield_ui_color") == 1 then
		SettingsList:setRGB(1, 0, 0)
	elseif Engine[@"getdvarint"]("shield_ui_color") == 2 then
		SettingsList:setRGB(0, 1, 0)
	end

	self:addElement( SettingsList )
	self.SettingsList = SettingsList

	SettingsList.id = "SettingsList"

	LUI.OverrideFunction_CallOriginalSecond( self, "close", self.__onClose )
	
	if PostLoadFunc then
		PostLoadFunc( self, f1_arg1, f1_arg0 )
	end

	return self
end

CoD.ReactiveSettingContainer.__onClose = function ( f9_arg0 )
	f9_arg0.SettingsList:close()
end

CoD.ShieldReactiveSettingsList = InheritFrom( LUI.UIElement )
CoD.ShieldReactiveSettingsList.__defaultWidth = 1214
CoD.ShieldReactiveSettingsList.__defaultHeight = 350
CoD.ShieldReactiveSettingsList.new = function ( f1_arg0, f1_arg1, f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	local self = LUI.UIElement.new( f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	self:setClass( CoD.ShieldReactiveSettingsList )
	self.id = "ShieldReactiveSettingsList"
	self.soundSet = "none"
	self.onlyChildrenFocusable = true
	self.anyChildUsesUpdateState = true

	-- setting list
	local SettingsList = CoD.ReactiveSettingContainer.new( f1_arg0, f1_arg1, 0.5000, 0.5000, -521.0000, -131.0000, 0.5000, 0.5000, -131.0000, 255.0000 )
	self:addElement( SettingsList )
	self.SettingsList = SettingsList

	SettingsList.id = "SettingsList"
	
	local Label = LUI.UIText.new( 0, 0, 0.5, 340.5, 0, 0, 11, 27 )
	Label:setRGB( ColorSet.T8__OFF__GRAY.r, ColorSet.T8__OFF__GRAY.g, ColorSet.T8__OFF__GRAY.b )
	Label:setText( LocalizeToUpperString( @"hash_3F602F1BAFC731B5" ) )
	Label:setTTF( "default" )
	Label:setLetterSpacing( 4 )
	Label:setAlignment( Enum[@"luialignment"][@"lui_alignment_left"] )
	Label:setAlignment( Enum[@"luialignment"][@"lui_alignment_top"] )
	self:addElement( Label )
	self.Label = Label

	local Desc1 = LUI.UIText.new( 0.0000, 0.0000, 0.0000, 553.0000, 0.0000, 0.0000, 132.0000, 151.0000 )
	Desc1:setRGB( ColorSet.T8__OFF__GRAY.r, ColorSet.T8__OFF__GRAY.g, ColorSet.T8__OFF__GRAY.b )
	Desc1:setText( "Forces the reactive camo to never change and always apply to the selected stage (this applys to every reactive camo)" )
	Desc1:setTTF( "default" )
	Desc1:setLetterSpacing( 4 )
	Desc1:setAlignment( Enum[@"luialignment"][@"lui_alignment_center"] )
	Desc1:setAlignment( Enum[@"luialignment"][@"lui_alignment_middle"] )
	self:addElement( Desc1 )
	self.Desc1 = Desc1
	
	local BottomBracket9Slice = LUI.UIImage.new( 0, 0, 0, 1214, 0, 0, 28, 37 )
	BottomBracket9Slice:setAlpha( 0.5 )
	BottomBracket9Slice:setZRot( 180 )
	BottomBracket9Slice:setImage( RegisterImage( @"hash_4C325BED3F226657" ) )
	BottomBracket9Slice:setMaterial( LUI.UIImage.GetCachedMaterial( @"uie_nineslice_add" ) )
	BottomBracket9Slice:setShaderVector( 0, 0, 0, 0, 0 )
	BottomBracket9Slice:setupNineSliceShader( 16, 4 )
	self:addElement( BottomBracket9Slice )
	self.BottomBracket9Slice = BottomBracket9Slice
	
	self.__defaultFocus = Label
	LUI.OverrideFunction_CallOriginalSecond( self, "close", self.__onClose )
	if PreLoadFunc then
		PreLoadFunc( self, f1_arg1, f1_arg0 )
	end
	return self
end

CoD.ShieldReactiveSettingsList.__onClose = function ( f20_arg0 )
	f20_arg0.SettingsList:close()
end