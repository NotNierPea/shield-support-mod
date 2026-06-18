--[[
		.\hksc.exe ".\Lua\ShieldOptions.Lua" -o "C:\Program Files (x86)\Call of Duty Black Ops 4\project-bo4\mods\T8ShieldSupport\Lua\ShieldOptions.luac"
]]

---------------------------

CoD.ShieldInitLuaFile()

---------------------------

-- dvars
-- username
Engine[@"exec"](Engine[@"getprimarycontroller"](), "readjson shield_username identity name string")

---------------------------

local function Enh_WidgetSelectorShieldFunc( f49_arg0, f49_arg1, f49_arg2 )
	return CoD.CraftActionSliderEnhShield
end

local function Enh_GetEditModeActionsShield( f53_arg0, f53_arg1 )
	local max_clients_com_shield = Engine[@"getmodel"]( Engine[@"getmodelforcontroller"]( f53_arg0 ), "max_clients_com_shield" )

	if max_clients_com_shield == nil then
		max_clients_com_shield = Engine[@"createmodel"]( Engine[@"getmodelforcontroller"]( f53_arg0 ), "max_clients_com_shield" )
	end
	
	max_clients_com_shield:set(Engine[@"getdvarint"]("shield_com_clients"))

	local f53_local0 = {}

	local f53_local4 = {}
	local f53_local5 = {
		actionName = @"shield/client_num_helper",
		widgetType = "slider",
		perControllerValueModel = "max_clients_com_shield",
		lowValue = 0,
		highValue = 127
	}
	local f53_local6 = Engine[@"getmodelforcontroller"]( f53_arg0 )
	f53_local5.currentValue = 0
	f53_local4.models = f53_local5
	f53_local4.properties = {
		updateAction = function ( f60_arg0, f60_arg1, f60_arg2, f60_arg3 )
			local GetNum = math.floor((f53_local5.highValue - f53_local5.lowValue) * f60_arg2)

			Engine[@"setdvar"]("shield_com_clients", GetNum)

			Engine[@"setlobbymaxclients"](Enum[@"lobbytype"][@"lobby_type_game"], GetNum) 
			Engine[@"setlobbymaxclients"](Enum[@"lobbytype"][@"lobby_type_private"], GetNum)
			Engine[@"setlobbymaxclients"](Engine[@"getprimarycontroller"](), GetNum)
			Dvar[@"hash_4FF45B41C6046F8"]:set(GetNum)
			Engine[@"setmodelvalue"](Engine[@"createmodel"]( Engine[@"createmodel"]( Engine[@"getglobalmodel"](), "PartyPrivacy" ), "maxPlayers" ), GetNum)
		end
	}

	table.insert( f53_local0, f53_local4 )

	return f53_local0
end

DataSources.EnhActionsShieldPC = DataSourceHelpers.ListSetup( "PC.CraftActionsPC", function ( f50_arg0, f50_arg1 )
	return Enh_GetEditModeActionsShield( f50_arg0, f50_arg1.menu )
end, false, {
	getWidgetTypeForItem = Enh_WidgetSelectorShieldFunc
} )

-- Shield's Options Tab
DataSources.ShieldOptionsTabs = DataSourceHelpers.ListSetup( "ShieldOptionsTabs", function ( f3_arg0, f3_arg1 )
	local f3_local0 = {
		{
			models = {
				name = @"shield/settings_tab",
				filter = "shield_options"
			}
		}
	}

	return f3_local0
end, true )

-- prestige master
CoD.OverlayUtility.Overlays.PrestigeMasterActivated = {
	menuName = "SystemOverlay_Compact",
	postCreateStep = function ( f155_arg0, f155_arg1 )
		f155_arg0.anyControllerAllowed = true
	end,
	title = @"menu/notice",
	description = @"shield/prestige_master",
	categoryType = CoD.OverlayUtility.OverlayTypes.Connection,
	[CoD.OverlayUtility.GoBackPropertyName] = CoD.OverlayUtility.DefaultGoBack,
	listDatasource = function ( f156_arg0 )
		DataSources.PrestigeMasterActivated = DataSourceHelpers.ListSetup( "PrestigeMasterActivated", function ( f157_arg0 )
			return {
				{
					models = {
						displayText = Engine[@"hash_4F9F1239CFD921FE"]( @"menu/ok" )
					},
					properties = {
						action = function ( f158_arg0, f158_arg1, f158_arg2, f158_arg3, f158_arg4 )
							GoBack( f158_arg4, f158_arg2 )
						end
					}
				}
			}
		end, true, nil )
		return "PrestigeMasterActivated"
	end
}

CoD.ShieldOptionsReload = function()
	CoD.DirectorUtility.IsNumClientsExceeded = function ( f264_arg0 )
		local GetNum = Engine[@"getdvarint"]("shield_com_clients")

		if GetNum >= 1 then
			return false
		end

		if IsLobbyNetworkModeLive() then
			local f264_local0 = Engine[@"getglobalmodel"]()
			f264_local0 = f264_local0:create( "lobbyRoot.playlistId" )
			local f264_local1 = Engine[@"getplaylistinfobyid"]( f264_local0:get() )
			local f264_local2 = Engine[@"getglobalmodel"]()
			if f264_local1 and f264_local2.lobbyRoot.lobbyMainMode:get() == f264_local1.mainMode then
				local f264_local3 = Engine[@"getglobalmodel"]()
				f264_local3 = f264_local3:create( "lobbyRoot.lobbyList.playerCount" )
				if f264_local1.maxPartySize < f264_local3:get() then
					return true
				end
			end
		end
		return false
	end

	-- reapply party settings
	local GetNum = Engine[@"getdvarint"]("shield_com_clients")

	if GetNum >= 1 then
		Engine[@"setdvar"]("shield_com_clients", GetNum)

		Engine[@"setlobbymaxclients"](Enum[@"lobbytype"][@"lobby_type_game"], GetNum) 
		Engine[@"setlobbymaxclients"](Enum[@"lobbytype"][@"lobby_type_private"], GetNum)
		Engine[@"setlobbymaxclients"](Engine[@"getprimarycontroller"](), GetNum)
		Dvar[@"hash_4FF45B41C6046F8"]:set(GetNum)
		Engine[@"setmodelvalue"](Engine[@"createmodel"]( Engine[@"createmodel"]( Engine[@"getglobalmodel"](), "PartyPrivacy" ), "maxPlayers" ), GetNum)
	end
end

---------------------------

-- Shield Options Menu
CoD.ShieldOptionsMenu = InheritFrom( CoD.Menu )
LUI.createMenu.ShieldOptionsMenu = function ( f1_arg0, f1_arg1 )
	local self = CoD.Menu.NewForUIEditor( "ShieldOptionsMenu", f1_arg0 )
	local f1_local1 = self
	self:setClass( CoD.ShieldOptionsMenu )
	self.soundSet = "default"
	self:setOwner( f1_arg0 )
	self:setLeftRight( 0, 1, 0, 0 )
	self:setTopBottom( 0, 1, 0, 0 )
	self:playSound( "menu_open", f1_arg0 )
	self.anyChildUsesUpdateState = true
	
	local Background = CoD.StartMenuOptionsBackground.new( f1_local1, f1_arg0, 0, 1, 0, 0, 0, 1, 0, 0 )
	self:addElement( Background )
	self.Background = Background
	
	local FooterContainerFrontendRight = nil
	
	FooterContainerFrontendRight = CoD.FooterContainer_Frontend_Right.new( f1_local1, f1_arg0, 0.5, 0.5, -960, 960, 1, 1, -48, 0 )
	self:addElement( FooterContainerFrontendRight )
	self.FooterContainerFrontendRight = FooterContainerFrontendRight
	
	-- removed, breaks glowing on pc
	--[[
	local FooterContainerFrontendRight2 = CoD.Fo..., -48, 0 )
	]]

	local HeaderPixelGridTiledBackingL = LUI.UIImage.new( 0, 0, 0, 4000, 0.61, 0.61, -160.5, -120.5 )
	HeaderPixelGridTiledBackingL:setAlpha( 0.25 )
	HeaderPixelGridTiledBackingL:setImage( RegisterImage( @"hash_1311E811A3183347" ) )
	HeaderPixelGridTiledBackingL:setMaterial( LUI.UIImage.GetCachedMaterial( @"hash_16CBE95C250C6D15" ) )
	HeaderPixelGridTiledBackingL:setShaderVector( 0, 0, 0, 0, 0 )
	HeaderPixelGridTiledBackingL:setupNineSliceShader( 128, 128 )
	self:addElement( HeaderPixelGridTiledBackingL )
	self.HeaderPixelGridTiledBackingL = HeaderPixelGridTiledBackingL
	
	local HeaderPixelGridTiledBackingR = LUI.UIImage.new( 0, 0, 0, 4000, 0.27, 0.27, -160.5, -120.5 )
	HeaderPixelGridTiledBackingR:setAlpha( 0.15 )
	HeaderPixelGridTiledBackingR:setImage( RegisterImage( @"hash_1311E811A3183347" ) )
	HeaderPixelGridTiledBackingR:setMaterial( LUI.UIImage.GetCachedMaterial( @"hash_16CBE95C250C6D15" ) )
	HeaderPixelGridTiledBackingR:setShaderVector( 0, 0, 0, 0, 0 )
	HeaderPixelGridTiledBackingR:setupNineSliceShader( 128, 128 )
	self:addElement( HeaderPixelGridTiledBackingR )
	self.HeaderPixelGridTiledBackingR = HeaderPixelGridTiledBackingR
	
	--[[
	local CornerPipR = LUI.UIImage.new( 0, 0, 1749.5, 1765.5, 0, 0, 930, 946 )
	CornerPipR:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )
	CornerPipR:setAlpha( 0.25 )
	CornerPipR:setImage( RegisterImage( @"hash_28DC834094E7A02C" ) )
	self:addElement( CornerPipR )
	self.CornerPipR = CornerPipR
	
	local CornerPipL = LUI.UIImage.new( 0, 0, 155, 171, 0, 0, 930, 946 )
	CornerPipL:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )
	CornerPipL:setAlpha( 0.25 )
	CornerPipL:setYRot( 180 )
	CornerPipL:setImage( RegisterImage( @"hash_28DC834094E7A02C" ) )
	self:addElement( CornerPipL )
	self.CornerPipL = CornerPipL
	
	local TabbedScoreboardFuiBox = CoD.TabbedScoreboardFuiBox.new( f1_local1, f1_arg0, 0, 0, 1645.5, 1757.5, 0, 0, 954, 970 )
	self:addElement( TabbedScoreboardFuiBox )
	self.TabbedScoreboardFuiBox = TabbedScoreboardFuiBox
	]]

	local ShieldOptionsMenu_SafeAreaFront = CoD.ShieldOptionsMenu_SafeAreaFront.new( f1_local1, f1_arg0, 0, 0, 0, 1920, 0, 0, 0, 1080 )
	ShieldOptionsMenu_SafeAreaFront:registerEventHandler( "menu_loaded", function ( element, event )
		local f3_local0 = nil
		if element.menuLoaded then
			f3_local0 = element:menuLoaded( event )
		elseif element.super.menuLoaded then
			f3_local0 = element.super:menuLoaded( event )
		end
		if not IsPC() then
			SizeToSafeArea( element, f1_arg0 )
		end
		if not f3_local0 then
			f3_local0 = element:dispatchEventToChildren( event )
		end
		return f3_local0
	end )
	self:addElement( ShieldOptionsMenu_SafeAreaFront )
	self.ShieldOptionsMenu_SafeAreaFront = ShieldOptionsMenu_SafeAreaFront

	f1_local1:AddButtonCallbackFunction( self, f1_arg0, Enum[@"hash_3DD78803F918E9D"][@"hash_1805EFA15E9E7E5A"], nil, function ( element, menu, controller, model )
		GoBack( self, controller )
		return true
	end, function ( element, menu, controller )
		CoD.Menu.SetButtonLabel( menu, Enum[@"hash_3DD78803F918E9D"][@"hash_1805EFA15E9E7E5A"], @"hash_6A4032FB2AAB69F2", nil, nil )
		return true
	end, false )

	FooterContainerFrontendRight:setModel( self.buttonModel, f1_arg0 )
	FooterContainerFrontendRight.id = "FooterContainerFrontendRight"

	self:processEvent( {
		name = "menu_loaded",
		controller = f1_arg0
	} )

	LUI.OverrideFunction_CallOriginalSecond( self, "close", self.__onClose )
	
	if PostLoadFunc then
		PostLoadFunc( self, f1_arg0 )
	end
	
	--MenuHidesFreeCursor( f1_local1, f1_arg0 )
	CoD.EnhPrintInfo("Called", "Shield's Unlock Options")

	SizeToSafeArea(ShieldOptionsMenu_SafeAreaFront, f1_arg0)

	return self
end

CoD.ShieldOptionsMenu.__onClose = function ( f8_arg0 )
	-- adding on close to everything in lua menu i make is important
	-- its mostly because to avoid element pool being fucked

	f8_arg0.Background:close()
	f8_arg0.FooterContainerFrontendRight:close()
	f8_arg0.ShieldOptionsMenu_SafeAreaFront:close()

	f8_arg0.HeaderPixelGridTiledBackingL:close()
	f8_arg0.HeaderPixelGridTiledBackingR:close()
end

CoD.ShieldOptionsMenu_SafeAreaFront = InheritFrom( LUI.UIElement )
CoD.ShieldOptionsMenu_SafeAreaFront.__defaultWidth = 1920
CoD.ShieldOptionsMenu_SafeAreaFront.__defaultHeight = 1080
CoD.ShieldOptionsMenu_SafeAreaFront.new = function ( f1_arg0, f1_arg1, f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	local self = LUI.UIElement.new( f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	self:setClass( CoD.ShieldOptionsMenu_SafeAreaFront )
	self.id = "ShieldOptionsMenu_SafeAreaFront"
	self.soundSet = "none"
	self.onlyChildrenFocusable = true
	self.anyChildUsesUpdateState = true
	
	local TabBacking = CoD.CommonTabBarBacking.new( f1_arg0, f1_arg1, -0.1, 1.1, 0, 0, 0, 0, 52, 89 )
	TabBacking.TabBackingBlur:setAlpha( 0 )
	self:addElement( TabBacking )
	self.TabBacking = TabBacking
	
	local CommonHeader = CoD.CommonHeader.new( f1_arg0, f1_arg1, 0, 1, 0, 0, 0, 0, 0, 67 )
	CommonHeader.subtitle.StageTitle:setText("^2Shield Options")
	CommonHeader.subtitle.subtitle:setText("^3Modify Username, Unlock Options and Rank")
	self:addElement( CommonHeader )
	self.CommonHeader = CommonHeader

	local actionsListPCEnh = LUI.UIList.new( f1_arg0, f1_arg1, 0, 0, nil, false, false, false, false )
	actionsListPCEnh:setLeftRight( 0.50, 0.50, -695.77 + 10, -530.77 + 10 )
	actionsListPCEnh:setTopBottom( 0.50, 0.50, 295.26 - 80, 391.26 - 80 )
	actionsListPCEnh:setAlpha( 1 )
	actionsListPCEnh:setWidgetType( CoD.CraftActionHeaderEnhShield )
	actionsListPCEnh:setVerticalCount( 15 )
	actionsListPCEnh:setSpacing( 0 )
	actionsListPCEnh:setDataSource( "EnhActionsShieldPC" )
	self:addElement( actionsListPCEnh )
	self.actionsListPCEnh = actionsListPCEnh

	actionsListPCEnh.id = "actionsListPCEnh"

	--LUI_DebugElement(f1_arg0, f1_arg1, self, actionsListPCEnh, "actionsListPCEnh", 10)

	local actionsListPCEnhHint = LUI.UIText.new( 0.50, 0.50, -789.26 + 10, -143.26 + 10, 0.50, 0.50, 386.76 - 80, 406.76 - 80 )
	actionsListPCEnhHint:setText("Sets your party/engine player limit, for zombies 4+ players, you need to use the Enhancement Mod for fixes/improvments and better gameplay.")
	actionsListPCEnhHint:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )
	actionsListPCEnhHint:setTTF("notosans_bold")
	actionsListPCEnhHint:setBackingType( 2 )
	actionsListPCEnhHint:setBackingColor( 0.04, 0.81, 1 )
	actionsListPCEnhHint:setBackingAlpha( 0.01 )
	actionsListPCEnhHint:setBackingXPadding( 12 )
	actionsListPCEnhHint:setBackingYPadding( 6 )
	actionsListPCEnhHint:setAlignment( Enum[@"luialignment"][@"lui_alignment_left"] )
	actionsListPCEnhHint:setAlignment( Enum[@"luialignment"][@"lui_alignment_top"] )
	self:addElement( actionsListPCEnhHint )
	self.actionsListPCEnhHint = actionsListPCEnhHint

	--LUI_DebugElement(f1_arg0, f1_arg1, self, actionsListPCEnhHint, "actionsListPCEnhHint", 10)

	local ShieldSettingsTabs = CoD.Common_Tabbar_Center.new( f1_arg0, f1_arg1, 0.5, 0.5, -100.5, 100.5, 0, 0, 52.5 - 15, 113.5 - 15 )

	local f1_local4 = ShieldSettingsTabs
	local HeaderStripe = ShieldSettingsTabs.subscribeToModel
	local f1_local6 = Engine[@"hash_78DF2E5447F384B9"]()
	HeaderStripe( f1_local4, f1_local6["lobbyRoot.lobbyNav"], function ( f3_arg0 )
		f1_arg0:updateElementState( ShieldSettingsTabs, {
			name = "model_validation",
			menu = f1_arg0,
			controller = f1_arg1,
			modelValue = f3_arg0:get(),
			modelName = "lobbyRoot.lobbyNav"
		} )
	end, false )

	ShieldSettingsTabs.Tabs.grid:setDataSource( "ShieldOptionsTabs" )
	ShieldSettingsTabs:registerEventHandler( "grid_item_changed", function ( element, event )
		local f2_local0 = nil
		UpdateAllMenuButtonPrompts( f1_arg0, f1_arg1 )
		CloseContextualMenu( f1_arg0, f1_arg1 )
		return f2_local0
	end )
	self:addElement( ShieldSettingsTabs )
	self.ShieldSettingsTabs = ShieldSettingsTabs
	
	HeaderStripe = CoD.header_container_frontend.new( f1_arg0, f1_arg1, 0, 1, 0, 0, 0, 0, 0, 42 )
	self:addElement( HeaderStripe )
	self.HeaderStripe = HeaderStripe
	
	-- Name Edit
	local NameEditBox = CoD.Shield_NameEditBox.new( f1_arg0, f1_arg1, 0.5, 0.5, -20 - 750, 350 - 750, 0.5, 0.5, 100 - 400, 150 - 400 )
	NameEditBox:linkToElementModel( self, nil, false, function ( model )
		NameEditBox:setModel( model, f1_arg1 )
	end )
	NameEditBox.TextBox:setLeftRight(0, 0, 20 + 110, 320 + 110)
	NameEditBox.RankHighlight:setText("^2Set Username: ")
	self:addElement( NameEditBox )
	self.NameEditBox = NameEditBox

	-- prevent element pool being fucked
	local NameEditBoxModel = Engine[@"getmodel"]( Engine[@"getmodelforcontroller"]( f1_arg1 ), "Shield_Name" )

	if NameEditBoxModel == nil then
		NameEditBoxModel = Engine[@"createmodel"]( Engine[@"getmodelforcontroller"]( f1_arg1 ), "Shield_Name" )
	end

	Engine[@"exec"](Engine[@"getprimarycontroller"](), "readjson shield_username identity name string")

	NameEditBoxModel:set(Engine[@"getdvarstring"]("shield_username"))

	CoD.PCUtility.SetupEditControlWithModel( NameEditBox, f1_arg1, f1_arg0, NameEditBoxModel, function ( f331_arg0, f331_arg1, f331_arg2 )
		if not f331_arg2.canceled and f331_arg2.name == "textbox_editdone" then
			local NameData = f331_arg0:get()

			CoD.EnhPrintInfo("Username", NameData)
			PlaySoundAlias( "uin_paint_image_flip_toggle" )
			
			if not CoD.IsValidName(NameData) then
				f331_arg0:set("^1Invalid Username!")
				NameEditBox:addElement( LUI.UITimer.newElementTimer( 300, true, function ()
					-- reset old name
				f331_arg0:set(Engine[@"getdvarstring"]("shield_username"))
				end ) )
			else
				f331_arg0:set("^3Username Set!")
				NameEditBox:addElement( LUI.UITimer.newElementTimer( 300, true, function ()
					-- reset new name
				f331_arg0:set(NameData)
				end ) )

				-- shield api here later..
				Engine[@"exec"](Engine[@"getprimarycontroller"](), "writejson identity name " .. NameData .. " string")
				Engine[@"setdvar"]("shield_username", NameData)
			end
		else
			f331_arg0:set("") -- reset it
		end
	end )

	self.NameEditBoxModel = NameEditBoxModel

	local ReloadModsButton = CoD.DirectorSelectButtonMiniInternal.new( f1_arg0, f1_arg1, 0.5, 0.5, -740, 310 - 740, 0.5, 0.5, -165, 50 - 165 )
	
	ReloadModsButton.MiddleText:setTTF( "notosans_bold" )
	ReloadModsButton.MiddleText:setText("Reload Shield Mods")

	ReloadModsButton.MiddleTextFocus:setText("Reload Shield Mods")
	ReloadModsButton.MiddleTextFocus:setTTF( "notosans_bold" )

	ReloadModsButton:mergeStateConditions( {
		{
			stateName = "Locked",
			condition = function ( menu, element, event )
				return false
			end
		}
	} )

	ReloadModsButton:linkToElementModel( self, nil, false, function ( model )
		ReloadModsButton:setModel( model, f1_arg1 )
	end )
	self:addElement( ReloadModsButton )
	self.ReloadModsButton = ReloadModsButton

	f1_arg0:AddButtonCallbackFunction( ReloadModsButton, f1_arg0, Enum[@"luibutton"][@"lui_key_xba_pscross"], "ui_confirm", function ( element, menu, controller, model )
		PlaySoundAlias( "uin_paint_image_flip_toggle" )
		CoD.EnhPrintInfo("ReloadModsButton")
		
		-- reload with killserver
		CoD.VM_ReloadMods()

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
	
	local sizeReloadModsButton = CoD.DirectorSelectButtonImageInternal.new( f1_arg0, f1_arg1, 0.5, 0.5, -740, 310 - 740, 0.5, 0.5, -165, 50 - 165 )
	sizeReloadModsButton:mergeStateConditions( {
		{
			stateName = "Disabled",
			condition = function ( menu, element, event )
				return AlwaysFalse()
			end
		}
	} )

	sizeReloadModsButton:setAlpha( 0 )
	sizeReloadModsButton.Tint:setRGB( 0.05, 0.08, 0.11 )
	sizeReloadModsButton.Tint:setAlpha( 0.25 )
	sizeReloadModsButton:linkToElementModel( self, nil, false, function ( model )
		sizeReloadModsButton:setModel( model, f1_arg1 )
	end )
	sizeReloadModsButton.ButtonName.GameModeText:setText("^3Reload Mods")
	self:addElement( sizeReloadModsButton )
	self.sizeReloadModsButton = sizeReloadModsButton

	ReloadModsButton.id = "ReloadModsButton"
	sizeReloadModsButton.id = "sizeReloadModsButton"

	local MiscModsButton = CoD.DirectorSelectButtonMiniInternal.new( f1_arg0, f1_arg1, 0.5, 0.5, -740 + 500, 310 - 740 + 500, 0.5, 0.5, -165, 50 - 165 )
	
	MiscModsButton.MiddleText:setTTF( "notosans_bold" )
	MiscModsButton.MiddleText:setText("Misc Settings")

	MiscModsButton.MiddleTextFocus:setText("Misc Settings")
	MiscModsButton.MiddleTextFocus:setTTF( "notosans_bold" )

	MiscModsButton:mergeStateConditions( {
		{
			stateName = "Locked",
			condition = function ( menu, element, event )
				return false
			end
		}
	} )

	MiscModsButton:linkToElementModel( self, nil, false, function ( model )
		MiscModsButton:setModel( model, f1_arg1 )
	end )
	self:addElement( MiscModsButton )
	self.MiscModsButton = MiscModsButton

	f1_arg0:AddButtonCallbackFunction( MiscModsButton, f1_arg0, Enum[@"luibutton"][@"lui_key_xba_pscross"], "ui_confirm", function ( element, menu, controller, model )
		PlaySoundAlias( "uin_paint_image_flip_toggle" )
		CoD.EnhPrintInfo("MiscModsButton")
		
		-- open misc settings..
		OpenOverlay( self, "Shield_Misc_SettingsPopup", controller )

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

	MiscModsButton.id = "MiscModsButton"

	-- watermark
	local WaterMarkSettings = CoD.DirectorSelectButtonMiniInternal.new( f1_arg0, f1_arg1, 0.5, 0.5, -740 + 1000, 310 - 740 + 1000, 0.5, 0.5, -165, 50 - 165 )
	
	WaterMarkSettings.MiddleText:setTTF( "notosans_bold" )
	WaterMarkSettings.MiddleText:setText("Watermark Settings")

	WaterMarkSettings.MiddleTextFocus:setText("Watermark Settings")
	WaterMarkSettings.MiddleTextFocus:setTTF( "notosans_bold" )
	
	WaterMarkSettings:linkToElementModel( self, nil, false, function ( model )
		WaterMarkSettings:setModel( model, f1_arg1 )
	end )
	self:addElement( WaterMarkSettings )
	self.WaterMarkSettings = WaterMarkSettings

	f1_arg0:AddButtonCallbackFunction( WaterMarkSettings, f1_arg0, Enum[@"luibutton"][@"lui_key_xba_pscross"], "ui_confirm", function ( element, menu, controller, model )
		PlaySoundAlias( "uin_paint_image_flip_toggle" )
		CoD.EnhPrintInfo("WaterMarkSettings")
		
		OpenOverlay( self, "Shield_WaterMark_SettingsPopup", controller )

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

	WaterMarkSettings.id = "WaterMarkSettings"

	-- desc for name
	local NameHint = LUI.UIText.new( 0.5, 0.5, 0 - 755, 550 - 755, 0.5, 0.5, 100 - 315, 120 - 315 )
	NameHint:setText("To Apply Username Change, Restart the Game!")
	NameHint:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )
	NameHint:setTTF("notosans_bold")
	NameHint:setBackingType( 2 )
	NameHint:setBackingColor( 0.04, 0.81, 1 )
	NameHint:setBackingAlpha( 0.01 )
	NameHint:setBackingXPadding( 12 )
	NameHint:setBackingYPadding( 6 )
	NameHint:setAlignment( Enum[@"luialignment"][@"lui_alignment_left"] )
	NameHint:setAlignment( Enum[@"luialignment"][@"lui_alignment_top"] )
	self:addElement( NameHint )
	self.NameHint = NameHint

	local AimAssistSettings = CoD.DirectorSelectButtonMiniInternal.new( f1_arg0, f1_arg1, 0.5, 0.5, -740 + 1000, 310 - 740 + 1000, 0.5, 0.5, -165 - 125, 50 - 165 - 125 )
	
	AimAssistSettings.MiddleText:setTTF( "notosans_bold" )
	AimAssistSettings.MiddleText:setText("FOV & Aim Assist Settings")

	AimAssistSettings.MiddleTextFocus:setText("FOV & Aim Assist Settings")
	AimAssistSettings.MiddleTextFocus:setTTF( "notosans_bold" )
	
	AimAssistSettings:linkToElementModel( self, nil, false, function ( model )
		AimAssistSettings:setModel( model, f1_arg1 )
	end )
	self:addElement( AimAssistSettings )
	self.AimAssistSettings = AimAssistSettings

	f1_arg0:AddButtonCallbackFunction( AimAssistSettings, f1_arg0, Enum[@"luibutton"][@"lui_key_xba_pscross"], "ui_confirm", function ( element, menu, controller, model )
		PlaySoundAlias( "uin_paint_image_flip_toggle" )
		CoD.EnhPrintInfo("AimAssistSettings")
		
		OpenOverlay( self, "Shield_AimAssist_SettingsPopup", controller )

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

	AimAssistSettings.id = "AimAssistSettings"

	-- unlock button
	local UnlockSettings = CoD.DirectorSelectButtonMiniInternal.new( f1_arg0, f1_arg1, 0.5, 0.5, -740 + 500, 310 - 740 + 500, 0.5, 0.5, -165 - 125, 50 - 165 - 125 )
	
	UnlockSettings.MiddleText:setTTF( "notosans_bold" )
	UnlockSettings.MiddleText:setText("Unlock All Settings")

	UnlockSettings.MiddleTextFocus:setText("Unlock All Settings")
	UnlockSettings.MiddleTextFocus:setTTF( "notosans_bold" )
	
	UnlockSettings:linkToElementModel( self, nil, false, function ( model )
		UnlockSettings:setModel( model, f1_arg1 )
	end )
	self:addElement( UnlockSettings )
	self.UnlockSettings = UnlockSettings

	f1_arg0:AddButtonCallbackFunction( UnlockSettings, f1_arg0, Enum[@"luibutton"][@"lui_key_xba_pscross"], "ui_confirm", function ( element, menu, controller, model )
		PlaySoundAlias( "uin_paint_image_flip_toggle" )
		CoD.EnhPrintInfo("UnlockSettings")
		
		OpenOverlay( self, "Shield_Unlocks_SettingsPopup", controller )

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

	UnlockSettings.id = "UnlockSettings"

	-- neat trick here lol
	-- LUI.UIText.new(0.5, 0.5, Engine[@"getdvarint"]("x1"), Engine[@"getdvarint"]("x2"), 0.5, 0.5, Engine[@"getdvarint"]("y1"), Engine[@"getdvarint"]("y2"))

	-- Rank Edit
	local RankEditBox = CoD.Shield_RankEditBox.new( f1_arg0, f1_arg1, 0.5, 0.5, -20 - 770, 350 - 770, 0.5, 0.5, 230 - 100, 280 - 100 )
	RankEditBox:linkToElementModel( self, nil, false, function ( model )
		RankEditBox:setModel( model, f1_arg1 )
	end )
	RankEditBox.TextBox:setLeftRight(0, 0, 20 + 80, 320 + 80)
	RankEditBox.RankHighlight:setText("^2Set Rank: ")
	self:addElement( RankEditBox )
	self.RankEditBox = RankEditBox

	local RankEditBoxModel = Engine[@"getmodel"]( Engine[@"getmodelforcontroller"]( f1_arg1 ), "Shield_Rank" )

	if RankEditBoxModel == nil then
		RankEditBoxModel = Engine[@"createmodel"]( Engine[@"getmodelforcontroller"]( f1_arg1 ), "Shield_Rank" )
	end

	if RankEditBoxModel:get() == nil then
		RankEditBoxModel:set( "" )
	end

	local PrestigeNon = Engine[@"getstatbyname"](Engine[@"getprimarycontroller"](), "plevel")
	local isPrestigeMasterNon = PrestigeNon ~= nil and tonumber(PrestigeNon) == 11

	if isPrestigeMasterNon == true then
		RankEditBoxModel:set(Engine[@"getstatbyname"](Engine[@"getprimarycontroller"](), "paragon_rank"))
	else
		RankEditBoxModel:set(Engine[@"getstatbyname"](Engine[@"getprimarycontroller"](), "RANK"))
	end

	CoD.PCUtility.SetupEditControlWithModel( RankEditBox, f1_arg1, f1_arg0, RankEditBoxModel, function ( f331_arg0, f331_arg1, f331_arg2 )
		if not f331_arg2.canceled and f331_arg2.name == "textbox_editdone" then
			local RankData = f331_arg0:get()
			local RankLimit = 54
			local sessionmode = Engine[@"CurrentSessionMode"]()

			if sessionmode == Enum[@"emodes"][@"mode_multiplayer"] then -- mp
				RankLimit = 54
			end
			if sessionmode == Enum[@"emodes"][@"mode_zombies"] then -- zm
				RankLimit = 54
			end
			if sessionmode == Enum[@"emodes"][@"mode_warzone"] then -- wz
				RankLimit = 79
			end

			local Prestige = Engine[@"getstatbyname"](Engine[@"getprimarycontroller"](), "plevel")
			local isPrestigeMaster = Prestige ~= nil and tonumber(Prestige) == 11

			if isPrestigeMaster == true then
				RankLimit = 999

				-- wz is diff
				if sessionmode == Enum[@"emodes"][@"mode_warzone"] then -- wz
					RankLimit = 1000
				end
			end

			if RankData ~= nil and RankData ~= "" then
				CoD.EnhPrintInfo("Gamemode RankData", RankData)
				PlaySoundAlias( "uin_paint_image_flip_toggle" )
				
				if not CoD.isInteger(RankData) or tonumber(RankData) > RankLimit or tonumber(RankData) < 1 then
					f331_arg0:set("^1Invalid Rank!")
					RankEditBox:addElement( LUI.UITimer.newElementTimer( 300, true, function ()
						if isPrestigeMaster == true then
							f331_arg0:set(Engine[@"getstatbyname"](Engine[@"getprimarycontroller"](), "paragon_rank"))
						else
							f331_arg0:set(Engine[@"getstatbyname"](Engine[@"getprimarycontroller"](), "RANK"))
						end
					end ) )
				else
					f331_arg0:set("^3Rank Set!")
					RankEditBox:addElement( LUI.UITimer.newElementTimer( 300, true, function ()
						if isPrestigeMaster == true then
							f331_arg0:set(Engine[@"getstatbyname"](Engine[@"getprimarycontroller"](), "paragon_rank"))
						else
							f331_arg0:set(Engine[@"getstatbyname"](Engine[@"getprimarycontroller"](), "RANK"))
						end
					end ) )

					-- shield api here later..
					CoD.RankUtils.SetRank(RankData)
				end
			end
		else
			f331_arg0:set("") -- reset it
		end
	end )


	local PrestigeEditBox = CoD.Shield_PrestigeEditBox.new( f1_arg0, f1_arg1, 0.5, 0.5, -20 - 350, 350 - 350, 0.5, 0.5, 230 - 100, 280 - 100 )
	PrestigeEditBox:linkToElementModel( self, nil, false, function ( model )
		PrestigeEditBox:setModel( model, f1_arg1 )
	end )
	PrestigeEditBox.TextBox:setLeftRight(0, 0, 20 + 100, 320 + 100)
	PrestigeEditBox.RankHighlight:setText("^2Set Prestige: ")
	self:addElement( PrestigeEditBox )
	self.PrestigeEditBox = PrestigeEditBox

	local PrestigeEditModel = Engine[@"getmodel"]( Engine[@"getmodelforcontroller"]( f1_arg1 ), "Shield_Prestige" )

	if PrestigeEditModel == nil then
		PrestigeEditModel = Engine[@"createmodel"]( Engine[@"getmodelforcontroller"]( f1_arg1 ), "Shield_Prestige" )
	end

	if PrestigeEditModel:get() == nil then
		PrestigeEditModel:set( "" )
	end

	PrestigeEditModel:set(Engine[@"getstatbyname"](Engine[@"getprimarycontroller"](), "plevel"))

	CoD.PCUtility.SetupEditControlWithModel( PrestigeEditBox, f1_arg1, f1_arg0, PrestigeEditModel, function ( f331_arg0, f331_arg1, f331_arg2 )
		if not f331_arg2.canceled and f331_arg2.name == "textbox_editdone" then
			local PrestigeData = f331_arg0:get()
			if PrestigeData ~= nil and PrestigeData ~= "" then
				CoD.EnhPrintInfo("PrestigeData", PrestigeData)
				PlaySoundAlias( "uin_paint_image_flip_toggle" )

				if not CoD.isInteger(PrestigeData) or tonumber(PrestigeData) > 11 or tonumber(PrestigeData) < 0 then
					f331_arg0:set("^1Invalid Prestige!")
					PrestigeEditBox:addElement( LUI.UITimer.newElementTimer( 300, true, function ()
						f331_arg0:set(Engine[@"getstatbyname"](Engine[@"getprimarycontroller"](), "plevel"))
					end ) )
				else
					f331_arg0:set("^3Prestige Set!")
					PrestigeEditBox:addElement( LUI.UITimer.newElementTimer( 300, true, function ()
						f331_arg0:set(Engine[@"getstatbyname"](Engine[@"getprimarycontroller"](), "plevel"))
					end ) )

					-- shield api here later..
					CoD.RankUtils.SetPrestige(PrestigeData)
				end
			end
		else
			f331_arg0:set("") -- reset it
		end
	end )

	local PrestigeMasterButton = CoD.DirectorSelectButtonMiniInternal.new( f1_arg0, f1_arg1, 0.5, 0.5, 70, 370, 0.5, 0.5, 227.5 - 100, 277.5 - 100 )
	
	PrestigeMasterButton.MiddleText:setTTF( "notosans_bold" )
	PrestigeMasterButton.MiddleText:setText("Prestige Master")

	PrestigeMasterButton.MiddleTextFocus:setText("Prestige Master")
	PrestigeMasterButton.MiddleTextFocus:setTTF( "notosans_bold" )

	PrestigeMasterButton:mergeStateConditions( {
		{
			stateName = "Locked",
			condition = function ( menu, element, event )
				return AlwaysFalse()
			end
		}
	} )

	PrestigeMasterButton:linkToElementModel( self, nil, false, function ( model )
		PrestigeMasterButton:setModel( model, f1_arg1 )
	end )
	self:addElement( PrestigeMasterButton )
	self.PrestigeMasterButton = PrestigeMasterButton

	f1_arg0:AddButtonCallbackFunction( PrestigeMasterButton, f1_arg0, Enum[@"luibutton"][@"lui_key_xba_pscross"], "ui_confirm", function ( element, menu, controller, model )
		PlaySoundAlias( "uin_paint_image_flip_toggle" )
		CoD.EnhPrintInfo("PrestigeMasterButton")
		
		local sessionmode = Engine[@"CurrentSessionMode"]()
		local RankSet = 55

		if sessionmode == Enum[@"emodes"][@"mode_warzone"] then -- wz
			RankSet = 81
		end

		CoD.RankUtils.SetPrestige(11)
		CoD.RankUtils.SetRank(RankSet)

		Engine[@"exec"](Engine[@"getprimarycontroller"](), "statsetbyname rankxp 1457200")
		-- idk if this even exists in bo4.. (nvm it does lol)
		Engine[@"exec"](Engine[@"getprimarycontroller"](), "PrestigeStatsMaster " .. tostring(Engine[@"CurrentSessionMode"]()))

		CoD.OverlayUtility.CreateOverlay(controller, menu, "PrestigeMasterActivated")

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

	PrestigeMasterButton.id = "PrestigeMasterButton"
	
	RankEditBox.id = "RankEditBox"
	PrestigeEditBox.id = "PrestigeEditBox"

	NameEditBox.id = "NameEditBox"

	ShieldSettingsTabs.id = "ShieldSettingsTabs"
	LUI.OverrideFunction_CallOriginalSecond( self, "close", self.__onClose )
	
	if PostLoadFunc then
		PostLoadFunc( self, f1_arg1, f1_arg0 )
	end
	
	return self
end

CoD.ShieldOptionsMenu_SafeAreaFront.__onClose = function ( f8_arg0 )
	f8_arg0.HeaderStripe:close()
	f8_arg0.ShieldSettingsTabs:close()
	f8_arg0.actionsListPCEnh:close()
	f8_arg0.actionsListPCEnhHint:close()
	f8_arg0.CommonHeader:close()
	f8_arg0.TabBacking:close()

	f8_arg0.PrestigeMasterButton:close()
	f8_arg0.AimAssistSettings:close()
	f8_arg0.WaterMarkSettings:close()
	f8_arg0.PrestigeEditBox:close()
	f8_arg0.RankEditBox:close()
	f8_arg0.NameHint:close()
	f8_arg0.NameEditBox:close()
	f8_arg0.ReloadModsButton:close()
	f8_arg0.sizeReloadModsButton:close()

	f8_arg0.MiscModsButton:close()
end