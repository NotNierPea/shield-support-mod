--[[
		.\hksc.exe ".\Lua\ReloadOverrides.Lua" -o "C:\Program Files (x86)\Call of Duty Black Ops 4\project-bo4\mods\T8ShieldSupport\Lua\Game\ReloadOverrides.luac"
]]

---------------------------

if CoD.isFrontend then
	return
end

CoD.ShieldInitLuaFile()

---------------------------

CoD.LoadOveridesSpawn = function()
	-- chat
	CoD.ChatOverride()
	
	-- wz public
	CoD.BlackoutStartButtonReload()

	-- subtitles fixes, and other
	local HUD_FirstSnapshot_Common_Original = HUD_FirstSnapshot_Common
	function HUD_FirstSnapshot_Common(f58_arg0, f58_arg1)
	      Engine[@"PrintInfo"](0, "^3Reseted Subtitles!")

		  CoD.ResetRoundPatch()

		  -- reset rpc too
		  CoD.ResetRPC()

		  -- flash hashes (zm only)
		  CoD.FlashHashes(f58_arg1.controller)

		  -- fix for zm fast restart
	      CoD.FixSubtitles(f58_arg1.controller)
		  
	      HUD_FirstSnapshot_Common_Original(f58_arg0, f58_arg1)
	end

	CoD.ApplyRoundPatches()

	-- send reactive force stage dvar
	CoD.SentReativeForceStage(Engine[@"getprimarycontroller"]())
end

-- for wz
CoD.PCUtility.AreUIShortcutInputLocked = function ( f18_arg0 )
	CoD.LoadOveridesSpawn()

	local f18_local0 = Engine[@"getmodelforcontroller"]( f18_arg0 )
	return f18_local0.LockUIShortcutInput:get()
end

-- other modes
CoD.PCUtility.MenuChatToggleShouldBeVisible = function ( f388_arg0, f388_arg1, f388_arg2 )
	CoD.EnhPrintInfo("Returned True", "MenuChat and Load Overides")

	CoD.LoadOveridesSpawn()

	return true
end