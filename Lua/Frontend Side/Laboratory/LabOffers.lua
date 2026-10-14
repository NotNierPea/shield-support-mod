--[[
		.\hksc.exe ".\Lua\LabOffers.Lua" -o "C:\Program Files (x86)\Call of Duty Black Ops 4\project-bo4\mods\T8ShieldSupport\Lua\LabOffers.luac"
]]

---------------------------

CoD.ShieldInitLuaFile()

---------------------------

--[[
	The offers of the zombies laboratory the old servers handed out. The game has eight mixes (scriptbundles
	zm_lab_*), shows three of them always, and the others only as experiments or special offers that the servers
	named in dvars (laboratory_special_offer_1 to 3). Without them those five are gone, the triple ones too.
	They are put back as special offers, in the panel the laboratory has for them under its regular ones: into the
	list of offers of the game (DataSources.ZMLaboratoryNPItemList), after what it makes itself. That panel has one
	row of three, it gets a second. Bought, they ask for the loot drop of their bundle like the others, which the
	client answers (LAB_OFFERS of bdLootGeneration.cpp).
]]
-- From the cheapest, as the client prices them. The names and descriptions are the mod's (localize entries of
-- metadata.json): those of the bundles are missing for some, and they say what the client gives. talisman: the icon
-- of an offer with one stands in for its own when that is missing.
local ShieldLabOffers = {
	{ name = @"zm_lab_beryllium_bundle", label = @"shield/lab_beryllium_bundle", description = @"shield/lab_beryllium_bundle_desc" },
	{ name = @"zm_lab_titanium_treble", label = @"shield/lab_titanium_treble", description = @"shield/lab_titanium_treble_desc" },
	{ name = @"zm_lab_selenium_selection", label = @"shield/lab_selenium_selection", description = @"shield/lab_selenium_selection_desc" },
	{ name = @"zm_lab_rhodium_roundup", label = @"shield/lab_rhodium_roundup", description = @"shield/lab_rhodium_roundup_desc", talisman = true },
	{ name = @"zm_lab_tungsten_tripler", label = @"shield/lab_tungsten_tripler", description = @"shield/lab_tungsten_tripler_desc", talisman = true }
}

-- the regular offers whose icons stand in: without a talisman, and with one
local FALLBACK_ICON = @"zm_lab_carbon_combo"
local FALLBACK_TALISMAN_ICON = @"zm_lab_palladium_package"

-- the rows of the panel, of the height of an offer and the space between them (LaboratorySpecialOffers)
local OFFER_ROWS = 2
local OFFER_LIST_TOP = 62.5
local OFFER_HEIGHT = 150
local OFFER_SPACING = 16

local function IsShieldOffer( name )
	for _, offer in ipairs( ShieldLabOffers ) do
		if offer.name == name then
			return true
		end
	end

	return false
end

-- The fields of a bundle are looked up by their names: the keys are hashes of 16 digits, and those the
-- decompiled scripts show have lost the first one.
local function IconOf( bundle )
	return bundle and bundle[@"tileicon"]
end

-- An icon the frontend has loaded. The card of an offer registers its icon, and an image that is in no zone loaded
-- makes that a Lua error: some offers name icons that never shipped.
local function IsIconLoaded( icon )
	return icon ~= nil and pcall( RegisterImage, icon )
end

-- an offer as the list of the game makes it from its bundle, see ZMLaboratoryNPItemList in the laboratory utility
local function OfferOf( bundle, offer )
	local icon = IconOf( bundle )

	if not IsIconLoaded( icon ) then
		local stand_in = IconOf( Engine[@"hash_2E00B2F29271C60B"]( offer.talisman and FALLBACK_TALISMAN_ICON or FALLBACK_ICON ) )

		CoD.EnhPrintInfo( "icon " .. tostring( icon ) .. " is not loaded, the one of a regular offer stands in: " .. tostring( stand_in ), "Lab offers" )
		icon = IsIconLoaded( stand_in ) and stand_in or nil
	end

	local models = {
		skuID = bundle[@"skuid"] or 0,
		dropType = bundle[@"droptype"] or 0,
		icon = icon,
		name = Engine[@"hash_4F9F1239CFD921FE"]( offer.label ),
		labelName = offer.label,
		displayName = bundle[@"numplasma"] or 0,
		description = offer.description,
		plasmaPrice = bundle[@"plasmaprice"] or 0,
		-- in COD Points, for offers bought with them: these are bought with plasma
		price = 0,
		specialOffer = true,
		maxQuantity = bundle[@"maxquantity"],
		offerAssetName = offer.name
	}

	local properties = {
		action = CoD.ZMLaboratoryUtility.DoLootQueryAndSendClientScriptNotify,
		actionParam = { price = models.price },
		widgetOverride = CoD.LaboratoryListItem
	}

	-- the colour the centrifuge of the laboratory takes while the offer has the focus
	if bundle[@"centrifugecolor"] and bundle[@"globstate"] then
		properties.focusChangedNotifyParams = {
			centrifuge_color = bundle[@"centrifugecolor"],
			glob_state = bundle[@"globstate"]
		}
	end

	return models, properties
end

-- the offers go into the list the game made: its model, and its buttons when its filter takes them
local function AddShieldOffers( controller, list, filter )
	if list.model == nil or list.buttons == nil then
		return
	end

	for index, offer in ipairs( ShieldLabOffers ) do
		local bundle = Engine[@"hash_2E00B2F29271C60B"]( offer.name )

		if bundle ~= nil then
			local models, properties = OfferOf( bundle, offer )
			local model = Engine[@"createmodel"]( list.model, "shield_offer_" .. index )

			LuaUtils.CreateModelsFromTable( model, models )

			if not filter or filter( model ) then
				table.insert( list.buttons, {
					model = model,
					properties = properties
				} )
			end
		else
			CoD.EnhPrintInfo( "the game has no bundle for laboratory offer " .. index, "Lab offers" )
		end
	end
end

-- Put into the list of offers and into the check of the popups whether an offer still stands, which asks the dvars of
-- the servers. Done again whenever the overrides of the mod are: the file of the laboratory can be loaded after this one.
CoD.LabOffersReload = function ()
	local utility = CoD.ZMLaboratoryUtility
	local source = DataSources.ZMLaboratoryNPItemList

	if utility == nil or source == nil or source.prepare == nil then
		return
	end

	if source.prepare ~= CoD.Shield.LabOffersPrepare then
		local prepare = source.prepare

		CoD.Shield.LabOffersPrepare = function ( controller, list, filter )
			prepare( controller, list, filter )
			AddShieldOffers( controller, list, filter )
		end

		source.prepare = CoD.Shield.LabOffersPrepare
	end

	if utility.IsOfferAvailable ~= CoD.Shield.LabOffersAvailable then
		local available = utility.IsOfferAvailable

		CoD.Shield.LabOffersAvailable = function ( name )
			return IsShieldOffer( name ) or available( name )
		end

		utility.IsOfferAvailable = CoD.Shield.LabOffersAvailable
	end
end

-- the panel of special offers of a laboratory just made gets its second row
CoD.LabOffersLayout = function ( menu )
	local panel = menu.SpecialOffers
	local list = panel and panel.SpecialOffers

	if list == nil then
		return
	end

	list:setTopBottom( 0, 0, OFFER_LIST_TOP, OFFER_LIST_TOP + OFFER_ROWS * OFFER_HEIGHT + ( OFFER_ROWS - 1 ) * OFFER_SPACING )
	list:setVerticalCount( OFFER_ROWS )
	list:updateDataSource()
end

CoD.LabOffersReload()
