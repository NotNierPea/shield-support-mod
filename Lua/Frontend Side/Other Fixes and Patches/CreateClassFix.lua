--[[
		.\hksc.exe ".\Lua\CreateClassFix.Lua" -o "C:\Program Files (x86)\Call of Duty Black Ops 4\project-bo4\mods\T8ShieldSupport\Lua\CreateClassFix.luac"
]]

---------------------------

CoD.ShieldInitLuaFile()

---------------------------

CoD.CreateClassFixReload = function()
	-- create a class disappearing fix
	CoD.DirectorUtility.HideCustomizationPlaylistGametypes = {
		
	}

	CoD.DirectorUtility.HideCustomizationGametypes = {

	}
end