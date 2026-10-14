--[[
		.\hksc.exe ".\Lua\LobbyBrowser.Lua" -o "C:\Program Files (x86)\Call of Duty Black Ops 4\project-bo4\mods\T8ShieldSupport\Lua\LobbyBrowser.luac"
]]

---------------------------

CoD.ShieldInitLuaFile()

---------------------------

-- dvars
Engine[@"exec"](Engine[@"getprimarycontroller"](), "set shield_filter_server " .. 0)
Engine[@"setdvar"]( "shield_search_server", "" )

---------------------------

CoD.Shield.ShowServerToast = function(event_name, event_table)
	-- Play a little sound
	Engine[@"playsound"]("uin_map_vote")

	-- Default values
	local message = event_name

	if type(event_table) == "table" and type(event_table.message) == "string" then
		message = event_table.message
	end

	-- debug
	CoD.EnhPrintInfo("Got Toast", message)

	-- show some toast
	CoD.OverlayUtility.ShowToast( "Invite", "Server", message, "ui_icon_startmenu_option_network" )
end

-- how often the client answered a question for the lobbies, with a list or with the word that there is none
local LobbyAnswers = 0

CoD.Shield.OnServerLobbyListReceived = function(event_name, event_table)
	CoD.EnhPrintInfo("got servers from C++ side")

	LobbyAnswers = LobbyAnswers + 1

	-- the master server gave no answer: that is said in the place of the rows, and nothing is waited for any more
	local Failed = type(event_table) == "table" and event_table.failed == 1
	local Root = Engine[@"getglobalmodel"]()

	Engine[@"createmodel"]( Root, "ShieldLobbyBrowser.failed" ):set( Failed and 1 or 0 )

	if Failed then
		Engine[@"createmodel"]( Root, "ShieldLobbyBrowser.count" ):set( 0 )
	end

	if CoD.Menu.ServerLobbyBrowser ~= nil then
		CoD.Menu.ServerLobbyBrowser:addElement( LUI.UITimer.newElementTimer( 5, true, function ()
			CoD.Shield.RefillLobbyRows( CoD.Menu.ServerLobbyBrowser )
			end)
		)
	end
end

-- The rows again, by what the client, the filter and the search say now. A list keeps the row it was scrolled to
-- when its rows change: with fewer rows than that, only the last ones would show. Emptied, it is put back to its
-- top before the new rows come.
CoD.Shield.RefillLobbyRows = function ( list )
	list:setDataSource( "ShieldDWGameServersEmpty" )
	list:updateDataSource()
	list:clearLayout()
	list:clearSavedActiveIndex()
	list:setDataSource( "ShieldDWGameServers" )
	list:updateDataSource()
end

---------------------------

-- the host of a row as the client sends it, "Name ^3[Mods: A, B]^7": the name, and the mods or ""
local function SplitHostLabel( label )
	local _, _, name, mods = string.find( label, "^(.-) %^3%[Mods: (.*)%]%^7$" )
	if name == nil then
		return label, ""
	end
	return name, mods
end

-- "mp", "zm" or "wz": the map says it best, a lobby with no map yet goes by what its host is in
local function LobbyModeOf( mode, map )
	if map ~= nil then
		local prefix = string.sub( map, 1, 3 )
		if prefix == "zm_" then
			return "zm"
		elseif prefix == "wz_" then
			return "wz"
		elseif prefix == "mp_" then
			return "mp"
		end
	end
	if mode == "zm" or mode == "wz" then
		return mode
	end
	return "mp"
end

-- the colour of a mode: the bar and the tag of a row, the line and the tag of the card
local LobbyModeColors = {
	mp = { r = 0.35, g = 0.75, b = 1 },
	zm = { r = 1, g = 0.38, b = 0.28 },
	wz = { r = 0.45, g = 0.9, b = 0.45 }
}

-- a mode in full, where a lobby tells no gametype
local LobbyModeNames = {
	mp = "MULTIPLAYER",
	zm = "ZOMBIES",
	wz = "BLACKOUT"
}

-- how many lobbies the list shows: -1 while the first answer is waited for
local function LobbyCountModel()
	return Engine[@"createmodel"]( Engine[@"getglobalmodel"](), "ShieldLobbyBrowser.count" )
end

-- 1 when the master server gave no answer to the last question, see CoD.Shield.OnServerLobbyListReceived
local function LobbyFailedModel()
	return Engine[@"createmodel"]( Engine[@"getglobalmodel"](), "ShieldLobbyBrowser.failed" )
end

-- the maps of blackout have no name in the table of maps
local BlackoutMapNames = {
	wz_open_skyscrapers = "Blackout",
	wz_open_skyscrapers_alt = "Blackout",
	wz_escape = "Alcatraz",
	wz_escape_alt = "Alcatraz"
}

-- no text, or one with nothing to see in it
local function IsBlankText( text )
	return type( text ) ~= "string" or string.find( text, "%S" ) == nil
end

-- what a row shows of a lobby: the map and the gametype its host tells, as the game names them. No playlist: a host can change both.
local function DescribeLobby( mode, map, gametype )
	local info = {
		mode = LobbyModeOf( mode, map ),
		mapName = "",
		gametypeName = "",
		image = @"ui_icon_director_quickplay_large"
	}

	if map ~= nil and map ~= "" and map ~= "UNK_MAP0" then
		if info.mode == "wz" then
			info.mapName = BlackoutMapNames[map] or "Blackout"
		else
			info.mapName = CoD.MapUtility.GetLocalizedMapValue( map, "mapName", "" )
		end

		info.image = MapNameToMapImage( map )
	end

	if IsBlankText( info.mapName ) then
		if info.mode == "wz" then
			info.mapName = "Blackout"
		else
			info.mapName = "Lobby"
		end
	end

	if gametype ~= nil and gametype ~= "" then
		info.gametypeName = CoD.GameTypeUtility.GetLocalizedGameTypeValue( gametype, "nameRef", "" )

		if IsBlankText( info.gametypeName ) then
			info.gametypeName = ToUpper( gametype )
		end
	end

	info.tag = ToUpper( info.mode )
	info.name = info.mapName

	if info.gametypeName ~= "" then
		info.name = info.name .. " - " .. info.gametypeName
	end

	info.title = "[" .. info.tag .. "] " .. info.name

	return info
end

-- a field of a row of the server list, nil when the client does not send it
local function ServerRowValue( root, index, field )
	local model = Engine[@"getmodel"]( root, "server" .. index .. "." .. field )
	if model == nil then
		return nil
	end
	return Engine[@"getmodelvalue"]( model )
end

-- A picture in a box that cuts what is over (setUseStencil): the pictures of the game are not all of one shape,
-- so it is made as large as the box needs in its own shape, centred, and never squeezed into the box.
local function SetPreviewImage( image, name, width, height )
	-- a picture some tables of the game give registered already, as userdata, draws nothing when it is registered again
	image:setImage( type( name ) == "userdata" and name or RegisterImage( name ) )

	local imageWidth, imageHeight = image:getImageDimensions()

	if imageWidth == nil or imageHeight == nil or imageWidth <= 0 or imageHeight <= 0 then
		image:setLeftRight( 0, 1, 0, 0 )
		image:setTopBottom( 0, 1, 0, 0 )
		return
	end

	local scale = math.max( width / imageWidth, height / imageHeight )
	local halfWidth = imageWidth * scale / 2
	local halfHeight = imageHeight * scale / 2

	image:setLeftRight( 0.5, 0.5, -halfWidth, halfWidth )
	image:setTopBottom( 0.5, 0.5, -halfHeight, halfHeight )
end

-- a text cut to what a row has room for
local function ShortenText( text, max )
	if string.len( text ) > max then
		return string.sub( text, 1, max - 2 ) .. ".."
	end
	return text
end

-- a text of one line, by its left and right end, its top and its size
local function NewText( left, right, top, size, font, alignment )
	local text = LUI.UIText.new( 0, 0, left, right, 0, 0, top, top + size )
	text:setTTF( font )
	text:setAlignment( alignment or Enum[@"luialignment"][@"lui_alignment_left"] )
	text:setAlignment( Enum[@"luialignment"][@"lui_alignment_top"] )
	return text
end

-- the small grey words over a value
local function NewCaption( left, right, top, words, alignment )
	local text = NewText( left, right, top, 15, "ttmussels_regular", alignment )
	text:setRGB( 0.55, 0.55, 0.55 )
	text:setLetterSpacing( 2 )
	text:setText( words )
	return text
end

-- a box of one colour
local function NewBox( left, right, top, bottom, r, g, b, alpha )
	local box = LUI.UIImage.new( 0, 0, left, right, 0, 0, top, bottom )
	box:setRGB( r, g, b )
	box:setAlpha( alpha )
	return box
end

-- Black over the lower end of a picture, fading out upwards, for what is written on it. Thin layers that all reach
-- down to the end, each a little stronger than the one over it: nothing shows between them at any size of the screen.
-- They go into the box that cuts the picture, after it, so they are drawn with it and over it.
local function AddBottomFade( clip, height, fade )
	local layers = math.floor( fade / 6 )

	for layer = 1, layers, 1 do
		local shade = LUI.UIImage.new( 0, 1, 0, 0, 0, 0, height - fade + ( layer - 1 ) * 6, height )
		shade:setRGB( 0, 0, 0 )
		shade:setAlpha( 0.01 + 0.09 * layer / layers )
		clip:addElement( shade )
	end
end

-- how full a lobby is: green, yellow when it fills, red when there is hardly a place left
local function FillColor( ratio )
	if ratio >= 0.9 then
		return 1, 0.4, 0.3
	elseif ratio >= 0.5 then
		return 1, 0.8, 0.25
	end
	return 0.45, 0.9, 0.45
end

-- the bar under the players of a lobby, nothing of it when the host tells no limit
local function SetFillBar( fill, left, width, players, max )
	if players == nil or max == nil or max <= 0 then
		fill:setAlpha( 0 )
		return
	end

	local ratio = math.min( math.max( players / max, 0 ), 1 )

	fill:setRGB( FillColor( ratio ) )
	fill:setAlpha( 1 )
	fill:setLeftRight( 0, 0, left, left + math.max( width * ratio, 2 ) )
end

-- "3 / 12", or the players alone
local function PlayersLabel( players, max )
	if max ~= nil and max > 0 then
		return players .. " / " .. max
	end
	return tostring( players or 0 )
end

-- empty to fix weird bug
DataSources.ShieldDWGameServersEmpty = DataSourceHelpers.ListSetup( "ShieldDWGameServersEmpty", function ( f3_arg0, f3_arg1 )
	local InfoServers = {

	}

	return InfoServers
end, true )

-- Shield's DW Game Server Data
DataSources.ShieldDWGameServers = DataSourceHelpers.ListSetup( "ShieldDWGameServers", function ( f3_arg0, f3_arg1 )
	local InfoServers = {

	}

	local ServerRoot = Engine[@"getmodel"]( Engine[@"getglobalmodel"](), "serverListRoot" )
	local ActiveServers = Engine[@"getdvarint"](@"shield_active_lobbies")

	local CountModel = LobbyCountModel()

	if ServerRoot == nil or ActiveServers == nil or ActiveServers <= 0 then
		CountModel:set( 0 )
		return InfoServers
	end

	local ModeNumbers = { mp = 1, zm = 2, wz = 3 }
	local Search = ToUpper( Engine[@"getdvarstring"]("shield_search_server") )
	local Filter = Engine[@"getdvarint"](@"shield_filter_server")

	for times_servers = 0, ActiveServers - 1, 1 do

		if Engine[@"getmodel"]( ServerRoot, "server" .. times_servers) ~= nil then

			local TryGetMap = ServerRowValue( ServerRoot, times_servers, "mapName" ) or "UNK_MAP0"
			local TryGetGameType = ServerRowValue( ServerRoot, times_servers, "gameType" ) or ""
			local TryHostName = ServerRowValue( ServerRoot, times_servers, "gamertag" ) or ""
			local TryClientCount = tonumber( ServerRowValue( ServerRoot, times_servers, "clientCount" ) ) or 0
			local TryLobbyID = ServerRowValue( ServerRoot, times_servers, "xuid" )
			-- these three come with the newer clients
			local TryMaxClients = tonumber( ServerRowValue( ServerRoot, times_servers, "maxClients" ) ) or 0
			local TryMode = ServerRowValue( ServerRoot, times_servers, "mode" )
			local TryMods = ServerRowValue( ServerRoot, times_servers, "mods" )

			if TryHostName == "" then
				TryHostName = "None, nil?"
			end

			-- an older client tells the mods in the name of the host
			local HostName, HostMods = SplitHostLabel( TryHostName )

			if TryMods ~= nil and TryMods ~= "" then
				HostMods = TryMods
			end

			local Lobby = DescribeLobby( TryMode, TryGetMap, TryGetGameType )
			local Shown = Filter == 0 or ModeNumbers[Lobby.mode] == Filter

			if Shown and Search ~= "" then
				-- the map, the gametype or the host, as they are named or as they are shown
				Shown = string.find( ToUpper( TryGetMap ), Search, 1, true ) ~= nil or
					string.find( ToUpper( Lobby.mapName ), Search, 1, true ) ~= nil or
					string.find( ToUpper( TryGetGameType ), Search, 1, true ) ~= nil or
					string.find( ToUpper( Lobby.gametypeName ), Search, 1, true ) ~= nil or
					string.find( ToUpper( HostName ), Search, 1, true ) ~= nil
			end

			if Shown then
				table.insert( InfoServers, {
					models = {
						ServerName = Lobby.title,
						HostedBy = HostName,
						Mods = HostMods,
						ClientCount = PlayersLabel( TryClientCount, TryMaxClients ),
						Players = TryClientCount,
						MaxPlayers = TryMaxClients,
						ConnectionIP = Engine[@"uint64tostring"](TryLobbyID),
						MapStatus = TryGetMap,
						GameTypeStatus = TryGetGameType,
						Mode = Lobby.mode
					},
					properties = {

					}
				} )
			end
		end
	end

	-- the lobbies with the most players first
	table.sort( InfoServers, function ( a, b )
		return a.models.Players > b.models.Players
	end )

	CountModel:set( #InfoServers )

	return InfoServers
end, true )

---------------------------

-- LAN Servers
CoD.ShieldLobbyServerBrowserOverlay = InheritFrom( CoD.Menu )
LUI.createMenu.ShieldLobbyServerBrowserOverlay = function ( f1_arg0, f1_arg1 )
	local self = CoD.Menu.NewForUIEditor( "ShieldLobbyServerBrowserOverlay", f1_arg0 )
	local f1_local1 = self

	self:setClass( CoD.ShieldLobbyServerBrowserOverlay )
	self.soundSet = "default"
	self:setOwner( f1_arg0 )
	self:setLeftRight( 0, 1, 0, 0 )
	self:setTopBottom( 0, 1, 0, 0 )
	self:playSound( "menu_open", f1_arg0 )
	self.anyChildUsesUpdateState = true

	local Background = CoD.StartMenuOptionsBackground.new( f1_local1, f1_arg0, 0, 1, 0, 0, 0, 1, 0, 0 )
	self:addElement( Background )
	self.Background = Background

	local FooterContainerFrontendRight = nil

	FooterContainerFrontendRight = CoD.FooterContainer_Frontend_Right.new( f1_local1, f1_arg0, 0.5, 0.5, -960, 960, 1, 1, -48, 0 )
	self:addElement( FooterContainerFrontendRight )
	self.FooterContainerFrontendRight = FooterContainerFrontendRight

	local SafeAreaContainerLobbyServerBrwoserOverlay = CoD.Shield_SafeAreaContainer_LobbyServerBrwoserOverlay.new( f1_local1, f1_arg0, 0, 0, 0, 1920, 0, 0, 0, 1080 )
	SafeAreaContainerLobbyServerBrwoserOverlay:registerEventHandler( "menu_loaded", function ( element, event )
		local f3_local0 = nil
		if element.menuLoaded then
			f3_local0 = element:menuLoaded( event )
		elseif element.super.menuLoaded then
			f3_local0 = element.super:menuLoaded( event )
		end
		if not IsPC() then
			SizeToSafeArea( element, f1_arg0 )
		end
		if not f3_local0 then
			f3_local0 = element:dispatchEventToChildren( event )
		end
		return f3_local0
	end )
	self:addElement( SafeAreaContainerLobbyServerBrwoserOverlay )
	self.SafeAreaContainerLobbyServerBrwoserOverlay = SafeAreaContainerLobbyServerBrwoserOverlay

	f1_local1:AddButtonCallbackFunction( self, f1_arg0, Enum[@"hash_3DD78803F918E9D"][@"hash_1805EFA15E9E7E5A"], nil, function ( element, menu, controller, model )
		GoBack( self, controller )
		return true
	end, function ( element, menu, controller )
		CoD.Menu.SetButtonLabel( menu, Enum[@"hash_3DD78803F918E9D"][@"hash_1805EFA15E9E7E5A"], @"hash_6A4032FB2AAB69F2", nil, nil )
		return true
	end, false )

	FooterContainerFrontendRight:setModel( self.buttonModel, f1_arg0 )
	if CoD.isPC then
		FooterContainerFrontendRight.id = "FooterContainerFrontendRight"
	end

	SafeAreaContainerLobbyServerBrwoserOverlay.id = "SafeAreaContainerLobbyServerBrwoserOverlay"

	self:processEvent( {
		name = "menu_loaded",
		controller = f1_arg0
	} )

	LUI.OverrideFunction_CallOriginalSecond( self, "close", self.__onClose )

	if PostLoadFunc then
		PostLoadFunc( self, f1_arg0 )
	end

	local f1_local19 = self

	CoD.EnhPrintInfo("Called", "Shield's Lobby Server Browser")

	SizeToSafeArea(SafeAreaContainerLobbyServerBrwoserOverlay, f1_arg0)

	return self
end

CoD.ShieldLobbyServerBrowserOverlay.__onClose = function ( f8_arg0 )
	f8_arg0.Background:close()
	f8_arg0.FooterContainerFrontendRight:close()
	f8_arg0.SafeAreaContainerLobbyServerBrwoserOverlay:close()
end

---------------------------

--[[
	The body of the browser, 1744 by 800.
	Left, 1060 wide: the title with the filter of modes, the names of the columns, and ten rows.
	Right, from 1084, 660 wide: the card of the lobby in focus, under it the search and the refresh, and under those the way to a lobby of one's own.
]]
local CARD_LEFT = 1084
local CARD_RIGHT = 1744
local CARD_IMAGE_HEIGHT = 430
local CARD_BOTTOM = 680
local CARD_TEXT_LEFT = CARD_LEFT + 24
local CARD_TEXT_RIGHT = CARD_RIGHT - 24
local CARD_PLAYERS_LEFT = CARD_LEFT + 416
local LIST_TOP = 86

-- the modes of the filter, as shield_filter_server counts them
local FilterChips = {
	-- all 200 wide: the glow of the button in focus is made for that, on a narrower one it spills far over
	{ label = "ALL", value = 0, left = 236, right = 436, color = { r = 1, g = 1, b = 1 } },
	{ label = "MP", value = 1, left = 444, right = 644, color = LobbyModeColors.mp },
	{ label = "ZM", value = 2, left = 652, right = 852, color = LobbyModeColors.zm },
	{ label = "BLACKOUT", value = 3, left = 860, right = 1060, color = LobbyModeColors.wz }
}

-- a button of the game with its own words, never locked
local function NewBrowserButton( self, menu, controller, label, left, right, top, bottom )
	local button = CoD.DirectorSelectButtonMiniInternal.new( menu, controller, 0, 0, left, right, 0, 0, top, bottom )

	button.MiddleText:setText( label )
	button.MiddleTextFocus:setText( label )

	button:mergeStateConditions( {
		{
			stateName = "Locked",
			condition = function ( menu, element, event )
				return AlwaysFalse()
			end
		}
	} )

	button:linkToElementModel( self, nil, false, function ( model )
		button:setModel( model, controller )
	end )

	return button
end

-- what a button of the browser does when it is clicked
local function OnBrowserButton( menu, controller, button, action )
	menu:AddButtonCallbackFunction( button, controller, Enum[@"luibutton"][@"lui_key_xba_pscross"], "ui_confirm", function ( element, menu, controller, model )
		action()
		return true
	end, function ( element, menu, controller )
		if IsGamepad( controller ) then
			CoD.Menu.SetButtonLabel( menu, Enum[@"luibutton"][@"lui_key_xba_pscross"], @"menu/select", nil, "ui_confirm" )
			return true
		elseif IsMouseOrKeyboard( controller ) then
			CoD.Menu.SetButtonLabel( menu, Enum[@"luibutton"][@"lui_key_xba_pscross"], @"hash_0", nil, "ui_confirm" )
			return false
		else
			return false
		end
	end, false )
end

CoD.ShieldDWGameServerRowList = InheritFrom( LUI.UIElement )
CoD.ShieldDWGameServerRowList.__defaultWidth = 1744
CoD.ShieldDWGameServerRowList.__defaultHeight = 800
CoD.ShieldDWGameServerRowList.new = function ( f1_arg0, f1_arg1, f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	local self = LUI.UIElement.new( f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	self:setClass( CoD.ShieldDWGameServerRowList )
	self.id = "ShieldDWGameServerRowList"
	self.soundSet = "default"
	self.onlyChildrenFocusable = true
	self.anyChildUsesUpdateState = true

	-- everything of the body that is only closed with it
	self.Parts = {}

	local function Add( element )
		self:addElement( element )
		table.insert( self.Parts, element )
		return element
	end

	local Servers = LUI.UIList.new( f1_arg0, f1_arg1, 7, 0, nil, false, false, false, false )
	Servers:setLeftRight( 0, 0, 0, 1060 )
	Servers:setTopBottom( 0, 0, LIST_TOP, LIST_TOP + 654 )

	-- fix weird bug
	Servers:setDataSource( "ShieldDWGameServersEmpty" )

	Servers:setWidgetType( CoD.ShieldGameServerRow )
	Servers:setVerticalCount( 10 )
	Servers:setSpacing( 6 )

	Servers:setAlignment( Enum[@"luialignment"][@"lui_alignment_left"] )
	Servers:setVerticalCounter( CoD.verticalCounter )
	Servers:appendEventHandler( "input_source_changed", function ( f2_arg0, f2_arg1 )
		f2_arg1.menu = f2_arg1.menu or f1_arg0
		CoD.Menu.UpdateButtonShownState( f2_arg0, f1_arg0, f1_arg1, Enum[@"luibutton"][@"lui_key_xba_pscross"] )
	end )

	CoD.Menu.ServerLobbyBrowser = Servers

	-- Asks the client for the lobbies. It answers with the list, or says that the master server gave none.
	-- An older client says nothing then: no word from it after a while is taken for no answer of the server.
	local function AskForLobbies()
		local answers = LobbyAnswers

		CoD.ShowServerToast("Refreshing lobbies...")
		Engine[@"exec"](Engine[@"getprimarycontroller"](), "getservers")

		self:addElement( LUI.UITimer.newElementTimer( 6000, true, function ()
			if LobbyAnswers == answers then
				LobbyFailedModel():set( 1 )

				-- rows of an answer of before stay: only the wait for a first one ends
				local count = LobbyCountModel():get()
				if count == nil or count < 0 then
					LobbyCountModel():set( 0 )
				end
			end
		end ) )
	end

	LobbyFailedModel():set( 0 )
	AskForLobbies()

	-- the rows again, by what the filter and the search are now
	local function ReloadRows()
		CoD.Shield.RefillLobbyRows( Servers )
	end

	---------------------------
	-- over the rows: the title, how many lobbies, and the filter of modes

	local Title = Add( NewText( 0, 228, -4, 32, "notosans_bold" ) )
	Title:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )
	Title:setText( "LOBBIES" )

	-- the count under the title: the filter takes the room beside it
	local CountText = Add( NewText( 2, 228, 30, 14, "ttmussels_regular" ) )
	CountText:setRGB( 0.55, 0.55, 0.55 )
	CountText:setLetterSpacing( 2 )

	local CountModel = LobbyCountModel()
	CountModel:set( -1 )

	local FailedModel = LobbyFailedModel()

	local function ShowCount()
		local count = CountModel:get()
		if FailedModel:get() == 1 then
			CountText:setText( "NO ANSWER" )
		elseif count == nil or count < 0 then
			CountText:setText( "SEARCHING" )
		elseif count == 0 then
			CountText:setText( "NONE OPEN" )
		else
			CountText:setText( count .. " OPEN" )
		end
	end

	CountText:subscribeToModel( CountModel, ShowCount )
	CountText:subscribeToModel( FailedModel, ShowCount )

	self.FilterChips = {}

	local function MarkFilterChips( filter )
		for _, chip in ipairs( self.FilterChips ) do
			if chip.FilterValue == filter then
				chip.ActiveMark:setAlpha( 1 )
			else
				chip.ActiveMark:setAlpha( 0 )
			end
		end
	end

	for _, info in ipairs( FilterChips ) do
		local Chip = NewBrowserButton( self, f1_arg0, f1_arg1, info.label, info.left, info.right, 0, 44 )
		Chip.FilterValue = info.value

		-- the line under the mode the list is on
		local ActiveMark = LUI.UIImage.new( 0, 1, 0, 0, 1, 1, -3, 0 )
		ActiveMark:setRGB( info.color.r, info.color.g, info.color.b )
		ActiveMark:setAlpha( 0 )
		Chip:addElement( ActiveMark )
		Chip.ActiveMark = ActiveMark

		self:addElement( Chip )
		-- the menu finds what can take the focus as parent[id]: the id has to be the name it is kept under
		Chip.id = "FilterChip" .. info.value
		self[Chip.id] = Chip
		table.insert( self.FilterChips, Chip )

		OnBrowserButton( f1_arg0, f1_arg1, Chip, function ()
			PlaySoundAlias( "uin_paint_image_flip_toggle" )
			Engine[@"setdvar"]( "shield_filter_server", info.value )
			MarkFilterChips( info.value )
			ReloadRows()
		end )
	end

	MarkFilterChips( Engine[@"getdvarint"]( @"shield_filter_server" ) )

	-- the names of the columns, where the rows have them
	Add( NewCaption( 127, 560, 56, "LOBBY" ) )
	Add( NewCaption( 590, 880, 56, "HOST" ) )
	Add( NewCaption( 900, 1040, 56, "PLAYERS", Enum[@"luialignment"][@"lui_alignment_right"] ) )
	Add( NewBox( 0, 1060, 78, 79, 1, 1, 1, 0.12 ) )

	---------------------------
	-- the card of the lobby in focus: its picture, 660 by 430, which cuts what of the picture is over

	local MapClip = LUI.UIElement.new( 0, 0, CARD_LEFT, CARD_RIGHT, 0, 0, 0, CARD_IMAGE_HEIGHT )
	MapClip:setUseStencil( true )
	Add( MapClip )

	local MapImage = LUI.UIImage.new( 0, 1, 0, 0, 0, 1, 0, 0 )
	MapImage:setImage( RegisterImage( @"uie_ui_menu_emblem_grid" ) )
	MapImage:setMaterial( LUI.UIImage.GetCachedMaterial( @"hash_1A02C44161370F6D" ) )
	MapImage:setShaderVector( 0, 0, 0, 0, 0 )
	MapImage:setShaderVector( 1, 1, 1, 0, 0 )
	MapImage:setShaderVector( 2, 0, 0, 0, 0 )
	MapClip:addElement( MapImage )
	self.MapImage = MapImage

	-- the picture goes dark to its lower end, where the name of the map is written on it
	AddBottomFade( MapClip, CARD_IMAGE_HEIGHT, 200 )

	-- the line over the card, in the colour of the mode
	local CardAccent = Add( NewBox( CARD_LEFT, CARD_RIGHT, 0, 4, 1, 1, 1, 0.25 ) )

	local CardPill = Add( NewBox( CARD_TEXT_LEFT, CARD_TEXT_LEFT + 52, 318, 344, 1, 1, 1, 0 ) )

	local CardPillText = Add( NewText( CARD_TEXT_LEFT, CARD_TEXT_LEFT + 52, 322, 18, "notosans_bold", Enum[@"luialignment"][@"lui_alignment_center"] ) )
	CardPillText:setRGB( 0.04, 0.04, 0.04 )

	local CardGametype = Add( NewText( CARD_TEXT_LEFT + 64, CARD_TEXT_RIGHT, 320, 22, "ttmussels_regular" ) )
	CardGametype:setRGB( 0.86, 0.86, 0.86 )
	CardGametype:setLetterSpacing( 2 )

	local CardTitle = Add( NewText( CARD_TEXT_LEFT, CARD_TEXT_RIGHT, 354, 48, "notosans_bold" ) )
	CardTitle:setRGB( 1, 1, 1 )
	CardTitle:setText( "Select a lobby" )

	-- under the picture: who hosts it, how many play, and the mods it runs
	Add( NewBox( CARD_LEFT, CARD_RIGHT, CARD_IMAGE_HEIGHT, CARD_BOTTOM, 0, 0, 0, 0.5 ) )

	Add( NewCaption( CARD_TEXT_LEFT, CARD_PLAYERS_LEFT - 20, 450, "HOSTED BY" ) )

	local CardHost = Add( NewText( CARD_TEXT_LEFT, CARD_PLAYERS_LEFT - 20, 472, 30, "notosans_bold" ) )
	CardHost:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )
	CardHost:setText( "-" )

	Add( NewCaption( CARD_PLAYERS_LEFT, CARD_TEXT_RIGHT, 450, "PLAYERS" ) )

	local CardPlayers = Add( NewText( CARD_PLAYERS_LEFT, CARD_TEXT_RIGHT, 471, 32, "0arame_mono_stencil" ) )
	CardPlayers:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )
	CardPlayers:setText( "-" )

	Add( NewBox( CARD_PLAYERS_LEFT, CARD_TEXT_RIGHT, 516, 522, 1, 1, 1, 0.12 ) )
	local CardFill = Add( NewBox( CARD_PLAYERS_LEFT, CARD_PLAYERS_LEFT + 2, 516, 522, 1, 1, 1, 0 ) )

	Add( NewBox( CARD_TEXT_LEFT, CARD_TEXT_RIGHT, 546, 547, 1, 1, 1, 0.1 ) )

	Add( NewCaption( CARD_TEXT_LEFT, CARD_TEXT_RIGHT, 564, "MODS" ) )

	local CardMods = Add( NewText( CARD_TEXT_LEFT, CARD_TEXT_RIGHT, 586, 22, "ttmussels_regular" ) )
	CardMods:setRGB( 0.55, 0.55, 0.55 )
	CardMods:setText( "-" )

	Add( NewCaption( CARD_TEXT_LEFT, CARD_TEXT_RIGHT, 646, "CLICK A LOBBY TO JOIN IT", Enum[@"luialignment"][@"lui_alignment_right"] ) )

	-- the thin frame of the game around the card
	local CardFrame = LUI.UIImage.new( 0, 0, CARD_LEFT - 1, CARD_RIGHT + 1, 0, 0, -1, CARD_BOTTOM + 1 )
	CardFrame:setAlpha( 0.12 )
	CardFrame:setImage( RegisterImage( @"uie_ui_menu_store_common_frame" ) )
	CardFrame:setMaterial( LUI.UIImage.GetCachedMaterial( @"uie_nineslice_add" ) )
	CardFrame:setShaderVector( 0, 0, 0, 0, 0 )
	CardFrame:setupNineSliceShader( 12, 12 )
	Add( CardFrame )

	-- the card tells of that row
	local function ShowLobby( row )
		local mode = row.LobbyMode or "mp"
		local color = LobbyModeColors[mode] or LobbyModeColors.mp

		-- arena, hopefully, for a lobby with no picture
		SetPreviewImage( MapImage, row.CurrentMapImage or @"uie_ui_menu_survey_arena", CARD_RIGHT - CARD_LEFT, CARD_IMAGE_HEIGHT )

		-- the new picture comes up out of the dark
		MapImage:completeAnimation()
		MapImage:setAlpha( 0.35 )
		MapImage:beginAnimation( 180 )
		MapImage:setAlpha( 1 )

		CardAccent:setRGB( color.r, color.g, color.b )
		CardAccent:setAlpha( 1 )
		CardPill:setRGB( color.r, color.g, color.b )
		CardPill:setAlpha( 1 )
		CardPillText:setText( ToUpper( mode ) )

		if row.CurrentGameTypeTranslated ~= nil and row.CurrentGameTypeTranslated ~= "" then
			CardGametype:setText( ToUpper( row.CurrentGameTypeTranslated ) )
		else
			CardGametype:setText( LobbyModeNames[mode] or "" )
		end

		CardTitle:setText( row.CurrentMapTranslated or "Lobby" )
		CardHost:setText( row.HostedUser or "-" )
		CardPlayers:setText( PlayersLabel( row.Players, row.MaxPlayers ) )
		SetFillBar( CardFill, CARD_PLAYERS_LEFT, CARD_TEXT_RIGHT - CARD_PLAYERS_LEFT, row.Players, row.MaxPlayers )

		if row.HostMods ~= nil and row.HostMods ~= "" then
			CardMods:setRGB( 1, 0.85, 0.2 )
			CardMods:setText( row.HostMods )
		else
			CardMods:setRGB( 0.55, 0.55, 0.55 )
			CardMods:setText( "None" )
		end
	end

	---------------------------
	-- under the card: the search and the refresh

	local SearchServer = CoD.Shield_NameEditBox.new( f1_arg0, f1_arg1, 0, 0, CARD_LEFT, CARD_LEFT + 400, 0, 0, 692, 740 )
	SearchServer:linkToElementModel( self, nil, false, function ( model )
		SearchServer:setModel( model, f1_arg1 )
	end )
	SearchServer.TextBox:setLeftRight( 0, 0, 100, 385 )
	SearchServer.RankHighlight:setText( "Search:" )
	self:addElement( SearchServer )
	self.SearchServer = SearchServer

	local SearchServerModel = Engine[@"getmodel"]( Engine[@"getmodelforcontroller"]( f1_arg1 ), "Shield_Search_Server" )

	if SearchServerModel == nil then
		SearchServerModel = Engine[@"createmodel"]( Engine[@"getmodelforcontroller"]( f1_arg1 ), "Shield_Search_Server" )
	end

	if SearchServerModel:get() == nil then
		SearchServerModel:set("")
	end

	SearchServer.__editControlMaxChar = 16
	SearchServer.__editControlisInteger = 1
	SearchServer.__editControlMin = 0
	SearchServer.__editControlMax = 1000

	CoD.PCUtility.SetupEditControlWithModel( SearchServer, f1_arg1, f1_arg0, SearchServerModel, function ( f331_arg0, f331_arg1, f331_arg2 )
		if not f331_arg2.canceled and f331_arg2.name == "textbox_editdone" then
			local ServerData = f331_arg0:get()

			CoD.EnhPrintInfo("Server Search", ServerData)
			PlaySoundAlias( "uin_paint_image_flip_toggle" )

			Engine[@"setdvar"]( "shield_search_server", ServerData )
		else
			f331_arg0:set("") -- reset it
			Engine[@"setdvar"]( "shield_search_server", "" )
		end

		ReloadRows()
	end )

	SearchServer.id = "SearchServer"

	local RefreshServersButton = NewBrowserButton( self, f1_arg0, f1_arg1, "REFRESH", CARD_LEFT + 412, CARD_RIGHT, 692, 740 )
	self:addElement( RefreshServersButton )
	self.RefreshServersButton = RefreshServersButton
	RefreshServersButton.id = "RefreshServersButton"

	OnBrowserButton( f1_arg0, f1_arg1, RefreshServersButton, function ()
		PlaySoundAlias( "uin_paint_image_flip_toggle" )
		CoD.EnhPrintInfo("RefreshServersButton")

		AskForLobbies()
	end )

	-- under them: a lobby of one's own, see HostLobby.lua
	local HostLobbyButton = NewBrowserButton( self, f1_arg0, f1_arg1, "HOST LOBBY", CARD_LEFT, CARD_RIGHT, 752, 800 )
	self:addElement( HostLobbyButton )
	self.HostLobbyButton = HostLobbyButton
	HostLobbyButton.id = "HostLobbyButton"

	OnBrowserButton( f1_arg0, f1_arg1, HostLobbyButton, function ()
		PlaySoundAlias( "uin_paint_image_flip_toggle" )
		OpenOverlay( f1_arg0, "ShieldHostLobbyOverlay", f1_arg1 )
	end )

	---------------------------
	-- the rows

	Servers:registerEventHandler( "list_item_gain_focus", function ( element, event )
		ShowLobby( element )
		return nil
	end )

	Servers:registerEventHandler( "gain_focus", function ( element, event )
		local f5_local0 = nil
		if element.gainFocus then
			f5_local0 = element:gainFocus( event )
		elseif element.super.gainFocus then
			f5_local0 = element.super:gainFocus( event )
		end
		CoD.Menu.UpdateButtonShownState( element, f1_arg0, f1_arg1, Enum[@"luibutton"][@"lui_key_xba_pscross"] )
		return f5_local0
	end )

	-- element is the current datasource being clicked..
	f1_arg0:AddButtonCallbackFunction( Servers, f1_arg1, Enum[@"luibutton"][@"lui_key_xba_pscross"], "ui_confirm", function ( element, menu, controller, model )
		if IsGamepad( controller ) or IsMouseOrKeyboard( controller ) then
			PlaySoundAlias("uin_toggle_generic")
			CoD.EnhPrintInfo("Server Game Connect", element.CurrentLobbyID)
			CoD.ShowServerToast("Joining to Lobby " .. element.CurrentLobbyID .. "...")
			Engine[@"exec"](Engine[@"getprimarycontroller"](), "joinserver " .. element.CurrentLobbyID)
			return true
		end
	end, function ( element, menu, controller )
		if IsGamepad( controller ) then
			CoD.Menu.SetButtonLabel( menu, Enum[@"luibutton"][@"lui_key_xba_pscross"], @"menu/join", nil, "ui_confirm" )
			return true
		elseif IsMouseOrKeyboard( controller ) then
			CoD.Menu.SetButtonLabel( menu, Enum[@"luibutton"][@"lui_key_xba_pscross"], @"hash_0", nil, "ui_confirm" )
			return false
		else
			return false
		end
	end, false )

	self:addElement( Servers )
	self.Servers = Servers

	-- in the place of the rows while there is none
	local EmptyTitle = Add( NewText( 0, 1060, LIST_TOP + 250, 30, "notosans_bold", Enum[@"luialignment"][@"lui_alignment_center"] ) )
	EmptyTitle:setRGB( 0.75, 0.75, 0.75 )

	local EmptyText = Add( NewText( 0, 1060, LIST_TOP + 292, 20, "ttmussels_regular", Enum[@"luialignment"][@"lui_alignment_center"] ) )
	EmptyText:setRGB( 0.5, 0.5, 0.5 )

	local function ShowEmpty()
		local count = CountModel:get()
		if FailedModel:get() == 1 and ( count == nil or count <= 0 ) then
			EmptyTitle:setText( "The master server does not answer" )
			EmptyText:setText( "No lobbies can be listed until it does. Refresh in a moment." )
			EmptyTitle:setAlpha( 1 )
			EmptyText:setAlpha( 1 )
		elseif count == nil or count < 0 then
			EmptyTitle:setText( "Looking for lobbies..." )
			EmptyText:setText( "" )
			EmptyTitle:setAlpha( 1 )
			EmptyText:setAlpha( 1 )
		elseif count == 0 then
			EmptyTitle:setText( "No lobbies found" )
			EmptyText:setText( "Host a public match, change the filter, or refresh in a moment." )
			EmptyTitle:setAlpha( 1 )
			EmptyText:setAlpha( 1 )
		else
			EmptyTitle:setAlpha( 0 )
			EmptyText:setAlpha( 0 )
		end
	end

	EmptyText:subscribeToModel( CountModel, ShowEmpty )
	EmptyText:subscribeToModel( FailedModel, ShowEmpty )

	Servers.id = "Servers"
	LUI.OverrideFunction_CallOriginalSecond( self, "close", self.__onClose )

	if PostLoadFunc then
		PostLoadFunc( self, f1_arg1, f1_arg0 )
	end

	return self
end

CoD.ShieldDWGameServerRowList.__onClose = function ( f9_arg0 )
	for _, element in ipairs( f9_arg0.Parts ) do
		element:close()
	end
	for _, chip in ipairs( f9_arg0.FilterChips ) do
		chip:close()
	end
	f9_arg0.MapImage:close()
	f9_arg0.SearchServer:close()
	f9_arg0.RefreshServersButton:close()
	f9_arg0.HostLobbyButton:close()
	f9_arg0.Servers:close()
end

---------------------------

--[[
	A row, 1060 by 60: the picture of the map, the map over its mode and gametype,
	the host over the mods, and the players over a bar of how full the lobby is.
]]
local ROW_HEIGHT = 60
local ROW_THUMB_WIDTH = 107
local ROW_TEXT_LEFT = 127
local ROW_BAR_LEFT = 920
local ROW_BAR_WIDTH = 120

-- what of a row changes with the focus: nothing here has a colour of its own, a row keeps that of its mode
local RowFocusParts = {
	{ "BlackBar", function ( element, focus ) element:setAlpha( focus and 0.1 or 0.05 ) end },
	{ "Tint", function ( element, focus ) element:setAlpha( focus and 0.16 or 0 ) end },
	{ "FocusFrame", function ( element, focus ) element:setAlpha( focus and 1 or 0 ) end },
	{ "ThumbDim", function ( element, focus ) element:setAlpha( focus and 0 or 0.35 ) end },
	{ "Accent", function ( element, focus ) element:setLeftRight( 0, 0, 0, focus and 7 or 4 ) end }
}

-- a clip of a row that ends in the focus or out of it, at once or over some time coming from the other
local function RowClip( parts, focus, duration )
	return function ( self, event )
		self:__resetProperties()
		self:setupElementClipCounter( #parts )

		for _, part in ipairs( parts ) do
			local element = self[part[1]]

			element:completeAnimation()

			if duration then
				part[2]( element, not focus )
				element:beginAnimation( duration )
				part[2]( element, focus )
				element:registerEventHandler( "interrupted_keyframe", self.clipInterrupted )
				element:registerEventHandler( "transition_complete_keyframe", self.clipFinished )
			else
				part[2]( element, focus )
				self.clipFinished( element )
			end
		end
	end
end

CoD.ShieldGameServerRow = InheritFrom( LUI.UIElement )
CoD.ShieldGameServerRow.__defaultWidth = 1060
CoD.ShieldGameServerRow.__defaultHeight = ROW_HEIGHT
CoD.ShieldGameServerRow.new = function ( f1_arg0, f1_arg1, f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	local self = LUI.UIElement.new( f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	self:setClass( CoD.ShieldGameServerRow )
	self.id = "ShieldGameServerRow"
	self.soundSet = "default"
	f1_arg0:addElementToPendingUpdateStateList( self )

	self.Parts = {}

	local function Add( element )
		self:addElement( element )
		table.insert( self.Parts, element )
		return element
	end

	local BlackBar = LUI.UIImage.new( 0, 1, 0, 0, 0, 1, 0, 0 )
	BlackBar:setRGB( 1, 1, 1 )
	BlackBar:setAlpha( 0.05 )
	Add( BlackBar )
	self.BlackBar = BlackBar

	-- the colour of the mode over the row in focus
	local Tint = LUI.UIImage.new( 0, 1, 0, 0, 0, 1, 0, 0 )
	Tint:setAlpha( 0 )
	Add( Tint )
	self.Tint = Tint

	-- the picture of the map, cut to its box
	local ThumbClip = LUI.UIElement.new( 0, 0, 0, ROW_THUMB_WIDTH, 0, 0, 0, ROW_HEIGHT )
	ThumbClip:setUseStencil( true )
	Add( ThumbClip )

	local Thumb = LUI.UIImage.new( 0, 1, 0, 0, 0, 1, 0, 0 )
	Thumb:setAlpha( 0 )
	ThumbClip:addElement( Thumb )
	self.Thumb = Thumb

	-- it is a little dark until the row is in focus. Of the row, not of the box of the picture:
	-- a part that a clip changes tells its parent when it is done, and only the row counts those
	local ThumbDim = Add( NewBox( 0, ROW_THUMB_WIDTH, 0, ROW_HEIGHT, 0, 0, 0, 0.35 ) )
	self.ThumbDim = ThumbDim

	-- the bar at the start of the row
	local Accent = LUI.UIImage.new( 0, 0, 0, 4, 0, 1, 0, 0 )
	Add( Accent )
	self.Accent = Accent

	local ServerName = Add( NewText( ROW_TEXT_LEFT, 570, 7, 24, "notosans_bold" ) )
	ServerName:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )
	self.ServerName = ServerName

	-- MP, ZM or WZ, dark on the colour of the mode
	local Pill = Add( NewBox( ROW_TEXT_LEFT, ROW_TEXT_LEFT + 36, 36, 54, 1, 1, 1, 1 ) )

	local PillText = Add( NewText( ROW_TEXT_LEFT, ROW_TEXT_LEFT + 36, 38, 14, "notosans_bold", Enum[@"luialignment"][@"lui_alignment_center"] ) )
	PillText:setRGB( 0.04, 0.04, 0.04 )

	local Gametype = Add( NewText( ROW_TEXT_LEFT + 46, 570, 36, 18, "ttmussels_regular" ) )
	Gametype:setRGB( 0.68, 0.68, 0.68 )
	Gametype:setLetterSpacing( 1 )

	local HostedBy = Add( NewText( 590, 890, 8, 22, "ttmussels_regular" ) )
	HostedBy:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )

	local HostMods = Add( NewText( 590, 890, 37, 16, "ttmussels_regular" ) )

	local ClientCount = Add( NewText( 900, 1040, 9, 24, "0arame_mono_stencil", Enum[@"luialignment"][@"lui_alignment_right"] ) )
	ClientCount:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )

	Add( NewBox( ROW_BAR_LEFT, ROW_BAR_LEFT + ROW_BAR_WIDTH, 43, 47, 1, 1, 1, 0.12 ) )
	local Fill = Add( NewBox( ROW_BAR_LEFT, ROW_BAR_LEFT + 2, 43, 47, 1, 1, 1, 0 ) )

	-- the frame of the game around the row in focus, in the colour of the mode
	local FocusFrame = LUI.UIImage.new( 0, 1, -4, 4, 0, 1, -4, 4 )
	FocusFrame:setAlpha( 0 )
	FocusFrame:setImage( RegisterImage( @"uie_ui_menu_store_focus_frame" ) )
	FocusFrame:setMaterial( LUI.UIImage.GetCachedMaterial( @"uie_nineslice_add" ) )
	FocusFrame:setShaderVector( 0, 0, 0, 0, 0 )
	FocusFrame:setupNineSliceShader( 10, 10 )
	Add( FocusFrame )
	self.FocusFrame = FocusFrame

	-- everything of the row is read when its lobby is set: the list makes the lobby whole before it gives it
	ServerName:linkToElementModel( self, "ServerName", true, function ( model )
		if model:get() == nil then
			return
		end

		local Lobby = DescribeLobby( CoD.ModelUtility.GetSelfModelPathValue( self, "Mode" ), CoD.ModelUtility.GetSelfModelPathValue( self, "MapStatus" ),
			CoD.ModelUtility.GetSelfModelPathValue( self, "GameTypeStatus" ) )
		local color = LobbyModeColors[Lobby.mode] or LobbyModeColors.mp

		-- what the card and the join read of the row in focus
		self.CurrentMapTranslated = Lobby.mapName
		self.CurrentGameTypeTranslated = Lobby.gametypeName
		self.CurrentMapImage = Lobby.image
		self.CurrentSessionMode = ToUpper( Lobby.mode )
		self.LobbyMode = Lobby.mode
		self.CurrentLobbyID = CoD.ModelUtility.GetSelfModelPathValue( self, "ConnectionIP" )
		self.HostedUser = CoD.ModelUtility.GetSelfModelPathValue( self, "HostedBy" ) or ""
		self.HostMods = CoD.ModelUtility.GetSelfModelPathValue( self, "Mods" ) or ""
		self.Players = CoD.ModelUtility.GetSelfModelPathValue( self, "Players" ) or 0
		self.MaxPlayers = CoD.ModelUtility.GetSelfModelPathValue( self, "MaxPlayers" ) or 0
		self.CurrentClientCount = CoD.ModelUtility.GetSelfModelPathValue( self, "ClientCount" )

		Accent:setRGB( color.r, color.g, color.b )
		Tint:setRGB( color.r, color.g, color.b )
		FocusFrame:setRGB( color.r, color.g, color.b )
		Pill:setRGB( color.r, color.g, color.b )
		PillText:setText( Lobby.tag )

		SetPreviewImage( Thumb, Lobby.image, ROW_THUMB_WIDTH, ROW_HEIGHT )
		Thumb:setAlpha( 1 )

		ServerName:setText( Lobby.mapName )

		if Lobby.gametypeName ~= "" then
			Gametype:setText( ToUpper( Lobby.gametypeName ) )
		else
			Gametype:setText( LobbyModeNames[Lobby.mode] or "" )
		end

		HostedBy:setText( self.HostedUser )

		if self.HostMods ~= "" then
			HostMods:setRGB( 1, 0.85, 0.2 )
			HostMods:setText( "Mods: " .. ShortenText( self.HostMods, 36 ) )
		else
			HostMods:setRGB( 0.42, 0.42, 0.42 )
			HostMods:setText( "No mods" )
		end

		ClientCount:setText( self.CurrentClientCount or "" )

		-- red when nobody else gets in
		if self.MaxPlayers > 0 and self.Players >= self.MaxPlayers then
			ClientCount:setRGB( 1, 0.4, 0.3 )
		else
			ClientCount:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )
		end

		SetFillBar( Fill, ROW_BAR_LEFT, ROW_BAR_WIDTH, self.Players, self.MaxPlayers )
	end )

	LUI.OverrideFunction_CallOriginalSecond( self, "close", self.__onClose )

	if PostLoadFunc then
		PostLoadFunc( self, f1_arg1, f1_arg0 )
	end

	return self
end

CoD.ShieldGameServerRow.__resetProperties = function ( f7_arg0 )
	for _, part in ipairs( RowFocusParts ) do
		local element = f7_arg0[part[1]]
		element:completeAnimation()
		part[2]( element, false )
	end
end

CoD.ShieldGameServerRow.__clipsPerState = {
	DefaultState = {
		DefaultClip = RowClip( RowFocusParts, false ),
		Focus = RowClip( RowFocusParts, true ),
		GainFocus = RowClip( RowFocusParts, true, 120 ),
		LoseFocus = RowClip( RowFocusParts, false, 120 )
	}
}

CoD.ShieldGameServerRow.__onClose = function ( f10_arg0 )
	f10_arg0.Thumb:close()
	for _, element in ipairs( f10_arg0.Parts ) do
		element:close()
	end
end

---------------------------

-- Safe for Server
CoD.Shield_SafeAreaContainer_LobbyServerBrwoserOverlay = InheritFrom( LUI.UIElement )
CoD.Shield_SafeAreaContainer_LobbyServerBrwoserOverlay.__defaultWidth = 1920
CoD.Shield_SafeAreaContainer_LobbyServerBrwoserOverlay.__defaultHeight = 1080
CoD.Shield_SafeAreaContainer_LobbyServerBrwoserOverlay.new = function ( f1_arg0, f1_arg1, f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	local self = LUI.UIElement.new( f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	self:setClass( CoD.Shield_SafeAreaContainer_LobbyServerBrwoserOverlay )
	self.id = "Shield_SafeAreaContainer_LobbyServerBrwoserOverlay"
	self.soundSet = "none"
	self.onlyChildrenFocusable = true
	self.anyChildUsesUpdateState = true

	local TabBacking = CoD.CommonTabBarBacking.new( f1_arg0, f1_arg1, -0.1, 1.1, 0, 0, 0, 0, 52, 89 )
	TabBacking.TabBackingBlur:setAlpha( 0 )
	self:addElement( TabBacking )
	self.TabBacking = TabBacking

	local CommonHeader = CoD.CommonHeader.new( f1_arg0, f1_arg1, 0, 1, 0, 0, 0, 0, 0, 67 )
	CommonHeader.subtitle.StageTitle:setText("^2Lobby Browser")
	CommonHeader.subtitle.subtitle:setText("^3Open Lobbies")
	self:addElement( CommonHeader )
	self.CommonHeader = CommonHeader

	local FETabBar = CoD.DirectorSelect_Tabbar_Center.new( f1_arg0, f1_arg1, 0.5, 0.5, -100.5, 100.5, 0, 0, 52.5, 113.5 )
	FETabBar:mergeStateConditions( {
		{
			stateName = "DimBumperIcons",
			condition = function ( menu, element, event )
				return IsLobbyNetworkModeLAN()
			end
		}
	} )
	local f1_local4 = FETabBar
	local HeaderStripe = FETabBar.subscribeToModel
	local f1_local6 = Engine[@"hash_78DF2E5447F384B9"]()
	HeaderStripe( f1_local4, f1_local6["lobbyRoot.lobbyNav"], function ( f3_arg0 )
		f1_arg0:updateElementState( FETabBar, {
			name = "model_validation",
			menu = f1_arg0,
			controller = f1_arg1,
			modelValue = f3_arg0:get(),
			modelName = "lobbyRoot.lobbyNav"
		} )
	end, false )
	FETabBar.Tabs.grid:setHorizontalCount( 5 )
	FETabBar.Tabs.grid:setDataSource( "ShieldServerBrowserFilters" )
	FETabBar:registerEventHandler( "list_active_changed", function ( element, event )
		local f4_local0 = nil
		CoD.LobbyUtility.LobbyLANServerBrowserSetMainModeFilter( self, element, f1_arg1 )
		return f4_local0
	end )
	self:addElement( FETabBar )
	self.FETabBar = FETabBar

	HeaderStripe = CoD.header_container_frontend.new( f1_arg0, f1_arg1, 0, 1, 0, 0, 0, 0, 0, 42 )
	self:addElement( HeaderStripe )
	self.HeaderStripe = HeaderStripe

	-- the body: from 88 to 1832 of the 1920 across, from 140 to 940 down
	local ShieldDWGameServerDetails = CoD.ShieldDWGameServerRowList.new( f1_arg0, f1_arg1, 0.5, 0.5, -872, 872, 0, 0, 140, 940 )
	self:addElement( ShieldDWGameServerDetails )
	self.ShieldDWGameServerDetails = ShieldDWGameServerDetails

	ShieldDWGameServerDetails.id = "ShieldDWGameServerDetails"
	FETabBar.id = "FETabBar"

	LUI.OverrideFunction_CallOriginalSecond( self, "close", self.__onClose )

	if PostLoadFunc then
		PostLoadFunc( self, f1_arg1, f1_arg0 )
	end

	return self
end

CoD.Shield_SafeAreaContainer_LobbyServerBrwoserOverlay.__onClose = function ( f5_arg0 )
	f5_arg0.TabBacking:close()
	f5_arg0.CommonHeader:close()
	f5_arg0.FETabBar:close()
	f5_arg0.HeaderStripe:close()
	f5_arg0.ShieldDWGameServerDetails:close()
end

---------------------------

-- what the browser is drawn with, for the menu that hosts a lobby: HostLobby.lua
CoD.Shield.BrowserUI = {
	NewText = NewText,
	NewCaption = NewCaption,
	NewBox = NewBox,
	NewBrowserButton = NewBrowserButton,
	OnBrowserButton = OnBrowserButton,
	SetPreviewImage = SetPreviewImage,
	AddBottomFade = AddBottomFade,
	ShortenText = ShortenText,
	IsBlankText = IsBlankText,
	FocusClip = RowClip,
	ModeColors = LobbyModeColors
}
