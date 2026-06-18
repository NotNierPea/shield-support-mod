--[[
		.\hksc.exe ".\Lua\BlackoutSliderNoLocalize.Lua" -o "C:\Program Files (x86)\Call of Duty Black Ops 4\project-bo4\mods\T8ShieldSupport\Lua\BlackoutSliderNoLocalize.luac"
]]

---------------------------

CoD.ShieldInitLuaFile()

---------------------------

local function IsCustomGameSettingDefault_WZ( f127_arg0, f127_arg1 )
	local f127_local2 = f127_arg0:getModel( f127_arg1, "gamesetting" )
	local f127_local3 = f127_local2 and f127_local2:get()
	if f127_local3 then
		--CoD.EnhPrintInfo("comparing " .. f127_local3)
		-- check if in CoD.wz_settings_changed
		for i = #CoD.wz_settings_changed, 1, -1 do
			--CoD.EnhPrintInfo("comparing " .. CoD.wz_settings_changed[i].name_setting .. " - " .. f127_local3)
			if CoD.wz_settings_changed[i].name_setting == f127_local3 then
				return false
			end
		end
	end

	return true
end

---------------------------

-- for blackout options
CoD.CustomGames_SettingSliderNoCustom_NoLocalize = InheritFrom( LUI.UIElement )
CoD.CustomGames_SettingSliderNoCustom_NoLocalize.__defaultWidth = 500
CoD.CustomGames_SettingSliderNoCustom_NoLocalize.__defaultHeight = 60
CoD.CustomGames_SettingSliderNoCustom_NoLocalize.new = function ( f1_arg0, f1_arg1, f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	local self = LUI.UIElement.new( f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	self:setClass( CoD.CustomGames_SettingSliderNoCustom_NoLocalize )
	self.id = "CustomGames_SettingSliderNoCustom_NoLocalize"
	self.soundSet = "none"
	self.onlyChildrenFocusable = true
	self.anyChildUsesUpdateState = true
	f1_arg0:addElementToPendingUpdateStateList( self )
	
	local StartMenuOptionsSettingSlider = CoD.CustomGames_SettingSliderNoCustom_NoLocalize_Internal.new( f1_arg0, f1_arg1, 0, 1, 0, 0, 0, 0, 0, 60 )
	StartMenuOptionsSettingSlider:linkToElementModel( self, nil, false, function ( model )
		StartMenuOptionsSettingSlider:setModel( model, f1_arg1 )
	end )
	self:addElement( StartMenuOptionsSettingSlider )
	self.StartMenuOptionsSettingSlider = StartMenuOptionsSettingSlider
	
	StartMenuOptionsSettingSlider.id = "StartMenuOptionsSettingSlider"
	self.__defaultFocus = StartMenuOptionsSettingSlider
	LUI.OverrideFunction_CallOriginalSecond( self, "close", self.__onClose )
	
	if PostLoadFunc then
		PostLoadFunc( self, f1_arg1, f1_arg0 )
	end
	
	return self
end

CoD.CustomGames_SettingSliderNoCustom_NoLocalize.__resetProperties = function ( f3_arg0 )
	f3_arg0.StartMenuOptionsSettingSlider:completeAnimation()
	f3_arg0.StartMenuOptionsSettingSlider:setScale( 1, 1 )
end

CoD.CustomGames_SettingSliderNoCustom_NoLocalize.__clipsPerState = {
	DefaultState = {
		DefaultClip = function ( f4_arg0, f4_arg1 )
			f4_arg0:__resetProperties()
			f4_arg0:setupElementClipCounter( 0 )
		end,
		ChildFocus = function ( f5_arg0, f5_arg1 )
			f5_arg0:__resetProperties()
			f5_arg0:setupElementClipCounter( 1 )
			f5_arg0.StartMenuOptionsSettingSlider:completeAnimation()
			f5_arg0.StartMenuOptionsSettingSlider:setScale( 1.05, 1.05 )
			f5_arg0.clipFinished( f5_arg0.StartMenuOptionsSettingSlider )
		end,
		GainChildFocus = function ( f6_arg0, f6_arg1 )
			f6_arg0:__resetProperties()
			f6_arg0:setupElementClipCounter( 1 )
			local f6_local0 = function ( f7_arg0 )
				f6_arg0.StartMenuOptionsSettingSlider:beginAnimation( 200 )
				f6_arg0.StartMenuOptionsSettingSlider:setScale( 1.05, 1.05 )
				f6_arg0.StartMenuOptionsSettingSlider:registerEventHandler( "interrupted_keyframe", f6_arg0.clipInterrupted )
				f6_arg0.StartMenuOptionsSettingSlider:registerEventHandler( "transition_complete_keyframe", f6_arg0.clipFinished )
			end
			
			f6_arg0.StartMenuOptionsSettingSlider:completeAnimation()
			f6_arg0.StartMenuOptionsSettingSlider:setScale( 1, 1 )
			f6_local0( f6_arg0.StartMenuOptionsSettingSlider )
		end,
		LoseChildFocus = function ( f8_arg0, f8_arg1 )
			f8_arg0:__resetProperties()
			f8_arg0:setupElementClipCounter( 1 )
			local f8_local0 = function ( f9_arg0 )
				f8_arg0.StartMenuOptionsSettingSlider:beginAnimation( 200 )
				f8_arg0.StartMenuOptionsSettingSlider:setScale( 1, 1 )
				f8_arg0.StartMenuOptionsSettingSlider:registerEventHandler( "interrupted_keyframe", f8_arg0.clipInterrupted )
				f8_arg0.StartMenuOptionsSettingSlider:registerEventHandler( "transition_complete_keyframe", f8_arg0.clipFinished )
			end
			
			f8_arg0.StartMenuOptionsSettingSlider:completeAnimation()
			f8_arg0.StartMenuOptionsSettingSlider:setScale( 1.05, 1.05 )
			f8_local0( f8_arg0.StartMenuOptionsSettingSlider )
		end
	}
}

CoD.CustomGames_SettingSliderNoCustom_NoLocalize.__onClose = function ( f10_arg0 )
	f10_arg0.StartMenuOptionsSettingSlider:close()
end

CoD.CustomGames_SettingSliderNoCustom_NoLocalize_Internal = InheritFrom( LUI.UIElement )
CoD.CustomGames_SettingSliderNoCustom_NoLocalize_Internal.__defaultWidth = 500
CoD.CustomGames_SettingSliderNoCustom_NoLocalize_Internal.__defaultHeight = 60
CoD.CustomGames_SettingSliderNoCustom_NoLocalize_Internal.new = function ( f1_arg0, f1_arg1, f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	local self = LUI.UIElement.new( f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	self:setClass( CoD.CustomGames_SettingSliderNoCustom_NoLocalize_Internal )
	self.id = "CustomGames_SettingSliderNoCustom_NoLocalize_Internal"
	self.soundSet = "ChooseDecal"
	self.onlyChildrenFocusable = true
	self.anyChildUsesUpdateState = true
	f1_arg0:addElementToPendingUpdateStateList( self )
	local focusCatcher = nil
	
	focusCatcher = CoD.emptyFocusableNoCursorUpdate.new( f1_arg0, f1_arg1, 0, 1, 0, 0, 0, 1, 0, 0 )
	self:addElement( focusCatcher )
	self.focusCatcher = focusCatcher
	
	local FocusGlow = LUI.UIImage.new( 0, 1, -78, 78, 0, 1, -29, 29 )
	FocusGlow:setAlpha( 0 )
	FocusGlow:setImage( RegisterImage( @"hash_4B8F10D49D85E9C4" ) )
	FocusGlow:setMaterial( LUI.UIImage.GetCachedMaterial( @"hash_6DAB59B2CAE01851" ) )
	FocusGlow:setShaderVector( 0, 0, 0, 0, 0 )
	FocusGlow:setShaderVector( 1, 1.2, 0, 0, 0 )
	FocusGlow:setupNineSliceShader( 160, 100 )
	self:addElement( FocusGlow )
	self.FocusGlow = FocusGlow
	
	local NoiseTiledBacking = LUI.UIImage.new( 0, 1, 0, 0, 0, 1, 0, 0 )
	NoiseTiledBacking:setAlpha( 0.8 )
	NoiseTiledBacking:setImage( RegisterImage( @"hash_634839E8065B1E53" ) )
	NoiseTiledBacking:setMaterial( LUI.UIImage.GetCachedMaterial( @"hash_16CBE95C250C6D15" ) )
	NoiseTiledBacking:setShaderVector( 0, 0, 0, 0, 0 )
	NoiseTiledBacking:setupNineSliceShader( 196, 88 )
	self:addElement( NoiseTiledBacking )
	self.NoiseTiledBacking = NoiseTiledBacking
	
	local DotTiledBacking = CoD.StoreCommonTextBacking.new( f1_arg0, f1_arg1, 0, 1, 4, -4, 0, 1, 4, -4 )
	self:addElement( DotTiledBacking )
	self.DotTiledBacking = DotTiledBacking
	
	local SelectorOverlay = LUI.UIImage.new( 0, 1, 4, -4, 0, 1, 4, -4 )
	SelectorOverlay:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )
	SelectorOverlay:setAlpha( 0.02 )
	self:addElement( SelectorOverlay )
	self.SelectorOverlay = SelectorOverlay
	
	local SettingLabel = LUI.UIText.new( 0, 1, 16, -234, 0.5, 0.5, -10.5, 10.5 )
	SettingLabel:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )
	SettingLabel:setTTF( "ttmussels_regular" )
	SettingLabel:setAlignment( Enum[@"hash_67A5123B654282D2"][@"hash_558C8A85F2048829"] )
	SettingLabel:setAlignment( Enum[@"hash_67A5123B654282D2"][@"hash_6ED4298C93DC5ED"] )
	SettingLabel:linkToElementModel( self, "name", true, function ( model )
		local f2_local0 = model:get()
		if f2_local0 ~= nil then
			SettingLabel:setText( f2_local0 )
		end
	end )
	self:addElement( SettingLabel )
	self.SettingLabel = SettingLabel

	local CustomSettingsIndicator = CoD.StartMenu_Options_CustomSettingsIndicator.new( f1_arg0, f1_arg1, 0, 0, 2, 5, 0, 0, 2, 58 )
	CustomSettingsIndicator:mergeStateConditions( {
		{
			stateName = "Visible",
			condition = function ( menu, element, event )
				return not IsCustomGameSettingDefault_WZ( self, f1_arg1 )
			end
		}
	} )
	local CurrentOptionBorderDefault = CustomSettingsIndicator
	local CurrentOptionBorderCustom = Engine[@"getglobalmodel"]()
	CustomSettingsIndicator.subscribeToModel( CurrentOptionBorderDefault, CurrentOptionBorderCustom["GametypeSettings.Update"], function ( f4_arg0 )
		f1_arg0:updateElementState( CustomSettingsIndicator, {
			name = "model_validation",
			menu = f1_arg0,
			controller = f1_arg1,
			modelValue = f4_arg0:get(),
			modelName = "GametypeSettings.Update"
		} )
	end, false )
	CustomSettingsIndicator:linkToElementModel( CustomSettingsIndicator, "name", true, function ( model )
		f1_arg0:updateElementState( CustomSettingsIndicator, {
			name = "model_validation",
			menu = f1_arg0,
			controller = f1_arg1,
			modelValue = model:get(),
			modelName = "name"
		} )
	end )
	CustomSettingsIndicator:linkToElementModel( CustomSettingsIndicator, "setting", true, function ( model )
		f1_arg0:updateElementState( CustomSettingsIndicator, {
			name = "model_validation",
			menu = f1_arg0,
			controller = f1_arg1,
			modelValue = model:get(),
			modelName = "setting"
		} )
	end )
	CustomSettingsIndicator:linkToElementModel( self, nil, false, function ( model )
		CustomSettingsIndicator:setModel( model, f1_arg1 )
	end )
	self:addElement( CustomSettingsIndicator )
	self.CustomSettingsIndicator = CustomSettingsIndicator
	
	local OptionCountBorder = LUI.UIImage.new( 1, 1, -254, -4, 1, 1, -9, -5 )
	OptionCountBorder:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )
	OptionCountBorder:setAlpha( 0 )
	OptionCountBorder:setImage( RegisterImage( @"hash_61B69BB6285C5BBB" ) )
	OptionCountBorder:setMaterial( LUI.UIImage.GetCachedMaterial( @"hash_631E7B3C72564429" ) )
	OptionCountBorder:setShaderVector( 0, 0, 0, 0.55, 0.13 )
	OptionCountBorder:setShaderVector( 1, 10, 1, 0, 0 )
	OptionCountBorder:setShaderVector( 2, 0, 1, 0, 1 )
	OptionCountBorder:setupNineSliceShader( 25, 4 )
	self:addElement( OptionCountBorder )
	self.OptionCountBorder = OptionCountBorder
	
	local CurrentOptionBorder = LUI.UIImage.new( 1, 1, -254, -4, 1, 1, -9, -5 )
	CurrentOptionBorder:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )
	CurrentOptionBorder:setImage( RegisterImage( @"hash_61B69BB6285C5BBB" ) )
	CurrentOptionBorder:setMaterial( LUI.UIImage.GetCachedMaterial( @"hash_631E7B3C72564429" ) )
	CurrentOptionBorder:setShaderVector( 0, 0, 0, 0.55, 0.13 )
	CurrentOptionBorder:setShaderVector( 1, 10, 1, 0, 0 )
	CurrentOptionBorder:setShaderVector( 2, 0.3, 0.4, 0, 1 )
	CurrentOptionBorder:setupNineSliceShader( 25, 4 )
	self:addElement( CurrentOptionBorder )
	self.CurrentOptionBorder = CurrentOptionBorder
	
	local SettingSliderList = LUI.UIList.new( f1_arg0, f1_arg1, 2, 0, nil, false, false, false, false )
	SettingSliderList:mergeStateConditions( {
		{
			stateName = "KBMCustom",
			condition = function ( menu, element, event )
				return AlwaysFalse()
			end
		},
		{
			stateName = "Custom",
			condition = function ( menu, element, event )
				return AlwaysFalse()
			end
		}
	} )
	SettingSliderList:appendEventHandler( "input_source_changed", function ( f5_arg0, f5_arg1 )
		f5_arg1.menu = f5_arg1.menu or f1_arg0
		f1_arg0:updateElementState( SettingSliderList, f5_arg1 )
	end )
	local TopBarFocus = SettingSliderList
	local emptyFocusable = SettingSliderList.subscribeToModel
	local ItemFrameAdd = Engine[@"hash_4DF5CFBC1771947"]( f1_arg1 )
	emptyFocusable( TopBarFocus, ItemFrameAdd.LastInput, function ( f6_arg0 )
		f1_arg0:updateElementState( SettingSliderList, {
			name = "model_validation",
			menu = f1_arg0,
			controller = f1_arg1,
			modelValue = f6_arg0:get(),
			modelName = "LastInput"
		} )
	end, false )
	SettingSliderList:setLeftRight( 1, 1, -700, 0 )
	SettingSliderList:setTopBottom( 0.5, 0.5, -20, 20 )
	SettingSliderList:setWidgetType( CoD.CustomGames_SettingSliderList )
	SettingSliderList:setAlignment( Enum[@"hash_67A5123B654282D2"][@"hash_558C8A85F2048829"] )
	SettingSliderList:linkToElementModel( self, "optionsDatasource", true, function ( model )
		local f7_local0 = model:get()
		if f7_local0 ~= nil then
			SettingSliderList:setDataSource( f7_local0 )
		end
	end )
	SettingSliderList:registerEventHandler( "list_active_changed", function ( element, event )
		local f8_local0 = nil
		if IsMouseOrKeyboard( f1_arg1 ) then
			CoD.OptionsUtility.UpdateSettingSliderBarsNoCustom( self, element, f1_arg1, "OptionCountBorder", "CurrentOptionBorder" )
			ProcessListAction( self, element, f1_arg1, f1_arg0 )
		else
			CoD.OptionsUtility.UpdateSettingSliderBarsNoCustom( self, element, f1_arg1, "OptionCountBorder", "CurrentOptionBorder" )
		end
		return f8_local0
	end )
	SettingSliderList:registerEventHandler( "list_item_gain_focus", function ( element, event )
		local f9_local0 = nil
		if not IsMouseOrKeyboard( f1_arg1 ) then
			ProcessListAction( self, element, f1_arg1, f1_arg0 )
		end
		return f9_local0
	end )
	SettingSliderList:subscribeToGlobalModel( f1_arg1, "GlobalModel", "GametypeSettings.Reset", function ( model )
		CoD.GridAndListUtility.UpdateDataSource( SettingSliderList, false, false, true )
	end )
	self:addElement( SettingSliderList )
	self.SettingSliderList = SettingSliderList
	
	emptyFocusable = nil
	
	emptyFocusable = CoD.emptyFocusableNoYield.new( f1_arg0, f1_arg1, 0, 1, 0, 0, 0, 1, 0, 0 )
	self:addElement( emptyFocusable )
	self.emptyFocusable = emptyFocusable
	
	TopBarFocus = LUI.UIImage.new( 0, 0, -33.5, 31.5, 0.5, 0.5, -3, 3 )
	TopBarFocus:setAlpha( 0 )
	TopBarFocus:setZRot( -90 )
	TopBarFocus:setImage( RegisterImage( @"hash_7E8B272A3927DAB" ) )
	TopBarFocus:setMaterial( LUI.UIImage.GetCachedMaterial( @"hash_54E6CE42E0799F57" ) )
	self:addElement( TopBarFocus )
	self.TopBarFocus = TopBarFocus
	
	ItemFrameAdd = LUI.UIImage.new( 0, 1, -3, 3, 0, 1, -1, 1 )
	ItemFrameAdd:setAlpha( 0 )
	ItemFrameAdd:setImage( RegisterImage( @"hash_2C2AE59F4FA74812" ) )
	ItemFrameAdd:setMaterial( LUI.UIImage.GetCachedMaterial( @"hash_1FD777557404A7B3" ) )
	ItemFrameAdd:setShaderVector( 0, 0, 0, 0, 0 )
	ItemFrameAdd:setupNineSliceShader( 12, 164 )
	self:addElement( ItemFrameAdd )
	self.ItemFrameAdd = ItemFrameAdd
	
	local FrameSelected = LUI.UIImage.new( 0, 1, -3, 3, 0, 1, -3, 3 )
	FrameSelected:setAlpha( 0 )
	FrameSelected:setImage( RegisterImage( @"hash_CB07CCC28498CB2" ) )
	FrameSelected:setMaterial( LUI.UIImage.GetCachedMaterial( @"hash_1FD777557404A7B3" ) )
	FrameSelected:setShaderVector( 0, 0, 0, 0, 0 )
	FrameSelected:setupNineSliceShader( 8, 8 )
	self:addElement( FrameSelected )
	self.FrameSelected = FrameSelected
	
	local FocusBrackets = CoD.CommonFocusBrackets.new( f1_arg0, f1_arg1, 0, 1, -10, 10, 0, 1, -10, 10 )
	FocusBrackets:setAlpha( 0 )
	self:addElement( FocusBrackets )
	self.FocusBrackets = FocusBrackets
	
	local FocusBorder = LUI.UIImage.new( 0, 1, -4, 4, 0, 1, -4, 4 )
	FocusBorder:setRGB( ColorSet.T8__BIEGE.r, ColorSet.T8__BIEGE.g, ColorSet.T8__BIEGE.b )
	FocusBorder:setAlpha( 0 )
	FocusBorder:setImage( RegisterImage( @"hash_CB07CCC28498CB2" ) )
	FocusBorder:setMaterial( LUI.UIImage.GetCachedMaterial( @"hash_1FD777557404A7B3" ) )
	FocusBorder:setShaderVector( 0, 0, 0, 0, 0 )
	FocusBorder:setupNineSliceShader( 10, 10 )
	self:addElement( FocusBorder )
	self.FocusBorder = FocusBorder
	
	local FrameBorder = LUI.UIImage.new( 0, 1, -1, 1, 0, 1, -1, 1 )
	FrameBorder:setAlpha( 0.3 )
	FrameBorder:setImage( RegisterImage( @"hash_3185E11D74ECA3D7" ) )
	FrameBorder:setMaterial( LUI.UIImage.GetCachedMaterial( @"hash_1FD777557404A7B3" ) )
	FrameBorder:setShaderVector( 0, 0, 0, 0, 0 )
	FrameBorder:setupNineSliceShader( 12, 12 )
	self:addElement( FrameBorder )
	self.FrameBorder = FrameBorder
	
	local LeftArrow = nil
	
	LeftArrow = CoD.StartMenu_Options_SettingSliderArrow.new( f1_arg0, f1_arg1, 1, 1, -111, -57, 0.5, 0.5, -27, 27 )
	LeftArrow:setZRot( -90 )
	LeftArrow:registerEventHandler( "gain_focus", function ( element, event )
		local f11_local0 = nil
		if element.gainFocus then
			f11_local0 = element:gainFocus( event )
		elseif element.super.gainFocus then
			f11_local0 = element.super:gainFocus( event )
		end
		CoD.Menu.UpdateButtonShownState( element, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
		return f11_local0
	end )
	f1_arg0:AddButtonCallbackFunction( LeftArrow, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], nil, function ( element, menu, controller, model )
		CoD.GridAndListUtility.NavigateGridItem( self.SettingSliderList, controller, false )
		return true
	end, function ( element, menu, controller )
		CoD.Menu.SetButtonLabel( menu, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], @"hash_6D0BB36CD318F55F", nil, nil )
		return true
	end, false )
	self:addElement( LeftArrow )
	self.LeftArrow = LeftArrow
	
	local RightArrow = nil
	
	RightArrow = CoD.StartMenu_Options_SettingSliderArrow.new( f1_arg0, f1_arg1, 1, 1, -57, -3, 0.5, 0.5, -27, 27 )
	RightArrow:setZRot( 90 )
	RightArrow:registerEventHandler( "gain_focus", function ( element, event )
		local f14_local0 = nil
		if element.gainFocus then
			f14_local0 = element:gainFocus( event )
		elseif element.super.gainFocus then
			f14_local0 = element.super:gainFocus( event )
		end
		CoD.Menu.UpdateButtonShownState( element, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
		return f14_local0
	end )
	f1_arg0:AddButtonCallbackFunction( RightArrow, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], nil, function ( element, menu, controller, model )
		CoD.GridAndListUtility.NavigateGridItem( self.SettingSliderList, controller, true )
		return true
	end, function ( element, menu, controller )
		CoD.Menu.SetButtonLabel( menu, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], @"hash_6D0BB36CD318F55F", nil, nil )
		return true
	end, false )
	self:addElement( RightArrow )
	self.RightArrow = RightArrow
	
	self:mergeStateConditions( {
		{
			stateName = "KBM",
			condition = function ( menu, element, event )
				return IsMouseOrKeyboard( f1_arg1 )
			end
		}
	} )
	self:appendEventHandler( "input_source_changed", function ( f18_arg0, f18_arg1 )
		f18_arg1.menu = f18_arg1.menu or f1_arg0
		f1_arg0:updateElementState( self, f18_arg1 )
	end )
	local f1_local19 = self
	local f1_local20 = self.subscribeToModel
	local f1_local21 = Engine[@"hash_4DF5CFBC1771947"]( f1_arg1 )
	f1_local20( f1_local19, f1_local21.LastInput, function ( f19_arg0 )
		f1_arg0:updateElementState( self, {
			name = "model_validation",
			menu = f1_arg0,
			controller = f1_arg1,
			modelValue = f19_arg0:get(),
			modelName = "LastInput"
		} )
	end, false )
	if CoD.isPC then
		focusCatcher.id = "focusCatcher"
	end
	SettingSliderList.id = "SettingSliderList"
	if CoD.isPC then
		emptyFocusable.id = "emptyFocusable"
	end
	if CoD.isPC then
		LeftArrow.id = "LeftArrow"
	end
	if CoD.isPC then
		RightArrow.id = "RightArrow"
	end
	self.__defaultFocus = SettingSliderList
	LUI.OverrideFunction_CallOriginalSecond( self, "close", self.__onClose )
	if PostLoadFunc then
		PostLoadFunc( self, f1_arg1, f1_arg0 )
	end
	
	f1_local20 = self
	DisableKeyboardNavigationByElement( focusCatcher )
	DisableKeyboardNavigationByElement( LeftArrow )
	DisableKeyboardNavigationByElement( RightArrow )
	return self
end

CoD.CustomGames_SettingSliderNoCustom_NoLocalize_Internal.__resetProperties = function ( f20_arg0 )
	f20_arg0.CurrentOptionBorder:completeAnimation()
	f20_arg0.LeftArrow:completeAnimation()
	f20_arg0.RightArrow:completeAnimation()
	f20_arg0.OptionCountBorder:completeAnimation()
	f20_arg0.TopBarFocus:completeAnimation()
	f20_arg0.SelectorOverlay:completeAnimation()
	f20_arg0.SettingLabel:completeAnimation()
	f20_arg0.SettingSliderList:completeAnimation()
	f20_arg0.ItemFrameAdd:completeAnimation()
	f20_arg0.FocusGlow:completeAnimation()
	f20_arg0.FocusBorder:completeAnimation()
	f20_arg0.FocusBrackets:completeAnimation()
	f20_arg0.CurrentOptionBorder:setLeftRight( 1, 1, -254, -4 )
	f20_arg0.CurrentOptionBorder:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )
	f20_arg0.CurrentOptionBorder:setAlpha( 1 )
	f20_arg0.LeftArrow:setAlpha( 1 )
	f20_arg0.RightArrow:setAlpha( 1 )
	f20_arg0.OptionCountBorder:setLeftRight( 1, 1, -254, -4 )
	f20_arg0.OptionCountBorder:setAlpha( 0 )
	f20_arg0.TopBarFocus:setAlpha( 0 )
	f20_arg0.SelectorOverlay:setAlpha( 0.02 )
	f20_arg0.SettingLabel:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )
	f20_arg0.SettingSliderList:setLeftRight( 1, 1, -700, 0 )
	f20_arg0.SettingSliderList:setRGB( 1, 1, 1 )
	f20_arg0.ItemFrameAdd:setAlpha( 0 )
	f20_arg0.FocusGlow:setAlpha( 0 )
	f20_arg0.FocusBorder:setAlpha( 0 )
	f20_arg0.FocusBrackets:setLeftRight( 0, 1, -10, 10 )
	f20_arg0.FocusBrackets:setTopBottom( 0, 1, -10, 10 )
	f20_arg0.FocusBrackets:setAlpha( 0 )
end

CoD.CustomGames_SettingSliderNoCustom_NoLocalize_Internal.__clipsPerState = {
	DefaultState = {
		DefaultClip = function ( f21_arg0, f21_arg1 )
			f21_arg0:__resetProperties()
			f21_arg0:setupElementClipCounter( 3 )
			f21_arg0.CurrentOptionBorder:completeAnimation()
			f21_arg0.CurrentOptionBorder:setAlpha( 0 )
			f21_arg0.clipFinished( f21_arg0.CurrentOptionBorder )
			f21_arg0.LeftArrow:completeAnimation()
			f21_arg0.LeftArrow:setAlpha( 0 )
			f21_arg0.clipFinished( f21_arg0.LeftArrow )
			f21_arg0.RightArrow:completeAnimation()
			f21_arg0.RightArrow:setAlpha( 0 )
			f21_arg0.clipFinished( f21_arg0.RightArrow )
		end,
		ChildFocus = function ( f22_arg0, f22_arg1 )
			f22_arg0:__resetProperties()
			f22_arg0:setupElementClipCounter( 12 )
			f22_arg0.FocusGlow:completeAnimation()
			f22_arg0.FocusGlow:setAlpha( 0.6 )
			f22_arg0.clipFinished( f22_arg0.FocusGlow )
			f22_arg0.SelectorOverlay:completeAnimation()
			f22_arg0.SelectorOverlay:setAlpha( 0.04 )
			f22_arg0.clipFinished( f22_arg0.SelectorOverlay )
			f22_arg0.SettingLabel:completeAnimation()
			f22_arg0.SettingLabel:setRGB( 0.92, 0.89, 0.72 )
			f22_arg0.clipFinished( f22_arg0.SettingLabel )
			f22_arg0.OptionCountBorder:completeAnimation()
			f22_arg0.OptionCountBorder:setAlpha( 0.04 )
			f22_arg0.clipFinished( f22_arg0.OptionCountBorder )
			f22_arg0.CurrentOptionBorder:completeAnimation()
			f22_arg0.CurrentOptionBorder:setRGB( 0.92, 0.89, 0.72 )
			f22_arg0.clipFinished( f22_arg0.CurrentOptionBorder )
			f22_arg0.SettingSliderList:completeAnimation()
			f22_arg0.SettingSliderList:setRGB( 0.92, 0.89, 0.72 )
			f22_arg0.clipFinished( f22_arg0.SettingSliderList )
			f22_arg0.TopBarFocus:completeAnimation()
			f22_arg0.TopBarFocus:setAlpha( 1 )
			f22_arg0.clipFinished( f22_arg0.TopBarFocus )
			f22_arg0.ItemFrameAdd:completeAnimation()
			f22_arg0.ItemFrameAdd:setAlpha( 1 )
			f22_arg0.clipFinished( f22_arg0.ItemFrameAdd )
			f22_arg0.FocusBrackets:completeAnimation()
			f22_arg0.FocusBrackets:setLeftRight( 0, 1, -10, 10 )
			f22_arg0.FocusBrackets:setTopBottom( 0, 1, -10, 10 )
			f22_arg0.FocusBrackets:setAlpha( 1 )
			f22_arg0.clipFinished( f22_arg0.FocusBrackets )
			f22_arg0.FocusBorder:completeAnimation()
			f22_arg0.FocusBorder:setAlpha( 1 )
			f22_arg0.clipFinished( f22_arg0.FocusBorder )
			f22_arg0.LeftArrow:completeAnimation()
			f22_arg0.LeftArrow:setAlpha( 0 )
			f22_arg0.clipFinished( f22_arg0.LeftArrow )
			f22_arg0.RightArrow:completeAnimation()
			f22_arg0.RightArrow:setAlpha( 0 )
			f22_arg0.clipFinished( f22_arg0.RightArrow )
		end,
		GainChildFocus = function ( f23_arg0, f23_arg1 )
			f23_arg0:__resetProperties()
			f23_arg0:setupElementClipCounter( 12 )
			local f23_local0 = function ( f24_arg0 )
				f23_arg0.FocusGlow:beginAnimation( 200 )
				f23_arg0.FocusGlow:setAlpha( 0.6 )
				f23_arg0.FocusGlow:registerEventHandler( "interrupted_keyframe", f23_arg0.clipInterrupted )
				f23_arg0.FocusGlow:registerEventHandler( "transition_complete_keyframe", f23_arg0.clipFinished )
			end
			
			f23_arg0.FocusGlow:completeAnimation()
			f23_arg0.FocusGlow:setAlpha( 0 )
			f23_local0( f23_arg0.FocusGlow )
			local f23_local1 = function ( f25_arg0 )
				f23_arg0.SelectorOverlay:beginAnimation( 150 )
				f23_arg0.SelectorOverlay:setAlpha( 0.04 )
				f23_arg0.SelectorOverlay:registerEventHandler( "interrupted_keyframe", f23_arg0.clipInterrupted )
				f23_arg0.SelectorOverlay:registerEventHandler( "transition_complete_keyframe", f23_arg0.clipFinished )
			end
			
			f23_arg0.SelectorOverlay:completeAnimation()
			f23_arg0.SelectorOverlay:setAlpha( 0.02 )
			f23_local1( f23_arg0.SelectorOverlay )
			f23_arg0.SettingLabel:completeAnimation()
			f23_arg0.SettingLabel:setRGB( 0.92, 0.89, 0.72 )
			f23_arg0.clipFinished( f23_arg0.SettingLabel )
			local f23_local2 = function ( f26_arg0 )
				f23_arg0.OptionCountBorder:beginAnimation( 150 )
				f23_arg0.OptionCountBorder:setAlpha( 0.01 )
				f23_arg0.OptionCountBorder:registerEventHandler( "interrupted_keyframe", f23_arg0.clipInterrupted )
				f23_arg0.OptionCountBorder:registerEventHandler( "transition_complete_keyframe", f23_arg0.clipFinished )
			end
			
			f23_arg0.OptionCountBorder:completeAnimation()
			f23_arg0.OptionCountBorder:setAlpha( 0 )
			f23_local2( f23_arg0.OptionCountBorder )
			local f23_local3 = function ( f27_arg0 )
				f23_arg0.CurrentOptionBorder:beginAnimation( 150 )
				f23_arg0.CurrentOptionBorder:setAlpha( 1 )
				f23_arg0.CurrentOptionBorder:registerEventHandler( "interrupted_keyframe", f23_arg0.clipInterrupted )
				f23_arg0.CurrentOptionBorder:registerEventHandler( "transition_complete_keyframe", f23_arg0.clipFinished )
			end
			
			f23_arg0.CurrentOptionBorder:completeAnimation()
			f23_arg0.CurrentOptionBorder:setRGB( 0.92, 0.89, 0.72 )
			f23_arg0.CurrentOptionBorder:setAlpha( 0 )
			f23_local3( f23_arg0.CurrentOptionBorder )
			f23_arg0.SettingSliderList:completeAnimation()
			f23_arg0.SettingSliderList:setRGB( 0.92, 0.89, 0.72 )
			f23_arg0.clipFinished( f23_arg0.SettingSliderList )
			local f23_local4 = function ( f28_arg0 )
				f23_arg0.TopBarFocus:beginAnimation( 150 )
				f23_arg0.TopBarFocus:setAlpha( 1 )
				f23_arg0.TopBarFocus:registerEventHandler( "interrupted_keyframe", f23_arg0.clipInterrupted )
				f23_arg0.TopBarFocus:registerEventHandler( "transition_complete_keyframe", f23_arg0.clipFinished )
			end
			
			f23_arg0.TopBarFocus:completeAnimation()
			f23_arg0.TopBarFocus:setAlpha( 0 )
			f23_local4( f23_arg0.TopBarFocus )
			local f23_local5 = function ( f29_arg0 )
				f23_arg0.ItemFrameAdd:beginAnimation( 150 )
				f23_arg0.ItemFrameAdd:setAlpha( 1 )
				f23_arg0.ItemFrameAdd:registerEventHandler( "interrupted_keyframe", f23_arg0.clipInterrupted )
				f23_arg0.ItemFrameAdd:registerEventHandler( "transition_complete_keyframe", f23_arg0.clipFinished )
			end
			
			f23_arg0.ItemFrameAdd:completeAnimation()
			f23_arg0.ItemFrameAdd:setAlpha( 0 )
			f23_local5( f23_arg0.ItemFrameAdd )
			local f23_local6 = function ( f30_arg0 )
				local f30_local0 = function ( f31_arg0 )
					f31_arg0:beginAnimation( 50 )
					f31_arg0:setLeftRight( 0, 1, -10, 10 )
					f31_arg0:setTopBottom( 0, 1, -10, 10 )
					f31_arg0:setAlpha( 1 )
					f31_arg0:registerEventHandler( "transition_complete_keyframe", f23_arg0.clipFinished )
				end
				
				f23_arg0.FocusBrackets:beginAnimation( 100 )
				f23_arg0.FocusBrackets:setLeftRight( 0, 1, -8, 8 )
				f23_arg0.FocusBrackets:setTopBottom( 0, 1, -8, 8 )
				f23_arg0.FocusBrackets:setAlpha( 0.67 )
				f23_arg0.FocusBrackets:registerEventHandler( "interrupted_keyframe", f23_arg0.clipInterrupted )
				f23_arg0.FocusBrackets:registerEventHandler( "transition_complete_keyframe", f30_local0 )
			end
			
			f23_arg0.FocusBrackets:completeAnimation()
			f23_arg0.FocusBrackets:setLeftRight( 0, 1, -40, 40 )
			f23_arg0.FocusBrackets:setTopBottom( 0, 1, -40, 40 )
			f23_arg0.FocusBrackets:setAlpha( 0 )
			f23_local6( f23_arg0.FocusBrackets )
			local f23_local7 = function ( f32_arg0 )
				f23_arg0.FocusBorder:beginAnimation( 200 )
				f23_arg0.FocusBorder:setAlpha( 1 )
				f23_arg0.FocusBorder:registerEventHandler( "interrupted_keyframe", f23_arg0.clipInterrupted )
				f23_arg0.FocusBorder:registerEventHandler( "transition_complete_keyframe", f23_arg0.clipFinished )
			end
			
			f23_arg0.FocusBorder:completeAnimation()
			f23_arg0.FocusBorder:setAlpha( 0 )
			f23_local7( f23_arg0.FocusBorder )
			f23_arg0.LeftArrow:completeAnimation()
			f23_arg0.LeftArrow:setAlpha( 0 )
			f23_arg0.clipFinished( f23_arg0.LeftArrow )
			f23_arg0.RightArrow:completeAnimation()
			f23_arg0.RightArrow:setAlpha( 0 )
			f23_arg0.clipFinished( f23_arg0.RightArrow )
		end,
		LoseChildFocus = function ( f33_arg0, f33_arg1 )
			f33_arg0:__resetProperties()
			f33_arg0:setupElementClipCounter( 11 )
			f33_arg0.FocusGlow:beginAnimation( 200 )
			f33_arg0.FocusGlow:setAlpha( 0 )
			f33_arg0.FocusGlow:registerEventHandler( "interrupted_keyframe", f33_arg0.clipInterrupted )
			f33_arg0.FocusGlow:registerEventHandler( "transition_complete_keyframe", f33_arg0.clipFinished )
			local f33_local0 = function ( f34_arg0 )
				f33_arg0.SelectorOverlay:beginAnimation( 150 )
				f33_arg0.SelectorOverlay:setAlpha( 0.02 )
				f33_arg0.SelectorOverlay:registerEventHandler( "interrupted_keyframe", f33_arg0.clipInterrupted )
				f33_arg0.SelectorOverlay:registerEventHandler( "transition_complete_keyframe", f33_arg0.clipFinished )
			end
			
			f33_arg0.SelectorOverlay:completeAnimation()
			f33_arg0.SelectorOverlay:setAlpha( 0.04 )
			f33_local0( f33_arg0.SelectorOverlay )
			f33_arg0.SettingLabel:completeAnimation()
			f33_arg0.SettingLabel:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )
			f33_arg0.clipFinished( f33_arg0.SettingLabel )
			local f33_local1 = function ( f35_arg0 )
				f33_arg0.OptionCountBorder:beginAnimation( 150 )
				f33_arg0.OptionCountBorder:setAlpha( 0 )
				f33_arg0.OptionCountBorder:registerEventHandler( "interrupted_keyframe", f33_arg0.clipInterrupted )
				f33_arg0.OptionCountBorder:registerEventHandler( "transition_complete_keyframe", f33_arg0.clipFinished )
			end
			
			f33_arg0.OptionCountBorder:completeAnimation()
			f33_arg0.OptionCountBorder:setAlpha( 0.01 )
			f33_local1( f33_arg0.OptionCountBorder )
			local f33_local2 = function ( f36_arg0 )
				f33_arg0.CurrentOptionBorder:beginAnimation( 150 )
				f33_arg0.CurrentOptionBorder:setAlpha( 0 )
				f33_arg0.CurrentOptionBorder:registerEventHandler( "interrupted_keyframe", f33_arg0.clipInterrupted )
				f33_arg0.CurrentOptionBorder:registerEventHandler( "transition_complete_keyframe", f33_arg0.clipFinished )
			end
			
			f33_arg0.CurrentOptionBorder:completeAnimation()
			f33_arg0.CurrentOptionBorder:setAlpha( 1 )
			f33_local2( f33_arg0.CurrentOptionBorder )
			local f33_local3 = function ( f37_arg0 )
				f33_arg0.TopBarFocus:beginAnimation( 150 )
				f33_arg0.TopBarFocus:setAlpha( 0 )
				f33_arg0.TopBarFocus:registerEventHandler( "interrupted_keyframe", f33_arg0.clipInterrupted )
				f33_arg0.TopBarFocus:registerEventHandler( "transition_complete_keyframe", f33_arg0.clipFinished )
			end
			
			f33_arg0.TopBarFocus:completeAnimation()
			f33_arg0.TopBarFocus:setAlpha( 1 )
			f33_local3( f33_arg0.TopBarFocus )
			local f33_local4 = function ( f38_arg0 )
				f33_arg0.ItemFrameAdd:beginAnimation( 150 )
				f33_arg0.ItemFrameAdd:setAlpha( 0 )
				f33_arg0.ItemFrameAdd:registerEventHandler( "interrupted_keyframe", f33_arg0.clipInterrupted )
				f33_arg0.ItemFrameAdd:registerEventHandler( "transition_complete_keyframe", f33_arg0.clipFinished )
			end
			
			f33_arg0.ItemFrameAdd:completeAnimation()
			f33_arg0.ItemFrameAdd:setAlpha( 1 )
			f33_local4( f33_arg0.ItemFrameAdd )
			f33_arg0.FocusBrackets:beginAnimation( 60 )
			f33_arg0.FocusBrackets:setAlpha( 0 )
			f33_arg0.FocusBrackets:registerEventHandler( "interrupted_keyframe", f33_arg0.clipInterrupted )
			f33_arg0.FocusBrackets:registerEventHandler( "transition_complete_keyframe", f33_arg0.clipFinished )
			f33_arg0.FocusBorder:beginAnimation( 200 )
			f33_arg0.FocusBorder:setAlpha( 0 )
			f33_arg0.FocusBorder:registerEventHandler( "interrupted_keyframe", f33_arg0.clipInterrupted )
			f33_arg0.FocusBorder:registerEventHandler( "transition_complete_keyframe", f33_arg0.clipFinished )
			f33_arg0.LeftArrow:completeAnimation()
			f33_arg0.LeftArrow:setAlpha( 0 )
			f33_arg0.clipFinished( f33_arg0.LeftArrow )
			f33_arg0.RightArrow:completeAnimation()
			f33_arg0.RightArrow:setAlpha( 0 )
			f33_arg0.clipFinished( f33_arg0.RightArrow )
		end
	},
	KBM = {
		DefaultClip = function ( f39_arg0, f39_arg1 )
			f39_arg0:__resetProperties()
			f39_arg0:setupElementClipCounter( 3 )
			f39_arg0.OptionCountBorder:completeAnimation()
			f39_arg0.OptionCountBorder:setLeftRight( 1, 1, -259, -134 )
			f39_arg0.clipFinished( f39_arg0.OptionCountBorder )
			f39_arg0.CurrentOptionBorder:completeAnimation()
			f39_arg0.CurrentOptionBorder:setLeftRight( 1, 1, -259, -134 )
			f39_arg0.CurrentOptionBorder:setAlpha( 0 )
			f39_arg0.clipFinished( f39_arg0.CurrentOptionBorder )
			f39_arg0.SettingSliderList:completeAnimation()
			f39_arg0.SettingSliderList:setLeftRight( 1, 1, -810, -110 )
			f39_arg0.clipFinished( f39_arg0.SettingSliderList )
		end,
		ChildFocus = function ( f40_arg0, f40_arg1 )
			f40_arg0:__resetProperties()
			f40_arg0:setupElementClipCounter( 10 )
			f40_arg0.FocusGlow:completeAnimation()
			f40_arg0.FocusGlow:setAlpha( 0.6 )
			f40_arg0.clipFinished( f40_arg0.FocusGlow )
			f40_arg0.SelectorOverlay:completeAnimation()
			f40_arg0.SelectorOverlay:setAlpha( 0.04 )
			f40_arg0.clipFinished( f40_arg0.SelectorOverlay )
			f40_arg0.SettingLabel:completeAnimation()
			f40_arg0.SettingLabel:setRGB( 0.92, 0.89, 0.72 )
			f40_arg0.clipFinished( f40_arg0.SettingLabel )
			f40_arg0.OptionCountBorder:completeAnimation()
			f40_arg0.OptionCountBorder:setLeftRight( 1, 1, -259, -134 )
			f40_arg0.OptionCountBorder:setAlpha( 0.04 )
			f40_arg0.clipFinished( f40_arg0.OptionCountBorder )
			f40_arg0.CurrentOptionBorder:completeAnimation()
			f40_arg0.CurrentOptionBorder:setLeftRight( 1, 1, -259, -134 )
			f40_arg0.CurrentOptionBorder:setRGB( 0.92, 0.89, 0.72 )
			f40_arg0.clipFinished( f40_arg0.CurrentOptionBorder )
			f40_arg0.SettingSliderList:completeAnimation()
			f40_arg0.SettingSliderList:setLeftRight( 1, 1, -810, -110 )
			f40_arg0.SettingSliderList:setRGB( 0.92, 0.89, 0.72 )
			f40_arg0.clipFinished( f40_arg0.SettingSliderList )
			f40_arg0.TopBarFocus:completeAnimation()
			f40_arg0.TopBarFocus:setAlpha( 1 )
			f40_arg0.clipFinished( f40_arg0.TopBarFocus )
			f40_arg0.ItemFrameAdd:completeAnimation()
			f40_arg0.ItemFrameAdd:setAlpha( 1 )
			f40_arg0.clipFinished( f40_arg0.ItemFrameAdd )
			f40_arg0.FocusBrackets:completeAnimation()
			f40_arg0.FocusBrackets:setLeftRight( 0, 1, -10, 10 )
			f40_arg0.FocusBrackets:setTopBottom( 0, 1, -10, 10 )
			f40_arg0.FocusBrackets:setAlpha( 1 )
			f40_arg0.clipFinished( f40_arg0.FocusBrackets )
			f40_arg0.FocusBorder:completeAnimation()
			f40_arg0.FocusBorder:setAlpha( 1 )
			f40_arg0.clipFinished( f40_arg0.FocusBorder )
		end,
		GainChildFocus = function ( f41_arg0, f41_arg1 )
			f41_arg0:__resetProperties()
			f41_arg0:setupElementClipCounter( 10 )
			local f41_local0 = function ( f42_arg0 )
				f41_arg0.FocusGlow:beginAnimation( 200 )
				f41_arg0.FocusGlow:setAlpha( 0.6 )
				f41_arg0.FocusGlow:registerEventHandler( "interrupted_keyframe", f41_arg0.clipInterrupted )
				f41_arg0.FocusGlow:registerEventHandler( "transition_complete_keyframe", f41_arg0.clipFinished )
			end
			
			f41_arg0.FocusGlow:completeAnimation()
			f41_arg0.FocusGlow:setAlpha( 0 )
			f41_local0( f41_arg0.FocusGlow )
			local f41_local1 = function ( f43_arg0 )
				f41_arg0.SelectorOverlay:beginAnimation( 150 )
				f41_arg0.SelectorOverlay:setAlpha( 0.04 )
				f41_arg0.SelectorOverlay:registerEventHandler( "interrupted_keyframe", f41_arg0.clipInterrupted )
				f41_arg0.SelectorOverlay:registerEventHandler( "transition_complete_keyframe", f41_arg0.clipFinished )
			end
			
			f41_arg0.SelectorOverlay:completeAnimation()
			f41_arg0.SelectorOverlay:setAlpha( 0.02 )
			f41_local1( f41_arg0.SelectorOverlay )
			f41_arg0.SettingLabel:completeAnimation()
			f41_arg0.SettingLabel:setRGB( 0.92, 0.89, 0.72 )
			f41_arg0.clipFinished( f41_arg0.SettingLabel )
			local f41_local2 = function ( f44_arg0 )
				f41_arg0.OptionCountBorder:beginAnimation( 80 )
				f41_arg0.OptionCountBorder:setAlpha( 0.01 )
				f41_arg0.OptionCountBorder:registerEventHandler( "interrupted_keyframe", f41_arg0.clipInterrupted )
				f41_arg0.OptionCountBorder:registerEventHandler( "transition_complete_keyframe", f41_arg0.clipFinished )
			end
			
			f41_arg0.OptionCountBorder:completeAnimation()
			f41_arg0.OptionCountBorder:setLeftRight( 1, 1, -259, -134 )
			f41_arg0.OptionCountBorder:setAlpha( 0 )
			f41_local2( f41_arg0.OptionCountBorder )
			local f41_local3 = function ( f45_arg0 )
				f41_arg0.CurrentOptionBorder:beginAnimation( 150 )
				f41_arg0.CurrentOptionBorder:setAlpha( 1 )
				f41_arg0.CurrentOptionBorder:registerEventHandler( "interrupted_keyframe", f41_arg0.clipInterrupted )
				f41_arg0.CurrentOptionBorder:registerEventHandler( "transition_complete_keyframe", f41_arg0.clipFinished )
			end
			
			f41_arg0.CurrentOptionBorder:completeAnimation()
			f41_arg0.CurrentOptionBorder:setLeftRight( 1, 1, -259, -134 )
			f41_arg0.CurrentOptionBorder:setRGB( 0.92, 0.89, 0.72 )
			f41_arg0.CurrentOptionBorder:setAlpha( 0 )
			f41_local3( f41_arg0.CurrentOptionBorder )
			f41_arg0.SettingSliderList:completeAnimation()
			f41_arg0.SettingSliderList:setLeftRight( 1, 1, -810, -110 )
			f41_arg0.SettingSliderList:setRGB( 0.92, 0.89, 0.72 )
			f41_arg0.clipFinished( f41_arg0.SettingSliderList )
			local f41_local4 = function ( f46_arg0 )
				f41_arg0.TopBarFocus:beginAnimation( 150 )
				f41_arg0.TopBarFocus:setAlpha( 1 )
				f41_arg0.TopBarFocus:registerEventHandler( "interrupted_keyframe", f41_arg0.clipInterrupted )
				f41_arg0.TopBarFocus:registerEventHandler( "transition_complete_keyframe", f41_arg0.clipFinished )
			end
			
			f41_arg0.TopBarFocus:completeAnimation()
			f41_arg0.TopBarFocus:setAlpha( 0 )
			f41_local4( f41_arg0.TopBarFocus )
			local f41_local5 = function ( f47_arg0 )
				f41_arg0.ItemFrameAdd:beginAnimation( 150 )
				f41_arg0.ItemFrameAdd:setAlpha( 1 )
				f41_arg0.ItemFrameAdd:registerEventHandler( "interrupted_keyframe", f41_arg0.clipInterrupted )
				f41_arg0.ItemFrameAdd:registerEventHandler( "transition_complete_keyframe", f41_arg0.clipFinished )
			end
			
			f41_arg0.ItemFrameAdd:completeAnimation()
			f41_arg0.ItemFrameAdd:setAlpha( 0 )
			f41_local5( f41_arg0.ItemFrameAdd )
			local f41_local6 = function ( f48_arg0 )
				local f48_local0 = function ( f49_arg0 )
					f49_arg0:beginAnimation( 50 )
					f49_arg0:setLeftRight( 0, 1, -10, 10 )
					f49_arg0:setTopBottom( 0, 1, -10, 10 )
					f49_arg0:setAlpha( 1 )
					f49_arg0:registerEventHandler( "transition_complete_keyframe", f41_arg0.clipFinished )
				end
				
				f41_arg0.FocusBrackets:beginAnimation( 100 )
				f41_arg0.FocusBrackets:setLeftRight( 0, 1, -8, 8 )
				f41_arg0.FocusBrackets:setTopBottom( 0, 1, -8, 8 )
				f41_arg0.FocusBrackets:setAlpha( 0.67 )
				f41_arg0.FocusBrackets:registerEventHandler( "interrupted_keyframe", f41_arg0.clipInterrupted )
				f41_arg0.FocusBrackets:registerEventHandler( "transition_complete_keyframe", f48_local0 )
			end
			
			f41_arg0.FocusBrackets:completeAnimation()
			f41_arg0.FocusBrackets:setLeftRight( 0, 1, -40, 40 )
			f41_arg0.FocusBrackets:setTopBottom( 0, 1, -40, 40 )
			f41_arg0.FocusBrackets:setAlpha( 0 )
			f41_local6( f41_arg0.FocusBrackets )
			local f41_local7 = function ( f50_arg0 )
				f41_arg0.FocusBorder:beginAnimation( 200 )
				f41_arg0.FocusBorder:setAlpha( 1 )
				f41_arg0.FocusBorder:registerEventHandler( "interrupted_keyframe", f41_arg0.clipInterrupted )
				f41_arg0.FocusBorder:registerEventHandler( "transition_complete_keyframe", f41_arg0.clipFinished )
			end
			
			f41_arg0.FocusBorder:completeAnimation()
			f41_arg0.FocusBorder:setAlpha( 0 )
			f41_local7( f41_arg0.FocusBorder )
		end,
		LoseChildFocus = function ( f51_arg0, f51_arg1 )
			f51_arg0:__resetProperties()
			f51_arg0:setupElementClipCounter( 10 )
			f51_arg0.FocusGlow:beginAnimation( 200 )
			f51_arg0.FocusGlow:setAlpha( 0 )
			f51_arg0.FocusGlow:registerEventHandler( "interrupted_keyframe", f51_arg0.clipInterrupted )
			f51_arg0.FocusGlow:registerEventHandler( "transition_complete_keyframe", f51_arg0.clipFinished )
			local f51_local0 = function ( f52_arg0 )
				f51_arg0.SelectorOverlay:beginAnimation( 150 )
				f51_arg0.SelectorOverlay:setAlpha( 0.02 )
				f51_arg0.SelectorOverlay:registerEventHandler( "interrupted_keyframe", f51_arg0.clipInterrupted )
				f51_arg0.SelectorOverlay:registerEventHandler( "transition_complete_keyframe", f51_arg0.clipFinished )
			end
			
			f51_arg0.SelectorOverlay:completeAnimation()
			f51_arg0.SelectorOverlay:setAlpha( 0.04 )
			f51_local0( f51_arg0.SelectorOverlay )
			f51_arg0.SettingLabel:completeAnimation()
			f51_arg0.SettingLabel:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )
			f51_arg0.clipFinished( f51_arg0.SettingLabel )
			local f51_local1 = function ( f53_arg0 )
				f51_arg0.OptionCountBorder:beginAnimation( 150 )
				f51_arg0.OptionCountBorder:setAlpha( 0 )
				f51_arg0.OptionCountBorder:registerEventHandler( "interrupted_keyframe", f51_arg0.clipInterrupted )
				f51_arg0.OptionCountBorder:registerEventHandler( "transition_complete_keyframe", f51_arg0.clipFinished )
			end
			
			f51_arg0.OptionCountBorder:completeAnimation()
			f51_arg0.OptionCountBorder:setLeftRight( 1, 1, -259, -134 )
			f51_arg0.OptionCountBorder:setAlpha( 0.01 )
			f51_local1( f51_arg0.OptionCountBorder )
			local f51_local2 = function ( f54_arg0 )
				f51_arg0.CurrentOptionBorder:beginAnimation( 150 )
				f51_arg0.CurrentOptionBorder:setAlpha( 0 )
				f51_arg0.CurrentOptionBorder:registerEventHandler( "interrupted_keyframe", f51_arg0.clipInterrupted )
				f51_arg0.CurrentOptionBorder:registerEventHandler( "transition_complete_keyframe", f51_arg0.clipFinished )
			end
			
			f51_arg0.CurrentOptionBorder:completeAnimation()
			f51_arg0.CurrentOptionBorder:setLeftRight( 1, 1, -259, -134 )
			f51_arg0.CurrentOptionBorder:setAlpha( 1 )
			f51_local2( f51_arg0.CurrentOptionBorder )
			f51_arg0.SettingSliderList:completeAnimation()
			f51_arg0.SettingSliderList:setLeftRight( 1, 1, -810, -110 )
			f51_arg0.clipFinished( f51_arg0.SettingSliderList )
			local f51_local3 = function ( f55_arg0 )
				f51_arg0.TopBarFocus:beginAnimation( 150 )
				f51_arg0.TopBarFocus:setAlpha( 0 )
				f51_arg0.TopBarFocus:registerEventHandler( "interrupted_keyframe", f51_arg0.clipInterrupted )
				f51_arg0.TopBarFocus:registerEventHandler( "transition_complete_keyframe", f51_arg0.clipFinished )
			end
			
			f51_arg0.TopBarFocus:completeAnimation()
			f51_arg0.TopBarFocus:setAlpha( 1 )
			f51_local3( f51_arg0.TopBarFocus )
			local f51_local4 = function ( f56_arg0 )
				f51_arg0.ItemFrameAdd:beginAnimation( 150 )
				f51_arg0.ItemFrameAdd:setAlpha( 0 )
				f51_arg0.ItemFrameAdd:registerEventHandler( "interrupted_keyframe", f51_arg0.clipInterrupted )
				f51_arg0.ItemFrameAdd:registerEventHandler( "transition_complete_keyframe", f51_arg0.clipFinished )
			end
			
			f51_arg0.ItemFrameAdd:completeAnimation()
			f51_arg0.ItemFrameAdd:setAlpha( 1 )
			f51_local4( f51_arg0.ItemFrameAdd )
			f51_arg0.FocusBrackets:beginAnimation( 60 )
			f51_arg0.FocusBrackets:setAlpha( 0 )
			f51_arg0.FocusBrackets:registerEventHandler( "interrupted_keyframe", f51_arg0.clipInterrupted )
			f51_arg0.FocusBrackets:registerEventHandler( "transition_complete_keyframe", f51_arg0.clipFinished )
			f51_arg0.FocusBorder:beginAnimation( 200 )
			f51_arg0.FocusBorder:setAlpha( 0 )
			f51_arg0.FocusBorder:registerEventHandler( "interrupted_keyframe", f51_arg0.clipInterrupted )
			f51_arg0.FocusBorder:registerEventHandler( "transition_complete_keyframe", f51_arg0.clipFinished )
		end
	}
}

CoD.CustomGames_SettingSliderNoCustom_NoLocalize_Internal.__onClose = function ( f57_arg0 )
	f57_arg0.focusCatcher:close()
	f57_arg0.DotTiledBacking:close()
	f57_arg0.SettingLabel:close()
	f57_arg0.SettingSliderList:close()
	f57_arg0.emptyFocusable:close()
	f57_arg0.FocusBrackets:close()
	f57_arg0.LeftArrow:close()
	f57_arg0.RightArrow:close()
	f57_arg0.CustomSettingsIndicator:close()
end

-- for blackout too, no buttons
CoD.verticalCounter_no_buttons = InheritFrom( LUI.UIElement )
CoD.verticalCounter_no_buttons.__defaultWidth = 300
CoD.verticalCounter_no_buttons.__defaultHeight = 37
CoD.verticalCounter_no_buttons.new = function ( f1_arg0, f1_arg1, f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	local self = LUI.UIElement.new( f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	self:setClass( CoD.verticalCounter_no_buttons )
	self.id = "verticalCounter_no_buttons"
	self.soundSet = "default"
	self.onlyChildrenFocusable = true
	self.anyChildUsesUpdateState = true
	f1_arg0:addElementToPendingUpdateStateList( self )
	
	local currentItem = LUI.UIText.new( 0.5, 0.5, -57, -12, 0.5, 0.5, -9, 9 )
	currentItem:setAlpha( 0.65 )
	currentItem:setText( "" )
	currentItem:setTTF( "ttmussels_regular" )
	currentItem:setAlignment( Enum[@"hash_67A5123B654282D2"][@"hash_3830CFD395E6AA0A"] )
	currentItem:setAlignment( Enum[@"hash_67A5123B654282D2"][@"hash_3F41D595A2B0EDF3"] )
	self:addElement( currentItem )
	self.currentItem = currentItem
	
	local dividor = LUI.UIText.new( 0.5, 0.5, -4.5, 4.5, 0.5, 0.5, -9, 9 )
	dividor:setAlpha( 0.65 )
	dividor:setText( Engine[@"hash_4F9F1239CFD921FE"]( @"hash_6993C1A7DD3452BA" ) )
	dividor:setTTF( "ttmussels_regular" )
	dividor:setAlignment( Enum[@"hash_67A5123B654282D2"][@"hash_1FEEB12BCB0D7041"] )
	self:addElement( dividor )
	self.dividor = dividor
	
	local count = LUI.UIText.new( 0.5, 0.5, 12, 57, 0.5, 0.5, -9, 9 )
	count:setAlpha( 0.65 )
	count:setText( "" )
	count:setTTF( "ttmussels_regular" )
	count:setAlignment( Enum[@"hash_67A5123B654282D2"][@"hash_558C8A85F2048829"] )
	count:setAlignment( Enum[@"hash_67A5123B654282D2"][@"hash_3F41D595A2B0EDF3"] )
	self:addElement( count )
	self.count = count
	
	local downArrowBtn = CoD.listCounterButton.new( f1_arg0, f1_arg1, 0.5, 0.5, -107.5, -57.5, 0.5, 0.5, -25, 25 )
	downArrowBtn:mergeStateConditions( {
		{
			stateName = "Hidden",
			condition = function ( menu, element, event )
				return AlwaysFalse()
			end
		},
		{
			stateName = "Disabled",
			condition = function ( menu, element, event )
				return AlwaysTrue()
			end
		}
	} )
	local f1_local5 = downArrowBtn
	local upArrowBtn = downArrowBtn.subscribeToModel
	local f1_local7 = DataSources.FreeCursor.getModel( f1_arg1 )
	upArrowBtn( f1_local5, f1_local7.usingCursorInput, function ( f4_arg0 )
		f1_arg0:updateElementState( downArrowBtn, {
			name = "model_validation",
			menu = f1_arg0,
			controller = f1_arg1,
			modelValue = f4_arg0:get(),
			modelName = "usingCursorInput"
		} )
	end, false )
	f1_local5 = downArrowBtn
	upArrowBtn = downArrowBtn.subscribeToModel
	f1_local7 = DataSources.FreeCursor.getModel( f1_arg1 )
	upArrowBtn( f1_local5, f1_local7.hidden, function ( f5_arg0 )
		f1_arg0:updateElementState( downArrowBtn, {
			name = "model_validation",
			menu = f1_arg0,
			controller = f1_arg1,
			modelValue = f5_arg0:get(),
			modelName = "hidden"
		} )
	end, false )
	f1_local5 = downArrowBtn
	upArrowBtn = downArrowBtn.subscribeToModel
	f1_local7 = Engine[@"hash_4DF5CFBC1771947"]( f1_arg1 )
	upArrowBtn( f1_local5, f1_local7.activeKeys, function ( f6_arg0 )
		f1_arg0:updateElementState( downArrowBtn, {
			name = "model_validation",
			menu = f1_arg0,
			controller = f1_arg1,
			modelValue = f6_arg0:get(),
			modelName = "activeKeys"
		} )
	end, false )
	downArrowBtn:setZRot( 180 )
	downArrowBtn:registerEventHandler( "gain_focus", function ( element, event )
		local f7_local0 = nil
		if element.gainFocus then
			f7_local0 = element:gainFocus( event )
		elseif element.super.gainFocus then
			f7_local0 = element.super:gainFocus( event )
		end
		CoD.Menu.UpdateButtonShownState( element, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
		return f7_local0
	end )
	f1_arg0:AddButtonCallbackFunction( downArrowBtn, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], "ui_confirm", function ( element, menu, controller, model )
		NavigateScrollButtonDown( self )
		return true
	end, function ( element, menu, controller )
		CoD.Menu.SetButtonLabel( menu, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], @"hash_0", nil, "ui_confirm" )
		return false
	end, false )
	self:addElement( downArrowBtn )
	self.downArrowBtn = downArrowBtn
	
	upArrowBtn = CoD.listCounterButton.new( f1_arg0, f1_arg1, 0.5, 0.5, 57.5, 107.5, 0.5, 0.5, -25, 25 )
	upArrowBtn:mergeStateConditions( {
		{
			stateName = "Hidden",
			condition = function ( menu, element, event )
				return AlwaysFalse()
			end
		},
		{
			stateName = "Disabled",
			condition = function ( menu, element, event )
				return AlwaysTrue()
			end
		}
	} )
	f1_local7 = upArrowBtn
	f1_local5 = upArrowBtn.subscribeToModel
	local f1_local8 = DataSources.FreeCursor.getModel( f1_arg1 )
	f1_local5( f1_local7, f1_local8.usingCursorInput, function ( f12_arg0 )
		f1_arg0:updateElementState( upArrowBtn, {
			name = "model_validation",
			menu = f1_arg0,
			controller = f1_arg1,
			modelValue = f12_arg0:get(),
			modelName = "usingCursorInput"
		} )
	end, false )
	f1_local7 = upArrowBtn
	f1_local5 = upArrowBtn.subscribeToModel
	f1_local8 = DataSources.FreeCursor.getModel( f1_arg1 )
	f1_local5( f1_local7, f1_local8.hidden, function ( f13_arg0 )
		f1_arg0:updateElementState( upArrowBtn, {
			name = "model_validation",
			menu = f1_arg0,
			controller = f1_arg1,
			modelValue = f13_arg0:get(),
			modelName = "hidden"
		} )
	end, false )
	f1_local7 = upArrowBtn
	f1_local5 = upArrowBtn.subscribeToModel
	f1_local8 = Engine[@"hash_4DF5CFBC1771947"]( f1_arg1 )
	f1_local5( f1_local7, f1_local8.activeKeys, function ( f14_arg0 )
		f1_arg0:updateElementState( upArrowBtn, {
			name = "model_validation",
			menu = f1_arg0,
			controller = f1_arg1,
			modelValue = f14_arg0:get(),
			modelName = "activeKeys"
		} )
	end, false )
	upArrowBtn:registerEventHandler( "gain_focus", function ( element, event )
		local f15_local0 = nil
		if element.gainFocus then
			f15_local0 = element:gainFocus( event )
		elseif element.super.gainFocus then
			f15_local0 = element.super:gainFocus( event )
		end
		CoD.Menu.UpdateButtonShownState( element, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
		return f15_local0
	end )
	f1_arg0:AddButtonCallbackFunction( upArrowBtn, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], "ui_confirm", function ( element, menu, controller, model )
		NavigateScrollButtonUp( self )
		return true
	end, function ( element, menu, controller )
		CoD.Menu.SetButtonLabel( menu, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], @"hash_0", nil, "ui_confirm" )
		return false
	end, false )
	self:addElement( upArrowBtn )
	self.upArrowBtn = upArrowBtn
	
	self:mergeStateConditions( {
		{
			stateName = "AtTopAndBottom",
			condition = function ( menu, element, event )
				return IsSelfInState( self, "AtTopAndBottom" )
			end
		},
		{
			stateName = "AtTop",
			condition = function ( menu, element, event )
				return IsSelfInState( self, "AtTop" )
			end
		},
		{
			stateName = "AtBottom",
			condition = function ( menu, element, event )
				return IsSelfInState( self, "AtBottom" )
			end
		},
		{
			stateName = "NoItems",
			condition = function ( menu, element, event )
				return IsSelfInState( self, "NoItems" )
			end
		}
	} )
	LUI.OverrideFunction_CallOriginalFirst( self, "setState", function ( element, controller, f22_arg2, f22_arg3, f22_arg4 )
		UpdateElementState( self, "downArrowBtn", controller )
		UpdateElementState( self, "upArrowBtn", controller )
	end )
	downArrowBtn.id = "downArrowBtn"
	upArrowBtn.id = "upArrowBtn"
	self.__defaultFocus = downArrowBtn
	LUI.OverrideFunction_CallOriginalSecond( self, "close", self.__onClose )
	
	if PostLoadFunc then
		PostLoadFunc( self, f1_arg1, f1_arg0 )
	end
	
	return self
end

CoD.verticalCounter_no_buttons.__resetProperties = function ( f23_arg0 )
	f23_arg0.currentItem:completeAnimation()
	f23_arg0.dividor:completeAnimation()
	f23_arg0.count:completeAnimation()
	f23_arg0.downArrowBtn:completeAnimation()
	f23_arg0.upArrowBtn:completeAnimation()
	f23_arg0.currentItem:setAlpha( 0.65 )
	f23_arg0.dividor:setAlpha( 0.65 )
	f23_arg0.count:setAlpha( 0.65 )
	f23_arg0.downArrowBtn:setAlpha( 1 )
	f23_arg0.upArrowBtn:setAlpha( 1 )
end

CoD.verticalCounter_no_buttons.__clipsPerState = {
	DefaultState = {
		DefaultClip = function ( f24_arg0, f24_arg1 )
			f24_arg0:__resetProperties()
			f24_arg0:setupElementClipCounter( 3 )
			f24_arg0.currentItem:completeAnimation()
			f24_arg0.currentItem:setAlpha( 1 )
			f24_arg0.clipFinished( f24_arg0.currentItem )
			f24_arg0.dividor:completeAnimation()
			f24_arg0.dividor:setAlpha( 1 )
			f24_arg0.clipFinished( f24_arg0.dividor )
			f24_arg0.count:completeAnimation()
			f24_arg0.count:setAlpha( 1 )
			f24_arg0.clipFinished( f24_arg0.count )
		end
	},
	AtTopAndBottom = {
		DefaultClip = function ( f25_arg0, f25_arg1 )
			f25_arg0:__resetProperties()
			f25_arg0:setupElementClipCounter( 5 )
			f25_arg0.currentItem:completeAnimation()
			f25_arg0.currentItem:setAlpha( 0 )
			f25_arg0.clipFinished( f25_arg0.currentItem )
			f25_arg0.dividor:completeAnimation()
			f25_arg0.dividor:setAlpha( 0 )
			f25_arg0.clipFinished( f25_arg0.dividor )
			f25_arg0.count:completeAnimation()
			f25_arg0.count:setAlpha( 0 )
			f25_arg0.clipFinished( f25_arg0.count )
			f25_arg0.downArrowBtn:completeAnimation()
			f25_arg0.downArrowBtn:setAlpha( 0 )
			f25_arg0.clipFinished( f25_arg0.downArrowBtn )
			f25_arg0.upArrowBtn:completeAnimation()
			f25_arg0.upArrowBtn:setAlpha( 0 )
			f25_arg0.clipFinished( f25_arg0.upArrowBtn )
		end
	},
	AtTop = {
		DefaultClip = function ( f26_arg0, f26_arg1 )
			f26_arg0:__resetProperties()
			f26_arg0:setupElementClipCounter( 3 )
			f26_arg0.currentItem:completeAnimation()
			f26_arg0.currentItem:setAlpha( 1 )
			f26_arg0.clipFinished( f26_arg0.currentItem )
			f26_arg0.dividor:completeAnimation()
			f26_arg0.dividor:setAlpha( 1 )
			f26_arg0.clipFinished( f26_arg0.dividor )
			f26_arg0.count:completeAnimation()
			f26_arg0.count:setAlpha( 1 )
			f26_arg0.clipFinished( f26_arg0.count )
		end
	},
	AtBottom = {
		DefaultClip = function ( f27_arg0, f27_arg1 )
			f27_arg0:__resetProperties()
			f27_arg0:setupElementClipCounter( 3 )
			f27_arg0.currentItem:completeAnimation()
			f27_arg0.currentItem:setAlpha( 1 )
			f27_arg0.clipFinished( f27_arg0.currentItem )
			f27_arg0.dividor:completeAnimation()
			f27_arg0.dividor:setAlpha( 1 )
			f27_arg0.clipFinished( f27_arg0.dividor )
			f27_arg0.count:completeAnimation()
			f27_arg0.count:setAlpha( 1 )
			f27_arg0.clipFinished( f27_arg0.count )
		end
	},
	NoItems = {
		DefaultClip = function ( f28_arg0, f28_arg1 )
			f28_arg0:__resetProperties()
			f28_arg0:setupElementClipCounter( 5 )
			f28_arg0.currentItem:completeAnimation()
			f28_arg0.currentItem:setAlpha( 0 )
			f28_arg0.clipFinished( f28_arg0.currentItem )
			f28_arg0.dividor:completeAnimation()
			f28_arg0.dividor:setAlpha( 0 )
			f28_arg0.clipFinished( f28_arg0.dividor )
			f28_arg0.count:completeAnimation()
			f28_arg0.count:setAlpha( 0 )
			f28_arg0.clipFinished( f28_arg0.count )
			f28_arg0.downArrowBtn:completeAnimation()
			f28_arg0.downArrowBtn:setAlpha( 0 )
			f28_arg0.clipFinished( f28_arg0.downArrowBtn )
			f28_arg0.upArrowBtn:completeAnimation()
			f28_arg0.upArrowBtn:setAlpha( 0 )
			f28_arg0.clipFinished( f28_arg0.upArrowBtn )
		end
	}
}

CoD.verticalCounter_no_buttons.__onClose = function ( f29_arg0 )
	f29_arg0.downArrowBtn:close()
	f29_arg0.upArrowBtn:close()
end