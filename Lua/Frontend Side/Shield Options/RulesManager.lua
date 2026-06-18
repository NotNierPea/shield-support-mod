--[[
		.\hksc.exe ".\Lua\RulesManager.Lua" -o "C:\Program Files (x86)\Call of Duty Black Ops 4\project-bo4\mods\T8ShieldSupport\Lua\RulesManager.luac"
]]

---------------------------

CoD.ShieldInitLuaFile()

---------------------------

-- dvars
Engine[@"setdvar"]("shield_selected_saved_rule", "")
Engine[@"setdvar"]("shield_selected_saved_rule_name", "")

-- vars
local shield_rules = {}

---------------------------

local function ShieldSaveGameRules()
	local Name_To_Use = Engine[@"getdvarstring"]("shield_selected_saved_rule_name")
	if Name_To_Use == "" then
		Name_To_Use = "Unnamed Rule"
	end

	local SETTINGS_PER_CHUNK = 30
	local allSettings = {}

	if not IsWarzone() then
		-- preload the datasources first!
		CoD.OptionsUtility.PrepareCustomGameOptionCategoriesZMGeneral()
		CoD.OptionsUtility.PrepareCustomGameOptionCategoriesZMSystems()
		CoD.OptionsUtility.PrepareCustomGameOptionCategoriesZMWeapons()
		CoD.OptionsUtility.PrepareCustomGameOptionCategoriesZMEnemies()
		CoD.OptionsUtility.PrepareCustomGameOptionCategoriesZMPlayer()

		CoD.OptionsUtility.PrepareCustomGameOptionCategoriesWeaponScopeRestriction()
		CoD.OptionsUtility.PrepareCustomGameOptionCategoriesWeaponAttachmentRestriction()
		CoD.OptionsUtility.PrepareCustomGameOptionCategoriesWildcardRestriction()
		CoD.OptionsUtility.PrepareCustomGameOptionCategoriesPerkRestriction()
		CoD.OptionsUtility.PrepareCustomGameOptionCategoriesEquipmentRestriction()
		CoD.OptionsUtility.PrepareCustomGameOptionCategoriesGearRestriction()
		CoD.OptionsUtility.PrepareCustomGameOptionCategoriesAttachmentRestriction()
		CoD.OptionsUtility.PrepareCustomGameOptionCategoriesWeaponRestriction()
		CoD.OptionsUtility.PrepareCustomGameOptionRestrictionGameOptions()
		CoD.OptionsUtility.PrepareCustomGameOptionCategoriesSpecialist()
		CoD.OptionsUtility.PrepareCustomGameOptionCategoriesGametype()

		-- Collect all settings first
		for _, GameOptions in pairs(CoD.OptionsUtility.CustomGameOptions) do
			for _, Option in ipairs(GameOptions) do
				if Option.gameSettingListName then
					for _, GetOption in ipairs(Engine[@"hash_7A7E3CD65E63086F"](Option.gameSettingListName)) do
						local info = CoD.OptionsUtility.GetGameSettingsInfoFromTable(GetOption)
						local Setting_Name = info and info.setting
						if Setting_Name and Setting_Name ~= "" then
							local rawVal = Engine[@"getgametypesetting"](Setting_Name)
							local Setting_Value = tonumber(rawVal)
							if rawVal == nil then
								Setting_Value = -1
							end
							table.insert(allSettings, {name = Setting_Name, value = Setting_Value})
						end
					end
				end
			end
		end

		-- others
		local WinConds = CoD.OptionsUtility.GetGametypeWinConditionsTable( Engine[@"lobbygetgametype"]() )
		if WinConds then
			for _, GetOption in ipairs( WinConds ) do
				local info = CoD.OptionsUtility.GetGameSettingsInfo(GetOption)
				local Setting_Name = info and info.setting
				if Setting_Name and Setting_Name ~= "" then
					local rawVal = Engine[@"getgametypesetting"](Setting_Name)
					local Setting_Value = tonumber(rawVal)
					if rawVal == nil then
						Setting_Value = -1
					end
					table.insert(allSettings, {name = Setting_Name, value = Setting_Value})
				end
			end
		end

		local AdvsOptions = CoD.OptionsUtility.GetGametypeAdvancedOptionsTable( Engine[@"lobbygetgametype"]() )
		if AdvsOptions then
			for _, GetOption in ipairs( AdvsOptions ) do
				local info = CoD.OptionsUtility.GetGameSettingsInfo(GetOption)
				local Setting_Name = info and info.setting
				if Setting_Name and Setting_Name ~= "" then
					local rawVal = Engine[@"getgametypesetting"](Setting_Name)
					local Setting_Value = tonumber(rawVal)
					if rawVal == nil then
						Setting_Value = -1
					end
					table.insert(allSettings, {name = Setting_Name, value = Setting_Value})
				end
			end
		end

		local RosterOptions = CoD.PlayerRoleUtility.GetHeroList( Engine[@"currentsessionmode"]() )
		if RosterOptions then
			for _, Roster in ipairs( RosterOptions ) do
				if Roster.assetName ~= nil and Roster.bodyIndex ~= nil then
					local bodyName = tostring(Roster.assetName)
					local bodyIndex = Roster.bodyIndex
					local game_settings = Engine[@"getgametypesettings"]()
					
					-- in wz, they are nil
					if game_settings[@"maxuniquerolesperteam"][bodyIndex] ~= nil then
						local rawVal = game_settings[@"maxuniquerolesperteam"][bodyIndex]:get()
						local Setting_Value = tonumber(rawVal)
						if rawVal == nil then
							Setting_Value = -1
						end

						table.insert(allSettings, {name = bodyName, value = Setting_Value})
					end
				end
			end
		end
	else
		-- save wz settings
		for id, pair in ipairs( CoD.wz_settings_changed ) do
			local Setting_Name = tostring(pair.name)
			local Setting_Value = pair.value

			table.insert(allSettings, {name = Setting_Name, value = Setting_Value})
			CoD.EnhPrintInfo("Save gametype setting: " .. Setting_Name .. " with value " .. tostring(Setting_Value))
		end
	end

	-- Calculate number of chunks needed
	local totalSettings = #allSettings
	local numChunks = math.ceil(totalSettings / SETTINGS_PER_CHUNK)

	-- Send settings in chunks to the same file with multiple exec calls
	for chunkIndex = 1, numChunks do
		local Rules_Merged = ""
		local startIdx = (chunkIndex - 1) * SETTINGS_PER_CHUNK + 1
		local endIdx = math.min(chunkIndex * SETTINGS_PER_CHUNK, totalSettings)
		
		for i = startIdx, endIdx do
			local setting = allSettings[i]
			if Rules_Merged == "" then
				Rules_Merged = setting.name .. ", " .. setting.value
			else
				Rules_Merged = Rules_Merged .. ", " .. setting.name .. ", " .. setting.value
			end
		end
		
		-- Send multiple parts to the same command
		Engine[@"exec"](Engine[@"getprimarycontroller"](), 'rules_save_json ' .. '"' .. Name_To_Use .. '" "' .. Rules_Merged .. '"')
	end

	Engine[@"playsound"]("uin_map_vote")
	CoD.OverlayUtility.ShowToast("Mod Manager", "Update", "^2Saved Rule " .. Name_To_Use .. "!", "mm_icon")
end

local function ShieldLoadGameRules()
	local Name_To_Use = Engine[@"getdvarstring"]("shield_selected_saved_rule")
	if Name_To_Use == "" then
		Name_To_Use = "Unnamed Rule"
	end

	-- preload the datasources first!
	CoD.OptionsUtility.PrepareCustomGameOptionCategoriesZMGeneral()
	CoD.OptionsUtility.PrepareCustomGameOptionCategoriesZMSystems()
	CoD.OptionsUtility.PrepareCustomGameOptionCategoriesZMWeapons()
	CoD.OptionsUtility.PrepareCustomGameOptionCategoriesZMEnemies()
	CoD.OptionsUtility.PrepareCustomGameOptionCategoriesZMPlayer()

	CoD.OptionsUtility.PrepareCustomGameOptionCategoriesWeaponScopeRestriction()
	CoD.OptionsUtility.PrepareCustomGameOptionCategoriesWeaponAttachmentRestriction()
	CoD.OptionsUtility.PrepareCustomGameOptionCategoriesWildcardRestriction()
	CoD.OptionsUtility.PrepareCustomGameOptionCategoriesPerkRestriction()
	CoD.OptionsUtility.PrepareCustomGameOptionCategoriesEquipmentRestriction()
	CoD.OptionsUtility.PrepareCustomGameOptionCategoriesGearRestriction()
	CoD.OptionsUtility.PrepareCustomGameOptionCategoriesAttachmentRestriction()
	CoD.OptionsUtility.PrepareCustomGameOptionCategoriesWeaponRestriction()
	CoD.OptionsUtility.PrepareCustomGameOptionRestrictionGameOptions()
	CoD.OptionsUtility.PrepareCustomGameOptionCategoriesSpecialist()
	CoD.OptionsUtility.PrepareCustomGameOptionCategoriesGametype()

	Engine[@"playsound"]("uin_map_vote")
	Engine[@"exec"](Engine[@"getprimarycontroller"](), 'rules_load_json ' .. '"' .. Name_To_Use .. '"')
end

-- Store chunks until all are received
CoD.Shield.RulesLoadChunks = {}
CoD.Shield.RuleLoadCallback = function(event_name, event_table)
    local rule_name = event_table.rule_name or ""
    local rules_data = event_table.rules_data or ""
    local chunk_index = event_table.chunk_index or 1
    local total_chunks = event_table.total_chunks or 1
    local total_settings = event_table.total_settings or 0
    
    if rule_name == "" then
        return
    end
    
    -- Initialize chunk storage for this rule
    if CoD.Shield.RulesLoadChunks[rule_name] == nil then
        CoD.Shield.RulesLoadChunks[rule_name] = {
            chunks = {},
            total_chunks = total_chunks,
            total_settings = total_settings,
            received_chunks = 0
        }
    end
    
    local rule_data = CoD.Shield.RulesLoadChunks[rule_name]
    
    -- Store this chunk
    rule_data.chunks[chunk_index] = rules_data
    rule_data.received_chunks = rule_data.received_chunks + 1
    
    -- Check if all chunks received
    if rule_data.received_chunks >= rule_data.total_chunks then
        -- Merge all chunks in order
        local all_rules_data = ""
        for i = 1, rule_data.total_chunks do
            if rule_data.chunks[i] then
                if all_rules_data == "" then
                    all_rules_data = rule_data.chunks[i]
                else
                    all_rules_data = all_rules_data .. ", " .. rule_data.chunks[i]
                end
            end
        end
        
        -- Parse and apply settings
        local settings = {}
        local count = 0
        for token in string.gmatch(all_rules_data, "([^,]+)") do
            -- Manual trim: remove leading/trailing spaces
            local trimmed = token
            while string.sub(trimmed, 1, 1) == " " do
                trimmed = string.sub(trimmed, 2)
            end
            while string.sub(trimmed, -1) == " " do
                trimmed = string.sub(trimmed, 1, -2)
            end
            table.insert(settings, trimmed)
            count = count + 1
        end
        
        -- Apply settings in pairs (name, value)
        local applied_count = 0
        for i = 1, #settings, 2 do
            local setting_name = settings[i]
            local setting_value = settings[i + 1]
            
            if setting_name and setting_value then
                Engine[@"setgametypesetting"](setting_name, tonumber(setting_value) or setting_value)

				-- for wz
				if IsWarzone() then
					local hash_known_table = {
						["hash_0"] = @"hash_0",
						["hash_7695bdd7b20cdda"] = @"hash_7695bdd7b20cdda",
						["hash_5f842714fa80e5a9"] = @"hash_5f842714fa80e5a9",
						["hash_11b79ec2ffb886c8"] = @"hash_11b79ec2ffb886c8",
						["hash_30b11d064f146fcc"] = @"hash_30b11d064f146fcc",
						["hash_473fee16f796c84e"] = @"hash_473fee16f796c84e",
						["hash_697d65a68cc6c6f1"] = @"hash_697d65a68cc6c6f1",
						["hash_3a73deb0ca8c9aea"] = @"hash_3a73deb0ca8c9aea",
						["hash_3e2d2cf6b1cc6c68"] = @"hash_3e2d2cf6b1cc6c68",
						["hash_464afa49c60793b7"] = @"hash_464afa49c60793b7",
						["hash_701bac755292fab2"] = @"hash_701bac755292fab2",
						["hash_23e09b48546a7e3b"] = @"hash_23e09b48546a7e3b",
						["hash_78e459ad87509a46"] = @"hash_78e459ad87509a46",
						["hash_1d02e28ba907a343"] = @"hash_1d02e28ba907a343",
						["hash_53b5887dea69a320"] = @"hash_53b5887dea69a320",
						["hash_6fbf57e2af153e5f"] = @"hash_6fbf57e2af153e5f",
						["hash_50b1121aee76a7e4"] = @"hash_50b1121aee76a7e4",
						["hash_731aac1992af2669"] = @"hash_731aac1992af2669",
						["hash_6fb11b1e304d533c"] = @"hash_6fb11b1e304d533c",
						["hash_3624143624604b4c"] = @"hash_3624143624604b4c",
						["hash_76fb3219916a09f2"] = @"hash_76fb3219916a09f2",
						["hash_4d6cfd0b3ee4cc7d"] = @"hash_4d6cfd0b3ee4cc7d",
						["hash_44c7473eab6e5459"] = @"hash_44c7473eab6e5459",
						["hash_6cc7b012775d9662"] = @"hash_6cc7b012775d9662",
						["hash_2b2c167cf8889749"] = @"hash_2b2c167cf8889749",
						["hash_1bcb7e5d76212b76"] = @"hash_1bcb7e5d76212b76",
						["hash_232750b87390cbff"] = @"hash_232750b87390cbff",
						["hash_26f00de198472b81"] = @"hash_26f00de198472b81",

						-- characters
						["hash_d084b5063bb0c55"] = @"hash_d084b5063bb0c55",
						["hash_4c66b817adba935c"] = @"hash_4c66b817adba935c",
						["hash_2cd26947d8f311fa"] = @"hash_2cd26947d8f311fa",
						["hash_75370c9c920502fc"] = @"hash_75370c9c920502fc",
						["hash_26843909f5fdef20"] = @"hash_26843909f5fdef20",
						["hash_52d705a46da9e55f"] = @"hash_52d705a46da9e55f",
						["hash_7cf82cc41c0f0d5"] = @"hash_7cf82cc41c0f0d5",
						["hash_6b1ec01fa78af670"] = @"hash_6b1ec01fa78af670",
						["hash_34ea44c91776e52c"] = @"hash_34ea44c91776e52c",
						["hash_4f0a6d1e98cdbf81"] = @"hash_4f0a6d1e98cdbf81",
						["hash_183bcc0f6737224a"] = @"hash_183bcc0f6737224a",
						["hash_6fe34e77ba14d86f"] = @"hash_6fe34e77ba14d86f",
						["hash_3d719d86f2f3f14d"] = @"hash_3d719d86f2f3f14d",
						["hash_19c58d35b2ea8d15"] = @"hash_19c58d35b2ea8d15",
						["hash_2dfb36064be05f03"] = @"hash_2dfb36064be05f03",
						["hash_4547b7ecb49469f0"] = @"hash_4547b7ecb49469f0",
						["hash_7fc2867a4b8594bf"] = @"hash_7fc2867a4b8594bf",
						["hash_ff653cbb1438270"] = @"hash_ff653cbb1438270",
						["hash_7049c01d7ddf9b35"] = @"hash_7049c01d7ddf9b35",
						["hash_2b0f9caa00363ee8"] = @"hash_2b0f9caa00363ee8",
						["hash_20f3ff8fbb8d8295"] = @"hash_20f3ff8fbb8d8295",
						["hash_1d50c09e8021ab1"] = @"hash_1d50c09e8021ab1",
						["hash_47242abeaa29479b"] = @"hash_47242abeaa29479b",
						["hash_265bdda9362c5a35"] = @"hash_265bdda9362c5a35",
						["hash_2574d482086ec9d8"] = @"hash_2574d482086ec9d8",
						["hash_1d4c395693ce04fe"] = @"hash_1d4c395693ce04fe",
						["hash_19667f3338ed6b1f"] = @"hash_19667f3338ed6b1f",
						["hash_26186b4e5dc9bb6f"] = @"hash_26186b4e5dc9bb6f",
						["hash_5ea56d63c68b4396"] = @"hash_5ea56d63c68b4396",
						["hash_1ec2d38a40e97c55"] = @"hash_1ec2d38a40e97c55"
					}
					
					local dvar_name = "gametype_" .. setting_name
					local hash_only = string.gsub(setting_name, ".*%((.-)%)", "%1")
					local hash_try = "hash_" .. hash_only
					if hash_known_table[hash_try] then
						Engine[@"setgametypesetting"](hash_known_table[hash_try], setting_value)

						setting_name = hash_known_table[hash_try]
						dvar_name = "gametype_" .. hash_only
					end

					-- for wz
					table.insert(CoD.wz_settings_changed, {
						name = setting_name,
						name_setting = dvar_name,
						value = setting_value
					})
				end

                applied_count = applied_count + 1
            end

			local RosterOptions = CoD.PlayerRoleUtility.GetHeroList( Engine[@"currentsessionmode"]() )
			if RosterOptions then
				for _, Roster in ipairs( RosterOptions ) do
					local bodyName = tostring(Roster.assetName)
					local bodyIndex = Roster.bodyIndex
					local game_settings = Engine[@"getgametypesettings"]()

					if setting_name == bodyName then
						game_settings[@"maxuniquerolesperteam"][bodyIndex]:set(tonumber(setting_value) or setting_value)
					end
				end
			end
        end
        
        -- Clean up chunk storage
        CoD.Shield.RulesLoadChunks[rule_name] = nil
        
        -- Notify completion
		CoD.OverlayUtility.ShowToast("Mod Manager", "Update", "^2Loaded Rule " .. rule_name .. "!", "mm_icon")
    else

    end
end

CoD.Shield.RuleSaveCallback = function(event_name, event_table)
	-- Play a little sound
	Engine[@"playsound"]("uin_map_vote")

	-- Default values
	local message = event_name

	if event_table and event_table.message then
		if event_table and type(event_table) == "table" and type(event_table.message) == "string" then
			message = event_table.message
		end

		-- debug
		--CoD.EnhPrintInfo("Got Rule Toast", message)

		-- Show the toast
		if CoD.OverlayUtility.ShowToast then
			CoD.OverlayUtility.ShowToast("Mod Manager", "Update", message, "mm_icon")
		end
	end

	if CoD.Menu.ActiveRulesList ~= nil then
		Engine[@"exec"](Engine[@"getprimarycontroller"](), "rules_push")
		CoD.Menu.ActiveRulesList:setDataSource( "ShieldActiveRulesList" )
		CoD.Menu.ActiveRulesList:updateDataSource()
	end
end

CoD.Shield.RulesListUpdate = function(event_name, event_table)
	local raw = event_table.rules or ""
	shield_rules = {}

    for rule in string.gmatch(raw, "([^,]+)") do
        table.insert(shield_rules, rule)
    end

    --for i, name in ipairs(shield_rules) do
        --CoD.EnhPrintInfo("Found rule: " .. name)
    --end

	if CoD.Menu.ActiveRulesList ~= nil then
		CoD.Menu.ActiveRulesList:setDataSource( "ShieldActiveRulesList" )
		CoD.Menu.ActiveRulesList:updateDataSource()
	end
end

---------------------------

-- rules's
DataSources.ShieldActiveRulesList = DataSourceHelpers.ListSetup( "ShieldActiveRulesList", function ( f3_arg0, f3_arg1 )
	local InfoRules = {

	}

	for i, name in ipairs(shield_rules) do
		table.insert( InfoRules, {
			models = {
				RuleName = name,
			},
			properties = {
	
			}
		} )
    end

	return InfoRules
end, true )

DataSources.ShieldActiveRulesListEmpty = DataSourceHelpers.ListSetup( "ShieldActiveRulesListEmpty", function ( f3_arg0, f3_arg1 )
	local InfoRules = {

	}

	return InfoRules
end, true )

---------------------------

-- rules widget
CoD.ShieldActiveRuleRow = InheritFrom( LUI.UIElement )
CoD.ShieldActiveRuleRow.__defaultWidth = 1070
CoD.ShieldActiveRuleRow.__defaultHeight = 37
CoD.ShieldActiveRuleRow.new = function ( f1_arg0, f1_arg1, f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	local self = LUI.UIElement.new( f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	self:setClass( CoD.ShieldActiveRuleRow )
	self.id = "ShieldActiveRuleRow"
	self.soundSet = "default"
	f1_arg0:addElementToPendingUpdateStateList( self )
	
	local BlackBar = LUI.UIImage.new( 0, 1, 0, 0, 0, 1, 1, 1 )
	BlackBar:setRGB( 0.78, 0.78, 0.78 )
	BlackBar:setAlpha( 0.01 )
	self:addElement( BlackBar )
	self.BlackBar = BlackBar
	
	local RuleName = LUI.UIText.new( 0, 0, 15, 413, 0, 0, 6.5, 30.5 )
	RuleName:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )
	RuleName:setTTF( "ttmussels_regular" )
	RuleName:setLetterSpacing( 1 )
	RuleName:setAlignment( Enum[@"hash_67A5123B654282D2"][@"hash_558C8A85F2048829"] )
	RuleName:setAlignment( Enum[@"hash_67A5123B654282D2"][@"hash_3F41D595A2B0EDF3"] )
	self:addElement( RuleName )
	self.RuleName = RuleName
	
	self.RuleName:linkToElementModel( self, "RuleName", true, function ( model )
		local f5_local0 = model:get()
		if f5_local0 ~= nil then
			RuleName:setText(f5_local0)

			if Engine[@"getdvarstring"]("shield_selected_saved_rule") == f5_local0 then
				self:setRGB(1, 1, 0)
			else
				self:setRGB(1, 1, 1)
			end

			self.RuleName = RuleName
		end
	end )

	LUI.OverrideFunction_CallOriginalSecond( self, "close", self.__onClose )
	
	if PostLoadFunc then
		PostLoadFunc( self, f1_arg1, f1_arg0 )
	end
	
	return self
end

CoD.ShieldActiveRuleRow.__resetProperties = function ( f7_arg0 )
	f7_arg0.BlackBar:completeAnimation()
	f7_arg0.RuleName:completeAnimation()
	f7_arg0.BlackBar:setRGB( 0.78, 0.78, 0.78 )
	f7_arg0.BlackBar:setAlpha( 0.01 )
	f7_arg0.RuleName:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )
	f7_arg0.RuleName:setAlpha( 1 )
end

CoD.ShieldActiveRuleRow.__clipsPerState = {
	DefaultState = {
		DefaultClip = function ( f8_arg0, f8_arg1 )
			f8_arg0:__resetProperties()
			f8_arg0:setupElementClipCounter( 2 )
			f8_arg0.BlackBar:completeAnimation()
			f8_arg0.BlackBar:setRGB( 0.71, 0.71, 0.71 )
			f8_arg0.BlackBar:setAlpha( 0.01 )
			f8_arg0.clipFinished( f8_arg0.BlackBar )
			f8_arg0.RuleName:completeAnimation()
			f8_arg0.RuleName:setAlpha( 1 )
			f8_arg0.clipFinished( f8_arg0.RuleName )
		end,
		Focus = function ( f9_arg0, f9_arg1 )
			f9_arg0:__resetProperties()
			f9_arg0:setupElementClipCounter( 5 )
			f9_arg0.BlackBar:completeAnimation()
			f9_arg0.BlackBar:setRGB( 0.82, 0.82, 0.82 )
			f9_arg0.BlackBar:setAlpha( 0.05 )
			f9_arg0.clipFinished( f9_arg0.BlackBar )
			f9_arg0.RuleName:completeAnimation()
			f9_arg0.RuleName:setRGB( 0.93, 0.93, 0 )
			f9_arg0.clipFinished( f9_arg0.RuleName )
		end
	}
}

CoD.ShieldActiveRuleRow.__onClose = function ( f10_arg0 )
	f10_arg0.RuleName:close()
	f10_arg0.BlackBar:close()
end

-- rules options
CoD.Shield_Rules_SettingsPopup = InheritFrom( CoD.Menu )
LUI.createMenu.Shield_Rules_SettingsPopup = function ( f1_arg0, f1_arg1 )
	local self = CoD.Menu.NewForUIEditor( "Shield_Rules_SettingsPopup", f1_arg0 )
	local f1_local1 = self
	self:setClass( CoD.Shield_Rules_SettingsPopup )
	self.soundSet = "none"
	self:setOwner( f1_arg0 )
	self:setLeftRight( 0, 1, 0, 0 )
	self:setTopBottom( 0, 1, 0, 0 )
	self:playSound( "menu_open", f1_arg0 )
	self.anyChildUsesUpdateState = true
	f1_local1:addElementToPendingUpdateStateList( self )
	
	local CommomCenteredPopup = CoD.CommonCenteredPopup.new( f1_local1, f1_arg0, 0, 1, 0, 0, 0, 1, 0, 0 )
	CommomCenteredPopup.TitleText:setText("Saved Rules Settings")
	CommomCenteredPopup.HeaderBackground:setAlpha( 0 )
	CommomCenteredPopup.HeaderTopBar:setAlpha( 0 )
	CommomCenteredPopup.HeaderBottomBar:setAlpha( 0 )
	self:addElement( CommomCenteredPopup )
	self.CommomCenteredPopup = CommomCenteredPopup
	
	local TipSec = LUI.UIText.new( 0.50, 0.50, -310.25, 380.75, 0.55, 0.55, -476.25, -438.25 )
	TipSec:setText("Saved Game Rules:")
	TipSec:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )
	TipSec:setTTF( "notosans_regular" )
	TipSec:setAlignment( Enum[@"luialignment"][@"lui_alignment_left"] )
	TipSec:setAlignment( Enum[@"luialignment"][@"lui_alignment_top"] )
	self:addElement( TipSec )
	self.TipSec = TipSec

	local ActiveRulesList = LUI.UIList.new( f1_local1, f1_arg0, 10, 0, nil, false, false, false, false )
	ActiveRulesList:setLeftRight( 0.50, 0.50, -306.76, 265.24 )
	ActiveRulesList:setTopBottom( 0.00, 0.00, 170.74, 770.74 )
	ActiveRulesList:setAutoScaleContent( true )
	ActiveRulesList:setVerticalCount(10)
	ActiveRulesList:setHorizontalCount(1)
	ActiveRulesList:setSpacing( 10 )
	ActiveRulesList:setWidgetType( CoD.ShieldActiveRuleRow )
	ActiveRulesList:setVerticalCounter( CoD.verticalCounter )
	ActiveRulesList:setDataSource( "ShieldActiveRulesList" )
	ActiveRulesList:setAlignment( Enum[@"luialignment"][@"lui_alignment_left"] )
	self:addElement( ActiveRulesList )
	self.ActiveRulesList = ActiveRulesList

	Engine[@"exec"](Engine[@"getprimarycontroller"](), "rules_push")
	ActiveRulesList:AddContextualMenuAction( f1_local1, f1_arg0, @"menu/select", function ( f13_arg0, f13_arg1, f13_arg2, f13_arg3 )
		if AlwaysTrue() then
			return function ( f14_arg0, f14_arg1, f14_arg2, f14_arg3 )
				local RuleName = f14_arg0:getModel(f14_arg2, "RuleName")
				CoD.EnhPrintInfo("selected rule -> " .. RuleName:get())

				Engine[@"setdvar"]("shield_selected_saved_rule", RuleName:get())
				ActiveRulesList:setDataSource( "ShieldActiveRulesListEmpty" )
				ActiveRulesList:setDataSource( "ShieldActiveRulesList" )
				--CoD.OverlayUtility.ShowToast("Saved Rules", "Update", "Selected Rule " .. RuleName:get() .. "!", "mm_icon")
			end
			
		else
			CoD.EnhPrintInfo("WTF")
		end
	end ) 

	ActiveRulesList:AddContextualMenuAction( f1_local1, f1_arg0, @"menu/remove", function ( f13_arg0, f13_arg1, f13_arg2, f13_arg3 )
		if AlwaysTrue() then
			return function ( f14_arg0, f14_arg1, f14_arg2, f14_arg3 )
				local RuleName = f14_arg0:getModel(f14_arg2, "RuleName")
				CoD.EnhPrintInfo("remove rule -> " .. RuleName:get())

				Engine[@"exec"](Engine[@"getprimarycontroller"](), 'rules_remove ' .. '"' .. RuleName:get() .. '"')
			end
			
		else
			CoD.EnhPrintInfo("WTF")
		end
	end ) 

	CoD.PCWidgetUtility.SetupContextualMenu( ActiveRulesList, f1_arg0, "RuleName", "", "" )

	f1_local1:AddButtonCallbackFunction( ActiveRulesList, f1_arg0, Enum[@"luibutton"][@"lui_key_xbx_pssquare"], "ui_remove", function ( element, menu, controller, model )
		if AlwaysTrue() then
			local RuleName = element:getModel(model, "RuleName")
			CoD.EnhPrintInfo("remove rule -> " .. RuleName:get())

			Engine[@"exec"](Engine[@"getprimarycontroller"](), 'rules_remove ' .. '"' .. RuleName:get() .. '"')
			return true
		else
			
		end
	end, function ( element, menu, controller )
		if IsGamepad( controller ) then
			CoD.Menu.SetButtonLabel( menu, Enum[@"luibutton"][@"lui_key_xbx_pssquare"], @"menu/remove", nil, "ui_remove" )
			return true
		elseif IsMouseOrKeyboard( controller ) then
			CoD.Menu.SetButtonLabel( menu, Enum[@"luibutton"][@"lui_key_xbx_pssquare"], @"menu/remove", Enum[@"luibuttonpromptflags"][@"bpf_contextual"], "ui_remove" )
			return true
		else
			return false
		end
	end, false )

	f1_local1:AddButtonCallbackFunction( ActiveRulesList, f1_arg0, Enum[@"luibutton"][@"lui_key_xba_pscross"], "ui_confirm", function ( element, menu, controller, model )
		if AlwaysTrue() then
			local RuleName = element:getModel(model, "RuleName")
			CoD.EnhPrintInfo("selected rule -> " .. RuleName:get())

			Engine[@"setdvar"]("shield_selected_saved_rule", RuleName:get())
			ActiveRulesList:setDataSource( "ShieldActiveRulesListEmpty" )
			ActiveRulesList:setDataSource( "ShieldActiveRulesList" )
			--CoD.OverlayUtility.ShowToast("Saved Rules", "Update", "Selected Rule " .. RuleName:get() .. "!", "mm_icon")
			return true
		else
			
		end
	end, function ( element, menu, controller )
		if IsGamepad( controller ) then
			CoD.Menu.SetButtonLabel( menu, Enum[@"luibutton"][@"lui_key_xba_pscross"], @"menu/select", nil, "ui_confirm" )
			return true
		elseif IsMouseOrKeyboard( controller ) then
			CoD.Menu.SetButtonLabel( menu, Enum[@"luibutton"][@"lui_key_xba_pscross"], @"menu/select", Enum[@"luibuttonpromptflags"][@"bpf_contextual"], "ui_confirm" )
			return true
		else
			return false
		end
	end, false )

	-- for updates
	CoD.Menu.ActiveRulesList = ActiveRulesList

	ActiveRulesList.id = "ActiveRulesList"

	--LUI_DebugElement(f1_local1, f1_arg0, self, ActiveRulesList, "ActiveRulesList", 10)

	-- ...
	local SaveRuleButton = CoD.DirectorSelectButtonMiniInternal.new( f1_local1, f1_arg0, 0.50, 0.50, -319.00, -9.00, 0.50, 0.50, 352.25, 402.25 )
	
	SaveRuleButton.MiddleText:setTTF( "notosans_bold" )
	SaveRuleButton.MiddleText:setText("Save Current Rules")

	SaveRuleButton.MiddleTextFocus:setText("Save Current Rules")
	SaveRuleButton.MiddleTextFocus:setTTF( "notosans_bold" )
	
	SaveRuleButton:linkToElementModel( self, nil, false, function ( model )
		SaveRuleButton:setModel( model, f1_arg1 )
	end )
	self:addElement( SaveRuleButton )
	self.SaveRuleButton = SaveRuleButton

	f1_local1:AddButtonCallbackFunction( SaveRuleButton, f1_arg0, Enum[@"luibutton"][@"lui_key_xba_pscross"], "ui_confirm", function ( element, menu, controller, model )
		PlaySoundAlias( "uin_paint_image_flip_toggle" )
		CoD.EnhPrintInfo("SaveRuleButton")
		ShieldSaveGameRules()
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

	SaveRuleButton.id = "SaveRuleButton"

	local LoadRuleButton = CoD.DirectorSelectButtonMiniInternal.new( f1_local1, f1_arg0, 0.50, 0.50, 2.75, 312.75, 0.50, 0.50, 352.25, 402.25 )
	
	LoadRuleButton.MiddleText:setTTF( "notosans_bold" )
	LoadRuleButton.MiddleText:setText("Load Selected Rules")

	LoadRuleButton.MiddleTextFocus:setText("Load Selected Rules")
	LoadRuleButton.MiddleTextFocus:setTTF( "notosans_bold" )
	
	LoadRuleButton:linkToElementModel( self, nil, false, function ( model )
		LoadRuleButton:setModel( model, f1_arg1 )
	end )
	self:addElement( LoadRuleButton )
	self.LoadRuleButton = LoadRuleButton

	f1_local1:AddButtonCallbackFunction( LoadRuleButton, f1_arg0, Enum[@"luibutton"][@"lui_key_xba_pscross"], "ui_confirm", function ( element, menu, controller, model )
		PlaySoundAlias( "uin_paint_image_flip_toggle" )
		CoD.EnhPrintInfo("LoadRuleButton")
		ShieldLoadGameRules()
		-- ...

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

	LoadRuleButton.id = "LoadRuleButton"

	-- text box
	local NameEditBox = CoD.Shield_NameEditBox.new( self, f1_arg0, 0.50, 0.50, -319.00, -7.00, 0.50, 0.50, 283.76, 333.76 )
	NameEditBox:linkToElementModel( self, nil, false, function ( model )
		NameEditBox:setModel( model, f1_arg1 )
	end )
	NameEditBox.TextBox:setLeftRight(0, 0, 20 + 110, 320 + 110)
	NameEditBox.RankHighlight:setText("^2Save as Name: ")
	self:addElement( NameEditBox )
	self.NameEditBox = NameEditBox

	-- prevent element pool being fucked
	local NameEditBoxModel = Engine[@"getmodel"]( Engine[@"getmodelforcontroller"]( f1_arg1 ), "Shield_Rule_Name" )

	if NameEditBoxModel == nil then
		NameEditBoxModel = Engine[@"createmodel"]( Engine[@"getmodelforcontroller"]( f1_arg1 ), "Shield_Rule_Name" )
	end

	NameEditBoxModel:set("")

	CoD.PCUtility.SetupEditControlWithModel( NameEditBox, f1_arg0, self, NameEditBoxModel, function ( f331_arg0, f331_arg1, f331_arg2 )
		if not f331_arg2.canceled and f331_arg2.name == "textbox_editdone" then
			local NameData = f331_arg0:get()

			CoD.EnhPrintInfo("Rule Name", NameData)
			PlaySoundAlias( "uin_paint_image_flip_toggle" )
			
			f331_arg0:set(NameData)
			Engine[@"setdvar"]("shield_selected_saved_rule_name", NameData)
		else
			f331_arg0:set("") -- reset it
		end
	end )

	self.NameEditBoxModel = NameEditBoxModel
	NameEditBox.id = "NameEditBox"

	--LUI_DebugElement(f1_local1, f1_arg0, self, NameEditBox, "NameEditBox", 10)
	
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

	self:processEvent( {
		name = "menu_loaded",
		controller = f1_arg0
	} )
	self.__defaultFocus = ActiveRulesList
	if CoD.isPC and (IsKeyboard( f1_arg0 ) or self.ignoreCursor) then
		self:restoreState( f1_arg0 )
	end
	LUI.OverrideFunction_CallOriginalSecond( self, "close", self.__onClose )
	if PostLoadFunc then
		PostLoadFunc( self, f1_arg0 )
	end
	
	f1_local7 = self
	--MenuHidesFreeCursor( f1_local1, f1_arg0 )

	CoD.EnhPrintInfo("Called", "Shield's Rules Settings Menu")

	return self
end

CoD.Shield_Rules_SettingsPopup.__resetProperties = function ( f13_arg0 )
	
end

CoD.Shield_Rules_SettingsPopup.__clipsPerState = {
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
		end
	}
}

CoD.Shield_Rules_SettingsPopup.__onClose = function ( f16_arg0 )
	f16_arg0.CommomCenteredPopup:close()
	f16_arg0.NameEditBox:close()
	f16_arg0.LoadRuleButton:close()
	f16_arg0.SaveRuleButton:close()
	f16_arg0.ActiveRulesList:close()
end