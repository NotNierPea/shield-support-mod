--[[
		.\hksc.exe ".\Lua\Reactives.Lua" -o "C:\Program Files (x86)\Call of Duty Black Ops 4\project-bo4\mods\T8ShieldSupport\Lua\Reactives.luac"
]]

---------------------------

CoD.ShieldInitLuaFile()

---------------------------

Engine[@"exec"](Engine[@"getprimarycontroller"](), "readjson shield_active_camo_last lua active_camo_last uint64_t 0")

---------------------------

local GlobalMenu = nil

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

	GlobalMenu = f1_arg0
	
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