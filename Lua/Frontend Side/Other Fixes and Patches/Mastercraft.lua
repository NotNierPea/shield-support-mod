--[[
		.\hksc.exe ".\Lua\Mastercraft.Lua" -o "C:\Program Files (x86)\Call of Duty Black Ops 4\project-bo4\mods\T8ShieldSupport\Lua\Mastercraft.luac"
]]

---------------------------

CoD.ShieldInitLuaFile()

---------------------------

-- allow camos on mastercrafts
CoD.CACUtility.OpenWeaponPersonalizationOverlay = function ( f266_arg0, f266_arg1, f266_arg2, f266_arg3, f266_arg4, f266_arg5 )
	local f266_local0 = "WeaponPersonalization"
	--if CoD.SafeGetModelValue( f266_arg4:getModel(), "isMastercraft" ) then
	--	f266_local0 = "WeaponTabbedAccessoriesSelect"
	--end
	CoD.CACUtility.OpenCACOverlay( f266_arg0, f266_arg1, f266_arg2, f266_local0, f266_arg3, f266_arg5 )
end

CoD.MasterCraftReload = function()
	CoD.CACUtility.OpenWeaponPersonalizationOverlay = function ( f266_arg0, f266_arg1, f266_arg2, f266_arg3, f266_arg4, f266_arg5 )
		local f266_local0 = "WeaponPersonalization"
		--if CoD.SafeGetModelValue( f266_arg4:getModel(), "isMastercraft" ) then
		--	f266_local0 = "WeaponTabbedAccessoriesSelect"
		--end
		CoD.CACUtility.OpenCACOverlay( f266_arg0, f266_arg1, f266_arg2, f266_local0, f266_arg3, f266_arg5 )
	end
end