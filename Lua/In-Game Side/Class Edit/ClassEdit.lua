--[[
		.\hksc.exe ".\Lua\In-Game Side\Class Edit\ClassEdit.lua" -o "C:\Program Files (x86)\Call of Duty Black Ops 4\project-bo4\internals\T8ShieldSupport\Lua\Game\ClassEdit.luac"
]]

---------------------------

--[[
	Edit custom classes in a multiplayer match: "Edit Class" on the in-game class list (Choose Class) opens the
	frontend's class editor over the game, without the 3D preview.

	The engine sends a saved loadout to the host in a match (Engine.SaveLoadout -> LiveStats_Loadouts_Save ->
	CL_LoadoutChanged -> the host's SV_ReceiveModifiedLoadouts; the client fixes what it sends), and the host gives a
	class from that copy at every spawn, so an edit counts from the next spawn. What a match lacks is the menus: the
	editor's 118 files (with weapon personalization) and 44 of its texts are only in core_frontend. The mod carries them (Lua/Game/CAC, the game's
	own files, and English texts), marked "fallback" so the frontend keeps its own, and this file opens them and keeps
	them away from what only the frontend has.
]]

if CoD.isFrontend then
	return
end

-- only multiplayer has custom classes to edit
if Engine[@"currentsessionmode"]() ~= Enum[@"emodes"][@"mode_multiplayer"] then
	return
end

local MODE_MP = Enum[@"emodes"][@"mode_multiplayer"]
local EDIT_KEY = Enum[@"luibutton"][@"lui_key_xby_pstriangle"]

local function Log( text )
	if CoD.EnhPrintInfo then
		CoD.EnhPrintInfo( text, "Class edit" )
	end
end

if not ( CoD.Menu and CoD.Menu.safeCreateMenu ) then
	Log( "no CoD.Menu yet, no class editing" )
	return
end

--[[
	The game's own message for a class saved in a match sends the loadout storage file, which the host reads in another
	layout: the player is left with no weapons and a white default outfit. The client sends what the host expects
	(ingame_loadouts.cpp); an older client doesn't, so it gets no editor.
]]
if not ( ShieldFuncs ~= nil and ShieldFuncs.InGameClassEdit ~= nil and ShieldFuncs.InGameClassEdit() ) then
	Log( "the client doesn't send classes edited in a match, no class editing" )
	return
end

---------------------------

--[[
	The editor's files the mod carries (metadata.json, Lua\Game\CAC), all loaded when the editor first opens: menus
	are opened and frame widgets made by name ("CoD.CamoListSelectionWidget"), not only through requires.
]]
local EditorFiles = {
	"ui/uieditor/menus/cac/equipmentselect",
	"ui/uieditor/menus/cac/mpcustomizeclassmenu",
	"ui/uieditor/menus/cac/overcapacity",
	"ui/uieditor/menus/cac/perktalentselect",
	"ui/uieditor/menus/cac/popups/classoptions",
	"ui/uieditor/menus/cac/specialistequipmentselect",
	"ui/uieditor/menus/cac/weaponattachmentselect",
	"ui/uieditor/menus/cac/weaponselectflyout",
	"ui/uieditor/menus/cac/wildcardcapacity",
	"ui/uieditor/menus/cac/wildcardselect",
	"ui/uieditor/widgets/backgroundframes/cacfullpopupbackground",
	"ui/uieditor/widgets/blackmarket/bm_goldbarmed",
	"ui/uieditor/widgets/cac/cac_background_slide_panel",
	"ui/uieditor/widgets/cac/cac_background_slide_panel_short",
	"ui/uieditor/widgets/cac/cacbackgroundslidepanelwildcards",
	"ui/uieditor/widgets/cac/cacheader",
	"ui/uieditor/widgets/cac/classoptionswidget",
	"ui/uieditor/widgets/cac/customclasstabs",
	"ui/uieditor/widgets/cac/equipmentselect/equipmentlistwidget",
	"ui/uieditor/widgets/cac/itemnamedescunlocktext",
	"ui/uieditor/widgets/cac/menuchooseclass/chooseclassoverlay",
	"ui/uieditor/widgets/cac/menuchooseclass/itemwidgets/itemweaponlevel",
	"ui/uieditor/widgets/cac/menuchooseclass/itemwidgets/weaponlevelmeter",
	"ui/uieditor/widgets/cac/menuselectscreen/itemgridbutton",
	"ui/uieditor/widgets/cac/overcapacityitem",
	"ui/uieditor/widgets/cac/overcapacitylist",
	"ui/uieditor/widgets/cac/talentselect/talentslotcontainer",
	"ui/uieditor/widgets/cac/weaponattachmentselect/attachmentdescriptionheader",
	"ui/uieditor/widgets/cac/weaponattachmentselect/attachmentflyoutcontainer",
	"ui/uieditor/widgets/cac/weaponattachmentselect/attachmentslotcontainer",
	"ui/uieditor/widgets/cac/weaponattachmentselect/generalattachmentcontainer",
	"ui/uieditor/widgets/cac/wildcardselect/wildcardselectionwidget",
	"ui/uieditor/widgets/cac/wildcardselect/wildcardslotcontainer",
	"ui/uieditor/widgets/lobby/common/fe_buttonpanelshader",
	"x64:14875c56ab1b9ca8",
	"x64:14bb610f0602df09",
	"x64:1604be692d92c68c",
	"x64:16a177adf215eab",
	"x64:16c41982b9414c12",
	"x64:17b5952c3bc0ee42",
	"x64:180e4f83e25db76c",
	"x64:189be53e08699ecd",
	"x64:1b62ba0298ebda7a",
	"x64:1c4df7352304aecf",
	"x64:1d1b72c431d2cbb7",
	"x64:1edc2e1aae07ab05",
	"x64:1f88675da04d26fd",
	"x64:20fe1a52f98d23d",
	"x64:2116c2065cc3ac5e",
	"x64:21744d99b88fcb45",
	"x64:22f62ad5c139b24f",
	"x64:230f6657af27fb76",
	"x64:262dfb7afe71b40",
	"x64:278eb499a96d6585",
	"x64:28a564360a773656",
	"x64:2a3846462620f671",
	"x64:2a87c597c639d707",
	"x64:2b178a9bdf017263",
	"x64:2dbb73fb8fe6a257",
	"x64:2dbbe35720247c09",
	"x64:310483efa771121d",
	"x64:317e754536a5528",
	"x64:32136d2b295cb55e",
	"x64:368bcc307dcc87ad",
	"x64:369fdc75e3255cd7",
	"x64:37113d6053cc9f6",
	"x64:3a4c60719b1e8805",
	"x64:3a60f9dd8c2d255e",
	"x64:3bc87ac3fc76bb82",
	"x64:3c0cb09f85132dc0",
	"x64:3db0d043e3841f5c",
	"x64:3e2c12f88c203134",
	"x64:4031a96cffe9fd2d",
	"x64:449a95828346bc1b",
	"x64:453aa92712af1594",
	"x64:45f03a7cad3f6de0",
	"x64:49da7aea289e304f",
	"x64:4b1b346e32476a2e",
	"x64:4ca1dc89b2aa714c",
	"x64:4ec07622a7f2e74e",
	"x64:52213f4cb2c008",
	"x64:526078f55c3a4c45",
	"x64:53096a20718bc809",
	"x64:53d51e4fea9ed71c",
	"x64:5b3df56b6d23c7ac",
	"x64:5bfdb5df2cebf5b2",
	"x64:5d6dc417b7bcb1f0",
	"x64:5fba429cdc7392ca",
	"x64:605f4d99916f6c43",
	"x64:6103d565b59f1a18",
	"x64:61a4e34b4805b325",
	"x64:61bb87fb6a851b76",
	"x64:6458166a08ee8cce",
	"x64:6884fad5277b3107",
	"x64:6a49999b54fd0d2b",
	"x64:6cc9ca892a619096",
	"x64:6e6316db56ce8fb5",
	"x64:6fb1f8e518ebb17d",
	"x64:70ee455bcbe1a7e9",
	"x64:740aa7774ab8472c",
	"x64:76b510bc5f01b8c5",
	"x64:77198f4a2c6418a6",
	"x64:78085f9873d6d33b",
	"x64:7895a9e2a5208f5",
	"x64:789ba7fe93e9e723",
	"x64:7aa18a2396b77054",
	"x64:7d87d8c56a6a0017",
	"x64:7ec85b8e81fc1c0e",
	"x64:7fbffc86e9a93477",
	"x64:8904074a6536944",
	"x64:97d06fc9c1fdcaa",
	"x64:a22e4c82c4ffe1a",
	"x64:c5d63f9418f07c5",
	"x64:c6dd2c6b206676f",
	"x64:d1729e9d65fd99a",
	"x64:d4955d888afd063",
	"x64:d9c47b606eb32d9",
	"x64:e8da4b07a87fbd2"
}

-- the editor's menus, which tell the client scripts when they open and close (see PrepareMatch)
local EditorMenuNames = {
	MPCustomizeClassMenu = true,
	WeaponPersonalization = true,
	WeaponTabbedAccessoriesSelect = true,
	CamoPersonalizationDetails = true,
	PaintjobWeaponSelect = true,
	ReticleSelect = true,
	WeaponAccessoriesSelect = true,
	WeaponDeathFxSelect = true
}

--[[
	The Shield tab of the camos (Reactive Stage, Extra Camos, Custom Camos) and camos on mastercrafts: the support mod's
	own frontend files, which hook only the frontend. They go after the editor's files (Reactives remakes the camo tabs'
	widget, CoD.CamoFilterButtonList). Custom camos are drawn with CoD.Shield.BrowserUI, which the lobby browser's file
	makes: the handlers of the client's events it also sets (CoD.Shield.ShowServerToast...) stay the match's.
]]
local ShieldCamoFiles = {
	"x64:1e9f404fa48620d", -- ui/shield/ExtraCamos
	"x64:48feddfaf859c0c6", -- ui/shield/CustomCamos
	"x64:7c2fd0acae9118b2", -- ui/shield/Reactives
	"x64:5c9d7a6f14f71cc6" -- ui/shield/Mastercraft
}

local LOBBY_BROWSER = "x64:2c73def000207ee2" -- ui/shield/LobbyBrowser

local function LoadShieldCamos()
	if CoD.Shield and not CoD.Shield.BrowserUI then
		local kept = {}

		for key, value in pairs( CoD.Shield ) do
			kept[key] = value
		end

		local ok, err = pcall( require, LOBBY_BROWSER )

		for key, value in pairs( kept ) do
			CoD.Shield[key] = value
		end

		if not ok then
			Log( "can't load the lobby browser's UI: " .. tostring( err ) )
		end
	end

	for _, name in ipairs( ShieldCamoFiles ) do
		local ok, err = pcall( require, name )

		if not ok then
			Log( "can't load " .. name .. ": " .. tostring( err ) )
		end
	end

	-- what the frontend's ReloadOverrides calls of them
	for _, name in ipairs( { "ReactivesReload", "MasterCraftReload" } ) do
		if CoD[name] then
			local ok, err = pcall( CoD[name] )

			if not ok then
				Log( name .. ": " .. tostring( err ) )
			end
		end
	end
end

local EditorLoaded = false

local function LoadEditor()
	if EditorLoaded then
		return true
	end

	for _, name in ipairs( EditorFiles ) do
		local ok, err = pcall( require, name )

		if not ok then
			Log( "can't load " .. name .. ": " .. tostring( err ) )
			return false
		end
	end

	LoadShieldCamos()

	EditorLoaded = true
	return true
end

---------------------------

--[[
	Images of the editor that no zone of a match has (core_frontend only): registering one is a Lua error, "Image not
	cached". They are background patterns, glows, frames, lines and a few small icons, drawn as nothing here.
]]
local MissingImages = {
	@"t7_hud_mp_notifications_xp_alt",
	@"ui_icon_inventory_spray_can",
	@"uie_spawnselect_crosshair_auto",
	@"uie_ui_menu_aar_common_open_frame",
	@"ui_icon_blackmarket_lockbar_large",
	@"ui_icon_blackmarket_lockskull_128",
	@"uie_ui_menu_common_bracket01",
	@"uie_ui_menu_common_line_accent01",
	@"uie_ui_menu_emblem_empty_bg",
	@"hash_6AA0A70F33D3978",
	@"uie_t7_arena_star_petit_white",
	@"uie_t7_menu_cac_tabline",
	@"uie_ui_hud_wz_hud_core_qe_pointer",
	@"uie_ui_menu_cac_attachment_lvl_bg_colorless01",
	@"uie_ui_menu_cac_glow_half",
	@"uie_ui_menu_cac_grain_pattern_bg",
	@"uie_ui_menu_cac_grid_pattern_bg01",
	@"uie_ui_menu_item_ultra_backer",
	@"uie_ui_menu_social_emblem_dotline",
	@"hash_10A2CE59E7B7605F",
	@"hash_34C042BC6C9D43A9",
	@"hash_79D0184504FDF2CD"
}

local function SaveClass( controller )
	Engine[@"saveloadout"]( controller, MODE_MP )
end

--[[
	The game's functions the editor reaches for, changed for a match. Done when the class list is first made: by then
	the files that define them (actions.lua, the utilities) have run, so nothing puts the originals back.
]]
local MatchPrepared = false

local function PrepareMatch()
	if MatchPrepared then
		return
	end

	MatchPrepared = true

	local GameRegisterImage = RegisterImage

	RegisterImage = function ( image, ... )
		for i = 1, #MissingImages do
			if image == MissingImages[i] then
				return GameRegisterImage( @"blacktransparent", ... )
			end
		end

		return GameRegisterImage( image, ... )
	end

	-- a menu that only the frontend has and the mod doesn't carry (the paintshop) opens nothing instead of an error
	local GameOpenOverlay = OpenOverlay
	local GameOpenPopup = OpenPopup

	local function MenuExists( menuName )
		if type( menuName ) == "string" and LUI.createMenu[menuName] == nil then
			Log( "no menu " .. menuName .. " in a match" )
			return false
		end

		return true
	end

	OpenOverlay = function ( self, menuName, controller, userData, ... )
		if MenuExists( menuName ) then
			return GameOpenOverlay( self, menuName, controller, userData, ... )
		end
	end

	OpenPopup = function ( self, menuName, controller, userData, ... )
		if MenuExists( menuName ) then
			return GameOpenPopup( self, menuName, controller, userData, ... )
		end
	end

	--[[
		The editor tells the client scripts it opened and closed, for the frontend's 3D scene. In a match
		lui_shared.csc's setup_menu reads level.client_menus, which only the frontend makes: a client script error
		that drops the game to the frontend. Every way of telling them (by menu, by name, with a state) goes through
		this helper.
	]]
	local GameMenuChangeNotify = SendClientScriptMenuChangeNotifyHelper

	SendClientScriptMenuChangeNotifyHelper = function ( controller, menuName, ... )
		if menuName and EditorMenuNames[menuName] then
			return
		end

		return GameMenuChangeNotify( controller, menuName, ... )
	end

	--[[
		The attachment menu's description flyouts read the list's item models (controller model
		"WeaponAttachments") when the menu opens. The frontend has them from before; in a match the list fills
		them later, and reading them first was a Lua error that left the menu half open. They are made once the
		list has filled them.
	]]
	local Attachments = CoD.WeaponAttachmentsUtility

	if Attachments and Attachments.SetupAttachmentDescriptionFlyouts then
		local SetupFlyouts = Attachments.SetupAttachmentDescriptionFlyouts

		Attachments.SetupAttachmentDescriptionFlyouts = function ( menu, container, controller, owner )
			local tries = 0

			local function Setup()
				if Engine[@"getmodelforcontroller"]( controller ).WeaponAttachments then
					local ok, err = pcall( SetupFlyouts, menu, container, controller, owner )

					if not ok then
						Log( "attachment flyouts: " .. tostring( err ) )
					end

					return
				end

				tries = tries + 1

				if tries <= 20 and container then
					container:addElement( LUI.UITimer.newElementTimer( 100, true, Setup ) )
				end
			end

			Setup()
		end
	end

	-- before weapon personalization opens: reads the paintjob storage file; if a match hasn't it, no paintjobs to pick
	if CoD.CraftUtility and CoD.CraftUtility.SetupPaintjobPersonalization then
		local SetupPaintjobs = CoD.CraftUtility.SetupPaintjobPersonalization

		CoD.CraftUtility.SetupPaintjobPersonalization = function ( ... )
			local ok, err = pcall( SetupPaintjobs, ... )

			if not ok then
				Log( "paintjobs: " .. tostring( err ) )
			end
		end
	end

	-- the editor's first-time popup about weapon personalization
	if CoD.FTUEUtility and CoD.FTUEUtility.ShowFTUESequenceIfNotSeen then
		local ShowFTUE = CoD.FTUEUtility.ShowFTUESequenceIfNotSeen

		CoD.FTUEUtility.ShowFTUESequenceIfNotSeen = function ( menu, controller, sequence, ... )
			if sequence == "WeaponPersonalizationChanges" then
				return false
			end

			return ShowFTUE( menu, controller, sequence, ... )
		end
	end

	--[[
		The frontend saves a class and then uploads the stats file (breadcrumbs). In a match only the loadout is
		saved, which sends it to the host: the stats file is the match's until it ends.
	]]
	SaveLoadoutGeneric = function ( controller )
		SaveClass( controller )
	end

	SaveLoadout = function ( menu, controller )
		SaveClass( controller )
	end
end

---------------------------

local function HoveredClass( menu )
	local model = CoD.BaseUtility.GetMenuModel( menu )

	if model and model.classNum then
		return model.classNum:get()
	end
end

local function ParentMenu( element )
	local current = element:getParent()

	while current and not current.menuName do
		current = current:getParent()
	end

	return current
end

local function OpenEditor( popup, controller )
	if not LoadEditor() then
		return
	end

	-- the menu the class list slides out of (Position Draft): the editor goes over it, the list closes
	local owner = ParentMenu( popup ) or popup
	local classNum = HoveredClass( popup )

	CoD.StartMenuUtility.HideClassSelectSlideout( popup, controller )

	-- the editor's class tabs start on the selected class: the one hovered in the list
	local GetSelected = CoD.CACUtility.GetSelectedCustomClass

	if classNum then
		CoD.CACUtility.GetSelectedCustomClass = function ()
			return classNum
		end
	end

	local ok, editor = pcall( OpenOverlay, owner, "MPCustomizeClassMenu", controller, {
		_sessionMode = MODE_MP
	} )

	CoD.CACUtility.GetSelectedCustomClass = GetSelected

	if not ok then
		Log( "can't open the editor: " .. tostring( editor ) )
		return
	end

	if editor then
		LUI.OverrideFunction_CallOriginalFirst( editor, "close", function ()
			-- a match can close the menus (round end, killcam): what was changed is still saved
			SaveClass( controller )

			--[[
				Back to the class list, so the way out is picking a class, as without the editor. Back on Position
				Draft itself sends "changecharacter": the host clears the specialist (player_role::clear), the player
				is left with bare arms and every class picked after that is ignored (menuclass wants a role).
			]]
			if owner ~= popup and owner:getParent() then
				owner:addElement( LUI.UITimer.newElementTimer( 1, true, function ()
					if owner.ClassSelectPopup then
						CoD.StartMenuUtility.ShowClassSelectSlideout( owner, controller )
					end
				end ) )
			end
		end )
	end
end

local function AddEditButton( popup, controller )
	popup:AddButtonCallbackFunction( popup, controller, EDIT_KEY, "ui_contextual_1", function ( element, menu, controller, model )
		if not CoD.CACUtility.IsCurrentClassLocked( menu, controller ) then
			OpenEditor( menu, controller )
			return true
		end
	end, function ( element, menu, controller )
		-- a closed menu has no button model
		if menu and menu.buttonModel and not CoD.CACUtility.IsCurrentClassLocked( menu, controller ) then
			CoD.Menu.SetButtonLabel( menu, EDIT_KEY, @"shield/edit_class", nil, "ui_contextual_1" )
			return true
		else
			return false
		end
	end, false )

	-- the prompt follows the hovered class, as the list's own select prompt does
	popup:linkToElementModel( popup, nil, true, function ( model, element )
		CoD.Menu.UpdateButtonShownState( element, popup, controller, EDIT_KEY )
	end )
end

-- the class list of a match (Choose Class) gets the button when it is made
local CreateMenu = CoD.Menu.safeCreateMenu

CoD.Menu.safeCreateMenu = function ( name, controller, userData, ... )
	local menu = CreateMenu( name, controller, userData, ... )

	if menu and name == "ClassSelectSlideoutPopup" then
		PrepareMatch()

		local ok, err = pcall( AddEditButton, menu, controller )

		if not ok then
			Log( "can't add the button: " .. tostring( err ) )
		end
	end

	return menu
end
