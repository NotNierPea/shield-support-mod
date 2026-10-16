--[[
		.\hksc.exe ".\Lua\MovementSettings.Lua" -o "C:\Program Files (x86)\Call of Duty Black Ops 4\project-bo4\mods\T8ShieldSupport\Lua\MovementSettings.luac"
]]

---------------------------

CoD.ShieldInitLuaFile()

---------------------------

--[[
	The movement settings. The first turns the movement patches on, "alt_movement" under "game", and counts after a
	restart. The others are each a key under "movement", read by the client (movement_patches.cpp) and applied at once
	by movement_reload. Each setting: its dvar here, its section, key and type there, what it is when the config has
	nothing, and its choices with the value each one writes.
]]
local MovementSettings = {
	{
		dvar = "shield_alt_movement", section = "game", key = "alt_movement", type = "bool", default = 0,
		name = @"shield/alt_movement", desc = @"shield/alt_movement_desc",
		choices = { { "Off", 0 }, { "On", 1 } }
	},
	{
		dvar = "shield_mv_omni", section = "movement", key = "omni", type = "bool", default = 1,
		name = @"shield/mv_omni", desc = @"shield/mv_omni_desc",
		choices = { { "Off", 0 }, { "On", 1 } }
	},
	{
		dvar = "shield_mv_strafe", section = "movement", key = "strafe_scale", type = "int32_t", default = 97,
		name = @"shield/mv_strafe", desc = @"shield/mv_strafe_desc",
		choices = { { "67% (Game)", 67 }, { "80%", 80 }, { "90%", 90 }, { "97%", 97 }, { "100%", 100 } }
	},
	{
		dvar = "shield_mv_jump_cooldown", section = "movement", key = "jump_cooldown", type = "int32_t", default = 1,
		name = @"shield/mv_jump_cooldown", desc = @"shield/mv_jump_cooldown_desc",
		choices = { { "None", 1 }, { "100 ms", 100 }, { "250 ms", 250 }, { "500 ms (Game)", 500 } }
	},
	{
		dvar = "shield_mv_sprint_ramp", section = "movement", key = "sprint_ramp", type = "int32_t", default = 500,
		name = @"shield/mv_sprint_ramp", desc = @"shield/mv_sprint_ramp_desc",
		choices = { { "250 ms", 250 }, { "500 ms", 500 }, { "1 Second", 1000 }, { "1.5 Seconds (Game)", 1500 } }
	},
	{
		dvar = "shield_mv_instant_slide", section = "movement", key = "instant_slide", type = "bool", default = 1,
		name = @"shield/mv_instant_slide", desc = @"shield/mv_instant_slide_desc",
		choices = { { "Off", 0 }, { "On", 1 } }
	},
	{
		dvar = "shield_mv_jump_slowdown", section = "movement", key = "no_jump_slowdown", type = "bool", default = 1,
		name = @"shield/mv_jump_slowdown", desc = @"shield/mv_jump_slowdown_desc",
		choices = { { "Off", 0 }, { "On", 1 } }
	},
	{
		dvar = "shield_mv_landing_friction", section = "movement", key = "no_landing_friction", type = "bool", default = 1,
		name = @"shield/mv_landing_friction", desc = @"shield/mv_landing_friction_desc",
		choices = { { "Off", 0 }, { "On", 1 } }
	},
	{
		dvar = "shield_mv_slide_chaining", section = "movement", key = "slide_chaining", type = "bool", default = 1,
		name = @"shield/mv_slide_chaining", desc = @"shield/mv_slide_chaining_desc",
		choices = { { "Off", 0 }, { "On", 1 } }
	}
}

-- what is in the config now
for _, setting in ipairs( MovementSettings ) do
	Engine[@"exec"]( Engine[@"getprimarycontroller"](), "readjson " .. setting.dvar .. " " .. setting.section .. " " .. setting.key .. " " .. setting.type .. " " .. setting.default )
end

-- a choice was made: the dvar, the config the client reads, and the client applies it
local function OnMovementSettingChange( f137_arg0, f137_arg1, f137_arg2, f137_arg3, f137_arg4 )
	local dvar_name = f137_arg3
	local current_val = f137_arg1.value
	CoD.OptionsUtility.UpdateInfoModels( f137_arg1 )

	if current_val == Engine[@"getdvarint"]( dvar_name ) then
		return
	end

	Engine[@"setdvar"]( dvar_name, current_val )

	for _, setting in ipairs( MovementSettings ) do
		if setting.dvar == dvar_name then
			local value = tostring( current_val )

			if setting.type == "bool" then
				value = current_val == 1 and "true" or "false"
			end

			Engine[@"exec"]( Engine[@"getprimarycontroller"](), "writejson " .. setting.section .. " " .. setting.key .. " " .. value .. " " .. setting.type )
		end
	end

	Engine[@"exec"]( Engine[@"getprimarycontroller"](), "movement_reload" )
end

DataSources.ShieldMovementSettings = DataSourceHelpers.ListSetup( "ShieldMovementSettings", function ( f138_arg0 )
	local data = {}

	for _, setting in ipairs( MovementSettings ) do
		local options = {}

		for _, choice in ipairs( setting.choices ) do
			table.insert( options, {
				option = choice[1],
				value = choice[2],
				default = choice[2] == setting.default
			} )
		end

		table.insert( data, CoD.OptionsUtility.CreateDvarSettings( f138_arg0, setting.name, setting.desc, setting.dvar, setting.dvar, options, nil, OnMovementSettingChange ) )
	end

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

-- the menu of the movement settings: as the other settings menus, see CoD.ShieldSettingsFrame of ShieldOptions.lua
CoD.Shield_Movement_SettingsPopup = InheritFrom( CoD.Menu )
LUI.createMenu.Shield_Movement_SettingsPopup = function ( f1_arg0, f1_arg1 )
	local self = CoD.Menu.NewForUIEditor( "Shield_Movement_SettingsPopup", f1_arg0 )
	local f1_local1 = self
	self:setClass( CoD.Shield_Movement_SettingsPopup )
	self.soundSet = "none"
	self:setOwner( f1_arg0 )
	self:setLeftRight( 0, 1, 0, 0 )
	self:setTopBottom( 0, 1, 0, 0 )
	self:playSound( "menu_open", f1_arg0 )
	self.anyChildUsesUpdateState = true
	f1_local1:addElementToPendingUpdateStateList( self )

	local CommomCenteredPopup = CoD.ShieldSettingsFrame.new( f1_local1, f1_arg0, {
		title = "Movement",
		caption = "OMNI MOVEMENT, JUMPS AND SLIDES",
		color = { r = 0.45, g = 0.9, b = 0.45 },
		rows = #MovementSettings
	} )
	self:addElement( CommomCenteredPopup )
	self.CommomCenteredPopup = CommomCenteredPopup

	local MovementSettingsList = LUI.UIList.new( f1_local1, f1_arg0, 3, 3, nil, false, false, false, false )
	MovementSettingsList:setLeftRight( 0.5, 0.5, CoD.ShieldSettingsFrame.LIST_LEFT, CoD.ShieldSettingsFrame.LIST_RIGHT )
	MovementSettingsList:setTopBottom( 0.5, 0.5, CommomCenteredPopup.listTop, CommomCenteredPopup.listTop + CommomCenteredPopup.listHeight )
	MovementSettingsList:setAutoScaleContent( true )
	MovementSettingsList:setVerticalCount( #MovementSettings )
	MovementSettingsList:setHorizontalCount( 1 )
	MovementSettingsList:setWidgetType( CoD.CustomGames_SettingSliderNoCustom )
	MovementSettingsList:setAlignment( Enum[@"luialignment"][@"lui_alignment_left"] )
	MovementSettingsList:setDataSource( "ShieldMovementSettings" )
	self:addElement( MovementSettingsList )
	self.MovementSettingsList = MovementSettingsList

	if Engine[@"getdvarint"]("shield_ui_color") == 0 then
		MovementSettingsList:setRGB(0, 1, 1)
	elseif Engine[@"getdvarint"]("shield_ui_color") == 1 then
		MovementSettingsList:setRGB(1, 0, 0)
	elseif Engine[@"getdvarint"]("shield_ui_color") == 2 then
		MovementSettingsList:setRGB(0, 1, 0)
	end

	local SettingDescription = LUI.UIText.new( 0.5, 0.5, CoD.ShieldSettingsFrame.RIGHT_LEFT, CoD.ShieldSettingsFrame.RIGHT_RIGHT, 0.5, 0.5, CommomCenteredPopup.descTop, CommomCenteredPopup.descTop + 21 )
	SettingDescription:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )
	SettingDescription:setTTF( "notosans_regular" )
	SettingDescription:setAlignment( Enum[@"luialignment"][@"lui_alignment_left"] )
	SettingDescription:setAlignment( Enum[@"luialignment"][@"lui_alignment_top"] )
	self:addElement( SettingDescription )
	self.SettingDescription = SettingDescription

	SettingDescription:linkToElementModel( MovementSettingsList, "desc", true, function ( model )
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
	MovementSettingsList.id = "MovementSettingsList"
	self:processEvent( {
		name = "menu_loaded",
		controller = f1_arg0
	} )
	self.__defaultFocus = MovementSettingsList
	if CoD.isPC and (IsKeyboard( f1_arg0 ) or self.ignoreCursor) then
		self:restoreState( f1_arg0 )
	end
	LUI.OverrideFunction_CallOriginalSecond( self, "close", self.__onClose )
	if PostLoadFunc then
		PostLoadFunc( self, f1_arg0 )
	end

	CoD.EnhPrintInfo("Called", "Shield's Movement Settings Menu")

	return self
end

CoD.Shield_Movement_SettingsPopup.__resetProperties = function ( f13_arg0 )
	f13_arg0.MovementSettingsList:completeAnimation()
	f13_arg0.MovementSettingsList:setLeftRight( 0.5, 0.5, CoD.ShieldSettingsFrame.LIST_LEFT, CoD.ShieldSettingsFrame.LIST_RIGHT )
end

CoD.Shield_Movement_SettingsPopup.__clipsPerState = {
	DefaultState = {
		DefaultClip = function ( f14_arg0, f14_arg1 )
			f14_arg0:__resetProperties()
			f14_arg0:setupElementClipCounter( 0 )
		end
	},
	KBM = {
		DefaultClip = function ( f15_arg0, f15_arg1 )
			f15_arg0:__resetProperties()
			f15_arg0:setupElementClipCounter( 1 )
			f15_arg0.MovementSettingsList:completeAnimation()
			f15_arg0.MovementSettingsList:setLeftRight( 0.5, 0.5, CoD.ShieldSettingsFrame.LIST_LEFT, CoD.ShieldSettingsFrame.LIST_RIGHT_KBM )
			f15_arg0.clipFinished( f15_arg0.MovementSettingsList )
		end
	}
}

CoD.Shield_Movement_SettingsPopup.__onClose = function ( f16_arg0 )
	f16_arg0.SettingDescription:close()
	f16_arg0.CommomCenteredPopup:close()
	f16_arg0.MovementSettingsList:close()
end
