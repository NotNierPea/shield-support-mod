--[[
		.\hksc.exe ".\Lua\Social.Lua" -o "C:\Program Files (x86)\Call of Duty Black Ops 4\project-bo4\mods\T8ShieldSupport\Lua\Game\Social.luac"
]]

---------------------------

if CoD.isFrontend then
	return
end

CoD.ShieldInitLuaFile()

---------------------------

CoD.PCUtility.IsBGSEnabled = function ()
	return true
end

CoD.PCUtility.CanOpenSocialMenu = function ( f31_arg0, f31_arg1 )
	--CoD.EnhPrintInfo("Returned True", "Social Menu")
	return true
end

-- the game says "invalid" for a name with no # or @ (a BattleTag), the master server takes a plain name
CoD.PCUtility.FriendRequestPopup = function ( f303_arg0, f303_arg1, f303_arg2 )
	if f303_arg0.FriendRequestPopup and f303_arg0.FriendRequestPopup.FriendName then
		f303_arg0.FriendRequestPopup.FriendName.FriendName:setText( CoD.SocialUtility.CleanGamerTag( f303_arg2 ) )
		f303_arg0.FriendRequestPopup.RequestSentText:setText( Engine[@"hash_4F9F1239CFD921FE"]( @"hash_21AE94021C967D51" ) )
		f303_arg0.FriendRequestPopup:playClip( "FriendRequestSent" )
	end
end