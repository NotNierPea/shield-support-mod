--[[
		.\hksc.exe ".\Lua\RankUtils.Lua" -o "C:\Program Files (x86)\Call of Duty Black Ops 4\project-bo4\mods\T8ShieldSupport\Lua\RankUtils.luac"
]]

---------------------------

CoD.ShieldInitLuaFile()

---------------------------

-- Wanted Stuff and Utils for Stats..
CoD.RankUtils = {}

local PRESTIGE_MASTER = 11

--[[
	The rank stats are 0 based (rank 0 is level 1). Weapons and items unlock by the rank of rankxp
	(LiveStats_GetRank -> CL_Rank_GetRankForXP), never by the rank stat, so the two always go together.
	A row of maxrankdata is the xp a rank ends at, which is the xp the next one starts at.
]]
local function ModeData()
	local sessionmode = Engine[@"CurrentSessionMode"]()

	if sessionmode == Enum[@"emodes"][@"mode_zombies"] then
		return "gamedata/shield/rankutils/maxrankdata_zm.csv", 54, 57600
	elseif sessionmode == Enum[@"emodes"][@"mode_warzone"] then
		return "gamedata/shield/rankutils/maxrankdata_wz.csv", 80, 7500
	end

	return "gamedata/shield/rankutils/maxrankdata_mp.csv", 54, 55600
end

local function IsPrestigeMaster()
	local Prestige = Engine[@"getstatbyname"](Engine[@"getprimarycontroller"](), "plevel")
	return Prestige ~= nil and tonumber(Prestige) == PRESTIGE_MASTER
end

-- queued runs after what the buffer already holds, like PrestigeStatsMaster
local function SetStat(name, value, queued)
	local command = "statsetbyname " .. name .. " " .. tostring(value)

	if queued then
		Engine[@"exec"](Engine[@"getprimarycontroller"](), command)
	else
		Engine[@"execnow"](Engine[@"getprimarycontroller"](), command)
	end
end

local function UploadStats()
	Engine[@"exec"](Engine[@"getprimarycontroller"](), "uploadstats " .. tostring(Engine[@"CurrentSessionMode"]()))
end

-- a prestige master stays at the top rank, its unlocks with it
local function SetTopRank(queued)
	local _, maxRank = ModeData()
	SetStat("rank", maxRank, queued)
	SetStat("rankxp", CoD.RankUtils.GetRankXP(maxRank), queued)
end

CoD.RankUtils.GetRankXP = function(rank)
	local rankTable, maxRank = ModeData()
	rank = math.min(tonumber(rank) or 0, maxRank)

	if rank <= 0 then
		return 0
	end

	return tonumber(Engine[@"TableLookupGetColumnValueForRow"](rankTable, rank - 1, 0)) or 0
end

-- paragon ranks follow the top rank, one every paragonXP (CL_Rank_GetParagonRankForXP)
CoD.RankUtils.GetParagonXP = function(rank)
	local _, maxRank, paragonXP = ModeData()
	return math.max((tonumber(rank) or 0) - (maxRank + 1), 0) * paragonXP
end

CoD.RankUtils.GetLevelXP = function(level)
	if IsPrestigeMaster() then
		return CoD.RankUtils.GetParagonXP(level)
	end
	return CoD.RankUtils.GetRankXP(level)
end

CoD.RankUtils.SetRank = function(level)
	if not level then return end
	level = tonumber(level)

	if IsPrestigeMaster() then
		-- the level is a paragon rank, the rank under it stays at the top
		SetTopRank()
		SetStat("paragon_rank", level)
		SetStat("paragon_rankxp", CoD.RankUtils.GetParagonXP(level))
	else
		local _, maxRank = ModeData()
		level = math.max(math.min(level, maxRank), 0)

		SetStat("rank", level)
		SetStat("rankxp", CoD.RankUtils.GetRankXP(level))
		SetStat("paragon_rankxp", 0)
	end

	UploadStats()
end

CoD.RankUtils.SetPrestige = function(prestige)
	if not prestige then return end
	prestige = tonumber(prestige)

	SetStat("plevel", prestige)

	if prestige == PRESTIGE_MASTER then
		Engine[@"exec"](Engine[@"getprimarycontroller"](), "PrestigeStatsMaster " .. tostring(Engine[@"CurrentSessionMode"]()))

		-- queued after PrestigeStatsMaster so it can't undo them
		local _, maxRank = ModeData()
		SetTopRank(true)
		SetStat("paragon_rank", maxRank + 1, true)
		SetStat("paragon_rankxp", 0, true)
	end

	UploadStats()
end
