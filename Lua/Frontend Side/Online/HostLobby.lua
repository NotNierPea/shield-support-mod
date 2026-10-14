--[[
		.\hksc.exe ".\Lua\HostLobby.Lua" -o "C:\Program Files (x86)\Call of Duty Black Ops 4\project-bo4\mods\T8ShieldSupport\Lua\HostLobby.luac"
]]

---------------------------

CoD.ShieldInitLuaFile()

---------------------------

--[[
	The menu behind HOST LOBBY of the lobby browser: a mode, a kind of lobby, and what it plays, on one screen.
	The client walks the lobby menus of the game to it, see "hostlobby" in quickmap.cpp.
	It is drawn with the parts of the browser, CoD.Shield.BrowserUI of LobbyBrowser.lua: they are only read when a menu is made.
]]

-- the modes a lobby can be hosted in, and the kind each starts on
local HostModes = {
	{ key = "mp", label = "MULTIPLAYER", kind = 1 },
	{ key = "zm", label = "ZOMBIES", kind = 3 },
	{ key = "wz", label = "BLACKOUT", kind = 1 }
}

-- the kinds of lobby, by the last word of their menu: "director_online_<mode>_<key>". A hint ends in what the master
-- server does with such a lobby: only a public match is in the lobby browser, the others are joined by friends or by an invite.
local HostKinds = {
	{
		key = "custom",
		label = "CUSTOM GAME",
		name = "Custom Game",
		playlist = false,
		hint = "Your map and game mode, started by you. ^3Not in the lobby browser: only your friends can join it, or players you invite."
	},
	{
		key = "public",
		label = "PUBLIC MATCH",
		name = "Public Match",
		playlist = true,
		hint = "A playlist runs the lobby: maps, game modes and the countdown are its own. ^3The only kind in the lobby browser: anyone joins at once."
	},
	{
		key = "private",
		label = "PRIVATE MATCH",
		name = "Private Match",
		playlist = true,
		only = "zm",
		hint = "The rules of a playlist, started by you. ^3Not in the lobby browser: only your friends can join it, or players you invite."
	}
}

-- the gametype a custom game starts on
local HostDefaultGametypes = {
	mp = "tdm",
	zm = "zclassic",
	wz = "warzone_solo"
}

-- the maps of blackout have no name in the table of maps
local HostBlackoutMaps = {
	wz_open_skyscrapers = "Blackout",
	wz_open_skyscrapers_alt = "Blackout (Alternate)",
	wz_escape = "Alcatraz",
	wz_escape_alt = "Alcatraz (Night)"
}

-- what is picked, and the rows of the two lists: kept while the game runs, so the menu opens on the last pick
local Host = {
	mode = "mp",
	kind = 1,
	primary = "",
	map = "",
	primaryRows = {},
	mapRows = {}
}

-- a row knows by these whether it is the one picked
local function HostModel( name )
	return Engine[@"createmodel"]( Engine[@"getglobalmodel"](), "ShieldHostLobby." .. name )
end

local function SessionModeOf( mode )
	if mode == "zm" then
		return Enum[@"emodes"][@"mode_zombies"]
	elseif mode == "wz" then
		return Enum[@"emodes"][@"mode_warzone"]
	end
	return Enum[@"emodes"][@"mode_multiplayer"]
end

local function MainModeOf( mode )
	if mode == "zm" then
		return Enum[@"lobbymainmode"][@"lobby_mainmode_zm"]
	elseif mode == "wz" then
		return Enum[@"lobbymainmode"][@"lobby_mainmode_wz"]
	end
	return Enum[@"lobbymainmode"][@"lobby_mainmode_mp"]
end

-- the words of a name of the game, or the fallback where it has none
local function LocalizedOr( ref, fallback )
	if ref == nil then
		return fallback
	end

	local text = Engine[@"hash_4F9F1239CFD921FE"]( ref )

	if type( text ) ~= "string" or string.find( text, "%S" ) == nil then
		return fallback
	end

	return text
end

-- a name the console takes as one word
local function IsPlainName( name )
	return type( name ) == "string" and string.len( name ) <= 64 and string.find( name, "^[%w_]+$" ) ~= nil
end

local function RowOf( rows, id )
	for _, row in ipairs( rows ) do
		if row.id == id then
			return row
		end
	end
	return nil
end

-- the pick when it is still among the rows, else the preferred one, else the first
local function KeepOrFirst( rows, id, preferred )
	if RowOf( rows, id ) ~= nil then
		return id
	elseif preferred ~= nil and RowOf( rows, preferred ) ~= nil then
		return preferred
	elseif rows[1] ~= nil then
		return rows[1].id
	end
	return ""
end

local function SortRows( rows )
	table.sort( rows, function ( a, b )
		if a.group ~= b.group then
			return a.group < b.group
		elseif a.sort ~= b.sort then
			return a.sort < b.sort
		end
		return a.id < b.id
	end )
end

local function MapNameOf( map )
	local name = HostBlackoutMaps[map]

	if name == nil then
		name = CoD.MapUtility.GetLocalizedMapValue( map, "mapName", "" )
	end

	if type( name ) ~= "string" or string.find( name, "%S" ) == nil then
		return map
	end

	return name
end

-- the gametypes the playlists of zombies are variants of, as the tabs of its playlists name them
local HostZMModes = {
	[@"zclassic"] = "Classic",
	[@"zstandard"] = "Rush",
	[@"ztrials"] = "Gauntlet",
	[@"ztutorial"] = "Tutorial",
	[@"ztcm"] = "Custom Mutations"
}

-- those without a name here, each told once in the log
local HostZMModesLogged = {}

-- The name of a gametype, "" when the game has none for it. A playlist names its gametypes by their hash and not by
-- their word: the game is asked the way its playlist menus ask, and its table of gametypes after that. A playlist of
-- zombies names a variant of its own: it is named as the tabs of the playlists of zombies name the gametype it is a
-- variant of (info.gametype), CLASSIC, RUSH or GAUNTLET, see CoD.ZombieUtility.GetGametypeTabName.
local function GametypeNameOf( gametype, mode )
	local info = Engine[@"hash_1F2CD89B3C345FD3"]( gametype )
	local name = ""

	-- the names of the tabs of the game, which it keeps as strings of its own
	if mode == "zm" and info ~= nil and info.gametype ~= nil then
		name = HostZMModes[info.gametype] or ""
	end

	-- what was found for each gametype of zombies, told once in the log
	if mode == "zm" and not HostZMModesLogged[gametype] then
		HostZMModesLogged[gametype] = true
		CoD.EnhPrintInfo( "gametype " .. tostring( gametype ) .. ", info " .. tostring( info ) .. ", base " .. tostring( info and info.gametype ) ..
			", name '" .. tostring( name ) .. "'", "Host lobby" )
	end

	local bases = Engine[@"getgametypesbase"]

	if name == "" and mode == "zm" and bases ~= nil and info ~= nil and info.gametype ~= nil then
		for _, base in pairs( bases() or {} ) do
			if base.gametype == info.gametype then
				name = LocalizedOr( base.name, "" )
				break
			end
		end
	end

	if name == "" then
		name = info and LocalizedOr( info.nameRef, "" ) or ""
	end

	if name == "" then
		name = CoD.GameTypeUtility.GetLocalizedGameTypeValue( gametype, "nameRef", "" )
	end

	if ( type( name ) ~= "string" or name == "" ) and info ~= nil and info.gametype ~= nil then
		name = CoD.GameTypeUtility.GetLocalizedGameTypeValue( info.gametype, "nameRef", "" )
	end

	if type( name ) ~= "string" or string.find( name, "%S" ) == nil then
		return type( gametype ) == "string" and ToUpper( gametype ) or ""
	end

	return name
end

-- the gametypes a custom game of a mode can be set to, variants next to what they are a variant of
local function GametypeRows( mode )
	local rows = {}

	for _, info in pairs( CoD.GameTypeUtility.GameTypeTable ) do
		local id = info.name

		if IsPlainName( id ) then
			local group = info.groupName
			local fits = false

			if mode == "zm" then
				fits = group == "zclassic"
			elseif mode == "wz" then
				fits = group == "wzstandard"
			else
				-- what the mod lists in a custom game of multiplayer, see MultiplayerExtraGamemodes.lua
				fits = group ~= "zclassic" and group ~= "wzstandard" and not CoD.IsBadGameMode_MP( info.baseGameType )
			end

			if fits then
				table.insert( rows, {
					id = id,
					name = LocalizedOr( info.nameRef, ToUpper( id ) ),
					sub = id,
					kind = "primary",
					group = CoD.GameTypeUtility.GetGameTypeValue( info.baseGameType or id, "uniqueID", -1 ),
					sort = info.uniqueID or 0,
					about = LocalizedOr( info.descriptionRef, "" )
				} )
			end
		end
	end

	SortRows( rows )

	return rows
end

-- the maps of a mode, in the order of the game
local function MapRows( mode )
	local rows = {}
	local seen = {}
	local sessionMode = SessionModeOf( mode )

	for _, info in pairs( CoD.MapUtility.MapsTable ) do
		-- a lobby is given this name when the map has it, as SetMap of the game does
		local id = info[@"hash_3E2D141CB22F2813"]

		if type( id ) ~= "string" or id == "" then
			id = info.mapToLoad
		end

		-- the maps the game keeps out of its own lists have no pack
		local listed = mode == "wz" or ( info.dlc_pack ~= nil and info.dlc_pack > -1 )

		if info.session_mode == sessionMode and listed and IsPlainName( id ) and not seen[id] then
			seen[id] = true

			table.insert( rows, {
				id = id,
				name = HostBlackoutMaps[id] or LocalizedOr( info.mapName, id ),
				sub = id,
				kind = "map",
				image = info.previewImage,
				group = 0,
				sort = info.uniqueID or info.unique_id or 0,
				exec = info[@"hash_B514EC7141EE89B"]
			} )
		end
	end

	SortRows( rows )

	return rows
end

-- a picture the game can draw, and not one of its empty ones
local function IsPicture( image )
	return image ~= nil and image ~= "" and image ~= @"hash_0" and image ~= @"blacktransparent"
end

-- the picture of a playlist: the one zombies shows beside it, the one behind its card in the menus of the game, else its icon
local function PlaylistImageOf( entry )
	if IsPicture( entry.imageTileSideInfo ) then
		return entry.imageTileSideInfo
	elseif IsPicture( entry.imageBackground ) then
		return entry.imageBackground
	elseif IsPicture( entry.imageBackgroundFocus ) then
		return entry.imageBackgroundFocus
	elseif IsPicture( entry.image ) then
		return entry.image
	end
	return nil
end

-- what the game says about a playlist under its card, "" when it says nothing. Asked the way its menus ask: zombies names its mode.
local function PlaylistAboutOf( id, mode )
	local text = nil

	if mode == "zm" then
		text = Engine[@"hash_632A860841DBD025"]( Engine[@"getprimarycontroller"](), id, Enum[@"emodes"][@"mode_zombies"] )
	else
		text = Engine[@"hash_632A860841DBD025"]( Engine[@"getprimarycontroller"](), id )
	end

	if type( text ) == "xhash" then
		text = Engine[@"hash_4F9F1239CFD921FE"]( text )
	end

	if type( text ) ~= "string" or string.find( text, "%S" ) == nil then
		return ""
	end

	return text
end

-- the difficulties of zombies, by the value of the rule zmDifficulty of a playlist
local HostZMDifficulties = {
	[0] = "Casual",
	[1] = "Normal",
	[2] = "Hardcore",
	[3] = "Realistic"
}

-- the difficulty a playlist of zombies sets, nil when it sets none (see CoD.ZombieUtility.GetZMPlaylistDifficulty)
local function ZMDifficultyOf( entry )
	for _, rule in ipairs( entry.rules or {} ) do
		if rule.type == 0 and rule.name == @"zmdifficulty" then
			return HostZMDifficulties[tonumber( rule.value )]
		end
	end

	return nil
end

-- the maps and the gametypes a playlist goes through, each once
local function RotationOf( entry )
	local maps = {}
	local gametypes = {}
	local seenMaps = {}
	local seenGametypes = {}

	for _, step in ipairs( entry.rotationList or {} ) do
		if type( step.map ) == "string" and not seenMaps[step.map] then
			seenMaps[step.map] = true
			table.insert( maps, step.map )
		end
		-- a hash, not a word: see GametypeNameOf
		if step.gametype ~= nil and not seenGametypes[step.gametype] then
			seenGametypes[step.gametype] = true
			table.insert( gametypes, step.gametype )
		end
	end

	return maps, gametypes
end

-- the playlists of a mode, in the order of the game. No league play: it is no lobby to host.
local function PlaylistRows( mode )
	local UI = CoD.Shield.BrowserUI
	local rows = {}
	local seen = {}
	local mainMode = MainModeOf( mode )

	for _, category in ipairs( CoD.DirectorUtility.GetPlaylists() or {} ) do
		if category.nameHash ~= @"arena" and category.nameHash ~= @"hash_298A15D908A3089F" then
			local entries = category.entries or {}

			for index = 1, #entries, 1 do
				local entry = entries[index]
				local id = entry and entry.id

				if type( id ) == "number" and id > 0 and not seen[id] and entry.isNewGameOrResumeGame ~= true then
					local entryMode = entry.mainMode

					if entryMode == nil then
						local info = Engine[@"getplaylistinfobyid"]( id )
						entryMode = info and info.mainMode
					end

					if entryMode == mainMode then
						seen[id] = true

						local maps, gametypes = RotationOf( entry )
						local mapNames = {}
						local gametypeNames = {}

						for _, map in ipairs( maps ) do
							table.insert( mapNames, MapNameOf( map ) )
						end
						-- each name once: variants of a gametype can share one
						local seenNames = {}
						for _, gametype in ipairs( gametypes ) do
							local name = GametypeNameOf( gametype, mode )
							if name ~= "" and not seenNames[name] then
								seenNames[name] = true
								table.insert( gametypeNames, name )
							end
						end

						-- a playlist of zombies with its difficulty: CLASSIC (HARDCORE)
						local difficulty = mode == "zm" and ZMDifficultyOf( entry )
						if difficulty then
							for index, name in ipairs( gametypeNames ) do
								gametypeNames[index] = name .. " (" .. ToUpper( difficulty ) .. ")"
							end
						end

						-- the card has room for one name: the first, and how many more there are
						local gametypeLabel = gametypeNames[1] or ""
						if #gametypeNames > 1 then
							gametypeLabel = UI.ShortenText( gametypeLabel, 19 ) .. " +" .. ( #gametypeNames - 1 )
						end

						local players = "-"
						if type( entry.minPlayers ) == "number" and type( entry.maxPlayers ) == "number" then
							players = entry.minPlayers .. " - " .. entry.maxPlayers
						end

						table.insert( rows, {
							id = string.format( "%d", id ),
							name = LocalizedOr( entry.name, "Playlist " .. id ),
							sub = UI.ShortenText( table.concat( mapNames, ", " ), 58 ),
							kind = "primary",
							picture = PlaylistImageOf( entry ),
							about = PlaylistAboutOf( id, mode ),
							maps = maps,
							mapNames = table.concat( mapNames, ", " ),
							gametypeLabel = gametypeLabel,
							gametypeNames = table.concat( gametypeNames, ", " ),
							players = players
						} )
					end
				end
			end
		end
	end

	return rows
end

-- the maps of a playlist as rows: they are there to be read, the playlist picks among them
local function RotationRows( playlist )
	local rows = {}

	if playlist == nil then
		return rows
	end

	for _, map in ipairs( playlist.maps ) do
		table.insert( rows, {
			id = map,
			name = MapNameOf( map ),
			sub = map,
			kind = "info",
			image = CoD.MapUtility.GetMapValue( map, "previewImage", nil )
		} )
	end

	return rows
end

-- the rows of both lists for the mode and the kind picked, and a pick in each
local function RebuildHost()
	local kind = HostKinds[Host.kind]

	if kind.playlist then
		Host.primaryRows = PlaylistRows( Host.mode )
		Host.primary = KeepOrFirst( Host.primaryRows, Host.primary, nil )
		Host.mapRows = RotationRows( RowOf( Host.primaryRows, Host.primary ) )
		Host.map = ""
	else
		Host.primaryRows = GametypeRows( Host.mode )
		Host.primary = KeepOrFirst( Host.primaryRows, Host.primary, HostDefaultGametypes[Host.mode] )
		Host.mapRows = MapRows( Host.mode )
		Host.map = KeepOrFirst( Host.mapRows, Host.map, nil )
	end

	HostModel( "primary" ):set( Host.primary )
	HostModel( "map" ):set( Host.map )
end

-- the rows of a list as its data source wants them. "" for no picture: a field left out could keep what an older row had there.
local function RowsToItems( rows )
	local items = {}

	for _, row in ipairs( rows ) do
		table.insert( items, {
			models = {
				Name = row.name,
				Sub = row.sub,
				Id = row.id,
				Kind = row.kind,
				Image = row.image or ""
			},
			properties = {

			}
		} )
	end

	return items
end

-- a list is emptied through this one before it is filled again, as the browser does
DataSources.ShieldHostLobbyEmpty = DataSourceHelpers.ListSetup( "ShieldHostLobbyEmpty", function ( f3_arg0, f3_arg1 )
	return {}
end, true )

DataSources.ShieldHostLobbyPrimary = DataSourceHelpers.ListSetup( "ShieldHostLobbyPrimary", function ( f3_arg0, f3_arg1 )
	return RowsToItems( Host.primaryRows )
end, true )

DataSources.ShieldHostLobbyMaps = DataSourceHelpers.ListSetup( "ShieldHostLobbyMaps", function ( f3_arg0, f3_arg1 )
	return RowsToItems( Host.mapRows )
end, true )

-- the lobby menus of blackout take the map of Alcatraz from these, see ReloadOverrides.lua and BlackoutSettings.lua: they are made to tell the map picked here
local function SetBlackoutMapDvars( controller, map )
	local setting = 0

	if map == "wz_escape" then
		setting = 1
	elseif map == "wz_escape_alt" then
		setting = 2
	end

	Engine[@"exec"]( controller, "set use_wz_escape " .. ( setting == 1 and 1 or 0 ) )
	Engine[@"exec"]( controller, "set use_wz_escape_alt " .. ( setting == 2 and 1 or 0 ) )
	Engine[@"setdvar"]( "shield_wz_map", setting )
end

-- closes the menu and the browser under it, and has the client open the lobby picked
local function HostPickedLobby( menu, controller )
	local kind = HostKinds[Host.kind]
	local target = "director_online_" .. Host.mode .. "_" .. kind.key
	local command = nil

	if kind.playlist then
		if Host.primary ~= "" then
			command = "hostlobby playlist " .. Host.primary .. " " .. target
		end
	elseif Host.primary ~= "" and Host.map ~= "" then
		command = "hostlobby " .. Host.map .. " " .. Host.primary .. " " .. target

		-- what the game runs before it sets that map, as SetMap does
		local map = RowOf( Host.mapRows, Host.map )
		if map ~= nil and type( map.exec ) == "string" and map.exec ~= "" then
			Engine[@"exec"]( controller, map.exec )
		end

		if Host.mode == "wz" then
			SetBlackoutMapDvars( controller, Host.map )
		end
	end

	if command == nil then
		PlaySoundAlias( "uin_unavailable_click" )
		CoD.ShowServerToast( "Nothing to host here yet." )
		return
	end

	PlaySoundAlias( "uin_toggle_generic" )
	CoD.EnhPrintInfo( "Host Lobby", command )
	CoD.ShowServerToast( "Opening your lobby..." )

	GoBackMultiple( menu, controller, 2 )
	Engine[@"exec"]( controller, command )
end

---------------------------

--[[
	The body, 1744 by 740.
	Left, 1060 wide: the title with the modes, the kinds of lobby, and two lists of eleven rows, what is played and where.
	Right, from 1084, 660 wide: the card of the lobby as it is picked, and under it the button that opens it.
]]
local HOST_CARD_LEFT = 1084
local HOST_CARD_RIGHT = 1744
local HOST_CARD_IMAGE_HEIGHT = 380
local HOST_CARD_BOTTOM = 680
local HOST_CARD_TEXT_LEFT = HOST_CARD_LEFT + 24
local HOST_CARD_TEXT_RIGHT = HOST_CARD_RIGHT - 24
local HOST_CARD_HALF = HOST_CARD_LEFT + 340
local HOST_CHIPS_LEFT = 320
local HOST_ROW_WIDTH = 520
local HOST_ROW_HEIGHT = 44
local HOST_ROW_THUMB_WIDTH = 78
local HOST_LIST_TOP = 168
local HOST_LIST_ROWS = 11
local HOST_LIST_HEIGHT = HOST_LIST_ROWS * HOST_ROW_HEIGHT + ( HOST_LIST_ROWS - 1 ) * 6
local HOST_MAPS_LEFT = 540

CoD.ShieldHostLobbyBody = InheritFrom( LUI.UIElement )
CoD.ShieldHostLobbyBody.__defaultWidth = 1744
CoD.ShieldHostLobbyBody.__defaultHeight = 740
CoD.ShieldHostLobbyBody.new = function ( f1_arg0, f1_arg1, f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	local UI = CoD.Shield.BrowserUI

	local self = LUI.UIElement.new( f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	self:setClass( CoD.ShieldHostLobbyBody )
	self.id = "ShieldHostLobbyBody"
	self.soundSet = "default"
	self.onlyChildrenFocusable = true
	self.anyChildUsesUpdateState = true

	-- everything of the body that is only closed with it
	self.Parts = {}
	self.Buttons = {}

	local function Add( element )
		self:addElement( element )
		table.insert( self.Parts, element )
		return element
	end

	-- a button of the body: the menu finds what can take the focus as parent[id], so it is kept under its id
	local function AddButton( id, label, left, right, top, bottom )
		local button = UI.NewBrowserButton( self, f1_arg0, f1_arg1, label, left, right, top, bottom )
		self:addElement( button )
		button.id = id
		self[id] = button
		table.insert( self.Buttons, button )
		return button
	end

	-- the line under a chip that is the one picked
	local function AddActiveMark( chip, color )
		local mark = LUI.UIImage.new( 0, 1, 0, 0, 1, 1, -3, 0 )
		mark:setRGB( color.r, color.g, color.b )
		mark:setAlpha( 0 )
		chip:addElement( mark )
		chip.ActiveMark = mark
	end

	RebuildHost()

	---------------------------
	-- the two lists

	local function NewList( left )
		local list = LUI.UIList.new( f1_arg0, f1_arg1, 6, 0, nil, false, false, false, false )
		list:setLeftRight( 0, 0, left, left + HOST_ROW_WIDTH )
		list:setTopBottom( 0, 0, HOST_LIST_TOP, HOST_LIST_TOP + HOST_LIST_HEIGHT )

		-- filled a moment after the menu is up, see the timers below
		list:setDataSource( "ShieldHostLobbyEmpty" )

		list:setWidgetType( CoD.ShieldHostLobbyRow )
		list:setVerticalCount( HOST_LIST_ROWS )
		list:setSpacing( 6 )

		list:setAlignment( Enum[@"luialignment"][@"lui_alignment_left"] )
		list:setVerticalCounter( CoD.verticalCounter )
		list:appendEventHandler( "input_source_changed", function ( f2_arg0, f2_arg1 )
			f2_arg1.menu = f2_arg1.menu or f1_arg0
			CoD.Menu.UpdateButtonShownState( f2_arg0, f1_arg0, f1_arg1, Enum[@"luibutton"][@"lui_key_xba_pscross"] )
		end )

		list:registerEventHandler( "gain_focus", function ( element, event )
			local f5_local0 = nil
			if element.gainFocus then
				f5_local0 = element:gainFocus( event )
			elseif element.super.gainFocus then
				f5_local0 = element.super:gainFocus( event )
			end
			CoD.Menu.UpdateButtonShownState( element, f1_arg0, f1_arg1, Enum[@"luibutton"][@"lui_key_xba_pscross"] )
			return f5_local0
		end )

		return list
	end

	-- A list keeps the row it was scrolled to when its rows change: with fewer rows than that, only the last ones
	-- would show. Emptied, it is put back to its top before the new rows come.
	local function ReloadList( list, source )
		list:setDataSource( "ShieldHostLobbyEmpty" )
		list:updateDataSource()
		list:clearLayout()
		list:clearSavedActiveIndex()
		list:setDataSource( source )
		list:updateDataSource()
	end

	-- what a click on a row of a list does
	local function OnListRow( list, action )
		f1_arg0:AddButtonCallbackFunction( list, f1_arg1, Enum[@"luibutton"][@"lui_key_xba_pscross"], "ui_confirm", function ( element, menu, controller, model )
			if IsGamepad( controller ) or IsMouseOrKeyboard( controller ) then
				action( element )
				return true
			end
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

	local PrimaryList = NewList( 0 )
	local MapList = NewList( HOST_MAPS_LEFT )

	---------------------------
	-- over the lists: the title with the modes, and the kinds of lobby

	local Title = Add( UI.NewText( 0, HOST_CHIPS_LEFT - 12, -4, 32, "notosans_bold" ) )
	Title:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )
	Title:setText( "HOST A LOBBY" )

	Add( UI.NewCaption( 2, HOST_CHIPS_LEFT - 12, 30, "MODE" ) )
	Add( UI.NewCaption( 2, HOST_CHIPS_LEFT - 12, 71, "KIND OF LOBBY" ) )

	local Hint = Add( UI.NewText( 2, 1060, 110, 16, "ttmussels_regular" ) )
	Hint:setRGB( 0.62, 0.62, 0.62 )

	local PrimaryCaption = Add( UI.NewCaption( 18, HOST_ROW_WIDTH, 138, "" ) )
	local MapCaption = Add( UI.NewCaption( HOST_MAPS_LEFT + 18, HOST_MAPS_LEFT + HOST_ROW_WIDTH, 138, "" ) )
	Add( UI.NewBox( 0, 1060, 160, 161, 1, 1, 1, 0.12 ) )

	-- in the place of the first list while it has nothing
	local EmptyTitle = Add( UI.NewText( 0, HOST_ROW_WIDTH, HOST_LIST_TOP + 200, 26, "notosans_bold", Enum[@"luialignment"][@"lui_alignment_center"] ) )
	EmptyTitle:setRGB( 0.75, 0.75, 0.75 )

	local EmptyText = Add( UI.NewText( 0, HOST_ROW_WIDTH, HOST_LIST_TOP + 236, 18, "ttmussels_regular", Enum[@"luialignment"][@"lui_alignment_center"] ) )
	EmptyText:setRGB( 0.5, 0.5, 0.5 )

	---------------------------
	-- the card of the lobby as it is picked: its picture, 660 by 380, which cuts what of the picture is over

	local MapClip = LUI.UIElement.new( 0, 0, HOST_CARD_LEFT, HOST_CARD_RIGHT, 0, 0, 0, HOST_CARD_IMAGE_HEIGHT )
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

	-- the picture goes dark to its lower end, where the name is written on it
	UI.AddBottomFade( MapClip, HOST_CARD_IMAGE_HEIGHT, 200 )

	-- the parts of the card that change with the pick
	local Card = {}

	-- the line over the card, in the colour of the mode
	Card.Accent = Add( UI.NewBox( HOST_CARD_LEFT, HOST_CARD_RIGHT, 0, 4, 1, 1, 1, 1 ) )

	Card.Pill = Add( UI.NewBox( HOST_CARD_TEXT_LEFT, HOST_CARD_TEXT_LEFT + 52, 268, 294, 1, 1, 1, 1 ) )

	Card.PillText = Add( UI.NewText( HOST_CARD_TEXT_LEFT, HOST_CARD_TEXT_LEFT + 52, 272, 18, "notosans_bold", Enum[@"luialignment"][@"lui_alignment_center"] ) )
	Card.PillText:setRGB( 0.04, 0.04, 0.04 )

	Card.Kind = Add( UI.NewText( HOST_CARD_TEXT_LEFT + 64, HOST_CARD_TEXT_RIGHT, 270, 22, "ttmussels_regular" ) )
	Card.Kind:setRGB( 0.86, 0.86, 0.86 )
	Card.Kind:setLetterSpacing( 2 )

	Card.Title = Add( UI.NewText( HOST_CARD_TEXT_LEFT, HOST_CARD_TEXT_RIGHT, 304, 48, "notosans_bold" ) )
	Card.Title:setRGB( 1, 1, 1 )

	-- under the picture: two things told of the pick, and some words about it
	Add( UI.NewBox( HOST_CARD_LEFT, HOST_CARD_RIGHT, HOST_CARD_IMAGE_HEIGHT, HOST_CARD_BOTTOM, 0, 0, 0, 0.5 ) )

	Card.LeftCaption = Add( UI.NewCaption( HOST_CARD_TEXT_LEFT, HOST_CARD_HALF - 20, 400, "" ) )

	Card.LeftValue = Add( UI.NewText( HOST_CARD_TEXT_LEFT, HOST_CARD_HALF - 20, 422, 28, "notosans_bold" ) )
	Card.LeftValue:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )

	Card.RightCaption = Add( UI.NewCaption( HOST_CARD_HALF, HOST_CARD_TEXT_RIGHT, 400, "" ) )

	Card.RightValue = Add( UI.NewText( HOST_CARD_HALF, HOST_CARD_TEXT_RIGHT, 422, 28, "notosans_bold" ) )
	Card.RightValue:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )

	Add( UI.NewBox( HOST_CARD_TEXT_LEFT, HOST_CARD_TEXT_RIGHT, 476, 477, 1, 1, 1, 0.1 ) )

	Card.AboutCaption = Add( UI.NewCaption( HOST_CARD_TEXT_LEFT, HOST_CARD_TEXT_RIGHT, 494, "" ) )

	Card.About = Add( UI.NewText( HOST_CARD_TEXT_LEFT, HOST_CARD_TEXT_RIGHT, 516, 20, "ttmussels_regular" ) )
	Card.About:setRGB( 0.7, 0.7, 0.7 )

	-- the thin frame of the game around the card
	local CardFrame = LUI.UIImage.new( 0, 0, HOST_CARD_LEFT - 1, HOST_CARD_RIGHT + 1, 0, 0, -1, HOST_CARD_BOTTOM + 1 )
	CardFrame:setAlpha( 0.12 )
	CardFrame:setImage( RegisterImage( @"uie_ui_menu_store_common_frame" ) )
	CardFrame:setMaterial( LUI.UIImage.GetCachedMaterial( @"uie_nineslice_add" ) )
	CardFrame:setShaderVector( 0, 0, 0, 0, 0 )
	CardFrame:setupNineSliceShader( 12, 12 )
	Add( CardFrame )

	-- the card and the words over the lists, by what is picked now
	local function ShowPick()
		local kind = HostKinds[Host.kind]
		local color = UI.ModeColors[Host.mode] or UI.ModeColors.mp
		local primary = RowOf( Host.primaryRows, Host.primary )
		local image = nil

		Card.Accent:setRGB( color.r, color.g, color.b )
		Card.Pill:setRGB( color.r, color.g, color.b )
		Card.PillText:setText( ToUpper( Host.mode ) )
		Card.Kind:setText( kind.label )
		Hint:setText( kind.hint )

		if kind.playlist then
			PrimaryCaption:setText( "PLAYLIST" )
			MapCaption:setText( "MAPS IT PLAYS" )
			EmptyTitle:setText( "No playlists" )
			EmptyText:setText( "The game has none for this mode yet." )

			Card.LeftCaption:setText( "GAME MODES" )
			Card.RightCaption:setText( "PLAYERS" )
			Card.AboutCaption:setText( "ABOUT THE PLAYLIST" )

			if primary ~= nil then
				Card.Title:setText( primary.name )
				Card.LeftValue:setText( primary.gametypeLabel ~= "" and UI.ShortenText( primary.gametypeLabel, 24 ) or "-" )
				Card.RightValue:setText( primary.players )

				-- the words of the game about it, and its maps where it has none: they are in the list beside it too
				if primary.about ~= "" then
					local about = UI.ShortenText( primary.about, 300 )

					-- all of its game modes under those words, when the card over them had no room for them
					if primary.gametypeLabel ~= primary.gametypeNames then
						about = about .. "\n\nGame modes: " .. UI.ShortenText( primary.gametypeNames, 160 )
					end

					Card.About:setText( about )
				else
					Card.AboutCaption:setText( "MAPS" )
					Card.About:setText( UI.ShortenText( primary.mapNames ~= "" and primary.mapNames or "-", 220 ) )
				end

				-- its first map, and its own picture when it tells no map or the map has none
				if Host.mapRows[1] ~= nil and IsPicture( Host.mapRows[1].image ) then
					image = Host.mapRows[1].image
				else
					image = primary.picture
				end
			else
				Card.Title:setText( "No playlist" )
				Card.LeftValue:setText( "-" )
				Card.RightValue:setText( "-" )
				Card.About:setText( "" )
			end
		else
			local map = RowOf( Host.mapRows, Host.map )

			PrimaryCaption:setText( "GAME MODE" )
			MapCaption:setText( "MAP" )
			EmptyTitle:setText( "No game modes" )
			EmptyText:setText( "The game lists none for this mode." )

			Card.LeftCaption:setText( "GAME MODE" )
			Card.RightCaption:setText( "MAP FILE" )
			Card.AboutCaption:setText( "ABOUT THE MODE" )

			Card.Title:setText( map and map.name or "No map" )
			Card.LeftValue:setText( UI.ShortenText( primary and primary.name or "-", 24 ) )
			Card.RightValue:setText( map and map.id or "-" )
			Card.About:setText( primary and UI.ShortenText( primary.about, 300 ) or "" )

			if map ~= nil and IsPicture( map.image ) then
				image = map.image
			end
		end

		if #Host.primaryRows == 0 then
			EmptyTitle:setAlpha( 1 )
			EmptyText:setAlpha( 1 )
		else
			EmptyTitle:setAlpha( 0 )
			EmptyText:setAlpha( 0 )
		end

		-- arena, hopefully, for a pick with no picture
		UI.SetPreviewImage( MapImage, image or @"uie_ui_menu_survey_arena", HOST_CARD_RIGHT - HOST_CARD_LEFT, HOST_CARD_IMAGE_HEIGHT )

		-- the new picture comes up out of the dark
		MapImage:completeAnimation()
		MapImage:setAlpha( 0.35 )
		MapImage:beginAnimation( 180 )
		MapImage:setAlpha( 1 )
	end

	---------------------------
	-- the chips of the modes and of the kinds

	self.ModeChips = {}
	self.KindChips = {}

	local function MarkChips()
		for _, chip in ipairs( self.ModeChips ) do
			chip.ActiveMark:setAlpha( chip.HostMode == Host.mode and 1 or 0 )
		end

		local color = UI.ModeColors[Host.mode] or UI.ModeColors.mp

		for _, chip in ipairs( self.KindChips ) do
			local kind = HostKinds[chip.HostKind]

			chip.ActiveMark:setRGB( color.r, color.g, color.b )
			chip.ActiveMark:setAlpha( chip.HostKind == Host.kind and 1 or 0 )

			-- dim where the mode has no such lobby
			if kind.only ~= nil and kind.only ~= Host.mode then
				chip:setAlpha( 0.3 )
			else
				chip:setAlpha( 1 )
			end
		end
	end

	-- everything again, after the mode or the kind changed
	local function ShowHost()
		RebuildHost()
		MarkChips()
		ReloadList( PrimaryList, "ShieldHostLobbyPrimary" )
		ReloadList( MapList, "ShieldHostLobbyMaps" )
		ShowPick()
	end

	for index, info in ipairs( HostModes ) do
		local left = HOST_CHIPS_LEFT + ( index - 1 ) * 208
		local Chip = AddButton( "ModeChip" .. index, info.label, left, left + 200, 0, 44 )
		Chip.HostMode = info.key
		AddActiveMark( Chip, UI.ModeColors[info.key] )
		table.insert( self.ModeChips, Chip )

		UI.OnBrowserButton( f1_arg0, f1_arg1, Chip, function ()
			PlaySoundAlias( "uin_paint_image_flip_toggle" )

			if Host.mode ~= info.key then
				Host.mode = info.key
				Host.kind = info.kind
				ShowHost()
			end
		end )
	end

	for index, info in ipairs( HostKinds ) do
		local left = HOST_CHIPS_LEFT + ( index - 1 ) * 208
		local Chip = AddButton( "KindChip" .. index, info.label, left, left + 200, 56, 100 )
		Chip.HostKind = index
		AddActiveMark( Chip, UI.ModeColors.mp )
		table.insert( self.KindChips, Chip )

		UI.OnBrowserButton( f1_arg0, f1_arg1, Chip, function ()
			if info.only ~= nil and info.only ~= Host.mode then
				PlaySoundAlias( "uin_unavailable_click" )
				return
			end

			PlaySoundAlias( "uin_paint_image_flip_toggle" )

			if Host.kind ~= index then
				Host.kind = index
				ShowHost()
			end
		end )
	end

	---------------------------
	-- under the card: the button that opens the lobby

	local HostButton = AddButton( "HostButton", "HOST LOBBY", HOST_CARD_LEFT, HOST_CARD_RIGHT, 692, 740 )

	UI.OnBrowserButton( f1_arg0, f1_arg1, HostButton, function ()
		HostPickedLobby( f1_arg0, f1_arg1 )
	end )

	---------------------------
	-- the rows

	OnListRow( PrimaryList, function ( row )
		if row.RowId == nil or row.RowKind ~= "primary" then
			return
		end

		PlaySoundAlias( "uin_toggle_generic" )
		Host.primary = row.RowId
		HostModel( "primary" ):set( Host.primary )

		-- a playlist brings its own maps
		if HostKinds[Host.kind].playlist then
			Host.mapRows = RotationRows( RowOf( Host.primaryRows, Host.primary ) )
			ReloadList( MapList, "ShieldHostLobbyMaps" )
		end

		ShowPick()
	end )

	OnListRow( MapList, function ( row )
		if row.RowId == nil or row.RowKind ~= "map" then
			return
		end

		PlaySoundAlias( "uin_toggle_generic" )
		Host.map = row.RowId
		HostModel( "map" ):set( Host.map )
		ShowPick()
	end )

	self:addElement( PrimaryList )
	self.PrimaryList = PrimaryList
	PrimaryList.id = "PrimaryList"

	self:addElement( MapList )
	self.MapList = MapList
	MapList.id = "MapList"

	-- a list takes its rows once it is part of the menu: a moment later, as the browser fills its own
	PrimaryList:addElement( LUI.UITimer.newElementTimer( 5, true, function ()
		ReloadList( PrimaryList, "ShieldHostLobbyPrimary" )
	end ) )

	MapList:addElement( LUI.UITimer.newElementTimer( 5, true, function ()
		ReloadList( MapList, "ShieldHostLobbyMaps" )
	end ) )

	MarkChips()
	ShowPick()

	LUI.OverrideFunction_CallOriginalSecond( self, "close", self.__onClose )

	if PostLoadFunc then
		PostLoadFunc( self, f1_arg1, f1_arg0 )
	end

	return self
end

CoD.ShieldHostLobbyBody.__onClose = function ( f9_arg0 )
	for _, element in ipairs( f9_arg0.Parts ) do
		element:close()
	end
	for _, button in ipairs( f9_arg0.Buttons ) do
		button:close()
	end
	f9_arg0.MapImage:close()
	f9_arg0.PrimaryList:close()
	f9_arg0.MapList:close()
end

---------------------------

--[[
	A row of either list, 520 by 44: the name over the name the game knows it by, and for a map its picture.
	The one picked keeps the colour of the mode and a bar at its end.
]]

-- what of a row changes with the focus
local HostRowFocusParts = {
	{ "BlackBar", function ( element, focus ) element:setAlpha( focus and 0.1 or 0.05 ) end },
	{ "Tint", function ( element, focus ) element:setAlpha( focus and 0.16 or 0 ) end },
	{ "FocusFrame", function ( element, focus ) element:setAlpha( focus and 1 or 0 ) end },
	{ "Accent", function ( element, focus ) element:setLeftRight( 0, 0, 0, focus and 7 or 4 ) end }
}

-- the clip of the rows of the browser, looked up when it plays: that file may be loaded after this one
local function HostRowClip( focus, duration )
	return function ( self, event )
		return CoD.Shield.BrowserUI.FocusClip( HostRowFocusParts, focus, duration )( self, event )
	end
end

CoD.ShieldHostLobbyRow = InheritFrom( LUI.UIElement )
CoD.ShieldHostLobbyRow.__defaultWidth = HOST_ROW_WIDTH
CoD.ShieldHostLobbyRow.__defaultHeight = HOST_ROW_HEIGHT
CoD.ShieldHostLobbyRow.new = function ( f1_arg0, f1_arg1, f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	local UI = CoD.Shield.BrowserUI

	local self = LUI.UIElement.new( f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	self:setClass( CoD.ShieldHostLobbyRow )
	self.id = "ShieldHostLobbyRow"
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

	-- and over the row picked, which no clip touches
	local Chosen = LUI.UIImage.new( 0, 1, 0, 0, 0, 1, 0, 0 )
	Chosen:setAlpha( 0 )
	Add( Chosen )

	-- the picture of a map, cut to its box
	local ThumbClip = LUI.UIElement.new( 0, 0, 0, HOST_ROW_THUMB_WIDTH, 0, 0, 0, HOST_ROW_HEIGHT )
	ThumbClip:setUseStencil( true )
	Add( ThumbClip )

	local Thumb = LUI.UIImage.new( 0, 1, 0, 0, 0, 1, 0, 0 )
	Thumb:setAlpha( 0 )
	ThumbClip:addElement( Thumb )
	self.Thumb = Thumb

	-- the bar at the start of the row
	local Accent = LUI.UIImage.new( 0, 0, 0, 4, 0, 1, 0, 0 )
	Add( Accent )
	self.Accent = Accent

	local Name = Add( UI.NewText( 18, HOST_ROW_WIDTH - 20, 4, 21, "notosans_bold" ) )
	Name:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )

	local Sub = Add( UI.NewText( 18, HOST_ROW_WIDTH - 20, 26, 14, "ttmussels_regular" ) )
	Sub:setRGB( 0.5, 0.5, 0.5 )
	Sub:setLetterSpacing( 1 )

	-- the bar at the end of the row picked
	local ChosenMark = LUI.UIImage.new( 1, 1, -8, 0, 0, 1, 0, 0 )
	ChosenMark:setAlpha( 0 )
	Add( ChosenMark )

	-- the frame of the game around the row in focus, in the colour of the mode
	local FocusFrame = LUI.UIImage.new( 0, 1, -4, 4, 0, 1, -4, 4 )
	FocusFrame:setAlpha( 0 )
	FocusFrame:setImage( RegisterImage( @"uie_ui_menu_store_focus_frame" ) )
	FocusFrame:setMaterial( LUI.UIImage.GetCachedMaterial( @"uie_nineslice_add" ) )
	FocusFrame:setShaderVector( 0, 0, 0, 0, 0 )
	FocusFrame:setupNineSliceShader( 10, 10 )
	Add( FocusFrame )
	self.FocusFrame = FocusFrame

	local PrimaryModel = HostModel( "primary" )
	local MapModel = HostModel( "map" )

	local function ShowChosen()
		local chosen = false

		if self.RowId ~= nil then
			if self.RowKind == "primary" then
				chosen = PrimaryModel:get() == self.RowId
			elseif self.RowKind == "map" then
				chosen = MapModel:get() == self.RowId
			end
		end

		Chosen:setAlpha( chosen and 0.14 or 0 )
		ChosenMark:setAlpha( chosen and 1 or 0 )
	end

	-- everything of the row is read when its name is set: the list makes a row whole before it gives it
	Name:linkToElementModel( self, "Name", true, function ( model )
		if model:get() == nil then
			return
		end

		local color = UI.ModeColors[Host.mode] or UI.ModeColors.mp
		local image = CoD.ModelUtility.GetSelfModelPathValue( self, "Image" )
		local textLeft = 18

		-- what the click and the mark of the pick read of the row
		self.RowId = CoD.ModelUtility.GetSelfModelPathValue( self, "Id" )
		self.RowKind = CoD.ModelUtility.GetSelfModelPathValue( self, "Kind" )

		Accent:setRGB( color.r, color.g, color.b )
		Tint:setRGB( color.r, color.g, color.b )
		Chosen:setRGB( color.r, color.g, color.b )
		ChosenMark:setRGB( color.r, color.g, color.b )
		FocusFrame:setRGB( color.r, color.g, color.b )

		if IsPicture( image ) then
			UI.SetPreviewImage( Thumb, image, HOST_ROW_THUMB_WIDTH, HOST_ROW_HEIGHT )
			Thumb:setAlpha( 1 )
			textLeft = HOST_ROW_THUMB_WIDTH + 14
		else
			Thumb:setAlpha( 0 )
		end

		Name:setLeftRight( 0, 0, textLeft, HOST_ROW_WIDTH - 20 )
		Sub:setLeftRight( 0, 0, textLeft, HOST_ROW_WIDTH - 20 )

		Name:setText( model:get() )
		Sub:setText( CoD.ModelUtility.GetSelfModelPathValue( self, "Sub" ) or "" )

		ShowChosen()
	end )

	self:subscribeToModel( PrimaryModel, function ( model )
		ShowChosen()
	end )

	self:subscribeToModel( MapModel, function ( model )
		ShowChosen()
	end )

	LUI.OverrideFunction_CallOriginalSecond( self, "close", self.__onClose )

	if PostLoadFunc then
		PostLoadFunc( self, f1_arg1, f1_arg0 )
	end

	return self
end

CoD.ShieldHostLobbyRow.__resetProperties = function ( f7_arg0 )
	for _, part in ipairs( HostRowFocusParts ) do
		local element = f7_arg0[part[1]]
		element:completeAnimation()
		part[2]( element, false )
	end
end

CoD.ShieldHostLobbyRow.__clipsPerState = {
	DefaultState = {
		DefaultClip = HostRowClip( false ),
		Focus = HostRowClip( true ),
		GainFocus = HostRowClip( true, 120 ),
		LoseFocus = HostRowClip( false, 120 )
	}
}

CoD.ShieldHostLobbyRow.__onClose = function ( f10_arg0 )
	f10_arg0.Thumb:close()
	for _, element in ipairs( f10_arg0.Parts ) do
		element:close()
	end
end

---------------------------

-- Safe area of the menu: the header of the game over the body
CoD.Shield_SafeAreaContainer_HostLobbyOverlay = InheritFrom( LUI.UIElement )
CoD.Shield_SafeAreaContainer_HostLobbyOverlay.__defaultWidth = 1920
CoD.Shield_SafeAreaContainer_HostLobbyOverlay.__defaultHeight = 1080
CoD.Shield_SafeAreaContainer_HostLobbyOverlay.new = function ( f1_arg0, f1_arg1, f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	local self = LUI.UIElement.new( f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	self:setClass( CoD.Shield_SafeAreaContainer_HostLobbyOverlay )
	self.id = "Shield_SafeAreaContainer_HostLobbyOverlay"
	self.soundSet = "none"
	self.onlyChildrenFocusable = true
	self.anyChildUsesUpdateState = true

	local TabBacking = CoD.CommonTabBarBacking.new( f1_arg0, f1_arg1, -0.1, 1.1, 0, 0, 0, 0, 52, 89 )
	TabBacking.TabBackingBlur:setAlpha( 0 )
	self:addElement( TabBacking )
	self.TabBacking = TabBacking

	local CommonHeader = CoD.CommonHeader.new( f1_arg0, f1_arg1, 0, 1, 0, 0, 0, 0, 0, 67 )
	CommonHeader.subtitle.StageTitle:setText("^2Host Lobby")
	CommonHeader.subtitle.subtitle:setText("^3A Lobby Of Your Own")
	self:addElement( CommonHeader )
	self.CommonHeader = CommonHeader

	local HeaderStripe = CoD.header_container_frontend.new( f1_arg0, f1_arg1, 0, 1, 0, 0, 0, 0, 0, 42 )
	self:addElement( HeaderStripe )
	self.HeaderStripe = HeaderStripe

	-- the body: from 88 to 1832 of the 1920 across, from 140 to 880 down
	local ShieldHostLobbyBody = CoD.ShieldHostLobbyBody.new( f1_arg0, f1_arg1, 0.5, 0.5, -872, 872, 0, 0, 140, 880 )
	self:addElement( ShieldHostLobbyBody )
	self.ShieldHostLobbyBody = ShieldHostLobbyBody

	ShieldHostLobbyBody.id = "ShieldHostLobbyBody"

	LUI.OverrideFunction_CallOriginalSecond( self, "close", self.__onClose )

	if PostLoadFunc then
		PostLoadFunc( self, f1_arg1, f1_arg0 )
	end

	return self
end

CoD.Shield_SafeAreaContainer_HostLobbyOverlay.__onClose = function ( f5_arg0 )
	f5_arg0.TabBacking:close()
	f5_arg0.CommonHeader:close()
	f5_arg0.HeaderStripe:close()
	f5_arg0.ShieldHostLobbyBody:close()
end

---------------------------

-- the menu, opened over the lobby browser
CoD.ShieldHostLobbyOverlay = InheritFrom( CoD.Menu )
LUI.createMenu.ShieldHostLobbyOverlay = function ( f1_arg0, f1_arg1 )
	local self = CoD.Menu.NewForUIEditor( "ShieldHostLobbyOverlay", f1_arg0 )
	local f1_local1 = self

	self:setClass( CoD.ShieldHostLobbyOverlay )
	self.soundSet = "default"
	self:setOwner( f1_arg0 )
	self:setLeftRight( 0, 1, 0, 0 )
	self:setTopBottom( 0, 1, 0, 0 )
	self:playSound( "menu_open", f1_arg0 )
	self.anyChildUsesUpdateState = true

	local Background = CoD.StartMenuOptionsBackground.new( f1_local1, f1_arg0, 0, 1, 0, 0, 0, 1, 0, 0 )
	self:addElement( Background )
	self.Background = Background

	local FooterContainerFrontendRight = CoD.FooterContainer_Frontend_Right.new( f1_local1, f1_arg0, 0.5, 0.5, -960, 960, 1, 1, -48, 0 )
	self:addElement( FooterContainerFrontendRight )
	self.FooterContainerFrontendRight = FooterContainerFrontendRight

	local SafeAreaContainerHostLobbyOverlay = CoD.Shield_SafeAreaContainer_HostLobbyOverlay.new( f1_local1, f1_arg0, 0, 0, 0, 1920, 0, 0, 0, 1080 )
	SafeAreaContainerHostLobbyOverlay:registerEventHandler( "menu_loaded", function ( element, event )
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
	self:addElement( SafeAreaContainerHostLobbyOverlay )
	self.SafeAreaContainerHostLobbyOverlay = SafeAreaContainerHostLobbyOverlay

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

	SafeAreaContainerHostLobbyOverlay.id = "SafeAreaContainerHostLobbyOverlay"

	self:processEvent( {
		name = "menu_loaded",
		controller = f1_arg0
	} )

	LUI.OverrideFunction_CallOriginalSecond( self, "close", self.__onClose )

	if PostLoadFunc then
		PostLoadFunc( self, f1_arg0 )
	end

	CoD.EnhPrintInfo("Called", "Shield's Host Lobby")

	SizeToSafeArea(SafeAreaContainerHostLobbyOverlay, f1_arg0)

	return self
end

CoD.ShieldHostLobbyOverlay.__onClose = function ( f8_arg0 )
	f8_arg0.Background:close()
	f8_arg0.FooterContainerFrontendRight:close()
	f8_arg0.SafeAreaContainerHostLobbyOverlay:close()
end
