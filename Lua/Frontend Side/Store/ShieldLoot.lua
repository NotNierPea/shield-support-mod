--[[
		.\hksc.exe ".\Lua\ShieldLoot.Lua" -o "C:\Program Files (x86)\Call of Duty Black Ops 4\project-bo4\mods\T8ShieldSupport\Lua\ShieldLoot.luac"
]]

---------------------------

CoD.ShieldInitLuaFile()

---------------------------

--[[
	Black market items of our own, sold in the black market's contraband slot (the third of the item shop): the game
	picks them for it at random, as any contraband item, and sells them at their own price. They are the support fastfile's gamedata/shield/loot_items.csv: loot
	id, type, loot rule, slot, image, card image, name, description, currency, price. The client (custom_loot.cpp) adds
	them to the game's loot tables, gives their texts (shield/loot/<loot id>/name and /desc) and sells them on their
	loot rule, which is also their sku in the shop.
]]
local LOOT_TABLE = "gamedata/shield/loot_items.csv"
-- the item shop's third slot, looked up when used: the enum may not be there when this file is read
local function IsContrabandSlot( slot )
	return slot ~= nil and slot == Enum[@"hash_1CF7389DF8F39785"][@"hash_2AD9FB648E0B9A55"]
end

local function Log( text )
	Engine[@"printinfo"]( 0, "[shield] loot: " .. text .. "\n" )
end

local function Cell( row, column )
	return Engine[@"tablelookupgetcolumnvalueforrow"]( LOOT_TABLE, row, column )
end

-- the items of the table, nothing when the support fastfile is not there
local function ReadItems()
	local items = {}
	local rows = tonumber( Engine[@"gettablerowcount"]( LOOT_TABLE ) ) or 0

	for row = 0, rows - 1, 1 do
		-- a string, as the game passes loot ids: a Lua number here is a float, too short for them
		local lootId = Cell( row, 0 )
		local rule = tonumber( Cell( row, 2 ) )

		if lootId ~= nil and lootId ~= "" and rule ~= nil then
			table.insert( items, {
				lootId = lootId,
				rule = rule,
				image = Cell( row, 4 ) or "",
				currency = tonumber( Cell( row, 8 ) ) or 0,
				price = tonumber( Cell( row, 9 ) ) or 0
			} )
		end
	end

	return items
end

-- an id from the game may come as a string or as a (float) number
local function FindItem( itemId )
	if itemId == nil then
		return nil
	end

	for _, item in ipairs( ReadItems() ) do
		if item.lootId == tostring( itemId ) or ( type( itemId ) == "number" and tonumber( item.lootId ) == itemId ) then
			return item
		end
	end
end

-- the slot's item at our price and with our description; the sku of both prices is the loot rule
local function SetItemModels( models, item )
	local points = item.currency == CoD.BlackMarketUtility.COD_POINTS_CURRENCY_ID

	models.desc = Engine[@"hash_4F9F1239CFD921FE"]( Engine[@"converttoxhash"]( "shield/loot/" .. item.lootId .. "/desc" ) )
	models.price = points and item.price or 0
	models.skuID = tostring( item.rule )
	models.casePrice = points and 0 or item.price
	models.caseRule = item.rule
end

-- The black market's tables are made again after this file is read (its hooks never ran when they were made only
-- here), so they are hooked here and again when the black market opens: whatever tables there are then.
local function HookContrabandPrice()
	local utility = CoD.BlackMarketTableUtility
	if not utility or utility.shieldLoot or not utility.GetContrabandSkuAndCaseRule then
		return
	end

	utility.shieldLoot = true

	-- every contraband item costs the same in the game (dvars, 100 COD Points or 2 crates): ours its own
	local GameContrabandPrice = utility.GetContrabandSkuAndCaseRule
	utility.GetContrabandSkuAndCaseRule = function ( controller, itemId )
		local item = FindItem( itemId )

		if item then
			local points = item.currency == CoD.BlackMarketUtility.COD_POINTS_CURRENCY_ID
			return {
				cpPrice = points and item.price or 0,
				cpSku = item.rule,
				casePrice = points and 0 or item.price,
				caseRule = item.rule
			}
		end

		return GameContrabandPrice( controller, itemId )
	end

	Log( "contraband price hooked" )
end

local function HookContrabandSlot()
	if not CoD.BlackMarketUtility or CoD.BlackMarketUtility.shieldLoot or not CoD.BlackMarketUtility.SetupItemShopSunsetSlotDatasource then
		return
	end

	CoD.BlackMarketUtility.shieldLoot = true

	local GameSetupSlot = CoD.BlackMarketUtility.SetupItemShopSunsetSlotDatasource
	CoD.BlackMarketUtility.SetupItemShopSunsetSlotDatasource = function ( controller, slot )
		-- an item no contraband row has (an id an older ShieldLoot.lua put in) leaves the slot empty: a new one is picked
		if IsContrabandSlot( slot ) then
			local shown = Engine[@"hash_6F2CB6360236F359"]( controller, slot )

			if shown and not CoD.BlackMarketTableUtility.GetContrabandItemInfo( controller, shown.itemId, 0 ) then
				CoD.BlackMarketUtility.RevealItemShopSunsetSlotItem( controller, slot )
				Log( "unknown item " .. tostring( shown.itemId ) .. " taken out of the contraband slot" )
			end
		end

		local list = GameSetupSlot( controller, slot )
		local shown = Engine[@"hash_6F2CB6360236F359"]( controller, slot )
		local item = shown and FindItem( shown.itemId )

		if item and list then
			Log( "item " .. item.lootId .. " is in the contraband slot" )

			for _, entry in ipairs( list ) do
				if entry.models then
					SetItemModels( entry.models, item )
				end
			end
		end

		return list
	end

	Log( "contraband slot hooked" )
end

-- The shop's price tag shows FREE for no COD Points price before it looks at the crates price (every game item has both);
-- with crates only it shows the crates price, as the duplicate protected crate's card does.
local function HookPriceTag()
	local tag = CoD.ContractItemCost
	if not tag or tag.shieldLoot or not tag.new then
		return
	end

	tag.shieldLoot = true

	local GameNewTag = tag.new
	tag.new = function ( menu, controller, ... )
		local self = GameNewTag( menu, controller, ... )

		for _, state in ipairs( self.stateConditions or {} ) do
			if state.stateName == "Free" then
				local GameFree = state.condition
				state.condition = function ( menu, element, event )
					return GameFree( menu, element, event ) and not CoD.ModelUtility.IsSelfModelValueGreaterThan( element, controller, "casePrice", 0 )
				end
			end
		end

		return self
	end

	Log( "price tag hooked" )
end

local function Install()
	HookContrabandPrice()
	HookContrabandSlot()
	HookPriceTag()
end

Install()

-- the black market opens: its tables, if made again, are hooked now
local GameOpenOverlay = OpenOverlay
OpenOverlay = function ( self, menuName, controller, userData )
	if menuName == "QuarterMasterMenu" then
		Install()
	end

	return GameOpenOverlay( self, menuName, controller, userData )
end
