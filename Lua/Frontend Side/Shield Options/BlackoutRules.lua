--[[
		.\hksc.exe ".\Lua\BlackoutRules.Lua" -o "C:\Program Files (x86)\Call of Duty Black Ops 4\project-bo4\mods\T8ShieldSupport\Lua\BlackoutRules.luac"
]]

---------------------------

CoD.ShieldInitLuaFile()

---------------------------

-- wz
Engine[@"setdvar"]( "shield_force_wz_gametype", 0 )
Engine[@"setdvar"]("shield_force_wz_gametype_get", "")

CoD.wz_settings_changed = {}
local BlackoutSettingTab = 0
local GlobalBlackoutSettingsList = nil

---------------------------

CoD.WZRulesReloads = function()
	-- set saved wz gametype
	if IsWarzone() and Engine[@"getdvarstring"]("shield_force_wz_gametype_get") ~= nil and Engine[@"getdvarstring"]("shield_force_wz_gametype_get") ~= "" then
		local game_type_get = Engine[@"getdvarstring"]("shield_force_wz_gametype_get")
		SetGameType( Engine[@"getglobalmodel"](), game_type_get )
		CoD.EnhPrintInfo("Set gametype to: " .. tostring(game_type_get))
	end

	-- set saved wz settings
	if IsWarzone() and CoD.wz_settings_changed ~= nil then
		for id, pair in ipairs( CoD.wz_settings_changed ) do
			Engine[@"setgametypesetting"]( pair.name, pair.value )
			CoD.EnhPrintInfo("Set gametype setting: " .. tostring(pair.name) .. " to " .. tostring(pair.value))
		end
	end
end

local BadGamemodesWZ = {
	[10] = true,
	[279] = true,
	[281] = true,
	[275] = true,
	[274] = true,
	[276] = true,
	[273] = true,
	[278] = true,
	[280] = true,
	[272] = true,
	[277] = true,
	[282] = true,
	[285] = true,
	[291] = true
}

local function IsBadGameMode_WZ(gamemode_id)
    local GetID = gamemode_id
    return BadGamemodesWZ[GetID] == true
end

local function OpenResetGameSettingsPopupWZ( f488_arg0, f488_arg1, f488_arg2, f488_arg3, f488_arg4 )
	f488_arg4:saveState( f488_arg2 )
	CoD.OverlayUtility.CreateOverlay( f488_arg2, f488_arg0, "ResetCustomGameSettingsPCWZ" )
end

local function CreateDvarSettingsNoLocalize( f197_arg0, f197_arg1, f197_arg2, f197_arg3, f197_arg4, f197_arg5, f197_arg6, f197_arg7 )
	local f197_local0 = {}
	local f197_local1 = nil
	for f197_local5, f197_local6 in ipairs( f197_arg5 ) do
		if f197_local6.default == true then
			f197_local1 = f197_local6.value
		end
		table.insert( f197_local0, {
			name = f197_local6.option,
			value = f197_local6.value,
			title = f197_arg1,
			desc = f197_arg2,
			default = f197_local6.default
		} )
	end
	return {
		models = {
			name = f197_arg1,
			desc = f197_arg2,
			image = f197_arg6,
			gamesetting = f197_arg4,
			optionsDatasource = CoD.OptionsUtility.CreateDvarSettingsDataSource( f197_arg0, f197_arg3, f197_local0, f197_arg4, false, f197_arg7 )
		},
		properties = {
			revert = function ( f198_arg0 )
				Engine[@"setdvar"]( f197_arg4, f197_local1 )
			end
		}
	}
end

local function OnWzSettingDataChange ( f137_arg0, f137_arg1, f137_arg2, f137_arg3, f137_arg4 )
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

	if dvar_name == "shield_force_wz_gametype" then
		if dvar_val_new == 0 then
			Engine[@"setdvar"]( "shield_force_wz_gametype_get", "" )
			return
		end

		-- gametypes in wz
		local gametypes_table = {}
		local sort_func = function ( arg1, arg2 )
			return arg1.properties.sortIndex < arg2.properties.sortIndex
		end
		
		for i, gametype_group in pairs( CoD.GameTypeUtility.GameTypeTable ) do
			if gametype_group.groupName == "wzstandard" or gametype_group.groupName == "hidden" then
				local bad_wz_type = IsBadGameMode_WZ(gametype_group.uniqueID)
				if bad_wz_type == false then
					table.insert( gametypes_table, {
						models = {
							id = gametype_group.name,
							name = Engine[@"hash_4F9F1239CFD921FE"]( gametype_group.nameRef ),
							isOfficial = true
						},
						properties = {
							sortIndex = gametype_group.uniqueID,
							isGameTypeElement = true
						}
					} )
				end
			end
		end
		table.sort( gametypes_table, sort_func )

		for o, gametype in pairs( gametypes_table ) do
			--CoD.EnhPrintInfo("comparing " .. o .. " to " .. dvar_val_new)
			if dvar_val_new == o then
				Engine[@"setdvar"]( "shield_force_wz_gametype_get", gametype.models.id )
				--CoD.EnhPrintInfo("Setting WZ Gametype to " .. gametype.models.id)
			end
		end
	end
	
	if string.find(dvar_name, "gametype_") then
		local gametype_setting = string.gsub(dvar_name, "gametype_", "")
		Engine[@"setgametypesetting"]( gametype_setting, dvar_val_new )

		local hash_try = "hash_" .. gametype_setting

		-- TODO: add every other xhash ref
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

		if hash_known_table[hash_try] then
			Engine[@"setgametypesetting"](hash_known_table[hash_try], dvar_val_new)
			
			-- delete if it exists already to prevent duplicates, we only want the latest change for each setting
			for i = #CoD.wz_settings_changed, 1, -1 do
				if CoD.wz_settings_changed[i].name == hash_known_table[hash_try] then
					table.remove(CoD.wz_settings_changed, i)
				end
			end

			table.insert(CoD.wz_settings_changed, {
				name = hash_known_table[hash_try],
				name_setting = dvar_name,
				value = dvar_val_new
			})

			ForceNotifyGlobalModel( Engine[@"getprimarycontroller"](), "GametypeSettings.Update" )
			return
		else
			CoD.EnhPrintInfo("Gametype setting " .. gametype_setting .. " changed, but no known hash found to set for it.")
		end

		-- delete if it exists already to prevent duplicates, we only want the latest change for each setting
		for i = #CoD.wz_settings_changed, 1, -1 do
			if CoD.wz_settings_changed[i].name == gametype_setting then
				table.remove(CoD.wz_settings_changed, i)
			end
		end

		table.insert(CoD.wz_settings_changed, {
			name = gametype_setting,
			name_setting = dvar_name,
			value = dvar_val_new
		})

		ForceNotifyGlobalModel( Engine[@"getprimarycontroller"](), "GametypeSettings.Update" )
	end
end

---------------------------

-- BLackout Settings Tab
DataSources.ShieldBlackoutSettingsFilters = DataSourceHelpers.ListSetup( "ShieldBlackoutSettingsFilters", function ( f3_arg0, f3_arg1 )
	local filters = {
        {
            
			models = {
				name = @"shield/blackout_tab_gamemode",
				filter = 0
			},
            properties = {
				filter = 0
			}
		},
		{
            
			models = {
				name = @"shield/blackout_tab_events",
				filter = 1
			},
            properties = {
				filter = 1
			}

		},
		{
            
			models = {
				name = @"shield/blackout_tab_itemspawns",
				filter = 2
			},
            properties = {
				filter = 2
			}

		},
		{
            
			models = {
				name = @"shield/blackout_tab_weaponspawns",
				filter = 3
			},
            properties = {
				filter = 3
			}

		},
		{
            
			models = {
				name = @"shield/blackout_tab_perks",
				filter = 4
			},
            properties = {
				filter = 4
			}

		},
		{
            
			models = {
				name = @"shield/blackout_tab_enemiesspawns",
				filter = 5
			},
            properties = {
				filter = 5
			}

		},
		{
            
			models = {
				name = @"shield/blackout_tab_vehiclespawns",
				filter = 6
			},
            properties = {
				filter = 6
			}

		},
		{
            
			models = {
				name = @"shield/blackout_tab_characters",
				filter = 8
			},
            properties = {
				filter = 8
			}

		},
		{
            
			models = {
				name = @"shield/blackout_tab_misc",
				filter = 7
			},
            properties = {
				filter = 7
			}

		},
	}
	return filters
end, true )

CoD.OverlayUtility.Overlays.ResetCustomGameSettingsPCWZ = {
	menuName = "SystemOverlay_Compact",
	title = Engine[@"hash_4F9F1239CFD921FE"]( @"hash_48DA07D8AFA13097" ),
	description = @"hash_19C4B0F90AB92689",
	categoryType = CoD.OverlayUtility.OverlayTypes.Settings,
	listDatasource = function ()
		DataSources.ResetCustomGameSettingsPCWZ_List = DataSourceHelpers.ListSetup( "ResetCustomGameSettingsPCWZ_List", function ( f212_arg0 )
			return {
				{
					models = {
						displayText = Engine[@"toupper"]( Engine[@"hash_4F9F1239CFD921FE"]( @"platform/reset_all" ) )
					},
					properties = {
						action = function ( f213_arg0, f213_arg1, f213_arg2, f213_arg3, f213_arg4 )
							-- reset vars
							Engine[@"setdvar"]( "shield_force_wz_gametype", 0 )
							Engine[@"setdvar"]( "shield_force_wz_gametype_get", "" )
							CoD.wz_settings_changed = { }

							-- game's
							ResetGameSettings( f213_arg4, f213_arg2 )

							-- fix resetting defaults
							if GlobalBlackoutSettingsList ~= nil then
								GlobalBlackoutSettingsList:setDataSource("")
								GlobalBlackoutSettingsList:setDataSource("RulesSettingsDataBlackout")
							end

							GoBack( f213_arg4, f213_arg2 )
						end
						
					}
				},
				{
					models = {
						displayText = Engine[@"toupper"]( Engine[@"hash_4F9F1239CFD921FE"]( @"platform/cancel" ) )
					},
					properties = {
						action = function ( f214_arg0, f214_arg1, f214_arg2, f214_arg3, f214_arg4 )
							GoBack( f214_arg4, f214_arg2 )
						end
						
					}
				}
			}
		end, true, nil )
		return "ResetCustomGameSettingsPCWZ_List"
	end,
	[CoD.OverlayUtility.GoBackPropertyName] = CoD.OverlayUtility.DefaultGoBack,
	[CoD.OverlayUtility.aCrossPromptFn] = function ( f215_arg0 )
		return function ( f216_arg0, f216_arg1 )
			-- reset vars
			Engine[@"setdvar"]( "shield_force_wz_gametype", 0 )
			Engine[@"setdvar"]( "shield_force_wz_gametype_get", "" )
			CoD.wz_settings_changed = { }

			-- game's
			ResetGameSettings( f216_arg0, f216_arg1 )

			-- fix resetting defaults
			if GlobalBlackoutSettingsList ~= nil then
				GlobalBlackoutSettingsList:setDataSource("")
				GlobalBlackoutSettingsList:setDataSource("RulesSettingsDataBlackout")
			end

			GoBack( f216_arg0, f216_arg1 )
		end
		
	end,
	[CoD.OverlayUtility.aCrossPromptText] = @"platform/reset_all",
	[CoD.OverlayUtility.bCirclePromptFn] = function ( f217_arg0 )
		return function ( f218_arg0, f218_arg1 )
			GoBack( f218_arg0, f218_arg1 )
		end
		
	end,
	[CoD.OverlayUtility.bCirclePromptText] = @"hash_24A93EC78F54644E"
}

DataSources.RulesSettingsDataBlackout = DataSourceHelpers.ListSetup( "RulesSettingsDataBlackout", function ( f138_arg0 )
	local Settings = {}

	-- Gamemode
	if BlackoutSettingTab == 0 then
		local gametypes_table = {}
		local sort_func = function ( arg1, arg2 )
			return arg1.properties.sortIndex < arg2.properties.sortIndex
		end
		
		for _, gametype_group in pairs( CoD.GameTypeUtility.GameTypeTable ) do
			if gametype_group.groupName == "wzstandard" or gametype_group.groupName == "hidden" then
				local bad_wz_type = IsBadGameMode_WZ(gametype_group.uniqueID)
				if bad_wz_type == false then
					table.insert( gametypes_table, {
						models = {
							id = gametype_group.name,
							name = Engine[@"hash_4F9F1239CFD921FE"]( gametype_group.nameRef ),
							isOfficial = true
						},
						properties = {
							sortIndex = gametype_group.uniqueID,
							isGameTypeElement = true
						}
					} )
				end
			end
		end
		table.sort( gametypes_table, sort_func )

		local gametype_names = {
			{
				option = Engine[@"hash_4F9F1239CFD921FE"]( @"menu/off" ),
				value = 0,
				default = true
			}
		}

		for o, gametype in pairs( gametypes_table ) do
			table.insert( gametype_names, {
				option = gametype.models.name,
				value = o,
				default = false
			} )
		end

		Engine[@"setdvar"]( "shield_force_wz_gametype", Engine[@"getdvarstring"]( "shield_force_wz_gametype" ) or "" )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Force Gametype", "Forces gametype, useful for public matches (deploy button)", "shield_force_wz_gametype", "shield_force_wz_gametype",
		gametype_names, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzhardcore", Engine[@"getgametypesetting"]( @"wzhardcore" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Hardcore Mode", "WZ Hardcore", "gametype_wzhardcore", "gametype_wzhardcore", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzhardcore" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzhardcore" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_3a73deb0ca8c9aea", Engine[@"getgametypesetting"]( @"hash_3a73deb0ca8c9aea" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Disable Crosshair", "Disable crosshair", "gametype_3a73deb0ca8c9aea", "gametype_3a73deb0ca8c9aea", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"hash_3a73deb0ca8c9aea" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"hash_3a73deb0ca8c9aea" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzplayerinsertiontypeindex", Engine[@"getgametypesetting"]( @"wzplayerinsertiontypeindex" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Player Insertion Type", "Player entering or respawning type (0 = helicopter, 1 = portals, 2 = direct freefall??)", "gametype_wzplayerinsertiontypeindex", "gametype_wzplayerinsertiontypeindex", {
			{
				option = "0",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzplayerinsertiontypeindex" ) == 0
			},
			{
				option = "1",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzplayerinsertiontypeindex" ) == 1
			},
			{
				option = "2",
				value = 2,
				default = Engine[@"getgametypesetting"]( @"wzplayerinsertiontypeindex" ) == 2
			},
		}, nil, OnWzSettingDataChange ) )
		
		Engine[@"setdvar"]( "gametype_friendlyfiretype", Engine[@"getgametypesetting"]( @"friendlyfiretype" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Friendly Fire Type", "Set the type of friendly fire", "gametype_friendlyfiretype", "gametype_friendlyfiretype", {
			{
				option = "0",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"friendlyfiretype" ) == 0
			},
			{
				option = "1",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"friendlyfiretype" ) == 1
			},
			{
				option = "2",
				value = 2,
				default = Engine[@"getgametypesetting"]( @"friendlyfiretype" ) == 2
			},
			{
				option = "3",
				value = 3,
				default = Engine[@"getgametypesetting"]( @"friendlyfiretype" ) == 3
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenablecowardswayout", Engine[@"getgametypesetting"]( @"wzenablecowardswayout" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable Cowards Way Out", "Enable cowardswayout", "gametype_wzenablecowardswayout", "gametype_wzenablecowardswayout", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenablecowardswayout" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenablecowardswayout" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_6cc7b012775d9662", Engine[@"getgametypesetting"]( @"hash_6cc7b012775d9662" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable Bleed Out", "Enable bleed out", "gametype_6cc7b012775d9662", "gametype_6cc7b012775d9662", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"hash_6cc7b012775d9662" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"hash_6cc7b012775d9662" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )
	end

	-- AI Enemies Spawns
	if BlackoutSettingTab == 5 then
		Engine[@"setdvar"]( "gametype_wzzombies", Engine[@"getgametypesetting"]( @"wzzombies" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Warzone Zombies", "Enables Warzone Zombies", "gametype_wzzombies", "gametype_wzzombies", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzzombies" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzzombies" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_44c7473eab6e5459", Engine[@"getgametypesetting"]( @"hash_44c7473eab6e5459" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Spawn Zombies Cellhouse", "Spawn zombies zone cellhouse", "gametype_44c7473eab6e5459", "gametype_44c7473eab6e5459", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"hash_44c7473eab6e5459" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"hash_44c7473eab6e5459" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_4d6cfd0b3ee4cc7d", Engine[@"getgametypesetting"]( @"hash_4d6cfd0b3ee4cc7d" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Spawn Zombies New Industries", "Spawn zombies zone new industries", "gametype_4d6cfd0b3ee4cc7d", "gametype_4d6cfd0b3ee4cc7d", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"hash_4d6cfd0b3ee4cc7d" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"hash_4d6cfd0b3ee4cc7d" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_76fb3219916a09f2", Engine[@"getgametypesetting"]( @"hash_76fb3219916a09f2" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Spawn Zombies Parade Grounds", "Spawn zombies zone parade grounds", "gametype_76fb3219916a09f2", "gametype_76fb3219916a09f2", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"hash_76fb3219916a09f2" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"hash_76fb3219916a09f2" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_3624143624604b4c", Engine[@"getgametypesetting"]( @"hash_3624143624604b4c" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Spawn Zombies Global", "Spawn zombies zone global", "gametype_3624143624604b4c", "gametype_3624143624604b4c", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"hash_3624143624604b4c" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"hash_3624143624604b4c" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzminibosses", Engine[@"getgametypesetting"]( @"wzminibosses" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Spawn Minibosses", "Spawn minibosses", "gametype_wzminibosses", "gametype_wzminibosses", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzminibosses" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzminibosses" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzspawnspecial", Engine[@"getgametypesetting"]( @"wzspawnspecial" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Spawn Special AI", "Spawn special AI", "gametype_wzspawnspecial", "gametype_wzspawnspecial", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzspawnspecial" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzspawnspecial" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzbrutus", Engine[@"getgametypesetting"]( @"wzbrutus" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Spawn Brutus", "Spawn Brutus", "gametype_wzbrutus", "gametype_wzbrutus", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzbrutus" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzbrutus" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzblightfather", Engine[@"getgametypesetting"]( @"wzblightfather" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Spawn Blight Father", "Spawn Blight Father", "gametype_wzblightfather", "gametype_wzblightfather", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzblightfather" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzblightfather" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzavogadro", Engine[@"getgametypesetting"]( @"wzavogadro" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Spawn Avogadro", "Spawn Avogadro", "gametype_wzavogadro", "gametype_wzavogadro", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzavogadro" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzavogadro" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		
		Engine[@"setdvar"]( "gametype_wzbrutuseverywhere", Engine[@"getgametypesetting"]( @"wzbrutuseverywhere" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Brutus Everywhere", "Set spawner brutus boss", "gametype_wzbrutuseverywhere", "gametype_wzbrutuseverywhere", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzbrutuseverywhere" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzbrutuseverywhere" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzbrutuslarge", Engine[@"getgametypesetting"]( @"wzbrutuslarge" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Brutus Boss Zombies", "Allow brutus boss zombies", "gametype_wzbrutuslarge", "gametype_wzbrutuslarge", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzbrutuslarge" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzbrutuslarge" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzbrutuslargeeverywhere", Engine[@"getgametypesetting"]( @"wzbrutuslargeeverywhere" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Brutus Boss Everywhere", "Set spawner brutus bosses", "gametype_wzbrutuslargeeverywhere", "gametype_wzbrutuslargeeverywhere", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzbrutuslargeeverywhere" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzbrutuslargeeverywhere" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzavogadroeverywhere", Engine[@"getgametypesetting"]( @"wzavogadroeverywhere" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Avogadro Everywhere", "Set spawner avogadro", "gametype_wzavogadroeverywhere", "gametype_wzavogadroeverywhere", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzavogadroeverywhere" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzavogadroeverywhere" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzblightfatherseverywhere", Engine[@"getgametypesetting"]( @"wzblightfatherseverywhere" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Blight Father Everywhere", "Set spawner blight father", "gametype_wzblightfatherseverywhere", "gametype_wzblightfatherseverywhere", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzblightfatherseverywhere" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzblightfatherseverywhere" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzadddogs", Engine[@"getgametypesetting"]( @"wzadddogs" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Add Zombie Dogs", "Add zombies dog", "gametype_wzadddogs", "gametype_wzadddogs", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzadddogs" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzadddogs" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzhellhoundseverywhere", Engine[@"getgametypesetting"]( @"wzhellhoundseverywhere" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Hell Hounds Everywhere", "Set spawner dog (bugged)", "gametype_wzhellhoundseverywhere", "gametype_wzhellhoundseverywhere", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzhellhoundseverywhere" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzhellhoundseverywhere" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_3e2d2cf6b1cc6c68", Engine[@"getgametypesetting"]( @"hash_3e2d2cf6b1cc6c68" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Zombies With Duck Floats", "Spawn zombies with duck floats", "gametype_3e2d2cf6b1cc6c68", "gametype_3e2d2cf6b1cc6c68", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"hash_3e2d2cf6b1cc6c68" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"hash_3e2d2cf6b1cc6c68" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzgreeneyes", Engine[@"getgametypesetting"]( @"wzgreeneyes" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Green Eyes on Zombies", "Green eyes on zombies", "gametype_wzgreeneyes", "gametype_wzgreeneyes", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzgreeneyes" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzgreeneyes" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )
	end

	-- Events
	if BlackoutSettingTab == 1 then
		Engine[@"setdvar"]( "gametype_wzambush", Engine[@"getgametypesetting"]( @"wzambush" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Ambush Mode", "Ambush Mode", "gametype_wzambush", "gametype_wzambush", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzambush" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzambush" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzheavymetalheroes", Engine[@"getgametypesetting"]( @"wzheavymetalheroes" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Heavy Metal Heroes", "Is WZ heavy metal heroes", "gametype_wzheavymetalheroes", "gametype_wzheavymetalheroes", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzheavymetalheroes" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzheavymetalheroes" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenablehotpursuit", Engine[@"getgametypesetting"]( @"wzenablehotpursuit" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable Hot Pursuit", "Enable hotpursuit", "gametype_wzenablehotpursuit", "gametype_wzenablehotpursuit", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenablehotpursuit" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenablehotpursuit" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenableheavymetal", Engine[@"getgametypesetting"]( @"wzenableheavymetal" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable Heavy Metal", "Enable heavy metal stuff", "gametype_wzenableheavymetal", "gametype_wzenableheavymetal", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenableheavymetal" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenableheavymetal" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenablebountyhuntervehicles", Engine[@"getgametypesetting"]( @"wzenablebountyhuntervehicles" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable Bounty Hunter Vehicles", "Enable bounty hunter vehicle", "gametype_wzenablebountyhuntervehicles", "gametype_wzenablebountyhuntervehicles", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenablebountyhuntervehicles" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenablebountyhuntervehicles" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzzombieapocalypse", Engine[@"getgametypesetting"]( @"wzzombieapocalypse" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Zombie Apocalypse", "WZ Pandemic", "gametype_wzzombieapocalypse", "gametype_wzzombieapocalypse", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzzombieapocalypse" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzzombieapocalypse" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzzombieapocalypsemusic", Engine[@"getgametypesetting"]( @"wzzombieapocalypsemusic" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Zombie Apocalypse Music", "Play z apocalypse music", "gametype_wzzombieapocalypsemusic", "gametype_wzzombieapocalypsemusic", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzzombieapocalypsemusic" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzzombieapocalypsemusic" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzbigteambattle", Engine[@"getgametypesetting"]( @"wzbigteambattle" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Big Team Battle", "WZ Ground War", "gametype_wzbigteambattle", "gametype_wzbigteambattle", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzbigteambattle" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzbigteambattle" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzspectrerising", Engine[@"getgametypesetting"]( @"wzspectrerising" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Spectre Rising", "WZ Spectre Rising Operation", "gametype_wzspectrerising", "gametype_wzspectrerising", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzspectrerising" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzspectrerising" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzwetworks", Engine[@"getgametypesetting"]( @"wzwetworks" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Wetwork Event", "Flooded blackout map event (only affects vehicle spawns)", "gametype_wzwetworks", "gametype_wzwetworks", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzwetworks" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzwetworks" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_697d65a68cc6c6f1", Engine[@"getgametypesetting"]( @"hash_697d65a68cc6c6f1" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "WZ Escape EE", "Enable some EE (nixie, spoon, icarus)", "gametype_697d65a68cc6c6f1", "gametype_697d65a68cc6c6f1", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"hash_697d65a68cc6c6f1" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"hash_697d65a68cc6c6f1" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_473fee16f796c84e", Engine[@"getgametypesetting"]( @"hash_473fee16f796c84e" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "WZ Escape Fishing EE", "Enable wz escape fishing EE", "gametype_473fee16f796c84e", "gametype_473fee16f796c84e", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"hash_473fee16f796c84e" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"hash_473fee16f796c84e" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_30b11d064f146fcc", Engine[@"getgametypesetting"]( @"hash_30b11d064f146fcc" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "WZ Escape Spoon EE", "Enable wz escape spoon EE", "gametype_30b11d064f146fcc", "gametype_30b11d064f146fcc", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"hash_30b11d064f146fcc" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"hash_30b11d064f146fcc" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_11b79ec2ffb886c8", Engine[@"getgametypesetting"]( @"hash_11b79ec2ffb886c8" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "WZ Escape Nixie Tube EE", "Enable wz escape nixie tube EE", "gametype_11b79ec2ffb886c8", "gametype_11b79ec2ffb886c8", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"hash_11b79ec2ffb886c8" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"hash_11b79ec2ffb886c8" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_5f842714fa80e5a9", Engine[@"getgametypesetting"]( @"hash_5f842714fa80e5a9" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "WZ Escape Poster EE", "Enable wz escape poster EE", "gametype_5f842714fa80e5a9", "gametype_5f842714fa80e5a9", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"hash_5f842714fa80e5a9" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"hash_5f842714fa80e5a9" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_6fbf57e2af153e5f", Engine[@"getgametypesetting"]( @"hash_6fbf57e2af153e5f" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Homunculus EE", "Spawn homunculus ee", "gametype_6fbf57e2af153e5f", "gametype_6fbf57e2af153e5f", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"hash_6fbf57e2af153e5f" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"hash_6fbf57e2af153e5f" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_53b5887dea69a320", Engine[@"getgametypesetting"]( @"hash_53b5887dea69a320" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Spring Homunculus EE", "Enable spring homunculus ee", "gametype_53b5887dea69a320", "gametype_53b5887dea69a320", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"hash_53b5887dea69a320" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"hash_53b5887dea69a320" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_6fb11b1e304d533c", Engine[@"getgametypesetting"]( @"hash_6fb11b1e304d533c" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Halloween Blackout Event", "Activate halloween blackout event", "gametype_6fb11b1e304d533c", "gametype_6fb11b1e304d533c", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"hash_6fb11b1e304d533c" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"hash_6fb11b1e304d533c" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzhighvaluetargets", Engine[@"getgametypesetting"]( @"wzhighvaluetargets" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "High Value Targets", "High value targets", "gametype_wzhighvaluetargets", "gametype_wzhighvaluetargets", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzhighvaluetargets" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzhighvaluetargets" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )
	end

	-- Items Spawns
	if BlackoutSettingTab == 2 then
		Engine[@"setdvar"]( "gametype_wzenablespraycans", Engine[@"getgametypesetting"]( @"wzenablespraycans" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable Spray Cans", "Enable spray cans", "gametype_wzenablespraycans", "gametype_wzenablespraycans", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenablespraycans" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenablespraycans" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzwaterballoonsenabled", Engine[@"getgametypesetting"]( @"wzwaterballoonsenabled" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Water Balloons", "Spawn water balloons", "gametype_wzwaterballoonsenabled", "gametype_wzwaterballoonsenabled", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzwaterballoonsenabled" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzwaterballoonsenabled" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzsnowballsenabled", Engine[@"getgametypesetting"]( @"wzsnowballsenabled" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Snowballs", "Spawn snowballs", "gametype_wzsnowballsenabled", "gametype_wzsnowballsenabled", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzsnowballsenabled" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzsnowballsenabled" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzlootlockers", Engine[@"getgametypesetting"]( @"wzlootlockers" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Blackjack Crates", "Spawn blackjack crates", "gametype_wzlootlockers", "gametype_wzlootlockers", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzlootlockers" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzlootlockers" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenablebarricade", Engine[@"getgametypesetting"]( @"wzenablebarricade" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable Barricade", "Enable barricade item", "gametype_wzenablebarricade", "gametype_wzenablebarricade", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenablebarricade" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenablebarricade" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenablecontrabandstash", Engine[@"getgametypesetting"]( @"wzenablecontrabandstash" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable Contraband Stash", "Enable contrabandstash", "gametype_wzenablecontrabandstash", "gametype_wzenablecontrabandstash", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenablecontrabandstash" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenablecontrabandstash" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenablehawk", Engine[@"getgametypesetting"]( @"wzenablehawk" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable Hawk", "Enable hawk", "gametype_wzenablehawk", "gametype_wzenablehawk", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenablehawk" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenablehawk" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenabledart", Engine[@"getgametypesetting"]( @"wzenabledart" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable Dart", "Enable dart", "gametype_wzenabledart", "gametype_wzenabledart", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenabledart" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenabledart" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenablebandages", Engine[@"getgametypesetting"]( @"wzenablebandages" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable Bandages", "Enable bandages", "gametype_wzenablebandages", "gametype_wzenablebandages", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenablebandages" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenablebandages" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenablemedkit", Engine[@"getgametypesetting"]( @"wzenablemedkit" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable Medkit", "Enable medkit", "gametype_wzenablemedkit", "gametype_wzenablemedkit", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenablemedkit" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenablemedkit" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenabletraumakit", Engine[@"getgametypesetting"]( @"wzenabletraumakit" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable Trauma Kit", "Enable trauma kit", "gametype_wzenabletraumakit", "gametype_wzenabletraumakit", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenabletraumakit" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenabletraumakit" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenabletak5", Engine[@"getgametypesetting"]( @"wzenabletak5" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable Tak 5", "Enable tak5", "gametype_wzenabletak5", "gametype_wzenabletak5", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenabletak5" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenabletak5" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenablereflex", Engine[@"getgametypesetting"]( @"wzenablereflex" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable Reflex", "Enable reflex", "gametype_wzenablereflex", "gametype_wzenablereflex", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenablereflex" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenablereflex" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenableholo", Engine[@"getgametypesetting"]( @"wzenableholo" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable Holo", "Enable holo", "gametype_wzenableholo", "gametype_wzenableholo", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenableholo" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenableholo" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenablestock", Engine[@"getgametypesetting"]( @"wzenablestock" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable Stock", "Enable stock", "gametype_wzenablestock", "gametype_wzenablestock", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenablestock" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenablestock" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenableextmag", Engine[@"getgametypesetting"]( @"wzenableextmag" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable Extended Mag", "Enable extmag", "gametype_wzenableextmag", "gametype_wzenableextmag", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenableextmag" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenableextmag" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenableelo", Engine[@"getgametypesetting"]( @"wzenableelo" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable ELO", "Enable elo", "gametype_wzenableelo", "gametype_wzenableelo", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenableelo" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenableelo" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenablepurifier", Engine[@"getgametypesetting"]( @"wzenablepurifier" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable Purifier", "Enable purifier", "gametype_wzenablepurifier", "gametype_wzenablepurifier", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenablepurifier" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenablepurifier" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenablemeshmines", Engine[@"getgametypesetting"]( @"wzenablemeshmines" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable Mesh Mines", "Enable mesh mines", "gametype_wzenablemeshmines", "gametype_wzenablemeshmines", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenablemeshmines" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenablemeshmines" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenablearmorplate", Engine[@"getgametypesetting"]( @"wzenablearmorplate" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable Armor Plates", "Enable armor plates", "gametype_wzenablearmorplate", "gametype_wzenablearmorplate", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenablearmorplate" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenablearmorplate" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenablelv3armor", Engine[@"getgametypesetting"]( @"wzenablelv3armor" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable LV3 Armor", "Enable lv3armor", "gametype_wzenablelv3armor", "gametype_wzenablelv3armor", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenablelv3armor" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenablelv3armor" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenablelv2armor", Engine[@"getgametypesetting"]( @"wzenablelv2armor" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable LV2 Armor", "Enable lv2armor", "gametype_wzenablelv2armor", "gametype_wzenablelv2armor", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenablelv2armor" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenablelv2armor" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenablelv1armor", Engine[@"getgametypesetting"]( @"wzenablelv1armor" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable LV1 Armor", "Enable lv1armor", "gametype_wzenablelv1armor", "gametype_wzenablelv1armor", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenablelv1armor" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenablelv1armor" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenablefastmag", Engine[@"getgametypesetting"]( @"wzenablefastmag" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable Fast Mag", "Enable fastmag", "gametype_wzenablefastmag", "gametype_wzenablefastmag", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenablefastmag" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenablefastmag" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenablegrapple", Engine[@"getgametypesetting"]( @"wzenablegrapple" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable Grapple", "Enable grapple", "gametype_wzenablegrapple", "gametype_wzenablegrapple", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenablegrapple" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenablegrapple" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenablelasersight", Engine[@"getgametypesetting"]( @"wzenablelasersight" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable Laser Sight", "Enable laser sight", "gametype_wzenablelasersight", "gametype_wzenablelasersight", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenablelasersight" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenablelasersight" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenable4xscope", Engine[@"getgametypesetting"]( @"wzenable4xscope" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable 4x Scope", "Enable 4x scope", "gametype_wzenable4xscope", "gametype_wzenable4xscope", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenable4xscope" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenable4xscope" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenable3xscope", Engine[@"getgametypesetting"]( @"wzenable3xscope" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable 3x Scope", "Enable 3x scope", "gametype_wzenable3xscope", "gametype_wzenable3xscope", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenable3xscope" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenable3xscope" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenable2xscope", Engine[@"getgametypesetting"]( @"wzenable2xscope" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable 2x Scope", "Enable 2x scope", "gametype_wzenable2xscope", "gametype_wzenable2xscope", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenable2xscope" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenable2xscope" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenableextbarrel", Engine[@"getgametypesetting"]( @"wzenableextbarrel" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable Extended Barrel", "Enable extended barrel", "gametype_wzenableextbarrel", "gametype_wzenableextbarrel", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenableextbarrel" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenableextbarrel" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenableextfastmag", Engine[@"getgametypesetting"]( @"wzenableextfastmag" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable Extended Fast Mag", "Enable extended fast mag", "gametype_wzenableextfastmag", "gametype_wzenableextfastmag", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenableextfastmag" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenableextfastmag" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenableforegrip", Engine[@"getgametypesetting"]( @"wzenableforegrip" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable Foregrip", "Enable foregrip", "gametype_wzenableforegrip", "gametype_wzenableforegrip", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenableforegrip" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenableforegrip" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenablepistolgrip", Engine[@"getgametypesetting"]( @"wzenablepistolgrip" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable Pistol Grip", "Enable pistol foregrip", "gametype_wzenablepistolgrip", "gametype_wzenablepistolgrip", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenablepistolgrip" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenablepistolgrip" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )
	end

	-- Weapon Spawns
	if BlackoutSettingTab == 3 then
		-- Weapons
		Engine[@"setdvar"]( "gametype_wzrandomcamo", Engine[@"getgametypesetting"]( @"wzrandomcamo" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Random Camo", "Give random camo when picking up weapons", "gametype_wzrandomcamo", "gametype_wzrandomcamo", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzrandomcamo" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzrandomcamo" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )
		
		Engine[@"setdvar"]( "gametype_wzenableicr", Engine[@"getgametypesetting"]( @"wzenableicr" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable ICR", "Enable icr", "gametype_wzenableicr", "gametype_wzenableicr", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenableicr" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenableicr" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenableoperatorweapons", Engine[@"getgametypesetting"]( @"wzenableoperatorweapons" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable Operator Weapons", "Enable operatorweapons", "gametype_wzenableoperatorweapons", "gametype_wzenableoperatorweapons", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenableoperatorweapons" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenableoperatorweapons" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenablekn", Engine[@"getgametypesetting"]( @"wzenablekn" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable KN", "Enable kn", "gametype_wzenablekn", "gametype_wzenablekn", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenablekn" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenablekn" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenablegrav", Engine[@"getgametypesetting"]( @"wzenablegrav" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable GRAV", "Enable grav", "gametype_wzenablegrav", "gametype_wzenablegrav", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenablegrav" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenablegrav" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenablespectregrenade", Engine[@"getgametypesetting"]( @"wzenablespectregrenade" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable Spectre Grenade", "Enable spectre grenade", "gametype_wzenablespectregrenade", "gametype_wzenablespectregrenade", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenablespectregrenade" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenablespectregrenade" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenablevivaldi", Engine[@"getgametypesetting"]( @"wzenablevivaldi" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable Havelina", "Enable havelina", "gametype_wzenablevivaldi", "gametype_wzenablevivaldi", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenablevivaldi" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenablevivaldi" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_zmequipmentisenabled", Engine[@"getgametypesetting"]( @"zmequipmentisenabled" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable Zombies Equipment", "Enable zm equipment", "gametype_zmequipmentisenabled", "gametype_zmequipmentisenabled", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"zmequipmentisenabled" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"zmequipmentisenabled" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenableswat", Engine[@"getgametypesetting"]( @"wzenableswat" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable SWAT", "Enable swat", "gametype_wzenableswat", "gametype_wzenableswat", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenableswat" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenableswat" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenablevapr", Engine[@"getgametypesetting"]( @"wzenablevapr" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable VAPR", "Enable vapr", "gametype_wzenablevapr", "gametype_wzenablevapr", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenablevapr" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenablevapr" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenablemaddox", Engine[@"getgametypesetting"]( @"wzenablemaddox" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable Maddox", "Enable maddox", "gametype_wzenablemaddox", "gametype_wzenablemaddox", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenablemaddox" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenablemaddox" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenablean94", Engine[@"getgametypesetting"]( @"wzenablean94" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable AN94", "Enable an94", "gametype_wzenablean94", "gametype_wzenablean94", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenablean94" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenablean94" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenablerampart", Engine[@"getgametypesetting"]( @"wzenablerampart" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable Rampart", "Enable rampart", "gametype_wzenablerampart", "gametype_wzenablerampart", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenablerampart" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenablerampart" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenabledoublebarrel", Engine[@"getgametypesetting"]( @"wzenabledoublebarrel" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable Echo Hawk", "Enable echohawk", "gametype_wzenabledoublebarrel", "gametype_wzenabledoublebarrel", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenabledoublebarrel" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenabledoublebarrel" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenablegks", Engine[@"getgametypesetting"]( @"wzenablegks" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable GKS", "Enable gks", "gametype_wzenablegks", "gametype_wzenablegks", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenablegks" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenablegks" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenablesaug", Engine[@"getgametypesetting"]( @"wzenablesaug" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable SAUG", "Enable saug", "gametype_wzenablesaug", "gametype_wzenablesaug", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenablesaug" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenablesaug" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenablevmp", Engine[@"getgametypesetting"]( @"wzenablevmp" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable VMP", "Enable vmp", "gametype_wzenablevmp", "gametype_wzenablevmp", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenablevmp" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenablevmp" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenabledaemon", Engine[@"getgametypesetting"]( @"wzenabledaemon" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable Daemon", "Enable daemon", "gametype_wzenabledaemon", "gametype_wzenabledaemon", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenabledaemon" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenabledaemon" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenablemp40", Engine[@"getgametypesetting"]( @"wzenablemp40" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable MP40", "Enable mp40", "gametype_wzenablemp40", "gametype_wzenablemp40", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenablemp40" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenablemp40" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenablemx9", Engine[@"getgametypesetting"]( @"wzenablemx9" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable MX9", "Enable mx9", "gametype_wzenablemx9", "gametype_wzenablemx9", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenablemx9" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenablemx9" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenablecordite", Engine[@"getgametypesetting"]( @"wzenablecordite" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable Cordite", "Enable cordite", "gametype_wzenablecordite", "gametype_wzenablecordite", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenablecordite" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenablecordite" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenablespitfire", Engine[@"getgametypesetting"]( @"wzenablespitfire" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable Spitfire", "Enable spitfire", "gametype_wzenablespitfire", "gametype_wzenablespitfire", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenablespitfire" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenablespitfire" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenableminigun", Engine[@"getgametypesetting"]( @"wzenableminigun" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable Minigun", "Enable minigun", "gametype_wzenableminigun", "gametype_wzenableminigun", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenableminigun" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenableminigun" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenableswitchblade", Engine[@"getgametypesetting"]( @"wzenableswitchblade" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable Switchblade", "Enable switchblade", "gametype_wzenableswitchblade", "gametype_wzenableswitchblade", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenableswitchblade" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenableswitchblade" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenablesdm", Engine[@"getgametypesetting"]( @"wzenablesdm" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable SDM", "Enable sdm", "gametype_wzenablesdm", "gametype_wzenablesdm", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenablesdm" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenablesdm" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenablekoshka", Engine[@"getgametypesetting"]( @"wzenablekoshka" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable Koshka", "Enable koshka", "gametype_wzenablekoshka", "gametype_wzenablekoshka", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenablekoshka" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenablekoshka" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenableoutlaw", Engine[@"getgametypesetting"]( @"wzenableoutlaw" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable Outlaw", "Enable outlaw", "gametype_wzenableoutlaw", "gametype_wzenableoutlaw", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenableoutlaw" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenableoutlaw" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenablepaladin", Engine[@"getgametypesetting"]( @"wzenablepaladin" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable Paladin", "Enable paladin", "gametype_wzenablepaladin", "gametype_wzenablepaladin", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenablepaladin" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenablepaladin" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenablevendetta", Engine[@"getgametypesetting"]( @"wzenablevendetta" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable Vendetta", "Enable vendetta", "gametype_wzenablevendetta", "gametype_wzenablevendetta", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenablevendetta" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenablevendetta" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenablevkm", Engine[@"getgametypesetting"]( @"wzenablevkm" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable VKM", "Enable vkm", "gametype_wzenablevkm", "gametype_wzenablevkm", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenablevkm" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenablevkm" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenablehades", Engine[@"getgametypesetting"]( @"wzenablehades" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable Hades", "Enable hades", "gametype_wzenablehades", "gametype_wzenablehades", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenablehades" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenablehades" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenabletitan", Engine[@"getgametypesetting"]( @"wzenabletitan" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable Titan", "Enable titan", "gametype_wzenabletitan", "gametype_wzenabletitan", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenabletitan" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenabletitan" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenablezweihander", Engine[@"getgametypesetting"]( @"wzenablezweihander" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable Zweihander", "Enable zweihander", "gametype_wzenablezweihander", "gametype_wzenablezweihander", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenablezweihander" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenablezweihander" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenablemozu", Engine[@"getgametypesetting"]( @"wzenablemozu" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable Mozu", "Enable mozu", "gametype_wzenablemozu", "gametype_wzenablemozu", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenablemozu" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenablemozu" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenablestrife", Engine[@"getgametypesetting"]( @"wzenablestrife" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable Strife", "Enable strife", "gametype_wzenablestrife", "gametype_wzenablestrife", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenablestrife" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenablestrife" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenablerk7", Engine[@"getgametypesetting"]( @"wzenablerk7" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable RK7", "Enable rk7", "gametype_wzenablerk7", "gametype_wzenablerk7", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenablerk7" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenablerk7" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenablekap45", Engine[@"getgametypesetting"]( @"wzenablekap45" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable KAP45", "Enable kap45", "gametype_wzenablekap45", "gametype_wzenablekap45", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenablekap45" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenablekap45" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenableauger", Engine[@"getgametypesetting"]( @"wzenableauger" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable Auger", "Enable auger", "gametype_wzenableauger", "gametype_wzenableauger", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenableauger" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenableauger" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenableabr", Engine[@"getgametypesetting"]( @"wzenableabr" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable ABR", "Enable abr", "gametype_wzenableabr", "gametype_wzenableabr", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenableabr" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenableabr" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenableessex", Engine[@"getgametypesetting"]( @"wzenableessex" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable Essex", "Enable essex", "gametype_wzenableessex", "gametype_wzenableessex", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenableessex" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenableessex" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenablem16", Engine[@"getgametypesetting"]( @"wzenablem16" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable M16", "Enable m16", "gametype_wzenablem16", "gametype_wzenablem16", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenablem16" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenablem16" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenableswordfish", Engine[@"getgametypesetting"]( @"wzenableswordfish" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable Swordfish", "Enable swordfish", "gametype_wzenableswordfish", "gametype_wzenableswordfish", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenableswordfish" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenableswordfish" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenablesg12", Engine[@"getgametypesetting"]( @"wzenablesg12" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable SG12", "Enable sg12", "gametype_wzenablesg12", "gametype_wzenablesg12", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenablesg12" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenablesg12" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenablemog12", Engine[@"getgametypesetting"]( @"wzenablemog12" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable MOG12", "Enable mog12", "gametype_wzenablemog12", "gametype_wzenablemog12", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenablemog12" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenablemog12" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenablerampage", Engine[@"getgametypesetting"]( @"wzenablerampage" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable Rampage", "Enable rampage", "gametype_wzenablerampage", "gametype_wzenablerampage", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenablerampage" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenablerampage" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenableargus", Engine[@"getgametypesetting"]( @"wzenableargus" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable Argus", "Enable argus", "gametype_wzenableargus", "gametype_wzenableargus", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenableargus" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenableargus" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenablelauncher", Engine[@"getgametypesetting"]( @"wzenablelauncher" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable Launcher", "Enable launcher", "gametype_wzenablelauncher", "gametype_wzenablelauncher", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenablelauncher" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenablelauncher" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenablebowieknife", Engine[@"getgametypesetting"]( @"wzenablebowieknife" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable Bowie Knife", "Enable bowieknife", "gametype_wzenablebowieknife", "gametype_wzenablebowieknife", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenablebowieknife" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenablebowieknife" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenablesecretsanta", Engine[@"getgametypesetting"]( @"wzenablesecretsanta" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable Secret Santa", "Enable secretsanta", "gametype_wzenablesecretsanta", "gametype_wzenablesecretsanta", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenablesecretsanta" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenablesecretsanta" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenableslaybell", Engine[@"getgametypesetting"]( @"wzenableslaybell" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable Slaybell", "Enable slaybell", "gametype_wzenableslaybell", "gametype_wzenableslaybell", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenableslaybell" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenableslaybell" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenablestopsign", Engine[@"getgametypesetting"]( @"wzenablestopsign" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable Stop Sign", "Enable stopsign", "gametype_wzenablestopsign", "gametype_wzenablestopsign", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenablestopsign" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenablestopsign" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenablecoinbag", Engine[@"getgametypesetting"]( @"wzenablecoinbag" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable Coin Bag", "Enable coinbag", "gametype_wzenablecoinbag", "gametype_wzenablecoinbag", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenablecoinbag" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenablecoinbag" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenablehomewrecker", Engine[@"getgametypesetting"]( @"wzenablehomewrecker" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable Homewrecker", "Enable homewrecker", "gametype_wzenablehomewrecker", "gametype_wzenablehomewrecker", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenablehomewrecker" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenablehomewrecker" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenablezombiearm", Engine[@"getgametypesetting"]( @"wzenablezombiearm" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable Zombie Arm", "Enable zombiearm", "gametype_wzenablezombiearm", "gametype_wzenablezombiearm", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenablezombiearm" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenablezombiearm" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenableamulet", Engine[@"getgametypesetting"]( @"wzenableamulet" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable Amulet", "Enable amulet", "gametype_wzenableamulet", "gametype_wzenableamulet", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenableamulet" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenableamulet" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenableactionfigure", Engine[@"getgametypesetting"]( @"wzenableactionfigure" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable Action Figure", "Enable actionfigure", "gametype_wzenableactionfigure", "gametype_wzenableactionfigure", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenableactionfigure" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenableactionfigure" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenableraygun", Engine[@"getgametypesetting"]( @"wzenableraygun" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable Ray Gun", "Enable raygun", "gametype_wzenableraygun", "gametype_wzenableraygun", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenableraygun" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenableraygun" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenableblade", Engine[@"getgametypesetting"]( @"wzenableblade" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable Blade", "Enable blade", "gametype_wzenableblade", "gametype_wzenableblade", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenableblade" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenableblade" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenabletrophysystem", Engine[@"getgametypesetting"]( @"wzenabletrophysystem" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable Trophy System", "Enable trophysystem", "gametype_wzenabletrophysystem", "gametype_wzenabletrophysystem", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenabletrophysystem" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenabletrophysystem" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenablefraggrenade", Engine[@"getgametypesetting"]( @"wzenablefraggrenade" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable Frag Grenade", "Enable fraggrenade", "gametype_wzenablefraggrenade", "gametype_wzenablefraggrenade", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenablefraggrenade" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenablefraggrenade" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenablesmokegrenade", Engine[@"getgametypesetting"]( @"wzenablesmokegrenade" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable Smoke Grenade", "Enable smokegrenade", "gametype_wzenablesmokegrenade", "gametype_wzenablesmokegrenade", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenablesmokegrenade" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenablesmokegrenade" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenableacidbomb", Engine[@"getgametypesetting"]( @"wzenableacidbomb" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable Acid Bomb", "Enable acidbomb", "gametype_wzenableacidbomb", "gametype_wzenableacidbomb", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenableacidbomb" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenableacidbomb" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenablewraithfire", Engine[@"getgametypesetting"]( @"wzenablewraithfire" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable Wraithfire", "Enable wraithfire", "gametype_wzenablewraithfire", "gametype_wzenablewraithfire", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenablewraithfire" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenablewraithfire" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenablesparrow", Engine[@"getgametypesetting"]( @"wzenablesparrow" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable Sparrow", "Enable sparrow", "gametype_wzenablesparrow", "gametype_wzenablesparrow", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenablesparrow" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenablesparrow" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenablewarmachine", Engine[@"getgametypesetting"]( @"wzenablewarmachine" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable War Machine", "Enable warmachine", "gametype_wzenablewarmachine", "gametype_wzenablewarmachine", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenablewarmachine" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenablewarmachine" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenableempgrenade", Engine[@"getgametypesetting"]( @"wzenableempgrenade" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable EMP Grenade", "Enable empgrenade", "gametype_wzenableempgrenade", "gametype_wzenableempgrenade", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenableempgrenade" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenableempgrenade" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenablemolotov", Engine[@"getgametypesetting"]( @"wzenablemolotov" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable Molotov", "Enable molotov", "gametype_wzenablemolotov", "gametype_wzenablemolotov", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenablemolotov" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenablemolotov" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenableclustergrenade", Engine[@"getgametypesetting"]( @"wzenableclustergrenade" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable Cluster Grenade", "Enable clustergrenade", "gametype_wzenableclustergrenade", "gametype_wzenableclustergrenade", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenableclustergrenade" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenableclustergrenade" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenableannihilator", Engine[@"getgametypesetting"]( @"wzenableannihilator" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable Annihilator", "Enable annihilator", "gametype_wzenableannihilator", "gametype_wzenableannihilator", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenableannihilator" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenableannihilator" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenabledeathoforion", Engine[@"getgametypesetting"]( @"wzenabledeathoforion" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable Death of Orion", "Enable death of orion", "gametype_wzenabledeathoforion", "gametype_wzenabledeathoforion", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenabledeathoforion" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenabledeathoforion" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenablesentrygun", Engine[@"getgametypesetting"]( @"wzenablesentrygun" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable Sentry Gun", "Enable sentry gun", "gametype_wzenablesentrygun", "gametype_wzenablesentrygun", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenablesentrygun" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenablesentrygun" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenablesavageimpaler", Engine[@"getgametypesetting"]( @"wzenablesavageimpaler" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable Savage Impaler", "Enable savageimpaler", "gametype_wzenablesavageimpaler", "gametype_wzenablesavageimpaler", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenablesavageimpaler" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenablesavageimpaler" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenableconcussiongrenade", Engine[@"getgametypesetting"]( @"wzenableconcussiongrenade" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable Concussion Grenade", "Enable concussiongrenade", "gametype_wzenableconcussiongrenade", "gametype_wzenableconcussiongrenade", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenableconcussiongrenade" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenableconcussiongrenade" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenablesniperscope", Engine[@"getgametypesetting"]( @"wzenablesniperscope" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable Sniper Scope", "Enable sniperscope", "gametype_wzenablesniperscope", "gametype_wzenablesniperscope", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenablesniperscope" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenablesniperscope" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenablerazorwire", Engine[@"getgametypesetting"]( @"wzenablerazorwire" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable Razor Wire", "Enable razorwire", "gametype_wzenablerazorwire", "gametype_wzenablerazorwire", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenablerazorwire" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenablerazorwire" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenablesensordart", Engine[@"getgametypesetting"]( @"wzenablesensordart" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable Sensor Dart", "Enable sensordart", "gametype_wzenablesensordart", "gametype_wzenablesensordart", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenablesensordart" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenablesensordart" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenablecombataxe", Engine[@"getgametypesetting"]( @"wzenablecombataxe" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable Combat Axe", "Enable combataxe", "gametype_wzenablecombataxe", "gametype_wzenablecombataxe", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenablecombataxe" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenablecombataxe" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenablesuppressor", Engine[@"getgametypesetting"]( @"wzenablesuppressor" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable Suppressor", "Enable suppressor", "gametype_wzenablesuppressor", "gametype_wzenablesuppressor", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenablesuppressor" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenablesuppressor" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_701bac755292fab2", Engine[@"getgametypesetting"]( @"hash_701bac755292fab2" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Spawn Icarus", "Spawn icarus", "gametype_701bac755292fab2", "gametype_701bac755292fab2", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"hash_701bac755292fab2" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"hash_701bac755292fab2" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenableraygunmark2", Engine[@"getgametypesetting"]( @"wzenableraygunmark2" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable Ray Gun MK2", "Enable raygun mk2", "gametype_wzenableraygunmark2", "gametype_wzenableraygunmark2", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenableraygunmark2" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenableraygunmark2" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenablewintersfury", Engine[@"getgametypesetting"]( @"wzenablewintersfury" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable Winters Fury", "Enable winters fury", "gametype_wzenablewintersfury", "gametype_wzenablewintersfury", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenablewintersfury" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenablewintersfury" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenableflareguns", Engine[@"getgametypesetting"]( @"wzenableflareguns" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable Flare Guns", "Enable flareguns", "gametype_wzenableflareguns", "gametype_wzenableflareguns", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenableflareguns" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenableflareguns" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenablegambit22", Engine[@"getgametypesetting"]( @"wzenablegambit22" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable Gambit 22", "Enable gambit22", "gametype_wzenablegambit22", "gametype_wzenablegambit22", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenablegambit22" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenablegambit22" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenablehellsretriever", Engine[@"getgametypesetting"]( @"wzenablehellsretriever" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable Hells Retriever", "Enable hellsretriever", "gametype_wzenablehellsretriever", "gametype_wzenablehellsretriever", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenablehellsretriever" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenablehellsretriever" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenablewallbuyasylum", Engine[@"getgametypesetting"]( @"wzenablewallbuyasylum" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Wallbuy Asylum", "Enable wall buy asylum", "gametype_wzenablewallbuyasylum", "gametype_wzenablewallbuyasylum", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenablewallbuyasylum" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenablewallbuyasylum" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenablewallbuynuketown", Engine[@"getgametypesetting"]( @"wzenablewallbuynuketown" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Wallbuy Nuketown", "Enable wall buy nuketown", "gametype_wzenablewallbuynuketown", "gametype_wzenablewallbuynuketown", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenablewallbuynuketown" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenablewallbuynuketown" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenablewallbuycemetary", Engine[@"getgametypesetting"]( @"wzenablewallbuycemetary" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Wallbuy Cemetery", "Enable wallbuy cemetery", "gametype_wzenablewallbuycemetary", "gametype_wzenablewallbuycemetary", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenablewallbuycemetary" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenablewallbuycemetary" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenablewallbuydiner", Engine[@"getgametypesetting"]( @"wzenablewallbuydiner" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Wallbuy Diner", "Enable wallbuy diner", "gametype_wzenablewallbuydiner", "gametype_wzenablewallbuydiner", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenablewallbuydiner" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenablewallbuydiner" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenablewallbuyfarm", Engine[@"getgametypesetting"]( @"wzenablewallbuyfarm" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Wallbuy Farm", "Enable wallbuy farm", "gametype_wzenablewallbuyfarm", "gametype_wzenablewallbuyfarm", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenablewallbuyfarm" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenablewallbuyfarm" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenablewallbuylighthouse", Engine[@"getgametypesetting"]( @"wzenablewallbuylighthouse" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Wallbuy Lighthouse", "Enable wallbuy lighthouse", "gametype_wzenablewallbuylighthouse", "gametype_wzenablewallbuylighthouse", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenablewallbuylighthouse" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenablewallbuylighthouse" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenablewallbuyboxinggym", Engine[@"getgametypesetting"]( @"wzenablewallbuyboxinggym" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Wallbuy Boxing Gym", "Enable wallbuy boxing gym", "gametype_wzenablewallbuyboxinggym", "gametype_wzenablewallbuyboxinggym", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenablewallbuyboxinggym" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenablewallbuyboxinggym" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenablewallbuyghosttown", Engine[@"getgametypesetting"]( @"wzenablewallbuyghosttown" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Wallbuy Ghost Town", "Enable wallbuy ghosttown", "gametype_wzenablewallbuyghosttown", "gametype_wzenablewallbuyghosttown", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenablewallbuyghosttown" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenablewallbuyghosttown" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )
	end

	-- Perks Spawns
	if BlackoutSettingTab == 4 then
		Engine[@"setdvar"]( "gametype_wzenableperkawareness", Engine[@"getgametypesetting"]( @"wzenableperkawareness" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable Perk Awareness", "Enable perk awareness", "gametype_wzenableperkawareness", "gametype_wzenableperkawareness", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenableperkawareness" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenableperkawareness" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenableperkbrawler", Engine[@"getgametypesetting"]( @"wzenableperkbrawler" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable Perk Brawler", "Enable perk brawler", "gametype_wzenableperkbrawler", "gametype_wzenableperkbrawler", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenableperkbrawler" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenableperkbrawler" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenableperkconsumer", Engine[@"getgametypesetting"]( @"wzenableperkconsumer" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable Perk Consumer", "Enable perk consumer", "gametype_wzenableperkconsumer", "gametype_wzenableperkconsumer", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenableperkconsumer" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenableperkconsumer" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenableperkdeadsilence", Engine[@"getgametypesetting"]( @"wzenableperkdeadsilence" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable Perk Deadsilence", "Enable perk deadsilence", "gametype_wzenableperkdeadsilence", "gametype_wzenableperkdeadsilence", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenableperkdeadsilence" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenableperkdeadsilence" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenableperkengineer", Engine[@"getgametypesetting"]( @"wzenableperkengineer" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable Perk Engineer", "Enable perk engineer", "gametype_wzenableperkengineer", "gametype_wzenableperkengineer", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenableperkengineer" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenableperkengineer" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenableperkironlungs", Engine[@"getgametypesetting"]( @"wzenableperkironlungs" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable Perk Iron Lungs", "Enable perk ironlungs", "gametype_wzenableperkironlungs", "gametype_wzenableperkironlungs", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenableperkironlungs" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenableperkironlungs" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenableperklooter", Engine[@"getgametypesetting"]( @"wzenableperklooter" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable Perk Looter", "Enable perk looter", "gametype_wzenableperklooter", "gametype_wzenableperklooter", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenableperklooter" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenableperklooter" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenableperkmedic", Engine[@"getgametypesetting"]( @"wzenableperkmedic" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable Perk Medic", "Enable perk medic", "gametype_wzenableperkmedic", "gametype_wzenableperkmedic", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenableperkmedic" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenableperkmedic" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenableperkmobility", Engine[@"getgametypesetting"]( @"wzenableperkmobility" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable Perk Mobility", "Enable perk mobility", "gametype_wzenableperkmobility", "gametype_wzenableperkmobility", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenableperkmobility" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenableperkmobility" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenableperkoutlander", Engine[@"getgametypesetting"]( @"wzenableperkoutlander" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable Perk Outlander", "Enable perk outlander", "gametype_wzenableperkoutlander", "gametype_wzenableperkoutlander", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenableperkoutlander" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenableperkoutlander" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenableperkparanoia", Engine[@"getgametypesetting"]( @"wzenableperkparanoia" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable Perk Paranoia", "Enable perk paranoia", "gametype_wzenableperkparanoia", "gametype_wzenableperkparanoia", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenableperkparanoia" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenableperkparanoia" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenableperkreinforced", Engine[@"getgametypesetting"]( @"wzenableperkreinforced" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable Perk Reinforced", "Enable perk reinforced", "gametype_wzenableperkreinforced", "gametype_wzenableperkreinforced", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenableperkreinforced" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenableperkreinforced" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenableperksquadlink", Engine[@"getgametypesetting"]( @"wzenableperksquadlink" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable Perk Squadlink", "Enable perk squadlink", "gametype_wzenableperksquadlink", "gametype_wzenableperksquadlink", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenableperksquadlink" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenableperksquadlink" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_1d02e28ba907a343", Engine[@"getgametypesetting"]( @"hash_1d02e28ba907a343" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable Perk Tracker", "Enable perk tracker", "gametype_1d02e28ba907a343", "gametype_1d02e28ba907a343", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"hash_1d02e28ba907a343" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"hash_1d02e28ba907a343" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenableperkstimulant", Engine[@"getgametypesetting"]( @"wzenableperkstimulant" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable Perk Stimulant", "Enable perk stimulant", "gametype_wzenableperkstimulant", "gametype_wzenableperkstimulant", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenableperkstimulant" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenableperkstimulant" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_78e459ad87509a46", Engine[@"getgametypesetting"]( @"hash_78e459ad87509a46" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable Perk Skulker", "Enable perk skulker", "gametype_78e459ad87509a46", "gametype_78e459ad87509a46", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"hash_78e459ad87509a46" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"hash_78e459ad87509a46" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

	end

	-- Vehicle Spawns
	if BlackoutSettingTab == 6 then
		Engine[@"setdvar"]( "gametype_wzenablereplacercar", Engine[@"getgametypesetting"]( @"wzenablereplacercar" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable Replacer Car", "Vehicle spawn enable replacer car", "gametype_wzenablereplacercar", "gametype_wzenablereplacercar", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenablereplacercar" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenablereplacercar" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenablereconcar", Engine[@"getgametypesetting"]( @"wzenablereconcar" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable Recon Car", "Enable rcxd", "gametype_wzenablereconcar", "gametype_wzenablereconcar", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenablereconcar" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenablereconcar" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenableheavymetalvehicles", Engine[@"getgametypesetting"]( @"wzenableheavymetalvehicles" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable Heavy Metal Vehicles", "Vehicle spawn heavy metal vehicles", "gametype_wzenableheavymetalvehicles", "gametype_wzenableheavymetalvehicles", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenableheavymetalvehicles" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenableheavymetalvehicles" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenableattacklittlebird", Engine[@"getgametypesetting"]( @"wzenableattacklittlebird" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable Attack Little Bird", "Enable attack helicopter littlebird", "gametype_wzenableattacklittlebird", "gametype_wzenableattacklittlebird", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenableattacklittlebird" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenableattacklittlebird" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenablelittlebird", Engine[@"getgametypesetting"]( @"wzenablelittlebird" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable Little Bird", "Enable helicopter littlebird", "gametype_wzenablelittlebird", "gametype_wzenablelittlebird", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenablelittlebird" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenablelittlebird" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_7695bdd7b20cdda", Engine[@"getgametypesetting"]( @"hash_7695bdd7b20cdda" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Muscle Car Replacement", "Allow to convert the replacer's muscle car", "gametype_7695bdd7b20cdda", "gametype_7695bdd7b20cdda", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"hash_7695bdd7b20cdda" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"hash_7695bdd7b20cdda" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )


		Engine[@"setdvar"]( "gametype_wzenableatv", Engine[@"getgametypesetting"]( @"wzenableatv" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable ATV", "Enable atv", "gametype_wzenableatv", "gametype_wzenableatv", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenableatv" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenableatv" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenablesuv", Engine[@"getgametypesetting"]( @"wzenablesuv" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable SUV", "Enable suv", "gametype_wzenablesuv", "gametype_wzenablesuv", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenablesuv" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenablesuv" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenabletacticalraft", Engine[@"getgametypesetting"]( @"wzenabletacticalraft" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable Tactical Raft", "Enable tactical raft", "gametype_wzenabletacticalraft", "gametype_wzenabletacticalraft", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenabletacticalraft" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenabletacticalraft" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenablecargotruck", Engine[@"getgametypesetting"]( @"wzenablecargotruck" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable Cargo Truck", "Enable cargo truck", "gametype_wzenablecargotruck", "gametype_wzenablecargotruck", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenablecargotruck" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenablecargotruck" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenabletank", Engine[@"getgametypesetting"]( @"wzenabletank" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable Tank", "Enables tank", "gametype_wzenabletank", "gametype_wzenabletank", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenabletank" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenabletank" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenablepbr", Engine[@"getgametypesetting"]( @"wzenablepbr" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable PBR Boat", "Enable pbr boat", "gametype_wzenablepbr", "gametype_wzenablepbr", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenablepbr" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenablepbr" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenablearav", Engine[@"getgametypesetting"]( @"wzenablearav" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable ARAV", "Enable arav", "gametype_wzenablearav", "gametype_wzenablearav", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenablearav" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenablearav" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenablemotorcycle", Engine[@"getgametypesetting"]( @"wzenablemotorcycle" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable Motorcycle", "Enable motorcycle", "gametype_wzenablemotorcycle", "gametype_wzenablemotorcycle", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenablemotorcycle" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenablemotorcycle" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenablemusclecar", Engine[@"getgametypesetting"]( @"wzenablemusclecar" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable Muscle Car", "Enable muscle car", "gametype_wzenablemusclecar", "gametype_wzenablemusclecar", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenablemusclecar" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenablemusclecar" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )
	end

	-- Characters Unlocking
	if BlackoutSettingTab == 8 then
		Engine[@"setdvar"]( "gametype_50b1121aee76a7e4", Engine[@"getgametypesetting"]( @"hash_50b1121aee76a7e4" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Characters Unlocking", "Allow to Unlock Characters", "gametype_50b1121aee76a7e4", "gametype_50b1121aee76a7e4", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"hash_50b1121aee76a7e4" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"hash_50b1121aee76a7e4" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		local characterHashes = {
			{hash = @"hash_d084b5063bb0c55", name = "Ajax", dvar = "gametype_d084b5063bb0c55"},
			{hash = @"hash_4c66b817adba935c", name = "Crash", dvar = "gametype_4c66b817adba935c"},
			{hash = @"hash_2cd26947d8f311fa", name = "Battery", dvar = "gametype_2cd26947d8f311fa"},
			{hash = @"hash_75370c9c920502fc", name = "Firebreak", dvar = "gametype_75370c9c920502fc"},
			{hash = @"hash_26843909f5fdef20", name = "Nomad", dvar = "gametype_26843909f5fdef20"},
			{hash = @"hash_52d705a46da9e55f", name = "Outrider", dvar = "gametype_52d705a46da9e55f"},
			{hash = @"hash_7cf82cc41c0f0d5", name = "Prophet", dvar = "gametype_7cf82cc41c0f0d5"},
			{hash = @"hash_6b1ec01fa78af670", name = "Reaper", dvar = "gametype_6b1ec01fa78af670"},
			{hash = @"hash_34ea44c91776e52c", name = "Recon", dvar = "gametype_34ea44c91776e52c"},
			{hash = @"hash_4f0a6d1e98cdbf81", name = "Ruin", dvar = "gametype_4f0a6d1e98cdbf81"},
			{hash = @"hash_183bcc0f6737224a", name = "Seraph", dvar = "gametype_183bcc0f6737224a"},
			{hash = @"hash_6fe34e77ba14d86f", name = "Spectre", dvar = "gametype_6fe34e77ba14d86f"},
			{hash = @"hash_3d719d86f2f3f14d", name = "Torque", dvar = "gametype_3d719d86f2f3f14d"},
			{hash = @"hash_19c58d35b2ea8d15", name = "Zero", dvar = "gametype_19c58d35b2ea8d15"},
			{hash = @"hash_2dfb36064be05f03", name = "Bruno", dvar = "gametype_2dfb36064be05f03"},
			{hash = @"hash_4547b7ecb49469f0", name = "Bruno (IX)", dvar = "gametype_4547b7ecb49469f0"},
			{hash = @"hash_7fc2867a4b8594bf", name = "Diego", dvar = "gametype_7fc2867a4b8594bf"},
			{hash = @"hash_ff653cbb1438270", name = "Diego (IX)", dvar = "gametype_ff653cbb1438270"},
			{hash = @"hash_7049c01d7ddf9b35", name = "Scarlett", dvar = "gametype_7049c01d7ddf9b35"},
			{hash = @"hash_2b0f9caa00363ee8", name = "Scarlett (IX)", dvar = "gametype_2b0f9caa00363ee8"},
			{hash = @"hash_20f3ff8fbb8d8295", name = "Mason", dvar = "gametype_20f3ff8fbb8d8295"},
			{hash = @"hash_1d50c09e8021ab1", name = "Menendez", dvar = "gametype_1d50c09e8021ab1"},
			{hash = @"hash_47242abeaa29479b", name = "Reznov", dvar = "gametype_47242abeaa29479b"},
			{hash = @"hash_265bdda9362c5a35", name = "Woods", dvar = "gametype_265bdda9362c5a35"},
			{hash = @"hash_2574d482086ec9d8", name = "Nikolai", dvar = "gametype_2574d482086ec9d8"},
			{hash = @"hash_1d4c395693ce04fe", name = "Dempsey", dvar = "gametype_1d4c395693ce04fe"},
			{hash = @"hash_19667f3338ed6b1f", name = "Richtofen", dvar = "gametype_19667f3338ed6b1f"},
			{hash = @"hash_26186b4e5dc9bb6f", name = "Takeo", dvar = "gametype_26186b4e5dc9bb6f"},
			{hash = @"hash_5ea56d63c68b4396", name = "Shaw", dvar = "gametype_5ea56d63c68b4396"},
			{hash = @"hash_1ec2d38a40e97c55", name = "Shaw (IX)", dvar = "gametype_1ec2d38a40e97c55"}
		}

		for _, character in ipairs(characterHashes) do
			Engine[@"setdvar"]( character.dvar, Engine[@"getgametypesetting"]( character.hash ) or 0 )
			table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, character.name, "Allow to unlock " .. character.name, character.dvar, character.dvar, {
				{
					option = "Off",
					value = 0,
					default = Engine[@"getgametypesetting"]( character.hash ) == 0
				},
				{
					option = "On",
					value = 1,
					default = Engine[@"getgametypesetting"]( character.hash ) == 1
				}
			}, nil, OnWzSettingDataChange ) )
		end
	end
	
	-- Misc
	if BlackoutSettingTab == 7 then
		Engine[@"setdvar"]( "gametype_wztestallvehicles", Engine[@"getgametypesetting"]( @"wztestallvehicles" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Test All Vehicles", "Enable all vehicles", "gametype_wztestallvehicles", "gametype_wztestallvehicles", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wztestallvehicles" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wztestallvehicles" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_23e09b48546a7e3b", Engine[@"getgametypesetting"]( @"hash_23e09b48546a7e3b" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Vehicle Spawn Related", "Vehicle spawn related unknown", "gametype_23e09b48546a7e3b", "gametype_23e09b48546a7e3b", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"hash_23e09b48546a7e3b" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"hash_23e09b48546a7e3b" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_464afa49c60793b7", Engine[@"getgametypesetting"]( @"hash_464afa49c60793b7" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Detach Gun on Shoot", "Detach gun from favorite when shoot", "gametype_464afa49c60793b7", "gametype_464afa49c60793b7", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"hash_464afa49c60793b7" ) and Engine[@"getgametypesetting"]( @"hash_464afa49c60793b7" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"hash_464afa49c60793b7" ) and Engine[@"getgametypesetting"]( @"hash_464afa49c60793b7" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzaizones", Engine[@"getgametypesetting"]( @"wzaizones" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "AI Zones", "Create AI zones", "gametype_wzaizones", "gametype_wzaizones", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzaizones" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzaizones" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzzonerandom", Engine[@"getgametypesetting"]( @"wzzonerandom" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Random Zones", "Random zones", "gametype_wzzonerandom", "gametype_wzzonerandom", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzzonerandom" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzzonerandom" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzenablewaverespawn", Engine[@"getgametypesetting"]( @"wzenablewaverespawn" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Enable Wave Respawn", "Enable waverespawn", "gametype_wzenablewaverespawn", "gametype_wzenablewaverespawn", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzenablewaverespawn" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzenablewaverespawn" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzintersectdeathcircle", Engine[@"getgametypesetting"]( @"wzintersectdeathcircle" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Intersect Death Circle", "Intersect death circle", "gametype_wzintersectdeathcircle", "gametype_wzintersectdeathcircle", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzintersectdeathcircle" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzintersectdeathcircle" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzspawnanywhere", Engine[@"getgametypesetting"]( @"wzspawnanywhere" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Spawn Anywhere", "Spawn anywhere", "gametype_wzspawnanywhere", "gametype_wzspawnanywhere", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzspawnanywhere" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzspawnanywhere" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_wzweaponstest", Engine[@"getgametypesetting"]( @"wzweaponstest" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Weapons Test", "Weapon test items", "gametype_wzweaponstest", "gametype_wzweaponstest", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"wzweaponstest" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"wzweaponstest" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_26f00de198472b81", Engine[@"getgametypesetting"]( @"hash_26f00de198472b81" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Unknown Zombies Setting Related", "Unknown Zombies related", "gametype_26f00de198472b81", "gametype_26f00de198472b81", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"hash_26f00de198472b81" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"hash_26f00de198472b81" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_232750b87390cbff", Engine[@"getgametypesetting"]( @"hash_232750b87390cbff" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Unknown Wall Buy Setting Related", "Unknown Wall buy related", "gametype_232750b87390cbff", "gametype_232750b87390cbff", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"hash_232750b87390cbff" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"hash_232750b87390cbff" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_1bcb7e5d76212b76", Engine[@"getgametypesetting"]( @"hash_1bcb7e5d76212b76" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Unknown Luck Setting", "Unknown, Set 20% the luck of something (ai related)", "gametype_1bcb7e5d76212b76", "gametype_1bcb7e5d76212b76", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"hash_1bcb7e5d76212b76" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"hash_1bcb7e5d76212b76" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_2b2c167cf8889749", Engine[@"getgametypesetting"]( @"hash_2b2c167cf8889749" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "ZM AI Related", "ZM AI related", "gametype_2b2c167cf8889749", "gametype_2b2c167cf8889749", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"hash_2b2c167cf8889749" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"hash_2b2c167cf8889749" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )

		Engine[@"setdvar"]( "gametype_731aac1992af2669", Engine[@"getgametypesetting"]( @"hash_731aac1992af2669" ) or 0 )
		table.insert( Settings, CreateDvarSettingsNoLocalize( f138_arg0, "Death circle end at location", "wz_escape death circle set random end location to Parade/NewIndustries/CellHouse", "gametype_731aac1992af2669", "gametype_731aac1992af2669", {
			{
				option = "Off",
				value = 0,
				default = Engine[@"getgametypesetting"]( @"hash_731aac1992af2669" ) == 0
			},
			{
				option = "On",
				value = 1,
				default = Engine[@"getgametypesetting"]( @"hash_731aac1992af2669" ) == 1
			}
		}, nil, OnWzSettingDataChange ) )
	end
	
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

-- blackout rules options
CoD.BlackoutRulesContainer = InheritFrom( LUI.UIElement )
CoD.BlackoutRulesContainer.__defaultWidth = 1600
CoD.BlackoutRulesContainer.__defaultHeight = 620
CoD.BlackoutRulesContainer.new = function ( f1_arg0, f1_arg1, f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	local self = LUI.UIElement.new( f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	self:setClass( CoD.BlackoutRulesContainer )
	self.id = "BlackoutRulesContainer"
	self.soundSet = "default"
	self.onlyChildrenFocusable = true
	self.anyChildUsesUpdateState = true
	
	local MiscSettingsList = LUI.UIList.new( f1_arg0, f1_arg1, 3, 3, nil, false, false, false, false )
	MiscSettingsList:setLeftRight( 0.50, 0.50, -700.00, 250.00 )
	MiscSettingsList:setTopBottom( 0.00, 0.00, -180.00, -120.00  )
	MiscSettingsList:setVerticalCounter( CoD.verticalCounter_no_buttons )
	MiscSettingsList:setVerticalCount(10)
	MiscSettingsList:setHorizontalCount(1)
	MiscSettingsList:setAutoScaleContent( true )
	MiscSettingsList:setWidgetType( CoD.CustomGames_SettingSliderNoCustom_NoLocalize )
	MiscSettingsList:setAlignment( Enum[@"luialignment"][@"lui_alignment_left"] )
	MiscSettingsList:setDataSource( "RulesSettingsDataBlackout" )
	self:addElement( MiscSettingsList )
	self.MiscSettingsList = MiscSettingsList

	--LUI_DebugElement(f1_arg0, f1_arg1, self, MiscSettingsList, "MiscSettingsList", 10)

	if Engine[@"getdvarint"]("shield_ui_color") == 0 then
		MiscSettingsList:setRGB(0, 1, 1)
	elseif Engine[@"getdvarint"]("shield_ui_color") == 1 then
		MiscSettingsList:setRGB(1, 0, 0)
	elseif Engine[@"getdvarint"]("shield_ui_color") == 2 then
		MiscSettingsList:setRGB(0, 1, 0)
	end

	-- sep
	local HeaderPixSep = LUI.UIImage.new( 0.5, 0.5, 280, 310, 0.5, 0.5, -550, 350 )
	HeaderPixSep:setAlpha( 0.25 )
	HeaderPixSep:setImage( RegisterImage( @"hash_CB07CCC28498CB2" ) )
	--HeaderPixSep:setMaterial( LUI.UIImage.GetCachedMaterial( @"hash_16CBE95C250C6D15" ) )
	HeaderPixSep:setShaderVector( 0, 0, 0, 0, 0 )
	HeaderPixSep:setupNineSliceShader( 128, 128 )
	self:addElement( HeaderPixSep )
	self.HeaderPixSep = HeaderPixSep

	local SettingDescription = LUI.UIText.new( 0.50, 0.50, 320.51, 896.51, 0.55, 0.55, -460.00, -420.00 )
	SettingDescription:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )
	SettingDescription:setTTF( "notosans_regular" )
	SettingDescription:setAlignment( Enum[@"luialignment"][@"lui_alignment_left"] )
	SettingDescription:setAlignment( Enum[@"luialignment"][@"lui_alignment_top"] )
	self:addElement( SettingDescription )
	self.SettingDescription = SettingDescription

	--LUI_DebugElement(f1_arg0, f1_arg1, self, SettingDescription, "SettingDescription", 10)

	local Tip_Info = LUI.UIText.new( 0.50, 0.50, -464.00, 300.00, 0.55, 0.55, 232.49, 260.00 )
	Tip_Info:setText("Some rules are incompatable with other ones and some won't work on certain maps. Hover over each rule for more info.")
	Tip_Info:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )
	Tip_Info:setTTF( "notosans_regular" )
	Tip_Info:setAlignment( Enum[@"luialignment"][@"lui_alignment_left"] )
	Tip_Info:setAlignment( Enum[@"luialignment"][@"lui_alignment_top"] )
	self:addElement( Tip_Info )
	self.Tip_Info = Tip_Info

	--LUI_DebugElement(f1_arg0, f1_arg1, self, Tip_Info, "Tip_Info", 10)

	SettingDescription:linkToElementModel( MiscSettingsList, "desc", true, function ( model )
		local f7_local0 = model:get()
		if f7_local0 ~= nil then
			SettingDescription:setText( f7_local0 )

			-- fix issues with scroller
			MiscSettingsList:updateDataSource()
		end
	end )

	MiscSettingsList.id = "MiscSettingsList"
	self.__defaultFocus = MiscSettingsList

	LUI.OverrideFunction_CallOriginalSecond( self, "close", self.__onClose )
	
	if PostLoadFunc then
		PostLoadFunc( self, f1_arg1, f1_arg0 )
	end

	return self
end

CoD.BlackoutRulesContainer.__onClose = function ( f9_arg0 )
	f9_arg0.SettingDescription:close()
	f9_arg0.MiscSettingsList:close()
	f9_arg0.Tip_Info:close()
	f9_arg0.HeaderPixSep:close()
end

-- Blackout Rules Background Style
CoD.RulesCommonCenteredPopup = InheritFrom( LUI.UIElement )
CoD.RulesCommonCenteredPopup.__defaultWidth = 1920
CoD.RulesCommonCenteredPopup.__defaultHeight = 1080
CoD.RulesCommonCenteredPopup.new = function ( f1_arg0, f1_arg1, f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	local self = LUI.UIElement.new( f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	self:setClass( CoD.RulesCommonCenteredPopup )
	self.id = "RulesCommonCenteredPopup"
	self.soundSet = "default"
	self.onlyChildrenFocusable = true
	self.anyChildUsesUpdateState = true
	
	local BlackfadeBlurB = LUI.UIImage.new( 0, 1, -5, 5, 0, 1, -5, 5 )
	BlackfadeBlurB:setRGB( 0, 0, 0 )
	BlackfadeBlurB:setMaterial( LUI.UIImage.GetCachedMaterial( @"hash_E2354BE557C4C7A" ) )
	BlackfadeBlurB:setShaderVector( 0, 0, 0, 0, 0 )
	self:addElement( BlackfadeBlurB )
	self.BlackfadeBlurB = BlackfadeBlurB
	
	local BlackfadeBlurF = LUI.UIImage.new( 0, 1, -5, 5, 0, 1, -5, 5 )
	BlackfadeBlurF:setRGB( 0, 0, 0 )
	BlackfadeBlurF:setAlpha( 0.6 )
	self:addElement( BlackfadeBlurF )
	self.BlackfadeBlurF = BlackfadeBlurF
	
	local CenterBackground = LUI.UIImage.new( 0.5, 0.5, -348 - 1000, 348 + 1000, 0.5, 0.5, -500, 500 )
	CenterBackground:setRGB( 0.09, 0.09, 0.09 )
	CenterBackground:setAlpha( 0.9 )
	self:addElement( CenterBackground )
	self.CenterBackground = CenterBackground
	
	local CenterTiledBacking = LUI.UIImage.new( 0.5, 0.5, -348 - 1000, 348 + 1000, 0.5, 0.5, -500, 500 )
	CenterTiledBacking:setAlpha( 0.25 )
	CenterTiledBacking:setImage( RegisterImage( @"hash_634839E8065B1E53" ) )
	CenterTiledBacking:setMaterial( LUI.UIImage.GetCachedMaterial( @"hash_16CBE95C250C6D15" ) )
	CenterTiledBacking:setShaderVector( 0, 0, 0, 0, 0 )
	CenterTiledBacking:setupNineSliceShader( 196, 88 )
	self:addElement( CenterTiledBacking )
	self.CenterTiledBacking = CenterTiledBacking
	
	local buttons = CoD.fe_LeftContainer_NOTLobby.new( f1_arg0, f1_arg1, 0.5, 0.5, -312, 336, 0.5, 0.5, 439, 487 )
	self:addElement( buttons )
	self.buttons = buttons
	
	local featureOverlayButtonMouseOnly = nil
	
	featureOverlayButtonMouseOnly = CoD.featureOverlay_Button.new( f1_arg0, f1_arg1, 0.5, 0.5, -333 + 950, -147 + 950, 0.5, 0.5, 424, 484 )
	featureOverlayButtonMouseOnly.ButtonContainer.Title:setText( Engine[@"hash_4F9F1239CFD921FE"]( @"hash_778D439E1B360368" ) )
	featureOverlayButtonMouseOnly:registerEventHandler( "gain_focus", function ( element, event )
		local f2_local0 = nil
		if element.gainFocus then
			f2_local0 = element:gainFocus( event )
		elseif element.super.gainFocus then
			f2_local0 = element.super:gainFocus( event )
		end
		CoD.Menu.UpdateButtonShownState( element, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
		return f2_local0
	end )
	f1_arg0:AddButtonCallbackFunction( featureOverlayButtonMouseOnly, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], "ui_confirm", function ( element, menu, controller, model )
		GoBack( self, controller )
		return true
	end, function ( element, menu, controller )
		CoD.Menu.SetButtonLabel( menu, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], @"hash_0", nil, "ui_confirm" )
		return false
	end, false )
	self:addElement( featureOverlayButtonMouseOnly )
	self.featureOverlayButtonMouseOnly = featureOverlayButtonMouseOnly

	local reset_defaults = nil
	
	reset_defaults = CoD.featureOverlay_Button.new( f1_arg0, f1_arg1, 0.5, 0.5, -333 + 750, -147 + 750, 0.5, 0.5, 424, 484 )
	reset_defaults.ButtonContainer.Title:setText( "Reset Options" )
	reset_defaults:registerEventHandler( "gain_focus", function ( element, event )
		local f2_local0 = nil
		if element.gainFocus then
			f2_local0 = element:gainFocus( event )
		elseif element.super.gainFocus then
			f2_local0 = element.super:gainFocus( event )
		end
		CoD.Menu.UpdateButtonShownState( element, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
		return f2_local0
	end )
	f1_arg0:AddButtonCallbackFunction( reset_defaults, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], "ui_confirm", function ( element, menu, controller, model )
		OpenResetGameSettingsPopupWZ( self, element, controller, "", menu )
		return true
	end, function ( element, menu, controller )
		CoD.Menu.SetButtonLabel( menu, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], @"hash_0", nil, "ui_confirm" )
		return false
	end, false )
	self:addElement( reset_defaults )
	self.reset_defaults = reset_defaults
	
	local LayoutBottomBar = LUI.UIImage.new( 0.5, 0.5, -349.5 - 1000, 349.5 + 1000, 0.5, 0.5, 473, 501 )
	LayoutBottomBar:setZRot( 180 )
	LayoutBottomBar:setImage( RegisterImage( @"hash_87C348C36FF085C" ) )
	self:addElement( LayoutBottomBar )
	self.LayoutBottomBar = LayoutBottomBar
	
	local LayoutTopBar = LUI.UIImage.new( 0.5, 0.5, -349.5 - 1000, 349.5 + 1000, 0.5, 0.5, -500.5, -472.5 )
	LayoutTopBar:setImage( RegisterImage( @"hash_87C348C36FF085C" ) )
	self:addElement( LayoutTopBar )
	self.LayoutTopBar = LayoutTopBar
	
	local LayoutTopBarStripes = LUI.UIImage.new( 0.5, 0.5, -348 - 1000, 348 + 1000, 0.5, 0.5, -500.5, -484.5 )
	LayoutTopBarStripes:setImage( RegisterImage( @"hash_6A0F654633E4C64E" ) )
	self:addElement( LayoutTopBarStripes )
	self.LayoutTopBarStripes = LayoutTopBarStripes
	
	local TitleBackgroundBar = LUI.UIImage.new( 0.5, 0.5, -336.5, 336.5, 0.5, 0.5, -472, -444 )
	TitleBackgroundBar:setRGB( 0.25, 0.24, 0.22 )
	TitleBackgroundBar:setAlpha( 0.88 )
	self:addElement( TitleBackgroundBar )
	self.TitleBackgroundBar = TitleBackgroundBar
	
	local TitleTiledBacking = LUI.UIImage.new( 0.5, 0.5, -336.5, 336.5, 0.5, 0.5, -472, -444 )
	TitleTiledBacking:setAlpha( 0.5 )
	TitleTiledBacking:setImage( RegisterImage( @"hash_634839E8065B1E53" ) )
	TitleTiledBacking:setMaterial( LUI.UIImage.GetCachedMaterial( @"hash_16CBE95C250C6D15" ) )
	TitleTiledBacking:setShaderVector( 0, 0, 0, 0, 0 )
	TitleTiledBacking:setupNineSliceShader( 196, 88 )
	self:addElement( TitleTiledBacking )
	self.TitleTiledBacking = TitleTiledBacking
	
	local TitleText = LUI.UIText.new( 0.5, 0.5, -279.5, 279.5, 0.5, 0.5, -469, -445 )
	TitleText:setRGB( ColorSet.T8__BIEGE.r, ColorSet.T8__BIEGE.g, ColorSet.T8__BIEGE.b )
	TitleText:setAlpha( 0.6 )
	TitleText:setText( "" )
	TitleText:setTTF( "ttmussels_regular" )
	TitleText:setLetterSpacing( 4 )
	TitleText:setAlignment( Enum[@"hash_67A5123B654282D2"][@"hash_1FEEB12BCB0D7041"] )
	TitleText:setAlignment( Enum[@"hash_67A5123B654282D2"][@"hash_3F41D595A2B0EDF3"] )
	self:addElement( TitleText )
	self.TitleText = TitleText
	
	local TitleLayoutElementL = LUI.UIImage.new( 0.5, 0.5, -331, -315, 0.5, 0.5, -465, -449 )
	TitleLayoutElementL:setRGB( ColorSet.T8__BIEGE.r, ColorSet.T8__BIEGE.g, ColorSet.T8__BIEGE.b )
	TitleLayoutElementL:setZRot( 90 )
	TitleLayoutElementL:setImage( RegisterImage( @"hash_634B575F15CDD376" ) )
	TitleLayoutElementL:setMaterial( LUI.UIImage.GetCachedMaterial( @"hash_F755127C95CF5B6" ) )
	TitleLayoutElementL:setShaderVector( 0, 3, 0, 0, 0 )
	self:addElement( TitleLayoutElementL )
	self.TitleLayoutElementL = TitleLayoutElementL
	
	local TitleLayoutElementR = LUI.UIImage.new( 0.5, 0.5, 313, 329, 0.5, 0.5, -464, -448 )
	TitleLayoutElementR:setRGB( ColorSet.T8__BIEGE.r, ColorSet.T8__BIEGE.g, ColorSet.T8__BIEGE.b )
	TitleLayoutElementR:setImage( RegisterImage( @"hash_634B575F15CDD376" ) )
	TitleLayoutElementR:setMaterial( LUI.UIImage.GetCachedMaterial( @"hash_F755127C95CF5B6" ) )
	TitleLayoutElementR:setShaderVector( 0, 3, 0, 0, 0 )
	self:addElement( TitleLayoutElementR )
	self.TitleLayoutElementR = TitleLayoutElementR
	
	local HeaderBackground = LUI.UIImage.new( 0.5, 0.5, -336.5 - 1000, 336.5 + 1000, 0.5, 0.5, -423, -231 )
	HeaderBackground:setRGB( 0.23, 0.23, 0.23 )
	HeaderBackground:setAlpha( 0.25 )
	self:addElement( HeaderBackground )
	self.HeaderBackground = HeaderBackground
	
	local HeaderTopBar = LUI.UIImage.new( 0.5, 0.5, -5, -1, 0.5, 0.5, -767, -90 )
	HeaderTopBar:setAlpha( 0.09 )
	HeaderTopBar:setZRot( 90 )
	HeaderTopBar:setImage( RegisterImage( @"hash_C49B0C8991A541F" ) )
	HeaderTopBar:setMaterial( LUI.UIImage.GetCachedMaterial( @"hash_67C9C02F608D0A75" ) )
	HeaderTopBar:setShaderVector( 0, 0, 0, 0, 0 )
	HeaderTopBar:setupNineSliceShader( 4, 8 )
	self:addElement( HeaderTopBar )
	self.HeaderTopBar = HeaderTopBar
	
	local HeaderBottomBar = LUI.UIImage.new( 0.5, 0.5, -5, -1, 0.5, 0.5, -566, 111 )
	HeaderBottomBar:setAlpha( 0.09 )
	HeaderBottomBar:setZRot( 90 )
	HeaderBottomBar:setImage( RegisterImage( @"hash_C49B0C8991A541F" ) )
	HeaderBottomBar:setMaterial( LUI.UIImage.GetCachedMaterial( @"hash_67C9C02F608D0A75" ) )
	HeaderBottomBar:setShaderVector( 0, 0, 0, 0, 0 )
	HeaderBottomBar:setupNineSliceShader( 4, 8 )
	self:addElement( HeaderBottomBar )
	self.HeaderBottomBar = HeaderBottomBar
	
	local BTNQuit = nil
	
	BTNQuit = CoD.PC_SmallCloseButton.new( f1_arg0, f1_arg1, 0.5, 0.5, 302, 336, 0.5, 0.5, -475, -441 )
	BTNQuit:setScale( 0.8, 0.8 )
	BTNQuit:registerEventHandler( "gain_focus", function ( element, event )
		local f5_local0 = nil
		if element.gainFocus then
			f5_local0 = element:gainFocus( event )
		elseif element.super.gainFocus then
			f5_local0 = element.super:gainFocus( event )
		end
		CoD.Menu.UpdateButtonShownState( element, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
		return f5_local0
	end )
	f1_arg0:AddButtonCallbackFunction( BTNQuit, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], "ui_confirm", function ( element, menu, controller, model )
		GoBack( self, controller )
		return true
	end, function ( element, menu, controller )
		CoD.Menu.SetButtonLabel( menu, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], @"hash_0", nil, "ui_confirm" )
		return false
	end, false )
	self:addElement( BTNQuit )
	self.BTNQuit = BTNQuit
	
	--if CoD.isPC then
		buttons.id = "buttons"
	--end
	--if CoD.isPC then
		featureOverlayButtonMouseOnly.id = "featureOverlayButtonMouseOnly"
		reset_defaults.id = "reset_defaults"
		--ReloadModsOverlayButtonMouseOnly.id = "ReloadModsOverlayButtonMouseOnly"
	--end
	--if CoD.isPC then
		BTNQuit.id = "BTNQuit"
	--end
	LUI.OverrideFunction_CallOriginalSecond( self, "close", self.__onClose )
	if PostLoadFunc then
		PostLoadFunc( self, f1_arg1, f1_arg0 )
	end
	
	return self
end

CoD.RulesCommonCenteredPopup.__onClose = function ( f8_arg0 )
	f8_arg0.buttons:close()
	f8_arg0.featureOverlayButtonMouseOnly:close()
	f8_arg0.BTNQuit:close()
	f8_arg0.BlackfadeBlurB:close()
	f8_arg0.BlackfadeBlurF:close()
	f8_arg0.reset_defaults:close()
end

CoD.Shield_Blackout_Rules_SettingsPopup = InheritFrom( CoD.Menu )
LUI.createMenu.Shield_Blackout_Rules_SettingsPopup = function ( f1_arg0, f1_arg1 )
	local self = CoD.Menu.NewForUIEditor( "Shield_Blackout_Rules_SettingsPopup", f1_arg0 )
	local f1_local1 = self
	self:setClass( CoD.Shield_Blackout_Rules_SettingsPopup )
	self.soundSet = "none"
	self:setOwner( f1_arg0 )
	self:setLeftRight( 0, 1, 0, 0 )
	self:setTopBottom( 0, 1, 0, 0 )
	self:playSound( "menu_open", f1_arg0 )
	self.anyChildUsesUpdateState = true
	f1_local1:addElementToPendingUpdateStateList( self )
	
	local CommomCenteredPopup = CoD.RulesCommonCenteredPopup.new( f1_local1, f1_arg0, 0, 1, 0, 0, 0, 1, 0, 0 )
	CommomCenteredPopup.TitleText:setText("Blackout Rules Settings")
	CommomCenteredPopup.HeaderBackground:setAlpha( 0 )
	CommomCenteredPopup.HeaderTopBar:setAlpha( 0 )
	CommomCenteredPopup.HeaderBottomBar:setAlpha( 0 )
	self:addElement( CommomCenteredPopup )
	self.CommomCenteredPopup = CommomCenteredPopup

	local BlackoutContainer = CoD.BlackoutRulesContainer.new( f1_local1, f1_arg0, 0.50, 0.50, -257.49, 242.51, 0.50, 0.50, -154.76, 345.24 )
	self:addElement( BlackoutContainer )
	self.BlackoutContainer = BlackoutContainer

	BlackoutContainer.id = "BlackoutContainer"

	-- tabs
	-- tab for perks
	local TabBacking = CoD.CommonTabBarBacking.new( f1_arg0, f1_arg1, -1, 1, 0, 0, 0.5, 0.5, -413.74, -377.74 )
	TabBacking.TabBackingBlur:setAlpha( 0 )
	self:addElement( TabBacking )
	self.TabBacking = TabBacking

	--LUI_DebugElement(self, f1_arg0, self, TabBacking, "TabBacking", 10)

    local SettingsTab = CoD.Common_Tabbar_Center.new( f1_local1, f1_arg0, 0.50, 0.50, -448.25, 468.75, 0.50, 0.50, -428.76, -367.76 )

	SettingsTab.left:mergeStateConditions( {
		{
			stateName = "Disabled",
			condition = function ( menu, element, event )
				return AlwaysFalse()
			end
		}
	} )

    SettingsTab.right:mergeStateConditions( {
		{
			stateName = "Disabled",
			condition = function ( menu, element, event )
				return AlwaysFalse()
			end
		}
	} )

	GlobalBlackoutSettingsList = self.BlackoutContainer.MiscSettingsList

	SettingsTab.Tabs.grid:setHorizontalCount( 6 )
	SettingsTab.Tabs.grid:setDataSource( "ShieldBlackoutSettingsFilters" )

	SettingsTab:registerEventHandler( "list_active_changed", function ( element, event )
		CoD.EnhPrintInfo("Updating Blackout tab", element.filter)
		BlackoutSettingTab = element.filter
		self.BlackoutContainer.MiscSettingsList:setDataSource("")
		self.BlackoutContainer.MiscSettingsList:setDataSource("RulesSettingsDataBlackout")
	end )
	self:addElement( SettingsTab )
	self.SettingsTab = SettingsTab

    SettingsTab.id = "SettingsTab"

	--LUI_DebugElement(self, f1_arg0, self, SettingsTab, "SettingsTab", 10)

	--LUI_DebugElement(f1_local1, f1_arg0, self, BlackoutContainer, "BlackoutContainer", 10)
	
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
	self.__defaultFocus = BlackoutContainer
	if CoD.isPC and (IsKeyboard( f1_arg0 ) or self.ignoreCursor) then
		self:restoreState( f1_arg0 )
	end
	LUI.OverrideFunction_CallOriginalSecond( self, "close", self.__onClose )
	if PostLoadFunc then
		PostLoadFunc( self, f1_arg0 )
	end
	
	f1_local7 = self
	--MenuHidesFreeCursor( f1_local1, f1_arg0 )

	CoD.EnhPrintInfo("Called", "Shield_Blackout_Rules_SettingsPopup")

	return self
end

CoD.Shield_Blackout_Rules_SettingsPopup.__resetProperties = function ( f13_arg0 )

end

CoD.Shield_Blackout_Rules_SettingsPopup.__clipsPerState = {
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

CoD.Shield_Blackout_Rules_SettingsPopup.__onClose = function ( f16_arg0 )
	f16_arg0.CommomCenteredPopup:close()
	f16_arg0.BlackoutContainer:close()
	f16_arg0.SettingsTab:close()
	f16_arg0.TabBacking:close()
end