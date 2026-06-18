--[[
		.\hksc.exe ".\Lua\MusicManager.Lua" -o "C:\Program Files (x86)\Call of Duty Black Ops 4\project-bo4\mods\T8ShieldSupport\Lua\MusicManager.luac"
]]

---------------------------

CoD.ShieldInitLuaFile()

---------------------------

-- dvars
Engine[@"exec"](Engine[@"getprimarycontroller"](), "readjson Shield_Random_Music lua music_random uint64_t 0")
Engine[@"exec"](Engine[@"getprimarycontroller"](), "readjson Shield_ZM_Music lua zm_music string none")
Engine[@"exec"](Engine[@"getprimarycontroller"](), "readjson Shield_MP_Music lua mp_music string none")
Engine[@"exec"](Engine[@"getprimarycontroller"](), "readjson Shield_WZ_Music lua wz_music string none")
Engine[@"exec"](Engine[@"getprimarycontroller"](), "readjson Shield_TR_Music lua tr_music string none")

-- vars
local shield_musics = {}

local OldLobbyMusic = ""
local OldMusicName = ""

local Shield_ZM_Music = ""
local Shield_MP_Music = ""
local Shield_WZ_Music = ""
local Shield_TR_Music = ""

local Selected_Shield_Music = ""

---------------------------

-- music hook
CoD.PlayFrontendMusic = function ( f3_arg0 )
	CoD.EnhPrintInfo("PlayFrontendMusic")

	if f3_arg0 == nil then
		f3_arg0 = "titlescreen"
		if CoD.isCampaign then
			f3_arg0 = "cp_frontend"
		elseif CoD.isMultiplayer then
			f3_arg0 = "mp_frontend"
		elseif CoD.isZombie then
			f3_arg0 = "zm_frontend"
		end
	end
	if OldMusicName == f3_arg0 then
		return 
	else
		OldMusicName = f3_arg0
		Engine[@"playmenumusic"]( f3_arg0 )
	end
end

CoD.StopFrontendMusic = function ()
	CoD.EnhPrintInfo("StopFrontendMusic")
	Engine[@"playmenumusic"]( "" )
end

CoD.ResetFrontendMusic = function ()
	CoD.EnhPrintInfo("ResetFrontendMusic")

	-- will ignore if the song doesn't exists which its custom, ours.
	Engine[@"playmenumusic"]( OldMusicName )
end

CoD.PlayFrontendMusicForLobby = function ( f4_arg0 )
	CoD.ReloadOverrides()

	CoD.EnhPrintInfo("PlayFrontendMusicForLobby")

	local music_name = nil
	local f4_local1 = LobbyData.GetLobbyMenuByID( f4_arg0 )

	local controller = Engine[@"getprimarycontroller"]()

	if f4_local1[@"mainmode"] == Enum[@"lobbymainmode"][@"lobby_mainmode_zm"] and CoD.PCKoreaUtility.ShowKorea15Plus() then
		return 
	else
		music_name = f4_local1 and f4_local1[@"menumusic"]

		CoD.EnhPrintInfo("request music..")

		local PathToMusics = '"project-bo4\\music_manager\\music\\'

		if Engine[@"getdvarint"]("Shield_Random_Music") == 1 then
			if music_name == OldLobbyMusic then
				return
			end
			
			Engine[@"exec"](Engine[@"getprimarycontroller"](), "shield_stop")
			Engine[@"playmenumusic"]( "" )

			local RandomMusicToPlay = ""

			-- use array shield_musics to access .file_path from it, then put it in randommusictoplay
			if shield_musics and #shield_musics > 0 then
				local randomIndex = math.random(1, #shield_musics)
				RandomMusicToPlay = shield_musics[randomIndex].file_path
			end

			if RandomMusicToPlay == "" then
				CoD.EnhPrintInfo("No music found in shield_musics array!")
				return
			end
			
			OldMusicName = RandomMusicToPlay
			OldLobbyMusic = music_name

			local MusicPath = PathToMusics .. RandomMusicToPlay .. '"'

			CoD.Menu.OverlayMain:addElement( LUI.UITimer.newElementTimer( 1500, true, function ()
				Engine[@"exec"](Engine[@"getprimarycontroller"](), 'shield_play ' .. MusicPath .. ' "" ' .. '1' .. ' 1' .. " 0")
			end ) )

			return
		end

		if music_name == nil then
			return
		end
		
		-- update musics
		Shield_ZM_Music = Engine[@"getdvarstring"]("Shield_ZM_Music")
		Shield_MP_Music = Engine[@"getdvarstring"]("Shield_MP_Music")
		Shield_WZ_Music = Engine[@"getdvarstring"]("Shield_WZ_Music")
		Shield_TR_Music = Engine[@"getdvarstring"]("Shield_TR_Music")

		if music_name == "lobby_zm" and Shield_ZM_Music ~= "none" then

			if OldMusicName == Shield_ZM_Music then
				return
			end

			local MusicPath = PathToMusics .. Shield_ZM_Music .. '"'

			CoD.Menu.OverlayMain:addElement( LUI.UITimer.newElementTimer( 1500, true, function ()
				local session_mode = Engine[@"CurrentSessionMode"]()

				if session_mode ~= Enum[@"emodes"][@"mode_zombies"] then
					return
				end

				Engine[@"exec"](Engine[@"getprimarycontroller"](), "shield_stop")
				Engine[@"playmenumusic"]( "" )

				Engine[@"exec"](Engine[@"getprimarycontroller"](), 'shield_play ' .. MusicPath .. ' "" ' .. '1' .. ' 1' .. " 0")
			end ) )

			Engine[@"exec"](Engine[@"getprimarycontroller"](), "shield_stop")
			Engine[@"playmenumusic"]( "" )

			OldMusicName = Shield_ZM_Music
			return
		elseif music_name == "lobby_mp" and Shield_MP_Music ~= "none" then

			if OldMusicName == Shield_MP_Music then
				return
			end

			local MusicPath = PathToMusics .. Shield_MP_Music .. '"'

			CoD.Menu.OverlayMain:addElement( LUI.UITimer.newElementTimer( 1500, true, function ()
				local session_mode = Engine[@"CurrentSessionMode"]()

				if session_mode ~= Enum[@"emodes"][@"mode_multiplayer"] then
					return
				end

				Engine[@"exec"](Engine[@"getprimarycontroller"](), "shield_stop")
				Engine[@"playmenumusic"]( "" )

				Engine[@"exec"](Engine[@"getprimarycontroller"](), 'shield_play ' .. MusicPath .. ' "" ' .. '1' .. ' 1' .. " 0")
			end ) )

			Engine[@"exec"](Engine[@"getprimarycontroller"](), "shield_stop")
			Engine[@"playmenumusic"]( "" )

			OldMusicName = Shield_MP_Music
			return
		elseif music_name == "lobby_wz" and Shield_WZ_Music ~= "none" then

			if OldMusicName == Shield_WZ_Music then
				return
			end

			local MusicPath = PathToMusics .. Shield_WZ_Music .. '"'
			
			CoD.Menu.OverlayMain:addElement( LUI.UITimer.newElementTimer( 1500, true, function ()
				local session_mode = Engine[@"CurrentSessionMode"]()

				if session_mode ~= Enum[@"emodes"][@"mode_warzone"] then
					return
				end

				Engine[@"exec"](Engine[@"getprimarycontroller"](), "shield_stop")
				Engine[@"playmenumusic"]( "" )

				Engine[@"exec"](Engine[@"getprimarycontroller"](), 'shield_play ' .. MusicPath .. ' "" ' .. '1' .. ' 1' .. " 0")
			end ) )

			Engine[@"exec"](Engine[@"getprimarycontroller"](), "shield_stop")
			Engine[@"playmenumusic"]( "" )

			OldMusicName = Shield_WZ_Music
			return
		elseif music_name == "titlescreen" and Shield_TR_Music ~= "none" then

			if OldMusicName == Shield_TR_Music then
				return
			end

			local MusicPath = PathToMusics .. Shield_TR_Music .. '"'
			
			CoD.Menu.OverlayMain:addElement( LUI.UITimer.newElementTimer( 1500, true, function ()
				local session_mode = Engine[@"CurrentSessionMode"]()

				if session_mode == Enum[@"emodes"][@"mode_warzone"] or session_mode == Enum[@"emodes"][@"mode_zombies"] or session_mode == Enum[@"emodes"][@"mode_multiplayer"] then
					return
				end

				Engine[@"exec"](Engine[@"getprimarycontroller"](), "shield_stop")
				Engine[@"playmenumusic"]( "" )

				Engine[@"exec"](Engine[@"getprimarycontroller"](), 'shield_play ' .. MusicPath .. ' "" ' .. '1' .. ' 1' .. " 0")
			end ) )

			Engine[@"exec"](Engine[@"getprimarycontroller"](), "shield_stop")
			Engine[@"playmenumusic"]( "" )

			OldMusicName = Shield_TR_Music
			return
		else
			if OldMusicName == music_name then
				return
			end

			OldMusicName = music_name
			Engine[@"playmenumusic"]( music_name )

			-- stop our music if normal one gets played..
			Engine[@"exec"](Engine[@"getprimarycontroller"](), "shield_stop")
		end
	end

	CoD.EnhPrintInfo("played music -> " .. music_name)
end

CoD.Shield.MusicManagerToastUpdate = function(event_name, event_table)
	-- Play a little sound
	Engine[@"playsound"]("uin_map_vote")

	-- Default values
	local message = event_name

	if type(event_table) == "table" and type(event_table.message) == "string" then
		message = event_table.message
	end

	-- debug
	CoD.EnhPrintInfo("Got Music Toast", message)

	-- Show the toast
	if CoD.OverlayUtility.ShowToast then
		CoD.OverlayUtility.ShowToast("Mod Manager", "Update", message, "uie_img_t7_menu_startmenu_option_audio")
	end
end

CoD.Shield.MusicManagerListUpdate = function(event_name, event_table)
    -- Clear previous data
    shield_musics = {}
    
    local musics_table = event_table.musics or {}
    
    for i, music_data in ipairs(musics_table) do
        local music_entry = {
            name = music_data.music_name or "Unknown",
            author = music_data.music_author or "Unknown", 
            length = music_data.music_length or "0:00",
            file_path = music_data.file_path or "",
            display_name = music_data.music_name or "Unknown"
        }
        
        --if music_entry.author ~= "Unknown" and music_entry.author ~= music_entry.name then
           -- music_entry.display_name = music_entry.author .. " - " .. music_entry.name
        --end
        
        table.insert(shield_musics, music_entry)
        CoD.EnhPrintInfo(string.format("Found music: %s by %s (%s)", 
            music_entry.name, music_entry.author, music_entry.length))
    end
    
    CoD.EnhPrintInfo(string.format("Loaded %d music files", #shield_musics))
    
    -- Refresh the data source if it exists
    if CoD and CoD.Menu and CoD.Menu.ActiveMusicListData then
		CoD.Menu.ActiveMusicListData:setDataSource( "ShieldActiveMusicList" )
		CoD.Menu.ActiveMusicListData:updateDataSource()
    end
end

-- load them
Engine[@"exec"](Engine[@"getprimarycontroller"](), "MM_push_musics")

---------------------------

-- active musics
DataSources.ShieldActiveMusicList = DataSourceHelpers.ListSetup("ShieldActiveMusicList", function(f3_arg0, f3_arg1)
    local InfoMusics = {}
    
    for i, music_entry in ipairs(shield_musics or {}) do
        table.insert(InfoMusics, {
            models = {
                MusicName = music_entry.display_name,
                MusicAuthor = music_entry.author,
                MusicLength = music_entry.length,
                MusicFileName = music_entry.name,
                MusicFilePath = music_entry.file_path,
                MusicIndex = i
            },
            properties = {

            }
        })
    end
    
    return InfoMusics
end, true)

-- checkbox for random
DataSources.MusicOptionsList = ListHelper_SetupDataSource( "MusicOptionsList", function ( f39_arg0 )
	local f39_local0 = {}
	local f39_local1 = function ( f40_arg0, f40_arg1, f40_arg2, f40_arg3, f40_arg4 )
		return {
			models = {
				displayText = f40_arg0,
				description = f40_arg1,
				currentValue = Engine[@"getdvarint"]("Shield_Random_Music") == 1
			},
			properties = {
				action = f40_arg3,
				actionParam = f40_arg4
			}
		}
	end
	
	local f39_local2 = function ( f41_arg0, f41_arg1, f41_arg2, f41_arg3, f41_arg4 )
		local current_dvar_val = Engine[@"getdvarint"]("Shield_Random_Music")

		local val = 0

		if current_dvar_val == 1 then
			val = 0
		else
			val = 1
		end

		Engine[@"setdvar"]("Shield_Random_Music", val)

		Engine[@"exec"](Engine[@"getprimarycontroller"](), "writejson lua music_random " .. val .. " uint64_t")

		local f41_local2 = f41_arg1:getModel( f41_arg2, "currentValue" )
		f41_local2:set( val == 1 )
	end
	
	local f39_local4 = table.insert
	local f39_local5 = f39_local0
	local f39_local6 = f39_local1
	local f39_local7 = @"shield/random_music_toggle"
	local f39_local8 = @"shield/random_music_toggle"
	f39_local4( f39_local5, f39_local6( f39_local7, f39_local8, Engine[@"getdvarint"]("Shield_Random_Music") == 1, f39_local2 ) )
	return f39_local0
end, true )

---------------------------

-- Music Widget Active One
CoD.ShieldActiveMusicRow = InheritFrom( LUI.UIElement )
CoD.ShieldActiveMusicRow.__defaultWidth = 600
CoD.ShieldActiveMusicRow.__defaultHeight = 150
CoD.ShieldActiveMusicRow.new = function ( f1_arg0, f1_arg1, f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	local self = LUI.UIElement.new( f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	self:setClass( CoD.ShieldActiveMusicRow )
	self.id = "ShieldActiveMusicRow"
	self.soundSet = "default"
	f1_arg0:addElementToPendingUpdateStateList( self )
	
	local BlackBar = LUI.UIImage.new( 0, 1, 0, 0, 0, 1, 1, 1 )
	BlackBar:setRGB( 0.78, 0.78, 0.78 )
	BlackBar:setAlpha( 0.01 )
	self:addElement( BlackBar )
	self.BlackBar = BlackBar

	local MusicIcon = LUI.UIImage.new( 0.00, 0.00, -52.00, 256.00, 0.00, 0.00, -35.00, 186.00 )
	MusicIcon:setImage(RegisterImage(@"uie_img_t7_menu_startmenu_option_audio"))
	MusicIcon:setRGB( 0.70, 0.50, 1 )
	MusicIcon:setAlpha( 1 )
	self:addElement( MusicIcon )
	self.MusicIcon = MusicIcon

	--LUI_DebugElement(self, MusicIcon, 300, "MusicIcon")
	
	local MusicName = LUI.UIText.new( 0, 0, 215, 600, 0, 0, 6.5, 30.5 )
	MusicName:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )
	MusicName:setTTF( "notosans_bold" )
	MusicName:setLetterSpacing( 1 )
	MusicName:setAlignment( Enum[@"hash_67A5123B654282D2"][@"hash_558C8A85F2048829"] )
	MusicName:setAlignment( Enum[@"hash_67A5123B654282D2"][@"hash_3F41D595A2B0EDF3"] )
	self:addElement( MusicName )
	self.MusicName = MusicName

	local MusicLength = LUI.UIText.new( 0, 0, 215, 550, 0, 0, 6.5 + 30, 30.5 + 30 )
	MusicLength:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )
	MusicLength:setTTF( "notosans_bold" )
	MusicLength:setLetterSpacing( 1 )
	MusicLength:setText("Length: Unknown")
	MusicLength:setAlignment( Enum[@"hash_67A5123B654282D2"][@"hash_558C8A85F2048829"] )
	MusicLength:setAlignment( Enum[@"hash_67A5123B654282D2"][@"hash_3F41D595A2B0EDF3"] )
	self:addElement( MusicLength )
	self.MusicLength = MusicLength

	self.MusicLength:linkToElementModel( self, "MusicLength", true, function ( model )
		local get_length = model:get()
		if get_length ~= nil then
			MusicLength:setText("Length: " .. get_length)
		end
	end)

	local MusicAuthor = LUI.UIText.new( 0, 0, 215, 550, 0, 0, 6.5 + 60, 30.5 + 60 )
	MusicAuthor:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )
	MusicAuthor:setTTF( "notosans_bold" )
	MusicAuthor:setLetterSpacing( 1 )
	MusicAuthor:setText("Author: Unknown")
	MusicAuthor:setAlignment( Enum[@"hash_67A5123B654282D2"][@"hash_558C8A85F2048829"] )
	MusicAuthor:setAlignment( Enum[@"hash_67A5123B654282D2"][@"hash_3F41D595A2B0EDF3"] )
	self:addElement( MusicAuthor )
	self.MusicAuthor = MusicAuthor

	self.MusicAuthor:linkToElementModel( self, "MusicAuthor", true, function ( model )
		local get_MusicAuthor = model:get()
		if get_MusicAuthor ~= nil then
			MusicAuthor:setText("Author: " .. get_MusicAuthor)
		end
	end)

	--LUI_DebugElement(self, MusicName, 300, "MusicName")

	local MusicUsedIn = LUI.UIText.new( 0, 0, 215, 550, 0, 0, 6.5 + 90, 30.5 + 90 )
	MusicUsedIn:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )
	MusicUsedIn:setTTF( "notosans_bold" )
	MusicUsedIn:setLetterSpacing( 1 )
	MusicUsedIn:setText("Used in: None")
	MusicUsedIn:setAlignment( Enum[@"hash_67A5123B654282D2"][@"hash_558C8A85F2048829"] )
	MusicUsedIn:setAlignment( Enum[@"hash_67A5123B654282D2"][@"hash_3F41D595A2B0EDF3"] )
	self:addElement( MusicUsedIn )
	self.MusicUsedIn = MusicUsedIn

	self.MusicUsedIn:linkToElementModel( self, "MusicFilePath", true, function ( model )
		local get_name = model:get()
		if get_name ~= nil then
			local final_name = "Used in:"
		
			-- check if used in any gamemode
			Shield_ZM_Music = Engine[@"getdvarstring"]("Shield_ZM_Music")
			Shield_MP_Music = Engine[@"getdvarstring"]("Shield_MP_Music")
			Shield_WZ_Music = Engine[@"getdvarstring"]("Shield_WZ_Music")
			Shield_TR_Music = Engine[@"getdvarstring"]("Shield_TR_Music")

			if Shield_ZM_Music == get_name then
				final_name = final_name .. " ^1(Zombies)"
			end

			if Shield_WZ_Music == get_name then
				final_name = final_name .. " ^2(Blackout)"
			end

			if Shield_MP_Music == get_name then
				final_name = final_name .. " ^4(Multiplayer)"
			end

			if Shield_TR_Music == get_name then
				final_name = final_name .. " ^8(Main Menu)"
			end

			if final_name ~= "Used in:" then
				self.MusicUsedIn:setText(final_name)
			end
		end
	end )
		
	self.MusicName:linkToElementModel( self, "MusicName", true, function ( model )
		local get_name = model:get()
		if get_name ~= nil then
			MusicName:setText("Name: ".. get_name)
			self.MusicName = MusicName
		end
	end )



	LUI.OverrideFunction_CallOriginalSecond( self, "close", self.__onClose )
	
	if PostLoadFunc then
		PostLoadFunc( self, f1_arg1, f1_arg0 )
	end
	
	return self
end

CoD.ShieldActiveMusicRow.__resetProperties = function ( f7_arg0 )
	f7_arg0.BlackBar:completeAnimation()
	f7_arg0.MusicName:completeAnimation()
	f7_arg0.MusicUsedIn:completeAnimation()
	f7_arg0.BlackBar:setRGB( 0.78, 0.78, 0.78 )
	f7_arg0.BlackBar:setAlpha( 0.01 )
	f7_arg0.MusicName:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )
	f7_arg0.MusicName:setAlpha( 1 )
	f7_arg0.MusicUsedIn:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )
	f7_arg0.MusicUsedIn:setAlpha( 1 )
	f7_arg0.MusicLength:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )
	f7_arg0.MusicLength:setAlpha( 1 )
	f7_arg0.MusicAuthor:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )
	f7_arg0.MusicAuthor:setAlpha( 1 )
end

CoD.ShieldActiveMusicRow.__clipsPerState = {
	DefaultState = {
		DefaultClip = function ( f8_arg0, f8_arg1 )
			f8_arg0:__resetProperties()
			f8_arg0:setupElementClipCounter( 2 )
			f8_arg0.BlackBar:completeAnimation()
			f8_arg0.BlackBar:setRGB( 0.71, 0.71, 0.71 )
			f8_arg0.BlackBar:setAlpha( 0.01 )
			f8_arg0.clipFinished( f8_arg0.BlackBar )
			f8_arg0.MusicName:completeAnimation()
			f8_arg0.MusicName:setAlpha( 1 )
			f8_arg0.clipFinished( f8_arg0.MusicName )
			f8_arg0.MusicUsedIn:completeAnimation()
			f8_arg0.MusicUsedIn:setAlpha( 1 )
			f8_arg0.clipFinished( f8_arg0.MusicUsedIn )
			f8_arg0.MusicLength:completeAnimation()
			f8_arg0.MusicLength:setAlpha( 1 )
			f8_arg0.clipFinished( f8_arg0.MusicLength )
			f8_arg0.MusicAuthor:completeAnimation()
			f8_arg0.MusicAuthor:setAlpha( 1 )
			f8_arg0.clipFinished( f8_arg0.MusicAuthor )
		end,
		Focus = function ( f9_arg0, f9_arg1 )
			f9_arg0:__resetProperties()
			f9_arg0:setupElementClipCounter( 5 )
			f9_arg0.BlackBar:completeAnimation()
			f9_arg0.BlackBar:setRGB( 0.82, 0.82, 0.82 )
			f9_arg0.BlackBar:setAlpha( 0.05 )
			f9_arg0.clipFinished( f9_arg0.BlackBar )
			f9_arg0.MusicName:completeAnimation()
			f9_arg0.MusicName:setRGB( 0.93, 0.93, 0 )
			f9_arg0.clipFinished( f9_arg0.MusicName )
			f9_arg0.MusicUsedIn:completeAnimation()
			f9_arg0.MusicUsedIn:setRGB( 0.93, 0.93, 0 )
			f9_arg0.clipFinished( f9_arg0.MusicUsedIn )
			f9_arg0.MusicLength:completeAnimation()
			f9_arg0.MusicLength:setRGB( 0.93, 0.93, 0 )
			f9_arg0.clipFinished( f9_arg0.MusicLength )
			f9_arg0.MusicAuthor:completeAnimation()
			f9_arg0.MusicAuthor:setRGB( 0.93, 0.93, 0 )
			f9_arg0.clipFinished( f9_arg0.MusicAuthor )
		end
	}
}

CoD.ShieldActiveMusicRow.__onClose = function ( f10_arg0 )
	f10_arg0.MusicName:close()
	f10_arg0.BlackBar:close()
	f10_arg0.MusicUsedIn:close()
	f10_arg0.MusicLength:close()
	f10_arg0.MusicAuthor:close()
end

CoD.StartMenu_Options_SimpleCheckOptionEnh = InheritFrom( LUI.UIElement )
CoD.StartMenu_Options_SimpleCheckOptionEnh.__defaultWidth = 360
CoD.StartMenu_Options_SimpleCheckOptionEnh.__defaultHeight = 60
CoD.StartMenu_Options_SimpleCheckOptionEnh.new = function ( f1_arg0, f1_arg1, f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	local self = LUI.UIElement.new( f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	self:setClass( CoD.StartMenu_Options_SimpleCheckOptionEnh )
	self.id = "StartMenu_Options_SimpleCheckOptionEnh"
	self.soundSet = "ChooseDecal"
	f1_arg0:addElementToPendingUpdateStateList( self )
	
	local Backing = LUI.UIImage.new( 0, 1, 0, 0, 0, 0, 0, 60 )
	Backing:setRGB( 0.13, 0.12, 0.12 )
	Backing:setAlpha( 0.5 )
	self:addElement( Backing )
	self.Backing = Backing
	
	local Frame = CoD.StartMenuOptionsMainFrame.new( f1_arg0, f1_arg1, 0, 1, 0, 0, 0, 0, 0, 60 )
	Frame:setRGB( 0.78, 0.74, 0.67 )
	Frame:setAlpha( 0.04 )
	self:addElement( Frame )
	self.Frame = Frame
	
	local Corner = CoD.StartMenuOptionsMainCorners.new( f1_arg0, f1_arg1, 0, 1, 0, 0, 0, 0, 0, 60 )
	self:addElement( Corner )
	self.Corner = Corner
	
	local checkboxBacking = CoD.StartMenu_frame_noBG.new( f1_arg0, f1_arg1, 0, 1, 0, 0, 0, 1, 0, 0 )
	checkboxBacking:setScale( 0.3, 0.3 )
	self:addElement( checkboxBacking )
	self.checkboxBacking = checkboxBacking
	
	local Dash = LUI.UIImage.new( 0, 0, 18.5, 42.5, 0, 0, 18, 42 )
	Dash:setScale( 1.5, 1.5 )
	Dash:setImage( RegisterImage( @"uie_ui_menu_cac_allocation_pip_full" ) )
	self:addElement( Dash )
	self.Dash = Dash
	
	local LabelText = LUI.UIText.new( 0, 0.89, 70, 70, 0.5, 0.5, -10.5, 10.5 )
	LabelText:setRGB( 0.78, 0.74, 0.67 )
	LabelText:setTTF( "ttmussels_regular" )
	LabelText:setAlignment( Enum[@"luialignment"][@"lui_alignment_left"] )
	LabelText:linkToElementModel( self, "displayText", true, function ( model )
		local f2_local0 = model:get()
		if f2_local0 ~= nil then
			LabelText:setText( Engine[@"hash_4F9F1239CFD921FE"]( f2_local0 ) )
		end
	end )
	self:addElement( LabelText )
	self.LabelText = LabelText
	
	local StartMenuframenoBG00 = CoD.StartMenu_frame_noBG.new( f1_arg0, f1_arg1, 0, 1, 0, 0, 0, 1, 0, 0 )
	self:addElement( StartMenuframenoBG00 )
	self.StartMenuframenoBG00 = StartMenuframenoBG00
	
	local Border = CoD.Border.new( f1_arg0, f1_arg1, 0, 0, 15.5, 43.5, 0, 0, 16.5, 44.5 )
	self:addElement( Border )
	self.Border = Border
	
	local BorderAdd = CoD.Border.new( f1_arg0, f1_arg1, 0, 0, 15.5, 43.5, 0, 0, 16.5, 44.5 )
	self:addElement( BorderAdd )
	self.BorderAdd = BorderAdd
	
	local Empty = LUI.UIImage.new( 0, 0, 11.5, 46.5, 0, 0, 12.5, 47.5 )
	Empty:setScale( 0.67, 0.67 )
	Empty:setImage( RegisterImage( @"uie_ui_menu_specialist_hub_selectbox_empty" ) )
	Empty:setMaterial( LUI.UIImage.GetCachedMaterial( @"ui_add" ) )
	self:addElement( Empty )
	self.Empty = Empty
	
	local DashBacking = LUI.UIImage.new( 0, 0, 17, 41, 0, 0, 18, 42 )
	DashBacking:setScale( 1.5, 1.5 )
	DashBacking:setImage( RegisterImage( @"uie_ui_menu_cac_allocation_pip_empty" ) )
	self:addElement( DashBacking )
	self.DashBacking = DashBacking
	
	local CornerDots = LUI.UIImage.new( 0, 0, 14.5, 43.5, 0, 0, 15.5, 44.5 )
	CornerDots:setAlpha( 0 )
	CornerDots:setScale( 1.5, 1.5 )
	CornerDots:setImage( RegisterImage( @"uie_ui_menu_cac_allocation_pip_dots" ) )
	self:addElement( CornerDots )
	self.CornerDots = CornerDots
	
	local Glow = LUI.UIImage.new( 0, 0.06, 8, 8, 0, 0, -6.5, 66.5 )
	Glow:setRGB( 0.88, 0.8, 0.45 )
	Glow:setAlpha( 0 )
	Glow:setImage( RegisterImage( @"uie_t7_menu_cac_glow" ) )
	Glow:setMaterial( LUI.UIImage.GetCachedMaterial( @"ui_add" ) )
	self:addElement( Glow )
	self.Glow = Glow
	
	self:mergeStateConditions( {
		{
			stateName = "Checked",
			condition = function ( menu, element, event )
				return CoD.ModelUtility.IsSelfModelValueTrue( self, f1_arg1, "currentValue" )
			end
		},
		{
			stateName = "Disabled",
			condition = function ( menu, element, event )
				return IsDisabled( element, f1_arg1 )
			end
		}
	} )
	self:linkToElementModel( self, "currentValue", true, function ( model )
		f1_arg0:updateElementState( self, {
			name = "model_validation",
			menu = f1_arg0,
			controller = f1_arg1,
			modelValue = model:get(),
			modelName = "currentValue"
		} )
	end )
	self:linkToElementModel( self, "disabled", true, function ( model )
		f1_arg0:updateElementState( self, {
			name = "model_validation",
			menu = f1_arg0,
			controller = f1_arg1,
			modelValue = model:get(),
			modelName = "disabled"
		} )
	end )
	self:linkToElementModel( self, "currentValue", true, function ( model )
		local f7_local0 = self
	end )
	LUI.OverrideFunction_CallOriginalSecond( self, "close", self.__onClose )
	
	if PostLoadFunc then
		PostLoadFunc( self, f1_arg1, f1_arg0 )
	end
	
	return self
end

CoD.StartMenu_Options_SimpleCheckOptionEnh.__resetProperties = function ( f8_arg0 )
	f8_arg0.checkboxBacking:completeAnimation()
	f8_arg0.CornerDots:completeAnimation()
	f8_arg0.Dash:completeAnimation()
	f8_arg0.DashBacking:completeAnimation()
	f8_arg0.Backing:completeAnimation()
	f8_arg0.Frame:completeAnimation()
	f8_arg0.Corner:completeAnimation()
	f8_arg0.BorderAdd:completeAnimation()
	f8_arg0.Empty:completeAnimation()
	f8_arg0.LabelText:completeAnimation()
	f8_arg0.checkboxBacking:setRGB( 1, 1, 1 )
	f8_arg0.CornerDots:setAlpha( 0 )
	f8_arg0.Dash:setAlpha( 1 )
	f8_arg0.DashBacking:setAlpha( 1 )
	f8_arg0.Backing:setRGB( 0.13, 0.12, 0.12 )
	f8_arg0.Backing:setAlpha( 0.5 )
	f8_arg0.Frame:setAlpha( 0.04 )
	f8_arg0.Corner:setScale( 1, 1 )
	f8_arg0.BorderAdd:setAlpha( 1 )
	f8_arg0.Empty:setAlpha( 1 )
	f8_arg0.LabelText:setRGB( 0.78, 0.74, 0.67 )
end

CoD.StartMenu_Options_SimpleCheckOptionEnh.__clipsPerState = {
	DefaultState = {
		DefaultClip = function ( f9_arg0, f9_arg1 )
			f9_arg0:__resetProperties()
			f9_arg0:setupElementClipCounter( 4 )
			f9_arg0.checkboxBacking:completeAnimation()
			f9_arg0.checkboxBacking:setRGB( 0.78, 0.78, 0.78 )
			f9_arg0.clipFinished( f9_arg0.checkboxBacking )
			f9_arg0.Dash:completeAnimation()
			f9_arg0.Dash:setAlpha( 0 )
			f9_arg0.clipFinished( f9_arg0.Dash )
			f9_arg0.DashBacking:completeAnimation()
			f9_arg0.DashBacking:setAlpha( 0 )
			f9_arg0.clipFinished( f9_arg0.DashBacking )
			f9_arg0.CornerDots:completeAnimation()
			f9_arg0.CornerDots:setAlpha( 0 )
			f9_arg0.clipFinished( f9_arg0.CornerDots )
		end,
		Focus = function ( f10_arg0, f10_arg1 )
			f10_arg0:__resetProperties()
			f10_arg0:setupElementClipCounter( 9 )
			f10_arg0.Backing:completeAnimation()
			f10_arg0.Backing:setRGB( 0.78, 0.74, 0.67 )
			f10_arg0.Backing:setAlpha( 0.2 )
			f10_arg0.clipFinished( f10_arg0.Backing )
			f10_arg0.Frame:completeAnimation()
			f10_arg0.Frame:setAlpha( 0.6 )
			f10_arg0.clipFinished( f10_arg0.Frame )
			f10_arg0.Corner:completeAnimation()
			f10_arg0.Corner:setScale( 0.98, 0.83 )
			f10_arg0.clipFinished( f10_arg0.Corner )
			f10_arg0.checkboxBacking:completeAnimation()
			f10_arg0.checkboxBacking:setRGB( 0.87, 0.37, 0 )
			f10_arg0.clipFinished( f10_arg0.checkboxBacking )
			f10_arg0.Dash:completeAnimation()
			f10_arg0.Dash:setAlpha( 0 )
			f10_arg0.clipFinished( f10_arg0.Dash )
			f10_arg0.BorderAdd:completeAnimation()
			f10_arg0.BorderAdd:setAlpha( 0 )
			f10_arg0.clipFinished( f10_arg0.BorderAdd )
			f10_arg0.Empty:completeAnimation()
			f10_arg0.Empty:setAlpha( 0 )
			f10_arg0.clipFinished( f10_arg0.Empty )
			f10_arg0.DashBacking:completeAnimation()
			f10_arg0.DashBacking:setAlpha( 0 )
			f10_arg0.clipFinished( f10_arg0.DashBacking )
			f10_arg0.CornerDots:completeAnimation()
			f10_arg0.CornerDots:setAlpha( 1 )
			f10_arg0.clipFinished( f10_arg0.CornerDots )
		end
	},
	Checked = {
		DefaultClip = function ( f11_arg0, f11_arg1 )
			f11_arg0:__resetProperties()
			f11_arg0:setupElementClipCounter( 1 )
			f11_arg0.checkboxBacking:completeAnimation()
			f11_arg0.checkboxBacking:setRGB( 0.78, 0.78, 0.78 )
			f11_arg0.clipFinished( f11_arg0.checkboxBacking )
		end,
		Focus = function ( f12_arg0, f12_arg1 )
			f12_arg0:__resetProperties()
			f12_arg0:setupElementClipCounter( 4 )
			f12_arg0.Backing:completeAnimation()
			f12_arg0.Backing:setRGB( 0.78, 0.74, 0.67 )
			f12_arg0.Backing:setAlpha( 0.2 )
			f12_arg0.clipFinished( f12_arg0.Backing )
			f12_arg0.Frame:completeAnimation()
			f12_arg0.Frame:setAlpha( 0.6 )
			f12_arg0.clipFinished( f12_arg0.Frame )
			f12_arg0.Corner:completeAnimation()
			f12_arg0.Corner:setScale( 0.98, 0.83 )
			f12_arg0.clipFinished( f12_arg0.Corner )
			f12_arg0.checkboxBacking:completeAnimation()
			f12_arg0.checkboxBacking:setRGB( 0.87, 0.37, 0 )
			f12_arg0.clipFinished( f12_arg0.checkboxBacking )
		end,
		GainFocus = function ( f13_arg0, f13_arg1 )
			f13_arg0:__resetProperties()
			f13_arg0:setupElementClipCounter( 4 )
			local f13_local0 = function ( f14_arg0 )
				f13_arg0.Backing:beginAnimation( 200 )
				f13_arg0.Backing:setRGB( 0.78, 0.74, 0.67 )
				f13_arg0.Backing:setAlpha( 0.2 )
				f13_arg0.Backing:registerEventHandler( "interrupted_keyframe", f13_arg0.clipInterrupted )
				f13_arg0.Backing:registerEventHandler( "transition_complete_keyframe", f13_arg0.clipFinished )
			end
			
			f13_arg0.Backing:completeAnimation()
			f13_arg0.Backing:setRGB( 0.13, 0.12, 0.12 )
			f13_arg0.Backing:setAlpha( 0.5 )
			f13_local0( f13_arg0.Backing )
			local f13_local1 = function ( f15_arg0 )
				f13_arg0.Frame:beginAnimation( 200 )
				f13_arg0.Frame:setAlpha( 0.6 )
				f13_arg0.Frame:registerEventHandler( "interrupted_keyframe", f13_arg0.clipInterrupted )
				f13_arg0.Frame:registerEventHandler( "transition_complete_keyframe", f13_arg0.clipFinished )
			end
			
			f13_arg0.Frame:completeAnimation()
			f13_arg0.Frame:setAlpha( 0.04 )
			f13_local1( f13_arg0.Frame )
			local f13_local2 = function ( f16_arg0 )
				f13_arg0.Corner:beginAnimation( 200 )
				f13_arg0.Corner:setScale( 0.98, 0.83 )
				f13_arg0.Corner:registerEventHandler( "interrupted_keyframe", f13_arg0.clipInterrupted )
				f13_arg0.Corner:registerEventHandler( "transition_complete_keyframe", f13_arg0.clipFinished )
			end
			
			f13_arg0.Corner:completeAnimation()
			f13_arg0.Corner:setScale( 1, 1 )
			f13_local2( f13_arg0.Corner )
			local f13_local3 = function ( f17_arg0 )
				f13_arg0.checkboxBacking:beginAnimation( 200 )
				f13_arg0.checkboxBacking:setRGB( 0.87, 0.37, 0 )
				f13_arg0.checkboxBacking:registerEventHandler( "interrupted_keyframe", f13_arg0.clipInterrupted )
				f13_arg0.checkboxBacking:registerEventHandler( "transition_complete_keyframe", f13_arg0.clipFinished )
			end
			
			f13_arg0.checkboxBacking:completeAnimation()
			f13_arg0.checkboxBacking:setRGB( 0.78, 0.78, 0.78 )
			f13_local3( f13_arg0.checkboxBacking )
		end,
		LoseFocus = function ( f18_arg0, f18_arg1 )
			f18_arg0:__resetProperties()
			f18_arg0:setupElementClipCounter( 4 )
			local f18_local0 = function ( f19_arg0 )
				f18_arg0.Backing:beginAnimation( 200 )
				f18_arg0.Backing:setRGB( 0.13, 0.12, 0.12 )
				f18_arg0.Backing:setAlpha( 0.5 )
				f18_arg0.Backing:registerEventHandler( "interrupted_keyframe", f18_arg0.clipInterrupted )
				f18_arg0.Backing:registerEventHandler( "transition_complete_keyframe", f18_arg0.clipFinished )
			end
			
			f18_arg0.Backing:completeAnimation()
			f18_arg0.Backing:setRGB( 0.78, 0.74, 0.67 )
			f18_arg0.Backing:setAlpha( 0.2 )
			f18_local0( f18_arg0.Backing )
			local f18_local1 = function ( f20_arg0 )
				f18_arg0.Frame:beginAnimation( 200 )
				f18_arg0.Frame:setAlpha( 0.04 )
				f18_arg0.Frame:registerEventHandler( "interrupted_keyframe", f18_arg0.clipInterrupted )
				f18_arg0.Frame:registerEventHandler( "transition_complete_keyframe", f18_arg0.clipFinished )
			end
			
			f18_arg0.Frame:completeAnimation()
			f18_arg0.Frame:setAlpha( 0.6 )
			f18_local1( f18_arg0.Frame )
			local f18_local2 = function ( f21_arg0 )
				f18_arg0.Corner:beginAnimation( 200 )
				f18_arg0.Corner:setScale( 1, 1 )
				f18_arg0.Corner:registerEventHandler( "interrupted_keyframe", f18_arg0.clipInterrupted )
				f18_arg0.Corner:registerEventHandler( "transition_complete_keyframe", f18_arg0.clipFinished )
			end
			
			f18_arg0.Corner:completeAnimation()
			f18_arg0.Corner:setScale( 0.98, 0.83 )
			f18_local2( f18_arg0.Corner )
			local f18_local3 = function ( f22_arg0 )
				f18_arg0.checkboxBacking:beginAnimation( 200 )
				f18_arg0.checkboxBacking:setRGB( 0.78, 0.78, 0.78 )
				f18_arg0.checkboxBacking:registerEventHandler( "interrupted_keyframe", f18_arg0.clipInterrupted )
				f18_arg0.checkboxBacking:registerEventHandler( "transition_complete_keyframe", f18_arg0.clipFinished )
			end
			
			f18_arg0.checkboxBacking:completeAnimation()
			f18_arg0.checkboxBacking:setRGB( 0.87, 0.37, 0 )
			f18_local3( f18_arg0.checkboxBacking )
		end
	},
	Disabled = {
		DefaultClip = function ( f23_arg0, f23_arg1 )
			f23_arg0:__resetProperties()
			f23_arg0:setupElementClipCounter( 2 )
			f23_arg0.checkboxBacking:completeAnimation()
			f23_arg0.checkboxBacking:setRGB( 0.2, 0.2, 0.2 )
			f23_arg0.clipFinished( f23_arg0.checkboxBacking )
			f23_arg0.LabelText:completeAnimation()
			f23_arg0.LabelText:setRGB( 0.2, 0.2, 0.2 )
			f23_arg0.clipFinished( f23_arg0.LabelText )
		end
	}
}

CoD.StartMenu_Options_SimpleCheckOptionEnh.__onClose = function ( f24_arg0 )
	f24_arg0.Frame:close()
	f24_arg0.Corner:close()
	f24_arg0.checkboxBacking:close()
	f24_arg0.LabelText:close()
	f24_arg0.StartMenuframenoBG00:close()
	f24_arg0.Border:close()
	f24_arg0.BorderAdd:close()
end

-- Active Music list
CoD.ActiveMusicListData = InheritFrom( LUI.UIElement )
CoD.ActiveMusicListData.__defaultWidth = 1600
CoD.ActiveMusicListData.__defaultHeight = 620
CoD.ActiveMusicListData.new = function ( f1_arg0, f1_arg1, f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	local self = LUI.UIElement.new( f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	self:setClass( CoD.ActiveMusicListData )
	self.id = "ActiveMusicListData"
	self.soundSet = "default"
	self.onlyChildrenFocusable = true
	self.anyChildUsesUpdateState = true

	local ActiveMusicListData = LUI.UIList.new( f1_arg0, f1_arg1, 10, 0, nil, false, false, false, false )
	ActiveMusicListData:setLeftRight( 0.5, 0.5, -300, 565 )
	ActiveMusicListData:setTopBottom( 0, 0, 240, 840 )
	ActiveMusicListData:setAutoScaleContent( false )
	ActiveMusicListData:setVerticalCount(4)
	ActiveMusicListData:setHorizontalCount(2)
	ActiveMusicListData:setSpacing( 10 )
	ActiveMusicListData:setWidgetType( CoD.ShieldActiveMusicRow )
	ActiveMusicListData:setVerticalCounter( CoD.verticalCounter )
	ActiveMusicListData:setDataSource( "ShieldActiveMusicList" )
	ActiveMusicListData:setAlignment( Enum[@"luialignment"][@"lui_alignment_left"] )
	self:addElement( ActiveMusicListData )
	self.ActiveMusicListData = ActiveMusicListData

	CoD.Menu.ActiveMusicListData = ActiveMusicListData

	-- options
	local MusicOptions = LUI.UIList.new( f1_arg0, f1_arg1, 12, 0, nil, false, false, false, false )
	MusicOptions:setLeftRight( 0.5, 0.5, -460, -140 )
	MusicOptions:setTopBottom( 0, 0, 860.5, 1400.5 )
	MusicOptions:setWidgetType( CoD.StartMenu_Options_SimpleCheckOptionEnh )
	MusicOptions:setVerticalCount( 2 )
	MusicOptions:setSpacing( 12 )
	MusicOptions:setAlignment( Enum[@"luialignment"][@"lui_alignment_left"] )
	MusicOptions:setDataSource( "MusicOptionsList" )
	MusicOptions:registerEventHandler( "gain_focus", function ( element, event )
		local f5_local0 = nil
		if element.gainFocus then
			f5_local0 = element:gainFocus( event )
		elseif element.super.gainFocus then
			f5_local0 = element.super:gainFocus( event )
		end
		CoD.Menu.UpdateButtonShownState( element, f1_arg0, f1_arg1, Enum[@"luibutton"][@"lui_key_xba_pscross"] )
		return f5_local0
	end )
	f1_arg0:AddButtonCallbackFunction( MusicOptions, f1_arg1, Enum[@"luibutton"][@"lui_key_xba_pscross"], nil, function ( element, menu, controller, model )
		ProcessListAction( self, element, controller, menu )
		PlaySoundAlias( "uin_paint_image_flip_toggle" )
		return true
	end, function ( element, menu, controller )
		--CoD.Menu.SetButtonLabel( menu, Enum[@"luibutton"][@"lui_key_xba_pscross"], @"hash_0", nil, nil )
		return false
	end, false )
	self:addElement( MusicOptions )
	self.MusicOptions = MusicOptions

	MusicOptions.id = "MusicOptions"

	--LUI_DebugElement(self, ActiveMusicListData, 300, "ActiveMusicListData")

	-- run engine to check for new musics
	Engine[@"exec"](Engine[@"getprimarycontroller"](), "MM_push_musics")

	ActiveMusicListData:AddContextualMenuAction( f1_arg0, f1_arg1, @"shield/set_music_tr", function ( f13_arg0, f13_arg1, f13_arg2, f13_arg3 )
		if AlwaysTrue() then
			return function ( f14_arg0, f14_arg1, f14_arg2, f14_arg3 )
				local MusicName = f14_arg0:getModel(f14_arg2, "MusicFilePath")
				MusicName = MusicName:get()
				
				Shield_TR_Music = MusicName
				CoD.Shield.MusicManagerToastUpdate("Music has been set for Main Menu!")

				Engine[@"exec"](Engine[@"getprimarycontroller"](), "writejson lua tr_music " .. '"' .. MusicName .. '"' .. " string")
				Engine[@"exec"](Engine[@"getprimarycontroller"](), "set Shield_TR_Music " .. MusicName)

				ActiveMusicListData:addElement( LUI.UITimer.newElementTimer( 15, true, function ()
					ActiveMusicListData:setDataSource( "test" ) -- Data Source and refresh after delay
					ActiveMusicListData:updateDataSource()
					ActiveMusicListData:setDataSource( "ShieldActiveMusicList" ) -- Data Source and refresh after delay
					ActiveMusicListData:updateDataSource()
				end ) )
			end
			
		else
			CoD.EnhPrintInfo("WTF")
		end
	end )

	ActiveMusicListData:AddContextualMenuAction( f1_arg0, f1_arg1, @"shield/set_music_wz", function ( f13_arg0, f13_arg1, f13_arg2, f13_arg3 )
		if AlwaysTrue() then
			return function ( f14_arg0, f14_arg1, f14_arg2, f14_arg3 )
				local MusicName = f14_arg0:getModel(f14_arg2, "MusicFilePath")
				MusicName = MusicName:get()

				Shield_WZ_Music = MusicName
				CoD.Shield.MusicManagerToastUpdate("Music has been set for Blackout!")

				Engine[@"exec"](Engine[@"getprimarycontroller"](), "writejson lua wz_music " .. '"' .. MusicName .. '"' .. " string")
				Engine[@"exec"](Engine[@"getprimarycontroller"](), "set Shield_WZ_Music " .. MusicName)

				ActiveMusicListData:addElement( LUI.UITimer.newElementTimer( 15, true, function ()
					ActiveMusicListData:setDataSource( "test" ) -- Data Source and refresh after delay
					ActiveMusicListData:updateDataSource()
					ActiveMusicListData:setDataSource( "ShieldActiveMusicList" ) -- Data Source and refresh after delay
					ActiveMusicListData:updateDataSource()
				end ) )
			end
			
		else
			CoD.EnhPrintInfo("WTF")
		end
	end )

	ActiveMusicListData:AddContextualMenuAction( f1_arg0, f1_arg1, @"shield/set_music_mp", function ( f13_arg0, f13_arg1, f13_arg2, f13_arg3 )
		if AlwaysTrue() then
			return function ( f14_arg0, f14_arg1, f14_arg2, f14_arg3 )
				local MusicName = f14_arg0:getModel(f14_arg2, "MusicFilePath")
				MusicName = MusicName:get()

				Shield_MP_Music = MusicName
				CoD.Shield.MusicManagerToastUpdate("Music has been set for Multiplayer!")

				Engine[@"exec"](Engine[@"getprimarycontroller"](), "writejson lua mp_music " .. '"' .. MusicName .. '"' .. " string")
				Engine[@"exec"](Engine[@"getprimarycontroller"](), "set Shield_MP_Music " .. MusicName)

				ActiveMusicListData:addElement( LUI.UITimer.newElementTimer( 15, true, function ()
					ActiveMusicListData:setDataSource( "test" ) -- Data Source and refresh after delay
					ActiveMusicListData:updateDataSource()
					ActiveMusicListData:setDataSource( "ShieldActiveMusicList" ) -- Data Source and refresh after delay
					ActiveMusicListData:updateDataSource()
				end ) )
			end
			
		else
			CoD.EnhPrintInfo("WTF")
		end
	end )

	ActiveMusicListData:AddContextualMenuAction( f1_arg0, f1_arg1, @"shield/set_music_zm", function ( f13_arg0, f13_arg1, f13_arg2, f13_arg3 )
		if AlwaysTrue() then
			return function ( f14_arg0, f14_arg1, f14_arg2, f14_arg3 )
				local MusicName = f14_arg0:getModel(f14_arg2, "MusicFilePath")
				MusicName = MusicName:get()
				
				Shield_ZM_Music = MusicName
				CoD.Shield.MusicManagerToastUpdate("Music has been set for Zombies!")

				Engine[@"exec"](Engine[@"getprimarycontroller"](), "writejson lua zm_music " .. '"' .. MusicName .. '"' .. " string")
				Engine[@"exec"](Engine[@"getprimarycontroller"](), "set Shield_ZM_Music " .. MusicName)

				ActiveMusicListData:addElement( LUI.UITimer.newElementTimer( 15, true, function ()
					ActiveMusicListData:setDataSource( "test" ) -- Data Source and refresh after delay
					ActiveMusicListData:updateDataSource()
					ActiveMusicListData:setDataSource( "ShieldActiveMusicList" ) -- Data Source and refresh after delay
					ActiveMusicListData:updateDataSource()
				end ) )
			end
			
		else
			CoD.EnhPrintInfo("WTF")
		end
	end )

	ActiveMusicListData:AddContextualMenuAction( f1_arg0, f1_arg1, @"shield/clear_music", function ( f13_arg0, f13_arg1, f13_arg2, f13_arg3 )
		if AlwaysTrue() then
			return function ( f14_arg0, f14_arg1, f14_arg2, f14_arg3 )
				local MusicName = f14_arg0:getModel(f14_arg2, "MusicFilePath")
				MusicName = MusicName:get()

				-- update musics
				Shield_ZM_Music = Engine[@"getdvarstring"]("Shield_ZM_Music")
				Shield_MP_Music = Engine[@"getdvarstring"]("Shield_MP_Music")
				Shield_WZ_Music = Engine[@"getdvarstring"]("Shield_WZ_Music")
				Shield_TR_Music = Engine[@"getdvarstring"]("Shield_TR_Music")

				local removed = false

				if Shield_ZM_Music == MusicName then
					Shield_ZM_Music = ""
					Engine[@"exec"](Engine[@"getprimarycontroller"](), "writejson lua zm_music " .. "none" .. " string")
					Engine[@"exec"](Engine[@"getprimarycontroller"](), "set Shield_ZM_Music " .. "none")
					CoD.Shield.MusicManagerToastUpdate("Cleared Music of Zombies!")

					removed = true
				end

				if Shield_WZ_Music == MusicName then
					Shield_WZ_Music = ""
					Engine[@"exec"](Engine[@"getprimarycontroller"](), "writejson lua wz_music " .. "none" .. " string")
					Engine[@"exec"](Engine[@"getprimarycontroller"](), "set Shield_WZ_Music " .. "none")
					CoD.Shield.MusicManagerToastUpdate("Cleared Music of Blackout!")

					removed = true
				end

				if Shield_MP_Music == MusicName then
					Shield_MP_Music = ""
					Engine[@"exec"](Engine[@"getprimarycontroller"](), "writejson lua mp_music " .. "none" .. " string")
					Engine[@"exec"](Engine[@"getprimarycontroller"](), "set Shield_MP_Music " .. "none")
					CoD.Shield.MusicManagerToastUpdate("Cleared Music of Multiplayer!")

					removed = true
				end

				if Shield_TR_Music == MusicName then
					Shield_TR_Music = ""
					Engine[@"exec"](Engine[@"getprimarycontroller"](), "writejson lua tr_music " .. "none" .. " string")
					Engine[@"exec"](Engine[@"getprimarycontroller"](), "set Shield_TR_Music " .. "none")
					CoD.Shield.MusicManagerToastUpdate("Cleared Music of Main Menu!")

					removed = true
				end

				if removed == false then
					CoD.Shield.MusicManagerToastUpdate("Error: Music is not set to any mode!")
				end

				ActiveMusicListData:addElement( LUI.UITimer.newElementTimer( 15, true, function ()
					ActiveMusicListData:setDataSource( "test" ) -- Data Source and refresh after delay
					ActiveMusicListData:updateDataSource()
					ActiveMusicListData:setDataSource( "ShieldActiveMusicList" ) -- Data Source and refresh after delay
					ActiveMusicListData:updateDataSource()
				end ) )
			end
			
		else
			CoD.EnhPrintInfo("WTF")
		end
	end )

	-- controller/keyboard inputs
	f1_arg0:AddButtonCallbackFunction( ActiveMusicListData, f1_arg1, Enum[@"luibutton"][@"lui_key_xbx_pssquare"], "ui_remove", function ( element, menu, controller, model )
		if AlwaysTrue() then
			local MusicName = element:getModel(model, "MusicFilePath")
			MusicName = MusicName:get()
			
			Selected_Shield_Music = MusicName
			CoD.Shield.MusicManagerToastUpdate("Selected " .. Selected_Shield_Music .. " Music!")
			return true
		else
			return false
		end
	end, function ( element, menu, controller )
			CoD.Menu.SetButtonLabel( menu, Enum[@"luibutton"][@"lui_key_xbx_pssquare"], @"shield/select_music", Enum[@"luibuttonpromptflags"][@"bpf_contextual"], "ui_confirm" )
			return true
	end, false )

	-- name
	CoD.PCWidgetUtility.SetupContextualMenu( ActiveMusicListData, f1_arg1, "MusicFilePath", "", "" )

	ActiveMusicListData.id = "ActiveMusicListData"

	LUI.OverrideFunction_CallOriginalSecond( self, "close", self.__onClose )
	
	if PostLoadFunc then
		PostLoadFunc( self, f1_arg1, f1_arg0 )
	end

	return self
end

CoD.ActiveMusicListData.__onClose = function ( f9_arg0 )
	--f9_arg0.LANServerBrowserDetails:close()
	f9_arg0.ActiveMusicListData:close()
	f9_arg0.MusicOptions:close()
end

-- Music Background Style
CoD.MusicCommonCenteredPopup = InheritFrom( LUI.UIElement )
CoD.MusicCommonCenteredPopup.__defaultWidth = 1920
CoD.MusicCommonCenteredPopup.__defaultHeight = 1080
CoD.MusicCommonCenteredPopup.new = function ( f1_arg0, f1_arg1, f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	local self = LUI.UIElement.new( f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	self:setClass( CoD.MusicCommonCenteredPopup )
	self.id = "MusicCommonCenteredPopup"
	self.soundSet = "default"
	self.onlyChildrenFocusable = true
	self.anyChildUsesUpdateState = true
	
	--[[
	local BlackfadeBlurB = LUI.UIImage.new( 0, 1, -5, 5, 0, 1, -5, 5 )
	BlackfadeBlurB:setRGB( 0, 0, 0 )
	BlackfadeBlurB:setMaterial( LUI.UIImage.GetCachedMaterial( @"hash_E2354BE557C4C7A" ) )
	BlackfadeBlurB:setShaderVector( 0, 0, 0, 0, 0 )
	self:addElement( BlackfadeBlurB )
	self.BlackfadeBlurB = BlackfadeBlurB
	
	local BlackfadeBlurF = LUI.UIImage.new( 0, 1, -5, 5, 0, 1, -5, 5 )
	BlackfadeBlurF:setRGB( 0, 0, 0 )
	BlackfadeBlurF:setAlpha( 0.6 )
	self:addElement( BlackfadeBlurF )
	self.BlackfadeBlurF = BlackfadeBlurF
	]]
	
	local CenterBackground = LUI.UIImage.new( 0.5, 0.5, -348 - 350, 348 + 350, 0.5, 0.5, -500, 500 )
	CenterBackground:setRGB( 0.09, 0.09, 0.09 )
	CenterBackground:setAlpha( 0.9 )
	self:addElement( CenterBackground )
	self.CenterBackground = CenterBackground
	
	local CenterTiledBacking = LUI.UIImage.new( 0.5, 0.5, -348 - 350, 348 + 350, 0.5, 0.5, -500, 500 )
	CenterTiledBacking:setAlpha( 0.25 )
	CenterTiledBacking:setImage( RegisterImage( @"hash_634839E8065B1E53" ) )
	CenterTiledBacking:setMaterial( LUI.UIImage.GetCachedMaterial( @"hash_16CBE95C250C6D15" ) )
	CenterTiledBacking:setShaderVector( 0, 0, 0, 0, 0 )
	CenterTiledBacking:setupNineSliceShader( 196, 88 )
	self:addElement( CenterTiledBacking )
	self.CenterTiledBacking = CenterTiledBacking
	
	local buttons = CoD.fe_LeftContainer_NOTLobby.new( f1_arg0, f1_arg1, 0.50, 0.50, 50.00, 300.00, 0.50, 0.50, 0.00, 400.00 )
	self:addElement( buttons )
	self.buttons = buttons
	
	local featureOverlayButtonMouseOnly = nil
	
	featureOverlayButtonMouseOnly = CoD.featureOverlay_Button.new( f1_arg0, f1_arg1, 0.5, 0.5, -333 + 950 - 125, -147 + 950 - 125, 0.5, 0.5, 424, 484 )
	featureOverlayButtonMouseOnly.ButtonContainer.Title:setText( Engine[@"hash_4F9F1239CFD921FE"]( @"hash_778D439E1B360368" ) )
	featureOverlayButtonMouseOnly:registerEventHandler( "gain_focus", function ( element, event )
		local f2_local0 = nil
		if element.gainFocus then
			f2_local0 = element:gainFocus( event )
		elseif element.super.gainFocus then
			f2_local0 = element.super:gainFocus( event )
		end
		CoD.Menu.UpdateButtonShownState( element, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
		return f2_local0
	end )
	f1_arg0:AddButtonCallbackFunction( featureOverlayButtonMouseOnly, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], "ui_confirm", function ( element, menu, controller, model )
		GoBack( self, controller )
		return true
	end, function ( element, menu, controller )
		CoD.Menu.SetButtonLabel( menu, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], @"hash_0", nil, "ui_confirm" )
		return false
	end, false )
	self:addElement( featureOverlayButtonMouseOnly )
	self.featureOverlayButtonMouseOnly = featureOverlayButtonMouseOnly

	-- selection for controller/keyboard only
	local ClearALLMusicButton = nil
	
	ClearALLMusicButton = CoD.featureOverlay_Button.new( f1_arg0, f1_arg1, 0.5, 0.5, -333 + 950 - 125, -147 + 950 - 125, 0.5, 0.5, 424 - 80, 484 - 80 )
	ClearALLMusicButton.ButtonContainer.Title:setText( Engine[@"hash_4F9F1239CFD921FE"]( @"shield/clear_all_music" ) )
	ClearALLMusicButton:registerEventHandler( "gain_focus", function ( element, event )
		local f2_local0 = nil
		if element.gainFocus then
			f2_local0 = element:gainFocus( event )
		elseif element.super.gainFocus then
			f2_local0 = element.super:gainFocus( event )
		end
		CoD.Menu.UpdateButtonShownState( element, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
		return f2_local0
	end )
	f1_arg0:AddButtonCallbackFunction( ClearALLMusicButton, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], "ui_confirm", function ( element, menu, controller, model )
		-- reset musics
		Shield_ZM_Music = ""
		Engine[@"exec"](Engine[@"getprimarycontroller"](), "writejson lua zm_music " .. "none" .. " string")
		Engine[@"exec"](Engine[@"getprimarycontroller"](), "set Shield_ZM_Music " .. "none")

		Shield_WZ_Music = ""
		Engine[@"exec"](Engine[@"getprimarycontroller"](), "writejson lua wz_music " .. "none" .. " string")
		Engine[@"exec"](Engine[@"getprimarycontroller"](), "set Shield_WZ_Music " .. "none")

		Shield_MP_Music = ""
		Engine[@"exec"](Engine[@"getprimarycontroller"](), "writejson lua mp_music " .. "none" .. " string")
		Engine[@"exec"](Engine[@"getprimarycontroller"](), "set Shield_MP_Music " .. "none")

		Shield_TR_Music = ""
		Engine[@"exec"](Engine[@"getprimarycontroller"](), "writejson lua tr_music " .. "none" .. " string")
		Engine[@"exec"](Engine[@"getprimarycontroller"](), "set Shield_TR_Music " .. "none")

		if CoD.Menu.ActiveMusicListData ~= nil then
			CoD.Menu.ActiveMusicListData:addElement( LUI.UITimer.newElementTimer( 15, true, function ()
				CoD.Menu.ActiveMusicListData:setDataSource( "test" ) -- Data Source and refresh after delay
				CoD.Menu.ActiveMusicListData:updateDataSource()
				CoD.Menu.ActiveMusicListData:setDataSource( "ShieldActiveMusicList" ) -- Data Source and refresh after delay
				CoD.Menu.ActiveMusicListData:updateDataSource()
			end ) )
		end

		CoD.Shield.MusicManagerToastUpdate("All Music has been reset to default!")

		return true
	end, function ( element, menu, controller )
		CoD.Menu.SetButtonLabel( menu, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], @"hash_0", nil, "ui_confirm" )
		return false
	end, false )
	self:addElement( ClearALLMusicButton )
	self.ClearALLMusicButton = ClearALLMusicButton

	ClearALLMusicButton.id = "ClearALLMusicButton"

	local ClearMusicButton = nil
	
	ClearMusicButton = CoD.featureOverlay_Button.new( f1_arg0, f1_arg1, 0.5, 0.5, -333 + 950 - 450, -147 + 950 - 450, 0.5, 0.5, 424, 484 )
	ClearMusicButton.ButtonContainer.Title:setText( Engine[@"hash_4F9F1239CFD921FE"]( @"shield/clear_music" ) )
	ClearMusicButton:registerEventHandler( "gain_focus", function ( element, event )
		local f2_local0 = nil
		if element.gainFocus then
			f2_local0 = element:gainFocus( event )
		elseif element.super.gainFocus then
			f2_local0 = element.super:gainFocus( event )
		end
		CoD.Menu.UpdateButtonShownState( element, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
		return f2_local0
	end )
	f1_arg0:AddButtonCallbackFunction( ClearMusicButton, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], "ui_confirm", function ( element, menu, controller, model )
		-- logic
		local MusicName = Selected_Shield_Music

		if MusicName == "" or MusicName == "none" then
			CoD.Shield.MusicManagerToastUpdate("You need to Select a Music first!")
			return true
		end

		-- update musics
		Shield_ZM_Music = Engine[@"getdvarstring"]("Shield_ZM_Music")
		Shield_MP_Music = Engine[@"getdvarstring"]("Shield_MP_Music")
		Shield_WZ_Music = Engine[@"getdvarstring"]("Shield_WZ_Music")
		Shield_TR_Music = Engine[@"getdvarstring"]("Shield_TR_Music")

		local removed = false

		if Shield_ZM_Music == MusicName then
			Shield_ZM_Music = ""
			Engine[@"exec"](Engine[@"getprimarycontroller"](), "writejson lua zm_music " .. "none" .. " string")
			Engine[@"exec"](Engine[@"getprimarycontroller"](), "set Shield_ZM_Music " .. "none")
			CoD.Shield.MusicManagerToastUpdate("Cleared Music of Zombies!")

			removed = true
		end

		if Shield_WZ_Music == MusicName then
			Shield_WZ_Music = ""
			Engine[@"exec"](Engine[@"getprimarycontroller"](), "writejson lua wz_music " .. "none" .. " string")
			Engine[@"exec"](Engine[@"getprimarycontroller"](), "set Shield_WZ_Music " .. "none")
			CoD.Shield.MusicManagerToastUpdate("Cleared Music of Blackout!")

			removed = true
		end

		if Shield_MP_Music == MusicName then
			Shield_MP_Music = ""
			Engine[@"exec"](Engine[@"getprimarycontroller"](), "writejson lua mp_music " .. "none" .. " string")
			Engine[@"exec"](Engine[@"getprimarycontroller"](), "set Shield_MP_Music " .. "none")
			CoD.Shield.MusicManagerToastUpdate("Cleared Music of Multiplayer!")

			removed = true
		end

		if Shield_TR_Music == MusicName then
			Shield_TR_Music = ""
			Engine[@"exec"](Engine[@"getprimarycontroller"](), "writejson lua tr_music " .. "none" .. " string")
			Engine[@"exec"](Engine[@"getprimarycontroller"](), "set Shield_TR_Music " .. "none")
			CoD.Shield.MusicManagerToastUpdate("Cleared Music of Main Menu!")

			removed = true
		end

		if removed == false then
			CoD.Shield.MusicManagerToastUpdate("Error: Music is not set to any mode!")
		end

		if CoD.Menu.ActiveMusicListData ~= nil then
			CoD.Menu.ActiveMusicListData:addElement( LUI.UITimer.newElementTimer( 15, true, function ()
				CoD.Menu.ActiveMusicListData:setDataSource( "test" ) -- Data Source and refresh after delay
				CoD.Menu.ActiveMusicListData:updateDataSource()
				CoD.Menu.ActiveMusicListData:setDataSource( "ShieldActiveMusicList" ) -- Data Source and refresh after delay
				CoD.Menu.ActiveMusicListData:updateDataSource()
			end ) )
		end

		return true
	end, function ( element, menu, controller )
		CoD.Menu.SetButtonLabel( menu, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], @"hash_0", nil, "ui_confirm" )
		return false
	end, false )
	self:addElement( ClearMusicButton )
	self.ClearMusicButton = ClearMusicButton

	local ZombiesMusicButton = nil
	
	ZombiesMusicButton = CoD.featureOverlay_Button.new( f1_arg0, f1_arg1, 0.5, 0.5, -333 + 950 - 650, -147 + 950 - 650, 0.5, 0.5, 424, 484 )
	ZombiesMusicButton.ButtonContainer.Title:setText( Engine[@"hash_4F9F1239CFD921FE"]( @"shield/set_music_zm" ) )
	ZombiesMusicButton:registerEventHandler( "gain_focus", function ( element, event )
		local f2_local0 = nil
		if element.gainFocus then
			f2_local0 = element:gainFocus( event )
		elseif element.super.gainFocus then
			f2_local0 = element.super:gainFocus( event )
		end
		CoD.Menu.UpdateButtonShownState( element, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
		return f2_local0
	end )
	f1_arg0:AddButtonCallbackFunction( ZombiesMusicButton, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], "ui_confirm", function ( element, menu, controller, model )
		-- logic
		local MusicName = Selected_Shield_Music

		if MusicName == "" or MusicName == "none" then
			CoD.Shield.MusicManagerToastUpdate("You need to Select a Music first!")
			return true
		end

		Shield_ZM_Music = MusicName
		CoD.Shield.MusicManagerToastUpdate("Music has been set for Zombies!")

		Engine[@"exec"](Engine[@"getprimarycontroller"](), "writejson lua zm_music " .. '"' .. MusicName .. '"' .. " string")
		Engine[@"exec"](Engine[@"getprimarycontroller"](), "set Shield_ZM_Music " .. MusicName)

		if CoD.Menu.ActiveMusicListData ~= nil then
			CoD.Menu.ActiveMusicListData:addElement( LUI.UITimer.newElementTimer( 15, true, function ()
				CoD.Menu.ActiveMusicListData:setDataSource( "test" ) -- Data Source and refresh after delay
				CoD.Menu.ActiveMusicListData:updateDataSource()
				CoD.Menu.ActiveMusicListData:setDataSource( "ShieldActiveMusicList" ) -- Data Source and refresh after delay
				CoD.Menu.ActiveMusicListData:updateDataSource()
			end ) )
		end

		return true
	end, function ( element, menu, controller )
		CoD.Menu.SetButtonLabel( menu, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], @"hash_0", nil, "ui_confirm" )
		return false
	end, false )
	self:addElement( ZombiesMusicButton )
	self.ZombiesMusicButton = ZombiesMusicButton

	ZombiesMusicButton.id = "ZombiesMusicButton"

	local MultiPlayerMusicButton = nil
	
	MultiPlayerMusicButton = CoD.featureOverlay_Button.new( f1_arg0, f1_arg1, 0.5, 0.5, -333 + 950 - 850, -147 + 950 - 850, 0.5, 0.5, 424, 484 )
	MultiPlayerMusicButton.ButtonContainer.Title:setText( Engine[@"hash_4F9F1239CFD921FE"]( @"shield/set_music_mp" ) )
	MultiPlayerMusicButton:registerEventHandler( "gain_focus", function ( element, event )
		local f2_local0 = nil
		if element.gainFocus then
			f2_local0 = element:gainFocus( event )
		elseif element.super.gainFocus then
			f2_local0 = element.super:gainFocus( event )
		end
		CoD.Menu.UpdateButtonShownState( element, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
		return f2_local0
	end )
	f1_arg0:AddButtonCallbackFunction( MultiPlayerMusicButton, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], "ui_confirm", function ( element, menu, controller, model )
		-- logic
		local MusicName = Selected_Shield_Music

		if MusicName == "" or MusicName == "none" then
			CoD.Shield.MusicManagerToastUpdate("You need to Select a Music first!")
			return true
		end

		Shield_MP_Music = MusicName
		CoD.Shield.MusicManagerToastUpdate("Music has been set for Multiplayer!")

		Engine[@"exec"](Engine[@"getprimarycontroller"](), "writejson lua mp_music " .. '"' .. MusicName .. '"' .. " string")
		Engine[@"exec"](Engine[@"getprimarycontroller"](), "set Shield_MP_Music " .. MusicName)

		if CoD.Menu.ActiveMusicListData ~= nil then
			CoD.Menu.ActiveMusicListData:addElement( LUI.UITimer.newElementTimer( 15, true, function ()
				CoD.Menu.ActiveMusicListData:setDataSource( "test" ) -- Data Source and refresh after delay
				CoD.Menu.ActiveMusicListData:updateDataSource()
				CoD.Menu.ActiveMusicListData:setDataSource( "ShieldActiveMusicList" ) -- Data Source and refresh after delay
				CoD.Menu.ActiveMusicListData:updateDataSource()
			end ) )
		end

		return true
	end, function ( element, menu, controller )
		CoD.Menu.SetButtonLabel( menu, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], @"hash_0", nil, "ui_confirm" )
		return false
	end, false )
	self:addElement( MultiPlayerMusicButton )
	self.MultiPlayerMusicButton = MultiPlayerMusicButton

	MultiPlayerMusicButton.id = "MultiPlayerMusicButton"

	local BlackoutMusicButton = nil
	
	BlackoutMusicButton = CoD.featureOverlay_Button.new( f1_arg0, f1_arg1, 0.5, 0.5, -333 + 950 - 1050, -147 + 950 - 1050, 0.5, 0.5, 424, 484 )
	BlackoutMusicButton.ButtonContainer.Title:setText( Engine[@"hash_4F9F1239CFD921FE"]( @"shield/set_music_wz" ) )
	BlackoutMusicButton:registerEventHandler( "gain_focus", function ( element, event )
		local f2_local0 = nil
		if element.gainFocus then
			f2_local0 = element:gainFocus( event )
		elseif element.super.gainFocus then
			f2_local0 = element.super:gainFocus( event )
		end
		CoD.Menu.UpdateButtonShownState( element, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
		return f2_local0
	end )
	f1_arg0:AddButtonCallbackFunction( BlackoutMusicButton, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], "ui_confirm", function ( element, menu, controller, model )
		-- logic
		local MusicName = Selected_Shield_Music

		if MusicName == "" or MusicName == "none" then
			CoD.Shield.MusicManagerToastUpdate("You need to Select a Music first!")
			return true
		end

		Shield_WZ_Music = MusicName
		CoD.Shield.MusicManagerToastUpdate("Music has been set for Blackout!")

		Engine[@"exec"](Engine[@"getprimarycontroller"](), "writejson lua wz_music " .. '"' .. MusicName .. '"' .. " string")
		Engine[@"exec"](Engine[@"getprimarycontroller"](), "set Shield_WZ_Music " .. MusicName)

		if CoD.Menu.ActiveMusicListData ~= nil then
			CoD.Menu.ActiveMusicListData:addElement( LUI.UITimer.newElementTimer( 15, true, function ()
				CoD.Menu.ActiveMusicListData:setDataSource( "test" ) -- Data Source and refresh after delay
				CoD.Menu.ActiveMusicListData:updateDataSource()
				CoD.Menu.ActiveMusicListData:setDataSource( "ShieldActiveMusicList" ) -- Data Source and refresh after delay
				CoD.Menu.ActiveMusicListData:updateDataSource()
			end ) )
		end

		return true
	end, function ( element, menu, controller )
		CoD.Menu.SetButtonLabel( menu, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], @"hash_0", nil, "ui_confirm" )
		return false
	end, false )
	self:addElement( BlackoutMusicButton )
	self.BlackoutMusicButton = BlackoutMusicButton

	BlackoutMusicButton.id = "BlackoutMusicButton"

	local TitleScreenMusicButton = nil
	
	TitleScreenMusicButton = CoD.featureOverlay_Button.new( f1_arg0, f1_arg1, 0.5, 0.5, -333 + 950 - 1250, -147 + 950 - 1250, 0.5, 0.5, 424, 484 )
	TitleScreenMusicButton.ButtonContainer.Title:setText( Engine[@"hash_4F9F1239CFD921FE"]( @"shield/set_music_tr" ) )
	TitleScreenMusicButton:registerEventHandler( "gain_focus", function ( element, event )
		local f2_local0 = nil
		if element.gainFocus then
			f2_local0 = element:gainFocus( event )
		elseif element.super.gainFocus then
			f2_local0 = element.super:gainFocus( event )
		end
		CoD.Menu.UpdateButtonShownState( element, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
		return f2_local0
	end )
	f1_arg0:AddButtonCallbackFunction( TitleScreenMusicButton, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], "ui_confirm", function ( element, menu, controller, model )
		-- logic
		local MusicName = Selected_Shield_Music

		if MusicName == "" or MusicName == "none" then
			CoD.Shield.MusicManagerToastUpdate("You need to Select a Music first!")
			return true
		end

		Shield_TR_Music = MusicName
		CoD.Shield.MusicManagerToastUpdate("Music has been set for Main Menu!")

		Engine[@"exec"](Engine[@"getprimarycontroller"](), "writejson lua tr_music " .. '"' .. MusicName .. '"' .. " string")
		Engine[@"exec"](Engine[@"getprimarycontroller"](), "set Shield_TR_Music " .. MusicName)
		

		if CoD.Menu.ActiveMusicListData ~= nil then
			CoD.Menu.ActiveMusicListData:addElement( LUI.UITimer.newElementTimer( 15, true, function ()
				CoD.Menu.ActiveMusicListData:setDataSource( "test" ) -- Data Source and refresh after delay
				CoD.Menu.ActiveMusicListData:updateDataSource()
				CoD.Menu.ActiveMusicListData:setDataSource( "ShieldActiveMusicList" ) -- Data Source and refresh after delay
				CoD.Menu.ActiveMusicListData:updateDataSource()
			end ) )
		end

		return true
	end, function ( element, menu, controller )
		CoD.Menu.SetButtonLabel( menu, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], @"hash_0", nil, "ui_confirm" )
		return false
	end, false )
	self:addElement( TitleScreenMusicButton )
	self.TitleScreenMusicButton = TitleScreenMusicButton

	TitleScreenMusicButton.id = "TitleScreenMusicButton"
	
	local LayoutBottomBar = LUI.UIImage.new( 0.5, 0.5, -349.5 - 350, 349.5 + 350, 0.5, 0.5, 473, 501 )
	LayoutBottomBar:setZRot( 180 )
	LayoutBottomBar:setImage( RegisterImage( @"hash_87C348C36FF085C" ) )
	self:addElement( LayoutBottomBar )
	self.LayoutBottomBar = LayoutBottomBar
	
	local LayoutTopBar = LUI.UIImage.new( 0.5, 0.5, -349.5 - 350, 349.5 + 350, 0.5, 0.5, -500.5, -472.5 )
	LayoutTopBar:setImage( RegisterImage( @"hash_87C348C36FF085C" ) )
	self:addElement( LayoutTopBar )
	self.LayoutTopBar = LayoutTopBar
	
	local LayoutTopBarStripes = LUI.UIImage.new( 0.5, 0.5, -348 - 350, 348 + 350, 0.5, 0.5, -500.5, -484.5 )
	LayoutTopBarStripes:setImage( RegisterImage( @"hash_6A0F654633E4C64E" ) )
	self:addElement( LayoutTopBarStripes )
	self.LayoutTopBarStripes = LayoutTopBarStripes
	
	local TitleBackgroundBar = LUI.UIImage.new( 0.5, 0.5, -336.5, 336.5, 0.5, 0.5, -472, -444 )
	TitleBackgroundBar:setRGB( 0.25, 0.24, 0.22 )
	TitleBackgroundBar:setAlpha( 0.88 )
	self:addElement( TitleBackgroundBar )
	self.TitleBackgroundBar = TitleBackgroundBar
	
	local TitleTiledBacking = LUI.UIImage.new( 0.5, 0.5, -336.5, 336.5, 0.5, 0.5, -472, -444 )
	TitleTiledBacking:setAlpha( 0.5 )
	TitleTiledBacking:setImage( RegisterImage( @"hash_634839E8065B1E53" ) )
	TitleTiledBacking:setMaterial( LUI.UIImage.GetCachedMaterial( @"hash_16CBE95C250C6D15" ) )
	TitleTiledBacking:setShaderVector( 0, 0, 0, 0, 0 )
	TitleTiledBacking:setupNineSliceShader( 196, 88 )
	self:addElement( TitleTiledBacking )
	self.TitleTiledBacking = TitleTiledBacking
	
	local TitleText = LUI.UIText.new( 0.5, 0.5, -279.5, 279.5, 0.5, 0.5, -469, -445 )
	TitleText:setRGB( ColorSet.T8__BIEGE.r, ColorSet.T8__BIEGE.g, ColorSet.T8__BIEGE.b )
	TitleText:setAlpha( 0.6 )
	TitleText:setText( "" )
	TitleText:setTTF( "ttmussels_regular" )
	TitleText:setLetterSpacing( 4 )
	TitleText:setAlignment( Enum[@"hash_67A5123B654282D2"][@"hash_1FEEB12BCB0D7041"] )
	TitleText:setAlignment( Enum[@"hash_67A5123B654282D2"][@"hash_3F41D595A2B0EDF3"] )
	self:addElement( TitleText )
	self.TitleText = TitleText
	
	local TitleLayoutElementL = LUI.UIImage.new( 0.5, 0.5, -331, -315, 0.5, 0.5, -465, -449 )
	TitleLayoutElementL:setRGB( ColorSet.T8__BIEGE.r, ColorSet.T8__BIEGE.g, ColorSet.T8__BIEGE.b )
	TitleLayoutElementL:setZRot( 90 )
	TitleLayoutElementL:setImage( RegisterImage( @"hash_634B575F15CDD376" ) )
	TitleLayoutElementL:setMaterial( LUI.UIImage.GetCachedMaterial( @"hash_F755127C95CF5B6" ) )
	TitleLayoutElementL:setShaderVector( 0, 3, 0, 0, 0 )
	self:addElement( TitleLayoutElementL )
	self.TitleLayoutElementL = TitleLayoutElementL
	
	local TitleLayoutElementR = LUI.UIImage.new( 0.5, 0.5, 313, 329, 0.5, 0.5, -464, -448 )
	TitleLayoutElementR:setRGB( ColorSet.T8__BIEGE.r, ColorSet.T8__BIEGE.g, ColorSet.T8__BIEGE.b )
	TitleLayoutElementR:setImage( RegisterImage( @"hash_634B575F15CDD376" ) )
	TitleLayoutElementR:setMaterial( LUI.UIImage.GetCachedMaterial( @"hash_F755127C95CF5B6" ) )
	TitleLayoutElementR:setShaderVector( 0, 3, 0, 0, 0 )
	self:addElement( TitleLayoutElementR )
	self.TitleLayoutElementR = TitleLayoutElementR
	
	local HeaderBackground = LUI.UIImage.new( 0.5, 0.5, -336.5 - 350, 336.5 + 350, 0.5, 0.5, -423, -231 )
	HeaderBackground:setRGB( 0.23, 0.23, 0.23 )
	HeaderBackground:setAlpha( 0.25 )
	self:addElement( HeaderBackground )
	self.HeaderBackground = HeaderBackground
	
	local HeaderTopBar = LUI.UIImage.new( 0.5, 0.5, -5, -1, 0.5, 0.5, -767, -90 )
	HeaderTopBar:setAlpha( 0.09 )
	HeaderTopBar:setZRot( 90 )
	HeaderTopBar:setImage( RegisterImage( @"hash_C49B0C8991A541F" ) )
	HeaderTopBar:setMaterial( LUI.UIImage.GetCachedMaterial( @"hash_67C9C02F608D0A75" ) )
	HeaderTopBar:setShaderVector( 0, 0, 0, 0, 0 )
	HeaderTopBar:setupNineSliceShader( 4, 8 )
	self:addElement( HeaderTopBar )
	self.HeaderTopBar = HeaderTopBar
	
	local HeaderBottomBar = LUI.UIImage.new( 0.5, 0.5, -5, -1, 0.5, 0.5, -566, 111 )
	HeaderBottomBar:setAlpha( 0.09 )
	HeaderBottomBar:setZRot( 90 )
	HeaderBottomBar:setImage( RegisterImage( @"hash_C49B0C8991A541F" ) )
	HeaderBottomBar:setMaterial( LUI.UIImage.GetCachedMaterial( @"hash_67C9C02F608D0A75" ) )
	HeaderBottomBar:setShaderVector( 0, 0, 0, 0, 0 )
	HeaderBottomBar:setupNineSliceShader( 4, 8 )
	self:addElement( HeaderBottomBar )
	self.HeaderBottomBar = HeaderBottomBar
	
	local BTNQuit = nil
	
	BTNQuit = CoD.PC_SmallCloseButton.new( f1_arg0, f1_arg1, 0.5, 0.5, 302 + 7, 336 + 7, 0.5, 0.5, -475, -441 )
	BTNQuit:setScale( 0.8, 0.8 )
	BTNQuit:registerEventHandler( "gain_focus", function ( element, event )
		local f5_local0 = nil
		if element.gainFocus then
			f5_local0 = element:gainFocus( event )
		elseif element.super.gainFocus then
			f5_local0 = element.super:gainFocus( event )
		end
		CoD.Menu.UpdateButtonShownState( element, f1_arg0, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"] )
		return f5_local0
	end )
	f1_arg0:AddButtonCallbackFunction( BTNQuit, f1_arg1, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], "ui_confirm", function ( element, menu, controller, model )
		GoBack( self, controller )
		return true
	end, function ( element, menu, controller )
		CoD.Menu.SetButtonLabel( menu, Enum[@"hash_3DD78803F918E9D"][@"hash_3755DA1E2E7C263F"], @"hash_0", nil, "ui_confirm" )
		return false
	end, false )
	self:addElement( BTNQuit )
	self.BTNQuit = BTNQuit
	
	--if CoD.isPC then
		buttons.id = "buttons"
	--end
	--if CoD.isPC then
		featureOverlayButtonMouseOnly.id = "featureOverlayButtonMouseOnly"
		ClearMusicButton.id = "ClearMusicButton"
		--ReloadModsOverlayButtonMouseOnly.id = "ReloadModsOverlayButtonMouseOnly"
	--end
	--if CoD.isPC then
		BTNQuit.id = "BTNQuit"
	--end
	LUI.OverrideFunction_CallOriginalSecond( self, "close", self.__onClose )
	if PostLoadFunc then
		PostLoadFunc( self, f1_arg1, f1_arg0 )
	end
	
	return self
end

CoD.MusicCommonCenteredPopup.__onClose = function ( f8_arg0 )
	f8_arg0.buttons:close()
	f8_arg0.featureOverlayButtonMouseOnly:close()
	f8_arg0.ClearMusicButton:close()
	f8_arg0.ZombiesMusicButton:close()
	f8_arg0.BlackoutMusicButton:close()
	f8_arg0.ClearALLMusicButton:close()
	f8_arg0.MultiPlayerMusicButton:close()	
	f8_arg0.TitleScreenMusicButton:close()
	--f8_arg0.ReloadModsOverlayButtonMouseOnly:close()
	f8_arg0.BTNQuit:close()
end

-- Music Manager
CoD.ShieldMusicManager = InheritFrom( CoD.Menu )
LUI.createMenu.ShieldMusicManager = function ( f1_arg0, f1_arg1 )
	local self = CoD.Menu.NewForUIEditor( "ShieldMusicManager", f1_arg0 )
	local f1_local1 = self
	self:setClass( CoD.ShieldMusicManager )
	self.soundSet = "none"
	self:setOwner( f1_arg0 )
	self:setLeftRight( 0, 1, 0, 0 )
	self:setTopBottom( 0, 1, 0, 0 )
	self:playSound( "menu_open", f1_arg0 )
	self.anyChildUsesUpdateState = true
	f1_local1:addElementToPendingUpdateStateList( self )

	-- reset selection
	Selected_Shield_Music = ""
	
	local CommomCenteredPopup = CoD.MusicCommonCenteredPopup.new( f1_local1, f1_arg0, 0, 1, 0, 0, 0, 1, 0, 0 )
	CommomCenteredPopup.TitleText:setText("Music Manager")
	CommomCenteredPopup.HeaderBackground:setAlpha( 0 )
	CommomCenteredPopup.HeaderTopBar:setAlpha( 0 )
	CommomCenteredPopup.HeaderBottomBar:setAlpha( 0 )
	self:addElement( CommomCenteredPopup )
	self.CommomCenteredPopup = CommomCenteredPopup

	local FeatMusicsText = LUI.UIText.new( 0.5, 0.5, -695 + 75, 695 + 75, 0.5, 0.5, 0 - 350, 35 - 350 )
	FeatMusicsText:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )
	FeatMusicsText:setTTF( "notosans_bold" )
	FeatMusicsText:setText("Music Available:")
	FeatMusicsText:setAlignment( Enum[@"luialignment"][@"lui_alignment_left"] )
	FeatMusicsText:setAlignment( Enum[@"luialignment"][@"lui_alignment_top"] )
	self:addElement( FeatMusicsText )
	self.FeatMusicsText = FeatMusicsText

	-- sep
	local HeaderPixSep = LUI.UIImage.new( 0.5, 0.5, 60, 90, 0.5, 0.5, -450, 450 )
	HeaderPixSep:setAlpha( 0 )
	HeaderPixSep:setImage( RegisterImage( @"hash_CB07CCC28498CB2" ) )
	--HeaderPixSep:setMaterial( LUI.UIImage.GetCachedMaterial( @"hash_16CBE95C250C6D15" ) )
	HeaderPixSep:setShaderVector( 0, 0, 0, 0, 0 )
	HeaderPixSep:setupNineSliceShader( 128, 128 )
	self:addElement( HeaderPixSep )
	self.HeaderPixSep = HeaderPixSep

	-- active, fucked up datasource widget, so inside a cod better
	local ActiveMusicListData = CoD.ActiveMusicListData.new( self, f1_arg0, 0.5, 0.5, -1100, 800, 0.5, 0.5, -535, 400 )
	self:addElement( ActiveMusicListData )
	self.ActiveMusicListData = ActiveMusicListData

	ActiveMusicListData.id = "ActiveMusicListData"
	
	self:mergeStateConditions( {
		{
			stateName = "KBM",
			condition = function ( menu, element, event )
				return IsMouseOrKeyboard( f1_arg0 )
			end
		}
	} )

	self:appendEventHandler( "input_source_changed", function ( f9_arg0, f9_arg1 )
		f9_arg1.menu = f9_arg1.menu or f1_local1
		f1_local1:updateElementState( self, f9_arg1 )
	end )
	local f1_local6 = self
	local f1_local7 = self.subscribeToModel
	local f1_local8 = Engine[@"getmodelforcontroller"]( f1_arg0 )
	f1_local7( f1_local6, f1_local8.LastInput, function ( f10_arg0 )
		f1_local1:updateElementState( self, {
			name = "model_validation",
			menu = f1_local1,
			controller = f1_arg0,
			modelValue = f10_arg0:get(),
			modelName = "LastInput"
		} )
	end, false )
	f1_local1:AddButtonCallbackFunction( self, f1_arg0, Enum[@"luibutton"][@"lui_key_xbb_pscircle"], nil, function ( element, menu, controller, model )
		GoBack( self, controller )
		ClearMenuSavedState( menu )
		ForceNotifyGlobalModel( controller, "GametypeSettings.Update" )
		return true
	end, function ( element, menu, controller )
		CoD.Menu.SetButtonLabel( menu, Enum[@"luibutton"][@"lui_key_xbb_pscircle"], @"menu/back", nil, nil )
		return true
	end, false )
	CommomCenteredPopup.buttons:setModel( self.buttonModel, f1_arg0 )
	if CoD.isPC then
		CommomCenteredPopup.id = "CommomCenteredPopup"
	end

	--if CoD.isPC then
	--	PCSmallCloseButton.id = "PCSmallCloseButton"
	--end

	self:processEvent( {
		name = "menu_loaded",
		controller = f1_arg0
	} )

	self.__defaultFocus = ActiveMusicListData
	if CoD.isPC and (IsKeyboard( f1_arg0 ) or self.ignoreCursor) then
		self:restoreState( f1_arg0 )
	end
	LUI.OverrideFunction_CallOriginalSecond( self, "close", self.__onClose )
	if PostLoadFunc then
		PostLoadFunc( self, f1_arg0 )
	end
	
	f1_local7 = self
	--MenuHidesFreeCursor( f1_local1, f1_arg0 )

	CoD.EnhPrintInfo("Called", "Shield's Music Manager")

	return self
end

CoD.ShieldMusicManager.__resetProperties = function ( f13_arg0 )

end

CoD.ShieldMusicManager.__clipsPerState = {
	DefaultState = {
		DefaultClip = function ( f14_arg0, f14_arg1 )
			f14_arg0:__resetProperties()
			f14_arg0:setupElementClipCounter( 0 )
		end
	},
	KBM = {
		DefaultClip = function ( f15_arg0, f15_arg1 )
			f15_arg0:__resetProperties()
			f15_arg0:setupElementClipCounter( 2 )
		end
	}
}

CoD.ShieldMusicManager.__onClose = function ( f16_arg0 )
	f16_arg0.CommomCenteredPopup:close()
	f16_arg0.HeaderPixSep:close()
	f16_arg0.FeatMusicsText:close()
	f16_arg0.ActiveMusicListData:close()
end