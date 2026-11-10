AddMenuReponses()
{
    self callback::function_d8abfc3d(#"menu_response", &TryReactiveCamo);
    self callback::function_d8abfc3d(#"menu_response", &HostLeaveAfterGameEnd);
    self callback::function_d8abfc3d(#"menu_response", &SetSprayGesture);
    self callback::function_d8abfc3d(#"menu_response", &TryCallout);
    self callback::function_d8abfc3d(#"menu_response", &SetZombiesOutfit);
    //ShieldLog("^2Added menu responses..");
}

/*
    Zombies outfits of ours (shield-client "outfit_adds", Outfits.lua's outfit list): zm_characters sets outfit 0 on every
    player, SprayGestureWheel.lua sends the outfit picked of each character that has one (64 * character index + outfit),
    set again here and on each spawn
*/
SetZombiesOutfit(params)
{
    if(!sessionmodeiszombiesgame() || !isdefined(self) || !isdefined(params))
     return;

    if(params.menu !== #"shield_support_menu" || params.response !== #"zm_outfit")
     return;

    if(!isdefined(self.shield_outfits))
     self.shield_outfits = [];

    self.shield_outfits[int(params.intpayload / 64)] = params.intpayload % 64;
    self ApplyZombiesOutfit();
    BroadcastZombiesOutfits();
}

ApplyZombiesOutfit()
{
    if(!isdefined(self.shield_outfits) || !isdefined(self.characterindex) || !isdefined(self.shield_outfits[self.characterindex]))
     return;

    self setcharacteroutfit(self.shield_outfits[self.characterindex]);
}

ZombiesOutfitOnSpawned()
{
    self endon(#"disconnect");

    // (after zm_characters' outfit 0)
    waitframe(1);
    self ApplyZombiesOutfit();
    BroadcastZombiesOutfits();
}

// every player's outfit to every player's HUD (SprayGestureWheel.lua: portraits, scoreboard): client, character, outfit
BroadcastZombiesOutfits()
{
    players = getplayers();
    foreach(player in players)
    {
        if(!isdefined(player.characterindex))
         continue;

        outfit = 0;
        if(isdefined(player.shield_outfits) && isdefined(player.shield_outfits[player.characterindex]))
         outfit = player.shield_outfits[player.characterindex];

        foreach(other in players)
         other luinotifyevent(#"shield_outfit", 3, player getentitynumber(), player.characterindex, outfit);
    }
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

    self thread CalloutVoice(params.intpayload % 100, params.intpayload >= 100);
}

/*
    The character's line for the callout, Blackout's (support.ff: shield_vo_<callout>_<character>, the 2d variant for
    the speaker, the 3d one for the others), after a moment as battlechatter.gsc's function_e3ebbf87.
*/
CalloutVoice(index, alt)
{
    self endon(#"death", #"disconnect");

    callout = CalloutVoiceName(index, alt);
    character = CalloutVoiceCharacter();
    if (!isdefined(callout) || !isdefined(character))
        return;

    // Marlton, Russman and Stuhlinger have no "need revive" line
    if (callout == "needrevive" && (character == "marlton" || character == "russman" || character == "stuhlinger"))
        callout = "needhelp";

    wait 0.25;

    if (!isdefined(self) || !isalive(self) || self isplayerunderwater() || (isdefined(self.isspeaking) && self.isspeaking))
        return;

    self playsoundontag("shield_vo_" + callout + "_" + character, "J_Head");
}

// the callouts of CalloutWheel.lua with lines; cover me and flanking have none
CalloutVoiceName(index, alt)
{
    switch (index)
    {
        case 0: return "hello";
        case 1: return "nicework";
        case 2: return alt ? "needrevive" : "needhelp";
        case 4: return "groupup";
        case 6: return "acknowledge";
        case 7: return "thanks";
        case 8: return "taunt";
    }

    return undefined;
}

// the player's character as the lines name it (Shaw is stanton; the _whi and _dlc0 ones are the same voices)
CalloutVoiceCharacter()
{
    if (!player_role::is_valid(player_role::get()))
        return undefined;

    switch (function_b14806c6(player_role::get(), currentsessionmode()))
    {
        case #"prt_zm_dempsey":
        case #"prt_zm_dempsey_whi": return "dempsey";
        case #"prt_zm_dempsey_ofc": return "dempsey_ofc";
        case #"prt_zm_nikolai":
        case #"prt_zm_nikolai_whi": return "nikolai";
        case #"prt_zm_nikolai_ofc": return "nikolai_ofc";
        case #"prt_zm_richtofen":
        case #"prt_zm_richtofen_whi": return "richtofen";
        case #"prt_zm_richtofen_ofc": return "richtofen_ofc";
        case #"prt_zm_takeo":
        case #"prt_zm_takeo_whi": return "takeo";
        case #"prt_zm_takeo_ofc": return "takeo_ofc";
        case #"prt_zm_scarlett":
        case #"prt_zm_scarlett_dlc0": return "scarlett";
        case #"prt_zm_stanton":
        case #"prt_zm_stanton_dlc0": return "stanton";
        case #"prt_zm_bruno":
        case #"prt_zm_bruno_dlc0": return "bruno";
        case #"prt_zm_diego":
        case #"prt_zm_diego_dlc0": return "diego";
        case #"prt_zm_misty": return "misty";
        case #"prt_zm_marlton": return "marlton";
        case #"prt_zm_russman": return "russman";
        case #"prt_zm_stuhlinger": return "stuhlinger";
    }

    return undefined;
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
        case 8: return #"gestable_command_taunt";
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