--[[
		.\hksc.exe ".\Lua\Party.Lua" -o "C:\Program Files (x86)\Call of Duty Black Ops 4\project-bo4\mods\T8ShieldSupport\Lua\Party.luac"
]]

---------------------------

CoD.ShieldInitLuaFile()

---------------------------

-- dvars
Engine[@"exec"](Engine[@"getprimarycontroller"](), "set shield_party_privacy 0")

-- vars
local active_party = {}

---------------------------

CoD.Shield.OnPartyListReceived = function(event_name, event_table)
	if event_name == "party_list_event_clear" then
		-- Clear party
		active_party = {}

		CoD.EnhPrintInfo("Cleared Party, from c++")

		-- update widget
		if CoD.Menu.CurrentPartyWidget ~= nil then
			CoD.Menu.CurrentPartyWidget:setDataSource( "ShieldPartyList" )
			CoD.Menu.CurrentPartyWidget:updateDataSource()
		end

		return
	end

	local party = event_table.party
	if party then
		-- Clear existing
		active_party = {}

		for i = 1, #party do
			local party_guy = party[i]
			if party_guy and party_guy.username and party_guy.xuid then
				table.insert(active_party, {
					username = party_guy.username,
					xuid = party_guy.xuid,
					status = party_guy.status,
					activity = party_guy.activity
				})
			end
		end

		-- Optional debug output
		for i, f in ipairs(active_party) do
			CoD.EnhPrintInfo("Stored party guy: " .. f.username .. " - " .. f.status .. " (XUID: " .. Engine[@"uint64tostring"](f.xuid) .. ")")
		end
	end

	if CoD.Menu.CurrentPartyWidget ~= nil then
		CoD.Menu.CurrentPartyWidget:setDataSource( "ShieldPartyList" )
		CoD.Menu.CurrentPartyWidget:updateDataSource()
	end
end

local function OnPartykDataChange ( f137_arg0, f137_arg1, f137_arg2, f137_arg3, f137_arg4 )
	local dvar_name = f137_arg3
	local dvar_val = Engine[@"getdvarint"]( dvar_name )
	local current_val = f137_arg1.value
	CoD.OptionsUtility.UpdateInfoModels( f137_arg1 )

	if current_val == dvar_val then
		return 
	else
		Engine[@"setdvar"]( dvar_name, current_val )
	end

	if dvar_name == "shield_party_privacy" then
		if current_val == 0 then
			Engine[@"exec"](Engine[@"getprimarycontroller"](), "unlockparty")
		else
			Engine[@"exec"](Engine[@"getprimarycontroller"](), "lockparty")
		end
	end
end

---------------------------

-- party
DataSources.ShieldPartyList = DataSourceHelpers.ListSetup("ShieldPartyList", function(f3_arg0, f3_arg1)
	local InfoParty = {}

	if active_party then
		for i = 1, #active_party do
			local party_guy = active_party[i]
			table.insert(InfoParty, {
				models = {
					FriendName = party_guy.username or "unknown",
					FriendXUID = Engine[@"uint64tostring"](party_guy.xuid or 0),
					FriendXUID_Userdata = party_guy.xuid or 0,
					FriendStatus = (party_guy.status or "offline") .. " (" .. party_guy.activity .. ")",
				},
				properties = {}
			})
		end
	end

	return InfoParty
end, true)

DataSources.ShieldPartyData = DataSourceHelpers.ListSetup( "ShieldPartyData", function ( f138_arg0 )
	local Settings = {}

	table.insert( Settings, CoD.OptionsUtility.CreateDvarSettings( f138_arg0, @"hash_7c66adde88e8d222", @"hash_21e6c0a18fb50ff2", "shield_party_privacy", "shield_party_privacy", {
		{
			option = Engine[@"hash_4F9F1239CFD921FE"]( @"hash_7ebc76ab224b7dcb" ), 
			value = 0,
			default = true
		},
		{
			option = Engine[@"hash_4F9F1239CFD921FE"]( @"hash_4980ddea2fd1615b" ),
			value = 1
		}
	}, nil, OnPartykDataChange ) )

	return Settings

end, nil, nil, function ( f139_arg0, f139_arg1, f139_arg2 )
	local f139_local0 = Engine[@"createmodel"]( Engine[@"getglobalmodel"](), "GametypeSettings.Update" )
	if f139_arg1.updateSubscription then
		f139_arg1:removeSubscription( f139_arg1.updateSubscription )
	end
	f139_arg1.updateSubscription = f139_arg1:subscribeToModel( f139_local0, function ()
		f139_arg1:updateDataSource()
	end, false )
end )

---------------------------

-- Party List
CoD.PartyListData = InheritFrom( LUI.UIElement )
CoD.PartyListData.__defaultWidth = 1600
CoD.PartyListData.__defaultHeight = 620
CoD.PartyListData.new = function ( f1_arg0, f1_arg1, f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	local self = LUI.UIElement.new( f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	self:setClass( CoD.PartyListData )
	self.id = "PartyListData"
	self.soundSet = "default"
	self.onlyChildrenFocusable = true
	self.anyChildUsesUpdateState = true

	-------------------------

	local PartyList = LUI.UIList.new( f1_arg0, f1_arg1, 10, 0, nil, false, false, false, false )
	PartyList:setLeftRight( 0.5, 0.5, 0 - 300, 600 - 300 )
	PartyList:setTopBottom( 0, 0, 240, 240)
	PartyList:setAutoScaleContent( true )
	PartyList:setVerticalCount(3)
	PartyList:setHorizontalCount(1)
	PartyList:setSpacing( 10 )
	PartyList:setWidgetType( CoD.ShieldFriendRow )
	PartyList:setVerticalCounter( CoD.verticalCounter )
	PartyList:setDataSource( "ShieldPartyList" )
	PartyList:setAlignment( Enum[@"luialignment"][@"lui_alignment_left"] )
	self:addElement( PartyList )
	self.PartyList = PartyList

	CoD.Menu.CurrentPartyWidget = PartyList

	PartyList.id = "PartyList"

	-------------------------

	LUI.OverrideFunction_CallOriginalSecond( self, "close", self.__onClose )
	
	if PostLoadFunc then
		PostLoadFunc( self, f1_arg1, f1_arg0 )
	end

	return self
end

CoD.PartyListData.__onClose = function ( f9_arg0 )
	--f9_arg0.LANServerBrowserDetails:close()
	f9_arg0.PartyList:close()
end

-- shield's party
CoD.ShieldPartyStuff = InheritFrom( CoD.Menu )
LUI.createMenu.ShieldPartyStuff = function ( f1_arg0, f1_arg1 )
	local self = CoD.Menu.NewForUIEditor( "ShieldPartyStuff", f1_arg0 )
	local f1_local1 = self
	self:setClass( CoD.ShieldPartyStuff )
	self.soundSet = "none"
	self:setOwner( f1_arg0 )
	self:setLeftRight( 0, 1, 0, 0 )
	self:setTopBottom( 0, 1, 0, 0 )
	self:playSound( "menu_open", f1_arg0 )
	self.anyChildUsesUpdateState = true
	f1_local1:addElementToPendingUpdateStateList( self )
	
	local CommomCenteredPopup = CoD.PartyCommonCenteredPopup.new( f1_local1, f1_arg0, 0, 1, 0, 0, 0, 1, 0, 0 )
	CommomCenteredPopup.TitleText:setText("Shield Party")
	CommomCenteredPopup.HeaderBackground:setAlpha( 0 )
	CommomCenteredPopup.HeaderTopBar:setAlpha( 0 )
	CommomCenteredPopup.HeaderBottomBar:setAlpha( 0 )
	self:addElement( CommomCenteredPopup )
	self.CommomCenteredPopup = CommomCenteredPopup

	local PartyListsHint = LUI.UIText.new( 0.5, 0.5, -120 - 170, 120 - 170, 0.5, 0.5, 100 - 490, 135 - 490 )
	PartyListsHint:setText("Active Party")
	PartyListsHint:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )
	PartyListsHint:setTTF("notosans_bold")
	PartyListsHint:setBackingType( 2 )
	PartyListsHint:setBackingColor( 0.04, 0.81, 1 )
	PartyListsHint:setBackingAlpha( 0.01 )
	PartyListsHint:setBackingXPadding( 12 )
	PartyListsHint:setBackingYPadding( 6 )
	PartyListsHint:setAlignment( Enum[@"luialignment"][@"lui_alignment_left"] )
	PartyListsHint:setAlignment( Enum[@"luialignment"][@"lui_alignment_top"] )
	self:addElement( PartyListsHint )
	self.PartyListsHint = PartyListsHint

	local PartyLists = CoD.PartyListData.new( self, f1_arg0, 0.5, 0.5, -800, 800, 0.5, 0.5, -535, 400 )
	self:addElement( PartyLists )
	self.PartyLists = PartyLists

	PartyLists.id = "PartyLists"

	local CreatePartyButton = CoD.DirectorSelectButtonMiniInternal.new( f1_local1, f1_arg0, 0.5, 0.5, -160 - 200, 160 - 200, 0.5, 0.5, 15 + 100, 75 + 100 )
		
	CreatePartyButton.MiddleText:setTTF( "ttmussels_regular" )
	CreatePartyButton.MiddleText:setText("Create a Party")

	CreatePartyButton.MiddleTextFocus:setText("Create a Party")
	CreatePartyButton.MiddleTextFocus:setTTF( "ttmussels_regular" )

	CreatePartyButton:linkToElementModel( self, nil, false, function ( model )
		CreatePartyButton:setModel( model, f1_arg1 )
	end )
	self:addElement( CreatePartyButton )
	self.CreatePartyButton = CreatePartyButton

	self:AddButtonCallbackFunction( CreatePartyButton, f1_arg0, Enum[@"luibutton"][@"lui_key_xba_pscross"], "ui_confirm", function ( element, menu, controller, model )
		PlaySoundAlias( "uin_paint_image_flip_toggle" )
		CoD.EnhPrintInfo("CreatePartyButton")
		
		Engine[@"exec"](Engine[@"getprimarycontroller"](), "createparty")
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

	CreatePartyButton.id = "CreatePartyButton"

	local LeavePartyButton = CoD.DirectorSelectButtonMiniInternal.new( f1_local1, f1_arg0, 0.5, 0.5, -160 + 200, 160 + 200, 0.5, 0.5, 15 + 100, 75 + 100 )
		
	LeavePartyButton.MiddleText:setTTF( "ttmussels_regular" )
	LeavePartyButton.MiddleText:setText("Leave Party")

	LeavePartyButton.MiddleTextFocus:setText("Leave Party")
	LeavePartyButton.MiddleTextFocus:setTTF( "ttmussels_regular" )

	LeavePartyButton:linkToElementModel( self, nil, false, function ( model )
		LeavePartyButton:setModel( model, f1_arg1 )
	end )
	self:addElement( LeavePartyButton )
	self.LeavePartyButton = LeavePartyButton

	self:AddButtonCallbackFunction( LeavePartyButton, f1_arg0, Enum[@"luibutton"][@"lui_key_xba_pscross"], "ui_confirm", function ( element, menu, controller, model )
		PlaySoundAlias( "uin_paint_image_flip_toggle" )
		CoD.EnhPrintInfo("LeavePartyButton")
		
		Engine[@"exec"](Engine[@"getprimarycontroller"](), "leaveparty")
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

	LeavePartyButton.id = "LeavePartyButton"

	Engine[@"exec"](Engine[@"getprimarycontroller"](), "partystatus")

	-- datasources for unlocks here
	local PartySettings = LUI.UIList.new( f1_local1, f1_arg0, 3, 3, nil, false, false, false, false )

	if Engine[@"getdvarint"]("shield_ui_color") == 0 then
		PartySettings:setRGB(0, 1, 1)
	elseif Engine[@"getdvarint"]("shield_ui_color") == 1 then
		PartySettings:setRGB(1, 0, 0)
	elseif Engine[@"getdvarint"]("shield_ui_color") == 2 then
		PartySettings:setRGB(0, 1, 0)
	end

	PartySettings:setLeftRight( 0.5, 0.5, -250, 250 )
	PartySettings:setTopBottom( 0.5, 0.5, -380 + 585, -320 + 585 )
	PartySettings:setVerticalCount(9) -- fix
	PartySettings:setHorizontalCount(1)
	PartySettings:setSpacing(10) -- spacing needed..
	PartySettings:setWidgetType( CoD.CustomGames_SettingSliderNoCustom )
	PartySettings:setAlignment( Enum[@"luialignment"][@"lui_alignment_left"] )
	PartySettings:setDataSource( "ShieldPartyData" )
	self:addElement( PartySettings )
	self.PartySettings = PartySettings

	PartySettings.id = "PartySettings"

	-- desc
	local PartySettingDescription = LUI.UIText.new( 0.5, 0.5, -300, 250, 0.65, 0.65, 150, 180 )
	PartySettingDescription:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )
	PartySettingDescription:setTTF("notosans_bold")
	PartySettingDescription:setBackingType( 2 )
	PartySettingDescription:setBackingColor( 0.04, 0.81, 1 )
	PartySettingDescription:setBackingAlpha( 0.01 )
	PartySettingDescription:setBackingXPadding( 12 )
	PartySettingDescription:setBackingYPadding( 6 )
	PartySettingDescription:setAlignment( Enum[@"luialignment"][@"lui_alignment_left"] )
	PartySettingDescription:setAlignment( Enum[@"luialignment"][@"lui_alignment_top"] )
	self:addElement( PartySettingDescription )
	self.PartySettingDescription = PartySettingDescription

	-- link it, subtitles like
	PartySettingDescription:linkToElementModel( PartySettings, "desc", true, function ( model )
		local f7_local0 = model:get()
		if f7_local0 ~= nil then
			PartySettingDescription:setText( Engine[@"hash_4F9F1239CFD921FE"]( f7_local0 ) )
		end
	end )

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

	CoD.EnhPrintInfo("Called", "Shield's Party")

	return self
end

CoD.ShieldPartyStuff.__resetProperties = function ( f13_arg0 )

end

CoD.ShieldPartyStuff.__clipsPerState = {
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
			--f15_arg0.FriendLists:completeAnimation()
			--f15_arg0.FriendLists:setLeftRight( 0, 0, 1060, 1630 )
			--f15_arg0.clipFinished( f15_arg0.FriendLists )
		end
	}
}

CoD.ShieldPartyStuff.__onClose = function ( f16_arg0 )
	f16_arg0.CommomCenteredPopup:close()
	f16_arg0.PartyListsHint:close()
	f16_arg0.PartyLists:close()
end

-- friend's background
CoD.PartyCommonCenteredPopup = InheritFrom( LUI.UIElement )
CoD.PartyCommonCenteredPopup.__defaultWidth = 1920
CoD.PartyCommonCenteredPopup.__defaultHeight = 1080
CoD.PartyCommonCenteredPopup.new = function ( f1_arg0, f1_arg1, f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	local self = LUI.UIElement.new( f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	self:setClass( CoD.PartyCommonCenteredPopup )
	self.id = "PartyCommonCenteredPopup"
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
	
	local CenterBackground = LUI.UIImage.new( 0.5, 0.5, -348 - 300, 348 + 300, 0.5, 0.5, -500, 500 )
	CenterBackground:setRGB( 0.09, 0.09, 0.09 )
	CenterBackground:setAlpha( 0.9 )
	self:addElement( CenterBackground )
	self.CenterBackground = CenterBackground
	
	local CenterTiledBacking = LUI.UIImage.new( 0.5, 0.5, -348 - 300, 348 + 300, 0.5, 0.5, -500, 500 )
	CenterTiledBacking:setAlpha( 0.25 )
	CenterTiledBacking:setImage( RegisterImage( @"hash_634839E8065B1E53" ) )
	CenterTiledBacking:setMaterial( LUI.UIImage.GetCachedMaterial( @"hash_16CBE95C250C6D15" ) )
	CenterTiledBacking:setShaderVector( 0, 0, 0, 0, 0 )
	CenterTiledBacking:setupNineSliceShader( 196, 88 )
	self:addElement( CenterTiledBacking )
	self.CenterTiledBacking = CenterTiledBacking
	
	local buttons = CoD.fe_LeftContainer_NOTLobby.new( f1_arg0, f1_arg1, 0.5, 0.5, -312, 336, 0.5, 0.5, 439, 487 )
	self:addElement( buttons )
	self.buttons = buttons
	
	local featureOverlayButtonMouseOnly = nil
	
	featureOverlayButtonMouseOnly = CoD.featureOverlay_Button.new( f1_arg0, f1_arg1, 0.5, 0.5, -333 + 950 - 200, -147 + 950 - 200, 0.5, 0.5, 424, 484 )
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
	
	local LayoutBottomBar = LUI.UIImage.new( 0.5, 0.5, -349.5 - 300, 349.5 + 300, 0.5, 0.5, 473, 501 )
	LayoutBottomBar:setZRot( 180 )
	LayoutBottomBar:setImage( RegisterImage( @"hash_87C348C36FF085C" ) )
	self:addElement( LayoutBottomBar )
	self.LayoutBottomBar = LayoutBottomBar
	
	local LayoutTopBar = LUI.UIImage.new( 0.5, 0.5, -349.5 - 300, 349.5 + 300, 0.5, 0.5, -500.5, -472.5 )
	LayoutTopBar:setImage( RegisterImage( @"hash_87C348C36FF085C" ) )
	self:addElement( LayoutTopBar )
	self.LayoutTopBar = LayoutTopBar
	
	local LayoutTopBarStripes = LUI.UIImage.new( 0.5, 0.5, -348 - 300, 348 + 300, 0.5, 0.5, -500.5, -484.5 )
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
	
	local HeaderBackground = LUI.UIImage.new( 0.5, 0.5, -336.5 - 300, 336.5 + 300, 0.5, 0.5, -423, -231 )
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

CoD.PartyCommonCenteredPopup.__onClose = function ( f8_arg0 )
	f8_arg0.buttons:close()
	f8_arg0.featureOverlayButtonMouseOnly:close()
	f8_arg0.BTNQuit:close()
end