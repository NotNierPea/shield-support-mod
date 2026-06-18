--[[
		.\hksc.exe ".\Lua\ModManager.Lua" -o "C:\Program Files (x86)\Call of Duty Black Ops 4\project-bo4\mods\T8ShieldSupport\Lua\ModManager.luac"
]]

---------------------------

CoD.ShieldInitLuaFile()

---------------------------

local shield_mods = {}

---------------------------

CoD.Shield.ModManagerToastUpdate = function(event_name, event_table)
	-- Play a little sound
	Engine[@"playsound"]("uin_map_vote")

	-- Default values
	local message = event_name

	if type(event_table) == "table" and type(event_table.message) == "string" then
		message = event_table.message
	end

	-- debug
	CoD.EnhPrintInfo("Got Mod Toast", message)

	-- Show the toast
	if CoD.OverlayUtility.ShowToast then
		CoD.OverlayUtility.ShowToast("Mod Manager", "Update", message, "mm_icon")
	end
end

CoD.Shield.ModManagerPrecentUpdate = function(event_name, event_table)
	if CoD.Menu.C_Status ~= nil then
		CoD.Menu.C_Status:setText("Status: " .. event_table.precent)
	end
end

CoD.Shield.DownloadedModCallback = function(event_name, event_table)
	if CoD.Menu.C_Status ~= nil then
		CoD.Menu.C_Status:setText("Status: Download and Extraction Complete!")
	end

	if CoD.Menu.ActiveModsList ~= nil then
		if CoD.Menu.C_Status ~= nil then
			CoD.Menu.C_Status:setText("Status: Idle")
		end
	end

	local message = "Download and Extraction Complete!"

	if type(event_table) == "table" and type(event_table.message) == "string" then
		message = event_table.message
	end

	-- Show the toast, with sound
	CoD.Shield.ModManagerToastUpdate(message)
end

CoD.Shield.ModManagerModListUpdate = function(event_name, event_table)
	local raw = event_table.mods or ""
	shield_mods = {}

    for mod in string.gmatch(raw, "([^,]+)") do
        table.insert(shield_mods, mod)
    end

    for i, name in ipairs(shield_mods) do
        CoD.EnhPrintInfo("Found mod: " .. name)
    end

	if CoD.Menu.ActiveModsList ~= nil then
		CoD.Menu.ActiveModsList:setDataSource( "ShieldActiveModsList" )
		CoD.Menu.ActiveModsList:updateDataSource()
	end
end

CoD.Shield.ModManagerModTestTable = function(event_name, event_table)
	local stuff = event_table.mods
	if stuff then
		for i, mod in ipairs(stuff) do
			CoD.EnhPrintInfo("test table: " .. i .. " - " .. mod.code .. " - " .. mod.str .. " - " .. mod.duration)
		end
	end

	CoD.EnhPrintInfo("test table index..: " .. stuff[1].code)
end

---------------------------

-- Mods
DataSources.ShieldFeaturedModsList = DataSourceHelpers.ListSetup( "ShieldFeaturedModsList", function ( f3_arg0, f3_arg1 )
	local InfoMods = {
		{
			models = {
				title = "[ZM] - Enhancement Mod",
				icon = "ui_menu_ftue_zm_custom_mutations",
				desc = "Improves the zombies experience with a lot of mods and a config in a menu. By peawhatever",
				link = "github.com/NotNierPea/shield-MM-mods/releases/download/release/EnhancementModT8.zip"
			},
			properties = {
				-- none yet
			}
		},
		{
			models = {
				title = "[ZM] - Rush Mod",
				icon = "mod_manager_rush",
				desc = "Chaos Mod like for zombies, a lot of ducks too. By peawhatever",
				link = "github.com/NotNierPea/shield-MM-mods/releases/download/release/RushModT8.zip"
			},
			properties = {
				-- none yet
			}
		},
		{
			models = {
				title = "[ALL] - Atian Mod Menu",
				icon = "mod_manager_french",
				desc = "A really cool looking mod menu by a french man (ATE47), Note: might randomly crash in long sessions..",
				link = "github.com/ate47/t8-atian-menu/releases/download/latest_build/BlackOps4_shield_atianmenu.zip"
			},
			properties = {
				-- none yet
			}
		},
		{
			models = {
				title = "[ALL] - Black Ops 4 Menu",
				icon = "mod_manager_kim",
				desc = "a menu made for Blackout, Multiplayer and Zombies. the code as easy to read as possible for devs. By Kam",
				link = "github.com/NotNierPea/shield-MM-mods/releases/download/release/BlackOps4Menu.zip"
			},
			properties = {
				-- none yet
			}
		},
		{
			models = {
				title = "[ZM] - Survival Maps",
				icon = "mod_manager_surv",
				desc = "Survival mod, first room only like, made by GerardS0406",
				link = "github.com/NotNierPea/shield-MM-mods/releases/download/release/survival.zip"
			},
			properties = {
				-- none yet
			}
		},
		{
			models = {
				title = "[ZM] - Abomination Menu",
				icon = "mod_manager_abom",
				desc = "Mod Menu made for zombies, by SirCryptic",
				link = "github.com/NotNierPea/shield-MM-mods/releases/download/release/abdom.zip"
			},
			properties = {
				-- none yet
			}
		},
		{
			models = {
				title = "[MP/ZM] - Synergy Mod Menu",
				icon = "mod_manager_synergy",
				desc = "Mod Menu made for zombies and multiplayer, by SyndiShanX",
				link = "github.com/SyndiShanX/Synergy-BO4-GSC-Menu/releases/download/Latest/Synergy.zip"
			},
			properties = {
				-- none yet
			}
		},
		{
			models = {
				title = "[ZM] - Gun Game",
				icon = "ui_menu_ftue_zm_tutorial_mode",
				desc = "Gun Game mod for zombies, by SyndiShanX",
				link = "github.com/SyndiShanX/Synergy-BO4-GSC-Menu/releases/download/Latest/Gun_Game.zip"
			},
			properties = {
				-- none yet
			}
		},
		{
			models = {
				title = "[ZM] - Round Timer",
				icon = "mod_manager_timers",
				desc = "Adds a round timer to zombies. By RealD4rk9",
				link = "github.com/NotNierPea/shield-MM-mods/releases/download/release/TimersMod.zip"
			},
			properties = {
				-- none yet
			}
		}
	}
	return InfoMods
end, true )

-- Active Nods
DataSources.ShieldActiveModsList = DataSourceHelpers.ListSetup( "ShieldActiveModsList", function ( f3_arg0, f3_arg1 )
	local InfoMods = {

	}

	for i, name in ipairs(shield_mods) do
		table.insert( InfoMods, {
			models = {
				ModName = name,
			},
			properties = {
	
			}
		} )
    end

	return InfoMods
end, true )

---------------------------

-- Mods Widget Active One
CoD.ShieldActiveModRow = InheritFrom( LUI.UIElement )
CoD.ShieldActiveModRow.__defaultWidth = 1070
CoD.ShieldActiveModRow.__defaultHeight = 37
CoD.ShieldActiveModRow.new = function ( f1_arg0, f1_arg1, f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	local self = LUI.UIElement.new( f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	self:setClass( CoD.ShieldActiveModRow )
	self.id = "ShieldActiveModRow"
	self.soundSet = "default"
	f1_arg0:addElementToPendingUpdateStateList( self )
	
	local BlackBar = LUI.UIImage.new( 0, 1, 0, 0, 0, 1, 1, 1 )
	BlackBar:setRGB( 0.78, 0.78, 0.78 )
	BlackBar:setAlpha( 0.01 )
	self:addElement( BlackBar )
	self.BlackBar = BlackBar
	
	local ModName = LUI.UIText.new( 0, 0, 15, 413, 0, 0, 6.5, 30.5 )
	ModName:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )
	ModName:setTTF( "ttmussels_regular" )
	ModName:setLetterSpacing( 1 )
	ModName:setAlignment( Enum[@"hash_67A5123B654282D2"][@"hash_558C8A85F2048829"] )
	ModName:setAlignment( Enum[@"hash_67A5123B654282D2"][@"hash_3F41D595A2B0EDF3"] )
	self:addElement( ModName )
	self.ModName = ModName
	
	self.ModName:linkToElementModel( self, "ModName", true, function ( model )
		local f5_local0 = model:get()
		if f5_local0 ~= nil then
			ModName:setText(f5_local0)

			self.ModName = ModName
		end
	end )

	LUI.OverrideFunction_CallOriginalSecond( self, "close", self.__onClose )
	
	if PostLoadFunc then
		PostLoadFunc( self, f1_arg1, f1_arg0 )
	end
	
	return self
end

CoD.ShieldActiveModRow.__resetProperties = function ( f7_arg0 )
	f7_arg0.BlackBar:completeAnimation()
	f7_arg0.ModName:completeAnimation()
	f7_arg0.BlackBar:setRGB( 0.78, 0.78, 0.78 )
	f7_arg0.BlackBar:setAlpha( 0.01 )
	f7_arg0.ModName:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )
	f7_arg0.ModName:setAlpha( 1 )
end

CoD.ShieldActiveModRow.__clipsPerState = {
	DefaultState = {
		DefaultClip = function ( f8_arg0, f8_arg1 )
			f8_arg0:__resetProperties()
			f8_arg0:setupElementClipCounter( 2 )
			f8_arg0.BlackBar:completeAnimation()
			f8_arg0.BlackBar:setRGB( 0.71, 0.71, 0.71 )
			f8_arg0.BlackBar:setAlpha( 0.01 )
			f8_arg0.clipFinished( f8_arg0.BlackBar )
			f8_arg0.ModName:completeAnimation()
			f8_arg0.ModName:setAlpha( 1 )
			f8_arg0.clipFinished( f8_arg0.ModName )
		end,
		Focus = function ( f9_arg0, f9_arg1 )
			f9_arg0:__resetProperties()
			f9_arg0:setupElementClipCounter( 5 )
			f9_arg0.BlackBar:completeAnimation()
			f9_arg0.BlackBar:setRGB( 0.82, 0.82, 0.82 )
			f9_arg0.BlackBar:setAlpha( 0.05 )
			f9_arg0.clipFinished( f9_arg0.BlackBar )
			f9_arg0.ModName:completeAnimation()
			f9_arg0.ModName:setRGB( 0.93, 0.93, 0 )
			f9_arg0.clipFinished( f9_arg0.ModName )
		end
	}
}

CoD.ShieldActiveModRow.__onClose = function ( f10_arg0 )
	f10_arg0.ModName:close()
	f10_arg0.BlackBar:close()
end

-- Mods Style
CoD.Shield_ModsStyleMain = InheritFrom( LUI.UIElement )
CoD.Shield_ModsStyleMain.__defaultWidth = 360
CoD.Shield_ModsStyleMain.__defaultHeight = 126
CoD.Shield_ModsStyleMain.new = function ( f1_arg0, f1_arg1, f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	local self = LUI.UIElement.new( f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	self:setClass( CoD.Shield_ModsStyleMain )
	self.id = "Shield_ModsStyleMain"
	self.soundSet = "FrontendMain"
	self.onlyChildrenFocusable = true
	self.anyChildUsesUpdateState = true
	f1_arg0:addElementToPendingUpdateStateList( self )
	
	local NoiseTiledBacking = CoD.Shield_ModsStyle.new( f1_arg0, f1_arg1, 0.5, 0.5, -180, 180, 0.5, 0.5, -63, 63 )
	NoiseTiledBacking:mergeStateConditions( {
		{
			stateName = "Locked",
			condition = function ( menu, element, event )
				return CoD.BaseUtility.IsSelfInState( self, "Locked" )
			end
		},
		{
			stateName = "Classified",
			condition = function ( menu, element, event )
				return CoD.BaseUtility.IsSelfInState( self, "Classified" )
			end
		},
		{
			stateName = "ClassifiedShowProgress",
			condition = function ( menu, element, event )
				return CoD.BaseUtility.IsSelfInState( self, "ClassifiedShowProgress" )
			end
		}
	} )
	NoiseTiledBacking:linkToElementModel( self, nil, false, function ( model )
		NoiseTiledBacking:setModel( model, f1_arg1 )
	end )
	NoiseTiledBacking:linkToElementModel( self, "title", true, function ( model )
		local f6_local0 = model:get()
		if f6_local0 ~= nil then
			NoiseTiledBacking.Label:setText( f6_local0 )
		end
	end )

	-- get the site for click datasource
	NoiseTiledBacking:linkToElementModel( self, "link", true, function ( model )
		local f6_local0 = model:get()
		if f6_local0 ~= nil then
			self.site = f6_local0
		end
	end )

	self:addElement( NoiseTiledBacking )
	self.NoiseTiledBacking = NoiseTiledBacking
	
	self:mergeStateConditions( {
		{
			stateName = "Locked",
			condition = function ( menu, element, event )
				return CoD.ModelUtility.IsSelfModelValueTrue( element, f1_arg1, "isLocked" )
			end
		},
		{
			stateName = "Classified",
			condition = function ( menu, element, event )
				return AlwaysFalse()
			end
		},
		{
			stateName = "ClassifiedShowProgress",
			condition = function ( menu, element, event )
				return AlwaysFalse()
			end
		}
	} )
	self:linkToElementModel( self, "isLocked", true, function ( model )
		f1_arg0:updateElementState( self, {
			name = "model_validation",
			menu = f1_arg0,
			controller = f1_arg1,
			modelValue = model:get(),
			modelName = "isLocked"
		} )
	end )
	LUI.OverrideFunction_CallOriginalFirst( self, "setState", function ( element, controller, f11_arg2, f11_arg3, f11_arg4 )
		UpdateElementState( self, "NoiseTiledBacking", controller )
	end )
	NoiseTiledBacking.id = "NoiseTiledBacking"
	self.__defaultFocus = NoiseTiledBacking
	LUI.OverrideFunction_CallOriginalSecond( self, "close", self.__onClose )
	
	if PostLoadFunc then
		PostLoadFunc( self, f1_arg1, f1_arg0 )
	end
	
	return self
end

CoD.Shield_ModsStyleMain.__resetProperties = function ( f12_arg0 )
	f12_arg0.NoiseTiledBacking:completeAnimation()
	f12_arg0.NoiseTiledBacking:setScale( 1, 1 )
end

CoD.Shield_ModsStyleMain.__clipsPerState = {
	DefaultState = {
		DefaultClip = function ( f13_arg0, f13_arg1 )
			f13_arg0:__resetProperties()
			f13_arg0:setupElementClipCounter( 0 )
		end,
		ChildFocus = function ( f14_arg0, f14_arg1 )
			f14_arg0:__resetProperties()
			f14_arg0:setupElementClipCounter( 1 )
			f14_arg0.NoiseTiledBacking:completeAnimation()
			f14_arg0.NoiseTiledBacking:setScale( 1.05, 1.05 )
			f14_arg0.clipFinished( f14_arg0.NoiseTiledBacking )
		end,
		GainChildFocus = function ( f15_arg0, f15_arg1 )
			f15_arg0:__resetProperties()
			f15_arg0:setupElementClipCounter( 1 )
			local f15_local0 = function ( f16_arg0 )
				f15_arg0.NoiseTiledBacking:beginAnimation( 200 )
				f15_arg0.NoiseTiledBacking:setScale( 1.05, 1.05 )
				f15_arg0.NoiseTiledBacking:registerEventHandler( "interrupted_keyframe", f15_arg0.clipInterrupted )
				f15_arg0.NoiseTiledBacking:registerEventHandler( "transition_complete_keyframe", f15_arg0.clipFinished )
			end
			
			f15_arg0.NoiseTiledBacking:completeAnimation()
			f15_arg0.NoiseTiledBacking:setScale( 1, 1 )
			f15_local0( f15_arg0.NoiseTiledBacking )
		end,
		LoseChildFocus = function ( f17_arg0, f17_arg1 )
			f17_arg0:__resetProperties()
			f17_arg0:setupElementClipCounter( 1 )
			local f17_local0 = function ( f18_arg0 )
				f17_arg0.NoiseTiledBacking:beginAnimation( 200 )
				f17_arg0.NoiseTiledBacking:setScale( 1, 1 )
				f17_arg0.NoiseTiledBacking:registerEventHandler( "interrupted_keyframe", f17_arg0.clipInterrupted )
				f17_arg0.NoiseTiledBacking:registerEventHandler( "transition_complete_keyframe", f17_arg0.clipFinished )
			end
			
			f17_arg0.NoiseTiledBacking:completeAnimation()
			f17_arg0.NoiseTiledBacking:setScale( 1.05, 1.05 )
			f17_local0( f17_arg0.NoiseTiledBacking )
		end
	},
	Locked = {
		DefaultClip = function ( f19_arg0, f19_arg1 )
			f19_arg0:__resetProperties()
			f19_arg0:setupElementClipCounter( 0 )
		end
	},
	Classified = {
		DefaultClip = function ( f20_arg0, f20_arg1 )
			f20_arg0:__resetProperties()
			f20_arg0:setupElementClipCounter( 0 )
		end
	},
	ClassifiedShowProgress = {
		DefaultClip = function ( f21_arg0, f21_arg1 )
			f21_arg0:__resetProperties()
			f21_arg0:setupElementClipCounter( 0 )
		end
	}
}

CoD.Shield_ModsStyleMain.__onClose = function ( f22_arg0 )
	f22_arg0.NoiseTiledBacking:close()
end

-- Mods Style Internal
CoD.Shield_ModsStyle = InheritFrom( LUI.UIElement )
CoD.Shield_ModsStyle.__defaultWidth = 360
CoD.Shield_ModsStyle.__defaultHeight = 126
CoD.Shield_ModsStyle.new = function ( f1_arg0, f1_arg1, f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	local self = LUI.UIElement.new( f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	self:setClass( CoD.Shield_ModsStyle )
	self.id = "Shield_ModsStyle"
	self.soundSet = "FrontendMain"
	self.anyChildUsesUpdateState = true
	f1_arg0:addElementToPendingUpdateStateList( self )
	
	local NoiseTiledBacking = LUI.UIImage.new( 0, 1, 0, 0, 0, 1, 0, 0 )
	NoiseTiledBacking:setAlpha( 0.8 )
	NoiseTiledBacking:setImage( RegisterImage( @"uie_ui_menu_specialist_hub_repeat_bg" ) )
	NoiseTiledBacking:setMaterial( LUI.UIImage.GetCachedMaterial( @"hash_16CBE95C250C6D15" ) )
	NoiseTiledBacking:setShaderVector( 0, 0, 0, 0, 0 )
	NoiseTiledBacking:setupNineSliceShader( 196, 88 )
	self:addElement( NoiseTiledBacking )
	self.NoiseTiledBacking = NoiseTiledBacking
	
	local FocusGlow = LUI.UIImage.new( -0.09, 1.1, -110, 110, 0.5, 0.5, -99, 99 )
	FocusGlow:setAlpha( 0 )
	FocusGlow:setImage( RegisterImage( @"uie_ui_menu_common_focus_glow_large" ) )
	FocusGlow:setMaterial( LUI.UIImage.GetCachedMaterial( @"hash_6DAB59B2CAE01851" ) )
	FocusGlow:setShaderVector( 0, 0, 0, 0.25, 0.25 )
	FocusGlow:setShaderVector( 1, 1.2, 0, 0, 0 )
	FocusGlow:setupNineSliceShader( 300, 300 )
	self:addElement( FocusGlow )
	self.FocusGlow = FocusGlow
	
	local FrameBorder = LUI.UIImage.new( 0, 1, -1, 1, 0, 1, -1, 1 )
	FrameBorder:setAlpha( 0.15 )
	FrameBorder:setImage( RegisterImage( @"uie_ui_menu_store_common_frame" ) )
	FrameBorder:setMaterial( LUI.UIImage.GetCachedMaterial( @"uie_nineslice_add" ) )
	FrameBorder:setShaderVector( 0, 0, 0, 0, 0 )
	FrameBorder:setupNineSliceShader( 12, 12 )
	self:addElement( FrameBorder )
	self.FrameBorder = FrameBorder
	
	local FocusBorder = LUI.UIImage.new( 0, 1, -4, 4, 0, 1, -4, 4 )
	FocusBorder:setRGB( 0.96, 0.94, 0.78 )
	FocusBorder:setAlpha( 0 )
	FocusBorder:setImage( RegisterImage( @"uie_ui_menu_store_focus_frame" ) )
	FocusBorder:setMaterial( LUI.UIImage.GetCachedMaterial( @"uie_nineslice_add" ) )
	FocusBorder:setShaderVector( 0, 0, 0, 0, 0 )
	FocusBorder:setupNineSliceShader( 10, 10 )
	self:addElement( FocusBorder )
	self.FocusBorder = FocusBorder
	
	local SelectorOverlay = LUI.UIImage.new( 0, 1, 0, 0, 0, 1, 0, 0 )
	SelectorOverlay:setAlpha( 0.01 )
	self:addElement( SelectorOverlay )
	self.SelectorOverlay = SelectorOverlay
	
	local FocusBrackets = CoD.CommonFocusBrackets.new( f1_arg0, f1_arg1, 0, 1, -10, 10, 0, 1, -10, 10 )
	self:addElement( FocusBrackets )
	self.FocusBrackets = FocusBrackets
	
	local CardIcon = LUI.UIImage.new( 0, 1, 1, -1, 0, 0.71, 2, -2 )
	CardIcon:linkToElementModel( self, "icon", true, function ( model )
		local f2_local0 = model:get()
		if f2_local0 ~= nil then
			CardIcon:setImage( RegisterImage( f2_local0 ) )
		end
	end )
	self:addElement( CardIcon )
	self.CardIcon = CardIcon
	
	local CardIconLockOverlay = LUI.UIImage.new( 0, 1, 1, -1, 0, 0.71, 2, -2 )
	CardIconLockOverlay:setRGB( 0, 0, 0 )
	CardIconLockOverlay:setAlpha( 0 )
	self:addElement( CardIconLockOverlay )
	self.CardIconLockOverlay = CardIconLockOverlay
	
	local DarkOpsClassifiedIcon = LUI.UIImage.new( 0, 1, 1, -1, -0, 0.71, 2, -2 )
	DarkOpsClassifiedIcon:setAlpha( 0 )
	DarkOpsClassifiedIcon:setImage( RegisterImage( @"uie_t7_icons_challenges_classified_placeholder" ) )
	self:addElement( DarkOpsClassifiedIcon )
	self.DarkOpsClassifiedIcon = DarkOpsClassifiedIcon
	
	local Lines = CoD.DirectorSelectButtonLines.new( f1_arg0, f1_arg1, 0, 1, 0, 0, 0, 1, 1, -1 )
	Lines:setRGB( 0.64, 0.71, 0.78 )
	self:addElement( Lines )
	self.Lines = Lines
	
	local Label = LUI.UIText.new( 0.5, 0.5, -175, 175, 0, 0, 93, 113 )
	Label:setAlpha( 0.85 )
	Label:setTTF( "ttmussels_regular" )
	Label:setLetterSpacing( 2 )
	Label:setAlignment( Enum[@"luialignment"][@"lui_alignment_center"] )
	Label:setAlignment( Enum[@"luialignment"][@"hash_E821F0ECFF8D1C7"] )
	Label:linkToElementModel( self, "title", true, function ( model )
		local f3_local0 = model:get()
		if f3_local0 ~= nil then
			Label:setText( f3_local0 )
		end
	end )
	self:addElement( Label )
	self.Label = Label
	
	local lockedIcon = CoD.cac_lock.new( f1_arg0, f1_arg1, 0.5, 0.5, -18, 18, 0, 0, 27, 63 )
	self:addElement( lockedIcon )
	self.lockedIcon = lockedIcon
	
	local TrialWidget = CoD.TrialWidget.new( f1_arg0, f1_arg1, 0, 0, 5, 30, 0, 0, 5, 30 )
	TrialWidget:setAlpha( 0 )
	self:addElement( TrialWidget )
	self.TrialWidget = TrialWidget
	
	local ProgressBarBacking = LUI.UIImage.new( 0, 0, 5, 355, 0, 0, 115, 121 )
	ProgressBarBacking:setRGB( ColorSet.T8__OFF__GRAY.r, ColorSet.T8__OFF__GRAY.g, ColorSet.T8__OFF__GRAY.b )
	ProgressBarBacking:setAlpha( 0 )
	self:addElement( ProgressBarBacking )
	self.ProgressBarBacking = ProgressBarBacking
	
	local ProgressBorder = CoD.StartMenuOptionsMainFrame.new( f1_arg0, f1_arg1, 0.5, 0.5, -175, 175, 0, 0, 115, 121 )
	ProgressBorder:setAlpha( 0 )
	self:addElement( ProgressBorder )
	self.ProgressBorder = ProgressBorder
	
	local ProgressBar = LUI.UIImage.new( 0, 0, 5, 355, 0, 0, 115, 121 )
	ProgressBar:setRGB( 1, 0.35, 0 )
	ProgressBar:setAlpha( 0 )
	ProgressBar:setMaterial( LUI.UIImage.GetCachedMaterial( @"uie_wipe" ) )
	ProgressBar:setShaderVector( 1, 0, 0, 0, 0 )
	ProgressBar:setShaderVector( 2, 1, 0, 0, 0 )
	ProgressBar:setShaderVector( 3, 0, 0, 0, 0 )
	ProgressBar:setShaderVector( 4, 0, 0, 0, 0 )
	ProgressBar:linkToElementModel( self, "statPercent", true, function ( model )
		local f4_local0 = model:get()
		if f4_local0 ~= nil then
			ProgressBar:setShaderVector( 0, CoD.GetVectorComponentFromString( f4_local0, 1 ), CoD.GetVectorComponentFromString( f4_local0, 2 ), CoD.GetVectorComponentFromString( f4_local0, 3 ), CoD.GetVectorComponentFromString( f4_local0, 4 ) )
		end
	end )
	self:addElement( ProgressBar )
	self.ProgressBar = ProgressBar
	
	self:mergeStateConditions( {
		{
			stateName = "Locked",
			condition = function ( menu, element, event )
				return CoD.ModelUtility.IsSelfModelValueTrue( element, f1_arg1, "isLocked" )
			end
		},
		{
			stateName = "Classified",
			condition = function ( menu, element, event )
				return AlwaysFalse()
			end
		},
		{
			stateName = "ClassifiedShowProgress",
			condition = function ( menu, element, event )
				return AlwaysFalse()
			end
		}
	} )
	self:linkToElementModel( self, "isLocked", true, function ( model )
		f1_arg0:updateElementState( self, {
			name = "model_validation",
			menu = f1_arg0,
			controller = f1_arg1,
			modelValue = model:get(),
			modelName = "isLocked"
		} )
	end )
	LUI.OverrideFunction_CallOriginalSecond( self, "close", self.__onClose )
	
	if PostLoadFunc then
		PostLoadFunc( self, f1_arg1, f1_arg0 )
	end
	
	return self
end

CoD.Shield_ModsStyle.__resetProperties = function ( f9_arg0 )
	f9_arg0.lockedIcon:completeAnimation()
	f9_arg0.ProgressBar:completeAnimation()
	f9_arg0.FocusBrackets:completeAnimation()
	f9_arg0.ProgressBorder:completeAnimation()
	f9_arg0.TrialWidget:completeAnimation()
	f9_arg0.SelectorOverlay:completeAnimation()
	f9_arg0.FocusBorder:completeAnimation()
	f9_arg0.Lines:completeAnimation()
	f9_arg0.FocusGlow:completeAnimation()
	f9_arg0.Label:completeAnimation()
	f9_arg0.CardIcon:completeAnimation()
	f9_arg0.ProgressBarBacking:completeAnimation()
	f9_arg0.CardIconLockOverlay:completeAnimation()
	f9_arg0.DarkOpsClassifiedIcon:completeAnimation()
	f9_arg0.lockedIcon:setAlpha( 1 )
	f9_arg0.ProgressBar:setAlpha( 0 )
	f9_arg0.FocusBrackets:setLeftRight( 0, 1, -10, 10 )
	f9_arg0.FocusBrackets:setTopBottom( 0, 1, -10, 10 )
	f9_arg0.FocusBrackets:setAlpha( 1 )
	f9_arg0.FocusBrackets:setScale( 1, 1 )
	f9_arg0.ProgressBorder:setAlpha( 0 )
	f9_arg0.TrialWidget:setAlpha( 0 )
	f9_arg0.SelectorOverlay:setAlpha( 0.01 )
	f9_arg0.FocusBorder:setRGB( 0.96, 0.94, 0.78 )
	f9_arg0.FocusBorder:setAlpha( 0 )
	f9_arg0.Lines:setAlpha( 1 )
	f9_arg0.FocusGlow:setAlpha( 0 )
	f9_arg0.Label:setRGB( 1, 1, 1 )
	f9_arg0.CardIcon:setAlpha( 1 )
	f9_arg0.ProgressBarBacking:setAlpha( 0 )
	f9_arg0.CardIconLockOverlay:setAlpha( 0 )
	f9_arg0.DarkOpsClassifiedIcon:setAlpha( 0 )
end

CoD.Shield_ModsStyle.__clipsPerState = {
	DefaultState = {
		DefaultClip = function ( f10_arg0, f10_arg1 )
			f10_arg0:__resetProperties()
			f10_arg0:setupElementClipCounter( 5 )
			f10_arg0.FocusBrackets:completeAnimation()
			f10_arg0.FocusBrackets:setAlpha( 0 )
			f10_arg0.clipFinished( f10_arg0.FocusBrackets )
			f10_arg0.lockedIcon:completeAnimation()
			f10_arg0.lockedIcon:setAlpha( 0 )
			f10_arg0.clipFinished( f10_arg0.lockedIcon )
			f10_arg0.TrialWidget:completeAnimation()
			f10_arg0.TrialWidget:setAlpha( 1 )
			f10_arg0.clipFinished( f10_arg0.TrialWidget )
			f10_arg0.ProgressBorder:completeAnimation()
			f10_arg0.ProgressBorder:setAlpha( 0 )
			f10_arg0.clipFinished( f10_arg0.ProgressBorder )
			f10_arg0.ProgressBar:completeAnimation()
			f10_arg0.ProgressBar:setAlpha( 0 )
			f10_arg0.clipFinished( f10_arg0.ProgressBar )
		end,
		Focus = function ( f11_arg0, f11_arg1 )
			f11_arg0:__resetProperties()
			f11_arg0:setupElementClipCounter( 8 )
			f11_arg0.FocusGlow:completeAnimation()
			f11_arg0.FocusGlow:setAlpha( 0.6 )
			f11_arg0.clipFinished( f11_arg0.FocusGlow )
			f11_arg0.FocusBorder:completeAnimation()
			f11_arg0.FocusBorder:setAlpha( 1 )
			f11_arg0.clipFinished( f11_arg0.FocusBorder )
			f11_arg0.SelectorOverlay:completeAnimation()
			f11_arg0.SelectorOverlay:setAlpha( 0.04 )
			f11_arg0.clipFinished( f11_arg0.SelectorOverlay )
			f11_arg0.Lines:completeAnimation()
			f11_arg0.Lines:setAlpha( 0 )
			f11_arg0.clipFinished( f11_arg0.Lines )
			f11_arg0.Label:completeAnimation()
			f11_arg0.Label:setRGB( 0.96, 0.94, 0.78 )
			f11_arg0.clipFinished( f11_arg0.Label )
			f11_arg0.lockedIcon:completeAnimation()
			f11_arg0.lockedIcon:setAlpha( 0 )
			f11_arg0.clipFinished( f11_arg0.lockedIcon )
			f11_arg0.TrialWidget:completeAnimation()
			f11_arg0.TrialWidget:setAlpha( 1 )
			f11_arg0.clipFinished( f11_arg0.TrialWidget )
			f11_arg0.ProgressBar:completeAnimation()
			f11_arg0.ProgressBar:setAlpha( 0 )
			f11_arg0.clipFinished( f11_arg0.ProgressBar )
		end,
		GainFocus = function ( f12_arg0, f12_arg1 )
			f12_arg0:__resetProperties()
			f12_arg0:setupElementClipCounter( 10 )
			local f12_local0 = function ( f13_arg0 )
				f12_arg0.FocusGlow:beginAnimation( 200 )
				f12_arg0.FocusGlow:setAlpha( 0.6 )
				f12_arg0.FocusGlow:registerEventHandler( "interrupted_keyframe", f12_arg0.clipInterrupted )
				f12_arg0.FocusGlow:registerEventHandler( "transition_complete_keyframe", f12_arg0.clipFinished )
			end
			
			f12_arg0.FocusGlow:completeAnimation()
			f12_arg0.FocusGlow:setAlpha( 0 )
			f12_local0( f12_arg0.FocusGlow )
			local f12_local1 = function ( f14_arg0 )
				f12_arg0.FocusBorder:beginAnimation( 200 )
				f12_arg0.FocusBorder:setAlpha( 1 )
				f12_arg0.FocusBorder:registerEventHandler( "interrupted_keyframe", f12_arg0.clipInterrupted )
				f12_arg0.FocusBorder:registerEventHandler( "transition_complete_keyframe", f12_arg0.clipFinished )
			end
			
			f12_arg0.FocusBorder:completeAnimation()
			f12_arg0.FocusBorder:setAlpha( 0 )
			f12_local1( f12_arg0.FocusBorder )
			local f12_local2 = function ( f15_arg0 )
				f12_arg0.SelectorOverlay:beginAnimation( 200 )
				f12_arg0.SelectorOverlay:setAlpha( 0.04 )
				f12_arg0.SelectorOverlay:registerEventHandler( "interrupted_keyframe", f12_arg0.clipInterrupted )
				f12_arg0.SelectorOverlay:registerEventHandler( "transition_complete_keyframe", f12_arg0.clipFinished )
			end
			
			f12_arg0.SelectorOverlay:completeAnimation()
			f12_arg0.SelectorOverlay:setAlpha( 0.01 )
			f12_local2( f12_arg0.SelectorOverlay )
			local f12_local3 = function ( f16_arg0 )
				local f16_local0 = function ( f17_arg0 )
					f17_arg0:beginAnimation( 50 )
					f17_arg0:setLeftRight( 0, 1, -10, 10 )
					f17_arg0:setTopBottom( 0, 1, -10, 10 )
					f17_arg0:setAlpha( 1 )
					f17_arg0:registerEventHandler( "transition_complete_keyframe", f12_arg0.clipFinished )
				end
				
				f12_arg0.FocusBrackets:beginAnimation( 100 )
				f12_arg0.FocusBrackets:setLeftRight( 0, 1, -8, 8 )
				f12_arg0.FocusBrackets:setTopBottom( 0, 1, -8, 8 )
				f12_arg0.FocusBrackets:setAlpha( 0.67 )
				f12_arg0.FocusBrackets:registerEventHandler( "interrupted_keyframe", f12_arg0.clipInterrupted )
				f12_arg0.FocusBrackets:registerEventHandler( "transition_complete_keyframe", f16_local0 )
			end
			
			f12_arg0.FocusBrackets:completeAnimation()
			f12_arg0.FocusBrackets:setLeftRight( 0, 1, -40, 40 )
			f12_arg0.FocusBrackets:setTopBottom( 0, 1, -40, 40 )
			f12_arg0.FocusBrackets:setAlpha( 0 )
			f12_local3( f12_arg0.FocusBrackets )
			local f12_local4 = function ( f18_arg0 )
				f12_arg0.Lines:beginAnimation( 200 )
				f12_arg0.Lines:setAlpha( 0 )
				f12_arg0.Lines:registerEventHandler( "interrupted_keyframe", f12_arg0.clipInterrupted )
				f12_arg0.Lines:registerEventHandler( "transition_complete_keyframe", f12_arg0.clipFinished )
			end
			
			f12_arg0.Lines:completeAnimation()
			f12_arg0.Lines:setAlpha( 1 )
			f12_local4( f12_arg0.Lines )
			f12_arg0.Label:completeAnimation()
			f12_arg0.Label:setRGB( 0.96, 0.94, 0.78 )
			f12_arg0.clipFinished( f12_arg0.Label )
			f12_arg0.lockedIcon:completeAnimation()
			f12_arg0.lockedIcon:setAlpha( 0 )
			f12_arg0.clipFinished( f12_arg0.lockedIcon )
			f12_arg0.TrialWidget:completeAnimation()
			f12_arg0.TrialWidget:setAlpha( 1 )
			f12_arg0.clipFinished( f12_arg0.TrialWidget )
			f12_arg0.ProgressBorder:completeAnimation()
			f12_arg0.ProgressBorder:setAlpha( 0 )
			f12_arg0.clipFinished( f12_arg0.ProgressBorder )
			f12_arg0.ProgressBar:completeAnimation()
			f12_arg0.ProgressBar:setAlpha( 0 )
			f12_arg0.clipFinished( f12_arg0.ProgressBar )
		end,
		LoseFocus = function ( f19_arg0, f19_arg1 )
			f19_arg0:__resetProperties()
			f19_arg0:setupElementClipCounter( 9 )
			local f19_local0 = function ( f20_arg0 )
				f19_arg0.FocusGlow:beginAnimation( 200 )
				f19_arg0.FocusGlow:setAlpha( 0 )
				f19_arg0.FocusGlow:registerEventHandler( "interrupted_keyframe", f19_arg0.clipInterrupted )
				f19_arg0.FocusGlow:registerEventHandler( "transition_complete_keyframe", f19_arg0.clipFinished )
			end
			
			f19_arg0.FocusGlow:completeAnimation()
			f19_arg0.FocusGlow:setAlpha( 0.6 )
			f19_local0( f19_arg0.FocusGlow )
			local f19_local1 = function ( f21_arg0 )
				f19_arg0.FocusBorder:beginAnimation( 200 )
				f19_arg0.FocusBorder:setAlpha( 0 )
				f19_arg0.FocusBorder:registerEventHandler( "interrupted_keyframe", f19_arg0.clipInterrupted )
				f19_arg0.FocusBorder:registerEventHandler( "transition_complete_keyframe", f19_arg0.clipFinished )
			end
			
			f19_arg0.FocusBorder:completeAnimation()
			f19_arg0.FocusBorder:setAlpha( 1 )
			f19_local1( f19_arg0.FocusBorder )
			local f19_local2 = function ( f22_arg0 )
				f19_arg0.SelectorOverlay:beginAnimation( 200 )
				f19_arg0.SelectorOverlay:setAlpha( 0.01 )
				f19_arg0.SelectorOverlay:registerEventHandler( "interrupted_keyframe", f19_arg0.clipInterrupted )
				f19_arg0.SelectorOverlay:registerEventHandler( "transition_complete_keyframe", f19_arg0.clipFinished )
			end
			
			f19_arg0.SelectorOverlay:completeAnimation()
			f19_arg0.SelectorOverlay:setAlpha( 0.04 )
			f19_local2( f19_arg0.SelectorOverlay )
			local f19_local3 = function ( f23_arg0 )
				f19_arg0.FocusBrackets:beginAnimation( 60 )
				f19_arg0.FocusBrackets:setAlpha( 0 )
				f19_arg0.FocusBrackets:registerEventHandler( "interrupted_keyframe", f19_arg0.clipInterrupted )
				f19_arg0.FocusBrackets:registerEventHandler( "transition_complete_keyframe", f19_arg0.clipFinished )
			end
			
			f19_arg0.FocusBrackets:completeAnimation()
			f19_arg0.FocusBrackets:setAlpha( 1 )
			f19_local3( f19_arg0.FocusBrackets )
			local f19_local4 = function ( f24_arg0 )
				f19_arg0.Lines:beginAnimation( 200 )
				f19_arg0.Lines:setAlpha( 1 )
				f19_arg0.Lines:registerEventHandler( "interrupted_keyframe", f19_arg0.clipInterrupted )
				f19_arg0.Lines:registerEventHandler( "transition_complete_keyframe", f19_arg0.clipFinished )
			end
			
			f19_arg0.Lines:completeAnimation()
			f19_arg0.Lines:setAlpha( 0 )
			f19_local4( f19_arg0.Lines )
			f19_arg0.lockedIcon:completeAnimation()
			f19_arg0.lockedIcon:setAlpha( 0 )
			f19_arg0.clipFinished( f19_arg0.lockedIcon )
			f19_arg0.TrialWidget:completeAnimation()
			f19_arg0.TrialWidget:setAlpha( 1 )
			f19_arg0.clipFinished( f19_arg0.TrialWidget )
			f19_arg0.ProgressBorder:completeAnimation()
			f19_arg0.ProgressBorder:setAlpha( 0 )
			f19_arg0.clipFinished( f19_arg0.ProgressBorder )
			f19_arg0.ProgressBar:completeAnimation()
			f19_arg0.ProgressBar:setAlpha( 0 )
			f19_arg0.clipFinished( f19_arg0.ProgressBar )
		end
	},
	Locked = {
		DefaultClip = function ( f25_arg0, f25_arg1 )
			f25_arg0:__resetProperties()
			f25_arg0:setupElementClipCounter( 7 )
			f25_arg0.FocusBrackets:completeAnimation()
			f25_arg0.FocusBrackets:setAlpha( 0 )
			f25_arg0.clipFinished( f25_arg0.FocusBrackets )
			f25_arg0.CardIcon:completeAnimation()
			f25_arg0.CardIcon:setAlpha( 1 )
			f25_arg0.clipFinished( f25_arg0.CardIcon )
			f25_arg0.CardIconLockOverlay:completeAnimation()
			f25_arg0.CardIconLockOverlay:setAlpha( 0.98 )
			f25_arg0.clipFinished( f25_arg0.CardIconLockOverlay )
			f25_arg0.Lines:completeAnimation()
			f25_arg0.Lines:setAlpha( 0.5 )
			f25_arg0.clipFinished( f25_arg0.Lines )
			f25_arg0.ProgressBarBacking:completeAnimation()
			f25_arg0.ProgressBarBacking:setAlpha( 0.02 )
			f25_arg0.clipFinished( f25_arg0.ProgressBarBacking )
			f25_arg0.ProgressBorder:completeAnimation()
			f25_arg0.ProgressBorder:setAlpha( 0.02 )
			f25_arg0.clipFinished( f25_arg0.ProgressBorder )
			f25_arg0.ProgressBar:completeAnimation()
			f25_arg0.ProgressBar:setAlpha( 1 )
			f25_arg0.clipFinished( f25_arg0.ProgressBar )
		end,
		Focus = function ( f26_arg0, f26_arg1 )
			f26_arg0:__resetProperties()
			f26_arg0:setupElementClipCounter( 11 )
			f26_arg0.FocusGlow:completeAnimation()
			f26_arg0.FocusGlow:setAlpha( 0 )
			f26_arg0.clipFinished( f26_arg0.FocusGlow )
			f26_arg0.FocusBorder:completeAnimation()
			f26_arg0.FocusBorder:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )
			f26_arg0.FocusBorder:setAlpha( 0.25 )
			f26_arg0.clipFinished( f26_arg0.FocusBorder )
			f26_arg0.SelectorOverlay:completeAnimation()
			f26_arg0.SelectorOverlay:setAlpha( 0.04 )
			f26_arg0.clipFinished( f26_arg0.SelectorOverlay )
			f26_arg0.FocusBrackets:completeAnimation()
			f26_arg0.FocusBrackets:setAlpha( 1 )
			f26_arg0.FocusBrackets:setScale( 1, 1 )
			f26_arg0.clipFinished( f26_arg0.FocusBrackets )
			f26_arg0.CardIconLockOverlay:completeAnimation()
			f26_arg0.CardIconLockOverlay:setAlpha( 0.98 )
			f26_arg0.clipFinished( f26_arg0.CardIconLockOverlay )
			f26_arg0.Lines:completeAnimation()
			f26_arg0.Lines:setAlpha( 0 )
			f26_arg0.clipFinished( f26_arg0.Lines )
			f26_arg0.Label:completeAnimation()
			f26_arg0.Label:setRGB( 0.96, 0.94, 0.78 )
			f26_arg0.clipFinished( f26_arg0.Label )
			f26_arg0.lockedIcon:completeAnimation()
			f26_arg0.lockedIcon:setAlpha( 0.8 )
			f26_arg0.clipFinished( f26_arg0.lockedIcon )
			f26_arg0.ProgressBarBacking:completeAnimation()
			f26_arg0.ProgressBarBacking:setAlpha( 0.02 )
			f26_arg0.clipFinished( f26_arg0.ProgressBarBacking )
			f26_arg0.ProgressBorder:completeAnimation()
			f26_arg0.ProgressBorder:setAlpha( 0.05 )
			f26_arg0.clipFinished( f26_arg0.ProgressBorder )
			f26_arg0.ProgressBar:completeAnimation()
			f26_arg0.ProgressBar:setAlpha( 1 )
			f26_arg0.clipFinished( f26_arg0.ProgressBar )
		end,
		GainFocus = function ( f27_arg0, f27_arg1 )
			f27_arg0:__resetProperties()
			f27_arg0:setupElementClipCounter( 10 )
			local f27_local0 = function ( f28_arg0 )
				f27_arg0.FocusBorder:beginAnimation( 200 )
				f27_arg0.FocusBorder:setAlpha( 0.25 )
				f27_arg0.FocusBorder:registerEventHandler( "interrupted_keyframe", f27_arg0.clipInterrupted )
				f27_arg0.FocusBorder:registerEventHandler( "transition_complete_keyframe", f27_arg0.clipFinished )
			end
			
			f27_arg0.FocusBorder:completeAnimation()
			f27_arg0.FocusBorder:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )
			f27_arg0.FocusBorder:setAlpha( 0 )
			f27_local0( f27_arg0.FocusBorder )
			local f27_local1 = function ( f29_arg0 )
				f27_arg0.SelectorOverlay:beginAnimation( 200 )
				f27_arg0.SelectorOverlay:setAlpha( 0.04 )
				f27_arg0.SelectorOverlay:registerEventHandler( "interrupted_keyframe", f27_arg0.clipInterrupted )
				f27_arg0.SelectorOverlay:registerEventHandler( "transition_complete_keyframe", f27_arg0.clipFinished )
			end
			
			f27_arg0.SelectorOverlay:completeAnimation()
			f27_arg0.SelectorOverlay:setAlpha( 0.01 )
			f27_local1( f27_arg0.SelectorOverlay )
			local f27_local2 = function ( f30_arg0 )
				local f30_local0 = function ( f31_arg0 )
					f31_arg0:beginAnimation( 50 )
					f31_arg0:setLeftRight( 0, 1, -10, 10 )
					f31_arg0:setTopBottom( 0, 1, -10, 10 )
					f31_arg0:setAlpha( 1 )
					f31_arg0:registerEventHandler( "transition_complete_keyframe", f27_arg0.clipFinished )
				end
				
				f27_arg0.FocusBrackets:beginAnimation( 100 )
				f27_arg0.FocusBrackets:setLeftRight( 0, 1, -8, 8 )
				f27_arg0.FocusBrackets:setTopBottom( 0, 1, -8, 8 )
				f27_arg0.FocusBrackets:setAlpha( 0.67 )
				f27_arg0.FocusBrackets:registerEventHandler( "interrupted_keyframe", f27_arg0.clipInterrupted )
				f27_arg0.FocusBrackets:registerEventHandler( "transition_complete_keyframe", f30_local0 )
			end
			
			f27_arg0.FocusBrackets:completeAnimation()
			f27_arg0.FocusBrackets:setLeftRight( 0, 1, -40, 40 )
			f27_arg0.FocusBrackets:setTopBottom( 0, 1, -40, 40 )
			f27_arg0.FocusBrackets:setAlpha( 0 )
			f27_local2( f27_arg0.FocusBrackets )
			f27_arg0.CardIconLockOverlay:completeAnimation()
			f27_arg0.CardIconLockOverlay:setAlpha( 0.98 )
			f27_arg0.clipFinished( f27_arg0.CardIconLockOverlay )
			f27_arg0.Lines:completeAnimation()
			f27_arg0.Lines:setAlpha( 0.5 )
			f27_arg0.clipFinished( f27_arg0.Lines )
			f27_arg0.Label:completeAnimation()
			f27_arg0.Label:setRGB( 0.96, 0.94, 0.78 )
			f27_arg0.clipFinished( f27_arg0.Label )
			local f27_local3 = function ( f32_arg0 )
				f27_arg0.lockedIcon:beginAnimation( 200 )
				f27_arg0.lockedIcon:setAlpha( 0.8 )
				f27_arg0.lockedIcon:registerEventHandler( "interrupted_keyframe", f27_arg0.clipInterrupted )
				f27_arg0.lockedIcon:registerEventHandler( "transition_complete_keyframe", f27_arg0.clipFinished )
			end
			
			f27_arg0.lockedIcon:completeAnimation()
			f27_arg0.lockedIcon:setAlpha( 1 )
			f27_local3( f27_arg0.lockedIcon )
			f27_arg0.ProgressBarBacking:completeAnimation()
			f27_arg0.ProgressBarBacking:setAlpha( 0.02 )
			f27_arg0.clipFinished( f27_arg0.ProgressBarBacking )
			f27_arg0.ProgressBorder:completeAnimation()
			f27_arg0.ProgressBorder:setAlpha( 0.05 )
			f27_arg0.clipFinished( f27_arg0.ProgressBorder )
			f27_arg0.ProgressBar:completeAnimation()
			f27_arg0.ProgressBar:setAlpha( 1 )
			f27_arg0.clipFinished( f27_arg0.ProgressBar )
		end,
		LoseFocus = function ( f33_arg0, f33_arg1 )
			f33_arg0:__resetProperties()
			f33_arg0:setupElementClipCounter( 9 )
			local f33_local0 = function ( f34_arg0 )
				f33_arg0.FocusBorder:beginAnimation( 150 )
				f33_arg0.FocusBorder:setAlpha( 0 )
				f33_arg0.FocusBorder:registerEventHandler( "interrupted_keyframe", f33_arg0.clipInterrupted )
				f33_arg0.FocusBorder:registerEventHandler( "transition_complete_keyframe", f33_arg0.clipFinished )
			end
			
			f33_arg0.FocusBorder:completeAnimation()
			f33_arg0.FocusBorder:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )
			f33_arg0.FocusBorder:setAlpha( 0.5 )
			f33_local0( f33_arg0.FocusBorder )
			local f33_local1 = function ( f35_arg0 )
				f33_arg0.SelectorOverlay:beginAnimation( 150 )
				f33_arg0.SelectorOverlay:setAlpha( 0.01 )
				f33_arg0.SelectorOverlay:registerEventHandler( "interrupted_keyframe", f33_arg0.clipInterrupted )
				f33_arg0.SelectorOverlay:registerEventHandler( "transition_complete_keyframe", f33_arg0.clipFinished )
			end
			
			f33_arg0.SelectorOverlay:completeAnimation()
			f33_arg0.SelectorOverlay:setAlpha( 0.04 )
			f33_local1( f33_arg0.SelectorOverlay )
			local f33_local2 = function ( f36_arg0 )
				f33_arg0.FocusBrackets:beginAnimation( 60 )
				f33_arg0.FocusBrackets:setAlpha( 0 )
				f33_arg0.FocusBrackets:registerEventHandler( "interrupted_keyframe", f33_arg0.clipInterrupted )
				f33_arg0.FocusBrackets:registerEventHandler( "transition_complete_keyframe", f33_arg0.clipFinished )
			end
			
			f33_arg0.FocusBrackets:completeAnimation()
			f33_arg0.FocusBrackets:setAlpha( 1 )
			f33_local2( f33_arg0.FocusBrackets )
			f33_arg0.CardIconLockOverlay:completeAnimation()
			f33_arg0.CardIconLockOverlay:setAlpha( 0.98 )
			f33_arg0.clipFinished( f33_arg0.CardIconLockOverlay )
			local f33_local3 = function ( f37_arg0 )
				f33_arg0.Lines:beginAnimation( 150 )
				f33_arg0.Lines:setAlpha( 1 )
				f33_arg0.Lines:registerEventHandler( "interrupted_keyframe", f33_arg0.clipInterrupted )
				f33_arg0.Lines:registerEventHandler( "transition_complete_keyframe", f33_arg0.clipFinished )
			end
			
			f33_arg0.Lines:completeAnimation()
			f33_arg0.Lines:setAlpha( 0 )
			f33_local3( f33_arg0.Lines )
			local f33_local4 = function ( f38_arg0 )
				f33_arg0.lockedIcon:beginAnimation( 150 )
				f33_arg0.lockedIcon:setAlpha( 1 )
				f33_arg0.lockedIcon:registerEventHandler( "interrupted_keyframe", f33_arg0.clipInterrupted )
				f33_arg0.lockedIcon:registerEventHandler( "transition_complete_keyframe", f33_arg0.clipFinished )
			end
			
			f33_arg0.lockedIcon:completeAnimation()
			f33_arg0.lockedIcon:setAlpha( 0.8 )
			f33_local4( f33_arg0.lockedIcon )
			f33_arg0.ProgressBarBacking:completeAnimation()
			f33_arg0.ProgressBarBacking:setAlpha( 0.02 )
			f33_arg0.clipFinished( f33_arg0.ProgressBarBacking )
			f33_arg0.ProgressBorder:completeAnimation()
			f33_arg0.ProgressBorder:setAlpha( 0.05 )
			f33_arg0.clipFinished( f33_arg0.ProgressBorder )
			f33_arg0.ProgressBar:completeAnimation()
			f33_arg0.ProgressBar:setAlpha( 1 )
			f33_arg0.clipFinished( f33_arg0.ProgressBar )
		end
	},
	Classified = {
		DefaultClip = function ( f39_arg0, f39_arg1 )
			f39_arg0:__resetProperties()
			f39_arg0:setupElementClipCounter( 7 )
			f39_arg0.FocusBrackets:completeAnimation()
			f39_arg0.FocusBrackets:setAlpha( 0 )
			f39_arg0.clipFinished( f39_arg0.FocusBrackets )
			f39_arg0.CardIcon:completeAnimation()
			f39_arg0.CardIcon:setAlpha( 0 )
			f39_arg0.clipFinished( f39_arg0.CardIcon )
			f39_arg0.DarkOpsClassifiedIcon:completeAnimation()
			f39_arg0.DarkOpsClassifiedIcon:setAlpha( 1 )
			f39_arg0.clipFinished( f39_arg0.DarkOpsClassifiedIcon )
			f39_arg0.lockedIcon:completeAnimation()
			f39_arg0.lockedIcon:setAlpha( 0 )
			f39_arg0.clipFinished( f39_arg0.lockedIcon )
			f39_arg0.ProgressBarBacking:completeAnimation()
			f39_arg0.ProgressBarBacking:setAlpha( 0.1 )
			f39_arg0.clipFinished( f39_arg0.ProgressBarBacking )
			f39_arg0.ProgressBorder:completeAnimation()
			f39_arg0.ProgressBorder:setAlpha( 0.02 )
			f39_arg0.clipFinished( f39_arg0.ProgressBorder )
			f39_arg0.ProgressBar:completeAnimation()
			f39_arg0.ProgressBar:setAlpha( 0 )
			f39_arg0.clipFinished( f39_arg0.ProgressBar )
		end,
		Focus = function ( f40_arg0, f40_arg1 )
			f40_arg0:__resetProperties()
			f40_arg0:setupElementClipCounter( 7 )
			f40_arg0.FocusGlow:completeAnimation()
			f40_arg0.FocusGlow:setAlpha( 0.6 )
			f40_arg0.clipFinished( f40_arg0.FocusGlow )
			f40_arg0.FocusBorder:completeAnimation()
			f40_arg0.FocusBorder:setRGB( 0.96, 0.94, 0.78 )
			f40_arg0.FocusBorder:setAlpha( 1 )
			f40_arg0.clipFinished( f40_arg0.FocusBorder )
			f40_arg0.SelectorOverlay:completeAnimation()
			f40_arg0.SelectorOverlay:setAlpha( 0.04 )
			f40_arg0.clipFinished( f40_arg0.SelectorOverlay )
			f40_arg0.CardIcon:completeAnimation()
			f40_arg0.CardIcon:setAlpha( 0 )
			f40_arg0.clipFinished( f40_arg0.CardIcon )
			f40_arg0.DarkOpsClassifiedIcon:completeAnimation()
			f40_arg0.DarkOpsClassifiedIcon:setAlpha( 1 )
			f40_arg0.clipFinished( f40_arg0.DarkOpsClassifiedIcon )
			f40_arg0.Label:completeAnimation()
			f40_arg0.Label:setRGB( 0.96, 0.94, 0.78 )
			f40_arg0.clipFinished( f40_arg0.Label )
			f40_arg0.lockedIcon:completeAnimation()
			f40_arg0.lockedIcon:setAlpha( 0 )
			f40_arg0.clipFinished( f40_arg0.lockedIcon )
		end,
		GainFocus = function ( f41_arg0, f41_arg1 )
			f41_arg0:__resetProperties()
			f41_arg0:setupElementClipCounter( 8 )
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
				f41_arg0.FocusBorder:beginAnimation( 200 )
				f41_arg0.FocusBorder:setAlpha( 1 )
				f41_arg0.FocusBorder:registerEventHandler( "interrupted_keyframe", f41_arg0.clipInterrupted )
				f41_arg0.FocusBorder:registerEventHandler( "transition_complete_keyframe", f41_arg0.clipFinished )
			end
			
			f41_arg0.FocusBorder:completeAnimation()
			f41_arg0.FocusBorder:setAlpha( 0 )
			f41_local1( f41_arg0.FocusBorder )
			local f41_local2 = function ( f44_arg0 )
				f41_arg0.SelectorOverlay:beginAnimation( 200 )
				f41_arg0.SelectorOverlay:setAlpha( 0.04 )
				f41_arg0.SelectorOverlay:registerEventHandler( "interrupted_keyframe", f41_arg0.clipInterrupted )
				f41_arg0.SelectorOverlay:registerEventHandler( "transition_complete_keyframe", f41_arg0.clipFinished )
			end
			
			f41_arg0.SelectorOverlay:completeAnimation()
			f41_arg0.SelectorOverlay:setAlpha( 0.01 )
			f41_local2( f41_arg0.SelectorOverlay )
			local f41_local3 = function ( f45_arg0 )
				local f45_local0 = function ( f46_arg0 )
					f46_arg0:beginAnimation( 50 )
					f46_arg0:setLeftRight( 0, 1, -10, 10 )
					f46_arg0:setTopBottom( 0, 1, -10, 10 )
					f46_arg0:setAlpha( 1 )
					f46_arg0:registerEventHandler( "transition_complete_keyframe", f41_arg0.clipFinished )
				end
				
				f41_arg0.FocusBrackets:beginAnimation( 100 )
				f41_arg0.FocusBrackets:setLeftRight( 0, 1, -8, 8 )
				f41_arg0.FocusBrackets:setTopBottom( 0, 1, -8, 8 )
				f41_arg0.FocusBrackets:setAlpha( 0.67 )
				f41_arg0.FocusBrackets:registerEventHandler( "interrupted_keyframe", f41_arg0.clipInterrupted )
				f41_arg0.FocusBrackets:registerEventHandler( "transition_complete_keyframe", f45_local0 )
			end
			
			f41_arg0.FocusBrackets:completeAnimation()
			f41_arg0.FocusBrackets:setLeftRight( 0, 1, -40, 40 )
			f41_arg0.FocusBrackets:setTopBottom( 0, 1, -40, 40 )
			f41_arg0.FocusBrackets:setAlpha( 0 )
			f41_local3( f41_arg0.FocusBrackets )
			f41_arg0.CardIcon:completeAnimation()
			f41_arg0.CardIcon:setAlpha( 0 )
			f41_arg0.clipFinished( f41_arg0.CardIcon )
			f41_arg0.DarkOpsClassifiedIcon:completeAnimation()
			f41_arg0.DarkOpsClassifiedIcon:setAlpha( 1 )
			f41_arg0.clipFinished( f41_arg0.DarkOpsClassifiedIcon )
			f41_arg0.Label:completeAnimation()
			f41_arg0.Label:setRGB( 0.96, 0.94, 0.78 )
			f41_arg0.clipFinished( f41_arg0.Label )
			f41_arg0.lockedIcon:completeAnimation()
			f41_arg0.lockedIcon:setAlpha( 0 )
			f41_arg0.clipFinished( f41_arg0.lockedIcon )
		end,
		LoseFocus = function ( f47_arg0, f47_arg1 )
			f47_arg0:__resetProperties()
			f47_arg0:setupElementClipCounter( 7 )
			local f47_local0 = function ( f48_arg0 )
				f47_arg0.FocusGlow:beginAnimation( 200 )
				f47_arg0.FocusGlow:setAlpha( 0 )
				f47_arg0.FocusGlow:registerEventHandler( "interrupted_keyframe", f47_arg0.clipInterrupted )
				f47_arg0.FocusGlow:registerEventHandler( "transition_complete_keyframe", f47_arg0.clipFinished )
			end
			
			f47_arg0.FocusGlow:completeAnimation()
			f47_arg0.FocusGlow:setAlpha( 0.6 )
			f47_local0( f47_arg0.FocusGlow )
			local f47_local1 = function ( f49_arg0 )
				f47_arg0.FocusBorder:beginAnimation( 200 )
				f47_arg0.FocusBorder:setAlpha( 0 )
				f47_arg0.FocusBorder:registerEventHandler( "interrupted_keyframe", f47_arg0.clipInterrupted )
				f47_arg0.FocusBorder:registerEventHandler( "transition_complete_keyframe", f47_arg0.clipFinished )
			end
			
			f47_arg0.FocusBorder:completeAnimation()
			f47_arg0.FocusBorder:setAlpha( 1 )
			f47_local1( f47_arg0.FocusBorder )
			local f47_local2 = function ( f50_arg0 )
				f47_arg0.SelectorOverlay:beginAnimation( 200 )
				f47_arg0.SelectorOverlay:setAlpha( 0.01 )
				f47_arg0.SelectorOverlay:registerEventHandler( "interrupted_keyframe", f47_arg0.clipInterrupted )
				f47_arg0.SelectorOverlay:registerEventHandler( "transition_complete_keyframe", f47_arg0.clipFinished )
			end
			
			f47_arg0.SelectorOverlay:completeAnimation()
			f47_arg0.SelectorOverlay:setAlpha( 0.04 )
			f47_local2( f47_arg0.SelectorOverlay )
			local f47_local3 = function ( f51_arg0 )
				f47_arg0.FocusBrackets:beginAnimation( 60 )
				f47_arg0.FocusBrackets:setAlpha( 0 )
				f47_arg0.FocusBrackets:registerEventHandler( "interrupted_keyframe", f47_arg0.clipInterrupted )
				f47_arg0.FocusBrackets:registerEventHandler( "transition_complete_keyframe", f47_arg0.clipFinished )
			end
			
			f47_arg0.FocusBrackets:completeAnimation()
			f47_arg0.FocusBrackets:setAlpha( 1 )
			f47_local3( f47_arg0.FocusBrackets )
			f47_arg0.CardIcon:completeAnimation()
			f47_arg0.CardIcon:setAlpha( 0 )
			f47_arg0.clipFinished( f47_arg0.CardIcon )
			f47_arg0.DarkOpsClassifiedIcon:completeAnimation()
			f47_arg0.DarkOpsClassifiedIcon:setAlpha( 1 )
			f47_arg0.clipFinished( f47_arg0.DarkOpsClassifiedIcon )
			f47_arg0.lockedIcon:completeAnimation()
			f47_arg0.lockedIcon:setAlpha( 0 )
			f47_arg0.clipFinished( f47_arg0.lockedIcon )
		end
	},
	ClassifiedShowProgress = {
		DefaultClip = function ( f52_arg0, f52_arg1 )
			f52_arg0:__resetProperties()
			f52_arg0:setupElementClipCounter( 7 )
			f52_arg0.FocusBrackets:completeAnimation()
			f52_arg0.FocusBrackets:setAlpha( 0 )
			f52_arg0.clipFinished( f52_arg0.FocusBrackets )
			f52_arg0.CardIcon:completeAnimation()
			f52_arg0.CardIcon:setAlpha( 0 )
			f52_arg0.clipFinished( f52_arg0.CardIcon )
			f52_arg0.DarkOpsClassifiedIcon:completeAnimation()
			f52_arg0.DarkOpsClassifiedIcon:setAlpha( 1 )
			f52_arg0.clipFinished( f52_arg0.DarkOpsClassifiedIcon )
			f52_arg0.lockedIcon:completeAnimation()
			f52_arg0.lockedIcon:setAlpha( 0 )
			f52_arg0.clipFinished( f52_arg0.lockedIcon )
			f52_arg0.ProgressBarBacking:completeAnimation()
			f52_arg0.ProgressBarBacking:setAlpha( 0.1 )
			f52_arg0.clipFinished( f52_arg0.ProgressBarBacking )
			f52_arg0.ProgressBorder:completeAnimation()
			f52_arg0.ProgressBorder:setAlpha( 0.02 )
			f52_arg0.clipFinished( f52_arg0.ProgressBorder )
			f52_arg0.ProgressBar:completeAnimation()
			f52_arg0.ProgressBar:setAlpha( 1 )
			f52_arg0.clipFinished( f52_arg0.ProgressBar )
		end,
		Focus = function ( f53_arg0, f53_arg1 )
			f53_arg0:__resetProperties()
			f53_arg0:setupElementClipCounter( 8 )
			f53_arg0.FocusGlow:completeAnimation()
			f53_arg0.FocusGlow:setAlpha( 0.6 )
			f53_arg0.clipFinished( f53_arg0.FocusGlow )
			f53_arg0.FocusBorder:completeAnimation()
			f53_arg0.FocusBorder:setAlpha( 1 )
			f53_arg0.clipFinished( f53_arg0.FocusBorder )
			f53_arg0.SelectorOverlay:completeAnimation()
			f53_arg0.SelectorOverlay:setAlpha( 0.04 )
			f53_arg0.clipFinished( f53_arg0.SelectorOverlay )
			f53_arg0.CardIcon:completeAnimation()
			f53_arg0.CardIcon:setAlpha( 0 )
			f53_arg0.clipFinished( f53_arg0.CardIcon )
			f53_arg0.DarkOpsClassifiedIcon:completeAnimation()
			f53_arg0.DarkOpsClassifiedIcon:setAlpha( 1 )
			f53_arg0.clipFinished( f53_arg0.DarkOpsClassifiedIcon )
			f53_arg0.Label:completeAnimation()
			f53_arg0.Label:setRGB( 0.96, 0.94, 0.78 )
			f53_arg0.clipFinished( f53_arg0.Label )
			f53_arg0.lockedIcon:completeAnimation()
			f53_arg0.lockedIcon:setAlpha( 0 )
			f53_arg0.clipFinished( f53_arg0.lockedIcon )
			f53_arg0.ProgressBar:completeAnimation()
			f53_arg0.ProgressBar:setAlpha( 1 )
			f53_arg0.clipFinished( f53_arg0.ProgressBar )
		end,
		GainFocus = function ( f54_arg0, f54_arg1 )
			f54_arg0:__resetProperties()
			f54_arg0:setupElementClipCounter( 9 )
			local f54_local0 = function ( f55_arg0 )
				f54_arg0.FocusGlow:beginAnimation( 200 )
				f54_arg0.FocusGlow:setAlpha( 0.6 )
				f54_arg0.FocusGlow:registerEventHandler( "interrupted_keyframe", f54_arg0.clipInterrupted )
				f54_arg0.FocusGlow:registerEventHandler( "transition_complete_keyframe", f54_arg0.clipFinished )
			end
			
			f54_arg0.FocusGlow:completeAnimation()
			f54_arg0.FocusGlow:setAlpha( 0 )
			f54_local0( f54_arg0.FocusGlow )
			local f54_local1 = function ( f56_arg0 )
				f54_arg0.FocusBorder:beginAnimation( 200 )
				f54_arg0.FocusBorder:setAlpha( 1 )
				f54_arg0.FocusBorder:registerEventHandler( "interrupted_keyframe", f54_arg0.clipInterrupted )
				f54_arg0.FocusBorder:registerEventHandler( "transition_complete_keyframe", f54_arg0.clipFinished )
			end
			
			f54_arg0.FocusBorder:completeAnimation()
			f54_arg0.FocusBorder:setAlpha( 0 )
			f54_local1( f54_arg0.FocusBorder )
			local f54_local2 = function ( f57_arg0 )
				f54_arg0.SelectorOverlay:beginAnimation( 200 )
				f54_arg0.SelectorOverlay:setAlpha( 0.04 )
				f54_arg0.SelectorOverlay:registerEventHandler( "interrupted_keyframe", f54_arg0.clipInterrupted )
				f54_arg0.SelectorOverlay:registerEventHandler( "transition_complete_keyframe", f54_arg0.clipFinished )
			end
			
			f54_arg0.SelectorOverlay:completeAnimation()
			f54_arg0.SelectorOverlay:setAlpha( 0.01 )
			f54_local2( f54_arg0.SelectorOverlay )
			local f54_local3 = function ( f58_arg0 )
				local f58_local0 = function ( f59_arg0 )
					f59_arg0:beginAnimation( 50 )
					f59_arg0:setLeftRight( 0, 1, -10, 10 )
					f59_arg0:setTopBottom( 0, 1, -10, 10 )
					f59_arg0:setAlpha( 1 )
					f59_arg0:registerEventHandler( "transition_complete_keyframe", f54_arg0.clipFinished )
				end
				
				f54_arg0.FocusBrackets:beginAnimation( 100 )
				f54_arg0.FocusBrackets:setLeftRight( 0, 1, -8, 8 )
				f54_arg0.FocusBrackets:setTopBottom( 0, 1, -8, 8 )
				f54_arg0.FocusBrackets:setAlpha( 0.67 )
				f54_arg0.FocusBrackets:registerEventHandler( "interrupted_keyframe", f54_arg0.clipInterrupted )
				f54_arg0.FocusBrackets:registerEventHandler( "transition_complete_keyframe", f58_local0 )
			end
			
			f54_arg0.FocusBrackets:completeAnimation()
			f54_arg0.FocusBrackets:setLeftRight( 0, 1, -40, 40 )
			f54_arg0.FocusBrackets:setTopBottom( 0, 1, -40, 40 )
			f54_arg0.FocusBrackets:setAlpha( 0 )
			f54_local3( f54_arg0.FocusBrackets )
			f54_arg0.CardIcon:completeAnimation()
			f54_arg0.CardIcon:setAlpha( 0 )
			f54_arg0.clipFinished( f54_arg0.CardIcon )
			f54_arg0.DarkOpsClassifiedIcon:completeAnimation()
			f54_arg0.DarkOpsClassifiedIcon:setAlpha( 1 )
			f54_arg0.clipFinished( f54_arg0.DarkOpsClassifiedIcon )
			f54_arg0.Label:completeAnimation()
			f54_arg0.Label:setRGB( 0.96, 0.94, 0.78 )
			f54_arg0.clipFinished( f54_arg0.Label )
			f54_arg0.lockedIcon:completeAnimation()
			f54_arg0.lockedIcon:setAlpha( 0 )
			f54_arg0.clipFinished( f54_arg0.lockedIcon )
			f54_arg0.ProgressBar:completeAnimation()
			f54_arg0.ProgressBar:setAlpha( 1 )
			f54_arg0.clipFinished( f54_arg0.ProgressBar )
		end,
		LoseFocus = function ( f60_arg0, f60_arg1 )
			f60_arg0:__resetProperties()
			f60_arg0:setupElementClipCounter( 8 )
			local f60_local0 = function ( f61_arg0 )
				f60_arg0.FocusGlow:beginAnimation( 200 )
				f60_arg0.FocusGlow:setAlpha( 0 )
				f60_arg0.FocusGlow:registerEventHandler( "interrupted_keyframe", f60_arg0.clipInterrupted )
				f60_arg0.FocusGlow:registerEventHandler( "transition_complete_keyframe", f60_arg0.clipFinished )
			end
			
			f60_arg0.FocusGlow:completeAnimation()
			f60_arg0.FocusGlow:setAlpha( 0.6 )
			f60_local0( f60_arg0.FocusGlow )
			local f60_local1 = function ( f62_arg0 )
				f60_arg0.FocusBorder:beginAnimation( 200 )
				f60_arg0.FocusBorder:setAlpha( 0 )
				f60_arg0.FocusBorder:registerEventHandler( "interrupted_keyframe", f60_arg0.clipInterrupted )
				f60_arg0.FocusBorder:registerEventHandler( "transition_complete_keyframe", f60_arg0.clipFinished )
			end
			
			f60_arg0.FocusBorder:completeAnimation()
			f60_arg0.FocusBorder:setAlpha( 1 )
			f60_local1( f60_arg0.FocusBorder )
			local f60_local2 = function ( f63_arg0 )
				f60_arg0.SelectorOverlay:beginAnimation( 200 )
				f60_arg0.SelectorOverlay:setAlpha( 0.01 )
				f60_arg0.SelectorOverlay:registerEventHandler( "interrupted_keyframe", f60_arg0.clipInterrupted )
				f60_arg0.SelectorOverlay:registerEventHandler( "transition_complete_keyframe", f60_arg0.clipFinished )
			end
			
			f60_arg0.SelectorOverlay:completeAnimation()
			f60_arg0.SelectorOverlay:setAlpha( 0.04 )
			f60_local2( f60_arg0.SelectorOverlay )
			local f60_local3 = function ( f64_arg0 )
				f60_arg0.FocusBrackets:beginAnimation( 60 )
				f60_arg0.FocusBrackets:setAlpha( 0 )
				f60_arg0.FocusBrackets:registerEventHandler( "interrupted_keyframe", f60_arg0.clipInterrupted )
				f60_arg0.FocusBrackets:registerEventHandler( "transition_complete_keyframe", f60_arg0.clipFinished )
			end
			
			f60_arg0.FocusBrackets:completeAnimation()
			f60_arg0.FocusBrackets:setAlpha( 1 )
			f60_local3( f60_arg0.FocusBrackets )
			f60_arg0.CardIcon:completeAnimation()
			f60_arg0.CardIcon:setAlpha( 0 )
			f60_arg0.clipFinished( f60_arg0.CardIcon )
			f60_arg0.DarkOpsClassifiedIcon:completeAnimation()
			f60_arg0.DarkOpsClassifiedIcon:setAlpha( 1 )
			f60_arg0.clipFinished( f60_arg0.DarkOpsClassifiedIcon )
			f60_arg0.lockedIcon:completeAnimation()
			f60_arg0.lockedIcon:setAlpha( 0 )
			f60_arg0.clipFinished( f60_arg0.lockedIcon )
			f60_arg0.ProgressBar:completeAnimation()
			f60_arg0.ProgressBar:setAlpha( 1 )
			f60_arg0.clipFinished( f60_arg0.ProgressBar )
		end
	}
}

CoD.Shield_ModsStyle.__onClose = function ( f65_arg0 )
	f65_arg0.FocusBrackets:close()
	f65_arg0.CardIcon:close()
	f65_arg0.Lines:close()
	f65_arg0.Label:close()
	f65_arg0.lockedIcon:close()
	f65_arg0.TrialWidget:close()
	f65_arg0.ProgressBorder:close()
	f65_arg0.ProgressBar:close()
end

-- Mod Active List
CoD.ActiveModListData = InheritFrom( LUI.UIElement )
CoD.ActiveModListData.__defaultWidth = 1600
CoD.ActiveModListData.__defaultHeight = 620
CoD.ActiveModListData.new = function ( f1_arg0, f1_arg1, f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	local self = LUI.UIElement.new( f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	self:setClass( CoD.ActiveModListData )
	self.id = "ActiveModListData"
	self.soundSet = "default"
	self.onlyChildrenFocusable = true
	self.anyChildUsesUpdateState = true

	local ActiveModsList = LUI.UIList.new( f1_arg0, f1_arg1, 10, 0, nil, false, false, false, false )
	ActiveModsList:setLeftRight( 0.5, 0.5, 100, -700 + 1400 )
	ActiveModsList:setTopBottom( 0, 0, 240, 840 )
	ActiveModsList:setAutoScaleContent( true )
	ActiveModsList:setVerticalCount(10)
	ActiveModsList:setHorizontalCount(1)
	ActiveModsList:setSpacing( 10 )
	ActiveModsList:setWidgetType( CoD.ShieldActiveModRow )
	ActiveModsList:setVerticalCounter( CoD.verticalCounter )
	ActiveModsList:setDataSource( "ShieldActiveModsList" )
	ActiveModsList:setAlignment( Enum[@"luialignment"][@"lui_alignment_left"] )
	self:addElement( ActiveModsList )
	self.ActiveModsList = ActiveModsList

	-- for updates
	CoD.Menu.ActiveModsList = ActiveModsList

	-- update active mods
	Engine[@"exec"](Engine[@"getprimarycontroller"](), "MM_push_mods")

	ActiveModsList:AddContextualMenuAction( f1_arg0, f1_arg1, @"menu/remove", function ( f13_arg0, f13_arg1, f13_arg2, f13_arg3 )
		if AlwaysTrue() then
			return function ( f14_arg0, f14_arg1, f14_arg2, f14_arg3 )
				local ModName = f14_arg0:getModel(f14_arg2, "ModName")

				-- remove ^1 prefix if it's there
				local rawName = ModName:get()
				if string.sub(rawName, 1, 2) == "^1" then
					rawName = string.sub(rawName, 3)
				end
				
				CoD.EnhPrintInfo("Removing Mod -> " .. rawName)

				Engine[@"exec"](Engine[@"getprimarycontroller"](), "MM_remove_mod " .. rawName)
			end
			
		else
			CoD.EnhPrintInfo("WTF")
		end
	end ) 

	ActiveModsList:AddContextualMenuAction( f1_arg0, f1_arg1, @"shield/toggle_mod", function ( f13_arg0, f13_arg1, f13_arg2, f13_arg3 )
		if AlwaysTrue() then
			return function ( f14_arg0, f14_arg1, f14_arg2, f14_arg3 )
				local ModName = f14_arg0:getModel(f14_arg2, "ModName")
				CoD.EnhPrintInfo("Toggling Mod -> " .. ModName:get())

				-- remove ^1 prefix if it's there
				local rawName = ModName:get()
				if string.sub(rawName, 1, 2) == "^1" then
					rawName = string.sub(rawName, 3)
				end

				CoD.EnhPrintInfo("Toggling Mod -> " .. rawName)
				Engine[@"exec"](Engine["getprimarycontroller"](), "MM_toggle_mod " .. rawName)
			end
		else
			CoD.EnhPrintInfo("WTF")
		end
	end ) 

	f1_arg0:AddButtonCallbackFunction( ActiveModsList, f1_arg1, Enum[@"luibutton"][@"lui_key_xbx_pssquare"], "ui_remove", function ( element, menu, controller, model )
		if AlwaysTrue() then
			local ModName = element:getModel(model, "ModName")

			-- remove ^1 prefix if it's there
			local rawName = ModName:get()
			if string.sub(rawName, 1, 2) == "^1" then
				rawName = string.sub(rawName, 3)
			end

			CoD.EnhPrintInfo("Removing Mod -> " .. rawName)

			Engine[@"exec"](Engine[@"getprimarycontroller"](), "MM_remove_mod " .. rawName)
			
			return true
		else
			
		end
	end, function ( element, menu, controller )
		if not CoD.ModelUtility.IsSelfModelValueEqualTo( element, controller, "itemIndex", CoDShared.EmptyItemIndex ) and IsGamepad( controller ) and not IsElementPropertyValue( element, "__hasFocusOnVariantWidget", true ) then
			CoD.Menu.SetButtonLabel( menu, Enum[@"luibutton"][@"lui_key_xbx_pssquare"], @"menu/remove", nil, "ui_remove" )
			return true
		elseif IsMouseOrKeyboard( controller ) and not CoD.ModelUtility.IsSelfModelValueEqualTo( element, controller, "itemIndex", CoDShared.EmptyItemIndex ) and not IsElementPropertyValue( element, "__hasFocusOnVariantWidget", true ) then
			CoD.Menu.SetButtonLabel( menu, Enum[@"luibutton"][@"lui_key_xbx_pssquare"], @"menu/remove", Enum[@"luibuttonpromptflags"][@"bpf_contextual"], "ui_remove" )
			return true
		else
			return false
		end
	end, false )

	f1_arg0:AddButtonCallbackFunction( ActiveModsList, f1_arg1, Enum[@"luibutton"][@"lui_key_xby_pstriangle"], "Y", function ( element, menu, controller, model )
		if AlwaysTrue() then
			local ModName = element:getModel(model, "ModName")
			CoD.EnhPrintInfo("Toggling Mod -> " .. ModName:get())

			-- remove ^1 prefix if it's there
			local rawName = ModName:get()
			if string.sub(rawName, 1, 2) == "^1" then
				rawName = string.sub(rawName, 3)
			end

			CoD.EnhPrintInfo("Toggling Mod -> " .. rawName)
			Engine[@"exec"](Engine["getprimarycontroller"](), "MM_toggle_mod " .. rawName)


			return true
		else
			
		end
	end, function ( element, menu, controller )
		if not CoD.ModelUtility.IsSelfModelValueEqualTo( element, controller, "itemIndex", CoDShared.EmptyItemIndex ) and IsGamepad( controller ) and not IsElementPropertyValue( element, "__hasFocusOnVariantWidget", true ) then
			CoD.Menu.SetButtonLabel( menu, Enum[@"luibutton"][@"lui_key_xby_pstriangle"], @"shield/toggle_mod", nil, "Y" )
			return true
		elseif IsMouseOrKeyboard( controller ) and not CoD.ModelUtility.IsSelfModelValueEqualTo( element, controller, "itemIndex", CoDShared.EmptyItemIndex ) and not IsElementPropertyValue( element, "__hasFocusOnVariantWidget", true ) then
			CoD.Menu.SetButtonLabel( menu, Enum[@"luibutton"][@"lui_key_xby_pstriangle"], @"shield/toggle_mod", Enum[@"luibuttonpromptflags"][@"bpf_contextual"], "Y" )
			return true
		else
			return false
		end
	end, false )

	-- name
	CoD.PCWidgetUtility.SetupContextualMenu( ActiveModsList, f1_arg1, "ModName", "", "" )

	ActiveModsList.id = "ActiveModsList"

	LUI.OverrideFunction_CallOriginalSecond( self, "close", self.__onClose )
	
	if PostLoadFunc then
		PostLoadFunc( self, f1_arg1, f1_arg0 )
	end

	return self
end

CoD.ActiveModListData.__onClose = function ( f9_arg0 )
	--f9_arg0.LANServerBrowserDetails:close()
	f9_arg0.ActiveModsList:close()
end

-- Mods Background Style
CoD.ModsCommonCenteredPopup = InheritFrom( LUI.UIElement )
CoD.ModsCommonCenteredPopup.__defaultWidth = 1920
CoD.ModsCommonCenteredPopup.__defaultHeight = 1080
CoD.ModsCommonCenteredPopup.new = function ( f1_arg0, f1_arg1, f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	local self = LUI.UIElement.new( f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	self:setClass( CoD.ModsCommonCenteredPopup )
	self.id = "ModsCommonCenteredPopup"
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
	
	local buttons = CoD.fe_LeftContainer_NOTLobby.new( f1_arg0, f1_arg1, 0.5, 0.5, -312, 336, 0.5, 0.5, 439, 487 )
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

	-- reload one
	local ReloadModsOverlayButtonMouseOnly = nil
	
	ReloadModsOverlayButtonMouseOnly = CoD.featureOverlay_Button.new( f1_arg0, f1_arg1, 0.5, 0.5, -333 + 750, -147 + 750, 0.5, 0.5, 424, 484 )
	ReloadModsOverlayButtonMouseOnly.ButtonContainer.Title:setText( "Reload Mods" )
	ReloadModsOverlayButtonMouseOnly:registerEventHandler( "gain_focus", function ( element, event )
		local f2_local0 = nil
		if element.gainFocus then
			f2_local0 = element:gainFocus( event )
		elseif element.super.gainFocus then
			f2_local0 = element.super:gainFocus( event )
		end
		CoD.Menu.UpdateButtonShownState( element, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
		return f2_local0
	end )
	f1_arg0:AddButtonCallbackFunction( ReloadModsOverlayButtonMouseOnly, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], "ui_confirm", function ( element, menu, controller, model )
		PlaySoundAlias( "uin_paint_image_flip_toggle" )
		CoD.EnhPrintInfo("ReloadModsButton")
		
		-- reload with killserver
		CoD.VM_ReloadMods()
		return true
	end, function ( element, menu, controller )
		CoD.Menu.SetButtonLabel( menu, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], @"hash_0", nil, "ui_confirm" )
		return false
	end, false )
	self:addElement( ReloadModsOverlayButtonMouseOnly )
	self.ReloadModsOverlayButtonMouseOnly = ReloadModsOverlayButtonMouseOnly
	
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
		ReloadModsOverlayButtonMouseOnly.id = "ReloadModsOverlayButtonMouseOnly"
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

CoD.ModsCommonCenteredPopup.__onClose = function ( f8_arg0 )
	f8_arg0.buttons:close()
	f8_arg0.featureOverlayButtonMouseOnly:close()
	f8_arg0.ReloadModsOverlayButtonMouseOnly:close()
	f8_arg0.BTNQuit:close()
end

-- Mods
CoD.ShieldModManager = InheritFrom( CoD.Menu )
LUI.createMenu.ShieldModManager = function ( f1_arg0, f1_arg1 )
	local self = CoD.Menu.NewForUIEditor( "ShieldModManager", f1_arg0 )
	local f1_local1 = self
	self:setClass( CoD.ShieldModManager )
	self.soundSet = "none"
	self:setOwner( f1_arg0 )
	self:setLeftRight( 0, 1, 0, 0 )
	self:setTopBottom( 0, 1, 0, 0 )
	self:playSound( "menu_open", f1_arg0 )
	self.anyChildUsesUpdateState = true
	f1_local1:addElementToPendingUpdateStateList( self )
	
	local CommomCenteredPopup = CoD.ModsCommonCenteredPopup.new( f1_local1, f1_arg0, 0, 1, 0, 0, 0, 1, 0, 0 )
	CommomCenteredPopup.TitleText:setText("Mod Manager")
	CommomCenteredPopup.HeaderBackground:setAlpha( 0 )
	CommomCenteredPopup.HeaderTopBar:setAlpha( 0 )
	CommomCenteredPopup.HeaderBottomBar:setAlpha( 0 )
	self:addElement( CommomCenteredPopup )
	self.CommomCenteredPopup = CommomCenteredPopup

	local InstalledModsText = LUI.UIText.new( 0.5, 0.5, 105, 900, 0.5, 0.5, 0 - 350, 35 - 350 )
	InstalledModsText:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )
	InstalledModsText:setTTF( "notosans_regular" )
	InstalledModsText:setText("Installed Mods: (right click for more actions..)")
	InstalledModsText:setAlignment( Enum[@"luialignment"][@"lui_alignment_left"] )
	InstalledModsText:setAlignment( Enum[@"luialignment"][@"lui_alignment_top"] )
	self:addElement( InstalledModsText )
	self.InstalledModsText = InstalledModsText

	local FeatModsText = LUI.UIText.new( 0.5, 0.5, -695, 695, 0.5, 0.5, 0 - 350, 35 - 350 )
	FeatModsText:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )
	FeatModsText:setTTF( "notosans_regular" )
	FeatModsText:setText("Featured Mods:")
	FeatModsText:setAlignment( Enum[@"luialignment"][@"lui_alignment_left"] )
	FeatModsText:setAlignment( Enum[@"luialignment"][@"lui_alignment_top"] )
	self:addElement( FeatModsText )
	self.FeatModsText = FeatModsText

	-- sep
	local HeaderPixSep = LUI.UIImage.new( 0.5, 0.5, 60, 90, 0.5, 0.5, -450, 450 )
	HeaderPixSep:setAlpha( 0.25 )
	HeaderPixSep:setImage( RegisterImage( @"hash_CB07CCC28498CB2" ) )
	--HeaderPixSep:setMaterial( LUI.UIImage.GetCachedMaterial( @"hash_16CBE95C250C6D15" ) )
	HeaderPixSep:setShaderVector( 0, 0, 0, 0, 0 )
	HeaderPixSep:setupNineSliceShader( 128, 128 )
	self:addElement( HeaderPixSep )
	self.HeaderPixSep = HeaderPixSep

	-- active, fucked up datasource widget, so inside a cod better
	local ActiveModList = CoD.ActiveModListData.new( self, f1_arg0, 0.5, 0.5, -800, 800, 0.5, 0.5, -535, 400 )
	self:addElement( ActiveModList )
	self.ActiveModList = ActiveModList

	ActiveModList.id = "ActiveModList"
	
	local ModsList = LUI.UIList.new( f1_local1, f1_arg0, 3, 3, nil, false, false, false, false )
	ModsList:setLeftRight( 0.5, 0.5, -1100, 450 )
	ModsList:setTopBottom( 0.55, 0.55, -380 + 290, -320 + 290 )
	ModsList:setAutoScaleContent( true )
	ModsList:setVerticalCount(4)
	ModsList:setHorizontalCount(2)
	ModsList:setSpacing( 30 )
	ModsList:setWidgetType( CoD.Shield_ModsStyleMain )
	ModsList:setVerticalCounter( CoD.verticalCounter )
	ModsList:setAlignment( Enum[@"luialignment"][@"lui_alignment_left"] )
	ModsList:setDataSource( "ShieldFeaturedModsList" )

	self:AddButtonCallbackFunction( ModsList, f1_arg0, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], "ui_confirm", function ( element, menu, controller, model )
		if not CoD.ModelUtility.IsSelfModelValueTrue( element, controller, "locked" ) and CoD.DirectorUtility.ShowForAllClients( element, controller ) then
			PlaySoundAlias( "uin_toggle_generic" )
			
			-- open site
			CoD.EnhPrintInfo("MM_download_mod", element.site)

			-- removed delay, we have in c++ side anyways.
			Engine[@"exec"](Engine[@"getprimarycontroller"](), "MM_download_mod " .. element.site)

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

	self:addElement( ModsList )
	self.ModsList = ModsList

	local C_Status = LUI.UIText.new( 0.5, 0.5, 150, 850, 0.60, 0.60, -284 + 475, -263 + 475 )
	C_Status:setText("Status: Idle")
	C_Status:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )
	C_Status:setTTF( "notosans_bold" )
	C_Status:setAlignment( Enum[@"luialignment"][@"lui_alignment_left"] )
	C_Status:setAlignment( Enum[@"luialignment"][@"lui_alignment_top"] )
	self:addElement( C_Status )

	-- for updates
	CoD.Menu.C_Status = C_Status
	
	local ModDescription = LUI.UIText.new( 0.5, 0.5, -700, 50, 0.50, 0.50, -284 + 640, -263 + 640 )
	ModDescription:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )
	ModDescription:setTTF( "notosans_regular" )
	ModDescription:setAlignment( Enum[@"luialignment"][@"lui_alignment_left"] )
	ModDescription:setAlignment( Enum[@"luialignment"][@"lui_alignment_top"] )
	self:addElement( ModDescription )
	self.ModDescription = ModDescription
	
	local PCSmallCloseButton = nil
	
	--[[
	PCSmallCloseButton = CoD.PC_SmallCloseButton.new( f1_local1, f1_arg0, 0.5, 0.5, 308, 342, 0.5, 0.5, -438.5, -404.5 )
	PCSmallCloseButton:registerEventHandler( "gain_focus", function ( element, event )
		local f2_local0 = nil
		if element.gainFocus then
			f2_local0 = element:gainFocus( event )
		elseif element.super.gainFocus then
			f2_local0 = element.super:gainFocus( event )
		end
		CoD.Menu.UpdateButtonShownState( element, f1_local1, f1_arg0, Enum[@"luibutton"][@"lui_key_none"] )
		return f2_local0
	end )
	f1_local1:AddButtonCallbackFunction( PCSmallCloseButton, f1_arg0, Enum[@"luibutton"][@"lui_key_none"], "MOUSE1", function ( element, menu, controller, model )
		GoBack( self, controller )
		return true
	end, function ( element, menu, controller )
		CoD.Menu.SetButtonLabel( menu, Enum[@"luibutton"][@"lui_key_none"], @"hash_0", nil, "MOUSE1" )
		return false
	end, false )
	f1_local1:AddButtonCallbackFunction( PCSmallCloseButton, f1_arg0, Enum[@"luibutton"][@"lui_key_none"], "ui_confirm", function ( element, menu, controller, model )
		GoBack( self, controller )
		return true
	end, function ( element, menu, controller )
		CoD.Menu.SetButtonLabel( menu, Enum[@"luibutton"][@"lui_key_none"], @"hash_0", nil, "ui_confirm" )
		return false
	end, false )

	-- no point?
	--self:addElement( PCSmallCloseButton )
	--self.PCSmallCloseButton = PCSmallCloseButton
	]]
	
	ModDescription:linkToElementModel( ModsList, "desc", true, function ( model )
		local f7_local0 = model:get()
		if f7_local0 ~= nil then
			ModDescription:setText( f7_local0 )
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
	ModsList.id = "ModsList"
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

	CoD.EnhPrintInfo("Called", "Shield's Mods")

	return self
end

CoD.ShieldModManager.__resetProperties = function ( f13_arg0 )
	f13_arg0.ModsList:completeAnimation()
	f13_arg0.ModDescription:completeAnimation()
	f13_arg0.ModsList:setLeftRight( 0.5, 0.5, -1100, 450 )
end

CoD.ShieldModManager.__clipsPerState = {
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
			f15_arg0.ModsList:completeAnimation()
			f15_arg0.ModsList:setLeftRight( 0.5, 0.5, -1100, 450 )
			f15_arg0.clipFinished( f15_arg0.ModsList )
		end
	}
}

CoD.ShieldModManager.__onClose = function ( f16_arg0 )
	f16_arg0.ModDescription:close()
	f16_arg0.CommomCenteredPopup:close()
	f16_arg0.ModsList:close()
	f16_arg0.C_Status:close()
	f16_arg0.InstalledModsText:close()
	f16_arg0.FeatModsText:close()
	f16_arg0.HeaderPixSep:close()
	f16_arg0.ActiveModList:close()
	--f16_arg0.PCSmallCloseButton:close()
end