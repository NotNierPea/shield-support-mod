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

CoD.EnhPrintInfo = function(PrintInfo, DebugName)
	if DebugName ~= nill then
		Engine[@"printinfo"](0, "^1LUA Debug: " .. tostring(DebugName) .. " -> " .. tostring(PrintInfo))
	elseif PrintInfo ~= nill then
		Engine[@"printinfo"](0, "^1LUA Debug: " .. tostring(PrintInfo))
	end
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