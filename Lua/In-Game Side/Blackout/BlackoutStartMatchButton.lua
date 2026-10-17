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

---------------------------

--[[
	The host leaving a public Blackout match after it ended (a win): QuitGame of the game sends the leave of a host
	of a ranked game only while g_gameEnded is not 1, so after the end the button did nothing and the host waited
	out the timer. It is sent then too, and the scripts of the mod end the match on it (MenuReponses.gsc).
]]
local SharedTable = type( CoDShared ) == "table" and CoDShared._originalTable or nil

if SharedTable ~= nil and type( SharedTable.QuitGame ) == "function" and not SharedTable.ShieldHostQuitAfterEnd then
	local QuitGame = SharedTable.QuitGame

	SharedTable.QuitGame = function ( controller, unbalanced )
		local result = QuitGame( controller, unbalanced )

		if Engine[@"currentsessionmode"]() == Enum[@"emodes"][@"mode_warzone"] and Engine[@"getdvarint"]( "g_gameEnded" ) == 1 and CoDShared.IsHost() and CoDShared.IsRankedGame() then
			Engine[@"sendmenuresponse"]( controller, "popup_leavegame", "endround", 0 )
		end

		return result
	end

	SharedTable.ShieldHostQuitAfterEnd = true
end
