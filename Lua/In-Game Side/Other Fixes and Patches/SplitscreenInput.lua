---------------------------

if CoD.isFrontend then
	return
end

CoD.ShieldInitLuaFile()

---------------------------

--[[
	Splitscreen: the stock IsMouseOrKeyboard / IsGamepad ask the engine about the primary controller whatever controller
	they're given (Engine.LastInput_* take one, the primary when left out), so the guest's HUD showed the keyboard's
	prompts (elixirs 1234, not the D-pad) whenever player 1 played on keyboard. The same checks for the given controller.
]]
local function SplitscreenOn()
	return ShieldFuncs ~= nil and ShieldFuncs.Splitscreen ~= nil and ShieldFuncs.Splitscreen() == true
end

if SplitscreenOn() and IsMouseOrKeyboard ~= nil and IsGamepad ~= nil then
	local StockIsMouseOrKeyboard = IsMouseOrKeyboard
	local StockIsGamepad = IsGamepad

	IsMouseOrKeyboard = function ( controller )
		if controller == nil then
			return StockIsMouseOrKeyboard( controller )
		end
		local result = CoD.useMouse and Engine[@"lastinput_mouse"]( controller )
		if not result then
			result = CoD.useKeyboard and Engine[@"hash_267ACA658A43FBD"]( controller )
		end
		return result
	end

	IsGamepad = function ( controller )
		if controller == nil then
			return StockIsGamepad( controller )
		end
		return CoD.useController and Engine[@"lastinput_gamepad"]( controller )
	end
end

--[[
	The chat key on the keyboard sometimes opened the chat of the guest's controller (ChatGlobal.inGameChatActive is per
	controller, each HUD opens its own box by it): the box showed on player 2's screen and player 1's UI had no cursor,
	the mouse was captured. A pad has no chat key, so a guest's chat is the keyboard player's: handed to the primary.
]]
if SplitscreenOn() and CoD.PCWidgetUtility and CoD.PCWidgetUtility.RegisterInGameChatEventActivated and not CoD.ShieldSplitscreenChat then
	local register = CoD.PCWidgetUtility.RegisterInGameChatEventActivated
	CoD.PCWidgetUtility.RegisterInGameChatEventActivated = function ( controller, menu, element, ... )
		local result = register( controller, menu, element, ... )
		local primary = Engine[@"getprimarycontroller"]()
		if controller ~= primary and element and CoD.ChatClientUtility and CoD.ChatClientUtility.GetInGameChattingModel then
			pcall( function ()
				element:subscribeToModel( CoD.ChatClientUtility.GetInGameChattingModel( controller ), function ( model )
					if model:get() then
						model:set( false )
						CoD.ChatClientUtility.GetInGameChattingModel( primary ):set( true )
						Engine[@"printinfo"]( 0, "[shield] splitscreen: chat of controller " .. tostring( controller ) .. " handed to the keyboard player" )
					end
				end, false )
			end )
		end
		return result
	end
	CoD.ShieldSplitscreenChat = true
end

--[[
	TEMPORARY (2026-11-12): the keyboard player's mouse hovered elements away from the cursor in splitscreen. Logs each
	element a mouse event finds the cursor in (only when it changes) with its rect (getRect: the event's units), and
	every 300 ms the event's x / y with the root's rect and the screen size. Matched in the log with the client's
	"[splitscreen] mouse" lines. Remove once the mapping is fixed.
]]
local function RectText( element )
	local ok, left, top, right, bottom = pcall( function ()
		return element:getRect()
	end )
	if not ok or left == nil then
		return "?"
	end
	return string.format( "%.0f,%.0f-%.0f,%.0f", left, top, right, bottom )
end

if SplitscreenOn() and LUI.UIElement and LUI.UIElement.GetMouseEventElementIntersection and not CoD.ShieldMouseWatch then
	local intersection = LUI.UIElement.GetMouseEventElementIntersection
	local last = {}
	local lastTime = 0
	LUI.UIElement.GetMouseEventElementIntersection = function ( element, event, ... )
		local result = intersection( element, event, ... )
		if type( event ) ~= "table" or not event.rootName then
			return result
		end
		local key = tostring( event.rootName )
		local now = Engine[@"milliseconds"]()
		if now - lastTime >= 300 then
			lastTime = now
			local root = LUI.roots and LUI.roots[event.rootName]
			local width, height = Engine[@"getscreensize"]( event.controller or 0 )
			Engine[@"printinfo"]( 0, "[shield] splitscreen mouse event: " .. key .. " controller " .. tostring( event.controller ) .. " x " ..
				tostring( event.x ) .. " y " .. tostring( event.y ) .. " root " .. ( root and RectText( root ) or "?" ) .. " screen " ..
				tostring( width ) .. "x" .. tostring( height ) )
		end
		if result and result ~= false and result ~= 0 then
			local name = tostring( element.id or element.menuName or "?" )
			if last[key] ~= name then
				last[key] = name
				Engine[@"printinfo"]( 0, "[shield] splitscreen mouse: " .. key .. " controller " .. tostring( event.controller ) .. " x " ..
					tostring( event.x ) .. " y " .. tostring( event.y ) .. " in " .. name .. " " .. RectText( element ) )
			end
		end
		return result
	end
	CoD.ShieldMouseWatch = true
end
