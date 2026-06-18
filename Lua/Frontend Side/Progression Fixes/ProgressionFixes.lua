--[[
		.\hksc.exe ".\Lua\ProgressionFixes.Lua" -o "C:\Program Files (x86)\Call of Duty Black Ops 4\project-bo4\mods\T8ShieldSupport\Lua\ProgressionFixes.luac"
]]

---------------------------

CoD.ShieldInitLuaFile()

---------------------------

-- some fixes
CoD.OverlayUtility.AddSystemOverlay( "ShieldPrestigeActivate", {
	menuName = "SystemOverlay_Full",
	frameWidget = "CoD.systemOverlay_Prestige",
	title = Engine[@"hash_4F9F1239CFD921FE"]( @"shield/prestige" ),
	subtitle = Engine[@"hash_4F9F1239CFD921FE"]( @"hash_0" ), -- not needed
	prestigeLayout = CoD.PrestigeUtility.PrestigeOverlayLayouts.RequestProcessing,
	categoryType = CoD.OverlayUtility.OverlayTypes.Unlock,
	[CoD.OverlayUtility.GoBackPropertyName] = CoD.OverlayUtility.DefaultGoBack
} )

CoD.OverlayUtility.AddSystemOverlay( "ShieldFreshStartActivate", {
	menuName = "SystemOverlay_Full",
	frameWidget = "CoD.systemOverlay_Prestige",
	title = Engine[@"hash_4F9F1239CFD921FE"]( @"shield/fresh_start" ),
	subtitle = Engine[@"hash_4F9F1239CFD921FE"]( @"hash_0" ),
	prestigeLayout = CoD.PrestigeUtility.PrestigeOverlayLayouts.RequestProcessing,
	categoryType = CoD.OverlayUtility.OverlayTypes.Unlock,
	[CoD.OverlayUtility.GoBackPropertyName] = CoD.OverlayUtility.DefaultGoBack
} )

CoD.PrestigeUtility.ShowFreshStart = function ( f51_arg0 )
	return not IsPrestigeLevelAtZero( f51_arg0 )
end

CoD.PrestigeUtility.EnterPrestigeAction = function ( f13_arg0, f13_arg1, f13_arg2 )
	local PrestigeCurrent = Engine[@"getstatbyname"]( Engine[@"getprimarycontroller"](), "PLEVEL" )

	if PrestigeCurrent then
		RankUtils.SetRank(0)
		RankUtils.SetPrestige(PrestigeCurrent + 1)

		OpenSystemOverlay(f13_arg0, f13_arg0, f13_arg1, "ShieldPrestigeActivate", nil)
		CoD.EnhPrintInfo("Next Prestige Success!")
	else
		OpenSystemOverlay(f13_arg0, f13_arg0, f13_arg1, "RequestProcessingFailedOverlay", nil)
		CoD.EnhPrintInfo("Next Prestige Failed!")
	end
end

CoD.PrestigeUtility.FreshStartAction = function ( f18_arg0, f18_arg1, f18_arg2 )
	-- offline stats
	Engine[@"exec"](Engine[@"getprimarycontroller"](), "exec gamedata/stats/zm/playerstats_reset.cfg")
	Engine[@"exec"](Engine[@"getprimarycontroller"](), "exec gamedata/stats/mp/playerstats_reset.cfg")

	-- live stats
	RankUtils.SetRank(0)
	RankUtils.SetPrestige(0)

	OpenSystemOverlay(f18_arg0, f18_arg0, f18_arg1, "ShieldFreshStartActivate", nil)

	CoD.EnhPrintInfo("Fresh Restart Done")
end

CoD.CACUtility.IsProgressionEnabled = function ( f218_arg0 )
	return true
end

CoD.CACUtility.IsProgressionWithWarzoneEnabled = function ( f219_arg0 )
	--CoD.EnhPrintInfo("Returned True", "IsProgressionWithWarzoneEnabled")
	return true
end