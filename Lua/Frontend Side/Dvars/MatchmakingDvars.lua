--[[
		.\hksc.exe ".\Lua\MatchmakingDvars.Lua" -o "C:\Program Files (x86)\Call of Duty Black Ops 4\project-bo4\mods\T8ShieldSupport\Lua\MatchmakingDvars.luac"
]]

---------------------------

CoD.ShieldInitLuaFile()

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