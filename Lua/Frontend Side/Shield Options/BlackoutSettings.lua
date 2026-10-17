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

-- the bot count only exists once the slider moved: the scripts must not read a default then
if Engine[@"getdvarint"]("shield_wz_bots_num") > 0 then
	-- don't reset it
else
	Engine[@"exec"](Engine[@"getprimarycontroller"](), "set shield_wz_bots_num 0")
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

--[[
	The menu of Blackout, in the frame of the settings menus (CoD.ShieldSettingsFrame): left the settings
	and under them how many bots there are, right what the one in focus does, a tip, and the game rules.
]]
local BLACKOUT_ROWS = 5
local BLACKOUT_LIST_HEIGHT = BLACKOUT_ROWS * 60 + ( BLACKOUT_ROWS - 1 ) * 3
local BLACKOUT_SLIDER_TOP = BLACKOUT_LIST_HEIGHT + 48

-- words of the menu, placed from the middle of the screen
local function BlackoutText( left, right, top, size, font, r, g, b )
	local text = LUI.UIText.new( 0.5, 0.5, left, right, 0.5, 0.5, top, top + size )
	text:setRGB( r, g, b )
	text:setTTF( font )
	text:setAlignment( Enum[@"luialignment"][@"lui_alignment_left"] )
	text:setAlignment( Enum[@"luialignment"][@"lui_alignment_top"] )
	return text
end

-- the small grey words over a part
local function BlackoutCaption( left, right, top, words )
	local text = BlackoutText( left, right, top, 15, "ttmussels_regular", 0.55, 0.55, 0.55 )
	text:setLetterSpacing( 2 )
	text:setText( words )
	return text
end

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

	-- the words of the menu, closed with it
	self.Parts = {}

	local function Add( element )
		self:addElement( element )
		table.insert( self.Parts, element )
		return element
	end

	local CommomCenteredPopup = CoD.ShieldSettingsFrame.new( f1_local1, f1_arg0, {
		title = "Blackout",
		caption = "BOTS, MAP AND RULES OF THE MATCH",
		color = { r = 1, g = 0.62, b = 0.2 },
		listHeight = BLACKOUT_SLIDER_TOP + 60,
		extra = 3
	} )
	self:addElement( CommomCenteredPopup )
	self.CommomCenteredPopup = CommomCenteredPopup

	local listTop = CommomCenteredPopup.listTop

	local BlackoutSettingsList = LUI.UIList.new( f1_local1, f1_arg0, 3, 3, nil, false, false, false, false )
	BlackoutSettingsList:setLeftRight( 0.5, 0.5, CoD.ShieldSettingsFrame.LIST_LEFT, CoD.ShieldSettingsFrame.LIST_RIGHT )
	BlackoutSettingsList:setTopBottom( 0.5, 0.5, listTop, listTop + BLACKOUT_LIST_HEIGHT )
	BlackoutSettingsList:setAutoScaleContent( true )
	BlackoutSettingsList:setVerticalCount( BLACKOUT_ROWS )
	BlackoutSettingsList:setHorizontalCount( 1 )
	BlackoutSettingsList:setWidgetType( CoD.CustomGames_SettingSliderNoCustom )
	BlackoutSettingsList:setAlignment( Enum[@"luialignment"][@"lui_alignment_left"] )
	BlackoutSettingsList:setDataSource( "OptionalSettingsDataBlackout" )
	self:addElement( BlackoutSettingsList )
	self.BlackoutSettingsList = BlackoutSettingsList

	if Engine[@"getdvarint"]("shield_ui_color") == 0 then
		BlackoutSettingsList:setRGB(0, 1, 1)
	elseif Engine[@"getdvarint"]("shield_ui_color") == 1 then
		BlackoutSettingsList:setRGB(1, 0, 0)
	elseif Engine[@"getdvarint"]("shield_ui_color") == 2 then
		BlackoutSettingsList:setRGB(0, 1, 0)
	end

	-- how many bots: a list of one slider, 375 by 60
	Add( BlackoutCaption( CoD.ShieldSettingsFrame.LIST_LEFT, CoD.ShieldSettingsFrame.LIST_RIGHT, listTop + BLACKOUT_SLIDER_TOP - 24, "BOTS IN THE MATCH" ) )

	local actionsListPCEnh = LUI.UIList.new( f1_local1, f1_arg0, 0, 0, nil, false, false, false, false )
	actionsListPCEnh:setLeftRight( 0.5, 0.5, CoD.ShieldSettingsFrame.LIST_LEFT, CoD.ShieldSettingsFrame.LIST_LEFT + 375 )
	actionsListPCEnh:setTopBottom( 0.5, 0.5, listTop + BLACKOUT_SLIDER_TOP, listTop + BLACKOUT_SLIDER_TOP + 60 )
	actionsListPCEnh:setAlpha( 1 )
	actionsListPCEnh:setWidgetType( CoD.CraftActionHeaderEnhShield )
	actionsListPCEnh:setVerticalCount( 15 )
	actionsListPCEnh:setSpacing( 0 )
	actionsListPCEnh:setDataSource( "EnhActionsShieldPCWZBots" )
	self:addElement( actionsListPCEnh )
	self.actionsListPCEnh = actionsListPCEnh

	actionsListPCEnh.id = "actionsListPCEnh"

	local SettingDescription = LUI.UIText.new( 0.5, 0.5, CoD.ShieldSettingsFrame.RIGHT_LEFT, CoD.ShieldSettingsFrame.RIGHT_RIGHT, 0.5, 0.5, CommomCenteredPopup.descTop, CommomCenteredPopup.descTop + 21 )
	SettingDescription:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )
	SettingDescription:setTTF( "notosans_regular" )
	SettingDescription:setAlignment( Enum[@"luialignment"][@"lui_alignment_left"] )
	SettingDescription:setAlignment( Enum[@"luialignment"][@"lui_alignment_top"] )
	self:addElement( SettingDescription )
	self.SettingDescription = SettingDescription

	SettingDescription:linkToElementModel( BlackoutSettingsList, "desc", true, function ( model )
		local f7_local0 = model:get()
		if f7_local0 ~= nil then
			SettingDescription:setText( Engine[@"hash_4F9F1239CFD921FE"]( f7_local0 ) )
		end
	end )

	-- under the description: a tip, and the rules of the match
	local extraTop = CommomCenteredPopup.extraTop

	Add( BlackoutCaption( CoD.ShieldSettingsFrame.RIGHT_LEFT, CoD.ShieldSettingsFrame.RIGHT_RIGHT, extraTop + 20, "TIP" ) )

	local Tip = Add( BlackoutText( CoD.ShieldSettingsFrame.RIGHT_LEFT, CoD.ShieldSettingsFrame.RIGHT_RIGHT, extraTop + 42, 18, "notosans_regular", 0.62, 0.62, 0.62 ) )
	Tip:setText( "Public matches play better than custom games: start one with the deploy button." )

	local BlackoutRulesSettings = CoD.DirectorSelectButtonMiniInternal.new( f1_local1, f1_arg0, 0.5, 0.5, CoD.ShieldSettingsFrame.RIGHT_LEFT, CoD.ShieldSettingsFrame.RIGHT_RIGHT, 0.5, 0.5, extraTop + 124, extraTop + 174 )
	BlackoutRulesSettings.MiddleText:setText( "GAME RULES" )
	BlackoutRulesSettings.MiddleTextFocus:setText( "GAME RULES" )

	BlackoutRulesSettings:mergeStateConditions( {
		{
			stateName = "Locked",
			condition = function ( menu, element, event )
				return AlwaysFalse()
			end
		}
	} )

	BlackoutRulesSettings:linkToElementModel( self, nil, false, function ( model )
		BlackoutRulesSettings:setModel( model, f1_arg1 )
	end )
	self:addElement( BlackoutRulesSettings )
	self.BlackoutRulesSettings = BlackoutRulesSettings

	f1_local1:AddButtonCallbackFunction( BlackoutRulesSettings, f1_arg0, Enum[@"luibutton"][@"lui_key_xba_pscross"], "ui_confirm", function ( element, menu, controller, model )
		PlaySoundAlias( "uin_paint_image_flip_toggle" )
		CoD.EnhPrintInfo("BlackoutRulesSettings")

		OpenOverlay( self, "Shield_Blackout_Rules_SettingsPopup", controller )
		return true
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
	BlackoutSettingsList.id = "BlackoutSettingsList"
	self:processEvent( {
		name = "menu_loaded",
		controller = f1_arg0
	} )
	self.__defaultFocus = BlackoutSettingsList
	if CoD.isPC and (IsKeyboard( f1_arg0 ) or self.ignoreCursor) then
		self:restoreState( f1_arg0 )
	end
	LUI.OverrideFunction_CallOriginalSecond( self, "close", self.__onClose )
	if PostLoadFunc then
		PostLoadFunc( self, f1_arg0 )
	end

	CoD.EnhPrintInfo("Called", "Shield_Blackout_SettingsPopup")

	return self
end

CoD.Shield_Blackout_SettingsPopup.__resetProperties = function ( f13_arg0 )
	f13_arg0.BlackoutSettingsList:completeAnimation()
	f13_arg0.BlackoutSettingsList:setLeftRight( 0.5, 0.5, CoD.ShieldSettingsFrame.LIST_LEFT, CoD.ShieldSettingsFrame.LIST_RIGHT )
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
			f15_arg0:setupElementClipCounter( 1 )
			f15_arg0.BlackoutSettingsList:completeAnimation()
			f15_arg0.BlackoutSettingsList:setLeftRight( 0.5, 0.5, CoD.ShieldSettingsFrame.LIST_LEFT, CoD.ShieldSettingsFrame.LIST_RIGHT_KBM )
			f15_arg0.clipFinished( f15_arg0.BlackoutSettingsList )
		end
	}
}

CoD.Shield_Blackout_SettingsPopup.__onClose = function ( f16_arg0 )
	f16_arg0.SettingDescription:close()
	f16_arg0.BlackoutRulesSettings:close()
	f16_arg0.CommomCenteredPopup:close()
	f16_arg0.BlackoutSettingsList:close()
	f16_arg0.actionsListPCEnh:close()

	for _, element in ipairs( f16_arg0.Parts ) do
		element:close()
	end
end
