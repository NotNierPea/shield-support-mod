--[[
		.\hksc.exe ".\Lua\In-Game Side\Zombies\SprayGestureWheel.lua" -o "C:\Program Files (x86)\Call of Duty Black Ops 4\project-bo4\internals\T8ShieldSupport\Lua\Game\SprayGestureWheel.luac"
]]

---------------------------

if CoD.isFrontend or not CoD.isZombie then
	return
end

CoD.ShieldInitLuaFile()

---------------------------

--[[
	The sprays and gestures wheel of multiplayer and Blackout, in zombies. The game plays a spray or a gesture itself once the
	slot chosen on the wheel reaches it (Engine[@"hash_111C001DF63C3ABA"], as the multiplayer HUD does); what zombies lacks is
	put in place here and in shield-client (sprays_gestures.cpp):
	- the wheel on the HUD: zombies has none, nor the files of its widgets, so those of mp_common are copied at the end;
	- what is on it: zombies loadouts have no slots for sprays and gestures, shield-client keeps 9 for zombies (set in the
	  lobby's Extras, ZombiesExtras.lua) and the game's reader of the slots answers with them;
	- the server knowing them: it only has the zombies loadouts of its players, so each one sends it its 9 here (a menu response,
	  the support GSC passes it to ShieldSetSprayGesture).
	The spray can's gesture table is support.ff's.
]]
local MENU = "shield_support_menu"
local RESPONSE = "spray_gesture"
local SLOTS = 9

local function Log( text )
	Engine[@"printinfo"]( 0, "[shield] sprays and gestures: " .. text .. "\n" )
end

-- zombies' 9 slots: an item index + 1 each, 0 for none. The first is the quick spray, the wheel has the others
local function EquippedItems( controller )
	return Engine[@"hash_688987BA1B9D616B"]( controller, Enum[@"emodes"][@"mode_zombies"] ) or {}
end

-- the game's DataSources.SpraysAndGestures, on zombies' slots
local function SetupDataSource()
	if DataSources.ShieldSpraysAndGestures then
		return
	end

	DataSources.ShieldSpraysAndGestures = DataSourceHelpers.ListSetup( "ShieldSpraysAndGestures", function ( controller )
		local list = {}
		local images = {}
		local all = Engine[@"hash_2B2E4CCC119597B0"]()

		for slot, item in ipairs( EquippedItems( controller ) ) do
			if slot ~= 1 then
				local info = all[item]
				if info then
					table.insert( images, info[@"hash_5BFF4CC56C2092F0"] )
					table.insert( list, {
						models = {
							image = info[@"hash_5BFF4CC56C2092F0"],
							displayName = info[@"hash_5A31296C0C1B6029"],
							index = slot - 2,
							item_index = item - 1,
							chosen = false,
							assetName = info[@"hash_514C91FFB3BA4240"]
						},
						properties = {}
					} )
				else
					table.insert( list, {
						models = {
							image = @"hash_77615068F50B3D66",
							displayName = @"hash_0",
							index = slot - 2,
							item_index = 0,
							chosen = false,
							assetName = @"hash_0"
						},
						properties = {}
					} )
				end
			end
		end

		CoD.HUDUtility.ForceStreamedSpraysAndGesturesImages = CoD.BaseUtility.ForceStreamHelper( CoD.HUDUtility.ForceStreamedSpraysAndGesturesImages or {}, images )
		return list
	end, nil )
end

-- the button of the wheel tapped (a controller's action slot): the spray of the first slot, as CoD.HUDUtility.AddQuickSprayCallback
CoD.ShieldQuickSpray = function ( controller )
	local items = EquippedItems( controller )
	if items[1] and items[1] > 0 then
		Engine[@"hash_111C001DF63C3ABA"]( controller, 0, true )
	end
end

-- the server keeps them by slot: 4096 * slot + the value of the slot
local function SendItems( controller )
	local items = EquippedItems( controller )
	for slot = 1, SLOTS do
		CoD.BaseUtility.SendCustomMenuResponse( controller, MENU, RESPONSE, (slot - 1) * 4096 + (items[slot] or 0) )
	end
end

-- the outfits picked of zombies characters with outfits of ours (Outfits.lua's outfit list): zm_characters sets outfit 0,
-- the support GSC sets these again (64 * character index + outfit)
local function SendOutfits( controller )
	local mode = Enum[@"emodes"][@"mode_zombies"]
	for _, hero in ipairs( Engine[@"getherolist"]( mode ) or {} ) do
		local info = hero.bodyIndex and Engine[@"getequippedinfoforhero"]( controller, mode, hero.bodyIndex )
		local outfit = info and info[@"selectedoutfit"]
		if outfit and outfit > 0 and outfit < 64 then
			CoD.BaseUtility.SendCustomMenuResponse( controller, MENU, "zm_outfit", hero.bodyIndex * 64 + outfit )
		end
	end
end

--[[
	Character pictures of outfits of ours (Peeks on Scarlett), for every player: the ammo widget's portrait
	(GetPositionDraftStatePortraitByIndex), the scoreboard's (GetPositionDraftIconByIndex) and the party list's and game
	over's (the controller's PlayerList.<slot>.zombiePlayerIcon models). The support GSC tells every HUD each player's
	outfit (the notify shield_outfit: client, character index, outfit); an outfit of these, by its name (shield-client
	"shield/outfits/<zone>/<mode>/<role>/name"), has its own pictures: the 84x60 portrait, the 168x148 icon.
]]
local OUTFIT_NOTIFY = @"shield_outfit"
local OutfitPictures = {
	[@"shield/outfits/support/zm/1/name"] = { portrait = @"peaks_hud", icon = @"peaks_portrait" },
	[@"shield/outfits/support/zm/15/name"] = { portrait = @"peaks_hud", icon = @"peaks_portrait" }
}

-- client number: { character, outfit }
local ClientOutfits = {}

local function PicturesOf( characterIndex, outfit )
	if not outfit or outfit <= 0 then
		return nil
	end
	local customization = CoD.PlayerRoleUtility.GetCachedHeroCustomization( Enum[@"emodes"][@"mode_zombies"], characterIndex )
	local picked = customization and customization.outfits and customization.outfits[outfit + 1]
	return picked and OutfitPictures[picked.displayName]
end

-- the pictures of the player playing that character (before any notify: this player's own pick)
local function CharacterPictures( characterIndex )
	for _, worn in pairs( ClientOutfits ) do
		if worn.character == characterIndex then
			return PicturesOf( characterIndex, worn.outfit )
		end
	end
	local info = Engine[@"getequippedinfoforhero"]( Engine[@"getprimarycontroller"](), Enum[@"emodes"][@"mode_zombies"], characterIndex )
	return PicturesOf( characterIndex, info and info[@"selectedoutfit"] )
end

local function PictureOf( characterIndex, field )
	local ok, pictures = pcall( CharacterPictures, characterIndex )
	return ok and pictures and pictures[field]
end

local function HookPortraits()
	if GetPositionDraftStatePortraitByIndex and CoD.ShieldPortraits ~= GetPositionDraftStatePortraitByIndex then
		local game = GetPositionDraftStatePortraitByIndex
		CoD.ShieldPortraits = function ( state, characterIndex )
			return PictureOf( characterIndex, "portrait" ) or game( state, characterIndex )
		end
		GetPositionDraftStatePortraitByIndex = CoD.ShieldPortraits
	end
	if GetPositionDraftIconByIndex and CoD.ShieldIcons ~= GetPositionDraftIconByIndex then
		local game = GetPositionDraftIconByIndex
		CoD.ShieldIcons = function ( characterIndex )
			return PictureOf( characterIndex, "icon" ) or game( characterIndex )
		end
		GetPositionDraftIconByIndex = CoD.ShieldIcons
	end
end

-- a party list / game over icon: ours for a player in an outfit of these (set again whenever the game sets its own)
local function PlayerIconOf( clientNum )
	local worn = ClientOutfits[clientNum]
	local pictures = worn and PicturesOf( worn.character, worn.outfit )
	return pictures and pictures.icon
end

-- subscribed once per HUD, applied again on each notify
local function WatchPlayerIcons( menu, controller )
	if not menu.ShieldPlayerIcons then
		menu.ShieldPlayerIcons = {}
		local list = DataSources.ZMPlayerList.getModel( controller )
		local me = Engine[@"getclientnum"]( controller )
		for clientNum = 0, 3 do
			local entry = Engine[@"createmodel"]( list, DataSources.PlayerListZM.clientNumToArrayIndex( clientNum, me ) )
			local icon = Engine[@"createmodel"]( entry, "zombiePlayerIcon" )
			local apply = function ()
				local ours = PlayerIconOf( clientNum )
				if ours and Engine[@"getmodelvalue"]( icon ) ~= ours then
					Engine[@"setmodelvalue"]( icon, ours )
				end
			end
			menu:subscribeToModel( icon, apply, false )
			table.insert( menu.ShieldPlayerIcons, apply )
		end
	end
	for _, apply in ipairs( menu.ShieldPlayerIcons ) do
		apply()
	end
end

local function ListenOutfits( menu, controller )
	if menu.ShieldOutfitPictures then
		return
	end
	menu.ShieldOutfitPictures = true
	menu:subscribeToGlobalModel( controller, "PerController", "scriptNotify", function ( model )
		if Engine[@"getmodelvalue"]( model ) ~= OUTFIT_NOTIFY then
			return
		end
		local data = CoD.GetScriptNotifyData( model )
		if data and data[1] then
			ClientOutfits[data[1]] = { character = data[2], outfit = data[3] }
			pcall( WatchPlayerIcons, menu, controller )
		end
	end )
	WatchPlayerIcons( menu, controller )
end

local function AddWheel( menu, controller )
	if menu.ShieldSpraysAndGestures then
		return
	end

	SetupDataSource()

	local wheel = CoD.MPSpraysAndGestures.new( menu, controller, 0, 1, 0, 0, 0, 1, 0, 0 )
	menu:addElement( wheel )
	menu.ShieldSpraysAndGestures = wheel
end

-- every zombies HUD (T7Hud_zm_factory and those of the maps) ends with this
local function HookHud()
	local utility = CoD.ZombieUtility
	if not utility or utility.ShieldSprayWheel or not utility.CommonPostLoadHud then
		return
	end

	utility.ShieldSprayWheel = true
	local GamePostLoadHud = utility.CommonPostLoadHud
	utility.CommonPostLoadHud = function ( hud, controller, menu, ... )
		GamePostLoadHud( hud, controller, menu, ... )

		-- a HUD with an error in it would not show at all
		local ok, err = pcall( AddWheel, menu or hud, controller )
		if not ok then
			Log( "no wheel: " .. tostring( err ) )
		end

		ok, err = pcall( SendItems, controller )
		if not ok then
			Log( "not sent to the server: " .. tostring( err ) )
		end

		ok, err = pcall( SendOutfits, controller )
		if not ok then
			Log( "outfits not sent to the server: " .. tostring( err ) )
		end

		ok, err = pcall( ListenOutfits, menu or hud, controller )
		if not ok then
			Log( "no outfit pictures: " .. tostring( err ) )
		end
	end
end

HookHud()
HookPortraits()

-- the zombies utility may be read after this file: hooked once it is
if not CoD.ShieldSprayWheelRequire then
	CoD.ShieldSprayWheelRequire = true
	local GameRequire = require
	require = function ( ... )
		local result = GameRequire( ... )
		HookHud()
		HookPortraits()
		return result
	end
end

---------------------------

-- the widgets of the wheel, from mp_common (ui/uieditor/widgets/hud/mpspraysandgestures and what it uses). Only the data
-- source and the quick spray are changed: ShieldSpraysAndGestures, CoD.ShieldQuickSpray

if not CoD.WheelTriangleIndicator then
	CoD.WheelTriangleIndicator = InheritFrom( LUI.UIElement )
	CoD.WheelTriangleIndicator.__defaultWidth = 24
	CoD.WheelTriangleIndicator.__defaultHeight = 24
	CoD.WheelTriangleIndicator.new = function ( f1_arg0, f1_arg1, f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
		local self = LUI.UIElement.new( f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
		self:setClass( CoD.WheelTriangleIndicator )
		self.id = "WheelTriangleIndicator"
		self.soundSet = "default"
		f1_arg0:addElementToPendingUpdateStateList( self )

		local PointerImage = LUI.UIImage.new( 0, 0, 62, 130, 0.5, 0.5, -12, 8 )
		PointerImage:setZRot( -90 )
		PointerImage:setImage( RegisterImage( @"hash_3E08357911B44221" ) )
		self:addElement( PointerImage )
		self.PointerImage = PointerImage

		local PointerImageAdd = LUI.UIImage.new( 0, 0, 62, 130, 0.5, 0.5, -12, 8 )
		PointerImageAdd:setAlpha( 0 )
		PointerImageAdd:setZRot( -90 )
		PointerImageAdd:setImage( RegisterImage( @"hash_3E08357911B44221" ) )
		PointerImageAdd:setMaterial( LUI.UIImage.GetCachedMaterial( @"hash_54E6CE42E0799F57" ) )
		self:addElement( PointerImageAdd )
		self.PointerImageAdd = PointerImageAdd

		self:mergeStateConditions( {
			{
				stateName = "Visible",
				condition = function ( menu, element, event )
					return CoD.HUDUtility.IsWheelPointerVisible( f1_arg1 )
				end
			}
		} )
		self:appendEventHandler( "input_source_changed", function ( f3_arg0, f3_arg1 )
			f3_arg1.menu = f3_arg1.menu or f1_arg0
			f1_arg0:updateElementState( self, f3_arg1 )
		end )
		local f1_local3 = self
		local f1_local4 = self.subscribeToModel
		local f1_local5 = Engine[@"hash_4DF5CFBC1771947"]( f1_arg1 )
		f1_local4( f1_local3, f1_local5.LastInput, function ( f4_arg0 )
			f1_arg0:updateElementState( self, {
				name = "model_validation",
				menu = f1_arg0,
				controller = f1_arg1,
				modelValue = f4_arg0:get(),
				modelName = "LastInput"
			} )
		end, false )
		f1_local3 = self
		f1_local4 = self.subscribeToModel
		f1_local5 = DataSources.RightStick.getModel( f1_arg1 )
		f1_local4( f1_local3, f1_local5.WheelSelectionEnabled, function ( f5_arg0 )
			f1_arg0:updateElementState( self, {
				name = "model_validation",
				menu = f1_arg0,
				controller = f1_arg1,
				modelValue = f5_arg0:get(),
				modelName = "WheelSelectionEnabled"
			} )
		end, false )
		f1_local3 = self
		f1_local4 = self.subscribeToModel
		f1_local5 = DataSources.LeftStick.getModel( f1_arg1 )
		f1_local4( f1_local3, f1_local5.WheelSelectionEnabled, function ( f6_arg0 )
			f1_arg0:updateElementState( self, {
				name = "model_validation",
				menu = f1_arg0,
				controller = f1_arg1,
				modelValue = f6_arg0:get(),
				modelName = "WheelSelectionEnabled"
			} )
		end, false )


		return self
	end
	CoD.WheelTriangleIndicator.__resetProperties = function ( f7_arg0 )
		f7_arg0.PointerImage:completeAnimation()
		f7_arg0.PointerImageAdd:completeAnimation()
		f7_arg0.PointerImage:setAlpha( 1 )
		f7_arg0.PointerImageAdd:setAlpha( 0 )
	end
	CoD.WheelTriangleIndicator.__clipsPerState = {
		DefaultState = {
			DefaultClip = function ( f8_arg0, f8_arg1 )
				f8_arg0:__resetProperties()
				f8_arg0:setupElementClipCounter( 1 )
				f8_arg0.PointerImage:completeAnimation()
				f8_arg0.PointerImage:setAlpha( 0 )
				f8_arg0.clipFinished( f8_arg0.PointerImage )
			end,
			Visible = function ( f9_arg0, f9_arg1 )
				f9_arg0:__resetProperties()
				f9_arg0:setupElementClipCounter( 2 )
				local f9_local0 = function ( f10_arg0 )
					f9_arg0.PointerImage:beginAnimation( 100, Enum[@"hash_1F50FFF429AB1890"][@"hash_2053CEB9A0427197"] )
					f9_arg0.PointerImage:setAlpha( 1 )
					f9_arg0.PointerImage:registerEventHandler( "interrupted_keyframe", f9_arg0.clipInterrupted )
					f9_arg0.PointerImage:registerEventHandler( "transition_complete_keyframe", f9_arg0.clipFinished )
				end
				f9_arg0.PointerImage:completeAnimation()
				f9_arg0.PointerImage:setAlpha( 0 )
				f9_local0( f9_arg0.PointerImage )
				f9_arg0.PointerImageAdd:completeAnimation()
				f9_arg0.PointerImageAdd:setAlpha( 0 )
				f9_arg0.clipFinished( f9_arg0.PointerImageAdd )
			end
		},
		Visible = {
			DefaultClip = function ( f11_arg0, f11_arg1 )
				f11_arg0:__resetProperties()
				f11_arg0:setupElementClipCounter( 2 )
				f11_arg0.PointerImage:completeAnimation()
				f11_arg0.PointerImage:setAlpha( 1 )
				f11_arg0.clipFinished( f11_arg0.PointerImage )
				local f11_local0 = function ( f12_arg0 )
					local f12_local0 = function ( f13_arg0 )
						f13_arg0:beginAnimation( 1000, Enum[@"hash_1F50FFF429AB1890"][@"hash_15193EA7825DC097"] )
						f13_arg0:setAlpha( 0 )
						f13_arg0:registerEventHandler( "transition_complete_keyframe", f11_arg0.clipFinished )
					end
					f11_arg0.PointerImageAdd:beginAnimation( 1000, Enum[@"hash_1F50FFF429AB1890"][@"hash_15193EA7825DC097"] )
					f11_arg0.PointerImageAdd:setAlpha( 0.5 )
					f11_arg0.PointerImageAdd:registerEventHandler( "interrupted_keyframe", f11_arg0.clipInterrupted )
					f11_arg0.PointerImageAdd:registerEventHandler( "transition_complete_keyframe", f12_local0 )
				end
				f11_arg0.PointerImageAdd:completeAnimation()
				f11_arg0.PointerImageAdd:setAlpha( 0 )
				f11_local0( f11_arg0.PointerImageAdd )
				f11_arg0.nextClip = "DefaultClip"
			end
		}
	}
end

if not CoD.MPWheelPrompt then
	CoD.MPWheelPrompt = InheritFrom( LUI.UIElement )
	CoD.MPWheelPrompt.__defaultWidth = 80
	CoD.MPWheelPrompt.__defaultHeight = 80
	CoD.MPWheelPrompt.new = function ( f1_arg0, f1_arg1, f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
		local self = LUI.UIElement.new( f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
		self:setClass( CoD.MPWheelPrompt )
		self.id = "MPWheelPrompt"
		self.soundSet = "default"
		f1_arg0:addElementToPendingUpdateStateList( self )

		local RStick = LUI.UIImage.new( 0.5, 0.5, -40, 40, 0.5, 0.5, -40, 40 )
		RStick:subscribeToGlobalModel( f1_arg1, "Controller", "move_right_stick_button_image", function ( model )
			local f2_local0 = model:get()
			if f2_local0 ~= nil then
				RStick:setImage( RegisterImage( f2_local0 ) )
			end
		end )
		self:addElement( RStick )
		self.RStick = RStick

		self:mergeStateConditions( {
			{
				stateName = "Keyboard",
				condition = function ( menu, element, event )
					return IsMouseOrKeyboard( f1_arg1 )
				end
			}
		} )
		self:appendEventHandler( "input_source_changed", function ( f4_arg0, f4_arg1 )
			f4_arg1.menu = f4_arg1.menu or f1_arg0
			f1_arg0:updateElementState( self, f4_arg1 )
		end )
		local f1_local2 = self
		local f1_local3 = self.subscribeToModel
		local f1_local4 = Engine[@"hash_4DF5CFBC1771947"]( f1_arg1 )
		f1_local3( f1_local2, f1_local4.LastInput, function ( f5_arg0 )
			f1_arg0:updateElementState( self, {
				name = "model_validation",
				menu = f1_arg0,
				controller = f1_arg1,
				modelValue = f5_arg0:get(),
				modelName = "LastInput"
			} )
		end, false )
		LUI.OverrideFunction_CallOriginalSecond( self, "close", self.__onClose )


		return self
	end
	CoD.MPWheelPrompt.__resetProperties = function ( f6_arg0 )
		f6_arg0.RStick:completeAnimation()
		f6_arg0.RStick:setAlpha( 1 )
	end
	CoD.MPWheelPrompt.__clipsPerState = {
		DefaultState = {
			DefaultClip = function ( f7_arg0, f7_arg1 )
				f7_arg0:__resetProperties()
				f7_arg0:setupElementClipCounter( 1 )
				f7_arg0.RStick:completeAnimation()
				f7_arg0.RStick:setAlpha( 1 )
				f7_arg0.clipFinished( f7_arg0.RStick )
			end
		},
		Keyboard = {
			DefaultClip = function ( f8_arg0, f8_arg1 )
				f8_arg0:__resetProperties()
				f8_arg0:setupElementClipCounter( 1 )
				f8_arg0.RStick:completeAnimation()
				f8_arg0.RStick:setAlpha( 0 )
				f8_arg0.clipFinished( f8_arg0.RStick )
			end
		}
	}
	CoD.MPWheelPrompt.__onClose = function ( f9_arg0 )
		f9_arg0.RStick:close()
	end
end

if not CoD.SprayOrGesture then
	CoD.SprayOrGesture = InheritFrom( LUI.UIElement )
	CoD.SprayOrGesture.__defaultWidth = 382
	CoD.SprayOrGesture.__defaultHeight = 382
	CoD.SprayOrGesture.new = function ( f1_arg0, f1_arg1, f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
		local self = LUI.UIElement.new( f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
		self:setClass( CoD.SprayOrGesture )
		self.id = "SprayOrGesture"
		self.soundSet = "default"
		self.anyChildUsesUpdateState = true
		f1_arg0:addElementToPendingUpdateStateList( self )

		local SocialArrow = LUI.UIImage.new( 0.35, 0.35, 48.5, 60.5, 0, 0, 84, 92 )
		SocialArrow:setAlpha( 0.2 )
		SocialArrow:setImage( RegisterImage( @"hash_56EE9D102BDF58E4" ) )
		SocialArrow:setMaterial( LUI.UIImage.GetCachedMaterial( @"hash_31CC85D0A86303B0" ) )
		SocialArrow:setShaderVector( 0, 1, 0, 0, 0 )
		self:addElement( SocialArrow )
		self.SocialArrow = SocialArrow

		local backingSolid = LUI.UIImage.new( -0.5, 1.5, 0, 0, -0.5, 0.5, -8, -8 )
		backingSolid:setRGB( 0, 0, 0 )
		backingSolid:setAlpha( 0.25 )
		backingSolid:setMaterial( LUI.UIImage.GetCachedMaterial( @"hash_3027EBC307ABF865" ) )
		backingSolid:setShaderVector( 0, 0.1, 0.25, 0, 0 )
		backingSolid:setShaderVector( 2, 0, 0, 0, 0 )
		backingSolid:linkToElementModel( self, "angleWidth", true, function ( model )
			local f2_local0 = model:get()
			if f2_local0 ~= nil then
				backingSolid:setShaderVector( 1, CoD.GetVectorComponentFromString( f2_local0, 1 ), CoD.GetVectorComponentFromString( f2_local0, 2 ), CoD.GetVectorComponentFromString( f2_local0, 3 ), CoD.GetVectorComponentFromString( f2_local0, 4 ) )
			end
		end )
		self:addElement( backingSolid )
		self.backingSolid = backingSolid

		local backing = LUI.UIImage.new( -0.5, 1.5, 0, 0, -0.5, 0.5, -8, -8 )
		backing:setRGB( 0, 0, 0 )
		backing:setAlpha( 0.5 )
		backing:setMaterial( LUI.UIImage.GetCachedMaterial( @"hash_3027EBC307ABF865" ) )
		backing:setShaderVector( 0, 0.1, 0, 0, 0 )
		backing:setShaderVector( 2, 0, 0, 0, 0 )
		backing:linkToElementModel( self, "angleWidth", true, function ( model )
			local f3_local0 = model:get()
			if f3_local0 ~= nil then
				backing:setShaderVector( 1, CoD.GetVectorComponentFromString( f3_local0, 1 ), CoD.GetVectorComponentFromString( f3_local0, 2 ), CoD.GetVectorComponentFromString( f3_local0, 3 ), CoD.GetVectorComponentFromString( f3_local0, 4 ) )
			end
		end )
		self:addElement( backing )
		self.backing = backing

		local SocialArrowAdd = LUI.UIImage.new( 0.35, 0.35, 48.5, 60.5, 0, 0, 84, 92 )
		SocialArrowAdd:setRGB( 0.87, 0.65, 0.05 )
		SocialArrowAdd:setAlpha( 0 )
		SocialArrowAdd:setImage( RegisterImage( @"hash_56EE9D102BDF58E4" ) )
		SocialArrowAdd:setMaterial( LUI.UIImage.GetCachedMaterial( @"hash_31CC85D0A86303B0" ) )
		SocialArrowAdd:setShaderVector( 0, 1, 0, 0, 0 )
		self:addElement( SocialArrowAdd )
		self.SocialArrowAdd = SocialArrowAdd

		local backingAdd = LUI.UIImage.new( -0.5, 1.5, 0, 0, -0.5, 0.5, -8, -8 )
		backingAdd:setRGB( 0.87, 0.53, 0.05 )
		backingAdd:setAlpha( 0 )
		backingAdd:setMaterial( LUI.UIImage.GetCachedMaterial( @"hash_4FB9F1A22257E145" ) )
		backingAdd:setShaderVector( 0, 0.1, 0.8, 0, 0 )
		backingAdd:setShaderVector( 2, 0, 0, 0, 0 )
		backingAdd:linkToElementModel( self, "angleWidth", true, function ( model )
			local f4_local0 = model:get()
			if f4_local0 ~= nil then
				backingAdd:setShaderVector( 1, CoD.GetVectorComponentFromString( f4_local0, 1 ), CoD.GetVectorComponentFromString( f4_local0, 2 ), CoD.GetVectorComponentFromString( f4_local0, 3 ), CoD.GetVectorComponentFromString( f4_local0, 4 ) )
			end
		end )
		self:addElement( backingAdd )
		self.backingAdd = backingAdd

		local SprayOrGesture = LUI.UIImage.new( 0.35, 0.35, 0, 115, 0, 0, -122, -7 )
		SprayOrGesture:linkToElementModel( self, "zRot", true, function ( model )
			local f5_local0 = model:get()
			if f5_local0 ~= nil then
				SprayOrGesture:setZRot( Multiple( -1, f5_local0 ) )
			end
		end )
		SprayOrGesture:linkToElementModel( self, "image", true, function ( model )
			local f6_local0 = model:get()
			if f6_local0 ~= nil then
				SprayOrGesture:setImage( RegisterImage( f6_local0 ) )
			end
		end )
		self:addElement( SprayOrGesture )
		self.SprayOrGesture = SprayOrGesture

		local f1_local7 = nil
		self.ButtonImage = LUI.UIElement.createFake()
		self:mergeStateConditions( {
			{
				stateName = "Disabled",
				condition = function ( menu, element, event )
					return CoD.ModelUtility.IsSelfModelValueTrue( element, f1_arg1, "disabled" )
				end
			},
			{
				stateName = "Chosen",
				condition = function ( menu, element, event )
					return CoD.ModelUtility.IsSelfModelValueTrue( element, f1_arg1, "chosen" ) and CoD.ModelUtility.IsGlobalDataSourceModelValueEqualToSelfModelValue( element, f1_arg1, "RightStick", "SelectedWedge", "index" )
				end
			},
			{
				stateName = "Highlighted",
				condition = function ( menu, element, event )
					return CoD.ModelUtility.IsGlobalDataSourceModelValueEqualToSelfModelValue( element, f1_arg1, "RightStick", "SelectedWedge", "index" )
				end
			}
		} )
		self:linkToElementModel( self, "disabled", true, function ( model )
			f1_arg0:updateElementState( self, {
				name = "model_validation",
				menu = f1_arg0,
				controller = f1_arg1,
				modelValue = model:get(),
				modelName = "disabled"
			} )
		end )
		self:linkToElementModel( self, "chosen", true, function ( model )
			f1_arg0:updateElementState( self, {
				name = "model_validation",
				menu = f1_arg0,
				controller = f1_arg1,
				modelValue = model:get(),
				modelName = "chosen"
			} )
		end )
		local f1_local8 = self
		local f1_local9 = self.subscribeToModel
		local f1_local10 = DataSources.RightStick.getModel( f1_arg1 )
		f1_local9( f1_local8, f1_local10.SelectedWedge, function ( f12_arg0 )
			f1_arg0:updateElementState( self, {
				name = "model_validation",
				menu = f1_arg0,
				controller = f1_arg1,
				modelValue = f12_arg0:get(),
				modelName = "SelectedWedge"
			} )
		end, false )
		self:linkToElementModel( self, "index", true, function ( model )
			f1_arg0:updateElementState( self, {
				name = "model_validation",
				menu = f1_arg0,
				controller = f1_arg1,
				modelValue = model:get(),
				modelName = "index"
			} )
		end )
		LUI.OverrideFunction_CallOriginalSecond( self, "close", self.__onClose )


		return self
	end
	CoD.SprayOrGesture.__resetProperties = function ( f14_arg0 )
		f14_arg0.SprayOrGesture:completeAnimation()
		f14_arg0.backing:completeAnimation()
		f14_arg0.SocialArrowAdd:completeAnimation()
		f14_arg0.backingAdd:completeAnimation()
		f14_arg0.SocialArrow:completeAnimation()
		f14_arg0.ButtonImage:completeAnimation()
		f14_arg0.SprayOrGesture:setTopBottom( 0, 0, -122, -7 )
		f14_arg0.SprayOrGesture:setRGB( 1, 1, 1 )
		f14_arg0.SprayOrGesture:setAlpha( 1 )
		f14_arg0.backing:setTopBottom( -0.5, 0.5, -8, -8 )
		f14_arg0.backing:setRGB( 0, 0, 0 )
		f14_arg0.backing:setAlpha( 0.5 )
		f14_arg0.backing:setScale( 1, 1 )
		f14_arg0.SocialArrowAdd:setTopBottom( 0, 0, 84, 92 )
		f14_arg0.SocialArrowAdd:setAlpha( 0 )
		f14_arg0.SocialArrowAdd:setScale( 1, 1 )
		f14_arg0.backingAdd:setTopBottom( -0.5, 0.5, -8, -8 )
		f14_arg0.backingAdd:setAlpha( 0 )
		f14_arg0.backingAdd:setScale( 1, 1 )
		f14_arg0.backingAdd:setShaderVector( 0, 0.1, 0.8, 0, 0 )
		f14_arg0.backingAdd:setShaderVector( 2, 0, 0, 0, 0 )
		f14_arg0.SocialArrow:setTopBottom( 0, 0, 84, 92 )
		f14_arg0.SocialArrow:setAlpha( 0.2 )
		f14_arg0.SocialArrow:setScale( 1, 1 )
		f14_arg0.ButtonImage:setTopBottom( 0, 0, 20, 60 )
		f14_arg0.ButtonImage:setAlpha( 0 )
	end
	CoD.SprayOrGesture.__clipsPerState = {
		DefaultState = {
			DefaultClip = function ( f15_arg0, f15_arg1 )
				f15_arg0:__resetProperties()
				f15_arg0:setupElementClipCounter( 1 )
				f15_arg0.SprayOrGesture:completeAnimation()
				f15_arg0.SprayOrGesture:setRGB( 0.78, 0.75, 0.62 )
				f15_arg0.clipFinished( f15_arg0.SprayOrGesture )
			end,
			Selected = function ( f16_arg0, f16_arg1 )
				f16_arg0:__resetProperties()
				f16_arg0:setupElementClipCounter( 5 )
				local f16_local0 = function ( f17_arg0 )
					f16_arg0.SocialArrow:beginAnimation( 150 )
					f16_arg0.SocialArrow:setTopBottom( 0, 0, 65, 73 )
					f16_arg0.SocialArrow:setAlpha( 0.5 )
					f16_arg0.SocialArrow:setScale( 1.5, 1.5 )
					f16_arg0.SocialArrow:registerEventHandler( "interrupted_keyframe", f16_arg0.clipInterrupted )
					f16_arg0.SocialArrow:registerEventHandler( "transition_complete_keyframe", f16_arg0.clipFinished )
				end
				f16_arg0.SocialArrow:completeAnimation()
				f16_arg0.SocialArrow:setTopBottom( 0, 0, 84, 92 )
				f16_arg0.SocialArrow:setAlpha( 0.2 )
				f16_arg0.SocialArrow:setScale( 1, 1 )
				f16_local0( f16_arg0.SocialArrow )
				local f16_local1 = function ( f18_arg0 )
					f16_arg0.backing:beginAnimation( 150, Enum[@"hash_1F50FFF429AB1890"][@"hash_2053CEB9A0427197"] )
					f16_arg0.backing:setRGB( 0.57, 0.42, 0.03 )
					f16_arg0.backing:setAlpha( 0.25 )
					f16_arg0.backing:registerEventHandler( "interrupted_keyframe", f16_arg0.clipInterrupted )
					f16_arg0.backing:registerEventHandler( "transition_complete_keyframe", f16_arg0.clipFinished )
				end
				f16_arg0.backing:completeAnimation()
				f16_arg0.backing:setRGB( 0, 0, 0 )
				f16_arg0.backing:setAlpha( 0.5 )
				f16_local1( f16_arg0.backing )
				local f16_local2 = function ( f19_arg0 )
					f16_arg0.SocialArrowAdd:beginAnimation( 150 )
					f16_arg0.SocialArrowAdd:setTopBottom( 0, 0, 65, 73 )
					f16_arg0.SocialArrowAdd:setAlpha( 1 )
					f16_arg0.SocialArrowAdd:setScale( 1.5, 1.5 )
					f16_arg0.SocialArrowAdd:registerEventHandler( "interrupted_keyframe", f16_arg0.clipInterrupted )
					f16_arg0.SocialArrowAdd:registerEventHandler( "transition_complete_keyframe", f16_arg0.clipFinished )
				end
				f16_arg0.SocialArrowAdd:completeAnimation()
				f16_arg0.SocialArrowAdd:setTopBottom( 0, 0, 84, 92 )
				f16_arg0.SocialArrowAdd:setAlpha( 0 )
				f16_arg0.SocialArrowAdd:setScale( 1, 1 )
				f16_local2( f16_arg0.SocialArrowAdd )
				local f16_local3 = function ( f20_arg0 )
					local f20_local0 = function ( f21_arg0 )
						f21_arg0:beginAnimation( 99 )
						f21_arg0:setAlpha( 0.8 )
						f21_arg0:setShaderVector( 0, 0.1, 0.8, 0, 0 )
						f21_arg0:registerEventHandler( "transition_complete_keyframe", f16_arg0.clipFinished )
					end
					f16_arg0.backingAdd:beginAnimation( 150, Enum[@"hash_1F50FFF429AB1890"][@"hash_2053CEB9A0427197"] )
					f16_arg0.backingAdd:setAlpha( 0.9 )
					f16_arg0.backingAdd:setShaderVector( 0, 0.1, 0.95, 0, 0 )
					f16_arg0.backingAdd:registerEventHandler( "interrupted_keyframe", f16_arg0.clipInterrupted )
					f16_arg0.backingAdd:registerEventHandler( "transition_complete_keyframe", f20_local0 )
				end
				f16_arg0.backingAdd:completeAnimation()
				f16_arg0.backingAdd:setAlpha( 0 )
				f16_arg0.backingAdd:setShaderVector( 0, 0.1, 1.5, 0, 0 )
				f16_arg0.backingAdd:setShaderVector( 2, 0, 0, 0, 0 )
				f16_local3( f16_arg0.backingAdd )
				local f16_local4 = function ( f22_arg0 )
					f16_arg0.SprayOrGesture:beginAnimation( 150 )
					f16_arg0.SprayOrGesture:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )
					f16_arg0.SprayOrGesture:registerEventHandler( "interrupted_keyframe", f16_arg0.clipInterrupted )
					f16_arg0.SprayOrGesture:registerEventHandler( "transition_complete_keyframe", f16_arg0.clipFinished )
				end
				f16_arg0.SprayOrGesture:completeAnimation()
				f16_arg0.SprayOrGesture:setRGB( 0.78, 0.75, 0.62 )
				f16_local4( f16_arg0.SprayOrGesture )
			end,
			Highlighted = function ( f23_arg0, f23_arg1 )
				f23_arg0:__resetProperties()
				f23_arg0:setupElementClipCounter( 5 )
				local f23_local0 = function ( f24_arg0 )
					f23_arg0.SocialArrow:beginAnimation( 200 )
					f23_arg0.SocialArrow:setTopBottom( 0, 0, 65, 73 )
					f23_arg0.SocialArrow:setScale( 1.5, 1.5 )
					f23_arg0.SocialArrow:registerEventHandler( "interrupted_keyframe", f23_arg0.clipInterrupted )
					f23_arg0.SocialArrow:registerEventHandler( "transition_complete_keyframe", f23_arg0.clipFinished )
				end
				f23_arg0.SocialArrow:completeAnimation()
				f23_arg0.SocialArrow:setTopBottom( 0, 0, 84, 92 )
				f23_arg0.SocialArrow:setScale( 1, 1 )
				f23_local0( f23_arg0.SocialArrow )
				local f23_local1 = function ( f25_arg0 )
					f23_arg0.backing:beginAnimation( 200, Enum[@"hash_1F50FFF429AB1890"][@"hash_15193EA7825DC097"] )
					f23_arg0.backing:setTopBottom( -0.5, 0.5, -24, -24 )
					f23_arg0.backing:setRGB( 0.57, 0.42, 0.03 )
					f23_arg0.backing:setAlpha( 0.25 )
					f23_arg0.backing:setScale( 1.08, 1.08 )
					f23_arg0.backing:registerEventHandler( "interrupted_keyframe", f23_arg0.clipInterrupted )
					f23_arg0.backing:registerEventHandler( "transition_complete_keyframe", f23_arg0.clipFinished )
				end
				f23_arg0.backing:completeAnimation()
				f23_arg0.backing:setTopBottom( -0.5, 0.5, -8, -8 )
				f23_arg0.backing:setRGB( 0, 0, 0 )
				f23_arg0.backing:setAlpha( 0.5 )
				f23_arg0.backing:setScale( 1, 1 )
				f23_local1( f23_arg0.backing )
				local f23_local2 = function ( f26_arg0 )
					f23_arg0.SocialArrowAdd:beginAnimation( 200 )
					f23_arg0.SocialArrowAdd:setTopBottom( 0, 0, 65, 73 )
					f23_arg0.SocialArrowAdd:setAlpha( 1 )
					f23_arg0.SocialArrowAdd:setScale( 1.5, 1.5 )
					f23_arg0.SocialArrowAdd:registerEventHandler( "interrupted_keyframe", f23_arg0.clipInterrupted )
					f23_arg0.SocialArrowAdd:registerEventHandler( "transition_complete_keyframe", f23_arg0.clipFinished )
				end
				f23_arg0.SocialArrowAdd:completeAnimation()
				f23_arg0.SocialArrowAdd:setTopBottom( 0, 0, 84, 92 )
				f23_arg0.SocialArrowAdd:setAlpha( 0 )
				f23_arg0.SocialArrowAdd:setScale( 1, 1 )
				f23_local2( f23_arg0.SocialArrowAdd )
				local f23_local3 = function ( f27_arg0 )
					local f27_local0 = function ( f28_arg0 )
						f28_arg0:beginAnimation( 100 )
						f28_arg0:setAlpha( 0.8 )
						f28_arg0:setShaderVector( 0, 0.1, 0.8, 0, 0 )
						f28_arg0:registerEventHandler( "transition_complete_keyframe", f23_arg0.clipFinished )
					end
					f23_arg0.backingAdd:beginAnimation( 200 )
					f23_arg0.backingAdd:setTopBottom( -0.5, 0.5, -24, -24 )
					f23_arg0.backingAdd:setAlpha( 0.9 )
					f23_arg0.backingAdd:setScale( 1.08, 1.08 )
					f23_arg0.backingAdd:setShaderVector( 0, 0.1, 0.95, 0, 0 )
					f23_arg0.backingAdd:registerEventHandler( "interrupted_keyframe", f23_arg0.clipInterrupted )
					f23_arg0.backingAdd:registerEventHandler( "transition_complete_keyframe", f27_local0 )
				end
				f23_arg0.backingAdd:completeAnimation()
				f23_arg0.backingAdd:setTopBottom( -0.5, 0.5, -8, -8 )
				f23_arg0.backingAdd:setAlpha( 0 )
				f23_arg0.backingAdd:setScale( 1, 1 )
				f23_arg0.backingAdd:setShaderVector( 0, 0.1, 1.5, 0, 0 )
				f23_arg0.backingAdd:setShaderVector( 2, 0, 0, 0, 0 )
				f23_local3( f23_arg0.backingAdd )
				local f23_local4 = function ( f29_arg0 )
					f23_arg0.SprayOrGesture:beginAnimation( 200, Enum[@"hash_1F50FFF429AB1890"][@"hash_15193EA7825DC097"] )
					f23_arg0.SprayOrGesture:setTopBottom( 0, 0, -132, -17 )
					f23_arg0.SprayOrGesture:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )
					f23_arg0.SprayOrGesture:registerEventHandler( "interrupted_keyframe", f23_arg0.clipInterrupted )
					f23_arg0.SprayOrGesture:registerEventHandler( "transition_complete_keyframe", f23_arg0.clipFinished )
				end
				f23_arg0.SprayOrGesture:completeAnimation()
				f23_arg0.SprayOrGesture:setTopBottom( 0, 0, -122, -7 )
				f23_arg0.SprayOrGesture:setRGB( 0.78, 0.75, 0.62 )
				f23_local4( f23_arg0.SprayOrGesture )
				local f23_local5 = function ( f30_arg0 )
					f23_arg0.ButtonImage:beginAnimation( 200 )
					f23_arg0.ButtonImage:setTopBottom( 0, 0, 20, 60 )
					f23_arg0.ButtonImage:setAlpha( 1 )
					f23_arg0.ButtonImage:registerEventHandler( "interrupted_keyframe", f23_arg0.clipInterrupted )
					f23_arg0.ButtonImage:registerEventHandler( "transition_complete_keyframe", f23_arg0.clipFinished )
				end
				f23_arg0.ButtonImage:completeAnimation()
				f23_arg0.ButtonImage:setTopBottom( 0, 0, 40, 80 )
				f23_arg0.ButtonImage:setAlpha( 0 )
				f23_local5( f23_arg0.ButtonImage )
			end,
			Chosen = function ( f31_arg0, f31_arg1 )
				f31_arg0:__resetProperties()
				f31_arg0:setupElementClipCounter( 5 )
				local f31_local0 = function ( f32_arg0 )
					f31_arg0.SocialArrow:beginAnimation( 200 )
					f31_arg0.SocialArrow:setTopBottom( 0, 0, 65, 73 )
					f31_arg0.SocialArrow:setScale( 1.5, 1.5 )
					f31_arg0.SocialArrow:registerEventHandler( "interrupted_keyframe", f31_arg0.clipInterrupted )
					f31_arg0.SocialArrow:registerEventHandler( "transition_complete_keyframe", f31_arg0.clipFinished )
				end
				f31_arg0.SocialArrow:completeAnimation()
				f31_arg0.SocialArrow:setTopBottom( 0, 0, 84, 92 )
				f31_arg0.SocialArrow:setScale( 1, 1 )
				f31_local0( f31_arg0.SocialArrow )
				local f31_local1 = function ( f33_arg0 )
					f31_arg0.backing:beginAnimation( 200, Enum[@"hash_1F50FFF429AB1890"][@"hash_15193EA7825DC097"] )
					f31_arg0.backing:setTopBottom( -0.5, 0.5, -24, -24 )
					f31_arg0.backing:setRGB( 0.57, 0.42, 0.03 )
					f31_arg0.backing:setAlpha( 0.25 )
					f31_arg0.backing:setScale( 1.08, 1.08 )
					f31_arg0.backing:registerEventHandler( "interrupted_keyframe", f31_arg0.clipInterrupted )
					f31_arg0.backing:registerEventHandler( "transition_complete_keyframe", f31_arg0.clipFinished )
				end
				f31_arg0.backing:completeAnimation()
				f31_arg0.backing:setTopBottom( -0.5, 0.5, -8, -8 )
				f31_arg0.backing:setRGB( 0, 0, 0 )
				f31_arg0.backing:setAlpha( 0.5 )
				f31_arg0.backing:setScale( 1, 1 )
				f31_local1( f31_arg0.backing )
				local f31_local2 = function ( f34_arg0 )
					f31_arg0.SocialArrowAdd:beginAnimation( 200 )
					f31_arg0.SocialArrowAdd:setTopBottom( 0, 0, 65, 73 )
					f31_arg0.SocialArrowAdd:setAlpha( 1 )
					f31_arg0.SocialArrowAdd:setScale( 1.5, 1.5 )
					f31_arg0.SocialArrowAdd:registerEventHandler( "interrupted_keyframe", f31_arg0.clipInterrupted )
					f31_arg0.SocialArrowAdd:registerEventHandler( "transition_complete_keyframe", f31_arg0.clipFinished )
				end
				f31_arg0.SocialArrowAdd:completeAnimation()
				f31_arg0.SocialArrowAdd:setTopBottom( 0, 0, 84, 92 )
				f31_arg0.SocialArrowAdd:setAlpha( 0 )
				f31_arg0.SocialArrowAdd:setScale( 1, 1 )
				f31_local2( f31_arg0.SocialArrowAdd )
				local f31_local3 = function ( f35_arg0 )
					local f35_local0 = function ( f36_arg0 )
						f36_arg0:beginAnimation( 100 )
						f36_arg0:setAlpha( 0.8 )
						f36_arg0:setShaderVector( 0, 0.1, 0.8, 0, 0 )
						f36_arg0:registerEventHandler( "transition_complete_keyframe", f31_arg0.clipFinished )
					end
					f31_arg0.backingAdd:beginAnimation( 200 )
					f31_arg0.backingAdd:setTopBottom( -0.5, 0.5, -24, -24 )
					f31_arg0.backingAdd:setAlpha( 0.9 )
					f31_arg0.backingAdd:setScale( 1.08, 1.08 )
					f31_arg0.backingAdd:setShaderVector( 0, 0.1, 0.95, 0, 0 )
					f31_arg0.backingAdd:registerEventHandler( "interrupted_keyframe", f31_arg0.clipInterrupted )
					f31_arg0.backingAdd:registerEventHandler( "transition_complete_keyframe", f35_local0 )
				end
				f31_arg0.backingAdd:completeAnimation()
				f31_arg0.backingAdd:setTopBottom( -0.5, 0.5, -8, -8 )
				f31_arg0.backingAdd:setAlpha( 0 )
				f31_arg0.backingAdd:setScale( 1, 1 )
				f31_arg0.backingAdd:setShaderVector( 0, 0.1, 1.5, 0, 0 )
				f31_arg0.backingAdd:setShaderVector( 2, 0, 0, 0, 0 )
				f31_local3( f31_arg0.backingAdd )
				local f31_local4 = function ( f37_arg0 )
					f31_arg0.SprayOrGesture:beginAnimation( 200, Enum[@"hash_1F50FFF429AB1890"][@"hash_15193EA7825DC097"] )
					f31_arg0.SprayOrGesture:setTopBottom( 0, 0, -132, -17 )
					f31_arg0.SprayOrGesture:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )
					f31_arg0.SprayOrGesture:registerEventHandler( "interrupted_keyframe", f31_arg0.clipInterrupted )
					f31_arg0.SprayOrGesture:registerEventHandler( "transition_complete_keyframe", f31_arg0.clipFinished )
				end
				f31_arg0.SprayOrGesture:completeAnimation()
				f31_arg0.SprayOrGesture:setTopBottom( 0, 0, -122, -7 )
				f31_arg0.SprayOrGesture:setRGB( 0.78, 0.75, 0.62 )
				f31_local4( f31_arg0.SprayOrGesture )
			end
		},
		Disabled = {
			DefaultClip = function ( f38_arg0, f38_arg1 )
				f38_arg0:__resetProperties()
				f38_arg0:setupElementClipCounter( 2 )
				f38_arg0.backing:completeAnimation()
				f38_arg0.backing:setRGB( 0.15, 0.15, 0.15 )
				f38_arg0.clipFinished( f38_arg0.backing )
				f38_arg0.SprayOrGesture:completeAnimation()
				f38_arg0.SprayOrGesture:setRGB( 0.78, 0.75, 0.62 )
				f38_arg0.clipFinished( f38_arg0.SprayOrGesture )
			end
		},
		Chosen = {
			DefaultClip = function ( f39_arg0, f39_arg1 )
				f39_arg0:__resetProperties()
				f39_arg0:setupElementClipCounter( 5 )
				f39_arg0.SocialArrow:completeAnimation()
				f39_arg0.SocialArrow:setTopBottom( 0, 0, 65, 73 )
				f39_arg0.SocialArrow:setScale( 1.5, 1.5 )
				f39_arg0.clipFinished( f39_arg0.SocialArrow )
				f39_arg0.backing:completeAnimation()
				f39_arg0.backing:setTopBottom( -0.5, 0.5, -24, -24 )
				f39_arg0.backing:setRGB( 0.57, 0.42, 0.03 )
				f39_arg0.backing:setAlpha( 0.25 )
				f39_arg0.backing:setScale( 1.08, 1.08 )
				f39_arg0.clipFinished( f39_arg0.backing )
				f39_arg0.SocialArrowAdd:completeAnimation()
				f39_arg0.SocialArrowAdd:setTopBottom( 0, 0, 65, 73 )
				f39_arg0.SocialArrowAdd:setAlpha( 1 )
				f39_arg0.SocialArrowAdd:setScale( 1.4, 1.4 )
				f39_arg0.clipFinished( f39_arg0.SocialArrowAdd )
				f39_arg0.backingAdd:completeAnimation()
				f39_arg0.backingAdd:setTopBottom( -0.5, 0.5, -24, -24 )
				f39_arg0.backingAdd:setAlpha( 0.8 )
				f39_arg0.backingAdd:setScale( 1.08, 1.08 )
				f39_arg0.clipFinished( f39_arg0.backingAdd )
				f39_arg0.SprayOrGesture:completeAnimation()
				f39_arg0.SprayOrGesture:setTopBottom( 0, 0, -132, -17 )
				f39_arg0.SprayOrGesture:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )
				f39_arg0.clipFinished( f39_arg0.SprayOrGesture )
			end,
			DefaultState = function ( f40_arg0, f40_arg1 )
				f40_arg0:__resetProperties()
				f40_arg0:setupElementClipCounter( 5 )
				local f40_local0 = function ( f41_arg0 )
					local f41_local0 = function ( f42_arg0 )
						f42_arg0:beginAnimation( 240 )
						f42_arg0:setTopBottom( 0, 0, 84, 92 )
						f42_arg0:setScale( 1, 1 )
						f42_arg0:registerEventHandler( "transition_complete_keyframe", f40_arg0.clipFinished )
					end
					f40_arg0.SocialArrow:beginAnimation( 160 )
					f40_arg0.SocialArrow:registerEventHandler( "interrupted_keyframe", f40_arg0.clipInterrupted )
					f40_arg0.SocialArrow:registerEventHandler( "transition_complete_keyframe", f41_local0 )
				end
				f40_arg0.SocialArrow:completeAnimation()
				f40_arg0.SocialArrow:setTopBottom( 0, 0, 65, 73 )
				f40_arg0.SocialArrow:setAlpha( 0.2 )
				f40_arg0.SocialArrow:setScale( 1.5, 1.5 )
				f40_local0( f40_arg0.SocialArrow )
				local f40_local1 = function ( f43_arg0 )
					local f43_local0 = function ( f44_arg0 )
						f44_arg0:beginAnimation( 240, Enum[@"hash_1F50FFF429AB1890"][@"hash_15193EA7825DC097"] )
						f44_arg0:setTopBottom( -0.5, 0.5, -8, -8 )
						f44_arg0:setRGB( 0, 0, 0 )
						f44_arg0:setAlpha( 0.5 )
						f44_arg0:setScale( 1, 1 )
						f44_arg0:registerEventHandler( "transition_complete_keyframe", f40_arg0.clipFinished )
					end
					f40_arg0.backing:beginAnimation( 160 )
					f40_arg0.backing:setRGB( 0.92, 0.85, 0.67 )
					f40_arg0.backing:setAlpha( 0.8 )
					f40_arg0.backing:registerEventHandler( "interrupted_keyframe", f40_arg0.clipInterrupted )
					f40_arg0.backing:registerEventHandler( "transition_complete_keyframe", f43_local0 )
				end
				f40_arg0.backing:completeAnimation()
				f40_arg0.backing:setTopBottom( -0.5, 0.5, -24, -24 )
				f40_arg0.backing:setRGB( 0.57, 0.42, 0.03 )
				f40_arg0.backing:setAlpha( 0.25 )
				f40_arg0.backing:setScale( 1.08, 1.08 )
				f40_local1( f40_arg0.backing )
				local f40_local2 = function ( f45_arg0 )
					local f45_local0 = function ( f46_arg0 )
						f46_arg0:beginAnimation( 240 )
						f46_arg0:setTopBottom( 0, 0, 84, 92 )
						f46_arg0:setAlpha( 0 )
						f46_arg0:setScale( 1, 1 )
						f46_arg0:registerEventHandler( "transition_complete_keyframe", f40_arg0.clipFinished )
					end
					f40_arg0.SocialArrowAdd:beginAnimation( 160 )
					f40_arg0.SocialArrowAdd:setAlpha( 0.6 )
					f40_arg0.SocialArrowAdd:registerEventHandler( "interrupted_keyframe", f40_arg0.clipInterrupted )
					f40_arg0.SocialArrowAdd:registerEventHandler( "transition_complete_keyframe", f45_local0 )
				end
				f40_arg0.SocialArrowAdd:completeAnimation()
				f40_arg0.SocialArrowAdd:setTopBottom( 0, 0, 65, 73 )
				f40_arg0.SocialArrowAdd:setAlpha( 1 )
				f40_arg0.SocialArrowAdd:setScale( 1.5, 1.5 )
				f40_local2( f40_arg0.SocialArrowAdd )
				local f40_local3 = function ( f47_arg0 )
					local f47_local0 = function ( f48_arg0 )
						f48_arg0:beginAnimation( 240 )
						f48_arg0:setTopBottom( -0.5, 0.5, -8, -8 )
						f48_arg0:setAlpha( 0 )
						f48_arg0:setScale( 1, 1 )
						f48_arg0:registerEventHandler( "transition_complete_keyframe", f40_arg0.clipFinished )
					end
					f40_arg0.backingAdd:beginAnimation( 160 )
					f40_arg0.backingAdd:registerEventHandler( "interrupted_keyframe", f40_arg0.clipInterrupted )
					f40_arg0.backingAdd:registerEventHandler( "transition_complete_keyframe", f47_local0 )
				end
				f40_arg0.backingAdd:completeAnimation()
				f40_arg0.backingAdd:setTopBottom( -0.5, 0.5, -24, -24 )
				f40_arg0.backingAdd:setAlpha( 0.8 )
				f40_arg0.backingAdd:setScale( 1.08, 1.08 )
				f40_local3( f40_arg0.backingAdd )
				local f40_local4 = function ( f49_arg0 )
					local f49_local0 = function ( f50_arg0 )
						f50_arg0:beginAnimation( 240, Enum[@"hash_1F50FFF429AB1890"][@"hash_15193EA7825DC097"] )
						f50_arg0:setTopBottom( 0, 0, -122, -7 )
						f50_arg0:setRGB( 0.78, 0.75, 0.62 )
						f50_arg0:registerEventHandler( "transition_complete_keyframe", f40_arg0.clipFinished )
					end
					f40_arg0.SprayOrGesture:beginAnimation( 160 )
					f40_arg0.SprayOrGesture:registerEventHandler( "interrupted_keyframe", f40_arg0.clipInterrupted )
					f40_arg0.SprayOrGesture:registerEventHandler( "transition_complete_keyframe", f49_local0 )
				end
				f40_arg0.SprayOrGesture:completeAnimation()
				f40_arg0.SprayOrGesture:setTopBottom( 0, 0, -132, -17 )
				f40_arg0.SprayOrGesture:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )
				f40_arg0.SprayOrGesture:setAlpha( 1 )
				f40_local4( f40_arg0.SprayOrGesture )
			end,
			Highlighted = function ( f51_arg0, f51_arg1 )
				f51_arg0:__resetProperties()
				f51_arg0:setupElementClipCounter( 5 )
				f51_arg0.SocialArrow:completeAnimation()
				f51_arg0.SocialArrow:setTopBottom( 0, 0, 65, 73 )
				f51_arg0.SocialArrow:setScale( 1.5, 1.5 )
				f51_arg0.clipFinished( f51_arg0.SocialArrow )
				f51_arg0.backing:completeAnimation()
				f51_arg0.backing:setTopBottom( -0.5, 0.5, -24, -24 )
				f51_arg0.backing:setRGB( 0.57, 0.42, 0.03 )
				f51_arg0.backing:setAlpha( 0.25 )
				f51_arg0.backing:setScale( 1.08, 1.08 )
				f51_arg0.clipFinished( f51_arg0.backing )
				f51_arg0.SocialArrowAdd:completeAnimation()
				f51_arg0.SocialArrowAdd:setTopBottom( 0, 0, 65, 73 )
				f51_arg0.SocialArrowAdd:setAlpha( 1 )
				f51_arg0.SocialArrowAdd:setScale( 1.5, 1.5 )
				f51_arg0.clipFinished( f51_arg0.SocialArrowAdd )
				f51_arg0.backingAdd:completeAnimation()
				f51_arg0.backingAdd:setTopBottom( -0.5, 0.5, -24, -24 )
				f51_arg0.backingAdd:setAlpha( 0.8 )
				f51_arg0.backingAdd:setScale( 1.08, 1.08 )
				f51_arg0.clipFinished( f51_arg0.backingAdd )
				f51_arg0.SprayOrGesture:completeAnimation()
				f51_arg0.SprayOrGesture:setTopBottom( 0, 0, -132, -17 )
				f51_arg0.SprayOrGesture:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )
				f51_arg0.clipFinished( f51_arg0.SprayOrGesture )
			end
		},
		Highlighted = {
			DefaultClip = function ( f52_arg0, f52_arg1 )
				f52_arg0:__resetProperties()
				f52_arg0:setupElementClipCounter( 5 )
				f52_arg0.SocialArrow:completeAnimation()
				f52_arg0.SocialArrow:setTopBottom( 0, 0, 65, 73 )
				f52_arg0.SocialArrow:setScale( 1.5, 1.5 )
				f52_arg0.clipFinished( f52_arg0.SocialArrow )
				f52_arg0.backing:completeAnimation()
				f52_arg0.backing:setTopBottom( -0.5, 0.5, -24, -24 )
				f52_arg0.backing:setRGB( 0.57, 0.42, 0.03 )
				f52_arg0.backing:setAlpha( 0.25 )
				f52_arg0.backing:setScale( 1.08, 1.08 )
				f52_arg0.clipFinished( f52_arg0.backing )
				f52_arg0.SocialArrowAdd:completeAnimation()
				f52_arg0.SocialArrowAdd:setTopBottom( 0, 0, 65, 73 )
				f52_arg0.SocialArrowAdd:setAlpha( 1 )
				f52_arg0.SocialArrowAdd:setScale( 1.5, 1.5 )
				f52_arg0.clipFinished( f52_arg0.SocialArrowAdd )
				f52_arg0.backingAdd:completeAnimation()
				f52_arg0.backingAdd:setTopBottom( -0.5, 0.5, -24, -24 )
				f52_arg0.backingAdd:setAlpha( 0.8 )
				f52_arg0.backingAdd:setScale( 1.08, 1.08 )
				f52_arg0.clipFinished( f52_arg0.backingAdd )
				f52_arg0.SprayOrGesture:completeAnimation()
				f52_arg0.SprayOrGesture:setTopBottom( 0, 0, -132, -17 )
				f52_arg0.SprayOrGesture:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )
				f52_arg0.clipFinished( f52_arg0.SprayOrGesture )
				f52_arg0.ButtonImage:completeAnimation()
				f52_arg0.ButtonImage:setAlpha( 1 )
				f52_arg0.clipFinished( f52_arg0.ButtonImage )
			end,
			DefaultState = function ( f53_arg0, f53_arg1 )
				f53_arg0:__resetProperties()
				f53_arg0:setupElementClipCounter( 5 )
				local f53_local0 = function ( f54_arg0 )
					f53_arg0.SocialArrow:beginAnimation( 200 )
					f53_arg0.SocialArrow:setTopBottom( 0, 0, 84, 92 )
					f53_arg0.SocialArrow:setScale( 1, 1 )
					f53_arg0.SocialArrow:registerEventHandler( "interrupted_keyframe", f53_arg0.clipInterrupted )
					f53_arg0.SocialArrow:registerEventHandler( "transition_complete_keyframe", f53_arg0.clipFinished )
				end
				f53_arg0.SocialArrow:completeAnimation()
				f53_arg0.SocialArrow:setTopBottom( 0, 0, 65, 73 )
				f53_arg0.SocialArrow:setScale( 1.5, 1.5 )
				f53_local0( f53_arg0.SocialArrow )
				local f53_local1 = function ( f55_arg0 )
					f53_arg0.backing:beginAnimation( 200, Enum[@"hash_1F50FFF429AB1890"][@"hash_15193EA7825DC097"] )
					f53_arg0.backing:setTopBottom( -0.5, 0.5, -8, -8 )
					f53_arg0.backing:setRGB( 0, 0, 0 )
					f53_arg0.backing:setAlpha( 0.5 )
					f53_arg0.backing:setScale( 1, 1 )
					f53_arg0.backing:registerEventHandler( "interrupted_keyframe", f53_arg0.clipInterrupted )
					f53_arg0.backing:registerEventHandler( "transition_complete_keyframe", f53_arg0.clipFinished )
				end
				f53_arg0.backing:completeAnimation()
				f53_arg0.backing:setTopBottom( -0.5, 0.5, -24, -24 )
				f53_arg0.backing:setRGB( 0.57, 0.42, 0.03 )
				f53_arg0.backing:setAlpha( 0.25 )
				f53_arg0.backing:setScale( 1.08, 1.08 )
				f53_local1( f53_arg0.backing )
				local f53_local2 = function ( f56_arg0 )
					f53_arg0.SocialArrowAdd:beginAnimation( 200 )
					f53_arg0.SocialArrowAdd:setTopBottom( 0, 0, 84, 92 )
					f53_arg0.SocialArrowAdd:setAlpha( 0 )
					f53_arg0.SocialArrowAdd:setScale( 1, 1 )
					f53_arg0.SocialArrowAdd:registerEventHandler( "interrupted_keyframe", f53_arg0.clipInterrupted )
					f53_arg0.SocialArrowAdd:registerEventHandler( "transition_complete_keyframe", f53_arg0.clipFinished )
				end
				f53_arg0.SocialArrowAdd:completeAnimation()
				f53_arg0.SocialArrowAdd:setTopBottom( 0, 0, 65, 73 )
				f53_arg0.SocialArrowAdd:setAlpha( 1 )
				f53_arg0.SocialArrowAdd:setScale( 1.5, 1.5 )
				f53_local2( f53_arg0.SocialArrowAdd )
				local f53_local3 = function ( f57_arg0 )
					f53_arg0.backingAdd:beginAnimation( 200 )
					f53_arg0.backingAdd:setTopBottom( -0.5, 0.5, -8, -8 )
					f53_arg0.backingAdd:setAlpha( 0 )
					f53_arg0.backingAdd:setScale( 1, 1 )
					f53_arg0.backingAdd:registerEventHandler( "interrupted_keyframe", f53_arg0.clipInterrupted )
					f53_arg0.backingAdd:registerEventHandler( "transition_complete_keyframe", f53_arg0.clipFinished )
				end
				f53_arg0.backingAdd:completeAnimation()
				f53_arg0.backingAdd:setTopBottom( -0.5, 0.5, -24, -24 )
				f53_arg0.backingAdd:setAlpha( 0.8 )
				f53_arg0.backingAdd:setScale( 1.08, 1.08 )
				f53_local3( f53_arg0.backingAdd )
				local f53_local4 = function ( f58_arg0 )
					f53_arg0.SprayOrGesture:beginAnimation( 200, Enum[@"hash_1F50FFF429AB1890"][@"hash_15193EA7825DC097"] )
					f53_arg0.SprayOrGesture:setTopBottom( 0, 0, -122, -7 )
					f53_arg0.SprayOrGesture:setRGB( 0.78, 0.75, 0.62 )
					f53_arg0.SprayOrGesture:registerEventHandler( "interrupted_keyframe", f53_arg0.clipInterrupted )
					f53_arg0.SprayOrGesture:registerEventHandler( "transition_complete_keyframe", f53_arg0.clipFinished )
				end
				f53_arg0.SprayOrGesture:completeAnimation()
				f53_arg0.SprayOrGesture:setTopBottom( 0, 0, -132, -17 )
				f53_arg0.SprayOrGesture:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )
				f53_local4( f53_arg0.SprayOrGesture )
				local f53_local5 = function ( f59_arg0 )
					f53_arg0.ButtonImage:beginAnimation( 200 )
					f53_arg0.ButtonImage:setTopBottom( 0, 0, 40, 80 )
					f53_arg0.ButtonImage:setAlpha( 0 )
					f53_arg0.ButtonImage:registerEventHandler( "interrupted_keyframe", f53_arg0.clipInterrupted )
					f53_arg0.ButtonImage:registerEventHandler( "transition_complete_keyframe", f53_arg0.clipFinished )
				end
				f53_arg0.ButtonImage:completeAnimation()
				f53_arg0.ButtonImage:setTopBottom( 0, 0, 20, 60 )
				f53_arg0.ButtonImage:setAlpha( 1 )
				f53_local5( f53_arg0.ButtonImage )
			end,
			Chosen = function ( f60_arg0, f60_arg1 )
				f60_arg0:__resetProperties()
				f60_arg0:setupElementClipCounter( 5 )
				f60_arg0.SocialArrow:completeAnimation()
				f60_arg0.SocialArrow:setTopBottom( 0, 0, 65, 73 )
				f60_arg0.SocialArrow:setScale( 1.5, 1.5 )
				f60_arg0.clipFinished( f60_arg0.SocialArrow )
				f60_arg0.backing:completeAnimation()
				f60_arg0.backing:setTopBottom( -0.5, 0.5, -24, -24 )
				f60_arg0.backing:setRGB( 0.57, 0.42, 0.03 )
				f60_arg0.backing:setAlpha( 0.25 )
				f60_arg0.backing:setScale( 1.08, 1.08 )
				f60_arg0.clipFinished( f60_arg0.backing )
				f60_arg0.SocialArrowAdd:completeAnimation()
				f60_arg0.SocialArrowAdd:setTopBottom( 0, 0, 65, 73 )
				f60_arg0.SocialArrowAdd:setAlpha( 1 )
				f60_arg0.SocialArrowAdd:setScale( 1.5, 1.5 )
				f60_arg0.clipFinished( f60_arg0.SocialArrowAdd )
				f60_arg0.backingAdd:completeAnimation()
				f60_arg0.backingAdd:setTopBottom( -0.5, 0.5, -24, -24 )
				f60_arg0.backingAdd:setAlpha( 0.8 )
				f60_arg0.backingAdd:setScale( 1.08, 1.08 )
				f60_arg0.clipFinished( f60_arg0.backingAdd )
				f60_arg0.SprayOrGesture:completeAnimation()
				f60_arg0.SprayOrGesture:setTopBottom( 0, 0, -132, -17 )
				f60_arg0.SprayOrGesture:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )
				f60_arg0.clipFinished( f60_arg0.SprayOrGesture )
			end
		}
	}
	CoD.SprayOrGesture.__onClose = function ( f61_arg0 )
		f61_arg0.backingSolid:close()
		f61_arg0.backing:close()
		f61_arg0.backingAdd:close()
		f61_arg0.SprayOrGesture:close()
		f61_arg0.ButtonImage:close()
	end
end

if not CoD.MPSpraysAndGestures then
	CoD.MPSpraysAndGestures = InheritFrom( LUI.UIElement )
	CoD.MPSpraysAndGestures.__defaultWidth = 1920
	CoD.MPSpraysAndGestures.__defaultHeight = 1080
	CoD.MPSpraysAndGestures.new = function ( f1_arg0, f1_arg1, f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
		local self = LUI.UIElement.new( f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
		self:setUseCylinderMapping( false )
		self:setClass( CoD.MPSpraysAndGestures )
		self.id = "MPSpraysAndGestures"
		self.soundSet = "default"
		self.onlyChildrenFocusable = true
		self.anyChildUsesUpdateState = true
		f1_arg0:addElementToPendingUpdateStateList( self )

		local BGDarkening = LUI.UIImage.new( 0, 1, 0, 0, 0, 1, 0, 0 )
		BGDarkening:setRGB( 0, 0, 0 )
		BGDarkening:setAlpha( 0.65 )
		self:addElement( BGDarkening )
		self.BGDarkening = BGDarkening

		local CenterCircle = LUI.UIImage.new( 0.5, 0.5, -78, 78, 0.5, 0.5, -78, 78 )
		CenterCircle:setImage( RegisterImage( @"uie_ui_hud_radial_menu_center_circle" ) )
		CenterCircle:setMaterial( LUI.UIImage.GetCachedMaterial( @"hash_F755127C95CF5B6" ) )
		CenterCircle:setShaderVector( 0, 1.5, 0, 0, 0 )
		self:addElement( CenterCircle )
		self.CenterCircle = CenterCircle

		local SpraysAndGestures = LUI.WheelLayout.new( f1_arg0, f1_arg1, nil )
		SpraysAndGestures:setLeftRight( 0.5, 0.5, -177, 177 )
		SpraysAndGestures:setTopBottom( 0.5, 0.5, -177, 177 )
		SpraysAndGestures:setWidgetType( CoD.SprayOrGesture )
		SpraysAndGestures:setCount( 8 )
		SpraysAndGestures:setDataSource( "ShieldSpraysAndGestures" )
		self:addElement( SpraysAndGestures )
		self.SpraysAndGestures = SpraysAndGestures

		local MPWheelPrompt = CoD.MPWheelPrompt.new( f1_arg0, f1_arg1, 0.5, 0.5, -40, 40, 0.5, 0.5, -40, 40 )
		MPWheelPrompt:subscribeToGlobalModel( f1_arg1, "Controller", "move_right_stick_button_image", function ( model )
			local f2_local0 = model:get()
			if f2_local0 ~= nil then
				MPWheelPrompt.RStick:setImage( RegisterImage( f2_local0 ) )
			end
		end )
		self:addElement( MPWheelPrompt )
		self.MPWheelPrompt = MPWheelPrompt

		local Pointer = CoD.WheelTriangleIndicator.new( f1_arg0, f1_arg1, 0.5, 0.5, -12, 12, 0.5, 0.5, -12, 12 )
		Pointer:subscribeToGlobalModel( f1_arg1, "HUDItems", "wheelPointerDegrees", function ( model )
			local f3_local0 = model:get()
			if f3_local0 ~= nil then
				Pointer:setZRot( f3_local0 )
			end
		end )
		self:addElement( Pointer )
		self.Pointer = Pointer

		local emptyFocusable = nil

		emptyFocusable = CoD.emptyFocusable.new( f1_arg0, f1_arg1, 0, 1, 0, 0, 0, 1, 0, 0 )
		emptyFocusable:registerEventHandler( "gain_focus", function ( element, event )
			local f4_local0 = nil
			if element.gainFocus then
				f4_local0 = element:gainFocus( event )
			elseif element.super.gainFocus then
				f4_local0 = element.super:gainFocus( event )
			end
			CoD.Menu.UpdateButtonShownState( element, f1_arg0, f1_arg1, Enum[@"luibutton"][@"lui_key_xba_pscross"] )
			return f4_local0
		end )
		f1_arg0:AddButtonCallbackFunction( emptyFocusable, f1_arg1, Enum[@"luibutton"][@"lui_key_xba_pscross"], "ui_confirm", function ( element, menu, controller, model )
			if IsPC() then
				SetElementState( self, self, controller, "DefaultState" )
				return true
			else

			end
		end, function ( element, menu, controller )
			if IsPC() then
				CoD.Menu.SetButtonLabel( menu, Enum[@"luibutton"][@"lui_key_xba_pscross"], @"menu/select", nil, "ui_confirm" )
				return true
			else
				return false
			end
		end, false )
		self:addElement( emptyFocusable )
		self.emptyFocusable = emptyFocusable

		self:mergeStateConditions( {
			{
				stateName = "Visible",
				condition = function ( menu, element, event )
					local f7_local0 = CoD.HUDUtility.IsSpraysAndGesturesButtonHeld( f1_arg1 )
					if f7_local0 then
						if not Engine[@"isvisibilitybitset"]( f1_arg1, Enum[@"uivisibilitybit"][@"bit_game_ended"] ) and not Engine[@"isvisibilitybitset"]( f1_arg1, Enum[@"uivisibilitybit"][@"bit_in_guided_missile"] ) and not Engine[@"isvisibilitybitset"]( f1_arg1, Enum[@"uivisibilitybit"][@"bit_in_remote_killstreak_static"] ) and not Engine[@"isvisibilitybitset"]( f1_arg1, Enum[@"uivisibilitybit"][@"bit_in_remote_missile"] ) and not Engine[@"isvisibilitybitset"]( f1_arg1, Enum[@"uivisibilitybit"][@"bit_in_vehicle"] ) and not Engine[@"isvisibilitybitset"]( f1_arg1, Enum[@"uivisibilitybit"][@"bit_is_demo_playing"] ) and not Engine[@"isvisibilitybitset"]( f1_arg1, Enum[@"uivisibilitybit"][@"bit_player_dead"] ) and not Engine[@"isvisibilitybitset"]( f1_arg1, Enum[@"uivisibilitybit"][@"bit_round_end_killcam"] ) and not Engine[@"isvisibilitybitset"]( f1_arg1, Enum[@"uivisibilitybit"][@"bit_scoreboard_open"] ) and not Engine[@"isvisibilitybitset"]( f1_arg1, Enum[@"uivisibilitybit"][@"bit_spectating_client"] ) and not CoD.HUDUtility.HideWheelInPrematch( f1_arg1 ) then
							f7_local0 = not CoD.ModelUtility.IsClientModelValueTrue( f1_arg1, "isInLastStand" )
						else
							f7_local0 = false
						end
					end
					return f7_local0
				end
			}
		} )
		local f1_local7 = self
		local f1_local8 = self.subscribeToModel
		local f1_local9 = Engine[@"getmodelforcontroller"]( f1_arg1 )
		f1_local8( f1_local7, f1_local9["ButtonBits.actionSlots.Sprays_Boasts"], function ( f8_arg0 )
			f1_arg0:updateElementState( self, {
				name = "model_validation",
				menu = f1_arg0,
				controller = f1_arg1,
				modelValue = f8_arg0:get(),
				modelName = "ButtonBits.actionSlots.Sprays_Boasts"
			} )
		end, false )
		f1_local7 = self
		f1_local8 = self.subscribeToModel
		f1_local9 = Engine[@"getmodelforcontroller"]( f1_arg1 )
		f1_local8( f1_local7, f1_local9["hudItems.PCWheels.sprayGestureWheelKeyPressed"], function ( f9_arg0 )
			f1_arg0:updateElementState( self, {
				name = "model_validation",
				menu = f1_arg0,
				controller = f1_arg1,
				modelValue = f9_arg0:get(),
				modelName = "hudItems.PCWheels.sprayGestureWheelKeyPressed"
			} )
		end, false )
		f1_local7 = self
		f1_local8 = self.subscribeToModel
		f1_local9 = Engine[@"getmodelforcontroller"]( f1_arg1 )
		f1_local8( f1_local7, f1_local9["hudItems.PCWheels.calloutWheelKeyPressed"], function ( f10_arg0 )
			f1_arg0:updateElementState( self, {
				name = "model_validation",
				menu = f1_arg0,
				controller = f1_arg1,
				modelValue = f10_arg0:get(),
				modelName = "hudItems.PCWheels.calloutWheelKeyPressed"
			} )
		end, false )
		f1_local7 = self
		f1_local8 = self.subscribeToModel
		f1_local9 = Engine[@"getmodelforcontroller"]( f1_arg1 )
		f1_local8( f1_local7, f1_local9["UIVisibilityBit." .. Enum[@"uivisibilitybit"][@"bit_game_ended"]], function ( f11_arg0 )
			f1_arg0:updateElementState( self, {
				name = "model_validation",
				menu = f1_arg0,
				controller = f1_arg1,
				modelValue = f11_arg0:get(),
				modelName = "UIVisibilityBit." .. Enum[@"uivisibilitybit"][@"bit_game_ended"]
			} )
		end, false )
		f1_local7 = self
		f1_local8 = self.subscribeToModel
		f1_local9 = Engine[@"getmodelforcontroller"]( f1_arg1 )
		f1_local8( f1_local7, f1_local9["UIVisibilityBit." .. Enum[@"uivisibilitybit"][@"bit_in_guided_missile"]], function ( f12_arg0 )
			f1_arg0:updateElementState( self, {
				name = "model_validation",
				menu = f1_arg0,
				controller = f1_arg1,
				modelValue = f12_arg0:get(),
				modelName = "UIVisibilityBit." .. Enum[@"uivisibilitybit"][@"bit_in_guided_missile"]
			} )
		end, false )
		f1_local7 = self
		f1_local8 = self.subscribeToModel
		f1_local9 = Engine[@"getmodelforcontroller"]( f1_arg1 )
		f1_local8( f1_local7, f1_local9["UIVisibilityBit." .. Enum[@"uivisibilitybit"][@"bit_in_remote_killstreak_static"]], function ( f13_arg0 )
			f1_arg0:updateElementState( self, {
				name = "model_validation",
				menu = f1_arg0,
				controller = f1_arg1,
				modelValue = f13_arg0:get(),
				modelName = "UIVisibilityBit." .. Enum[@"uivisibilitybit"][@"bit_in_remote_killstreak_static"]
			} )
		end, false )
		f1_local7 = self
		f1_local8 = self.subscribeToModel
		f1_local9 = Engine[@"getmodelforcontroller"]( f1_arg1 )
		f1_local8( f1_local7, f1_local9["UIVisibilityBit." .. Enum[@"uivisibilitybit"][@"bit_in_remote_missile"]], function ( f14_arg0 )
			f1_arg0:updateElementState( self, {
				name = "model_validation",
				menu = f1_arg0,
				controller = f1_arg1,
				modelValue = f14_arg0:get(),
				modelName = "UIVisibilityBit." .. Enum[@"uivisibilitybit"][@"bit_in_remote_missile"]
			} )
		end, false )
		f1_local7 = self
		f1_local8 = self.subscribeToModel
		f1_local9 = Engine[@"getmodelforcontroller"]( f1_arg1 )
		f1_local8( f1_local7, f1_local9["UIVisibilityBit." .. Enum[@"uivisibilitybit"][@"bit_in_vehicle"]], function ( f15_arg0 )
			f1_arg0:updateElementState( self, {
				name = "model_validation",
				menu = f1_arg0,
				controller = f1_arg1,
				modelValue = f15_arg0:get(),
				modelName = "UIVisibilityBit." .. Enum[@"uivisibilitybit"][@"bit_in_vehicle"]
			} )
		end, false )
		f1_local7 = self
		f1_local8 = self.subscribeToModel
		f1_local9 = Engine[@"getmodelforcontroller"]( f1_arg1 )
		f1_local8( f1_local7, f1_local9["UIVisibilityBit." .. Enum[@"uivisibilitybit"][@"bit_is_demo_playing"]], function ( f16_arg0 )
			f1_arg0:updateElementState( self, {
				name = "model_validation",
				menu = f1_arg0,
				controller = f1_arg1,
				modelValue = f16_arg0:get(),
				modelName = "UIVisibilityBit." .. Enum[@"uivisibilitybit"][@"bit_is_demo_playing"]
			} )
		end, false )
		f1_local7 = self
		f1_local8 = self.subscribeToModel
		f1_local9 = Engine[@"getmodelforcontroller"]( f1_arg1 )
		f1_local8( f1_local7, f1_local9["UIVisibilityBit." .. Enum[@"uivisibilitybit"][@"bit_player_dead"]], function ( f17_arg0 )
			f1_arg0:updateElementState( self, {
				name = "model_validation",
				menu = f1_arg0,
				controller = f1_arg1,
				modelValue = f17_arg0:get(),
				modelName = "UIVisibilityBit." .. Enum[@"uivisibilitybit"][@"bit_player_dead"]
			} )
		end, false )
		f1_local7 = self
		f1_local8 = self.subscribeToModel
		f1_local9 = Engine[@"getmodelforcontroller"]( f1_arg1 )
		f1_local8( f1_local7, f1_local9["UIVisibilityBit." .. Enum[@"uivisibilitybit"][@"bit_round_end_killcam"]], function ( f18_arg0 )
			f1_arg0:updateElementState( self, {
				name = "model_validation",
				menu = f1_arg0,
				controller = f1_arg1,
				modelValue = f18_arg0:get(),
				modelName = "UIVisibilityBit." .. Enum[@"uivisibilitybit"][@"bit_round_end_killcam"]
			} )
		end, false )
		f1_local7 = self
		f1_local8 = self.subscribeToModel
		f1_local9 = Engine[@"getmodelforcontroller"]( f1_arg1 )
		f1_local8( f1_local7, f1_local9["UIVisibilityBit." .. Enum[@"uivisibilitybit"][@"bit_scoreboard_open"]], function ( f19_arg0 )
			f1_arg0:updateElementState( self, {
				name = "model_validation",
				menu = f1_arg0,
				controller = f1_arg1,
				modelValue = f19_arg0:get(),
				modelName = "UIVisibilityBit." .. Enum[@"uivisibilitybit"][@"bit_scoreboard_open"]
			} )
		end, false )
		f1_local7 = self
		f1_local8 = self.subscribeToModel
		f1_local9 = Engine[@"getmodelforcontroller"]( f1_arg1 )
		f1_local8( f1_local7, f1_local9["UIVisibilityBit." .. Enum[@"uivisibilitybit"][@"bit_spectating_client"]], function ( f20_arg0 )
			f1_arg0:updateElementState( self, {
				name = "model_validation",
				menu = f1_arg0,
				controller = f1_arg1,
				modelValue = f20_arg0:get(),
				modelName = "UIVisibilityBit." .. Enum[@"uivisibilitybit"][@"bit_spectating_client"]
			} )
		end, false )
		f1_local7 = self
		f1_local8 = self.subscribeToModel
		f1_local9 = Engine[@"getmodelforclient"]( Engine[@"getclientnum"]( f1_arg1 ) )
		f1_local8( f1_local7, f1_local9.isInLastStand, function ( f21_arg0 )
			f1_arg0:updateElementState( self, {
				name = "model_validation",
				menu = f1_arg0,
				controller = f1_arg1,
				modelValue = f21_arg0:get(),
				modelName = "isInLastStand"
			} )
		end, false )
		LUI.OverrideFunction_CallOriginalFirst( self, "setState", function ( element, controller, f22_arg2, f22_arg3, f22_arg4 )
			if IsSelfInState( self, "Visible" ) then
				CoD.HUDUtility.MenuDelayedSetRightStickLock( f1_arg0, controller, 0, true )
			else
				CoD.HUDUtility.MenuDelayedSetRightStickLock( f1_arg0, controller, 125, false )
				CoD.HUDUtility.DisableWheelSelection( controller, self, self.SpraysAndGestures )
			end
		end )
		self:subscribeToGlobalModel( f1_arg1, "RightStick", "Length", function ( model )
			local f23_local0 = self
			if IsSelfInState( self, "Visible" ) then
				CoD.HUDUtility.UpdateSelectionModelFromLength( f1_arg1, self, self.SpraysAndGestures, model, false )
			end
		end )
		self:subscribeToGlobalModel( f1_arg1, "RightStick", "Degrees", function ( model )
			local f24_local0 = self
			if IsSelfInState( self, "Visible" ) then
				CoD.HUDUtility.UpdateSelectionModelFromDegrees( f1_arg1, self, self.SpraysAndGestures, false )
			end
		end )
		self:subscribeToGlobalModel( f1_arg1, "PerController", "ButtonBits.actionSlots.Sprays_Boasts", function ( model )
			local f25_local0 = self
			if CoD.ModelUtility.IsParamModelEqualToEnum( model, Enum[@"hash_1A3A4D6F29781E2C"][@"hash_643535815622BB59"] ) then
				CoD.ShieldQuickSpray( f1_arg1 )
			end
		end )
		if CoD.isPC then
			emptyFocusable.id = "emptyFocusable"
		end
		LUI.OverrideFunction_CallOriginalSecond( self, "close", self.__onClose )

		f1_local8 = self
		CoD.HUDUtility.AddSprayGestureCallback( f1_arg1, self.SpraysAndGestures )
		CoD.HUDUtility.InitWheelPCForMouseDrag( self, f1_arg1, f1_arg0, self.SpraysAndGestures )
		return self
	end
	CoD.MPSpraysAndGestures.__resetProperties = function ( f26_arg0 )
		f26_arg0.SpraysAndGestures:completeAnimation()
		f26_arg0.CenterCircle:completeAnimation()
		f26_arg0.BGDarkening:completeAnimation()
		f26_arg0.Pointer:completeAnimation()
		f26_arg0.MPWheelPrompt:completeAnimation()
		f26_arg0.emptyFocusable:completeAnimation()
		f26_arg0.SpraysAndGestures:setAlpha( 1 )
		f26_arg0.CenterCircle:setAlpha( 1 )
		f26_arg0.BGDarkening:setAlpha( 0.65 )
		f26_arg0.Pointer:setAlpha( 1 )
		f26_arg0.MPWheelPrompt:setAlpha( 1 )
		f26_arg0.emptyFocusable:setAlpha( 1 )
	end
	CoD.MPSpraysAndGestures.__clipsPerState = {
		DefaultState = {
			DefaultClip = function ( f27_arg0, f27_arg1 )
				f27_arg0:__resetProperties()
				f27_arg0:setupElementClipCounter( 6 )
				f27_arg0.BGDarkening:completeAnimation()
				f27_arg0.BGDarkening:setAlpha( 0 )
				f27_arg0.clipFinished( f27_arg0.BGDarkening )
				f27_arg0.CenterCircle:completeAnimation()
				f27_arg0.CenterCircle:setAlpha( 0 )
				f27_arg0.clipFinished( f27_arg0.CenterCircle )
				f27_arg0.SpraysAndGestures:completeAnimation()
				f27_arg0.SpraysAndGestures:setAlpha( 0 )
				f27_arg0.clipFinished( f27_arg0.SpraysAndGestures )
				f27_arg0.MPWheelPrompt:completeAnimation()
				f27_arg0.MPWheelPrompt:setAlpha( 0 )
				f27_arg0.clipFinished( f27_arg0.MPWheelPrompt )
				f27_arg0.Pointer:completeAnimation()
				f27_arg0.Pointer:setAlpha( 0 )
				f27_arg0.clipFinished( f27_arg0.Pointer )
				f27_arg0.emptyFocusable:completeAnimation()
				f27_arg0.emptyFocusable:setAlpha( 0 )
				f27_arg0.clipFinished( f27_arg0.emptyFocusable )
			end,
			Visible = function ( f28_arg0, f28_arg1 )
				f28_arg0:__resetProperties()
				f28_arg0:setupElementClipCounter( 5 )
				local f28_local0 = function ( f29_arg0 )
					f28_arg0.BGDarkening:beginAnimation( 60 )
					f28_arg0.BGDarkening:setAlpha( 0.4 )
					f28_arg0.BGDarkening:registerEventHandler( "interrupted_keyframe", f28_arg0.clipInterrupted )
					f28_arg0.BGDarkening:registerEventHandler( "transition_complete_keyframe", f28_arg0.clipFinished )
				end
				f28_arg0.BGDarkening:completeAnimation()
				f28_arg0.BGDarkening:setAlpha( 0 )
				f28_local0( f28_arg0.BGDarkening )
				local f28_local1 = function ( f30_arg0 )
					f28_arg0.CenterCircle:beginAnimation( 60 )
					f28_arg0.CenterCircle:setAlpha( 1 )
					f28_arg0.CenterCircle:registerEventHandler( "interrupted_keyframe", f28_arg0.clipInterrupted )
					f28_arg0.CenterCircle:registerEventHandler( "transition_complete_keyframe", f28_arg0.clipFinished )
				end
				f28_arg0.CenterCircle:completeAnimation()
				f28_arg0.CenterCircle:setAlpha( 0 )
				f28_local1( f28_arg0.CenterCircle )
				local f28_local2 = function ( f31_arg0 )
					f28_arg0.SpraysAndGestures:beginAnimation( 60 )
					f28_arg0.SpraysAndGestures:setAlpha( 1 )
					f28_arg0.SpraysAndGestures:registerEventHandler( "interrupted_keyframe", f28_arg0.clipInterrupted )
					f28_arg0.SpraysAndGestures:registerEventHandler( "transition_complete_keyframe", f28_arg0.clipFinished )
				end
				f28_arg0.SpraysAndGestures:completeAnimation()
				f28_arg0.SpraysAndGestures:setAlpha( 0 )
				f28_local2( f28_arg0.SpraysAndGestures )
				local f28_local3 = function ( f32_arg0 )
					f28_arg0.MPWheelPrompt:beginAnimation( 60 )
					f28_arg0.MPWheelPrompt:setAlpha( 1 )
					f28_arg0.MPWheelPrompt:registerEventHandler( "interrupted_keyframe", f28_arg0.clipInterrupted )
					f28_arg0.MPWheelPrompt:registerEventHandler( "transition_complete_keyframe", f28_arg0.clipFinished )
				end
				f28_arg0.MPWheelPrompt:completeAnimation()
				f28_arg0.MPWheelPrompt:setAlpha( 0 )
				f28_local3( f28_arg0.MPWheelPrompt )
				local f28_local4 = function ( f33_arg0 )
					f28_arg0.Pointer:beginAnimation( 60 )
					f28_arg0.Pointer:setAlpha( 1 )
					f28_arg0.Pointer:registerEventHandler( "interrupted_keyframe", f28_arg0.clipInterrupted )
					f28_arg0.Pointer:registerEventHandler( "transition_complete_keyframe", f28_arg0.clipFinished )
				end
				f28_arg0.Pointer:completeAnimation()
				f28_arg0.Pointer:setAlpha( 0 )
				f28_local4( f28_arg0.Pointer )
			end
		},
		Visible = {
			DefaultClip = function ( f34_arg0, f34_arg1 )
				f34_arg0:__resetProperties()
				f34_arg0:setupElementClipCounter( 0 )
			end,
			DefaultState = function ( f35_arg0, f35_arg1 )
				f35_arg0:__resetProperties()
				f35_arg0:setupElementClipCounter( 5 )
				local f35_local0 = function ( f36_arg0 )
					f35_arg0.BGDarkening:beginAnimation( 60 )
					f35_arg0.BGDarkening:setAlpha( 0 )
					f35_arg0.BGDarkening:registerEventHandler( "interrupted_keyframe", f35_arg0.clipInterrupted )
					f35_arg0.BGDarkening:registerEventHandler( "transition_complete_keyframe", f35_arg0.clipFinished )
				end
				f35_arg0.BGDarkening:completeAnimation()
				f35_arg0.BGDarkening:setAlpha( 0.4 )
				f35_local0( f35_arg0.BGDarkening )
				local f35_local1 = function ( f37_arg0 )
					f35_arg0.CenterCircle:beginAnimation( 60 )
					f35_arg0.CenterCircle:setAlpha( 0 )
					f35_arg0.CenterCircle:registerEventHandler( "interrupted_keyframe", f35_arg0.clipInterrupted )
					f35_arg0.CenterCircle:registerEventHandler( "transition_complete_keyframe", f35_arg0.clipFinished )
				end
				f35_arg0.CenterCircle:completeAnimation()
				f35_arg0.CenterCircle:setAlpha( 1 )
				f35_local1( f35_arg0.CenterCircle )
				local f35_local2 = function ( f38_arg0 )
					f35_arg0.SpraysAndGestures:beginAnimation( 60 )
					f35_arg0.SpraysAndGestures:setAlpha( 0 )
					f35_arg0.SpraysAndGestures:registerEventHandler( "interrupted_keyframe", f35_arg0.clipInterrupted )
					f35_arg0.SpraysAndGestures:registerEventHandler( "transition_complete_keyframe", f35_arg0.clipFinished )
				end
				f35_arg0.SpraysAndGestures:completeAnimation()
				f35_arg0.SpraysAndGestures:setAlpha( 1 )
				f35_local2( f35_arg0.SpraysAndGestures )
				local f35_local3 = function ( f39_arg0 )
					f35_arg0.MPWheelPrompt:beginAnimation( 60 )
					f35_arg0.MPWheelPrompt:setAlpha( 0 )
					f35_arg0.MPWheelPrompt:registerEventHandler( "interrupted_keyframe", f35_arg0.clipInterrupted )
					f35_arg0.MPWheelPrompt:registerEventHandler( "transition_complete_keyframe", f35_arg0.clipFinished )
				end
				f35_arg0.MPWheelPrompt:completeAnimation()
				f35_arg0.MPWheelPrompt:setAlpha( 1 )
				f35_local3( f35_arg0.MPWheelPrompt )
				local f35_local4 = function ( f40_arg0 )
					f35_arg0.Pointer:beginAnimation( 60 )
					f35_arg0.Pointer:setAlpha( 0 )
					f35_arg0.Pointer:registerEventHandler( "interrupted_keyframe", f35_arg0.clipInterrupted )
					f35_arg0.Pointer:registerEventHandler( "transition_complete_keyframe", f35_arg0.clipFinished )
				end
				f35_arg0.Pointer:completeAnimation()
				f35_arg0.Pointer:setAlpha( 1 )
				f35_local4( f35_arg0.Pointer )
			end
		}
	}
	CoD.MPSpraysAndGestures.__onClose = function ( f41_arg0 )
		f41_arg0.SpraysAndGestures:close()
		f41_arg0.MPWheelPrompt:close()
		f41_arg0.Pointer:close()
		f41_arg0.emptyFocusable:close()
	end
end
