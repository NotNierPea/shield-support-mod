AddMenuReponses()
{
    self callback::function_d8abfc3d(#"menu_response", &TryReactiveCamo);
    //ShieldLog("^2Added menu responses..");
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