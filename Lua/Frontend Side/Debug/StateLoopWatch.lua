--[[
		.\hksc.exe ".\Lua\Frontend Side\Debug\StateLoopWatch.lua" -o "C:\Program Files (x86)\Call of Duty Black Ops 4\project-bo4\internals\T8ShieldSupport\Lua\Frontend\StateLoopWatch.luac"
]]

---------------------------

CoD.ShieldInitLuaFile()

---------------------------

--[[
	TEMPORARY (2026-11-12): the Mod Manager freeze. A hang dump showed CoD.Menu.UpdatePendingElements never ending after
	an input device change (keyboard / pad), its elements' conditions asking the chat state over and over. Its while
	loop runs as long as updating elements adds elements again. This logs a pass that goes on: its round, how many
	elements, the menu and the element ids that keep coming back. Remove once the cause is found.
]]

local function Log( text )
	Engine[@"printinfo"]( 0, "^3[StateLoopWatch] " .. tostring( text ) )
end

local function NameOf( element )
	if element == nil then
		return "nil"
	end
	return tostring( element.id or element.menuName or "?" )
end

if CoD.Menu and CoD.Menu.UpdatePendingElements and CoD.Menu.UpdatePendingElements ~= CoD.ShieldStateLoopWatch then
	local updateState = CoD.Menu.updateElementState

	CoD.Menu.UpdatePendingElements = function ( menu, event )
		local round = 0
		while menu.__elementsPendingUpdateState[1] ~= nil do
			local pending = menu.__elementsPendingUpdateState
			menu.__elementsPendingUpdateState = {}
			round = round + 1

			-- a pass that should have ended long ago: what it keeps updating
			if round == 50 or round == 200 or round % 1000 == 0 then
				local counts = {}
				for _, element in ipairs( pending ) do
					local name = NameOf( element ) .. " < " .. NameOf( element.getParent and element:getParent() )
					counts[name] = ( counts[name] or 0 ) + 1
				end
				local parts = {}
				for name, count in pairs( counts ) do
					table.insert( parts, name .. " x" .. count )
					if #parts >= 12 then
						break
					end
				end
				Log( "menu " .. NameOf( menu ) .. ", event " .. tostring( event and event.name ) .. ": round " .. round .. ", " .. #pending ..
					" pending: " .. table.concat( parts, ", " ) )
			end

			for _, element in ipairs( pending ) do
				updateState( menu, element, event )
			end
		end
		if round >= 50 then
			Log( "menu " .. NameOf( menu ) .. ": done after " .. round .. " rounds" )
		end
	end
	CoD.ShieldStateLoopWatch = CoD.Menu.UpdatePendingElements
end

-- The other way it can hang: updateElementState searches the menu's pending list (FindItemInArray) on every update, and a
-- long lived menu that keeps adding elements after it loaded never empties it. Logged as it grows: 500, 1000, 2000...
if CoD.Menu and CoD.Menu.addElementToPendingUpdateStateList and CoD.Menu.addElementToPendingUpdateStateList ~= CoD.ShieldPendingWatch then
	CoD.Menu.addElementToPendingUpdateStateList = function ( menu, element )
		table.insert( menu.__elementsPendingUpdateState, element )
		local size = #menu.__elementsPendingUpdateState
		if size >= 500 and ( size == 500 or ( size % 1000 == 0 ) ) then
			Log( "menu " .. NameOf( menu ) .. " has " .. size .. " elements pending (loaded " .. tostring( menu.__loaded ) .. "), the last " ..
				NameOf( element ) .. " < " .. NameOf( element and element.getParent and element:getParent() ) )
		end
	end
	CoD.ShieldPendingWatch = CoD.Menu.addElementToPendingUpdateStateList
end
