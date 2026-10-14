--[[
		.\hksc.exe ".\Lua\BlackoutJoinInProgress.Lua" -o "C:\Program Files (x86)\Call of Duty Black Ops 4\project-bo4\mods\T8ShieldSupport\Lua\Frontend\BlackoutJoinInProgress.luac"

		Not a menu file: this one runs in the lobby VM, with the party privacy file of the game
		(metadata.json: hooks_post x64:222503cffc39f501). No CoD table there, only Lobby, LobbyData, Engine, Dvar.

		A "post" hook runs once the hooked file is loaded, which is before that file has run: Lobby.PartyPrivacy
		is not there yet. So nothing of it is touched here: the rule is caught when the game puts it in its table.
		An error in this VM is a fatal "Lobby Error" and the game has no pcall: only what the lobby files of the
		game use themselves is called, and each of the others is looked at before it is.
]]

---------------------------

local function Note( text )
	Engine[@"printinfo"]( Enum[@"consolelabel_e"][@"con_label_lobby"], "[shield] blackout join in progress: " .. text .. "\n" )
end

-- The side that joins: its join check (Lobby.Actions.AsyncMatchmakingJoinCheck) sends it to the game lobby of
-- a public blackout host only when this dvar exists, and to the party of the host when it does not. The game
-- never makes the dvar, so a joiner sat in the party, "waiting for game or party". It can't be made from here
-- (setting it does not): the client does, by giving its name to a dvar nothing reads. This only tells which it is.
if Dvar[@"hash_3D6B7833ECC9D286"]:exists() then
	Note( "a join goes to the game lobby" )
else
	Note( "this client does not make the dvar of the join check, a join still goes to the party" )
end

-- The game closes the lobby of a public blackout match the moment it launches: the host then refuses
-- every join, and the lobby browser does not list a closed lobby. A blackout lobby launches by itself
-- a few seconds after it opens, so nobody could ever join one. With joins in progress allowed (the dvar
-- the client makes true, which the join check of the host reads as well) the lobby stays open.
local function WrapRule( original )
	return function ()
		local privacy = original()

		if privacy ~= Enum[@"partyprivacy"][@"party_privacy_closed"] then
			return privacy
		end

		-- only what the blackout rule closed: not the theater, not another mode
		if not Engine[@"hash_356B4618D857143D"]() or CoDShared.IsInTheaterLobby() then
			return privacy
		end

		if not Dvar[@"hash_2A546240BBE08638"]:exists() or not Dvar[@"hash_2A546240BBE08638"]:get() then
			return privacy
		end

		local target = LobbyData.GetCurrentMenuTarget()

		if target ~= nil and target[@"lobbymode"] == Enum[@"lobbymode"][@"lobby_mode_public"] then
			return Enum[@"partyprivacy"][@"party_privacy_open"]
		end

		return privacy
	end
end

if type( Lobby ) ~= "table" then
	Note( "no Lobby table here, nothing done" )
elseif type( Lobby.PartyPrivacy ) == "table" and type( Lobby.PartyPrivacy.GetGameLobbyPartyPrivacy ) == "function" then
	-- the rule is there already: wrapped now
	Lobby.PartyPrivacy.GetGameLobbyPartyPrivacy = WrapRule( Lobby.PartyPrivacy.GetGameLobbyPartyPrivacy )
	Note( "the rule is wrapped" )
elseif type( setmetatable ) ~= "function" or type( getmetatable ) ~= "function" or type( rawset ) ~= "function" then
	Note( "the rule can't be waited for here, nothing done" )
else
	-- The game makes Lobby.PartyPrivacy next, then puts the rule in it. Another file of the mod may watch Lobby too
	-- (HostTeamSwitch.lua): its watch is kept and called, and whichever is done first leaves the other to go on alone.
	local other = getmetatable( Lobby )
	local otherSet = other and other.__newindex
	local watch = {}

	watch.__newindex = function ( lobby, key, value )
		if type( otherSet ) == "function" then
			otherSet( lobby, key, value )
		else
			rawset( lobby, key, value )
		end

		if key == "PartyPrivacy" and type( value ) == "table" then
			setmetatable( lobby, otherSet and other or nil )
			setmetatable( value, {
				__newindex = function ( privacy, name, func )
					if name == "GetGameLobbyPartyPrivacy" and type( func ) == "function" then
						rawset( privacy, name, WrapRule( func ) )
						setmetatable( privacy, nil )
						Note( "the rule is wrapped" )
					else
						rawset( privacy, name, func )
					end
				end
			} )
		elseif getmetatable( lobby ) ~= watch then
			-- the other watch is done: this one goes on alone
			otherSet = nil
			setmetatable( lobby, watch )
		end
	end

	setmetatable( Lobby, watch )
	Note( "waiting for the rule" )
end
