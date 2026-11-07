AddMenuReponses()
{
    self callback::function_d8abfc3d(#"menu_response", &TryReactiveCamo);
    self callback::function_d8abfc3d(#"menu_response", &HostLeaveAfterGameEnd);
    self callback::function_d8abfc3d(#"menu_response", &SetSprayGesture);
    self callback::function_d8abfc3d(#"menu_response", &TryCallout);
    //ShieldLog("^2Added menu responses..");
}

/*
    The host leaving Blackout after the game ended (a win): the game only skips the end screen it is on,
    and the host waited out the "match ends in" timer. Its server ends instead, as at the end of that.
*/
HostLeaveAfterGameEnd(params)
{
    if (!sessionmodeiswarzonegame() || !isdefined(self) || !isdefined(params))
        return;

    // as text or as a hash, whichever reaches the scripts
    if (params.response !== "endround" && params.response !== #"endround")
        return;

    if (!isdefined(level.gameended) || !level.gameended || !self ishost())
        return;

    if (isdefined(level.exitlevel) && level.exitlevel)
        return;

    ShieldLog("^2Host left after the game ended: ending the match");

    level.exitlevel = 1;
    exitlevel(0);
}

/*
    Zombies: the sprays and gestures a player equipped in multiplayer, one slot at a time (SprayGestureWheel.lua sends
    4096 * slot + item index + 1), for shield-client to know what each slot of the player's wheel plays.
*/
SetSprayGesture(params)
{
    if (!sessionmodeiszombiesgame() || !isdefined(self) || !isdefined(params))
        return;

    if (params.menu !== #"shield_support_menu" || params.response !== #"spray_gesture")
        return;

    ShieldSetSprayGesture(self getentitynumber(), int(params.intpayload / 4096), params.intpayload % 4096);
}

/*
    Zombies callouts (CalloutWheel.lua sends the index on its wheel, + 100 for the title used in last stand): the
    callout's gesture, as multiplayer's menus.gsc plays it, and the callout to the player's team (shown by CalloutWheel.lua).
*/
TryCallout(params)
{
    if (!sessionmodeiszombiesgame() || !isdefined(self) || !isdefined(params))
        return;

    if (params.menu !== #"shield_support_menu" || params.response !== #"callout")
        return;

    table = CalloutGestureTable(params.intpayload % 100);
    if (!isdefined(table))
        return;

    // one a second at most
    time = gettime();
    if (isdefined(self.shield_callout_time) && self.shield_callout_time > time)
        return;

    self.shield_callout_time = time + 1000;

    if (isalive(self) && self isonground() && !self isinfreefall() && !self inlaststand())
        self gestures::function_56e00fbf(table, undefined, 0);

    foreach (player in level.players)
    {
        if (player.team == self.team)
            player luinotifyevent(#"shield_callout", 2, params.intpayload, self getentitynumber());
    }
}

// the gesture tables of the callouts of CalloutWheel.lua, in its order (the callout_wheel bundles of multiplayer)
CalloutGestureTable(index)
{
    switch (index)
    {
        case 0: return #"gestable_command_hello";
        case 1: return #"gestable_command_thanks";
        case 2: return #"gestable_command_need_help";
        case 3: return #"gestable_command_defending";
        case 4: return #"gestable_order_follow";
        case 5: return #"gestable_command_flanking";
        case 6: return #"gestable_command_acknowledge";
        case 7: return #"gestable_command_thanks";
    }

    return undefined;
}

TryReactiveCamo(params) {
    if (!isdefined(self) || isdefined(self.reactive_stage)) {
        return;
    }

	menu = params.menu;

    //ShieldLog("^2menu response with " + ShieldHashLookup(menu));

	if (menu !== #"shield_support_menu")
		return;

    response = params.response;
    intpayload = params.intpayload;

    if (response === #"reactive_apply")
    {
        // add player's reactive camo stage force
        self.reactive_stage = intpayload;

        // log
        ShieldLog("^2added reactive stage player with request -> " + self.name + " -> " + intpayload);
    }
}