--[[
		.\hksc.exe ".\Lua\BlackoutStartMatchButton.Lua" -o "C:\Program Files (x86)\Call of Duty Black Ops 4\project-bo4\mods\T8ShieldSupport\Lua\Game\BlackoutStartMatchButton.luac"
]]

---------------------------

if CoD.isFrontend then
	return
end

CoD.ShieldInitLuaFile()

---------------------------

-- wz public
CoD.PCUtility.CanShowStartWarzoneButton = function ( f451_arg0, f451_arg1 )
	local bool_v = IsInGame()
	if bool_v then
		bool_v = CoD.HUDUtility.IsWarzone()
		if bool_v then
			bool_v = CoD.WZUtility.AllowWZOffline() -- returns true anyways
			if bool_v then
				bool_v = IsLobbyHost()
				if bool_v then
					bool_v = --[[IsCustomLobby()]] true
					if bool_v then
						if not CoD.ModelUtility.IsControllerModelValueTrue( f451_arg1, "hudItems.hasStartedWZMatch" ) then
							bool_v = IsCurrentMenu( f451_arg0, "StartMenu_Main" )
						else
							bool_v = false
						end
					end
				end
			end
		end
	end
	return bool_v
end

CoD.BlackoutStartButtonReload = function()
	-- wz public
	CoD.PCUtility.CanShowStartWarzoneButton = function ( f451_arg0, f451_arg1 )
		local bool_v = IsInGame()
		if bool_v then
			bool_v = CoD.HUDUtility.IsWarzone()
			if bool_v then
				bool_v = CoD.WZUtility.AllowWZOffline() -- returns true anyways
				if bool_v then
					bool_v = IsLobbyHost()
					if bool_v then
						bool_v = --[[IsCustomLobby()]] true
						if bool_v then
							if not CoD.ModelUtility.IsControllerModelValueTrue( f451_arg1, "hudItems.hasStartedWZMatch" ) then
								bool_v = IsCurrentMenu( f451_arg0, "StartMenu_Main" )
							else
								bool_v = false
							end
						end
					end
				end
			end
		end
		return bool_v
	end
end