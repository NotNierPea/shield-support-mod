--[[
		.\hksc.exe ".\Lua\RankUtils.Lua" -o "C:\Program Files (x86)\Call of Duty Black Ops 4\project-bo4\mods\T8ShieldSupport\Lua\RankUtils.luac"
]]

---------------------------

CoD.ShieldInitLuaFile()

---------------------------

-- Wanted Stuff and Utils for Stats..
CoD.RankUtils = {}

CoD.RankUtils.GetLevelXP = function(level)
	local sessionmode = Engine[@"CurrentSessionMode"]()
	local rankTable = ""
	local rankMult
	local rankTT
	local XP = 0

	local Prestige = Engine[@"getstatbyname"](Engine[@"getprimarycontroller"](), "plevel")

	local isPrestigeMaster = Prestige ~= nil and tonumber(Prestige) == 11

	if isPrestigeMaster == false then
		if sessionmode == Enum[@"emodes"][@"mode_multiplayer"] then -- mp
			rankTable = "gamedata/shield/rankutils/maxrankdata_mp.csv"
		end
		if sessionmode == Enum[@"emodes"][@"mode_zombies"] then -- zm
			rankTable = "gamedata/shield/rankutils/maxrankdata_zm.csv"
		end
		if sessionmode == Enum[@"emodes"][@"mode_warzone"] then -- wz
			rankTable = "gamedata/shield/rankutils/maxrankdata_wz.csv"
		end
	else
		if sessionmode == Enum[@"emodes"][@"mode_multiplayer"] then -- mp
			rankMult = 55600
			rankTT = 55
		end
		if sessionmode == Enum[@"emodes"][@"mode_zombies"] then -- zm
			rankMult = 57600
			rankTT = 55
		end
		if sessionmode == Enum[@"emodes"][@"mode_warzone"] then -- wz
			rankMult = 7500
			rankTT = 81
		end
		local leveldiff = tonumber(level) - rankTT
		return rankMult * leveldiff
	end

	if rankTable ~= "" then
		local row = tonumber(level) - 1
		XP = tonumber(Engine[@"TableLookupGetColumnValueForRow"](rankTable, row, 0))
	end

	if XP == nil then
		XP = 0
	end

	CoD.EnhPrintInfo(XP, "XP Data")

	return XP
end

CoD.RankUtils.SetRank = function(level)
	if not level then return end

	-- local currentPrestige = CoD.PrestigeUtility.GetCurrentPLevel(controller, Engine.CurrentSessionMode())
	-- local currentRank = CoD.BlackMarketUtility.GetCurrentRank(controller) + 1

	local Prestige = Engine[@"getstatbyname"](Engine[@"getprimarycontroller"](), "plevel")
	local sessionmode = Engine[@"CurrentSessionMode"]()

	local isPrestigeMaster = Prestige ~= nil and tonumber(Prestige) == 11
	local maxXP = CoD.RankUtils.GetLevelXP(tonumber(level))

	if isPrestigeMaster == false then
		Engine[@"execnow"](Engine[@"getprimarycontroller"](), "statsetbyname rank " .. tonumber(level))
		Engine[@"execnow"](Engine[@"getprimarycontroller"](), "statsetbyname rankxp " .. maxXP)
		Engine[@"execnow"](Engine[@"getprimarycontroller"](), "statsetbyname paragon_rankxp " .. 0)	
	else
		Engine[@"execnow"](Engine[@"getprimarycontroller"](), "statsetbyname rank " .. 55)

		if sessionmode == Enum[@"emodes"][@"mode_warzone"] then
			Engine[@"execnow"](Engine[@"getprimarycontroller"](), "statsetbyname rankxp " .. CoD.RankUtils.GetLevelXP(81))
		else
			Engine[@"execnow"](Engine[@"getprimarycontroller"](), "statsetbyname rankxp " .. CoD.RankUtils.GetLevelXP(55))
		end

		Engine[@"execnow"](Engine[@"getprimarycontroller"](), "statsetbyname paragon_rank " .. tonumber(level)) -- rank for prestige master
		Engine[@"execnow"](Engine[@"getprimarycontroller"](), "statsetbyname paragon_rankxp " .. maxXP)
	end

	-- shield api to fix online stats here...
	local RankFix = string.format("%0.2i", level)

	if sessionmode == Enum[@"emodes"][@"mode_multiplayer"] then -- mp
		--Engine[@"exec"](Engine[@"getprimarycontroller"](), "setplayerstat mp rank " .. RankFix)
		--Engine[@"exec"](Engine[@"getprimarycontroller"](), "setplayerstat mp xp " .. maxXP)
	end
	if sessionmode == Enum[@"emodes"][@"mode_zombies"] then -- zm
		--Engine[@"exec"](Engine[@"getprimarycontroller"](), "setplayerstat zm rank " .. RankFix)
		--Engine[@"exec"](Engine[@"getprimarycontroller"](), "setplayerstat zm xp " .. maxXP)
	end
	if sessionmode == Enum[@"emodes"][@"mode_warzone"] then -- wz
		--Engine[@"exec"](Engine[@"getprimarycontroller"](), "setplayerstat wz rank " .. RankFix)
		--Engine[@"exec"](Engine[@"getprimarycontroller"](), "setplayerstat wz xp " .. maxXP)
	end

	Engine[@"exec"](Engine[@"getprimarycontroller"](), "uploadstats " .. tostring(Engine[@"CurrentSessionMode"]()))
end

CoD.RankUtils.SetPrestige = function(prestige)
	if not prestige then return end

	local sessionmode = Engine[@"CurrentSessionMode"]()

	-- local currentPrestige = CoD.PrestigeUtility.GetCurrentPLevel(controller, Engine.CurrentSessionMode())
	if tonumber(prestige) == 11 then
		-- prestige master here..
		Engine[@"execnow"](Engine[@"getprimarycontroller"](), "statsetbyname plevel " .. tonumber(11))
		Engine[@"exec"](Engine[@"getprimarycontroller"](), "PrestigeStatsMaster " .. tostring(Engine[@"CurrentSessionMode"]()))

		if sessionmode == Enum[@"emodes"][@"mode_warzone"] then -- wz
			Engine[@"execnow"](Engine[@"getprimarycontroller"](), "statsetbyname paragon_rank 81") -- rank for prestige master
		else
			Engine[@"execnow"](Engine[@"getprimarycontroller"](), "statsetbyname paragon_rank 55")
		end

		Engine[@"execnow"](Engine[@"getprimarycontroller"](), "statsetbyname paragon_rankxp 0")
	else
		Engine[@"execnow"](Engine[@"getprimarycontroller"](), "statsetbyname plevel " .. tonumber(prestige))
	end

	-- shield api to fix online stats here...
	local PrestigeFix = string.format("%0.2i", prestige)

	if sessionmode == Enum[@"emodes"][@"mode_multiplayer"] then -- mp
		--Engine[@"exec"](Engine[@"getprimarycontroller"](), "setplayerstat mp prestige " .. PrestigeFix)
	end
	if sessionmode == Enum[@"emodes"][@"mode_zombies"] then -- zm
		--Engine[@"exec"](Engine[@"getprimarycontroller"](), "setplayerstat zm prestige " .. PrestigeFix)
	end
	if sessionmode == Enum[@"emodes"][@"mode_warzone"] then -- wz
		--Engine[@"exec"](Engine[@"getprimarycontroller"](), "setplayerstat wz prestige " .. PrestigeFix)
	end

	Engine[@"exec"](Engine[@"getprimarycontroller"](), "uploadstats " .. tostring(Engine[@"CurrentSessionMode"]()))
end