--[[
		.\hksc.exe ".\Lua\UnlockAll.Lua" -o "C:\Program Files (x86)\Call of Duty Black Ops 4\project-bo4\mods\T8ShieldSupport\Lua\UnlockAll.luac"
]]

---------------------------

CoD.ShieldInitLuaFile()

---------------------------

-- ? this file is for the unlock patches + unlock all menu thats used in shield options. ?

---------------------------

-- unlocks dvars (used for unlock settings in shield's menu)
Engine[@"exec"](Engine[@"getprimarycontroller"](), "readjson shield_unlock_all unlock all bool")
Engine[@"exec"](Engine[@"getprimarycontroller"](), "readjson shield_unlock_loot unlock loot bool")
Engine[@"exec"](Engine[@"getprimarycontroller"](), "readjson shield_unlock_attachments unlock attachments bool")
Engine[@"exec"](Engine[@"getprimarycontroller"](), "readjson shield_unlock_itemoptions unlock itemoptions bool")
Engine[@"exec"](Engine[@"getprimarycontroller"](), "readjson shield_unlock_items unlock items bool")
Engine[@"exec"](Engine[@"getprimarycontroller"](), "readjson shield_unlock_classes unlock classes bool")

local UnlockAll = Engine[@"getdvarint"]("shield_unlock_all")
local UnlockLoot = Engine[@"getdvarint"]("shield_unlock_loot")
local UnlockAttachments = Engine[@"getdvarint"]("shield_unlock_attachments")
local UnlockCamos = Engine[@"getdvarint"]("shield_unlock_itemoptions")
local UnlockCards = Engine[@"getdvarint"]("")
local UnlockItems = Engine[@"getdvarint"]("shield_unlock_items")
local UnlockClassSlots = Engine[@"getdvarint"]("shield_unlock_classes")
local UnlockBlackMarket = Engine[@"getdvarint"]("")

---------------------------

local function ShieldUnlockAll_Toggle(Controller)
	UnlockAll = Engine[@"getdvarint"]("shield_unlock_all")

	if UnlockAll == 1 then
		CoD.EnhPrintInfo(UnlockAll, "Unlock All")
		Engine[@"exec"](Engine[@"getprimarycontroller"](), "unlock all true")
		--Engine[@"exec"](Engine[@"getprimarycontroller"](), "set allItemsUnlocked 1")
	else
		CoD.EnhPrintInfo(UnlockAll, "Unlock All")
		Engine[@"exec"](Engine[@"getprimarycontroller"](), "unlock all false")
		--Engine[@"exec"](Engine[@"getprimarycontroller"](), "set allItemsUnlocked 0")
	end
end

local function ShieldUnlockAttachments_Toggle(Controller)
	UnlockAttachments = Engine[@"getdvarint"]("shield_unlock_attachments")

	if UnlockAttachments == 1 then
		CoD.EnhPrintInfo(UnlockAttachments, "Unlock Attachments")
		Engine[@"exec"](Engine[@"getprimarycontroller"](), "unlock attachments true")
		Engine[@"exec"](Engine[@"getprimarycontroller"](), "unlock attachmentslot true")
	else
		CoD.EnhPrintInfo(UnlockAttachments, "Unlock Attachments")
		Engine[@"exec"](Engine[@"getprimarycontroller"](), "unlock attachments false")
		Engine[@"exec"](Engine[@"getprimarycontroller"](), "unlock attachmentslot false")
	end
end

local function ShieldUnlockLoot_Toggle(Controller)
	UnlockLoot = Engine[@"getdvarint"]("shield_unlock_loot")

	if UnlockLoot == 1 then
		CoD.EnhPrintInfo(UnlockLoot, "Unlock Loot All")
		Engine[@"exec"](Engine[@"getprimarycontroller"](), "unlock loot true")
		Engine[@"exec"](Engine[@"getprimarycontroller"](), "unlock zm_loot true")
	else
		CoD.EnhPrintInfo(UnlockLoot, "Unlock Loot All")
		Engine[@"exec"](Engine[@"getprimarycontroller"](), "unlock loot false")
		Engine[@"exec"](Engine[@"getprimarycontroller"](), "unlock zm_loot false")
	end
end

local function ShieldUnlockCamosCards_Toggle(Controller)
	UnlockCamos = Engine[@"getdvarint"]("shield_unlock_itemoptions")

	if UnlockCamos == 1 then
		CoD.EnhPrintInfo(UnlockCamos, "Unlock Camos")
		Engine[@"exec"](Engine[@"getprimarycontroller"](), "unlock itemoptions true")
		--Engine[@"exec"](Engine[@"getprimarycontroller"](), "set allItemsUnlocked 1")
	else
		CoD.EnhPrintInfo(UnlockCamos, "Unlock Camos")
		Engine[@"exec"](Engine[@"getprimarycontroller"](), "unlock itemoptions false")
		--Engine[@"exec"](Engine[@"getprimarycontroller"](), "set allItemsUnlocked 0")
	end
end

local function ShieldUnlockCards_Toggle(Controller)
	UnlockCards = Engine[@"getdvarint"]("placeholder")

	if UnlockCards == 1 then
		CoD.EnhPrintInfo(UnlockCards, "Unlock Cards")
		Engine[@"exec"](Engine[@"getprimarycontroller"](), "unlock cards true")
	else
		CoD.EnhPrintInfo(UnlockCards, "Unlock Cards")
		Engine[@"exec"](Engine[@"getprimarycontroller"](), "unlock cards false")
	end
end

local function ShieldItems_Toggle(Controller)
	UnlockItems = Engine[@"getdvarint"]("shield_unlock_items")

	if UnlockItems == 1 then
		CoD.EnhPrintInfo(UnlockItems, "Unlock Items")
		Engine[@"exec"](Engine[@"getprimarycontroller"](), "unlock items true")
	else
		CoD.EnhPrintInfo(UnlockItems, "Unlock Items")
		Engine[@"exec"](Engine[@"getprimarycontroller"](), "unlock items false")
	end
end


local function ShieldUnlockClassSlots_Toggle(Controller)
	UnlockClassSlots = Engine[@"getdvarint"]("shield_unlock_classes")

	if UnlockClassSlots == 1 then
		CoD.EnhPrintInfo(UnlockClassSlots, "Unlock Class Slots")
		Engine[@"exec"](Engine[@"getprimarycontroller"](), "unlock classes true")
	else
		CoD.EnhPrintInfo(UnlockClassSlots, "Unlock Class Slots")
		Engine[@"exec"](Engine[@"getprimarycontroller"](), "unlock classes false")
	end
end

local function ShieldUnlockBlackMarket_Toggle(Controller)
	UnlockBlackMarket = Engine[@"getdvarint"]("placeholder")

	if UnlockBlackMarket == 1 then
		CoD.EnhPrintInfo(UnlockBlackMarket, "Unlock Black Market")
		Engine[@"exec"](Engine[@"getprimarycontroller"](), "unlock market true")
	else
		CoD.EnhPrintInfo(UnlockBlackMarket, "Unlock Black Market")
		Engine[@"exec"](Engine[@"getprimarycontroller"](), "unlock market false")
	end
end

local function ShieldShouldUnlockItem_Dvar()
	return Engine[@"getdvarint"]("allitemsunlocked") == 1
end

local function OnUnlockDataChange ( f137_arg0, f137_arg1, f137_arg2, f137_arg3, f137_arg4 )
	local dvar_name = f137_arg3
	local dvar_val = Engine[@"getdvarint"]( dvar_name )
	local current_val = f137_arg1.value
	CoD.OptionsUtility.UpdateInfoModels( f137_arg1 )

	if current_val == dvar_val then
		return 
	else
		Engine[@"setdvar"]( dvar_name, current_val )
	end
	
	if dvar_name == "shield_unlock_all" then
		ShieldUnlockAll_Toggle()
	elseif dvar_name == "shield_unlock_attachments" then
		ShieldUnlockAttachments_Toggle()
	elseif dvar_name == "shield_unlock_loot" then
		ShieldUnlockLoot_Toggle()
	elseif dvar_name == "shield_unlock_itemoptions" then
		ShieldUnlockCamosCards_Toggle()
	elseif dvar_name == "shield_unlock_items" then
		ShieldItems_Toggle()
	elseif dvar_name == "shield_unlock_classes" then
		ShieldUnlockClassSlots_Toggle()
	end

	if dvar_name == "shield_server_style" then
		Engine[@"exec"](Engine[@"getprimarycontroller"](), "writejson lua server_style " .. current_val .. " uint64_t")
	end

	if dvar_name == "shield_party_privacy" then
		if current_val == 0 then
			Engine[@"exec"](Engine[@"getprimarycontroller"](), "unlockparty")
		else
			Engine[@"exec"](Engine[@"getprimarycontroller"](), "lockparty")
		end
	end
end

local function ShieldIsRoleUnlocked(f119_arg0, f119_arg1, f119_arg2)
	local f119_local0 = Engine[@"getpositionrolebundleinfo"]( f119_arg1, f119_arg2 )
	if not f119_local0 then
		return false
	elseif f119_local0[@"entitlement"] ~= nil then
		return Engine[@"hasentitlement"]( f119_arg0, f119_local0[@"entitlement"] )
	end
	local f119_local1 = f119_local0[@"hash_7A01F4246639318C"]
	if f119_local1 and CoDShared.IsIntDvarNonZero( f119_local1 ) then
		return true
	elseif f119_local0[@"unlockableitementry"] ~= nil then
		local f119_local2 = Engine[@"hash_68FF94BB44442412"]( f119_local0[@"unlockableitementry"], f119_arg1 )
		if f119_local2 > CoDShared.EmptyItemIndex and not Engine[@"isitemlocked"]( f119_arg0, f119_local2, f119_arg1 ) then
			return true
		elseif f119_local0[@"hash_41D6157DBA773DA3"] ~= nil and f119_local0[@"hash_41D6157DBA773DA3"] ~= @"hash_0" then
			local f119_local3 = CoDShared.LootIndexInfoLookup( f119_local0[@"hash_41D6157DBA773DA3"] )
			if f119_local3 then
				return CoDShared.IsLootItemOwnedByName( f119_arg0, f119_local3.nameHash )
			end
		end
	end
	if f119_local0[@"hash_5D48E06E94FE4AFA"] == 1 then
		return true
	elseif ShieldShouldUnlockItem_Dvar() then
		return true
	elseif f119_arg1 == Enum[@"emodes"][@"mode_warzone"] and (not CoDShared.IsIntDvarNonZero( @"hash_4A5FD7D94CFC9DFD" ) or f119_local0[@"modecategory"] ~= Enum[@"emodes"][@"mode_multiplayer"]) then
		if Engine[@"storagegetbuffer"]( f119_arg0, Enum[@"storagefiletype"][@"storage_wz_stats_online"] ) == nil then
			return false
		elseif Engine[@"storagegetbuffer"]( f119_arg0, Enum[@"storagefiletype"][@"storage_common_settings"] ) == nil then
			return false
		end
		local f119_local4 = Engine[@"storagegetbuffer"]( f119_arg0, Enum[@"storagefiletype"][@"hash_1AB0E693244221BC"] )
		if not f119_local4 then
			return false
		end
		local f119_local5 = Engine[@"hash_682C5756563934AE"]( f119_arg1, f119_arg2 )
		if f119_local5 and f119_local4[@"characters"][f119_local5] then
			return f119_local4[@"characters"][f119_local5][@"unlocked"]:get() == 1
		end
		return false
	end
	return true
end

local function ShieldCreateOutfits(f40_arg0, f40_arg1, f40_arg2, f40_arg3, f40_arg4, f40_arg5)
	local f40_local0 = "ThemeOutfit" .. f40_arg3
	DataSources[f40_local0] = DataSourceHelpers.ListSetup( f40_local0, function ( f41_arg0, f41_arg1 )
		local f41_local0 = {}
		for f41_local15, f41_local16 in ipairs( f40_arg4.presets ) do
			if f41_local16.isValid then
				local f41_local4 = CoD.BlackMarketTableUtility.LootInfoLookup( f41_arg0, f41_local16.lootId )
				f41_local4.owned = true
				local f41_local5 = f41_local16.entitlement
				if f41_local5 then
					f41_local5 = f41_local16.entitlement ~= @"hash_0"
				end
				local f41_local6 = ""
				local f41_local7 = true
				for f41_local8 = 0, Enum[@"characteritemtype"][@"character_item_type_count"] - 1, 1 do
					local f41_local11 = nil
					if f41_local8 == Enum[@"characteritemtype"][@"hash_141B42F0A58AC50F"] then
						f41_local11 = f41_local16.arms
					elseif f41_local8 == Enum[@"characteritemtype"][@"hash_37AD40A4111A72FE"] then
						f41_local11 = f41_local16.head
					elseif f41_local8 == Enum[@"characteritemtype"][@"hash_4FF8573E011622F4"] then
						f41_local11 = f41_local16.headgear
					elseif f41_local8 == Enum[@"characteritemtype"][@"hash_283CBB806B732B11"] then
						f41_local11 = f41_local16.legs
					elseif f41_local8 == Enum[@"characteritemtype"][@"hash_4922FE5C41D9EE8B"] then
						f41_local11 = f41_local16.palette
					elseif f41_local8 == Enum[@"characteritemtype"][@"hash_19DDCEC39BA98B97"] then
						f41_local11 = f41_local16.torso
					end
					if f41_local11 and f41_local7 then
						f41_local7 = f41_local11 == CoD.PlayerRoleUtility.EquippedOutfitItems[f41_arg0][@"outfits"][f40_arg3][f41_local8]
					end
					f41_local6 = f41_local6 .. (f41_local11 or 0) .. ";"
				end
				local f41_local8 = f41_local4.unlockInfo
				if not f41_local8 then
					f41_local8 = ""
				end
				local f41_local9 = ""
				if f41_local4.isLoot and f41_local4.available and f41_local4.disableWhenAvailable and not f41_local4.owned then
					f41_local9 = f41_local8
					f41_local8 = ""
				end
				local f41_local10 = table.insert
				local f41_local12 = f41_local0
				local f41_local11 = {}
				local f41_local13 = {
					displayName = Engine[@"hash_4F9F1239CFD921FE"]( f41_local16.displayName ),
					icon = f41_local16.icon,
					outfitIndex = f40_arg3,
					itemType = Enum[@"characteritemtype"][@"hash_4922FE5C41D9EE8B"],
					itemIndex = f41_local16.palette,
					lootId = f41_local16.lootId
				}
				local f41_local14 = CoD.BlackMarketUtility.LootIdRarities[f41_local4.rarity]
				if not f41_local14 then
					f41_local14 = Enum[@"lootraritytype"][@"loot_rarity_type_count"]
				end
				f41_local13.rarity = f41_local14
				f41_local13.category = @"menu/outfit"
				f41_local13.unlockInfo = f41_local8
				f41_local13.alertMessage = f41_local9
				f41_local14 = f41_local4.available
				if not f41_local14 then
					f41_local14 = not f41_local4.isLoot
				end
				f41_local13.available = true
				f41_local14 = f41_local4.owned
				if not f41_local14 then
					f41_local14 = not f41_local4.isLoot
				end
				f41_local13.owned = f41_local14
				f41_local14 = f40_arg5
				if not f41_local14 then
					f41_local14 = f41_local4.available
					if f41_local14 then
						f41_local14 = f41_local4.disableWhenAvailable
					end
				end
				f41_local13.disabled = false
				f41_local13.skipDefaultTitle = f41_local4.isNotDefault
				f41_local14 = f41_local4.hideRarity
				if not f41_local14 then
					f41_local14 = f41_local5 or false
				end
				f41_local13.hideRarity = f41_local14
				f41_local13.presets = f41_local6
				f41_local13.arms = f41_local16.arms
				f41_local13.head = f41_local16.head
				f41_local13.headgear = f41_local16.headgear
				f41_local13.legs = f41_local16.legs
				f41_local13.palette = f41_local16.palette
				f41_local13.torso = f41_local16.torso
				f41_local13.presetIndex = f41_local15 - 1
				f41_local13.checkEquippedOutfit = true
				f41_local11.models = f41_local13
				f41_local11.properties = {
					selectIndex = f41_local7,
					entitlement = f41_local16.entitlement,
					accessoryCount = 0,
					lootData = f41_local4
				}
				f41_local11.options = {}
				f41_local10( f41_local12, f41_local11 )
			end
		end
		local f41_local1 = {}
		for f41_local5, f41_local6 in LUI.IterateTableBySortedKeys( f41_local0, function ( f42_arg0, f42_arg1 )
			f42_arg0 = f41_local0[f42_arg0]
			f42_arg1 = f41_local0[f42_arg1]
			if f42_arg0.properties.owned ~= f42_arg1.properties.owned then
				return f42_arg0.properties.owned
			elseif f42_arg0.properties.available ~= f42_arg1.properties.available then
				return f42_arg0.properties.available
			else
				return f42_arg0.models.itemIndex < f42_arg1.models.itemIndex
			end
		end, function ( f43_arg0, f43_arg1 )
			if f43_arg1.properties.lootData.isLoot then
				local f43_local0 = f43_arg1.properties.lootData.owned
				if not f43_local0 then
					f43_local0 = f43_arg1.properties.lootData.available
					if f43_local0 then
						f43_local0 = f43_arg1.properties.lootData.disableWhenAvailable
					end
				end
				return f43_local0
			else
				local f43_local0
				if f43_arg1.properties.entitlement ~= @"hash_0" then
					f43_local0 = Engine[@"hasentitlement"]( f41_arg0, f43_arg1.properties.entitlement )
				else
					f43_local0 = true
				end
			end
			return f43_local0
		end ) do
			table.insert( f41_local1, f41_local6 )
		end
		return f41_local1
	end, true )
	return f40_local0
end

-- Reactives and Calling Card Fixes
CoD.UnlockReload = function()
	-- Outfits Theme Unlocking, even some unused ones
	DataSources.MPSpecialistThemes = DataSourceHelpers.ListSetup( "MPSpecialistThemes", function ( f56_arg0, f56_arg1 )
		local f56_local0 = f56_arg1.menu:getModel()
		local f56_local1 = f56_local0.characterIndex:get()
		local f56_local2 = Engine[@"currentsessionmode"]()
		local f56_local3 = {}
		local f56_local4 = CoD.PlayerRoleUtility.GetCachedHeroCustomization( f56_local2, f56_local1 )
		CoD.PlayerRoleUtility.EquippedOutfitItems[f56_arg0] = Engine[@"getequippedinfoforhero"]( f56_arg0, f56_local2, f56_local1 ) or {}
		local f56_local5 = DataSources.MPOutfitCategories.getModel( f56_arg0 )
		f56_local5 = f56_local5.selectedCategory
		if not f56_arg1._selectedCategorySub then
			f56_arg1._selectedCategorySub = f56_arg1:subscribeToModel( f56_local5, function ()
				f56_arg1:updateDataSource()
			end, false )
		end
		local f56_local6 = DataSources.MPSpecialistThemes.getCurrentCategoryHelper( f56_arg0, f56_local4, f56_local2, f56_local1 )
		if f56_local6 then
			local f56_local7 = {}
			local f56_local8 = true
			for f56_local16, f56_local17 in LUI.IterateTableBySortedKeys( f56_local4.outfits, f56_local6.sort, f56_local6.filter ) do
				f56_local8 = true
				if f56_local7[f56_local17.displayName] then
					f56_local8 = false
				end
				if f56_local8 then
					local f56_local12 = f56_local16 - 1
					local f56_local13 = f56_local6.getBreadcrumbModel( f56_local12 )
					local f56_local14 = f56_local6.lookupHighestRarity( f56_local16, f56_local17 )
					local f56_local15 = f56_local6.isDisabled( f56_local17 )
					table.insert( f56_local3, {
						models = {
							displayName = Engine[@"hash_4F9F1239CFD921FE"]( f56_local17.displayName ),
							datasourceName = f56_local6.dataSourceFunction( f56_arg0, f56_local2, f56_local1, f56_local12, f56_local17, f56_local15 ),
							decalDataSourceName = f56_local6.decalDataSourceFunction( f56_arg0, f56_local2, f56_local1, f56_local12, f56_local17 ),
							decalCount = #f56_local17.decals,
							outfitIndex = f56_local12,
							category = @"hash_54106C155ACE8F96",
							rarity = f56_local14,
							available = true,
							disabled = false,
							hideRarity = f56_local14 == Enum[@"lootraritytype"][@"loot_rarity_type_count"],
							unlockInfo = f56_local6.getUnlockInfo( f56_local17 ),
							alertMessage = f56_local6.getAlertMessage( f56_local17 ),
							breadcrumb = f56_local13
						},
						properties = {
							selectIndex = f56_local12 == f56_local6.selectedIndex()
						}
					} )
				end
				f56_local7[f56_local17.displayName] = true
			end
		end
		return f56_local3
	end, true, {
		getModel = function ( f58_arg0 )
			local f58_local0 = Engine[@"getmodelforcontroller"]( f58_arg0 )
			f58_local0 = f58_local0:create( "MPSpecialistThemes" )
			if not f58_local0.update then
				f58_local0:create( "update" )
			end
			return f58_local0
		end,
		getCurrentCategoryHelper = function ( f59_arg0, f59_arg1, f59_arg2, f59_arg3 )
			local f59_local0 = DataSources.MPOutfitCategories.getModel( f59_arg0 )
			local f59_local1 = DataSources.MPSpecialistThemes.getCategoryHelperFunctions[f59_local0.selectedCategory:get()]
			return f59_local1 and f59_local1( f59_arg0, f59_arg1, f59_arg2, f59_arg3 )
		end,
		getCategoryHelperFunctions = {
			[@"outfit"] = function ( f60_arg0, f60_arg1, f60_arg2, f60_arg3 )
				local f60_local0 = function ( f61_arg0 )
					if #f61_arg0.presets == 3 and (f61_arg0.presets[2].lootId == @"hash_40AC40E28D648CB3" or f61_arg0.presets[2].lootId == @"hash_6037D456548D22D4") then
						for f61_local3, f61_local4 in ipairs( f61_arg0.presets ) do
							f61_local4.isValid = false
						end
					end
					for f61_local3, f61_local4 in ipairs( f61_arg0.presets ) do
						if f61_local4.isValid and CoD.PlayerRoleUtility.IsPresetOwned( f60_arg0, f61_local4 ) then
							return true
						end
					end
					return false
				end
				
				local f60_local1 = function ( f62_arg0 )
					for f62_local4, f62_local5 in ipairs( f62_arg0.presets ) do
						if f62_local5.isValid then
							local f62_local3 = CoD.BlackMarketTableUtility.LootInfoLookup( f60_arg0, f62_local5.lootId )
							return f62_local3.available and f62_local3.disableWhenAvailable
						end
					end
					return false
				end
				
				local f60_local2 = function ( f63_arg0, f63_arg1 )
					local f63_local0 = Enum[@"lootraritytype"][@"loot_rarity_type_count"]
					for f63_local5, f63_local6 in ipairs( f63_arg1.presets ) do
						local f63_local7 = CoD.BlackMarketTableUtility.LootInfoLookup( f60_arg0, f63_local6.lootId )
						if f63_local7.isLoot then
							local f63_local4 = CoD.BlackMarketUtility.LootIdRarities[f63_local7.rarity]
							if not f63_local4 then
								f63_local4 = Enum[@"lootraritytype"][@"loot_rarity_type_count"]
							end
							if f63_local4 ~= Enum[@"lootraritytype"][@"loot_rarity_type_count"] then
								if f63_local0 == Enum[@"lootraritytype"][@"loot_rarity_type_count"] then
									f63_local0 = f63_local4
								else
									f63_local0 = math.max( f63_local0, f63_local4 )
								end
							end
						end
					end
					return f63_local0
				end
				
				return {
					filter = function ( f64_arg0, f64_arg1 )
						if not f64_arg1.isValid then
							return false
						end
						local f64_local0 = f60_local0( f64_arg1 )
						if not f64_local0 then
							f64_local0 = f60_local1( f64_arg1 )
						end
						return f64_local0
					end
					,
					sort = function ( f65_arg0, f65_arg1 )
						local f65_local0 = f60_local0( f60_arg1.outfits[f65_arg0] )
						if f65_local0 ~= f60_local0( f60_arg1.outfits[f65_arg1] ) then
							return f65_local0
						elseif f65_arg0 == 1 then
							return false
						elseif f65_arg1 == 1 then
							return true
						else
							return f60_local2( f65_arg1, f60_arg1.outfits[f65_arg1] ) < f60_local2( f65_arg0, f60_arg1.outfits[f65_arg0] )
						end
					end
					,
					lookupHighestRarity = f60_local2,
					selectedIndex = function ()
						return CoD.PlayerRoleUtility.EquippedOutfitItems[f60_arg0][@"selectedoutfit"]
					end
					,
					dataSourceFunction = ShieldCreateOutfits,
					decalDataSourceFunction = CoD.PlayerRoleUtility.CreateDecalsForTheme,
					getBreadcrumbModel = function ( f67_arg0 )
						return DataSources.SpecialistOutfitBreadcrumbs.getBreadcrumbModelForThemePresetCategory( f60_arg0, f60_arg2, f60_arg3, f67_arg0 )
					end
					,
					getUnlockInfo = function ( f68_arg0 )
						if f60_local0( f68_arg0 ) then
							for f68_local4, f68_local5 in ipairs( f68_arg0.presets ) do
								if f68_local5.isValid then
									local f68_local3 = CoD.BlackMarketTableUtility.LootInfoLookup( f60_arg0, f68_local5.lootId )
									if f68_local3.available and f68_local3.disableWhenAvailable then
										return f68_local3.unlockInfo or ""
									end
								end
							end
						end
						return ""
					end
					,
					getAlertMessage = function ( f69_arg0 )
						if not f60_local0( f69_arg0 ) then
							for f69_local4, f69_local5 in ipairs( f69_arg0.presets ) do
								if f69_local5.isValid then
									local f69_local3 = CoD.BlackMarketTableUtility.LootInfoLookup( f60_arg0, f69_local5.lootId )
									if f69_local3.available and f69_local3.disableWhenAvailable then
										return f69_local3.unlockInfo or ""
									end
								end
							end
						end
						return ""
					end
					,
					isDisabled = function ( f70_arg0 )
						return not f60_local0( f70_arg0 )
					end
					
				}
			end,
			[@"war_paint"] = function ( f71_arg0, f71_arg1, f71_arg2, f71_arg3 )
				local f71_local0 = function ( f72_arg0, f72_arg1 )
					local f72_local0 = Enum[@"lootraritytype"][@"loot_rarity_type_count"]
					for f72_local5, f72_local6 in ipairs( f72_arg1.warPaints ) do
						local f72_local7 = CoD.PlayerRoleUtility.LookupLootForWarPaint( f71_arg0, f72_local6, f72_arg1.presets )
						if f72_local7.isLoot then
							local f72_local4 = CoD.BlackMarketUtility.LootIdRarities[f72_local7.rarity]
							if not f72_local4 then
								f72_local4 = Enum[@"lootraritytype"][@"loot_rarity_type_count"]
							end
							if f72_local4 ~= Enum[@"lootraritytype"][@"loot_rarity_type_count"] then
								if f72_local0 == Enum[@"lootraritytype"][@"loot_rarity_type_count"] then
									f72_local0 = f72_local4
								else
									f72_local0 = math.max( f72_local0, f72_local4 )
								end
							end
						end
					end
					return f72_local0
				end
				
				local f71_local1 = function ( f73_arg0 )
					local f73_local0 = false
					for f73_local4, f73_local5 in ipairs( f73_arg0.warPaints ) do
						if f73_local4 > 1 and CoD.PlayerRoleUtility.IsWarPaintOwned( f71_arg0, f73_local5, f73_arg0.presets ) then
							f73_local0 = true
							break
						end
					end
					return f73_local0
				end
				
				return {
					filter = function ( f74_arg0, f74_arg1 )
						if not f74_arg1.isValid then
							return false
						else
							return f71_local1( f74_arg1 )
						end
					end
					,
					sort = function ( f75_arg0, f75_arg1 )
						if f75_arg0 == 1 then
							return false
						elseif f75_arg1 == 1 then
							return true
						else
							return f71_local0( f75_arg1, f71_arg1.outfits[f75_arg1] ) < f71_local0( f75_arg0, f71_arg1.outfits[f75_arg0] )
						end
					end
					,
					lookupHighestRarity = f71_local0,
					selectedIndex = function ()
						return CoD.PlayerRoleUtility.EquippedOutfitItems[f71_arg0][@"hash_4D9FCEAC8FF24CBD"]
					end
					,
					dataSourceFunction = CoD.PlayerRoleUtility.CreateWarPaintsForTheme,
					decalDataSourceFunction = function ()
						return ""
					end
					,
					getBreadcrumbModel = function ( f78_arg0 )
						return DataSources.SpecialistOutfitBreadcrumbs.getBreadcrumbModelForThemeItemType( f71_arg0, f71_arg2, f71_arg3, f78_arg0, Enum[@"characteritemtype"][@"hash_48E3A65D78229DC1"] )
					end
					,
					getUnlockInfo = function ( f79_arg0 )
						return ""
					end
					,
					getAlertMessage = function ( f80_arg0 )
						return ""
					end
					,
					isDisabled = function ( f81_arg0 )
						return false
					end
					
				}
			end
		}
	} )

	-- for numbers effect
	DataSources.WeaponDeathFxList = ListHelper_SetupDataSource( "WeaponDeathFxList", function ( f49_arg0, f49_arg1 )
		local f49_local0 = {}
		local f49_local1 = nil
		local f49_local2 = CoD.BaseUtility.GetMenuSessionMode( f49_arg1.menu )
		local f49_local3 = CoD.GetCustomization( f49_arg0, "weaponRefHash" )
		if not f49_local3 then
			return f49_local0
		end
		local f49_local4 = {
			weaponRef = f49_local3
		}
		local f49_local5 = Engine[@"hash_7A7E3CD65E63086F"]( @"hash_A8F031F7C7B2ED8" )
		if f49_local5 then
			for f49_local17, f49_local18 in ipairs( f49_local5 ) do
				if f49_local17 ~= 1 then
					local f49_local9 = CoD.BlackMarketTableUtility.LootInfoLookup( f49_arg0, f49_local18[@"lootid"], f49_local18[@"entitlement"], f49_local4 )
					local f49_local10 = f49_local9.isLoot or f49_local9.isEntitlement
					if (f49_local9.owned and f49_local10) or Engine[@"getdvarint"]("shield_unlock_all") == 1 then
						local f49_local11 = true
						if f49_local18[@"lootid"] == @"hash_29A9BD2389B3C356" and CoD.BaseUtility.IsDvarEnabled( "ui_hideRavenDeathFX" ) then
							f49_local11 = false
						end
						if f49_local11 then
							local f49_local12 = table.insert
							local f49_local13 = f49_local0
							local f49_local14 = {}
							local f49_local15 = {
								displayName = Engine[@"hash_4F9F1239CFD921FE"]( f49_local18[@"displayname"] ),
								category = @"hash_57B491E0F2A8C286"
							}
							local f49_local16 = f49_local18[@"icon"]
							if not f49_local16 then
								f49_local16 = @"blacktransparent"
							end
							f49_local15.icon = f49_local16
							f49_local15.itemIndex = f49_local17 - 1
							f49_local15.description = Engine[@"hash_4F9F1239CFD921FE"]( @"hash_2B48EB67B2AE72B3" )
							f49_local15.isEquippedFn = CoD.WeaponOptionsUtility.IsDeathFxEquipped
							f49_local15.isNewFn = CoD.BreadcrumbUtility.IsWeaponDeathFxNew
							f49_local16 = f49_local9.unlockInfo
							if not f49_local16 then
								f49_local16 = ""
							end
							f49_local15.unlockInfo = f49_local16
							f49_local16 = CoD.BlackMarketUtility.LootIdRarities[f49_local9.rarity]
							if not f49_local16 then
								f49_local16 = Enum[@"lootraritytype"][@"loot_rarity_type_count"]
							end
							f49_local15.rarity = f49_local16
							f49_local16 = f49_local9.owned
							if not f49_local16 then
								f49_local16 = f49_local9.available
								if not f49_local16 then
									f49_local16 = not f49_local10
								end
							end
							f49_local15.available = f49_local16 or Engine[@"getdvarint"]("shield_unlock_all") == 0
							f49_local16 = f49_local9.owned
							if not f49_local16 then
								f49_local16 = not f49_local10
							end
							f49_local15.owned = f49_local16 or Engine[@"getdvarint"]("shield_unlock_all") == 1
							f49_local16 = f49_local9.isLoot
							if f49_local16 then
								f49_local16 = f49_local9.owned
								if f49_local16 then
									f49_local16 = Engine[@"hash_5CB675CA7856DA25"]()
								end
							end
							f49_local15.trialLocked = f49_local16
							f49_local16 = f49_local9.isLoot
							if f49_local16 then
								f49_local16 = not f49_local9.owned
							end
							f49_local15.lootLocked = f49_local16 or Engine[@"getdvarint"]("shield_unlock_all") == 1
							f49_local16 = f49_local9.hideRarity
							if not f49_local16 then
								f49_local16 = f49_local9.isEntitlement
								if not f49_local16 then
									f49_local16 = false
								end
							end
							f49_local15.hideRarity = f49_local16
							f49_local15.lootId = f49_local18[@"lootid"]
							f49_local14.models = f49_local15
							f49_local12( f49_local13, f49_local14 )
						end
					end
				end
			end
		end
		return f49_local0
	end, true, {
		getModel = function ( f50_arg0 )
			local f50_local0 = Engine[@"getmodelforcontroller"]( f50_arg0 )
			f50_local0 = f50_local0:create( "WeaponDeathFxList" )
			f50_local0:create( "updateSelections" )
			return f50_local0
		end
	} )
end

DataSources.MasterCTCallingCard = {
	getModel = function ( f12_arg0 )
		local f12_local0 = Engine[@"getmodel"]( Engine[@"getmodelforcontroller"]( f12_arg0 ), "MasterCTCallingCard" )
		if f12_local0 == nil then
			f12_local0 = Engine[@"createmodel"]( Engine[@"getmodelforcontroller"]( f12_arg0 ), "MasterCTCallingCard" )
			f12_local0:create( "title" )
			f12_local0:create( "description" )
			f12_local0:create( "iconId" )
			f12_local0:create( "icon" )
			f12_local0:create( "statPercent" )
			f12_local0:create( "percentComplete" )
			f12_local0:create( "statFractionText" )
			f12_local0:create( "isLocked" )
		end
		return f12_local0
	end,
	setModelValues = function ( f13_arg0, f13_arg1, f13_arg2, f13_arg3, f13_arg4, f13_arg5 )
		local f13_local0 = Engine[@"getmodel"]( Engine[@"getmodelforcontroller"]( f13_arg0 ), "MasterCTCallingCard" )
		if f13_local0 == nil then
			f13_local0 = DataSources.MasterCTCallingCard.getModel( f13_arg0 )
		end
		f13_local0.title:set( f13_arg1 )
		f13_local0.description:set( f13_arg2 )
		f13_local0.iconId:set( f13_arg3 )
		f13_local0.icon:set( CoD.ChallengesUtility.GetBackgroundByID( f13_arg3 ) )
		f13_local0.statPercent:set( ShieldShouldUnlockItem_Dvar() and 1 or f13_arg4 / f13_arg5 )
		f13_local0.percentComplete:set( ShieldShouldUnlockItem_Dvar() and 1 or f13_arg4 / f13_arg5 )
		f13_local0.statFractionText:set( Engine[@"hash_4F9F1239CFD921FE"]( @"hash_631CF0F51CCA3A27", f13_arg4, f13_arg5 ) )
		local f13_local1 = f13_local0.isLocked
		local f13_local2 = f13_local1
		f13_local1 = f13_local1.set
		local f13_local3
		if f13_arg4 < f13_arg5 then
			f13_local3 = not ShieldShouldUnlockItem_Dvar()
		else
			f13_local3 = false
		end
		f13_local1( f13_local2, f13_local3 )
	end
}

DataSources.MasterCallingCard = {
	getModel = function ( f10_arg0 )
		local f10_local0 = Engine[@"getmodel"]( Engine[@"getmodelforcontroller"]( f10_arg0 ), "MasterCallingCard" )
		if f10_local0 == nil then
			f10_local0 = Engine[@"createmodel"]( Engine[@"getmodelforcontroller"]( f10_arg0 ), "MasterCallingCard" )
			f10_local0:create( "title" )
			f10_local0:create( "description" )
			f10_local0:create( "icon" )
			f10_local0:create( "percentComplete" )
			f10_local0:create( "isLocked" )
			f10_local0:create( "statFractionText" )
			f10_local0:create( "xp" )
			local f10_local1 = f10_local0:create( "maxTier" )
			f10_local1:set( 0 )
			f10_local1 = f10_local0:create( "currentTier" )
			f10_local1:set( 0 )
			f10_local1 = f10_local0:create( "tierStatus" )
			f10_local1:set( "" )
		end
		return f10_local0
	end,
	setModelValues = function ( f11_arg0, f11_arg1, f11_arg2, f11_arg3, f11_arg4, f11_arg5, f11_arg6 )
		local f11_local0 = Engine[@"getmodel"]( Engine[@"getmodelforcontroller"]( f11_arg0 ), "MasterCallingCard" )
		if f11_local0 == nil then
			f11_local0 = DataSources.MasterCallingCard.getModel( f11_arg0 )
		end
		f11_local0.title:set( f11_arg1 )
		f11_local0.description:set( f11_arg2 )
		f11_local0.icon:set( f11_arg3 )
		f11_local0.percentComplete:set( f11_arg4 )
		local f11_local1 = f11_local0.isLocked
		local f11_local2 = f11_local1
		f11_local1 = f11_local1.set
		local f11_local3
		if f11_arg4 < 1 then
			f11_local3 = not ShieldShouldUnlockItem_Dvar()
		else
			f11_local3 = false
		end
		f11_local1( f11_local2, f11_local3 )
		if f11_arg5 then
			f11_local0.statFractionText:set( f11_arg5 )
		end
		if f11_arg6 then
			f11_local0.xp:set( f11_arg6 )
		else
			f11_local0.xp:set( 0 )
		end
	end
}

CoD.ChallengesUtility.GetCTChallengeTable = function ( f70_arg0 )
	local f70_local0 = {}
	for f70_local1 = 1, CoD.CTUtility.NumCTChallenges, 1 do
		local f70_local4, f70_local5, f70_local6, f70_local7, f70_local8, f70_local9 = CoD.CTUtility.GetCTChallenge( f70_arg0, f70_local1 )
		if not f70_local6 then
			f70_local9 = 0
		end
		local f70_local10 = table.insert
		local f70_local11 = f70_local0
		local f70_local12 = {}
		local f70_local13 = {
			title = f70_local7,
			description = f70_local8,
			iconId = f70_local9,
			icon = CoD.ChallengesUtility.GetBackgroundByID( f70_local9 ),
			statPercent = ShieldShouldUnlockItem_Dvar() and 1 or f70_local4 / f70_local5,
			statFractionText = Engine[@"hash_4F9F1239CFD921FE"]( @"hash_631CF0F51CCA3A27", f70_local4, f70_local5 )
		}
		local f70_local14
		if not f70_local6 then
			f70_local14 = not ShieldShouldUnlockItem_Dvar()
		else
			f70_local14 = false
		end
		f70_local13.isLocked = f70_local14
		f70_local12.models = f70_local13
		f70_local10( f70_local11, f70_local12 )
	end
	return f70_local0
end

CoD.ChallengesUtility.AddDarkOpsChallengeCardsToList = function ( f68_arg0, f68_arg1, f68_arg2, f68_arg3 )
	local f68_local0 = CoD.ChallengesUtility.GetChallengeTable( f68_arg0, f68_arg1, f68_arg2, "darkops", function ( f69_arg0, f69_arg1 )
		return tonumber( f69_arg0.imageID ) < tonumber( f69_arg1.imageID )
	end )
	local f68_local1 = 0
	local f68_local2 = 0
	local f68_local3 = nil
	for f68_local7, f68_local8 in ipairs( f68_local0 ) do
		local f68_local9 = f68_local8.models

		-- fix "Zombie Dark Ops Master" card bug
		if f68_local9.iconId == 325 then
			return
		end

		if f68_local8.properties.isMastery then
			f68_local3 = f68_local8
		end
		table.insert( f68_arg3, f68_local8 )
		f68_local2 = f68_local2 + 1
		if not f68_local9.isLocked then
			f68_local1 = f68_local1 + 1
		end
	end
	if f68_local3 then
		local f68_local4 = f68_local3.models
		local f68_local5 = {}
		local f68_local6 = {
			title = f68_local4.title,
			description = f68_local4.description,
			iconId = f68_local4.iconId,
			icon = f68_local4.icon,
			percentComplete = f68_local1 / f68_local2,
			statFractionText = Engine[@"hash_4F9F1239CFD921FE"]( @"hash_631CF0F51CCA3A27", f68_local1, f68_local2 )
		}
		if f68_local1 < f68_local2 then
			local f68_local7 = not ShieldShouldUnlockItem_Dvar()
		else
			local f68_local7 = false
		end
		f68_local6.isLocked = f68_local7
		f68_local5.models = f68_local6
		return f68_local5
	else
		
	end
end

CoD.ChallengesUtility.AddCombatTrainingChallengesToList = function ( f53_arg0, f53_arg1 )
	for f53_local0 = 1, CoD.CTUtility.NumCTChallenges, 1 do
		local f53_local3, f53_local4, f53_local5, f53_local6, f53_local7, f53_local8 = CoD.CTUtility.GetCTChallenge( f53_arg0, f53_local0 )
		if f53_local3 == nil then
			f53_local3 = 0
		end
		local f53_local9 = table.insert
		local f53_local10 = f53_arg1
		local f53_local11 = {}
		local f53_local12 = {
			title = Engine[@"hash_4F9F1239CFD921FE"]( f53_local6 ),
			description = Engine[@"hash_4F9F1239CFD921FE"]( f53_local7 ),
			iconId = f53_local8,
			icon = CoD.ChallengesUtility.GetBackgroundByID( f53_local8 ),
			percentComplete = f53_local3 / f53_local4,
			statFractionText = Engine[@"hash_4F9F1239CFD921FE"]( @"hash_631CF0F51CCA3A27", f53_local3, f53_local4 )
		}
		local f53_local13
		if not f53_local5 then
			f53_local13 = not ShieldShouldUnlockItem_Dvar()
		else
			f53_local13 = false
		end
		f53_local12.isLocked = f53_local13
		f53_local11.models = f53_local12
		f53_local11.properties = {
			ctChallenge = true
		}
		f53_local9( f53_local10, f53_local11 )
	end
end

CoD.ChallengesUtility.AddDefaultCallingCardsToList = function ( f52_arg0, f52_arg1 )
	for f52_local8, f52_local9 in ipairs( Engine[@"getbackgroundsforcategoryname"]( f52_arg0, "default" ) ) do
		if not f52_local9.isBGLocked then
			local f52_local3 = table.insert
			local f52_local4 = f52_arg1
			local f52_local5 = {}
			local f52_local6 = {
				title = Engine[@"localize"]( f52_local9.description ),
				description = "",
				iconId = f52_local9.id,
				icon = CoD.ChallengesUtility.GetBackgroundByID( f52_local9.id )
			}
			local f52_local7 = f52_local9.isBGLocked
			if f52_local7 then
				f52_local7 = not ShieldShouldUnlockItem_Dvar()
			end
			f52_local6.isLocked = f52_local7
			f52_local5.models = f52_local6
			f52_local5.properties = {
				trialUnlocked = true
			}
			f52_local3( f52_local4, f52_local5 )
		end
	end
end

CoD.ChallengesUtility.GetMasteryChallengeCards = function ( f50_arg0, f50_arg1 )
	local f50_local0 = {}
	CoD.ChallengesUtility.AddMasteryChallengeCardsToList( f50_arg0, Enum[@"emodes"][@"mode_multiplayer"], "mp", f50_local0 )
	if not CoD.isPC or not CoD.PCKoreaUtility.ShowKorea15Plus() then
		CoD.ChallengesUtility.AddMasteryChallengeCardsToList( f50_arg0, Enum[@"emodes"][@"mode_zombies"], "zm", f50_local0 )
	end
	CoD.ChallengesUtility.AddMasteryChallengeCardsToList( f50_arg0, Enum[@"emodes"][@"mode_warzone"], "wz", f50_local0 )
	local f50_local1 = CoD.ChallengesUtility.AddGlobalChallengesToList( f50_arg0, {} )
	if not CoD.isPC or not CoD.PCKoreaUtility.ShowKorea15Plus() then
		table.insert( f50_local0, f50_local1 )
	end
	local f50_local2, f50_local3, f50_local4, f50_local5, f50_local6 = CoD.CTUtility.GetCTMasterChallenge( f50_arg0 )
	local f50_local7 = table.insert
	local f50_local8 = f50_local0
	local f50_local9 = {}
	local f50_local10 = {
		title = Engine[@"hash_4F9F1239CFD921FE"]( f50_local4 ),
		description = Engine[@"hash_4F9F1239CFD921FE"]( f50_local5 ),
		iconId = f50_local6,
		icon = CoD.ChallengesUtility.GetBackgroundByID( f50_local6 ),
		percentComplete = f50_local2 / f50_local3,
		statFractionText = Engine[@"hash_4F9F1239CFD921FE"]( @"hash_631CF0F51CCA3A27", f50_local2, f50_local3 )
	}
	local f50_local11
	if f50_local2 ~= f50_local3 then
		f50_local11 = not ShieldShouldUnlockItem_Dvar()
	else
		f50_local11 = false
	end
	f50_local10.isLocked = f50_local11
	f50_local9.models = f50_local10
	f50_local9.properties = {
		ctChallenge = true
	}
	f50_local7( f50_local8, f50_local9 )
	f50_local7 = {}
	if not CoD.isPC or not CoD.PCKoreaUtility.ShowKorea15Plus() then
		f50_local8 = CoD.ChallengesUtility.AddDarkOpsChallengeCardsToList( f50_arg0, Enum[@"emodes"][@"mode_zombies"], "zm", f50_local7 )
		if f50_local8 and not f50_local8.models.isLocked then
			table.insert( f50_local0, f50_local8 )
		end
	end
	if f50_arg1 then
		table.sort( f50_local0, function ( f51_arg0, f51_arg1 )
			local f51_local0 = f51_arg0.models
			local f51_local1 = f51_arg1.models
			if f51_local0.isLocked ~= f51_local1.isLocked then
				return f51_local1.isLocked
			else
				return tonumber( f51_local0.iconId ) < tonumber( f51_local1.iconId )
			end
		end )
	end
	return f50_local0
end

CoD.ChallengesUtility.GetChallengeTable = function ( f38_arg0, f38_arg1, f38_arg2, f38_arg3, f38_arg4 )
	local f38_local0 = {}
	local f38_local1 = Engine[@"getchallengeinfoforimages"]( f38_arg0, f38_arg3, f38_arg1 )
	if not f38_local1 then
		return f38_local0
	end
	local f38_local2 = Engine[@"getplayerstats"]( f38_arg0, CoD.STATS_LOCATION_NORMAL, f38_arg1 )
	local f38_local3 = 0
	local f38_local4 = 0
	if f38_local2 and f38_local2.PlayerStatsList then
		f38_local3 = f38_local2.PlayerStatsList.RANK.StatValue:get()
		f38_local4 = f38_local2.PlayerStatsList.PLEVEL.StatValue:get()
	end
	if f38_arg4 then
		table.sort( f38_local1, f38_arg4 )
	end
	for f38_local31, f38_local32 in ipairs( f38_local1 ) do
		local f38_local33 = f38_local32.challengeRow
		local f38_local34 = f38_local32.currentChallengeRow
		local f38_local35 = f38_local32.challengeCategory
		local f38_local36 = f38_local32.tableNum
		local f38_local37 = f38_local32.isMastery
		local f38_local38 = f38_local32.challengeType
		local f38_local28 = f38_local32.prevChallengeStatValue or 0
		local f38_local29 = f38_local32.currChallengeStatValue
		local f38_local39 = f38_local32.imageID
		local f38_local17 = 0
		local f38_local18 = 0
		local f38_local26 = 0
		local f38_local19 = ""
		local f38_local40, f38_local23, f38_local24, f38_local27, f38_local25 = nil
		if f38_local33 ~= nil then
			local f38_local8 = "gamedata/stats/" .. f38_arg2 .. "/statsmilestones" .. f38_local36 + 1 .. ".csv"
			local f38_local9 = tonumber( Engine[@"hash_4C6F8EC444864600"]( f38_local8, f38_local33, CoD.ChallengesUtility.TierIdCol ) )
			local f38_local10 = Engine[@"hash_4C6F8EC444864600"]( f38_local8, f38_local33, CoD.ChallengesUtility.TargetValCol )
			local f38_local11 = Engine[@"hash_4C6F8EC444864600"]( f38_local8, f38_local33, CoD.ChallengesUtility.NameStringCol )
			local f38_local12 = Engine[@"hash_4C6F8EC444864600"]( f38_local8, f38_local33, CoD.ChallengesUtility.NameStringCol ) .. "_DESC"
			local f38_local13 = tonumber( Engine[@"hash_4C6F8EC444864600"]( f38_local8, f38_local33, CoD.ChallengesUtility.XpEarnedCol ) )
			local f38_local14 = Engine[@"hash_4C6F8EC444864600"]( f38_local8, f38_local33, CoD.ChallengesUtility.UnlockRankCol )
			local f38_local15 = Engine[@"hash_4C6F8EC444864600"]( f38_local8, f38_local33, CoD.ChallengesUtility.UnlockPLevelCol )
			local f38_local16 = CoD.ChallengesUtility.GetLocalizedTierText( f38_local8, f38_local33 )
			if f38_local14 ~= "" then
				f38_local17 = tonumber( f38_local14 )
			end
			if f38_local15 ~= "" then
				f38_local18 = tonumber( f38_local15 )
			end
			if f38_local38 == Enum[@"statsmilestonetypes_t"][@"milestone_weapon"] then
				f38_local19 = Engine[@"hash_4F9F1239CFD921FE"]( Engine[@"getitemname"]( f38_local32.itemIndex, Enum[@"statindexoffset"][@"hash_6569E84652131CD7"], f38_arg1 ) )
			elseif f38_local38 == Enum[@"statsmilestonetypes_t"][@"milestone_group"] then
				f38_local19 = Engine[@"hash_4F9F1239CFD921FE"]( CoD.ChallengesUtility.GetChallengeTypeString( Engine[@"getitemgroupbyindex"]( f38_local32.itemIndex ) ) )
			elseif f38_local38 == Enum[@"statsmilestonetypes_t"][@"milestone_attachments"] then
				f38_local19 = Engine[@"localize"]( Engine[@"getattachmentnamebyindex"]( f38_local32.itemIndex ) )
			elseif f38_local38 == Enum[@"statsmilestonetypes_t"][@"milestone_gamemode"] then
				local f38_local20 = Engine[@"getgametypeinfo"]( Engine[@"getgametypename"]( f38_local32.itemIndex ) )
				local f38_local21 = Engine[@"hash_4F9F1239CFD921FE"]
				local f38_local22
				if f38_local20 then
					f38_local22 = f38_local20[@"challengetypestring"]
					if not f38_local22 then
					
					else
						f38_local19 = f38_local21( f38_local22 )
					end
				end
				f38_local22 = @"hash_0"
			end
			if f38_local16 ~= "" then
				f38_local23 = true
			end
			if not f38_local37 then
				if f38_local4 < f38_local18 then
					f38_local24 = true
					f38_local25 = Engine[@"hash_4F9F1239CFD921FE"]( @"hash_4E2EF437F27777CE", f38_local18 )
				elseif f38_local4 == 0 and f38_local3 < f38_local17 then
					f38_local24 = true
					f38_local25 = Engine[@"hash_4F9F1239CFD921FE"]( @"hash_510EFA40E4B9F78E", CoD.GetRankName( f38_local17, 0, f38_arg1 ), f38_local17 + 1 )
				end
			end
			if f38_local23 and f38_local24 then
				f38_local16 = Engine[@"localize"]( CoD.ChallengesUtility.TierString[0] )
			end
			local f38_local20 = f38_local32.currentChallengeRow
			if f38_local20 then
				f38_local12 = Engine[@"hash_4C6F8EC444864600"]( f38_local8, f38_local20, CoD.ChallengesUtility.NameStringCol ) .. "_DESC"
				if f38_local23 then
					f38_local26 = tonumber( Engine[@"hash_4C6F8EC444864600"]( f38_local8, f38_local20, CoD.ChallengesUtility.TierIdCol ) )
					f38_local10 = Engine[@"hash_4C6F8EC444864600"]( f38_local8, f38_local20, CoD.ChallengesUtility.TargetValCol )
					f38_local13 = tonumber( Engine[@"hash_4C6F8EC444864600"]( f38_local8, f38_local20, CoD.ChallengesUtility.XpEarnedCol ) )
					f38_local16 = CoD.ChallengesUtility.GetLocalizedTierText( f38_local8, f38_local20 )
				end
			end
			f38_local27 = Engine[@"localize"]( f38_local11, "", f38_local19, f38_local16 )
			if not f38_local25 then
				f38_local25 = Engine[@"localize"]( f38_local12, f38_local10, f38_local19 )
			end
			if ShieldShouldUnlockItem_Dvar() then
				f38_local28 = f38_local10
				f38_local29 = f38_local10
			end
			local f38_local21 = f38_local28 / f38_local10
			local f38_local22 = f38_local29 / f38_local10
			local f38_local30 = f38_local22 < 1
			if f38_local35 == "darkops" and not f38_local37 and f38_local30 then
				f38_local27 = Engine[@"hash_4F9F1239CFD921FE"]( @"challenge/classified" )
				f38_local25 = Engine[@"hash_4F9F1239CFD921FE"]( @"hash_5D39450F492BCD23" )
			end
			table.insert( f38_local0, {
				models = {
					title = f38_local27,
					description = f38_local25,
					iconId = f38_local39,
					icon = CoD.ChallengesUtility.GetBackgroundByID( f38_local39 ),
					maxTier = f38_local9,
					currentTier = f38_local26,
					previousVal = f38_local28,
					currentVal = f38_local29,
					prevStatPercent = f38_local21,
					statPercent = ShieldShouldUnlockItem_Dvar() and 1 or f38_local22,
					statFractionText = Engine[@"hash_4F9F1239CFD921FE"]( @"hash_631CF0F51CCA3A27", f38_local29, f38_local10 ),
					tierStatus = Engine[@"hash_4F9F1239CFD921FE"]( @"hash_10038A59531FCD1E", f38_local26 + 1, f38_local9 + 1 ),
					xp = f38_local13,
					percentComplete = f38_local22,
					isLocked = f38_local30 and not ShieldShouldUnlockItem_Dvar(),
					isWZ = f38_arg1 == Enum[@"emodes"][@"mode_warzone"]
				},
				properties = {
					isMastery = f38_local37,
					isDarkOps = f38_local35 == "darkops",
					category = f38_local35,
					targetVal = f38_local10
				}
			} )
		end
	end
	return f38_local0
end

CoD.PlayerRoleUtility.IsRoleUnlocked = function ( f183_arg0, f183_arg1, f183_arg2 )
	return ShieldIsRoleUnlocked( f183_arg0, f183_arg1, f183_arg2 )
end

CoD.ChallengesUtility.SetupCategoryStatsDatasource = function ( f1_arg0, f1_arg1, f1_arg2 )
	local f1_local0 = Engine[@"getchallengeinfoforimages"]( f1_arg0, nil, f1_arg1 )
	local f1_local1 = {
		[f1_arg2] = {}
	}
	f1_local1[f1_arg2].numComplete = 0
	f1_local1[f1_arg2].numTotal = 0
	for f1_local8, f1_local9 in pairs( CoD.ChallengesUtility.ChallengeCategoryTable[f1_arg2] ) do
		for f1_local5, f1_local6 in ipairs( f1_local9 ) do
			f1_local1[f1_local6] = {}
			f1_local1[f1_local6].numComplete = 0
			f1_local1[f1_local6].numTotal = 0
		end
		f1_local1[f1_local8] = {}
		f1_local1[f1_local8].numComplete = 0
		f1_local1[f1_local8].numTotal = 0
	end
	local f1_local2 = nil
	local f1_local3 = Engine[@"getmodelforcontroller"]( f1_arg0 )
	if f1_arg1 == Enum[@"emodes"][@"mode_multiplayer"] then
		f1_local2 = f1_local3:create( "ChallengesMPCategoryStats" )
	elseif f1_arg1 == Enum[@"emodes"][@"mode_zombies"] then
		f1_local2 = f1_local3:create( "ChallengesZMCategoryStats" )
	else
		f1_local2 = f1_local3:create( "ChallengesWZCategoryStats" )
	end
	for f1_local10, f1_local11 in ipairs( f1_local0 ) do
		local f1_local7 = f1_local11.challengeCategory
		if not f1_local11.isMastery and f1_local7 ~= "darkops" then
			--assert( f1_local1[f1_local7] )
			f1_local1[f1_local7].numTotal = f1_local1[f1_local7].numTotal + 1
			local f1_local12
			if f1_local11.currChallengeStatValue < Engine[@"hash_4C6F8EC444864600"]( "gamedata/stats/" .. f1_arg2 .. "/statsmilestones" .. f1_local11.tableNum + 1 .. ".csv", f1_local11.currentChallengeRow or f1_local11.challengeRow, CoD.ChallengesUtility.TargetValCol ) then
				f1_local12 = not ShieldShouldUnlockItem_Dvar()
			else
				f1_local12 = false
			end
			if not f1_local12 then
				f1_local1[f1_local7].numComplete = f1_local1[f1_local7].numComplete + 1
			end
			local f1_local13, f1_local14, f1_local15, f1_local16 = CoD.ChallengesUtility.SetupIsCategoryLocked( f1_arg0, f1_arg1, f1_arg2, f1_local11 )
			f1_local1[f1_local7].categoryLocked = f1_local1[f1_local7].categoryLocked or f1_local13
			f1_local1[f1_local7].categoryLockedText = f1_local1[f1_local7].categoryLockedText or f1_local14
			f1_local1[f1_local7].unlockRank = f1_local1[f1_local7].unlockRank or f1_local15
			f1_local1[f1_local7].unlockPLevel = f1_local1[f1_local7].unlockPLevel or f1_local16
		end
		if f1_local11.isMastery and f1_local1[f1_local7] then
			f1_local1[f1_local7].masteryIconId = f1_local11.imageID
		end
	end
	for f1_local10, f1_local11 in pairs( CoD.ChallengesUtility.ChallengeCategoryTable[f1_arg2] ) do
		local f1_local7 = false
		local f1_local5, f1_local6 = nil
		for f1_local13, f1_local14 in ipairs( f1_local11 ) do
			if not f1_local7 and f1_local1[f1_local14].categoryLocked then
				if f1_local1[f1_local14].unlockPLevel and (not f1_local6 or f1_local1[f1_local14].unlockPLevel < f1_local6) then
					f1_local6 = f1_local1[f1_local14].unlockPLevel
				elseif f1_local1[f1_local14].unlockRank and (not f1_local5 or f1_local1[f1_local14].unlockRank < f1_local5) then
					f1_local5 = f1_local1[f1_local14].unlockRank
				end
			else
				f1_local7 = true
			end
			f1_local1[f1_local10].numComplete = f1_local1[f1_local10].numComplete + f1_local1[f1_local14].numComplete
			f1_local1[f1_local10].numTotal = f1_local1[f1_local10].numTotal + f1_local1[f1_local14].numTotal
		end
		if not f1_local7 then
			if f1_local6 then
				f1_local1[f1_local10].categoryLocked = true
				f1_local1[f1_local10].categoryLockedText = Engine[@"hash_4F9F1239CFD921FE"]( @"hash_57FFD6D29AEB436E", f1_local6 )
			elseif f1_local5 then
				f1_local1[f1_local10].categoryLocked = true
				f1_local1[f1_local10].categoryLockedText = Engine[@"hash_4F9F1239CFD921FE"]( @"hash_381C07BC4A11544D", f1_local5 )
			end
		else
			f1_local1[f1_local10].categoryLocked = false
		end
		f1_local1[f1_local10].isSuperCategory = true
		f1_local1[f1_arg2].numComplete = f1_local1[f1_arg2].numComplete + f1_local1[f1_local10].numComplete
		f1_local1[f1_arg2].numTotal = f1_local1[f1_arg2].numTotal + f1_local1[f1_local10].numTotal
	end
	for f1_local10, f1_local11 in pairs( f1_local1 ) do
		local f1_local7 = 0
		if f1_local11.numTotal ~= 0 then
			f1_local7 = f1_local11.numComplete / f1_local11.numTotal
		end
		local f1_local5 = f1_local2:create( f1_local10 )
		local f1_local6 = f1_local5:create( "percentComplete" )
		f1_local6:set( f1_local7 )
		f1_local6 = f1_local5:create( "categoryLocked" )
		f1_local6:set( f1_local11.categoryLocked )
		f1_local6 = f1_local5:create( "categoryLockedText" )
		f1_local6:set( f1_local11.categoryLockedText )
		if f1_local11.masteryIconId then
			f1_local6 = f1_local5:create( "iconId" )
			f1_local6:set( f1_local11.masteryIconId )
		end
	end
	return f1_local2
end

CoD.WeaponOptionsUtility.IsItemLockedHelper = function ( f55_arg0, f55_arg1, f55_arg2 )
	if not CoD.WeaponOptionsUtility.IsCACPersonalizationProgressionEnabled( f55_arg1, f55_arg2 ) then
		
	else
		
	end
	local f55_local0, f55_local1, f55_local2, f55_local3 = CoD.WeaponOptionsUtility.GetWeaponOptionItemInfo( f55_arg0, f55_arg1, f55_arg2 )
	if f55_local0 and f55_local1 and f55_local2 and f55_local3 then
		if f55_local2 == Enum[@"eweaponoptiongroup"][@"weaponoption_group_paintjob"] then
			return false
		elseif f55_local2 == Enum[@"eweaponoptiongroup"][@"weaponoption_group_reticle"] then
			local f55_local4 = f55_arg1:getModel()
			if f55_local4.entitlement then
				f55_local4 = f55_arg1:getModel()
				if f55_local4.entitlement:get() then
					return false
				end
			end
		end
		if (f55_local2 == Enum[@"eweaponoptiongroup"][@"weaponoption_group_camo"] or f55_local2 == Enum[@"eweaponoptiongroup"][@"weaponoption_group_reticle"]) and f55_local1 == 0 then
			return false
		elseif f55_local2 == Enum[@"eweaponoptiongroup"][@"weaponoption_group_invalid"] then
			if f55_local1 == 0 then
				return false
			end
			local f55_local4 = Engine[@"getattachmentref"]( f55_local0, f55_local1 )
			for f55_local9, f55_local10 in ipairs( CoD.CACUtility.mpPrestigeAttachments ) do
				if f55_local4 == f55_local10.ref then
					local f55_local8
					if CoD.CACUtility.GetWeaponPLevel( f55_arg2, f55_local0 ) < f55_local9 then
						f55_local8 = not ShieldShouldUnlockItem_Dvar()
					else
						f55_local8 = false
					end
					return f55_local8
				end
			end
			return false
		else
			local f55_local4 = false
			local f55_local5 = CoD.BaseUtility.GetMenuSessionMode( f55_arg0 )
			if CoD.SafeGetModelValue( f55_arg1:getModel(), "weaponOptionCategory" ) == "mstr" or f55_local2 == Enum[@"eweaponoptiongroup"][@"weaponoption_group_reticle"] then
				f55_local4 = Engine[@"hash_6F1FD722970FDBA3"]( f55_arg2, f55_local0, f55_local3, f55_local5 )
			else
				f55_local4 = Engine[@"isitemoptionlocked"]( f55_arg2, f55_local0, f55_local3 )
			end
			if f55_local4 then
				return true
			else
				local f55_local6 = f55_local0 and Engine[@"hash_7B98952F69D937F9"]( f55_local0 )
				local f55_local7 = f55_local6 and CoD.BlackMarketTableUtility.LootInfoLookup( f55_arg2, f55_local6 )
				if f55_local2 == Enum[@"eweaponoptiongroup"][@"weaponoption_group_camo"] and f55_local7 and f55_local7.isLoot then
					return CoD.WeaponOptionsUtility.IsDarkmatterLockedForDLC( f55_arg2, f55_local0, f55_local5, f55_local2, f55_local3 )
				else
					return f55_local4
				end
			end
		end
	else
		return false
	end
end

CoD.CACUtility.GetHighestPermanentlyCompletedActiveCamoStage = function ( f118_arg0, f118_arg1, f118_arg2 )
	local f118_local0 = 1
	local f118_local1 = CoD.PlayerStatsUtility.GetStorageBufferForPlayer( f118_arg0 )
	f118_local1 = f118_local1 and f118_local1[@"playerstatslist"]
	if not f118_local1 then
		return f118_local0
	elseif f118_arg2 then
		for f118_local2 = 1, #f118_arg1.stages, 1 do
			if f118_arg1.stages[f118_local2][@"disabled"] == 1 then
				return f118_local0
			end
			f118_local0 = f118_local2
		end
		return f118_local0
	elseif ShieldShouldUnlockItem_Dvar() and #f118_arg1.stages >= CoD.CACUtility.BaseUnwrappedStageForActiveCamo then
		return CoD.CACUtility.BaseUnwrappedStageForActiveCamo
	end
	for f118_local6, f118_local7 in ipairs( f118_arg1.stages ) do
		local f118_local8 = f118_local7[@"permanentstatname"]
		local f118_local9 = f118_local7[@"hash_5181D2404B77545F"]
		if f118_local8 and f118_local9 then
			local f118_local5 = f118_local1[f118_local8]
			if f118_local5 then
				f118_local5 = f118_local1[f118_local8][@"challengevalue"]:get()
			end
			if f118_local5 and f118_local9 <= f118_local5 then
				f118_local0 = f118_local6 + 1
			end
		end
	end
	return f118_local0
end

---------------------------

-- Unlock Settings (Shield Unlock Data)
DataSources.ShieldUnlockData = DataSourceHelpers.ListSetup( "ShieldUnlockData", function ( f138_arg0 )
	local Settings = {}

	table.insert( Settings, CoD.OptionsUtility.CreateDvarSettings( f138_arg0, @"shield/unlock_all", @"shield/unlock_all_desc", "shield_unlock_all", "shield_unlock_all", {
		{
			option = Engine[@"hash_4F9F1239CFD921FE"]( @"hash_94EB0E3329EDF5F" ), -- "disabled", its hashed bruh
			value = 0,
			default = true
		},
		{
			option = Engine[@"hash_4F9F1239CFD921FE"]( @"menu/enabled" ),
			value = 1
		}
	}, nil, OnUnlockDataChange ) )

	table.insert( Settings, CoD.OptionsUtility.CreateDvarSettings( f138_arg0, @"shield/unlock_attch", @"shield/unlock_attch_desc", "shield_unlock_attachments", "shield_unlock_attachments", {
		{
			option = Engine[@"hash_4F9F1239CFD921FE"]( @"hash_94EB0E3329EDF5F" ),
			value = 0,
			default = true
		},
		{
			option = Engine[@"hash_4F9F1239CFD921FE"]( @"menu/enabled" ),
			value = 1
		}
	}, nil, OnUnlockDataChange ) )

	table.insert( Settings, CoD.OptionsUtility.CreateDvarSettings( f138_arg0, @"shield/unlock_loot", @"shield/unlock_loot_desc", "shield_unlock_loot", "shield_unlock_loot", {
		{
			option = Engine[@"hash_4F9F1239CFD921FE"]( @"hash_94EB0E3329EDF5F" ),
			value = 0,
			default = true
		},
		{
			option = Engine[@"hash_4F9F1239CFD921FE"]( @"menu/enabled" ),
			value = 1
		}
	}, nil, OnUnlockDataChange ) )

	table.insert( Settings, CoD.OptionsUtility.CreateDvarSettings( f138_arg0, @"shield/unlock_camos", @"shield/unlock_camos_desc", "shield_unlock_itemoptions", "shield_unlock_itemoptions", {
		{
			option = Engine[@"hash_4F9F1239CFD921FE"]( @"hash_94EB0E3329EDF5F" ),
			value = 0,
			default = true
		},
		{
			option = Engine[@"hash_4F9F1239CFD921FE"]( @"menu/enabled" ),
			value = 1
		}
	}, nil, OnUnlockDataChange ) )

	table.insert( Settings, CoD.OptionsUtility.CreateDvarSettings( f138_arg0, @"shield/unlock_items", @"shield/unlock_items_desc", "shield_unlock_items", "shield_unlock_items", {
		{
			option = Engine[@"hash_4F9F1239CFD921FE"]( @"hash_94EB0E3329EDF5F" ),
			value = 0,
			default = true
		},
		{
			option = Engine[@"hash_4F9F1239CFD921FE"]( @"menu/enabled" ),
			value = 1
		}
	}, nil, OnUnlockDataChange ) )

	table.insert( Settings, CoD.OptionsUtility.CreateDvarSettings( f138_arg0, @"shield/unlockclassslots", @"shield/unlockclassslots_desc", "shield_unlock_classes", "shield_unlock_classes", {
		{
			option = Engine[@"hash_4F9F1239CFD921FE"]( @"hash_94EB0E3329EDF5F" ),
			value = 0,
			default = true
		},
		{
			option = Engine[@"hash_4F9F1239CFD921FE"]( @"menu/enabled" ),
			value = 1
		}
	}, nil, OnUnlockDataChange ) )

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

-- unlock popup
CoD.Shield_Unlocks_SettingsPopup = InheritFrom( CoD.Menu )
LUI.createMenu.Shield_Unlocks_SettingsPopup = function ( f1_arg0, f1_arg1 )
	local self = CoD.Menu.NewForUIEditor( "Shield_Unlocks_SettingsPopup", f1_arg0 )
	local f1_local1 = self
	self:setClass( CoD.Shield_Unlocks_SettingsPopup )
	self.soundSet = "none"
	self:setOwner( f1_arg0 )
	self:setLeftRight( 0, 1, 0, 0 )
	self:setTopBottom( 0, 1, 0, 0 )
	self:playSound( "menu_open", f1_arg0 )
	self.anyChildUsesUpdateState = true
	f1_local1:addElementToPendingUpdateStateList( self )
	
	local CommomCenteredPopup = CoD.CommonCenteredPopup.new( f1_local1, f1_arg0, 0, 1, 0, 0, 0, 1, 0, 0 )
	CommomCenteredPopup.TitleText:setText("Unlock All Settings")
	CommomCenteredPopup.HeaderBackground:setAlpha( 0 )
	CommomCenteredPopup.HeaderTopBar:setAlpha( 0 )
	CommomCenteredPopup.HeaderBottomBar:setAlpha( 0 )
	self:addElement( CommomCenteredPopup )
	self.CommomCenteredPopup = CommomCenteredPopup
	
	-- datasources for unlocks here
	local UnlockSettingsList = LUI.UIList.new( f1_local1, f1_arg0, 3, 3, nil, false, false, false, false )

	if Engine[@"getdvarint"]("shield_ui_color") == 0 then
		UnlockSettingsList:setRGB(0, 1, 1)
	elseif Engine[@"getdvarint"]("shield_ui_color") == 1 then
		UnlockSettingsList:setRGB(1, 0, 0)
	elseif Engine[@"getdvarint"]("shield_ui_color") == 2 then
		UnlockSettingsList:setRGB(0, 1, 0)
	end

	UnlockSettingsList:setLeftRight( 0.5, 0.5, -250, 250 )
	UnlockSettingsList:setTopBottom( 0.50, 0.50, -240 + 30, -180 + 30 )
	--UnlockSettingsList:setScale(0.90, 0.90)
	--UnlockSettingsList:setAutoScaleContent( true )
	UnlockSettingsList:setVerticalCount(9) -- fix
	UnlockSettingsList:setHorizontalCount(1)
	UnlockSettingsList:setSpacing(10) -- spacing needed..
	UnlockSettingsList:setWidgetType( CoD.CustomGames_SettingSliderNoCustom )
	UnlockSettingsList:setAlignment( Enum[@"luialignment"][@"lui_alignment_left"] )
	UnlockSettingsList:setDataSource( "ShieldUnlockData" )
	self:addElement( UnlockSettingsList )
	self.UnlockSettingsList = UnlockSettingsList

	UnlockSettingsList.id = "UnlockSettingsList"

	-- desc
	local UnlockSettingDescription = LUI.UIText.new( 0.5, 0.5, -300, 250, 0.65, 0.65, 150, 180 )
	UnlockSettingDescription:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )
	UnlockSettingDescription:setTTF("notosans_bold")
	UnlockSettingDescription:setBackingType( 2 )
	UnlockSettingDescription:setBackingColor( 0.04, 0.81, 1 )
	UnlockSettingDescription:setBackingAlpha( 0.01 )
	UnlockSettingDescription:setBackingXPadding( 12 )
	UnlockSettingDescription:setBackingYPadding( 6 )
	UnlockSettingDescription:setAlignment( Enum[@"luialignment"][@"lui_alignment_left"] )
	UnlockSettingDescription:setAlignment( Enum[@"luialignment"][@"lui_alignment_top"] )
	self:addElement( UnlockSettingDescription )
	self.UnlockSettingDescription = UnlockSettingDescription

	-- link it, subtitles like
	UnlockSettingDescription:linkToElementModel( UnlockSettingsList, "desc", true, function ( model )
		local f7_local0 = model:get()
		if f7_local0 ~= nil then
			UnlockSettingDescription:setText( Engine[@"hash_4F9F1239CFD921FE"]( f7_local0 ) )
		end
	end )
	
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
	--AimSettingsList.id = "AimSettingsList"
	--if CoD.isPC then
	--	PCSmallCloseButton.id = "PCSmallCloseButton"
	--end
	self:processEvent( {
		name = "menu_loaded",
		controller = f1_arg0
	} )
	self.__defaultFocus = UnlockSettingsList
	if CoD.isPC and (IsKeyboard( f1_arg0 ) or self.ignoreCursor) then
		self:restoreState( f1_arg0 )
	end
	LUI.OverrideFunction_CallOriginalSecond( self, "close", self.__onClose )
	if PostLoadFunc then
		PostLoadFunc( self, f1_arg0 )
	end
	
	f1_local7 = self
	--MenuHidesFreeCursor( f1_local1, f1_arg0 )

	CoD.EnhPrintInfo("Called", "Shield's Unlock All Settings Menu")

	return self
end

CoD.Shield_Unlocks_SettingsPopup.__resetProperties = function ( f13_arg0 )
	f13_arg0.UnlockSettingsList:completeAnimation()
	f13_arg0.UnlockSettingDescription:completeAnimation()
	f13_arg0.UnlockSettingsList:setLeftRight( 0.5, 0.5, -250, 250 )
	f13_arg0.UnlockSettingDescription:setLeftRight( 0.5, 0.5, -250, 250 )
end

CoD.Shield_Unlocks_SettingsPopup.__clipsPerState = {
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
			f15_arg0.UnlockSettingsList:completeAnimation()
			f15_arg0.UnlockSettingsList:setLeftRight( 0.5, 0.5, -290, 290 )
			f15_arg0.clipFinished( f15_arg0.UnlockSettingsList )
			f15_arg0.UnlockSettingDescription:completeAnimation()
			f15_arg0.UnlockSettingDescription:setLeftRight( 0.5, 0.5, -290, 290 )
			f15_arg0.clipFinished( f15_arg0.UnlockSettingDescription )
		end
	}
}

CoD.Shield_Unlocks_SettingsPopup.__onClose = function ( f16_arg0 )
	f16_arg0.UnlockSettingDescription:close()
	f16_arg0.CommomCenteredPopup:close()
	f16_arg0.UnlockSettingsList:close()
	--f16_arg0.PCSmallCloseButton:close()
end