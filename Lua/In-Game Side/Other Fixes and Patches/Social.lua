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

-- "Send Friend Request" in the menu of a right click on a player: sent by xuid, and not offered for a player who is blocked
require( "ui/utility/socialutility" )

if CoD.SocialUtility.GetFriendsButtonOptions and not CoD.ShieldGetFriendsButtonOptions then
	CoD.ShieldGetFriendsButtonOptions = CoD.SocialUtility.GetFriendsButtonOptions
	CoD.SocialUtility.GetFriendsButtonOptions = function ( f1_arg0, f1_arg1, f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6 )
		local options = CoD.ShieldGetFriendsButtonOptions( f1_arg0, f1_arg1, f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6 )
		local blocked = f1_arg2 ~= nil and Engine[@"isplayerblocked"]( f1_arg2 )
		for index = #options, 1, -1 do
			local option = options[index]
			if option.id == "sendFriendRequest" then
				if blocked then
					if option.lastInGroup and index > 1 then
						options[index - 1].lastInGroup = true
					end
					table.remove( options, index )
				else
					option.action = function ( self, element, controller, params, menu )
						if params and params.xuid then
							Engine[@"hash_AF6BD480E7BDBAB"]( params.xuid )
						end
					end
				end
			end
		end
		return options
	end
end
