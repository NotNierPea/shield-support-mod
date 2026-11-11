--[[
		.\hksc.exe ".\Lua\Frontend Side\Outfits\Outfits.lua" -o "C:\Program Files (x86)\Call of Duty Black Ops 4\project-bo4\internals\T8ShieldSupport\Lua\Frontend\Outfits.luac"
]]

---------------------------

if not CoD.isFrontend then
	return
end

CoD.ShieldInitLuaFile()

---------------------------

--[[
	Outfits of ours on zombies characters (shield-client "outfit_adds", e.g. Scarlett's): the game's personalize menu has an
	outfit list only for multiplayer specialists (DataSources.MPOutfitCategories adds the "outfit" category only in that
	customization mode), the others get their war paints alone. This is the game's list with the outfit category for any
	character with outfits of ours (their presets marked: matchedWarPaintLootId "shield_outfit"; the default one beside them
	too), and that list showing ours alone (stock presets of the Tag crew and others are broken outside multiplayer).
	The outfit picked is saved as in multiplayer (the loadout's selectedoutfit); the support GSC applies it in zombies, where
	zm_characters sets outfit 0 (SprayGestureWheel.lua sends it to the server).
]]
local function Log( text )
	Engine[@"printinfo"]( 0, "[shield] outfits: " .. text .. "\n" )
end

-- an outfit shield-client added (or the default one it gave a preset)
local function IsOurs( outfit )
	for _, preset in ipairs( outfit and outfit.presets or {} ) do
		if preset.matchedWarPaintLootId == @"shield_outfit" then
			return true
		end
	end
	return false
end

-- (outfits, ours, with presets: a multiplayer / Blackout specialist's outfits on its zombies copy)
local function CountOutfits( customization )
	local outfits, ours, presets = 0, 0, 0
	for _, outfit in ipairs( customization and customization.outfits or {} ) do
		outfits = outfits + 1
		if outfit.isValid and IsOurs( outfit ) then
			ours = ours + 1
		end
		if outfit.isValid and outfit.presets and #outfit.presets > 0 then
			presets = presets + 1
		end
	end
	return outfits, ours, presets
end

-- the breadcrumb models are made for multiplayer's specialists: none for the others' outfit tab
local function PresetsBreadcrumb( controller, mode, characterIndex )
	local ok, breadcrumb = pcall( DataSources.SpecialistOutfitBreadcrumbs.getBreadcrumbModelForPresetsCategory, controller, mode, characterIndex )
	return ok and breadcrumb or nil
end

local logged = {}

local function Categories( controller, list )
	local model = list.menu:getModel()
	local characterIndex = model.characterIndex:get()
	local mode = Engine[@"currentsessionmode"]()
	local customizationMode = model.customizationMode and model.customizationMode:get() or mode
	local customization = CoD.PlayerRoleUtility.GetCachedHeroCustomization( mode, characterIndex )
	local categories = {}
	local outfits, owned, withPresets = CountOutfits( customization )

	if not logged[mode .. ":" .. characterIndex] then
		logged[mode .. ":" .. characterIndex] = true
		Log( string.format( "mode %d (customization %d), character %d: %d outfits, %d ours, %d with presets", mode, customizationMode, characterIndex, outfits, owned, withPresets ) )
	end

	-- (in zombies only the support zone's specialist copies have presets: shield-client takes the stock zombies ones off)
	if customizationMode == Enum[@"emodes"][@"mode_multiplayer"] or owned > 0
		or ( mode == Enum[@"emodes"][@"mode_zombies"] and characterIndex >= 30 and withPresets > 0 ) then
		table.insert( categories, {
			models = {
				tabName = @"hash_63C743FD222BE966",
				category = @"outfit",
				breadcrumb = PresetsBreadcrumb( controller, mode, characterIndex ),
				camera = "character"
			}
		} )
	end

	local hasWarPaints = false
	for _, outfit in ipairs( customization and customization.outfits or {} ) do
		if outfit.isValid then
			for index, warPaint in ipairs( outfit.warPaints ) do
				if index > 1 and CoD.PlayerRoleUtility.IsWarPaintOwned( controller, warPaint, outfit.presets ) then
					hasWarPaints = true
					break
				end
			end
		end
		if hasWarPaints then
			break
		end
	end

	table.insert( categories, {
		models = {
			tabName = @"hash_1ADD4C3535DC47",
			disabled = not hasWarPaints,
			category = @"war_paint",
			breadcrumb = DataSources.SpecialistOutfitBreadcrumbs.getBreadcrumbModelForItemTypeCategory( controller, mode, characterIndex, Enum[@"characteritemtype"][@"hash_48E3A65D78229DC1"] ),
			camera = "face"
		}
	} )
	return categories
end

-- the game's playerroleutility may be read after this file (it makes its own MPOutfitCategories then): ours put back after
-- every require that replaced it
local ours = nil

-- a game outfit of a specialist (its presets: the colour variants a specialist outfit has; the zombies ones' war paint sets
-- have none, the crews' broken ones had theirs taken off by shield-client)
local function IsSpecialistOutfit( outfit )
	return outfit ~= nil and outfit.presets ~= nil and #outfit.presets > 0
end

-- the outfit list of a character with outfits of ours: those and its specialist outfits (Spectre's beside the School Mascot)
local function WrapOutfitList()
	local themes = DataSources.MPSpecialistThemes
	local helpers = themes and themes.getCategoryHelperFunctions
	local game = helpers and helpers[@"outfit"]
	if not game or helpers.shieldOurs == game then
		return
	end
	local wrapped = function ( controller, customization, ... )
		local result = game( controller, customization, ... )
		local _, owned = CountOutfits( customization )
		if result and owned > 0 then
			local filter = result.filter
			result.filter = function ( index, outfit )
				return ( IsOurs( outfit ) or IsSpecialistOutfit( outfit ) ) and filter( index, outfit )
			end
		end
		return result
	end
	helpers[@"outfit"] = wrapped
	helpers.shieldOurs = wrapped
	Log( "outfit list wrapped" )
end

--[[
	WZ's character select shows the games a character is from (CharacterSelection_FeaturedGamesList: WaW to BO4 marks, the
	role bundle's characterint4..8). Characters of ours from other games have those off (shield-client "role_bundle") and
	their own game's icon here, found by their list picture (the "icon" model: positionDraftIcon).
]]
local GameIcons = {
	[@"wesker_portrait"] = @"wesker_game_re5",
	[@"kagan_portrait"] = @"kagan_game_bo7",
	[@"jacket_portrait"] = @"jacket_game_pd3"
}

local function GameIconOf( model )
	local icon = model and model:get()
	return icon and GameIcons[icon]
end

local function WrapGamesList()
	local list = CoD.CharacterSelection_FeaturedGamesList
	if not list or not CoD.CharacterSelection_FeaturedGamesIcon or list.shieldNew == list.new then
		return
	end
	local gameNew = list.new
	list.new = function ( menu, controller, ... )
		local self = gameNew( menu, controller, ... )
		local own = CoD.CharacterSelection_FeaturedGamesIcon.new( menu, controller, 0, 0, 0, 64, 0, 0, 0, 64 )
		own:mergeStateConditions( {
			{
				stateName = "Visible",
				condition = function ( menu, element, event )
					local model = element:getModel()
					return GameIconOf( model and Engine[@"getmodel"]( model, "icon" ) ) ~= nil
				end
			}
		} )
		own:linkToElementModel( own, "icon", true, function ( model )
			local image = GameIconOf( model )
			if image then
				own.GameIcon:setImage( RegisterImage( image ) )
			end
			menu:updateElementState( own, {
				name = "model_validation",
				menu = menu,
				controller = controller,
				modelValue = model:get(),
				modelName = "icon"
			} )
		end )
		own:linkToElementModel( self, nil, false, function ( model )
			own:setModel( model, controller )
		end )
		LUI.OverrideFunction_CallOriginalFirst( own, "setState", function ( element )
			if IsElementInState( element, "Visible" ) then
				ShowWidget( element )
			else
				HideWidget( element )
			end
		end )
		HideWidget( own )
		self:addElement( own )
		self.ShieldGame = own
		return self
	end
	list.shieldNew = list.new
	Log( "games icons wrapped" )
end

local function Install()
	WrapOutfitList()
	WrapGamesList()
	if ours and DataSources.MPOutfitCategories == ours then
		return
	end
	ours = DataSourceHelpers.ListSetup( "MPOutfitCategories", Categories, true, {
		getModel = function ( controller )
			local model = Engine[@"getmodelforcontroller"]( controller )
			model = model:create( "MPOutfitCategories" )
			if not model.selectedCategory then
				local selected = model:create( "selectedCategory" )
				selected:set( @"outfit" )
			end
			return model
		end
	} )
	DataSources.MPOutfitCategories = ours
	Log( "outfit categories installed" )
end

Install()

if not CoD.ShieldOutfitsRequire then
	CoD.ShieldOutfitsRequire = true
	local GameRequire = require
	require = function ( ... )
		local result = GameRequire( ... )
		Install()
		return result
	end
end
