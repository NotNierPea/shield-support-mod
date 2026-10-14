--[[
		.\hksc.exe ".\Lua\Cookbook.Lua" -o "C:\Program Files (x86)\Call of Duty Black Ops 4\project-bo4\mods\T8ShieldSupport\Lua\Cookbook.luac"
]]

---------------------------

CoD.ShieldInitLuaFile()

---------------------------

--[[
	Newton's Cookbook of the zombies laboratory, as Black Ops 3 had it: three recipes a day, each of one to three
	elixirs that make one better elixir. Who has what a recipe takes can make it. The game planned it and cut it:
	the book still stands in the laboratory, with a camera on it that nothing used.

	The laboratory gets a cookbook card, which opens the menu of the recipes (ShieldCookbookRecipes): the three
	of the day, what each makes and takes. The one picked opens the book (ShieldCookbook). That menu tells the
	scripts of the frontend that it is open (CookbookCamera of Support.csc turns the camera to the book), and
	leaves the middle of the screen free for the book: the elixirs of the recipe are on the left, what they make
	on the right.
	The client knows the recipes, holds the elixirs and makes the trade, see cookbook.cpp: it is asked with
	cookbook_list and cookbook_trade <1-3>, and answers with CoD.Shield.OnCookbookUpdate.
	It is drawn with the parts of the lobby browser, CoD.Shield.BrowserUI of LobbyBrowser.lua, read when a menu is made.
]]

local BookRarityNames = {
	[0] = "COMMON",
	[1] = "RARE",
	[2] = "LEGENDARY",
	[3] = "EPIC"
}

-- the colours of the rarities, where the laboratory of the game has none to give
local BookRarityColors = {
	[0] = { r = 0.75, g = 0.75, b = 0.75 },
	[1] = { r = 0.35, g = 0.75, b = 1 },
	[2] = { r = 1, g = 0.8, b = 0.25 },
	[3] = { r = 0.78, g = 0.55, b = 1 }
}

-- the colour of the menu
local BookColor = { r = 1, g = 0.8, b = 0.25 }

-- What the client told of the recipes: each with the elixir it makes and the one to three it takes, and when
-- the day of them ends (in the milliseconds of the game). selected: the recipe the book is open on, its result
-- and ingredients those of the book. message: what the client said was wrong. info: what the game knows of each
-- elixir, by its name.
local Book = {
	recipes = {},
	selected = 1,
	result = nil,
	ingredients = {},
	untilMs = 0,
	message = "",
	info = nil
}

local BookCountWords = { "one", "two", "three" }

local function RarityColor( rarity )
	local sets = CoD.ZMLaboratoryUtility and CoD.ZMLaboratoryUtility.RarityColorSets
	local set = sets and sets[rarity]

	if set ~= nil then
		return set.r, set.g, set.b
	end

	set = BookRarityColors[rarity] or BookRarityColors[0]
	return set.r, set.g, set.b
end

-- a picture the game can draw, and not one of its empty ones
local function IsPicture( image )
	return image ~= nil and image ~= "" and image ~= @"hash_0" and image ~= @"blacktransparent"
end

-- what the game knows of an elixir: its name on the menus and its pictures. nil for one it does not list.
local function ElixirInfoOf( ref )
	if Book.info == nil then
		Book.info = {}

		for _, info in pairs( CoD.CACUtility.GetUnlockableItemTable() or {} ) do
			if type( info ) == "table" and info.itemGroup == "bubblegum_consumable" and type( info.name ) == "string" then
				Book.info[info.name] = info
			end
		end
	end

	return Book.info[ref]
end

-- "zm_bgb_ctrl_z" as words, for an elixir the game gives no name
local function PrettyRef( ref )
	local words = string.gsub( string.gsub( ref, "^zm_bgb_", "" ), "_", " " )
	return ToUpper( words )
end

local function ElixirNameOf( ref )
	local info = ElixirInfoOf( ref )

	if info ~= nil and info.displayName ~= nil then
		local name = Engine[@"hash_4F9F1239CFD921FE"]( info.displayName )

		if type( name ) == "string" and string.find( name, "%S" ) ~= nil then
			return name
		end
	end

	return PrettyRef( ref )
end

-- The picture of an elixir, as the menus of the game pick it: the one of zombies, then the common one.
-- Not its large one: an elixir has that field, but nothing is drawn of it in the frontend.
local function ElixirImageOf( ref )
	local info = ElixirInfoOf( ref )

	if info == nil then
		return nil
	end

	local image = CoD.CACUtility.GetPreviewImage( Enum[@"emodes"][@"mode_zombies"], info )

	if IsPicture( image ) then
		return image
	elseif IsPicture( info.image ) then
		return info.image
	end

	return nil
end

-- an elixir as the client tells it, with what the game shows of it
local function ReadElixir( entry )
	if type( entry ) ~= "table" or type( entry.ref ) ~= "string" then
		return nil
	end

	return {
		id = entry.id,
		ref = entry.ref,
		rarity = entry.rarity or 0,
		count = entry.count or 0,
		name = ElixirNameOf( entry.ref ),
		image = ElixirImageOf( entry.ref )
	}
end

-- how many of the elixirs a recipe takes are not held
local function MissingOf( ingredients )
	local missing = 0

	for _, elixir in ipairs( ingredients ) do
		if elixir.count < 1 then
			missing = missing + 1
		end
	end

	return missing
end

-- those of the recipe the book is open on
local function MissingElixirs()
	return MissingOf( Book.ingredients )
end

-- the book is open on that recipe
local function SelectRecipe( index )
	local recipe = Book.recipes[index]

	Book.selected = index
	Book.result = recipe and recipe.result
	Book.ingredients = recipe and recipe.ingredients or {}
end

-- "two elixirs", "one elixir"
local function ElixirWords( count )
	return ( BookCountWords[count] or tostring( count ) ) .. ( count == 1 and " elixir" or " elixirs" )
end

-- The client tells the recipes: when a menu asked, and after a trade, with the one it made (1 to 3) or what was wrong.
-- A client from before there were three tells one, as result and ingredients.
CoD.Shield.OnCookbookUpdate = function ( event_name, event_table )
	if type( event_table ) ~= "table" then
		return
	end

	local list = event_table.recipes

	if type( list ) ~= "table" and type( event_table.result ) == "table" then
		list = { { result = event_table.result, ingredients = event_table.ingredients } }
	end

	Book.recipes = {}

	for _, entry in ipairs( list or {} ) do
		local recipe = { result = ReadElixir( entry.result ), ingredients = {} }

		for _, ingredient in ipairs( entry.ingredients or {} ) do
			local elixir = ReadElixir( ingredient )
			if elixir ~= nil then
				table.insert( recipe.ingredients, elixir )
			end
		end

		if recipe.result ~= nil then
			table.insert( Book.recipes, recipe )
		end
	end

	SelectRecipe( Book.selected )

	Book.untilMs = Engine[@"milliseconds"]() + ( event_table.seconds or 0 ) * 1000
	Book.message = type( event_table.error ) == "string" and event_table.error or ""

	local made = tonumber( event_table.made ) or 0

	if CoD.Shield.OnCookbookChanged then
		CoD.Shield.OnCookbookChanged( made ~= 0 and made == Book.selected )
	end

	if CoD.Shield.OnCookbookRecipesChanged then
		CoD.Shield.OnCookbookRecipesChanged()
	end
end

-- The scripts of the frontend are told what the menu does, see CookbookCamera of Support.csc: "opened" and "closed"
-- move the camera to the book and back, "models" and "made" put the bottles of the recipe in front of it, "mix"
-- sends the three of the recipe into the book.
local function TellCookbookCamera( controller, status )
	Engine[@"sendclientscriptnotify"]( controller, "shield_cookbook" .. Engine[@"getlocalclientnum"]( controller ), {
		status = status,
		controller = controller,
		-- of the elixir the recipe makes: the scripts give its bottle the glow of that rarity
		rarity = Book.result and Book.result.rarity or 0
	} )
end

-- The bottles of the recipe, the models of the game: the scripts read which they are from models of the UI,
-- the three the recipe takes and then the one they make. made: that one was just made, and comes up turning.
local function TellCookbookBottles( controller, made )
	local root = Engine[@"getmodelforcontroller"]( controller )

	for index = 1, 4, 1 do
		local elixir = index == 4 and Book.result or Book.ingredients[index]
		local info = elixir and ElixirInfoOf( elixir.ref )

		Engine[@"createmodel"]( root, "ShieldCookbook.model" .. index ):set( info and info[@"previewmodelname"] or "" )
	end

	TellCookbookCamera( controller, made and "made" or "models" )
end

-- What of the laboratory lies under the menu and would show through the windows it leaves for the bottles.
-- All of it is there to be seen when the button of the cookbook can be clicked, so it is shown again as it was.
local LaboratoryParts = { "SpecialOffers", "LaboratoryRegularOffers", "LaboratoryBottleLabelList", "ShieldCookbookButton" }

-- how many menus of the cookbook hide it: the book opens over the menu of the recipes
local LaboratoryHidden = 0

local function ShowLaboratory( shown )
	LaboratoryHidden = shown and math.max( 0, LaboratoryHidden - 1 ) or LaboratoryHidden + 1

	local laboratory = CoD.Shield.CookbookLaboratory

	if laboratory == nil then
		return
	end

	for _, name in ipairs( LaboratoryParts ) do
		if laboratory[name] ~= nil then
			laboratory[name]:setAlpha( LaboratoryHidden == 0 and 1 or 0 )
		end
	end
end

---------------------------

--[[
	The body, 1840 by 930. Its middle stays free: the camera shows the book there.
	Left, 600 wide: the elixirs of the recipe, each a card with a window for its bottle and whether it is held. A
	recipe of fewer than three leaves the cards under its elixirs empty.
	Right, from 1240, 600 wide: a window for the bottle of the elixir they make, its name, and the button that makes it.
	The bottles are models in the laboratory, put behind the windows by the scripts: where the windows are on the
	screen is written there too, in CookbookShowBottles of Support.csc.
]]
local BOOK_WIDTH = 1840
local BOOK_HEIGHT = 930
local BOOK_TOP = 70
local BOOK_PANEL_WIDTH = 600
local BOOK_RIGHT = BOOK_WIDTH - BOOK_PANEL_WIDTH
local BOOK_LEFT_TEXT = 24
local BOOK_RIGHT_TEXT = BOOK_RIGHT + 24
local BOOK_RIGHT_END = BOOK_WIDTH - 24
local BOOK_CARDS = 3
local BOOK_CARD_TOP = 122
local BOOK_CARD_HEIGHT = 256
local BOOK_CARD_STEP = 270
local BOOK_WINDOW_LEFT = 16
local BOOK_WINDOW_RIGHT = 266
local BOOK_CARD_TEXT = BOOK_WINDOW_RIGHT + 20
local BOOK_CARD_ICON = 56
local BOOK_RESULT_WINDOW_TOP = 48
local BOOK_RESULT_WINDOW_BOTTOM = 520

-- the parts of the right panel under its window, from where the window ends
local BOOK_RESULT_TEXT = BOOK_RESULT_WINDOW_BOTTOM + 10

CoD.ShieldCookbookBody = InheritFrom( LUI.UIElement )
CoD.ShieldCookbookBody.__defaultWidth = BOOK_WIDTH
CoD.ShieldCookbookBody.__defaultHeight = BOOK_HEIGHT
CoD.ShieldCookbookBody.new = function ( f1_arg0, f1_arg1, f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	local UI = CoD.Shield.BrowserUI

	local self = LUI.UIElement.new( f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	self:setClass( CoD.ShieldCookbookBody )
	self.id = "ShieldCookbookBody"
	self.soundSet = "default"
	self.onlyChildrenFocusable = true
	self.anyChildUsesUpdateState = true

	-- everything of the body that is only closed with it
	self.Parts = {}

	-- the three elixirs are on their way into the book: nothing else is started until the client answered.
	-- trades: how many were started, for the wait of each to know whether it is still the one waited for
	local busy = false
	local trades = 0

	local function Add( element )
		self:addElement( element )
		table.insert( self.Parts, element )
		return element
	end

	-- does that after so many milliseconds
	local function After( delay, action )
		self:addElement( LUI.UITimer.newElementTimer( delay, true, action ) )
	end

	-- the thin frame of the game around something
	local function AddFrame( left, right, top, bottom, alpha )
		local frame = LUI.UIImage.new( 0, 0, left - 1, right + 1, 0, 0, top - 1, bottom + 1 )
		frame:setAlpha( alpha )
		frame:setImage( RegisterImage( @"uie_ui_menu_store_common_frame" ) )
		frame:setMaterial( LUI.UIImage.GetCachedMaterial( @"uie_nineslice_add" ) )
		frame:setShaderVector( 0, 0, 0, 0, 0 )
		frame:setupNineSliceShader( 12, 12 )
		Add( frame )
	end

	-- a dark piece of a panel: a panel is made of pieces, around the windows the bottles are seen through
	local function AddBacking( left, right, top, bottom )
		Add( UI.NewBox( left, right, top, bottom, 0, 0, 0, 0.9 ) )
	end

	-- a panel is closed with a line of the colour of the menu over it and the frame around it
	local function AddPanelEdge( left, right )
		Add( UI.NewBox( left, right, 0, 4, BookColor.r, BookColor.g, BookColor.b, 1 ) )
		AddFrame( left, right, 0, BOOK_HEIGHT, 0.12 )
	end

	-- a square for the picture of an elixir: those are square, and need no box that cuts them as the pictures of the maps do
	local function AddPicture( left, top, size )
		local image = LUI.UIImage.new( 0, 0, left, left + size, 0, 0, top, top + size )
		image:setAlpha( 0 )
		return Add( image )
	end

	-- Shows a picture, or nothing where the elixir has none. The table of items gives its pictures registered
	-- already, as userdata, where a map names its picture: registered once more, such a picture draws nothing.
	local function ShowPicture( image, name )
		image:completeAnimation()
		image:setScale( 1, 1 )

		if name ~= nil then
			image:setImage( type( name ) == "userdata" and name or RegisterImage( name ) )
			image:setAlpha( 1 )
		else
			image:setAlpha( 0 )
		end
	end

	-- left: its head, what is beside the windows, and what is between and under them
	AddBacking( 0, BOOK_PANEL_WIDTH, 0, BOOK_CARD_TOP )
	AddBacking( 0, BOOK_WINDOW_LEFT, BOOK_CARD_TOP, BOOK_HEIGHT )
	AddBacking( BOOK_WINDOW_RIGHT, BOOK_PANEL_WIDTH, BOOK_CARD_TOP, BOOK_HEIGHT )

	for index = 1, BOOK_CARDS, 1 do
		local bottom = BOOK_CARD_TOP + ( index - 1 ) * BOOK_CARD_STEP + BOOK_CARD_HEIGHT
		local under = index < BOOK_CARDS and bottom + BOOK_CARD_STEP - BOOK_CARD_HEIGHT or BOOK_HEIGHT

		AddBacking( BOOK_WINDOW_LEFT, BOOK_WINDOW_RIGHT, bottom, under )
		AddFrame( BOOK_WINDOW_LEFT, BOOK_WINDOW_RIGHT, bottom - BOOK_CARD_HEIGHT, bottom, 0.2 )
	end

	AddPanelEdge( 0, BOOK_PANEL_WIDTH )

	-- right: its head, and everything under the window
	AddBacking( BOOK_RIGHT, BOOK_WIDTH, 0, BOOK_RESULT_WINDOW_TOP )
	AddBacking( BOOK_RIGHT, BOOK_WIDTH, BOOK_RESULT_WINDOW_BOTTOM, BOOK_HEIGHT )
	AddFrame( BOOK_RIGHT + 16, BOOK_WIDTH - 16, BOOK_RESULT_WINDOW_TOP + 8, BOOK_RESULT_WINDOW_BOTTOM - 8, 0.2 )
	AddPanelEdge( BOOK_RIGHT, BOOK_WIDTH )

	---------------------------
	-- left: the three elixirs of the recipe

	local Title = Add( UI.NewText( BOOK_LEFT_TEXT, BOOK_PANEL_WIDTH - 24, 20, 30, "notosans_bold" ) )
	Title:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )
	Title:setText( "NEWTON'S COOKBOOK" )

	Add( UI.NewCaption( BOOK_LEFT_TEXT, 280, 60, "TODAY'S RECIPE" ) )

	local TimerText = Add( UI.NewCaption( 280, BOOK_PANEL_WIDTH - 24, 60, "", Enum[@"luialignment"][@"lui_alignment_right"] ) )

	local Hint = Add( UI.NewText( BOOK_LEFT_TEXT, BOOK_PANEL_WIDTH - 24, 86, 16, "ttmussels_regular" ) )
	Hint:setRGB( 0.6, 0.6, 0.6 )

	local Cards = {}

	for index = 1, BOOK_CARDS, 1 do
		local top = BOOK_CARD_TOP + ( index - 1 ) * BOOK_CARD_STEP
		local card = {}

		Add( UI.NewBox( BOOK_WINDOW_RIGHT, BOOK_PANEL_WIDTH - 16, top, top + BOOK_CARD_HEIGHT, 1, 1, 1, 0.05 ) )

		-- the bar beside the window, in the colour of the rarity
		card.Accent = Add( UI.NewBox( BOOK_WINDOW_RIGHT, BOOK_WINDOW_RIGHT + 4, top, top + BOOK_CARD_HEIGHT, 1, 1, 1, 1 ) )

		-- the picture of the elixir, small: its bottle is what the window shows
		card.Image = AddPicture( BOOK_PANEL_WIDTH - 32 - BOOK_CARD_ICON, top + BOOK_CARD_HEIGHT - 16 - BOOK_CARD_ICON, BOOK_CARD_ICON )

		card.Name = Add( UI.NewText( BOOK_CARD_TEXT, BOOK_PANEL_WIDTH - 32, top + 52, 26, "notosans_bold" ) )
		card.Name:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )

		card.Rarity = Add( UI.NewText( BOOK_CARD_TEXT, BOOK_PANEL_WIDTH - 32, top + 90, 16, "ttmussels_regular" ) )
		card.Rarity:setLetterSpacing( 2 )

		card.Have = Add( UI.NewText( BOOK_CARD_TEXT, BOOK_PANEL_WIDTH - 32 - BOOK_CARD_ICON - 12, top + 140, 20, "ttmussels_regular" ) )
		card.Have:setLetterSpacing( 1 )

		-- over a card the recipe has no elixir for, its window too
		card.Empty = Add( UI.NewBox( BOOK_WINDOW_LEFT, BOOK_PANEL_WIDTH - 16, top, top + BOOK_CARD_HEIGHT, 0, 0, 0, 0 ) )
		card.EmptyText = Add( UI.NewCaption( BOOK_WINDOW_LEFT, BOOK_PANEL_WIDTH - 16, top + BOOK_CARD_HEIGHT / 2 - 8, "", Enum[@"luialignment"][@"lui_alignment_center"] ) )

		-- the light that goes over the card and its window when its elixir goes into the book
		card.Flash = Add( UI.NewBox( BOOK_WINDOW_LEFT, BOOK_PANEL_WIDTH - 16, top, top + BOOK_CARD_HEIGHT, 1, 1, 1, 0 ) )

		table.insert( Cards, card )
	end

	---------------------------
	-- right: the elixir they make

	Add( UI.NewCaption( BOOK_RIGHT_TEXT, BOOK_RIGHT_END, 24, "IT MAKES" ) )

	-- the picture of the elixir, small in the head of the panel: its bottle is what the window shows
	local ResultImage = AddPicture( BOOK_RIGHT_END - 40, 5, 40 )

	-- the light over the new elixir
	local ResultFlash = Add( UI.NewBox( BOOK_RIGHT, BOOK_WIDTH, 4, BOOK_RESULT_TEXT + 104, 1, 1, 1, 0 ) )

	local ResultName = Add( UI.NewText( BOOK_RIGHT_TEXT, BOOK_RIGHT_END, BOOK_RESULT_TEXT, 34, "notosans_bold", Enum[@"luialignment"][@"lui_alignment_center"] ) )
	ResultName:setRGB( 1, 1, 1 )

	local ResultRarity = Add( UI.NewText( BOOK_RIGHT_TEXT, BOOK_RIGHT_END, BOOK_RESULT_TEXT + 44, 18, "ttmussels_regular", Enum[@"luialignment"][@"lui_alignment_center"] ) )
	ResultRarity:setLetterSpacing( 2 )

	local ResultHave = Add( UI.NewText( BOOK_RIGHT_TEXT, BOOK_RIGHT_END, BOOK_RESULT_TEXT + 72, 18, "ttmussels_regular", Enum[@"luialignment"][@"lui_alignment_center"] ) )
	ResultHave:setRGB( 0.6, 0.6, 0.6 )
	ResultHave:setLetterSpacing( 1 )

	Add( UI.NewBox( BOOK_RIGHT_TEXT, BOOK_RIGHT_END, BOOK_RESULT_TEXT + 118, BOOK_RESULT_TEXT + 119, 1, 1, 1, 0.1 ) )

	local Status = Add( UI.NewText( BOOK_RIGHT_TEXT, BOOK_RIGHT_END, BOOK_RESULT_TEXT + 138, 22, "notosans_bold", Enum[@"luialignment"][@"lui_alignment_center"] ) )

	local Message = Add( UI.NewText( BOOK_RIGHT_TEXT, BOOK_RIGHT_END, BOOK_RESULT_TEXT + 174, 18, "ttmussels_regular", Enum[@"luialignment"][@"lui_alignment_center"] ) )
	Message:setRGB( 1, 0.5, 0.35 )

	---------------------------
	-- what the menu shows of the recipe

	local function ShowTimer()
		local left = math.max( 0, math.floor( ( Book.untilMs - Engine[@"milliseconds"]() ) / 1000 ) )

		if Book.result == nil then
			TimerText:setText( "" )
		else
			TimerText:setText( "NEW ONE IN " .. math.floor( left / 3600 ) .. "H " .. math.floor( ( left % 3600 ) / 60 ) .. "M" )
		end

		return left
	end

	local function ShowBook()
		for index, card in ipairs( Cards ) do
			local elixir = Book.ingredients[index]

			card.Flash:completeAnimation()
			card.Flash:setAlpha( 0 )

			if elixir ~= nil then
				card.Accent:setRGB( RarityColor( elixir.rarity ) )
				card.Name:setText( UI.ShortenText( elixir.name, 22 ) )
				card.Rarity:setRGB( RarityColor( elixir.rarity ) )
				card.Rarity:setText( BookRarityNames[elixir.rarity] or "" )

				if elixir.count > 0 then
					card.Have:setRGB( 0.45, 0.9, 0.45 )
					card.Have:setText( "YOU HAVE " .. elixir.count )
				else
					card.Have:setRGB( 1, 0.4, 0.3 )
					card.Have:setText( "YOU HAVE NONE" )
				end

				ShowPicture( card.Image, elixir.image )
			else
				card.Name:setText( "" )
				card.Rarity:setText( "" )
				card.Have:setText( "" )
				ShowPicture( card.Image, nil )
			end

			local empty = elixir == nil and Book.result ~= nil
			card.Empty:setAlpha( empty and 0.92 or 0 )
			card.EmptyText:setText( empty and "NOT IN THIS RECIPE" or "" )
		end

		local count = #Book.ingredients

		if Book.result == nil then
			Hint:setText( "" )
		elseif count == 1 then
			Hint:setText( "This elixir makes the one on the right." )
		else
			Hint:setText( "These " .. ( BookCountWords[count] or tostring( count ) ) .. " elixirs make the one on the right." )
		end

		ResultFlash:completeAnimation()
		ResultFlash:setAlpha( 0 )

		if Book.result ~= nil then
			local missing = MissingElixirs()

			ResultName:setText( UI.ShortenText( Book.result.name, 26 ) )
			ResultRarity:setRGB( RarityColor( Book.result.rarity ) )
			ResultRarity:setText( BookRarityNames[Book.result.rarity] or "" )
			ResultHave:setText( "YOU HAVE " .. Book.result.count )
			ShowPicture( ResultImage, Book.result.image )

			if missing == 0 then
				Status:setRGB( 0.45, 0.9, 0.45 )
				Status:setText( "You have everything it takes." )
			elseif count == 1 then
				Status:setRGB( 0.7, 0.7, 0.7 )
				Status:setText( "You are missing the elixir it takes." )
			else
				Status:setRGB( 0.7, 0.7, 0.7 )
				Status:setText( "You are missing " .. ( BookCountWords[missing] or tostring( missing ) ) .. " of the " .. ( BookCountWords[count] or tostring( count ) ) .. "." )
			end
		else
			ResultName:setText( "" )
			ResultRarity:setText( "" )
			ResultHave:setText( "" )
			ShowPicture( ResultImage, nil )

			Status:setRGB( 0.7, 0.7, 0.7 )
			Status:setText( "Asking for the recipes of today..." )
		end

		Message:setText( Book.message )
		ShowTimer()

		-- The button is dim and takes no focus while the recipe can't be made: no light goes over it then.
		-- It is made after this function: it is looked up when the function runs.
		local button = self.MakeButton

		if button ~= nil then
			if Book.result ~= nil and MissingElixirs() == 0 and not busy then
				button:setAlpha( 1 )
				button:makeFocusableWithoutResettingNavigation( f1_arg1 )
			else
				button:setAlpha( 0.3 )
				button:makeNotFocusable( f1_arg1 )
			end
		end
	end

	---------------------------
	-- the little show of a trade

	-- the elixirs go into the book one after the other: a light over each card, and its picture shrinks away
	local function PlayIngredients()
		for index = 1, #Book.ingredients, 1 do
			local card = Cards[index]

			After( 1 + ( index - 1 ) * 220, function ()
				PlaySoundAlias( "uin_paint_image_flip_toggle" )

				card.Flash:completeAnimation()
				card.Flash:setAlpha( 0.5 )
				card.Flash:beginAnimation( 360 )
				card.Flash:setAlpha( 0 )

				card.Image:completeAnimation()
				card.Image:beginAnimation( 360 )
				card.Image:setScale( 0.4, 0.4 )
				card.Image:setAlpha( 0 )
			end )
		end

		-- what they make goes dark until it is made
		ResultImage:completeAnimation()
		ResultImage:beginAnimation( 600 )
		ResultImage:setAlpha( 0.12 )
	end

	-- the new elixir comes up out of a light
	local function PlayResult()
		Engine[@"playsound"]( "uin_map_vote" )

		ResultFlash:completeAnimation()
		ResultFlash:setAlpha( 0.6 )
		ResultFlash:beginAnimation( 700 )
		ResultFlash:setAlpha( 0 )

		ResultImage:completeAnimation()
		ResultImage:setScale( 0.5, 0.5 )
		ResultImage:setAlpha( 0 )
		ResultImage:beginAnimation( 420 )
		ResultImage:setScale( 1, 1 )
		ResultImage:setAlpha( 1 )
	end

	---------------------------
	-- the button that makes the recipe

	local MakeButton = UI.NewBrowserButton( self, f1_arg0, f1_arg1, "MAKE IT", BOOK_RIGHT_TEXT, BOOK_RIGHT_END, BOOK_HEIGHT - 84, BOOK_HEIGHT - 36 )
	self:addElement( MakeButton )

	-- the menu finds what can take the focus as parent[id]: it is kept under its id
	MakeButton.id = "MakeButton"
	self.MakeButton = MakeButton

	UI.OnBrowserButton( f1_arg0, f1_arg1, MakeButton, function ()
		if busy then
			return
		end

		if Book.result == nil or MissingElixirs() > 0 then
			PlaySoundAlias( "uin_unavailable_click" )
			Book.message = Book.result ~= nil and "You need all the elixirs it takes to make it." or ""
			ShowBook()
			return
		end

		busy = true
		trades = trades + 1
		Book.message = ""
		Message:setText( "" )

		-- not twice: it is there again when the client answered
		MakeButton:setAlpha( 0.3 )
		MakeButton:makeNotFocusable( f1_arg1 )
		Status:setRGB( 0.7, 0.7, 0.7 )
		Status:setText( "Mixing..." )

		PlayIngredients()
		TellCookbookCamera( f1_arg1, "mix" )

		-- the client is asked once the three are in the book
		After( 950, function ()
			Engine[@"exec"]( f1_arg1, "cookbook_trade " .. Book.selected )
		end )

		-- a client that never answers: the menu is not left waiting for it
		local trade = trades

		After( 5000, function ()
			if busy and trade == trades then
				busy = false
				Book.message = "The client gave no answer."
				ShowBook()
			end
		end )
	end )

	-- the client told the recipe, or what came of a trade
	CoD.Shield.OnCookbookChanged = function ( made )
		busy = false
		ShowBook()
		TellCookbookBottles( f1_arg1, made )

		if made and Book.result ~= nil then
			PlayResult()
		end
	end

	-- the time left counts down, and the recipe is asked for again when its day is over
	local asked = 0

	self:addElement( LUI.UITimer.newElementTimer( 1000, false, function ()
		local now = Engine[@"milliseconds"]()

		if ShowTimer() == 0 and Book.result ~= nil and not busy and now - asked > 5000 then
			asked = now
			Engine[@"exec"]( f1_arg1, "cookbook_list" )
		end
	end ) )

	ShowBook()

	-- and it is asked for
	Engine[@"exec"]( f1_arg1, "cookbook_list" )

	LUI.OverrideFunction_CallOriginalSecond( self, "close", self.__onClose )

	if PostLoadFunc then
		PostLoadFunc( self, f1_arg1, f1_arg0 )
	end

	return self
end

CoD.ShieldCookbookBody.__onClose = function ( f9_arg0 )
	CoD.Shield.OnCookbookChanged = nil

	for _, element in ipairs( f9_arg0.Parts ) do
		element:close()
	end
	f9_arg0.MakeButton:close()
end

---------------------------

-- the menu, opened over the laboratory. No background: the laboratory is what it shows, with the camera on the book.
CoD.ShieldCookbook = InheritFrom( CoD.Menu )
LUI.createMenu.ShieldCookbook = function ( f1_arg0, f1_arg1 )
	local self = CoD.Menu.NewForUIEditor( "ShieldCookbook", f1_arg0 )
	local f1_local1 = self

	self:setClass( CoD.ShieldCookbook )
	self.soundSet = "default"
	self:setOwner( f1_arg0 )
	self:setLeftRight( 0, 1, 0, 0 )
	self:setTopBottom( 0, 1, 0, 0 )
	self:playSound( "menu_open", f1_arg0 )
	self.anyChildUsesUpdateState = true

	-- the recipe picked in the menu of the recipes, asked for again by the body; nothing of before is said
	SelectRecipe( Book.selected )
	Book.message = ""
	self.ShieldController = f1_arg0

	TellCookbookCamera( f1_arg0, "opened" )
	ShowLaboratory( false )

	local FooterContainerFrontendRight = CoD.FooterContainer_Frontend_Right.new( f1_local1, f1_arg0, 0.5, 0.5, -960, 960, 1, 1, -48, 0 )
	self:addElement( FooterContainerFrontendRight )
	self.FooterContainerFrontendRight = FooterContainerFrontendRight

	-- the body: from 40 to 1880 of the 1920 across, from 70 to 1000 down
	local ShieldCookbookBody = CoD.ShieldCookbookBody.new( f1_local1, f1_arg0, 0.5, 0.5, -BOOK_WIDTH / 2, BOOK_WIDTH / 2, 0, 0, BOOK_TOP, BOOK_TOP + BOOK_HEIGHT )
	self:addElement( ShieldCookbookBody )
	self.ShieldCookbookBody = ShieldCookbookBody

	f1_local1:AddButtonCallbackFunction( self, f1_arg0, Enum[@"hash_3DD78803F918E9D"][@"hash_1805EFA15E9E7E5A"], nil, function ( element, menu, controller, model )
		GoBack( self, controller )
		return true
	end, function ( element, menu, controller )
		CoD.Menu.SetButtonLabel( menu, Enum[@"hash_3DD78803F918E9D"][@"hash_1805EFA15E9E7E5A"], @"hash_6A4032FB2AAB69F2", nil, nil )
		return true
	end, false )

	FooterContainerFrontendRight:setModel( self.buttonModel, f1_arg0 )
	if CoD.isPC then
		FooterContainerFrontendRight.id = "FooterContainerFrontendRight"
	end

	ShieldCookbookBody.id = "ShieldCookbookBody"

	self:processEvent( {
		name = "menu_loaded",
		controller = f1_arg0
	} )

	LUI.OverrideFunction_CallOriginalSecond( self, "close", self.__onClose )

	if PostLoadFunc then
		PostLoadFunc( self, f1_arg0 )
	end

	CoD.EnhPrintInfo("Called", "Shield's Cookbook")

	return self
end

CoD.ShieldCookbook.__onClose = function ( f8_arg0 )
	TellCookbookCamera( f8_arg0.ShieldController, "closed" )
	ShowLaboratory( true )

	f8_arg0.FooterContainerFrontendRight:close()
	f8_arg0.ShieldCookbookBody:close()
end

---------------------------

--[[
	The menu of the recipes, opened from the card of the laboratory: the camera stays where it is. The three
	recipes of the day stand side by side, each a card of 420 by 640 with the elixir it makes, what it takes and
	whether all of it is held. The one clicked opens the book on it.
]]
local RECIPE_CARD_WIDTH = 420
local RECIPE_CARD_HEIGHT = 640
local RECIPE_CARD_GAP = 40
local RECIPE_PICTURE = 200
local RECIPE_ROW_TOP = 368
local RECIPE_ROW_STEP = 64
local RECIPE_ROW_ICON = 48
local RECIPES_HEAD = 96
local RECIPES_CARD_TOP = 120
local RECIPES_WIDTH = 3 * RECIPE_CARD_WIDTH + 2 * RECIPE_CARD_GAP
local RECIPES_HEIGHT = RECIPES_CARD_TOP + RECIPE_CARD_HEIGHT

-- a picture of the table of items is registered already, as userdata: registered once more, it draws nothing
local function ShowElixirPicture( image, picture )
	if picture ~= nil then
		image:setImage( type( picture ) == "userdata" and picture or RegisterImage( picture ) )
		image:setAlpha( 1 )
	else
		image:setAlpha( 0 )
	end
end

local RecipeCardFocusParts = {
	{ "Tint", function ( element, focus ) element:setAlpha( focus and 0.1 or 0 ) end },
	{ "FocusFrame", function ( element, focus ) element:setAlpha( focus and 1 or 0 ) end },
	{ "Dim", function ( element, focus ) element:setAlpha( focus and 0 or 0.25 ) end }
}

local function RecipeCardClip( focus, duration )
	return function ( self, event )
		return CoD.Shield.BrowserUI.FocusClip( RecipeCardFocusParts, focus, duration )( self, event )
	end
end

CoD.ShieldCookbookRecipeCard = InheritFrom( LUI.UIElement )
CoD.ShieldCookbookRecipeCard.__defaultWidth = RECIPE_CARD_WIDTH
CoD.ShieldCookbookRecipeCard.__defaultHeight = RECIPE_CARD_HEIGHT
CoD.ShieldCookbookRecipeCard.new = function ( f1_arg0, f1_arg1, f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	local UI = CoD.Shield.BrowserUI

	local self = LUI.UIElement.new( f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	self:setClass( CoD.ShieldCookbookRecipeCard )
	self.id = "ShieldCookbookRecipeCard"
	self.soundSet = "default"
	f1_arg0:addElementToPendingUpdateStateList( self )

	self.Parts = {}

	local function Add( element )
		self:addElement( element )
		table.insert( self.Parts, element )
		return element
	end

	local center = Enum[@"luialignment"][@"lui_alignment_center"]
	local right = Enum[@"luialignment"][@"lui_alignment_right"]

	Add( UI.NewBox( 0, RECIPE_CARD_WIDTH, 0, RECIPE_CARD_HEIGHT, 0, 0, 0, 0.88 ) )

	-- the line of the rarity of what it makes
	self.Accent = Add( UI.NewBox( 0, RECIPE_CARD_WIDTH, 0, 4, 1, 1, 1, 1 ) )

	-- a light of that rarity behind its picture
	self.Glow = Add( UI.NewBox( 0, RECIPE_CARD_WIDTH, 4, 236, 1, 1, 1, 0.06 ) )

	local pictureLeft = ( RECIPE_CARD_WIDTH - RECIPE_PICTURE ) / 2
	self.Picture = Add( LUI.UIImage.new( 0, 0, pictureLeft, pictureLeft + RECIPE_PICTURE, 0, 0, 24, 24 + RECIPE_PICTURE ) )
	self.Picture:setAlpha( 0 )

	self.Name = Add( UI.NewText( 20, RECIPE_CARD_WIDTH - 20, 248, 30, "notosans_bold", center ) )
	self.Name:setRGB( 1, 1, 1 )

	self.Rarity = Add( UI.NewText( 20, RECIPE_CARD_WIDTH - 20, 286, 16, "ttmussels_regular", center ) )
	self.Rarity:setLetterSpacing( 2 )

	Add( UI.NewBox( 24, RECIPE_CARD_WIDTH - 24, 322, 323, 1, 1, 1, 0.1 ) )

	self.Takes = Add( UI.NewCaption( 24, RECIPE_CARD_WIDTH - 24, 336, "" ) )

	-- the elixirs it takes, a row each
	self.Rows = {}

	for index = 1, 3, 1 do
		local top = RECIPE_ROW_TOP + ( index - 1 ) * RECIPE_ROW_STEP
		local row = {}

		row.Back = Add( UI.NewBox( 16, RECIPE_CARD_WIDTH - 16, top, top + RECIPE_ROW_STEP - 8, 1, 1, 1, 0.04 ) )
		row.Accent = Add( UI.NewBox( 16, 19, top, top + RECIPE_ROW_STEP - 8, 1, 1, 1, 1 ) )

		row.Icon = Add( LUI.UIImage.new( 0, 0, 28, 28 + RECIPE_ROW_ICON, 0, 0, top + 4, top + 4 + RECIPE_ROW_ICON ) )
		row.Icon:setAlpha( 0 )

		row.Name = Add( UI.NewText( 88, RECIPE_CARD_WIDTH - 120, top + 8, 20, "notosans_bold" ) )
		row.Name:setRGB( 1, 1, 1 )

		row.Rarity = Add( UI.NewText( 88, RECIPE_CARD_WIDTH - 120, top + 32, 14, "ttmussels_regular" ) )
		row.Rarity:setLetterSpacing( 1 )

		row.Have = Add( UI.NewText( RECIPE_CARD_WIDTH - 116, RECIPE_CARD_WIDTH - 30, top + 18, 18, "ttmussels_regular", right ) )
		row.Have:setLetterSpacing( 1 )

		table.insert( self.Rows, row )
	end

	Add( UI.NewBox( 24, RECIPE_CARD_WIDTH - 24, 580, 581, 1, 1, 1, 0.1 ) )

	self.Status = Add( UI.NewText( 20, RECIPE_CARD_WIDTH - 20, 598, 22, "notosans_bold", center ) )

	self.Dim = Add( UI.NewBox( 0, RECIPE_CARD_WIDTH, 0, RECIPE_CARD_HEIGHT, 0, 0, 0, 0.25 ) )
	self.Tint = Add( UI.NewBox( 0, RECIPE_CARD_WIDTH, 0, RECIPE_CARD_HEIGHT, BookColor.r, BookColor.g, BookColor.b, 0 ) )

	local Frame = LUI.UIImage.new( 0, 1, -1, 1, 0, 1, -1, 1 )
	Frame:setAlpha( 0.2 )
	Frame:setImage( RegisterImage( @"uie_ui_menu_store_common_frame" ) )
	Frame:setMaterial( LUI.UIImage.GetCachedMaterial( @"uie_nineslice_add" ) )
	Frame:setShaderVector( 0, 0, 0, 0, 0 )
	Frame:setupNineSliceShader( 12, 12 )
	Add( Frame )

	local FocusFrame = LUI.UIImage.new( 0, 1, -4, 4, 0, 1, -4, 4 )
	FocusFrame:setRGB( BookColor.r, BookColor.g, BookColor.b )
	FocusFrame:setAlpha( 0 )
	FocusFrame:setImage( RegisterImage( @"uie_ui_menu_store_focus_frame" ) )
	FocusFrame:setMaterial( LUI.UIImage.GetCachedMaterial( @"uie_nineslice_add" ) )
	FocusFrame:setShaderVector( 0, 0, 0, 0, 0 )
	FocusFrame:setupNineSliceShader( 10, 10 )
	Add( FocusFrame )
	self.FocusFrame = FocusFrame

	LUI.OverrideFunction_CallOriginalSecond( self, "close", self.__onClose )

	if PostLoadFunc then
		PostLoadFunc( self, f1_arg1, f1_arg0 )
	end

	return self
end

-- the card shows a recipe, or that the recipes are not told yet
CoD.ShieldCookbookRecipeCard.ShowRecipe = function ( self, recipe )
	local UI = CoD.Shield.BrowserUI

	if recipe == nil then
		self.Accent:setRGB( BookColor.r, BookColor.g, BookColor.b )
		self.Glow:setRGB( 1, 1, 1 )
		ShowElixirPicture( self.Picture, nil )
		self.Name:setText( "" )
		self.Rarity:setText( "" )
		self.Takes:setText( "" )

		for _, row in ipairs( self.Rows ) do
			row.Back:setAlpha( 0 )
			row.Accent:setAlpha( 0 )
			row.Icon:setAlpha( 0 )
			row.Name:setText( "" )
			row.Rarity:setText( "" )
			row.Have:setText( "" )
		end

		self.Status:setRGB( 0.7, 0.7, 0.7 )
		self.Status:setText( "Asking..." )
		return
	end

	local result = recipe.result

	self.Accent:setRGB( RarityColor( result.rarity ) )
	self.Glow:setRGB( RarityColor( result.rarity ) )
	ShowElixirPicture( self.Picture, result.image )
	self.Name:setText( UI.ShortenText( result.name, 22 ) )
	self.Rarity:setRGB( RarityColor( result.rarity ) )
	self.Rarity:setText( ( BookRarityNames[result.rarity] or "" ) .. "  -  YOU HAVE " .. result.count )
	self.Takes:setText( "IT TAKES " .. ToUpper( ElixirWords( #recipe.ingredients ) ) )

	for index, row in ipairs( self.Rows ) do
		local elixir = recipe.ingredients[index]

		if elixir ~= nil then
			row.Back:setAlpha( 0.04 )
			row.Accent:setAlpha( 1 )
			row.Accent:setRGB( RarityColor( elixir.rarity ) )
			ShowElixirPicture( row.Icon, elixir.image )
			row.Name:setText( UI.ShortenText( elixir.name, 20 ) )
			row.Rarity:setRGB( RarityColor( elixir.rarity ) )
			row.Rarity:setText( BookRarityNames[elixir.rarity] or "" )

			if elixir.count > 0 then
				row.Have:setRGB( 0.45, 0.9, 0.45 )
				row.Have:setText( "HAVE " .. elixir.count )
			else
				row.Have:setRGB( 1, 0.4, 0.3 )
				row.Have:setText( "NONE" )
			end
		else
			row.Back:setAlpha( 0 )
			row.Accent:setAlpha( 0 )
			row.Icon:setAlpha( 0 )
			row.Name:setText( "" )
			row.Rarity:setText( "" )
			row.Have:setText( "" )
		end
	end

	local missing = MissingOf( recipe.ingredients )

	if missing == 0 then
		self.Status:setRGB( 0.45, 0.9, 0.45 )
		self.Status:setText( "READY TO MAKE" )
	else
		self.Status:setRGB( 1, 0.5, 0.35 )
		self.Status:setText( "MISSING " .. missing .. " OF " .. #recipe.ingredients )
	end
end

CoD.ShieldCookbookRecipeCard.__resetProperties = function ( f7_arg0 )
	for _, part in ipairs( RecipeCardFocusParts ) do
		local element = f7_arg0[part[1]]
		element:completeAnimation()
		part[2]( element, false )
	end
end

CoD.ShieldCookbookRecipeCard.__clipsPerState = {
	DefaultState = {
		DefaultClip = RecipeCardClip( false ),
		Focus = RecipeCardClip( true ),
		GainFocus = RecipeCardClip( true, 120 ),
		LoseFocus = RecipeCardClip( false, 120 )
	}
}

CoD.ShieldCookbookRecipeCard.__onClose = function ( f10_arg0 )
	for _, element in ipairs( f10_arg0.Parts ) do
		element:close()
	end
end

-- the head of the menu, and the three cards under it
CoD.ShieldCookbookRecipesBody = InheritFrom( LUI.UIElement )
CoD.ShieldCookbookRecipesBody.__defaultWidth = RECIPES_WIDTH
CoD.ShieldCookbookRecipesBody.__defaultHeight = RECIPES_HEIGHT
CoD.ShieldCookbookRecipesBody.new = function ( f1_arg0, f1_arg1, f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	local UI = CoD.Shield.BrowserUI

	local self = LUI.UIElement.new( f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	self:setClass( CoD.ShieldCookbookRecipesBody )
	self.id = "ShieldCookbookRecipesBody"
	self.soundSet = "default"
	self.onlyChildrenFocusable = true
	self.anyChildUsesUpdateState = true

	self.Parts = {}

	local function Add( element )
		self:addElement( element )
		table.insert( self.Parts, element )
		return element
	end

	-- the head
	Add( UI.NewBox( 0, RECIPES_WIDTH, 0, RECIPES_HEAD, 0, 0, 0, 0.9 ) )
	Add( UI.NewBox( 0, RECIPES_WIDTH, 0, 4, BookColor.r, BookColor.g, BookColor.b, 1 ) )

	local Title = Add( UI.NewText( 24, RECIPES_WIDTH - 24, 16, 30, "notosans_bold" ) )
	Title:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )
	Title:setText( "NEWTON'S COOKBOOK" )

	Add( UI.NewCaption( 24, 700, 58, "TODAY'S RECIPES  -  PICK THE ELIXIR YOU WANT TO MAKE" ) )

	local TimerText = Add( UI.NewCaption( 700, RECIPES_WIDTH - 24, 58, "", Enum[@"luialignment"][@"lui_alignment_right"] ) )

	local Cards = {}

	for index = 1, 3, 1 do
		local left = ( index - 1 ) * ( RECIPE_CARD_WIDTH + RECIPE_CARD_GAP )
		local card = CoD.ShieldCookbookRecipeCard.new( f1_arg0, f1_arg1, 0, 0, left, left + RECIPE_CARD_WIDTH, 0, 0, RECIPES_CARD_TOP, RECIPES_CARD_TOP + RECIPE_CARD_HEIGHT )

		card:linkToElementModel( self, nil, false, function ( model )
			card:setModel( model, f1_arg1 )
		end )

		self:addElement( card )

		-- the menu finds what can take the focus as parent[id]: it is kept under its id
		card.id = "ShieldCookbookRecipe" .. index
		self[card.id] = card
		table.insert( Cards, card )

		UI.OnBrowserButton( f1_arg0, f1_arg1, card, function ()
			if Book.recipes[index] == nil then
				PlaySoundAlias( "uin_unavailable_click" )
				return
			end

			PlaySoundAlias( "uin_paint_image_flip_toggle" )
			SelectRecipe( index )
			OpenOverlay( f1_arg0, "ShieldCookbook", f1_arg1 )
		end )

		card:makeFocusableWithoutResettingNavigation( f1_arg1 )
	end

	self.Cards = Cards

	local function ShowTimer()
		local left = math.max( 0, math.floor( ( Book.untilMs - Engine[@"milliseconds"]() ) / 1000 ) )

		if #Book.recipes == 0 then
			TimerText:setText( "" )
		else
			TimerText:setText( "NEW ONES IN " .. math.floor( left / 3600 ) .. "H " .. math.floor( ( left % 3600 ) / 60 ) .. "M" )
		end

		return left
	end

	local function ShowRecipes()
		for index, card in ipairs( Cards ) do
			card:ShowRecipe( Book.recipes[index] )
		end

		ShowTimer()
	end

	CoD.Shield.OnCookbookRecipesChanged = ShowRecipes

	-- the time left counts down, and the recipes are asked for again when their day is over
	local asked = 0

	self:addElement( LUI.UITimer.newElementTimer( 1000, false, function ()
		local now = Engine[@"milliseconds"]()

		if ShowTimer() == 0 and #Book.recipes > 0 and now - asked > 5000 then
			asked = now
			Engine[@"exec"]( f1_arg1, "cookbook_list" )
		end
	end ) )

	ShowRecipes()
	Engine[@"exec"]( f1_arg1, "cookbook_list" )

	LUI.OverrideFunction_CallOriginalSecond( self, "close", self.__onClose )

	if PostLoadFunc then
		PostLoadFunc( self, f1_arg1, f1_arg0 )
	end

	return self
end

CoD.ShieldCookbookRecipesBody.__onClose = function ( f9_arg0 )
	if CoD.Shield.OnCookbookRecipesChanged ~= nil then
		CoD.Shield.OnCookbookRecipesChanged = nil
	end

	for _, element in ipairs( f9_arg0.Parts ) do
		element:close()
	end

	for _, card in ipairs( f9_arg0.Cards ) do
		card:close()
	end
end

-- the menu, opened over the laboratory, with the camera where it is
CoD.ShieldCookbookRecipes = InheritFrom( CoD.Menu )
LUI.createMenu.ShieldCookbookRecipes = function ( f1_arg0, f1_arg1 )
	local self = CoD.Menu.NewForUIEditor( "ShieldCookbookRecipes", f1_arg0 )
	local f1_local1 = self

	self:setClass( CoD.ShieldCookbookRecipes )
	self.soundSet = "default"
	self:setOwner( f1_arg0 )
	self:setLeftRight( 0, 1, 0, 0 )
	self:setTopBottom( 0, 1, 0, 0 )
	self:playSound( "menu_open", f1_arg0 )
	self.anyChildUsesUpdateState = true

	Book.message = ""
	ShowLaboratory( false )

	local FooterContainerFrontendRight = CoD.FooterContainer_Frontend_Right.new( f1_local1, f1_arg0, 0.5, 0.5, -960, 960, 1, 1, -48, 0 )
	self:addElement( FooterContainerFrontendRight )
	self.FooterContainerFrontendRight = FooterContainerFrontendRight

	-- the body, in the middle of the screen: from 230 to 1690 of the 1920 across, from 150 to 910 down
	local Body = CoD.ShieldCookbookRecipesBody.new( f1_local1, f1_arg0, 0.5, 0.5, -RECIPES_WIDTH / 2, RECIPES_WIDTH / 2, 0, 0, 150, 150 + RECIPES_HEIGHT )
	self:addElement( Body )
	self.ShieldCookbookRecipesBody = Body

	f1_local1:AddButtonCallbackFunction( self, f1_arg0, Enum[@"hash_3DD78803F918E9D"][@"hash_1805EFA15E9E7E5A"], nil, function ( element, menu, controller, model )
		GoBack( self, controller )
		return true
	end, function ( element, menu, controller )
		CoD.Menu.SetButtonLabel( menu, Enum[@"hash_3DD78803F918E9D"][@"hash_1805EFA15E9E7E5A"], @"hash_6A4032FB2AAB69F2", nil, nil )
		return true
	end, false )

	FooterContainerFrontendRight:setModel( self.buttonModel, f1_arg0 )
	if CoD.isPC then
		FooterContainerFrontendRight.id = "FooterContainerFrontendRight"
	end

	Body.id = "ShieldCookbookRecipesBody"

	self:processEvent( {
		name = "menu_loaded",
		controller = f1_arg0
	} )

	LUI.OverrideFunction_CallOriginalSecond( self, "close", self.__onClose )

	if PostLoadFunc then
		PostLoadFunc( self, f1_arg0 )
	end

	return self
end

CoD.ShieldCookbookRecipes.__onClose = function ( f8_arg0 )
	ShowLaboratory( true )

	f8_arg0.FooterContainerFrontendRight:close()
	f8_arg0.ShieldCookbookRecipesBody:close()
end

---------------------------

--[[
	The card of the laboratory that opens the cookbook, 360 by 270, at its right.
	It is the picture the game made to explain the cookbook it then cut, with the name on its lower end, and a line
	of words under it. In focus it lights up as the rows of the mod's menus do.
]]
local LAB_CARD_WIDTH = 360
local LAB_CARD_HEIGHT = 270
local LAB_CARD_PICTURE = 203
-- from the middle of the screen: 1360 and 660 of 1920 by 1080
local LAB_CARD_LEFT = 400
local LAB_CARD_TOP = 120

-- what of the card changes with the focus
local LabCardFocusParts = {
	{ "Tint", function ( element, focus ) element:setAlpha( focus and 0.12 or 0 ) end },
	{ "FocusFrame", function ( element, focus ) element:setAlpha( focus and 1 or 0 ) end },
	{ "Dim", function ( element, focus ) element:setAlpha( focus and 0 or 0.3 ) end }
}

-- the clip of the rows of the browser, looked up when it plays: that file may be loaded after this one
local function LabCardClip( focus, duration )
	return function ( self, event )
		return CoD.Shield.BrowserUI.FocusClip( LabCardFocusParts, focus, duration )( self, event )
	end
end

CoD.ShieldCookbookCard = InheritFrom( LUI.UIElement )
CoD.ShieldCookbookCard.__defaultWidth = LAB_CARD_WIDTH
CoD.ShieldCookbookCard.__defaultHeight = LAB_CARD_HEIGHT
CoD.ShieldCookbookCard.new = function ( f1_arg0, f1_arg1, f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	local UI = CoD.Shield.BrowserUI

	local self = LUI.UIElement.new( f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	self:setClass( CoD.ShieldCookbookCard )
	self.id = "ShieldCookbookCard"
	self.soundSet = "default"
	f1_arg0:addElementToPendingUpdateStateList( self )

	self.Parts = {}

	local function Add( element )
		self:addElement( element )
		table.insert( self.Parts, element )
		return element
	end

	Add( UI.NewBox( 0, LAB_CARD_WIDTH, 0, LAB_CARD_HEIGHT, 0, 0, 0, 0.85 ) )

	-- the picture, cut to its box, dark to its lower end where the name is written on it
	local PictureClip = LUI.UIElement.new( 0, 0, 0, LAB_CARD_WIDTH, 0, 0, 0, LAB_CARD_PICTURE )
	PictureClip:setUseStencil( true )
	Add( PictureClip )

	local Picture = LUI.UIImage.new( 0, 1, 0, 0, 0, 1, 0, 0 )
	UI.SetPreviewImage( Picture, @"ui_menu_ftue_zm_newtons_cookbook", LAB_CARD_WIDTH, LAB_CARD_PICTURE )
	PictureClip:addElement( Picture )
	self.Picture = Picture

	UI.AddBottomFade( PictureClip, LAB_CARD_PICTURE, 120 )

	-- it is a little dark until the card is in focus. Of the card, not of the box of the picture: a part that a
	-- clip changes tells its parent when it is done, and only the card counts those
	local Dim = Add( UI.NewBox( 0, LAB_CARD_WIDTH, 0, LAB_CARD_PICTURE, 0, 0, 0, 0.3 ) )
	self.Dim = Dim

	-- the colour of the menu over the card in focus
	local Tint = Add( UI.NewBox( 0, LAB_CARD_WIDTH, 0, LAB_CARD_HEIGHT, BookColor.r, BookColor.g, BookColor.b, 0 ) )
	self.Tint = Tint

	Add( UI.NewBox( 0, LAB_CARD_WIDTH, 0, 4, BookColor.r, BookColor.g, BookColor.b, 1 ) )

	Add( UI.NewCaption( 20, LAB_CARD_WIDTH - 20, LAB_CARD_PICTURE - 60, "TRADE YOUR ELIXIRS" ) )

	local Title = Add( UI.NewText( 20, LAB_CARD_WIDTH - 20, LAB_CARD_PICTURE - 42, 28, "notosans_bold" ) )
	Title:setRGB( 1, 1, 1 )
	Title:setText( "NEWTON'S COOKBOOK" )

	local Words = Add( UI.NewText( 20, LAB_CARD_WIDTH - 20, LAB_CARD_PICTURE + 12, 16, "ttmussels_regular" ) )
	Words:setRGB( 0.65, 0.65, 0.65 )
	Words:setText( "Trade your elixirs for better ones. Three new recipes every day." )

	local Frame = LUI.UIImage.new( 0, 1, -1, 1, 0, 1, -1, 1 )
	Frame:setAlpha( 0.2 )
	Frame:setImage( RegisterImage( @"uie_ui_menu_store_common_frame" ) )
	Frame:setMaterial( LUI.UIImage.GetCachedMaterial( @"uie_nineslice_add" ) )
	Frame:setShaderVector( 0, 0, 0, 0, 0 )
	Frame:setupNineSliceShader( 12, 12 )
	Add( Frame )

	-- the frame of the game around the card in focus
	local FocusFrame = LUI.UIImage.new( 0, 1, -4, 4, 0, 1, -4, 4 )
	FocusFrame:setRGB( BookColor.r, BookColor.g, BookColor.b )
	FocusFrame:setAlpha( 0 )
	FocusFrame:setImage( RegisterImage( @"uie_ui_menu_store_focus_frame" ) )
	FocusFrame:setMaterial( LUI.UIImage.GetCachedMaterial( @"uie_nineslice_add" ) )
	FocusFrame:setShaderVector( 0, 0, 0, 0, 0 )
	FocusFrame:setupNineSliceShader( 10, 10 )
	Add( FocusFrame )
	self.FocusFrame = FocusFrame

	LUI.OverrideFunction_CallOriginalSecond( self, "close", self.__onClose )

	if PostLoadFunc then
		PostLoadFunc( self, f1_arg1, f1_arg0 )
	end

	return self
end

CoD.ShieldCookbookCard.__resetProperties = function ( f7_arg0 )
	for _, part in ipairs( LabCardFocusParts ) do
		local element = f7_arg0[part[1]]
		element:completeAnimation()
		part[2]( element, false )
	end
end

CoD.ShieldCookbookCard.__clipsPerState = {
	DefaultState = {
		DefaultClip = LabCardClip( false ),
		Focus = LabCardClip( true ),
		GainFocus = LabCardClip( true, 120 ),
		LoseFocus = LabCardClip( false, 120 )
	}
}

CoD.ShieldCookbookCard.__onClose = function ( f10_arg0 )
	f10_arg0.Picture:close()
	for _, element in ipairs( f10_arg0.Parts ) do
		element:close()
	end
end

-- The card is put into the laboratory, at its right, low on the screen. It is gone while the
-- laboratory mixes, like the offers of the laboratory: the bottles come up where it stands.
local function AddCookbookButton( menu, controller )
	-- by its place from the middle of the screen, so it stays where it is on a wide one
	local card = CoD.ShieldCookbookCard.new( menu, controller, 0.5, 0.5, LAB_CARD_LEFT, LAB_CARD_LEFT + LAB_CARD_WIDTH, 0.5, 0.5, LAB_CARD_TOP, LAB_CARD_TOP + LAB_CARD_HEIGHT )

	card:linkToElementModel( menu, nil, false, function ( model )
		card:setModel( model, controller )
	end )

	menu:addElement( card )

	-- the menu finds what can take the focus as parent[id]: it is kept under its id
	card.id = "ShieldCookbookButton"
	menu.ShieldCookbookButton = card

	-- the laboratory the cookbook opens over: it hides what of it would show through its windows
	CoD.Shield.CookbookLaboratory = menu
	LaboratoryHidden = 0

	menu:AddButtonCallbackFunction( card, controller, Enum[@"luibutton"][@"lui_key_xba_pscross"], "ui_confirm", function ( element, menu, controller, model )
		PlaySoundAlias( "uin_paint_image_flip_toggle" )
		OpenOverlay( menu, "ShieldCookbookRecipes", controller )
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

	-- the card was made after the menu took stock of what can have the focus
	card:makeFocusableWithoutResettingNavigation( controller )

	-- 0 while the laboratory does not mix, see CoD.ZMLaboratoryUtility.LabAnimState
	local mixing = Engine[@"createmodel"]( Engine[@"getmodelforcontroller"]( controller ), "Laboratory.animState" )

	card:subscribeToModel( mixing, function ( model )
		local state = model:get()
		card:setAlpha( ( state == nil or state == 0 ) and 1 or 0 )
	end )

	LUI.OverrideFunction_CallOriginalSecond( menu, "close", function ( closing )
		if CoD.Shield.CookbookLaboratory == closing then
			CoD.Shield.CookbookLaboratory = nil
		end

		if closing.ShieldCookbookButton ~= nil then
			closing.ShieldCookbookButton:close()
		end
	end )
end

-- The laboratory of the game is made with the button in it. Done again whenever the overrides of the mod are:
-- the game can load the file of its laboratory after this one, or load it anew.
CoD.CookbookReload = function ()
	local create = LUI.createMenu.Laboratory

	if create == nil or create == CoD.Shield.LaboratoryWithCookbook then
		return
	end

	CoD.Shield.LaboratoryWithCookbook = function ( controller, userData )
		-- the offers of LabOffers.lua are in its lists: the utility of the laboratory is loaded by now
		if CoD.LabOffersReload then
			CoD.LabOffersReload()
		end

		local menu = create( controller, userData )
		AddCookbookButton( menu, controller )

		if CoD.LabOffersLayout then
			CoD.LabOffersLayout( menu )
		end
		return menu
	end

	LUI.createMenu.Laboratory = CoD.Shield.LaboratoryWithCookbook
end

CoD.CookbookReload()
