--[[
		.\hksc.exe ".\Lua\In-Game Side\Podium\PodiumHud.lua" -o "C:\Program Files (x86)\Call of Duty Black Ops 4\project-bo4\internals\T8ShieldSupport\Lua\Game\PodiumHud.luac"
]]

---------------------------

if CoD.isFrontend then
	return
end

CoD.ShieldInitLuaFile()

---------------------------

--[[
	The end of match podium's HUD (Podium.gsc / Podium.csc). When the podium shows, the server sends
	`luinotifyevent(#"shield_podium", 7, count + 4 * seconds, packed1, score1, packed2, score2, packed3, score3)`, packed =
	client number + 128 * (deaths + 1000 * kills). Three cards go under the characters (2nd left, 1st in the middle, 3rd
	right), each with its place, score, the player's calling card, name, kills and deaths; a title and a countdown on top.
	The HUD is hidden meanwhile: the cards sit on the HUD's root, next to Hud_MP, whose alpha (and the common HUD's) is
	kept at 0 (main.lua's UpdateHUDVisibility sets it back on events).
	A calling card is the game's own lookup (ChallengesUtility.UpdateCallingCard's clientNum path): the client's lobby
	xuid, then its emblem background id from the profiles, drawn from the backgrounds table (CallingCard). Animated cards
	are widgets whose Lua only the frontend has: in game they show their still picture.
	The three on the podium get a button and a wheel of their equipped sprays and gestures (ShieldPodiumPick): a pick
	goes to the server (podium_gesture), which plays it on the character for everyone.
]]
local NOTIFY = @"shield_podium"
local PICK_MENU = "ShieldPodiumPick"
local FONT = "ttmussels_regular"
local FONT_BOLD = "ttmussels_demibold"

local CARD_W, CARD_H = 420, 256
local FADE_MS = 1000

local PLACES = {
	{ label = "1ST", color = { 1, 0.82, 0.25 }, x = 0, delay = 700 },
	{ label = "2ND", color = { 0.82, 0.87, 0.93 }, x = -480, delay = 350 },
	{ label = "3RD", color = { 1, 0.62, 0.35 }, x = 480, delay = 0 }
}

local ITEMS = @"hash_2B2E4CCC119597B0"
local SLOTS = @"hash_688987BA1B9D616B"
local ITEM_ICON = @"hash_5BFF4CC56C2092F0"
local ITEM_NAME = @"hash_5A31296C0C1B6029"

local function Log( text )
	Engine[@"printinfo"]( 0, "[PodiumHud] " .. tostring( text ) )
end

local function Localize( text )
	if not text or text == @"hash_0" then
		return ""
	end
	return Engine[@"hash_4F9F1239CFD921FE"]( text ) or ""
end

local function Image( name )
	if type( name ) == "userdata" then
		return name
	end
	return RegisterImage( name )
end

local function Rect( parent, xl, xr, left, right, yt, yb, top, bottom, rgb, alpha )
	local rect = LUI.UIImage.new( xl, xr, left, right, yt, yb, top, bottom )
	rect:setRGB( rgb[1], rgb[2], rgb[3] )
	rect:setAlpha( alpha or 1 )
	parent:addElement( rect )
	return rect
end

local function Text( parent, xl, xr, left, right, yt, yb, top, bottom, align, font )
	local text = LUI.UIText.new( xl, xr, left, right, yt, yb, top, bottom )
	text:setTTF( font or FONT )
	text:setAlignment( Enum[@"luialignment"][align or @"lui_alignment_center"] )
	text:setRGB( 1, 1, 1 )
	parent:addElement( text )
	return text
end

--[[
	Animation steps one after the other on an element: { ms, fn } each, fn sets where the step ends. A new sequence on
	the element drops the old one (its token).
]]
local function Sequence( element, steps )
	local token = {}
	element.shieldSequence = nil
	element:completeAnimation()
	element.shieldSequence = token
	local k = 0
	local function nextStep()
		if element.shieldSequence ~= token then
			return
		end
		k = k + 1
		local step = steps[k]
		if not step then
			element.shieldSequence = nil
			return
		end
		element:beginAnimation( math.max( 1, step[1] ) )
		step[2]( element )
	end
	element:registerEventHandler( "transition_complete_keyframe", function ()
		nextStep()
	end )
	nextStep()
end

-- fades in from offset y below its place
local function Reveal( element, delay, setTopBottom, offset )
	element:setAlpha( 0 )
	setTopBottom( offset )
	Sequence( element, {
		{ delay, function () end },
		{ 350, function ( self )
			self:setAlpha( 1 )
			setTopBottom( 0 )
		end }
	} )
end

local function PlayerName( controller, client )
	local name = Engine[@"getplayernameforclientnum"]( controller, client )
	if name and CoD.SocialUtility and CoD.SocialUtility.CleanGamerTag then
		name = CoD.SocialUtility.CleanGamerTag( name )
	end
	return name or ""
end

local function ClientXuid( client )
	if GetClientGameLobbyXUIDForClientNum then
		return GetClientGameLobbyXUIDForClientNum( client )
	end
	local module = Enum[@"lobbymodule"][@"lobby_module_client"]
	return Engine[@"getlobbyxuidforclientnum"]( module, Engine[@"lobbygetcontrollinglobbysession"]( module ), client )
end

-- (FreeCursorUtility.XUIDToEmblemBackgroundId's engine call)
local function BackgroundId( client )
	local ok, xuid = pcall( ClientXuid, client )
	if not ok or not xuid then
		Log( "client " .. tostring( client ) .. ": no xuid (" .. tostring( xuid ) .. ")" )
		return nil
	end
	local done, id = pcall( Engine[@"hash_72BA5D66D21186AD"], xuid )
	Log( "client " .. tostring( client ) .. ": xuid " .. tostring( xuid ) .. ", calling card " .. tostring( id ) )
	if done then
		return id
	end
	return nil
end

--[[
	A calling card from the backgrounds table (ChallengesUtility.GetBackgroundByID: column 3 of the id's row): an
	animated card's name is a widget class (ChallengesUtility.IsWidgetBasedCallingCard), else it is the card's image.
]]
local function CallingCard( menu, controller, parent, id, left, right, top, bottom )
	local csv = CoD.backgroundsTable or @"gamedata/emblems/backgrounds.csv"
	local name = Engine[@"tablelookup"]( csv, 3, 1, id )
	if not name or name == @"hash_0" or name == "" then
		Log( "calling card " .. tostring( id ) .. ": not in " .. tostring( csv ) )
		return nil
	end

	local widget = CoD[name]
	if widget and widget.new then
		local ok, result = pcall( function ()
			local card = widget.new( menu, controller, 0, 0, left, right, 0, 0, top, bottom )
			parent:addElement( card )
			return card
		end )
		Log( "calling card " .. tostring( id ) .. ": widget " .. tostring( name ) .. ( ok and "" or ( " failed: " .. tostring( result ) ) ) )
		if ok then
			return result
		end
	end

	local picture = LUI.UIImage.new( 0, 0, left, right, 0, 0, top, bottom )
	picture:setImage( RegisterImage( name ) )
	parent:addElement( picture )
	Log( "calling card " .. tostring( id ) .. ": image " .. tostring( name ) )
	return picture
end

local function HideHud( menu )
	menu:setAlpha( 0 )
	local root = menu:getParent()
	if root and root.T7HudMenu then
		root.T7HudMenu:setAlpha( 0 )
	end
end

-- the item of the sprays and gestures list (index from 0): icon, name
local function ItemInfo( item )
	local all = Engine[ITEMS]()
	local info = all and all[item + 1]
	if not info then
		return nil
	end
	return { icon = info[ITEM_ICON], name = info[ITEM_NAME] }
end

---------------------------
-- the cards

local function MakeCard( self, menu, controller, index, place, client, score, kills, deaths )
	local card = LUI.UIElement.new( 0.5, 0.5, place.x - CARD_W / 2, place.x + CARD_W / 2, 1, 1, -CARD_H - 44, -44 )
	self:addElement( card )
	local rgb = place.color

	Rect( card, 0, 1, 0, 0, 0, 1, 0, 0, { 0.03, 0.04, 0.06 }, 0.82 )
	-- a glow of the place's colour along the top
	local glow = Rect( card, 0, 1, 0, 0, 0, 0, 0, 70, rgb, index == 1 and 0.16 or 0.08 )
	glow:setMaterial( LUI.UIImage.GetCachedMaterial( @"uie_feather_blend" ) )
	Rect( card, 0, 1, 0, 0, 0, 0, 0, index == 1 and 6 or 4, rgb )

	local label = Text( card, 0, 0, 16, 200, 0, 0, 12, 52, @"lui_alignment_left", FONT_BOLD )
	label:setText( place.label )
	label:setRGB( rgb[1], rgb[2], rgb[3] )
	local points = Text( card, 1, 1, -260, -16, 0, 0, 20, 48, @"lui_alignment_right" )
	points:setText( tostring( score ) .. " PTS" )
	points:setRGB( 0.85, 0.85, 0.85 )

	-- the calling card in a thin frame of the place's colour
	Rect( card, 0, 0, 8, CARD_W - 8, 0, 0, 58, 162, rgb, 0.7 )
	Rect( card, 0, 0, 10, CARD_W - 10, 0, 0, 60, 160, { 0, 0, 0 } )
	local id = BackgroundId( client )
	if id and id >= 0 then
		local ok, err = pcall( CallingCard, menu, controller, card, id, 10, CARD_W - 10, 60, 160 )
		if not ok then
			Log( "calling card " .. tostring( id ) .. " failed: " .. tostring( err ) )
		end
	end

	local name = Text( card, 0, 1, 10, -10, 0, 0, 170, 208, nil, FONT_BOLD )
	name:setText( PlayerName( controller, client ) )
	local stats = Text( card, 0, 1, 10, -10, 0, 0, 216, 242 )
	local ratio = deaths > 0 and kills / deaths or kills
	stats:setText( string.format( "KILLS %d     DEATHS %d     K/D %.2f", kills, deaths, ratio ) )
	stats:setRGB( 0.62, 0.64, 0.68 )

	Reveal( card, place.delay, function ( offset )
		card:setTopBottom( 1, 1, -CARD_H - 44 + offset, -44 + offset )
	end, 60 )
	return card
end

local function ShowPodium( menu, controller, data )
	if menu.ShieldPodium then
		return
	end

	local head = data[1] or 0
	local count = head % 4
	local seconds = math.floor( head / 4 )

	-- (on the HUD's root, so hiding Hud_MP leaves it)
	local root = menu:getParent() or menu
	local self = LUI.UIElement.new( 0, 1, 0, 0, 0, 1, 0, 0 )
	self.id = "ShieldPodium"
	root:addElement( self )
	menu.ShieldPodium = self
	self.cards = {}
	self.clients = {}

	HideHud( menu )
	self:addElement( LUI.UITimer.newElementTimer( 100, false, function ()
		HideHud( menu )
	end ) )

	-- a dark band behind the title, the title, a line, the countdown under it
	local band = Rect( self, 0, 1, 0, 0, 0, 0, 0, 190, { 0, 0, 0 }, 0.45 )
	band:setMaterial( LUI.UIImage.GetCachedMaterial( @"uie_feather_blend" ) )
	local titleBox = LUI.UIElement.new( 0, 1, 0, 0, 0, 0, 0, 190 )
	self:addElement( titleBox )
	local title = Text( titleBox, 0.5, 0.5, -600, 600, 0, 0, 44, 110, nil, FONT_BOLD )
	title:setText( "TOP PLAYERS" )
	local sub = Text( titleBox, 0.5, 0.5, -600, 600, 0, 0, 114, 138 )
	sub:setText( "MATCH COMPLETE" )
	sub:setRGB( 0.65, 0.67, 0.7 )
	Rect( titleBox, 0.5, 0.5, -160, 160, 0, 0, 148, 150, { 0.25, 0.26, 0.3 } )
	local timer = Rect( titleBox, 0.5, 0.5, -160, 160, 0, 0, 148, 150, PLACES[1].color )
	if seconds > 0 then
		timer:beginAnimation( seconds * 1000 )
		timer:setLeftRight( 0.5, 0.5, 0, 0 )
	end
	Reveal( titleBox, 0, function ( offset )
		titleBox:setTopBottom( 0, 0, -offset, 190 - offset )
	end, 30 )

	for i, place in ipairs( PLACES ) do
		local packed = data[i * 2]
		if i <= count and packed ~= nil and packed >= 0 then
			local client = packed % 128
			local rest = math.floor( packed / 128 )
			local deaths = rest % 1000
			local kills = math.floor( rest / 1000 )
			self.cards[i] = MakeCard( self, menu, controller, i, place, client, data[i * 2 + 1] or 0, kills, deaths )
			self.clients[i] = client
		end
	end
	Log( "shown, " .. tostring( count ) .. " players, " .. tostring( seconds ) .. " s" )

	-- the end: a fade to black over the last FADE_MS, held until the next map
	if seconds > 0 then
		local black = Rect( self, 0, 1, 0, 0, 0, 1, 0, 0, { 0, 0, 0 }, 0 )
		Sequence( black, {
			{ math.max( 1, seconds * 1000 - FADE_MS ), function () end },
			{ FADE_MS, function ( element )
				element:setAlpha( 1 )
			end }
		} )
	end

	-- the bar for a local player on the podium
	local mine = Engine[@"getclientnum"]( controller )
	for i, client in pairs( self.clients ) do
		if client == mine then
			CoD.ShieldPodiumPickSeconds = seconds
			OpenPopup( menu, PICK_MENU, controller )
			Log( "you are " .. PLACES[i].label .. ": the pick bar is open" )
		end
	end
end

---------------------------
--[[
	The pick menu of a player on the podium: a button (top left: G / click, the pad's Y) opens a wheel like the game's
	(CoD.MPSpraysAndGestures: the same LUI.WheelLayout of CoD.SprayOrGesture items on the game's SpraysAndGestures data
	source, the centre circle, the pointer; the mouse or the right stick points, a click / A plays the item), F plays the
	quick spray, 1-8 an item of the wheel straight away. A pick goes to the server (podium_gesture, the item index),
	which plays it on the character for everyone. Esc closes the wheel, then hides it all.
]]
local WHEEL_SIZE = 354

LUI.createMenu[PICK_MENU] = function ( controller )
	local self = CoD.Menu.NewForUIEditor( PICK_MENU, controller )
	self:setOwner( controller )
	self:setLeftRight( 0, 1, 0, 0 )
	self:setTopBottom( 0, 1, 0, 0 )
	self.soundSet = "default"
	-- (the stage stays sharp behind it)
	self.disableBlur = true

	-- multiplayer's 9 slots (item index + 1): the quick spray, then the wheel's 8
	local slots = Engine[SLOTS]( controller, Enum[@"emodes"][@"mode_multiplayer"] ) or {}
	local function SlotItem( slot )
		local value = slots[slot]
		if value and value > 0 and ItemInfo( value - 1 ) then
			return value - 1
		end
		return nil
	end
	local quick = SlotItem( 1 )
	Log( "pick menu: quick spray " .. tostring( quick ) .. ", " .. tostring( #slots ) .. " slots" )

	-- the button
	local button = LUI.UIElement.new( 0, 0, 40, 380, 0, 0, 36, 108 )
	self:addElement( button )
	button.id = "PodiumWheelButton"
	self.PodiumWheelButton = button
	local edge = Rect( button, 0, 1, -2, 2, 0, 1, -2, 2, PLACES[1].color, 0.35 )
	Rect( button, 0, 1, 0, 0, 0, 1, 0, 0, { 0.03, 0.04, 0.06 }, 0.85 )
	Rect( button, 0, 0, 14, 58, 0, 0, 14, 58, PLACES[1].color )
	local keyCap = Text( button, 0, 0, 14, 58, 0, 0, 20, 52, nil, FONT_BOLD )
	keyCap:setText( "G" )
	keyCap:setRGB( 0, 0, 0 )
	Text( button, 0, 0, 72, 330, 0, 0, 10, 40, @"lui_alignment_left", FONT_BOLD ):setText( "SPRAYS & GESTURES" )
	local buttonHint = Text( button, 0, 0, 72, 330, 0, 0, 42, 62, @"lui_alignment_left" )
	buttonHint:setRGB( 0.6, 0.62, 0.66 )
	buttonHint:setText( quick and "[F] QUICK SPRAY     [ESC] HIDE" or "[ESC] HIDE" )
	local buttonHit = LUI.UIElement.new( 0, 1, 0, 0, 0, 1, 0, 0 )
	buttonHit:setHandleMouse( true )
	button:addElement( buttonHit )
	buttonHit.id = "PodiumWheelButtonHit"
	button.PodiumWheelButtonHit = buttonHit

	-- the wheel (CoD.MPSpraysAndGestures' parts)
	local wheelRoot = LUI.UIElement.new( 0, 1, 0, 0, 0, 1, 0, 0 )
	wheelRoot:setAlpha( 0 )
	self:addElement( wheelRoot )
	wheelRoot.id = "PodiumWheelRoot"
	self.PodiumWheelRoot = wheelRoot
	Rect( wheelRoot, 0, 1, 0, 0, 0, 1, 0, 0, { 0, 0, 0 }, 0.45 )
	local center = LUI.UIImage.new( 0.5, 0.5, -78, 78, 0.5, 0.5, -78, 78 )
	center:setImage( RegisterImage( @"uie_ui_hud_radial_menu_center_circle" ) )
	center:setMaterial( LUI.UIImage.GetCachedMaterial( @"hash_F755127C95CF5B6" ) )
	center:setShaderVector( 0, 1.5, 0, 0, 0 )
	wheelRoot:addElement( center )
	local wheel = LUI.WheelLayout.new( self, controller, nil )
	wheel:setLeftRight( 0.5, 0.5, -WHEEL_SIZE / 2, WHEEL_SIZE / 2 )
	wheel:setTopBottom( 0.5, 0.5, -WHEEL_SIZE / 2, WHEEL_SIZE / 2 )
	wheel:setWidgetType( CoD.SprayOrGesture )
	wheel:setCount( 8 )
	wheel:setDataSource( "SpraysAndGestures" )
	wheelRoot:addElement( wheel )
	local title = Text( wheelRoot, 0.5, 0.5, -70, 70, 0.5, 0.5, -12, 12, nil, FONT_BOLD )
	title:setRGB( 0.87, 0.53, 0.05 )
	title:setText( "" )
	if CoD.WheelTriangleIndicator then
		local pointer = CoD.WheelTriangleIndicator.new( self, controller, 0.5, 0.5, -12, 12, 0.5, 0.5, -12, 12 )
		pointer:subscribeToGlobalModel( controller, "HUDItems", "wheelPointerDegrees", function ( model )
			local degrees = model:get()
			if degrees ~= nil then
				pointer:setZRot( degrees )
			end
		end )
		wheelRoot:addElement( pointer )
	end
	-- the click area over the wheel
	local wheelHit = LUI.UIElement.new( 0.5, 0.5, -300, 300, 0.5, 0.5, -300, 300 )
	wheelHit:setHandleMouse( true )
	wheelRoot:addElement( wheelHit )
	wheelHit.id = "PodiumWheelHit"
	wheelRoot.PodiumWheelHit = wheelHit

	local stick = wheel:getStickModel( controller )
	local isOpen = false

	-- the wedge's item: the wheel's slot k (0-based) is the 9 slots' k + 2
	local function WedgeItem( wedge )
		return wedge and wedge >= 0 and SlotItem( wedge + 2 ) or nil
	end

	local ready = 0
	local function play( item )
		if not item then
			return false
		end
		local now = Engine[@"milliseconds"]()
		if now < ready then
			return false
		end
		ready = now + 1000
		Engine[@"sendmenuresponse"]( controller, "shield_support_menu", "podium_gesture", item )
		Log( "picked item " .. tostring( item ) )
		return true
	end

	local function SetOpen( open )
		if open == isOpen then
			return
		end
		isOpen = open
		wheelRoot:beginAnimation( open and 80 or 120 )
		wheelRoot:setAlpha( open and 1 or 0 )
		button:beginAnimation( 120 )
		button:setAlpha( open and 0.4 or 1 )
		stick.SelectedWedge:set( -1 )
		self._gamepadSelectionEnabled = false
		title:setText( "" )
		if open then
			wheel:updateDataSource()
			CoD.HUDUtility.MenuDelayedSetRightStickLock( self, controller, 0, true )
		else
			CoD.HUDUtility.MenuDelayedSetRightStickLock( self, controller, 125, false )
		end
	end

	local function choose()
		if not isOpen then
			return
		end
		local item = WedgeItem( stick.SelectedWedge:get() )
		if item then
			play( item )
			SetOpen( false )
		end
	end

	-- pointing: the mouse (the game's PC wheel, by the cursor's angle from the centre) and the right stick
	self:subscribeToModel( DataSources.FreeCursor.getModel( controller ).position, function ()
		if isOpen and not self._gamepadSelectionEnabled then
			CoD.HUDUtility.UpdateCurrentStickSelectionModelOnPC( self, controller, wheel )
		end
	end, false )
	self:subscribeToGlobalModel( controller, "RightStick", "Length", function ( model )
		if isOpen then
			CoD.HUDUtility.UpdateSelectionModelFromLength( controller, self, wheel, model, false )
		end
	end )
	self:subscribeToGlobalModel( controller, "RightStick", "Degrees", function ()
		if isOpen then
			CoD.HUDUtility.UpdateSelectionModelFromDegrees( controller, self, wheel, false )
		end
	end )
	self:subscribeToModel( stick.SelectedWedge, function ( model )
		local item = WedgeItem( model:get() )
		local info = item and ItemInfo( item )
		title:setText( info and Localize( info.name ) or "" )
	end, false )

	local function cycle( step )
		if not isOpen then
			return
		end
		local wedge = stick.SelectedWedge:get() or -1
		wedge = wedge < 0 and 0 or ( wedge + step ) % 8
		if stick.SelectedWedge:set( wedge ) then
			wheel:playSound( "wheel_changed" )
		end
		Engine[@"getmodelforcontroller"]( controller ).hudItems.wheelPointerDegrees:set( ( ( wedge + 2 ) % 8 ) * 45 )
	end

	local closing = false
	local function close()
		if isOpen then
			SetOpen( false )
			return
		end
		if closing then
			return
		end
		closing = true
		CoD.HUDUtility.MenuDelayedSetRightStickLock( self, controller, 0, false )
		GoBack( self, controller )
	end

	local function always()
		return true
	end
	local luiButton = Enum[@"luibutton"]
	local keys = {
		{ luiButton[@"lui_key_xbb_pscircle"], "ESCAPE", close },
		{ luiButton[@"lui_key_xby_pstriangle"], "G", function () SetOpen( not isOpen ) end },
		{ luiButton[@"lui_key_none"], "F", function () play( quick ) end },
		{ luiButton[@"lui_key_left"], "ui_navleft", function () cycle( -1 ) end },
		{ luiButton[@"lui_key_right"], "ui_navright", function () cycle( 1 ) end },
		{ luiButton[@"lui_key_xba_pscross"], "ui_confirm", choose },
	}
	for k = 1, 8 do
		table.insert( keys, { luiButton[@"lui_key_none"], tostring( k ), function ()
			if play( SlotItem( k + 1 ) ) then
				SetOpen( false )
			end
		end } )
	end
	for _, key in ipairs( keys ) do
		self:AddButtonCallbackFunction( self, controller, key[1], key[2], function ()
			key[3]()
			return true
		end, always, false )
	end

	--[[
	 the mouse (zm_park's pot menu): the menu gives mouse focus only to a focusable element it registered (makeFocusable,
	 found down menu[id][id]...); a click is the MOUSE1 key, which a menu listens for once a child has its own confirm
	 callback, and the press and release reach the element with mouse focus as leftmousedown / leftmouseup
	]]
	local function Clickable( hit, fn, focus )
		hit:registerEventHandler( "gain_focus", function ( element, event )
			LUI.UIElement.gainFocus( element, event )
			if focus then
				focus( true )
			end
			return true
		end )
		hit:registerEventHandler( "lose_focus", function ( element, event )
			LUI.UIElement.loseFocus( element, event )
			if focus then
				focus( false )
			end
			return true
		end )
		hit:registerEventHandler( "leftmousedown", function ()
			return true
		end )
		hit:registerEventHandler( "leftmouseup", function ( element, event )
			if event.inside then
				fn()
			end
			return true
		end )
		self:AddButtonCallbackFunction( hit, controller, luiButton[@"lui_key_xba_pscross"], "ui_confirm", function ()
			fn()
			return true
		end, always, false )
		hit:makeFocusable( controller )
	end
	Clickable( buttonHit, function ()
		SetOpen( not isOpen )
	end, function ( focused )
		edge:setAlpha( focused and 1 or 0.35 )
	end )
	Clickable( wheelHit, choose )

	-- closes itself as the fade to black starts
	local seconds = CoD.ShieldPodiumPickSeconds or 8
	self:addElement( LUI.UITimer.newElementTimer( math.max( 1, seconds * 1000 - FADE_MS ), true, function ()
		SetOpen( false )
		close()
	end ) )

	Reveal( button, 900, function ( offset )
		button:setTopBottom( 0, 0, 36 - offset, 108 - offset )
	end, 20 )
	return self
end

---------------------------

local function WatchPodium( menu, controller )
	if menu.ShieldPodiumWatch then
		return
	end

	local watch = LUI.UIElement.new( 0, 0, 0, 0, 0, 0, 0, 0 )
	watch.id = "ShieldPodiumWatch"
	menu:addElement( watch )
	menu.ShieldPodiumWatch = watch

	watch:subscribeToGlobalModel( controller, "PerController", "scriptNotify", function ( model )
		local name = Engine[@"getmodelvalue"]( model )
		if name == NOTIFY then
			local ok, err = pcall( ShowPodium, menu, controller, CoD.GetScriptNotifyData( model ) or {} )
			if not ok then
				Log( "not shown: " .. tostring( err ) )
			end
		end
	end )
end

-- (CustomMapHud.lua calls the watchers when the MP HUD opens)
CoD.ShieldHudWatchers = CoD.ShieldHudWatchers or {}
CoD.ShieldHudWatchers.podium = function ( menu, controller )
	local ok, err = pcall( WatchPodium, menu, controller )
	if not ok then
		Log( "not watched: " .. tostring( err ) )
	end
end
