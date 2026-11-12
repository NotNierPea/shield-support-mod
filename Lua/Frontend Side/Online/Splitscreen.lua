--[[
	Native splitscreen: a 2nd controller joins the lobby as a guest of the signed-in player (shield-client
	splitscreen.cpp, "splitscreen": { "enabled": true }). The stock check below returns false on PC; this is the same
	check without that exit.
]]

---------------------------

CoD.ShieldInitLuaFile()

---------------------------

local function SplitscreenOn()
	return ShieldFuncs ~= nil and ShieldFuncs.Splitscreen ~= nil and ShieldFuncs.Splitscreen() == true
end

local function LobbyLog( text )
	Engine[@"printinfo"]( Enum[@"consolelabel_e"][@"con_label_live"], "[splitscreen] " .. text .. "\n" )
end

-- defined with the free cursor fix below
local EnsureFreeCursorModels

-- the lobby VM sets it to min(lobby menu maxLocalClients, 2)
local function ForceMaxLocalPlayers()
	if Dvar[@"lobby_maxlocalplayers"]:get() < 2 then
		Dvar[@"lobby_maxlocalplayers"]:set( 2 )
	end
end

local function IsManualGame()
	return Engine[@"gamemodeismode"]( Enum[@"egamemodes"][@"mode_game_matchmaking_manual"] ) or Engine[@"gamemodeismode"]( Enum[@"egamemodes"][@"hash_27B5630CD29180CB"] )
end

-- stock lobbyutility's local max players: the playlist's limits in matchmaking, else the dvar
local function MaxLocalPlayers()
	local max = Dvar[@"lobby_maxlocalplayers"]:get()
	if not IsLAN() and not IsManualGame() then
		local playlist = Engine[@"getplaylistinfobyid"]( Engine[@"getmodelvalue"]( Engine[@"getmodel"]( Engine[@"getglobalmodel"](), "lobbyRoot.playlistId" ) ) )
		local globalModel = Engine[@"getglobalmodel"]()
		if playlist ~= nil and globalModel.lobbyRoot.lobbyMainMode:get() == playlist.mainMode then
			max = math.min( playlist.maxLocalPlayers, playlist.maxPartySize )
		end
	end
	if Engine[@"lobbygetgametype"]() == "ztutorial" then
		max = 1
	end
	return max
end

local StockControllersAllowed = CoD.LobbyUtility.SplitscreenControllersAllowed

CoD.LobbyUtility.SplitscreenControllersAllowed = function ()
	if not SplitscreenOn() then
		return StockControllersAllowed()
	end

	local client = Enum[@"lobbymodule"][@"lobby_module_client"]
	local lobbyType = Enum[@"lobbytype"][@"lobby_type_private"]
	if not IsLobbyHostOfLobbyType( lobbyType ) then
		return false
	end
	ForceMaxLocalPlayers()

	if Engine[@"islobbyactive"]( client, Enum[@"lobbytype"][@"lobby_type_game"] ) then
		lobbyType = Enum[@"lobbytype"][@"lobby_type_game"]
		if not IsLobbyHostOfLobbyType( lobbyType ) then
			return false
		elseif IsMultiplayer() and IsLive() and not IsManualGame() then
			return false
		elseif IsZombies() and IsLive() and not Engine[@"gamemodeismode"]( Enum[@"egamemodes"][@"mode_game_matchmaking_manual"] ) then
			return false
		elseif CompetitiveSettingsEnabled() then
			return false
		end
	end

	local clients = Engine[@"getlobbyclientcount"]( client, lobbyType, Enum[@"lobbyclientfiltertype"][@"lobby_client_filter_type_all"] )
	local maxClients = Engine[@"getlobbymaxclients"]( client, lobbyType )
	local used = Engine[@"getusedcontrollercount"]()
	if used >= 2 and lobbyType == Enum[@"lobbytype"][@"lobby_type_game"] and clients + Engine[@"lobbyjoincount"]() ~= used then
		return false
	end
	return clients < maxClients and used < MaxLocalPlayers()
end

-- the lobby's unused_gamepad_button handler checks the dvar before the function above
if LobbyAddLocalClient ~= nil then
	local StockAddLocalClient = LobbyAddLocalClient
	LobbyAddLocalClient = function ( menu, controller )
		if SplitscreenOn() then
			ForceMaxLocalPlayers()
			EnsureFreeCursorModels( controller )
		end
		return StockAddLocalClient( menu, controller )
	end
elseif SplitscreenOn() then
	LobbyLog( "LobbyAddLocalClient isn't loaded yet, the dvar is only raised by the join check" )
end

if SplitscreenOn() then
	ForceMaxLocalPlayers()
end

---------------------------

-- a child model with its default, only when it isn't there yet
local function EnsureModel( parent, name, default )
	if parent[name] == nil then
		local model = parent:create( name )
		if default ~= nil then
			model:set( default )
		end
	end
end

--[[
	The PC free cursor makes its models (FreeCursor.contextualInfo.*) for the cursor's controller only, the primary one
	in the frontend, but OpenDetailedViewPC, CloseDetailedViewPC (every popup opening), IsDetailedViewPCActive and
	SetIsShowingContextualPromptsModelPC read them under the controller they're given: the guest's are nil (UI Errors
	64247, 67537 when the guest backs out). Same tree as DataSources.FreeCursor.getModel, for any controller.
]]
EnsureFreeCursorModels = function ( controller )
	if DataSources.FreeCursor == nil then
		return
	end
	local root = Engine[@"getmodelforcontroller"]( controller ):create( "FreeCursor" )
	EnsureModel( root, "hasFocus", false )
	EnsureModel( root, "hasLockedFocus", false )
	EnsureModel( root, "position" )
	EnsureModel( root, "hidden", 0 )
	EnsureModel( root, "usingCursorInput" )

	local info = root:create( "contextualInfo" )
	EnsureModel( info, "buttonPrompts" )
	EnsureModel( info, "updateActivePrompts" )
	EnsureModel( info, "updated", true )
	EnsureModel( info, "detailedView", true )
	for _, def in ipairs( DataSources.FreeCursor.modelDefs or {} ) do
		EnsureModel( info, def.name, def.default )
	end
	if CoD.isPC then
		EnsureModel( info, "detailedViewPC", false )
		EnsureModel( info, "updateContextualPromptPC" )
		EnsureModel( info, "hasContextualPrompts", false )
	end
end

if SplitscreenOn() then
	for controller = 0, 1 do
		EnsureFreeCursorModels( controller )
	end
end

if CoD.FreeCursorUtility ~= nil then
	CoD.FreeCursorUtility.IsDetailedViewPCActive = function ( controller )
		if not CoD.isPC then
			return false
		end
		local info = Engine[@"getmodelforcontroller"]( controller ):create( "FreeCursor" ):create( "contextualInfo" )
		local detailed = info.detailedViewPC
		return detailed ~= nil and detailed:get() == true
	end
end

---------------------------

-- the stock input checks ask about the primary controller whatever they're given (Engine.LastInput_* take one)
if SplitscreenOn() and IsMouseOrKeyboard ~= nil and IsGamepad ~= nil then
	local StockIsMouseOrKeyboard = IsMouseOrKeyboard
	local StockIsGamepad = IsGamepad

	IsMouseOrKeyboard = function ( controller )
		if controller == nil then
			return StockIsMouseOrKeyboard( controller )
		end
		local result = CoD.useMouse and Engine[@"lastinput_mouse"]( controller )
		if not result then
			result = CoD.useKeyboard and Engine[@"hash_267ACA658A43FBD"]( controller )
		end
		return result
	end

	IsGamepad = function ( controller )
		if controller == nil then
			return StockIsGamepad( controller )
		end
		return CoD.useController and Engine[@"lastinput_gamepad"]( controller )
	end
end

---------------------------

-- the guest backing out signs them out and leaves the party where it is, as on console (PC's leave popup has no such choice)
local function IsGuestController( controller )
	return controller ~= nil and controller ~= Engine[@"getprimarycontroller"]() and Engine[@"iscontrollerbeingused"]( controller )
end

if CoD.OverlayUtility ~= nil and CoD.OverlayUtility.AddSystemOverlay ~= nil then
	CoD.OverlayUtility.AddSystemOverlay( "ShieldSplitscreenSignOut", {
		menuName = "SystemOverlay_Compact",
		categoryType = CoD.OverlayUtility.OverlayTypes.Quit,
		-- the Compact menu localizes these: our own entries (metadata.json), not plain text
		title = @"shield/splitscreen_signout_title",
		description = @"shield/splitscreen_signout_desc",
		[CoD.OverlayUtility.aCrossPromptText] = @"shield/splitscreen_signout",
		[CoD.OverlayUtility.aCrossPromptFn] = function ()
			return function ( popup, controller )
				GoBack( popup, controller )
				LobbyLog( "controller " .. tostring( controller ) .. " signs out" )
				CoD.LobbyUtility.RemoveLocalPlayerFromTheLobby( popup, controller )
			end
		end,
		[CoD.OverlayUtility.bCirclePromptFn] = function ()
			return function ( popup, controller )
				GoBack( popup, controller )
			end
		end,
		[CoD.OverlayUtility.bCirclePromptText] = @"shield/splitscreen_cancel"
	} )

	local StockGoBack = CoD.LobbyUtility.LobbyGoBack
	CoD.LobbyUtility.LobbyGoBack = function ( menu, controller )
		if SplitscreenOn() and IsGuestController( controller ) then
			OpenSystemOverlay( menu, menu, controller, "ShieldSplitscreenSignOut" )
			return
		end
		return StockGoBack( menu, controller )
	end
end

---------------------------

-- "press a button to join" on the lobby while a guest can still join (BO4 has no widget for it)
local HINT_LEFT, HINT_RIGHT, HINT_TOP, HINT_HEIGHT = 96, 616, 948, 52

local function JoinHintVisible()
	return SplitscreenOn() and CoD.LobbyUtility.SplitscreenControllersAllowed() and Engine[@"getusedcontrollercount"]() < 2
end

local function AddJoinHint( menu )
	local ui = CoD.Shield.BrowserUI
	local hint = LUI.UIElement.new( 0, 0, HINT_LEFT, HINT_RIGHT, 0, 0, HINT_TOP, HINT_TOP + HINT_HEIGHT )
	hint.id = "ShieldSplitscreenJoinHint"

	local back = LUI.UIImage.new( 0, 1, 0, 0, 0, 1, 0, 0 )
	back:setRGB( 0, 0, 0 )
	back:setAlpha( 0.9 )
	hint:addElement( back )

	local accent = LUI.UIImage.new( 0, 1, 0, 0, 0, 0, 0, 4 )
	accent:setRGB( 1, 1, 1 )
	accent:setAlpha( 0.25 )
	hint:addElement( accent )

	if ui ~= nil then
		hint:addElement( ui.NewCaption( 16, HINT_RIGHT - HINT_LEFT - 16, 9, "SPLITSCREEN" ) )
		local line = ui.NewText( 16, HINT_RIGHT - HINT_LEFT - 16, 26, 20, "ttmussels_regular" )
		line:setText( "Press any button on another controller to join" )
		hint:addElement( line )
	end

	hint:setAlpha( 0 )
	hint:addElement( LUI.UITimer.newElementTimer( 500, false, function ()
		local ok, visible = pcall( JoinHintVisible )
		hint:setAlpha( ( ok and visible ) and 1 or 0 )
	end ) )

	menu:addElement( hint )
	menu.ShieldSplitscreenJoinHint = hint
end

-- the Director file loads after this one and LUI.createMenu has a metatable of its own: catch the menu where it's made
-- (LUI.createMenu.Director starts with CoD.Menu.NewForUIEditor( "Director" )), add the hint once it has its children
if CoD.Menu ~= nil and CoD.Menu.NewForUIEditor ~= nil then
	local StockNewForUIEditor = CoD.Menu.NewForUIEditor
	CoD.Menu.NewForUIEditor = function ( name, ... )
		local menu = StockNewForUIEditor( name, ... )
		if name == "Director" and menu ~= nil and SplitscreenOn() then
			menu:addElement( LUI.UITimer.newElementTimer( 1, true, function ()
				if menu.ShieldSplitscreenJoinHint == nil then
					AddJoinHint( menu )
				end
			end ) )
		end
		return menu
	end
elseif SplitscreenOn() then
	LobbyLog( "CoD.Menu.NewForUIEditor isn't loaded yet, no join hint" )
end
