AddMenuReponses()
{
    self callback::function_d8abfc3d(#"menu_response", &TryReactiveCamo);
    self callback::function_d8abfc3d(#"menu_response", &HostLeaveAfterGameEnd);
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