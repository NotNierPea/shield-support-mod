--[[
		.\hksc.exe ".\Lua\Utils.Lua" -o "C:\Program Files (x86)\Call of Duty Black Ops 4\project-bo4\mods\T8ShieldSupport\Lua\Game\Utils.luac"
]]

---------------------------

CoD.ShieldInitLuaFile = function()
	if CoD.isFrontend then
		return
	end

	require( "lua/shared/luareadonlytables" )
	require( "lua/shared/lobbydata" )
	require( "x64:5127dca51df8f7c7" )
	require( "x64:785d6d26960f9bae" )
	require( "x64:675e553bec904d39" )

	require( "ui/utility/overlayutility" )

	require( "ui/uieditor/widgets/backgroundframes/menuframeingame" )
	require( "ui/uieditor/widgets/startmenu/options/startmenuoptionsbackground" )
	require( "x64:36374709588b8a15" )
	require( "ui/uieditor/widgets/director/directorquitbuttoncontainer" )
	require( "ui/uieditor/widgets/hud/console/consoleentrycontainer" )

	require( "ui/uieditor/widgets/hud/centerconsole/centerconsoleentrycontainer" )

	require( "x64:4c50f23ab4600782" )
	require( "x64:1ee862a5c760e804" )
	require( "ui/uieditor/widgets/lobby/common/fe_listsubheaderpanel" )

	require( "ui/uieditor/widgets/chat/ingame/ingamechatclient" )
	require( "ui/uieditor/widgets/chat/chatclientchatentryscrollviewcontainer" )
	require( "ui/uieditor/widgets/chat/chatclientchatentrystaticview" )
	require( "ui/uieditor/widgets/chat/chatclientfilterbutton" )
	require( "ui/uieditor/widgets/chat/chatclientinputtextbox" )
	require( "ui/uieditor/widgets/emptyfocusable" )

	require( "ui/uieditor/widgets/border" )
	require( "x64:234a25dc398a559c" )

	require( "x64:55814753ce54450b" )

	require( "ui/uieditor/widgets/loadinganimation/animationloadingwidget" )
end

CoD.ShieldInitLuaFile()

---------------------------

CoD.Shield = {}

---------------------------

--[[
	The client calls these by name when it has news for the menus (LuaScopedEvent of party.cpp, join_events.cpp,
	master.cpp and others), in a match too: a party that changes, a player who joins or switches teams. Only the menus
	of the frontend define them, and a call of one that is not there is "Attempt to call a nil value" with no stack,
	a UI error 74046 on the screen. In a match they only go to the log; a file that handles one (ChatUpdate, Chat.lua)
	puts its own in their place.
]]
local ShieldMenuEvents = {
	"ChatUpdate",
	"CheckServerStatus",
	"DownloadedModCallback",
	"ModManagerModListUpdate",
	"ModManagerModTestTable",
	"ModManagerPrecentUpdate",
	"ModManagerToastUpdate",
	"MusicManagerListUpdate",
	"OnCookbookUpdate",
	"OnPartyListReceived",
	"OnServerLobbyListReceived",
	"RuleLoadCallback",
	"RuleSaveCallback",
	"RulesListUpdate",
	"ShowServerToast"
}

for _, name in ipairs( ShieldMenuEvents ) do
	CoD.Shield[name] = function ( event_name, event_table )
		local message = type( event_table ) == "table" and event_table.message

		if type( message ) == "string" then
			CoD.EnhPrintInfo( message, "In match, " .. name )
		end
	end
end

---------------------------

CoD.EnhPrintInfo = function(PrintInfo, DebugName)
	if DebugName ~= nill then
		Engine[@"printinfo"](0, "^1LUA Debug: " .. tostring(DebugName) .. " -> " .. tostring(PrintInfo))
	elseif PrintInfo ~= nill then
		Engine[@"printinfo"](0, "^1LUA Debug: " .. tostring(PrintInfo))
	end
end

---------------------------

--[[
	A subscription to a UI model made with no function (subscribeToModel( model, nil ), also through
	linkToElementModel and subscribeToGlobalModel, which end there) is called with the rest when the model changes:
	"Attempt to call a nil value" with no stack, UI error 74046. The engine calls them (sub_143AD1010), so nothing
	tells which. Here such a subscription gets a function that does nothing, and the log says who made it.
]]
local function ElementPath( element )
	local path = {}
	local current = element

	while current ~= nil and #path < 8 do
		table.insert( path, 1, tostring( current.id ) )
		current = current.getParent and current:getParent() or nil
	end

	return table.concat( path, " > " )
end

--[[
	Who made each subscription, by its number, for the client to ask when one has lost its function (lua.cpp,
	find_dead_subscriptions): the functions of subscriptions are held weakly, and are collected with an element
	that was dropped without being closed. What the element was called is kept as words, and the element weakly,
	to say where it is if it is still there.
	The engine gives some classes of LUI their own subscribeToModel (a list has its own, not the one of
	LUI.UIElement): each class of LUI with one of its own gets the guard, with its own as the one it calls.
]]
local SubscriptionOwners = {}
local SubscriptionElements = setmetatable( {}, { __mode = "v" } )

CoD.ShieldDeadSubscription = function ( id )
	local element = SubscriptionElements[id]
	CoD.EnhPrintInfo( "subscription " .. tostring( id ) .. " made by " .. tostring( SubscriptionOwners[id] ) .. ", the element is " ..
		( element ~= nil and "still at " .. ElementPath( element ) or "gone" ), "Model subscription" )
end

-- the guards made, so a class that takes its function from a guarded one is not guarded twice
local SubscriptionGuards = setmetatable( {}, { __mode = "k" } )

local function GuardSubscriptions( class, className )
	local subscribe = class.subscribeToModel

	if type( subscribe ) ~= "function" or SubscriptionGuards[subscribe] then
		return false
	end

	local guard = function ( self, model, callback, ... )
		if callback == nil then
			CoD.EnhPrintInfo( "no function, by " .. ElementPath( self ), "Model subscription" )
			callback = function () end
		end

		local id = subscribe( self, model, callback, ... )

		if id ~= nil then
			SubscriptionOwners[id] = ElementPath( self ) .. " (" .. className .. ")"
			SubscriptionElements[id] = self
		end

		return id
	end

	SubscriptionGuards[guard] = true
	class.subscribeToModel = guard
	return true
end

if LUI then
	local guarded = {}

	-- the base first, so the classes that inherit its function are seen as guarded
	if type( LUI.UIElement ) == "table" and GuardSubscriptions( LUI.UIElement, "UIElement" ) then
		table.insert( guarded, "UIElement" )
	end

	for name, class in pairs( LUI ) do
		if type( class ) == "table" and type( name ) == "string" and GuardSubscriptions( class, name ) then
			table.insert( guarded, name )
		end
	end

	CoD.EnhPrintInfo( "subscriptions of " .. ( #guarded > 0 and table.concat( guarded, ", " ) or "no class" ) .. " are guarded", "Model subscription" )
end

CoD.GetErrorText = function(controller)
	local errortext = Engine[@"getmodelvalue"]( Engine[@"getmodel"]( DataSources.MessageDialog.getModel(controller), "message" ) )
	if errortext ~= nil then
		if type(errortext) == "xhash" then
			errortext = Engine[@"hash_4F9F1239CFD921FE"]( errortext )
		end
		return errortext
	else
		return "No Error"
	end
end