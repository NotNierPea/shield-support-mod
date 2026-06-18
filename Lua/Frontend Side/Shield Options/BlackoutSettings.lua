--[[
		.\hksc.exe ".\Lua\MiscSettings.Lua" -o "C:\Program Files (x86)\Call of Duty Black Ops 4\project-bo4\mods\T8ShieldSupport\Lua\MiscSettings.luac"
]]

---------------------------

CoD.ShieldInitLuaFile()

---------------------------

-- dvars
if Engine[@"getdvarint"]("shield_wz_map") > 0 then
	-- don't reset it
else
	Engine[@"exec"](Engine[@"getprimarycontroller"](), "set shield_wz_map 0")
end

Engine[@"exec"](Engine[@"getprimarycontroller"](), "readjson shield_bots_wz_lives lua bots_wz_lives uint64_t 1")
Engine[@"exec"](Engine[@"getprimarycontroller"](), "readjson shield_wz_uav lua wz_uav uint64_t 1")
Engine[@"exec"](Engine[@"getprimarycontroller"](), "readjson shield_bots_wz_difficulty lua bots_wz_difficulty uint64_t 1")

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

	if dvar_name == "shield_wz_map" then	
		if current_val == 0 then -- none
			Engine[@"exec"](Engine[@"getprimarycontroller"](), "set use_wz_escape 0")
			Engine[@"exec"](Engine[@"getprimarycontroller"](), "set use_wz_escape_alt 0")
		elseif current_val == 1 then -- alt
			Engine[@"exec"](Engine[@"getprimarycontroller"](), "set use_wz_escape 1")
			Engine[@"exec"](Engine[@"getprimarycontroller"](), "set use_wz_escape_alt 0")
		else -- night
			Engine[@"exec"](Engine[@"getprimarycontroller"](), "set use_wz_escape 0")
			Engine[@"exec"](Engine[@"getprimarycontroller"](), "set use_wz_escape_alt 1")
		end
	end

	if dvar_name == "shield_bots_wz_lives" then	
		Engine[@"exec"](Engine[@"getprimarycontroller"](), "writejson lua bots_wz_lives " .. dvar_val_new .. " uint64_t")
	end

	if dvar_name == "shield_wz_uav" then	
		Engine[@"exec"](Engine[@"getprimarycontroller"](), "writejson lua wz_uav " .. dvar_val_new .. " uint64_t")
	end

	if dvar_name == "shield_bots_wz_difficulty" then	
		Engine[@"exec"](Engine[@"getprimarycontroller"](), "writejson lua bots_wz_difficulty " .. dvar_val_new .. " uint64_t")
	end
end

---------------------------

-- slider
local function Enh_WidgetSelectorShieldFuncWZBots( f49_arg0, f49_arg1, f49_arg2 )
	return CoD.CraftActionSliderEnhShield
end

local function Enh_GetEditModeActionsShieldWZBots( f53_arg0, f53_arg1 )
	local shield_wz_bots_num = Engine[@"getmodel"]( Engine[@"getmodelforcontroller"]( f53_arg0 ), "shield_wz_bots_num" )

	if shield_wz_bots_num == nil then
		shield_wz_bots_num = Engine[@"createmodel"]( Engine[@"getmodelforcontroller"]( f53_arg0 ), "shield_wz_bots_num" )
	end
	
	shield_wz_bots_num:set(Engine[@"getdvarint"]("shield_wz_bots_num"))

	local f53_local0 = {}

	local f53_local4 = {}
	local f53_local5 = {
		actionName = @"shield/wz_bots_helper",
		widgetType = "slider",
		perControllerValueModel = "shield_wz_bots_num",
		lowValue = 0,
		highValue = 60
	}
	local f53_local6 = Engine[@"getmodelforcontroller"]( f53_arg0 )
	f53_local5.currentValue = 0
	f53_local4.models = f53_local5
	f53_local4.properties = {
		updateAction = function ( f60_arg0, f60_arg1, f60_arg2, f60_arg3 )
			local GetNum = math.floor((f53_local5.highValue - f53_local5.lowValue) * f60_arg2)

			Engine[@"setdvar"]("shield_wz_bots_num", GetNum)

			-- set more engine limit
			if GetNum >= 1 and Engine[@"currentsessionmode"]() == Enum[@"emodes"][@"mode_warzone"] then
				Engine[@"setdvar"]("shield_com_clients", GetNum + 10)
				Engine[@"setlobbymaxclients"](Enum[@"lobbytype"][@"lobby_type_game"], GetNum + 10) 
				Engine[@"setlobbymaxclients"](Enum[@"lobbytype"][@"lobby_type_private"], GetNum + 10)
				Engine[@"setlobbymaxclients"](Engine[@"getprimarycontroller"](), GetNum + 10)
				Dvar[@"hash_4FF45B41C6046F8"]:set(GetNum + 10)
				Engine[@"setmodelvalue"](Engine[@"createmodel"]( Engine[@"createmodel"]( Engine[@"getglobalmodel"](), "PartyPrivacy" ), "maxPlayers" ), GetNum + 10)
			else
				Engine[@"setdvar"]("shield_com_clients", 0)
				Engine[@"setlobbymaxclients"](Enum[@"lobbytype"][@"lobby_type_game"], 0) 
				Engine[@"setlobbymaxclients"](Enum[@"lobbytype"][@"lobby_type_private"], 0)
				Engine[@"setlobbymaxclients"](Engine[@"getprimarycontroller"](), 0)
				Dvar[@"hash_4FF45B41C6046F8"]:set(0)
				Engine[@"setmodelvalue"](Engine[@"createmodel"]( Engine[@"createmodel"]( Engine[@"getglobalmodel"](), "PartyPrivacy" ), "maxPlayers" ), 0)
			end
		end
	}

	table.insert( f53_local0, f53_local4 )

	return f53_local0
end

DataSources.EnhActionsShieldPCWZBots = DataSourceHelpers.ListSetup( "PC.CraftActionsPCWZBots", function ( f50_arg0, f50_arg1 )
	return Enh_GetEditModeActionsShieldWZBots( f50_arg0, f50_arg1.menu )
end, false, {
	getWidgetTypeForItem = Enh_WidgetSelectorShieldFuncWZBots
} )

-- blackout's
DataSources.OptionalSettingsDataBlackout = DataSourceHelpers.ListSetup( "OptionalSettingsDataBlackout", function ( f138_arg0 )
	local Settings = {}

	-- !! decs is not needed here!!!, nvm

	table.insert( Settings, CoD.OptionsUtility.CreateDvarSettings( f138_arg0, @"shield/use_wz_alts", @"shield/use_wz_alts_desc", "shield_wz_map", "shield_wz_map", {
		{
			option = Engine[@"hash_4F9F1239CFD921FE"]( @"shield/use_wz_def" ),
			value = 0,
			default = true
		},
		{
			option = Engine[@"hash_4F9F1239CFD921FE"]( @"shield/use_wz_alts_other" ),
			value = 1
		},
		{
			option = Engine[@"hash_4F9F1239CFD921FE"]( @"shield/use_wz_alts_other_night" ),
			value = 2
		}
	}, nil, OnExtraDataChange ) )

	table.insert( Settings, CoD.OptionsUtility.CreateDvarSettings( f138_arg0, @"shield/bots_difficulty", @"shield/bots_difficulty_desc", "shield_bots_wz_difficulty", "shield_bots_wz_difficulty", {
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
	}, nil, OnExtraDataChange ) )

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

	table.insert( Settings, CoD.OptionsUtility.CreateDvarSettings( f138_arg0, @"shield/bots_wz_lives", @"shield/bots_wz_lives_desc", "shield_bots_wz_lives", "shield_bots_wz_lives", {
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

	table.insert( Settings, CoD.OptionsUtility.CreateDvarSettings( f138_arg0, @"shield/wz_uav", @"shield/wz_uav_desc", "shield_wz_uav", "shield_wz_uav", {
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

-- blackout options
CoD.Shield_Blackout_SettingsPopup = InheritFrom( CoD.Menu )
LUI.createMenu.Shield_Blackout_SettingsPopup = function ( f1_arg0, f1_arg1 )
	local self = CoD.Menu.NewForUIEditor( "Shield_Blackout_SettingsPopup", f1_arg0 )
	local f1_local1 = self
	self:setClass( CoD.Shield_Blackout_SettingsPopup )
	self.soundSet = "none"
	self:setOwner( f1_arg0 )
	self:setLeftRight( 0, 1, 0, 0 )
	self:setTopBottom( 0, 1, 0, 0 )
	self:playSound( "menu_open", f1_arg0 )
	self.anyChildUsesUpdateState = true
	f1_local1:addElementToPendingUpdateStateList( self )
	
	local CommomCenteredPopup = CoD.CommonCenteredPopup.new( f1_local1, f1_arg0, 0, 1, 0, 0, 0, 1, 0, 0 )
	CommomCenteredPopup.TitleText:setText("Blackout Settings")
	CommomCenteredPopup.HeaderBackground:setAlpha( 0 )
	CommomCenteredPopup.HeaderTopBar:setAlpha( 0 )
	CommomCenteredPopup.HeaderBottomBar:setAlpha( 0 )
	self:addElement( CommomCenteredPopup )
	self.CommomCenteredPopup = CommomCenteredPopup
	
	local MiscSettingsList = LUI.UIList.new( f1_local1, f1_arg0, 3, 3, nil, false, false, false, false )
	MiscSettingsList:setLeftRight( 0.5, 0.5, -250, 250 )
	MiscSettingsList:setTopBottom( 0.5, 0.5, -380 + 126, -320 + 126 )
	MiscSettingsList:setAutoScaleContent( true )
	MiscSettingsList:setVerticalCount(10)
	MiscSettingsList:setHorizontalCount(1)
	MiscSettingsList:setWidgetType( CoD.CustomGames_SettingSliderNoCustom )
	MiscSettingsList:setAlignment( Enum[@"luialignment"][@"lui_alignment_left"] )
	MiscSettingsList:setDataSource( "OptionalSettingsDataBlackout" )
	self:addElement( MiscSettingsList )
	self.MiscSettingsList = MiscSettingsList

	if Engine[@"getdvarint"]("shield_ui_color") == 0 then
		MiscSettingsList:setRGB(0, 1, 1)
	elseif Engine[@"getdvarint"]("shield_ui_color") == 1 then
		MiscSettingsList:setRGB(1, 0, 0)
	elseif Engine[@"getdvarint"]("shield_ui_color") == 2 then
		MiscSettingsList:setRGB(0, 1, 0)
	end
	
	local SettingDescription = LUI.UIText.new( 0.5, 0.5, -250, 250, 0.55, 0.55, -284 + 180, -263 + 180 )
	SettingDescription:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )
	SettingDescription:setTTF( "notosans_regular" )
	SettingDescription:setAlignment( Enum[@"luialignment"][@"lui_alignment_left"] )
	SettingDescription:setAlignment( Enum[@"luialignment"][@"lui_alignment_top"] )
	self:addElement( SettingDescription )
	self.SettingDescription = SettingDescription

	local TipSec = LUI.UIText.new( 0.5, 0.5, -250, 250, 0.55, 0.55, -284 + 300, -263 + 300 )
	TipSec:setText("It is better to use public matches instead of custom games (deploy button for public match)")
	TipSec:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )
	TipSec:setTTF( "notosans_regular" )
	TipSec:setAlignment( Enum[@"luialignment"][@"lui_alignment_left"] )
	TipSec:setAlignment( Enum[@"luialignment"][@"lui_alignment_top"] )
	self:addElement( TipSec )
	self.TipSec = TipSec

	local actionsListPCEnh = LUI.UIList.new( f1_local1, f1_arg0, 0, 0, nil, false, false, false, false )
	actionsListPCEnh:setLeftRight( 0.50, 0.50, -95.52, 69.48 )
	actionsListPCEnh:setTopBottom( 0.50, 0.50, 268.77 - 300, 368.77 - 300 )
	actionsListPCEnh:setAlpha( 1 )
	actionsListPCEnh:setWidgetType( CoD.CraftActionHeaderEnhShield )
	actionsListPCEnh:setVerticalCount( 15 )
	actionsListPCEnh:setSpacing( 0 )
	actionsListPCEnh:setDataSource( "EnhActionsShieldPCWZBots" )
	self:addElement( actionsListPCEnh )
	self.actionsListPCEnh = actionsListPCEnh

	actionsListPCEnh.id = "actionsListPCEnh"

	local BlackoutRulesSettings = CoD.DirectorSelectButtonMiniInternal.new( f1_local1, f1_arg0, 0.50, 0.50, -178.50, 131.50, 0.50, 0.50, 329.01, 379.01 )
	
	BlackoutRulesSettings.MiddleText:setTTF( "notosans_bold" )
	BlackoutRulesSettings.MiddleText:setText("Rules Settings")

	BlackoutRulesSettings.MiddleTextFocus:setText("Rules Settings")
	BlackoutRulesSettings.MiddleTextFocus:setTTF( "notosans_bold" )
	
	BlackoutRulesSettings:linkToElementModel( self, nil, false, function ( model )
		BlackoutRulesSettings:setModel( model, f1_arg1 )
	end )
	self:addElement( BlackoutRulesSettings )
	self.BlackoutRulesSettings = BlackoutRulesSettings

	--LUI_DebugElement(f1_local1, f1_arg0, self, BlackoutRulesSettings, "BlackoutRulesSettings", 10)

	f1_local1:AddButtonCallbackFunction( BlackoutRulesSettings, f1_arg0, Enum[@"luibutton"][@"lui_key_xba_pscross"], "ui_confirm", function ( element, menu, controller, model )
		PlaySoundAlias( "uin_paint_image_flip_toggle" )
		CoD.EnhPrintInfo("BlackoutRulesSettings")
		
		OpenOverlay( self, "Shield_Blackout_Rules_SettingsPopup", controller )

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

	BlackoutRulesSettings.id = "BlackoutRulesSettings"
	
	SettingDescription:linkToElementModel( MiscSettingsList, "desc", true, function ( model )
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

	CoD.EnhPrintInfo("Called", "Shield_Blackout_SettingsPopup")

	return self
end

CoD.Shield_Blackout_SettingsPopup.__resetProperties = function ( f13_arg0 )
	f13_arg0.MiscSettingsList:completeAnimation()
	f13_arg0.SettingDescription:completeAnimation()
	f13_arg0.MiscSettingsList:setLeftRight( 0.5, 0.5, -250, 250 )
	f13_arg0.SettingDescription:setLeftRight( 0.5, 0.5, -250, 250 )
end

CoD.Shield_Blackout_SettingsPopup.__clipsPerState = {
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

CoD.Shield_Blackout_SettingsPopup.__onClose = function ( f16_arg0 )
	f16_arg0.SettingDescription:close()
	f16_arg0.BlackoutRulesSettings:close()
	f16_arg0.TipSec:close()
	f16_arg0.CommomCenteredPopup:close()
	f16_arg0.MiscSettingsList:close()
	f16_arg0.actionsListPCEnh:close()
end