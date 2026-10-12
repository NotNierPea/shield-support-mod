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


-- the lobby timers and the players a lobby waits for are the game's own now: a server runs its lobby by them

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