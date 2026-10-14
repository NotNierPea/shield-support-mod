--[[
		.\hksc.exe ".\Lua\ChatCommands.Lua" -o "C:\Program Files (x86)\Call of Duty Black Ops 4\project-bo4\mods\T8ShieldSupport\Lua\Game\ChatCommands.luac"
]]

---------------------------

if CoD.isFrontend then
	return
end

CoD.ShieldInitLuaFile()

---------------------------

CoD.Shield.ChatUpdate = function(event_name, event_table)
	if CoD.Menu.TabTextChat ~= nil then
		CoD.Menu.TabTextChat:setText( "Channel is set to " .. Engine[@"getdvarstring"]("shield_chat_type") or "GLOBAL" )
	end
end

CoD.ChatOverride = function() 
	CoD.PCUtility.ChatClientInputTextFieldUpdatePrompt = function ( f376_arg0, f376_arg1, f376_arg2 )
		-- update shield's chat state
		Engine[@"exec"](Engine[@"getprimarycontroller"](), "update_chat")

		
		local f376_local0 = CoD.ChatClientUtility.GetInputTextModel( f376_arg2 )
		if Engine[@"hash_27272CF98D12ADE1"]( f376_arg2 ) and Engine[@"hash_189364092E497C4D"]( f376_arg2 ) then
			local f376_local1 = CoD.ChatClientUtility.GetInputChannelModel( f376_arg2 )
			local f376_local2 = f376_local1:get()
			if f376_local2 ~= nil and f376_local2 ~= "" then
				local f376_local3 = Engine[@"hash_3E09A39AE156EB71"]( f376_local2 )
				local f376_local4 = CoD.ChatClientUtility.ColorToString( CoD.ChatClientUtility.GetColorForChannelType( Engine[@"hash_5884871F4FF3ACA"]( f376_local2 ) ) )
			end
			return 
		elseif not ChatClientEnabled( f376_arg2 ) then
			Engine[@"setmodelvalue"]( f376_local0, Engine[@"hash_4F9F1239CFD921FE"]( @"hash_6CC67122F64C7D6A" ) )
			return 
		elseif not ChatClientIsAvailable( f376_arg0, f376_arg1, f376_arg2 ) then
			Engine[@"setmodelvalue"]( f376_local0, Engine[@"hash_4F9F1239CFD921FE"]( @"hash_1D6681AB0261E81B" ) )
			return 
		else
			Engine[@"setmodelvalue"]( f376_local0, Engine[@"hash_4F9F1239CFD921FE"]( @"hash_5C145B7A0B9AFC02" ) )
			Engine[@"forcenotifymodelsubscriptions"]( f376_local0 )
		end
	end
end

---------------------------

-- commands
local function TryFovScale(f34_arg0, f34_arg1, f34_arg2)
	if f34_arg1 == nil and CoD.ChatClientUtility.ChatWidget then

		return false, f34_arg2 == nil, false, @"shield/fov_wrong"
	elseif f34_arg1 then
		local FOVScaleGet = tonumber(f34_arg1)

		if FOVScaleGet ~= nil and FOVScaleGet > 0 then
			CoD.EnhPrintInfo("FOV SCALE", FOVScaleGet)
			
			Engine[@"setdvar"]( "shield_fov", FOVScaleGet)
			Engine[@"exec"](Engine[@"getprimarycontroller"](), "updateFovscale")

			return false, true, false, @"shield/fov_set"
		end
	end
	return false, true, false, @"shield/fov_wrong"
end

local function TryGunScaleX(f34_arg0, f34_arg1, f34_arg2)
	if f34_arg1 == nil and CoD.ChatClientUtility.ChatWidget then

		return false, f34_arg2 == nil, false, @"shield/gun_fov_wrong"
	elseif f34_arg1 then
		local FOVScaleGet = tonumber(f34_arg1)

		if FOVScaleGet ~= nil then
			CoD.EnhPrintInfo("GUN X", FOVScaleGet)
			
			Engine[@"setdvar"]( "cg_gun_x", FOVScaleGet)
			Engine[@"exec"](Engine[@"getprimarycontroller"](), "updateGunXYZ")

			return false, true, false, @"shield/gun_fov_set"
		end
	end
	return false, true, false, @"shield/gun_fov_wrong"
end

local function TryGunScaleY(f34_arg0, f34_arg1, f34_arg2)
	if f34_arg1 == nil and CoD.ChatClientUtility.ChatWidget then

		return false, f34_arg2 == nil, false, @"shield/gun_fov_wrong"
	elseif f34_arg1 then
		local FOVScaleGet = tonumber(f34_arg1)

		if FOVScaleGet ~= nil then
			CoD.EnhPrintInfo("GUN Y", FOVScaleGet)
			
			Engine[@"setdvar"]( "cg_gun_y", FOVScaleGet)
			Engine[@"exec"](Engine[@"getprimarycontroller"](), "updateGunXYZ")

			return false, true, false, @"shield/gun_fov_set"
		end
	end
	return false, true, false, @"shield/gun_fov_wrong"
end

local function TryGunScaleZ(f34_arg0, f34_arg1, f34_arg2)
	if f34_arg1 == nil and CoD.ChatClientUtility.ChatWidget then

		return false, f34_arg2 == nil, false, @"shield/gun_fov_wrong"
	elseif f34_arg1 then
		local FOVScaleGet = tonumber(f34_arg1)

		if FOVScaleGet ~= nil then
			CoD.EnhPrintInfo("GUN Z", FOVScaleGet)
			
			Engine[@"setdvar"]( "cg_gun_z", FOVScaleGet)
			Engine[@"exec"](Engine[@"getprimarycontroller"](), "updateGunXYZ")

			return false, true, false, @"shield/gun_fov_set"
		end
	end
	return false, true, false, @"shield/gun_fov_wrong"
end

local function TryMuteChat(f34_arg0, f34_arg1, f34_arg2)
	Engine[@"exec"](Engine[@"getprimarycontroller"](), "mute_chat")
	return false, true, false, @"shield/chat_mute"
end

local function TryUnmuteChat(f34_arg0, f34_arg1, f34_arg2)
	Engine[@"exec"](Engine[@"getprimarycontroller"](), "unmute_chat")
	return false, true, false, @"shield/chat_unmute"
end

local function TryFovViewmodel(f34_arg0, f34_arg1, f34_arg2)
	if f34_arg1 == nil and CoD.ChatClientUtility.ChatWidget then

		return false, f34_arg2 == nil, false, @"shield/viewmodel_wrong"
	elseif f34_arg1 then
		local FOVScaleGet = tonumber(f34_arg1)

		if FOVScaleGet ~= nil and FOVScaleGet > 0 then
			CoD.EnhPrintInfo("VIEWMODEL SCALE", FOVScaleGet)

			Engine[@"exec"](Engine[@"getprimarycontroller"](), "updateFovViewmodel " .. FOVScaleGet)
			return false, true, false, @"shield/viewmodel_set"
		end
	end
	return false, true, false, @"shield/viewmodel_set"
end

local function TryFovAspectratio(f34_arg0, f34_arg1, f34_arg2)
	if f34_arg1 == nil and CoD.ChatClientUtility.ChatWidget then

		return false, f34_arg2 == nil, false, @"shield/aspect_wrong"
	elseif f34_arg1 then
		local FOVScaleGet = tonumber(f34_arg1)

		if FOVScaleGet ~= nil and FOVScaleGet > 0 then
			CoD.EnhPrintInfo("ASPECT RATIO SCALE", FOVScaleGet)
			
			Engine[@"exec"](Engine[@"getprimarycontroller"](), "updateFovAspectratio " .. FOVScaleGet)
			return false, true, false, @"shield/aspect_set"
		end
	end
	return false, true, false, @"shield/aspect_set"
end

table.insert(CoD.ChatClientUtility.ChatCommands, {
	strings = {
		  "fovscale",
		  "fov",
	},
	usage = "/fov <scale>",
	help = "field of view scale",
	fct = TryFovScale
})

table.insert(CoD.ChatClientUtility.ChatCommands, {
	strings = {
		  "viewmodel",
		  "view",
	},
	usage = "/viewmodel <scale>",
	help = "viewmodel scale",
	fct = TryFovViewmodel
})

table.insert(CoD.ChatClientUtility.ChatCommands, {
	strings = {
		  "aspect",
		  "ratio",
	},
	usage = "/aspect <scale>",
	help = "aspect ratio scale",
	fct = TryFovAspectratio
})

table.insert(CoD.ChatClientUtility.ChatCommands,
{
	strings = {
		  "gunscale_x",
		  "gunx",
	},
	usage = "/gunx, /guny, /gunz <number>",
	help = "gun position",
	fct = TryGunScaleX
})

table.insert(CoD.ChatClientUtility.ChatCommands,
{
	strings = {
		  "gunscale_z",
		  "gunz",
	},
	usage = "/gunz <number>",
	help = "gun position, up and down",
	hidden = true,
	fct = TryGunScaleZ
})

table.insert(CoD.ChatClientUtility.ChatCommands,
{
	strings = {
		  "gunscale_y",
		  "guny",
	},
	usage = "/guny <number>",
	help = "gun position, left and right",
	hidden = true,
	fct = TryGunScaleY
})

table.insert(CoD.ChatClientUtility.ChatCommands,
{
	strings = {
		  "mute"
	},
	usage = "/mute, /unmute",
	help = "hide or show the chat of others",
	fct = TryMuteChat
})

table.insert(CoD.ChatClientUtility.ChatCommands,
{
	strings = {
		  "unmute"
	},
	usage = "/unmute",
	help = "show the chat of others again",
	hidden = true,
	fct = TryUnmuteChat
})

---------------------------

-- The whisper of the client, see chat.cpp. The game has /all, /r and /w for the chat channels of its servers,
-- which are gone: its three entries are given these. A command is also asked while the line is being typed
-- (typing is true then), and does nothing until the line is sent.
local function TryWhisperOff( controller, text, typing )
	if typing then
		return false, false, false
	end

	Engine[@"exec"]( Engine[@"getprimarycontroller"](), "whisper_off" )

	-- "/all hello": the line goes where the box is back to
	if text ~= nil and text ~= "" then
		Engine[@"exec"]( Engine[@"getprimarycontroller"](), "sendchatmessage " .. text )
	end

	return false, true, false, nil
end

local function TryWhisperReply( controller, text, typing )
	if typing then
		return false, false, false
	end

	if text ~= nil and text ~= "" then
		Engine[@"exec"]( Engine[@"getprimarycontroller"](), "whisper_reply " .. text )
	else
		Engine[@"exec"]( Engine[@"getprimarycontroller"](), "whisper_reply" )
	end

	return false, true, false, nil
end

-- "/w name line": one line to that player. "/w name": the box turns to that player.
local function TryWhisperName( controller, text, typing )
	if typing then
		return false, false, false
	end

	if text == nil or text == "" then
		Engine[@"exec"]( Engine[@"getprimarycontroller"](), "whisper" )
	elseif string.find( text, " " ) then
		Engine[@"exec"]( Engine[@"getprimarycontroller"](), "whisper " .. text )
	else
		Engine[@"exec"]( Engine[@"getprimarycontroller"](), "whisper_to " .. text )
	end

	return false, true, false, nil
end

for _, command in ipairs( CoD.ChatClientUtility.ChatCommands ) do
	for _, name in ipairs( command.strings ) do
		if name == "all" then
			command.fct = TryWhisperOff
			command.usage = "/all [message]"
			command.help = "stop whispering"
		elseif name == "reply" then
			command.fct = TryWhisperReply
			command.usage = "/r [message]"
			command.help = "answer the last whisper"
		elseif name == "whisper" then
			command.fct = TryWhisperName
			command.usage = "/w <name> [message]"
			command.help = "whisper to a player"
		elseif name == "team" or name == "party" then
			-- the client picks party or lobby by itself
			command.hidden = true
		end
	end
end

---------------------------

-- /help: the commands of the list with what they do, shown in the chat box to this player alone.
-- A command is listed by its "usage" and "help", one without them by its first name, one with
-- "hidden" only when it is asked for: "/help guny".
local function ShowCommandHelp( command )
	local line = "^3" .. ( command.usage or ( "/" .. command.strings[1] ) )
	if command.help then
		line = line .. "^7 - " .. command.help
	end
	CoD.PCUtility.ShowGameEvent( line )
end

local function TryHelp( controller, text, typing )
	if typing then
		return false, false, false
	end

	local asked = text and string.match( text, "(%a+)" )

	if asked then
		asked = string.lower( asked )

		for _, command in ipairs( CoD.ChatClientUtility.ChatCommands ) do
			for _, name in ipairs( command.strings ) do
				if name == asked then
					ShowCommandHelp( command )
					if #command.strings > 1 then
						CoD.PCUtility.ShowGameEvent( "^7Same as: /" .. table.concat( command.strings, ", /" ) )
					end
					return false, true, false, nil
				end
			end
		end

		CoD.PCUtility.ShowGameEvent( "^1No command is called /" .. asked .. "." )
		return false, true, false, nil
	end

	CoD.PCUtility.ShowGameEvent( "^2Chat commands:" )

	for _, command in ipairs( CoD.ChatClientUtility.ChatCommands ) do
		if not command.hidden then
			ShowCommandHelp( command )
		end
	end

	return false, true, false, nil
end

table.insert(CoD.ChatClientUtility.ChatCommands,
{
	strings = {
		  "help",
		  "commands",
		  "cmds",
		  "h"
	},
	usage = "/help [command]",
	help = "this list, or one command",
	fct = TryHelp
})
