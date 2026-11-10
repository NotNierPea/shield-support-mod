--[[
		.\hksc.exe ".\Lua\Frontend Side\Specialists\DraftArrows.lua" -o "C:\Program Files (x86)\Call of Duty Black Ops 4\project-bo4\internals\T8ShieldSupport\Lua\Frontend\DraftArrows.luac"
		.\hksc.exe ".\Lua\Frontend Side\Specialists\DraftArrows.lua" -o "C:\Program Files (x86)\Call of Duty Black Ops 4\project-bo4\internals\T8ShieldSupport\Lua\Game\DraftArrows.luac"
	(the same file in the frontend and in games: the character select lists are in both)
]]

---------------------------

if not LUI or not LUI.UIList or not LUI.GridLayout then
	return
end

CoD.ShieldInitLuaFile()

---------------------------

--[[
	The character select lists (the frontend's and the draft's PositionDraft_CharacterList, the pause menu's
	StartMenu_ChangeSpecialist, ChooseSpecialistMidMatch: every list of the PositionDraftCharacters data source) scroll
	when there are more characters than they show (ours: the zombies crews as specialists), with nothing telling so.
	These get an arrow above the list and one below it, a little away from it, each shown while
	there are rows that way (the grid's currentStartRow, vCount, requestedRowCount, which its scrollbars go by), updated
	whenever the grid lays itself out (updateScrollbars). Their images are the support fastfile's (the frontend hasn't
	the game's uie_ui_arrow_up / down).
]]
local LISTS = {
	PositionDraftCharacters = true,
	PositionDraftCharactersMPPromo = true
}

local function UpdateArrows( list )
	local arrows = list.shieldArrows
	if not arrows then
		return
	end
	local rows = list.requestedRowCount or 0
	local visible = list.vCount or 0
	local first = list.currentStartRow or 1
	local more = visible > 0 and rows > visible
	arrows.up:setAlpha( (more and first > 1) and 1 or 0 )
	arrows.down:setAlpha( (more and rows >= first + visible) and 1 or 0 )
end

local function Arrow( image, topAnchor, top, bottom )
	local arrow = LUI.UIImage.new( 0.5, 0.5, -18, 18, topAnchor, topAnchor, top, bottom )
	arrow:setImage( RegisterImage( image ) )
	arrow:setAlpha( 0 )
	return arrow
end

--[[
	Scrolled with the mouse, these grids jumped from character to character (the pause menu's above all): hovering an item
	at the edge scrolls the grid to it, and its layout (LUI.GridLayout.updateLayout) ends by hovering what is under the
	cursor again (CoD.FreeCursorUtility.RetriggerCursorPosition), which scrolls it again. The game's lists of 14 never
	scrolled. While one of these lays itself out the mouse reads as outside it (the layout's only use of it is that
	re-hover), and a hover of an item out of the rows shown is passed over.
]]
local function RowShown( list, row )
	local first = list.currentStartRow or 1
	return row ~= nil and row >= first and row < first + (list.vCount or 1)
end

-- the active item when its row is shown, else the first selectable item of the rows shown (none made)
local function ShownFocus( list, getItem )
	local active = list.activeWidget
	if active and active.gridInfoTable and RowShown( list, active.gridInfoTable.gridRowIndex ) then
		return active
	end
	local first = list.currentStartRow or 1
	local firstColumn = list.currentStartColumn or 1
	for row = first, first + (list.vCount or 1) - 1 do
		for column = firstColumn, firstColumn + (list.hCount or 1) - 1 do
			local item = getItem( list, row, column, false )
			if item and list:isWidgetSelectable( item ) then
				return item
			end
		end
	end
	return nil
end

local function NoLayoutHover( list )
	if list.shieldNoLayoutHover then
		return
	end
	list.shieldNoLayoutHover = true

	-- the hover itself (an item's focus: parentGrid:setActiveItem) of an item out of the rows shown scrolls the grid to it,
	-- and another comes under the cursor: with the mouse, such a hover is passed over (the wheel, keys and pad navigate
	-- by LUI.GridLayout.setActiveItem, not this, and still scroll)
	local activate = list.setActiveItem
	list.setActiveItem = function ( self, item, ... )
		if item and item.gridInfoTable and IsFreeCursorActiveAndVisible( self.controller ) then
			local rows, columns = self:getWidgetVisiblePosition( item )
			if rows ~= 0 or columns ~= 0 then
				return
			end
		end
		return activate( self, item, ... )
	end

	--[[
		An item made out of the rows shown (getItemAtPosition's create: the default focus, getFirstSelectableItem, makes the
		first one, Ajax) is placed by LUI.GridLayout.positionElementWithStart, whose rows add up with the column's sign: row 1
		of a grid scrolled down lands on a row shown, and stays until a layout. Such an item is hidden (a layout shows it
		when its row comes into view); the default focus is the active item or the first one shown.
	]]
	local getItem = list.getItemAtPosition
	list.getItemAtPosition = function ( self, row, column, create, ... )
		local existing = getItem( self, row, column, false )
		if existing or not create then
			return existing
		end
		local item = getItem( self, row, column, create, ... )
		if item and not RowShown( self, row ) then
			item:setAlpha( 0 )
		end
		return item
	end

	local defaultFocus = list.getDefaultFocus
	list.getDefaultFocus = function ( ... )
		local ok, item = pcall( ShownFocus, list, getItem )
		if ok and item then
			return item
		end
		return defaultFocus and defaultFocus( ... )
	end

	local layout = list.updateLayout
	local inside = list.IsMouseInsideElement
	list.updateLayout = function ( self, ... )
		self.shieldInLayout = true
		local ok, result = pcall( layout, self, ... )
		self.shieldInLayout = false
		if not ok then
			error( result )
		end
		return result
	end
	list.IsMouseInsideElement = function ( self, ... )
		if self.shieldInLayout then
			return false
		end
		return inside( self, ... )
	end
end

local function AddArrows( list )
	pcall( NoLayoutHover, list )
	if list.shieldArrows then
		return
	end
	local up = Arrow( @"shield_list_arrow_up", 0, -46, -10 )
	local down = Arrow( @"shield_list_arrow_down", 1, 10, 46 )
	list:addElement( up )
	list:addElement( down )
	list.shieldArrows = { up = up, down = down }

	local layout = list.updateScrollbars
	list.updateScrollbars = function ( self, ... )
		local result = layout( self, ... )
		pcall( UpdateArrows, self )
		return result
	end
	pcall( UpdateArrows, list )
end

--[[
	A list item's models (LuaUtils.CreateModelsFromTable, every ListHelper list): a value no model takes made a UI error
	that ended the game (UI Error 10020, "function expected instead of nil", loading into mp_room with the Blackout
	characters). Each value is made on its own: one that fails is logged once with its path and left out.
]]
-- (LuaUtils is a read-only table, LuaReadOnlyTables: its fields are in _originalTable, which every lookup reads)
local utils = LuaUtils and (rawget( LuaUtils, "_originalTable" ) or LuaUtils)
if utils and utils.CreateModelsFromTable and not rawget( utils, "ShieldSafeModels" ) then
	rawset( utils, "ShieldSafeModels", true )
	local logged = {}
	local function Make( model, values, path )
		for key, value in pairs( values ) do
			local ok, problem = pcall( function ()
				local child = model:create( key )
				if type( value ) == "table" then
					Make( child, value, path .. "." .. tostring( key ) )
				else
					child:set( value )
				end
			end )
			local where = path .. "." .. tostring( key )
			if not ok and not logged[where] then
				logged[where] = true
				local text = "model " .. where .. " (" .. type( key ) .. " key, " .. type( value ) .. " " .. tostring( value ) .. ") not made: " .. tostring( problem )
				if CoD.EnhPrintInfo then
					pcall( CoD.EnhPrintInfo, text, "Safe Models" )
				end
			end
		end
	end
	rawset( utils, "CreateModelsFromTable", function ( model, values )
		if model and type( values ) == "table" then
			Make( model, values, "models" )
		end
	end )
end

--[[
	The UI models are a fixed pool (UI_Model_AllocateNode, a 16 bit index): the character lists (PositionDraftCharacters)
	make a whole class model for every character (CACUtility.GetCustomClassModel into PositionDraftCharacters.<n>.classModel),
	and with the Blackout characters (69 MP characters) a match ran out: every model after failed (UI Error 10020 /
	74646 loading into mp_room). Characters past the game's 17 (ours) get no class model there.
]]
local FIRST_OURS = 17
local function InstallClassModels()
	local utility = CoD.PlayerRoleUtility
	if not utility or not utility.GetPlayerRolesListHelper or utility.ShieldClassModels == utility.GetPlayerRolesListHelper then
		return
	end
	local helper = utility.GetPlayerRolesListHelper
	utility.GetPlayerRolesListHelper = function ( list, controller, mode, filter, ... )
		local ours = filter
		if filter then
			ours = function ( a, b, c, characterIndex, ... )
				local cac = CoD.CACUtility
				if not characterIndex or characterIndex < FIRST_OURS or not cac or not cac.GetCustomClassModel then
					return filter( a, b, c, characterIndex, ... )
				end
				local make = cac.GetCustomClassModel
				cac.GetCustomClassModel = function () end
				local ok, result = pcall( filter, a, b, c, characterIndex, ... )
				cac.GetCustomClassModel = make
				if not ok then
					error( result )
				end
				return result
			end
		end
		return helper( list, controller, mode, ours, ... )
	end
	utility.ShieldClassModels = utility.GetPlayerRolesListHelper
end
pcall( InstallClassModels )
-- (the player role utility may be read after this file)
if not CoD.ShieldClassModelsRequire then
	CoD.ShieldClassModelsRequire = true
	local GameRequire = require
	require = function ( ... )
		local result = GameRequire( ... )
		pcall( InstallClassModels )
		return result
	end
end

if LUI.UIList.ShieldArrows == nil or LUI.UIList.ShieldArrows ~= LUI.UIList.setDataSource then
	local GameSetDataSource = LUI.UIList.setDataSource or LUI.GridLayout.setDataSource
	LUI.UIList.setDataSource = function ( self, name, ... )
		local result = GameSetDataSource( self, name, ... )
		if name and LISTS[name] then
			pcall( AddArrows, self )
		end
		return result
	end
	LUI.UIList.ShieldArrows = LUI.UIList.setDataSource
end
