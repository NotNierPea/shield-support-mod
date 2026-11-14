--[[
		.\hksc.exe ".\Lua\In-Game Side\Target Range\TargetRangeHud.lua" -o "C:\Program Files (x86)\Call of Duty Black Ops 4\project-bo4\internals\T8ShieldSupport\Lua\Game\TargetRangeHud.luac"
]]

---------------------------

if CoD.isFrontend then
	return
end

CoD.ShieldInitLuaFile()

---------------------------

--[[
	The target range's HUD (TargetRange.gsc): the damage of each hit floats up beside the crosshair, and a panel on the
	right keeps the last hit, its distance, the target's state and the last kill. The server sends, to the shooter:
	  shield_targetrange_hit   damage, health left, hits on it, damage on it, headshot 0/1, distance in m
	  shield_targetrange_kill  hits, ms from the first hit, damage
	The panel shows in a target range match (gametype targetrange or dvar shield_targetrange 1) or at the first hit.
]]

local HIT = @"shield_targetrange_hit"
local KILL = @"shield_targetrange_kill"
local FONT = "ttmussels_regular"
local FONT_BOLD = "ttmussels_demibold"
local ACCENT = { 1, 0.55, 0.2 }
local HEAD = { 1, 0.3, 0.25 }
local GREY = { 0.55, 0.55, 0.55 }

local function Log( text )
	Engine[@"printinfo"]( 0, "[TargetRangeHud] " .. tostring( text ) )
end

local function IsTargetRange()
	local gametype = ""
	pcall( function ()
		gametype = Dvar[@"g_gametype"] and Dvar[@"g_gametype"]:get() or ""
	end )
	return gametype == "targetrange" or Engine[@"getdvarint"]( @"shield_targetrange" ) == 1
end

local function Rect( parent, xl, xr, left, right, yt, yb, top, bottom, rgb, alpha )
	local rect = LUI.UIImage.new( xl, xr, left, right, yt, yb, top, bottom )
	rect:setRGB( rgb[1], rgb[2], rgb[3] )
	rect:setAlpha( alpha or 1 )
	parent:addElement( rect )
	return rect
end

local function Text( parent, left, right, top, size, font, align, rgb )
	local text = LUI.UIText.new( 0, 0, left, right, 0, 0, top, top + size )
	text:setTTF( font or FONT )
	text:setAlignment( Enum[@"luialignment"][align or @"lui_alignment_left"] )
	text:setRGB( ( rgb or { 1, 1, 1 } )[1], ( rgb or { 1, 1, 1 } )[2], ( rgb or { 1, 1, 1 } )[3] )
	parent:addElement( text )
	return text
end

-- animation steps one after the other ({ ms, fn }); a new sequence drops the old one
local function Sequence( element, steps )
	local token = {}
	element:completeAnimation()
	element.shieldSequence = token
	local k = 0
	local function nextStep()
		if element.shieldSequence ~= token then
			return
		end
		k = k + 1
		local step = steps[k]
		if not step then
			element.shieldSequence = nil
			return
		end
		element:beginAnimation( math.max( 1, step[1] ) )
		step[2]( element )
	end
	element:registerEventHandler( "transition_complete_keyframe", function ()
		nextStep()
	end )
	nextStep()
end

---------------------------

-- the panel on the right: 340 x 236, its rows of caption and value
local PANEL_W = 340

local function NewPanel( menu )
	local panel = LUI.UIElement.new( 1, 1, -PANEL_W - 48, -48, 0.5, 0.5, -60, 176 )
	panel.id = "ShieldTargetRangePanel"
	menu:addElement( panel )

	Rect( panel, 0, 1, 0, 0, 0, 1, 0, 0, { 0.04, 0.04, 0.04 }, 0.78 )
	Rect( panel, 0, 1, 0, 0, 0, 0, 0, 4, ACCENT, 1 )
	Text( panel, 18, PANEL_W - 18, 14, 24, FONT_BOLD ):setText( "TARGET RANGE" )
	Rect( panel, 0, 0, 18, PANEL_W - 18, 0, 0, 46, 47, { 1, 1, 1 }, 0.12 )

	local function Row( top, caption )
		local label = Text( panel, 18, 140, top + 4, 15, FONT, nil, GREY )
		label:setLetterSpacing( 2 )
		label:setText( caption )
		local value = Text( panel, 140, PANEL_W - 18, top, 22, FONT_BOLD, @"lui_alignment_right" )
		value:setText( "-" )
		return value
	end

	panel.LastHit = Row( 58, "LAST HIT" )
	panel.Distance = Row( 88, "DISTANCE" )
	panel.Target = Row( 118, "TARGET" )
	panel.Kill = Row( 148, "LAST KILL" )

	local hint = Text( panel, 18, PANEL_W - 18, 204, 14, FONT, nil, GREY )
	hint:setText( "Pause menu: change class or leave" )

	return panel
end

-- the number by the crosshair
local function NewFloater( menu )
	local floater = LUI.UIText.new( 0.5, 0.5, 40, 240, 0.5, 0.5, -64, -28 )
	floater.id = "ShieldTargetRangeFloater"
	floater:setTTF( "notosans_bold" )
	floater:setAlignment( Enum[@"luialignment"][@"lui_alignment_left"] )
	floater:setAlpha( 0 )
	menu:addElement( floater )
	return floater
end

local function Ensure( menu )
	if not menu.ShieldTargetRangePanel then
		menu.ShieldTargetRangePanel = NewPanel( menu )
		menu.ShieldTargetRangeFloater = NewFloater( menu )
	end
	return menu.ShieldTargetRangePanel, menu.ShieldTargetRangeFloater
end

local function OnHit( menu, data )
	local damage, left, hits, total, head, meters = data[1] or 0, data[2] or 0, data[3] or 0, data[4] or 0, data[5] == 1, data[6] or 0
	local panel, floater = Ensure( menu )

	panel.LastHit:setText( tostring( damage ) .. ( head and "  HEAD" or "" ) )
	if head then
		panel.LastHit:setRGB( HEAD[1], HEAD[2], HEAD[3] )
	else
		panel.LastHit:setRGB( 1, 1, 1 )
	end
	panel.Distance:setText( tostring( meters ) .. " m" )
	panel.Target:setText( tostring( left ) .. " HP  -  " .. tostring( hits ) .. ( hits == 1 and " hit" or " hits" ) )

	local rgb = head and HEAD or { 1, 1, 1 }
	floater:setText( tostring( damage ) )
	Sequence( floater, {
		{ 1, function ( self )
			self:setRGB( rgb[1], rgb[2], rgb[3] )
			self:setAlpha( 1 )
			self:setTopBottom( 0.5, 0.5, -64, -28 )
		end },
		{ 250, function () end },
		{ 500, function ( self )
			self:setAlpha( 0 )
			self:setTopBottom( 0.5, 0.5, -92, -56 )
		end }
	} )
end

local function OnKill( menu, data )
	local hits, ms, total = data[1] or 0, data[2] or 0, data[3] or 0
	local panel = Ensure( menu )
	panel.Kill:setText( tostring( hits ) .. ( hits == 1 and " hit, " or " hits, " ) .. string.format( "%.2f s", ms / 1000 ) )
	panel.Target:setText( "down, " .. tostring( total ) .. " damage" )
end

local function Watch( menu, controller )
	if menu.ShieldTargetRangeWatch then
		return
	end

	local watch = LUI.UIElement.new( 0, 0, 0, 0, 0, 0, 0, 0 )
	watch.id = "ShieldTargetRangeWatch"
	menu:addElement( watch )
	menu.ShieldTargetRangeWatch = watch

	if IsTargetRange() then
		Ensure( menu )
	end

	watch:subscribeToGlobalModel( controller, "PerController", "scriptNotify", function ( model )
		local name = Engine[@"getmodelvalue"]( model )
		if name ~= HIT and name ~= KILL then
			return
		end
		local ok, err = pcall( name == HIT and OnHit or OnKill, menu, CoD.GetScriptNotifyData( model ) or {} )
		if not ok then
			Log( "not shown: " .. tostring( err ) )
		end
	end )
end

-- (CustomMapHud.lua calls the watchers when the MP HUD opens)
CoD.ShieldHudWatchers = CoD.ShieldHudWatchers or {}
CoD.ShieldHudWatchers.targetrange = function ( menu, controller )
	local ok, err = pcall( Watch, menu, controller )
	if not ok then
		Log( "not watched: " .. tostring( err ) )
	end
end
