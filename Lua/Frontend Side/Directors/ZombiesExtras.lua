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

-- one of the two choices, as ServerORLobbyBrowserSelect.lua's
local function AddChoice( self, menu, controller, left, right, text, open )
	local button = CoD.DirectorSelectButtonMiniInternal.new( menu, controller, 0.5, 0.5, left, right, 0.5, 0.5, -150, 150 )
	button.MiddleText:setTTF( "notosans_bold" )
	button.MiddleText:setText( text )
	button.MiddleTextFocus:setTTF( "notosans_bold" )
	button.MiddleTextFocus:setText( text )
	button:mergeStateConditions( {
		{
			stateName = "Locked",
			condition = function ( menu, element, event )
				return AlwaysFalse()
			end
		}
	} )
	self:addElement( button )

	menu:AddButtonCallbackFunction( button, controller, Enum[@"luibutton"][@"lui_key_xba_pscross"], "ui_confirm", function ( element, menu, controller, model )
		PlaySoundAlias( "uin_paint_image_flip_toggle" )
		open( controller )
		return true
	end, function ( element, menu, controller )
		if IsGamepad( controller ) then
			CoD.Menu.SetButtonLabel( menu, Enum[@"luibutton"][@"lui_key_xba_pscross"], @"menu/select", nil, "ui_confirm" )
			return true
		end
		CoD.Menu.SetButtonLabel( menu, Enum[@"luibutton"][@"lui_key_xba_pscross"], @"hash_0", nil, "ui_confirm" )
		return false
	end, false )

	return button
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

	-- the zombies characters, as the button did
	self.Characters = AddChoice( self, menu, controller, -550, -100, Localize( @"menu/characters" ), function ( controller )
		CoD.DirectorUtility.OpenDirectorChangeCharacterMenu( self, nil, controller, param, self )
	end )
	self.Characters.id = "Characters"

	-- multiplayer's sprays and gestures menu, on zombies' own slots until this menu is back on top
	self.SpraysGestures = AddChoice( self, menu, controller, 100, 550, "Sprays & Gestures", function ( controller )
		local mode = Enum[@"emodes"][@"mode_multiplayer"]
		EditZombiesSlots( true )
		CoD.DirectorUtility.OpenDirectorPersonalizationMenu( self, nil, controller, {
			_sessionMode = mode,
			_storageLoadoutBuffer = CoD.BreadcrumbUtility.GetStorageLoadoutBufferForPlayer( controller, mode ),
			_allowsQuickSelect = true
		}, self )
	end )
	self.SpraysGestures.id = "SpraysGestures"

	self:appendEventHandler( "occlusion_change", function ( element, event )
		if not event.occluded then
			EditZombiesSlots( false )
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
	self.Characters:close()
	self.SpraysGestures:close()
end
