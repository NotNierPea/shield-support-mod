--[[
		.\hksc.exe ".\Lua\Social.Lua" -o "C:\Program Files (x86)\Call of Duty Black Ops 4\project-bo4\mods\T8ShieldSupport\Lua\Game\Social.luac"
]]

---------------------------

if CoD.isFrontend then
	return
end

CoD.ShieldInitLuaFile()

---------------------------

CoD.PCUtility.IsBGSEnabled = function ()
	return true
end

CoD.PCUtility.CanOpenSocialMenu = function ( f31_arg0, f31_arg1 )
	--CoD.EnhPrintInfo("Returned True", "Social Menu")
	return true
end