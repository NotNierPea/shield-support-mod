--[[
		.\hksc.exe ".\Lua\CallingCardToast.Lua" -o "C:\Program Files (x86)\Call of Duty Black Ops 4\project-bo4\internals\T8ShieldSupport\Lua\Game\CallingCardToast.luac"
]]

---------------------------

if CoD.isFrontend then
	return
end

CoD.ShieldInitLuaFile()

---------------------------

--[[
	A calling card of ours earned in a match (shield-client's custom_calling_cards.cpp; a map's GSC sends
	`player luinotifyevent(#"shield_calling_card", 1, <background id>)`, zm_park's bfn_quest.py): the game's challenge
	toast, as when a challenge gives a calling card (CoD.NotificationUtility, "Challenges"): the card's name and
	description, the Custom challenges' icon, the card as its reward.
]]
local NOTIFY = @"shield_calling_card"

local function Log( text )
	Engine[@"printinfo"]( 0, "[shield] calling card toast: " .. text .. "\n" )
end

-- a text of a card, localized: its localize entry shield/callingcard/<id>/<name | desc> (shield-client's)
local function CardText( id, field )
	return Engine[@"hash_4F9F1239CFD921FE"]( Engine[@"converttoxhash"]( "shield/callingcard/" .. id .. "/" .. field ) )
end

local function CardImage( id )
	if CoD.ChallengesUtility and CoD.ChallengesUtility.GetBackgroundByID then
		return CoD.ChallengesUtility.GetBackgroundByID( id )
	end
	return Engine[@"tablelookup"]( CoD.backgroundsTable or @"gamedata/emblems/backgrounds.csv", 3, 1, id )
end

local function ShowCardToast( widget, id )
	local image = CardImage( id )
	if image == nil or image == @"hash_0" then
		Log( "card " .. tostring( id ) .. " is no background" )
		return
	end

	-- (GetChallengeRewardInfo's fields: one tier, done, the card in the reward queue as a challenge's)
	CoD.NotificationUtility.AddNotification( widget, {
		type = "Challenges",
		rewardInfo = {
			titleText = CardText( id, "name" ),
			subtitleText = CardText( id, "desc" ),
			icon = @"shield_challenges_custom",
			currentTier = 0,
			maxTier = 0,
			emblemInfo = {
				displayString = Engine[@"localize"]( @"hash_65D0D4D46178F2C8" ),
				image = image
			}
		}
	} )
	Log( "card " .. tostring( id ) )
end

local function HookNotifications()
	local utility = CoD.NotificationUtility
	if not utility or utility.shieldCardToast or not utility.InitNotifications then
		return
	end

	utility.shieldCardToast = true
	local GameInit = utility.InitNotifications
	utility.InitNotifications = function ( self, controller, menu, ... )
		GameInit( self, controller, menu, ... )

		self:subscribeToGlobalModel( controller, "PerController", "scriptNotify", function ( model )
			if Engine[@"getmodelvalue"]( model ) == NOTIFY then
				local data = CoD.GetScriptNotifyData( model )
				ShowCardToast( self, data and data[1] )
			end
		end )
	end
end

HookNotifications()

-- the notifications' file may be read after this one: hooked once it is
if not CoD.ShieldCardToastRequire then
	CoD.ShieldCardToastRequire = true
	local GameRequire = require
	require = function ( ... )
		local result = GameRequire( ... )
		HookNotifications()
		return result
	end
end
