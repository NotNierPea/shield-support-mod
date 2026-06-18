--[[
		.\hksc.exe ".\Lua\RemovePopUps.Lua" -o "C:\Program Files (x86)\Call of Duty Black Ops 4\project-bo4\mods\T8ShieldSupport\Lua\RemovePopUps.luac"
]]

---------------------------

CoD.ShieldInitLuaFile()

---------------------------

-- remove annoying new xuid user popups (offer redeem ones)
CoD.EntitlementUtility.OpenEntitlementPopups = function ( f14_arg0, f14_arg1 )
	CoD.EnhPrintInfo("Open Entitlement Popups Removed..")
	return false
end

CoD.EntitlementUtility.OpenEntitlementPopup = function ( f8_arg0, f8_arg1, f8_arg2 )
	CoD.EnhPrintInfo("Entitlement Offer Popups Removed..")
	return false
end

-- prestige one (beta token)
CoD.PrestigeUtility.DisplayBetaRewardInventoryNotification = function ( f17_arg0, f17_arg1, f17_arg2 )
	CoD.EnhPrintInfo("Beta Token Offer Popup Removed..")
	return false
end