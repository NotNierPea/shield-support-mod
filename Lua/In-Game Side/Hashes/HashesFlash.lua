--[[
		.\hksc.exe ".\Lua\HashesFlash.Lua" -o "C:\Program Files (x86)\Call of Duty Black Ops 4\project-bo4\mods\T8ShieldSupport\Lua\Game\HashesFlash.luac"
]]

---------------------------

if CoD.isFrontend then
	return
end

CoD.ShieldInitLuaFile()

---------------------------

CoD.FlashHashes = function(controller)
	if IsZombies() then
		Engine[@"exec"](controller, "flashScriptHashes")
	end
end