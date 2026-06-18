--[[
		.\hksc.exe ".\Lua\BlackoutWinIcons.Lua" -o "C:\Program Files (x86)\Call of Duty Black Ops 4\project-bo4\mods\T8ShieldSupport\Lua\BlackoutWinIcons.luac"
]]

---------------------------

CoD.ShieldInitLuaFile()

---------------------------

-- fix wz prestige icons
CoD.CustomizePrestigeIconUtility.GetCurrentWins = function ( f5_arg0, f5_arg1 )
	-- useless, only for wz
	return 999
end

CoD.CustomizePrestigeIconUtility.IsIconUnlockedByWins = function ( f3_arg0, f3_arg1 )
	return true
end

CoD.CustomizePrestigeIconUtility.IsIconUnlockedByLevel = function ( f4_arg0, f4_arg1, f4_arg2, f4_arg3, f4_arg4 )

	-- failed func for WZ?
	--if f4_arg4 == Enum[@"emodes"][@"mode_warzone"] then
	--	return f4_arg0 and f4_arg2 <= f4_arg1 + 1
	--end

	if Engine[@"CurrentSessionMode"]() == Enum[@"emodes"][@"mode_warzone"] then
		return f4_arg0 and f4_arg2 <= f4_arg1
	end
	
	local f4_local0 = f4_arg0
	local f4_local1
	if f4_arg2 > f4_arg1 + 1 and f4_arg3 ~= Enum[@"hash_79FC886F1051643D"][@"hash_6CBFFC10B9836971"] then
		f4_local1 = false
	else
		f4_local1 = f4_local0 and true
	end
	return f4_local1
end

---------------------------

-- Prestige Icons (fix wz mode)
DataSources.PrestigeIcon = ListHelper_SetupDataSource( "PrestigeIcon", function ( f11_arg0 )
	local f11_local0 = {}
	local f11_local1 = CoD.PrestigeUtility.GetPrestigeGameMode()
	local f11_local2 = Engine[@"getparagonicontable"]( f11_local1 )

	-- nope
	if not f11_local2 then 
		CoD.EnhPrintInfo("not good...")
		return
	end

	local f11_local3 = CoD.PrestigeUtility.GetCurrentLevel( f11_arg0, f11_local1 )
	local f11_local4 = CoD.PrestigeUtility.GetPrestigeCap( f11_local1 ) <= CoD.PrestigeUtility.GetCurrentPLevel( f11_arg0, f11_local1 )

	-- line fail
	local f11_local5 = CoD.CustomizePrestigeIconUtility.GetCurrentWins( f11_arg0, f11_local1 )

	local f11_local6 = CoD.CustomizePrestigeIconUtility.GetCurrentParagonIconId( f11_arg0, f11_local1 )
	
	if f11_local2 and f11_local2.icons and #f11_local2.icons > 0 then
		for f11_local11, f11_local12 in ipairs( f11_local2.icons ) do
			local f11_local13 = table.insert
			local f11_local14 = f11_local0
			local f11_local15 = {}
			local f11_local16 = {
				iconId = f11_local12.iconId,
				iconImage = f11_local12.iconNameLarge,
				iconName = f11_local12.displayName,
				iconOriginString = CoD.CustomizePrestigeIconUtility.EnumToTitleOfOriginString( f11_local12.titleOfOrigin ),
				rankRequirementString = CoD.CustomizePrestigeIconUtility.RankToRankRequirementString( f11_local12.unlockLevel )
			}

			--local f11_local10

			-- changed from wins to level instead for wz (unused wins mode)
			f11_local16.isLocked = not CoD.CustomizePrestigeIconUtility.IsIconUnlockedByLevel( f11_local4, f11_local3, f11_local12.unlockLevel, f11_local1 )
			f11_local16.isEquipped = f11_local6 == f11_local12.iconId
			f11_local16.isLockedByWins = not CoD.CustomizePrestigeIconUtility.IsIconUnlockedByLevel( f11_local4, f11_local3, f11_local12.unlockLevel, f11_local1 )
			f11_local15.models = f11_local16
			f11_local13( f11_local14, f11_local15 )
		end
	end
	return f11_local0
end, true )