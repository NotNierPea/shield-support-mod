--[[
		.\hksc.exe ".\Lua\Frontend Side\Main Menu\CommunityAd.lua" -o "C:\Program Files (x86)\Call of Duty Black Ops 4\project-bo4\internals\T8ShieldSupport\Lua\Frontend\CommunityAd.luac"
]]

---------------------------

CoD.ShieldInitLuaFile()

---------------------------

-- the community events' listeners: shield-client community.cpp calls CoD.ShieldCommunityChanged after each answer
CoD.ShieldCommunityListeners = CoD.ShieldCommunityListeners or {}
CoD.ShieldCommunityChanged = function ()
	for _, listener in pairs( CoD.ShieldCommunityListeners ) do
		listener()
	end
end

local AD_WIDTH = 440
local AD_HEIGHT = 142
local AD_EVENT = "chaos_space"
local AD_IMAGE = "shield_ad_chaos_space"
local ACCENT = { r = 1, g = 0.36, b = 0.2 }
local DONE = { r = 1, g = 0.78, b = 0.3 }
local TEXT_LEFT = 13
local TEXT_RIGHT = 300

-- 12345 as "12,345"
local function Thousands( value )
	local text = tostring( math.floor( value or 0 ) ):reverse():gsub( "(%d%d%d)", "%1," ):reverse()
	return ( text:gsub( "^,", "" ) )
end

-- the community event's ad, where BO4 had its featured cards: the camo, the progress, how it unlocks
CoD.ShieldCommunityAd = InheritFrom( LUI.UIElement )
CoD.ShieldCommunityAd.__defaultWidth = AD_WIDTH
CoD.ShieldCommunityAd.__defaultHeight = AD_HEIGHT
CoD.ShieldCommunityAd.new = function ( f1_arg0, f1_arg1, f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	local self = LUI.UIElement.new( f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
	self:setClass( CoD.ShieldCommunityAd )
	self.id = "ShieldCommunityAd"
	self.soundSet = "none"

	local UI = CoD.Shield.BrowserUI

	self.Parts = {}

	local function Add( element )
		self:addElement( element )
		table.insert( self.Parts, element )
		return element
	end

	local ImageClip = LUI.UIElement.new( 0, 1, 0, 0, 0, 1, 0, 0 )
	ImageClip:setUseStencil( true )
	Add( ImageClip )

	local Image = LUI.UIImage.new( 0, 1, 0, 0, 0, 1, 0, 0 )
	ImageClip:addElement( Image )
	self.Image = Image
	UI.SetPreviewImage( Image, AD_IMAGE, AD_WIDTH, AD_HEIGHT )

	-- the header as BO4's featured cards have it: dark letters on a light backing
	local Header = LUI.UIText.new( 0, 0, TEXT_LEFT, TEXT_RIGHT, 0, 0, 7, 27 )
	Header:setRGB( 0.14, 0.14, 0.14 )
	Header:setTTF( "ttmussels_demibold" )
	Header:setLetterSpacing( 6 )
	Header:setAlignment( Enum[@"luialignment"][@"lui_alignment_left"] )
	Header:setBackingType( 2 )
	Header:setBackingColor( 0.86, 0.86, 0.86 )
	Header:setBackingAlpha( 0.85 )
	Header:setBackingXPadding( 10 )
	Header:setBackingYPadding( 3 )
	Header:setText( "COMMUNITY EVENT" )
	Add( Header )

	local Title = Add( UI.NewText( TEXT_LEFT, TEXT_RIGHT, 38, 24, "notosans_bold" ) )
	Title:setRGB( 1, 1, 1 )
	Title:setText( "CHAOS SPACE CAMO" )

	local Progress = Add( UI.NewText( TEXT_LEFT, TEXT_RIGHT, 70, 17, "ttmussels_demibold" ) )
	Progress:setRGB( ColorSet.T8__OFF__WHITE.r, ColorSet.T8__OFF__WHITE.g, ColorSet.T8__OFF__WHITE.b )

	local BarBack = Add( UI.NewBox( TEXT_LEFT, TEXT_RIGHT - 30, 93, 98, 1, 1, 1, 0.15 ) )
	local BarFill = Add( UI.NewBox( TEXT_LEFT, TEXT_LEFT, 93, 98, ACCENT.r, ACCENT.g, ACCENT.b, 1 ) )

	local About = Add( UI.NewText( TEXT_LEFT, TEXT_RIGHT, 108, 15, "ttmussels_regular" ) )
	About:setRGB( 0.75, 0.75, 0.75 )

	local Frame = LUI.UIImage.new( 0, 1, -1, 1, 0, 1, -1, 1 )
	Frame:setAlpha( 0.25 )
	Frame:setImage( RegisterImage( @"uie_ui_menu_store_common_frame" ) )
	Frame:setMaterial( LUI.UIImage.GetCachedMaterial( @"uie_nineslice_add" ) )
	Frame:setShaderVector( 0, 0, 0, 0, 0 )
	Frame:setupNineSliceShader( 12, 12 )
	Add( Frame )

	local Accent = Add( UI.NewBox( 0, AD_WIDTH, AD_HEIGHT - 3, AD_HEIGHT, ACCENT.r, ACCENT.g, ACCENT.b, 1 ) )

	-- what the client knows of the event
	local function Refresh()
		local state = CoD.ShieldCommunity and CoD.ShieldCommunity[AD_EVENT]
		local barWidth = TEXT_RIGHT - 30 - TEXT_LEFT
		local share = 0
		local color = ACCENT

		if state ~= nil and state.done then
			Header:setText( "COMMUNITY EVENT COMPLETE" )
			Progress:setText( "UNLOCKED FOR EVERYONE" )
			About:setText( "In every weapon's Shield camos" )
			share = 1
			color = DONE
		elseif state ~= nil and state.known then
			Header:setText( "COMMUNITY EVENT" )
			Progress:setText( Thousands( state.current ) .. " / " .. Thousands( state.goal ) .. " KILLS" )
			About:setText( "Kills in any mode unlock it for everyone" )
			if state.goal > 0 then
				share = math.min( 1, state.current / state.goal )
			end
		else
			Header:setText( "COMMUNITY EVENT" )
			Progress:setText( "100,000 KILLS UNLOCK IT" )
			About:setText( "Kills in any mode unlock it for everyone" )
		end

		BarFill:setLeftRight( 0, 0, TEXT_LEFT, TEXT_LEFT + barWidth * share )
		BarFill:setRGB( color.r, color.g, color.b )
		Accent:setRGB( color.r, color.g, color.b )
	end
	self.Refresh = Refresh

	Refresh()
	CoD.ShieldCommunityListeners.ad = Refresh
	Engine[@"exec"]( f1_arg1, "community_status" )

	LUI.OverrideFunction_CallOriginalSecond( self, "close", self.__onClose )

	if PostLoadFunc then
		PostLoadFunc( self, f1_arg1, f1_arg0 )
	end

	return self
end

CoD.ShieldCommunityAd.__onClose = function ( f2_arg0 )
	if CoD.ShieldCommunityListeners.ad == f2_arg0.Refresh then
		CoD.ShieldCommunityListeners.ad = nil
	end
	f2_arg0.Image:close()
	for _, element in ipairs( f2_arg0.Parts ) do
		element:close()
	end
end
