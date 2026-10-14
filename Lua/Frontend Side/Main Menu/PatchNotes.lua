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

---------------------------

-- What the menu says: change it here, the cards lay themselves out. A line may have colours in it (^3).
local PatchNotes = {
	"Added support for custom camos",
	"Improved viewmodel fov, no needing to move the gun around anymore, with aspect ratio support (/viewmodel (fov) in chat, /ratio (amount) in chat, moving the gun xyz around still exists)",
	"Added an option to make fov not affect ADS (kinda works)",
	"Added an option to mute the chat in online (/mute or /unmute in chat)",
	"Added a timescale command",
	"Some other stuff added/fixed"
}

local InfoNotes = {
	"You can find Mods in the Discord Server, or from Featured Mods in Main Menu",
	"Voice Chat is not supported yet",
	"Having NAT Type: Open, will fix some errors when joining lobbies",
	"To open Console, Press '~'",
	"To Unlock All, Press Shield Options on the far left",
	"To View Client's Logs, you can find it in BO4's Files called 'project-bo4.log'"
}

local Credits = {
	{ name = "peawhatever", role = "Lua and GSC of the support mod, some C++, and hosting the online server", image = @"peawhatever_cred" },
	{ name = "Wanted", role = "Hooks and patches in C++", image = @"wanted_cred" },
	{ name = "ATE47", role = "GSC, CSC and Lua modding, and some custom assets", image = @"ate47_cred" },
	{ name = "Project-Bo4", role = "By Eagle: the base client in the public GitHub version, and some help", image = @"eagle_cred" }
}

-- the links: what the button says, the command of the client that opens it, and the address shown under it
local Links = {
	{ id = "OpenDocsButton", label = "SHIELD DOCS", command = "docs", address = "shield-client.gitbook.io" },
	{ id = "OpenDiscordButton", label = "DISCORD SERVER", command = "discord", address = "discord.gg/AXECAzJJGU" }
}

---------------------------

--[[
	The body, 1744 by 850, in the middle of the screen from 140 down.
	Left, 860 wide: the patch notes over the info. Right, from 884: the credits over the links.
	Everything is placed by its place in the body.
]]
local BODY_LEFT = -872
local BODY_TOP = 140
local BODY_BOTTOM = 850
local COLUMN_WIDTH = 860
local RIGHT_COLUMN = 884
local CARD_PADDING = 28

local NOTES_BOTTOM = 430
local CREDITS_BOTTOM = 660
local CARD_GAP = 24

-- a line of the notes: its letters, and the room between two notes. NOTE_LINE and NOTE_CHARS are only
-- for a game that does not tell how high a note is: then it is guessed from how many letters it has
local NOTE_SIZE = 20
local NOTE_GAP = 14
local NOTE_LINE = 25
local NOTE_CHARS = 90

local CardColors = {
	notes = { r = 0.45, g = 0.9, b = 0.45 },
	info = { r = 0.35, g = 0.75, b = 1 },
	credits = { r = 1, g = 0.8, b = 0.25 },
	links = { r = 1, g = 0.38, b = 0.28 }
}

local function NewText( left, right, top, size, font, alignment )
	local text = LUI.UIText.new( 0.5, 0.5, BODY_LEFT + left, BODY_LEFT + right, 0, 0, BODY_TOP + top, BODY_TOP + top + size )
	text:setTTF( font )
	text:setAlignment( alignment or Enum[@"luialignment"][@"lui_alignment_left"] )
	text:setAlignment( Enum[@"luialignment"][@"lui_alignment_top"] )
	return text
end

-- the small grey words over a title
local function NewCaption( left, right, top, words, alignment )
	local text = NewText( left, right, top, 15, "ttmussels_regular", alignment )
	text:setRGB( 0.55, 0.55, 0.55 )
	text:setLetterSpacing( 2 )
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
local function AddCard( add, left, right, top, bottom, color, caption, title )
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

	-- a card with no title is a low one: its things come right under the small words
	if title == nil then
		return top + 52
	end

	local Title = add( NewText( left + CARD_PADDING, right - CARD_PADDING, top + 44, 34, "notosans_bold" ) )
	Title:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )
	Title:setText( title )

	add( NewBox( left + CARD_PADDING, right - CARD_PADDING, top + 94, top + 95, 1, 1, 1, 0.1 ) )

	return top + 112
end

-- the notes of a card, one under the other, each after a small square of the colour of the card
local function AddNotes( add, left, right, top, color, notes )
	local y = top

	for _, note in ipairs( notes ) do
		add( NewBox( left, left + 6, y + 9, y + 15, color.r, color.g, color.b, 1 ) )

		local Note = add( NewText( left + 20, right, y, NOTE_SIZE, "notosans_regular" ) )
		Note:setRGB( 0.86, 0.86, 0.86 )
		Note:setText( note )

		-- the game breaks a long note in lines by itself: it is asked how high that makes it
		local height = Note:getTextHeightForWidth( right - left - 20 )

		if height == nil or height <= 0 then
			height = math.ceil( string.len( note ) / NOTE_CHARS ) * NOTE_LINE
		end

		y = y + math.max( height, NOTE_SIZE ) + NOTE_GAP
	end
end

-- a button of the game with its own words, never locked
local function NewLinkButton( self, menu, controller, label, left, right, top, bottom )
	local button = CoD.DirectorSelectButtonMiniInternal.new( menu, controller, 0.5, 0.5, BODY_LEFT + left, BODY_LEFT + right, 0, 0, BODY_TOP + top, BODY_TOP + bottom )

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

	return button
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

	-- everything of the menu that is only closed with it
	self.Parts = {}

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
	CommonHeader.subtitle.StageTitle:setText("^2Shield Info")
	CommonHeader.subtitle.subtitle:setText("^3Patch Notes, Info & Credits")
	self:addElement( CommonHeader )
	self.CommonHeader = CommonHeader

	local HeaderStripe = CoD.header_container_frontend.new( f1_arg0, f1_arg1, 0, 1, 0, 0, 0, 0, 0, 42 )
	self:addElement( HeaderStripe )
	self.HeaderStripe = HeaderStripe

	---------------------------
	-- left: the patch notes over the info

	local NotesTop = AddCard( Add, 0, COLUMN_WIDTH, 0, NOTES_BOTTOM, CardColors.notes, "WHAT IS NEW", "Patch Notes" )
	AddNotes( Add, CARD_PADDING, COLUMN_WIDTH - CARD_PADDING, NotesTop, CardColors.notes, PatchNotes )

	local InfoTop = AddCard( Add, 0, COLUMN_WIDTH, NOTES_BOTTOM + CARD_GAP, BODY_BOTTOM, CardColors.info, "GOOD TO KNOW", "Shield Info" )
	AddNotes( Add, CARD_PADDING, COLUMN_WIDTH - CARD_PADDING, InfoTop, CardColors.info, InfoNotes )

	---------------------------
	-- right: the credits, two in a row

	local CreditsTop = AddCard( Add, RIGHT_COLUMN, RIGHT_COLUMN + COLUMN_WIDTH, 0, CREDITS_BOTTOM, CardColors.credits, "THE PEOPLE BEHIND SHIELD", "Credits" )

	local CELL_WIDTH = 400
	local CELL_HEIGHT = 222
	local CELL_GAP = 12
	-- the picture is 160 high, in the middle of its tile, and the words beside it start a little under its top
	local PORTRAIT_TOP = ( CELL_HEIGHT - 160 ) / 2
	local WORDS_TOP = PORTRAIT_TOP + 28

	self.Portraits = {}

	local function CellPlace( index )
		local column = ( index - 1 ) % 2
		local row = math.floor( ( index - 1 ) / 2 )
		return RIGHT_COLUMN + 24 + column * ( CELL_WIDTH + CELL_GAP ), CreditsTop - 4 + row * ( CELL_HEIGHT + 4 )
	end

	for index, credit in ipairs( Credits ) do
		local left, top = CellPlace( index )

		Add( NewBox( left, left + CELL_WIDTH, top, top + CELL_HEIGHT, 1, 1, 1, 0.04 ) )

		-- the round picture, as large as it was made for
		local Portrait = CoD.CreditsGuy.new( f1_arg0, f1_arg1, 0.5, 0.5, BODY_LEFT + left + 6, BODY_LEFT + left + 166, 0, 0, BODY_TOP + top + PORTRAIT_TOP, BODY_TOP + top + PORTRAIT_TOP + 159 )
		Portrait:setRFTMaterial( LUI.UIImage.GetCachedMaterial( @"hash_2D79DB5C45AD6024" ) )
		Portrait:setShaderVector( 0, 34, 6, 0, 0 )
		Portrait:setShaderVector( 1, 80, 80, 0, 0 )
		Portrait:setShaderVector( 2, 0, 0.45, 0, 0 )
		Portrait.Portrait:setShaderVector( 0, 0.1, 0, 0, 0 )
		Portrait.Portrait:setImage( RegisterImage( credit.image ) )
		self:addElement( Portrait )
		table.insert( self.Portraits, Portrait )

		local Name = Add( NewText( left + 182, left + CELL_WIDTH - 10, top + WORDS_TOP, 24, "notosans_bold" ) )
		Name:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )
		Name:setText( credit.name )

		Add( NewBox( left + 182, left + 222, top + WORDS_TOP + 32, top + WORDS_TOP + 34, CardColors.credits.r, CardColors.credits.g, CardColors.credits.b, 1 ) )

		local Role = Add( NewText( left + 182, left + CELL_WIDTH - 10, top + WORDS_TOP + 44, 16, "notosans_regular" ) )
		Role:setRGB( 0.62, 0.62, 0.62 )
		Role:setText( credit.role )
	end

	-- under the last row of them, over both columns
	local OthersLeft, OthersTop = CellPlace( math.ceil( #Credits / 2 ) * 2 + 1 )
	local OthersRight = OthersLeft + CELL_WIDTH * 2 + CELL_GAP

	Add( NewBox( OthersLeft, OthersRight, OthersTop, OthersTop + 80, 1, 1, 1, 0.04 ) )

	local Others = Add( NewText( OthersLeft, OthersRight, OthersTop + 29, 22, "notosans_bold", Enum[@"luialignment"][@"lui_alignment_center"] ) )
	Others:setRGB( 0.62, 0.62, 0.62 )
	Others:setText( "...and many others" )

	---------------------------
	-- under them: the links, each a button with its address under it

	local LinksTop = AddCard( Add, RIGHT_COLUMN, RIGHT_COLUMN + COLUMN_WIDTH, CREDITS_BOTTOM + CARD_GAP, BODY_BOTTOM, CardColors.links, "LINKS" )

	self.LinkButtons = {}

	for index, link in ipairs( Links ) do
		local left = RIGHT_COLUMN + 24 + ( index - 1 ) * ( CELL_WIDTH + CELL_GAP )

		local Button = NewLinkButton( self, f1_arg0, f1_arg1, link.label, left, left + CELL_WIDTH, LinksTop, LinksTop + 50 )
		self:addElement( Button )
		-- the menu finds what can take the focus as parent[id]: the id has to be the name it is kept under
		Button.id = link.id
		self[link.id] = Button
		table.insert( self.LinkButtons, Button )

		f1_arg0:AddButtonCallbackFunction( Button, f1_arg1, Enum[@"luibutton"][@"lui_key_xba_pscross"], "ui_confirm", function ( element, menu, controller, model )
			PlaySoundAlias( "uin_paint_image_flip_toggle" )
			CoD.EnhPrintInfo( link.id )

			Engine[@"exec"]( Engine[@"getprimarycontroller"](), link.command )
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

		Add( NewCaption( left, left + CELL_WIDTH, LinksTop + 62, link.address, Enum[@"luialignment"][@"lui_alignment_center"] ) )
	end

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

	for _, element in ipairs( f8_arg0.Parts ) do
		element:close()
	end
	for _, portrait in ipairs( f8_arg0.Portraits ) do
		portrait:close()
	end
	for _, button in ipairs( f8_arg0.LinkButtons ) do
		button:close()
	end
end
