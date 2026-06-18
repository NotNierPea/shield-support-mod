--[[
		.\hksc.exe ".\Lua\DiscordRPC.Lua" -o "C:\Program Files (x86)\Call of Duty Black Ops 4\project-bo4\mods\T8ShieldSupport\Lua\Game\DiscordRPC.luac"
]]

---------------------------

if CoD.isFrontend then
	return
end

CoD.ShieldInitLuaFile()

---------------------------

-- set dvars
Dvar[@"shield_rpc_round"]:set(0)

CoD.ResetRPC = function()
	-- reset dvars
	Dvar[@"shield_rpc_round"]:set(0)
end

CoD.SetRoundRPC = function(round)
	Dvar[@"shield_rpc_round"]:set(round)
end