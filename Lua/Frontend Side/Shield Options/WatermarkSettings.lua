--[[
		.\hksc.exe ".\Lua\WatermarkSettings.Lua" -o "C:\Program Files (x86)\Call of Duty Black Ops 4\project-bo4\mods\T8ShieldSupport\Lua\WatermarkSettings.luac"
]]

---------------------------

CoD.ShieldInitLuaFile()

---------------------------

-- watermarks
Engine[@"exec"](Engine[@"getprimarycontroller"](), "readjson shield_watermark_main_enabled common watermark_main bool true")
Engine[@"exec"](Engine[@"getprimarycontroller"](), "readjson shield_watermark_main_mods_enabled common watermark_main_mods bool true")
Engine[@"exec"](Engine[@"getprimarycontroller"](), "readjson shield_watermark_main_checksum_enabled common watermark_main_checksum bool false")
Engine[@"exec"](Engine[@"getprimarycontroller"](), "readjson shield_watermark_main_flash_hashes_enabled common watermark_main_flash_hashes bool false")

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

	if dvar_name == "shield_watermark_main_enabled" then	
		local str = "false"

		if dvar_val_new == 1 then
			str = "true"
		end
		
		Engine[@"exec"](Engine[@"getprimarycontroller"](), "writejson common watermark_main " .. str .. " bool")
	end

	if dvar_name == "shield_watermark_main_mods_enabled" then	
		local str = "false"

		if dvar_val_new == 1 then
			str = "true"
		end
		
		Engine[@"exec"](Engine[@"getprimarycontroller"](), "writejson common watermark_main_mods " .. str .. " bool")
	end

	if dvar_name == "shield_watermark_main_checksum_enabled" then	
		local str = "false"

		if dvar_val_new == 1 then
			str = "true"
		end
		
		Engine[@"exec"](Engine[@"getprimarycontroller"](), "writejson common watermark_main_checksum " .. str .. " bool")
	end

	if dvar_name == "shield_watermark_main_flash_hashes_enabled" then	
		local str = "false"

		if dvar_val_new == 1 then
			str = "true"
		end
		
		Engine[@"exec"](Engine[@"getprimarycontroller"](), "writejson common watermark_main_flash_hashes " .. str .. " bool")
	end
end

---------------------------

-- Watermark settings
DataSources.ShieldWaterMarkSettings = DataSourceHelpers.ListSetup( "ShieldWaterMarkSettings", function ( f138_arg0 )
	local data = {}

	table.insert( data, CoD.OptionsUtility.CreateDvarSettings( f138_arg0, @"shield/watermark_main", @"shield/watermark_main_desc", "shield_watermark_main_enabled", "shield_watermark_main_enabled", {
		{
			option = Engine[@"hash_4F9F1239CFD921FE"]( @"hash_94EB0E3329EDF5F" ),
			value = 0,
			default = true
		},
		{
			option = Engine[@"hash_4F9F1239CFD921FE"]( @"menu/enabled" ),
			value = 1
		}
	}, nil, OnExtraDataChange ) )

	table.insert( data, CoD.OptionsUtility.CreateDvarSettings( f138_arg0, @"shield/watermark_main_mods", @"shield/watermark_main_mods_desc", "shield_watermark_main_mods_enabled", "shield_watermark_main_mods_enabled", {
		{
			option = Engine[@"hash_4F9F1239CFD921FE"]( @"hash_94EB0E3329EDF5F" ),
			value = 0,
			default = true
		},
		{
			option = Engine[@"hash_4F9F1239CFD921FE"]( @"menu/enabled" ),
			value = 1
		}
	}, nil, OnExtraDataChange ) )

	table.insert( data, CoD.OptionsUtility.CreateDvarSettings( f138_arg0, @"shield/watermark_main_checksum", @"shield/watermark_main_checksum_desc", "shield_watermark_main_checksum_enabled", "shield_watermark_main_checksum_enabled", {
		{
			option = Engine[@"hash_4F9F1239CFD921FE"]( @"hash_94EB0E3329EDF5F" ),
			value = 0,
			default = true
		},
		{
			option = Engine[@"hash_4F9F1239CFD921FE"]( @"menu/enabled" ),
			value = 1
		}
	}, nil, OnExtraDataChange ) )

	table.insert( data, CoD.OptionsUtility.CreateDvarSettings( f138_arg0, @"shield/watermark_main_flash_hashes", @"shield/watermark_main_flash_hashes_desc", "shield_watermark_main_flash_hashes_enabled", "shield_watermark_main_flash_hashes_enabled", {
		{
			option = Engine[@"hash_4F9F1239CFD921FE"]( @"hash_94EB0E3329EDF5F" ),
			value = 0,
			default = true
		},
		{
			option = Engine[@"hash_4F9F1239CFD921FE"]( @"menu/enabled" ),
			value = 1
		}
	}, nil, OnExtraDataChange ) )

	return data
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

-- watermark
CoD.Shield_WaterMark_SettingsPopup = InheritFrom( CoD.Menu )
LUI.createMenu.Shield_WaterMark_SettingsPopup = function ( f1_arg0, f1_arg1 )
	local self = CoD.Menu.NewForUIEditor( "Shield_WaterMark_SettingsPopup", f1_arg0 )
	local f1_local1 = self
	self:setClass( CoD.Shield_WaterMark_SettingsPopup )
	self.soundSet = "none"
	self:setOwner( f1_arg0 )
	self:setLeftRight( 0, 1, 0, 0 )
	self:setTopBottom( 0, 1, 0, 0 )
	self:playSound( "menu_open", f1_arg0 )
	self.anyChildUsesUpdateState = true
	f1_local1:addElementToPendingUpdateStateList( self )
	
	local CommomCenteredPopup = CoD.CommonCenteredPopup.new( f1_local1, f1_arg0, 0, 1, 0, 0, 0, 1, 0, 0 )
	CommomCenteredPopup.TitleText:setText("Watermark Settings")
	CommomCenteredPopup.HeaderBackground:setAlpha( 0 )
	CommomCenteredPopup.HeaderTopBar:setAlpha( 0 )
	CommomCenteredPopup.HeaderBottomBar:setAlpha( 0 )
	self:addElement( CommomCenteredPopup )
	self.CommomCenteredPopup = CommomCenteredPopup
	
	local WaterMarkSettingsList = LUI.UIList.new( f1_local1, f1_arg0, 3, 3, nil, false, false, false, false )
	WaterMarkSettingsList:setLeftRight( 0.5, 0.5, -250, 250 )
	WaterMarkSettingsList:setTopBottom( 0.55, 0.55, -380 + 30, -320 + 30 )
	WaterMarkSettingsList:setAutoScaleContent( true )
	WaterMarkSettingsList:setVerticalCount(4) -- fix
	WaterMarkSettingsList:setHorizontalCount(1)
	WaterMarkSettingsList:setWidgetType( CoD.CustomGames_SettingSliderNoCustom )
	WaterMarkSettingsList:setAlignment( Enum[@"luialignment"][@"lui_alignment_left"] )
	WaterMarkSettingsList:setDataSource( "ShieldWaterMarkSettings" )
	self:addElement( WaterMarkSettingsList )
	self.WaterMarkSettingsList = WaterMarkSettingsList

	if Engine[@"getdvarint"]("shield_ui_color") == 0 then
		WaterMarkSettingsList:setRGB(0, 1, 1)
	elseif Engine[@"getdvarint"]("shield_ui_color") == 1 then
		WaterMarkSettingsList:setRGB(1, 0, 0)
	elseif Engine[@"getdvarint"]("shield_ui_color") == 2 then
		WaterMarkSettingsList:setRGB(0, 1, 0)
	end
	
	local SettingDescription = LUI.UIText.new( 0.5, 0.5, -250, 250, 0.60, 0.60, -284 + 75, -263 + 75 )
	SettingDescription:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )
	SettingDescription:setTTF( "notosans_regular" )
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
	
	SettingDescription:linkToElementModel( WaterMarkSettingsList, "desc", true, function ( model )
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
	WaterMarkSettingsList.id = "WaterMarkSettingsList"
	--if CoD.isPC then
	--	PCSmallCloseButton.id = "PCSmallCloseButton"
	--end
	self:processEvent( {
		name = "menu_loaded",
		controller = f1_arg0
	} )
	self.__defaultFocus = WaterMarkSettingsList
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

CoD.Shield_WaterMark_SettingsPopup.__resetProperties = function ( f13_arg0 )
	f13_arg0.WaterMarkSettingsList:completeAnimation()
	f13_arg0.SettingDescription:completeAnimation()
	f13_arg0.WaterMarkSettingsList:setLeftRight( 0.5, 0.5, -250, 250 )
	f13_arg0.SettingDescription:setLeftRight( 0.5, 0.5, -250, 250 )
end

CoD.Shield_WaterMark_SettingsPopup.__clipsPerState = {
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
			f15_arg0.WaterMarkSettingsList:completeAnimation()
			f15_arg0.WaterMarkSettingsList:setLeftRight( 0.5, 0.5, -290, 290 )
			f15_arg0.clipFinished( f15_arg0.WaterMarkSettingsList )
			f15_arg0.SettingDescription:completeAnimation()
			f15_arg0.SettingDescription:setLeftRight( 0.5, 0.5, -290, 290 )
			f15_arg0.clipFinished( f15_arg0.SettingDescription )
		end
	}
}

CoD.Shield_WaterMark_SettingsPopup.__onClose = function ( f16_arg0 )
	f16_arg0.SettingDescription:close()
	f16_arg0.CommomCenteredPopup:close()
	f16_arg0.WaterMarkSettingsList:close()
	--f16_arg0.PCSmallCloseButton:close()
end