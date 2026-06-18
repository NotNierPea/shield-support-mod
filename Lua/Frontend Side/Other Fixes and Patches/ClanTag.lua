--[[
		.\hksc.exe ".\Lua\ClanTag.Lua" -o "C:\Program Files (x86)\Call of Duty Black Ops 4\project-bo4\mods\T8ShieldSupport\Lua\ClanTag.luac"
]]

---------------------------

CoD.ShieldInitLuaFile()

---------------------------

-- clan
CoD.PCUtility.SetupEditClanTagWithControllerModelAndCallback = function ( f330_arg0, f330_arg1, f330_arg2, f330_arg3 )
	CoD.EnhPrintInfo("Clan tag callback..")
	local f330_local0 = Engine[@"createmodel"]( Engine[@"getmodelforcontroller"]( f330_arg1 ), f330_arg3 )
	if f330_local0:get() == nil then
		f330_local0:set( "" )
	end
	CoD.PCUtility.SetupEditControlWithModel( f330_arg0, f330_arg1, f330_arg2, f330_local0, function ( f331_arg0, f331_arg1, f331_arg2 )
		if not f331_arg2.canceled and f331_arg2.name == "textbox_editdone" then
			local f331_local0 = f331_arg0:get()
			--if not Engine[@"hash_E3FC4BECF450A06"]( f330_arg1, f331_local0, Enum[@"keyboardtype"][@"keyboard_type_clan_tag"] ) then
				Engine[@"setclantag"]( f330_arg1, f331_local0 )

				CoD.EnhPrintInfo("setting clan tag to " .. f331_local0)
			--end

			--Engine[@"exec"](Engine[@"getprimarycontroller"](), "shield_clantag " .. f331_local0)
		end
		f331_arg0:set( "" )
	end )
end