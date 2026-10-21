--[[
		.\hksc.exe ".\Lua\BlackMarketSettings.Lua" -o "C:\Program Files (x86)\Call of Duty Black Ops 4\project-bo4\mods\T8ShieldSupport\Lua\BlackMarketSettings.luac"
]]

---------------------------

CoD.ShieldInitLuaFile()

---------------------------

--[[
	The black market settings: how cases and tiers are earned and what the black market charges. Each is a key
	under "blackmarket" in the config, read by the client as it needs it (match_reward.cpp, bdLootGeneration.cpp),
	so a change counts at once, but for the season. Each setting: its dvar here, its key and type there, what it
	is when the config has nothing, and its choices with the value each one writes.
]]
local BlackMarketSettings = {
	{
		dvar = "shield_bm_rewards", key = "match_rewards", type = "bool", default = 1,
		name = @"shield/bm_rewards", desc = @"shield/bm_rewards_desc",
		choices = { { "Off", 0 }, { "On", 1 } }
	},
	{
		dvar = "shield_bm_case_minutes", key = "case_minutes", type = "int32_t", default = 60,
		name = @"shield/bm_case_minutes", desc = @"shield/bm_case_minutes_desc",
		choices = { { "Off", 0 }, { "30 Minutes", 30 }, { "1 Hour", 60 }, { "90 Minutes", 90 }, { "2 Hours", 120 } }
	},
	{
		dvar = "shield_bm_cases_per_match", key = "cases_per_match", type = "int32_t", default = 0,
		name = @"shield/bm_cases_per_match", desc = @"shield/bm_cases_per_match_desc",
		choices = { { "Off", 0 }, { "1", 1 }, { "2", 2 }, { "3", 3 }, { "5", 5 } }
	},
	{
		dvar = "shield_bm_tier_per_match", key = "tier_per_match", type = "bool", default = 1,
		name = @"shield/bm_tier_per_match", desc = @"shield/bm_tier_per_match_desc",
		choices = { { "Off", 0 }, { "On", 1 } }
	},
	{
		dvar = "shield_bm_season", key = "season_active", type = "int32_t", default = 8,
		name = @"shield/bm_season", desc = @"shield/bm_season_desc",
		-- 5 and 7 are the second streams of Spectre Rising and Apocalypse Z
		choices = {
			{ "First Strike", 1 }, { "Absolute Zero", 2 }, { "Grand Heist", 3 }, { "Spectre Rising", 4 },
			{ "Spectre Rising II", 5 }, { "Apocalypse Z", 6 }, { "Apocalypse Z II", 7 }, { "Dark Divide", 8 }
		}
	},
	{
		dvar = "shield_bm_season_rewards", key = "season_grants_rewards", type = "bool", default = 1,
		name = @"shield/bm_season_rewards", desc = @"shield/bm_season_rewards_desc",
		choices = { { "Off", 0 }, { "On", 1 } }
	},
	{
		dvar = "shield_bm_consume", key = "consume_cost", type = "bool", default = 1,
		name = @"shield/bm_consume", desc = @"shield/bm_consume_desc",
		choices = { { "Free", 0 }, { "On", 1 } }
	},
	{
		dvar = "shield_bm_bribe_crates", key = "bribe_bonus_crates", type = "int32_t", default = 5,
		name = @"shield/bm_bribe_crates", desc = @"shield/bm_bribe_crates_desc",
		choices = { { "Off", 0 }, { "1", 1 }, { "3", 3 }, { "5", 5 }, { "10", 10 } }
	}
}

--[[
	The gunsmith asks the loot season what it may show, as the live game grew: the row of personalize slots from
	season 4, death effects and accessories on a base weapon from season 5 (Grand Heist). With an earlier season
	picked here they were gone. The season only picks the black market's pass, so the gunsmith is the last one's.
	The game's file makes its table anew when it loads, which can be after this one: ReloadOverrides.lua does it again.
]]
CoD.BlackMarketSeasonReload = function()
	if CoD.BlackMarketUtility then
		CoD.BlackMarketUtility.IsCurrentLootSeasonAtLeast = function ( season )
			return true
		end
	end
end

CoD.BlackMarketSeasonReload()

-- what is in the config now
for _, setting in ipairs( BlackMarketSettings ) do
	Engine[@"exec"]( Engine[@"getprimarycontroller"](), "readjson " .. setting.dvar .. " blackmarket " .. setting.key .. " " .. setting.type .. " " .. setting.default )
end

-- a choice was made: the dvar, and the config the client reads
local function OnBlackMarketSettingChange( f137_arg0, f137_arg1, f137_arg2, f137_arg3, f137_arg4 )
	local dvar_name = f137_arg3
	local current_val = f137_arg1.value
	CoD.OptionsUtility.UpdateInfoModels( f137_arg1 )

	if current_val == Engine[@"getdvarint"]( dvar_name ) then
		return
	end

	Engine[@"setdvar"]( dvar_name, current_val )

	for _, setting in ipairs( BlackMarketSettings ) do
		if setting.dvar == dvar_name then
			local value = tostring( current_val )

			if setting.type == "bool" then
				value = current_val == 1 and "true" or "false"
			end

			Engine[@"exec"]( Engine[@"getprimarycontroller"](), "writejson blackmarket " .. setting.key .. " " .. value .. " " .. setting.type )
		end
	end
end

DataSources.ShieldBlackMarketSettings = DataSourceHelpers.ListSetup( "ShieldBlackMarketSettings", function ( f138_arg0 )
	local data = {}

	for _, setting in ipairs( BlackMarketSettings ) do
		local options = {}

		for _, choice in ipairs( setting.choices ) do
			table.insert( options, {
				option = choice[1],
				value = choice[2],
				default = choice[2] == setting.default
			} )
		end

		table.insert( data, CoD.OptionsUtility.CreateDvarSettings( f138_arg0, setting.name, setting.desc, setting.dvar, setting.dvar, options, nil, OnBlackMarketSettingChange ) )
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

-- the menu of the black market settings: as the other settings menus, see CoD.ShieldSettingsFrame of ShieldOptions.lua
CoD.Shield_BlackMarket_SettingsPopup = InheritFrom( CoD.Menu )
LUI.createMenu.Shield_BlackMarket_SettingsPopup = function ( f1_arg0, f1_arg1 )
	local self = CoD.Menu.NewForUIEditor( "Shield_BlackMarket_SettingsPopup", f1_arg0 )
	local f1_local1 = self
	self:setClass( CoD.Shield_BlackMarket_SettingsPopup )
	self.soundSet = "none"
	self:setOwner( f1_arg0 )
	self:setLeftRight( 0, 1, 0, 0 )
	self:setTopBottom( 0, 1, 0, 0 )
	self:playSound( "menu_open", f1_arg0 )
	self.anyChildUsesUpdateState = true
	f1_local1:addElementToPendingUpdateStateList( self )

	local CommomCenteredPopup = CoD.ShieldSettingsFrame.new( f1_local1, f1_arg0, {
		title = "Black Market",
		caption = "HOW CASES AND TIERS ARE EARNED",
		color = { r = 1, g = 0.78, b = 0.2 },
		rows = #BlackMarketSettings
	} )
	self:addElement( CommomCenteredPopup )
	self.CommomCenteredPopup = CommomCenteredPopup

	local BlackMarketSettingsList = LUI.UIList.new( f1_local1, f1_arg0, 3, 3, nil, false, false, false, false )
	BlackMarketSettingsList:setLeftRight( 0.5, 0.5, CoD.ShieldSettingsFrame.LIST_LEFT, CoD.ShieldSettingsFrame.LIST_RIGHT )
	BlackMarketSettingsList:setTopBottom( 0.5, 0.5, CommomCenteredPopup.listTop, CommomCenteredPopup.listTop + CommomCenteredPopup.listHeight )
	BlackMarketSettingsList:setAutoScaleContent( true )
	BlackMarketSettingsList:setVerticalCount( #BlackMarketSettings )
	BlackMarketSettingsList:setHorizontalCount( 1 )
	BlackMarketSettingsList:setWidgetType( CoD.CustomGames_SettingSliderNoCustom )
	BlackMarketSettingsList:setAlignment( Enum[@"luialignment"][@"lui_alignment_left"] )
	BlackMarketSettingsList:setDataSource( "ShieldBlackMarketSettings" )
	self:addElement( BlackMarketSettingsList )
	self.BlackMarketSettingsList = BlackMarketSettingsList

	if Engine[@"getdvarint"]("shield_ui_color") == 0 then
		BlackMarketSettingsList:setRGB(0, 1, 1)
	elseif Engine[@"getdvarint"]("shield_ui_color") == 1 then
		BlackMarketSettingsList:setRGB(1, 0, 0)
	elseif Engine[@"getdvarint"]("shield_ui_color") == 2 then
		BlackMarketSettingsList:setRGB(0, 1, 0)
	end

	local SettingDescription = LUI.UIText.new( 0.5, 0.5, CoD.ShieldSettingsFrame.RIGHT_LEFT, CoD.ShieldSettingsFrame.RIGHT_RIGHT, 0.5, 0.5, CommomCenteredPopup.descTop, CommomCenteredPopup.descTop + 21 )
	SettingDescription:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )
	SettingDescription:setTTF( "notosans_regular" )
	SettingDescription:setAlignment( Enum[@"luialignment"][@"lui_alignment_left"] )
	SettingDescription:setAlignment( Enum[@"luialignment"][@"lui_alignment_top"] )
	self:addElement( SettingDescription )
	self.SettingDescription = SettingDescription

	SettingDescription:linkToElementModel( BlackMarketSettingsList, "desc", true, function ( model )
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
	BlackMarketSettingsList.id = "BlackMarketSettingsList"
	self:processEvent( {
		name = "menu_loaded",
		controller = f1_arg0
	} )
	self.__defaultFocus = BlackMarketSettingsList
	if CoD.isPC and (IsKeyboard( f1_arg0 ) or self.ignoreCursor) then
		self:restoreState( f1_arg0 )
	end
	LUI.OverrideFunction_CallOriginalSecond( self, "close", self.__onClose )
	if PostLoadFunc then
		PostLoadFunc( self, f1_arg0 )
	end

	CoD.EnhPrintInfo("Called", "Shield's Black Market Settings Menu")

	return self
end

CoD.Shield_BlackMarket_SettingsPopup.__resetProperties = function ( f13_arg0 )
	f13_arg0.BlackMarketSettingsList:completeAnimation()
	f13_arg0.BlackMarketSettingsList:setLeftRight( 0.5, 0.5, CoD.ShieldSettingsFrame.LIST_LEFT, CoD.ShieldSettingsFrame.LIST_RIGHT )
end

CoD.Shield_BlackMarket_SettingsPopup.__clipsPerState = {
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
			f15_arg0.BlackMarketSettingsList:completeAnimation()
			f15_arg0.BlackMarketSettingsList:setLeftRight( 0.5, 0.5, CoD.ShieldSettingsFrame.LIST_LEFT, CoD.ShieldSettingsFrame.LIST_RIGHT_KBM )
			f15_arg0.clipFinished( f15_arg0.BlackMarketSettingsList )
		end
	}
}

CoD.Shield_BlackMarket_SettingsPopup.__onClose = function ( f16_arg0 )
	f16_arg0.SettingDescription:close()
	f16_arg0.CommomCenteredPopup:close()
	f16_arg0.BlackMarketSettingsList:close()
end
