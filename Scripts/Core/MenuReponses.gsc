AddMenuReponses()
{
    self callback::function_d8abfc3d(#"menu_response", &TryReactiveCamo);
    //ShieldLog("^2Added menu responses..");
}

TryReactiveCamo(params) {
    if (!isdefined(self)) {
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
        if (!isdefined(level.reactive_camos_force))
            level.reactive_camos_force = array();
        
        player_request = SpawnStruct();
        player_request.player = self; // player calling this menu
        player_request.reactive_stage = intpayload;

        // avoiding errors
        self.forced_reactive = true;

        // add it
        array::add(level.reactive_camos_force, player_request, false);
        ShieldLog("^2added reactive stage player with request -> " + self.name + " -> " + intpayload);

        // for zm, force it to refresh
        if (SessionModeIsZombiesGame() && isalive(self)) {
            level flag::wait_till("initial_blackscreen_passed");

            weapon = self getCurrentWeapon();
            if (isdefined(weapon) && isdefined(self.pers) && isdefined(self.pers[#"activecamo"]))
            {
                self setcamo(weapon, 0);

                wait 0.5;

                foreach (activecamo in self.pers[#"activecamo"])
                {
                    SetReactiveForcedStage(activecamo, intpayload);
                }
            }
        }
    }
}