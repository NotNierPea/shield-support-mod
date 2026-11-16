--[[
		.\hksc.exe ".\Lua\Mastercraft.Lua" -o "C:\Program Files (x86)\Call of Duty Black Ops 4\project-bo4\mods\T8ShieldSupport\Lua\Mastercraft.luac"
]]

---------------------------

CoD.ShieldInitLuaFile()

---------------------------

-- allow camos on mastercrafts
CoD.CACUtility.OpenWeaponPersonalizationOverlay = function ( f266_arg0, f266_arg1, f266_arg2, f266_arg3, f266_arg4, f266_arg5 )
	local f266_local0 = "WeaponPersonalization"
	--if CoD.SafeGetModelValue( f266_arg4:getModel(), "isMastercraft" ) then
	--	f266_local0 = "WeaponTabbedAccessoriesSelect"
	--end
	CoD.CACUtility.OpenCACOverlay( f266_arg0, f266_arg1, f266_arg2, f266_local0, f266_arg3, f266_arg5 )
end

--[[
	Keep the mastercraft when a camo (or reticle) goes on it. The game's camo list (GetWeaponOptionsTableForCategory)
	sets menu._baseWeaponModelSlot to the mastercraft's base slot when the weapon has the mastercraft's "theme" camo
	(attachmenttable theme row with a base slot), and equipping or previewing any camo then writes that slot back:
	the base model. Mastercrafts whose theme row has no base slot never got it, so camos already worked on them.
	Zombies and Blackout clear the slot of every non-base signature weapon on a camo instead.
]]
local CAMO_GROUP = Enum[@"eweaponoptiongroup"][@"weaponoption_group_camo"]
local Wrapped = {}
local InstallCamoKeep = nil

local function IsWrapped( func )
	return func ~= nil and Wrapped[func] == true
end

local function CurrentWeaponModelSlot( menu )
	local slotModel = CoD.WeaponOptionsUtility.GetWeaponSlotModelForMode( menu )
	return slotModel and slotModel:get()
end

local function WrapOptionsTable( original )
	local wrapper = function ( menu, controller, group, weaponIndex, attachment, allFilters )
		-- ZM / WZ utilities can load after this file
		InstallCamoKeep()

		local result = original( menu, controller, group, weaponIndex, attachment, allFilters )

		-- the game's pick, still used to take a theme off
		menu._shieldThemeBaseSlot = menu._baseWeaponModelSlot

		local ok, slot = pcall( CurrentWeaponModelSlot, menu )
		if ok and slot then
			menu._baseWeaponModelSlot = slot
		end

		return result
	end

	Wrapped[wrapper] = true
	return wrapper
end

local function WrapClearOptions( original )
	local wrapper = function ( element, menu, controller )
		local category = element and CoD.SafeGetModelValue( element:getModel(), "weaponOptionCategory" )

		-- taking a mastercraft theme off still goes back to the base weapon
		if category == "theme" and menu then
			local kept = menu._baseWeaponModelSlot
			menu._baseWeaponModelSlot = menu._shieldThemeBaseSlot
			local ok, err = pcall( original, element, menu, controller )
			menu._baseWeaponModelSlot = kept

			if not ok then
				error( err )
			end
			return
		end

		return original( element, menu, controller )
	end

	Wrapped[wrapper] = true
	return wrapper
end

-- ZM / WZ variant slots keep their weapon model slot through a camo
local function WrapVariantCamo( original, utility )
	local wrapper = function ( self, element, controller, menu )
		local typeModel = element and element:getModel( controller, "weaponOptionType" )
		local itemIndex = menu and menu._model and menu._model.itemIndex and menu._model.itemIndex:get()

		if not typeModel or typeModel:get() ~= CAMO_GROUP or not itemIndex then
			return original( self, element, controller, menu )
		end

		local variant = utility.GetVariantSlot( controller, itemIndex, true )
		local slot = variant and variant.weaponModelSlot and variant.weaponModelSlot:get()
		local menuSlotModel = menu._model.weaponModelSlot
		local menuSlot = menuSlotModel and menuSlotModel:get()

		original( self, element, controller, menu )

		local restored = false

		if slot and variant.weaponModelSlot:get() ~= slot then
			variant.weaponModelSlot:set( slot )
			restored = true
		end

		if menuSlot and menuSlotModel:get() ~= menuSlot then
			menuSlotModel:set( menuSlot )
			restored = true
		end

		if restored then
			CoD.WeaponOptionsUtility.UpdateWeaponOptionLists( element, controller )
		end
	end

	Wrapped[wrapper] = true
	return wrapper
end

--[[
	Our Mastercrafts (the support fastfile's custom_mastercrafts.csv; the client adds them to the weapons' variant lists)
	are always shown and kept in classes: the game hides a variant whose loot isn't owned and resets a class's to the
	base weapon. Ours are known by their name (column 1, a localize key) as the menus show it.
]]
local MASTERCRAFT_TABLE = "gamedata/shield/custom_mastercrafts.csv"
local MastercraftNames = nil

local function IsShieldMastercraft( variant )
	if not MastercraftNames then
		local rows = tonumber( Engine[@"gettablerowcount"]( MASTERCRAFT_TABLE ) ) or 0
		if rows <= 0 then
			return false
		end

		MastercraftNames = {}
		for row = 0, rows - 1 do
			local key = Engine[@"tablelookupgetcolumnvalueforrow"]( MASTERCRAFT_TABLE, row, 1 )
			if key and key ~= "" then
				MastercraftNames[Engine[@"hash_4F9F1239CFD921FE"]( key )] = true
			end
		end
	end

	local name = variant and variant[@"displayname"]
	if not name or name == @"hash_0" then
		return false
	end

	return MastercraftNames[Engine[@"hash_4F9F1239CFD921FE"]( name )] == true
end

local function WrapFilterSignatureWeapon( original )
	local wrapper = function ( controller, variant, baseOnly, ownedOnly )
		if not baseOnly then
			local ok, ours = pcall( IsShieldMastercraft, variant )
			if ok and ours then
				return true
			end
		end

		return original( controller, variant, baseOnly, ownedOnly )
	end

	Wrapped[wrapper] = true
	return wrapper
end

-- wraps each function once; a utility the game reloads gets wrapped again
InstallCamoKeep = function()
	local cac = CoD.CACUtility

	if cac and cac.FilterSignatureWeapon and not IsWrapped( cac.FilterSignatureWeapon ) then
		cac.FilterSignatureWeapon = WrapFilterSignatureWeapon( cac.FilterSignatureWeapon )
	end

	local options = CoD.WeaponOptionsUtility

	if options then
		if options.GetWeaponOptionsTableForCategory and not IsWrapped( options.GetWeaponOptionsTableForCategory ) then
			options.GetWeaponOptionsTableForCategory = WrapOptionsTable( options.GetWeaponOptionsTableForCategory )
		end

		if options.ClearWeaponOptions and not IsWrapped( options.ClearWeaponOptions ) then
			options.ClearWeaponOptions = WrapClearOptions( options.ClearWeaponOptions )
		end
	end

	for _, utility in ipairs( { CoD.ZMLoadoutUtility or false, CoD.WZUtility or false } ) do
		if utility and utility.SetWeaponOptionForVariant and utility.GetVariantSlot and not IsWrapped( utility.SetWeaponOptionForVariant ) then
			utility.SetWeaponOptionForVariant = WrapVariantCamo( utility.SetWeaponOptionForVariant, utility )
		end
	end
end

InstallCamoKeep()

CoD.MasterCraftReload = function()
	CoD.CACUtility.OpenWeaponPersonalizationOverlay = function ( f266_arg0, f266_arg1, f266_arg2, f266_arg3, f266_arg4, f266_arg5 )
		local f266_local0 = "WeaponPersonalization"
		--if CoD.SafeGetModelValue( f266_arg4:getModel(), "isMastercraft" ) then
		--	f266_local0 = "WeaponTabbedAccessoriesSelect"
		--end
		CoD.CACUtility.OpenCACOverlay( f266_arg0, f266_arg1, f266_arg2, f266_local0, f266_arg3, f266_arg5 )
	end

	InstallCamoKeep()
end
