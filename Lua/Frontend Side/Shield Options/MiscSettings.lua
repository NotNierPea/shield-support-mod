--[[
		.\hksc.exe ".\Lua\MiscSettings.Lua" -o "C:\Program Files (x86)\Call of Duty Black Ops 4\project-bo4\mods\T8ShieldSupport\Lua\MiscSettings.luac"
]]

---------------------------

CoD.ShieldInitLuaFile()

---------------------------

-- dvars
Engine[@"exec"](Engine[@"getprimarycontroller"](), "readjson shield_discordrpc common discord_rpc bool true")
Engine[@"exec"](Engine[@"getprimarycontroller"](), "readjson shield_botsrandom lua botsrandom uint64_t 1")
Engine[@"exec"](Engine[@"getprimarycontroller"](), "readjson shield_offline_perks lua offline_perks uint64_t 0")
Engine[@"exec"](Engine[@"getprimarycontroller"](), "readjson shield_prevent_dw_disconnect demonware prevent_dw_disconnect bool false")
Engine[@"exec"](Engine[@"getprimarycontroller"](), "readjson shield_ui_color lua ui_color uint64_t 0")
Engine[@"exec"](Engine[@"getprimarycontroller"](), "readjson shield_director_blur lua director_blur uint64_t 0")
Engine[@"exec"](Engine[@"getprimarycontroller"](), "readjson shield_diff_rounds lua diff_rounds uint64_t 0")
Engine[@"exec"](Engine[@"getprimarycontroller"](), "readjson shield_performance_frontend lua performance_frontend uint64_t 0")
Engine[@"exec"](Engine[@"getprimarycontroller"](), "readjson shield_show_scripts gsc show_script_usages bool false")
Engine[@"exec"](Engine[@"getprimarycontroller"](), "readjson shield_alt_movement game alt_movement bool false")

--Engine[@"exec"](Engine[@"getprimarycontroller"](), "readjson shield_checksum gsc show_checksum bool false")
--Engine[@"exec"](Engine[@"getprimarycontroller"](), "readjson shield_slide game slide_movement uint64_t 10")

---------------------------

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

	if dvar_name == "shield_ui_color" then	
		Engine[@"exec"](Engine[@"getprimarycontroller"](), "writejson lua ui_color " .. dvar_val_new .. " uint64_t")
	end

	if dvar_name == "shield_director_blur" then	
		Engine[@"exec"](Engine[@"getprimarycontroller"](), "writejson lua director_blur " .. dvar_val_new .. " uint64_t")
	end

	if dvar_name == "shield_diff_rounds" then	
		Engine[@"exec"](Engine[@"getprimarycontroller"](), "writejson lua diff_rounds " .. dvar_val_new .. " uint64_t")
	end

	-- moved to watermarks..
	--[[
	if dvar_name == "shield_checksum" then	
		Engine[@"exec"](Engine[@"getprimarycontroller"](), "writejson gsc show_checksum " .. dvar_val_new .. " bool")
	end
	]]

	if dvar_name == "shield_show_scripts" then	
		Engine[@"exec"](Engine[@"getprimarycontroller"](), "writejson gsc show_script_usages " .. dvar_val_new .. " bool")
	end

	if dvar_name == "shield_alt_movement" then	
		Engine[@"exec"](Engine[@"getprimarycontroller"](), "writejson game alt_movement " .. dvar_val_new .. " bool")
	end

	if dvar_name == "shield_performance_frontend" then	
		Engine[@"exec"](Engine[@"getprimarycontroller"](), "writejson lua performance_frontend " .. dvar_val_new .. " uint64_t")
	end

	if dvar_name == "shield_botsrandom" then	
		Engine[@"exec"](Engine[@"getprimarycontroller"](), "writejson lua botsrandom " .. dvar_val_new .. " uint64_t")
	end

	if dvar_name == "shield_offline_perks" then	
		Engine[@"exec"](Engine[@"getprimarycontroller"](), "writejson lua offline_perks " .. dvar_val_new .. " uint64_t")

		local val = 1

		if dvar_val_new == 1 then
			val = 0
		end

		Engine[@"setdvar"]("hash_1C1A8ED8D0BF271C", val)
		Engine[@"setdvar"]("hash_4E1190045EF3588B", val)
		Engine[@"setdvar"]("hash_49EF5478510B5AF3", val)
	end

	if dvar_name == "shield_prevent_dw_disconnect" then	
		local str = "false"

		if dvar_val_new == 1 then
			str = "true"
		end

		Engine[@"exec"](Engine[@"getprimarycontroller"](), "writejson demonware prevent_dw_disconnect " .. str .. " bool")
	end

	if dvar_name == "shield_discordrpc" then	
		Engine[@"exec"](Engine[@"getprimarycontroller"](), "writejson common discord_rpc " .. dvar_val_new .. " bool")
	end
end

CoD.MiscReload = function()
	local val = 1

	if Engine[@"getdvarint"]("shield_offline_perks") == 1 then
		val = 0
	end

	Engine[@"setdvar"]("hash_1C1A8ED8D0BF271C", val)
	Engine[@"setdvar"]("hash_4E1190045EF3588B", val)
	Engine[@"setdvar"]("hash_49EF5478510B5AF3", val)
end

---------------------------

-- Optional Settings (Other)
DataSources.OptionalSettingsData = DataSourceHelpers.ListSetup( "OptionalSettingsData", function ( f138_arg0 )
	local Settings = {}

	-- !! decs is not needed here!!!, nvm

	table.insert( Settings, CoD.OptionsUtility.CreateDvarSettings( f138_arg0, @"shield/ui_colors_setting", @"shield/ui_colors_setting_desc", "shield_ui_color", "shield_ui_color", {
		{
			option = Engine[@"hash_4F9F1239CFD921FE"]( @"shield/Blue" ),
			value = 0,
			default = true
		},
		{
			option = Engine[@"hash_4F9F1239CFD921FE"]( @"shield/Red" ),
			value = 1
		},
		{
			option = Engine[@"hash_4F9F1239CFD921FE"]( @"shield/Green" ),
			value = 2
		},
		{
			option = Engine[@"hash_4F9F1239CFD921FE"]( @"shield/Default_Color" ),
			value = 69
		}
	}, nil, OnExtraDataChange ) )

	table.insert( Settings, CoD.OptionsUtility.CreateDvarSettings( f138_arg0, @"shield/blureffect", @"shield/blureffect_desc", "shield_director_blur", "shield_director_blur", {
		{
			option = Engine[@"hash_4F9F1239CFD921FE"]( @"menu/off" ),
			value = 0,
			default = true
		},
		{
			option = Engine[@"hash_4F9F1239CFD921FE"]( @"menu/on" ),
			value = 1
		}
	}, nil, OnExtraDataChange ) )

	table.insert( Settings, CoD.OptionsUtility.CreateDvarSettings( f138_arg0, @"shield/roundcnt", @"shield/roundcnt_desc", "shield_diff_rounds", "shield_diff_rounds", {
		{
			option = Engine[@"hash_4F9F1239CFD921FE"]( @"menu/off" ),
			value = 0,
			default = true
		},
		{
			option = Engine[@"hash_4F9F1239CFD921FE"]( @"menu/on" ),
			value = 1
		}
	}, nil, OnExtraDataChange ) )

	--[[
	table.insert( Settings, CoD.OptionsUtility.CreateDvarSettings( f138_arg0, @"shield/checksum", @"shield/checksum_desc", "shield_checksum", "shield_checksum", {
		{
			option = Engine[@"hash_4F9F1239CFD921FE"]( @"menu/off" ),
			value = 0,
			default = true
		},
		{
			option = Engine[@"hash_4F9F1239CFD921FE"]( @"menu/on" ),
			value = 1
		}
	}, nil, OnExtraDataChange ) )
	]]

	table.insert( Settings, CoD.OptionsUtility.CreateDvarSettings( f138_arg0, @"shield/botsrandom", @"shield/botsrandom_desc", "shield_botsrandom", "shield_botsrandom", {
		{
			option = Engine[@"hash_4F9F1239CFD921FE"]( @"menu/off" ),
			value = 0,
			default = true
		},
		{
			option = Engine[@"hash_4F9F1239CFD921FE"]( @"menu/on" ),
			value = 1
		}
	}, nil, OnExtraDataChange ) )

	table.insert( Settings, CoD.OptionsUtility.CreateDvarSettings( f138_arg0, @"shield/prevent_dw_disconnect", @"shield/prevent_dw_disconnect_desc", "shield_prevent_dw_disconnect", "shield_prevent_dw_disconnect", {
		{
			option = Engine[@"hash_4F9F1239CFD921FE"]( @"menu/off" ),
			value = 0,
			default = true
		},
		{
			option = Engine[@"hash_4F9F1239CFD921FE"]( @"menu/on" ),
			value = 1
		}
	}, nil, OnExtraDataChange ) )

	table.insert( Settings, CoD.OptionsUtility.CreateDvarSettings( f138_arg0, @"shield/offline_perks", @"shield/offline_perks_desc", "shield_offline_perks", "shield_offline_perks", {
		{
			option = Engine[@"hash_4F9F1239CFD921FE"]( @"menu/off" ),
			value = 0,
			default = true
		},
		{
			option = Engine[@"hash_4F9F1239CFD921FE"]( @"menu/on" ),
			value = 1
		}
	}, nil, OnExtraDataChange ) )

	table.insert( Settings, CoD.OptionsUtility.CreateDvarSettings( f138_arg0, @"shield/discordrpc", @"shield/discordrpc_desc", "shield_discordrpc", "shield_discordrpc", {
		{
			option = Engine[@"hash_4F9F1239CFD921FE"]( @"menu/off" ),
			value = 0,
			default = true
		},
		{
			option = Engine[@"hash_4F9F1239CFD921FE"]( @"menu/on" ),
			value = 1
		}
	}, nil, OnExtraDataChange ) )

	table.insert( Settings, CoD.OptionsUtility.CreateDvarSettings( f138_arg0, @"shield/perfor_mode_frontend", @"shield/perfor_mode_frontend_desc", "shield_performance_frontend", "shield_performance_frontend", {
		{
			option = Engine[@"hash_4F9F1239CFD921FE"]( @"menu/off" ),
			value = 0,
			default = true
		},
		{
			option = Engine[@"hash_4F9F1239CFD921FE"]( @"menu/on" ),
			value = 1
		}
	}, nil, OnExtraDataChange ) )

	table.insert( Settings, CoD.OptionsUtility.CreateDvarSettings( f138_arg0, @"shield/show_script", @"shield/show_script_desc", "shield_show_scripts", "shield_show_scripts", {
		{
			option = Engine[@"hash_4F9F1239CFD921FE"]( @"menu/off" ),
			value = 0,
			default = true
		},
		{
			option = Engine[@"hash_4F9F1239CFD921FE"]( @"menu/on" ),
			value = 1
		}
	}, nil, OnExtraDataChange ) )

	table.insert( Settings, CoD.OptionsUtility.CreateDvarSettings( f138_arg0, @"shield/alt_movement", @"shield/alt_movement_desc", "shield_alt_movement", "shield_alt_movement", {
		{
			option = Engine[@"hash_4F9F1239CFD921FE"]( @"menu/off" ),
			value = 0,
			default = true
		},
		{
			option = Engine[@"hash_4F9F1239CFD921FE"]( @"menu/on" ),
			value = 1
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

-- misc
CoD.Shield_Misc_SettingsPopup = InheritFrom( CoD.Menu )
LUI.createMenu.Shield_Misc_SettingsPopup = function ( f1_arg0, f1_arg1 )
	local self = CoD.Menu.NewForUIEditor( "Shield_Misc_SettingsPopup", f1_arg0 )
	local f1_local1 = self
	self:setClass( CoD.Shield_Misc_SettingsPopup )
	self.soundSet = "none"
	self:setOwner( f1_arg0 )
	self:setLeftRight( 0, 1, 0, 0 )
	self:setTopBottom( 0, 1, 0, 0 )
	self:playSound( "menu_open", f1_arg0 )
	self.anyChildUsesUpdateState = true
	f1_local1:addElementToPendingUpdateStateList( self )
	
	local CommomCenteredPopup = CoD.CommonCenteredPopup.new( f1_local1, f1_arg0, 0, 1, 0, 0, 0, 1, 0, 0 )
	CommomCenteredPopup.TitleText:setText("Misc Settings")
	CommomCenteredPopup.HeaderBackground:setAlpha( 0 )
	CommomCenteredPopup.HeaderTopBar:setAlpha( 0 )
	CommomCenteredPopup.HeaderBottomBar:setAlpha( 0 )
	self:addElement( CommomCenteredPopup )
	self.CommomCenteredPopup = CommomCenteredPopup
	
	local MiscSettingsList = LUI.UIList.new( f1_local1, f1_arg0, 3, 3, nil, false, false, false, false )
	MiscSettingsList:setLeftRight( 0.5, 0.5, -250, 250 )
	MiscSettingsList:setTopBottom( 0.5, 0.5, -380 + 280, -320 + 280 )
	MiscSettingsList:setAutoScaleContent( true )
	MiscSettingsList:setVerticalCount(10)
	MiscSettingsList:setHorizontalCount(1)
	MiscSettingsList:setWidgetType( CoD.CustomGames_SettingSliderNoCustom )
	MiscSettingsList:setAlignment( Enum[@"luialignment"][@"lui_alignment_left"] )
	MiscSettingsList:setDataSource( "OptionalSettingsData" )
	self:addElement( MiscSettingsList )
	self.MiscSettingsList = MiscSettingsList

	if Engine[@"getdvarint"]("shield_ui_color") == 0 then
		MiscSettingsList:setRGB(0, 1, 1)
	elseif Engine[@"getdvarint"]("shield_ui_color") == 1 then
		MiscSettingsList:setRGB(1, 0, 0)
	elseif Engine[@"getdvarint"]("shield_ui_color") == 2 then
		MiscSettingsList:setRGB(0, 1, 0)
	end
	
	local SettingDescription = LUI.UIText.new( 0.5, 0.5, -250, 250, 0.55, 0.55, -284 + 320 + 180, -263 + 320 + 180 )
	SettingDescription:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )
	SettingDescription:setTTF( "notosans_regular" )
	SettingDescription:setAlignment( Enum[@"luialignment"][@"lui_alignment_left"] )
	SettingDescription:setAlignment( Enum[@"luialignment"][@"lui_alignment_top"] )
	self:addElement( SettingDescription )
	self.SettingDescription = SettingDescription
	
	SettingDescription:linkToElementModel( MiscSettingsList, "desc", true, function ( model )
		local f7_local0 = model:get()
		if f7_local0 ~= nil then
			SettingDescription:setText( Engine[@"hash_4F9F1239CFD921FE"]( f7_local0 ) )
		end
	end )

	-- rules options
	local RulesSettings = CoD.DirectorSelectButtonMiniInternal.new( f1_local1, f1_arg0, 0.50, 0.50, 28.28 - 20, 338.28 - 20, 0.50, 0.50, 338.01, 388.01 )
	
	RulesSettings.MiddleText:setTTF( "notosans_bold" )
	RulesSettings.MiddleText:setText("Saved Custom Rules")

	RulesSettings.MiddleTextFocus:setText("Saved Custom Rules")
	RulesSettings.MiddleTextFocus:setTTF( "notosans_bold" )
	
	RulesSettings:linkToElementModel( self, nil, false, function ( model )
		RulesSettings:setModel( model, f1_arg1 )
	end )
	self:addElement( RulesSettings )
	self.RulesSettings = RulesSettings

	f1_local1:AddButtonCallbackFunction( RulesSettings, f1_arg0, Enum[@"luibutton"][@"lui_key_xba_pscross"], "ui_confirm", function ( element, menu, controller, model )
		PlaySoundAlias( "uin_paint_image_flip_toggle" )
		CoD.EnhPrintInfo("RulesSettings")
		
		OpenOverlay( self, "Shield_Rules_SettingsPopup", controller )

	end, function ( element, menu, controller )
		if IsGamepad( controller ) then
			CoD.Menu.SetButtonLabel( menu, Enum[@"luibutton"][@"lui_key_xba_pscross"], @"menu/select", nil, "ui_confirm" )
			return true
		elseif IsMouseOrKeyboard( controller ) then
			CoD.Menu.SetButtonLabel( menu, Enum[@"luibutton"][@"lui_key_xba_pscross"], @"hash_0", nil, "ui_confirm" )
			return false
		else
			return false
		end
	end, false )

	RulesSettings.id = "RulesSettings"

	--LUI_DebugElement(f1_local1, f1_arg0, self, RulesSettings, "RulesSettings", 10)

	-- blackout options
	local BlackoutSettings = CoD.DirectorSelectButtonMiniInternal.new( f1_local1, f1_arg0, 0.50, 0.50, -315.24, -5.24, 0.50, 0.50, 338.01, 388.01 )
	
	BlackoutSettings.MiddleText:setTTF( "notosans_bold" )
	BlackoutSettings.MiddleText:setText("Blackout Settings")

	BlackoutSettings.MiddleTextFocus:setText("Blackout Settings")
	BlackoutSettings.MiddleTextFocus:setTTF( "notosans_bold" )
	
	BlackoutSettings:linkToElementModel( self, nil, false, function ( model )
		BlackoutSettings:setModel( model, f1_arg1 )
	end )
	self:addElement( BlackoutSettings )
	self.BlackoutSettings = BlackoutSettings

	--LUI_DebugElement(f1_local1, f1_arg0, self, BlackoutSettings, "BlackoutSettings", 10)

	f1_local1:AddButtonCallbackFunction( BlackoutSettings, f1_arg0, Enum[@"luibutton"][@"lui_key_xba_pscross"], "ui_confirm", function ( element, menu, controller, model )
		PlaySoundAlias( "uin_paint_image_flip_toggle" )
		CoD.EnhPrintInfo("BlackoutSettings")
		
		OpenOverlay( self, "Shield_Blackout_SettingsPopup", controller )

	end, function ( element, menu, controller )
		if IsGamepad( controller ) then
			CoD.Menu.SetButtonLabel( menu, Enum[@"luibutton"][@"lui_key_xba_pscross"], @"menu/select", nil, "ui_confirm" )
			return true
		elseif IsMouseOrKeyboard( controller ) then
			CoD.Menu.SetButtonLabel( menu, Enum[@"luibutton"][@"lui_key_xba_pscross"], @"hash_0", nil, "ui_confirm" )
			return false
		else
			return false
		end
	end, false )

	BlackoutSettings.id = "BlackoutSettings"

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
	MiscSettingsList.id = "MiscSettingsList"
	self:processEvent( {
		name = "menu_loaded",
		controller = f1_arg0
	} )
	self.__defaultFocus = MiscSettingsList
	if CoD.isPC and (IsKeyboard( f1_arg0 ) or self.ignoreCursor) then
		self:restoreState( f1_arg0 )
	end
	LUI.OverrideFunction_CallOriginalSecond( self, "close", self.__onClose )
	if PostLoadFunc then
		PostLoadFunc( self, f1_arg0 )
	end
	
	f1_local7 = self
	--MenuHidesFreeCursor( f1_local1, f1_arg0 )

	CoD.EnhPrintInfo("Called", "Shield's Aim Settings Menu")

	return self
end

CoD.Shield_Misc_SettingsPopup.__resetProperties = function ( f13_arg0 )
	f13_arg0.MiscSettingsList:completeAnimation()
	f13_arg0.SettingDescription:completeAnimation()
	f13_arg0.MiscSettingsList:setLeftRight( 0.5, 0.5, -250, 250 )
	f13_arg0.SettingDescription:setLeftRight( 0.5, 0.5, -250, 250 )
end

CoD.Shield_Misc_SettingsPopup.__clipsPerState = {
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
			f15_arg0.MiscSettingsList:completeAnimation()
			f15_arg0.MiscSettingsList:setLeftRight( 0.5, 0.5, -290, 290 )
			f15_arg0.clipFinished( f15_arg0.MiscSettingsList )
			f15_arg0.SettingDescription:completeAnimation()
			f15_arg0.SettingDescription:setLeftRight( 0.5, 0.5, -290, 290 )
			f15_arg0.clipFinished( f15_arg0.SettingDescription )
		end
	}
}

CoD.Shield_Misc_SettingsPopup.__onClose = function ( f16_arg0 )
	f16_arg0.SettingDescription:close()
	f16_arg0.CommomCenteredPopup:close()
	f16_arg0.MiscSettingsList:close()
	f16_arg0.BlackoutSettings:close()
end