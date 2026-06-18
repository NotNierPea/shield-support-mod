--[[
		.\hksc.exe ".\Lua\PatchNotes.Lua" -o "C:\Program Files (x86)\Call of Duty Black Ops 4\project-bo4\mods\T8ShieldSupport\Lua\PatchNotes.luac"
]]

---------------------------

CoD.ShieldInitLuaFile()

---------------------------

-- Patch Notes Menu
CoD.ShieldPatchNotes = InheritFrom( CoD.Menu )
LUI.createMenu.ShieldPatchNotes = function ( f1_arg0, f1_arg1 )
	local self = CoD.Menu.NewForUIEditor( "ShieldPatchNotes", f1_arg0 )
	local f1_local1 = self
	self:setClass( CoD.ShieldPatchNotes )
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

	local ShieldPatchNotes_SafeAreaFront = CoD.ShieldPatchNotes_SafeAreaFront.new( f1_local1, f1_arg0, 0, 0, 0, 1920, 0, 0, 0, 1080 )
	ShieldPatchNotes_SafeAreaFront:registerEventHandler( "menu_loaded", function ( element, event )
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
	self:addElement( ShieldPatchNotes_SafeAreaFront )
	self.ShieldPatchNotes_SafeAreaFront = ShieldPatchNotes_SafeAreaFront

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
	CoD.EnhPrintInfo("Called", "Shield's Patch Notes")

	SizeToSafeArea(ShieldPatchNotes_SafeAreaFront, f1_arg0)

	return self
end

CoD.ShieldPatchNotes.__onClose = function ( f8_arg0 )
	f8_arg0.Background:close()
	f8_arg0.FooterContainerFrontendRight:close()
	f8_arg0.ShieldPatchNotes_SafeAreaFront:close()
end

CoD.CreditsGuy = InheritFrom( LUI.UIElement ) 
CoD.CreditsGuy.__defaultWidth = 150 
CoD.CreditsGuy.__defaultHeight = 150 
CoD.CreditsGuy.new = function ( f1_arg0, f1_arg1, f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	local self = LUI.UIElement.new( f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 ) 
	self:setClass( CoD.CreditsGuy ) 
	self.id = "CreditsGuy" 
	self.soundSet = "default" 
	
	local Portrait = LUI.UIImage.new( 0, 1, 0, 0, 0, 1, 0, 0 ) 
	Portrait:setImage( RegisterImage( @"ui_icon_hero_portrait_draft_stanton" ) ) 
	Portrait:setMaterial( LUI.UIImage.GetCachedMaterial( @"hash_1A02C44161370F6D" ) ) 
	Portrait:setShaderVector( 0, 0, 0, 0, 0 ) 
	Portrait:setShaderVector( 1, 1, 1, 0, 0 ) 
	Portrait:setShaderVector( 2, 0.2, 0, 0, 0 ) 
	self:addElement( Portrait ) 
	self.Portrait = Portrait 
	
	if PostLoadFunc then
		PostLoadFunc( self, f1_arg1, f1_arg0 ) 
	end
	
	return self
end

CoD.ShieldPatchNotes_SafeAreaFront = InheritFrom( LUI.UIElement )
CoD.ShieldPatchNotes_SafeAreaFront.__defaultWidth = 1920
CoD.ShieldPatchNotes_SafeAreaFront.__defaultHeight = 1080
CoD.ShieldPatchNotes_SafeAreaFront.new = function ( f1_arg0, f1_arg1, f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	local self = LUI.UIElement.new( f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	self:setClass( CoD.ShieldPatchNotes_SafeAreaFront )
	self.id = "ShieldPatchNotes_SafeAreaFront"
	self.soundSet = "none"
	self.onlyChildrenFocusable = true
	self.anyChildUsesUpdateState = true
	
	local TabBacking = CoD.CommonTabBarBacking.new( f1_arg0, f1_arg1, -0.1, 1.1, 0, 0, 0, 0, 52, 89 )
	TabBacking.TabBackingBlur:setAlpha( 0 )
	self:addElement( TabBacking )
	self.TabBacking = TabBacking
	
	local CommonHeader = CoD.CommonHeader.new( f1_arg0, f1_arg1, 0, 1, 0, 0, 0, 0, 0, 67 )
	CommonHeader.subtitle.StageTitle:setText("^2Shield Patch Notes")
	CommonHeader.subtitle.subtitle:setText("^1Shield's Last Patch Notes")
	self:addElement( CommonHeader )
	self.CommonHeader = CommonHeader
	
	local HeaderStripe = CoD.header_container_frontend.new( f1_arg0, f1_arg1, 0, 1, 0, 0, 0, 0, 0, 42 )
	self:addElement( HeaderStripe )
	self.HeaderStripe = HeaderStripe

	local BG = LUI.UIImage.new( 0.50, 0.50, -896.74, 0.26, 0.50, 0.50, -445.50, 464.50 )
	BG:setRGB( 0, 0, 0 )
    BG:setAlpha( 0.50 )
	BG:setZRot( 180 )
	self:addElement( BG )
	self.BG = BG

	--LUI_DebugElement(f1_arg0, f1_arg1, self, BG, "BG", 10)

    local Outline = LUI.UIImage.new( 0.50, 0.50, -896.74, 0.26, 0.50, 0.50, -445.50, 464.50 )
    Outline:setRGB( 1, 1, 1 )
	Outline:setAlpha( 0.05 )
	Outline:setImage( RegisterImage( @"uie_highlight_border_line" ) )
	Outline:setMaterial( LUI.UIImage.GetCachedMaterial( @"uie_nineslice_normal" ) )
	Outline:setShaderVector( 0, 0, 0, 0, 0 )
	Outline:setupNineSliceShader( 6, 6 )
	self:addElement( Outline )
	self.Outline = Outline

	--LUI_DebugElement(f1_arg0, f1_arg1, self, Outline, "Outline", 10)

	local BG2 = LUI.UIImage.new( 0.50, 0.50, 49.50, 947.50, 0.50, 0.50, -445.50, 464.50 )
	BG2:setRGB( 0, 0, 0 )
    BG2:setAlpha( 0.50 )
	BG2:setZRot( 180 )
	self:addElement( BG2 )
	self.BG2 = BG2

	--LUI_DebugElement(f1_arg0, f1_arg1, self, BG2, "BG2", 10)

    local Outline2 = LUI.UIImage.new( 0.50, 0.50, 49.50, 947.50, 0.50, 0.50, -445.50, 464.50 )
    Outline2:setRGB( 1, 1, 1 )
	Outline2:setAlpha( 0.05 )
	Outline2:setImage( RegisterImage( @"uie_highlight_border_line" ) )
	Outline2:setMaterial( LUI.UIImage.GetCachedMaterial( @"uie_nineslice_normal" ) )
	Outline2:setShaderVector( 0, 0, 0, 0, 0 )
	Outline2:setupNineSliceShader( 6, 6 )
	self:addElement( Outline2 )
	self.Outline2 = Outline2

	--LUI_DebugElement(f1_arg0, f1_arg1, self, Outline2, "Outline2", 10)

	local PatchNotesText = LUI.UIText.new( 0.50, 0.50, -851.27, -251.27, 0.50, 0.50, -404.75, -362.75 )
	PatchNotesText:setText("Last Patch Notes:")
	PatchNotesText:setTTF("notosans_bold")
	PatchNotesText:setLetterSpacing(0.5)
	self:addElement(PatchNotesText)
	self.PatchNotesText = PatchNotesText

	local PatchNotesAll = LUI.UIText.new(0.50, 0.50, -850.99, -52.99, 0.50, 0.50, -351.25, -326.25)
	PatchNotesAll:setText("- Added support for custom camos\n- improved viewmodel fov, no needing to move the gun around anymore, with aspect ratio support (/viewmodel (fov) in chat, /ratio (amount) in chat, moving the gun xyz around still exists)\n- Added an option to make fov not affect ADS (kinda works)\n- Added an option to mute the chat in online (/mute or /unmute in chat)\n- Added a timescale command\n- Some other stuff added/fixed")
	PatchNotesAll:setAlignment( Enum[@"luialignment"][@"lui_alignment_left"] )
	PatchNotesAll:setAlignment( Enum[@"luialignment"][@"lui_alignment_top"] )
	PatchNotesAll:setTTF("notosans_bold")
	PatchNotesAll:setLetterSpacing(0.5)
	self:addElement(PatchNotesAll)
	self.PatchNotesAll = PatchNotesAll

	--LUI_DebugElement(f1_arg0, f1_arg1, self, PatchNotesText, "PatchNotesText", 10)

	local InfoNotesText = LUI.UIText.new( 0.50, 0.50, -851.27, -251.27, 0.50, 0.50, 3.50, 47.50 )
	InfoNotesText:setText("Shield Info:")
	InfoNotesText:setTTF("notosans_bold")
	InfoNotesText:setLetterSpacing(0.5)
	self:addElement(InfoNotesText)
	self.InfoNotesText = InfoNotesText

	local InfoNotesAll = LUI.UIText.new(0.50, 0.50, -851.52, -53.52, 0.50, 0.50, 56.75, 80.00)
	InfoNotesAll:setText("- Shield Documentation: shield-bo4.gitbook.io\n- Shield Discord Server: discord.gg/AXECAzJJGU\n- You can find Mods in the Discord Server, or from Featured Mods in Main Menu\n- Voice Chat is not supported yet\n- Having NAT Type: Open, will fix some errors when joining lobbies\n- To open Console, Press '~'\n- To Unlock All, Press Shield Options on the far left\n- To View Client's Logs, you can find it in BO4's Files called 'project-bo4.log'")
	InfoNotesAll:setAlignment( Enum[@"luialignment"][@"lui_alignment_left"] )
	InfoNotesAll:setAlignment( Enum[@"luialignment"][@"lui_alignment_top"] )
	InfoNotesAll:setTTF("notosans_bold")
	InfoNotesAll:setLetterSpacing(0.5)
	self:addElement(InfoNotesAll)
	self.InfoNotesAll = InfoNotesAll

	--LUI_DebugElement(f1_arg0, f1_arg1, self, InfoNotesText, "InfoNotesText", 10)

	-- open commands and buttons
	local OpenDocsButton = CoD.DirectorSelectButtonMiniInternal.new( f1_arg0, f1_arg1, 0.5, 0.5, 70 - 840 - 85 + 70, 370 - 840 - 85 + 90, 0.5, 0.5, 227.5 + 100, 277.5 + 100 )
	
	OpenDocsButton.MiddleText:setTTF( "notosans_bold" )
	OpenDocsButton.MiddleText:setText("Open Shield Docs Link")

	OpenDocsButton.MiddleTextFocus:setText("Open Shield Docs Link")
	OpenDocsButton.MiddleTextFocus:setTTF( "notosans_bold" )

	OpenDocsButton:mergeStateConditions( {
		{
			stateName = "Locked",
			condition = function ( menu, element, event )
				return AlwaysFalse()
			end
		}
	} )

	OpenDocsButton:linkToElementModel( self, nil, false, function ( model )
		OpenDocsButton:setModel( model, f1_arg1 )
	end )
	self:addElement( OpenDocsButton )
	self.OpenDocsButton = OpenDocsButton

	f1_arg0:AddButtonCallbackFunction( OpenDocsButton, f1_arg0, Enum[@"luibutton"][@"lui_key_xba_pscross"], "ui_confirm", function ( element, menu, controller, model )
		PlaySoundAlias( "uin_paint_image_flip_toggle" )
		CoD.EnhPrintInfo("OpenDocsButton")
		
		Engine[@"exec"](Engine[@"getprimarycontroller"](), "docs")

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
	
	OpenDocsButton.id = "OpenDocsButton"

	------------------------------------------

	local OpenDiscordButton = CoD.DirectorSelectButtonMiniInternal.new( f1_arg0, f1_arg1, 0.5, 0.5, 70 - 840 + 190 + 130, 370 - 840 + 210 + 130, 0.5, 0.5, 227.5 + 100, 277.5 + 100 )
	
	OpenDiscordButton.MiddleText:setTTF( "notosans_bold" )
	OpenDiscordButton.MiddleText:setText("Open Discord Invite Link")

	OpenDiscordButton.MiddleTextFocus:setText("Open Discord Invite Link")
	OpenDiscordButton.MiddleTextFocus:setTTF( "notosans_bold" )

	OpenDiscordButton:mergeStateConditions( {
		{
			stateName = "Locked",
			condition = function ( menu, element, event )
				return AlwaysFalse()
			end
		}
	} )

	OpenDiscordButton:linkToElementModel( self, nil, false, function ( model )
		OpenDiscordButton:setModel( model, f1_arg1 )
	end )
	self:addElement( OpenDiscordButton )
	self.OpenDiscordButton = OpenDiscordButton

	f1_arg0:AddButtonCallbackFunction( OpenDiscordButton, f1_arg0, Enum[@"luibutton"][@"lui_key_xba_pscross"], "ui_confirm", function ( element, menu, controller, model )
		PlaySoundAlias( "uin_paint_image_flip_toggle" )
		CoD.EnhPrintInfo("OpenDiscordButton")
		
		Engine[@"exec"](Engine[@"getprimarycontroller"](), "discord")

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
	
	OpenDiscordButton.id = "OpenDiscordButton"

	----------------------------------------------

	-- CREDITS
	local CreditsText = LUI.UIText.new( 0.50, 0.50, 393.02, 998.02, 0.40, 0.40, -319.26, -269.26 )
	CreditsText:setText("^5C R E D I T S")
	CreditsText:setTTF("notosans_bold")
	CreditsText:setLetterSpacing(0.5)
	self:addElement(CreditsText)
	self.CreditsText = CreditsText

	-- Peawhatever
	local Duck = CoD.CreditsGuy.new( f1_arg0, f1_arg1, 0.50, 0.50, 270.00, 430.00, 0.50, 0.50, -381.01, -222.01 )
	Duck:setRFTMaterial( LUI.UIImage.GetCachedMaterial( @"hash_2D79DB5C45AD6024" ) )
	Duck:setShaderVector( 0, 34, 6, 0, 0 )
	Duck:setShaderVector( 1, 80, 80, 0, 0 )
	Duck:setShaderVector( 2, 0, 0.45, 0, 0 )
	Duck.Portrait:setShaderVector( 0, 0.1, 0, 0, 0 )
	Duck.Portrait:setImage( RegisterImage( @"peawhatever_cred" ) )
	self:addElement( Duck )
	self.Duck = Duck

	local PeawhateverText = LUI.UIText.new( 0.50, 0.50, 276.02, 476.02, 0.50, 0.50, -224, -190 )
	PeawhateverText:setText("peawhatever")
	PeawhateverText:setTTF("notosans_bold")
	PeawhateverText:setLetterSpacing(0.5)
	self:addElement(PeawhateverText)
	self.PeawhateverText = PeawhateverText

	local PeawhateverText_Desc = LUI.UIText.new( 0.50, 0.50, 241.49, 284.49, 0.50, 0.50, -186.24, -174.24 )
	PeawhateverText_Desc:setText("(for lua/gsc support mod, and some c++)")
	PeawhateverText_Desc:setTTF( "default" )
	PeawhateverText_Desc:setLetterSpacing(0.5)
	self:addElement(PeawhateverText_Desc)
	self.PeawhateverText_Desc = PeawhateverText_Desc

	-- Wanted
	local Wanted = CoD.CreditsGuy.new( f1_arg0, f1_arg1, 0.50, 0.50, 560.00, 720.00, 0.50, 0.50, -381.01, -222.01 )
	Wanted:setRFTMaterial( LUI.UIImage.GetCachedMaterial( @"hash_2D79DB5C45AD6024" ) )
	Wanted:setShaderVector( 0, 34, 6, 0, 0 )
	Wanted:setShaderVector( 1, 80, 80, 0, 0 )
	Wanted:setShaderVector( 2, 0, 0.45, 0, 0 )
	Wanted.Portrait:setShaderVector( 0, 0.1, 0, 0, 0 )
	Wanted.Portrait:setImage( RegisterImage( @"wanted_cred" ) )
	self:addElement( Wanted )
	self.Wanted = Wanted

	local WantedText = LUI.UIText.new( 0.50, 0.50, 595.02, 795.02, 0.50, 0.50, -224, -190 )
	WantedText:setText("Wanted")
	WantedText:setTTF("notosans_bold")
	WantedText:setLetterSpacing(0.5)
	self:addElement(WantedText)
	self.WantedText = WantedText

	local WantedText_Desc = LUI.UIText.new( 0.50, 0.50, 561.27, 591.27, 0.50, 0.50, -186.51, -174.51 )
	WantedText_Desc:setText("(for hooks and patches in c++)")
	WantedText_Desc:setTTF( "default" )
	WantedText_Desc:setLetterSpacing(0.5)
	self:addElement(WantedText_Desc)
	self.WantedText_Desc = WantedText_Desc

	-- second
	-- BodNJenie
	local BodNJenie = CoD.CreditsGuy.new( f1_arg0, f1_arg1, 0.50, 0.50, 270.00, 430.00, 0.50, 0.50, -381.01 + 300, -222.01 + 300 )
	BodNJenie:setRFTMaterial( LUI.UIImage.GetCachedMaterial( @"hash_2D79DB5C45AD6024" ) )
	BodNJenie:setShaderVector( 0, 34, 6, 0, 0 )
	BodNJenie:setShaderVector( 1, 80, 80, 0, 0 )
	BodNJenie:setShaderVector( 2, 0, 0.45, 0, 0 )
	BodNJenie.Portrait:setShaderVector( 0, 0.1, 0, 0, 0 )
	BodNJenie.Portrait:setImage( RegisterImage( @"bodnjenie_cred" ) )
	self:addElement( BodNJenie )
	self.BodNJenie = BodNJenie

	local BodNJenieText = LUI.UIText.new( 0.50, 0.50, 290.02, 476.02, 0.50, 0.50, -224 + 300, -190 + 300 )
	BodNJenieText:setText("BodNJenie")
	BodNJenieText:setTTF("notosans_bold")
	BodNJenieText:setLetterSpacing(0.5)
	self:addElement(BodNJenieText)
	self.BodNJenieText = BodNJenieText

	local BodNJenieText_Desc = LUI.UIText.new( 0.50, 0.50, 20.75, 700.75, 0.50, 0.50, 114.75, 126.75 )
	BodNJenieText_Desc:setTTF( "default" )
	BodNJenieText_Desc:setAlignment( Enum[@"luialignment"][@"lui_alignment_center"] )
	BodNJenieText_Desc:setAlignment( Enum[@"luialignment"][@"lui_alignment_top"] )
	BodNJenieText_Desc:setText("(for hosting public server, making it \npossible to play online with friends)")
	BodNJenieText_Desc:setLetterSpacing(0.5)
	self:addElement(BodNJenieText_Desc)
	self.BodNJenieText_Desc = BodNJenieText_Desc

	-- ATE47
	local ATE47 = CoD.CreditsGuy.new( f1_arg0, f1_arg1, 0.50, 0.50, 560.00, 720.00, 0.50, 0.50, -381.01 + 300, -222.01 + 300 )
	ATE47:setRFTMaterial( LUI.UIImage.GetCachedMaterial( @"hash_2D79DB5C45AD6024" ) )
	ATE47:setShaderVector( 0, 34, 6, 0, 0 )
	ATE47:setShaderVector( 1, 80, 80, 0, 0 )
	ATE47:setShaderVector( 2, 0, 0.45, 0, 0 )
	ATE47.Portrait:setShaderVector( 0, 0.1, 0, 0, 0 )
	ATE47.Portrait:setImage( RegisterImage( @"ate47_cred" ) )
	self:addElement( ATE47 )
	self.ATE47 = ATE47

	local ATE47Text = LUI.UIText.new( 0.50, 0.50, 605.02, 795.02, 0.50, 0.50, -224 + 300, -190 + 300 )
	ATE47Text:setText("ATE47")
	ATE47Text:setTTF("notosans_bold")
	ATE47Text:setLetterSpacing(0.5)
	self:addElement(ATE47Text)
	self.ATE47Text = ATE47Text

	local ATE47Text_Desc = LUI.UIText.new( 0.50, 0.50, 504.30, 534.30, 0.50, 0.50, 114.75, 126.75 )
	ATE47Text_Desc:setText("(for gsc/csc/lua modding and some custom assets)")
	ATE47Text_Desc:setTTF( "default" )
	ATE47Text_Desc:setLetterSpacing(0.5)
	self:addElement(ATE47Text_Desc)
	self.ATE47Text_Desc = ATE47Text_Desc

	-- Eagle (Porject-Bo4)
	local Eagle = CoD.CreditsGuy.new( f1_arg0, f1_arg1, 0.50, 0.50, 403.27, 563.27, 0.50, 0.50, 179.99 - 10.0, 336.99 - 10.0 )
	Eagle:setRFTMaterial( LUI.UIImage.GetCachedMaterial( @"hash_2D79DB5C45AD6024" ) )
	Eagle:setShaderVector( 0, 34, 6, 0, 0 )
	Eagle:setShaderVector( 1, 80, 80, 0, 0 )
	Eagle:setShaderVector( 2, 0, 0.45, 0, 0 )
	Eagle.Portrait:setShaderVector( 0, 0.1, 0, 0, 0 )
	Eagle.Portrait:setImage( RegisterImage( @"eagle_cred" ) )
	self:addElement( Eagle )
	self.Eagle = Eagle

	local EagleText = LUI.UIText.new( 0.50, 0.50, 374.02, 564.02, 0.50, 0.50, 321.25 - 5.0, 355.25 - 5.0 )
	EagleText:setText("Project-Bo4 (Eagle)")
	EagleText:setTTF("notosans_bold")
	EagleText:setLetterSpacing(0.5)
	self:addElement(EagleText)
	self.EagleText = EagleText

	local EagleText_Desc = LUI.UIText.new( 0.50, 0.50, 310.50, 340.50, 0.50, 0.50, 356.50, 368.50 )
	EagleText_Desc:setText("(for the base client in the public github version, and some help)")
	EagleText_Desc:setTTF( "default" )
	EagleText_Desc:setLetterSpacing(0.5)
	self:addElement(EagleText_Desc)
	self.EagleText_Desc = EagleText_Desc

	-- others
	local others_many = LUI.UIText.new( 0.50, 0.50, 376.23, 406.23, 0.50, 0.50, 414.98, 444.98 )
	others_many:setText("and many others...")
	others_many:setTTF( "default" )
	others_many:setLetterSpacing(0.5)
	self:addElement(others_many)
	self.others_many = others_many

	LUI.OverrideFunction_CallOriginalSecond( self, "close", self.__onClose )
	
	if PostLoadFunc then
		PostLoadFunc( self, f1_arg1, f1_arg0 )
	end
	
	return self
end

CoD.ShieldPatchNotes_SafeAreaFront.__onClose = function ( f8_arg0 )
	f8_arg0.HeaderStripe:close()
	f8_arg0.CommonHeader:close()
	f8_arg0.TabBacking:close()

	f8_arg0.PatchNotesText:close()
	f8_arg0.InfoNotesText:close()

	f8_arg0.PatchNotesAll:close()
	f8_arg0.InfoNotesAll:close()

	f8_arg0.Duck:close()
end