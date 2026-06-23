--[[
		.\hksc.exe ".\Lua\MainMenu.Lua" -o "C:\Program Files (x86)\Call of Duty Black Ops 4\project-bo4\mods\T8ShieldSupport\Lua\MainMenu.luac"
]]

---------------------------

CoD.ShieldInitLuaFile()

---------------------------

-- dvars
Engine[@"exec"](Engine[@"getprimarycontroller"](), "readjson shield_dw_ip demonware ipv4 string")

---------------------------

-- Buttons in Extra Main
DataSources.DirectorExtraHomeButtonsCustom = ListHelper_SetupDataSource( "DirectorExtraHomeButtonsCustom", function ( f85_arg0, f85_arg1 )
	local f85_local0 = {}
	local f85_local1 = IsLobbyNetworkModeLAN()
	local f85_local2
	if Engine[@"hash_77D47312EBA41751"]() or LobbyData.GetLobbyMenuByName( LuaEnum.UI.DIRECTOR_ONLINE_MP_TRAINING ) == nil then
		f85_local2 = false
	else
		f85_local2 = true
	end
	local f85_local3 = false
	local f85_local4 = false
	local f85_local5 = Engine[@"getglobalmodel"]()
	f85_local5 = f85_local5:create( CoD.LobbyUtility.LobbyNavigationActionModel )
	f85_local5 = f85_local5:get()
	if f85_local5 == LuaEnum.UI.DIRECTOR_LAN_SELECT then
		f85_local3 = true
	elseif f85_local5 == LuaEnum.UI.DIRECTOR_ONLINE then
		f85_local4 = true
	end
	if f85_local1 then
		if not LuaUtils.OfflineOnlyDemo() then
			table.insert( f85_local0, {
				models = {
					subtitle = @"hash_2D63F1918C92A85D",
					iconBackground = @"blacktransparent",
					iconBackgroundFocus = @"blacktransparent",
					showOnLeft = true,
					small = true,
					locked = false
				},
				properties = {
					action = CoD.DirectorUtility.DirectorSelectAction,
					actionParam = LuaEnum.UI.DIRECTOR_ONLINE,
					selectIndex = f85_local3
				}
			} )
		end
		table.insert( f85_local0, {
			models = {
				subtitle = @"hash_5D7DF8AD7167B198",
				iconBackground = @"blacktransparent",
				iconBackgroundFocus = @"blacktransparent",
				showOnLeft = true,
				small = true,
				locked = false
			},
			properties = {
				action = CoD.DirectorUtility.DirectorSelectOpenPopup,
				actionParam = "LobbyServerBrowserOverlay"
			}
		} )
	else
		if f85_local2 then
			table.insert( f85_local0, {
				models = {
					showOnLeft = true,
					small = false,
					locked = false,
					trialLocked = Engine[@"hash_5CB675CA7856DA25"](),
					iconBackground = @"ui_icon_director_ct_tile",
					iconBackgroundFocus = @"ui_icon_director_ct_tile_focus",
					subtitle = @"hash_5AA1920F2AF31A03",
					showForAllClients = false
				},
				properties = {
					action = CoD.DirectorUtility.DirectorNavigateToSpecialistHeadquarters
				}
			} )
		end
		table.insert( f85_local0, {
			models = {
				subtitle = @"menu/theater",
				iconBackground = @"blacktransparent",
				iconBackgroundFocus = @"blacktransparent",
				showOnLeft = true,
				small = true,
				locked = CoD.DirectorUtility.DisableForCurrentMilestone( f85_arg0 ) and not CoD.BaseUtility.IsDvarEnabled( "ui_showTheater" ),
				trialLocked = Engine[@"hash_5CB675CA7856DA25"]()
			},
			properties = {
				action = CoD.DirectorUtility.DirectorSelectTheater,
				actionParam = LuaEnum.UI.DIRECTOR_ONLINE_THEATER
			}
		} ) 
		table.insert( f85_local0, {
			models = {
				subtitle = @"shield/serverbrowser",
				iconBackground = @"ui_icon_blackmarket_store_tile_focus_05",
				iconBackgroundFocus = @"ui_icon_blackmarket_store_tile_focus_05",
				showOnLeft = true,
				small = false,
				locked = Engine[@"getdvarint"](@"shield_is_offline") == 1
			},
			properties = {
				action = CoD.DirectorUtility.DirectorSelectOpenPopup,
				actionParam = "ShieldLobbyServerBrowserOverlay_Select"
			}
		} )
		local f85_local6 = @"ui_icon_blackmarket_store_tile_default_01"
		local f85_local7 = @"ui_icon_blackmarket_store_tile_focus_01"
		if IsBooleanDvarSet( @"loot_enableblackmarket" ) then
			local f85_local8 = Engine[@"hash_2E00B2F29271C60B"]( CoDShared.Loot.GetCurrentSeason() )
			local f85_local9
			if f85_local8 then
				f85_local9 = f85_local8[@"squareimage"]
				if not f85_local9 then
				
				else
					local f85_local10
					if f85_local8 then
						f85_local10 = f85_local8[@"hash_7B4983E074152C2D"]
						if not f85_local10 then
						
						else
							if f85_local8 then
								f85_local6 = f85_local8[@"hash_751E7101B70C8A6C"] or f85_local6
							end
							if f85_local8 then
								f85_local7 = f85_local8[@"hash_170243CFDCD07174"] or f85_local7
							end
							table.insert( f85_local0, {
								models = {
									showOnLeft = false,
									locked = false,
									iconBackground = f85_local9,
									iconBackgroundFocus = f85_local10,
									subtitle = @"hash_229C903C6DF90D6F",
									small = false,
									showForAllClients = true
								},
								properties = {
									action = OpenQuarterMaster
								}
							} )
						end
					end
					f85_local10 = @"ui_icon_blackmarket_store_tile_focus"
				end
			end
			f85_local9 = @"ui_icon_blackmarket_store_tile_default"
		end
		if IsCommerceEnabledOnPC() then
			table.insert( f85_local0, {
				models = {
					showOnLeft = not IsBooleanDvarSet( @"loot_enableblackmarket" ),
					iconBackground = f85_local6,
					iconBackgroundFocus = f85_local7,
					locked = false,
					subtitle = @"hash_4191CDDA584B4408",
					small = false,
					showForAllClients = true
				},
				properties = {
					action = OpenStore,
					actionParam = "DirectorPlayButton"
				}
			} )
		end

		if not CoD.isPC then 
			table.insert( f85_local0, {
				models = {
					subtitle = @"hash_2968A794E7F44FAD",
					iconBackground = @"blacktransparent",
					iconBackgroundFocus = @"blacktransparent",
					showOnLeft = true,
					small = true,
					locked = LuaUtils.OnlineOnlyDemo(),
					trialLocked = Engine[@"hash_5CB675CA7856DA25"]()
				},
				properties = {
					action = CoD.DirectorUtility.DirectorSelectAction,
					actionParam = LuaEnum.UI.DIRECTOR_LAN_SELECT,
					selectIndex = f85_local4
				}
			} )
		end
	end
	CoD.DirectorUtility.AddLobbyNavSubscriptionOnce( f85_arg1 )
	CoD.DirectorUtility.AddInstallSubscriptionOnce( f85_arg1 )
	if not f85_arg1._hasAutoEventSubscription then
		local f85_local11 = f85_arg1
		local f85_local12 = f85_arg1.subscribeToModel
		local f85_local6 = Engine[@"getglobalmodel"]()
		f85_local6 = f85_local6:create( "AutoEvents" )
		f85_local12( f85_local11, f85_local6:create( "cycled" ), function ()
			f85_arg1:updateDataSource()
		end, false )
		f85_arg1._hasAutoEventSubscription = true
	end
	return f85_local0
end )

---------------------------
-- Director Select, needs to have a custom datasource for server browser and other things.., custom menu beta test
CoD.DirectorSelectOverride = function()
	if Engine[@"getdvarint"]("shield_director_blur") == 0 then
		CoD.directorSelect = InheritFrom( LUI.UIElement )
		CoD.directorSelect.__defaultWidth = 1920
		CoD.directorSelect.__defaultHeight = 1080
		CoD.directorSelect.new = function ( f1_arg0, f1_arg1, f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
			local self = LUI.UIElement.new( f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
			self:setClass( CoD.directorSelect )
			self.id = "directorSelect"
			self.soundSet = "FrontendMain"
			self.onlyChildrenFocusable = true
			self.anyChildUsesUpdateState = true
			f1_arg0:addElementToPendingUpdateStateList( self )

			local backing = LUI.UIImage.new( 0, 1, 0, 0, 0, 1, 0, 0 )
			backing:setRGB( 0, 0, 0 )
			backing:setMaterial( LUI.UIImage.GetCachedMaterial( @"hash_E2354BE557C4C7A" ) )
			backing:setShaderVector( 0, 0, 0, 0, 0 )
			self:addElement( backing )
			self.backing = backing
			
			local BackgroundImage = LUI.UIImage.new( 0, 1, 0, 0, 0, 1, 0, 0 )
			BackgroundImage:setAlpha( 0.85 )
			BackgroundImage:setImage( RegisterImage( @"hash_64BF88A437F4C579" ) )
			self:addElement( BackgroundImage )
			self.BackgroundImage = BackgroundImage

			--self:setAlpha(0)
			
			local FramingCornerBrackets = CoD.CommonCornerBrackets01.new( f1_arg0, f1_arg1, 0.5, 0.5, -516.5, 516.5, 0, 0, 222, 796 )
			FramingCornerBrackets:setAlpha( 0.1 )
			self:addElement( FramingCornerBrackets )
			self.FramingCornerBrackets = FramingCornerBrackets
			
			local DotLineBottom = LUI.UIImage.new( 0.5, 0.5, -474.5, 474.5, 0, 0, 777, 781 )
			DotLineBottom:setAlpha( 0.4 )
			DotLineBottom:setImage( RegisterImage( @"hash_6F9C7F41C631866E" ) )
			DotLineBottom:setMaterial( LUI.UIImage.GetCachedMaterial( @"hash_31CC85D0A86303B0" ) )
			DotLineBottom:setShaderVector( 0, 1.2, 0, 0, 0 )
			self:addElement( DotLineBottom )
			self.DotLineBottom = DotLineBottom
			
			local DotLineTop = LUI.UIImage.new( 0.5, 0.5, -474.5, 474.5, 0, 0, 238, 242 )
			DotLineTop:setAlpha( 0.4 )
			DotLineTop:setImage( RegisterImage( @"hash_6F9C7F41C631866E" ) )
			DotLineTop:setMaterial( LUI.UIImage.GetCachedMaterial( @"hash_31CC85D0A86303B0" ) )
			DotLineTop:setShaderVector( 0, 1.2, 0, 0, 0 )
			self:addElement( DotLineTop )
			self.DotLineTop = DotLineTop
			
			local f1_local6 = nil
			self.Header = LUI.UIElement.createFake()
			local HeaderPC = nil
			
			HeaderPC = CoD.DirectorScreenHeader.new( f1_arg0, f1_arg1, 0.5, 0.5, -553, 81, 0.5, 0.5, -394, -297 )
			HeaderPC:setAlpha( 0 )
			HeaderPC:setZoom( 75 )
			HeaderPC.Header:setText( LocalizeToUpperString( @"hash_156CB4013028D74E" ) )
			self:addElement( HeaderPC )
			self.HeaderPC = HeaderPC
			
			local DirectorLeaderActivitySelect = CoD.DirectorLeaderActivitySelect.new( f1_arg0, f1_arg1, 0.5, 0.5, -622.5, -322.5, 1, 1, -197, -147 )
			DirectorLeaderActivitySelect:mergeStateConditions( {
				{
					stateName = "Invisible",
					condition = function ( menu, element, event )
						return AlwaysTrue()
					end
				}
			} )
			self:addElement( DirectorLeaderActivitySelect )
			self.DirectorLeaderActivitySelect = DirectorLeaderActivitySelect
			
			local pckeyboardNavigationRedirector2 = nil
			
			pckeyboardNavigationRedirector2 = CoD.emptyFocusable.new( f1_arg0, f1_arg1, 0.7, 1, 0, 0, 0.27, 0.32, -35, -35 )
			self:addElement( pckeyboardNavigationRedirector2 )
			self.pckeyboardNavigationRedirector2 = pckeyboardNavigationRedirector2
			
			local LogoBO4 = nil
			
			LogoBO4 = LUI.UIFixedAspectRatioImage.new( 0.5, 0.5, -945, -641, 0.5, 0.5, -525, -373 )
			LogoBO4:setAlpha( 0 )
			LogoBO4:setScale( 0.8, 0.8 )
			LogoBO4:setImage( RegisterImage( @"hash_3A921D8110F2D3BD" ) )
			self:addElement( LogoBO4 )
			self.LogoBO4 = LogoBO4
			
			local ButtonListLeft = LUI.UIList.new( f1_arg0, f1_arg1, 15, 0, nil, false, false, false, false )
			ButtonListLeft:setLeftRight( 0.5, 0.5, -725, -513 )
			ButtonListLeft:setTopBottom( 0, 0, 265, 510 )
			ButtonListLeft:setWidgetType( CoD.DirectorPreGameButtonLeftJustified )
			ButtonListLeft:setVerticalCount( 4 )
			ButtonListLeft:setSpacing( 15 )
			ButtonListLeft:setAlignment( Enum[@"hash_67A5123B654282D2"][@"hash_558C8A85F2048829"] )
			ButtonListLeft:setFilter( function ( f3_arg0 )
				return f3_arg0.showOnLeft:get() == true
			end )
			ButtonListLeft:setDataSource( "DirectorExtraHomeButtonsCustom" )
			ButtonListLeft:linkToElementModel( ButtonListLeft, "trialLocked", true, function ( model, f4_arg1 )
				CoD.Menu.UpdateButtonShownState( f4_arg1, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
			end )
			ButtonListLeft:linkToElementModel( ButtonListLeft, "locked", true, function ( model, f5_arg1 )
				CoD.Menu.UpdateButtonShownState( f5_arg1, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
			end )
			local ButtonFeatured = ButtonListLeft
			local ButtonListRight = ButtonListLeft.subscribeToModel
			local ButtonModes = Engine[@"hash_78DF2E5447F384B9"]()
			ButtonListRight( ButtonFeatured, ButtonModes["lobbyRoot.lobbyNav"], function ( f6_arg0, f6_arg1 )
				CoD.Menu.UpdateButtonShownState( f6_arg1, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
			end, false )
			ButtonFeatured = ButtonListLeft
			ButtonListRight = ButtonListLeft.subscribeToModel
			ButtonModes = Engine[@"hash_78DF2E5447F384B9"]()
			ButtonListRight( ButtonFeatured, ButtonModes["lobbyRoot.gameClient.update"], function ( f7_arg0, f7_arg1 )
				CoD.Menu.UpdateButtonShownState( f7_arg1, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
			end, false )
			ButtonFeatured = ButtonListLeft
			ButtonListRight = ButtonListLeft.subscribeToModel
			ButtonModes = Engine[@"hash_78DF2E5447F384B9"]()
			ButtonListRight( ButtonFeatured, ButtonModes["lobbyRoot.privateClient.update"], function ( f8_arg0, f8_arg1 )
				CoD.Menu.UpdateButtonShownState( f8_arg1, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
			end, false )
			ButtonListLeft:linkToElementModel( ButtonListLeft, "showForAllClients", true, function ( model, f9_arg1 )
				CoD.Menu.UpdateButtonShownState( f9_arg1, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
			end )
			ButtonListLeft:registerEventHandler( "list_item_gain_focus", function ( element, event )
				local f10_local0 = nil
				CoD.DirectorUtility.UpdateDescriptionTextFromSelectMenu( f1_arg1, element )
				return f10_local0
			end )
			ButtonListLeft:registerEventHandler( "gain_focus", function ( element, event )
				local f11_local0 = nil
				if element.gainFocus then
					f11_local0 = element:gainFocus( event )
				elseif element.super.gainFocus then
					f11_local0 = element.super:gainFocus( event )
				end
				CoD.Menu.UpdateButtonShownState( element, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
				return f11_local0
			end )
			f1_arg0:AddButtonCallbackFunction( ButtonListLeft, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], "ui_confirm", function ( element, menu, controller, model )
				if CoD.ModelUtility.IsSelfModelValueTrue( element, controller, "trialLocked" ) and AlwaysFalse() then
					OpenOverlay( self, "Store", controller )
					PlaySoundAlias( "uin_toggle_generic" )
					return true
				elseif not CoD.ModelUtility.IsSelfModelValueTrue( element, controller, "locked" ) and CoD.DirectorUtility.ShowForAllClients( element, controller ) and not CoD.ModelUtility.IsSelfModelValueTrue( element, controller, "trialLocked" ) then
					ProcessListAction( self, element, controller, menu )
					PlaySoundAlias( "uin_toggle_generic" )
					return true
				else
					
				end
			end, function ( element, menu, controller )
				if CoD.ModelUtility.IsSelfModelValueTrue( element, controller, "trialLocked" ) and AlwaysFalse() then
					CoD.Menu.SetButtonLabel( menu, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], @"hash_4191CDDA584B4408", nil, "ui_confirm" )
					return true
				elseif not CoD.ModelUtility.IsSelfModelValueTrue( element, controller, "locked" ) and CoD.DirectorUtility.ShowForAllClients( element, controller ) and not CoD.ModelUtility.IsSelfModelValueTrue( element, controller, "trialLocked" ) then
					CoD.Menu.SetButtonLabel( menu, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], @"hash_6D0BB36CD318F55F", nil, "ui_confirm" )
					return true
				else
					return false
				end
			end, false )
			self:addElement( ButtonListLeft )
			self.ButtonListLeft = ButtonListLeft
			
			ButtonListRight = LUI.UIList.new( f1_arg0, f1_arg1, 15, 0, nil, false, false, false, false )
			ButtonListRight:setLeftRight( 0.5, 0.5, 500, 712 )
			ButtonListRight:setTopBottom( 0, 0, 265, 510 )
			ButtonListRight:setWidgetType( CoD.DirectorPreGameButtonLeftJustified )
			ButtonListRight:setVerticalCount( 4 )
			ButtonListRight:setSpacing( 15 )
			ButtonListRight:setAlignment( Enum[@"hash_67A5123B654282D2"][@"hash_558C8A85F2048829"] )
			ButtonListRight:setFilter( function ( f14_arg0 )
				return f14_arg0.showOnLeft:get() == false
			end )
			ButtonListRight:setDataSource( "DirectorExtraHomeButtonsCustom" )
			ButtonListRight:linkToElementModel( ButtonListRight, "locked", true, function ( model, f15_arg1 )
				CoD.Menu.UpdateButtonShownState( f15_arg1, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
			end )
			ButtonModes = ButtonListRight
			ButtonFeatured = ButtonListRight.subscribeToModel
			local SafeAreaContainer = Engine[@"hash_78DF2E5447F384B9"]()
			ButtonFeatured( ButtonModes, SafeAreaContainer["lobbyRoot.lobbyNav"], function ( f16_arg0, f16_arg1 )
				CoD.Menu.UpdateButtonShownState( f16_arg1, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
			end, false )
			ButtonModes = ButtonListRight
			ButtonFeatured = ButtonListRight.subscribeToModel
			SafeAreaContainer = Engine[@"hash_78DF2E5447F384B9"]()
			ButtonFeatured( ButtonModes, SafeAreaContainer["lobbyRoot.gameClient.update"], function ( f17_arg0, f17_arg1 )
				CoD.Menu.UpdateButtonShownState( f17_arg1, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
			end, false )
			ButtonModes = ButtonListRight
			ButtonFeatured = ButtonListRight.subscribeToModel
			SafeAreaContainer = Engine[@"hash_78DF2E5447F384B9"]()
			ButtonFeatured( ButtonModes, SafeAreaContainer["lobbyRoot.privateClient.update"], function ( f18_arg0, f18_arg1 )
				CoD.Menu.UpdateButtonShownState( f18_arg1, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
			end, false )
			ButtonListRight:linkToElementModel( ButtonListRight, "showForAllClients", true, function ( model, f19_arg1 )
				CoD.Menu.UpdateButtonShownState( f19_arg1, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
			end )
			ButtonListRight:registerEventHandler( "list_item_gain_focus", function ( element, event )
				local f20_local0 = nil
				CoD.DirectorUtility.UpdateDescriptionTextFromSelectMenu( f1_arg1, element )
				return f20_local0
			end )
			ButtonListRight:registerEventHandler( "gain_focus", function ( element, event )
				local f21_local0 = nil
				if element.gainFocus then
					f21_local0 = element:gainFocus( event )
				elseif element.super.gainFocus then
					f21_local0 = element.super:gainFocus( event )
				end
				CoD.Menu.UpdateButtonShownState( element, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
				return f21_local0
			end )
			f1_arg0:AddButtonCallbackFunction( ButtonListRight, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], "ui_confirm", function ( element, menu, controller, model )
				if not CoD.ModelUtility.IsSelfModelValueTrue( element, controller, "locked" ) and CoD.DirectorUtility.ShowForAllClients( element, controller ) then
					PlaySoundAlias( "uin_toggle_generic" )
					ProcessListAction( self, element, controller, menu )
					return true
				else
					
				end
			end, function ( element, menu, controller )
				if not CoD.ModelUtility.IsSelfModelValueTrue( element, controller, "locked" ) and CoD.DirectorUtility.ShowForAllClients( element, controller ) then
					CoD.Menu.SetButtonLabel( menu, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], @"hash_6D0BB36CD318F55F", nil, "ui_confirm" )
					return true
				else
					return false
				end
			end, false )
			self:addElement( ButtonListRight )
			self.ButtonListRight = ButtonListRight
			
			ButtonFeatured = LUI.UIList.new( f1_arg0, f1_arg1, 25, 0, nil, false, false, false, false )
			ButtonFeatured:setLeftRight( 0.5, 0.5, -475, 475 )
			ButtonFeatured:setTopBottom( 0, 0, 265, 659 )
			ButtonFeatured:setWidgetType( CoD.DirectorSelectButton )
			ButtonFeatured:setHorizontalCount( 3 )
			ButtonFeatured:setSpacing( 25 )
			ButtonFeatured:setAlignment( Enum[@"hash_67A5123B654282D2"][@"hash_558C8A85F2048829"] )
			ButtonFeatured:setStaggeredIntroTime( 100 )
			ButtonFeatured:setDataSource( "DirectorFeaturedButtons" )
			ButtonFeatured:linkToElementModel( ButtonFeatured, "trialLocked", true, function ( model, f24_arg1 )
				CoD.Menu.UpdateButtonShownState( f24_arg1, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
			end )
			SafeAreaContainer = ButtonFeatured
			ButtonModes = ButtonFeatured.subscribeToModel
			local IGRPerksDirectorButton = Engine[@"hash_78DF2E5447F384B9"]()
			ButtonModes( SafeAreaContainer, IGRPerksDirectorButton["lobbyRoot.lobbyNav"], function ( f25_arg0, f25_arg1 )
				CoD.Menu.UpdateButtonShownState( f25_arg1, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
			end, false )
			SafeAreaContainer = ButtonFeatured
			ButtonModes = ButtonFeatured.subscribeToModel
			IGRPerksDirectorButton = Engine[@"hash_78DF2E5447F384B9"]()
			ButtonModes( SafeAreaContainer, IGRPerksDirectorButton["lobbyRoot.gameClient.update"], function ( f26_arg0, f26_arg1 )
				CoD.Menu.UpdateButtonShownState( f26_arg1, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
			end, false )
			SafeAreaContainer = ButtonFeatured
			ButtonModes = ButtonFeatured.subscribeToModel
			IGRPerksDirectorButton = Engine[@"hash_78DF2E5447F384B9"]()
			ButtonModes( SafeAreaContainer, IGRPerksDirectorButton["lobbyRoot.privateClient.update"], function ( f27_arg0, f27_arg1 )
				CoD.Menu.UpdateButtonShownState( f27_arg1, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
			end, false )
			ButtonFeatured:linkToElementModel( ButtonFeatured, "showForAllClients", true, function ( model, f28_arg1 )
				CoD.Menu.UpdateButtonShownState( f28_arg1, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
			end )
			ButtonFeatured:linkToElementModel( ButtonFeatured, "locked", true, function ( model, f29_arg1 )
				CoD.Menu.UpdateButtonShownState( f29_arg1, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
			end )
			ButtonFeatured:linkToElementModel( ButtonFeatured, "lockState", true, function ( model, f30_arg1 )
				CoD.Menu.UpdateButtonShownState( f30_arg1, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
			end )
			ButtonFeatured:linkToElementModel( ButtonFeatured, "mode", true, function ( model, f31_arg1 )
				CoD.Menu.UpdateButtonShownState( f31_arg1, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
			end )
			ButtonFeatured:registerEventHandler( "list_item_gain_focus", function ( element, event )
				local f32_local0 = nil
				CoD.DirectorUtility.UpdateDescriptionTextFromSelectMenu( f1_arg1, element )
				CoD.BlackMarketUtility.ShowTierSkipNotification( f1_arg1, element, f1_arg0 )
				return f32_local0
			end )
			ButtonFeatured:registerEventHandler( "list_item_lose_focus", function ( element, event )
				local f33_local0 = nil
				CoD.BlackMarketUtility.HideTierSkipNotification( f1_arg1, element, f1_arg0 )
				return f33_local0
			end )
			ButtonFeatured:registerEventHandler( "gain_focus", function ( element, event )
				local f34_local0 = nil
				if element.gainFocus then
					f34_local0 = element:gainFocus( event )
				elseif element.super.gainFocus then
					f34_local0 = element.super:gainFocus( event )
				end
				CoD.Menu.UpdateButtonShownState( element, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
				return f34_local0
			end )
			f1_arg0:AddButtonCallbackFunction( ButtonFeatured, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], "ui_confirm", function ( element, menu, controller, model )
				if CoD.ModelUtility.IsSelfModelValueTrue( element, controller, "trialLocked" ) then
					OpenOverlay( self, "Store", controller )
					PlaySoundAlias( "uin_toggle_generic" )
					return true
				elseif CoD.DirectorUtility.ShowForAllClients( element, controller ) and not CoD.ModelUtility.IsSelfModelValueTrue( element, controller, "locked" ) then
					ProcessListAction( self, element, controller, menu )
					PlaySoundAlias( "uin_toggle_featured_playlist" )
					return true
				elseif CoD.ModelUtility.IsSelfModelValueEqualToEnum( element, controller, "lockState", Enum[@"hash_4DACBB5C5F26BCD9"][@"hash_19B632F6362EA1BE"] ) then
					OpenSystemOverlay( self, menu, controller, "DownloadDLC", {
						_model = element:getModel()
					} )
					return true
				elseif CoD.ModelUtility.IsSelfModelValueEqualToEnum( element, controller, "lockState", Enum[@"hash_4DACBB5C5F26BCD9"][@"hash_4BDEB566326AC98"] ) and CoD.ModelUtility.IsSelfModelValueEqualToEnum( element, controller, "mode", Enum[@"hash_89C1455C5032969"][@"hash_379D01499920B292"] ) then
					CoD.StoreUtility.OpenStoreToDLCPack( self, element, controller, "DirectorSelect", menu )
					return true
				elseif CoD.ModelUtility.IsSelfModelValueEqualToEnum( element, controller, "lockState", Enum[@"hash_4DACBB5C5F26BCD9"][@"hash_4BDEB566326AC98"] ) then
					OpenSystemOverlay( self, menu, controller, "SeasonPassUpsell", {
						_model = element:getModel(),
						_description = @"hash_475EE3FCE54AF260"
					} )
					return true
				elseif CoD.DirectorUtility.ShowForAllClients( element, controller ) and CoD.ModelUtility.IsSelfModelValueTrue( element, controller, "locked" ) then
					ProcessListLockedAction( self, element, controller, menu )
					return true
				else
					
				end
			end, function ( element, menu, controller )
				if CoD.ModelUtility.IsSelfModelValueTrue( element, controller, "trialLocked" ) then
					CoD.Menu.SetButtonLabel( menu, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], @"hash_4191CDDA584B4408", nil, "ui_confirm" )
					return true
				elseif CoD.DirectorUtility.ShowForAllClients( element, controller ) and not CoD.ModelUtility.IsSelfModelValueTrue( element, controller, "locked" ) then
					CoD.Menu.SetButtonLabel( menu, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], @"hash_6D0BB36CD318F55F", nil, "ui_confirm" )
					return true
				elseif CoD.ModelUtility.IsSelfModelValueEqualToEnum( element, controller, "lockState", Enum[@"hash_4DACBB5C5F26BCD9"][@"hash_19B632F6362EA1BE"] ) then
					CoD.Menu.SetButtonLabel( menu, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], @"hash_6D0BB36CD318F55F", nil, "ui_confirm" )
					return true
				elseif CoD.ModelUtility.IsSelfModelValueEqualToEnum( element, controller, "lockState", Enum[@"hash_4DACBB5C5F26BCD9"][@"hash_4BDEB566326AC98"] ) and CoD.ModelUtility.IsSelfModelValueEqualToEnum( element, controller, "mode", Enum[@"hash_89C1455C5032969"][@"hash_379D01499920B292"] ) then
					CoD.Menu.SetButtonLabel( menu, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], @"hash_6D0BB36CD318F55F", nil, "ui_confirm" )
					return true
				elseif CoD.ModelUtility.IsSelfModelValueEqualToEnum( element, controller, "lockState", Enum[@"hash_4DACBB5C5F26BCD9"][@"hash_4BDEB566326AC98"] ) then
					CoD.Menu.SetButtonLabel( menu, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], @"hash_6D0BB36CD318F55F", nil, "ui_confirm" )
					return true
				elseif CoD.DirectorUtility.ShowForAllClients( element, controller ) and CoD.ModelUtility.IsSelfModelValueTrue( element, controller, "locked" ) then
					CoD.Menu.SetButtonLabel( menu, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], @"hash_6D0BB36CD318F55F", nil, "ui_confirm" )
					return true
				else
					return false
				end
			end, false )
			self:addElement( ButtonFeatured )
			self.ButtonFeatured = ButtonFeatured
			
			ButtonModes = LUI.UIList.new( f1_arg0, f1_arg1, 25, 0, nil, false, false, false, false )
			ButtonModes:setLeftRight( 0.5, 0.5, -475, 475 )
			ButtonModes:setTopBottom( 0, 0, 684, 754 )
			ButtonModes:setWidgetType( CoD.DirectorSelectButtonGameType )
			ButtonModes:setHorizontalCount( 3 )
			ButtonModes:setSpacing( 25 )
			ButtonModes:setAlignment( Enum[@"hash_67A5123B654282D2"][@"hash_558C8A85F2048829"] )
			ButtonModes:setDataSource( "DirectorPlayButtons" )
			ButtonModes:linkToElementModel( ButtonModes, "trialLocked", true, function ( model, f37_arg1 )
				CoD.Menu.UpdateButtonShownState( f37_arg1, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
			end )
			ButtonModes:linkToElementModel( ButtonModes, "locked", true, function ( model, f38_arg1 )
				CoD.Menu.UpdateButtonShownState( f38_arg1, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
			end )
			IGRPerksDirectorButton = ButtonModes
			SafeAreaContainer = ButtonModes.subscribeToModel
			local selectionDescription = Engine[@"hash_78DF2E5447F384B9"]()
			SafeAreaContainer( IGRPerksDirectorButton, selectionDescription["lobbyRoot.lobbyNav"], function ( f39_arg0, f39_arg1 )
				CoD.Menu.UpdateButtonShownState( f39_arg1, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
			end, false )
			IGRPerksDirectorButton = ButtonModes
			SafeAreaContainer = ButtonModes.subscribeToModel
			selectionDescription = Engine[@"hash_78DF2E5447F384B9"]()
			SafeAreaContainer( IGRPerksDirectorButton, selectionDescription["lobbyRoot.gameClient.update"], function ( f40_arg0, f40_arg1 )
				CoD.Menu.UpdateButtonShownState( f40_arg1, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
			end, false )
			IGRPerksDirectorButton = ButtonModes
			SafeAreaContainer = ButtonModes.subscribeToModel
			selectionDescription = Engine[@"hash_78DF2E5447F384B9"]()
			SafeAreaContainer( IGRPerksDirectorButton, selectionDescription["lobbyRoot.privateClient.update"], function ( f41_arg0, f41_arg1 )
				CoD.Menu.UpdateButtonShownState( f41_arg1, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
			end, false )
			ButtonModes:linkToElementModel( ButtonModes, "showForAllClients", true, function ( model, f42_arg1 )
				CoD.Menu.UpdateButtonShownState( f42_arg1, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
			end )
			ButtonModes:registerEventHandler( "list_item_gain_focus", function ( element, event )
				local f43_local0 = nil
				CoD.DirectorUtility.UpdateDescriptionTextFromSelectMenu( f1_arg1, element )
				CoD.BlackMarketUtility.ShowTierSkipNotification( f1_arg1, element, f1_arg0 )
				return f43_local0
			end )
			ButtonModes:registerEventHandler( "list_item_lose_focus", function ( element, event )
				local f44_local0 = nil
				CoD.BlackMarketUtility.HideTierSkipNotification( f1_arg1, element, f1_arg0 )
				return f44_local0
			end )
			ButtonModes:registerEventHandler( "gain_focus", function ( element, event )
				local f45_local0 = nil
				if element.gainFocus then
					f45_local0 = element:gainFocus( event )
				elseif element.super.gainFocus then
					f45_local0 = element.super:gainFocus( event )
				end
				CoD.Menu.UpdateButtonShownState( element, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
				return f45_local0
			end )
			f1_arg0:AddButtonCallbackFunction( ButtonModes, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], "ui_confirm", function ( element, menu, controller, model )
				if CoD.ModelUtility.IsSelfModelValueTrue( element, controller, "trialLocked" ) and AlwaysFalse() then
					OpenOverlay( self, "Store", controller )
					PlaySoundAlias( "uin_toggle_generic" )
					return true
				elseif not CoD.ModelUtility.IsSelfModelValueTrue( element, controller, "locked" ) and CoD.DirectorUtility.ShowForAllClients( element, controller ) and not CoD.ModelUtility.IsSelfModelValueTrue( element, controller, "trialLocked" ) then
					ProcessListAction( self, element, controller, menu )
					PlaySoundAlias( "uin_toggle_generic" )
					return true
				elseif IsPC() and CoD.ModelUtility.IsSelfModelValueTrue( element, controller, "locked" ) and CoD.DirectorUtility.ShowForAllClients( element, controller ) then
					ProcessListLockedAction( self, element, controller, menu )
					return true
				else
					
				end
			end, function ( element, menu, controller )
				if CoD.ModelUtility.IsSelfModelValueTrue( element, controller, "trialLocked" ) and AlwaysFalse() then
					CoD.Menu.SetButtonLabel( menu, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], @"hash_4191CDDA584B4408", nil, "ui_confirm" )
					return true
				elseif not CoD.ModelUtility.IsSelfModelValueTrue( element, controller, "locked" ) and CoD.DirectorUtility.ShowForAllClients( element, controller ) and not CoD.ModelUtility.IsSelfModelValueTrue( element, controller, "trialLocked" ) then
					CoD.Menu.SetButtonLabel( menu, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], @"hash_6D0BB36CD318F55F", nil, "ui_confirm" )
					return true
				elseif IsPC() and CoD.ModelUtility.IsSelfModelValueTrue( element, controller, "locked" ) and CoD.DirectorUtility.ShowForAllClients( element, controller ) then
					CoD.Menu.SetButtonLabel( menu, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], @"hash_6D0BB36CD318F55F", nil, "ui_confirm" )
					return true
				else
					return false
				end
			end, false )
			self:addElement( ButtonModes )
			self.ButtonModes = ButtonModes
			
			SafeAreaContainer = CoD.DirectorSelectSafeAreaContainer.new( f1_arg0, f1_arg1, 0.5, 0.5, -960, 960, 0, 0, 0, 1080 )
			SafeAreaContainer:registerEventHandler( "menu_loaded", function ( element, event )
				local f48_local0 = nil
				if element.menuLoaded then
					f48_local0 = element:menuLoaded( event )
				elseif element.super.menuLoaded then
					f48_local0 = element.super:menuLoaded( event )
				end
				if not IsPC() then
					SizeToSafeArea( element, f1_arg1 )
				end
				if not f48_local0 then
					f48_local0 = element:dispatchEventToChildren( event )
				end
				return f48_local0
			end )
			self:addElement( SafeAreaContainer )
			self.SafeAreaContainer = SafeAreaContainer
			
			IGRPerksDirectorButton = nil
			
			IGRPerksDirectorButton = CoD.IGRPerksDirectorButton.new( f1_arg0, f1_arg1, 0.5, 0.5, 265, 985, 0.5, 0.5, 239, 303 )
			IGRPerksDirectorButton:setScale( 0.9, 0.9 )
			self:addElement( IGRPerksDirectorButton )
			self.IGRPerksDirectorButton = IGRPerksDirectorButton
			
			selectionDescription = LUI.UIText.new( 0.5, 0.5, -473, 473, 0, 0, 793, 823 )
			selectionDescription:setTTF( "dinnext_regular" )
			selectionDescription:setAlignment( Enum[@"hash_67A5123B654282D2"][@"hash_558C8A85F2048829"] )
			selectionDescription:setAlignment( Enum[@"hash_67A5123B654282D2"][@"hash_3F41D595A2B0EDF3"] )
			selectionDescription:subscribeToGlobalModel( f1_arg1, "LobbyRoot", "selectScreenDescription", function ( model )
				local f49_local0 = model:get()
				if f49_local0 ~= nil then
					selectionDescription:setText( Engine[@"hash_4F9F1239CFD921FE"]( f49_local0 ) )
				end
			end )
			self:addElement( selectionDescription )
			self.selectionDescription = selectionDescription

			local PathNotesButton = CoD.DirectorSelectButtonMiniInternal.new( f1_arg0, f1_arg1, 0.5, 0.5, -140 + 770, 160 + 770, 0.88, 0.88, 15, 55 )
			
			PathNotesButton.MiddleText:setTTF( "ttmussels_regular" )
			PathNotesButton.MiddleText:setText("INFO & PATCH NOTES")

			PathNotesButton.MiddleTextFocus:setText("INFO & PATCH NOTES")
			PathNotesButton.MiddleTextFocus:setTTF( "ttmussels_regular" )

			PathNotesButton:linkToElementModel( self, nil, false, function ( model )
				PathNotesButton:setModel( model, f1_arg1 )
			end )
			self:addElement( PathNotesButton )
			self.PathNotesButton = PathNotesButton

			f1_arg0:AddButtonCallbackFunction( PathNotesButton, f1_arg0, Enum[@"luibutton"][@"lui_key_xba_pscross"], "ui_confirm", function ( element, menu, controller, model )
				PlaySoundAlias( "uin_paint_image_flip_toggle" )
				CoD.EnhPrintInfo("PathNotesButton")
				
				OpenOverlay( self, "ShieldPatchNotes", controller )

			end, function ( element, menu, controller )
				if IsGamepad( controller ) then
					CoD.Menu.SetButtonLabel( menu, Enum[@"luibutton"][@"lui_key_xba_pscross"], @"menu/join", nil, "ui_confirm" )
					return true
				elseif IsMouseOrKeyboard( controller ) then
					CoD.Menu.SetButtonLabel( menu, Enum[@"luibutton"][@"lui_key_xba_pscross"], @"hash_0", nil, "ui_confirm" )
					return false
				else
					return false
				end
			end, false )
			
			local sizePathNotesButton = CoD.DirectorSelectButtonImageInternal.new( f1_arg0, f1_arg1, 0.90, 0.90, -70, 200, 0.88, 0.88, 0, 30 )

			sizePathNotesButton:setAlpha( 0 )
			sizePathNotesButton.Tint:setRGB( 0.05, 0.08, 0.11 )
			sizePathNotesButton.Tint:setAlpha( 0.25 )
			sizePathNotesButton:linkToElementModel( self, nil, false, function ( model )
				sizePathNotesButton:setModel( model, f1_arg1 )
			end )
			sizePathNotesButton.ButtonName.GameModeText:setText("^3Patch Notes")
			self:addElement( sizePathNotesButton )
			self.sizePathNotesButton = sizePathNotesButton

			PathNotesButton.id = "PathNotesButton"
			sizePathNotesButton.id = "sizePathNotesButton"

			local MusicManager = CoD.DirectorSelectButtonMiniInternal.new( f1_arg0, f1_arg1, 0.5, 0.5, -140 + 770, 160 + 770, 0.88, 0.88, 15 - 55 - 110, 55 - 55 - 110 )
			
			MusicManager.MiddleText:setTTF( "ttmussels_regular" )
			MusicManager.MiddleText:setText("MUSIC MANAGER")

			MusicManager.MiddleTextFocus:setText("MUSIC MANAGER")
			MusicManager.MiddleTextFocus:setTTF( "ttmussels_regular" )

			MusicManager:linkToElementModel( self, nil, false, function ( model )
				MusicManager:setModel( model, f1_arg1 )
			end )
			self:addElement( MusicManager )
			self.MusicManager = MusicManager

			f1_arg0:AddButtonCallbackFunction( MusicManager, f1_arg0, Enum[@"luibutton"][@"lui_key_xba_pscross"], "ui_confirm", function ( element, menu, controller, model )
				PlaySoundAlias( "uin_paint_image_flip_toggle" )
				CoD.EnhPrintInfo("MusicManager")
				
				OpenOverlay( self, "ShieldMusicManager", controller )

			end, function ( element, menu, controller )
				if IsGamepad( controller ) then
					CoD.Menu.SetButtonLabel( menu, Enum[@"luibutton"][@"lui_key_xba_pscross"], @"menu/join", nil, "ui_confirm" )
					return true
				elseif IsMouseOrKeyboard( controller ) then
					CoD.Menu.SetButtonLabel( menu, Enum[@"luibutton"][@"lui_key_xba_pscross"], @"hash_0", nil, "ui_confirm" )
					return false
				else
					return false
				end
			end, false )

			MusicManager.id = "MusicManager"

			local FeaturedModsButton = CoD.DirectorSelectButtonMiniInternal.new( f1_arg0, f1_arg1, 0.5, 0.5, -140 + 770, 160 + 770, 0.88, 0.88, 15 - 55, 55 - 55 )
			
			FeaturedModsButton.MiddleText:setTTF( "ttmussels_regular" )
			FeaturedModsButton.MiddleText:setText("MOD MANAGER")

			FeaturedModsButton.MiddleTextFocus:setText("MOD MANAGER")
			FeaturedModsButton.MiddleTextFocus:setTTF( "ttmussels_regular" )

			FeaturedModsButton:linkToElementModel( self, nil, false, function ( model )
				FeaturedModsButton:setModel( model, f1_arg1 )
			end )
			self:addElement( FeaturedModsButton )
			self.FeaturedModsButton = FeaturedModsButton

			f1_arg0:AddButtonCallbackFunction( FeaturedModsButton, f1_arg0, Enum[@"luibutton"][@"lui_key_xba_pscross"], "ui_confirm", function ( element, menu, controller, model )
				PlaySoundAlias( "uin_paint_image_flip_toggle" )
				CoD.EnhPrintInfo("FeaturedModsButton")
				
				OpenOverlay( self, "ShieldModManager", controller )

			end, function ( element, menu, controller )
				if IsGamepad( controller ) then
					CoD.Menu.SetButtonLabel( menu, Enum[@"luibutton"][@"lui_key_xba_pscross"], @"menu/join", nil, "ui_confirm" )
					return true
				elseif IsMouseOrKeyboard( controller ) then
					CoD.Menu.SetButtonLabel( menu, Enum[@"luibutton"][@"lui_key_xba_pscross"], @"hash_0", nil, "ui_confirm" )
					return false
				else
					return false
				end
			end, false )

			FeaturedModsButton.id = "FeaturedModsButton"

			local ShieldFriendsButton = CoD.DirectorSelectButtonMiniInternal.new( f1_arg0, f1_arg1, 0.5, 0.5, -140 + 770, 160 + 770, 0.88, 0.88, 15 - 110, 55 - 110 )

			ShieldFriendsButton:mergeStateConditions( {
				{
					stateName = "Locked",
					condition = function ( menu, element, event )
						return Engine[@"getdvarint"](@"shield_is_offline") == 1
					end
				},
				{
					stateName = "Disabled",
					condition = function ( menu, element, event )
						return AlwaysFalse()
					end
				}
			} )
			
			ShieldFriendsButton.MiddleText:setTTF( "ttmussels_regular" )
			ShieldFriendsButton.MiddleText:setText("SHIELD FRIENDS")

			ShieldFriendsButton.MiddleTextFocus:setText("SHIELD FRIENDS")
			ShieldFriendsButton.MiddleTextFocus:setTTF( "ttmussels_regular" )

			ShieldFriendsButton:linkToElementModel( self, nil, false, function ( model )
				ShieldFriendsButton:setModel( model, f1_arg1 )
			end )
			self:addElement( ShieldFriendsButton )
			self.ShieldFriendsButton = ShieldFriendsButton

			f1_arg0:AddButtonCallbackFunction( ShieldFriendsButton, f1_arg0, Enum[@"luibutton"][@"lui_key_xba_pscross"], "ui_confirm", function ( element, menu, controller, model )
				CoD.EnhPrintInfo("ShieldFriendsButton")

				if Engine[@"getdvarint"](@"shield_is_offline") == 0 then
					PlaySoundAlias( "uin_paint_image_flip_toggle" )
					OpenOverlay( self, "ShieldFriendsMenu", controller )
				end

			end, function ( element, menu, controller )
				if IsGamepad( controller ) then
					CoD.Menu.SetButtonLabel( menu, Enum[@"luibutton"][@"lui_key_xba_pscross"], @"menu/join", nil, "ui_confirm" )
					return true
				elseif IsMouseOrKeyboard( controller ) then
					CoD.Menu.SetButtonLabel( menu, Enum[@"luibutton"][@"lui_key_xba_pscross"], @"hash_0", nil, "ui_confirm" )
					return false
				else
					return false
				end
			end, false )

			ShieldFriendsButton.id = "ShieldFriendsButton"

			local Shield_Nat = LUI.UIText.new( 0.5, 0.5, -70 - 870, 1500 - 870, 0.9, 0.9, 10, 30 )
			Shield_Nat:setText("Unknown Info")
			Shield_Nat:setTTF( "ttmussels_regular" )
			Shield_Nat:setBackingType( 2 )
			Shield_Nat:setBackingColor( 0.04, 0.81, 1 )
			Shield_Nat:setBackingAlpha( 0.01 )
			Shield_Nat:setBackingXPadding( 12 )
			Shield_Nat:setBackingYPadding( 6 )
			Shield_Nat:setLetterSpacing( 6 )
			Shield_Nat:setAlignment( Enum[@"hash_67A5123B654282D2"][@"hash_558C8A85F2048829"] )
			Shield_Nat:setAlignment( Enum[@"hash_67A5123B654282D2"][@"hash_3F41D595A2B0EDF3"] )
			Shield_Nat:subscribeToGlobalModel( f1_arg1, "LobbyRoot", "lobbyNatType", function ( model )
				local nattype = model:get()
				if nattype ~= nil and Engine[@"getdvarint"](@"shield_is_offline") == 0 then
					Shield_Nat:setText(ConvertToUpperString(LocalizeWithNatType(nattype)) .. " | SERVER IP: " .. Engine[@"getdvarstring"]("shield_dw_ip"))
				else
					Shield_Nat:setText("OFFLINE MODE")
				end
			end )
			self:addElement( Shield_Nat )
			self.Shield_Nat = Shield_Nat
			
			local PurchaseButton2 = nil
			
			PurchaseButton2 = CoD.PC_BnetStore_PurchaseButton.new( f1_arg0, f1_arg1, 0.5, 0.5, -272.5, 273.5, 0, 0, 829, 890 )
			PurchaseButton2:mergeStateConditions( {
				{
					stateName = "Hidden",
					condition = function ( menu, element, event )
						return HideKoreaEventButton( f1_arg1 )
					end
				},
				{
					stateName = "Disabled",
					condition = function ( menu, element, event )
						return AlwaysFalse()
					end
				}
			} )
			PurchaseButton2:setAlpha( 0 )
			PurchaseButton2.ButtonTitle:setText( LocalizeToUpperString( @"hash_648B6358827FB817" ) )
			PurchaseButton2:registerEventHandler( "gain_focus", function ( element, event )
				local f52_local0 = nil
				if element.gainFocus then
					f52_local0 = element:gainFocus( event )
				elseif element.super.gainFocus then
					f52_local0 = element.super:gainFocus( event )
				end
				CoD.Menu.UpdateButtonShownState( element, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
				return f52_local0
			end )
			f1_arg0:AddButtonCallbackFunction( PurchaseButton2, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], nil, function ( element, menu, controller, model )
				OpenOverlay( self, "PC_Korea_Event_Menu", controller )
				return true
			end, function ( element, menu, controller )
				CoD.Menu.SetButtonLabel( menu, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], @"hash_0", nil, nil )
				return false
			end, false )
			self:addElement( PurchaseButton2 )
			self.PurchaseButton2 = PurchaseButton2
			
			local f1_local19 = nil
			self.DirectorTierSkipNotification = LUI.UIElement.createFake()
			local DirectorTierSkipNotification2 = nil
			
			DirectorTierSkipNotification2 = CoD.DirectorTierSkipNotification.new( f1_arg0, f1_arg1, 0.5, 0.5, -400, 400, 0, 0, 143, 233 )
			self:addElement( DirectorTierSkipNotification2 )
			self.DirectorTierSkipNotification2 = DirectorTierSkipNotification2
			
			local IGREventButton = nil
			
			IGREventButton = CoD.PC_Korea_Event_DirectorButton.new( f1_arg0, f1_arg1, 0.5, 0.5, -225, 225, 0.5, 0.5, 293, 423 )
			IGREventButton:mergeStateConditions( {
				{
					stateName = "Hidden",
					condition = function ( menu, element, event )
						return HideKoreaEventButton( f1_arg1 )
					end
				}
			} )
			IGREventButton.SpecialEvent:setText( LocalizeToUpperString( @"hash_648B6358827FB817" ) )
			IGREventButton.EventName:setText( LocalizeToUpperString( @"hash_47CD2396EF33FB1" ) )
			IGREventButton:registerEventHandler( "gain_focus", function ( element, event )
				local f56_local0 = nil
				if element.gainFocus then
					f56_local0 = element:gainFocus( event )
				elseif element.super.gainFocus then
					f56_local0 = element.super:gainFocus( event )
				end
				CoD.Menu.UpdateButtonShownState( element, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
				return f56_local0
			end )
			f1_arg0:AddButtonCallbackFunction( IGREventButton, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], nil, function ( element, menu, controller, model )
				if IsKoreaProgressionSpecialEventActive( controller ) then
					PlaySoundAlias( "uin_toggle_generic" )
					OpenOverlay( self, "PC_Korea_Event_Menu", controller )
					return true
				elseif IsKoreaBonusXPSpecialEventActive( controller ) then
					PlaySoundAlias( "uin_toggle_generic" )
					CoD.FTUEUtility.ShowFTUESequence( self, controller, "KoreaSpecialEvent" )
					return true
				else
					
				end
			end, function ( element, menu, controller )
				if IsKoreaProgressionSpecialEventActive( controller ) then
					CoD.Menu.SetButtonLabel( menu, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], @"hash_0", nil, nil )
					return false
				elseif IsKoreaBonusXPSpecialEventActive( controller ) then
					CoD.Menu.SetButtonLabel( menu, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], @"hash_0", nil, nil )
					return false
				else
					return false
				end
			end, false )
			self:addElement( IGREventButton )
			self.IGREventButton = IGREventButton
			
			local pckeyboardNavigationRedirector = nil
			
			pckeyboardNavigationRedirector = CoD.emptyFocusable.new( f1_arg0, f1_arg1, 0.7, 1, 0, 0, 0.74, 0.79, -35, -35 )
			self:addElement( pckeyboardNavigationRedirector )
			self.pckeyboardNavigationRedirector = pckeyboardNavigationRedirector
			
			self:mergeStateConditions( {
				{
					stateName = "OnlineOnlyDemo",
					condition = function ( menu, element, event )
						return IsLobbyNetworkModeLive() and CoD.DirectorUtility.IsOnlineOnlyDemo()
					end
				},
				{
					stateName = "OnlineWithArena",
					condition = function ( menu, element, event )
						return IsLobbyNetworkModeLive() and CoD.DirectorUtility.HasArena()
					end
				},
				{
					stateName = "Online",
					condition = function ( menu, element, event )
						return IsLobbyNetworkModeLive()
					end
				},
				{
					stateName = "OfflineRevealEvent",
					condition = function ( menu, element, event )
						return IsLobbyNetworkModeLAN() and CoD.DirectorUtility.IsOfflineOnlyDemo()
					end
				},
				{
					stateName = "OfflineWithArena",
					condition = function ( menu, element, event )
						return IsLobbyNetworkModeLAN() and CoD.DirectorUtility.HasArena()
					end
				},
				{
					stateName = "Offline",
					condition = function ( menu, element, event )
						return IsLobbyNetworkModeLAN()
					end
				}
			} )
			local f1_local23 = self
			local f1_local24 = self.subscribeToModel
			local f1_local25 = Engine[@"hash_78DF2E5447F384B9"]()
			f1_local24( f1_local23, f1_local25["lobbyRoot.lobbyNav"], function ( f65_arg0 )
				f1_arg0:updateElementState( self, {
					name = "model_validation",
					menu = f1_arg0,
					controller = f1_arg1,
					modelValue = f65_arg0:get(),
					modelName = "lobbyRoot.lobbyNav"
				} )
			end, false )
			LUI.OverrideFunction_CallOriginalFirst( self, "setState", function ( element, controller, f66_arg2, f66_arg3, f66_arg4 )
				if IsPC() then
					ForceCheckDefaultPCFocus( element, f1_arg0, controller )
				end
			end )
			LUI.OverrideFunction_CallOriginalFirst( self, "childFocusLost", function ( element )
				CoD.DirectorUtility.UpdateDescriptionTextFromSelectMenu( f1_arg1, element )
			end )
			if CoD.isPC then
				pckeyboardNavigationRedirector2.id = "pckeyboardNavigationRedirector2"
			end
			ButtonListLeft.id = "ButtonListLeft"
			ButtonListRight.id = "ButtonListRight"
			ButtonFeatured.id = "ButtonFeatured"
			ButtonModes.id = "ButtonModes"
			SafeAreaContainer.id = "SafeAreaContainer"
			if CoD.isPC then
				IGRPerksDirectorButton.id = "IGRPerksDirectorButton"
			end
			if CoD.isPC then
				PurchaseButton2.id = "PurchaseButton2"
			end
			if CoD.isPC then
				IGREventButton.id = "IGREventButton"
			end
			if CoD.isPC then
				pckeyboardNavigationRedirector.id = "pckeyboardNavigationRedirector"
			end
			self.__defaultFocus = ButtonFeatured
			LUI.OverrideFunction_CallOriginalSecond( self, "close", self.__onClose )
			if PostLoadFunc then
				PostLoadFunc( self, f1_arg1, f1_arg0 )
			end
			f1_local24 = self
			CoD.BaseUtility.SetUpPassCustomFunctionToChild( self, self.SafeAreaContainer, f1_arg1, f1_arg0, "_activateFeaturedWidget" )
			CoD.CraftUtility.ValidateEquippedUGC( f1_arg1 )
			CoD.WZUtility.PlayWZTrialVideo( f1_arg0, f1_arg1 )
			f1_local24 = pckeyboardNavigationRedirector2
			if IsPC() then
				CoD.PCUtility.SetAsRedirectItem( f1_local24 )
				CoD.BaseUtility.SetCustomNavDirection( CoD.BaseUtility.NavigationDirection.down, f1_local24, self.Loadouts )
			end
			f1_local24 = pckeyboardNavigationRedirector
			if IsPC() then
				CoD.PCUtility.SetAsRedirectItem( f1_local24 )
				CoD.BaseUtility.SetCustomNavDirection( CoD.BaseUtility.NavigationDirection.up, f1_local24, self.Loadouts )
			end

			return self
		end

		CoD.directorSelect.__resetProperties = function ( f68_arg0 )
			f68_arg0.Header:completeAnimation()
			f68_arg0.HeaderPC:completeAnimation()
			f68_arg0.ButtonFeatured:completeAnimation()
			f68_arg0.ButtonModes:completeAnimation()
			f68_arg0.FramingCornerBrackets:completeAnimation()
			f68_arg0.ButtonListRight:completeAnimation()
			f68_arg0.ButtonListLeft:completeAnimation()
			f68_arg0.DotLineTop:completeAnimation()
			f68_arg0.DotLineBottom:completeAnimation()
			f68_arg0.Header:setLeftRight( 0, 0, 407, 1050 )
			f68_arg0.Header:setTopBottom( 0, 0, 146, 246 )
			f68_arg0.Header:setAlpha( 0 )
			f68_arg0.HeaderPC:setLeftRight( 0.5, 0.5, -553, 81 )
			f68_arg0.HeaderPC:setAlpha( 0 )
			f68_arg0.ButtonFeatured:setLeftRight( 0.5, 0.5, -475, 475 )
			f68_arg0.ButtonFeatured:setAlpha( 1 )
			f68_arg0.ButtonFeatured:setAutoScaleContent( false )
			f68_arg0.ButtonFeatured:setWidgetType( CoD.DirectorSelectButton )
			f68_arg0.ButtonFeatured:setHorizontalCount( 3 )
			f68_arg0.ButtonFeatured:setVerticalCount( 1 )
			f68_arg0.ButtonFeatured:setSpacing( 25 )
			f68_arg0.ButtonFeatured:setFirstElementXOffset( 0 )
			f68_arg0.ButtonFeatured:setFirstElementYOffset( 0 )
			f68_arg0.ButtonFeatured:setBalanceGridRows( false )
			f68_arg0.ButtonModes:setLeftRight( 0.5, 0.5, -475, 475 )
			f68_arg0.ButtonModes:setAutoScaleContent( false )
			f68_arg0.ButtonModes:setWidgetType( CoD.DirectorSelectButtonGameType )
			f68_arg0.ButtonModes:setHorizontalCount( 3 )
			f68_arg0.ButtonModes:setVerticalCount( 1 )
			f68_arg0.ButtonModes:setSpacing( 25 )
			f68_arg0.ButtonModes:setFirstElementXOffset( 0 )
			f68_arg0.ButtonModes:setFirstElementYOffset( 0 )
			f68_arg0.ButtonModes:setBalanceGridRows( false )
			f68_arg0.FramingCornerBrackets:setLeftRight( 0.5, 0.5, -516.5, 516.5 )
			f68_arg0.FramingCornerBrackets:setTopBottom( 0, 0, 222, 796 )
			f68_arg0.ButtonListRight:setLeftRight( 0.5, 0.5, 500, 712 )
			f68_arg0.ButtonListRight:setTopBottom( 0, 0, 265, 510 )
			f68_arg0.ButtonListLeft:setLeftRight( 0.5, 0.5, -725, -513 )
			f68_arg0.DotLineTop:setLeftRight( 0.5, 0.5, -474.5, 474.5 )
			f68_arg0.DotLineBottom:setLeftRight( 0.5, 0.5, -474.5, 474.5 )
		end

		CoD.directorSelect.__clipsPerState = {
			DefaultState = {
				DefaultClip = function ( f69_arg0, f69_arg1 )
					f69_arg0:__resetProperties()
					f69_arg0:setupElementClipCounter( 0 )
				end
			},
			OnlineOnlyDemo = {
				DefaultClip = function ( f70_arg0, f70_arg1 )
					f70_arg0:__resetProperties()
					f70_arg0:setupElementClipCounter( 1 )
					f70_arg0.Header:completeAnimation()
					f70_arg0.Header:setAlpha( 0 )
					f70_arg0.clipFinished( f70_arg0.Header )
					f70_arg0.HeaderPC:completeAnimation()
					f70_arg0.HeaderPC:setAlpha( 0 )
					f70_arg0.clipFinished( f70_arg0.HeaderPC )
				end
			},
			OnlineWithArena = {
				DefaultClip = function ( f71_arg0, f71_arg1 )
					f71_arg0:__resetProperties()
					f71_arg0:setupElementClipCounter( 8 )
					f71_arg0.FramingCornerBrackets:completeAnimation()
					f71_arg0.FramingCornerBrackets:setLeftRight( 0.5, 0.5, -691.5, 689.5 )
					f71_arg0.FramingCornerBrackets:setTopBottom( 0, 0, 224, 796 )
					f71_arg0.clipFinished( f71_arg0.FramingCornerBrackets )
					f71_arg0.DotLineBottom:completeAnimation()
					f71_arg0.DotLineBottom:setLeftRight( 0.5, 0.5, -638, 638 )
					f71_arg0.clipFinished( f71_arg0.DotLineBottom )
					f71_arg0.DotLineTop:completeAnimation()
					f71_arg0.DotLineTop:setLeftRight( 0.5, 0.5, -638, 638 )
					f71_arg0.clipFinished( f71_arg0.DotLineTop )
					f71_arg0.Header:completeAnimation()
					f71_arg0.Header:setLeftRight( 0, 0, 186, 829 )
					f71_arg0.clipFinished( f71_arg0.Header )
					f71_arg0.HeaderPC:completeAnimation()
					f71_arg0.HeaderPC:setLeftRight( 0.5, 0.5, -765, -131 )
					f71_arg0.clipFinished( f71_arg0.HeaderPC )
					f71_arg0.ButtonListLeft:completeAnimation()
					f71_arg0.ButtonListLeft:setLeftRight( 0.5, 0.5, -887, -675 )
					f71_arg0.clipFinished( f71_arg0.ButtonListLeft )
					f71_arg0.ButtonListRight:completeAnimation()
					f71_arg0.ButtonListRight:setLeftRight( 0.5, 0.5, 674, 886 )
					f71_arg0.ButtonListRight:setTopBottom( 0, 0, 265, 510 )
					f71_arg0.clipFinished( f71_arg0.ButtonListRight )
					f71_arg0.ButtonFeatured:completeAnimation()
					f71_arg0.ButtonFeatured:setLeftRight( 0.5, 0.5, -637.5, 637.5 )
					f71_arg0.ButtonFeatured:setAutoScaleContent( false )
					f71_arg0.ButtonFeatured:setWidgetType( CoD.DirectorSelectButton )
					f71_arg0.ButtonFeatured:setHorizontalCount( 4 )
					f71_arg0.ButtonFeatured:setVerticalCount( 1 )
					f71_arg0.ButtonFeatured:setSpacing( 25 )
					f71_arg0.ButtonFeatured:setFirstElementXOffset( 0 )
					f71_arg0.ButtonFeatured:setFirstElementYOffset( 0 )
					f71_arg0.ButtonFeatured:setBalanceGridRows( false )
					f71_arg0.clipFinished( f71_arg0.ButtonFeatured )
					f71_arg0.ButtonModes:completeAnimation()
					f71_arg0.ButtonModes:setLeftRight( 0.5, 0.5, -637.5, 637.5 )
					f71_arg0.ButtonModes:setAutoScaleContent( false )
					f71_arg0.ButtonModes:setWidgetType( CoD.DirectorSelectButtonGameType )
					f71_arg0.ButtonModes:setHorizontalCount( 4 )
					f71_arg0.ButtonModes:setVerticalCount( 1 )
					f71_arg0.ButtonModes:setSpacing( 25 )
					f71_arg0.ButtonModes:setFirstElementXOffset( 0 )
					f71_arg0.ButtonModes:setFirstElementYOffset( 0 )
					f71_arg0.ButtonModes:setBalanceGridRows( false )
					f71_arg0.clipFinished( f71_arg0.ButtonModes )
				end
			},
			Online = {
				DefaultClip = function ( f72_arg0, f72_arg1 )
					f72_arg0:__resetProperties()
					f72_arg0:setupElementClipCounter( 2 )
					f72_arg0.Header:completeAnimation()
					f72_arg0.Header:setAlpha( 0 )
					f72_arg0.clipFinished( f72_arg0.Header )
					f72_arg0.HeaderPC:completeAnimation()
					f72_arg0.HeaderPC:setAlpha( 0 )
					f72_arg0.clipFinished( f72_arg0.HeaderPC )
					f72_arg0.ButtonFeatured:completeAnimation()
					f72_arg0.ButtonFeatured:setAlpha( 1 )
					f72_arg0.clipFinished( f72_arg0.ButtonFeatured )
				end
			},
			OfflineRevealEvent = {
				DefaultClip = function ( f73_arg0, f73_arg1 )
					f73_arg0:__resetProperties()
					f73_arg0:setupElementClipCounter( 1 )
					f73_arg0.Header:completeAnimation()
					f73_arg0.Header:setLeftRight( 0, 0, 360, 1003 )
					f73_arg0.Header:setTopBottom( 0, 0, 183, 283 )
					f73_arg0.Header:setAlpha( 0 )
					f73_arg0.clipFinished( f73_arg0.Header )
					f73_arg0.HeaderPC:completeAnimation()
					f73_arg0.HeaderPC:setAlpha( 1 )
					f73_arg0.clipFinished( f73_arg0.HeaderPC )
				end
			},
			OfflineWithArena = {
				DefaultClip = function ( f74_arg0, f74_arg1 )
					f74_arg0:__resetProperties()
					f74_arg0:setupElementClipCounter( 8 )
					f74_arg0.FramingCornerBrackets:completeAnimation()
					f74_arg0.FramingCornerBrackets:setLeftRight( 0.5, 0.5, -691.5, 689.5 )
					f74_arg0.FramingCornerBrackets:setTopBottom( 0, 0, 224, 796 )
					f74_arg0.clipFinished( f74_arg0.FramingCornerBrackets )
					f74_arg0.DotLineBottom:completeAnimation()
					f74_arg0.DotLineBottom:setLeftRight( 0.5, 0.5, -637.5, 610.5 )
					f74_arg0.clipFinished( f74_arg0.DotLineBottom )
					f74_arg0.DotLineTop:completeAnimation()
					f74_arg0.DotLineTop:setLeftRight( 0.5, 0.5, -637, 637 )
					f74_arg0.clipFinished( f74_arg0.DotLineTop )
					f74_arg0.Header:completeAnimation()
					f74_arg0.Header:setLeftRight( 0, 0, 186, 829 )
					f74_arg0.clipFinished( f74_arg0.Header )
					f74_arg0.HeaderPC:completeAnimation()
					f74_arg0.HeaderPC:setLeftRight( 0.5, 0.5, -765, -131 )
					f74_arg0.clipFinished( f74_arg0.HeaderPC )
					f74_arg0.ButtonListLeft:completeAnimation()
					f74_arg0.ButtonListLeft:setLeftRight( 0.5, 0.5, -887, -675 )
					f74_arg0.clipFinished( f74_arg0.ButtonListLeft )
					f74_arg0.ButtonListRight:completeAnimation()
					f74_arg0.ButtonListRight:setLeftRight( 0.5, 0.5, 674, 886 )
					f74_arg0.ButtonListRight:setTopBottom( 0, 0, 265, 510 )
					f74_arg0.clipFinished( f74_arg0.ButtonListRight )
					f74_arg0.ButtonFeatured:completeAnimation()
					f74_arg0.ButtonFeatured:setLeftRight( 0.5, 0.5, -637.5, 637.5 )
					f74_arg0.ButtonFeatured:setAutoScaleContent( false )
					f74_arg0.ButtonFeatured:setWidgetType( CoD.DirectorSelectButton )
					f74_arg0.ButtonFeatured:setHorizontalCount( 4 )
					f74_arg0.ButtonFeatured:setVerticalCount( 1 )
					f74_arg0.ButtonFeatured:setSpacing( 25 )
					f74_arg0.ButtonFeatured:setFirstElementXOffset( 0 )
					f74_arg0.ButtonFeatured:setFirstElementYOffset( 0 )
					f74_arg0.ButtonFeatured:setBalanceGridRows( false )
					f74_arg0.clipFinished( f74_arg0.ButtonFeatured )
					f74_arg0.ButtonModes:completeAnimation()
					f74_arg0.ButtonModes:setLeftRight( 0.5, 0.5, -637.5, 637.5 )
					f74_arg0.ButtonModes:setAutoScaleContent( false )
					f74_arg0.ButtonModes:setWidgetType( CoD.DirectorSelectButtonGameType )
					f74_arg0.ButtonModes:setHorizontalCount( 4 )
					f74_arg0.ButtonModes:setVerticalCount( 1 )
					f74_arg0.ButtonModes:setSpacing( 25 )
					f74_arg0.ButtonModes:setFirstElementXOffset( 0 )
					f74_arg0.ButtonModes:setFirstElementYOffset( 0 )
					f74_arg0.ButtonModes:setBalanceGridRows( false )
					f74_arg0.clipFinished( f74_arg0.ButtonModes )
				end
			},
			Offline = {
				DefaultClip = function ( f75_arg0, f75_arg1 )
					f75_arg0:__resetProperties()
					f75_arg0:setupElementClipCounter( 1 )
					f75_arg0.Header:completeAnimation()
					f75_arg0.Header:setLeftRight( 0, 0, 360, 1003 )
					f75_arg0.Header:setTopBottom( 0, 0, 183, 283 )
					f75_arg0.Header:setAlpha( 0 )
					f75_arg0.clipFinished( f75_arg0.Header )
					f75_arg0.HeaderPC:completeAnimation()
					f75_arg0.HeaderPC:setAlpha( 1 )
					f75_arg0.clipFinished( f75_arg0.HeaderPC )
				end
			}
		}

		CoD.directorSelect.__onClose = function ( f76_arg0 )
			f76_arg0.FramingCornerBrackets:close()
			f76_arg0.Header:close()
			f76_arg0.HeaderPC:close()
			f76_arg0.DirectorLeaderActivitySelect:close()
			f76_arg0.pckeyboardNavigationRedirector2:close()
			f76_arg0.ButtonListLeft:close()
			f76_arg0.ButtonListRight:close()
			f76_arg0.ButtonFeatured:close()
			f76_arg0.ButtonModes:close()
			f76_arg0.SafeAreaContainer:close()
			f76_arg0.IGRPerksDirectorButton:close()
			f76_arg0.selectionDescription:close()
			f76_arg0.PurchaseButton2:close()
			f76_arg0.PathNotesButton:close()
			f76_arg0.sizePathNotesButton:close()
			f76_arg0.Shield_Nat:close()
			f76_arg0.DirectorTierSkipNotification:close()
			f76_arg0.DirectorTierSkipNotification2:close()
			f76_arg0.IGREventButton:close()
			f76_arg0.pckeyboardNavigationRedirector:close()
		end
	else
		CoD.DirectorUtility.MainScreenModes = {
			{
				arena = false,
				mainMode = Enum[@"lobbymainmode"][@"lobby_mainmode_wz"],
				stringIfLocked = @"menu/warzone",
				lockedOffline = false,
				isVisible = CoD.DirectorUtility.IsWZFeatureCardVisible,
				trialDisable = false
			},
			{
				arena = false,
				mainMode = Enum[@"lobbymainmode"][@"lobby_mainmode_mp"],
				stringIfLocked = @"menu/multiplayer",
				lockedOffline = false,
				isVisible = AlwaysTrue,
				trialDisable = true
			},
			{
				arena = false,
				mainMode = Enum[@"lobbymainmode"][@"lobby_mainmode_zm"],
				stringIfLocked = @"menu/zombies",
				lockedOffline = false,
				isVisible = CoD.DirectorUtility.HasZombie,
				trialDisable = true
			},
			{
				arena = true,
				mainMode = Enum[@"lobbymainmode"][@"lobby_mainmode_mp"],
				stringIfLocked = @"menu/arena",
				lockedOffline = false,
				isVisible = CoD.DirectorUtility.HasArena,
				trialDisable = true
			}
		}

		DataSources.DirectorExtraHomeButtonsCustom = ListHelper_SetupDataSource( "DirectorExtraHomeButtonsCustom", function ( f85_arg0, f85_arg1 )
			local f85_local0 = {}
			local f85_local1 = IsLobbyNetworkModeLAN()
			local f85_local2
			if Engine[@"hash_77D47312EBA41751"]() or LobbyData.GetLobbyMenuByName( LuaEnum.UI.DIRECTOR_ONLINE_MP_TRAINING ) == nil then
				f85_local2 = false
			else
				f85_local2 = true
			end
			local f85_local3 = false
			local f85_local4 = false
			local f85_local5 = Engine[@"getglobalmodel"]()
			f85_local5 = f85_local5:create( CoD.LobbyUtility.LobbyNavigationActionModel )
			f85_local5 = f85_local5:get()
			if f85_local5 == LuaEnum.UI.DIRECTOR_LAN_SELECT then
				f85_local3 = true
			elseif f85_local5 == LuaEnum.UI.DIRECTOR_ONLINE then
				f85_local4 = true
			end
			if f85_local1 then
				if not LuaUtils.OfflineOnlyDemo() then
					table.insert( f85_local0, {
						models = {
							subtitle = @"hash_2D63F1918C92A85D",
							iconBackground = @"blacktransparent",
							iconBackgroundFocus = @"blacktransparent",
							showOnLeft = true,
							small = true,
							locked = false
						},
						properties = {
							action = CoD.DirectorUtility.DirectorSelectAction,
							actionParam = LuaEnum.UI.DIRECTOR_ONLINE,
							selectIndex = f85_local3
						}
					} )
				end
				table.insert( f85_local0, {
					models = {
						subtitle = @"hash_5D7DF8AD7167B198",
						iconBackground = @"blacktransparent",
						iconBackgroundFocus = @"blacktransparent",
						showOnLeft = true,
						small = true,
						locked = false
					},
					properties = {
						action = CoD.DirectorUtility.DirectorSelectOpenPopup,
						actionParam = "LobbyServerBrowserOverlay"
					}
				} )
			else
				if f85_local2 then
					table.insert( f85_local0, {
						models = {
							showOnLeft = true,
							small = true,
							locked = false,
							trialLocked = Engine[@"hash_5CB675CA7856DA25"](),
							iconBackground = @"blacktransparent",
							iconBackgroundFocus = @"blacktransparent",
							subtitle = @"hash_5AA1920F2AF31A03",
							showForAllClients = false
						},
						properties = {
							action = CoD.DirectorUtility.DirectorNavigateToSpecialistHeadquarters
						}
					} )
				end
				table.insert( f85_local0, {
					models = {
						subtitle = @"menu/theater",
						iconBackground = @"blacktransparent",
						iconBackgroundFocus = @"blacktransparent",
						showOnLeft = true,
						small = true,
						locked = CoD.DirectorUtility.DisableForCurrentMilestone( f85_arg0 ) and not CoD.BaseUtility.IsDvarEnabled( "ui_showTheater" ),
						trialLocked = Engine[@"hash_5CB675CA7856DA25"]()
					},
					properties = {
						action = CoD.DirectorUtility.DirectorSelectTheater,
						actionParam = LuaEnum.UI.DIRECTOR_ONLINE_THEATER
					}
				} ) 
				local f85_local6 = @"ui_icon_blackmarket_store_tile_default_01"
				local f85_local7 = @"ui_icon_blackmarket_store_tile_focus_01"
				if IsBooleanDvarSet( @"loot_enableblackmarket" ) then
					local f85_local8 = Engine[@"hash_2E00B2F29271C60B"]( CoDShared.Loot.GetCurrentSeason() )
					local f85_local9
					if f85_local8 then
						f85_local9 = f85_local8[@"squareimage"]
						if not f85_local9 then
						
						else
							local f85_local10
							if f85_local8 then
								f85_local10 = f85_local8[@"hash_7B4983E074152C2D"]
								if not f85_local10 then
								
								else
									if f85_local8 then
										f85_local6 = f85_local8[@"hash_751E7101B70C8A6C"] or f85_local6
									end
									if f85_local8 then
										f85_local7 = f85_local8[@"hash_170243CFDCD07174"] or f85_local7
									end
									table.insert( f85_local0, {
										models = {
											showOnLeft = true,
											locked = false,
											iconBackground = @"blacktransparent",
											iconBackgroundFocus = @"blacktransparent",
											subtitle = @"hash_229C903C6DF90D6F",
											small = true,
											showForAllClients = true
										},
										properties = {
											action = OpenQuarterMaster
										}
									} )
								end
							end
							f85_local10 = @"ui_icon_blackmarket_store_tile_focus"
						end
					end
					f85_local9 = @"ui_icon_blackmarket_store_tile_default"
				end
				if IsCommerceEnabledOnPC() then
					--[[
					table.insert( f85_local0, {
						models = {
							showOnLeft = not IsBooleanDvarSet( @"loot_enableblackmarket" ),
							iconBackground = @"blacktransparent",
							iconBackgroundFocus = @"blacktransparent",
							locked = false,
							subtitle = @"hash_4191CDDA584B4408",
							small = true,
							showForAllClients = true
						},
						properties = {
							action = OpenStore,
							actionParam = "DirectorPlayButton"
						}
					} )
					]]
				end
		
				if not CoD.isPC then 
					table.insert( f85_local0, {
						models = {
							subtitle = @"hash_2968A794E7F44FAD",
							iconBackground = @"blacktransparent",
							iconBackgroundFocus = @"blacktransparent",
							showOnLeft = false,
							small = true,
							locked = LuaUtils.OnlineOnlyDemo(),
							trialLocked = Engine[@"hash_5CB675CA7856DA25"]()
						},
						properties = {
							action = CoD.DirectorUtility.DirectorSelectAction,
							actionParam = LuaEnum.UI.DIRECTOR_LAN_SELECT,
							selectIndex = f85_local4
						}
					} )
				end
			end
			CoD.DirectorUtility.AddLobbyNavSubscriptionOnce( f85_arg1 )
			CoD.DirectorUtility.AddInstallSubscriptionOnce( f85_arg1 )
			if not f85_arg1._hasAutoEventSubscription then
				local f85_local11 = f85_arg1
				local f85_local12 = f85_arg1.subscribeToModel
				local f85_local6 = Engine[@"getglobalmodel"]()
				f85_local6 = f85_local6:create( "AutoEvents" )
				f85_local12( f85_local11, f85_local6:create( "cycled" ), function ()
					f85_arg1:updateDataSource()
				end, false )
				f85_arg1._hasAutoEventSubscription = true
			end

			table.insert( f85_local0, {
				models = {
					subtitle = @"shield/serverbrowser",
					iconBackground = @"blacktransparent",
					iconBackgroundFocus = @"blacktransparent",
					showOnLeft = true,
					small = true,
					locked = Engine[@"getdvarint"](@"shield_is_offline") == 1
				},
				properties = {
					action = CoD.DirectorUtility.DirectorSelectOpenPopup,
					actionParam = "ShieldLobbyServerBrowserOverlay_Select"
				}
			} )

			return f85_local0
		end )

		CoD.DirectorPreGameButtonLeftJustified = InheritFrom( LUI.UIElement )
		CoD.DirectorPreGameButtonLeftJustified.__defaultWidth = 212
		CoD.DirectorPreGameButtonLeftJustified.__defaultHeight = 50
		CoD.DirectorPreGameButtonLeftJustified.new = function ( f1_arg0, f1_arg1, f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
			local self = LUI.UIElement.new( f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
			self:setClass( CoD.DirectorPreGameButtonLeftJustified )
			self.id = "DirectorPreGameButtonLeftJustified"
			self.soundSet = "FrontendMain"
			self.onlyChildrenFocusable = true
			self.anyChildUsesUpdateState = true
			f1_arg0:addElementToPendingUpdateStateList( self )
			
			local baseButton = CoD.DirectorSelectButtonMiniInternal.new( f1_arg0, f1_arg1, 0, 0, 0, 212 + 30, 0, 0, 0, 70 )
			baseButton:mergeStateConditions( {
				{
					stateName = "TrialLocked",
					condition = function ( menu, element, event )
						return CoD.ModelUtility.IsSelfModelValueTrue( element, f1_arg1, "trialLocked" )
					end
				},
				{
					stateName = "Locked",
					condition = function ( menu, element, event )
						return CoD.ModelUtility.IsSelfModelValueTrue( element, f1_arg1, "locked" )
					end
				}
			} )
			baseButton:linkToElementModel( baseButton, "trialLocked", true, function ( model )
				f1_arg0:updateElementState( baseButton, {
					name = "model_validation",
					menu = f1_arg0,
					controller = f1_arg1,
					modelValue = model:get(),
					modelName = "trialLocked"
				} )
			end )
			baseButton:linkToElementModel( baseButton, "locked", true, function ( model )
				f1_arg0:updateElementState( baseButton, {
					name = "model_validation",
					menu = f1_arg0,
					controller = f1_arg1,
					modelValue = model:get(),
					modelName = "locked"
				} )
			end )
			baseButton.MiddleText:setTTF( "ttmussels_regular" )
			baseButton.MiddleTextFocus:setTTF( "ttmussels_regular" )
			baseButton:linkToElementModel( self, nil, false, function ( model )
				baseButton:setModel( model, f1_arg1 )
			end )
			baseButton:linkToElementModel( self, "subtitle", true, function ( model )
				local f7_local0 = model:get()
				if f7_local0 ~= nil then
					baseButton.MiddleText:setText( LocalizeToUpperString( f7_local0 ) )
				end
			end )
			baseButton:linkToElementModel( self, "subtitle", true, function ( model )
				local f8_local0 = model:get()
				if f8_local0 ~= nil then
					baseButton.MiddleTextFocus:setText( LocalizeToUpperString( f8_local0 ) )
				end
			end )
			self:addElement( baseButton )
			self.baseButton = baseButton
			
			local sizeElement = CoD.DirectorSelectButtonImageInternal.new( f1_arg0, f1_arg1, 0, 0, 0, 212, 0, 0, 0, 50 )
			sizeElement:mergeStateConditions( {
				{
					stateName = "TrialLocked",
					condition = function ( menu, element, event )
						return CoD.ModelUtility.IsSelfModelValueTrue( element, f1_arg1, "trialLocked" )
					end
				},
				{
					stateName = "Locked",
					condition = function ( menu, element, event )
						return CoD.ModelUtility.IsSelfModelValueTrue( element, f1_arg1, "locked" )
					end
				},
				{
					stateName = "Disabled",
					condition = function ( menu, element, event )
						return AlwaysFalse()
					end
				}
			} )
			sizeElement:linkToElementModel( sizeElement, "trialLocked", true, function ( model )
				f1_arg0:updateElementState( sizeElement, {
					name = "model_validation",
					menu = f1_arg0,
					controller = f1_arg1,
					modelValue = model:get(),
					modelName = "trialLocked"
				} )
			end )
			sizeElement:linkToElementModel( sizeElement, "locked", true, function ( model )
				f1_arg0:updateElementState( sizeElement, {
					name = "model_validation",
					menu = f1_arg0,
					controller = f1_arg1,
					modelValue = model:get(),
					modelName = "locked"
				} )
			end )
			sizeElement:setAlpha( 0 )
			sizeElement.Tint:setRGB( 0.05, 0.08, 0.11 )
			sizeElement.Tint:setAlpha( 0.25 )
			sizeElement:linkToElementModel( self, nil, false, function ( model )
				sizeElement:setModel( model, f1_arg1 )
			end )
			sizeElement:linkToElementModel( self, "subtitle", true, function ( model )
				local f15_local0 = model:get()
				if f15_local0 ~= nil then
					sizeElement.ButtonName.GameModeText:setText( ToUpper( CoD.BaseUtility.LocalizeIfXHash( f15_local0 ) ) )
				end
			end )
			self:addElement( sizeElement )
			self.sizeElement = sizeElement
			
			self:mergeStateConditions( {
				{
					stateName = "Large",
					condition = function ( menu, element, event )
						return not CoD.ModelUtility.IsSelfModelValueTrue( element, f1_arg1, "small" )
					end
				}
			} )
			self:linkToElementModel( self, "small", true, function ( model )
				f1_arg0:updateElementState( self, {
					name = "model_validation",
					menu = f1_arg0,
					controller = f1_arg1,
					modelValue = model:get(),
					modelName = "small"
				} )
			end )
			baseButton.id = "baseButton"
			sizeElement.id = "sizeElement"
			self.__defaultFocus = baseButton
			LUI.OverrideFunction_CallOriginalSecond( self, "close", self.__onClose )
			
			if PostLoadFunc then
				PostLoadFunc( self, f1_arg1, f1_arg0 )
			end
			
			return self
		end
		
		CoD.DirectorPreGameButtonLeftJustified.__resetProperties = function ( f18_arg0 )
			f18_arg0.baseButton:completeAnimation()
			f18_arg0.sizeElement:completeAnimation()
			f18_arg0.baseButton:setTopBottom( 0, 0, 0, 50 )
			f18_arg0.baseButton:setAlpha( 1 )
			f18_arg0.baseButton:setScale( 1, 1 )
			f18_arg0.sizeElement:setLeftRight( 0, 0, 0, 212 )
			f18_arg0.sizeElement:setTopBottom( 0, 0, 0, 50 )
			f18_arg0.sizeElement:setAlpha( 0 )
			f18_arg0.sizeElement:setScale( 1, 1 )
		end
		
		CoD.DirectorPreGameButtonLeftJustified.__clipsPerState = {
			DefaultState = {
				DefaultClip = function ( f19_arg0, f19_arg1 )
					f19_arg0:__resetProperties()
					f19_arg0:setupElementClipCounter( 0 )
				end,
				ChildFocus = function ( f20_arg0, f20_arg1 )
					f20_arg0:__resetProperties()
					f20_arg0:setupElementClipCounter( 1 )
					f20_arg0.baseButton:completeAnimation()
					f20_arg0.baseButton:setScale( 1.05, 1.05 )
					f20_arg0.clipFinished( f20_arg0.baseButton )
				end,
				GainChildFocus = function ( f21_arg0, f21_arg1 )
					f21_arg0:__resetProperties()
					f21_arg0:setupElementClipCounter( 1 )
					local f21_local0 = function ( f22_arg0 )
						f21_arg0.baseButton:beginAnimation( 200 )
						f21_arg0.baseButton:setScale( 1.05, 1.05 )
						f21_arg0.baseButton:registerEventHandler( "interrupted_keyframe", f21_arg0.clipInterrupted )
						f21_arg0.baseButton:registerEventHandler( "transition_complete_keyframe", f21_arg0.clipFinished )
					end
					
					f21_arg0.baseButton:completeAnimation()
					f21_arg0.baseButton:setScale( 1, 1 )
					f21_local0( f21_arg0.baseButton )
				end,
				LoseChildFocus = function ( f23_arg0, f23_arg1 )
					f23_arg0:__resetProperties()
					f23_arg0:setupElementClipCounter( 1 )
					local f23_local0 = function ( f24_arg0 )
						f23_arg0.baseButton:beginAnimation( 200 )
						f23_arg0.baseButton:setScale( 1, 1 )
						f23_arg0.baseButton:registerEventHandler( "interrupted_keyframe", f23_arg0.clipInterrupted )
						f23_arg0.baseButton:registerEventHandler( "transition_complete_keyframe", f23_arg0.clipFinished )
					end
					
					f23_arg0.baseButton:completeAnimation()
					f23_arg0.baseButton:setScale( 1.05, 1.05 )
					f23_local0( f23_arg0.baseButton )
				end
			},
			Large = {
				DefaultClip = function ( f25_arg0, f25_arg1 )
					f25_arg0:__resetProperties()
					f25_arg0:setupElementClipCounter( 2 )
					f25_arg0.baseButton:completeAnimation()
					f25_arg0.baseButton:setTopBottom( 0, 0, 0, 197 )
					f25_arg0.baseButton:setAlpha( 0 )
					f25_arg0.clipFinished( f25_arg0.baseButton )
					f25_arg0.sizeElement:completeAnimation()
					f25_arg0.sizeElement:setLeftRight( 0, 0, 0, 212 )
					f25_arg0.sizeElement:setTopBottom( 0, 0, 0, 189 )
					f25_arg0.sizeElement:setAlpha( 1 )
					f25_arg0.clipFinished( f25_arg0.sizeElement )
				end,
				ChildFocus = function ( f26_arg0, f26_arg1 )
					f26_arg0:__resetProperties()
					f26_arg0:setupElementClipCounter( 2 )
					f26_arg0.baseButton:completeAnimation()
					f26_arg0.baseButton:setTopBottom( 0, 0, 0, 197 )
					f26_arg0.baseButton:setAlpha( 0 )
					f26_arg0.baseButton:setScale( 1.05, 1.05 )
					f26_arg0.clipFinished( f26_arg0.baseButton )
					f26_arg0.sizeElement:completeAnimation()
					f26_arg0.sizeElement:setLeftRight( 0, 0, 0, 212 )
					f26_arg0.sizeElement:setTopBottom( 0, 0, 0, 189 )
					f26_arg0.sizeElement:setAlpha( 1 )
					f26_arg0.sizeElement:setScale( 1.05, 1.05 )
					f26_arg0.clipFinished( f26_arg0.sizeElement )
				end,
				GainChildFocus = function ( f27_arg0, f27_arg1 )
					f27_arg0:__resetProperties()
					f27_arg0:setupElementClipCounter( 2 )
					local f27_local0 = function ( f28_arg0 )
						f27_arg0.baseButton:beginAnimation( 200 )
						f27_arg0.baseButton:setScale( 1.05, 1.05 )
						f27_arg0.baseButton:registerEventHandler( "interrupted_keyframe", f27_arg0.clipInterrupted )
						f27_arg0.baseButton:registerEventHandler( "transition_complete_keyframe", f27_arg0.clipFinished )
					end
					
					f27_arg0.baseButton:completeAnimation()
					f27_arg0.baseButton:setTopBottom( 0, 0, 0, 197 )
					f27_arg0.baseButton:setAlpha( 0 )
					f27_arg0.baseButton:setScale( 1, 1 )
					f27_local0( f27_arg0.baseButton )
					local f27_local1 = function ( f29_arg0 )
						f27_arg0.sizeElement:beginAnimation( 200 )
						f27_arg0.sizeElement:setScale( 1.05, 1.05 )
						f27_arg0.sizeElement:registerEventHandler( "interrupted_keyframe", f27_arg0.clipInterrupted )
						f27_arg0.sizeElement:registerEventHandler( "transition_complete_keyframe", f27_arg0.clipFinished )
					end
					
					f27_arg0.sizeElement:completeAnimation()
					f27_arg0.sizeElement:setLeftRight( 0, 0, 0, 212 )
					f27_arg0.sizeElement:setTopBottom( 0, 0, 0, 189 )
					f27_arg0.sizeElement:setAlpha( 1 )
					f27_arg0.sizeElement:setScale( 1, 1 )
					f27_local1( f27_arg0.sizeElement )
				end,
				LoseChildFocus = function ( f30_arg0, f30_arg1 )
					f30_arg0:__resetProperties()
					f30_arg0:setupElementClipCounter( 2 )
					local f30_local0 = function ( f31_arg0 )
						f30_arg0.baseButton:beginAnimation( 200 )
						f30_arg0.baseButton:setScale( 1, 1 )
						f30_arg0.baseButton:registerEventHandler( "interrupted_keyframe", f30_arg0.clipInterrupted )
						f30_arg0.baseButton:registerEventHandler( "transition_complete_keyframe", f30_arg0.clipFinished )
					end
					
					f30_arg0.baseButton:completeAnimation()
					f30_arg0.baseButton:setTopBottom( 0, 0, 0, 197 )
					f30_arg0.baseButton:setAlpha( 0 )
					f30_arg0.baseButton:setScale( 1.05, 1.05 )
					f30_local0( f30_arg0.baseButton )
					local f30_local1 = function ( f32_arg0 )
						f30_arg0.sizeElement:beginAnimation( 200 )
						f30_arg0.sizeElement:setScale( 1, 1 )
						f30_arg0.sizeElement:registerEventHandler( "interrupted_keyframe", f30_arg0.clipInterrupted )
						f30_arg0.sizeElement:registerEventHandler( "transition_complete_keyframe", f30_arg0.clipFinished )
					end
					
					f30_arg0.sizeElement:completeAnimation()
					f30_arg0.sizeElement:setLeftRight( 0, 0, 0, 212 )
					f30_arg0.sizeElement:setTopBottom( 0, 0, 0, 189 )
					f30_arg0.sizeElement:setAlpha( 1 )
					f30_arg0.sizeElement:setScale( 1.05, 1.05 )
					f30_local1( f30_arg0.sizeElement )
				end
			}
		}

		CoD.DirectorPreGameButtonLeftJustified.__onClose = function ( f33_arg0 )
			f33_arg0.baseButton:close()
			f33_arg0.sizeElement:close()
		end

		CoD.directorSelect = InheritFrom( LUI.UIElement )
		CoD.directorSelect.__defaultWidth = 1920
		CoD.directorSelect.__defaultHeight = 1080
		CoD.directorSelect.new = function ( f1_arg0, f1_arg1, f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
			local self = LUI.UIElement.new( f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
			self:setClass( CoD.directorSelect )
			self.id = "directorSelect"
			self.soundSet = "FrontendMain"
			self.onlyChildrenFocusable = true
			self.anyChildUsesUpdateState = true
			f1_arg0:addElementToPendingUpdateStateList( self )

			-- add a cool background
			local background_modes = LUI.UIImage.new( 0.5, 0.5, -275 - 750, 275 - 750, 0, 0, 684 - 420, 724 )
			background_modes:setRGB( 0.25, 0.25, 0.25 )
			background_modes:setAlpha(0)
			background_modes:setImage( RegisterImage( @"uie_fe_cp_background" ) )
			--background_modes:setMaterial( LUI.UIImage.GetCachedMaterial( @"hash_E2354BE557C4C7A" ) )
			self:addElement( background_modes )
			self.background_modes = background_modes

			local background_modes_2 = LUI.UIImage.new( 0.5, 0.5, -225 - 750, 225 - 750, 0, 0, 750, 1025 )
			background_modes_2:setRGB( 0.25, 0.25, 0.25 )
			background_modes_2:setAlpha(0)
			background_modes_2:setImage( RegisterImage( @"uie_fe_cp_background" ) )
			--background_modes:setMaterial( LUI.UIImage.GetCachedMaterial( @"hash_E2354BE557C4C7A" ) )
			self:addElement( background_modes_2 )
			self.background_modes_2 = background_modes_2

			--[[
				-- test chat
				CoD.Menu.AddButtonCallbackFunction( f1_arg0, self, f1_arg1, Enum[@"luibutton"][@"lui_key_none"], "F", function ( element, menu, controller, f10_arg3 )
					CoD.PCUtility.ToggleChatVisibility( controller )
				end )
			]]

			--[[
			local backing = LUI.UIImage.new( 0, 1, 0, 0, 0, 1, 0, 0 )
			backing:setRGB( 0, 0, 0 )
			backing:setMaterial( LUI.UIImage.GetCachedMaterial( @"hash_E2354BE557C4C7A" ) )
			backing:setShaderVector( 0, 0, 0, 0, 0 )
			self:addElement( backing )
			self.backing = backing
			
			local BackgroundImage = LUI.UIImage.new( 0, 1, 0, 0, 0, 1, 0, 0 )
			BackgroundImage:setAlpha( 0.85 )
			BackgroundImage:setImage( RegisterImage( @"hash_64BF88A437F4C579" ) )
			self:addElement( BackgroundImage )
			self.BackgroundImage = BackgroundImage

			--self:setAlpha(0)
			
			local FramingCornerBrackets = CoD.CommonCornerBrackets01.new( f1_arg0, f1_arg1, 0.5, 0.5, -516.5, 516.5, 0, 0, 222, 796 )
			FramingCornerBrackets:setAlpha( 0.1 )
			self:addElement( FramingCornerBrackets )
			self.FramingCornerBrackets = FramingCornerBrackets
			
			local DotLineBottom = LUI.UIImage.new( 0.5, 0.5, -474.5, 474.5, 0, 0, 777, 781 )
			DotLineBottom:setAlpha( 0.4 )
			DotLineBottom:setImage( RegisterImage( @"hash_6F9C7F41C631866E" ) )
			DotLineBottom:setMaterial( LUI.UIImage.GetCachedMaterial( @"hash_31CC85D0A86303B0" ) )
			DotLineBottom:setShaderVector( 0, 1.2, 0, 0, 0 )
			self:addElement( DotLineBottom )
			self.DotLineBottom = DotLineBottom
			
			local DotLineTop = LUI.UIImage.new( 0.5, 0.5, -474.5, 474.5, 0, 0, 238, 242 )
			DotLineTop:setAlpha( 0.4 )
			DotLineTop:setImage( RegisterImage( @"hash_6F9C7F41C631866E" ) )
			DotLineTop:setMaterial( LUI.UIImage.GetCachedMaterial( @"hash_31CC85D0A86303B0" ) )
			DotLineTop:setShaderVector( 0, 1.2, 0, 0, 0 )
			self:addElement( DotLineTop )
			self.DotLineTop = DotLineTop
			]]
			
			local f1_local6 = nil
			self.Header = LUI.UIElement.createFake()
			local HeaderPC = nil
			
			HeaderPC = CoD.DirectorScreenHeader.new( f1_arg0, f1_arg1, 0.5, 0.5, -553, 81, 0.5, 0.5, -394, -297 )
			HeaderPC:setAlpha( 0 )
			HeaderPC:setZoom( 75 )
			HeaderPC.Header:setText( LocalizeToUpperString( @"hash_156CB4013028D74E" ) )
			self:addElement( HeaderPC )
			self.HeaderPC = HeaderPC
			
			local DirectorLeaderActivitySelect = CoD.DirectorLeaderActivitySelect.new( f1_arg0, f1_arg1, 0.5, 0.5, -622.5, -322.5, 1, 1, -197, -147 )
			DirectorLeaderActivitySelect:mergeStateConditions( {
				{
					stateName = "Invisible",
					condition = function ( menu, element, event )
						return AlwaysTrue()
					end
				}
			} )
			self:addElement( DirectorLeaderActivitySelect )
			self.DirectorLeaderActivitySelect = DirectorLeaderActivitySelect
			
			local pckeyboardNavigationRedirector2 = nil
			
			pckeyboardNavigationRedirector2 = CoD.emptyFocusable.new( f1_arg0, f1_arg1, 0.7, 1, 0, 0, 0.27, 0.32, -35, -35 )
			self:addElement( pckeyboardNavigationRedirector2 )
			self.pckeyboardNavigationRedirector2 = pckeyboardNavigationRedirector2
			
			local LogoBO4 = nil
			
			LogoBO4 = LUI.UIFixedAspectRatioImage.new( 0.5, 0.5, -945, -641, 0.5, 0.5, -525, -373 )
			LogoBO4:setAlpha( 0 )
			LogoBO4:setScale( 0.8, 0.8 )
			LogoBO4:setImage( RegisterImage( @"hash_3A921D8110F2D3BD" ) )
			self:addElement( LogoBO4 )
			self.LogoBO4 = LogoBO4
			
			local ButtonListLeft = LUI.UIList.new( f1_arg0, f1_arg1, 15, 0, nil, false, false, false, false )
			ButtonListLeft:setLeftRight( 0, 0, 80, 185 )
			ButtonListLeft:setTopBottom( 0, 0, 265 + 500, 510 + 500 )
			ButtonListLeft:setWidgetType( CoD.DirectorPreGameButtonLeftJustified )
			ButtonListLeft:setVerticalCount( 4 )
			ButtonListLeft:setSpacing( 15 )
			--ButtonListLeft:setAlignment( Enum[@"hash_67A5123B654282D2"][@"hash_558C8A85F2048829"] )
			ButtonListLeft:setFilter( function ( f3_arg0 )
				return f3_arg0.showOnLeft:get() == true
			end )
			ButtonListLeft:setDataSource( "DirectorExtraHomeButtonsCustom" )
			ButtonListLeft:linkToElementModel( ButtonListLeft, "trialLocked", true, function ( model, f4_arg1 )
				CoD.Menu.UpdateButtonShownState( f4_arg1, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
			end )
			ButtonListLeft:linkToElementModel( ButtonListLeft, "locked", true, function ( model, f5_arg1 )
				CoD.Menu.UpdateButtonShownState( f5_arg1, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
			end )
			local ButtonFeatured = ButtonListLeft
			local ButtonListRight = ButtonListLeft.subscribeToModel
			local ButtonModes = Engine[@"hash_78DF2E5447F384B9"]()
			ButtonListRight( ButtonFeatured, ButtonModes["lobbyRoot.lobbyNav"], function ( f6_arg0, f6_arg1 )
				CoD.Menu.UpdateButtonShownState( f6_arg1, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
			end, false )
			ButtonFeatured = ButtonListLeft
			ButtonListRight = ButtonListLeft.subscribeToModel
			ButtonModes = Engine[@"hash_78DF2E5447F384B9"]()
			ButtonListRight( ButtonFeatured, ButtonModes["lobbyRoot.gameClient.update"], function ( f7_arg0, f7_arg1 )
				CoD.Menu.UpdateButtonShownState( f7_arg1, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
			end, false )
			ButtonFeatured = ButtonListLeft
			ButtonListRight = ButtonListLeft.subscribeToModel
			ButtonModes = Engine[@"hash_78DF2E5447F384B9"]()
			ButtonListRight( ButtonFeatured, ButtonModes["lobbyRoot.privateClient.update"], function ( f8_arg0, f8_arg1 )
				CoD.Menu.UpdateButtonShownState( f8_arg1, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
			end, false )
			ButtonListLeft:linkToElementModel( ButtonListLeft, "showForAllClients", true, function ( model, f9_arg1 )
				CoD.Menu.UpdateButtonShownState( f9_arg1, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
			end )
			ButtonListLeft:registerEventHandler( "list_item_gain_focus", function ( element, event )
				local f10_local0 = nil
				CoD.DirectorUtility.UpdateDescriptionTextFromSelectMenu( f1_arg1, element )
				return f10_local0
			end )
			ButtonListLeft:registerEventHandler( "gain_focus", function ( element, event )
				local f11_local0 = nil
				if element.gainFocus then
					f11_local0 = element:gainFocus( event )
				elseif element.super.gainFocus then
					f11_local0 = element.super:gainFocus( event )
				end
				CoD.Menu.UpdateButtonShownState( element, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
				return f11_local0
			end )
			f1_arg0:AddButtonCallbackFunction( ButtonListLeft, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], "ui_confirm", function ( element, menu, controller, model )
				if CoD.ModelUtility.IsSelfModelValueTrue( element, controller, "trialLocked" ) and AlwaysFalse() then
					OpenOverlay( self, "Store", controller )
					PlaySoundAlias( "uin_toggle_generic" )
					return true
				elseif not CoD.ModelUtility.IsSelfModelValueTrue( element, controller, "locked" ) and CoD.DirectorUtility.ShowForAllClients( element, controller ) and not CoD.ModelUtility.IsSelfModelValueTrue( element, controller, "trialLocked" ) then
					ProcessListAction( self, element, controller, menu )
					PlaySoundAlias( "uin_toggle_generic" )
					return true
				else
					
				end
			end, function ( element, menu, controller )
				if CoD.ModelUtility.IsSelfModelValueTrue( element, controller, "trialLocked" ) and AlwaysFalse() then
					CoD.Menu.SetButtonLabel( menu, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], @"hash_4191CDDA584B4408", nil, "ui_confirm" )
					return true
				elseif not CoD.ModelUtility.IsSelfModelValueTrue( element, controller, "locked" ) and CoD.DirectorUtility.ShowForAllClients( element, controller ) and not CoD.ModelUtility.IsSelfModelValueTrue( element, controller, "trialLocked" ) then
					CoD.Menu.SetButtonLabel( menu, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], @"hash_6D0BB36CD318F55F", nil, "ui_confirm" )
					return true
				else
					return false
				end
			end, false )
			self:addElement( ButtonListLeft )
			self.ButtonListLeft = ButtonListLeft
			
			ButtonListRight = LUI.UIList.new( f1_arg0, f1_arg1, 15, 0, nil, false, false, false, false )
			ButtonListRight:setLeftRight( 1, 1, -50, 150 )
			ButtonListRight:setTopBottom( 0, 0, 265, 510 )
			ButtonListRight:setWidgetType( CoD.DirectorPreGameButtonLeftJustified )
			ButtonListRight:setVerticalCount( 4 )
			ButtonListRight:setSpacing( 15 )
			--ButtonListRight:setAlignment( Enum[@"hash_67A5123B654282D2"][@"hash_558C8A85F2048829"] )
			ButtonListRight:setFilter( function ( f14_arg0 )
				return f14_arg0.showOnLeft:get() == false
			end )
			ButtonListRight:setDataSource( "DirectorExtraHomeButtonsCustom" )
			ButtonListRight:linkToElementModel( ButtonListRight, "locked", true, function ( model, f15_arg1 )
				CoD.Menu.UpdateButtonShownState( f15_arg1, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
			end )
			ButtonModes = ButtonListRight
			ButtonFeatured = ButtonListRight.subscribeToModel
			local SafeAreaContainer = Engine[@"hash_78DF2E5447F384B9"]()
			ButtonFeatured( ButtonModes, SafeAreaContainer["lobbyRoot.lobbyNav"], function ( f16_arg0, f16_arg1 )
				CoD.Menu.UpdateButtonShownState( f16_arg1, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
			end, false )
			ButtonModes = ButtonListRight
			ButtonFeatured = ButtonListRight.subscribeToModel
			SafeAreaContainer = Engine[@"hash_78DF2E5447F384B9"]()
			ButtonFeatured( ButtonModes, SafeAreaContainer["lobbyRoot.gameClient.update"], function ( f17_arg0, f17_arg1 )
				CoD.Menu.UpdateButtonShownState( f17_arg1, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
			end, false )
			ButtonModes = ButtonListRight
			ButtonFeatured = ButtonListRight.subscribeToModel
			SafeAreaContainer = Engine[@"hash_78DF2E5447F384B9"]()
			ButtonFeatured( ButtonModes, SafeAreaContainer["lobbyRoot.privateClient.update"], function ( f18_arg0, f18_arg1 )
				CoD.Menu.UpdateButtonShownState( f18_arg1, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
			end, false )
			ButtonListRight:linkToElementModel( ButtonListRight, "showForAllClients", true, function ( model, f19_arg1 )
				CoD.Menu.UpdateButtonShownState( f19_arg1, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
			end )
			ButtonListRight:registerEventHandler( "list_item_gain_focus", function ( element, event )
				local f20_local0 = nil
				CoD.DirectorUtility.UpdateDescriptionTextFromSelectMenu( f1_arg1, element )
				return f20_local0
			end )
			ButtonListRight:registerEventHandler( "gain_focus", function ( element, event )
				local f21_local0 = nil
				if element.gainFocus then
					f21_local0 = element:gainFocus( event )
				elseif element.super.gainFocus then
					f21_local0 = element.super:gainFocus( event )
				end
				CoD.Menu.UpdateButtonShownState( element, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
				return f21_local0
			end )
			f1_arg0:AddButtonCallbackFunction( ButtonListRight, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], "ui_confirm", function ( element, menu, controller, model )
				if not CoD.ModelUtility.IsSelfModelValueTrue( element, controller, "locked" ) and CoD.DirectorUtility.ShowForAllClients( element, controller ) then
					PlaySoundAlias( "uin_toggle_generic" )
					ProcessListAction( self, element, controller, menu )
					return true
				else
					
				end
			end, function ( element, menu, controller )
				if not CoD.ModelUtility.IsSelfModelValueTrue( element, controller, "locked" ) and CoD.DirectorUtility.ShowForAllClients( element, controller ) then
					CoD.Menu.SetButtonLabel( menu, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], @"hash_6D0BB36CD318F55F", nil, "ui_confirm" )
					return true
				else
					return false
				end
			end, false )
			self:addElement( ButtonListRight )
			self.ButtonListRight = ButtonListRight
			
			ButtonFeatured = LUI.UIList.new( f1_arg0, f1_arg1, 25, 0, nil, false, false, false, false )
			ButtonFeatured:setLeftRight( 0, 0, 50, 150 )
			ButtonFeatured:setTopBottom( 0, 0, 265, 659 )
			ButtonFeatured:setWidgetType( CoD.DirectorSelectButton )
			ButtonFeatured:setHorizontalCount( 1 )
			ButtonFeatured:setVerticalCount( 5 )
			ButtonFeatured:setSpacing( 10 )
			--ButtonFeatured:setAlignment( Enum[@"hash_67A5123B654282D2"][@"hash_558C8A85F2048829"] )
			ButtonFeatured:setStaggeredIntroTime( 100 )
			ButtonFeatured:setDataSource( "DirectorFeaturedButtons_non" )
			ButtonFeatured:linkToElementModel( ButtonFeatured, "trialLocked", true, function ( model, f24_arg1 )
				CoD.Menu.UpdateButtonShownState( f24_arg1, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
			end )
			SafeAreaContainer = ButtonFeatured
			ButtonModes = ButtonFeatured.subscribeToModel
			local IGRPerksDirectorButton = Engine[@"hash_78DF2E5447F384B9"]()
			ButtonModes( SafeAreaContainer, IGRPerksDirectorButton["lobbyRoot.lobbyNav"], function ( f25_arg0, f25_arg1 )
				CoD.Menu.UpdateButtonShownState( f25_arg1, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
			end, false )
			SafeAreaContainer = ButtonFeatured
			ButtonModes = ButtonFeatured.subscribeToModel
			IGRPerksDirectorButton = Engine[@"hash_78DF2E5447F384B9"]()
			ButtonModes( SafeAreaContainer, IGRPerksDirectorButton["lobbyRoot.gameClient.update"], function ( f26_arg0, f26_arg1 )
				CoD.Menu.UpdateButtonShownState( f26_arg1, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
			end, false )
			SafeAreaContainer = ButtonFeatured
			ButtonModes = ButtonFeatured.subscribeToModel
			IGRPerksDirectorButton = Engine[@"hash_78DF2E5447F384B9"]()
			ButtonModes( SafeAreaContainer, IGRPerksDirectorButton["lobbyRoot.privateClient.update"], function ( f27_arg0, f27_arg1 )
				CoD.Menu.UpdateButtonShownState( f27_arg1, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
			end, false )
			ButtonFeatured:linkToElementModel( ButtonFeatured, "showForAllClients", true, function ( model, f28_arg1 )
				CoD.Menu.UpdateButtonShownState( f28_arg1, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
			end )
			ButtonFeatured:linkToElementModel( ButtonFeatured, "locked", true, function ( model, f29_arg1 )
				CoD.Menu.UpdateButtonShownState( f29_arg1, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
			end )
			ButtonFeatured:linkToElementModel( ButtonFeatured, "lockState", true, function ( model, f30_arg1 )
				CoD.Menu.UpdateButtonShownState( f30_arg1, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
			end )
			ButtonFeatured:linkToElementModel( ButtonFeatured, "mode", true, function ( model, f31_arg1 )
				CoD.Menu.UpdateButtonShownState( f31_arg1, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
			end )
			ButtonFeatured:registerEventHandler( "list_item_gain_focus", function ( element, event )
				local f32_local0 = nil
				CoD.DirectorUtility.UpdateDescriptionTextFromSelectMenu( f1_arg1, element )
				CoD.BlackMarketUtility.ShowTierSkipNotification( f1_arg1, element, f1_arg0 )
				return f32_local0
			end )
			ButtonFeatured:registerEventHandler( "list_item_lose_focus", function ( element, event )
				local f33_local0 = nil
				CoD.BlackMarketUtility.HideTierSkipNotification( f1_arg1, element, f1_arg0 )
				return f33_local0
			end )
			ButtonFeatured:registerEventHandler( "gain_focus", function ( element, event )
				local f34_local0 = nil
				if element.gainFocus then
					f34_local0 = element:gainFocus( event )
				elseif element.super.gainFocus then
					f34_local0 = element.super:gainFocus( event )
				end
				CoD.Menu.UpdateButtonShownState( element, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
				return f34_local0
			end )
			f1_arg0:AddButtonCallbackFunction( ButtonFeatured, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], "ui_confirm", function ( element, menu, controller, model )
				if CoD.ModelUtility.IsSelfModelValueTrue( element, controller, "trialLocked" ) then
					OpenOverlay( self, "Store", controller )
					PlaySoundAlias( "uin_toggle_generic" )
					return true
				elseif CoD.DirectorUtility.ShowForAllClients( element, controller ) and not CoD.ModelUtility.IsSelfModelValueTrue( element, controller, "locked" ) then
					ProcessListAction( self, element, controller, menu )
					PlaySoundAlias( "uin_toggle_featured_playlist" )
					return true
				elseif CoD.ModelUtility.IsSelfModelValueEqualToEnum( element, controller, "lockState", Enum[@"hash_4DACBB5C5F26BCD9"][@"hash_19B632F6362EA1BE"] ) then
					OpenSystemOverlay( self, menu, controller, "DownloadDLC", {
						_model = element:getModel()
					} )
					return true
				elseif CoD.ModelUtility.IsSelfModelValueEqualToEnum( element, controller, "lockState", Enum[@"hash_4DACBB5C5F26BCD9"][@"hash_4BDEB566326AC98"] ) and CoD.ModelUtility.IsSelfModelValueEqualToEnum( element, controller, "mode", Enum[@"hash_89C1455C5032969"][@"hash_379D01499920B292"] ) then
					CoD.StoreUtility.OpenStoreToDLCPack( self, element, controller, "DirectorSelect", menu )
					return true
				elseif CoD.ModelUtility.IsSelfModelValueEqualToEnum( element, controller, "lockState", Enum[@"hash_4DACBB5C5F26BCD9"][@"hash_4BDEB566326AC98"] ) then
					OpenSystemOverlay( self, menu, controller, "SeasonPassUpsell", {
						_model = element:getModel(),
						_description = @"hash_475EE3FCE54AF260"
					} )
					return true
				elseif CoD.DirectorUtility.ShowForAllClients( element, controller ) and CoD.ModelUtility.IsSelfModelValueTrue( element, controller, "locked" ) then
					ProcessListLockedAction( self, element, controller, menu )
					return true
				else
					
				end
			end, function ( element, menu, controller )
				if CoD.ModelUtility.IsSelfModelValueTrue( element, controller, "trialLocked" ) then
					CoD.Menu.SetButtonLabel( menu, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], @"hash_4191CDDA584B4408", nil, "ui_confirm" )
					return true
				elseif CoD.DirectorUtility.ShowForAllClients( element, controller ) and not CoD.ModelUtility.IsSelfModelValueTrue( element, controller, "locked" ) then
					CoD.Menu.SetButtonLabel( menu, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], @"hash_6D0BB36CD318F55F", nil, "ui_confirm" )
					return true
				elseif CoD.ModelUtility.IsSelfModelValueEqualToEnum( element, controller, "lockState", Enum[@"hash_4DACBB5C5F26BCD9"][@"hash_19B632F6362EA1BE"] ) then
					CoD.Menu.SetButtonLabel( menu, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], @"hash_6D0BB36CD318F55F", nil, "ui_confirm" )
					return true
				elseif CoD.ModelUtility.IsSelfModelValueEqualToEnum( element, controller, "lockState", Enum[@"hash_4DACBB5C5F26BCD9"][@"hash_4BDEB566326AC98"] ) and CoD.ModelUtility.IsSelfModelValueEqualToEnum( element, controller, "mode", Enum[@"hash_89C1455C5032969"][@"hash_379D01499920B292"] ) then
					CoD.Menu.SetButtonLabel( menu, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], @"hash_6D0BB36CD318F55F", nil, "ui_confirm" )
					return true
				elseif CoD.ModelUtility.IsSelfModelValueEqualToEnum( element, controller, "lockState", Enum[@"hash_4DACBB5C5F26BCD9"][@"hash_4BDEB566326AC98"] ) then
					CoD.Menu.SetButtonLabel( menu, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], @"hash_6D0BB36CD318F55F", nil, "ui_confirm" )
					return true
				elseif CoD.DirectorUtility.ShowForAllClients( element, controller ) and CoD.ModelUtility.IsSelfModelValueTrue( element, controller, "locked" ) then
					CoD.Menu.SetButtonLabel( menu, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], @"hash_6D0BB36CD318F55F", nil, "ui_confirm" )
					return true
				else
					return false
				end
			end, false )
			self:addElement( ButtonFeatured )
			self.ButtonFeatured = ButtonFeatured

			ButtonModes = LUI.UIList.new( f1_arg0, f1_arg1, 25, 0, nil, false, false, false, false )
			ButtonModes:setLeftRight( 0, 0, 50, 150 )
			ButtonModes:setTopBottom( 0, 0, 684 - 370, 754 - 370 )
			ButtonModes:setWidgetType( CoD.DirectorSelectButtonGameType )
			ButtonModes:setHorizontalCount( 1 )
			ButtonModes:setVerticalCount( 5 )
			ButtonModes:setSpacing( 10 )
			--ButtonModes:setAlignment( Enum[@"hash_67A5123B654282D2"][@"hash_558C8A85F2048829"] )
			ButtonModes:setDataSource( "DirectorPlayButtons" )
			ButtonModes:linkToElementModel( ButtonModes, "trialLocked", true, function ( model, f37_arg1 )
				CoD.Menu.UpdateButtonShownState( f37_arg1, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
			end )
			ButtonModes:linkToElementModel( ButtonModes, "locked", true, function ( model, f38_arg1 )
				CoD.Menu.UpdateButtonShownState( f38_arg1, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
			end )
			IGRPerksDirectorButton = ButtonModes
			SafeAreaContainer = ButtonModes.subscribeToModel
			local selectionDescription = Engine[@"hash_78DF2E5447F384B9"]()
			SafeAreaContainer( IGRPerksDirectorButton, selectionDescription["lobbyRoot.lobbyNav"], function ( f39_arg0, f39_arg1 )
				CoD.Menu.UpdateButtonShownState( f39_arg1, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
			end, false )
			IGRPerksDirectorButton = ButtonModes
			SafeAreaContainer = ButtonModes.subscribeToModel
			selectionDescription = Engine[@"hash_78DF2E5447F384B9"]()
			SafeAreaContainer( IGRPerksDirectorButton, selectionDescription["lobbyRoot.gameClient.update"], function ( f40_arg0, f40_arg1 )
				CoD.Menu.UpdateButtonShownState( f40_arg1, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
			end, false )
			IGRPerksDirectorButton = ButtonModes
			SafeAreaContainer = ButtonModes.subscribeToModel
			selectionDescription = Engine[@"hash_78DF2E5447F384B9"]()
			SafeAreaContainer( IGRPerksDirectorButton, selectionDescription["lobbyRoot.privateClient.update"], function ( f41_arg0, f41_arg1 )
				CoD.Menu.UpdateButtonShownState( f41_arg1, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
			end, false )
			ButtonModes:linkToElementModel( ButtonModes, "showForAllClients", true, function ( model, f42_arg1 )
				CoD.Menu.UpdateButtonShownState( f42_arg1, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
			end )
			ButtonModes:registerEventHandler( "list_item_gain_focus", function ( element, event )
				local f43_local0 = nil
				CoD.DirectorUtility.UpdateDescriptionTextFromSelectMenu( f1_arg1, element )
				CoD.BlackMarketUtility.ShowTierSkipNotification( f1_arg1, element, f1_arg0 )
				return f43_local0
			end )
			ButtonModes:registerEventHandler( "list_item_lose_focus", function ( element, event )
				local f44_local0 = nil
				CoD.BlackMarketUtility.HideTierSkipNotification( f1_arg1, element, f1_arg0 )
				return f44_local0
			end )
			ButtonModes:registerEventHandler( "gain_focus", function ( element, event )
				local f45_local0 = nil
				if element.gainFocus then
					f45_local0 = element:gainFocus( event )
				elseif element.super.gainFocus then
					f45_local0 = element.super:gainFocus( event )
				end
				CoD.Menu.UpdateButtonShownState( element, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
				return f45_local0
			end )
			f1_arg0:AddButtonCallbackFunction( ButtonModes, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], "ui_confirm", function ( element, menu, controller, model )
				if CoD.ModelUtility.IsSelfModelValueTrue( element, controller, "trialLocked" ) and AlwaysFalse() then
					OpenOverlay( self, "Store", controller )
					PlaySoundAlias( "uin_toggle_generic" )
					return true
				elseif not CoD.ModelUtility.IsSelfModelValueTrue( element, controller, "locked" ) and CoD.DirectorUtility.ShowForAllClients( element, controller ) and not CoD.ModelUtility.IsSelfModelValueTrue( element, controller, "trialLocked" ) then
					ProcessListAction( self, element, controller, menu )
					PlaySoundAlias( "uin_toggle_generic" )
					return true
				elseif IsPC() and CoD.ModelUtility.IsSelfModelValueTrue( element, controller, "locked" ) and CoD.DirectorUtility.ShowForAllClients( element, controller ) then
					ProcessListLockedAction( self, element, controller, menu )
					return true
				else
					
				end
			end, function ( element, menu, controller )
				if CoD.ModelUtility.IsSelfModelValueTrue( element, controller, "trialLocked" ) and AlwaysFalse() then
					CoD.Menu.SetButtonLabel( menu, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], @"hash_4191CDDA584B4408", nil, "ui_confirm" )
					return true
				elseif not CoD.ModelUtility.IsSelfModelValueTrue( element, controller, "locked" ) and CoD.DirectorUtility.ShowForAllClients( element, controller ) and not CoD.ModelUtility.IsSelfModelValueTrue( element, controller, "trialLocked" ) then
					CoD.Menu.SetButtonLabel( menu, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], @"hash_6D0BB36CD318F55F", nil, "ui_confirm" )
					return true
				elseif IsPC() and CoD.ModelUtility.IsSelfModelValueTrue( element, controller, "locked" ) and CoD.DirectorUtility.ShowForAllClients( element, controller ) then
					CoD.Menu.SetButtonLabel( menu, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], @"hash_6D0BB36CD318F55F", nil, "ui_confirm" )
					return true
				else
					return false
				end
			end, false )
			self:addElement( ButtonModes )
			self.ButtonModes = ButtonModes
			
			SafeAreaContainer = CoD.DirectorSelectSafeAreaContainer.new( f1_arg0, f1_arg1, 0, 1, 0, 0, 0, 0, 0, 1080 )
			SafeAreaContainer:registerEventHandler( "menu_loaded", function ( element, event )
				local f48_local0 = nil
				if element.menuLoaded then
					f48_local0 = element:menuLoaded( event )
				elseif element.super.menuLoaded then
					f48_local0 = element.super:menuLoaded( event )
				end
				if not IsPC() then
					SizeToSafeArea( element, f1_arg1 )
				end
				if not f48_local0 then
					f48_local0 = element:dispatchEventToChildren( event )
				end
				return f48_local0
			end )
			self:addElement( SafeAreaContainer )
			self.SafeAreaContainer = SafeAreaContainer

			SafeAreaContainer.CRMFeatureList:setTopBottom(0, 0, 26 + 800, 168 + 800)
			SafeAreaContainer.CRMFeatureList:setLeftRight(0, 0, 26 + 350, 466 + 350)
			--self:addElement(SafeAreaContainer) -- reset anchors
			
			IGRPerksDirectorButton = nil
			
			IGRPerksDirectorButton = CoD.IGRPerksDirectorButton.new( f1_arg0, f1_arg1, 0.5, 0.5, 265, 985, 0.5, 0.5, 239, 303 )
			IGRPerksDirectorButton:setScale( 0.9, 0.9 )
			self:addElement( IGRPerksDirectorButton )
			self.IGRPerksDirectorButton = IGRPerksDirectorButton
			
			selectionDescription = LUI.UIText.new( 0.5, 0.5, -473, 473, 0, 0, 793, 823 )
			selectionDescription:setTTF( "dinnext_regular" )
			selectionDescription:setAlignment( Enum[@"hash_67A5123B654282D2"][@"hash_558C8A85F2048829"] )
			selectionDescription:setAlignment( Enum[@"hash_67A5123B654282D2"][@"hash_3F41D595A2B0EDF3"] )
			selectionDescription:subscribeToGlobalModel( f1_arg1, "LobbyRoot", "selectScreenDescription", function ( model )
				local f49_local0 = model:get()
				if f49_local0 ~= nil then
					selectionDescription:setText( Engine[@"hash_4F9F1239CFD921FE"]( f49_local0 ) )
				end
			end )
			self:addElement( selectionDescription )
			self.selectionDescription = selectionDescription

			local PathNotesButton = CoD.DirectorSelectButtonMiniInternal.new( f1_arg0, f1_arg1, 1, 1, -380, -50, 0.88, 0.88, 15, 55 )
			
			PathNotesButton.MiddleText:setTTF( "ttmussels_regular" )
			PathNotesButton.MiddleText:setText("INFO & PATCH NOTES")

			PathNotesButton.MiddleTextFocus:setText("INFO & PATCH NOTES")
			PathNotesButton.MiddleTextFocus:setTTF( "ttmussels_regular" )

			PathNotesButton:linkToElementModel( self, nil, false, function ( model )
				PathNotesButton:setModel( model, f1_arg1 )
			end )
			self:addElement( PathNotesButton )
			self.PathNotesButton = PathNotesButton

			f1_arg0:AddButtonCallbackFunction( PathNotesButton, f1_arg0, Enum[@"luibutton"][@"lui_key_xba_pscross"], "ui_confirm", function ( element, menu, controller, model )
				PlaySoundAlias( "uin_paint_image_flip_toggle" )
				CoD.EnhPrintInfo("PathNotesButton")
				
				OpenOverlay( self, "ShieldPatchNotes", controller )

			end, function ( element, menu, controller )
				if IsGamepad( controller ) then
					CoD.Menu.SetButtonLabel( menu, Enum[@"luibutton"][@"lui_key_xba_pscross"], @"menu/join", nil, "ui_confirm" )
					return true
				elseif IsMouseOrKeyboard( controller ) then
					CoD.Menu.SetButtonLabel( menu, Enum[@"luibutton"][@"lui_key_xba_pscross"], @"hash_0", nil, "ui_confirm" )
					return false
				else
					return false
				end
			end, false )
			
			local sizePathNotesButton = CoD.DirectorSelectButtonImageInternal.new( f1_arg0, f1_arg1, 1, 1, -380, -50, 0.88, 0.88, 0, 30 )

			sizePathNotesButton:setAlpha( 0 )
			sizePathNotesButton.Tint:setRGB( 0.05, 0.08, 0.11 )
			sizePathNotesButton.Tint:setAlpha( 0.25 )
			sizePathNotesButton:linkToElementModel( self, nil, false, function ( model )
				sizePathNotesButton:setModel( model, f1_arg1 )
			end )
			sizePathNotesButton.ButtonName.GameModeText:setText("^3Patch Notes")
			self:addElement( sizePathNotesButton )
			self.sizePathNotesButton = sizePathNotesButton

			PathNotesButton.id = "PathNotesButton"
			sizePathNotesButton.id = "sizePathNotesButton"

			local MusicManager = CoD.DirectorSelectButtonMiniInternal.new( f1_arg0, f1_arg1, 1, 1, -380, -50, 0.88, 0.88, 15 - 55 - 110, 55 - 55 - 110 )
			
			MusicManager.MiddleText:setTTF( "ttmussels_regular" )
			MusicManager.MiddleText:setText("MUSIC MANAGER")

			MusicManager.MiddleTextFocus:setText("MUSIC MANAGER")
			MusicManager.MiddleTextFocus:setTTF( "ttmussels_regular" )

			MusicManager:linkToElementModel( self, nil, false, function ( model )
				MusicManager:setModel( model, f1_arg1 )
			end )
			self:addElement( MusicManager )
			self.MusicManager = MusicManager

			f1_arg0:AddButtonCallbackFunction( MusicManager, f1_arg0, Enum[@"luibutton"][@"lui_key_xba_pscross"], "ui_confirm", function ( element, menu, controller, model )
				PlaySoundAlias( "uin_paint_image_flip_toggle" )
				CoD.EnhPrintInfo("MusicManager")
				
				OpenOverlay( self, "ShieldMusicManager", controller )

			end, function ( element, menu, controller )
				if IsGamepad( controller ) then
					CoD.Menu.SetButtonLabel( menu, Enum[@"luibutton"][@"lui_key_xba_pscross"], @"menu/join", nil, "ui_confirm" )
					return true
				elseif IsMouseOrKeyboard( controller ) then
					CoD.Menu.SetButtonLabel( menu, Enum[@"luibutton"][@"lui_key_xba_pscross"], @"hash_0", nil, "ui_confirm" )
					return false
				else
					return false
				end
			end, false )

			MusicManager.id = "MusicManager"

			local FeaturedModsButton = CoD.DirectorSelectButtonMiniInternal.new( f1_arg0, f1_arg1, 1, 1, -380, -50, 0.88, 0.88, 15 - 55, 55 - 55 )
			
			FeaturedModsButton.MiddleText:setTTF( "ttmussels_regular" )
			FeaturedModsButton.MiddleText:setText("MOD MANAGER")

			FeaturedModsButton.MiddleTextFocus:setText("MOD MANAGER")
			FeaturedModsButton.MiddleTextFocus:setTTF( "ttmussels_regular" )

			FeaturedModsButton:linkToElementModel( self, nil, false, function ( model )
				FeaturedModsButton:setModel( model, f1_arg1 )
			end )
			self:addElement( FeaturedModsButton )
			self.FeaturedModsButton = FeaturedModsButton

			f1_arg0:AddButtonCallbackFunction( FeaturedModsButton, f1_arg0, Enum[@"luibutton"][@"lui_key_xba_pscross"], "ui_confirm", function ( element, menu, controller, model )
				PlaySoundAlias( "uin_paint_image_flip_toggle" )
				CoD.EnhPrintInfo("FeaturedModsButton")
				
				OpenOverlay( self, "ShieldModManager", controller )

			end, function ( element, menu, controller )
				if IsGamepad( controller ) then
					CoD.Menu.SetButtonLabel( menu, Enum[@"luibutton"][@"lui_key_xba_pscross"], @"menu/join", nil, "ui_confirm" )
					return true
				elseif IsMouseOrKeyboard( controller ) then
					CoD.Menu.SetButtonLabel( menu, Enum[@"luibutton"][@"lui_key_xba_pscross"], @"hash_0", nil, "ui_confirm" )
					return false
				else
					return false
				end
			end, false )

			FeaturedModsButton.id = "FeaturedModsButton"

			local ShieldFriendsButton = CoD.DirectorSelectButtonMiniInternal.new( f1_arg0, f1_arg1, 1, 1, -380, -50, 0.88, 0.88, 15 - 110, 55 - 110 )
			
			ShieldFriendsButton:mergeStateConditions( {
				{
					stateName = "Locked",
					condition = function ( menu, element, event )
						return Engine[@"getdvarint"](@"shield_is_offline") == 1
					end
				},
				{
					stateName = "Disabled",
					condition = function ( menu, element, event )
						return AlwaysFalse()
					end
				}
			} )
			
			ShieldFriendsButton.MiddleText:setTTF( "ttmussels_regular" )
			ShieldFriendsButton.MiddleText:setText("SHIELD FRIENDS")

			ShieldFriendsButton.MiddleTextFocus:setText("SHIELD FRIENDS")
			ShieldFriendsButton.MiddleTextFocus:setTTF( "ttmussels_regular" )

			ShieldFriendsButton:linkToElementModel( self, nil, false, function ( model )
				ShieldFriendsButton:setModel( model, f1_arg1 )
			end )
			self:addElement( ShieldFriendsButton )
			self.ShieldFriendsButton = ShieldFriendsButton

			f1_arg0:AddButtonCallbackFunction( ShieldFriendsButton, f1_arg0, Enum[@"luibutton"][@"lui_key_xba_pscross"], "ui_confirm", function ( element, menu, controller, model )
				CoD.EnhPrintInfo("ShieldFriendsButton")
				
				if Engine[@"getdvarint"](@"shield_is_offline") == 0 then
					PlaySoundAlias( "uin_paint_image_flip_toggle" )
					OpenOverlay( self, "ShieldFriendsMenu", controller )
				end

			end, function ( element, menu, controller )
				if IsGamepad( controller ) then
					CoD.Menu.SetButtonLabel( menu, Enum[@"luibutton"][@"lui_key_xba_pscross"], @"menu/join", nil, "ui_confirm" )
					return true
				elseif IsMouseOrKeyboard( controller ) then
					CoD.Menu.SetButtonLabel( menu, Enum[@"luibutton"][@"lui_key_xba_pscross"], @"hash_0", nil, "ui_confirm" )
					return false
				else
					return false
				end
			end, false )

			ShieldFriendsButton.id = "ShieldFriendsButton"

			local Shield_Nat = LUI.UIText.new( 0, 0, 385, 1500, 0.9, 0.9, 10, 30 )
			Shield_Nat:setText("Unknown Info")
			Shield_Nat:setBackingType( 2 )
			Shield_Nat:setBackingColor( 0.04, 0.81, 1 )
			Shield_Nat:setBackingAlpha( 0.01 )
			Shield_Nat:setBackingXPadding( 12 )
			Shield_Nat:setBackingYPadding( 6 )
			Shield_Nat:setTTF( "ttmussels_regular" )
			Shield_Nat:setLetterSpacing( 6 )
			Shield_Nat:setAlignment( Enum[@"hash_67A5123B654282D2"][@"hash_558C8A85F2048829"] )
			Shield_Nat:setAlignment( Enum[@"hash_67A5123B654282D2"][@"hash_3F41D595A2B0EDF3"] )
			Shield_Nat:subscribeToGlobalModel( f1_arg1, "LobbyRoot", "lobbyNatType", function ( model )
				local nattype = model:get()
				if nattype ~= nil and Engine[@"getdvarint"](@"shield_is_offline") == 0 then
					Shield_Nat:setText(ConvertToUpperString(LocalizeWithNatType(nattype)) .. " | SERVER IP: " .. Engine[@"getdvarstring"]("shield_dw_ip"))
				else
					Shield_Nat:setText("OFFLINE MODE")
				end
			end )
			self:addElement( Shield_Nat )
			self.Shield_Nat = Shield_Nat
			
			local PurchaseButton2 = nil
			
			PurchaseButton2 = CoD.PC_BnetStore_PurchaseButton.new( f1_arg0, f1_arg1, 0.5, 0.5, -272.5, 273.5, 0, 0, 829, 890 )
			PurchaseButton2:mergeStateConditions( {
				{
					stateName = "Hidden",
					condition = function ( menu, element, event )
						return HideKoreaEventButton( f1_arg1 )
					end
				},
				{
					stateName = "Disabled",
					condition = function ( menu, element, event )
						return AlwaysFalse()
					end
				}
			} )
			PurchaseButton2:setAlpha( 0 )
			PurchaseButton2.ButtonTitle:setText( LocalizeToUpperString( @"hash_648B6358827FB817" ) )
			PurchaseButton2:registerEventHandler( "gain_focus", function ( element, event )
				local f52_local0 = nil
				if element.gainFocus then
					f52_local0 = element:gainFocus( event )
				elseif element.super.gainFocus then
					f52_local0 = element.super:gainFocus( event )
				end
				CoD.Menu.UpdateButtonShownState( element, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
				return f52_local0
			end )
			f1_arg0:AddButtonCallbackFunction( PurchaseButton2, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], nil, function ( element, menu, controller, model )
				OpenOverlay( self, "PC_Korea_Event_Menu", controller )
				return true
			end, function ( element, menu, controller )
				CoD.Menu.SetButtonLabel( menu, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], @"hash_0", nil, nil )
				return false
			end, false )
			self:addElement( PurchaseButton2 )
			self.PurchaseButton2 = PurchaseButton2
			
			local f1_local19 = nil
			self.DirectorTierSkipNotification = LUI.UIElement.createFake()
			local DirectorTierSkipNotification2 = nil
			
			DirectorTierSkipNotification2 = CoD.DirectorTierSkipNotification.new( f1_arg0, f1_arg1, 0.5, 0.5, -400, 400, 0, 0, 143, 233 )
			self:addElement( DirectorTierSkipNotification2 )
			self.DirectorTierSkipNotification2 = DirectorTierSkipNotification2
			
			local IGREventButton = nil
			
			IGREventButton = CoD.PC_Korea_Event_DirectorButton.new( f1_arg0, f1_arg1, 0.5, 0.5, -225, 225, 0.5, 0.5, 293, 423 )
			IGREventButton:mergeStateConditions( {
				{
					stateName = "Hidden",
					condition = function ( menu, element, event )
						return HideKoreaEventButton( f1_arg1 )
					end
				}
			} )
			IGREventButton.SpecialEvent:setText( LocalizeToUpperString( @"hash_648B6358827FB817" ) )
			IGREventButton.EventName:setText( LocalizeToUpperString( @"hash_47CD2396EF33FB1" ) )
			IGREventButton:registerEventHandler( "gain_focus", function ( element, event )
				local f56_local0 = nil
				if element.gainFocus then
					f56_local0 = element:gainFocus( event )
				elseif element.super.gainFocus then
					f56_local0 = element.super:gainFocus( event )
				end
				CoD.Menu.UpdateButtonShownState( element, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
				return f56_local0
			end )
			f1_arg0:AddButtonCallbackFunction( IGREventButton, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], nil, function ( element, menu, controller, model )
				if IsKoreaProgressionSpecialEventActive( controller ) then
					PlaySoundAlias( "uin_toggle_generic" )
					OpenOverlay( self, "PC_Korea_Event_Menu", controller )
					return true
				elseif IsKoreaBonusXPSpecialEventActive( controller ) then
					PlaySoundAlias( "uin_toggle_generic" )
					CoD.FTUEUtility.ShowFTUESequence( self, controller, "KoreaSpecialEvent" )
					return true
				else
					
				end
			end, function ( element, menu, controller )
				if IsKoreaProgressionSpecialEventActive( controller ) then
					CoD.Menu.SetButtonLabel( menu, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], @"hash_0", nil, nil )
					return false
				elseif IsKoreaBonusXPSpecialEventActive( controller ) then
					CoD.Menu.SetButtonLabel( menu, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], @"hash_0", nil, nil )
					return false
				else
					return false
				end
			end, false )
			self:addElement( IGREventButton )
			self.IGREventButton = IGREventButton
			
			local pckeyboardNavigationRedirector = nil
			
			pckeyboardNavigationRedirector = CoD.emptyFocusable.new( f1_arg0, f1_arg1, 0.7, 1, 0, 0, 0.74, 0.79, -35, -35 )
			self:addElement( pckeyboardNavigationRedirector )
			self.pckeyboardNavigationRedirector = pckeyboardNavigationRedirector
			
			self:mergeStateConditions( {
				{
					stateName = "OnlineOnlyDemo",
					condition = function ( menu, element, event )
						return IsLobbyNetworkModeLive() and CoD.DirectorUtility.IsOnlineOnlyDemo()
					end
				},
				{
					stateName = "OnlineWithArena",
					condition = function ( menu, element, event )
						return IsLobbyNetworkModeLive() and CoD.DirectorUtility.HasArena()
					end
				},
				{
					stateName = "Online",
					condition = function ( menu, element, event )
						return IsLobbyNetworkModeLive()
					end
				},
				{
					stateName = "OfflineRevealEvent",
					condition = function ( menu, element, event )
						return IsLobbyNetworkModeLAN() and CoD.DirectorUtility.IsOfflineOnlyDemo()
					end
				},
				{
					stateName = "OfflineWithArena",
					condition = function ( menu, element, event )
						return IsLobbyNetworkModeLAN() and CoD.DirectorUtility.HasArena()
					end
				},
				{
					stateName = "Offline",
					condition = function ( menu, element, event )
						return IsLobbyNetworkModeLAN()
					end
				}
			} )
			local f1_local23 = self
			local f1_local24 = self.subscribeToModel
			local f1_local25 = Engine[@"hash_78DF2E5447F384B9"]()
			f1_local24( f1_local23, f1_local25["lobbyRoot.lobbyNav"], function ( f65_arg0 )
				f1_arg0:updateElementState( self, {
					name = "model_validation",
					menu = f1_arg0,
					controller = f1_arg1,
					modelValue = f65_arg0:get(),
					modelName = "lobbyRoot.lobbyNav"
				} )
			end, false )
			LUI.OverrideFunction_CallOriginalFirst( self, "setState", function ( element, controller, f66_arg2, f66_arg3, f66_arg4 )
				if IsPC() then
					ForceCheckDefaultPCFocus( element, f1_arg0, controller )
				end
			end )
			LUI.OverrideFunction_CallOriginalFirst( self, "childFocusLost", function ( element )
				CoD.DirectorUtility.UpdateDescriptionTextFromSelectMenu( f1_arg1, element )
			end )
			if CoD.isPC then
				pckeyboardNavigationRedirector2.id = "pckeyboardNavigationRedirector2"
			end
			ButtonListLeft.id = "ButtonListLeft"
			ButtonListRight.id = "ButtonListRight"
			ButtonFeatured.id = "ButtonFeatured"
			ButtonModes.id = "ButtonModes"
			SafeAreaContainer.id = "SafeAreaContainer"
			if CoD.isPC then
				IGRPerksDirectorButton.id = "IGRPerksDirectorButton"
			end
			if CoD.isPC then
				PurchaseButton2.id = "PurchaseButton2"
			end
			if CoD.isPC then
				IGREventButton.id = "IGREventButton"
			end
			if CoD.isPC then
				pckeyboardNavigationRedirector.id = "pckeyboardNavigationRedirector"
			end
			self.__defaultFocus = ButtonFeatured
			LUI.OverrideFunction_CallOriginalSecond( self, "close", self.__onClose )
			if PostLoadFunc then
				PostLoadFunc( self, f1_arg1, f1_arg0 )
			end
			f1_local24 = self
			CoD.BaseUtility.SetUpPassCustomFunctionToChild( self, self.SafeAreaContainer, f1_arg1, f1_arg0, "_activateFeaturedWidget" )
			CoD.CraftUtility.ValidateEquippedUGC( f1_arg1 )
			CoD.WZUtility.PlayWZTrialVideo( f1_arg0, f1_arg1 )
			f1_local24 = pckeyboardNavigationRedirector2
			if IsPC() then
				CoD.PCUtility.SetAsRedirectItem( f1_local24 )
				CoD.BaseUtility.SetCustomNavDirection( CoD.BaseUtility.NavigationDirection.down, f1_local24, self.Loadouts )
			end
			f1_local24 = pckeyboardNavigationRedirector
			if IsPC() then
				CoD.PCUtility.SetAsRedirectItem( f1_local24 )
				CoD.BaseUtility.SetCustomNavDirection( CoD.BaseUtility.NavigationDirection.up, f1_local24, self.Loadouts )
			end

			--CoD.EnhPrintInfo("Loaded Alt Director Select....")

			return self
		end

		CoD.directorSelect.__resetProperties = function ( f68_arg0 )
			f68_arg0.Header:completeAnimation()
			f68_arg0.HeaderPC:completeAnimation()
			f68_arg0.ButtonFeatured:completeAnimation()
			f68_arg0.ButtonModes:completeAnimation()
			--f68_arg0.FramingCornerBrackets:completeAnimation()
			f68_arg0.ButtonListRight:completeAnimation()
			f68_arg0.ButtonListLeft:completeAnimation()
			--f68_arg0.DotLineTop:completeAnimation()
			--f68_arg0.DotLineBottom:completeAnimation()
			f68_arg0.Header:setLeftRight( 0, 0, 407, 1050 )
			f68_arg0.Header:setTopBottom( 0, 0, 146, 246 )
			f68_arg0.Header:setAlpha( 0 )
			f68_arg0.HeaderPC:setLeftRight( 0.5, 0.5, -553, 81 )
			f68_arg0.HeaderPC:setAlpha( 0 )
			f68_arg0.ButtonFeatured:setLeftRight( 0, 0, 50, 150 )
			f68_arg0.ButtonFeatured:setAlpha( 1 )
			f68_arg0.ButtonFeatured:setAutoScaleContent( false )
			f68_arg0.ButtonFeatured:setWidgetType( CoD.DirectorSelectButton )
			--f68_arg0.ButtonFeatured:setHorizontalCount( 3 )
			--f68_arg0.ButtonFeatured:setVerticalCount( 1 )
			f68_arg0.ButtonFeatured:setSpacing( 25 )
			f68_arg0.ButtonFeatured:setFirstElementXOffset( 0 )
			f68_arg0.ButtonFeatured:setFirstElementYOffset( 0 )
			f68_arg0.ButtonFeatured:setBalanceGridRows( false )
			--f68_arg0.ButtonModes:setLeftRight( 0.5, 0.5, -475, 475 )
			f68_arg0.ButtonModes:setAutoScaleContent( false )
			f68_arg0.ButtonModes:setWidgetType( CoD.DirectorSelectButtonGameType )
			--f68_arg0.ButtonModes:setHorizontalCount( 3 )
			--f68_arg0.ButtonModes:setVerticalCount( 1 )
			f68_arg0.ButtonModes:setSpacing( 25 )
			f68_arg0.ButtonModes:setFirstElementXOffset( 0 )
			f68_arg0.ButtonModes:setFirstElementYOffset( 0 )
			f68_arg0.ButtonModes:setBalanceGridRows( false )
			--f68_arg0.FramingCornerBrackets:setLeftRight( 0.5, 0.5, -516.5, 516.5 )
			--f68_arg0.FramingCornerBrackets:setTopBottom( 0, 0, 222, 796 )
			f68_arg0.ButtonListRight:setLeftRight( 1, 1, -50, 150 )
			f68_arg0.ButtonListRight:setTopBottom( 0, 0, 265, 510 )
			--f68_arg0.ButtonListLeft:setLeftRight( 0.5, 0.5, -725, -513 )
			--f68_arg0.DotLineTop:setLeftRight( 0.5, 0.5, -474.5, 474.5 )
			--f68_arg0.DotLineBottom:setLeftRight( 0.5, 0.5, -474.5, 474.5 )
		end

		CoD.directorSelect.__clipsPerState = {
			DefaultState = {
				DefaultClip = function ( f69_arg0, f69_arg1 )
					f69_arg0:__resetProperties()
					f69_arg0:setupElementClipCounter( 0 )
				end
			},
			OnlineOnlyDemo = {
				DefaultClip = function ( f70_arg0, f70_arg1 )
					f70_arg0:__resetProperties()
					f70_arg0:setupElementClipCounter( 1 )
					f70_arg0.Header:completeAnimation()
					f70_arg0.Header:setAlpha( 0 )
					f70_arg0.clipFinished( f70_arg0.Header )
					f70_arg0.HeaderPC:completeAnimation()
					f70_arg0.HeaderPC:setAlpha( 0 )
					f70_arg0.clipFinished( f70_arg0.HeaderPC )
				end
			},
			OnlineWithArena = {
				DefaultClip = function ( f71_arg0, f71_arg1 )
					f71_arg0:__resetProperties()
					f71_arg0:setupElementClipCounter( 8 )
					--f71_arg0.FramingCornerBrackets:completeAnimation()
					--f71_arg0.FramingCornerBrackets:setLeftRight( 0.5, 0.5, -691.5, 689.5 )
					--f71_arg0.FramingCornerBrackets:setTopBottom( 0, 0, 224, 796 )
					--f71_arg0.clipFinished( f71_arg0.FramingCornerBrackets )
					--f71_arg0.DotLineBottom:completeAnimation()
					--f71_arg0.DotLineBottom:setLeftRight( 0.5, 0.5, -638, 638 )
					--f71_arg0.clipFinished( f71_arg0.DotLineBottom )
					--f71_arg0.DotLineTop:completeAnimation()
					--f71_arg0.DotLineTop:setLeftRight( 0.5, 0.5, -638, 638 )
					--f71_arg0.clipFinished( f71_arg0.DotLineTop )
					f71_arg0.Header:completeAnimation()
					f71_arg0.Header:setLeftRight( 0, 0, 186, 829 )
					f71_arg0.clipFinished( f71_arg0.Header )
					f71_arg0.HeaderPC:completeAnimation()
					f71_arg0.HeaderPC:setLeftRight( 0.5, 0.5, -765, -131 )
					f71_arg0.clipFinished( f71_arg0.HeaderPC )
					--f71_arg0.ButtonListLeft:completeAnimation()
					--f71_arg0.ButtonListLeft:setLeftRight( 0.5, 0.5, -887, -675 )
					--f71_arg0.clipFinished( f71_arg0.ButtonListLeft )
					f71_arg0.ButtonListRight:completeAnimation()
					f71_arg0.ButtonListRight:setLeftRight( 1, 1, -50, 150 )
					f71_arg0.ButtonListRight:setTopBottom( 0, 0, 265, 510 )
					f71_arg0.clipFinished( f71_arg0.ButtonListRight )
					f71_arg0.ButtonFeatured:completeAnimation()
					f71_arg0.ButtonFeatured:setLeftRight( 0, 0, 50, 150 )
					f71_arg0.ButtonFeatured:setAutoScaleContent( false )
					f71_arg0.ButtonFeatured:setWidgetType( CoD.DirectorSelectButton )
					--f71_arg0.ButtonFeatured:setHorizontalCount( 4 )
					--f71_arg0.ButtonFeatured:setVerticalCount( 1 )
					f71_arg0.ButtonFeatured:setSpacing( 25 )
					f71_arg0.ButtonFeatured:setFirstElementXOffset( 0 )
					f71_arg0.ButtonFeatured:setFirstElementYOffset( 0 )
					f71_arg0.ButtonFeatured:setBalanceGridRows( false )
					f71_arg0.clipFinished( f71_arg0.ButtonFeatured )
					f71_arg0.ButtonModes:completeAnimation()
					--f71_arg0.ButtonModes:setLeftRight( 0.5, 0.5, -637.5, 637.5 )
					f71_arg0.ButtonModes:setAutoScaleContent( false )
					f71_arg0.ButtonModes:setWidgetType( CoD.DirectorSelectButtonGameType )
					--f71_arg0.ButtonModes:setHorizontalCount( 4 )
					--f71_arg0.ButtonModes:setVerticalCount( 1 )
					f71_arg0.ButtonModes:setSpacing( 25 )
					f71_arg0.ButtonModes:setFirstElementXOffset( 0 )
					f71_arg0.ButtonModes:setFirstElementYOffset( 0 )
					f71_arg0.ButtonModes:setBalanceGridRows( false )
					f71_arg0.clipFinished( f71_arg0.ButtonModes )
				end
			},
			Online = {
				DefaultClip = function ( f72_arg0, f72_arg1 )
					f72_arg0:__resetProperties()
					f72_arg0:setupElementClipCounter( 2 )
					f72_arg0.Header:completeAnimation()
					f72_arg0.Header:setAlpha( 0 )
					f72_arg0.clipFinished( f72_arg0.Header )
					f72_arg0.HeaderPC:completeAnimation()
					f72_arg0.HeaderPC:setAlpha( 0 )
					f72_arg0.clipFinished( f72_arg0.HeaderPC )
					f72_arg0.ButtonFeatured:completeAnimation()
					f72_arg0.ButtonFeatured:setAlpha( 1 )
					f72_arg0.clipFinished( f72_arg0.ButtonFeatured )
				end
			},
			OfflineRevealEvent = {
				DefaultClip = function ( f73_arg0, f73_arg1 )
					f73_arg0:__resetProperties()
					f73_arg0:setupElementClipCounter( 1 )
					f73_arg0.Header:completeAnimation()
					f73_arg0.Header:setLeftRight( 0, 0, 360, 1003 )
					f73_arg0.Header:setTopBottom( 0, 0, 183, 283 )
					f73_arg0.Header:setAlpha( 0 )
					f73_arg0.clipFinished( f73_arg0.Header )
					f73_arg0.HeaderPC:completeAnimation()
					f73_arg0.HeaderPC:setAlpha( 1 )
					f73_arg0.clipFinished( f73_arg0.HeaderPC )
				end
			},
			OfflineWithArena = {
				DefaultClip = function ( f74_arg0, f74_arg1 )
					f74_arg0:__resetProperties()
					f74_arg0:setupElementClipCounter( 8 )
					--f74_arg0.FramingCornerBrackets:completeAnimation()
					--f74_arg0.FramingCornerBrackets:setLeftRight( 0.5, 0.5, -691.5, 689.5 )
					--f74_arg0.FramingCornerBrackets:setTopBottom( 0, 0, 224, 796 )
					--f74_arg0.clipFinished( f74_arg0.FramingCornerBrackets )
					--f74_arg0.DotLineBottom:completeAnimation()
					--f74_arg0.DotLineBottom:setLeftRight( 0.5, 0.5, -637.5, 610.5 )
					--f74_arg0.clipFinished( f74_arg0.DotLineBottom )
					--f74_arg0.DotLineTop:completeAnimation()
					--f74_arg0.DotLineTop:setLeftRight( 0.5, 0.5, -637, 637 )
					--f74_arg0.clipFinished( f74_arg0.DotLineTop )
					f74_arg0.Header:completeAnimation()
					f74_arg0.Header:setLeftRight( 0, 0, 186, 829 )
					f74_arg0.clipFinished( f74_arg0.Header )
					f74_arg0.HeaderPC:completeAnimation()
					f74_arg0.HeaderPC:setLeftRight( 0.5, 0.5, -765, -131 )
					f74_arg0.clipFinished( f74_arg0.HeaderPC )
					--f74_arg0.ButtonListLeft:completeAnimation()
					--f74_arg0.ButtonListLeft:setLeftRight( 0.5, 0.5, -887, -675 )
					--f74_arg0.clipFinished( f74_arg0.ButtonListLeft )
					f74_arg0.ButtonListRight:completeAnimation()
					f74_arg0.ButtonListRight:setLeftRight( 1, 1, -50, 150 )
					f74_arg0.ButtonListRight:setTopBottom( 0, 0, 265, 510 )
					f74_arg0.clipFinished( f74_arg0.ButtonListRight )
					f74_arg0.ButtonFeatured:completeAnimation()
					f74_arg0.ButtonFeatured:setLeftRight( 0, 0, 50, 150 )
					f74_arg0.ButtonFeatured:setAutoScaleContent( false )
					f74_arg0.ButtonFeatured:setWidgetType( CoD.DirectorSelectButton )
					--f74_arg0.ButtonFeatured:setHorizontalCount( 4 )
					--f74_arg0.ButtonFeatured:setVerticalCount( 1 )
					f74_arg0.ButtonFeatured:setSpacing( 25 )
					f74_arg0.ButtonFeatured:setFirstElementXOffset( 0 )
					f74_arg0.ButtonFeatured:setFirstElementYOffset( 0 )
					f74_arg0.ButtonFeatured:setBalanceGridRows( false )
					f74_arg0.clipFinished( f74_arg0.ButtonFeatured )
					f74_arg0.ButtonModes:completeAnimation()
					--f74_arg0.ButtonModes:setLeftRight( 0.5, 0.5, -637.5, 637.5 )
					f74_arg0.ButtonModes:setAutoScaleContent( false )
					f74_arg0.ButtonModes:setWidgetType( CoD.DirectorSelectButtonGameType )
					--f74_arg0.ButtonModes:setHorizontalCount( 4 )
					--f74_arg0.ButtonModes:setVerticalCount( 1 )
					f74_arg0.ButtonModes:setSpacing( 25 )
					f74_arg0.ButtonModes:setFirstElementXOffset( 0 )
					f74_arg0.ButtonModes:setFirstElementYOffset( 0 )
					f74_arg0.ButtonModes:setBalanceGridRows( false )
					f74_arg0.clipFinished( f74_arg0.ButtonModes )
				end
			},
			Offline = {
				DefaultClip = function ( f75_arg0, f75_arg1 )
					f75_arg0:__resetProperties()
					f75_arg0:setupElementClipCounter( 1 )
					f75_arg0.Header:completeAnimation()
					f75_arg0.Header:setLeftRight( 0, 0, 360, 1003 )
					f75_arg0.Header:setTopBottom( 0, 0, 183, 283 )
					f75_arg0.Header:setAlpha( 0 )
					f75_arg0.clipFinished( f75_arg0.Header )
					f75_arg0.HeaderPC:completeAnimation()
					f75_arg0.HeaderPC:setAlpha( 1 )
					f75_arg0.clipFinished( f75_arg0.HeaderPC )
				end
			}
		}

		CoD.directorSelect.__onClose = function ( f76_arg0 )
			--f76_arg0.FramingCornerBrackets:close()
			f76_arg0.Header:close()
			f76_arg0.HeaderPC:close()
			f76_arg0.background_modes:close()
			f76_arg0.background_modes_2:close()
			f76_arg0.DirectorLeaderActivitySelect:close()
			f76_arg0.pckeyboardNavigationRedirector2:close()
			--f76_arg0.ButtonListLeft:close()
			f76_arg0.ButtonListRight:close()
			f76_arg0.ButtonFeatured:close()
			f76_arg0.ButtonModes:close()
			f76_arg0.SafeAreaContainer:close()
			f76_arg0.IGRPerksDirectorButton:close()
			f76_arg0.selectionDescription:close()
			f76_arg0.PurchaseButton2:close()
			f76_arg0.PathNotesButton:close()
			f76_arg0.sizePathNotesButton:close()
			f76_arg0.Shield_Nat:close()
			f76_arg0.DirectorTierSkipNotification:close()
			f76_arg0.DirectorTierSkipNotification2:close()
			f76_arg0.IGREventButton:close()
			f76_arg0.pckeyboardNavigationRedirector:close()
		end
	end
end

CoD.DirectorSelectOverride()