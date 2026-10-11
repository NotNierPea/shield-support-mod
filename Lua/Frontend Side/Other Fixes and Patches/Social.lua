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