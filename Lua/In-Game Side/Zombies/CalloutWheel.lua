--[[
		.\hksc.exe ".\Lua\In-Game Side\Zombies\CalloutWheel.lua" -o "C:\Program Files (x86)\Call of Duty Black Ops 4\project-bo4\internals\T8ShieldSupport\Lua\Game\CalloutWheel.luac"
]]

---------------------------

if CoD.isFrontend or not CoD.isZombie then
	return
end

CoD.ShieldInitLuaFile()

---------------------------

--[[
	The callout wheel of multiplayer (+calloutwheel, left Alt), in zombies: the callouts that fit a team of players, a
	gesture each, and the callout in the feed of the team. Multiplayer reads them from the callout_wheel bundles of
	mp_common; here they are below, with the same titles (metadata.json gives their English text) and gesture tables
	(borrowed from mp_common, metadata.json). The choice goes to the server as a menu response, the support GSC
	(TryCallout) plays the gesture and sends the callout to the team as the notify shield_callout.
]]
local MENU = "shield_support_menu"
local RESPONSE = "callout"
local NOTIFY = @"shield_callout"
local ALT = 100

-- in Blackout's wheel order; id: the support GSC's index (CalloutGestureTable), alt: the title while in last stand
local CALLOUTS = {
	{ id = 0, title = @"hash_750100D161C4D583", social = 1 }, -- Hello
	{ id = 1, title = @"hash_7382718D1BEA375C", social = 1 }, -- Nice Work
	{ id = 2, title = @"hash_EC2BD11204D4811", alt = @"hash_5DD4DE4914A2964B", social = 0 }, -- Need Help, Need Revive
	{ id = 3, title = @"hash_1E993A7261C62997", social = 0 }, -- Cover Me
	{ id = 4, title = @"hash_176DCB27E4A0B1F4", social = 0 }, -- Group Up
	{ id = 5, title = @"hash_6101245AEDFEB933", social = 0 }, -- Flanking
	{ id = 8, title = @"hash_4B446844FF94C9EB", social = 0 }, -- Taunt
	{ id = 6, title = @"hash_1CF45EADD754592B", social = 0 }, -- Acknowledged
	{ id = 7, title = @"hash_2323687D4A52A88", social = 1 } -- Thanks
}

local CALLOUTS_BY_ID = {}
for _, callout in ipairs( CALLOUTS ) do
	CALLOUTS_BY_ID[callout.id] = callout
end

local function Log( text )
	Engine[@"printinfo"]( 0, "[shield] callouts: " .. text .. "\n" )
end

local function InLastStand( controller )
	return CoD.ModelUtility.IsClientModelValueTrue( controller, "isInLastStand" )
end

local function SetupDataSource()
	if DataSources.ShieldCalloutWheel then
		return
	end

	DataSources.ShieldCalloutWheel = DataSourceHelpers.ListSetup( "ShieldCalloutWheel", function ( controller, list )
		-- the alternate titles follow last stand
		if not list._shieldLastStand then
			list._shieldLastStand = true
			local client = Engine[@"hash_E4D2F32833CFA6C"]( Engine.GetClientNum( controller ) )
			if client and client.isInLastStand then
				list:subscribeToModel( client.isInLastStand, function ()
					list:updateDataSource( true )
				end, false )
			end
		end

		local downed = InLastStand( controller )
		local items = {}
		for index, callout in ipairs( CALLOUTS ) do
			local alt = downed and callout.alt
			table.insert( items, {
				models = {
					disabled = false,
					text = alt or callout.title,
					arrayIndex = callout.id,
					index = index - 1,
					chosen = false,
					addNumber = alt and ALT or 0,
					isSocialCallout = callout.social
				},
				properties = {}
			} )
		end
		return items
	end, nil )
end

-- the choice, as CoD.HUDUtility.AddCalloutWheelCallback but to the support GSC
CoD.ShieldAddCalloutCallback = function ( controller, list )
	list._onChooseWedge = function ( index, element, model )
		CoD.BaseUtility.SendCustomMenuResponse( controller, MENU, RESPONSE, (model.arrayIndex:get() or index) + model.addNumber:get() )
	end
end

-- a callout of the team, as CoD.HUDUtility.ProcessPlayerCalloutInternal shows one (without its Blackout check)
local function ShowCallout( controller, payload, client )
	local callout = CALLOUTS_BY_ID[payload % ALT]
	if not callout or not client then
		return
	end

	local title = payload >= ALT and callout.alt or callout.title
	local text = Engine[@"hash_4F9F1239CFD921FE"]( title )
	local color = GetPlayerCalloutNameColor( controller, client )
	local name = GetClientNameAndClanTag( controller, client )

	if CoD.isPC then
		CoD.PCUtility.ShowGameEvent( "^" .. color .. name .. ": " .. text )
		return
	end

	local console = DataSources.HUDItems.getModel( controller ).console
	if not console then
		return
	end

	local line = console["line" .. console.currentIndex:get()]
	line.text0:set( name )
	line.text0color:set( color )
	line.text1:set( text )
	line.text1color:set( Enum[@"hash_197A8DF5F2FA8BD5"][@"hash_54A8B270BE295E3E"] )
	line.text2:set( "" )
	Engine[@"hash_76A489878620F3BC"]( console )
end

local function AddWheel( menu, controller )
	if menu.ShieldCalloutItems then
		return
	end

	SetupDataSource()

	local wheel = CoD.MPCalloutItems.new( menu, controller, 0, 1, 0, 0, 0, 1, 0, 0 )
	menu:addElement( wheel )
	menu.ShieldCalloutItems = wheel

	menu:subscribeToGlobalModel( controller, "PerController", "scriptNotify", function ( model )
		if Engine[@"getmodelvalue"]( model ) == NOTIFY then
			local data = CoD.GetScriptNotifyData( model )
			local ok, err = pcall( ShowCallout, controller, data[1], data[2] )
			if not ok then
				Log( "not shown: " .. tostring( err ) )
			end
		end
	end )
end

local function HookHud()
	local utility = CoD.ZombieUtility
	if not utility or utility.ShieldCalloutWheel or not utility.CommonPostLoadHud then
		return
	end

	utility.ShieldCalloutWheel = true
	local GamePostLoadHud = utility.CommonPostLoadHud
	utility.CommonPostLoadHud = function ( hud, controller, menu, ... )
		GamePostLoadHud( hud, controller, menu, ... )

		local ok, err = pcall( AddWheel, menu or hud, controller )
		if not ok then
			Log( "no wheel: " .. tostring( err ) )
		end
	end
end

HookHud()

-- the zombies utility may be read after this file: hooked once it is
if not CoD.ShieldCalloutWheelRequire then
	CoD.ShieldCalloutWheelRequire = true
	local GameRequire = require
	require = function ( ... )
		local result = GameRequire( ... )
		HookHud()
		return result
	end
end

---------------------------

-- the widgets of the wheel, from mp_common (ui/uieditor/widgets/hud/mpcalloutitems and what it uses). Changed: the data
-- source ShieldCalloutWheel and its 9 slots, the choice CoD.ShieldAddCalloutCallback, and the condition to show (the
-- decompiled one never shows it). The pointer and prompt widgets are SprayGestureWheel.lua's.

if not CoD.CalloutItemText then
	CoD.CalloutItemText = InheritFrom( LUI.UIElement )
	CoD.CalloutItemText.__defaultWidth = 182
	CoD.CalloutItemText.__defaultHeight = 26
	CoD.CalloutItemText.new = function ( f1_arg0, f1_arg1, f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
		local self = LUI.UIElement.new( f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
		self:setClass( CoD.CalloutItemText )
		self.id = "CalloutItemText"
		self.soundSet = "default"
		f1_arg0:addElementToPendingUpdateStateList( self )

		local Title = LUI.UIText.new( 0.5, 0.5, -91, 91, 0, 0, 0, 26 )
		Title:setTTF( "ttmussels_regular" )
		Title:setAlignment( Enum[@"luialignment"][@"lui_alignment_center"] )
		Title:setAlignment( Enum[@"luialignment"][@"lui_alignment_top"] )
		Title:linkToElementModel( self, "text", true, function ( model )
			local f2_local0 = model:get()
			if f2_local0 ~= nil then
				Title:setText( CoD.BaseUtility.LocalizeIfXHash( f2_local0 ) )
			end
		end )
		self:addElement( Title )
		self.Title = Title

		self:mergeStateConditions( {
			{
				stateName = "SocialCallout",
				condition = function ( menu, element, event )
					return CoD.ModelUtility.IsSelfModelValueEqualTo( element, f1_arg1, "isSocialCallout", 1 )
				end
			}
		} )
		self:linkToElementModel( self, "isSocialCallout", true, function ( model )
			f1_arg0:updateElementState( self, {
				name = "model_validation",
				menu = f1_arg0,
				controller = f1_arg1,
				modelValue = model:get(),
				modelName = "isSocialCallout"
			} )
		end )
		LUI.OverrideFunction_CallOriginalSecond( self, "close", self.__onClose )


		return self
	end
	CoD.CalloutItemText.__resetProperties = function ( f5_arg0 )
		f5_arg0.Title:completeAnimation()
		f5_arg0.Title:setRGB( 1, 1, 1 )
	end
	CoD.CalloutItemText.__clipsPerState = {
		DefaultState = {
			DefaultClip = function ( f6_arg0, f6_arg1 )
				f6_arg0:__resetProperties()
				f6_arg0:setupElementClipCounter( 0 )
			end
		},
		SocialCallout = {
			DefaultClip = function ( f7_arg0, f7_arg1 )
				f7_arg0:__resetProperties()
				f7_arg0:setupElementClipCounter( 1 )
				f7_arg0.Title:completeAnimation()
				f7_arg0.Title:setRGB( ColorSet.PlayerGreen.r, ColorSet.PlayerGreen.g, ColorSet.PlayerGreen.b )
				f7_arg0.clipFinished( f7_arg0.Title )
			end
		}
	}
	CoD.CalloutItemText.__onClose = function ( f8_arg0 )
		f8_arg0.Title:close()
	end
end

if not CoD.CalloutItem then
	CoD.CalloutItem = InheritFrom( LUI.UIElement )
	CoD.CalloutItem.__defaultWidth = 382
	CoD.CalloutItem.__defaultHeight = 382
	CoD.CalloutItem.new = function ( f1_arg0, f1_arg1, f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
		local self = LUI.UIElement.new( f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
		self:setClass( CoD.CalloutItem )
		self.id = "CalloutItem"
		self.soundSet = "default"
		self.anyChildUsesUpdateState = true
		f1_arg0:addElementToPendingUpdateStateList( self )

		local backingSolid = LUI.UIImage.new( -0.5, 1.5, 0, 0, -0.5, 0.5, -8, -8 )
		backingSolid:setRGB( 0, 0, 0 )
		backingSolid:setAlpha( 0.5 )
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
		backing:setShaderVector( 0, 0.1, 0.25, 0, 0 )
		backing:setShaderVector( 2, 0, 0, 0, 0 )
		backing:linkToElementModel( self, "angleWidth", true, function ( model )
			local f3_local0 = model:get()
			if f3_local0 ~= nil then
				backing:setShaderVector( 1, CoD.GetVectorComponentFromString( f3_local0, 1 ), CoD.GetVectorComponentFromString( f3_local0, 2 ), CoD.GetVectorComponentFromString( f3_local0, 3 ), CoD.GetVectorComponentFromString( f3_local0, 4 ) )
			end
		end )
		self:addElement( backing )
		self.backing = backing

		local Title = CoD.CalloutItemText.new( f1_arg0, f1_arg1, 0.5, 0.5, -91, 91, 0, 0, -122, -96 )
		Title:linkToElementModel( self, "zRot", true, function ( model )
			local f4_local0 = model:get()
			if f4_local0 ~= nil then
				Title:setZRot( Multiple( -1, f4_local0 ) )
			end
		end )
		Title:linkToElementModel( self, nil, false, function ( model )
			Title:setModel( model, f1_arg1 )
		end )
		self:addElement( Title )
		self.Title = Title

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
		local f1_local4 = self
		local f1_local5 = self.subscribeToModel
		local f1_local6 = DataSources.RightStick.getModel( f1_arg1 )
		f1_local5( f1_local4, f1_local6.SelectedWedge, function ( f11_arg0 )
			f1_arg0:updateElementState( self, {
				name = "model_validation",
				menu = f1_arg0,
				controller = f1_arg1,
				modelValue = f11_arg0:get(),
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
	CoD.CalloutItem.__resetProperties = function ( f13_arg0 )
		f13_arg0.Title:completeAnimation()
		f13_arg0.backing:completeAnimation()
		f13_arg0.Title:setTopBottom( 0, 0, -122, -96 )
		f13_arg0.Title:setRGB( 1, 1, 1 )
		f13_arg0.Title:setAlpha( 1 )
		f13_arg0.backing:setTopBottom( -0.5, 0.5, -8, -8 )
		f13_arg0.backing:setRGB( 0, 0, 0 )
		f13_arg0.backing:setAlpha( 0.5 )
		f13_arg0.backing:setScale( 1, 1 )
	end
	CoD.CalloutItem.__clipsPerState = {
		DefaultState = {
			DefaultClip = function ( f14_arg0, f14_arg1 )
				f14_arg0:__resetProperties()
				f14_arg0:setupElementClipCounter( 1 )
				f14_arg0.Title:completeAnimation()
				f14_arg0.Title:setRGB( 0.78, 0.75, 0.62 )
				f14_arg0.clipFinished( f14_arg0.Title )
			end,
			Selected = function ( f15_arg0, f15_arg1 )
				f15_arg0:__resetProperties()
				f15_arg0:setupElementClipCounter( 2 )
				local f15_local0 = function ( f16_arg0 )
					f15_arg0.backing:beginAnimation( 150 )
					f15_arg0.backing:setRGB( 0.57, 0.42, 0.03 )
					f15_arg0.backing:setAlpha( 0.6 )
					f15_arg0.backing:registerEventHandler( "interrupted_keyframe", f15_arg0.clipInterrupted )
					f15_arg0.backing:registerEventHandler( "transition_complete_keyframe", f15_arg0.clipFinished )
				end
				f15_arg0.backing:completeAnimation()
				f15_arg0.backing:setRGB( 0, 0, 0 )
				f15_arg0.backing:setAlpha( 0.5 )
				f15_local0( f15_arg0.backing )
				local f15_local1 = function ( f17_arg0 )
					f15_arg0.Title:beginAnimation( 150 )
					f15_arg0.Title:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )
					f15_arg0.Title:registerEventHandler( "interrupted_keyframe", f15_arg0.clipInterrupted )
					f15_arg0.Title:registerEventHandler( "transition_complete_keyframe", f15_arg0.clipFinished )
				end
				f15_arg0.Title:completeAnimation()
				f15_arg0.Title:setRGB( 0.78, 0.75, 0.62 )
				f15_local1( f15_arg0.Title )
			end,
			Highlighted = function ( f18_arg0, f18_arg1 )
				f18_arg0:__resetProperties()
				f18_arg0:setupElementClipCounter( 2 )
				local f18_local0 = function ( f19_arg0 )
					f18_arg0.backing:beginAnimation( 200, Enum[@"luitween"][@"luitween_ease_both"] )
					f18_arg0.backing:setTopBottom( -0.5, 0.5, -45, -45 )
					f18_arg0.backing:setRGB( 0.57, 0.42, 0.03 )
					f18_arg0.backing:setAlpha( 1 )
					f18_arg0.backing:setScale( 1.2, 1.2 )
					f18_arg0.backing:registerEventHandler( "interrupted_keyframe", f18_arg0.clipInterrupted )
					f18_arg0.backing:registerEventHandler( "transition_complete_keyframe", f18_arg0.clipFinished )
				end
				f18_arg0.backing:completeAnimation()
				f18_arg0.backing:setTopBottom( -0.5, 0.5, -8, -8 )
				f18_arg0.backing:setRGB( 0, 0, 0 )
				f18_arg0.backing:setAlpha( 0.5 )
				f18_arg0.backing:setScale( 1, 1 )
				f18_local0( f18_arg0.backing )
				local f18_local1 = function ( f20_arg0 )
					f18_arg0.Title:beginAnimation( 200, Enum[@"luitween"][@"luitween_ease_both"] )
					f18_arg0.Title:setTopBottom( 0, 0, -132, -106 )
					f18_arg0.Title:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )
					f18_arg0.Title:registerEventHandler( "interrupted_keyframe", f18_arg0.clipInterrupted )
					f18_arg0.Title:registerEventHandler( "transition_complete_keyframe", f18_arg0.clipFinished )
				end
				f18_arg0.Title:completeAnimation()
				f18_arg0.Title:setTopBottom( 0, 0, -122, -96 )
				f18_arg0.Title:setRGB( 0.78, 0.75, 0.62 )
				f18_local1( f18_arg0.Title )
			end,
			Chosen = function ( f21_arg0, f21_arg1 )
				f21_arg0:__resetProperties()
				f21_arg0:setupElementClipCounter( 2 )
				local f21_local0 = function ( f22_arg0 )
					f21_arg0.backing:beginAnimation( 200, Enum[@"luitween"][@"luitween_ease_both"] )
					f21_arg0.backing:setTopBottom( -0.5, 0.5, -45, -45 )
					f21_arg0.backing:setRGB( 0.57, 0.42, 0.03 )
					f21_arg0.backing:setAlpha( 1 )
					f21_arg0.backing:setScale( 1.2, 1.2 )
					f21_arg0.backing:registerEventHandler( "interrupted_keyframe", f21_arg0.clipInterrupted )
					f21_arg0.backing:registerEventHandler( "transition_complete_keyframe", f21_arg0.clipFinished )
				end
				f21_arg0.backing:completeAnimation()
				f21_arg0.backing:setTopBottom( -0.5, 0.5, -8, -8 )
				f21_arg0.backing:setRGB( 0, 0, 0 )
				f21_arg0.backing:setAlpha( 0.5 )
				f21_arg0.backing:setScale( 1, 1 )
				f21_local0( f21_arg0.backing )
				local f21_local1 = function ( f23_arg0 )
					f21_arg0.Title:beginAnimation( 200, Enum[@"luitween"][@"luitween_ease_both"] )
					f21_arg0.Title:setTopBottom( 0, 0, -132, -106 )
					f21_arg0.Title:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )
					f21_arg0.Title:registerEventHandler( "interrupted_keyframe", f21_arg0.clipInterrupted )
					f21_arg0.Title:registerEventHandler( "transition_complete_keyframe", f21_arg0.clipFinished )
				end
				f21_arg0.Title:completeAnimation()
				f21_arg0.Title:setTopBottom( 0, 0, -122, -96 )
				f21_arg0.Title:setRGB( 0.78, 0.75, 0.62 )
				f21_local1( f21_arg0.Title )
			end
		},
		Disabled = {
			DefaultClip = function ( f24_arg0, f24_arg1 )
				f24_arg0:__resetProperties()
				f24_arg0:setupElementClipCounter( 2 )
				f24_arg0.backing:completeAnimation()
				f24_arg0.backing:setRGB( 0.15, 0.15, 0.15 )
				f24_arg0.clipFinished( f24_arg0.backing )
				f24_arg0.Title:completeAnimation()
				f24_arg0.Title:setRGB( 0.78, 0.75, 0.62 )
				f24_arg0.clipFinished( f24_arg0.Title )
			end
		},
		Chosen = {
			DefaultClip = function ( f25_arg0, f25_arg1 )
				f25_arg0:__resetProperties()
				f25_arg0:setupElementClipCounter( 2 )
				f25_arg0.backing:completeAnimation()
				f25_arg0.backing:setTopBottom( -0.5, 0.5, -45, -45 )
				f25_arg0.backing:setRGB( 0.57, 0.42, 0.03 )
				f25_arg0.backing:setAlpha( 1 )
				f25_arg0.backing:setScale( 1.2, 1.2 )
				f25_arg0.clipFinished( f25_arg0.backing )
				f25_arg0.Title:completeAnimation()
				f25_arg0.Title:setTopBottom( 0, 0, -132, -106 )
				f25_arg0.Title:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )
				f25_arg0.clipFinished( f25_arg0.Title )
			end,
			DefaultState = function ( f26_arg0, f26_arg1 )
				f26_arg0:__resetProperties()
				f26_arg0:setupElementClipCounter( 2 )
				local f26_local0 = function ( f27_arg0 )
					local f27_local0 = function ( f28_arg0 )
						f28_arg0:beginAnimation( 240, Enum[@"luitween"][@"luitween_ease_both"] )
						f28_arg0:setTopBottom( -0.5, 0.5, -8, -8 )
						f28_arg0:setRGB( 0, 0, 0 )
						f28_arg0:setAlpha( 0.5 )
						f28_arg0:setScale( 1, 1 )
						f28_arg0:registerEventHandler( "transition_complete_keyframe", f26_arg0.clipFinished )
					end
					f26_arg0.backing:beginAnimation( 160 )
					f26_arg0.backing:setRGB( 0.92, 0.85, 0.67 )
					f26_arg0.backing:registerEventHandler( "interrupted_keyframe", f26_arg0.clipInterrupted )
					f26_arg0.backing:registerEventHandler( "transition_complete_keyframe", f27_local0 )
				end
				f26_arg0.backing:completeAnimation()
				f26_arg0.backing:setTopBottom( -0.5, 0.5, -45, -45 )
				f26_arg0.backing:setRGB( 0.57, 0.42, 0.03 )
				f26_arg0.backing:setAlpha( 1 )
				f26_arg0.backing:setScale( 1.2, 1.2 )
				f26_local0( f26_arg0.backing )
				local f26_local1 = function ( f29_arg0 )
					local f29_local0 = function ( f30_arg0 )
						f30_arg0:beginAnimation( 240, Enum[@"luitween"][@"luitween_ease_both"] )
						f30_arg0:setTopBottom( 0, 0, -122, -96 )
						f30_arg0:setRGB( 0.78, 0.75, 0.62 )
						f30_arg0:registerEventHandler( "transition_complete_keyframe", f26_arg0.clipFinished )
					end
					f26_arg0.Title:beginAnimation( 160 )
					f26_arg0.Title:registerEventHandler( "interrupted_keyframe", f26_arg0.clipInterrupted )
					f26_arg0.Title:registerEventHandler( "transition_complete_keyframe", f29_local0 )
				end
				f26_arg0.Title:completeAnimation()
				f26_arg0.Title:setTopBottom( 0, 0, -132, -106 )
				f26_arg0.Title:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )
				f26_arg0.Title:setAlpha( 1 )
				f26_local1( f26_arg0.Title )
			end,
			Highlighted = function ( f31_arg0, f31_arg1 )
				f31_arg0:__resetProperties()
				f31_arg0:setupElementClipCounter( 2 )
				f31_arg0.backing:completeAnimation()
				f31_arg0.backing:setTopBottom( -0.5, 0.5, -45, -45 )
				f31_arg0.backing:setRGB( 0.57, 0.42, 0.03 )
				f31_arg0.backing:setAlpha( 1 )
				f31_arg0.backing:setScale( 1.2, 1.2 )
				f31_arg0.clipFinished( f31_arg0.backing )
				f31_arg0.Title:completeAnimation()
				f31_arg0.Title:setTopBottom( 0, 0, -132, -106 )
				f31_arg0.Title:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )
				f31_arg0.clipFinished( f31_arg0.Title )
			end
		},
		Highlighted = {
			DefaultClip = function ( f32_arg0, f32_arg1 )
				f32_arg0:__resetProperties()
				f32_arg0:setupElementClipCounter( 2 )
				f32_arg0.backing:completeAnimation()
				f32_arg0.backing:setTopBottom( -0.5, 0.5, -45, -45 )
				f32_arg0.backing:setRGB( 0.57, 0.42, 0.03 )
				f32_arg0.backing:setAlpha( 1 )
				f32_arg0.backing:setScale( 1.2, 1.2 )
				f32_arg0.clipFinished( f32_arg0.backing )
				f32_arg0.Title:completeAnimation()
				f32_arg0.Title:setTopBottom( 0, 0, -132, -106 )
				f32_arg0.Title:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )
				f32_arg0.clipFinished( f32_arg0.Title )
			end,
			DefaultState = function ( f33_arg0, f33_arg1 )
				f33_arg0:__resetProperties()
				f33_arg0:setupElementClipCounter( 2 )
				local f33_local0 = function ( f34_arg0 )
					f33_arg0.backing:beginAnimation( 200, Enum[@"luitween"][@"luitween_ease_both"] )
					f33_arg0.backing:setTopBottom( -0.5, 0.5, -8, -8 )
					f33_arg0.backing:setRGB( 0, 0, 0 )
					f33_arg0.backing:setAlpha( 0.5 )
					f33_arg0.backing:setScale( 1, 1 )
					f33_arg0.backing:registerEventHandler( "interrupted_keyframe", f33_arg0.clipInterrupted )
					f33_arg0.backing:registerEventHandler( "transition_complete_keyframe", f33_arg0.clipFinished )
				end
				f33_arg0.backing:completeAnimation()
				f33_arg0.backing:setTopBottom( -0.5, 0.5, -45, -45 )
				f33_arg0.backing:setRGB( 0.57, 0.42, 0.03 )
				f33_arg0.backing:setAlpha( 1 )
				f33_arg0.backing:setScale( 1.2, 1.2 )
				f33_local0( f33_arg0.backing )
				local f33_local1 = function ( f35_arg0 )
					f33_arg0.Title:beginAnimation( 200, Enum[@"luitween"][@"luitween_ease_both"] )
					f33_arg0.Title:setTopBottom( 0, 0, -122, -96 )
					f33_arg0.Title:setRGB( 0.78, 0.75, 0.62 )
					f33_arg0.Title:registerEventHandler( "interrupted_keyframe", f33_arg0.clipInterrupted )
					f33_arg0.Title:registerEventHandler( "transition_complete_keyframe", f33_arg0.clipFinished )
				end
				f33_arg0.Title:completeAnimation()
				f33_arg0.Title:setTopBottom( 0, 0, -132, -106 )
				f33_arg0.Title:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )
				f33_local1( f33_arg0.Title )
			end,
			Chosen = function ( f36_arg0, f36_arg1 )
				f36_arg0:__resetProperties()
				f36_arg0:setupElementClipCounter( 2 )
				f36_arg0.backing:completeAnimation()
				f36_arg0.backing:setTopBottom( -0.5, 0.5, -45, -45 )
				f36_arg0.backing:setRGB( 0.57, 0.42, 0.03 )
				f36_arg0.backing:setAlpha( 1 )
				f36_arg0.backing:setScale( 1.2, 1.2 )
				f36_arg0.clipFinished( f36_arg0.backing )
				f36_arg0.Title:completeAnimation()
				f36_arg0.Title:setTopBottom( 0, 0, -132, -106 )
				f36_arg0.Title:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )
				f36_arg0.clipFinished( f36_arg0.Title )
			end
		}
	}
	CoD.CalloutItem.__onClose = function ( f37_arg0 )
		f37_arg0.backingSolid:close()
		f37_arg0.backing:close()
		f37_arg0.Title:close()
	end
end

if not CoD.MPCalloutItems then
	CoD.MPCalloutItems = InheritFrom( LUI.UIElement )
	CoD.MPCalloutItems.__defaultWidth = 1920
	CoD.MPCalloutItems.__defaultHeight = 1080
	CoD.MPCalloutItems.new = function ( f1_arg0, f1_arg1, f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
		local self = LUI.UIElement.new( f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
		self:setUseCylinderMapping( false )
		self:setClass( CoD.MPCalloutItems )
		self.id = "MPCalloutItems"
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

		local CalloutItems = LUI.WheelLayout.new( f1_arg0, f1_arg1, nil )
		CalloutItems:setLeftRight( 0.5, 0.5, -177, 177 )
		CalloutItems:setTopBottom( 0.5, 0.5, -177, 177 )
		CalloutItems:setWidgetType( CoD.CalloutItem )
		CalloutItems:setCount( #CALLOUTS )
		CalloutItems:setDataSource( "ShieldCalloutWheel" )
		self:addElement( CalloutItems )
		self.CalloutItems = CalloutItems

		local MPWheelPrompt = CoD.MPWheelPrompt.new( f1_arg0, f1_arg1, 0.5, 0.5, -9.5, 9.5, 0.5, 0.5, -5.5, 5.5 )
		MPWheelPrompt:subscribeToGlobalModel( f1_arg1, "Controller", "move_right_stick_button_image", function ( model )
			local f2_local0 = model:get()
			if f2_local0 ~= nil then
				MPWheelPrompt.RStick:setImage( RegisterImage( f2_local0 ) )
			end
		end )
		self:addElement( MPWheelPrompt )
		self.MPWheelPrompt = MPWheelPrompt

		local Pointer = CoD.WheelTriangleIndicator.new( f1_arg0, f1_arg1, 0.5, 0.5, -9.5, 9.5, 0.5, 0.5, -5.5, 5.5 )
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
					return CoD.HUDUtility.IsCalloutsButtonPressed( f1_arg1 )
						and not Engine[@"isvisibilitybitset"]( f1_arg1, Enum[@"uivisibilitybit"][@"bit_game_ended"] )
						and not Engine[@"isvisibilitybitset"]( f1_arg1, Enum[@"uivisibilitybit"][@"bit_player_dead"] )
						and not Engine[@"isvisibilitybitset"]( f1_arg1, Enum[@"uivisibilitybit"][@"bit_scoreboard_open"] )
						and not Engine[@"isvisibilitybitset"]( f1_arg1, Enum[@"uivisibilitybit"][@"bit_spectating_client"] )
						and not IsInTheaterMode()
				end
			}
		} )
		local f1_local7 = self
		local f1_local8 = self.subscribeToModel
		local f1_local9 = Engine[@"getmodelforcontroller"]( f1_arg1 )
		f1_local8( f1_local7, f1_local9["ButtonBits.actionSlots.Flourish_Callouts"], function ( f8_arg0 )
			f1_arg0:updateElementState( self, {
				name = "model_validation",
				menu = f1_arg0,
				controller = f1_arg1,
				modelValue = f8_arg0:get(),
				modelName = "ButtonBits.actionSlots.Flourish_Callouts"
			} )
		end, false )
		f1_local7 = self
		f1_local8 = self.subscribeToModel
		f1_local9 = Engine[@"getmodelforcontroller"]( f1_arg1 )
		f1_local8( f1_local7, f1_local9["hudItems.PCWheels.calloutWheelKeyPressed"], function ( f9_arg0 )
			f1_arg0:updateElementState( self, {
				name = "model_validation",
				menu = f1_arg0,
				controller = f1_arg1,
				modelValue = f9_arg0:get(),
				modelName = "hudItems.PCWheels.calloutWheelKeyPressed"
			} )
		end, false )
		f1_local7 = self
		f1_local8 = self.subscribeToModel
		f1_local9 = Engine[@"getmodelforcontroller"]( f1_arg1 )
		f1_local8( f1_local7, f1_local9["hudItems.PCWheels.sprayGestureWheelKeyPressed"], function ( f10_arg0 )
			f1_arg0:updateElementState( self, {
				name = "model_validation",
				menu = f1_arg0,
				controller = f1_arg1,
				modelValue = f10_arg0:get(),
				modelName = "hudItems.PCWheels.sprayGestureWheelKeyPressed"
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
		f1_local8( f1_local7, f1_local9["UIVisibilityBit." .. Enum[@"uivisibilitybit"][@"bit_player_dead"]], function ( f12_arg0 )
			f1_arg0:updateElementState( self, {
				name = "model_validation",
				menu = f1_arg0,
				controller = f1_arg1,
				modelValue = f12_arg0:get(),
				modelName = "UIVisibilityBit." .. Enum[@"uivisibilitybit"][@"bit_player_dead"]
			} )
		end, false )
		f1_local7 = self
		f1_local8 = self.subscribeToModel
		f1_local9 = Engine[@"getmodelforcontroller"]( f1_arg1 )
		f1_local8( f1_local7, f1_local9["UIVisibilityBit." .. Enum[@"uivisibilitybit"][@"bit_round_end_killcam"]], function ( f13_arg0 )
			f1_arg0:updateElementState( self, {
				name = "model_validation",
				menu = f1_arg0,
				controller = f1_arg1,
				modelValue = f13_arg0:get(),
				modelName = "UIVisibilityBit." .. Enum[@"uivisibilitybit"][@"bit_round_end_killcam"]
			} )
		end, false )
		f1_local7 = self
		f1_local8 = self.subscribeToModel
		f1_local9 = Engine[@"getmodelforcontroller"]( f1_arg1 )
		f1_local8( f1_local7, f1_local9["UIVisibilityBit." .. Enum[@"uivisibilitybit"][@"bit_scoreboard_open"]], function ( f14_arg0 )
			f1_arg0:updateElementState( self, {
				name = "model_validation",
				menu = f1_arg0,
				controller = f1_arg1,
				modelValue = f14_arg0:get(),
				modelName = "UIVisibilityBit." .. Enum[@"uivisibilitybit"][@"bit_scoreboard_open"]
			} )
		end, false )
		f1_local7 = self
		f1_local8 = self.subscribeToModel
		f1_local9 = Engine[@"getmodelforcontroller"]( f1_arg1 )
		f1_local8( f1_local7, f1_local9["UIVisibilityBit." .. Enum[@"uivisibilitybit"][@"bit_spectating_client"]], function ( f15_arg0 )
			f1_arg0:updateElementState( self, {
				name = "model_validation",
				menu = f1_arg0,
				controller = f1_arg1,
				modelValue = f15_arg0:get(),
				modelName = "UIVisibilityBit." .. Enum[@"uivisibilitybit"][@"bit_spectating_client"]
			} )
		end, false )
		f1_local7 = self
		f1_local8 = self.subscribeToModel
		f1_local9 = Engine[@"getglobalmodel"]()
		f1_local8( f1_local7, f1_local9["lobbyRoot.lobbyNav"], function ( f16_arg0 )
			f1_arg0:updateElementState( self, {
				name = "model_validation",
				menu = f1_arg0,
				controller = f1_arg1,
				modelValue = f16_arg0:get(),
				modelName = "lobbyRoot.lobbyNav"
			} )
		end, false )
		f1_local7 = self
		f1_local8 = self.subscribeToModel
		f1_local9 = Engine[@"getmodelforclient"]( Engine[@"getclientnum"]( f1_arg1 ) )
		f1_local8( f1_local7, f1_local9.isInLastStand, function ( f17_arg0 )
			f1_arg0:updateElementState( self, {
				name = "model_validation",
				menu = f1_arg0,
				controller = f1_arg1,
				modelValue = f17_arg0:get(),
				modelName = "isInLastStand"
			} )
		end, false )
		LUI.OverrideFunction_CallOriginalFirst( self, "setState", function ( element, controller, f18_arg2, f18_arg3, f18_arg4 )
			if IsSelfInState( self, "Visible" ) then
				CoD.HUDUtility.MenuDelayedSetRightStickLock( f1_arg0, controller, 0, true )
			else
				CoD.HUDUtility.MenuDelayedSetRightStickLock( f1_arg0, controller, 125, false )
				CoD.HUDUtility.DisableWheelSelection( controller, self, self.CalloutItems )
			end
		end )
		self:subscribeToGlobalModel( f1_arg1, "RightStick", "Length", function ( model )
			local f19_local0 = self
			if IsSelfInState( self, "Visible" ) then
				CoD.HUDUtility.UpdateSelectionModelFromLength( f1_arg1, self, self.CalloutItems, model, false )
			end
		end )
		self:subscribeToGlobalModel( f1_arg1, "RightStick", "Degrees", function ( model )
			local f20_local0 = self
			if IsSelfInState( self, "Visible" ) then
				CoD.HUDUtility.UpdateSelectionModelFromDegrees( f1_arg1, self, self.CalloutItems, false )
			end
		end )
		if CoD.isPC then
			emptyFocusable.id = "emptyFocusable"
		end
		LUI.OverrideFunction_CallOriginalSecond( self, "close", self.__onClose )

		f1_local8 = self
		CoD.ShieldAddCalloutCallback( f1_arg1, self.CalloutItems )
		CoD.HUDUtility.InitWheelPCForMouseDrag( self, f1_arg1, f1_arg0, self.CalloutItems )
		return self
	end
	CoD.MPCalloutItems.__resetProperties = function ( f21_arg0 )
		f21_arg0.CalloutItems:completeAnimation()
		f21_arg0.Pointer:completeAnimation()
		f21_arg0.CenterCircle:completeAnimation()
		f21_arg0.BGDarkening:completeAnimation()
		f21_arg0.MPWheelPrompt:completeAnimation()
		f21_arg0.emptyFocusable:completeAnimation()
		f21_arg0.CalloutItems:setAlpha( 1 )
		f21_arg0.Pointer:setAlpha( 1 )
		f21_arg0.CenterCircle:setAlpha( 1 )
		f21_arg0.BGDarkening:setAlpha( 0.65 )
		f21_arg0.MPWheelPrompt:setAlpha( 1 )
		f21_arg0.emptyFocusable:setAlpha( 1 )
	end
	CoD.MPCalloutItems.__clipsPerState = {
		DefaultState = {
			DefaultClip = function ( f22_arg0, f22_arg1 )
				f22_arg0:__resetProperties()
				f22_arg0:setupElementClipCounter( 6 )
				f22_arg0.BGDarkening:completeAnimation()
				f22_arg0.BGDarkening:setAlpha( 0 )
				f22_arg0.clipFinished( f22_arg0.BGDarkening )
				f22_arg0.CenterCircle:completeAnimation()
				f22_arg0.CenterCircle:setAlpha( 0 )
				f22_arg0.clipFinished( f22_arg0.CenterCircle )
				f22_arg0.CalloutItems:completeAnimation()
				f22_arg0.CalloutItems:setAlpha( 0 )
				f22_arg0.clipFinished( f22_arg0.CalloutItems )
				f22_arg0.MPWheelPrompt:completeAnimation()
				f22_arg0.MPWheelPrompt:setAlpha( 0 )
				f22_arg0.clipFinished( f22_arg0.MPWheelPrompt )
				f22_arg0.Pointer:completeAnimation()
				f22_arg0.Pointer:setAlpha( 0 )
				f22_arg0.clipFinished( f22_arg0.Pointer )
				f22_arg0.emptyFocusable:completeAnimation()
				f22_arg0.emptyFocusable:setAlpha( 0 )
				f22_arg0.clipFinished( f22_arg0.emptyFocusable )
			end,
			Visible = function ( f23_arg0, f23_arg1 )
				f23_arg0:__resetProperties()
				f23_arg0:setupElementClipCounter( 6 )
				local f23_local0 = function ( f24_arg0 )
					f23_arg0.BGDarkening:beginAnimation( 60 )
					f23_arg0.BGDarkening:setAlpha( 0.65 )
					f23_arg0.BGDarkening:registerEventHandler( "interrupted_keyframe", f23_arg0.clipInterrupted )
					f23_arg0.BGDarkening:registerEventHandler( "transition_complete_keyframe", f23_arg0.clipFinished )
				end
				f23_arg0.BGDarkening:completeAnimation()
				f23_arg0.BGDarkening:setAlpha( 0 )
				f23_local0( f23_arg0.BGDarkening )
				local f23_local1 = function ( f25_arg0 )
					f23_arg0.CenterCircle:beginAnimation( 60 )
					f23_arg0.CenterCircle:setAlpha( 1 )
					f23_arg0.CenterCircle:registerEventHandler( "interrupted_keyframe", f23_arg0.clipInterrupted )
					f23_arg0.CenterCircle:registerEventHandler( "transition_complete_keyframe", f23_arg0.clipFinished )
				end
				f23_arg0.CenterCircle:completeAnimation()
				f23_arg0.CenterCircle:setAlpha( 0 )
				f23_local1( f23_arg0.CenterCircle )
				local f23_local2 = function ( f26_arg0 )
					f23_arg0.CalloutItems:beginAnimation( 60 )
					f23_arg0.CalloutItems:setAlpha( 1 )
					f23_arg0.CalloutItems:registerEventHandler( "interrupted_keyframe", f23_arg0.clipInterrupted )
					f23_arg0.CalloutItems:registerEventHandler( "transition_complete_keyframe", f23_arg0.clipFinished )
				end
				f23_arg0.CalloutItems:completeAnimation()
				f23_arg0.CalloutItems:setAlpha( 0 )
				f23_local2( f23_arg0.CalloutItems )
				local f23_local3 = function ( f27_arg0 )
					f23_arg0.MPWheelPrompt:beginAnimation( 60 )
					f23_arg0.MPWheelPrompt:setAlpha( 1 )
					f23_arg0.MPWheelPrompt:registerEventHandler( "interrupted_keyframe", f23_arg0.clipInterrupted )
					f23_arg0.MPWheelPrompt:registerEventHandler( "transition_complete_keyframe", f23_arg0.clipFinished )
				end
				f23_arg0.MPWheelPrompt:completeAnimation()
				f23_arg0.MPWheelPrompt:setAlpha( 0 )
				f23_local3( f23_arg0.MPWheelPrompt )
				local f23_local4 = function ( f28_arg0 )
					f23_arg0.Pointer:beginAnimation( 60 )
					f23_arg0.Pointer:setAlpha( 1 )
					f23_arg0.Pointer:registerEventHandler( "interrupted_keyframe", f23_arg0.clipInterrupted )
					f23_arg0.Pointer:registerEventHandler( "transition_complete_keyframe", f23_arg0.clipFinished )
				end
				f23_arg0.Pointer:completeAnimation()
				f23_arg0.Pointer:setAlpha( 0 )
				f23_local4( f23_arg0.Pointer )
				f23_arg0.emptyFocusable:completeAnimation()
				f23_arg0.emptyFocusable:setAlpha( 1 )
				f23_arg0.clipFinished( f23_arg0.emptyFocusable )
			end
		},
		Visible = {
			DefaultClip = function ( f29_arg0, f29_arg1 )
				f29_arg0:__resetProperties()
				f29_arg0:setupElementClipCounter( 0 )
			end,
			DefaultState = function ( f30_arg0, f30_arg1 )
				f30_arg0:__resetProperties()
				f30_arg0:setupElementClipCounter( 5 )
				local f30_local0 = function ( f31_arg0 )
					local f31_local0 = function ( f32_arg0 )
						f32_arg0:beginAnimation( 380 )
						f32_arg0:setAlpha( 0 )
						f32_arg0:registerEventHandler( "transition_complete_keyframe", f30_arg0.clipFinished )
					end
					f30_arg0.BGDarkening:beginAnimation( 120 )
					f30_arg0.BGDarkening:setAlpha( 0.4 )
					f30_arg0.BGDarkening:registerEventHandler( "interrupted_keyframe", f30_arg0.clipInterrupted )
					f30_arg0.BGDarkening:registerEventHandler( "transition_complete_keyframe", f31_local0 )
				end
				f30_arg0.BGDarkening:completeAnimation()
				f30_arg0.BGDarkening:setAlpha( 0.65 )
				f30_local0( f30_arg0.BGDarkening )
				local f30_local1 = function ( f33_arg0 )
					local f33_local0 = function ( f34_arg0 )
						f34_arg0:beginAnimation( 380 )
						f34_arg0:setAlpha( 0 )
						f34_arg0:registerEventHandler( "transition_complete_keyframe", f30_arg0.clipFinished )
					end
					f30_arg0.CenterCircle:beginAnimation( 120 )
					f30_arg0.CenterCircle:registerEventHandler( "interrupted_keyframe", f30_arg0.clipInterrupted )
					f30_arg0.CenterCircle:registerEventHandler( "transition_complete_keyframe", f33_local0 )
				end
				f30_arg0.CenterCircle:completeAnimation()
				f30_arg0.CenterCircle:setAlpha( 1 )
				f30_local1( f30_arg0.CenterCircle )
				local f30_local2 = function ( f35_arg0 )
					f30_arg0.CalloutItems:beginAnimation( 500, Enum[@"luitween"][@"luitween_ease_out"] )
					f30_arg0.CalloutItems:setAlpha( 0 )
					f30_arg0.CalloutItems:registerEventHandler( "interrupted_keyframe", f30_arg0.clipInterrupted )
					f30_arg0.CalloutItems:registerEventHandler( "transition_complete_keyframe", f30_arg0.clipFinished )
				end
				f30_arg0.CalloutItems:completeAnimation()
				f30_arg0.CalloutItems:setAlpha( 1 )
				f30_local2( f30_arg0.CalloutItems )
				local f30_local3 = function ( f36_arg0 )
					f30_arg0.MPWheelPrompt:beginAnimation( 120 )
					f30_arg0.MPWheelPrompt:setAlpha( 0 )
					f30_arg0.MPWheelPrompt:registerEventHandler( "interrupted_keyframe", f30_arg0.clipInterrupted )
					f30_arg0.MPWheelPrompt:registerEventHandler( "transition_complete_keyframe", f30_arg0.clipFinished )
				end
				f30_arg0.MPWheelPrompt:completeAnimation()
				f30_arg0.MPWheelPrompt:setAlpha( 1 )
				f30_local3( f30_arg0.MPWheelPrompt )
				local f30_local4 = function ( f37_arg0 )
					f30_arg0.Pointer:beginAnimation( 120 )
					f30_arg0.Pointer:setAlpha( 0 )
					f30_arg0.Pointer:registerEventHandler( "interrupted_keyframe", f30_arg0.clipInterrupted )
					f30_arg0.Pointer:registerEventHandler( "transition_complete_keyframe", f30_arg0.clipFinished )
				end
				f30_arg0.Pointer:completeAnimation()
				f30_arg0.Pointer:setAlpha( 1 )
				f30_local4( f30_arg0.Pointer )
			end
		}
	}
	CoD.MPCalloutItems.__onClose = function ( f38_arg0 )
		f38_arg0.CalloutItems:close()
		f38_arg0.MPWheelPrompt:close()
		f38_arg0.Pointer:close()
		f38_arg0.emptyFocusable:close()
	end
end
