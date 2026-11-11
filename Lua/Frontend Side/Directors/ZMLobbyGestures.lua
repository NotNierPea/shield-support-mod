if not CoD.isFrontend then
	return
end

CoD.ShieldInitLuaFile()

---------------------------

--[[
	Lobby gestures in zombies. The lobby's gesture wheel (right trigger / its PC key: DirectorGestureSelector, opened by the
	Director) needs CoD.DirectorUtility[0x61E20A632CB63092] to say the lobby's room has players standing in it: the game's
	lists only multiplayer's and Blackout's (lobby_pose, private_lobby_pose, arena_pose, warzone). Zombies has two rooms:
	- zm_online / zm_custom, the ready-up screen: the players' draft characters, as Blackout's; frontend_draft.csc plays the
	  picks on them already (positiondraft_playgesture).
	- zombie, the lobby: one character, the frozen moment's (frontend.csc). Nothing plays them there: the picks are also
	  sent as shield_zm_lobby_gesture, Support.csc plays them on it.
	The wheel lists zombies' own slots (sprays_gestures.cpp of shield-client).

	Sprays: the quick spray (slot 1, right / F) is filled for multiplayer and Blackout only (DataSources.QuickSpray): it
	is filled here from zombies' slot when the wheel opens. A played spray shows only on the 3D tags (DirectorTagsUI3D,
	UI3D window 1), which zombies' lobby scenes have no surface for: the zombies overhead names (DirectorCharacterZM,
	over each character) get the spray's icon from the same model (LobbyClients.<n>.sprayGestureIndex, 5 s).
]]
local GESTURE_ROOM = @"hash_61E20A632CB63092"
local LOBBY_ROOM = @"zombie"
local ZOMBIES_ROOMS = { [@"zm_online"] = true, [@"zm_custom"] = true, [@"zombie"] = true }

local function Log( text )
	Engine[@"printinfo"]( 0, "[shield] zombies lobby gestures: " .. text .. "\n" )
end

local function Room()
	local target = LobbyData.GetCurrentMenuTarget()
	return target and target[@"room"] and Engine[@"converttoxhash"]( target[@"room"] )
end

local function WrapRoom()
	local utility = CoD.DirectorUtility
	if not utility or type( utility[GESTURE_ROOM] ) ~= "function" or utility[GESTURE_ROOM] == utility.shieldGestureRoom then
		return
	end
	local gameRoom = utility[GESTURE_ROOM]
	utility[GESTURE_ROOM] = function ( controller, ... )
		if gameRoom( controller, ... ) then
			return true
		end
		if Engine[@"currentsessionmode"]() ~= Enum[@"emodes"][@"mode_zombies"] then
			return false
		end
		local ok, room = pcall( Room )
		return ok and room ~= nil and ZOMBIES_ROOMS[room] == true
	end
	utility.shieldGestureRoom = utility[GESTURE_ROOM]
	Log( "rooms wrapped" )
end

-- the lobby's one character: the pick (-1 stops it) to Support.csc
local function SendLobbyGesture( controller, index )
	if Engine[@"currentsessionmode"]() ~= Enum[@"emodes"][@"mode_zombies"] or Room() ~= LOBBY_ROOM then
		return
	end
	Engine[@"sendclientscriptnotify"]( controller, "shield_zm_lobby_gesture" .. CoD.GetLocalClientAdjustedNum( controller ), {
		gesture_index = index
	} )
end

local function WrapPlay()
	local utility = CoD.PlayerRoleUtility
	if not utility or not utility.PlayDraftGesture_Internal or utility.PlayDraftGesture_Internal == utility.shieldLobbyGesture then
		return
	end
	local gamePlay = utility.PlayDraftGesture_Internal
	local gameStop = utility.StopDraftGesture
	utility.PlayDraftGesture_Internal = function ( controller, index, ... )
		local result = gamePlay( controller, index, ... )
		if index and index >= 0 then
			local ok, err = pcall( SendLobbyGesture, controller, index )
			if not ok then
				Log( "not sent: " .. tostring( err ) )
			end
		end
		return result
	end
	if gameStop then
		utility.StopDraftGesture = function ( menu, controller, ... )
			local result = gameStop( menu, controller, ... )
			pcall( SendLobbyGesture, controller, -1 )
			return result
		end
	end
	utility.shieldLobbyGesture = utility.PlayDraftGesture_Internal
	Log( "gesture picks wrapped" )
end

local GET_SLOTS = @"hash_688987BA1B9D616B"
local ITEMS = @"hash_2B2E4CCC119597B0"

-- the quick spray of zombies' slots (item index + 1 in slot 1)
local function FillQuickSpray( controller )
	if not DataSources.QuickSpray or Engine[@"currentsessionmode"]() ~= Enum[@"emodes"][@"mode_zombies"] then
		return
	end
	local slots = Engine[GET_SLOTS]( controller, Enum[@"emodes"][@"mode_zombies"] )
	local item = slots and slots[1]
	local entry = item and item > 0 and Engine[ITEMS]()[item]
	if not entry then
		Log( "quick spray: zombies slot 1 is empty (" .. tostring( item ) .. ")" )
		return
	end
	local model = DataSources.QuickSpray.getModel( controller )
	model.image:set( entry[@"icon"] )
	model.displayName:set( entry[@"title"] )
	model.index:set( item - 1 )
	Log( "quick spray: item " .. tostring( item - 1 ) )
end

local function WrapSelector()
	local create = LUI.createMenu.DirectorGestureSelector
	if not create or create == CoD.ShieldGestureSelector then
		return
	end
	-- (after the menu is made: it recreates the QuickSpray models first thing, which emptied it when filled before)
	CoD.ShieldGestureSelector = function ( controller, ... )
		local menu = create( controller, ... )
		local ok, err = pcall( FillQuickSpray, controller )
		if not ok then
			Log( "quick spray not filled: " .. tostring( err ) )
		end
		return menu
	end
	LUI.createMenu.DirectorGestureSelector = CoD.ShieldGestureSelector
	Log( "gesture selector wrapped" )
end

--[[
	The spray's icon while the character sprays: a small one above the name, and a big one in front of the character
	(multiplayer's 3D tag stands in front of them; the name is over the head, so the body is below it).
]]
local function AddSprayIcon( self )
	local top = LUI.UIImage.new( 0.5, 0.5, -48, 48, 0, 0, -104, -8 )
	local front = LUI.UIImage.new( 0.5, 0.5, -110, 110, 0, 0, 150, 370 )
	for _, icon in ipairs( { top, front } ) do
		icon:setAlpha( 0 )
		self:addElement( icon )
	end
	self.ShieldSprayIcon = top
	self.ShieldSprayFront = front
	self:linkToElementModel( self, "sprayGestureIndex", true, function ( model )
		local index = model:get()
		local shown = index and index >= 0
		local image = shown and RegisterImage( CoD.PlayerRoleUtility.GetTagIconFromIndex( index ) )
		for _, icon in ipairs( { top, front } ) do
			if shown then
				icon:setImage( image )
			end
			icon:setAlpha( shown and 1 or 0 )
		end
	end )
end

local function WrapOverhead()
	local widget = CoD.DirectorCharacterZM
	if not widget or widget.new == widget.shieldNew then
		return
	end
	local gameNew = widget.new
	widget.new = function ( menu, controller, ... )
		local self = gameNew( menu, controller, ... )
		local ok, err = pcall( AddSprayIcon, self )
		if not ok then
			Log( "spray icon not added: " .. tostring( err ) )
		end
		return self
	end
	widget.shieldNew = widget.new
	Log( "overhead names wrapped" )
end

local function Wrap()
	WrapRoom()
	WrapPlay()
	WrapSelector()
	WrapOverhead()
end

Wrap()

if not CoD.ShieldZMLobbyGesturesRequire then
	CoD.ShieldZMLobbyGesturesRequire = true
	local GameRequire = require
	require = function ( ... )
		local result = GameRequire( ... )
		Wrap()
		return result
	end
end
