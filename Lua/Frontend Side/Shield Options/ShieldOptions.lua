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
		-- the engine has a team for 126 players at most: a mode without teams gives each its own
		highValue = 126
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

end

---------------------------

--[[
	The body, 1744 by 770, in the middle of the screen from 140 down.
	Left, 860 wide: the profile, the rank and prestige, the size of the lobby.
	Right, from 884: the settings, each a button that opens its own menu, and the mods.
	Everything is placed by its place in the body.
]]
local BODY_LEFT = -872
local BODY_TOP = 140
local COLUMN_WIDTH = 860
local RIGHT_COLUMN = 884
local CARD_PADDING = 28
local BUTTON_WIDTH = 400
local BUTTON_HEIGHT = 50

-- the cards, by their top and bottom. The two of each column end and start on the same lines, 24 apart.
local PROFILE_CARD = { 0, 210 }
local RANK_CARD = { 234, 536 }
local LOBBY_CARD = { 560, 770 }
local SETTINGS_CARD = { 0, 536 }
local MODS_CARD = { 560, 770 }

-- the settings: what the button says, the menu it opens, and what is in there
local SettingsMenus = {
	{ id = "UnlockSettings", label = "UNLOCK ALL", menu = "Shield_Unlocks_SettingsPopup", about = "Everything, or only attachments, camos and cards, items, loot or class slots." },
	{ id = "BotSettings", label = "BOTS", menu = "Shield_Bot_SettingsPopup", about = "How good the bots of multiplayer are: aim, reaction, awareness, headshots, objectives." },
	{ id = "AimAssistSettings", label = "FOV & AIM ASSIST", menu = "Shield_AimAssist_SettingsPopup", about = "FOV scaling, and the lock-on and slowdown of aim assist." },
	{ id = "MovementSettings", label = "MOVEMENT", menu = "Shield_Movement_SettingsPopup", about = "Omni movement, sideways sprint speed, jump cooldown, slides." },
	{ id = "MiscModsButton", label = "MISC SETTINGS", menu = "Shield_Misc_SettingsPopup", about = "Menu colours, Discord presence, bots, round counter and more." },
	{ id = "WaterMarkSettings", label = "WATERMARK", menu = "Shield_WaterMark_SettingsPopup", about = "What the watermark shows: the Shield text, the mods, the checksum." },
	{ id = "BlackMarketSettings", label = "BLACK MARKET", menu = "Shield_BlackMarket_SettingsPopup", about = "How cases and tiers are earned, the active season, what purchases cost." }
}

local CardColors = {
	profile = { r = 0.35, g = 0.75, b = 1 },
	rank = { r = 1, g = 0.8, b = 0.25 },
	lobby = { r = 0.45, g = 0.9, b = 0.45 },
	settings = { r = 0.35, g = 0.75, b = 1 },
	mods = { r = 1, g = 0.38, b = 0.28 }
}

local function NewText( left, right, top, size, font, alignment )
	local text = LUI.UIText.new( 0.5, 0.5, BODY_LEFT + left, BODY_LEFT + right, 0, 0, BODY_TOP + top, BODY_TOP + top + size )
	text:setTTF( font )
	text:setAlignment( alignment or Enum[@"luialignment"][@"lui_alignment_left"] )
	text:setAlignment( Enum[@"luialignment"][@"lui_alignment_top"] )
	return text
end

-- the small grey words over a title
local function NewCaption( left, right, top, words )
	local text = NewText( left, right, top, 15, "ttmussels_regular" )
	text:setRGB( 0.55, 0.55, 0.55 )
	text:setLetterSpacing( 2 )
	text:setText( words )
	return text
end

-- what a thing beside it does, in grey: the game breaks it in lines
local function NewHint( left, right, top, words )
	local text = NewText( left, right, top, 18, "notosans_regular" )
	text:setRGB( 0.62, 0.62, 0.62 )
	text:setText( words )
	return text
end

-- a box of one colour
local function NewBox( left, right, top, bottom, r, g, b, alpha )
	local box = LUI.UIImage.new( 0.5, 0.5, BODY_LEFT + left, BODY_LEFT + right, 0, 0, BODY_TOP + top, BODY_TOP + bottom )
	box:setRGB( r, g, b )
	box:setAlpha( alpha )
	return box
end

-- A card: dark, with a line of its colour over it, the thin frame of the game around it, and its name.
-- Gives where its own things start.
local function AddCard( add, left, card, color, caption, title )
	local right = left + COLUMN_WIDTH
	local top = card[1]
	local bottom = card[2]

	add( NewBox( left, right, top, bottom, 0, 0, 0, 0.5 ) )
	add( NewBox( left, right, top, top + 4, color.r, color.g, color.b, 1 ) )

	local Frame = LUI.UIImage.new( 0.5, 0.5, BODY_LEFT + left - 1, BODY_LEFT + right + 1, 0, 0, BODY_TOP + top - 1, BODY_TOP + bottom + 1 )
	Frame:setAlpha( 0.12 )
	Frame:setImage( RegisterImage( @"uie_ui_menu_store_common_frame" ) )
	Frame:setMaterial( LUI.UIImage.GetCachedMaterial( @"uie_nineslice_add" ) )
	Frame:setShaderVector( 0, 0, 0, 0, 0 )
	Frame:setupNineSliceShader( 12, 12 )
	add( Frame )

	add( NewCaption( left + CARD_PADDING, right - CARD_PADDING, top + 24, caption ) )

	local Title = add( NewText( left + CARD_PADDING, right - CARD_PADDING, top + 44, 34, "notosans_bold" ) )
	Title:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )
	Title:setText( title )

	add( NewBox( left + CARD_PADDING, right - CARD_PADDING, top + 94, top + 95, 1, 1, 1, 0.1 ) )

	return top + 112
end

-- A button of the game with its own words, never locked, that does that when it is clicked. The menu finds
-- what can take the focus as parent[id]: it is kept under its id.
local function AddButton( self, menu, controller, id, label, left, top, action )
	local button = CoD.DirectorSelectButtonMiniInternal.new( menu, controller, 0.5, 0.5, BODY_LEFT + left, BODY_LEFT + left + BUTTON_WIDTH, 0, 0, BODY_TOP + top, BODY_TOP + top + BUTTON_HEIGHT )

	button.MiddleText:setText( label )
	button.MiddleTextFocus:setText( label )

	button:mergeStateConditions( {
		{
			stateName = "Locked",
			condition = function ( menu, element, event )
				return AlwaysFalse()
			end
		}
	} )

	button:linkToElementModel( self, nil, false, function ( model )
		button:setModel( model, controller )
	end )

	self:addElement( button )
	button.id = id
	self[id] = button
	table.insert( self.Buttons, button )

	menu:AddButtonCallbackFunction( button, controller, Enum[@"luibutton"][@"lui_key_xba_pscross"], "ui_confirm", function ( element, menu, controller, model )
		PlaySoundAlias( "uin_paint_image_flip_toggle" )
		CoD.EnhPrintInfo( id )
		action( menu, controller )
		return true
	end, function ( element, menu, controller )
		if IsGamepad( controller ) then
			CoD.Menu.SetButtonLabel( menu, Enum[@"luibutton"][@"lui_key_xba_pscross"], @"menu/select", nil, "ui_confirm" )
			return true
		elseif IsMouseOrKeyboard( controller ) then
			CoD.Menu.SetButtonLabel( menu, Enum[@"luibutton"][@"lui_key_xba_pscross"], @"hash_0", nil, "ui_confirm" )
			return false
		else
			return false
		end
	end, false )

	return button
end

-- the rank a player has now: its paragon rank once it is a prestige master
local function CurrentRank()
	local prestige = Engine[@"getstatbyname"]( Engine[@"getprimarycontroller"](), "plevel" )

	if prestige ~= nil and tonumber( prestige ) == 11 then
		return Engine[@"getstatbyname"]( Engine[@"getprimarycontroller"](), "paragon_rank" ), true
	end

	return Engine[@"getstatbyname"]( Engine[@"getprimarycontroller"](), "RANK" ), false
end

-- a model of the player for a box to write in
local function EditModel( controller, name )
	local model = Engine[@"getmodel"]( Engine[@"getmodelforcontroller"]( controller ), name )

	if model == nil then
		model = Engine[@"createmodel"]( Engine[@"getmodelforcontroller"]( controller ), name )
	end

	if model:get() == nil then
		model:set( "" )
	end

	return model
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

	-- everything of the menu that is only closed with it
	self.Parts = {}
	self.Buttons = {}

	local function Add( element )
		self:addElement( element )
		table.insert( self.Parts, element )
		return element
	end

	local TabBacking = CoD.CommonTabBarBacking.new( f1_arg0, f1_arg1, -0.1, 1.1, 0, 0, 0, 0, 52, 89 )
	TabBacking.TabBackingBlur:setAlpha( 0 )
	self:addElement( TabBacking )
	self.TabBacking = TabBacking

	local CommonHeader = CoD.CommonHeader.new( f1_arg0, f1_arg1, 0, 1, 0, 0, 0, 0, 0, 67 )
	CommonHeader.subtitle.StageTitle:setText("^2Shield Options")
	CommonHeader.subtitle.subtitle:setText("^3Profile, Rank, Lobby and Settings")
	self:addElement( CommonHeader )
	self.CommonHeader = CommonHeader

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

	---------------------------
	-- left: the profile

	local ProfileTop = AddCard( Add, 0, PROFILE_CARD, CardColors.profile, "WHO YOU ARE", "Profile" )

	local NameEditBox = CoD.Shield_NameEditBox.new( f1_arg0, f1_arg1, 0.5, 0.5, BODY_LEFT + CARD_PADDING, BODY_LEFT + CARD_PADDING + BUTTON_WIDTH, 0, 0, BODY_TOP + ProfileTop, BODY_TOP + ProfileTop + BUTTON_HEIGHT )
	NameEditBox:linkToElementModel( self, nil, false, function ( model )
		NameEditBox:setModel( model, f1_arg1 )
	end )
	NameEditBox.TextBox:setLeftRight( 0, 0, 125, 390 )
	NameEditBox.RankHighlight:setText( "Username:" )
	self:addElement( NameEditBox )
	self.NameEditBox = NameEditBox

	local NameEditBoxModel = EditModel( f1_arg1, "Shield_Name" )

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

	Add( NewHint( CARD_PADDING + BUTTON_WIDTH + 24, COLUMN_WIDTH - CARD_PADDING, ProfileTop + 4, "A new username applies after you restart the game." ) )

	---------------------------
	-- the rank and the prestige

	local RankTop = AddCard( Add, 0, RANK_CARD, CardColors.rank, "FOR THE MODE YOU ARE IN", "Rank & Prestige" )

	local RankEditBox = CoD.Shield_RankEditBox.new( f1_arg0, f1_arg1, 0.5, 0.5, BODY_LEFT + CARD_PADDING, BODY_LEFT + CARD_PADDING + 390, 0, 0, BODY_TOP + RankTop, BODY_TOP + RankTop + BUTTON_HEIGHT )
	RankEditBox:linkToElementModel( self, nil, false, function ( model )
		RankEditBox:setModel( model, f1_arg1 )
	end )
	RankEditBox.TextBox:setLeftRight( 0, 0, 85, 380 )
	RankEditBox.RankHighlight:setText( "Rank:" )
	self:addElement( RankEditBox )
	self.RankEditBox = RankEditBox

	local RankEditBoxModel = EditModel( f1_arg1, "Shield_Rank" )
	RankEditBoxModel:set( ( CurrentRank() ) )

	CoD.PCUtility.SetupEditControlWithModel( RankEditBox, f1_arg1, f1_arg0, RankEditBoxModel, function ( f331_arg0, f331_arg1, f331_arg2 )
		if not f331_arg2.canceled and f331_arg2.name == "textbox_editdone" then
			local RankData = f331_arg0:get()
			local RankLimit = 54
			local sessionmode = Engine[@"CurrentSessionMode"]()

			if sessionmode == Enum[@"emodes"][@"mode_warzone"] then -- wz
				RankLimit = 79
			end

			local _, isPrestigeMaster = CurrentRank()

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
				else
					f331_arg0:set("^3Rank Set!")

					-- shield api here later..
					CoD.RankUtils.SetRank(RankData)
				end

				-- the box shows the rank again once the word was read
				RankEditBox:addElement( LUI.UITimer.newElementTimer( 300, true, function ()
					f331_arg0:set( ( CurrentRank() ) )
				end ) )
			end
		else
			f331_arg0:set("") -- reset it
		end
	end )

	local PrestigeEditBox = CoD.Shield_PrestigeEditBox.new( f1_arg0, f1_arg1, 0.5, 0.5, BODY_LEFT + CARD_PADDING + 414, BODY_LEFT + COLUMN_WIDTH - CARD_PADDING, 0, 0, BODY_TOP + RankTop, BODY_TOP + RankTop + BUTTON_HEIGHT )
	PrestigeEditBox:linkToElementModel( self, nil, false, function ( model )
		PrestigeEditBox:setModel( model, f1_arg1 )
	end )
	PrestigeEditBox.TextBox:setLeftRight( 0, 0, 110, 380 )
	PrestigeEditBox.RankHighlight:setText( "Prestige:" )
	self:addElement( PrestigeEditBox )
	self.PrestigeEditBox = PrestigeEditBox

	local PrestigeEditModel = EditModel( f1_arg1, "Shield_Prestige" )
	PrestigeEditModel:set(Engine[@"getstatbyname"](Engine[@"getprimarycontroller"](), "plevel"))

	CoD.PCUtility.SetupEditControlWithModel( PrestigeEditBox, f1_arg1, f1_arg0, PrestigeEditModel, function ( f331_arg0, f331_arg1, f331_arg2 )
		if not f331_arg2.canceled and f331_arg2.name == "textbox_editdone" then
			local PrestigeData = f331_arg0:get()
			if PrestigeData ~= nil and PrestigeData ~= "" then
				CoD.EnhPrintInfo("PrestigeData", PrestigeData)
				PlaySoundAlias( "uin_paint_image_flip_toggle" )

				if not CoD.isInteger(PrestigeData) or tonumber(PrestigeData) > 11 or tonumber(PrestigeData) < 0 then
					f331_arg0:set("^1Invalid Prestige!")
				else
					f331_arg0:set("^3Prestige Set!")

					-- shield api here later..
					CoD.RankUtils.SetPrestige(PrestigeData)
				end

				PrestigeEditBox:addElement( LUI.UITimer.newElementTimer( 300, true, function ()
					f331_arg0:set(Engine[@"getstatbyname"](Engine[@"getprimarycontroller"](), "plevel"))
				end ) )
			end
		else
			f331_arg0:set("") -- reset it
		end
	end )

	AddButton( self, f1_arg0, f1_arg1, "PrestigeMasterButton", "PRESTIGE MASTER", CARD_PADDING, RankTop + 72, function ( menu, controller )
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
	end )

	Add( NewHint( CARD_PADDING + BUTTON_WIDTH + 24, COLUMN_WIDTH - CARD_PADDING, RankTop + 76, "Prestige 11 and the top rank, in one click." ) )

	---------------------------
	-- the size of the lobby

	local LobbyTop = AddCard( Add, 0, LOBBY_CARD, CardColors.lobby, "HOW MANY CAN PLAY", "Lobby Size" )

	-- a list of one slider, 375 by 60
	local actionsListPCEnh = LUI.UIList.new( f1_arg0, f1_arg1, 0, 0, nil, false, false, false, false )
	actionsListPCEnh:setLeftRight( 0.5, 0.5, BODY_LEFT + CARD_PADDING, BODY_LEFT + CARD_PADDING + 375 )
	actionsListPCEnh:setTopBottom( 0, 0, BODY_TOP + LobbyTop, BODY_TOP + LobbyTop + 60 )
	actionsListPCEnh:setAlpha( 1 )
	actionsListPCEnh:setWidgetType( CoD.CraftActionHeaderEnhShield )
	actionsListPCEnh:setVerticalCount( 15 )
	actionsListPCEnh:setSpacing( 0 )
	actionsListPCEnh:setDataSource( "EnhActionsShieldPC" )
	self:addElement( actionsListPCEnh )
	self.actionsListPCEnh = actionsListPCEnh

	actionsListPCEnh.id = "actionsListPCEnh"

	Add( NewHint( CARD_PADDING + BUTTON_WIDTH + 24, COLUMN_WIDTH - CARD_PADDING, LobbyTop + 2, "Sets your party and engine player limit. For Zombies with more than 4 players, use the Enhancement Mod for its fixes and improvements." ) )

	---------------------------
	-- right: the settings, each in a menu of its own

	local SettingsTop = AddCard( Add, RIGHT_COLUMN, SETTINGS_CARD, CardColors.settings, "EACH OPENS ITS OWN MENU", "Settings" )

	-- the buttons share the card: 86 apart while they fit, closer when there are more
	local SettingsStep = math.min( 86, math.floor( ( SETTINGS_CARD[2] - SettingsTop - BUTTON_HEIGHT - 24 ) / math.max( #SettingsMenus - 1, 1 ) ) )

	for index, entry in ipairs( SettingsMenus ) do
		local top = SettingsTop + ( index - 1 ) * SettingsStep

		AddButton( self, f1_arg0, f1_arg1, entry.id, entry.label, RIGHT_COLUMN + CARD_PADDING, top, function ( menu, controller )
			OpenOverlay( self, entry.menu, controller )
		end )

		Add( NewHint( RIGHT_COLUMN + CARD_PADDING + BUTTON_WIDTH + 24, RIGHT_COLUMN + COLUMN_WIDTH - CARD_PADDING, top + 4, entry.about ) )
	end

	---------------------------
	-- the mods

	local ModsTop = AddCard( Add, RIGHT_COLUMN, MODS_CARD, CardColors.mods, "AFTER YOU CHANGED ONE", "Mods" )

	AddButton( self, f1_arg0, f1_arg1, "ReloadModsButton", "RELOAD MODS", RIGHT_COLUMN + CARD_PADDING, ModsTop, function ( menu, controller )
		-- reload with killserver
		CoD.VM_ReloadMods()
	end )

	Add( NewHint( RIGHT_COLUMN + CARD_PADDING + BUTTON_WIDTH + 24, RIGHT_COLUMN + COLUMN_WIDTH - CARD_PADDING, ModsTop + 4, "Loads every Shield mod again and restarts the menus." ) )

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
	f8_arg0.CommonHeader:close()
	f8_arg0.TabBacking:close()

	f8_arg0.PrestigeEditBox:close()
	f8_arg0.RankEditBox:close()
	f8_arg0.NameEditBox:close()

	for _, element in ipairs( f8_arg0.Parts ) do
		element:close()
	end
	for _, button in ipairs( f8_arg0.Buttons ) do
		button:close()
	end
end

---------------------------

--[[
	The frame of the settings menus this one opens (unlock all, fov and aim assist, misc, watermark):
	the screen behind goes dark, and a card 1024 wide stands in its middle. Left in the card the settings,
	right of them what the one in focus does, with room under it for the buttons of a menu; at the foot
	the prompts and "close". Places are from the middle of the screen, as those menus count.

	options: title, caption, color { r, g, b }, rows (settings shown), spacing between two of them (3),
	extra (buttons under the description). A menu reads listLeft, listTop, listHeight, rightLeft,
	rightRight, descTop and extraTop of the frame to place its own things.
]]
local FRAME_HALF = 512
local FRAME_PADDING = 28
local FRAME_HEADER = 112
local FRAME_FOOT = 100
local FRAME_ROW = 60
local FRAME_RIGHT = 132

CoD.ShieldSettingsFrame = InheritFrom( LUI.UIElement )
CoD.ShieldSettingsFrame.__defaultWidth = 1920
CoD.ShieldSettingsFrame.__defaultHeight = 1080

-- the settings side of the card: 500 wide for a gamepad, 580 with a mouse, as the rows are made
CoD.ShieldSettingsFrame.LIST_LEFT = -FRAME_HALF + FRAME_PADDING
CoD.ShieldSettingsFrame.LIST_RIGHT = CoD.ShieldSettingsFrame.LIST_LEFT + 500
CoD.ShieldSettingsFrame.LIST_RIGHT_KBM = CoD.ShieldSettingsFrame.LIST_LEFT + 580
CoD.ShieldSettingsFrame.RIGHT_LEFT = FRAME_RIGHT
CoD.ShieldSettingsFrame.RIGHT_RIGHT = FRAME_HALF - FRAME_PADDING

CoD.ShieldSettingsFrame.new = function ( menu, controller, options )
	local self = LUI.UIElement.new( 0, 1, 0, 0, 0, 1, 0, 0 )
	self:setClass( CoD.ShieldSettingsFrame )
	self.id = "ShieldSettingsFrame"
	self.soundSet = "default"
	self.onlyChildrenFocusable = true
	self.anyChildUsesUpdateState = true

	local color = options.color or { r = 0.35, g = 0.75, b = 1 }
	local rows = options.rows or 4
	local spacing = options.spacing or 3
	local extra = options.extra or 0

	local listHeight = rows * FRAME_ROW + ( rows - 1 ) * spacing
	-- the right side needs its room too: the description, and the buttons under it
	local body = math.max( listHeight, 190 + extra * 62 )
	local top = -math.floor( ( FRAME_HEADER + body + FRAME_FOOT ) / 2 )
	local bottom = top + FRAME_HEADER + body + FRAME_FOOT

	self.listLeft = CoD.ShieldSettingsFrame.LIST_LEFT
	self.listTop = top + FRAME_HEADER
	self.listHeight = listHeight
	self.rightLeft = CoD.ShieldSettingsFrame.RIGHT_LEFT
	self.rightRight = CoD.ShieldSettingsFrame.RIGHT_RIGHT
	self.descTop = top + FRAME_HEADER + 26
	self.extraTop = top + FRAME_HEADER + body - extra * 62 + 12

	self.Parts = {}

	local function Add( element )
		self:addElement( element )
		table.insert( self.Parts, element )
		return element
	end

	local function Box( left, right, boxTop, boxBottom, r, g, b, alpha )
		local box = LUI.UIImage.new( 0.5, 0.5, left, right, 0.5, 0.5, boxTop, boxBottom )
		box:setRGB( r, g, b )
		box:setAlpha( alpha )
		return Add( box )
	end

	local function Text( left, right, textTop, size, font )
		local text = LUI.UIText.new( 0.5, 0.5, left, right, 0.5, 0.5, textTop, textTop + size )
		text:setTTF( font )
		text:setAlignment( Enum[@"luialignment"][@"lui_alignment_left"] )
		text:setAlignment( Enum[@"luialignment"][@"lui_alignment_top"] )
		return Add( text )
	end

	local function Caption( left, right, textTop, words )
		local text = Text( left, right, textTop, 15, "ttmussels_regular" )
		text:setRGB( 0.55, 0.55, 0.55 )
		text:setLetterSpacing( 2 )
		text:setText( words )
		return text
	end

	-- the menu behind goes dark
	local Dim = LUI.UIImage.new( 0, 1, -5, 5, 0, 1, -5, 5 )
	Dim:setRGB( 0, 0, 0 )
	Dim:setAlpha( 0.7 )
	Add( Dim )

	-- the card
	Box( -FRAME_HALF, FRAME_HALF, top, bottom, 0.06, 0.06, 0.06, 0.96 )
	Box( -FRAME_HALF, FRAME_HALF, top, top + 4, color.r, color.g, color.b, 1 )

	local Frame = LUI.UIImage.new( 0.5, 0.5, -FRAME_HALF - 1, FRAME_HALF + 1, 0.5, 0.5, top - 1, bottom + 1 )
	Frame:setAlpha( 0.2 )
	Frame:setImage( RegisterImage( @"uie_ui_menu_store_common_frame" ) )
	Frame:setMaterial( LUI.UIImage.GetCachedMaterial( @"uie_nineslice_add" ) )
	Frame:setShaderVector( 0, 0, 0, 0, 0 )
	Frame:setupNineSliceShader( 12, 12 )
	Add( Frame )

	Caption( self.listLeft, self.rightRight, top + 24, options.caption or "" )

	local Title = Text( self.listLeft, self.rightRight, top + 44, 34, "notosans_bold" )
	Title:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )
	Title:setText( options.title or "" )
	self.TitleText = Title

	Box( self.listLeft, self.rightRight, top + 94, top + 95, 1, 1, 1, 0.1 )

	-- between the settings and what they do
	Box( FRAME_RIGHT - 18, FRAME_RIGHT - 17, top + FRAME_HEADER, top + FRAME_HEADER + body, 1, 1, 1, 0.1 )
	Caption( self.rightLeft, self.rightRight, top + FRAME_HEADER, "WHAT IT DOES" )

	-- the foot: the prompts of the menu, and "close" for a mouse
	Box( self.listLeft, self.rightRight, top + FRAME_HEADER + body + 20, top + FRAME_HEADER + body + 21, 1, 1, 1, 0.1 )

	local buttons = CoD.fe_LeftContainer_NOTLobby.new( menu, controller, 0.5, 0.5, self.listLeft, self.listLeft + 648, 0.5, 0.5, bottom - 64, bottom - 16 )
	self:addElement( buttons )
	self.buttons = buttons

	local featureOverlayButtonMouseOnly = CoD.featureOverlay_Button.new( menu, controller, 0.5, 0.5, self.rightRight - 186, self.rightRight, 0.5, 0.5, bottom - 70, bottom - 10 )
	featureOverlayButtonMouseOnly.ButtonContainer.Title:setText( Engine[@"hash_4F9F1239CFD921FE"]( @"hash_778D439E1B360368" ) )
	featureOverlayButtonMouseOnly:registerEventHandler( "gain_focus", function ( element, event )
		local f2_local0 = nil
		if element.gainFocus then
			f2_local0 = element:gainFocus( event )
		elseif element.super.gainFocus then
			f2_local0 = element.super:gainFocus( event )
		end
		CoD.Menu.UpdateButtonShownState( element, menu, controller, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
		return f2_local0
	end )
	menu:AddButtonCallbackFunction( featureOverlayButtonMouseOnly, controller, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], "ui_confirm", function ( element, menu, controller, model )
		GoBack( self, controller )
		return true
	end, function ( element, menu, controller )
		CoD.Menu.SetButtonLabel( menu, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], @"hash_0", nil, "ui_confirm" )
		return false
	end, false )
	self:addElement( featureOverlayButtonMouseOnly )
	self.featureOverlayButtonMouseOnly = featureOverlayButtonMouseOnly

	buttons.id = "buttons"
	featureOverlayButtonMouseOnly.id = "featureOverlayButtonMouseOnly"

	LUI.OverrideFunction_CallOriginalSecond( self, "close", self.__onClose )

	return self
end

CoD.ShieldSettingsFrame.__onClose = function ( f8_arg0 )
	for _, element in ipairs( f8_arg0.Parts ) do
		element:close()
	end
	f8_arg0.buttons:close()
	f8_arg0.featureOverlayButtonMouseOnly:close()
end

---------------------------

--[[
	The bot settings: how good the bots of multiplayer are, read by the scripts of the mod when a match
	starts (BotSkill.gsc). Each is a dvar kept in the config under "lua": the name of the dvar, its key
	there, what it is when nothing was picked, and its choices by their number.
]]
local BotSettings = {
	{
		dvar = "shield_bot_skill", key = "bot_skill", default = 0, name = @"shield/bot_skill", desc = @"shield/bot_skill_desc",
		choices = { "Game Default", "Recruit", "Regular", "Hardened", "Veteran", "Ruthless" }
	},
	{
		dvar = "shield_bot_aim", key = "bot_aim", default = 0, name = @"shield/bot_aim", desc = @"shield/bot_aim_desc",
		choices = { "By Skill", "Sloppy", "Steady", "Sharp", "Deadly", "Aimbot" }
	},
	{
		dvar = "shield_bot_reaction", key = "bot_reaction", default = 0, name = @"shield/bot_reaction", desc = @"shield/bot_reaction_desc",
		choices = { "By Skill", "Slow", "Normal", "Fast", "Very Fast", "Instant" }
	},
	{
		dvar = "shield_bot_awareness", key = "bot_awareness", default = 0, name = @"shield/bot_awareness", desc = @"shield/bot_awareness_desc",
		choices = { "By Skill", "Tunnel Vision", "Normal", "Alert", "Sharp", "Sees All Around" }
	},
	{
		dvar = "shield_bot_headshots", key = "bot_headshots", default = 0, name = @"shield/bot_headshots", desc = @"shield/bot_headshots_desc",
		choices = { "By Skill", "Never", "Rare", "Sometimes", "Often", "Very Often" }
	},
	{
		dvar = "shield_bot_objectives", key = "bot_objectives", default = 1, name = @"shield/bot_objectives", desc = @"shield/bot_objectives_desc",
		choices = { "Game Default", "Always" }
	}
}

-- what was picked before, out of the config
for _, setting in ipairs( BotSettings ) do
	Engine[@"exec"]( Engine[@"getprimarycontroller"](), "readjson " .. setting.dvar .. " lua " .. setting.key .. " uint64_t " .. setting.default )
end

-- a choice was made: the dvar, and the config for the next start of the game
local function OnBotSettingChange( f137_arg0, f137_arg1, f137_arg2, f137_arg3, f137_arg4 )
	local dvar_name = f137_arg3
	local current_val = f137_arg1.value
	CoD.OptionsUtility.UpdateInfoModels( f137_arg1 )

	if current_val == Engine[@"getdvarint"]( dvar_name ) then
		return
	end

	Engine[@"setdvar"]( dvar_name, current_val )

	for _, setting in ipairs( BotSettings ) do
		if setting.dvar == dvar_name then
			Engine[@"exec"]( Engine[@"getprimarycontroller"](), "writejson lua " .. setting.key .. " " .. current_val .. " uint64_t" )
		end
	end
end

DataSources.ShieldBotSkillSettings = DataSourceHelpers.ListSetup( "ShieldBotSkillSettings", function ( f138_arg0 )
	local data = {}

	for _, setting in ipairs( BotSettings ) do
		local options = {}

		for index, choice in ipairs( setting.choices ) do
			table.insert( options, {
				option = choice,
				value = index - 1,
				default = index - 1 == setting.default
			} )
		end

		table.insert( data, CoD.OptionsUtility.CreateDvarSettings( f138_arg0, setting.name, setting.desc, setting.dvar, setting.dvar, options, nil, OnBotSettingChange ) )
	end

	return data
end, nil, nil, function ( f139_arg0, f139_arg1, f139_arg2 )
	local f139_local0 = Engine[@"createmodel"]( Engine[@"getglobalmodel"](), "GametypeSettings.Update" )
	if f139_arg1.updateSubscription then
		f139_arg1:removeSubscription( f139_arg1.updateSubscription )
	end
	f139_arg1.updateSubscription = f139_arg1:subscribeToModel( f139_local0, function ()
		f139_arg1:updateDataSource()
	end, false )
end )

-- the menu of the bot settings: as the other settings menus, see CoD.ShieldSettingsFrame
CoD.Shield_Bot_SettingsPopup = InheritFrom( CoD.Menu )
LUI.createMenu.Shield_Bot_SettingsPopup = function ( f1_arg0, f1_arg1 )
	local self = CoD.Menu.NewForUIEditor( "Shield_Bot_SettingsPopup", f1_arg0 )
	local f1_local1 = self
	self:setClass( CoD.Shield_Bot_SettingsPopup )
	self.soundSet = "none"
	self:setOwner( f1_arg0 )
	self:setLeftRight( 0, 1, 0, 0 )
	self:setTopBottom( 0, 1, 0, 0 )
	self:playSound( "menu_open", f1_arg0 )
	self.anyChildUsesUpdateState = true
	f1_local1:addElementToPendingUpdateStateList( self )

	local CommomCenteredPopup = CoD.ShieldSettingsFrame.new( f1_local1, f1_arg0, {
		title = "Bots",
		caption = "HOW GOOD THE BOTS OF MULTIPLAYER ARE",
		color = { r = 1, g = 0.38, b = 0.28 },
		rows = #BotSettings
	} )
	self:addElement( CommomCenteredPopup )
	self.CommomCenteredPopup = CommomCenteredPopup

	local BotSettingsList = LUI.UIList.new( f1_local1, f1_arg0, 3, 3, nil, false, false, false, false )
	BotSettingsList:setLeftRight( 0.5, 0.5, CoD.ShieldSettingsFrame.LIST_LEFT, CoD.ShieldSettingsFrame.LIST_RIGHT )
	BotSettingsList:setTopBottom( 0.5, 0.5, CommomCenteredPopup.listTop, CommomCenteredPopup.listTop + CommomCenteredPopup.listHeight )
	BotSettingsList:setAutoScaleContent( true )
	BotSettingsList:setVerticalCount( #BotSettings )
	BotSettingsList:setHorizontalCount( 1 )
	BotSettingsList:setWidgetType( CoD.CustomGames_SettingSliderNoCustom )
	BotSettingsList:setAlignment( Enum[@"luialignment"][@"lui_alignment_left"] )
	BotSettingsList:setDataSource( "ShieldBotSkillSettings" )
	self:addElement( BotSettingsList )
	self.BotSettingsList = BotSettingsList

	if Engine[@"getdvarint"]("shield_ui_color") == 0 then
		BotSettingsList:setRGB(0, 1, 1)
	elseif Engine[@"getdvarint"]("shield_ui_color") == 1 then
		BotSettingsList:setRGB(1, 0, 0)
	elseif Engine[@"getdvarint"]("shield_ui_color") == 2 then
		BotSettingsList:setRGB(0, 1, 0)
	end

	local SettingDescription = LUI.UIText.new( 0.5, 0.5, CoD.ShieldSettingsFrame.RIGHT_LEFT, CoD.ShieldSettingsFrame.RIGHT_RIGHT, 0.5, 0.5, CommomCenteredPopup.descTop, CommomCenteredPopup.descTop + 21 )
	SettingDescription:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )
	SettingDescription:setTTF( "notosans_regular" )
	SettingDescription:setAlignment( Enum[@"luialignment"][@"lui_alignment_left"] )
	SettingDescription:setAlignment( Enum[@"luialignment"][@"lui_alignment_top"] )
	self:addElement( SettingDescription )
	self.SettingDescription = SettingDescription

	SettingDescription:linkToElementModel( BotSettingsList, "desc", true, function ( model )
		local f7_local0 = model:get()
		if f7_local0 ~= nil then
			SettingDescription:setText( Engine[@"hash_4F9F1239CFD921FE"]( f7_local0 ) )
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
	BotSettingsList.id = "BotSettingsList"
	self:processEvent( {
		name = "menu_loaded",
		controller = f1_arg0
	} )
	self.__defaultFocus = BotSettingsList
	if CoD.isPC and (IsKeyboard( f1_arg0 ) or self.ignoreCursor) then
		self:restoreState( f1_arg0 )
	end
	LUI.OverrideFunction_CallOriginalSecond( self, "close", self.__onClose )
	if PostLoadFunc then
		PostLoadFunc( self, f1_arg0 )
	end

	CoD.EnhPrintInfo("Called", "Shield's Bot Settings Menu")

	return self
end

CoD.Shield_Bot_SettingsPopup.__resetProperties = function ( f13_arg0 )
	f13_arg0.BotSettingsList:completeAnimation()
	f13_arg0.BotSettingsList:setLeftRight( 0.5, 0.5, CoD.ShieldSettingsFrame.LIST_LEFT, CoD.ShieldSettingsFrame.LIST_RIGHT )
end

CoD.Shield_Bot_SettingsPopup.__clipsPerState = {
	DefaultState = {
		DefaultClip = function ( f14_arg0, f14_arg1 )
			f14_arg0:__resetProperties()
			f14_arg0:setupElementClipCounter( 0 )
		end
	},
	KBM = {
		DefaultClip = function ( f15_arg0, f15_arg1 )
			f15_arg0:__resetProperties()
			f15_arg0:setupElementClipCounter( 1 )
			f15_arg0.BotSettingsList:completeAnimation()
			f15_arg0.BotSettingsList:setLeftRight( 0.5, 0.5, CoD.ShieldSettingsFrame.LIST_LEFT, CoD.ShieldSettingsFrame.LIST_RIGHT_KBM )
			f15_arg0.clipFinished( f15_arg0.BotSettingsList )
		end
	}
}

CoD.Shield_Bot_SettingsPopup.__onClose = function ( f16_arg0 )
	f16_arg0.SettingDescription:close()
	f16_arg0.CommomCenteredPopup:close()
	f16_arg0.BotSettingsList:close()
end
