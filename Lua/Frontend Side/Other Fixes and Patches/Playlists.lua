--[[
		.\hksc.exe ".\Lua\Playlists.Lua" -o "C:\Program Files (x86)\Call of Duty Black Ops 4\project-bo4\mods\T8ShieldSupport\Lua\Playlists.luac"
]]

---------------------------

CoD.ShieldInitLuaFile()

---------------------------

-- add more/unused playlists
CoD.PlaylistsReload = function()
	CoD.DirectorFindGame = InheritFrom( CoD.Menu )
	LUI.createMenu.DirectorFindGame = function ( f1_arg0, f1_arg1 )
		local self = CoD.Menu.NewForUIEditor( "DirectorFindGame", f1_arg0 )
		local f1_local1 = self
		CoD.BaseUtility.SetPropertiesFromUserData( self, f1_arg1 )
		CoD.DirectorUtility.SetupDirectorFiltersCards( f1_local1, f1_arg0, self )
		self:setClass( CoD.DirectorFindGame )
		self.soundSet = "default"
		self:setOwner( f1_arg0 )
		self:setLeftRight( 0, 1, 0, 0 )
		self:setTopBottom( 0, 1, 0, 0 )
		self:playSound( "menu_open", f1_arg0 )
		self.anyChildUsesUpdateState = true
		
		local TEMPBlackBGOverlay = LUI.UIImage.new( 0, 1, 0, 0, 0, 1, 0, 0 )
		TEMPBlackBGOverlay:setRGB( 0, 0, 0 )
		TEMPBlackBGOverlay:setMaterial( LUI.UIImage.GetCachedMaterial( @"hash_E2354BE557C4C7A" ) )
		TEMPBlackBGOverlay:setShaderVector( 0, 0.01, 0.5, 0, 0 )
		self:addElement( TEMPBlackBGOverlay )
		self.TEMPBlackBGOverlay = TEMPBlackBGOverlay
		
		local OptionsList = LUI.UIList.new( f1_local1, f1_arg0, 20, 0, nil, false, false, false, false )
		OptionsList:setLeftRight( 0.5, 0.5, -864, 292 )
		OptionsList:setTopBottom( 0.5, 0.5, -522, 522 )
		OptionsList:setWidgetType( CoD.DirectorPlaylistOption )
		OptionsList:setHorizontalCount( 3 )
		OptionsList:setVerticalCount( 3 )
		OptionsList:setSpacing( 20 )
		OptionsList:setAlignment( Enum[@"luialignment"][@"lui_alignment_left"] )
		OptionsList:setVerticalCounter( CoD.verticalCounter )
		OptionsList:linkToElementModel( OptionsList, "locked", true, function ( model, f2_arg1 )
			CoD.Menu.UpdateButtonShownState( f2_arg1, f1_local1, f1_arg0, Enum[@"luibutton"][@"lui_key_xba_pscross"] )
		end )
		OptionsList:linkToElementModel( OptionsList, "lockState", true, function ( model, f3_arg1 )
			CoD.Menu.UpdateButtonShownState( f3_arg1, f1_local1, f1_arg0, Enum[@"luibutton"][@"lui_key_xba_pscross"] )
			CoD.Menu.UpdateButtonShownState( f3_arg1, f1_local1, f1_arg0, Enum[@"luibutton"][@"lui_key_xbx_pssquare"] )
		end )
		OptionsList:registerEventHandler( "gain_focus", function ( element, event )
			local f4_local0 = nil
			if element.gainFocus then
				f4_local0 = element:gainFocus( event )
			elseif element.super.gainFocus then
				f4_local0 = element.super:gainFocus( event )
			end
			CoD.Menu.UpdateButtonShownState( element, f1_local1, f1_arg0, Enum[@"luibutton"][@"lui_key_xba_pscross"] )
			CoD.Menu.UpdateButtonShownState( element, f1_local1, f1_arg0, Enum[@"luibutton"][@"lui_key_xbx_pssquare"] )
			return f4_local0
		end )
		f1_local1:AddButtonCallbackFunction( OptionsList, f1_arg0, Enum[@"luibutton"][@"lui_key_xba_pscross"], "ui_confirm", function ( element, menu, controller, model )
			if not CoD.ModelUtility.IsSelfModelValueTrue( element, controller, "locked" ) then
				ProcessListAction( self, element, controller, menu )
				GoBack( self, controller )
				return true
			elseif CoD.ModelUtility.IsSelfModelValueEqualToEnum( element, controller, "lockState", Enum[@"playlistlockstate"][@"pls_required_dlc_not_available"] ) then
				OpenSystemOverlay( self, menu, controller, "DownloadDLC", {
					_model = element:getModel()
				} )
				return true
			elseif CoD.ModelUtility.IsSelfModelValueEqualToEnum( element, controller, "lockState", Enum[@"playlistlockstate"][@"hash_4BDEB566326AC98"] ) then
				OpenSystemOverlay( self, menu, controller, "SeasonPassUpsell", {
					_model = element:getModel(),
					_description = @"hash_475EE3FCE54AF260"
				} )
				return true
			else
				
			end
		end, function ( element, menu, controller )
			if not CoD.ModelUtility.IsSelfModelValueTrue( element, controller, "locked" ) then
				CoD.Menu.SetButtonLabel( menu, Enum[@"luibutton"][@"lui_key_xba_pscross"], @"menu/select", nil, "ui_confirm" )
				return true
			elseif CoD.ModelUtility.IsSelfModelValueEqualToEnum( element, controller, "lockState", Enum[@"playlistlockstate"][@"pls_required_dlc_not_available"] ) then
				CoD.Menu.SetButtonLabel( menu, Enum[@"luibutton"][@"lui_key_xba_pscross"], @"menu/select", nil, "ui_confirm" )
				return true
			elseif CoD.ModelUtility.IsSelfModelValueEqualToEnum( element, controller, "lockState", Enum[@"playlistlockstate"][@"hash_4BDEB566326AC98"] ) then
				CoD.Menu.SetButtonLabel( menu, Enum[@"luibutton"][@"lui_key_xba_pscross"], @"menu/select", nil, "ui_confirm" )
				return true
			else
				return false
			end
		end, false )
		f1_local1:AddButtonCallbackFunction( OptionsList, f1_arg0, Enum[@"luibutton"][@"lui_key_xbx_pssquare"], "ui_contextual_1", function ( element, menu, controller, model )
			if CoD.ModelUtility.IsSelfModelValueEqualToEnum( element, controller, "lockState", Enum[@"playlistlockstate"][@"pls_required_dlc_not_available"] ) then
				CoD.StoreUtility.OpenStoreToDLCPack( self, element, controller, "DirectorFindGame", menu )
				return true
			elseif CoD.ModelUtility.IsSelfModelValueEqualToEnum( element, controller, "lockState", Enum[@"playlistlockstate"][@"hash_4BDEB566326AC98"] ) then
				CoD.StoreUtility.OpenStoreToDLCPack( self, element, controller, "DirectorFindGame", menu )
				return true
			else
				
			end
		end, function ( element, menu, controller )
			if CoD.ModelUtility.IsSelfModelValueEqualToEnum( element, controller, "lockState", Enum[@"playlistlockstate"][@"pls_required_dlc_not_available"] ) then
				CoD.Menu.SetButtonLabel( menu, Enum[@"luibutton"][@"lui_key_xbx_pssquare"], @"hash_0", nil, "ui_contextual_1" )
				return false
			elseif CoD.ModelUtility.IsSelfModelValueEqualToEnum( element, controller, "lockState", Enum[@"playlistlockstate"][@"hash_4BDEB566326AC98"] ) then
				CoD.Menu.SetButtonLabel( menu, Enum[@"luibutton"][@"lui_key_xbx_pssquare"], @"hash_0", nil, "ui_contextual_1" )
				return false
			else
				return false
			end
		end, false )
		self:addElement( OptionsList )
		self.OptionsList = OptionsList
		
		local FooterContainerFrontendRight = CoD.FooterContainer_Frontend_Right.new( f1_local1, f1_arg0, 0, 1, 0, 0, 1, 1, -48, 0 )
		FooterContainerFrontendRight:registerEventHandler( "menu_loaded", function ( element, event )
			local f9_local0 = nil
			if element.menuLoaded then
				f9_local0 = element:menuLoaded( event )
			elseif element.super.menuLoaded then
				f9_local0 = element.super:menuLoaded( event )
			end
			if not IsPC() then
				SizeToSafeArea( element, f1_arg0 )
			end
			if not f9_local0 then
				f9_local0 = element:dispatchEventToChildren( event )
			end
			return f9_local0
		end )
		self:addElement( FooterContainerFrontendRight )
		self.FooterContainerFrontendRight = FooterContainerFrontendRight
		
		local BackingGrayMediumLeft = CoD.header_container_frontend.new( f1_local1, f1_arg0, 0, 0, 0, 1920, 0, 0, 0, 42 )
		BackingGrayMediumLeft:registerEventHandler( "menu_loaded", function ( element, event )
			local f10_local0 = nil
			if element.menuLoaded then
				f10_local0 = element:menuLoaded( event )
			elseif element.super.menuLoaded then
				f10_local0 = element.super:menuLoaded( event )
			end
			SizeToSafeArea( element, f1_arg0 )
			if not f10_local0 then
				f10_local0 = element:dispatchEventToChildren( event )
			end
			return f10_local0
		end )
		self:addElement( BackingGrayMediumLeft )
		self.BackingGrayMediumLeft = BackingGrayMediumLeft
		
		local SelectedPlaylistInfo = CoD.DirectorFindGamePlaylistInfoMP.new( f1_local1, f1_arg0, 0.5, 0.5, 324, 864, 0.5, 0.5, -255, 257 )
		self:addElement( SelectedPlaylistInfo )
		self.SelectedPlaylistInfo = SelectedPlaylistInfo
		
		local DirectorHeaderTabSafeArea = CoD.DirectorHeaderTabSafeArea.new( f1_local1, f1_arg0, 0, 0, 0, 1920, 0, 0, 0, 1080 )
		DirectorHeaderTabSafeArea.CommonHeader.subtitle.StageTitle:setText( LocalizeToUpperString( @"hash_538A4FBEBCE1E6BE" ) )
		DirectorHeaderTabSafeArea.Tabs.customClasssList:setDataSource( "DirectorFilters" )
		DirectorHeaderTabSafeArea:subscribeToGlobalModel( f1_arg0, "LobbyRoot", "lobbyTitle", function ( model )
			local f11_local0 = model:get()
			if f11_local0 ~= nil then
				DirectorHeaderTabSafeArea.CommonHeader.subtitle.subtitle:setText( Engine[@"hash_4F9F1239CFD921FE"]( f11_local0 ) )
			end
		end )
		DirectorHeaderTabSafeArea:registerEventHandler( "menu_loaded", function ( element, event )
			local f12_local0 = nil
			if element.menuLoaded then
				f12_local0 = element:menuLoaded( event )
			elseif element.super.menuLoaded then
				f12_local0 = element.super:menuLoaded( event )
			end
			SizeToSafeArea( element, f1_arg0 )
			if not f12_local0 then
				f12_local0 = element:dispatchEventToChildren( event )
			end
			return f12_local0
		end )
		self:addElement( DirectorHeaderTabSafeArea )
		self.DirectorHeaderTabSafeArea = DirectorHeaderTabSafeArea
		
		local UpsellBanner = CoD.UpsellBanner.new( f1_local1, f1_arg0, 0, 0, 1284, 1824, 0, 0, 823.5, 973.5 )
		self:addElement( UpsellBanner )
		self.UpsellBanner = UpsellBanner
		
		OptionsList:linkToElementModel( DirectorHeaderTabSafeArea.Tabs.customClasssList, "dataSource", true, function ( model )
			local f13_local0 = model:get()
			if f13_local0 ~= nil then
				OptionsList:setDataSource( f13_local0 )
			end
		end )
		SelectedPlaylistInfo:linkToElementModel( OptionsList, nil, false, function ( model )
			SelectedPlaylistInfo:setModel( model, f1_arg0 )
		end )
		UpsellBanner:linkToElementModel( OptionsList, nil, false, function ( model )
			UpsellBanner:setModel( model, f1_arg0 )
		end )
		f1_local1:AddButtonCallbackFunction( self, f1_arg0, Enum[@"luibutton"][@"lui_key_xbb_pscircle"], nil, function ( element, menu, controller, model )
			GoBack( self, controller )
			return true
		end, function ( element, menu, controller )
			CoD.Menu.SetButtonLabel( menu, Enum[@"luibutton"][@"lui_key_xbb_pscircle"], @"menu/back", nil, nil )
			return true
		end, false )
		LUI.OverrideFunction_CallOriginalFirst( self, "close", function ( element )
			ClearMenuSavedState( f1_local1 )
		end )
		OptionsList.id = "OptionsList"
		FooterContainerFrontendRight:setModel( self.buttonModel, f1_arg0 )
		if CoD.isPC then
			FooterContainerFrontendRight.id = "FooterContainerFrontendRight"
		end
		DirectorHeaderTabSafeArea.id = "DirectorHeaderTabSafeArea"
		self:processEvent( {
			name = "menu_loaded",
			controller = f1_arg0
		} )
		self.__defaultFocus = OptionsList
		if CoD.isPC and (IsKeyboard( f1_arg0 ) or self.ignoreCursor) then
			self:restoreState( f1_arg0 )
		end
		LUI.OverrideFunction_CallOriginalSecond( self, "close", self.__onClose )
		if PostLoadFunc then
			PostLoadFunc( self, f1_arg0 )
		end
		
		local f1_local9 = self
		CoD.BaseUtility.SetModelFromPropertyModel( f1_arg0, self, self )
		CoD.DoubleXPUtility.SetupPromotionalXPTimer( f1_arg0, f1_local1 )
		return self
	end

	CoD.DirectorFindGame.__onClose = function ( f19_arg0 )
		f19_arg0.SelectedPlaylistInfo:close()
		f19_arg0.UpsellBanner:close()
		f19_arg0.OptionsList:close()
		f19_arg0.FooterContainerFrontendRight:close()
		f19_arg0.BackingGrayMediumLeft:close()
		f19_arg0.DirectorHeaderTabSafeArea:close()
	end

	CoD.DirectorUtility.CreateFilterCards = function ( f113_arg0, f113_arg1, f113_arg2, f113_arg3, f113_arg4, f113_arg5, f113_arg6, f113_arg7 )
		local f113_local0 = 1
		for f113_local1 = 1, #f113_arg3, 1 do
			local f113_local4 = f113_arg3[f113_local1]
			if f113_local4 ~= nil then
				local f113_local5 = CoD.DirectorUtility.CardNavigateToLobby
				local f113_local6 = f113_local4.id
				local f113_local7 = f113_local4.name
				if f113_local4.isNewGameOrResumeGame == true then
					f113_local5 = CoD.DirectorUtility.CPOnlineNewGame
					f113_local6 = 0
				end
				local f113_local8 = false
				local f113_local9 = Engine[@"getusertier"]( f113_arg1 )
				local f113_local10 = Engine[@"hash_514ECF96E169F000"]( f113_arg1, f113_local6 )
				local f113_local11 = false
				local f113_local12 = false
				local f113_local13 = false
				local f113_local14 = false
				if CoD.DirectorUtility.DisableForCurrentMilestone( f113_arg1 ) then
					local f113_local15 = Engine[@"getxpscale"]( f113_arg1 )
					f113_local11 = f113_local15 and f113_local15 >= 2
					local f113_local16 = Engine[@"getgunxpscale"]( f113_arg1 )
					f113_local12 = f113_local16 and f113_local16 >= 2
				else
					f113_local11 = LuaUtils.PlaylistRulesIncludes( f113_local4.rules, @"scr_xpscalemp", "2" )
					f113_local12 = LuaUtils.PlaylistRulesIncludes( f113_local4.rules, @"scr_gunxpscalemp", "2" )
					f113_local13 = LuaUtils.PlaylistRulesIncludes( f113_local4.rules, @"scr_credit_scale", "2" )
					f113_local14 = CoD.ZombieUtility.IsDoubleNP( f113_arg1 ) and f113_local4.mainMode == Enum[@"lobbymainmode"][@"lobby_mainmode_zm"]
				end
				if not (f113_local4.minUserTier == Enum[@"eusertier"][@"user_tier_none"] or f113_local9 >= f113_local4.minUserTier) or f113_local4.maxUserTier ~= Enum[@"eusertier"][@"user_tier_none"] and f113_local4.maxUserTier < f113_local9 then
					--f113_local8 = true
				end
				if f113_local10 == Enum[@"playlistlockstate"][@"hash_5B469AFA64270B7E"] then
					--f113_local8 = true
				end
				if f113_arg4 ~= nil and f113_arg4 ~= f113_local4.mainMode then
					f113_local8 = true
				end
				if f113_arg5 ~= nil and f113_arg5 ~= tonumber(f113_local4.arenaSlot) and tonumber(f113_local4.arenaSlot) >= 0 then
					f113_local8 = true
				end
				if f113_local4.hidden == true and f113_arg7 ~= true then
					--f113_local8 = true
				end
				if f113_arg6 ~= nil then
					if true == Dvar.tu17_playlist_autoschedule:get() then
						if f113_arg6 ~= CoD.DirectorUtility.IsAutoFeatured( f113_arg1, f113_arg4, f113_local4 ) then
							--f113_local8 = true
						end
					elseif f113_arg6 ~= f113_local4.featuredCategory then
						--f113_local8 = true
					end
				end
				local f113_local15 = {}
				local f113_local16 = {}
				local f113_local17 = {}
				local f113_local18 = {}
				for f113_local22, f113_local23 in ipairs( f113_local4.rotationList ) do
					if not f113_local16[f113_local23.map] then
						f113_local16[f113_local23.map] = true
						table.insert( f113_local15, f113_local23.map )
					end
					if not f113_local18[f113_local23.gametype] then
						f113_local18[f113_local23.gametype] = true
						table.insert( f113_local17, f113_local23.gametype )
					end
				end
				local f113_local19, f113_local20 = nil
				for f113_local25, f113_local26 in ipairs( f113_local15 ) do
					local f113_local27 = Engine[@"hash_4F9F1239CFD921FE"]( CoD.BaseUtility.GetMapValue( f113_local26, "mapName", @"hash_0" ) )
					if CoD.MapUtility.IsDLCMapFromName( f113_local26 ) then
						local f113_local24
						if f113_local20 then
							f113_local24 = f113_local20 .. ", "
							if not f113_local24 then
							
							else
								f113_local20 = f113_local24 .. f113_local27
							end
						end
						f113_local24 = ""
					end
					local f113_local24
					if f113_local19 then
						f113_local24 = f113_local19 .. ", "
						if not f113_local24 then
						
						else
							f113_local19 = f113_local24 .. f113_local27
						end
					end
					f113_local24 = ""
				end
				local f113_local21 = nil
				if f113_local20 then
					if f113_local19 then
						f113_local21 = f113_local19 .. "\n\n"
						if not f113_local21 then
						
						else
							f113_local19 = f113_local21 .. Engine[@"hash_4F9F1239CFD921FE"]( @"hash_16407D1BFF6842DA", f113_local20 )
						end
					end
					f113_local21 = ""
				end
				if IsBooleanDvarSet( "ui_freeMPDLC" ) then
					if f113_local19 then
						f113_local21 = f113_local19 .. "\n\n"
						if not f113_local21 then
						
						else
							f113_local19 = f113_local21 .. Engine[@"hash_4F9F1239CFD921FE"]( @"hash_4C83606D26B21D6E" )
						end
					end
					f113_local21 = ""
				end
				f113_local21 = nil
				for f113_local26, f113_local27 in ipairs( f113_local17 ) do
					local f113_local24 = Engine[@"hash_4F9F1239CFD921FE"]
					local f113_local28 = Engine[@"hash_1F2CD89B3C345FD3"]( f113_local27 )
					f113_local24 = f113_local24( f113_local28.nameRef )
					if f113_local21 then
						f113_local28 = f113_local21 .. ", "
						if not f113_local28 then
						
						else
							f113_local21 = f113_local28 .. f113_local24
						end
					end
					f113_local28 = ""
				end
				local f113_local22 = Engine[@"hash_4F9F1239CFD921FE"]( @"menu/player_range", f113_local4.minPlayers, f113_local4.maxPlayers )
				if f113_local4.isQuickplayCard then
					if not CoD.DirectorUtility.IsQuickplayAvailableForMode( f113_local4.mainMode ) then
						--f113_local8 = true
					end
					f113_local19 = Engine[@"hash_4F9F1239CFD921FE"]( @"hash_323ED5097167B286" )
					f113_local21 = Engine[@"hash_4F9F1239CFD921FE"]( @"hash_323ED5097167B286" )
					f113_local22 = Engine[@"hash_4F9F1239CFD921FE"]( @"hash_307AE56507881BD6" )
				end
				if true == Dvar.tu17_playlist_autoschedule:get() and CoDShared.Playlists.IsBlacklisted( f113_local4.uniqueName ) then
					--f113_local8 = true
				end
				if CoD.isPC and CoD.PCKoreaUtility.IsPlaylistEntryBlacklisted( f113_local4 ) then
					--f113_local8 = true
				end
				if f113_local8 ~= true then
					local f113_local23 = false
					if CoD.DirectorUtility.ShouldFeaturedAlternativeEntry( f113_arg1, f113_local4.mainMode ) then
						f113_local23 = f113_local4.featuredAlt == true
					else
						f113_local23 = f113_local4[@"featured"] == true
					end
					if CoD.DirectorUtility.RegionOnlyAllowsFeaturedPlaylistForMode( f113_arg1, f113_local4.mainMode ) and Dvar.ui_wzFeaturedOnlyCountriesPlaylistEntryID:exists() and 0 ~= tonumber( Dvar.ui_wzFeaturedOnlyCountriesPlaylistEntryID:get() ) then
						if f113_local6 == tonumber( Dvar.ui_wzFeaturedOnlyCountriesPlaylistEntryID:get() ) then
							f113_local23 = true
						else
							f113_local23 = false
						end
					end
					if true == Dvar.tu17_playlist_autoschedule:get() then
						if CoD.DirectorUtility.IsAutoShowcased( f113_arg1, f113_arg4, f113_local4 ) then
							f113_local23 = true
						else
							f113_local23 = false
						end
					end
					f113_arg0.cards[f113_local0] = {
						id = f113_arg2 .. "Ent" .. f113_local0,
						playlist = f113_local6,
						name = Engine[@"hash_4F9F1239CFD921FE"]( f113_local7 ),
						playlistDesc = Engine[@"hash_632A860841DBD025"]( f113_arg1, f113_local6 ),
						mapsString = f113_local19,
						modesString = f113_local21,
						playersString = f113_local22,
						icon = f113_local4.image,
						iconBackground = f113_local4.imageBackground,
						iconBackgroundFocus = f113_local4.imageBackgroundFocus,
						action = f113_local5,
						mode = f113_local4.mainMode,
						locked = Engine[@"isplaylistlocked"]( f113_arg1, f113_local6 ),
						lockState = f113_local10,
						featured = f113_local23,
						isQuickplayCard = f113_local4.isQuickplayCard,
						canQuickplay = f113_local4.canQuickplay,
						lowPopPlaylist = f113_local4.lowPopPlaylist,
						maxPartySize = f113_local4.maxPartySize,
						hasDoubleXP = f113_local11,
						hasDoubleWeaponXP = f113_local12,
						hasTierBoost = f113_local13,
						hasDoubleNP = f113_local14,
						showForAllClients = false
					}
					f113_local0 = f113_local0 + 1
				end
			end
		end
	end
end