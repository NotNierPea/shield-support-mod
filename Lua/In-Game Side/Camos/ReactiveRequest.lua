--[[
		.\hksc.exe ".\Lua\ReactiveRequest.Lua" -o "C:\Program Files (x86)\Call of Duty Black Ops 4\project-bo4\mods\T8ShieldSupport\Lua\Game\ReactiveRequest.luac"
]]

---------------------------

if CoD.isFrontend then
	return
end

CoD.ShieldInitLuaFile()

---------------------------

local SentOnce = false

---------------------------

CoD.SentReativeForceStage = function(controller)
	local dvar_val = Engine[@"getdvarint"]( "shield_active_camo_last" )

	if dvar_val ~= nil and dvar_val ~= 0 and SentOnce == false then
		CoD.BaseUtility.SendCustomMenuResponse(controller, "shield_support_menu", "reactive_apply", dvar_val)

		CoD.EnhPrintInfo("Sent Reactive Request with " .. dvar_val)
		SentOnce = true -- lets not spam it lol
	end
end