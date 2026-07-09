--[[
		.\hksc.exe ".\Lua\ExtraCamos.Lua" -o "C:\Program Files (x86)\Call of Duty Black Ops 4\project-bo4\mods\T8ShieldSupport\Lua\ExtraCamos.luac"
]]

---------------------------

CoD.ShieldInitLuaFile()

---------------------------

local ApplyExtraCamo = function(Controller, CamoIndex, Menu)
	local f61_local2, f61_local3, f61_local4 = CoD.BaseUtility.GetMenuModelModeLoadoutSlot( Menu )
	local session_mode = CoD.BaseUtility.GetMenuSessionMode( Menu )
	local f361_local1 = nil

	-- for visual
	if session_mode == Enum[@"emodes"][@"mode_multiplayer"] then
		f61_local2[f61_local4]["camoIndex"]:set(CamoIndex)
	elseif session_mode == Enum[@"emodes"][@"mode_warzone"] then
		local f361_local0 = Menu._model
		if f361_local0 then
			f361_local0 = Menu._model.itemIndex:get()
		end

		local f361_local1 = CoD.WZUtility.GetVariantSlot( Controller, f361_local0, false )
		f361_local1["camoIndex"]:set(CamoIndex)
	elseif session_mode == Enum[@"emodes"][@"mode_zombies"] then
		local f361_local0 = Menu._model
		if f361_local0 then
			f361_local0 = Menu._model.itemIndex:get()
		end

		local f361_local1 = CoD.ZMLoadoutUtility.GetVariantSlot( Controller, f361_local0, false )
		f361_local1["camoIndex"]:set(CamoIndex)
	end

	-- for saving it
	if session_mode == Enum[@"emodes"][@"mode_multiplayer"] then
		CoD.CACUtility.SetClassItem( Controller, f61_local2.classNum:get(), CoD.CACUtility.GetBaseWeaponLoadoutSlotName( f61_local4 ) .. ".camoIndex", CamoIndex )
	elseif session_mode == Enum[@"emodes"][@"mode_warzone"] then
		--CoD.CACUtility.SetClassItem( Controller, f61_local2.classNum:get(), CoD.CACUtility.GetBaseWeaponLoadoutSlotName( f61_local4 ) .. ".camoIndex", CamoIndex )
	end
end

local IsWeaponOptionEquippedCustom = function ( f61_arg0, f61_arg1, f61_arg2, f61_arg3 )
	local f61_local0 = CoD.BaseUtility.GetMenuSessionMode( f61_arg0 )
	if f61_local0 == Enum[@"emodes"][@"mode_zombies"] then
		return CoD.ZMLoadoutUtility.IsWeaponOptionEquipped( f61_arg0, f61_arg1, f61_arg2, f61_arg3 )
	elseif f61_local0 == Enum[@"emodes"][@"mode_warzone"] then
		return CoD.WZUtility.IsWeaponOptionEquipped( f61_arg0, f61_arg1, f61_arg2, f61_arg3 )
	end
	local f61_local1 = f61_arg1:getModel()
	local f61_local2, f61_local3, f61_local4 = CoD.BaseUtility.GetMenuModelModeLoadoutSlot( f61_arg0 )
	if f61_local1 and f61_local2[f61_local4] and f61_local2[f61_local4][f61_arg3] then
		local f61_local5 = f61_local2[f61_local4][f61_arg3]:get()
		local f61_local6 = f61_local1.camoIndex:get()

		if f61_local6 ~= f61_local5 then
			return false
		else
			return true
		end
	end
	return false
end

---------------------------

DataSources.WeaponOptionsCamoCategories = DataSourceHelpers.ListSetup( "WeaponOptionsCamoCategories", function ( f41_arg0, f41_arg1 )
	local f41_local0 = {}
	local f41_local1 = {
		refHash = @"camo_base",
		name = @"mpui/camo"
	}
	local f41_local2 = DataSources.LoadoutBreadcrumbs.getModel( f41_arg0 )
	f41_local1.breadcrumb = f41_local2.basiccamo
	f41_local1.frameWidget = "CoD.CamoListSelectionWidget"
	f41_local1.selectIndex = true
	f41_local2 = {
		refHash = @"hash_54675E6BE6454E41",
		name = @"hash_52EEF729B41D6347"
	}
	local f41_local3 = DataSources.LoadoutBreadcrumbs.getModel( f41_arg0 )
	f41_local2.breadcrumb = f41_local3.activecamo
	f41_local2.frameWidget = "CoD.ActiveCamoListSelectionWidget"
	f41_local0[1] = f41_local1
	f41_local0[2] = f41_local2
	f41_local3 = CoD.WeaponOptionsUtility.WeaponCannotGetHeadshots( CoD.BaseUtility.GetMenuSessionMode( f41_arg1.menu ), CoD.GetCustomization( f41_arg0, "weapon_index" ) )
	local f41_local4 = {}
	for f41_local8, f41_local9 in ipairs( f41_local0 ) do
		if f41_local9.refHash ~= @"hash_54675E6BE6454E41" or not f41_local3 then
			table.insert( f41_local4, {
				models = {
					name = f41_local9.name,
					frameWidget = f41_local9.frameWidget,
					breadcrumb = f41_local9.breadcrumb
				},
				properties = {
					refHash = f41_local9.refHash,
					selectIndex = f41_local9.selectIndex
				}
			} )
		end
	end

	table.insert( f41_local4, {
		models = {
			name = @"shield/reactive_settings_tab",
			frameWidget = "CoD.ShieldReativesSettingsTab",
			breadcrumb = nil
		},
		properties = {
			refHash = f41_local1.refHash,
			selectIndex = f41_local1.selectIndex
		}
	} )

	table.insert( f41_local4, {
		models = {
			name = @"shield/extra_camos_tab",
			frameWidget = "CoD.ShieldExtraCamos",
			breadcrumb = nil
		},
		properties = {
			refHash = f41_local1.refHash,
			selectIndex = f41_local1.selectIndex
		}
	} )

	return f41_local4
end, true )

DataSources.ShieldExtraCamosList = DataSourceHelpers.ListSetup( "ShieldExtraCamosList", function ( f41_arg0, f41_arg1 )
	local array_list = {}

	local function addCamo( list, camoIndex, name, image )
		table.insert( list, {
			models = {
				name = name,
				image = image or @"compassping_enemy_diamond_bottom",
				camoIndex = camoIndex,
				weaponOptionSubIndex = camoIndex,
				weaponOptionType = camoIndex,
				unlockDescription = "",
				weaponOptionTypeName = "",
				weaponOptionCategory = "",
			},
			properties = {}
		} )
	end

	-- ETC, done in other option
	--addCamo( array_list, 199, "Diamond (Last tier)", @"menu_camo_diamond_pattern")
	--addCamo( array_list, 192, "Dark matter (Last tier)", @"menu_camo_darkmatter_pattern")

	-- PAP CAMOS
	addCamo( array_list, 151, "IX Blue", @"t8_menu_zm_loadscreen_dlc0")
	addCamo( array_list, 152, "IX Red", @"t8_menu_zm_loadscreen_dlc0")
	addCamo( array_list, 153, "IX Green", @"t8_menu_zm_loadscreen_dlc0")
	addCamo( array_list, 154, "IX Purple", @"t8_menu_zm_loadscreen_dlc0")
	addCamo( array_list, 155, "IX Orange", @"t8_menu_zm_loadscreen_dlc0")
	addCamo( array_list, 146, "Voyage of despair purple", @"t8_menu_zm_loadscreen_zodt8")
	addCamo( array_list, 147, "Voyage of despair red", @"t8_menu_zm_loadscreen_zodt8")
	addCamo( array_list, 148, "Voyage of despair green", @"t8_menu_zm_loadscreen_zodt8")
	addCamo( array_list, 149, "Voyage of despair yellow", @"t8_menu_zm_loadscreen_zodt8")
	addCamo( array_list, 150, "Voyage of despair pink", @"t8_menu_zm_loadscreen_zodt8")
	addCamo( array_list, 156, "Blood of the Dead yellow", @"t8_menu_zm_loadscreen_escape")
	addCamo( array_list, 157, "Blood of the Dead red", @"t8_menu_zm_loadscreen_escape")
	addCamo( array_list, 158, "Blood of the Dead yellow", @"t8_menu_zm_loadscreen_escape")
	addCamo( array_list, 159, "Blood of the Dead green", @"t8_menu_zm_loadscreen_escape")
	addCamo( array_list, 160, "Blood of the Dead purple", @"t8_menu_zm_loadscreen_escape")
	addCamo( array_list, 161, "Classified 1", @"t8_menu_zm_loadscreen_office")
	addCamo( array_list, 162, "Classified 2", @"t8_menu_zm_loadscreen_office")
	addCamo( array_list, 163, "Classified 3", @"t8_menu_zm_loadscreen_office")
	addCamo( array_list, 164, "Classified 4", @"t8_menu_zm_loadscreen_office")
	addCamo( array_list, 165, "Classified 5", @"t8_menu_zm_loadscreen_office")
	addCamo( array_list, 280, "Dead of the night green", @"t8_menu_zm_loadscreen_mansion")
	addCamo( array_list, 281, "Dead of the night purple", @"t8_menu_zm_loadscreen_mansion")
	addCamo( array_list, 282, "Dead of the night red", @"t8_menu_zm_loadscreen_mansion")
	addCamo( array_list, 283, "Dead of the night blue", @"t8_menu_zm_loadscreen_mansion")
	addCamo( array_list, 284, "Dead of the night orange", @"t8_menu_zm_loadscreen_mansion")
	addCamo( array_list, 74, "Ancient Evil purple", @"t8_menu_zm_loadscreen_red")
	addCamo( array_list, 75, "Ancient Evil blue", @"t8_menu_zm_loadscreen_red")
	addCamo( array_list, 76, "Ancient Evil orange", @"t8_menu_zm_loadscreen_red")
	addCamo( array_list, 77, "Ancient Evil yellow", @"t8_menu_zm_loadscreen_red")
	addCamo( array_list, 78, "Ancient Evil green", @"t8_menu_zm_loadscreen_red")
	addCamo( array_list, 345, "Alpha Omega", @"hash_c13a3bf6f2906c8e")
	addCamo( array_list, 394, "Tag der toten", @"t8_menu_zm_loadscreen_orange")

	return array_list
end, true )

---------------------------

CoD.ShieldExtraCamos = InheritFrom( LUI.UIElement )
CoD.ShieldExtraCamos.__defaultWidth = 1214
CoD.ShieldExtraCamos.__defaultHeight = 400
CoD.ShieldExtraCamos.new = function ( f1_arg0, f1_arg1, f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	local self = LUI.UIElement.new( f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	self:setClass( CoD.ShieldExtraCamos )
	self.id = "ShieldExtraCamos"
	self.soundSet = "none"
	self.onlyChildrenFocusable = true
	self.anyChildUsesUpdateState = true
	f1_arg0:addElementToPendingUpdateStateList( self )
	
	local Backing = LUI.UIImage.new( 0, 1, 0, 0, 0, 1, 0, 0 )
	Backing:setRGB( 0, 0, 0 )
	Backing:setAlpha( 0 )
	self:addElement( Backing )
	self.Backing = Backing

	local ShieldCamosList = CoD.ShieldCamosList.new( f1_arg0, f1_arg1, 0, 0, 0, 1214, 0, 0, 24, 374 )
	ShieldCamosList:setAlpha( 0 )
	ShieldCamosList.Label:setText( "EXTRA/UNUSED CAMOS" )
	self:addElement( ShieldCamosList )
	self.ShieldCamosList = ShieldCamosList
	
	self:mergeStateConditions( {
		{
			stateName = "NotLive",
			condition = function ( menu, element, event )
				return not IsLive()
			end
		},
		{
			stateName = "BlackMarket",
			condition = function ( menu, element, event )
				return CoD.WeaponOptionsUtility.IsBlackMarketCamoFilter()
			end
		},
		{
			stateName = "NotCurrentModeFilter",
			condition = function ( menu, element, event )
				return not CoD.WeaponOptionsUtility.IsInCurrentModeFilter( menu, self, f1_arg1 )
			end
		},
		{
			stateName = "TempHideZMMastery",
			condition = function ( menu, element, event )
				return CoD.WeaponOptionsUtility.ShouldHideMasteryCamos( menu )
			end
		}
	} )
	local f1_local7 = self
	local f1_local8 = self.subscribeToModel
	local f1_local9 = Engine[@"getglobalmodel"]()
	f1_local8( f1_local7, f1_local9["lobbyRoot.lobbyNetworkMode"], function ( f7_arg0 )
		f1_arg0:updateElementState( self, {
			name = "model_validation",
			menu = f1_arg0,
			controller = f1_arg1,
			modelValue = f7_arg0:get(),
			modelName = "lobbyRoot.lobbyNetworkMode"
		} )
	end, false )
	f1_local7 = self
	f1_local8 = self.subscribeToModel
	f1_local9 = Engine[@"getglobalmodel"]()
	f1_local8( f1_local7, f1_local9["lobbyRoot.lobbyNav"], function ( f8_arg0 )
		f1_arg0:updateElementState( self, {
			name = "model_validation",
			menu = f1_arg0,
			controller = f1_arg1,
			modelValue = f8_arg0:get(),
			modelName = "lobbyRoot.lobbyNav"
		} )
	end, false )
	f1_local7 = self
	f1_local8 = self.subscribeToModel
	f1_local9 = Engine[@"getmodelforcontroller"]( f1_arg1 )
	f1_local8( f1_local7, f1_local9["WeaponPersonalization.listUpdate"], function ( f9_arg0 )
		f1_arg0:updateElementState( self, {
			name = "model_validation",
			menu = f1_arg0,
			controller = f1_arg1,
			modelValue = f9_arg0:get(),
			modelName = "WeaponPersonalization.listUpdate"
		} )
	end, false )
	LUI.OverrideFunction_CallOriginalFirst( self, "setState", function ( element, controller, f10_arg2, f10_arg3, f10_arg4 )
		if IsSelfInState( self, "BlackMarket" ) then
			CoD.BaseUtility.SetDefaultFocusToElement( self, self.ShieldCamosList )
		end
	end )
	ShieldCamosList.id = "ShieldCamosList"
	self.__defaultFocus = ShieldCamosList
	LUI.OverrideFunction_CallOriginalSecond( self, "close", self.__onClose )
	
	if PostLoadFunc then
		PostLoadFunc( self, f1_arg1, f1_arg0 )
	end
	
	return self
end

CoD.ShieldExtraCamos.__resetProperties = function ( f11_arg0 )
	f11_arg0.ShieldCamosList:completeAnimation()
	f11_arg0.ShieldCamosList:setAlpha( 0 )
end

CoD.ShieldExtraCamos.__clipsPerState = {
	DefaultState = {
		DefaultClip = function ( f12_arg0, f12_arg1 )
			f12_arg0:__resetProperties()
			f12_arg0:setupElementClipCounter( 0 )
		end
	},
	NotLive = {
		DefaultClip = function ( f13_arg0, f13_arg1 )
			f13_arg0:__resetProperties()
			f13_arg0:setupElementClipCounter( 2 )
		end
	},
	BlackMarket = {
		DefaultClip = function ( f14_arg0, f14_arg1 )
			f14_arg0:__resetProperties()
			f14_arg0:setupElementClipCounter( 5 )
			f14_arg0.ShieldCamosList:completeAnimation()
			f14_arg0.ShieldCamosList:setAlpha( 1 )
			f14_arg0.clipFinished( f14_arg0.ShieldCamosList )
		end
	},
	NotCurrentModeFilter = {
		DefaultClip = function ( f15_arg0, f15_arg1 )
			f15_arg0:__resetProperties()
			f15_arg0:setupElementClipCounter( 2 )
		end
	},
	TempHideZMMastery = {
		DefaultClip = function ( f16_arg0, f16_arg1 )
			f16_arg0:__resetProperties()
			f16_arg0:setupElementClipCounter( 2 )
		end
	}
}

CoD.ShieldExtraCamos.__onClose = function ( f18_arg0 )
	f18_arg0.ShieldCamosList:close()
end

CoD.ShieldCamosList = InheritFrom( LUI.UIElement )
CoD.ShieldCamosList.__defaultWidth = 1214
CoD.ShieldCamosList.__defaultHeight = 350
CoD.ShieldCamosList.new = function ( f1_arg0, f1_arg1, f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	local self = LUI.UIElement.new( f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	self:setClass( CoD.ShieldCamosList )
	self.id = "ShieldCamosList"
	self.soundSet = "none"
	self.onlyChildrenFocusable = true
	self.anyChildUsesUpdateState = true

	local ExtraCamosList = LUI.UIList.new( f1_arg0, f1_arg1, 10, 0, nil, false, false, false, false )
	ExtraCamosList:mergeStateConditions( {
		{
			stateName = "Equipped",
			condition = function ( menu, element, event )
				return IsWeaponOptionEquippedCustom( menu, element, f1_arg1, "camoIndex" )
			end
		},
		{
			stateName = "New",
			condition = function ( menu, element, event )
				return AlwaysFalse()
			end
		}
	} )
	ExtraCamosList:setLeftRight( 0, 0, 12, 1202 )
	ExtraCamosList:setTopBottom( 0, 0, 40, 300 )
	ExtraCamosList:setWidgetType( CoD.ShieldCamoSlot )
	ExtraCamosList:setHorizontalCount( 10 )
	ExtraCamosList:setVerticalCount( 3 )
	ExtraCamosList:setSpacing( 10 )
	ExtraCamosList:setAlignment( Enum[@"luialignment"][@"lui_alignment_left"] )
	ExtraCamosList:setDataSource( "ShieldExtraCamosList" )
	ExtraCamosList:linkToElementModel( ExtraCamosList, "itemIndex", true, function ( model, f4_arg1 )
		CoD.Menu.UpdateButtonShownState( f4_arg1, f1_arg0, f1_arg1, Enum[@"luibutton"][@"lui_key_xba_pscross"] )
	end )
	ExtraCamosList:appendEventHandler( "input_source_changed", function ( f5_arg0, f5_arg1 )
		f5_arg1.menu = f5_arg1.menu or f1_arg0
		CoD.Menu.UpdateButtonShownState( f5_arg0, f1_arg0, f1_arg1, Enum[@"luibutton"][@"lui_key_xbx_pssquare"] )
		CoD.Menu.UpdateButtonShownState( f5_arg0, f1_arg0, f1_arg1, Enum[@"luibutton"][@"hash_64D2505E19049444"] )
	end )
	local BottomBracket9Slice = ExtraCamosList
	local Label = ExtraCamosList.subscribeToModel
	local f1_local4 = Engine[@"getmodelforcontroller"]( f1_arg1 )
	Label( BottomBracket9Slice, f1_local4.LastInput, function ( f6_arg0, f6_arg1 )
		CoD.Menu.UpdateButtonShownState( f6_arg1, f1_arg0, f1_arg1, Enum[@"luibutton"][@"lui_key_xbx_pssquare"] )
		CoD.Menu.UpdateButtonShownState( f6_arg1, f1_arg0, f1_arg1, Enum[@"luibutton"][@"hash_64D2505E19049444"] )
	end, false )
	ExtraCamosList:registerEventHandler( "list_item_gain_focus", function ( element, event )
		local f7_local0 = nil
		CoD.WeaponOptionsUtility.SetFocusedWeaponOptionModel( element, f1_arg1, f1_arg0 )
		CoD.CraftUtility.PreviewWeaponCamo( self, element, f1_arg1, f1_arg0 )
		return f7_local0
	end )
	ExtraCamosList:registerEventHandler( "list_item_lose_focus", function ( element, event )
		local f8_local0 = nil
		if IsElementInState( element, "New" ) then
			CoD.BreadcrumbUtility.SetWeaponCamoOld( f1_arg0, element, f1_arg1 )
			CoD.BreadcrumbUtility.UpdateWeaponCamoBreadcrumbs( f1_arg0, f1_arg1 )
		end
		return f8_local0
	end )
	ExtraCamosList:registerEventHandler( "lose_list_focus", function ( element, event )
		local f9_local0 = nil
		CoD.WeaponOptionsUtility.SetBaseWeaponOptions( element, f1_arg0, f1_arg1 )
		CoD.WeaponOptionsUtility.ClearWeaponOptionInfoModel( f1_arg0, f1_arg1, element )
		return f9_local0
	end )
	ExtraCamosList:registerEventHandler( "gain_focus", function ( element, event )
		local f10_local0 = nil
		if element.gainFocus then
			f10_local0 = element:gainFocus( event )
		elseif element.super.gainFocus then
			f10_local0 = element.super:gainFocus( event )
		end
		CoD.Menu.UpdateButtonShownState( element, f1_arg0, f1_arg1, Enum[@"luibutton"][@"lui_key_xba_pscross"] )
		CoD.Menu.UpdateButtonShownState( element, f1_arg0, f1_arg1, Enum[@"luibutton"][@"lui_key_xbx_pssquare"] )
		CoD.Menu.UpdateButtonShownState( element, f1_arg0, f1_arg1, Enum[@"luibutton"][@"hash_64D2505E19049444"] )
		return f10_local0
	end )

	f1_arg0:AddButtonCallbackFunction( ExtraCamosList, f1_arg1, Enum[@"luibutton"][@"lui_key_xba_pscross"], nil, function ( element, menu, controller, model )
		PlaySoundAlias( "cac_equipment_add" )

		local CamoIndexModel = element:getModel(model, "camoIndex")
		local CamoIndex = CamoIndexModel:get()

		if CamoIndex ~= nil then
			ApplyExtraCamo(controller, CamoIndex, menu)
			CoD.EnhPrintInfo("applied camo index: " .. CamoIndex)
		end

		UpdateSelfState( self, controller )
		UpdateAllMenuButtonPrompts( menu, controller )

		return true
	end, function ( element, menu, controller )
		CoD.Menu.SetButtonLabel( menu, Enum[@"luibutton"][@"lui_key_xba_pscross"], @"menu/select", nil, nil )
		return true
	end, false )

	-- remove
	f1_arg0:AddButtonCallbackFunction( ExtraCamosList, f1_arg1, Enum[@"luibutton"][@"hash_64D2505E19049444"], "ui_remove", function ( element, menu, controller, model )
		if IsWeaponOptionEquippedCustom( menu, element, f1_arg1, "camoIndex" ) then
			PlaySoundAlias( "cac_equipment_remove" )
			ApplyExtraCamo(controller, 0, menu)
			UpdateSelfState( self, controller )
			UpdateAllMenuButtonPrompts( menu, controller )

			return true
		end

		return false
	end, function ( element, menu, controller )
		if IsWeaponOptionEquippedCustom( menu, element, f1_arg1, "camoIndex" ) then
			CoD.Menu.SetButtonLabel( menu, Enum[@"luibutton"][@"hash_64D2505E19049444"], @"menu/remove", Enum[@"luibuttonpromptflags"][@"bpf_contextual"], "ui_remove" )
			return true
		end

		return false
	end, false )

	-- remove context
	ExtraCamosList:AddContextualMenuAction( f1_arg0, f1_arg1, @"menu/remove", function ( f18_arg0, f18_arg1, f18_arg2, f18_arg3 )
		if IsWeaponOptionEquippedCustom( f18_arg1, f18_arg0, f18_arg2, "camoIndex" ) then
			return function ( f19_arg0, f19_arg1, f19_arg2, f19_arg3 )
				PlaySoundAlias( "cac_equipment_remove" )
				ApplyExtraCamo(f1_arg1, 0, f18_arg1)
				UpdateSelfState( self, f1_arg1 )
				UpdateAllMenuButtonPrompts( f18_arg1, f1_arg1 )
			end
			
		else
			
		end
	end )

	ExtraCamosList:subscribeToGlobalModel( f1_arg1, "PerController", "WeaponPersonalization.listUpdate", function ( model )
		CoD.GridAndListUtility.UpdateDataSource( ExtraCamosList, true, false, true )
		UpdateSelfState( self, f1_arg1 )
	end )
	self:addElement( ExtraCamosList )
	self.ExtraCamosList = ExtraCamosList
	
	Label = LUI.UIText.new( 0, 0, 0.5, 340.5, 0, 0, 11, 27 )
	Label:setRGB( ColorSet.T8__OFF__GRAY.r, ColorSet.T8__OFF__GRAY.g, ColorSet.T8__OFF__GRAY.b )
	Label:setText( LocalizeToUpperString( @"hash_3F602F1BAFC731B5" ) )
	Label:setTTF( "default" )
	Label:setLetterSpacing( 4 )
	Label:setAlignment( Enum[@"luialignment"][@"lui_alignment_left"] )
	Label:setAlignment( Enum[@"luialignment"][@"lui_alignment_top"] )
	self:addElement( Label )
	self.Label = Label
	
	BottomBracket9Slice = LUI.UIImage.new( 0, 0, 0, 1214, 0, 0, 28, 37 )
	BottomBracket9Slice:setAlpha( 0.5 )
	BottomBracket9Slice:setZRot( 180 )
	BottomBracket9Slice:setImage( RegisterImage( @"hash_4C325BED3F226657" ) )
	BottomBracket9Slice:setMaterial( LUI.UIImage.GetCachedMaterial( @"uie_nineslice_add" ) )
	BottomBracket9Slice:setShaderVector( 0, 0, 0, 0, 0 )
	BottomBracket9Slice:setupNineSliceShader( 16, 4 )
	self:addElement( BottomBracket9Slice )
	self.BottomBracket9Slice = BottomBracket9Slice
	
	ExtraCamosList.id = "ExtraCamosList"
	self.__defaultFocus = ExtraCamosList
	LUI.OverrideFunction_CallOriginalSecond( self, "close", self.__onClose )
	if PreLoadFunc then
		PreLoadFunc( self, f1_arg1, f1_arg0 )
	end
	f1_local4 = self
	f1_local4 = ExtraCamosList
	if IsPC() then
		SetElementProperty( f1_local4, "_category", "lootbase" )
		CoD.PCWidgetUtility.SetupContextualMenu( f1_local4, f1_arg1, "name", "", "" )
	else
		SetElementProperty( f1_local4, "_category", "lootbase" )
	end
	return self
end

CoD.ShieldCamosList.__onClose = function ( f20_arg0 )
	f20_arg0.ExtraCamosList:close()
end

CoD.ShieldCamoSlot = InheritFrom( LUI.UIElement )
CoD.ShieldCamoSlot.__defaultWidth = 110
CoD.ShieldCamoSlot.__defaultHeight = 80
CoD.ShieldCamoSlot.new = function ( f1_arg0, f1_arg1, f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	local self = LUI.UIElement.new( f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	self:setClass( CoD.ShieldCamoSlot )
	self.id = "ShieldCamoSlot"
	self.soundSet = "none"
	self.onlyChildrenFocusable = true
	self.anyChildUsesUpdateState = true
	f1_arg0:addElementToPendingUpdateStateList( self )
	
	local ShieldCamoSlotInternal = CoD.ShieldCamoSlotInternal.new( f1_arg0, f1_arg1, 0, 1, 0, 0, 0, 1, 0, 0 )
	ShieldCamoSlotInternal:linkToElementModel( self, nil, false, function ( model )
		ShieldCamoSlotInternal:setModel( model, f1_arg1 )
	end )
	self:addElement( ShieldCamoSlotInternal )
	self.ShieldCamoSlotInternal = ShieldCamoSlotInternal
	
	ShieldCamoSlotInternal.id = "ShieldCamoSlotInternal"
	self.__defaultFocus = ShieldCamoSlotInternal

	LUI.OverrideFunction_CallOriginalSecond( self, "close", self.__onClose )
	
	if PostLoadFunc then
		PostLoadFunc( self, f1_arg1, f1_arg0 )
	end
	
	return self
end

CoD.ShieldCamoSlot.__resetProperties = function ( f10_arg0 )
	f10_arg0.ShieldCamoSlotInternal:completeAnimation()
	f10_arg0.ShieldCamoSlotInternal:setAlpha( 1 )
	f10_arg0.ShieldCamoSlotInternal:setScale( 1, 1 )
	f10_arg0.ShieldCamoSlotInternal.EquippedMarkerBG:setAlpha( 0 )
	f10_arg0.ShieldCamoSlotInternal.EquippedMarkerTick:setAlpha( 0 )
end

CoD.ShieldCamoSlot.__clipsPerState = {
	DefaultState = {
		DefaultClip = function ( f11_arg0, f11_arg1 )
			f11_arg0:__resetProperties()
			f11_arg0:setupElementClipCounter( 0 )
		end,
		ChildFocus = function ( f12_arg0, f12_arg1 )
			f12_arg0:__resetProperties()
			f12_arg0:setupElementClipCounter( 1 )
			f12_arg0.ShieldCamoSlotInternal:completeAnimation()
			f12_arg0.ShieldCamoSlotInternal:setScale( 1.05, 1.05 )
			f12_arg0.clipFinished( f12_arg0.ShieldCamoSlotInternal )
		end,
		GainChildFocus = function ( f13_arg0, f13_arg1 )
			f13_arg0:__resetProperties()
			f13_arg0:setupElementClipCounter( 1 )
			local f13_local0 = function ( f14_arg0 )
				f13_arg0.ShieldCamoSlotInternal:beginAnimation( 200, Enum[@"luitween"][@"luitween_ease_in"] )
				f13_arg0.ShieldCamoSlotInternal:setScale( 1.05, 1.05 )
				f13_arg0.ShieldCamoSlotInternal:registerEventHandler( "interrupted_keyframe", f13_arg0.clipInterrupted )
				f13_arg0.ShieldCamoSlotInternal:registerEventHandler( "transition_complete_keyframe", f13_arg0.clipFinished )
			end
			
			f13_arg0.ShieldCamoSlotInternal:completeAnimation()
			f13_arg0.ShieldCamoSlotInternal:setScale( 1, 1 )
			f13_local0( f13_arg0.ShieldCamoSlotInternal )
		end,
		LoseChildFocus = function ( f15_arg0, f15_arg1 )
			f15_arg0:__resetProperties()
			f15_arg0:setupElementClipCounter( 1 )
			local f15_local0 = function ( f16_arg0 )
				f15_arg0.ShieldCamoSlotInternal:beginAnimation( 200, Enum[@"luitween"][@"luitween_ease_out"] )
				f15_arg0.ShieldCamoSlotInternal:setScale( 1, 1 )
				f15_arg0.ShieldCamoSlotInternal:registerEventHandler( "interrupted_keyframe", f15_arg0.clipInterrupted )
				f15_arg0.ShieldCamoSlotInternal:registerEventHandler( "transition_complete_keyframe", f15_arg0.clipFinished )
			end
			
			f15_arg0.ShieldCamoSlotInternal:completeAnimation()
			f15_arg0.ShieldCamoSlotInternal:setScale( 1.05, 1.05 )
			f15_local0( f15_arg0.ShieldCamoSlotInternal )
		end
	},
	Equipped = {
		DefaultClip = function ( f17_arg0, f17_arg1 )
			f17_arg0:__resetProperties()
			f17_arg0:setupElementClipCounter( 1 )
			f17_arg0.ShieldCamoSlotInternal:completeAnimation()
			f17_arg0.ShieldCamoSlotInternal.EquippedMarkerBG:completeAnimation()
			f17_arg0.ShieldCamoSlotInternal.EquippedMarkerTick:completeAnimation()
			f17_arg0.ShieldCamoSlotInternal.EquippedMarkerBG:setAlpha( 1 )
			f17_arg0.ShieldCamoSlotInternal.EquippedMarkerTick:setAlpha( 1 )
			f17_arg0.clipFinished( f17_arg0.ShieldCamoSlotInternal )
		end,
		ChildFocus = function ( f18_arg0, f18_arg1 )
			f18_arg0:__resetProperties()
			f18_arg0:setupElementClipCounter( 1 )
			f18_arg0.ShieldCamoSlotInternal:completeAnimation()
			f18_arg0.ShieldCamoSlotInternal.EquippedMarkerBG:completeAnimation()
			f18_arg0.ShieldCamoSlotInternal.EquippedMarkerTick:completeAnimation()
			f18_arg0.ShieldCamoSlotInternal:setScale( 1.05, 1.05 )
			f18_arg0.ShieldCamoSlotInternal.EquippedMarkerBG:setAlpha( 1 )
			f18_arg0.ShieldCamoSlotInternal.EquippedMarkerTick:setAlpha( 1 )
			f18_arg0.clipFinished( f18_arg0.ShieldCamoSlotInternal )
		end,
		GainChildFocus = function ( f19_arg0, f19_arg1 )
			f19_arg0:__resetProperties()
			f19_arg0:setupElementClipCounter( 1 )
			local f19_local0 = function ( f20_arg0 )
				f19_arg0.ShieldCamoSlotInternal:beginAnimation( 200, Enum[@"luitween"][@"luitween_ease_in"] )
				f19_arg0.ShieldCamoSlotInternal:setScale( 1.05, 1.05 )
				f19_arg0.ShieldCamoSlotInternal:registerEventHandler( "interrupted_keyframe", f19_arg0.clipInterrupted )
				f19_arg0.ShieldCamoSlotInternal:registerEventHandler( "transition_complete_keyframe", f19_arg0.clipFinished )
			end
			
			f19_arg0.ShieldCamoSlotInternal:completeAnimation()
			f19_arg0.ShieldCamoSlotInternal.EquippedMarkerBG:completeAnimation()
			f19_arg0.ShieldCamoSlotInternal.EquippedMarkerTick:completeAnimation()
			f19_arg0.ShieldCamoSlotInternal:setScale( 1, 1 )
			f19_arg0.ShieldCamoSlotInternal.EquippedMarkerBG:setAlpha( 1 )
			f19_arg0.ShieldCamoSlotInternal.EquippedMarkerTick:setAlpha( 1 )
			f19_local0( f19_arg0.ShieldCamoSlotInternal )
		end,
		LoseChildFocus = function ( f21_arg0, f21_arg1 )
			f21_arg0:__resetProperties()
			f21_arg0:setupElementClipCounter( 1 )
			local f21_local0 = function ( f22_arg0 )
				f21_arg0.ShieldCamoSlotInternal:beginAnimation( 200, Enum[@"luitween"][@"luitween_ease_out"] )
				f21_arg0.ShieldCamoSlotInternal:setScale( 1, 1 )
				f21_arg0.ShieldCamoSlotInternal:registerEventHandler( "interrupted_keyframe", f21_arg0.clipInterrupted )
				f21_arg0.ShieldCamoSlotInternal:registerEventHandler( "transition_complete_keyframe", f21_arg0.clipFinished )
			end
			
			f21_arg0.ShieldCamoSlotInternal:completeAnimation()
			f21_arg0.ShieldCamoSlotInternal.EquippedMarkerBG:completeAnimation()
			f21_arg0.ShieldCamoSlotInternal.EquippedMarkerTick:completeAnimation()
			f21_arg0.ShieldCamoSlotInternal:setScale( 1.05, 1.05 )
			f21_arg0.ShieldCamoSlotInternal.EquippedMarkerBG:setAlpha( 1 )
			f21_arg0.ShieldCamoSlotInternal.EquippedMarkerTick:setAlpha( 1 )
			f21_local0( f21_arg0.ShieldCamoSlotInternal )
		end
	},
	New = {
		DefaultClip = function ( f23_arg0, f23_arg1 )
			f23_arg0:__resetProperties()
			f23_arg0:setupElementClipCounter( 1 )
		end,
		ChildFocus = function ( f24_arg0, f24_arg1 )
			f24_arg0:__resetProperties()
			f24_arg0:setupElementClipCounter( 2 )
			f24_arg0.ShieldCamoSlotInternal:completeAnimation()
			f24_arg0.ShieldCamoSlotInternal:setScale( 1.05, 1.05 )
			f24_arg0.clipFinished( f24_arg0.ShieldCamoSlotInternal )
			local f24_local0 = function ( f25_arg0 )
				local f25_local0 = function ( f26_arg0 )
					f26_arg0:beginAnimation( 200 )
					f26_arg0:setAlpha( 0 )
					f26_arg0:registerEventHandler( "transition_complete_keyframe", f24_arg0.clipFinished )
				end
			end
		end,
		GainChildFocus = function ( f27_arg0, f27_arg1 )
			f27_arg0:__resetProperties()
			f27_arg0:setupElementClipCounter( 2 )
			local f27_local0 = function ( f28_arg0 )
				f27_arg0.ShieldCamoSlotInternal:beginAnimation( 200, Enum[@"luitween"][@"luitween_ease_in"] )
				f27_arg0.ShieldCamoSlotInternal:setScale( 1.05, 1.05 )
				f27_arg0.ShieldCamoSlotInternal:registerEventHandler( "interrupted_keyframe", f27_arg0.clipInterrupted )
				f27_arg0.ShieldCamoSlotInternal:registerEventHandler( "transition_complete_keyframe", f27_arg0.clipFinished )
			end
			
			f27_arg0.ShieldCamoSlotInternal:completeAnimation()
			f27_arg0.ShieldCamoSlotInternal:setAlpha( 1 )
			f27_arg0.ShieldCamoSlotInternal:setScale( 1, 1 )
			f27_local0( f27_arg0.ShieldCamoSlotInternal )
		end,
		LoseChildFocus = function ( f29_arg0, f29_arg1 )
			f29_arg0:__resetProperties()
			f29_arg0:setupElementClipCounter( 1 )
			local f29_local0 = function ( f30_arg0 )
				f29_arg0.ShieldCamoSlotInternal:beginAnimation( 200, Enum[@"luitween"][@"luitween_ease_out"] )
				f29_arg0.ShieldCamoSlotInternal:setScale( 1, 1 )
				f29_arg0.ShieldCamoSlotInternal:registerEventHandler( "interrupted_keyframe", f29_arg0.clipInterrupted )
				f29_arg0.ShieldCamoSlotInternal:registerEventHandler( "transition_complete_keyframe", f29_arg0.clipFinished )
			end
			
			f29_arg0.ShieldCamoSlotInternal:completeAnimation()
			f29_arg0.ShieldCamoSlotInternal:setScale( 1.05, 1.05 )
			f29_local0( f29_arg0.ShieldCamoSlotInternal )
		end
	}
}

CoD.ShieldCamoSlot.__onClose = function ( f31_arg0 )
	f31_arg0.ShieldCamoSlotInternal:close()
end

CoD.ShieldCamoSlotInternal = InheritFrom( LUI.UIElement )
CoD.ShieldCamoSlotInternal.__defaultWidth = 128
CoD.ShieldCamoSlotInternal.__defaultHeight = 89
CoD.ShieldCamoSlotInternal.new = function ( f1_arg0, f1_arg1, f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	local self = LUI.UIElement.new( f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	self:setClass( CoD.ShieldCamoSlotInternal )
	self.id = "ShieldCamoSlotInternal"
	self.soundSet = "FrontendMain"
	self.onlyChildrenFocusable = true
	self.anyChildUsesUpdateState = true
	f1_arg0:addElementToPendingUpdateStateList( self )
	
	local Image = LUI.UIImage.new( 0, 1, 0, 0, 0, 1, 0, 0 )
	Image:setMaterial( LUI.UIImage.GetCachedMaterial( @"hash_1A02C44161370F6D" ) )
	Image:setShaderVector( 0, 0, 0, 0, 0 )
	Image:setShaderVector( 1, 1, 1, 0, 0 )
	Image:setShaderVector( 2, 0, 0, 0, 0 )
	Image:linkToElementModel( self, "image", true, function ( model )
		local f2_local0 = model:get()
		if f2_local0 ~= nil then
			Image:setImage( RegisterImage( f2_local0 ) )
		end
	end )
	self:addElement( Image )
	self.Image = Image
	
	local DarkenedOverlay = LUI.UIImage.new( 0, 1, 0, 0, 0, 1, 0, 0 )
	DarkenedOverlay:setRGB( 0, 0, 0 )
	DarkenedOverlay:setAlpha( 0 )
	self:addElement( DarkenedOverlay )
	self.DarkenedOverlay = DarkenedOverlay
	
	local ProgressBarBG = LUI.UIImage.new( 0, 1, 0, 0, 1, 1, -62, 1 )
	ProgressBarBG:setRGB( ColorSet.Title.r, ColorSet.Title.g, ColorSet.Title.b )
	ProgressBarBG:setAlpha( 0 )
	ProgressBarBG:setImage( RegisterImage( @"uie_ui_menu_cac_weapon_select_button_bar" ) )
	self:addElement( ProgressBarBG )
	self.ProgressBarBG = ProgressBarBG
	
	local ProgressBar = LUI.UIImage.new( 0, 1, 0, 0, 1, 1, -62, 1 )
	ProgressBar:setAlpha( 0 )
	ProgressBar:setImage( RegisterImage( @"uie_ui_menu_cac_button_bottom_line_lvl" ) )
	ProgressBar:setMaterial( LUI.UIImage.GetCachedMaterial( @"uie_wipe_normal" ) )
	ProgressBar:setShaderVector( 1, 0, 0, 0, 0 )
	ProgressBar:setShaderVector( 2, 1, 0, 0, 0 )
	ProgressBar:setShaderVector( 3, 0, 0, 0, 0 )
	ProgressBar:setShaderVector( 4, 0, 0, 0, 0 )
	ProgressBar:linkToElementModel( self, "unlockProgressAndTarget", true, function ( model )
		local f3_local0 = model:get()
		if f3_local0 ~= nil then
			ProgressBar:setShaderVector( 0, CoD.WeaponOptionsUtility.GetWeaponOptionProgress( f1_arg0, f1_arg1, CoD.GetVectorComponentFromString( f3_local0, 1 ), CoD.GetVectorComponentFromString( f3_local0, 2 ), CoD.GetVectorComponentFromString( f3_local0, 3 ), CoD.GetVectorComponentFromString( f3_local0, 4 ) ) )
		end
	end )
	self:addElement( ProgressBar )
	self.ProgressBar = ProgressBar
	
	local CommonButtonOutline = CoD.CommonButtonOutline.new( f1_arg0, f1_arg1, 0, 1, -1, 1, 0, 1, 0, 0 )
	self:addElement( CommonButtonOutline )
	self.CommonButtonOutline = CommonButtonOutline
	
	local EquippedMarkerBG = LUI.UIImage.new( 1, 1, -35, 9, 0, 0, -8, 36 )
	EquippedMarkerBG:setAlpha( 0 )
	EquippedMarkerBG:setZoom( 4 )
	EquippedMarkerBG:setImage( RegisterImage( @"uie_ui_menu_cac_equipped_marker_bg" ) )
	EquippedMarkerBG:setMaterial( LUI.UIImage.GetCachedMaterial( @"ui_add" ) )
	self:addElement( EquippedMarkerBG )
	self.EquippedMarkerBG = EquippedMarkerBG
	
	local EquippedMarkerTick = LUI.UIImage.new( 1, 1, -35, 9, 0, 0, -8, 36 )
	EquippedMarkerTick:setAlpha( 0 )
	EquippedMarkerTick:setZoom( 4 )
	EquippedMarkerTick:setImage( RegisterImage( @"uie_ui_menu_cac_equipped_marker_tick" ) )
	self:addElement( EquippedMarkerTick )
	self.EquippedMarkerTick = EquippedMarkerTick
	
	local LockedX = LUI.UIImage.new( 0, 1, 0, 0, 0, 1, 0, 0 )
	LockedX:setRGB( ColorSet.Title.r, ColorSet.Title.g, ColorSet.Title.b )
	LockedX:setAlpha( 0 )
	LockedX:setImage( RegisterImage( @"uie_spawnselect_crosshair_auto" ) )
	self:addElement( LockedX )
	self.LockedX = LockedX
	
	local LockedIcon = LUI.UIImage.new( 0.5, 0.5, -15, 15, 0.5, 0.5, -15, 15 )
	LockedIcon:setAlpha( 0 )
	LockedIcon:setImage( RegisterImage( @"uie_icon_locks_lock_01" ) )
	self:addElement( LockedIcon )
	self.LockedIcon = LockedIcon
	
	local BMLock = CoD.BM_Lock.new( f1_arg0, f1_arg1, 0.5, 0.5, -24, 24, 0.5, 0.5, -24, 24 )
	BMLock:setAlpha( 0 )
	BMLock:setScale( 0.6, 0.6 )
	self:addElement( BMLock )
	self.BMLock = BMLock
	
	local PaintCanImage = LUI.UIImage.new( 0.5, 0.5, -24, 24, 0.5, 0.5, -24, 24 )
	PaintCanImage:setAlpha( 0 )
	PaintCanImage:setImage( RegisterImage( @"ui_icon_inventory_spray_can" ) )
	self:addElement( PaintCanImage )
	self.PaintCanImage = PaintCanImage
	
	CommonButtonOutline.id = "CommonButtonOutline"
	self.__defaultFocus = CommonButtonOutline
	LUI.OverrideFunction_CallOriginalSecond( self, "close", self.__onClose )
	
	if PostLoadFunc then
		PostLoadFunc( self, f1_arg1, f1_arg0 )
	end
	
	return self
end

CoD.ShieldCamoSlotInternal.__resetProperties = function ( f4_arg0 )
	f4_arg0.LockedIcon:completeAnimation()
	f4_arg0.ProgressBarBG:completeAnimation()
	f4_arg0.ProgressBar:completeAnimation()
	f4_arg0.DarkenedOverlay:completeAnimation()
	f4_arg0.Image:completeAnimation()
	f4_arg0.BMLock:completeAnimation()
	f4_arg0.LockedX:completeAnimation()
	f4_arg0.PaintCanImage:completeAnimation()
	f4_arg0.LockedIcon:setAlpha( 0 )
	f4_arg0.LockedIcon:setZoom( 0 )
	f4_arg0.ProgressBarBG:setAlpha( 0 )
	f4_arg0.ProgressBar:setAlpha( 0 )
	f4_arg0.DarkenedOverlay:setAlpha( 0 )
	f4_arg0.Image:setRGB( 1, 1, 1 )
	f4_arg0.BMLock:setAlpha( 0 )
	f4_arg0.LockedX:setAlpha( 0 )
	f4_arg0.PaintCanImage:setLeftRight( 0.5, 0.5, -24, 24 )
	f4_arg0.PaintCanImage:setTopBottom( 0.5, 0.5, -24, 24 )
	f4_arg0.PaintCanImage:setAlpha( 0 )
end

CoD.ShieldCamoSlotInternal.__clipsPerState = {
	DefaultState = {
		DefaultClip = function ( f5_arg0, f5_arg1 )
			f5_arg0:__resetProperties()
			f5_arg0:setupElementClipCounter( 0 )
		end,
		ChildFocus = function ( f6_arg0, f6_arg1 )
			f6_arg0:__resetProperties()
			f6_arg0:setupElementClipCounter( 1 )
			f6_arg0.LockedIcon:completeAnimation()
			f6_arg0.LockedIcon:setZoom( 0 )
			f6_arg0.clipFinished( f6_arg0.LockedIcon )
		end,
		GainChildFocus = function ( f7_arg0, f7_arg1 )
			f7_arg0:__resetProperties()
			f7_arg0:setupElementClipCounter( 1 )
			f7_arg0.LockedIcon:completeAnimation()
			f7_arg0.LockedIcon:setZoom( 0 )
			f7_arg0.clipFinished( f7_arg0.LockedIcon )
		end,
		LoseChildFocus = function ( f8_arg0, f8_arg1 )
			f8_arg0:__resetProperties()
			f8_arg0:setupElementClipCounter( 1 )
			f8_arg0.LockedIcon:completeAnimation()
			f8_arg0.LockedIcon:setZoom( 0 )
			f8_arg0.clipFinished( f8_arg0.LockedIcon )
		end
	},
	LootLocked = {
		DefaultClip = function ( f9_arg0, f9_arg1 )
			f9_arg0:__resetProperties()
			f9_arg0:setupElementClipCounter( 5 )
			f9_arg0.Image:completeAnimation()
			f9_arg0.Image:setRGB( 0.29, 0.29, 0.29 )
			f9_arg0.clipFinished( f9_arg0.Image )
			f9_arg0.DarkenedOverlay:completeAnimation()
			f9_arg0.DarkenedOverlay:setAlpha( 0.5 )
			f9_arg0.clipFinished( f9_arg0.DarkenedOverlay )
			f9_arg0.ProgressBarBG:completeAnimation()
			f9_arg0.ProgressBarBG:setAlpha( 1 )
			f9_arg0.clipFinished( f9_arg0.ProgressBarBG )
			f9_arg0.ProgressBar:completeAnimation()
			f9_arg0.ProgressBar:setAlpha( 1 )
			f9_arg0.clipFinished( f9_arg0.ProgressBar )
			f9_arg0.BMLock:completeAnimation()
			f9_arg0.BMLock:setAlpha( 0.5 )
			f9_arg0.clipFinished( f9_arg0.BMLock )
		end,
		ChildFocus = function ( f10_arg0, f10_arg1 )
			f10_arg0:__resetProperties()
			f10_arg0:setupElementClipCounter( 5 )
			f10_arg0.Image:completeAnimation()
			f10_arg0.Image:setRGB( 0.29, 0.29, 0.29 )
			f10_arg0.clipFinished( f10_arg0.Image )
			f10_arg0.DarkenedOverlay:completeAnimation()
			f10_arg0.DarkenedOverlay:setAlpha( 0.5 )
			f10_arg0.clipFinished( f10_arg0.DarkenedOverlay )
			f10_arg0.ProgressBarBG:completeAnimation()
			f10_arg0.ProgressBarBG:setAlpha( 1 )
			f10_arg0.clipFinished( f10_arg0.ProgressBarBG )
			f10_arg0.ProgressBar:completeAnimation()
			f10_arg0.ProgressBar:setAlpha( 1 )
			f10_arg0.clipFinished( f10_arg0.ProgressBar )
			f10_arg0.BMLock:completeAnimation()
			f10_arg0.BMLock:setAlpha( 0.75 )
			f10_arg0.clipFinished( f10_arg0.BMLock )
		end,
		ChildGainFocus = function ( f11_arg0, f11_arg1 )
			f11_arg0:__resetProperties()
			f11_arg0:setupElementClipCounter( 5 )
			f11_arg0.Image:completeAnimation()
			f11_arg0.Image:setRGB( 0.29, 0.29, 0.29 )
			f11_arg0.clipFinished( f11_arg0.Image )
			f11_arg0.DarkenedOverlay:completeAnimation()
			f11_arg0.DarkenedOverlay:setAlpha( 0.5 )
			f11_arg0.clipFinished( f11_arg0.DarkenedOverlay )
			f11_arg0.ProgressBarBG:completeAnimation()
			f11_arg0.ProgressBarBG:setAlpha( 1 )
			f11_arg0.clipFinished( f11_arg0.ProgressBarBG )
			f11_arg0.ProgressBar:completeAnimation()
			f11_arg0.ProgressBar:setAlpha( 1 )
			f11_arg0.clipFinished( f11_arg0.ProgressBar )
			local f11_local0 = function ( f12_arg0 )
				f11_arg0.BMLock:beginAnimation( 200 )
				f11_arg0.BMLock:setAlpha( 0.75 )
				f11_arg0.BMLock:registerEventHandler( "interrupted_keyframe", f11_arg0.clipInterrupted )
				f11_arg0.BMLock:registerEventHandler( "transition_complete_keyframe", f11_arg0.clipFinished )
			end
			
			f11_arg0.BMLock:completeAnimation()
			f11_arg0.BMLock:setAlpha( 0.5 )
			f11_local0( f11_arg0.BMLock )
		end,
		LoseChildFocus = function ( f13_arg0, f13_arg1 )
			f13_arg0:__resetProperties()
			f13_arg0:setupElementClipCounter( 5 )
			f13_arg0.Image:completeAnimation()
			f13_arg0.Image:setRGB( 0.29, 0.29, 0.29 )
			f13_arg0.clipFinished( f13_arg0.Image )
			f13_arg0.DarkenedOverlay:completeAnimation()
			f13_arg0.DarkenedOverlay:setAlpha( 0.5 )
			f13_arg0.clipFinished( f13_arg0.DarkenedOverlay )
			f13_arg0.ProgressBarBG:completeAnimation()
			f13_arg0.ProgressBarBG:setAlpha( 1 )
			f13_arg0.clipFinished( f13_arg0.ProgressBarBG )
			f13_arg0.ProgressBar:completeAnimation()
			f13_arg0.ProgressBar:setAlpha( 1 )
			f13_arg0.clipFinished( f13_arg0.ProgressBar )
			local f13_local0 = function ( f14_arg0 )
				f13_arg0.BMLock:beginAnimation( 220 )
				f13_arg0.BMLock:setAlpha( 0.5 )
				f13_arg0.BMLock:registerEventHandler( "interrupted_keyframe", f13_arg0.clipInterrupted )
				f13_arg0.BMLock:registerEventHandler( "transition_complete_keyframe", f13_arg0.clipFinished )
			end
			
			f13_arg0.BMLock:completeAnimation()
			f13_arg0.BMLock:setAlpha( 0.75 )
			f13_local0( f13_arg0.BMLock )
		end
	},
	PaintCanLocked = {
		DefaultClip = function ( f15_arg0, f15_arg1 )
			f15_arg0:__resetProperties()
			f15_arg0:setupElementClipCounter( 6 )
			f15_arg0.Image:completeAnimation()
			f15_arg0.Image:setRGB( 0.29, 0.29, 0.29 )
			f15_arg0.clipFinished( f15_arg0.Image )
			f15_arg0.DarkenedOverlay:completeAnimation()
			f15_arg0.DarkenedOverlay:setAlpha( 0 )
			f15_arg0.clipFinished( f15_arg0.DarkenedOverlay )
			f15_arg0.ProgressBarBG:completeAnimation()
			f15_arg0.ProgressBarBG:setAlpha( 0 )
			f15_arg0.clipFinished( f15_arg0.ProgressBarBG )
			f15_arg0.ProgressBar:completeAnimation()
			f15_arg0.ProgressBar:setAlpha( 0 )
			f15_arg0.clipFinished( f15_arg0.ProgressBar )
			f15_arg0.LockedX:completeAnimation()
			f15_arg0.LockedX:setAlpha( 0 )
			f15_arg0.clipFinished( f15_arg0.LockedX )
			f15_arg0.PaintCanImage:completeAnimation()
			f15_arg0.PaintCanImage:setLeftRight( 0.5, 0.5, -40, 40 )
			f15_arg0.PaintCanImage:setTopBottom( 0.5, 0.5, -40, 40 )
			f15_arg0.PaintCanImage:setAlpha( 0.5 )
			f15_arg0.clipFinished( f15_arg0.PaintCanImage )
		end,
		ChildFocus = function ( f16_arg0, f16_arg1 )
			f16_arg0:__resetProperties()
			f16_arg0:setupElementClipCounter( 4 )
			f16_arg0.Image:completeAnimation()
			f16_arg0.Image:setRGB( 0.47, 0.47, 0.47 )
			f16_arg0.clipFinished( f16_arg0.Image )
			f16_arg0.DarkenedOverlay:completeAnimation()
			f16_arg0.DarkenedOverlay:setAlpha( 0 )
			f16_arg0.clipFinished( f16_arg0.DarkenedOverlay )
			f16_arg0.LockedX:completeAnimation()
			f16_arg0.LockedX:setAlpha( 0 )
			f16_arg0.clipFinished( f16_arg0.LockedX )
			f16_arg0.PaintCanImage:completeAnimation()
			f16_arg0.PaintCanImage:setLeftRight( 0.5, 0.5, -40, 40 )
			f16_arg0.PaintCanImage:setTopBottom( 0.5, 0.5, -40, 40 )
			f16_arg0.PaintCanImage:setAlpha( 1 )
			f16_arg0.clipFinished( f16_arg0.PaintCanImage )
		end,
		ChildGainFocus = function ( f17_arg0, f17_arg1 )
			f17_arg0:__resetProperties()
			f17_arg0:setupElementClipCounter( 4 )
			local f17_local0 = function ( f18_arg0 )
				f17_arg0.Image:beginAnimation( 200 )
				f17_arg0.Image:setRGB( 0.47, 0.47, 0.47 )
				f17_arg0.Image:registerEventHandler( "interrupted_keyframe", f17_arg0.clipInterrupted )
				f17_arg0.Image:registerEventHandler( "transition_complete_keyframe", f17_arg0.clipFinished )
			end
			
			f17_arg0.Image:completeAnimation()
			f17_arg0.Image:setRGB( 0.29, 0.29, 0.29 )
			f17_local0( f17_arg0.Image )
			f17_arg0.DarkenedOverlay:completeAnimation()
			f17_arg0.DarkenedOverlay:setAlpha( 0 )
			f17_arg0.clipFinished( f17_arg0.DarkenedOverlay )
			f17_arg0.LockedX:completeAnimation()
			f17_arg0.LockedX:setAlpha( 0 )
			f17_arg0.clipFinished( f17_arg0.LockedX )
			local f17_local1 = function ( f19_arg0 )
				f17_arg0.PaintCanImage:beginAnimation( 200 )
				f17_arg0.PaintCanImage:setAlpha( 1 )
				f17_arg0.PaintCanImage:registerEventHandler( "interrupted_keyframe", f17_arg0.clipInterrupted )
				f17_arg0.PaintCanImage:registerEventHandler( "transition_complete_keyframe", f17_arg0.clipFinished )
			end
			
			f17_arg0.PaintCanImage:completeAnimation()
			f17_arg0.PaintCanImage:setLeftRight( 0.5, 0.5, -40, 40 )
			f17_arg0.PaintCanImage:setTopBottom( 0.5, 0.5, -40, 40 )
			f17_arg0.PaintCanImage:setAlpha( 0.5 )
			f17_local1( f17_arg0.PaintCanImage )
		end,
		LoseChildFocus = function ( f20_arg0, f20_arg1 )
			f20_arg0:__resetProperties()
			f20_arg0:setupElementClipCounter( 4 )
			local f20_local0 = function ( f21_arg0 )
				f20_arg0.Image:beginAnimation( 220 )
				f20_arg0.Image:setRGB( 0.29, 0.29, 0.29 )
				f20_arg0.Image:registerEventHandler( "interrupted_keyframe", f20_arg0.clipInterrupted )
				f20_arg0.Image:registerEventHandler( "transition_complete_keyframe", f20_arg0.clipFinished )
			end
			
			f20_arg0.Image:completeAnimation()
			f20_arg0.Image:setRGB( 0.47, 0.47, 0.47 )
			f20_local0( f20_arg0.Image )
			f20_arg0.DarkenedOverlay:completeAnimation()
			f20_arg0.DarkenedOverlay:setAlpha( 0 )
			f20_arg0.clipFinished( f20_arg0.DarkenedOverlay )
			f20_arg0.LockedX:completeAnimation()
			f20_arg0.LockedX:setAlpha( 0 )
			f20_arg0.clipFinished( f20_arg0.LockedX )
			local f20_local1 = function ( f22_arg0 )
				f20_arg0.PaintCanImage:beginAnimation( 220 )
				f20_arg0.PaintCanImage:setAlpha( 0.5 )
				f20_arg0.PaintCanImage:registerEventHandler( "interrupted_keyframe", f20_arg0.clipInterrupted )
				f20_arg0.PaintCanImage:registerEventHandler( "transition_complete_keyframe", f20_arg0.clipFinished )
			end
			
			f20_arg0.PaintCanImage:completeAnimation()
			f20_arg0.PaintCanImage:setLeftRight( 0.5, 0.5, -40, 40 )
			f20_arg0.PaintCanImage:setTopBottom( 0.5, 0.5, -40, 40 )
			f20_arg0.PaintCanImage:setAlpha( 1 )
			f20_local1( f20_arg0.PaintCanImage )
		end
	},
	Locked = {
		DefaultClip = function ( f23_arg0, f23_arg1 )
			f23_arg0:__resetProperties()
			f23_arg0:setupElementClipCounter( 6 )
			f23_arg0.Image:completeAnimation()
			f23_arg0.Image:setRGB( 0.29, 0.29, 0.29 )
			f23_arg0.clipFinished( f23_arg0.Image )
			f23_arg0.DarkenedOverlay:completeAnimation()
			f23_arg0.DarkenedOverlay:setAlpha( 0.5 )
			f23_arg0.clipFinished( f23_arg0.DarkenedOverlay )
			f23_arg0.ProgressBarBG:completeAnimation()
			f23_arg0.ProgressBarBG:setAlpha( 1 )
			f23_arg0.clipFinished( f23_arg0.ProgressBarBG )
			f23_arg0.ProgressBar:completeAnimation()
			f23_arg0.ProgressBar:setAlpha( 1 )
			f23_arg0.clipFinished( f23_arg0.ProgressBar )
			f23_arg0.LockedX:completeAnimation()
			f23_arg0.LockedX:setAlpha( 0.66 )
			f23_arg0.clipFinished( f23_arg0.LockedX )
			f23_arg0.LockedIcon:completeAnimation()
			f23_arg0.LockedIcon:setAlpha( 0.33 )
			f23_arg0.clipFinished( f23_arg0.LockedIcon )
		end,
		ChildFocus = function ( f24_arg0, f24_arg1 )
			f24_arg0:__resetProperties()
			f24_arg0:setupElementClipCounter( 6 )
			f24_arg0.Image:completeAnimation()
			f24_arg0.Image:setRGB( 0.29, 0.29, 0.29 )
			f24_arg0.clipFinished( f24_arg0.Image )
			f24_arg0.DarkenedOverlay:completeAnimation()
			f24_arg0.DarkenedOverlay:setAlpha( 0.5 )
			f24_arg0.clipFinished( f24_arg0.DarkenedOverlay )
			f24_arg0.ProgressBarBG:completeAnimation()
			f24_arg0.ProgressBarBG:setAlpha( 1 )
			f24_arg0.clipFinished( f24_arg0.ProgressBarBG )
			f24_arg0.ProgressBar:completeAnimation()
			f24_arg0.ProgressBar:setAlpha( 1 )
			f24_arg0.clipFinished( f24_arg0.ProgressBar )
			f24_arg0.LockedX:completeAnimation()
			f24_arg0.LockedX:setAlpha( 1 )
			f24_arg0.clipFinished( f24_arg0.LockedX )
			f24_arg0.LockedIcon:completeAnimation()
			f24_arg0.LockedIcon:setAlpha( 0.75 )
			f24_arg0.clipFinished( f24_arg0.LockedIcon )
		end,
		ChildGainFocus = function ( f25_arg0, f25_arg1 )
			f25_arg0:__resetProperties()
			f25_arg0:setupElementClipCounter( 6 )
			f25_arg0.Image:completeAnimation()
			f25_arg0.Image:setRGB( 0.29, 0.29, 0.29 )
			f25_arg0.clipFinished( f25_arg0.Image )
			f25_arg0.DarkenedOverlay:completeAnimation()
			f25_arg0.DarkenedOverlay:setAlpha( 0.5 )
			f25_arg0.clipFinished( f25_arg0.DarkenedOverlay )
			f25_arg0.ProgressBarBG:completeAnimation()
			f25_arg0.ProgressBarBG:setAlpha( 1 )
			f25_arg0.clipFinished( f25_arg0.ProgressBarBG )
			f25_arg0.ProgressBar:completeAnimation()
			f25_arg0.ProgressBar:setAlpha( 1 )
			f25_arg0.clipFinished( f25_arg0.ProgressBar )
			local f25_local0 = function ( f26_arg0 )
				f25_arg0.LockedX:beginAnimation( 200 )
				f25_arg0.LockedX:setAlpha( 1 )
				f25_arg0.LockedX:registerEventHandler( "interrupted_keyframe", f25_arg0.clipInterrupted )
				f25_arg0.LockedX:registerEventHandler( "transition_complete_keyframe", f25_arg0.clipFinished )
			end
			
			f25_arg0.LockedX:completeAnimation()
			f25_arg0.LockedX:setAlpha( 0.66 )
			f25_local0( f25_arg0.LockedX )
			local f25_local1 = function ( f27_arg0 )
				f25_arg0.LockedIcon:beginAnimation( 200 )
				f25_arg0.LockedIcon:setAlpha( 0.75 )
				f25_arg0.LockedIcon:registerEventHandler( "interrupted_keyframe", f25_arg0.clipInterrupted )
				f25_arg0.LockedIcon:registerEventHandler( "transition_complete_keyframe", f25_arg0.clipFinished )
			end
			
			f25_arg0.LockedIcon:completeAnimation()
			f25_arg0.LockedIcon:setAlpha( 0.33 )
			f25_local1( f25_arg0.LockedIcon )
		end,
		LoseChildFocus = function ( f28_arg0, f28_arg1 )
			f28_arg0:__resetProperties()
			f28_arg0:setupElementClipCounter( 6 )
			f28_arg0.Image:completeAnimation()
			f28_arg0.Image:setRGB( 0.29, 0.29, 0.29 )
			f28_arg0.clipFinished( f28_arg0.Image )
			f28_arg0.DarkenedOverlay:completeAnimation()
			f28_arg0.DarkenedOverlay:setAlpha( 0.5 )
			f28_arg0.clipFinished( f28_arg0.DarkenedOverlay )
			f28_arg0.ProgressBarBG:completeAnimation()
			f28_arg0.ProgressBarBG:setAlpha( 1 )
			f28_arg0.clipFinished( f28_arg0.ProgressBarBG )
			f28_arg0.ProgressBar:completeAnimation()
			f28_arg0.ProgressBar:setAlpha( 1 )
			f28_arg0.clipFinished( f28_arg0.ProgressBar )
			local f28_local0 = function ( f29_arg0 )
				f28_arg0.LockedX:beginAnimation( 220 )
				f28_arg0.LockedX:setAlpha( 0.66 )
				f28_arg0.LockedX:registerEventHandler( "interrupted_keyframe", f28_arg0.clipInterrupted )
				f28_arg0.LockedX:registerEventHandler( "transition_complete_keyframe", f28_arg0.clipFinished )
			end
			
			f28_arg0.LockedX:completeAnimation()
			f28_arg0.LockedX:setAlpha( 1 )
			f28_local0( f28_arg0.LockedX )
			local f28_local1 = function ( f30_arg0 )
				f28_arg0.LockedIcon:beginAnimation( 220 )
				f28_arg0.LockedIcon:setAlpha( 0.33 )
				f28_arg0.LockedIcon:registerEventHandler( "interrupted_keyframe", f28_arg0.clipInterrupted )
				f28_arg0.LockedIcon:registerEventHandler( "transition_complete_keyframe", f28_arg0.clipFinished )
			end
			
			f28_arg0.LockedIcon:completeAnimation()
			f28_arg0.LockedIcon:setAlpha( 0.75 )
			f28_local1( f28_arg0.LockedIcon )
		end
	}
}

CoD.ShieldCamoSlotInternal.__onClose = function ( f31_arg0 )
	f31_arg0.Image:close()
	f31_arg0.ProgressBar:close()
	f31_arg0.CommonButtonOutline:close()
	f31_arg0.BMLock:close()
end