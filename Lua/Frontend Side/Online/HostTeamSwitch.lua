--[[
		.\hksc.exe ".\Lua\HostTeamSwitch.Lua" -o "C:\Program Files (x86)\Call of Duty Black Ops 4\project-bo4\mods\T8ShieldSupport\Lua\Frontend\HostTeamSwitch.luac"

		Not a menu file: this one runs in the lobby VM, with the events file of the lobby (metadata.json: hooks_post
		x64:0c0cc5d8d2fa7820, lua/lobby/lobbyevents.lua). No CoD table there, only Lobby, LobbyData, Engine, Dvar, Enum.
		An error in this VM is a fatal "Lobby Error" and there is no pcall: everything is looked at before it is used.
		The functions of Engine are found by their whole hash, of 16 digits: the decompiled scripts show 15, which find
		nothing here. Those below were read from the compiled lobby file of the game.
		Changes to this file need the game restarted: the lobby VM is not reloaded with the mods.

	The host of a public lobby moves players between teams as in a custom game, and they stay where it put them.

	In a public lobby teams are assigned by the game (gametype setting teamAssignment is AUTO), and
	Lobby.TeamSelection.SwitchTeam then only asks a team for the local player: the move of the host (swapXuid, sent
	by CoD.DirectorUtility.MoveClient_Internal) moved nobody, or the host. And when the match starts, Lobby.Timer
	splits the teams again by skill (Lobby.TeamSelection.AutoSplitTeam), undoing any move.
	So a move of the host goes the way it goes in a custom game (SwitchTeamHostAssignment), the teams it gave are
	kept, and put back after each split. They are forgotten with the lobby (Lobby.TeamSelection.Clear), or when the
	player leaves.
	The players of a public lobby of multiplayer are also left on no team (free) until it starts, only bots get one:
	the team setup has no place for them, so the host could not move them, itself neither. Each time the game assigns
	teams (Lobby.TeamSelection.AutoAssignPlayers, on joins and on going to a lobby), those are put on the smaller team.
]]

---------------------------

local function Note( text )
	Engine[@"printinfo"]( Enum[@"consolelabel_e"][@"con_label_lobby"], "[shield] host team switch: " .. text .. "\n" )
end

-- The teams the host gave, by xuid as text, each { xuid, team }. A xuid comes from the game as a new object each time
-- it is asked for, and objects are keys by being the same object: by them, each move of a player was kept apart from
-- the ones before it, and all of them were put back in turn.
local HostTeams = {}

local function HostModule()
	return Enum[@"lobbymodule"][@"lobby_module_host"]
end

local function HostLobbyType()
	return Engine[@"hash_3C3DF042E7492B66"]( HostModule() )
end

local function IsHost()
	if Engine[@"islobbyhost"]( HostLobbyType() ) then
		return true
	end

	return false
end

local function IsInLobby( xuid )
	return Engine[@"hash_7EFBAAD12776201D"]( HostModule(), HostLobbyType(), xuid ) ~= LuaDefine.INVALID_CLIENT_INDEX
end

local function TeamOf( xuid )
	return Engine[@"hash_420826BD382E3A23"]( HostModule(), HostLobbyType(), xuid )
end

local function IsAutoAssigned()
	return Engine[@"getgametypesetting"]( "teamAssignment" ) == LuaEnum.TEAM_ASSIGNMENT.AUTO
end

-- a move of the host: the player it picked, and the one it swaps with when it picked a second
local function IsHostMove( event )
	return type( event ) == "table" and event.swapXuid ~= nil and event.swapXuid ~= 0 and event.swapXuid ~= LuaDefine.INVALID_XUID_X64
end

--[[
	What the host gives is kept: the teams the move asks for, taken before it is made. The session read back right
	after a move can still have the team from before it, and that was kept and put back again and again.
	A swap gives each of the two the team of the other, a move gives the one picked the team asked for.
]]
local function MoveTeams( event )
	local teams = {}

	if event.withXuid ~= nil and IsInLobby( event.withXuid ) and IsInLobby( event.swapXuid ) then
		table.insert( teams, { xuid = event.swapXuid, team = TeamOf( event.withXuid ) } )
		table.insert( teams, { xuid = event.withXuid, team = TeamOf( event.swapXuid ) } )
	elseif event.requestedTeam ~= nil and IsInLobby( event.swapXuid ) then
		table.insert( teams, { xuid = event.swapXuid, team = event.requestedTeam } )
	end

	return teams
end

local function Remember( teams )
	for _, entry in ipairs( teams ) do
		HostTeams[tostring( entry.xuid )] = entry
	end
end

-- The players on no team are put on the smaller of the two, as many as the lobby launches with: in a public lobby of
-- multiplayer, where the game assigns the teams only when it starts.
local LastAssignNote = ""

-- temporary: why a player on no team is left there, told when it changes
local function AssignNote( text )
	if text ~= LastAssignNote then
		LastAssignNote = text
		Note( text )
	end
end

local function IsPublicLobby()
	local target = LobbyData.GetCurrentMenuTarget()
	return type( target ) == "table" and target[@"lobbymode"] == Enum[@"lobbymode"][@"lobby_mode_public"]
end

-- A public lobby of multiplayer, whichever way its teams are assigned: the setting is HOST in the playlists of this
-- client, and the game gives the players of a public lobby a team neither way.
-- puts back the teams the host gave, see below
local PutBack

local function AssignFree( lobbyMode )
	local host = IsHost()
	local public = IsPublicLobby() or lobbyMode == Enum[@"lobbymode"][@"lobby_mode_public"]
	local teams = CoDShared.IsGametypeTeamBased()
	local mode = Engine[@"currentsessionmode"]()

	if not host or not public or not teams or mode ~= Enum[@"emodes"][@"mode_multiplayer"] then
		AssignNote( "free players kept: host " .. tostring( host ) .. ", public " .. tostring( public ) ..
			", team based " .. tostring( teams ) .. ", mode " .. tostring( mode ) .. " of " .. tostring( Enum[@"emodes"][@"mode_multiplayer"] ) )
		return
	end

	-- what the host gave first: the game spreads all bots again when one joins, and clears the teams when the timer
	-- of the lobby goes back to waiting for players
	PutBack()

	local lobbyType = HostLobbyType()
	local session = Engine[@"hash_4755D55B3813D249"]( HostModule(), lobbyType )
	local sizes = LobbyData.GetCurrentLobbySizes()

	if type( session ) ~= "table" or type( session.sessionClients ) ~= "table" or type( sizes ) ~= "table" then
		AssignNote( "free players kept: no session " .. type( session ) .. " or sizes " .. type( sizes ) )
		return
	end

	AssignNote( "free players get a team, " .. #session.sessionClients .. " clients, launch size " .. tostring( sizes.maxLaunchClients ) )

	local allies = Enum[@"team_t"][@"team_allies"]
	local axis = Enum[@"team_t"][@"team_axis"]
	local free = Enum[@"team_t"][@"team_free"]
	local counts = { [allies] = 0, [axis] = 0 }

	for _, client in ipairs( session.sessionClients ) do
		if counts[client.team] ~= nil then
			counts[client.team] = counts[client.team] + 1
		end
	end

	for _, client in ipairs( session.sessionClients ) do
		if client.team == free and counts[allies] + counts[axis] < ( sizes.maxLaunchClients or 0 ) then
			local team = counts[allies] <= counts[axis] and allies or axis
			Engine[@"hash_6D506AB0E93540B3"]( lobbyType, client.xuid, team )
			counts[team] = counts[team] + 1
			Note( tostring( client.gamertag ) .. " put on team " .. tostring( team ) .. ", now on " .. tostring( TeamOf( client.xuid ) ) )
		end
	end
end

-- the teams the host gave, put back: after a split of the game
-- how many were put back
PutBack = function ()
	local lobbyType = HostLobbyType()
	local count = 0

	for key, entry in pairs( HostTeams ) do
		if IsInLobby( entry.xuid ) then
			local now = TeamOf( entry.xuid )

			-- only who the game moved: the others stay as they are
			if now ~= entry.team then
				Engine[@"hash_6D506AB0E93540B3"]( lobbyType, entry.xuid, entry.team )
				Note( "put back " .. key .. " from team " .. tostring( now ) .. " to " .. tostring( entry.team ) )
			end

			count = count + 1
		else
			HostTeams[key] = nil
		end
	end

	return count
end

-- whether the host moved anyone still in the lobby
local function HasHostTeams()
	for _, entry in pairs( HostTeams ) do
		if IsInLobby( entry.xuid ) then
			return true
		end
	end

	return false
end

--[[
	When the countdown of a public lobby ends, Lobby.Launch.HostLaunchPump counts allies and axis in the session of the
	game lobby and does not launch when they differ by more than one: it starts the timer again. Teams the host made
	are let through. Engine can't be changed, but those checks are only made when the menu is the one of a public lobby
	of multiplayer, which it asks LobbyData for: while it runs, LobbyData knows no such menu. Its check of too few
	players goes with them, the timer of the lobby has its own.
	LobbyData is read only (LuaReadOnlyTables.ReadOnlyTable): what it reads is in its _originalTable, which is not.
]]
-- the check of the launch once wrapped, or once it could not be
local LaunchWrapper

local function WrapLaunch()
	local launch = Lobby.Launch

	if type( launch ) ~= "table" or type( launch.HostLaunchPump ) ~= "function" or launch.HostLaunchPump == LaunchWrapper then
		return
	end

	local data = type( LobbyData ) == "table" and LobbyData._originalTable

	if type( data ) ~= "table" or getmetatable( data ) ~= nil or type( data.GetLobbyMenuIDByName ) ~= "function" then
		Note( "the check of the launch can't be changed here, teams of the host must be balanced (lobby data " .. type( data ) .. ")" )
		LaunchWrapper = launch.HostLaunchPump
		return
	end

	local hostLaunchPump = launch.HostLaunchPump

	LaunchWrapper = function ( event )
		if not HasHostTeams() then
			return hostLaunchPump( event )
		end

		local menuID = data.GetLobbyMenuIDByName
		local public = LuaEnum.UI.DIRECTOR_ONLINE_MP_PUBLIC

		data.GetLobbyMenuIDByName = function ( name )
			if name == public then
				return nil
			end

			return menuID( name )
		end

		local launched = hostLaunchPump( event )
		data.GetLobbyMenuIDByName = menuID

		return launched
	end

	launch.HostLaunchPump = LaunchWrapper
	Note( "teams the host made are launched as they are" )
end

--[[
	Deploy right after a match failed ("Failed to host a lobby", then back to the main menu), and worked from the main
	menu: the game lobby of the last match was most likely still hosted, and hosting the new one failed on it. The
	process that hosts it now ends that one first, as the game does before hosting in its other processes. Each
	deploy notes what was there, to see in project-bo4.log whether that was it.
]]
local function WrapHostStart()
	local process = Lobby.Process
	local actions = Lobby.Actions

	if type( process ) ~= "table" or type( process.CreateAsyncMatchmakingLobby ) ~= "function" or type( process.ForceAction ) ~= "function" then
		Note( "no lobby process yet (" .. type( process ) .. "), a game lobby left from a match is not ended before hosting" )
		return
	end

	if type( actions ) ~= "table" or type( actions.LobbyHostEnd ) ~= "function" then
		Note( "no host end action (" .. type( actions ) .. "), a game lobby left from a match is not ended before hosting" )
		return
	end

	local create = process.CreateAsyncMatchmakingLobby

	process.CreateAsyncMatchmakingLobby = function ( ... )
		local queued = create( ... )

		local gameType = Enum[@"lobbytype"][@"lobby_type_game"]
		local hosted = Engine[@"islobbyactive"]( Enum[@"lobbymodule"][@"lobby_module_host"], gameType )
		local joined = Engine[@"islobbyactive"]( Enum[@"lobbymodule"][@"lobby_module_client"], gameType )

		Note( "hosting a game lobby: one hosted already " .. tostring( hosted ) .. ", one joined " .. tostring( joined ) )

		if hosted and type( queued ) == "table" and queued.head ~= nil then
			local finish = actions.LobbyHostEnd( gameType )

			process.ForceAction( finish, queued.head )
			queued.head = finish

			Note( "the game lobby left from the last match is ended first" )
		end

		return queued
	end

	Note( "a game lobby left from a match is ended before hosting a new one" )
end

local function Wrap( selection )
	-- the lobby process is loaded by the time the events are made
	WrapHostStart()

	local switchTeam = selection.SwitchTeam
	local hostAssignment = selection.SwitchTeamHostAssignment
	local autoSplit = selection.AutoSplitTeam
	local clear = selection.Clear
	local autoAssign = selection.AutoAssignPlayers
	local clientAdded = selection.OnClientAdded
	local sessionStart = selection.OnSessionStart
	local settingsChange = selection.OnGametypeSettingsChange

	if type( switchTeam ) ~= "function" or type( hostAssignment ) ~= "function" or type( autoSplit ) ~= "function" or type( clear ) ~= "function" or
		type( autoAssign ) ~= "function" or type( clientAdded ) ~= "function" or type( sessionStart ) ~= "function" or
		type( settingsChange ) ~= "function" then
		Note( "the team selection of the game is not as expected, nothing done" )
		return
	end

	-- A move of the host goes as in a custom game, and is kept: the game splits the teams again when a public match
	-- starts (Lobby.MatchmakingAsync.AssignTeams spreads the bots over both), whichever way its teams are assigned.
	selection.SwitchTeam = function ( event )
		if IsHostMove( event ) and IsHost() then
			local teams = MoveTeams( event )

			if IsAutoAssigned() then
				hostAssignment( event )
			else
				switchTeam( event )
			end

			Remember( teams )

			-- temporary: each move of the host, and the team the game has for the moved right after
			for _, entry in ipairs( teams ) do
				Note( "host moves " .. tostring( entry.xuid ) .. " to team " .. tostring( entry.team ) .. ", now on " .. tostring( TeamOf( entry.xuid ) ) )
			end

			if #teams == 0 then
				Note( "host move kept nobody: picked " .. tostring( event.swapXuid ) .. ", with " .. tostring( event.withXuid ) .. ", team " .. tostring( event.requestedTeam ) )
			end

			return
		end

		return switchTeam( event )
	end

	-- The timer of the lobby asks the split whether the teams are balanced, and does not start the match until they
	-- are: teams the host made are taken as they are.
	selection.AutoSplitTeam = function ( balanced, verbose, check )
		local result = autoSplit( balanced, verbose, check )

		if PutBack() > 0 then
			return true
		end

		return result
	end

	selection.AutoAssignPlayers = function ( xuid )
		autoAssign( xuid )
		AssignFree()
	end

	-- The host goes into the game lobby of a public match without the game assigning teams: it is put on one when it is
	-- added. The events of the lobby name their lobby mode, the menu may still be the one before.
	selection.OnClientAdded = function ( event )
		clientAdded( event )
		AssignFree( type( event ) == "table" and event.lobbyMode )
	end

	selection.OnSessionStart = function ( event )
		sessionStart( event )
		AssignFree( type( event ) == "table" and event.lobbyMode )
	end

	-- the gametype of the playlist comes after the host is added: before it, the lobby is not of teams yet
	selection.OnGametypeSettingsChange = function ( event )
		settingsChange( event )
		AssignFree( type( event ) == "table" and event.lobbyMode )
	end

	selection.Clear = function ( ... )
		HostTeams = {}
		return clear( ... )
	end

	Note( "the host moves players in public lobbies" )

	--[[
		The gametype of the playlist reaches a public lobby a few seconds after the host, and no event of the lobby
		says when: the timer of the lobby, which runs while it is open, puts the players on no team on one, every
		tenth time. The timer takes its pump from here when it starts, so it gets this one.
	]]
	local timer = Lobby.Timer

	if type( timer ) ~= "table" or type( timer.AutoMPPump ) ~= "function" then
		Note( "no timer of the lobby yet, the host gets a team only when the game assigns teams" )
		return
	end

	local pump = timer.AutoMPPump
	local pumps = 0

	timer.AutoMPPump = function ( ... )
		-- the launch is loaded by the time a lobby has a timer
		WrapLaunch()

		pumps = pumps + 1

		if pumps >= 10 then
			pumps = 0
			AssignFree( nil )
		end

		return pump( ... )
	end
end

if type( Lobby ) ~= "table" then
	Note( "no Lobby table here, nothing done" )
elseif type( Lobby.TeamSelection ) == "table" and type( Lobby.TeamSelection.SwitchTeam ) == "function" then
	-- there already: wrapped before the events file takes SwitchTeam for its handler
	Wrap( Lobby.TeamSelection )
elseif type( setmetatable ) ~= "function" or type( getmetatable ) ~= "function" or type( rawset ) ~= "function" then
	Note( "the team selection can't be waited for here, nothing done" )
else
	--[[
		The events file makes Lobby.Events once what it requires is loaded, the team selection among it, and takes
		SwitchTeam for its handler right after: it is wrapped when Lobby.Events is made. Another file of the mod may
		watch Lobby too (BlackoutJoinInProgress.lua): its watch is kept and called, and when it takes its watch away,
		this one is put back.
	]]
	local other = getmetatable( Lobby )
	local otherSet = other and other.__newindex
	local watch = {}

	watch.__newindex = function ( lobby, key, value )
		if type( otherSet ) == "function" then
			otherSet( lobby, key, value )
		else
			rawset( lobby, key, value )
		end

		if key == "Events" then
			-- done: the other watch goes on alone, when it still waits
			setmetatable( lobby, otherSet and other or nil )

			if type( Lobby.TeamSelection ) == "table" then
				Wrap( Lobby.TeamSelection )
			else
				Note( "no team selection when the events were made, nothing done" )
			end
		elseif getmetatable( lobby ) ~= watch then
			-- the other watch is done: this one goes on alone
			otherSet = nil
			setmetatable( lobby, watch )
		end
	end

	setmetatable( Lobby, watch )
	Note( "waiting for the team selection" )
end
