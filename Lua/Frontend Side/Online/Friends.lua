--[[
		.\hksc.exe ".\Lua\Friends.Lua" -o "C:\Program Files (x86)\Call of Duty Black Ops 4\project-bo4\mods\T8ShieldSupport\Lua\Friends.luac"
]]

---------------------------

CoD.ShieldInitLuaFile()

---------------------------

local active_friends = {}
local pending_friends = {}

---------------------------

CoD.Shield.OnFriendsListReceived = function(event_name, event_table)
	local friends = event_table.friends
	if friends then
		-- Clear existing
		active_friends = {}

		for i = 1, #friends do
			local friend = friends[i]
			if friend and friend.username and friend.xuid then
				table.insert(active_friends, {
					username = friend.username,
					xuid = friend.xuid,
					status = friend.status,
					activity = friend.activity
				})
			end
		end

		-- Optional debug output
		for i, f in ipairs(active_friends) do
			CoD.EnhPrintInfo("Stored friend: " .. f.username .. " - " .. f.status .. " (XUID: " .. Engine[@"uint64tostring"](f.xuid) .. ")")
		end
	end

	if CoD.Menu.FriendListWidget ~= nil then
		CoD.Menu.FriendListWidget:setDataSource( "ShieldFriendList" )
		CoD.Menu.FriendListWidget:updateDataSource()
	end
end

CoD.Shield.OnPendingFriendRequests = function(event_name, event_table)
	local reqs = event_table.requests
	if reqs then
		pending_friends = {}

		for i = 1, #reqs do
			local entry = reqs[i]
			pending_friends[#pending_friends + 1] = {
				username = entry.username or "unknown",
				xuid = entry.xuid or 0,
				status = entry.status or "?"
			}
		end

		-- Optional debug output
		for i, f in ipairs(pending_friends) do
			CoD.EnhPrintInfo("Stored pending friend: " .. f.username .. " - " .. f.status .. " (XUID: " .. Engine[@"uint64tostring"](f.xuid) .. ")")
		end
	end

	if CoD.Menu.FriendReqWidget ~= nil then
		CoD.Menu.FriendReqWidget:setDataSource( "ShieldFriendReqList" )
		CoD.Menu.FriendReqWidget:updateDataSource()
	end
end

-- add shield friend in user's context menu
CoD.SocialUtility.GetFriendsButtonOptions = function ( f36_arg0, f36_arg1, f36_arg2, f36_arg3, f36_arg4, f36_arg5, f36_arg6 )
	CoD.EnhPrintInfo("GetFriendsButtonOptions")

	local f36_local0 = {}
	local f36_local1 = Engine[@"getmodelforcontroller"]( f36_arg0 )
	local f36_local2 = f36_arg2 == Engine[@"getxuid64"]( f36_arg0 )
	if f36_arg2 == nil then
		return f36_local0
	end
	local f36_local3 = Engine[@"hash_65CB8E6B7FBBFFD5"]( f36_arg2 )
	local f36_local4 = function ()
		if 0 < #f36_local0 then
			f36_local0[#f36_local0].lastInGroup = true
		end
	end
	
	local f36_local5 = Engine[@"getplayerinfo"]( f36_arg0, f36_arg2 )
	local f36_local6 = Engine[@"hash_686E64DD1C270046"]( Enum[@"lobbymodule"][@"lobby_module_client"], Enum[@"lobbytype"][@"lobby_type_private"], f36_arg2 )
	local f36_local7 = Engine[@"hash_686E64DD1C270046"]( Enum[@"lobbymodule"][@"lobby_module_client"], Enum[@"lobbytype"][@"lobby_type_game"], f36_arg2 )
	if f36_local2 == false and IsInFileshare( f36_arg0 ) == false then
		if Engine[@"hash_686E64DD1C270046"]( Enum[@"lobbymodule"][@"lobby_module_client"], Enum[@"lobbytype"][@"lobby_type_private"], f36_arg2 ) then
			if Engine[@"isleader"]( f36_arg0, Enum[@"lobbytype"][@"lobby_type_private"] ) then
				if ShouldShowPromotePlayer( f36_arg0 ) and not f36_local3 then
					table.insert( f36_local0, {
						text = @"hash_5431AAED2A65A9AC",
						id = "promoteToLeader",
						disabled = CoD.DirectorUtility.DisableForCurrentMilestone(),
						action = PromoteToLeader,
						params = {
							controller = f36_arg0,
							xuid = f36_arg2
						}
					} )
				end
				if Engine[@"islocalclient"]( f36_arg2 ) == false then
					table.insert( f36_local0, {
						text = @"hash_3FEF051FC818F01B",
						id = "removeFromParty",
						disabled = false,
						action = DisconnectClient,
						params = {
							controller = f36_arg0,
							xuid = f36_arg2
						}
					} )
				end
			end
		else
			if f36_arg4 == true then
				local f36_local8 = Engine[@"isfriendfromxuid"]( f36_arg0, f36_arg2 )
				if f36_local5.info.joinable == Enum[@"lobbyjoinable"][@"lobby_joinable_yes"] or f36_local8 and f36_local5.info.joinable == Enum[@"lobbyjoinable"][@"lobby_joinable_yes_friends_only"] then
					local f36_local9 = true
					if f36_local5.info.mapid then
						local f36_local10 = f36_local5.info.mapid
						if f36_local10 then
							f36_local10 = CoD.BaseUtility.GetMapDataFromMapID( f36_local5.info.mapid )
						end
						local f36_local11 = f36_local10 and f36_local10.session_mode
						if f36_local11 and f36_local11 == Enum[@"emodes"][@"mode_multiplayer"] then
							local f36_local12 = Engine[@"ownseasonpass"]( f36_arg0 )
						end
						f36_local9 = f36_local12 or CoD.MapUtility.LobbyHasMap( f36_local5.info.mapid )
					end
					if f36_local9 then
						if f36_local8 then
							table.insert( f36_local0, {
								text = @"hash_4E49D0B0BAC3E752",
								id = "joinGame",
								disabled = false,
								action = SocialJoin,
								params = {
									controller = f36_arg0,
									xuid = f36_arg2,
									joinType = Enum[@"jointype"][@"join_type_friend"],
									goBack = true
								}
							} )
						else
							table.insert( f36_local0, {
								text = @"hash_4E49D0B0BAC3E752",
								id = "joinGame",
								disabled = false,
								action = SocialJoin,
								params = {
									controller = f36_arg0,
									xuid = f36_arg2,
									joinType = Enum[@"jointype"][@"join_type_normal"],
									goBack = true
								}
							} )
						end
					end
				end
			end
			if (not CoD.isPC or f36_arg4) and CoD.canInviteToGame( f36_arg0, f36_arg2, true ) and not f36_local6 and not f36_local7 then
				table.insert( f36_local0, {
					text = @"hash_42EA47C1D2988981",
					id = "inviteToParty",
					disabled = false,
					action = LobbyInviteFriendGoBack,
					params = {
						controller = f36_arg0,
						xuid = f36_arg2,
						gamertag = f36_arg3
					}
				} )
			end
		end
	end
	f36_local4()
	if f36_local5.info.hasEverPlayed == true and not f36_local3 and (not (not f36_arg1 or not f36_arg1.menu or f36_arg1.menu.disableInspection or IsInGame()) or IsPC() and not IsInGame() and f36_arg5 and f36_arg6 ~= "SinglePlayerInspection" and f36_arg6 ~= "LobbyInspection") then
		table.insert( f36_local0, {
			text = @"hash_FF0DBCF80106E7B",
			id = "inspectPlayer",
			disabled = false,
			action = function ( f38_arg0, f38_arg1, f38_arg2, f38_arg3, f38_arg4 )
				SetSelectedFriendXUID( f38_arg0, f38_arg1, f38_arg2 )
				OpenOverlay( f38_arg4, "SinglePlayerInspection", f38_arg2 )
			end,
			params = nil
		} )
	end
	if not IsPC() and not f36_local3 then
		table.insert( f36_local0, {
			text = @"hash_1250EFC225EDF7D0",
			id = "platformProfile",
			disabled = false,
			action = OpenPlatformProfile,
			params = {
				controller = f36_arg0,
				gamertag = f36_arg3,
				xuid = f36_arg2
			}
		} )
	end
	f36_local4()
	if f36_local2 == false and not f36_local3 then
		local f36_local8 = Engine[@"isplayermuted"]( f36_arg0, Enum[@"lobbytype"][@"lobby_type_private"], f36_arg2 )
		if Engine[@"islobbyactive"]( Enum[@"lobbymodule"][@"lobby_module_client"], Enum[@"lobbytype"][@"lobby_type_game"] ) then
			f36_local8 = Engine[@"isplayermuted"]( f36_arg0, Enum[@"lobbytype"][@"lobby_type_game"], f36_arg2 )
		end
		if IsGroupsEnabled( f36_arg0 ) then
			
		else
			
		end
		if not Engine[@"isfriendfromxuid"]( f36_arg0, f36_arg2 ) then
			if IsDurango() then
				table.insert( f36_local0, {
					text = @"hash_7AE669C3D0CBB316",
					id = "sendFriendRequest",
					disabled = false,
					action = OpenPlatformFriendRequest,
					params = {
						controller = f36_arg0,
						gamertag = f36_arg3,
						xuid = f36_arg2
					}
				} )
			elseif not CoD.isPC or not CoD.PCBattlenetUtility.HasSentFriendInvite( f36_arg3 ) then
				table.insert( f36_local0, {
					text = @"shield/send_friend",
					id = "sendFriendRequest",
					disabled = false,
					action = function ( f444_arg0, f444_arg1, f444_arg2, f444_arg3, f444_arg4 )
						local Xxuid = Engine[@"uint64tostring"](f444_arg3.xuid) 
						CoD.EnhPrintInfo("from menu xuid -> " .. Xxuid, "gamertag -> " .. f444_arg3.gamertag)
			
						Engine[@"exec"](Engine[@"getprimarycontroller"](), "addfriend " .. f444_arg3.gamertag)
					end,
					params = {
						controller = f36_arg0,
						gamertag = f36_arg3,
						xuid = f36_arg2
					}
				} )
			end
		end
		f36_local4()
		local f36_local9 = Engine[@"isfriendfromxuid"]( f36_arg0, f36_arg2 )
		if not f36_local9 or f36_local5.info.hasEverBootedGame and f36_local9 then
			table.insert( f36_local0, {
				text = @"hash_2074834ABE9827A3",
				id = "reportPlayer",
				disabled = false,
				action = ShowReportPlayerDialog,
				params = {
					controller = f36_arg0,
					gamertag = f36_arg3,
					xuid = f36_arg2
				}
			} )
		end
		if f36_local6 or f36_local7 then
			if f36_local8 then
				table.insert( f36_local0, {
					text = @"hash_39685D9366015DB",
					id = "unmutePlayer",
					disabled = false,
					action = UnMutePlayer,
					params = {
						controller = f36_arg0,
						xuid = f36_arg2
					}
				} )
			else
				table.insert( f36_local0, {
					text = @"hash_112FAB6BE7D9F2EA",
					id = "mutePlayer",
					disabled = false,
					action = MutePlayer,
					params = {
						controller = f36_arg0,
						xuid = f36_arg2
					}
				} )
			end
		end
	end

	CoD.ClanUtility.AddMemberActions( f36_arg0, f36_arg1, f36_local0, {
		selectedXuid = f36_arg2
	} )
	return f36_local0
end

---------------------------

DataSources.ShieldFriendList = DataSourceHelpers.ListSetup("ShieldFriendList", function(f3_arg0, f3_arg1)
	local InfoFriends = {}

	if active_friends then
		for i = 1, #active_friends do
			local friend = active_friends[i]
			table.insert(InfoFriends, {
				models = {
					FriendName = friend.username or "unknown",
					FriendXUID = Engine[@"uint64tostring"](friend.xuid or 0),
					FriendXUID_Userdata = friend.xuid or 0,
					FriendStatus = (friend.status or "offline") .. " (" .. friend.activity .. ")",
				},
				properties = {}
			})
		end
	end

	return InfoFriends
end, true)

DataSources.ShieldFriendReqList = DataSourceHelpers.ListSetup("ShieldFriendReqList", function(f3_arg0, f3_arg1)
	local InfoFriends = {}

	if pending_friends then
		for i = 1, #pending_friends do
			local req = pending_friends[i]
			table.insert(InfoFriends, {
				models = {
					FriendName = req.username or "unknown",
					FriendXUID = Engine[@"uint64tostring"](req.xuid or 0),
					FriendXUID_Userdata = req.xuid or 0,
					FriendStatus = req.status or "offline",
				},
				properties = {}
			})
		end
	end

	return InfoFriends
end, true)

---------------------------

-- friend
CoD.ShieldFriendRow = InheritFrom( LUI.UIElement )
CoD.ShieldFriendRow.__defaultWidth = 1070
CoD.ShieldFriendRow.__defaultHeight = 107
CoD.ShieldFriendRow.new = function ( f1_arg0, f1_arg1, f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	local self = LUI.UIElement.new( f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	self:setClass( CoD.ShieldFriendRow )
	self.id = "ShieldFriendRow"
	self.soundSet = "default"
	f1_arg0:addElementToPendingUpdateStateList( self )
	
	local BlackBar = LUI.UIImage.new( 0, 1, 0, 0, 0, 1, 1, 1 )
	BlackBar:setRGB( 0.78, 0.78, 0.78 )
	BlackBar:setAlpha( 0.85 )
	BlackBar:setImage( RegisterImage( @"blacktransparent" ) )
	BlackBar:linkToElementModel( self, "FriendXUID_Userdata", true, function ( model )
		local f2_local0 = model:get()
		if f2_local0 ~= nil then
			-- need to wait on emu to send it back (if only first time)
			local ImageID = CoD.FreeCursorUtility.XUIDToEmblemBackgroundId(f2_local0)

			-- if valid or else wait on emu
			if ImageID and ImageID > -1 then
				BlackBar:setImage( RegisterImage(CoD.ChallengesUtility.GetBackgroundByID(ImageID)) )
			else
				self:addElement( LUI.UITimer.newElementTimer( 800, true, function ()
					local ImageID = CoD.FreeCursorUtility.XUIDToEmblemBackgroundId(f2_local0)

					if ImageID and ImageID > -1 then
						BlackBar:setImage( RegisterImage(CoD.ChallengesUtility.GetBackgroundByID(ImageID)) )
					else
						BlackBar:setImage( RegisterImage(@"uie_ui_menu_emblem_grid"))
					end
				end ) )
			end
		end
	end )
	self:addElement( BlackBar )
	self.BlackBar = BlackBar

	local FrameBorder = LUI.UIImage.new( 0, 1, -1, 1, 0, 1, -1, 1 )
	FrameBorder:setAlpha( 0.75 )
	FrameBorder:setImage( RegisterImage( @"uie_ui_menu_store_common_frame" ) )
	FrameBorder:setMaterial( LUI.UIImage.GetCachedMaterial( @"uie_nineslice_add" ) )
	FrameBorder:setShaderVector( 0, 0, 0, 0, 0 )
	FrameBorder:setupNineSliceShader( 12, 12 )
	self:addElement( FrameBorder )
	self.FrameBorder = FrameBorder
	
	local FriendName = LUI.UIText.new( 0, 0, 15, 413, 0, 0, 6.5, 30.5 )
	FriendName:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )
	FriendName:setTTF( "notosans_bold" )
	FriendName:setLetterSpacing( 1 )
	FriendName:setAlignment( Enum[@"hash_67A5123B654282D2"][@"hash_558C8A85F2048829"] )
	FriendName:setAlignment( Enum[@"hash_67A5123B654282D2"][@"hash_3F41D595A2B0EDF3"] )
	self:addElement( FriendName )
	self.FriendName = FriendName
	
	self.FriendName:linkToElementModel( self, "FriendName", true, function ( model )
		local f5_local0 = model:get()
		if f5_local0 ~= nil then
			FriendName:setText(f5_local0)

			self.FriendName = FriendName
		end
	end )

	-- xuid
	local FriendXUID = LUI.UIText.new( 0, 0, 15, 413, 0, 0, 6.5 + 20.5, 30.5 + 20.5 )
	FriendXUID:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )
	FriendXUID:setTTF( "notosans_bold" )
	FriendXUID:setLetterSpacing( 1 )
	FriendXUID:setAlignment( Enum[@"hash_67A5123B654282D2"][@"hash_558C8A85F2048829"] )
	FriendXUID:setAlignment( Enum[@"hash_67A5123B654282D2"][@"hash_3F41D595A2B0EDF3"] )
	self:addElement( FriendXUID )
	self.FriendXUID = FriendXUID
	
	self.FriendXUID:linkToElementModel( self, "FriendXUID", true, function ( model )
		local f5_local0 = model:get()
		if f5_local0 ~= nil then
			FriendXUID:setText("XUID: " .. f5_local0)

			self.FriendXUID = FriendXUID
		end
	end )

	-- status
	local FriendStatus = LUI.UIText.new( 0, 0, 15, 413, 0, 0, 6.5 + 20.5 + 20.5, 30.5 + 20.5 + 20.5 )
	FriendStatus:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )
	FriendStatus:setTTF( "notosans_bold" )
	FriendStatus:setLetterSpacing( 1 )
	FriendStatus:setAlignment( Enum[@"hash_67A5123B654282D2"][@"hash_558C8A85F2048829"] )
	FriendStatus:setAlignment( Enum[@"hash_67A5123B654282D2"][@"hash_3F41D595A2B0EDF3"] )
	self:addElement( FriendStatus )
	self.FriendStatus = FriendStatus

	-- other stuff
	local Mainframe = CoD.StartMenuOptionsMainFrame.new( f1_arg0, f1_arg1, 0, 0, 2.5 + 510 - 25.0 - 1, 108.5 + 510 - 25.0 + 1, 0, 0, 13 - 1, 67 + 1 )
	Mainframe:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )
	Mainframe:setAlpha( 0.05 )
	self:addElement( Mainframe )
	self.Mainframe = Mainframe

	local FriendEmblem = LUI.UIImage.new( 0, 0, 2.5 + 510 - 25.0, 108.5 + 510 - 25.0, 0, 0, 13, 67 )
	FriendEmblem:setZoom( 1 )
	FriendEmblem:linkToElementModel( self, "FriendXUID_Userdata", true, function ( model )
		local f2_local0 = model:get()
		if f2_local0 ~= nil then
			FriendEmblem:setupPlayerEmblemByXUID( f2_local0 )
		end
	end )
	self:addElement( FriendEmblem )
	self.FriendEmblem = FriendEmblem
	
	self.FriendStatus:linkToElementModel( self, "FriendStatus", true, function ( model )
		local f5_local0 = model:get()
		if f5_local0 ~= nil then
			FriendStatus:setText("Status: " .. f5_local0)

			-- color
			if string.find(f5_local0, "offline") then
				FriendStatus:setRGB(1, 0, 0)
				FriendStatus:setText("Status: " .. "offline")
			else
				FriendStatus:setRGB(0, 1, 0)
			end			

			self.FriendStatus = FriendStatus
		end
	end )

	LUI.OverrideFunction_CallOriginalSecond( self, "close", self.__onClose )
	
	if PostLoadFunc then
		PostLoadFunc( self, f1_arg1, f1_arg0 )
	end
	
	return self
end

CoD.ShieldFriendRow.__resetProperties = function ( f7_arg0 )
	f7_arg0.BlackBar:completeAnimation()
	f7_arg0.BlackBar:setRGB( 0.78, 0.78, 0.78 )
end

CoD.ShieldFriendRow.__clipsPerState = {
	DefaultState = {
		DefaultClip = function ( f8_arg0, f8_arg1 )
			f8_arg0:__resetProperties()
			f8_arg0:setupElementClipCounter( 2 )
			f8_arg0.BlackBar:completeAnimation()
			f8_arg0.BlackBar:setRGB( 0.71, 0.71, 0.71 )
			--f8_arg0.BlackBar:setAlpha( 0.01 )
			f8_arg0.clipFinished( f8_arg0.BlackBar )
		end,
		Focus = function ( f9_arg0, f9_arg1 )
			f9_arg0:__resetProperties()
			f9_arg0:setupElementClipCounter( 5 )
			f9_arg0.BlackBar:completeAnimation()
			f9_arg0.BlackBar:setRGB( 0.82, 0.82, 0.82 )
			--f9_arg0.BlackBar:setAlpha( 0.05 )
			f9_arg0.clipFinished( f9_arg0.BlackBar )
		end
	}
}

CoD.ShieldFriendRow.__onClose = function ( f10_arg0 )
	f10_arg0.FriendName:close()
	f10_arg0.FriendXUID:close()
	f10_arg0.FriendStatus:close()
	f10_arg0.FriendEmblem:close()
	f10_arg0.BlackBar:close()
	f10_arg0.FrameBorder:close()
	f10_arg0.Mainframe:close()
end

-- datasrouce for friends
CoD.FriendListData = InheritFrom( LUI.UIElement )
CoD.FriendListData.__defaultWidth = 1600
CoD.FriendListData.__defaultHeight = 620
CoD.FriendListData.new = function ( f1_arg0, f1_arg1, f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	local self = LUI.UIElement.new( f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	self:setClass( CoD.FriendListData )
	self.id = "FriendListData"
	self.soundSet = "default"
	self.onlyChildrenFocusable = true
	self.anyChildUsesUpdateState = true

	------------------------------

	local FriendLists = LUI.UIList.new( f1_arg0, f1_arg1, 10, 0, nil, false, false, false, false )
	FriendLists:setLeftRight( 0.5, 0.5, -700, -700 + 600 )
	FriendLists:setTopBottom( 0, 0, 240, 240)
	FriendLists:setAutoScaleContent( true )
	FriendLists:setVerticalCount(5)
	FriendLists:setHorizontalCount(1)
	FriendLists:setSpacing( 10 )
	FriendLists:setWidgetType( CoD.ShieldFriendRow )
	FriendLists:setVerticalCounter( CoD.verticalCounter )
	FriendLists:setDataSource( "ShieldFriendList" )
	FriendLists:setAlignment( Enum[@"luialignment"][@"lui_alignment_left"] )
	self:addElement( FriendLists )
	self.FriendLists = FriendLists

	CoD.Menu.FriendListWidget = FriendLists

	Engine[@"exec"](Engine[@"getprimarycontroller"](), "friends")

	-- join
	FriendLists:AddContextualMenuAction( f1_arg0, f1_arg1, @"hash_4e49d0b0bac3e752", function ( f13_arg0, f13_arg1, f13_arg2, f13_arg3 )
		if AlwaysTrue() then
			return function ( f14_arg0, f14_arg1, f14_arg2, f14_arg3 )
				local FriendXUID = f14_arg0:getModel(f14_arg2, "FriendXUID")

				PlaySoundAlias( "uin_paint_image_flip_toggle" )
				CoD.EnhPrintInfo("Joining Friend -> " .. FriendXUID:get())
	
				Engine[@"exec"](Engine[@"getprimarycontroller"](), "shield_join " .. FriendXUID:get())

				GoBack(self, controller)
			end
		else
			CoD.EnhPrintInfo("WTF")
		end
	end ) 

	-- remove
	FriendLists:AddContextualMenuAction( f1_arg0, f1_arg1, @"hash_62abb014b7887052", function ( f13_arg0, f13_arg1, f13_arg2, f13_arg3 )
		if AlwaysTrue() then
			return function ( f14_arg0, f14_arg1, f14_arg2, f14_arg3 )
				local FriendXUID = f14_arg0:getModel(f14_arg2, "FriendXUID")

				PlaySoundAlias( "uin_paint_image_flip_toggle" )
				CoD.EnhPrintInfo("Removing Friend -> " .. FriendXUID:get())

				Engine[@"exec"](Engine[@"getprimarycontroller"](), "removefriend " .. FriendXUID:get())
			end
			
		else
			CoD.EnhPrintInfo("WTF")
		end
	end ) 

	f1_arg0:AddButtonCallbackFunction( FriendLists, f1_arg1, Enum[@"luibutton"][@"lui_key_xbx_pssquare"], "ui_remove", function ( element, menu, controller, model )
		if AlwaysTrue() then
			local FriendXUID = element:getModel(model, "FriendXUID")

			PlaySoundAlias( "uin_paint_image_flip_toggle" )
			CoD.EnhPrintInfo("Joining Friend -> " .. FriendXUID:get())

			Engine[@"exec"](Engine[@"getprimarycontroller"](), "shield_join " .. FriendXUID:get())

			GoBack(self, controller)
			return true
		else
			
		end
	end, function ( element, menu, controller )
		if not CoD.ModelUtility.IsSelfModelValueEqualTo( element, controller, "itemIndex", CoDShared.EmptyItemIndex ) and IsGamepad( controller ) and not IsElementPropertyValue( element, "__hasFocusOnVariantWidget", true ) then
			CoD.Menu.SetButtonLabel( menu, Enum[@"luibutton"][@"lui_key_xbx_pssquare"], @"hash_4e49d0b0bac3e752", nil, "ui_remove" )
			return true
		elseif IsMouseOrKeyboard( controller ) and not CoD.ModelUtility.IsSelfModelValueEqualTo( element, controller, "itemIndex", CoDShared.EmptyItemIndex ) and not IsElementPropertyValue( element, "__hasFocusOnVariantWidget", true ) then
			CoD.Menu.SetButtonLabel( menu, Enum[@"luibutton"][@"lui_key_xbx_pssquare"], @"hash_4e49d0b0bac3e752", Enum[@"luibuttonpromptflags"][@"bpf_contextual"], "ui_remove" )
			return true
		else
			return false
		end
	end, false )

	f1_arg0:AddButtonCallbackFunction( FriendLists, f1_arg1, Enum[@"luibutton"][@"lui_key_xby_pstriangle"], "Y", function ( element, menu, controller, model )
		if AlwaysTrue() then
			local FriendXUID = element:getModel(model, "FriendXUID")

			PlaySoundAlias( "uin_paint_image_flip_toggle" )
			CoD.EnhPrintInfo("Removing Friend -> " .. FriendXUID:get())

			Engine[@"exec"](Engine[@"getprimarycontroller"](), "removefriend " .. FriendXUID:get())
			
			return true
		else
			
		end
	end, function ( element, menu, controller )
		if not CoD.ModelUtility.IsSelfModelValueEqualTo( element, controller, "itemIndex", CoDShared.EmptyItemIndex ) and IsGamepad( controller ) and not IsElementPropertyValue( element, "__hasFocusOnVariantWidget", true ) then
			CoD.Menu.SetButtonLabel( menu, Enum[@"luibutton"][@"lui_key_xby_pstriangle"], @"hash_62abb014b7887052", nil, "Y" )
			return true
		elseif IsMouseOrKeyboard( controller ) and not CoD.ModelUtility.IsSelfModelValueEqualTo( element, controller, "itemIndex", CoDShared.EmptyItemIndex ) and not IsElementPropertyValue( element, "__hasFocusOnVariantWidget", true ) then
			CoD.Menu.SetButtonLabel( menu, Enum[@"luibutton"][@"lui_key_xby_pstriangle"], @"hash_62abb014b7887052", Enum[@"luibuttonpromptflags"][@"bpf_contextual"], "Y" )
			return true
		else
			return false
		end
	end, false )

	-- name
	CoD.PCWidgetUtility.SetupContextualMenu( FriendLists, f1_arg1, "FriendName", "", "" )

	FriendLists.id = "FriendLists"

	-- reqs
	local FriendReq = LUI.UIList.new( f1_arg0, f1_arg1, 10, 0, nil, false, false, false, false )
	FriendReq:setLeftRight( 0.5, 0.5, 100, -700 + 1400 )
	FriendReq:setTopBottom( 0, 0, 240, 240)
	FriendReq:setAutoScaleContent( true )
	FriendReq:setVerticalCount(5)
	FriendReq:setHorizontalCount(1)
	FriendReq:setSpacing( 10 )
	FriendReq:setWidgetType( CoD.ShieldFriendRow )
	FriendReq:setVerticalCounter( CoD.verticalCounter )
	FriendReq:setDataSource( "ShieldFriendReqList" )
	FriendReq:setAlignment( Enum[@"luialignment"][@"lui_alignment_left"] )
	self:addElement( FriendReq )
	self.FriendReq = FriendReq

	CoD.Menu.FriendReqWidget = FriendReq

	Engine[@"exec"](Engine[@"getprimarycontroller"](), "pendingfriends")

	-- accept
	FriendReq:AddContextualMenuAction( f1_arg0, f1_arg1, @"hash_40bd872543f8a833", function ( f13_arg0, f13_arg1, f13_arg2, f13_arg3 )
		-- check if pending?
		if f13_arg0:getModel(f13_arg2, "FriendStatus"):get() ~= "requested" then
			return function ( f14_arg0, f14_arg1, f14_arg2, f14_arg3 )
				local FriendName = f14_arg0:getModel(f14_arg2, "FriendName")

				PlaySoundAlias( "uin_paint_image_flip_toggle" )
				CoD.EnhPrintInfo("Accepting Friend -> " .. FriendName:get())

				Engine[@"exec"](Engine[@"getprimarycontroller"](), "acceptfriend " .. FriendName:get())
			end
			
		else
			--CoD.EnhPrintInfo("WTF")
		end
	end)

	f1_arg0:AddButtonCallbackFunction( FriendReq, f1_arg1, Enum[@"luibutton"][@"lui_key_xbx_pssquare"], "ui_remove", function ( element, menu, controller, model )
		if element:getModel(model, "FriendStatus"):get() ~= "requested" then
			local FriendName = element:getModel(model, "FriendName")

			PlaySoundAlias( "uin_paint_image_flip_toggle" )
			CoD.EnhPrintInfo("Accepting Friend -> " .. FriendName:get())

			Engine[@"exec"](Engine[@"getprimarycontroller"](), "acceptfriend " .. FriendName:get())
			
			return true
		else
			
		end
	end, function ( element, menu, controller )
		if element:getModel(model, "FriendStatus"):get() ~= "requested" and not CoD.ModelUtility.IsSelfModelValueEqualTo( element, controller, "itemIndex", CoDShared.EmptyItemIndex ) and IsGamepad( controller ) and not IsElementPropertyValue( element, "__hasFocusOnVariantWidget", true ) then
			CoD.Menu.SetButtonLabel( menu, Enum[@"luibutton"][@"lui_key_xbx_pssquare"], @"hash_40bd872543f8a833", nil, "ui_remove" )
			return true
		elseif element:getModel(model, "FriendStatus"):get() ~= "requested" and IsMouseOrKeyboard( controller ) and not CoD.ModelUtility.IsSelfModelValueEqualTo( element, controller, "itemIndex", CoDShared.EmptyItemIndex ) and not IsElementPropertyValue( element, "__hasFocusOnVariantWidget", true ) then
			CoD.Menu.SetButtonLabel( menu, Enum[@"luibutton"][@"lui_key_xbx_pssquare"], @"hash_40bd872543f8a833", Enum[@"luibuttonpromptflags"][@"bpf_contextual"], "ui_remove" )
			return true
		else
			return false
		end
	end, false )

	-- name
	CoD.PCWidgetUtility.SetupContextualMenu( FriendReq, f1_arg1, "FriendName", "", "" )

	FriendReq.id = "FriendReq"

	-------------------------------

	LUI.OverrideFunction_CallOriginalSecond( self, "close", self.__onClose )
	
	if PostLoadFunc then
		PostLoadFunc( self, f1_arg1, f1_arg0 )
	end

	return self
end

CoD.FriendListData.__onClose = function ( f9_arg0 )
	--f9_arg0.LANServerBrowserDetails:close()
	f9_arg0.FriendLists:close()
	f9_arg0.FriendReq:close()
end

-- friends buttons
CoD.fe_LeftContainer_NOTLobby_Friends = InheritFrom( LUI.UIElement )
CoD.fe_LeftContainer_NOTLobby_Friends.__defaultWidth = 792
CoD.fe_LeftContainer_NOTLobby_Friends.__defaultHeight = 48
CoD.fe_LeftContainer_NOTLobby_Friends.new = function ( f1_arg0, f1_arg1, f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	local self = LUI.UIHorizontalList.new( f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9, 0, false )
	self:setAlignment( LUI.Alignment.Left )
	self:setClass( CoD.fe_LeftContainer_NOTLobby_Friends )
	self.id = "fe_LeftContainer_NOTLobby_Friends"
	self.soundSet = "default"
	self.onlyChildrenFocusable = CoD.isPC
	self.anyChildUsesUpdateState = true
	f1_arg0:addElementToPendingUpdateStateList( self )
	
	local Abtn = CoD.FooterButtonPrompt.new( f1_arg0, f1_arg1, 0, 0, 0, 132, 1, 1, -48, 0 )
	Abtn:subscribeToGlobalModel( f1_arg1, "Controller", "primary_button_image", function ( model )
		local f2_local0 = model:get()
		if f2_local0 ~= nil then
			Abtn.buttonPromptImage:setImage( RegisterImage( f2_local0 ) )
		end
	end )
	Abtn:linkToElementModel( self, "" .. Enum[@"luibutton"][@"lui_key_xba_pscross"], false, function ( model )
		Abtn:setModel( model, f1_arg1 )
	end )
	self:addElement( Abtn )
	self.Abtn = Abtn
	
	local Xbtn = CoD.FooterButtonPrompt.new( f1_arg0, f1_arg1, 0, 0, 132, 264, 1, 1, -48, 0 )
	Xbtn:subscribeToGlobalModel( f1_arg1, "Controller", "alt1_button_image", function ( model )
		local f4_local0 = model:get()
		if f4_local0 ~= nil then
			Xbtn.buttonPromptImage:setImage( RegisterImage( f4_local0 ) )
		end
	end )
	Xbtn:linkToElementModel( self, "" .. Enum[@"luibutton"][@"lui_key_xbx_pssquare"], false, function ( model )
		Xbtn:setModel( model, f1_arg1 )
	end )
	self:addElement( Xbtn )
	self.Xbtn = Xbtn
	
	local Bbtn = CoD.FooterButtonPrompt.new( f1_arg0, f1_arg1, 0, 0, 264, 384, 1, 1, -48, 0 )
	Bbtn:subscribeToGlobalModel( f1_arg1, "Controller", "secondary_button_image", function ( model )
		local f6_local0 = model:get()
		if f6_local0 ~= nil then
			Bbtn.buttonPromptImage:setImage( RegisterImage( f6_local0 ) )
		end
	end )
	Bbtn:linkToElementModel( self, "" .. Enum[@"luibutton"][@"lui_key_xbb_pscircle"], false, function ( model )
		Bbtn:setModel( model, f1_arg1 )
	end )
	self:addElement( Bbtn )
	self.Bbtn = Bbtn
	
	local OptionsBtn = CoD.FooterButtonPrompt.new( f1_arg0, f1_arg1, 0, 0, 384, 516, 1, 1, -48, 0 )
	OptionsBtn:subscribeToGlobalModel( f1_arg1, "Controller", "start_button_image", function ( model )
		local f8_local0 = model:get()
		if f8_local0 ~= nil then
			OptionsBtn.buttonPromptImage:setImage( RegisterImage( f8_local0 ) )
		end
	end )
	OptionsBtn:linkToElementModel( self, "" .. Enum[@"luibutton"][@"lui_key_start"], false, function ( model )
		OptionsBtn:setModel( model, f1_arg1 )
	end )
	self:addElement( OptionsBtn )
	self.OptionsBtn = OptionsBtn
	
	local Ybtn = CoD.FooterButtonPrompt.new( f1_arg0, f1_arg1, 0, 0, 516 - 100, 648 - 100, 1, 1, -48, 0 )
	Ybtn:subscribeToGlobalModel( f1_arg1, "Controller", "alt2_button_image", function ( model )
		local f10_local0 = model:get()
		if f10_local0 ~= nil then
			Ybtn.buttonPromptImage:setImage( RegisterImage( f10_local0 ) )
		end
	end )
	Ybtn:linkToElementModel( self, "" .. Enum[@"luibutton"][@"lui_key_xby_pstriangle"], false, function ( model )
		Ybtn:setModel( model, f1_arg1 )
	end )
	self:addElement( Ybtn )
	self.Ybtn = Ybtn
	
	local LTbtn = CoD.FooterButtonPrompt.new( f1_arg0, f1_arg1, 0, 0, 648, 780, 1, 1, -48, 0 )
	LTbtn:subscribeToGlobalModel( f1_arg1, "Controller", "left_trigger_button_image", function ( model )
		local f12_local0 = model:get()
		if f12_local0 ~= nil then
			LTbtn.buttonPromptImage:setImage( RegisterImage( f12_local0 ) )
		end
	end )
	LTbtn:linkToElementModel( self, "" .. Enum[@"luibutton"][@"lui_key_ltrig"], false, function ( model )
		LTbtn:setModel( model, f1_arg1 )
	end )
	self:addElement( LTbtn )
	self.LTbtn = LTbtn
	
	local RTbtn = CoD.FooterButtonPrompt.new( f1_arg0, f1_arg1, 0, 0, 780, 912, 1, 1, -48, 0 )
	RTbtn:subscribeToGlobalModel( f1_arg1, "Controller", "right_trigger_button_image", function ( model )
		local f14_local0 = model:get()
		if f14_local0 ~= nil then
			RTbtn.buttonPromptImage:setImage( RegisterImage( f14_local0 ) )
		end
	end )
	RTbtn:linkToElementModel( self, "" .. Enum[@"luibutton"][@"lui_key_rtrig"], false, function ( model )
		RTbtn:setModel( model, f1_arg1 )
	end )
	self:addElement( RTbtn )
	self.RTbtn = RTbtn
	
	local LeftStick = CoD.FooterButtonPrompt.new( f1_arg0, f1_arg1, 0, 0, 912, 1044, 1, 1, -48, 0 )
	LeftStick:subscribeToGlobalModel( f1_arg1, "Controller", "move_left_stick_button_image", function ( model )
		local f16_local0 = model:get()
		if f16_local0 ~= nil then
			LeftStick.buttonPromptImage:setImage( RegisterImage( f16_local0 ) )
		end
	end )
	LeftStick:linkToElementModel( self, "" .. Enum[@"luibutton"][@"lui_key_lstick_pressed"], false, function ( model )
		LeftStick:setModel( model, f1_arg1 )
	end )
	self:addElement( LeftStick )
	self.LeftStick = LeftStick
	
	self:mergeStateConditions( {
		{
			stateName = "MouseKeyboard",
			condition = function ( menu, element, event )
				return IsMouseOrKeyboard( f1_arg1 )
			end
		}
	} )
	self:appendEventHandler( "input_source_changed", function ( f19_arg0, f19_arg1 )
		f19_arg1.menu = f19_arg1.menu or f1_arg0
		f1_arg0:updateElementState( self, f19_arg1 )
	end )
	local f1_local9 = self
	local f1_local10 = self.subscribeToModel
	local f1_local11 = Engine[@"getmodelforcontroller"]( f1_arg1 )
	f1_local10( f1_local9, f1_local11.LastInput, function ( f20_arg0 )
		f1_arg0:updateElementState( self, {
			name = "model_validation",
			menu = f1_arg0,
			controller = f1_arg1,
			modelValue = f20_arg0:get(),
			modelName = "LastInput"
		} )
	end, false )
	if CoD.isPC then
		Abtn.id = "Abtn"
	end
	if CoD.isPC then
		Xbtn.id = "Xbtn"
	end
	if CoD.isPC then
		Bbtn.id = "Bbtn"
	end
	if CoD.isPC then
		OptionsBtn.id = "OptionsBtn"
	end
	if CoD.isPC then
		Ybtn.id = "Ybtn"
	end
	if CoD.isPC then
		LTbtn.id = "LTbtn"
	end
	if CoD.isPC then
		RTbtn.id = "RTbtn"
	end
	if CoD.isPC then
		LeftStick.id = "LeftStick"
	end
	self.__defaultFocus = Bbtn
	LUI.OverrideFunction_CallOriginalSecond( self, "close", self.__onClose )
	if PostLoadFunc then
		PostLoadFunc( self, f1_arg1, f1_arg0 )
	end
	
	return self
end

CoD.fe_LeftContainer_NOTLobby_Friends.__resetProperties = function ( f21_arg0 )
	f21_arg0.Bbtn:completeAnimation()
	f21_arg0.Abtn:completeAnimation()
	f21_arg0.Bbtn:setAlpha( 1 )
	f21_arg0.Abtn:setAlpha( 1 )
end

CoD.fe_LeftContainer_NOTLobby_Friends.__clipsPerState = {
	DefaultState = {
		DefaultClip = function ( f22_arg0, f22_arg1 )
			f22_arg0:__resetProperties()
			f22_arg0:setupElementClipCounter( 0 )
		end
	},
	MouseKeyboard = {
		DefaultClip = function ( f23_arg0, f23_arg1 )
			f23_arg0:__resetProperties()
			f23_arg0:setupElementClipCounter( 2 )
			f23_arg0.Abtn:completeAnimation()
			f23_arg0.Abtn:setAlpha( 0 )
			f23_arg0.clipFinished( f23_arg0.Abtn )
			f23_arg0.Bbtn:completeAnimation()
			f23_arg0.Bbtn:setAlpha( 0 )
			f23_arg0.clipFinished( f23_arg0.Bbtn )
		end
	}
}

CoD.fe_LeftContainer_NOTLobby_Friends.__onClose = function ( f24_arg0 )
	f24_arg0.Abtn:close()
	f24_arg0.Xbtn:close()
	f24_arg0.Bbtn:close()
	f24_arg0.OptionsBtn:close()
	f24_arg0.Ybtn:close()
	f24_arg0.LTbtn:close()
	f24_arg0.RTbtn:close()
	f24_arg0.LeftStick:close()
end

-- friend's background
CoD.FriendsCommonCenteredPopup = InheritFrom( LUI.UIElement )
CoD.FriendsCommonCenteredPopup.__defaultWidth = 1920
CoD.FriendsCommonCenteredPopup.__defaultHeight = 1080
CoD.FriendsCommonCenteredPopup.new = function ( f1_arg0, f1_arg1, f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	local self = LUI.UIElement.new( f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	self:setClass( CoD.FriendsCommonCenteredPopup )
	self.id = "FriendsCommonCenteredPopup"
	self.soundSet = "default"
	self.onlyChildrenFocusable = true
	self.anyChildUsesUpdateState = true
	
	--[[
	local BlackfadeBlurB = LUI.UIImage.new( 0, 1, -5, 5, 0, 1, -5, 5 )
	BlackfadeBlurB:setRGB( 0, 0, 0 )
	BlackfadeBlurB:setMaterial( LUI.UIImage.GetCachedMaterial( @"hash_E2354BE557C4C7A" ) )
	BlackfadeBlurB:setShaderVector( 0, 0, 0, 0, 0 )
	self:addElement( BlackfadeBlurB )
	self.BlackfadeBlurB = BlackfadeBlurB
	
	local BlackfadeBlurF = LUI.UIImage.new( 0, 1, -5, 5, 0, 1, -5, 5 )
	BlackfadeBlurF:setRGB( 0, 0, 0 )
	BlackfadeBlurF:setAlpha( 0.6 )
	self:addElement( BlackfadeBlurF )
	self.BlackfadeBlurF = BlackfadeBlurF
	]]
	
	local CenterBackground = LUI.UIImage.new( 0.5, 0.5, -348 - 500, 348 + 500, 0.5, 0.5, -500, 500 )
	CenterBackground:setRGB( 0.09, 0.09, 0.09 )
	CenterBackground:setAlpha( 0.9 )
	self:addElement( CenterBackground )
	self.CenterBackground = CenterBackground
	
	local CenterTiledBacking = LUI.UIImage.new( 0.5, 0.5, -348 - 500, 348 + 500, 0.5, 0.5, -500, 500 )
	CenterTiledBacking:setAlpha( 0.25 )
	CenterTiledBacking:setImage( RegisterImage( @"hash_634839E8065B1E53" ) )
	CenterTiledBacking:setMaterial( LUI.UIImage.GetCachedMaterial( @"hash_16CBE95C250C6D15" ) )
	CenterTiledBacking:setShaderVector( 0, 0, 0, 0, 0 )
	CenterTiledBacking:setupNineSliceShader( 196, 88 )
	self:addElement( CenterTiledBacking )
	self.CenterTiledBacking = CenterTiledBacking
	
	local buttons = CoD.fe_LeftContainer_NOTLobby_Friends.new( f1_arg0, f1_arg1, 0.5, 0.5, -312 - 100, 336 - 100, 0.5, 0.5, 439, 487 )
	self:addElement( buttons )
	self.buttons = buttons
	
	local featureOverlayButtonMouseOnly = nil
	
	featureOverlayButtonMouseOnly = CoD.featureOverlay_Button.new( f1_arg0, f1_arg1, 0.5, 0.5, -333 + 950, -147 + 950, 0.5, 0.5, 424, 484 )
	featureOverlayButtonMouseOnly.ButtonContainer.Title:setText( Engine[@"hash_4F9F1239CFD921FE"]( @"hash_778D439E1B360368" ) )
	featureOverlayButtonMouseOnly:registerEventHandler( "gain_focus", function ( element, event )
		local f2_local0 = nil
		if element.gainFocus then
			f2_local0 = element:gainFocus( event )
		elseif element.super.gainFocus then
			f2_local0 = element.super:gainFocus( event )
		end
		CoD.Menu.UpdateButtonShownState( element, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
		return f2_local0
	end )
	f1_arg0:AddButtonCallbackFunction( featureOverlayButtonMouseOnly, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], "ui_confirm", function ( element, menu, controller, model )
		GoBack( self, controller )
		return true
	end, function ( element, menu, controller )
		CoD.Menu.SetButtonLabel( menu, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], @"hash_0", nil, "ui_confirm" )
		return false
	end, false )
	self:addElement( featureOverlayButtonMouseOnly )
	self.featureOverlayButtonMouseOnly = featureOverlayButtonMouseOnly
	
	local LayoutBottomBar = LUI.UIImage.new( 0.5, 0.5, -349.5 - 500, 349.5 + 500, 0.5, 0.5, 473, 501 )
	LayoutBottomBar:setZRot( 180 )
	LayoutBottomBar:setImage( RegisterImage( @"hash_87C348C36FF085C" ) )
	self:addElement( LayoutBottomBar )
	self.LayoutBottomBar = LayoutBottomBar
	
	local LayoutTopBar = LUI.UIImage.new( 0.5, 0.5, -349.5 - 500, 349.5 + 500, 0.5, 0.5, -500.5, -472.5 )
	LayoutTopBar:setImage( RegisterImage( @"hash_87C348C36FF085C" ) )
	self:addElement( LayoutTopBar )
	self.LayoutTopBar = LayoutTopBar
	
	local LayoutTopBarStripes = LUI.UIImage.new( 0.5, 0.5, -348 - 500, 348 + 500, 0.5, 0.5, -500.5, -484.5 )
	LayoutTopBarStripes:setImage( RegisterImage( @"hash_6A0F654633E4C64E" ) )
	self:addElement( LayoutTopBarStripes )
	self.LayoutTopBarStripes = LayoutTopBarStripes
	
	local TitleBackgroundBar = LUI.UIImage.new( 0.5, 0.5, -336.5, 336.5, 0.5, 0.5, -472, -444 )
	TitleBackgroundBar:setRGB( 0.25, 0.24, 0.22 )
	TitleBackgroundBar:setAlpha( 0.88 )
	self:addElement( TitleBackgroundBar )
	self.TitleBackgroundBar = TitleBackgroundBar
	
	local TitleTiledBacking = LUI.UIImage.new( 0.5, 0.5, -336.5, 336.5, 0.5, 0.5, -472, -444 )
	TitleTiledBacking:setAlpha( 0.5 )
	TitleTiledBacking:setImage( RegisterImage( @"hash_634839E8065B1E53" ) )
	TitleTiledBacking:setMaterial( LUI.UIImage.GetCachedMaterial( @"hash_16CBE95C250C6D15" ) )
	TitleTiledBacking:setShaderVector( 0, 0, 0, 0, 0 )
	TitleTiledBacking:setupNineSliceShader( 196, 88 )
	self:addElement( TitleTiledBacking )
	self.TitleTiledBacking = TitleTiledBacking
	
	local TitleText = LUI.UIText.new( 0.5, 0.5, -279.5, 279.5, 0.5, 0.5, -469, -445 )
	TitleText:setRGB( ColorSet.T8__BIEGE.r, ColorSet.T8__BIEGE.g, ColorSet.T8__BIEGE.b )
	TitleText:setAlpha( 0.6 )
	TitleText:setText( "" )
	TitleText:setTTF( "ttmussels_regular" )
	TitleText:setLetterSpacing( 4 )
	TitleText:setAlignment( Enum[@"hash_67A5123B654282D2"][@"hash_1FEEB12BCB0D7041"] )
	TitleText:setAlignment( Enum[@"hash_67A5123B654282D2"][@"hash_3F41D595A2B0EDF3"] )
	self:addElement( TitleText )
	self.TitleText = TitleText
	
	local TitleLayoutElementL = LUI.UIImage.new( 0.5, 0.5, -331, -315, 0.5, 0.5, -465, -449 )
	TitleLayoutElementL:setRGB( ColorSet.T8__BIEGE.r, ColorSet.T8__BIEGE.g, ColorSet.T8__BIEGE.b )
	TitleLayoutElementL:setZRot( 90 )
	TitleLayoutElementL:setImage( RegisterImage( @"hash_634B575F15CDD376" ) )
	TitleLayoutElementL:setMaterial( LUI.UIImage.GetCachedMaterial( @"hash_F755127C95CF5B6" ) )
	TitleLayoutElementL:setShaderVector( 0, 3, 0, 0, 0 )
	self:addElement( TitleLayoutElementL )
	self.TitleLayoutElementL = TitleLayoutElementL
	
	local TitleLayoutElementR = LUI.UIImage.new( 0.5, 0.5, 313, 329, 0.5, 0.5, -464, -448 )
	TitleLayoutElementR:setRGB( ColorSet.T8__BIEGE.r, ColorSet.T8__BIEGE.g, ColorSet.T8__BIEGE.b )
	TitleLayoutElementR:setImage( RegisterImage( @"hash_634B575F15CDD376" ) )
	TitleLayoutElementR:setMaterial( LUI.UIImage.GetCachedMaterial( @"hash_F755127C95CF5B6" ) )
	TitleLayoutElementR:setShaderVector( 0, 3, 0, 0, 0 )
	self:addElement( TitleLayoutElementR )
	self.TitleLayoutElementR = TitleLayoutElementR
	
	local HeaderBackground = LUI.UIImage.new( 0.5, 0.5, -336.5 - 500, 336.5 + 500, 0.5, 0.5, -423, -231 )
	HeaderBackground:setRGB( 0.23, 0.23, 0.23 )
	HeaderBackground:setAlpha( 0.25 )
	self:addElement( HeaderBackground )
	self.HeaderBackground = HeaderBackground
	
	local HeaderTopBar = LUI.UIImage.new( 0.5, 0.5, -5, -1, 0.5, 0.5, -767, -90 )
	HeaderTopBar:setAlpha( 0.09 )
	HeaderTopBar:setZRot( 90 )
	HeaderTopBar:setImage( RegisterImage( @"hash_C49B0C8991A541F" ) )
	HeaderTopBar:setMaterial( LUI.UIImage.GetCachedMaterial( @"hash_67C9C02F608D0A75" ) )
	HeaderTopBar:setShaderVector( 0, 0, 0, 0, 0 )
	HeaderTopBar:setupNineSliceShader( 4, 8 )
	self:addElement( HeaderTopBar )
	self.HeaderTopBar = HeaderTopBar
	
	local HeaderBottomBar = LUI.UIImage.new( 0.5, 0.5, -5, -1, 0.5, 0.5, -566, 111 )
	HeaderBottomBar:setAlpha( 0.09 )
	HeaderBottomBar:setZRot( 90 )
	HeaderBottomBar:setImage( RegisterImage( @"hash_C49B0C8991A541F" ) )
	HeaderBottomBar:setMaterial( LUI.UIImage.GetCachedMaterial( @"hash_67C9C02F608D0A75" ) )
	HeaderBottomBar:setShaderVector( 0, 0, 0, 0, 0 )
	HeaderBottomBar:setupNineSliceShader( 4, 8 )
	self:addElement( HeaderBottomBar )
	self.HeaderBottomBar = HeaderBottomBar

	-- party one
	local PartyOverlayButtonMouseOnly = nil
	
	PartyOverlayButtonMouseOnly = CoD.featureOverlay_Button.new( f1_arg0, f1_arg1, 0.5, 0.5, -333 + 750, -147 + 750, 0.5, 0.5, 424, 484 )
	PartyOverlayButtonMouseOnly.ButtonContainer.Title:setText( Engine[@"hash_4F9F1239CFD921FE"](@"hash_2f3189ebf087907e") )
	PartyOverlayButtonMouseOnly:registerEventHandler( "gain_focus", function ( element, event )
		local f2_local0 = nil
		if element.gainFocus then
			f2_local0 = element:gainFocus( event )
		elseif element.super.gainFocus then
			f2_local0 = element.super:gainFocus( event )
		end
		CoD.Menu.UpdateButtonShownState( element, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
		return f2_local0
	end )
	f1_arg0:AddButtonCallbackFunction( PartyOverlayButtonMouseOnly, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], "ui_confirm", function ( element, menu, controller, model )
		PlaySoundAlias( "uin_paint_image_flip_toggle" )
		CoD.EnhPrintInfo("ReloadModsButton")
		
		OpenOverlay( self, "ShieldPartyStuff", controller )
		return true
	end, function ( element, menu, controller )
		CoD.Menu.SetButtonLabel( menu, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], @"hash_0", nil, "ui_confirm" )
		return false
	end, false )
	self:addElement( PartyOverlayButtonMouseOnly )
	self.PartyOverlayButtonMouseOnly = PartyOverlayButtonMouseOnly

	PartyOverlayButtonMouseOnly.id = "PartyOverlayButtonMouseOnly"
	
	local BTNQuit = nil
	
	BTNQuit = CoD.PC_SmallCloseButton.new( f1_arg0, f1_arg1, 0.5, 0.5, 302, 336, 0.5, 0.5, -475, -441 )
	BTNQuit:setScale( 0.8, 0.8 )
	BTNQuit:registerEventHandler( "gain_focus", function ( element, event )
		local f5_local0 = nil
		if element.gainFocus then
			f5_local0 = element:gainFocus( event )
		elseif element.super.gainFocus then
			f5_local0 = element.super:gainFocus( event )
		end
		CoD.Menu.UpdateButtonShownState( element, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
		return f5_local0
	end )
	f1_arg0:AddButtonCallbackFunction( BTNQuit, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], "ui_confirm", function ( element, menu, controller, model )
		GoBack( self, controller )
		return true
	end, function ( element, menu, controller )
		CoD.Menu.SetButtonLabel( menu, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], @"hash_0", nil, "ui_confirm" )
		return false
	end, false )
	self:addElement( BTNQuit )
	self.BTNQuit = BTNQuit
	
	--if CoD.isPC then
		buttons.id = "buttons"
	--end
	--if CoD.isPC then
		featureOverlayButtonMouseOnly.id = "featureOverlayButtonMouseOnly"
	--end
	--if CoD.isPC then
		BTNQuit.id = "BTNQuit"
	--end
	LUI.OverrideFunction_CallOriginalSecond( self, "close", self.__onClose )
	if PostLoadFunc then
		PostLoadFunc( self, f1_arg1, f1_arg0 )
	end
	
	return self
end

CoD.FriendsCommonCenteredPopup.__onClose = function ( f8_arg0 )
	f8_arg0.buttons:close()
	f8_arg0.featureOverlayButtonMouseOnly:close()
	f8_arg0.BTNQuit:close()
	f8_arg0.PartyOverlayButtonMouseOnly:close()
end

-- shield's friends
CoD.ShieldFriendsMenu = InheritFrom( CoD.Menu )
LUI.createMenu.ShieldFriendsMenu = function ( f1_arg0, f1_arg1 )
	local self = CoD.Menu.NewForUIEditor( "ShieldFriendsMenu", f1_arg0 )
	local f1_local1 = self
	self:setClass( CoD.ShieldFriendsMenu )
	self.soundSet = "none"
	self:setOwner( f1_arg0 )
	self:setLeftRight( 0, 1, 0, 0 )
	self:setTopBottom( 0, 1, 0, 0 )
	self:playSound( "menu_open", f1_arg0 )
	self.anyChildUsesUpdateState = true
	f1_local1:addElementToPendingUpdateStateList( self )
	
	local CommomCenteredPopup = CoD.FriendsCommonCenteredPopup.new( f1_local1, f1_arg0, 0, 1, 0, 0, 0, 1, 0, 0 )
	CommomCenteredPopup.TitleText:setText("Shield Friends")
	CommomCenteredPopup.HeaderBackground:setAlpha( 0 )
	CommomCenteredPopup.HeaderTopBar:setAlpha( 0 )
	CommomCenteredPopup.HeaderBottomBar:setAlpha( 0 )
	self:addElement( CommomCenteredPopup )
	self.CommomCenteredPopup = CommomCenteredPopup
	
	local FriendListsHint = LUI.UIText.new( 0.5, 0.5, 0 - 755 + 70, 550 - 755 + 70, 0.5, 0.5, 100 - 490, 155 - 490 )
	FriendListsHint:setText("Active Friends")
	FriendListsHint:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )
	FriendListsHint:setTTF("notosans_bold")
	FriendListsHint:setBackingType( 2 )
	FriendListsHint:setBackingColor( 0.04, 0.81, 1 )
	FriendListsHint:setBackingAlpha( 0.01 )
	FriendListsHint:setBackingXPadding( 12 )
	FriendListsHint:setBackingYPadding( 6 )
	FriendListsHint:setAlignment( Enum[@"luialignment"][@"lui_alignment_left"] )
	FriendListsHint:setAlignment( Enum[@"luialignment"][@"lui_alignment_top"] )
	self:addElement( FriendListsHint )
	self.FriendListsHint = FriendListsHint

	local FriendLists = CoD.FriendListData.new( self, f1_arg0, 0.5, 0.5, -800, 800, 0.5, 0.5, -535, 400 )
	self:addElement( FriendLists )
	self.FriendLists = FriendLists

	-- sep
	local HeaderPixSep = LUI.UIImage.new( 0.5, 0.5, -15, 15, 0.5, 0.5, -550, 550 )
	HeaderPixSep:setAlpha( 0.25 )
	HeaderPixSep:setImage( RegisterImage( @"hash_CB07CCC28498CB2" ) )
	--HeaderPixSep:setMaterial( LUI.UIImage.GetCachedMaterial( @"hash_16CBE95C250C6D15" ) )
	HeaderPixSep:setShaderVector( 0, 0, 0, 0, 0 )
	HeaderPixSep:setupNineSliceShader( 128, 128 )
	self:addElement( HeaderPixSep )
	self.HeaderPixSep = HeaderPixSep

	local FriendReqHint = LUI.UIText.new( 0.5, 0.5, 0 - 755 + 870, 550 - 755 + 870, 0.5, 0.5, 100 - 490, 155 - 490 )
	FriendReqHint:setText("Friend Requests")
	FriendReqHint:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )
	FriendReqHint:setTTF("notosans_bold")
	FriendReqHint:setBackingType( 2 )
	FriendReqHint:setBackingColor( 0.04, 0.81, 1 )
	FriendReqHint:setBackingAlpha( 0.01 )
	FriendReqHint:setBackingXPadding( 12 )
	FriendReqHint:setBackingYPadding( 6 )
	FriendReqHint:setAlignment( Enum[@"luialignment"][@"lui_alignment_left"] )
	FriendReqHint:setAlignment( Enum[@"luialignment"][@"lui_alignment_top"] )
	self:addElement( FriendReqHint )
	self.FriendReqHint = FriendReqHint

	-- Custom Friend Req Send..
	local FriendReqEditBox = CoD.Shield_NameEditBox.new( f1_local1, f1_arg0, 0.5, 0.5, -20 - 770, 350 - 675, 0.75, 0.75, 100, 150 )
	FriendReqEditBox:linkToElementModel( self, nil, false, function ( model )
		FriendReqEditBox:setModel( model, f1_arg0 )
	end )
	FriendReqEditBox.TextBox:setLeftRight(0, 0, 20 + 150, 320 + 150)
	FriendReqEditBox.RankHighlight:setText("^2Send Friend Request: ")
	self:addElement( FriendReqEditBox )
	self.FriendReqEditBox = FriendReqEditBox

	local FriendReqBoxModel = Engine[@"getmodel"]( Engine[@"getmodelforcontroller"]( f1_arg0 ), "Shield_FriendReq" )

	if FriendReqBoxModel == nil then
		FriendReqBoxModel = Engine[@"createmodel"]( Engine[@"getmodelforcontroller"]( f1_arg0 ), "Shield_FriendReq" )
	end

	if FriendReqBoxModel:get() == nil then
		FriendReqBoxModel:set("")
	end

	FriendReqEditBox.__editControlMaxChar = 16
	FriendReqEditBox.__editControlisInteger = 1
	FriendReqEditBox.__editControlMin = 0
	FriendReqEditBox.__editControlMax = 1000

	CoD.PCUtility.SetupEditControlWithModel( FriendReqEditBox, f1_arg0, f1_local1, FriendReqBoxModel, function ( f331_arg0, f331_arg1, f331_arg2 )
		if not f331_arg2.canceled and f331_arg2.name == "textbox_editdone" then
			local FriendData = f331_arg0:get()

			CoD.EnhPrintInfo("SendFeq", FriendData)
			PlaySoundAlias( "uin_paint_image_flip_toggle" )

			f331_arg0:set("^3Sent a Friend Request to " .. FriendData)
			FriendReqEditBox:addElement( LUI.UITimer.newElementTimer( 300, true, function ()
				f331_arg0:set("")
			end ) )

			-- shield api here later..
			Engine[@"exec"](Engine[@"getprimarycontroller"](), "addfriend " .. FriendData)

			-- MIGHT ERROR!
			--CoD.OverlayUtility.CreateOverlay(f1_local1, f1_arg0, "Shield...", "shield/....")
		else
			f331_arg0:set("") -- reset it
		end
	end )

	FriendReqEditBox.id = "FriendReqEditBox"

	self:mergeStateConditions( {
		{
			stateName = "KBM",
			condition = function ( menu, element, event )
				return IsMouseOrKeyboard( f1_arg0 )
			end
		}
	} )
	self:appendEventHandler( "input_source_changed", function ( f9_arg0, f9_arg1 )
		f9_arg1.menu = f9_arg1.menu or f1_local1
		f1_local1:updateElementState( self, f9_arg1 )
	end )
	local f1_local6 = self
	local f1_local7 = self.subscribeToModel
	local f1_local8 = Engine[@"getmodelforcontroller"]( f1_arg0 )
	f1_local7( f1_local6, f1_local8.LastInput, function ( f10_arg0 )
		f1_local1:updateElementState( self, {
			name = "model_validation",
			menu = f1_local1,
			controller = f1_arg0,
			modelValue = f10_arg0:get(),
			modelName = "LastInput"
		} )
	end, false )
	f1_local1:AddButtonCallbackFunction( self, f1_arg0, Enum[@"luibutton"][@"lui_key_xbb_pscircle"], nil, function ( element, menu, controller, model )
		GoBack( self, controller )
		ClearMenuSavedState( menu )
		ForceNotifyGlobalModel( controller, "GametypeSettings.Update" )
		return true
	end, function ( element, menu, controller )
		CoD.Menu.SetButtonLabel( menu, Enum[@"luibutton"][@"lui_key_xbb_pscircle"], @"menu/back", nil, nil )
		return true
	end, false )
	CommomCenteredPopup.buttons:setModel( self.buttonModel, f1_arg0 )
	if CoD.isPC then
		CommomCenteredPopup.id = "CommomCenteredPopup"
	end
	FriendLists.id = "FriendLists"
	--if CoD.isPC then
	--	PCSmallCloseButton.id = "PCSmallCloseButton"
	--end
	self:processEvent( {
		name = "menu_loaded",
		controller = f1_arg0
	} )
	self.__defaultFocus = ModsList
	if CoD.isPC and (IsKeyboard( f1_arg0 ) or self.ignoreCursor) then
		self:restoreState( f1_arg0 )
	end
	LUI.OverrideFunction_CallOriginalSecond( self, "close", self.__onClose )
	if PostLoadFunc then
		PostLoadFunc( self, f1_arg0 )
	end
	
	f1_local7 = self
	--MenuHidesFreeCursor( f1_local1, f1_arg0 )

	CoD.EnhPrintInfo("Called", "Shield's Friends")

	return self
end

CoD.ShieldFriendsMenu.__resetProperties = function ( f13_arg0 )

end

CoD.ShieldFriendsMenu.__clipsPerState = {
	DefaultState = {
		DefaultClip = function ( f14_arg0, f14_arg1 )
			f14_arg0:__resetProperties()
			f14_arg0:setupElementClipCounter( 0 )
		end
	},
	KBM = {
		DefaultClip = function ( f15_arg0, f15_arg1 )
			f15_arg0:__resetProperties()
			f15_arg0:setupElementClipCounter( 2 )
		end
	}
}

CoD.ShieldFriendsMenu.__onClose = function ( f16_arg0 )
	f16_arg0.CommomCenteredPopup:close()
	f16_arg0.FriendLists:close()
	f16_arg0.FriendListsHint:close()
	f16_arg0.FriendReqHint:close()
	f16_arg0.HeaderPixSep:close()
	f16_arg0.FriendReqEditBox:close()
end