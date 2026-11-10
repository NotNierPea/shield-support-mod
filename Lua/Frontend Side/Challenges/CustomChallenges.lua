--[[
		.\hksc.exe ".\Lua\CustomChallenges.Lua" -o "C:\Program Files (x86)\Call of Duty Black Ops 4\project-bo4\internals\T8ShieldSupport\Lua\Frontend\CustomChallenges.luac"
]]

---------------------------

CoD.ShieldInitLuaFile()

---------------------------

--[[
	Calling cards of our own: the support fastfile's gamedata/shield/calling_cards.csv (background id, image, name,
	description, mode, map, stat). shield-client (custom_calling_cards.cpp) adds them to the game's backgrounds, so they are
	real calling cards, and keeps them locked until their map's GSC sets their stat (Engine.IsEmblemBackgroundLocked).
	- the zombies challenges (Barracks): a fourth tile, Custom, after Dark Ops, opens a page of our zombies cards (the
	  game's card grid and profiler); confirm on an unlocked card makes it the player's calling card
	- the calling card picker's zombies cards have ours after the game's
	- an animated card is a widget named as its image, CoD[@"<image>"], as the game's (SetCallingCardForWidget)
]]
local CARD_TABLE = "gamedata/shield/calling_cards.csv"
local CONFIRM = Enum[@"luibutton"][@"lui_key_xba_pscross"]
local BACK = Enum[@"luibutton"][@"lui_key_xbb_pscircle"]
-- the widgets of our animated cards by their image's name (the table's image column)
local CARD_WIDGETS = {}

local function Log( text )
	Engine[@"printinfo"]( 0, "[shield] calling cards: " .. text .. "\n" )
end

local function Cell( row, column )
	return Engine[@"tablelookupgetcolumnvalueforrow"]( CARD_TABLE, row, column )
end

-- a card's picture: nil when it is no background (an older client, the support fastfile not there)
local function CardImage( id )
	local image = CoD.ChallengesUtility.GetBackgroundByID( id )
	if image == nil or image == "" or image == @"hash_0" then
		return nil
	end

	return image
end

-- the cards of a mode ("zm", nil: all) that are backgrounds; an animated one's widget is put where the menus look for it,
-- CoD[<the background's image>] (SetCallingCardForWidget), under the very value the backgrounds table gives
local function ReadCards( mode )
	local cards = {}
	local rows = tonumber( Engine[@"gettablerowcount"]( CARD_TABLE ) ) or 0

	for row = 0, rows - 1, 1 do
		local id = tonumber( Cell( row, 0 ) )

		if id ~= nil and ( mode == nil or Cell( row, 4 ) == mode ) then
			local image = CardImage( id )
			local widget = CARD_WIDGETS[Cell( row, 1 ) or ""]

			if image ~= nil and widget ~= nil then
				CoD[image] = widget
			end

			if image ~= nil then
				table.insert( cards, { id = id, image = image } )
			else
				Log( "card " .. id .. " is no background (shield-client without custom_calling_cards?)" )
			end
		end
	end

	return cards
end

-- a text of a card, localized: its localize entry shield/callingcard/<id>/<name | desc> (shield-client's). The game's
-- widgets localize the title again (LocalizeToUpperString), which only takes text the game localized ("localize string
-- not cached" for any other)
local function CardText( id, field )
	return Engine[@"hash_4F9F1239CFD921FE"]( Engine[@"converttoxhash"]( "shield/callingcard/" .. id .. "/" .. field ) )
end

-- a card as the game's challenge cards are (CoD.ChallengesUtility.GetChallengeTable), one tier, no XP
local function CardItem( controller, card )
	local locked = Engine[@"isemblembackgroundlocked"]( controller, card.id ) == true
	local done = locked and 0 or 1

	return {
		models = {
			title = CardText( card.id, "name" ),
			description = CardText( card.id, "desc" ),
			iconId = card.id,
			icon = card.image,
			maxTier = 0,
			currentTier = 0,
			tierStatus = "",
			previousVal = done,
			currentVal = done,
			prevStatPercent = done,
			statPercent = done,
			percentComplete = done,
			statFractionText = Engine[@"hash_4F9F1239CFD921FE"]( @"hash_631CF0F51CCA3A27", done, 1 ),
			xp = 0,
			isLocked = locked,
			isWZ = false
		},
		properties = {
			isMastery = false,
			isDarkOps = false,
			category = "custom",
			targetVal = 1,
			shieldCard = true
		}
	}
end

local function CardItems( controller, mode )
	local items = {}
	for _, card in ipairs( ReadCards( mode ) ) do
		table.insert( items, CardItem( controller, card ) )
	end
	return items
end

DataSources.ShieldCustomCallingCards = DataSourceHelpers.ListSetup( "ShieldCustomCallingCards", function ( controller )
	local items = CardItems( controller, "zm" )
	if #items > 0 then
		items[1].properties.selectIndex = true
	end
	return items
end, true )

-- the Custom tile's numbers, as the game's categories' (ChallengesZMCategoryStats.<category>)
local function CustomStatsModel( controller, items )
	local unlocked = 0
	for _, item in ipairs( items ) do
		if not item.models.isLocked then
			unlocked = unlocked + 1
		end
	end

	local model = Engine[@"createmodel"]( Engine[@"getmodelforcontroller"]( controller ), "ShieldCustomChallengeStats" )
	model:create( "percentComplete" ):set( #items > 0 and unlocked / #items or 0 )
	model:create( "categoryLocked" ):set( false )
	model:create( "categoryLockedText" ):set( "" )
	return model
end

---------------------------

-- zm_park's Giddy Park Main Quest: its background and the ferris wheel turning, on the card's 960x240 as the game's animated cards
local PARK_WHEEL_MS = 90
local PARK_WHEEL = {
	@"shield_cc_zm_park_quest_wheel_00", @"shield_cc_zm_park_quest_wheel_01", @"shield_cc_zm_park_quest_wheel_02",
	@"shield_cc_zm_park_quest_wheel_03", @"shield_cc_zm_park_quest_wheel_04", @"shield_cc_zm_park_quest_wheel_05",
	@"shield_cc_zm_park_quest_wheel_06", @"shield_cc_zm_park_quest_wheel_07", @"shield_cc_zm_park_quest_wheel_08",
	@"shield_cc_zm_park_quest_wheel_09", @"shield_cc_zm_park_quest_wheel_10", @"shield_cc_zm_park_quest_wheel_11"
}

CoD.ShieldCallingCardZmParkQuest = InheritFrom( LUI.UIElement )
CoD.ShieldCallingCardZmParkQuest.__defaultWidth = 960
CoD.ShieldCallingCardZmParkQuest.__defaultHeight = 240
CoD.ShieldCallingCardZmParkQuest.new = function ( menu, controller, left, right, leftOffset, rightOffset, top, bottom, topOffset, bottomOffset )
	local self = LUI.UIElement.new( left, right, leftOffset, rightOffset, top, bottom, topOffset, bottomOffset )
	self:setClass( CoD.ShieldCallingCardZmParkQuest )
	self.id = "ShieldCallingCardZmParkQuest"
	self.soundSet = "default"

	local Background = LUI.UIImage.new( 0, 0, 0, 960, 0, 0, 0, 240 )
	Background:setImage( RegisterImage( @"shield_cc_zm_park_quest_bg" ) )
	self:addElement( Background )
	self.Background = Background

	local frames = {}
	for index, name in ipairs( PARK_WHEEL ) do
		frames[index] = RegisterImage( name )
	end

	local Wheel = LUI.UIImage.new( 0, 0, 640, 900, 0, 0, -10, 250 )
	Wheel:setImage( frames[1] )
	self:addElement( Wheel )
	self.Wheel = Wheel

	local frame = 1
	local Timer = LUI.UITimer.newElementTimer( PARK_WHEEL_MS, false, function ()
		frame = frame % #frames + 1
		Wheel:setImage( frames[frame] )
	end )
	self:addElement( Timer )
	self.Timer = Timer

	LUI.OverrideFunction_CallOriginalSecond( self, "close", function ( element )
		element.Timer:close()
	end )

	return self
end

-- the game's name for a widget card is its image's: the table's image column (a hash)
CoD[@"shield_cc_zm_park_quest"] = CoD.ShieldCallingCardZmParkQuest
CARD_WIDGETS.shield_cc_zm_park_quest = CoD.ShieldCallingCardZmParkQuest

---------------------------

-- the Custom page: the game's card grid and profiler (CoD.ChallengesStickerbook's), without a master card
CoD.ShieldCustomStickerbook = InheritFrom( LUI.UIElement )
CoD.ShieldCustomStickerbook.__defaultWidth = 1725
CoD.ShieldCustomStickerbook.__defaultHeight = 780
CoD.ShieldCustomStickerbook.new = function ( menu, controller, left, right, leftOffset, rightOffset, top, bottom, topOffset, bottomOffset )
	local self = LUI.UIElement.new( left, right, leftOffset, rightOffset, top, bottom, topOffset, bottomOffset )
	self:setClass( CoD.ShieldCustomStickerbook )
	self.id = "ShieldCustomStickerbook"
	self.soundSet = "ChooseDecal"
	self.onlyChildrenFocusable = true
	self.anyChildUsesUpdateState = true

	local CardGrid = LUI.UIList.new( menu, controller, 20, 0, nil, true, false, false, false )
	CardGrid:setLeftRight( 0, 0, 15, 1135 )
	CardGrid:setTopBottom( 0, 0, 19, 583 )
	CardGrid:setWidgetType( CoD.Challenges_CallingCardWidget )
	CardGrid:setHorizontalCount( 3 )
	CardGrid:setVerticalCount( 4 )
	CardGrid:setSpacing( 20 )
	CardGrid:setAlignment( Enum[@"luialignment"][@"lui_alignment_left"] )
	CardGrid:setDataSource( "ShieldCustomCallingCards" )
	CardGrid:registerEventHandler( "list_item_gain_focus", function ( element, event )
		SetElementModelToFocusedElementModel( controller, self, element, "CallingCardProfiler" )
	end )
	CardGrid:registerEventHandler( "gain_focus", function ( element, event )
		local result = nil
		if element.gainFocus then
			result = element:gainFocus( event )
		elseif element.super.gainFocus then
			result = element.super:gainFocus( event )
		end
		CoD.Menu.UpdateButtonShownState( element, menu, controller, CONFIRM )
		return result
	end )
	-- an unlocked card becomes the calling card (the picker's way)
	menu:AddButtonCallbackFunction( CardGrid, controller, CONFIRM, "ui_confirm", function ( element, menu, controller, model )
		if not IsElementInState( element, "Locked" ) then
			CallingCards_SetPlayerBackground( menu, element, controller )
			PlaySoundSetSound( self, "action" )
			menu.shieldBackgroundSet = true
			return true
		end
	end, function ( element, menu, controller )
		if not IsElementInState( element, "Locked" ) then
			CoD.Menu.SetButtonLabel( menu, CONFIRM, @"menu/select", nil, "ui_confirm" )
			return true
		else
			return false
		end
	end, false )
	self:addElement( CardGrid )
	self.CardGrid = CardGrid

	local TitleBG = CoD.Challenges_FrameWidget_TitleBackground.new( menu, controller, 0, 0, 1177, 1710, 0, 0, 1, 769 )
	TitleBG.HeaderStripeBot:setAlpha( 0.5 )
	self:addElement( TitleBG )
	self.TitleBG = TitleBG

	local CallingCardProfiler = CoD.Challenges_CallingCardProfiler.new( menu, controller, 0, 0, 1181, 1706, 0, 0, 20, 750 )
	CallingCardProfiler:linkToElementModel( CardGrid, nil, false, function ( model )
		CallingCardProfiler:setModel( model, controller )
	end )
	self:addElement( CallingCardProfiler )
	self.CallingCardProfiler = CallingCardProfiler

	CardGrid.id = "CardGrid"
	CallingCardProfiler.id = "CallingCardProfiler"
	self.__defaultFocus = CardGrid
	LUI.OverrideFunction_CallOriginalSecond( self, "close", self.__onClose )

	return self
end

CoD.ShieldCustomStickerbook.__onClose = function ( self )
	self.CallingCardProfiler:close()
	self.CardGrid:close()
	self.TitleBG:close()
end

-- the page, as the game's Dark Ops one (ChallengesDarkOps)
-- the game's classes the page is made of: read with the challenges (the game's requires; two by their paths here)
local function PageReady()
	if not CoD.GenericMenuFrame then
		require( "ui/uieditor/widgets/backgroundframes/genericmenuframe" )
	end
	if not CoD.Challenges_CallingCardProfiler then
		require( "ui/uieditor/widgets/challenges/challenges_callingcardprofiler" )
	end

	for _, name in ipairs( { "GenericMenuFrame", "Challenges_CallingCardProfiler", "Challenges_CallingCardWidget", "Challenges_FrameWidget_TitleBackground" } ) do
		if not CoD[name] then
			Log( "the Custom page can't open: no CoD." .. name )
			return false
		end
	end

	return true
end

CoD.ShieldChallengesCustom = InheritFrom( CoD.Menu )
LUI.createMenu.ShieldChallengesCustom = function ( controller, userData )
	local self = CoD.Menu.NewForUIEditor( "ShieldChallengesCustom", controller )
	local menu = self
	self:setClass( CoD.ShieldChallengesCustom )
	self.soundSet = "ChooseDecal"
	self:setOwner( controller )
	self:setLeftRight( 0, 1, 0, 0 )
	self:setTopBottom( 0, 1, 0, 0 )
	self:playSound( "menu_open", controller )
	self.anyChildUsesUpdateState = true

	local Backing = LUI.UIImage.new( 0, 1, 0, 0, 0, 1, 0, 0 )
	Backing:setRGB( 0, 0, 0 )
	Backing:setAlpha( 0.9 )
	self:addElement( Backing )
	self.Backing = Backing

	local Stickers = CoD.ShieldCustomStickerbook.new( menu, controller, 0.5, 0.5, -861, 864, 0.5, 0.5, -391, 391 )
	self:addElement( Stickers )
	self.Stickers = Stickers

	local MenuFrame = CoD.GenericMenuFrame.new( menu, controller, 0, 1, 0, 0, 0, 1, 0, 0 )
	MenuFrame.CommonHeader.subtitle.StageTitle:setText( "CUSTOM" )
	MenuFrame:subscribeToGlobalModel( controller, "LobbyRoot", "lobbyTitle", function ( model )
		local title = model:get()
		if title ~= nil then
			MenuFrame.CommonHeader.subtitle.subtitle:setText( Engine[@"hash_4F9F1239CFD921FE"]( title ) )
		end
	end )
	self:addElement( MenuFrame )
	self.MenuFrame = MenuFrame

	-- the player's card at the top (the Dark Ops page's), when its class was read
	if CoD.CommonIdentityWidgetStreamlinedSafeAreaContainer then
		local Identity = CoD.CommonIdentityWidgetStreamlinedSafeAreaContainer.new( menu, controller, 0, 0, 0, 1920, 0, 0, 0, 1080 )
		Identity:registerEventHandler( "menu_loaded", function ( element, event )
			local result = nil
			if element.menuLoaded then
				result = element:menuLoaded( event )
			elseif element.super.menuLoaded then
				result = element.super:menuLoaded( event )
			end
			SizeToSafeArea( element, controller )
			if not result then
				result = element:dispatchEventToChildren( event )
			end
			return result
		end )
		self:addElement( Identity )
		self.Identity = Identity
	end

	menu:AddButtonCallbackFunction( self, controller, BACK, nil, function ( element, menu, controller, model )
		GoBack( self, controller )
		return true
	end, function ( element, menu, controller )
		CoD.Menu.SetButtonLabel( menu, BACK, @"menu/back", nil, nil )
		return true
	end, false )

	-- a calling card set here goes to the profile when leaving (CoD.CraftUtility.BlackMarketResultsOnClose's way)
	LUI.OverrideFunction_CallOriginalFirst( self, "close", function ( element )
		if element.shieldBackgroundSet then
			if not IsLive() then
				Engine[@"commitprofilechanges"]( controller )
			else
				CoD.CraftUtility.UploadPublicProfile( nil, controller )
			end
		end
	end )

	Stickers.id = "Stickers"
	MenuFrame:setModel( self.buttonModel, controller )
	if CoD.isPC then
		MenuFrame.id = "MenuFrame"
	end
	self:processEvent( {
		name = "menu_loaded",
		controller = controller
	} )
	self.__defaultFocus = Stickers
	if CoD.isPC and (IsKeyboard( controller ) or self.ignoreCursor) then
		self:restoreState( controller )
	end
	LUI.OverrideFunction_CallOriginalSecond( self, "close", self.__onClose )

	return self
end

CoD.ShieldChallengesCustom.__onClose = function ( self )
	self.Stickers:close()
	self.MenuFrame:close()
	if self.Identity then
		self.Identity:close()
	end
end

---------------------------

-- the zombies challenges' summary (Toolkit, Expert, Dark Ops tiles, 363 wide 44 apart, a 1175 wide list): Custom after
-- Dark Ops, the same size and gap, the list made wider for it (a tile draws 364 wide in zombies whatever its slot: its
-- backing is -0.41 to 1.41 of the 200 wide inside)
local TILE_WIDTH = 363
local TILE_SPACING = 44

local function AddCustomTile( self, menu, controller )
	if self.Custom or not self.DarkOps or not CoD.ChallengesSummaryCategory then
		return
	end

	local items = CardItems( controller, "zm" )
	if #items == 0 then
		return
	end

	local row = 4 * TILE_WIDTH + 3 * TILE_SPACING
	local x = 3 * ( TILE_WIDTH + TILE_SPACING )
	self:setLeftRight( 0.5, 0.5, -row / 2, row / 2 )

	local Custom = CoD.ChallengesSummaryCategory.new( menu, controller, 0, 0, x, x + TILE_WIDTH, 0.5, 0.5, -112.5, 112.5 )
	Custom.SummaryCategory.Icon:setImage( RegisterImage( @"shield_challenges_custom" ) )
	Custom.SummaryCategory.Name:setText( "CUSTOM" )
	Custom:setModel( CustomStatsModel( controller, items ), controller )
	Custom:registerEventHandler( "gain_focus", function ( element, event )
		local result = nil
		if element.gainFocus then
			result = element:gainFocus( event )
		elseif element.super.gainFocus then
			result = element.super:gainFocus( event )
		end
		CoD.Menu.UpdateButtonShownState( element, menu, controller, CONFIRM )
		return result
	end )
	menu:AddButtonCallbackFunction( Custom, controller, CONFIRM, "ui_confirm", function ( element, menu, controller, model )
		if PageReady() then
			PlaySoundAlias( "uin_toggle_generic" )
			OpenOverlay( self, "ShieldChallengesCustom", controller )
		end
		return true
	end, function ( element, menu, controller )
		CoD.Menu.SetButtonLabel( menu, CONFIRM, @"menu/select", nil, "ui_confirm" )
		return true
	end, false )
	self:addElement( Custom )
	self.Custom = Custom
	Custom.id = "Custom"
	self:setLayoutCached( false )

	LUI.OverrideFunction_CallOriginalSecond( self, "close", function ( element )
		element.Custom:close()
	end )
end

local function HookSummary()
	local class = CoD.ChallengesSummaryCategoryList_ZM
	if not class or class.shieldCustom then
		return
	end

	class.shieldCustom = true
	local GameNew = class.new
	class.new = function ( menu, controller, ... )
		local self = GameNew( menu, controller, ... )
		AddCustomTile( self, menu, controller )
		return self
	end

	Log( "zombies challenges hooked" )
end

-- the calling card picker's zombies cards (DataSources.CallingCardsSorted, category "zm"): ours after the game's
local function HookPicker()
	local utility = CoD.ChallengesUtility
	if not utility or utility.shieldCustomCards or not utility.GetChallengeCardsForSessionMode then
		return
	end

	utility.shieldCustomCards = true
	local GameCards = utility.GetChallengeCardsForSessionMode
	utility.GetChallengeCardsForSessionMode = function ( controller, mode, modeName, sorted )
		local list = GameCards( controller, mode, modeName, sorted )

		if mode == Enum[@"emodes"][@"mode_zombies"] and list then
			for _, item in ipairs( CardItems( controller, "zm" ) ) do
				table.insert( list, item )
			end
		end

		return list
	end
end

-- the widgets in place for an equipped card drawn before any of our lists
local widgetsRegistered = false
local function RegisterWidgets()
	if not widgetsRegistered and CoD.ChallengesUtility and CoD.ChallengesUtility.GetBackgroundByID then
		widgetsRegistered = true
		ReadCards( nil )
	end
end

local function Install()
	HookSummary()
	HookPicker()
	RegisterWidgets()
end

if CoD.isFrontend then
	Install()

	-- the challenges' files are read when a menu needs them (the summary list by its parent widget): hooked as soon as
	-- they are
	if not CoD.ShieldCustomChallengesRequire then
		CoD.ShieldCustomChallengesRequire = true
		local GameRequire = require
		require = function ( ... )
			local result = GameRequire( ... )
			Install()
			return result
		end
	end
end
