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
    
    -- by their names, as the menu lists them
    table.sort(shield_musics, function ( a, b )
        if a.name ~= b.name then
            return a.name < b.name
        end
        return a.file_path < b.file_path
    end)

    -- the menu shows them when it is open, see CoD.ShieldMusicBody
    if CoD.Shield.OnMusicListChanged then
        CoD.Shield.OnMusicListChanged()
    end
end

-- load them
Engine[@"exec"](Engine[@"getprimarycontroller"](), "MM_push_musics")

---------------------------

--[[
	The menu, drawn with the parts of the lobby browser: CoD.Shield.BrowserUI of LobbyBrowser.lua, read when a menu is made.
	A track is picked in the list, and given to a place by a click on that place in the card: the main menu,
	multiplayer, zombies, blackout. What a place plays is kept in its dvar and in the settings file, as before.
]]

-- the places music plays in: the dvar and the name in the settings file each is kept under
local MusicSlots = {
	{ key = "tr", label = "MAIN MENU", tag = "MENU", name = "The Main Menu", dvar = "Shield_TR_Music", json = "tr_music", color = { r = 1, g = 0.8, b = 0.25 } },
	{ key = "mp", label = "MULTIPLAYER", tag = "MP", name = "Multiplayer", dvar = "Shield_MP_Music", json = "mp_music", color = { r = 0.35, g = 0.75, b = 1 } },
	{ key = "zm", label = "ZOMBIES", tag = "ZM", name = "Zombies", dvar = "Shield_ZM_Music", json = "zm_music", color = { r = 1, g = 0.38, b = 0.28 } },
	{ key = "wz", label = "BLACKOUT", tag = "WZ", name = "Blackout", dvar = "Shield_WZ_Music", json = "wz_music", color = { r = 0.45, g = 0.9, b = 0.45 } }
}

-- the colour of the menu
local MusicColor = { r = 0.78, g = 0.55, b = 1 }

-- the track picked in the list, what each place plays, and whether the music has to be started again when the menu closes
local Music = {
	selected = "",
	slots = {},
	changed = false
}

-- a row knows by these which track is picked, and when a place was given another one
local function MusicModel( name )
	return Engine[@"createmodel"]( Engine[@"getglobalmodel"](), "ShieldMusicManager." .. name )
end

local function TrackOf( path )
	for _, track in ipairs( shield_musics ) do
		if track.file_path == path then
			return track
		end
	end
	return nil
end

-- what each place plays, from the dvars the settings file filled: "none" for the music of the game
local function ReadMusicSlots()
	for _, slot in ipairs( MusicSlots ) do
		local value = Engine[@"getdvarstring"]( slot.dvar )

		if type( value ) ~= "string" or value == "" then
			value = "none"
		end

		Music.slots[slot.key] = value
	end
end

-- the rows and the card show the places again
local function TellMusicSlots()
	local model = MusicModel( "slots" )
	model:set( ( model:get() or 0 ) + 1 )
end

-- a place plays that track from now on, "none" for the music of the game
local function SetMusicSlot( slot, path )
	local controller = Engine[@"getprimarycontroller"]()

	Music.slots[slot.key] = path
	Music.changed = true

	-- at once for what plays the music, by the console as it was set before, and to the settings file
	Engine[@"setdvar"]( slot.dvar, path )
	Engine[@"exec"]( controller, "set " .. slot.dvar .. ' "' .. path .. '"' )
	Engine[@"exec"]( controller, "writejson lua " .. slot.json .. ' "' .. path .. '" string' )
end

-- plays a track now, in the place of whatever the menu plays
local function PreviewMusic( path )
	local controller = Engine[@"getprimarycontroller"]()

	Engine[@"exec"]( controller, "shield_stop" )
	Engine[@"playmenumusic"]( "" )
	Engine[@"exec"]( controller, 'shield_play "project-bo4\\music_manager\\music\\' .. path .. '" "" 1 1 0' )

	OldMusicName = path
	Music.changed = true
end

-- the music of the lobby menu the game is in again, by what the places say now
local function RestoreLobbyMusic()
	local screen = Engine[@"getlobbyuiscreen"]()

	OldMusicName = ""
	OldLobbyMusic = ""

	Engine[@"exec"]( Engine[@"getprimarycontroller"](), "shield_stop" )

	if LobbyData.GetLobbyMenuByID( screen ) ~= nil then
		CoD.PlayFrontendMusicForLobby( screen )
	end
end

DataSources.ShieldMusicTracksEmpty = DataSourceHelpers.ListSetup( "ShieldMusicTracksEmpty", function ( f3_arg0, f3_arg1 )
	return {}
end, true )

DataSources.ShieldMusicTracks = DataSourceHelpers.ListSetup( "ShieldMusicTracks", function ( f3_arg0, f3_arg1 )
	local items = {}

	for _, track in ipairs( shield_musics ) do
		table.insert( items, {
			models = {
				Name = track.display_name,
				Author = track.author,
				Length = track.length,
				Path = track.file_path
			},
			properties = {

			}
		} )
	end

	return items
end, true )

---------------------------

--[[
	The body, 1744 by 740.
	Left, 1060 wide: the title, the names of the columns, and ten tracks.
	Right, from 1084, 660 wide: the card of the track picked, with the places it can play in and the shuffle,
	and under it the buttons that look for tracks again and that take every place back.
]]
local MUSIC_CARD_LEFT = 1084
local MUSIC_CARD_RIGHT = 1744
local MUSIC_CARD_BOTTOM = 680
local MUSIC_TEXT_LEFT = MUSIC_CARD_LEFT + 24
local MUSIC_TEXT_RIGHT = MUSIC_CARD_RIGHT - 24
local MUSIC_BUTTON_RIGHT = MUSIC_TEXT_LEFT + 220
local MUSIC_HINT_LEFT = MUSIC_BUTTON_RIGHT + 18
local MUSIC_LIST_TOP = 86
local MUSIC_ROW_HEIGHT = 60
local MUSIC_ROW_TEXT_LEFT = 24
local MUSIC_ROW_PILLS_LEFT = 600
local MUSIC_SLOTS_TOP = 286

local function SetButtonWords( button, words )
	button.MiddleText:setText( words )
	button.MiddleTextFocus:setText( words )
end

-- the line under a button that is on, in that colour
local function AddActiveMark( button, color )
	local mark = LUI.UIImage.new( 0, 1, 0, 0, 1, 1, -3, 0 )
	mark:setRGB( color.r, color.g, color.b )
	mark:setAlpha( 0 )
	button:addElement( mark )
	button.ActiveMark = mark
end

CoD.ShieldMusicBody = InheritFrom( LUI.UIElement )
CoD.ShieldMusicBody.__defaultWidth = 1744
CoD.ShieldMusicBody.__defaultHeight = 740
CoD.ShieldMusicBody.new = function ( f1_arg0, f1_arg1, f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	local UI = CoD.Shield.BrowserUI

	local self = LUI.UIElement.new( f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	self:setClass( CoD.ShieldMusicBody )
	self.id = "ShieldMusicBody"
	self.soundSet = "default"
	self.onlyChildrenFocusable = true
	self.anyChildUsesUpdateState = true

	-- everything of the body that is only closed with it
	self.Parts = {}
	self.Buttons = {}

	local function Add( element )
		self:addElement( element )
		table.insert( self.Parts, element )
		return element
	end

	-- a button of the body: the menu finds what can take the focus as parent[id], so it is kept under its id
	local function AddButton( id, label, left, right, top, bottom, action )
		local button = UI.NewBrowserButton( self, f1_arg0, f1_arg1, label, left, right, top, bottom )
		self:addElement( button )
		button.id = id
		self[id] = button
		table.insert( self.Buttons, button )
		UI.OnBrowserButton( f1_arg0, f1_arg1, button, action )
		return button
	end

	local function AddHint( left, right, top, words )
		local text = Add( UI.NewText( left, right, top, 16, "ttmussels_regular" ) )
		text:setRGB( 0.6, 0.6, 0.6 )
		text:setText( words )
		return text
	end

	---------------------------
	-- the list of the tracks

	local Tracks = LUI.UIList.new( f1_arg0, f1_arg1, 7, 0, nil, false, false, false, false )
	Tracks:setLeftRight( 0, 0, 0, 1060 )
	Tracks:setTopBottom( 0, 0, MUSIC_LIST_TOP, MUSIC_LIST_TOP + 654 )

	-- filled a moment after the menu is up, and when the client tells its tracks
	Tracks:setDataSource( "ShieldMusicTracksEmpty" )

	Tracks:setWidgetType( CoD.ShieldMusicRow )
	Tracks:setVerticalCount( 10 )
	Tracks:setSpacing( 6 )

	Tracks:setAlignment( Enum[@"luialignment"][@"lui_alignment_left"] )
	Tracks:setVerticalCounter( CoD.verticalCounter )
	Tracks:appendEventHandler( "input_source_changed", function ( f2_arg0, f2_arg1 )
		f2_arg1.menu = f2_arg1.menu or f1_arg0
		CoD.Menu.UpdateButtonShownState( f2_arg0, f1_arg0, f1_arg1, Enum[@"luibutton"][@"lui_key_xba_pscross"] )
	end )

	Tracks:registerEventHandler( "gain_focus", function ( element, event )
		local f5_local0 = nil
		if element.gainFocus then
			f5_local0 = element:gainFocus( event )
		elseif element.super.gainFocus then
			f5_local0 = element.super:gainFocus( event )
		end
		CoD.Menu.UpdateButtonShownState( element, f1_arg0, f1_arg1, Enum[@"luibutton"][@"lui_key_xba_pscross"] )
		return f5_local0
	end )

	-- A list keeps the row it was scrolled to when its rows change: emptied, it is put back to its top before the new rows come.
	local function ReloadTracks()
		Tracks:setDataSource( "ShieldMusicTracksEmpty" )
		Tracks:updateDataSource()
		Tracks:clearLayout()
		Tracks:clearSavedActiveIndex()
		Tracks:setDataSource( "ShieldMusicTracks" )
		Tracks:updateDataSource()
	end

	---------------------------
	-- over the tracks: the title, how many there are, and where they are looked for

	local Title = Add( UI.NewText( 0, 400, -4, 32, "notosans_bold" ) )
	Title:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )
	Title:setText( "YOUR MUSIC" )

	local CountText = Add( UI.NewText( 2, 400, 30, 14, "ttmussels_regular" ) )
	CountText:setRGB( 0.55, 0.55, 0.55 )
	CountText:setLetterSpacing( 2 )

	local Folder = Add( UI.NewText( 420, 1060, 6, 16, "ttmussels_regular", Enum[@"luialignment"][@"lui_alignment_right"] ) )
	Folder:setRGB( 0.6, 0.6, 0.6 )
	Folder:setText( "Tracks are the files of  project-bo4\\music_manager\\music" )

	local Formats = Add( UI.NewText( 420, 1060, 28, 14, "ttmussels_regular", Enum[@"luialignment"][@"lui_alignment_right"] ) )
	Formats:setRGB( 0.42, 0.42, 0.42 )
	Formats:setLetterSpacing( 1 )
	Formats:setText( "MP3  WAV  OGG  FLAC  M4A  AAC" )

	-- the names of the columns, where the rows have them
	Add( UI.NewCaption( MUSIC_ROW_TEXT_LEFT, 560, 56, "TRACK" ) )
	Add( UI.NewCaption( MUSIC_ROW_PILLS_LEFT, 900, 56, "PLAYS IN" ) )
	Add( UI.NewCaption( 900, 1040, 56, "LENGTH", Enum[@"luialignment"][@"lui_alignment_right"] ) )
	Add( UI.NewBox( 0, 1060, 78, 79, 1, 1, 1, 0.12 ) )

	-- in the place of the rows while there is none
	local EmptyTitle = Add( UI.NewText( 0, 1060, MUSIC_LIST_TOP + 250, 30, "notosans_bold", Enum[@"luialignment"][@"lui_alignment_center"] ) )
	EmptyTitle:setRGB( 0.75, 0.75, 0.75 )
	EmptyTitle:setText( "No music found" )

	local EmptyText = Add( UI.NewText( 0, 1060, MUSIC_LIST_TOP + 292, 20, "ttmussels_regular", Enum[@"luialignment"][@"lui_alignment_center"] ) )
	EmptyText:setRGB( 0.5, 0.5, 0.5 )
	EmptyText:setText( "Put your tracks in the folder named above, then look again." )

	---------------------------
	-- the card of the track picked

	Add( UI.NewBox( MUSIC_CARD_LEFT, MUSIC_CARD_RIGHT, 0, MUSIC_CARD_BOTTOM, 0, 0, 0, 0.5 ) )
	Add( UI.NewBox( MUSIC_CARD_LEFT, MUSIC_CARD_RIGHT, 0, 4, MusicColor.r, MusicColor.g, MusicColor.b, 1 ) )

	local CardFrame = LUI.UIImage.new( 0, 0, MUSIC_CARD_LEFT - 1, MUSIC_CARD_RIGHT + 1, 0, 0, -1, MUSIC_CARD_BOTTOM + 1 )
	CardFrame:setAlpha( 0.12 )
	CardFrame:setImage( RegisterImage( @"uie_ui_menu_store_common_frame" ) )
	CardFrame:setMaterial( LUI.UIImage.GetCachedMaterial( @"uie_nineslice_add" ) )
	CardFrame:setShaderVector( 0, 0, 0, 0, 0 )
	CardFrame:setupNineSliceShader( 12, 12 )
	Add( CardFrame )

	-- the parts of the card that change with the pick
	local Card = {}

	Add( UI.NewCaption( MUSIC_TEXT_LEFT, MUSIC_TEXT_RIGHT - 140, 24, "SELECTED TRACK" ) )

	Card.Title = Add( UI.NewText( MUSIC_TEXT_LEFT, MUSIC_TEXT_RIGHT - 140, 46, 40, "notosans_bold" ) )
	Card.Title:setRGB( 1, 1, 1 )

	Card.Author = Add( UI.NewText( MUSIC_TEXT_LEFT, MUSIC_TEXT_RIGHT, 98, 22, "ttmussels_regular" ) )
	Card.Author:setRGB( 0.7, 0.7, 0.7 )
	Card.Author:setLetterSpacing( 1 )

	Add( UI.NewCaption( MUSIC_TEXT_RIGHT - 130, MUSIC_TEXT_RIGHT, 24, "LENGTH", Enum[@"luialignment"][@"lui_alignment_right"] ) )

	Card.Length = Add( UI.NewText( MUSIC_TEXT_RIGHT - 130, MUSIC_TEXT_RIGHT, 48, 32, "0arame_mono_stencil", Enum[@"luialignment"][@"lui_alignment_right"] ) )
	Card.Length:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )

	AddHint( MUSIC_HINT_LEFT, MUSIC_TEXT_RIGHT, 146, "Plays it now. The music of the menu you are in comes back when you leave here." )

	Add( UI.NewBox( MUSIC_TEXT_LEFT, MUSIC_TEXT_RIGHT, 206, 207, 1, 1, 1, 0.1 ) )

	Add( UI.NewCaption( MUSIC_TEXT_LEFT, MUSIC_TEXT_RIGHT, 222, "WHERE IT PLAYS" ) )
	Card.SlotsHint = AddHint( MUSIC_TEXT_LEFT, MUSIC_TEXT_RIGHT, 246, "" )

	-- beside each place: the track it plays
	Card.SlotTexts = {}

	for index, slot in ipairs( MusicSlots ) do
		local top = MUSIC_SLOTS_TOP + ( index - 1 ) * 64

		Card.SlotTexts[slot.key] = Add( UI.NewText( MUSIC_HINT_LEFT, MUSIC_TEXT_RIGHT, top + 13, 22, "ttmussels_regular" ) )
	end

	Add( UI.NewBox( MUSIC_TEXT_LEFT, MUSIC_TEXT_RIGHT, 548, 549, 1, 1, 1, 0.1 ) )

	AddHint( MUSIC_HINT_LEFT, MUSIC_TEXT_RIGHT, 574, "A random track of yours in every lobby. The places above are not used while it is on." )

	---------------------------
	-- what the menu shows of the tracks, the pick and the places

	self.SlotButtons = {}

	local function ShowMusic()
		local count = #shield_musics
		local track = TrackOf( Music.selected )
		local shuffle = Engine[@"getdvarint"]( "Shield_Random_Music" ) == 1

		if count == 0 then
			CountText:setText( "NO TRACKS" )
			EmptyTitle:setAlpha( 1 )
			EmptyText:setAlpha( 1 )
		else
			CountText:setText( count == 1 and "1 TRACK" or ( count .. " TRACKS" ) )
			EmptyTitle:setAlpha( 0 )
			EmptyText:setAlpha( 0 )
		end

		if track ~= nil then
			Card.Title:setText( UI.ShortenText( track.display_name, 22 ) )
			Card.Author:setText( track.author ~= "Unknown" and ( "BY " .. ToUpper( track.author ) ) or "UNKNOWN ARTIST" )
			Card.Length:setText( track.length )
		else
			Card.Title:setText( "No track" )
			Card.Author:setText( "PICK ONE IN THE LIST" )
			Card.Length:setText( "-" )
		end

		for _, slot in ipairs( MusicSlots ) do
			local playing = TrackOf( Music.slots[slot.key] )
			local text = Card.SlotTexts[slot.key]
			local button = self.SlotButtons[slot.key]

			if playing ~= nil then
				text:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )
				text:setText( UI.ShortenText( playing.display_name, 34 ) )
			else
				text:setRGB( 0.45, 0.45, 0.45 )
				text:setText( "The music of the game" )
			end

			-- the line under a place that plays the track picked, and all of them dim while the shuffle is on
			if button ~= nil then
				button.ActiveMark:setAlpha( ( track ~= nil and Music.slots[slot.key] == Music.selected ) and 1 or 0 )
				button:setAlpha( shuffle and 0.45 or 1 )
			end
		end

		if shuffle then
			Card.SlotsHint:setText( "^3Not used while the shuffle is on. Turn it off to give a place its own track." )
		else
			Card.SlotsHint:setText( "Click a place to give it the selected track. Click it again to take the track away." )
		end

		if self.ShuffleButton ~= nil then
			SetButtonWords( self.ShuffleButton, shuffle and "SHUFFLE: ON" or "SHUFFLE: OFF" )
			self.ShuffleButton.ActiveMark:setAlpha( shuffle and 1 or 0 )
		end
	end

	-- the track picked: the one of before when it is still there, else the first
	local function PickTrack( path )
		if TrackOf( path ) == nil then
			path = shield_musics[1] and shield_musics[1].file_path or ""
		end

		Music.selected = path
		MusicModel( "selected" ):set( path )
	end

	---------------------------
	-- the buttons of the card

	AddButton( "PreviewButton", "PREVIEW", MUSIC_TEXT_LEFT, MUSIC_BUTTON_RIGHT, 140, 188, function ()
		local track = TrackOf( Music.selected )

		if track == nil then
			PlaySoundAlias( "uin_unavailable_click" )
			CoD.Shield.MusicManagerToastUpdate( "Pick a track in the list first." )
			return
		end

		PlaySoundAlias( "uin_toggle_generic" )
		PreviewMusic( track.file_path )
	end )

	for index, slot in ipairs( MusicSlots ) do
		local top = MUSIC_SLOTS_TOP + ( index - 1 ) * 64

		local button = AddButton( "Slot" .. index, slot.label, MUSIC_TEXT_LEFT, MUSIC_BUTTON_RIGHT, top, top + 48, function ()
			-- the places are not used while the shuffle is on: a click does nothing but say so
			if Engine[@"getdvarint"]( "Shield_Random_Music" ) == 1 then
				PlaySoundAlias( "uin_unavailable_click" )
				CoD.Shield.MusicManagerToastUpdate( "Shuffle is on. Turn it off to give a place its own track." )
				return
			end

			local track = TrackOf( Music.selected )

			if track == nil then
				PlaySoundAlias( "uin_unavailable_click" )
				CoD.Shield.MusicManagerToastUpdate( "Pick a track in the list first." )
				return
			end

			PlaySoundAlias( "uin_paint_image_flip_toggle" )

			if Music.slots[slot.key] == track.file_path then
				SetMusicSlot( slot, "none" )
				CoD.Shield.MusicManagerToastUpdate( slot.name .. " plays the music of the game again." )
			else
				SetMusicSlot( slot, track.file_path )
				CoD.Shield.MusicManagerToastUpdate( slot.name .. " now plays " .. track.display_name .. "." )
			end

			TellMusicSlots()
			ShowMusic()
		end )

		AddActiveMark( button, slot.color )
		self.SlotButtons[slot.key] = button
	end

	local ShuffleButton = AddButton( "ShuffleButton", "SHUFFLE: OFF", MUSIC_TEXT_LEFT, MUSIC_BUTTON_RIGHT, 568, 616, function ()
		local shuffle = Engine[@"getdvarint"]( "Shield_Random_Music" ) == 1 and 0 or 1

		PlaySoundAlias( "uin_paint_image_flip_toggle" )

		Engine[@"setdvar"]( "Shield_Random_Music", shuffle )
		Engine[@"exec"]( Engine[@"getprimarycontroller"](), "writejson lua music_random " .. shuffle .. " uint64_t" )

		Music.changed = true
		ShowMusic()
	end )

	AddActiveMark( ShuffleButton, MusicColor )
	self.ShuffleButton = ShuffleButton

	---------------------------
	-- under the card: look for tracks again, and every place back to the music of the game

	AddButton( "RescanButton", "LOOK AGAIN", MUSIC_CARD_LEFT, MUSIC_CARD_LEFT + 324, 692, 740, function ()
		PlaySoundAlias( "uin_paint_image_flip_toggle" )
		CoD.Shield.MusicManagerToastUpdate( "Looking for music..." )
		Engine[@"exec"]( Engine[@"getprimarycontroller"](), "MM_push_musics" )
	end )

	AddButton( "ClearButton", "CLEAR EVERY PLACE", MUSIC_CARD_RIGHT - 324, MUSIC_CARD_RIGHT, 692, 740, function ()
		PlaySoundAlias( "uin_paint_image_flip_toggle" )

		for _, slot in ipairs( MusicSlots ) do
			if Music.slots[slot.key] ~= "none" then
				SetMusicSlot( slot, "none" )
			end
		end

		CoD.Shield.MusicManagerToastUpdate( "Every place plays the music of the game again." )
		TellMusicSlots()
		ShowMusic()
	end )

	---------------------------
	-- the rows

	f1_arg0:AddButtonCallbackFunction( Tracks, f1_arg1, Enum[@"luibutton"][@"lui_key_xba_pscross"], "ui_confirm", function ( element, menu, controller, model )
		if ( IsGamepad( controller ) or IsMouseOrKeyboard( controller ) ) and element.TrackPath ~= nil then
			PlaySoundAlias( "uin_toggle_generic" )
			PickTrack( element.TrackPath )
			ShowMusic()
			return true
		end
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

	self:addElement( Tracks )
	self.Tracks = Tracks
	Tracks.id = "Tracks"

	-- the client told its tracks: the rows a moment later, as the browser fills its own
	CoD.Shield.OnMusicListChanged = function ()
		PickTrack( Music.selected )
		ShowMusic()

		Tracks:addElement( LUI.UITimer.newElementTimer( 5, true, function ()
			ReloadTracks()
		end ) )
	end

	CoD.Shield.OnMusicListChanged()

	-- and it is asked for them again: a track can be new since the game started
	Engine[@"exec"]( Engine[@"getprimarycontroller"](), "MM_push_musics" )

	LUI.OverrideFunction_CallOriginalSecond( self, "close", self.__onClose )

	if PostLoadFunc then
		PostLoadFunc( self, f1_arg1, f1_arg0 )
	end

	return self
end

CoD.ShieldMusicBody.__onClose = function ( f9_arg0 )
	CoD.Shield.OnMusicListChanged = nil

	for _, element in ipairs( f9_arg0.Parts ) do
		element:close()
	end
	for _, button in ipairs( f9_arg0.Buttons ) do
		button:close()
	end
	f9_arg0.Tracks:close()
end

---------------------------

--[[
	A track, 1060 by 60: its name over who made it, the places that play it, and how long it is.
	The one picked keeps the colour of the menu and a bar at its end.
]]

-- what of a row changes with the focus
local MusicRowFocusParts = {
	{ "BlackBar", function ( element, focus ) element:setAlpha( focus and 0.1 or 0.05 ) end },
	{ "Tint", function ( element, focus ) element:setAlpha( focus and 0.16 or 0 ) end },
	{ "FocusFrame", function ( element, focus ) element:setAlpha( focus and 1 or 0 ) end },
	{ "Accent", function ( element, focus ) element:setLeftRight( 0, 0, 0, focus and 7 or 4 ) end }
}

-- the clip of the rows of the browser, looked up when it plays: that file may be loaded after this one
local function MusicRowClip( focus, duration )
	return function ( self, event )
		return CoD.Shield.BrowserUI.FocusClip( MusicRowFocusParts, focus, duration )( self, event )
	end
end

CoD.ShieldMusicRow = InheritFrom( LUI.UIElement )
CoD.ShieldMusicRow.__defaultWidth = 1060
CoD.ShieldMusicRow.__defaultHeight = MUSIC_ROW_HEIGHT
CoD.ShieldMusicRow.new = function ( f1_arg0, f1_arg1, f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	local UI = CoD.Shield.BrowserUI

	local self = LUI.UIElement.new( f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	self:setClass( CoD.ShieldMusicRow )
	self.id = "ShieldMusicRow"
	self.soundSet = "default"
	f1_arg0:addElementToPendingUpdateStateList( self )

	self.Parts = {}

	local function Add( element )
		self:addElement( element )
		table.insert( self.Parts, element )
		return element
	end

	local BlackBar = LUI.UIImage.new( 0, 1, 0, 0, 0, 1, 0, 0 )
	BlackBar:setRGB( 1, 1, 1 )
	BlackBar:setAlpha( 0.05 )
	Add( BlackBar )
	self.BlackBar = BlackBar

	-- the colour of the menu over the row in focus
	local Tint = LUI.UIImage.new( 0, 1, 0, 0, 0, 1, 0, 0 )
	Tint:setRGB( MusicColor.r, MusicColor.g, MusicColor.b )
	Tint:setAlpha( 0 )
	Add( Tint )
	self.Tint = Tint

	-- and over the row picked, which no clip touches
	local Chosen = LUI.UIImage.new( 0, 1, 0, 0, 0, 1, 0, 0 )
	Chosen:setRGB( MusicColor.r, MusicColor.g, MusicColor.b )
	Chosen:setAlpha( 0 )
	Add( Chosen )

	-- the bar at the start of the row
	local Accent = LUI.UIImage.new( 0, 0, 0, 4, 0, 1, 0, 0 )
	Accent:setRGB( MusicColor.r, MusicColor.g, MusicColor.b )
	Add( Accent )
	self.Accent = Accent

	local Name = Add( UI.NewText( MUSIC_ROW_TEXT_LEFT, MUSIC_ROW_PILLS_LEFT - 20, 7, 24, "notosans_bold" ) )
	Name:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )

	local Author = Add( UI.NewText( MUSIC_ROW_TEXT_LEFT, MUSIC_ROW_PILLS_LEFT - 20, 36, 16, "ttmussels_regular" ) )
	Author:setRGB( 0.55, 0.55, 0.55 )
	Author:setLetterSpacing( 1 )

	-- the places, each lit in its colour when it plays this track
	local Pills = {}

	for index, slot in ipairs( MusicSlots ) do
		local left = MUSIC_ROW_PILLS_LEFT + ( index - 1 ) * 72

		local box = Add( UI.NewBox( left, left + 64, 19, 41, 1, 1, 1, 0.13 ) )

		local text = Add( UI.NewText( left, left + 64, 23, 14, "notosans_bold", Enum[@"luialignment"][@"lui_alignment_center"] ) )
		text:setText( slot.tag )

		Pills[slot.key] = { box = box, text = text }
	end

	local Length = Add( UI.NewText( 900, 1040, 17, 26, "0arame_mono_stencil", Enum[@"luialignment"][@"lui_alignment_right"] ) )
	Length:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )

	-- the bar at the end of the row picked
	local ChosenMark = LUI.UIImage.new( 1, 1, -8, 0, 0, 1, 0, 0 )
	ChosenMark:setRGB( MusicColor.r, MusicColor.g, MusicColor.b )
	ChosenMark:setAlpha( 0 )
	Add( ChosenMark )

	-- the frame of the game around the row in focus
	local FocusFrame = LUI.UIImage.new( 0, 1, -4, 4, 0, 1, -4, 4 )
	FocusFrame:setRGB( MusicColor.r, MusicColor.g, MusicColor.b )
	FocusFrame:setAlpha( 0 )
	FocusFrame:setImage( RegisterImage( @"uie_ui_menu_store_focus_frame" ) )
	FocusFrame:setMaterial( LUI.UIImage.GetCachedMaterial( @"uie_nineslice_add" ) )
	FocusFrame:setShaderVector( 0, 0, 0, 0, 0 )
	FocusFrame:setupNineSliceShader( 10, 10 )
	Add( FocusFrame )
	self.FocusFrame = FocusFrame

	local SelectedModel = MusicModel( "selected" )
	local SlotsModel = MusicModel( "slots" )

	-- whether the row is the one picked, and which places play its track
	local function ShowState()
		local chosen = self.TrackPath ~= nil and SelectedModel:get() == self.TrackPath

		Chosen:setAlpha( chosen and 0.14 or 0 )
		ChosenMark:setAlpha( chosen and 1 or 0 )

		for _, slot in ipairs( MusicSlots ) do
			local pill = Pills[slot.key]

			if self.TrackPath ~= nil and Music.slots[slot.key] == self.TrackPath then
				pill.box:setRGB( slot.color.r, slot.color.g, slot.color.b )
				pill.box:setAlpha( 1 )
				pill.text:setRGB( 0.04, 0.04, 0.04 )
			else
				pill.box:setRGB( 1, 1, 1 )
				pill.box:setAlpha( 0.13 )
				pill.text:setRGB( 0.66, 0.66, 0.66 )
			end
		end
	end

	-- everything of the row is read when its name is set: the list makes a row whole before it gives it
	Name:linkToElementModel( self, "Name", true, function ( model )
		if model:get() == nil then
			return
		end

		local author = CoD.ModelUtility.GetSelfModelPathValue( self, "Author" ) or "Unknown"

		-- what the click and the marks read of the row
		self.TrackPath = CoD.ModelUtility.GetSelfModelPathValue( self, "Path" )

		Name:setText( UI.ShortenText( model:get(), 44 ) )
		Author:setText( author ~= "Unknown" and ToUpper( UI.ShortenText( author, 50 ) ) or "UNKNOWN ARTIST" )
		Length:setText( CoD.ModelUtility.GetSelfModelPathValue( self, "Length" ) or "" )

		ShowState()
	end )

	self:subscribeToModel( SelectedModel, function ( model )
		ShowState()
	end )

	self:subscribeToModel( SlotsModel, function ( model )
		ShowState()
	end )

	LUI.OverrideFunction_CallOriginalSecond( self, "close", self.__onClose )

	if PostLoadFunc then
		PostLoadFunc( self, f1_arg1, f1_arg0 )
	end

	return self
end

CoD.ShieldMusicRow.__resetProperties = function ( f7_arg0 )
	for _, part in ipairs( MusicRowFocusParts ) do
		local element = f7_arg0[part[1]]
		element:completeAnimation()
		part[2]( element, false )
	end
end

CoD.ShieldMusicRow.__clipsPerState = {
	DefaultState = {
		DefaultClip = MusicRowClip( false ),
		Focus = MusicRowClip( true ),
		GainFocus = MusicRowClip( true, 120 ),
		LoseFocus = MusicRowClip( false, 120 )
	}
}

CoD.ShieldMusicRow.__onClose = function ( f10_arg0 )
	for _, element in ipairs( f10_arg0.Parts ) do
		element:close()
	end
end

---------------------------

-- Safe area of the menu: the header of the game over the body
CoD.Shield_SafeAreaContainer_MusicManager = InheritFrom( LUI.UIElement )
CoD.Shield_SafeAreaContainer_MusicManager.__defaultWidth = 1920
CoD.Shield_SafeAreaContainer_MusicManager.__defaultHeight = 1080
CoD.Shield_SafeAreaContainer_MusicManager.new = function ( f1_arg0, f1_arg1, f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	local self = LUI.UIElement.new( f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	self:setClass( CoD.Shield_SafeAreaContainer_MusicManager )
	self.id = "Shield_SafeAreaContainer_MusicManager"
	self.soundSet = "none"
	self.onlyChildrenFocusable = true
	self.anyChildUsesUpdateState = true

	local TabBacking = CoD.CommonTabBarBacking.new( f1_arg0, f1_arg1, -0.1, 1.1, 0, 0, 0, 0, 52, 89 )
	TabBacking.TabBackingBlur:setAlpha( 0 )
	self:addElement( TabBacking )
	self.TabBacking = TabBacking

	local CommonHeader = CoD.CommonHeader.new( f1_arg0, f1_arg1, 0, 1, 0, 0, 0, 0, 0, 67 )
	CommonHeader.subtitle.StageTitle:setText("^2Music Manager")
	CommonHeader.subtitle.subtitle:setText("^3Your Own Menu Music")
	self:addElement( CommonHeader )
	self.CommonHeader = CommonHeader

	local HeaderStripe = CoD.header_container_frontend.new( f1_arg0, f1_arg1, 0, 1, 0, 0, 0, 0, 0, 42 )
	self:addElement( HeaderStripe )
	self.HeaderStripe = HeaderStripe

	-- the body: from 88 to 1832 of the 1920 across, from 140 to 880 down
	local ShieldMusicBody = CoD.ShieldMusicBody.new( f1_arg0, f1_arg1, 0.5, 0.5, -872, 872, 0, 0, 140, 880 )
	self:addElement( ShieldMusicBody )
	self.ShieldMusicBody = ShieldMusicBody

	ShieldMusicBody.id = "ShieldMusicBody"

	LUI.OverrideFunction_CallOriginalSecond( self, "close", self.__onClose )

	if PostLoadFunc then
		PostLoadFunc( self, f1_arg1, f1_arg0 )
	end

	return self
end

CoD.Shield_SafeAreaContainer_MusicManager.__onClose = function ( f5_arg0 )
	f5_arg0.TabBacking:close()
	f5_arg0.CommonHeader:close()
	f5_arg0.HeaderStripe:close()
	f5_arg0.ShieldMusicBody:close()
end

---------------------------

-- the menu, opened from the main menu
CoD.ShieldMusicManager = InheritFrom( CoD.Menu )
LUI.createMenu.ShieldMusicManager = function ( f1_arg0, f1_arg1 )
	local self = CoD.Menu.NewForUIEditor( "ShieldMusicManager", f1_arg0 )
	local f1_local1 = self

	self:setClass( CoD.ShieldMusicManager )
	self.soundSet = "default"
	self:setOwner( f1_arg0 )
	self:setLeftRight( 0, 1, 0, 0 )
	self:setTopBottom( 0, 1, 0, 0 )
	self:playSound( "menu_open", f1_arg0 )
	self.anyChildUsesUpdateState = true

	-- what the places play, as the settings file has it
	ReadMusicSlots()
	Music.changed = false

	local Background = CoD.StartMenuOptionsBackground.new( f1_local1, f1_arg0, 0, 1, 0, 0, 0, 1, 0, 0 )
	self:addElement( Background )
	self.Background = Background

	local FooterContainerFrontendRight = CoD.FooterContainer_Frontend_Right.new( f1_local1, f1_arg0, 0.5, 0.5, -960, 960, 1, 1, -48, 0 )
	self:addElement( FooterContainerFrontendRight )
	self.FooterContainerFrontendRight = FooterContainerFrontendRight

	local SafeAreaContainerMusicManager = CoD.Shield_SafeAreaContainer_MusicManager.new( f1_local1, f1_arg0, 0, 0, 0, 1920, 0, 0, 0, 1080 )
	SafeAreaContainerMusicManager:registerEventHandler( "menu_loaded", function ( element, event )
		local f3_local0 = nil
		if element.menuLoaded then
			f3_local0 = element:menuLoaded( event )
		elseif element.super.menuLoaded then
			f3_local0 = element.super:menuLoaded( event )
		end
		if not IsPC() then
			SizeToSafeArea( element, f1_arg0 )
		end
		if not f3_local0 then
			f3_local0 = element:dispatchEventToChildren( event )
		end
		return f3_local0
	end )
	self:addElement( SafeAreaContainerMusicManager )
	self.SafeAreaContainerMusicManager = SafeAreaContainerMusicManager

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

	SafeAreaContainerMusicManager.id = "SafeAreaContainerMusicManager"

	self:processEvent( {
		name = "menu_loaded",
		controller = f1_arg0
	} )

	LUI.OverrideFunction_CallOriginalSecond( self, "close", self.__onClose )

	if PostLoadFunc then
		PostLoadFunc( self, f1_arg0 )
	end

	CoD.EnhPrintInfo("Called", "Shield's Music Manager")

	SizeToSafeArea(SafeAreaContainerMusicManager, f1_arg0)

	return self
end

CoD.ShieldMusicManager.__onClose = function ( f8_arg0 )
	f8_arg0.Background:close()
	f8_arg0.FooterContainerFrontendRight:close()
	f8_arg0.SafeAreaContainerMusicManager:close()

	-- a place got another track, the shuffle changed or a track was played here: the menu under this one gets its music again
	if Music.changed then
		Music.changed = false
		RestoreLobbyMusic()
	end
end
