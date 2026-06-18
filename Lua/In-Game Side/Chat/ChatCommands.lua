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
	fct = TryFovScale
})

table.insert(CoD.ChatClientUtility.ChatCommands, {
	strings = {
		  "viewmodel",
		  "view",
	},
	fct = TryFovViewmodel
})

table.insert(CoD.ChatClientUtility.ChatCommands, {
	strings = {
		  "aspect",
		  "ratio",
	},
	fct = TryFovAspectratio
})

table.insert(CoD.ChatClientUtility.ChatCommands,
{
	strings = {
		  "gunscale_x",
		  "gunx",
	},
	fct = TryGunScaleX
})

table.insert(CoD.ChatClientUtility.ChatCommands,
{
	strings = {
		  "gunscale_z",
		  "gunz",
	},
	fct = TryGunScaleZ
})

table.insert(CoD.ChatClientUtility.ChatCommands,
{
	strings = {
		  "gunscale_y",
		  "guny",	
	},
	fct = TryGunScaleY
})

table.insert(CoD.ChatClientUtility.ChatCommands,
{
	strings = {
		  "mute"
	},
	fct = TryMuteChat
})

table.insert(CoD.ChatClientUtility.ChatCommands,
{
	strings = {
		  "unmute"
	},
	fct = TryUnmuteChat
})
