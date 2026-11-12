--[[
		.\hksc.exe ".\Lua\Frontend Side\Directors\ZombiesExtras.lua" -o "C:\Program Files (x86)\Call of Duty Black Ops 4\project-bo4\internals\T8ShieldSupport\Lua\Frontend\ZombiesExtras.luac"
]]

---------------------------

CoD.ShieldInitLuaFile()

---------------------------

--[[
	Zombies lobby: the Characters button becomes Extras, as in multiplayer and Blackout, and opens a choice of the
	characters (the game's ZMPersonalizeCharacterMain) or the sprays and gestures (multiplayer's MPSpecialistHUBBindWheel).

	The lobby's buttons are a list built by ListHelper_Prepare: the game's DirectorPregameButtons (directorutility.lua),
	or the DirectorPregameButtonsCustom of PreGameButtons.lua, ours or the enhancement mod's (whichever defined it last).
	The button is changed there, in whichever list it is.

	The sprays and gestures menus ask Engine.CurrentSessionMode() for everything, the specialist preview and its background
	too, which only work in multiplayer. While they are open it says multiplayer, and the two Engine functions that read and
	write the 9 slots (Engine[0x688987BA1B9D616B], Engine[0x36994F951ED2C61E]) are given zombies for multiplayer: shield-client
	(sprays_gestures.cpp) keeps zombies' own slots, which zombies loadouts have no room for, and the HUD's wheel shows them
	(SprayGestureWheel.lua).
]]

local LISTS = { DirectorPregameButtons = true, DirectorPregameButtonsCustom = true }
local CURRENT_SESSION_MODE = @"hash_63EAC408F958FF05"
local GET_SLOTS = @"hash_688987BA1B9D616B"
local SET_SLOT = @"hash_36994F951ED2C61E"

local function Log( text )
	Engine[@"printinfo"]( 0, "[shield] zombies extras: " .. text .. "\n" )
end

local function Localize( text )
	return Engine[@"hash_4F9F1239CFD921FE"]( text )
end

local function SetEngine( key, value )
	local ok, err = pcall( rawset, Engine, key, value )
	if not ok then
		Log( "an engine function can't be set: " .. tostring( err ) )
	end
end

-- the menus as in multiplayer, on zombies' slots; the game's functions again with false
local function EditZombiesSlots( on )
	if not CoD.ShieldGameEngine then
		CoD.ShieldGameEngine = {
			currentSessionMode = Engine[CURRENT_SESSION_MODE],
			getSlots = Engine[GET_SLOTS],
			setSlot = Engine[SET_SLOT]
		}
	end

	local game = CoD.ShieldGameEngine
	CoD.ShieldEditingZombiesSlots = on
	if not on then
		SetEngine( CURRENT_SESSION_MODE, game.currentSessionMode )
		SetEngine( GET_SLOTS, game.getSlots )
		SetEngine( SET_SLOT, game.setSlot )
		return
	end

	local modes = Enum[@"emodes"]
	local function Zombies( mode )
		return mode == modes[@"mode_multiplayer"] and modes[@"mode_zombies"] or mode
	end

	SetEngine( CURRENT_SESSION_MODE, function ()
		return modes[@"mode_multiplayer"]
	end )
	SetEngine( GET_SLOTS, function ( controller, mode )
		return game.getSlots( controller, Zombies( mode ) )
	end )
	SetEngine( SET_SLOT, function ( controller, mode, slot, item )
		return game.setSlot( controller, Zombies( mode ), slot, item )
	end )
end

--[[
	The gestures tab's preview (MPSpecialistHUBGesturesInternal): the tab opens the client menu MPSpecialistHUBGestures with
	the multiplayer specialist as its state, and frontend.csc (function_9602c423) shows that index as a character of its
	own currentsessionmode(), zombies in this lobby: some other zombies character, not loaded yet. The state is the zombies
	character the lobby has for the player instead, so it is loaded already.
]]
-- the zombies lobby's character of the local player, as GetSelectedCharacterIndex reads Blackout's (by its lobby client)
local function LobbyCharacter( controller )
	local module = Enum[@"lobbymodule"][@"lobby_module_client"]
	local session = Engine[@"lobbygetcontrollinglobbysession"]( module )
	local client = Engine[@"hash_7EFBAAD12776201D"]( module, session, Engine[@"getxuid64"]( controller ) )
	return Engine[@"hash_140145EEB2E913D2"]( controller, client ), client
end

local function SendGesturePreview( menu, controller )
	local ok, character, client = pcall( LobbyCharacter, controller )
	Log( "gesture preview: lobby character " .. tostring( character ) .. " (client " .. tostring( client ) .. ")" )
	if not ok or type( character ) ~= "number" or character < 0 then
		local equipped
		ok, equipped = pcall( Engine[@"getequippedhero"], controller, Enum[@"emodes"][@"mode_zombies"] )
		Log( "gesture preview: equipped zombies character " .. tostring( equipped ) )
		character = ok and type( equipped ) == "number" and equipped >= 0 and equipped or nil
	end

	local GameStateNotify = SendCustomClientScriptMenuExpressionStateChangeNotify
	SendCustomClientScriptMenuExpressionStateChangeNotify = function ( c, name, open, state, ... )
		Log( "gesture preview: zombies character " .. tostring( character or state ) .. " (game state " .. tostring( state ) .. ")" )
		return GameStateNotify( c, name, open, character or state, ... )
	end
	local sent, err = pcall( CoD.PlayerRoleUtility.ShieldGameSendClientNotifyGestureMenu, menu, controller )
	SendCustomClientScriptMenuExpressionStateChangeNotify = GameStateNotify

	if not sent then
		Log( "gesture menu notify failed: " .. tostring( err ) )
	end
end

local function HookGesturePreview()
	local utility = CoD.PlayerRoleUtility
	if not utility or not utility.SendClientNotifyGestureMenu or utility.ShieldGameSendClientNotifyGestureMenu then
		return
	end

	utility.ShieldGameSendClientNotifyGestureMenu = utility.SendClientNotifyGestureMenu
	utility.SendClientNotifyGestureMenu = function ( menu, controller, ... )
		if CoD.ShieldEditingZombiesSlots and CoD.ShieldSendGesturePreview then
			return CoD.ShieldSendGesturePreview( menu, controller )
		end
		return utility.ShieldGameSendClientNotifyGestureMenu( menu, controller, ... )
	end
end

-- on CoD, so a reload of the mods updates the hook's function
CoD.ShieldSendGesturePreview = SendGesturePreview

CoD.ShieldOpenZombiesExtras = function ( list, element, controller, param, menu )
	HookGesturePreview()
	OpenOverlay( list, "ShieldZombiesExtras", controller, param )
end

local function IsZombiesCharacters( item )
	local properties = item.properties
	return properties and properties.action == CoD.DirectorUtility.OpenDirectorChangeCharacterMenu and properties.actionParam
		and properties.actionParam._sessionMode == Enum[@"emodes"][@"mode_zombies"]
end

local function ZombiesExtrasButtons( buttons )
	return function ( controller, list )
		local items = buttons( controller, list ) or {}
		for _, item in ipairs( items ) do
			if IsZombiesCharacters( item ) then
				item.models.name = @"menu/depot"
				item.models.subtitle = @"menu/depot"
				item.properties.action = CoD.ShieldOpenZombiesExtras
			end
		end
		return items
	end
end

-- one wrapper, kept on CoD so a reload of the mods does not wrap it again
if not CoD.ShieldZombiesExtrasPrepare then
	CoD.ShieldZombiesExtrasPrepare = function ( list, controller, name, buttons, ... )
		if LISTS[name] and buttons then
			buttons = ZombiesExtrasButtons( buttons )
		end
		return CoD.ShieldGameListPrepare( list, controller, name, buttons, ... )
	end
end

-- datasources.lua defines ListHelper_Prepare and may be read after this file: wrapped again whenever it is replaced
local function HookPrepare()
	if ListHelper_Prepare and ListHelper_Prepare ~= CoD.ShieldZombiesExtrasPrepare then
		CoD.ShieldGameListPrepare = ListHelper_Prepare
		ListHelper_Prepare = CoD.ShieldZombiesExtrasPrepare
	end
end

HookPrepare()

if not CoD.ShieldZombiesExtrasRequire then
	CoD.ShieldZombiesExtrasRequire = true
	local GameRequire = require
	require = function ( ... )
		local result = GameRequire( ... )
		HookPrepare()
		return result
	end
end

---------------------------

--[[
	The two choices are cards (the support mod's BrowserUI look, as the lobby browser's card and Freerun's rows) in a list of
	two, which gives them hover, clicks and pad navigation: a picture over each, its name, what it is for, and a line of
	what is set now. Characters: the zombies character of the lobby (or the forced one) between the ones before and after
	it. Sprays & Gestures: zombies' 9 slots as tiles, the quick spray first. Both filled again when the menu is back on top.
]]
local CARD_WIDTH = 540
local CARD_HEIGHT = 600
local CARD_GAP = 40
local PICTURE_HEIGHT = 380
local ACCENT = { r = 1, g = 0.38, b = 0.28 }
local CARD_SOURCE = "ShieldZombiesExtrasCards"

local CARDS = {
	characters = {
		caption = "PERSONALIZE",
		title = "CHARACTERS",
		text = "Choose who you play as, their outfits and war paints."
	},
	sprays = {
		caption = "LOADOUT",
		title = "SPRAYS & GESTURES",
		text = "Fill the wheel with sprays and gestures for a match."
	}
}

local ZOMBIES = Enum[@"emodes"][@"mode_zombies"]

-- an image a table gave as userdata is registered already
local function Picture( image, name )
	local ok = pcall( function ()
		image:setImage( type( name ) == "userdata" and name or RegisterImage( name ) )
	end )
	return ok
end

-- the lobby map's cast (character indices as keys), nil without a map that lists one
local function MapCast()
	local map = Engine[@"lobbygetmap"]()
	if not map or map == "" then
		return nil
	end
	local entry = LuaUtils.GetMapsTable()[Engine[@"converttoxhash"]( map )]
	local cast = {}
	for _, character in ipairs( entry and entry.zmCharacters or {} ) do
		if character.characterIndex then
			cast[character.characterIndex] = true
		end
	end
	return next( cast ) and cast or nil
end

--[[
	The zombies character shown: the forced one (ZMForcedCharacter.lua), else the lobby's pick when it is in the map's cast
	(the ready-up screen's game lobby). Outside a game lobby the party still answers a character (Scarlett, Bruno): none
	then, the map's cast plays.
	Also the map's cast, for the picture when there is no character.
]]
local function ShownCharacter( controller )
	local forced = Engine[@"getdvarint"]( "shield_zm_character" ) or 0
	if forced > 0 then
		return forced, "forced"
	end
	local ok, cast = pcall( MapCast )
	cast = ok and cast or nil
	if not cast then
		return nil, "no map"
	end
	-- (only a game lobby's pick is the one played: the main menu's party answers one too, a cast character)
	local inGame
	ok, inGame = pcall( IsGameLobbyActive )
	if not ok or not inGame then
		return nil, "cast", cast
	end
	local character
	ok, character = pcall( LobbyCharacter, controller )
	if ok and type( character ) == "number" and cast[character] then
		return character, "lobby", cast
	end
	return nil, "cast", cast
end

local function FillCharacters( card, controller )
	local heroes = {}
	for _, hero in ipairs( Engine[@"getherolist"]( ZOMBIES ) or {} ) do
		if hero.positionDraftIcon then
			table.insert( heroes, hero )
		end
	end
	if #heroes == 0 then
		card.Footer:setText( "" )
		return
	end
	local index, why, cast = ShownCharacter( controller )
	local at = nil
	for i, hero in ipairs( heroes ) do
		if hero.bodyIndex == index then
			at = i
		end
	end

	-- the ones before and after it, behind it and dimmer
	local function Portrait( hero, left, right, top, alpha, shade )
		local image = LUI.UIImage.new( 0, 0, left, right, 0, 0, top, top + right - left )
		if not Picture( image, hero.positionDraftIcon ) then
			image:close()
			return
		end
		image:setRGB( shade, shade, shade )
		image:setAlpha( alpha )
		card:AddPicturePart( image )
	end

	-- no character yet: a line of three, the map's cast (the first characters without a map)
	if not at then
		local shown = {}
		for _, hero in ipairs( heroes ) do
			if #shown < 3 and ( not cast or cast[hero.bodyIndex] ) then
				table.insert( shown, hero )
			end
		end
		local size, gap = 130, 10
		local left = ( CARD_WIDTH - ( #shown * size + ( #shown - 1 ) * gap ) ) / 2
		for i, hero in ipairs( shown ) do
			local x = left + ( i - 1 ) * ( size + gap )
			Portrait( hero, x, x + size, PICTURE_HEIGHT - size - 70, 0.8, 0.8 )
		end
		card.Footer:setText( why == "cast" and "THE MAP'S CAST" or "NO MAP PICKED YET" )
		return
	end

	if #heroes > 1 then
		local size = 160
		Portrait( heroes[( at - 2 ) % #heroes + 1], 40, 40 + size, PICTURE_HEIGHT - size - 50, 0.45, 0.55 )
		Portrait( heroes[at % #heroes + 1], CARD_WIDTH - 40 - size, CARD_WIDTH - 40, PICTURE_HEIGHT - size - 50, 0.45, 0.55 )
	end
	local size = 230
	Portrait( heroes[at], ( CARD_WIDTH - size ) / 2, ( CARD_WIDTH + size ) / 2, PICTURE_HEIGHT - size - 50, 1, 1 )

	local name = Localize( heroes[at].displayName ) or ""
	card.Footer:setText( ( why == "forced" and "FORCED: " or "PLAYING AS " ) .. string.upper( name ) )
end

local function FillSprays( card, controller )
	local getSlots = CoD.ShieldGameEngine and CoD.ShieldGameEngine.getSlots or Engine[GET_SLOTS]
	local ok, slots = pcall( getSlots, controller, ZOMBIES )
	slots = ok and slots or {}
	local items = Engine[@"hash_2B2E4CCC119597B0"]
	local all = items and items() or {}

	-- 3 by 3 tiles, the quick spray first (marked)
	local tile, gap = 104, 10
	local left = ( CARD_WIDTH - ( 3 * tile + 2 * gap ) ) / 2
	local top = ( PICTURE_HEIGHT - ( 3 * tile + 2 * gap ) ) / 2 + 6
	local set, images = 0, {}
	for slot = 1, 9 do
		local x = left + ( ( slot - 1 ) % 3 ) * ( tile + gap )
		local y = top + math.floor( ( slot - 1 ) / 3 ) * ( tile + gap )
		local back = LUI.UIImage.new( 0, 0, x, x + tile, 0, 0, y, y + tile )
		back:setRGB( 1, 1, 1 )
		back:setAlpha( 0.05 )
		card:AddPicturePart( back )

		local info = slots[slot] and slots[slot] > 0 and all[slots[slot]]
		local name = info and info[@"hash_5BFF4CC56C2092F0"]
		if name then
			local image = LUI.UIImage.new( 0, 0, x + 6, x + tile - 6, 0, 0, y + 6, y + tile - 6 )
			if Picture( image, name ) then
				card:AddPicturePart( image )
				table.insert( images, name )
				set = set + 1
			else
				image:close()
			end
		end

		if slot == 1 then
			local mark = LUI.UIImage.new( 0, 0, x, x + tile, 0, 0, y + tile - 3, y + tile )
			mark:setRGB( ACCENT.r, ACCENT.g, ACCENT.b )
			card:AddPicturePart( mark )
		end
	end
	if #images > 0 and CoD.BaseUtility.ForceStreamHelper then
		pcall( function ()
			CoD.ShieldExtrasStreamedImages = CoD.BaseUtility.ForceStreamHelper( CoD.ShieldExtrasStreamedImages or {}, images )
		end )
	end
	card.Footer:setText( set == 0 and "NOTHING EQUIPPED YET" or ( set .. " OF 9 SLOTS SET" ) )
end

local CardFocusParts = {
	{ "Tint", function ( element, focus ) element:setAlpha( focus and 0.08 or 0 ) end },
	{ "Dim", function ( element, focus ) element:setAlpha( focus and 0 or 0.4 ) end },
	{ "FocusFrame", function ( element, focus ) element:setAlpha( focus and 1 or 0 ) end },
	{ "Accent", function ( element, focus ) element:setTopBottom( 0, 0, 0, focus and 7 or 4 ) end },
	{ "Arrow", function ( element, focus ) element:setAlpha( focus and 1 or 0.25 ) end }
}

local function CardClip( focus, duration )
	return function ( self, event )
		return CoD.Shield.BrowserUI.FocusClip( CardFocusParts, focus, duration )( self, event )
	end
end

CoD.ShieldZombiesExtrasCard = InheritFrom( LUI.UIElement )
CoD.ShieldZombiesExtrasCard.__defaultWidth = CARD_WIDTH
CoD.ShieldZombiesExtrasCard.__defaultHeight = CARD_HEIGHT
CoD.ShieldZombiesExtrasCard.new = function ( menu, controller, ... )
	local UI = CoD.Shield.BrowserUI
	local self = LUI.UIElement.new( ... )
	self:setClass( CoD.ShieldZombiesExtrasCard )
	self.id = "ShieldZombiesExtrasCard"
	self.soundSet = "default"
	menu:addElementToPendingUpdateStateList( self )

	self.Parts = {}
	self.PictureParts = {}
	local function Add( element )
		self:addElement( element )
		table.insert( self.Parts, element )
		return element
	end

	local Back = Add( LUI.UIImage.new( 0, 1, 0, 0, 0, 1, 0, 0 ) )
	Back:setRGB( 0.05, 0.05, 0.06 )
	Back:setAlpha( 0.9 )

	-- the picture, cut to its box, darker at the bottom where the words begin
	local PictureClip = Add( LUI.UIElement.new( 0, 0, 0, CARD_WIDTH, 0, 0, 0, PICTURE_HEIGHT ) )
	PictureClip:setUseStencil( true )
	local PictureBack = LUI.UIImage.new( 0, 1, 0, 0, 0, 1, 0, 0 )
	PictureBack:setRGB( 0.09, 0.08, 0.08 )
	PictureClip:addElement( PictureBack )
	local Glow = LUI.UIImage.new( 0, 1, 0, 0, 0, 1, PICTURE_HEIGHT * 0.45, 0 )
	Glow:setRGB( ACCENT.r, ACCENT.g, ACCENT.b )
	Glow:setAlpha( 0.06 )
	PictureClip:addElement( Glow )
	local Pictures = LUI.UIElement.new( 0, 1, 0, 0, 0, 1, 0, 0 )
	PictureClip:addElement( Pictures )
	UI.AddBottomFade( PictureClip, PICTURE_HEIGHT, 90 )
	self.Pictures = Pictures

	local Dim = Add( LUI.UIImage.new( 0, 0, 0, CARD_WIDTH, 0, 0, 0, PICTURE_HEIGHT ) )
	Dim:setRGB( 0, 0, 0 )
	Dim:setAlpha( 0.4 )
	self.Dim = Dim

	local Tint = Add( LUI.UIImage.new( 0, 1, 0, 0, 0, 1, 0, 0 ) )
	Tint:setRGB( ACCENT.r, ACCENT.g, ACCENT.b )
	Tint:setAlpha( 0 )
	self.Tint = Tint

	local Accent = Add( LUI.UIImage.new( 0, 1, 0, 0, 0, 0, 0, 4 ) )
	Accent:setRGB( ACCENT.r, ACCENT.g, ACCENT.b )
	self.Accent = Accent

	local Caption = Add( UI.NewCaption( 28, CARD_WIDTH - 28, PICTURE_HEIGHT + 22, "" ) )
	Caption:setRGB( ACCENT.r, ACCENT.g, ACCENT.b )

	local Title = Add( UI.NewText( 28, CARD_WIDTH - 70, PICTURE_HEIGHT + 42, 38, "notosans_bold" ) )
	Title:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )

	local Arrow = Add( UI.NewText( CARD_WIDTH - 66, CARD_WIDTH - 28, PICTURE_HEIGHT + 42, 38, "notosans_bold", Enum[@"luialignment"][@"lui_alignment_right"] ) )
	Arrow:setRGB( ACCENT.r, ACCENT.g, ACCENT.b )
	Arrow:setAlpha( 0.25 )
	Arrow:setText( ">" )
	self.Arrow = Arrow

	local Text = Add( UI.NewText( 28, CARD_WIDTH - 28, PICTURE_HEIGHT + 92, 18, "ttmussels_regular" ) )
	Text:setRGB( 0.62, 0.62, 0.62 )

	Add( UI.NewBox( 28, CARD_WIDTH - 28, CARD_HEIGHT - 62, CARD_HEIGHT - 61, 1, 1, 1, 0.1 ) )
	local Dot = Add( LUI.UIImage.new( 0, 0, 28, 36, 0, 0, CARD_HEIGHT - 38, CARD_HEIGHT - 30 ) )
	Dot:setRGB( ACCENT.r, ACCENT.g, ACCENT.b )
	local Footer = Add( UI.NewText( 46, CARD_WIDTH - 28, CARD_HEIGHT - 44, 18, "notosans_bold" ) )
	Footer:setRGB( 0.85, 0.85, 0.85 )
	Footer:setLetterSpacing( 1 )
	self.Footer = Footer

	local FocusFrame = Add( LUI.UIImage.new( 0, 1, -4, 4, 0, 1, -4, 4 ) )
	FocusFrame:setRGB( ACCENT.r, ACCENT.g, ACCENT.b )
	FocusFrame:setAlpha( 0 )
	FocusFrame:setImage( RegisterImage( @"uie_ui_menu_store_focus_frame" ) )
	FocusFrame:setMaterial( LUI.UIImage.GetCachedMaterial( @"uie_nineslice_add" ) )
	FocusFrame:setShaderVector( 0, 0, 0, 0, 0 )
	FocusFrame:setupNineSliceShader( 10, 10 )
	self.FocusFrame = FocusFrame

	self.AddPicturePart = function ( card, element )
		card.Pictures:addElement( element )
		table.insert( card.PictureParts, element )
	end

	-- the picture and the line of what is set, again whenever asked (the menu back on top)
	self.Fill = function ( card )
		for _, element in ipairs( card.PictureParts ) do
			element:close()
		end
		card.PictureParts = {}
		local fill = card.Kind == "characters" and FillCharacters or card.Kind == "sprays" and FillSprays
		if fill then
			local ok, err = pcall( fill, card, controller )
			if not ok then
				Log( "card " .. tostring( card.Kind ) .. " not filled: " .. tostring( err ) )
			end
		end
	end

	Title:linkToElementModel( self, "kind", true, function ( model )
		local kind = model:get()
		local info = kind and CARDS[kind]
		if not info then
			return
		end
		self.Kind = kind
		Caption:setText( info.caption )
		Title:setText( info.title )
		Text:setText( info.text )
		self:Fill()
	end )

	menu.ShieldExtrasCards = menu.ShieldExtrasCards or {}
	table.insert( menu.ShieldExtrasCards, self )

	LUI.OverrideFunction_CallOriginalSecond( self, "close", self.__onClose )
	return self
end

CoD.ShieldZombiesExtrasCard.__resetProperties = function ( self )
	for _, part in ipairs( CardFocusParts ) do
		local element = self[part[1]]
		element:completeAnimation()
		part[2]( element, false )
	end
end

CoD.ShieldZombiesExtrasCard.__clipsPerState = {
	DefaultState = {
		DefaultClip = CardClip( false ),
		Focus = CardClip( true ),
		GainFocus = CardClip( true, 120 ),
		LoseFocus = CardClip( false, 120 )
	}
}

CoD.ShieldZombiesExtrasCard.__onClose = function ( self )
	for _, element in ipairs( self.PictureParts ) do
		element:close()
	end
	for _, element in ipairs( self.Parts ) do
		element:close()
	end
end

local function CardSource()
	if not DataSources[CARD_SOURCE] then
		DataSources[CARD_SOURCE] = DataSourceHelpers.ListSetup( CARD_SOURCE, function ( controller )
			return {
				{ models = { kind = "characters" }, properties = { selectIndex = true } },
				{ models = { kind = "sprays" }, properties = {} }
			}
		end, true )
	end
	return CARD_SOURCE
end

CoD.ShieldZombiesExtras = InheritFrom( CoD.Menu )
LUI.createMenu.ShieldZombiesExtras = function ( controller, param )
	local self = CoD.Menu.NewForUIEditor( "ShieldZombiesExtras", controller )
	local menu = self

	self:setClass( CoD.ShieldZombiesExtras )
	self.soundSet = "default"
	self:setOwner( controller )
	self:setLeftRight( 0, 1, 0, 0 )
	self:setTopBottom( 0, 1, 0, 0 )
	self:playSound( "menu_open", controller )
	self.anyChildUsesUpdateState = true

	local Background = CoD.StartMenuOptionsBackground.new( menu, controller, 0, 1, 0, 0, 0, 1, 0, 0 )
	self:addElement( Background )
	self.Background = Background

	local UI = CoD.Shield.BrowserUI
	local half = CARD_WIDTH + CARD_GAP / 2
	local top = -CARD_HEIGHT / 2 + 30

	-- over the cards: the mode, the menu's name
	local Mode = UI.NewCaption( 0, 600, 0, "ZOMBIES" )
	Mode:setLeftRight( 0.5, 0.5, -half, -half + 600 )
	Mode:setTopBottom( 0.5, 0.5, top - 74, top - 59 )
	Mode:setRGB( ACCENT.r, ACCENT.g, ACCENT.b )
	self:addElement( Mode )
	self.Mode = Mode

	local Title = UI.NewText( 0, 600, 0, 40, "notosans_bold" )
	Title:setLeftRight( 0.5, 0.5, -half, -half + 600 )
	Title:setTopBottom( 0.5, 0.5, top - 56, top - 16 )
	Title:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )
	Title:setText( "EXTRAS" )
	self:addElement( Title )
	self.Title = Title

	-- the zombies characters, as the button did; multiplayer's sprays and gestures menu, on zombies' own slots until this
	-- menu is back on top
	local actions = {
		characters = function ()
			CoD.DirectorUtility.OpenDirectorChangeCharacterMenu( self, nil, controller, param, self )
		end,
		sprays = function ()
			local mode = Enum[@"emodes"][@"mode_multiplayer"]
			EditZombiesSlots( true )
			CoD.DirectorUtility.OpenDirectorPersonalizationMenu( self, nil, controller, {
				_sessionMode = mode,
				_storageLoadoutBuffer = CoD.BreadcrumbUtility.GetStorageLoadoutBufferForPlayer( controller, mode ),
				_allowsQuickSelect = true
			}, self )
		end
	}

	local Cards = LUI.UIList.new( menu, controller, CARD_GAP, 0, nil, false, false, false, false )
	Cards:setLeftRight( 0.5, 0.5, -half, half )
	Cards:setTopBottom( 0.5, 0.5, top, top + CARD_HEIGHT )
	Cards:setWidgetType( CoD.ShieldZombiesExtrasCard )
	Cards:setHorizontalCount( 2 )
	Cards:setSpacing( CARD_GAP )
	Cards:setDataSource( CardSource() )
	Cards:registerEventHandler( "gain_focus", function ( element, event )
		local result = nil
		if element.gainFocus then
			result = element:gainFocus( event )
		elseif element.super.gainFocus then
			result = element.super:gainFocus( event )
		end
		CoD.Menu.UpdateButtonShownState( element, menu, controller, Enum[@"luibutton"][@"lui_key_xba_pscross"] )
		return result
	end )
	menu:AddButtonCallbackFunction( Cards, controller, Enum[@"luibutton"][@"lui_key_xba_pscross"], "ui_confirm", function ( element, menu, controller, model )
		local action = element.Kind and actions[element.Kind]
		if action then
			PlaySoundAlias( "uin_paint_image_flip_toggle" )
			action()
		end
		return true
	end, function ( element, menu, controller )
		if IsGamepad( controller ) then
			CoD.Menu.SetButtonLabel( menu, Enum[@"luibutton"][@"lui_key_xba_pscross"], @"menu/select", nil, "ui_confirm" )
			return true
		end
		CoD.Menu.SetButtonLabel( menu, Enum[@"luibutton"][@"lui_key_xba_pscross"], @"hash_0", nil, "ui_confirm" )
		return false
	end, false )
	self:addElement( Cards )
	self.Cards = Cards
	Cards.id = "Cards"
	self.__defaultFocus = Cards

	-- back on top: the game's slots again, the cards show what was picked
	self:appendEventHandler( "occlusion_change", function ( element, event )
		if not event.occluded then
			EditZombiesSlots( false )
			for _, card in ipairs( self.ShieldExtrasCards or {} ) do
				pcall( card.Fill, card )
			end
		end
	end )

	local FooterContainerFrontendRight = CoD.FooterContainer_Frontend_Right.new( menu, controller, 0.5, 0.5, -960, 960, 1, 1, -48, 0 )
	self:addElement( FooterContainerFrontendRight )
	self.FooterContainerFrontendRight = FooterContainerFrontendRight

	menu:AddButtonCallbackFunction( self, controller, Enum[@"hash_3DD78803F918E9D"][@"hash_1805EFA15E9E7E5A"], nil, function ( element, menu, controller, model )
		GoBack( self, controller )
		return true
	end, function ( element, menu, controller )
		CoD.Menu.SetButtonLabel( menu, Enum[@"hash_3DD78803F918E9D"][@"hash_1805EFA15E9E7E5A"], @"hash_6A4032FB2AAB69F2", nil, nil )
		return true
	end, false )

	FooterContainerFrontendRight:setModel( self.buttonModel, controller )
	if CoD.isPC then
		FooterContainerFrontendRight.id = "FooterContainerFrontendRight"
	end

	self:processEvent( {
		name = "menu_loaded",
		controller = controller
	} )

	LUI.OverrideFunction_CallOriginalSecond( self, "close", self.__onClose )

	return self
end

CoD.ShieldZombiesExtras.__onClose = function ( self )
	EditZombiesSlots( false )
	self.Background:close()
	self.FooterContainerFrontendRight:close()
	self.Mode:close()
	self.Title:close()
	self.Cards:close()
	self.ShieldExtrasCards = nil
end
