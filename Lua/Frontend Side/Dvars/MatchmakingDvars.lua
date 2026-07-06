--[[
		.\hksc.exe ".\Lua\MatchmakingDvars.Lua" -o "C:\Program Files (x86)\Call of Duty Black Ops 4\project-bo4\mods\T8ShieldSupport\Lua\MatchmakingDvars.luac"
]]

---------------------------

CoD.ShieldInitLuaFile()

---------------------------

-- dvars for old
if Engine[@"getdvarstring"]("shield_old_map") == "" and Engine[@"getdvarstring"]("shield_old_gametype") == "" then
	Engine[@"exec"](Engine[@"getprimarycontroller"](), "set shield_old_map " .. "mp_seaside")
	Engine[@"exec"](Engine[@"getprimarycontroller"](), "set shield_old_gametype " .. "tdm")
end

---------------------------


CoD.MatchmakingDvarsReload = function()
	-- Dvars for Matchmaking..
	Dvar[@"party_minplayers"]:set(1)
	--Dvar[@"hash_68827F6EDED32B08"]:set(true)
	Dvar[@"lobbytimerstartinterval"]:set(0)
	Dvar[@"lobbycptimerstartinterval"]:set(0)
	Dvar[@"lobbycpzmtimerstartinterval"]:set(0)

	-- time to choose before custom
	Dvar[@"lobbytimerstatusvotinginterval"]:set(0)

	Dvar[@"lobbytimerstatusbegininterval"]:set(0)
	Dvar[@"lobbytimerstatusstartinterval"]:set(0)

	-- after match, WE DONT WANT THAT
	Dvar[@"lobbytimerstatuspostgameinterval"]:set(200000)
end

CoD.ChangeToOldMapGameType = function(controller)
	if IsLobbyHostOfCurrentMenu() then
		CoD.EnhPrintInfo("setting old map and gametype back....")

		-- set map from same match
		local old_map = Engine[@"getdvarstring"]("shield_old_map")
		SetMap(controller, Engine[@"converttoxhash"](old_map))

		-- set map from same match
		local old_gametype = Engine[@"getdvarstring"]("shield_old_gametype")
		SetGameType(controller, old_gametype)
	end
end