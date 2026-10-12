--[[
		.\hksc.exe ".\Lua\Social.Lua" -o "C:\Program Files (x86)\Call of Duty Black Ops 4\project-bo4\mods\T8ShieldSupport\Lua\Social.luac"
]]

---------------------------

CoD.ShieldInitLuaFile()

---------------------------

CoD.PCUtility.IsBGSEnabled = function ()
	return true
end

CoD.PCUtility.CanOpenSocialMenu = function ( f31_arg0, f31_arg1 )
	--CoD.EnhPrintInfo("Returned True", "Social Menu")
	return true
end

-- Inspect takes the rank of a player from a profile cache that is empty here, and wrote it over the rank its rows show
require( "ui/utility/rankutility" )
require( "ui/utility/socialutility" )

if DataSources.SocialPlayerInfo and not CoD.ShieldSocialPlayerInfoGetModel then
	CoD.ShieldSocialPlayerInfoGetModel = DataSources.SocialPlayerInfo.getModel
	DataSources.SocialPlayerInfo.getModel = function ( controller )
		local controllerModel = Engine[@"getmodelforcontroller"]( controller )
		local xuidModel = controllerModel:create( "Social.selectedFriendXUID" )
		local xuid = xuidModel:get()
		local key = xuid and Engine[@"hash_75065E759595C457"]( xuid )
		local cached = key and CoD.RankUtility.CachedRankInfo[key]
		local kept = nil
		if cached then
			kept = {
				current = cached.current
			}
			for _, mode in pairs( CoD.RankUtility.CachedRankFieldForRankMode ) do
				if type( cached[mode] ) == "table" then
					kept[mode] = LUI.ShallowCopy( cached[mode] )
				end
			end
		end
		local model = CoD.ShieldSocialPlayerInfoGetModel( controller )
		if kept then
			cached = CoD.RankUtility.CachedRankInfo[key]
			for _, mode in pairs( CoD.RankUtility.CachedRankFieldForRankMode ) do
				if kept[mode] then
					cached[mode] = kept[mode]
				end
			end
			if kept.current and kept[kept.current] then
				CoD.RankUtility.CreateOrUpdateRankInfoModel( key, kept.current, kept[kept.current] )
			end
		end
		return model
	end
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

-- A dedicated server hosts the lobby and is no player: it is left out of the list of the lobby
if CoD.LobbyUtility and CoD.LobbyUtility.GetClientList and not CoD.ShieldGetClientList then
	CoD.ShieldGetClientList = CoD.LobbyUtility.GetClientList
	CoD.LobbyUtility.GetClientList = function ()
		local clients = CoD.ShieldGetClientList()
		if Engine[@"lobbyconnectedtodedicatedhost"]() == true then
			local host = Engine[@"getlobbyhostxuid"]( Enum[@"lobbytype"][@"lobby_type_game"] )
			for index = #clients, 1, -1 do
				if clients[index].xuid == host then
					table.remove( clients, index )
				end
			end
		end
		return clients
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
