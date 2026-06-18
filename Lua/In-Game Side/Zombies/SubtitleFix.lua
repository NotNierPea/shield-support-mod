--[[
		.\hksc.exe ".\Lua\SubtitleFix.Lua" -o "C:\Program Files (x86)\Call of Duty Black Ops 4\project-bo4\mods\T8ShieldSupport\Lua\Game\SubtitleFix.luac"
]]

---------------------------

if CoD.isFrontend then
	return
end

CoD.ShieldInitLuaFile()

---------------------------

CoD.FixSubtitles = function(controller)
	CoD.SubtitleUtility.ClearSubtitleModels(controller)
end