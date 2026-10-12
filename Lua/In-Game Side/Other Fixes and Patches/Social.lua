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

-- "Whisper" in the menu of a right click on a player. The game's own asks its servers for a chat channel, which
-- are gone: here the chat box of the client is turned to that player (whisper_to), and opened as the game opens it.
-- The menu keeps the functions it was made with, so they are put into its list, not only over the old ones.

CoD.PCWidgetUtility.WhisperPlayer = function ( self, element, controller, params, menu, keepMenu )
	local xuid = params and params.xuid
	if not xuid then
		return
	end

	local name = ""
	if params.gamertag ~= nil and params.gamertag ~= "" then
		name = CoD.SocialUtility.CleanGamerTag( params.gamertag )
	end

	Engine[@"exec"]( controller, "whisper_to " .. Engine[@"uint64tostring"]( xuid ) .. " " .. name )

	local chatting = CoD.ChatClientUtility.GetCurrentChattingModel( controller )
	if chatting and not chatting:get() then
		chatting:set( true )
	end

	CoD.PCBattlenetUtility.CloseBattlenetMenu( element, menu, controller, false )

	if not keepMenu and menu then
		menu:goBack( controller )
	end
end

-- anyone but the player itself and those it blocked
CoD.PCWidgetUtility.ShowWhisperPlayer = function ( controller, element, xuid )
	if Engine[@"getxuid64"]( controller ) == xuid then
		return false
	end
	return not Engine[@"isplayerblocked"]( xuid )
end

if CoD.PCWidgetUtility.PlayerContextualMenuExtraOptionsData then
	for _, option in pairs( CoD.PCWidgetUtility.PlayerContextualMenuExtraOptionsData ) do
		if option.id == "whisperPlayer" then
			option.clickFct = CoD.PCWidgetUtility.WhisperPlayer
			option.visibilityFct = CoD.PCWidgetUtility.ShowWhisperPlayer
		end
	end
end
