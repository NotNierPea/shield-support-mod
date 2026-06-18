--[[
		.\hksc.exe ".\Lua\ZombiesEasterEggChecks.Lua" -o "C:\Program Files (x86)\Call of Duty Black Ops 4\project-bo4\mods\T8ShieldSupport\Lua\ZombiesEasterEggChecks.luac"
]]

---------------------------

CoD.ShieldInitLuaFile()

---------------------------

CoD.called_ee_check = false
CoD.Shield.Check_Settings_Mutations = function(undef)
	if CoD.ZombieUtility and CoD.ZombieUtility.IsEasterEggsAllowed and CoD.OptionsUtility and CoD.OptionsUtility.AreAllCustomGameOptionsDefault and CoD.called_ee_check then
		CoD.called_ee_check = false
		local bool_ee = CoD.ZombieUtility.IsEasterEggsAllowed(0) and CoD.OptionsUtility.AreAllCustomGameOptionsDefault(0)

		if bool_ee and bool_ee == true then
			return 1
		else
			return 0
		end
	end

	return 0
end