AddMenuReponses()
{
    self callback::function_d8abfc3d(#"menu_response", &TryReactiveCamo);
    self callback::function_d8abfc3d(#"menu_response", &HostLeaveAfterGameEnd);
    self callback::function_d8abfc3d(#"menu_response", &SetSprayGesture);
    self callback::function_d8abfc3d(#"menu_response", &TryCallout);
    self callback::function_d8abfc3d(#"menu_response", &SetZombiesOutfit);
    self callback::function_d8abfc3d(#"menu_response", &SetShieldCustomization);
    //ShieldLog("^2Added menu responses..");
}

/*
    Multiplayer characters past the loadout's 17 (the support zone's crews as specialists, shield-client mp_loadouts.cpp
    keeps their picks): the game reads a player's look in a match from their public profile, which has no entry for them.
    Their client sends its picks when asked (shield_custom_request, at the connection; OutfitPortraits.lua): 16384 *
    character + 1024 * field + value, fields 0 outfit, 1 war paint outfit, 2.. the items (CustomItemTypes), those not the default, then 15
    (the end); put on as the player picks the character and at each spawn
*/
CustomItemTypes()
{
    return array("head", "headgear", "arms", "torso", "legs", "palette", "warpaint", "decal");
}

SetShieldCustomization(params)
{
    if(!sessionmodeismultiplayergame() || !isdefined(self) || !isdefined(params))
     return;

    if(params.menu !== #"shield_support_menu" || params.response !== #"mp_custom")
     return;

    character = int(params.intpayload / 16384);
    field = int(params.intpayload / 1024) % 16;
    value = params.intpayload % 1024;

    // the end of the picks (only those not the default come): logged, the look put on (alive or not: the draft shows it)
    if(field == 15)
    {
        self.shield_custom_done = 1;
        role = self getspecialistindex();
        custom = (isdefined(role) && isdefined(self.shield_custom) && isdefined(self.shield_custom[role])) ? self.shield_custom[role] : [];
        ShieldLog("^3MP custom of " + self.name + " in (character " + (isdefined(role) ? role : -1) + ": outfit " + (isdefined(custom[0]) ? custom[0] : 0)
            + ", war paint outfit " + (isdefined(custom[1]) ? custom[1] : 0) + ", war paint " + (isdefined(custom[8]) ? custom[8] : 0) + ")");
        self ApplyShieldCustomization();
        return;
    }

    if(!isdefined(self.shield_custom))
     self.shield_custom = [];
    if(!isdefined(self.shield_custom[character]))
     self.shield_custom[character] = [];
    self.shield_custom[character][field] = value;
}

ApplyShieldCustomization()
{
    role = self getspecialistindex();
    if(!isdefined(role) || !isdefined(self.shield_custom) || !isdefined(self.shield_custom[role]))
    {
        self SetShieldCustomFields(undefined, undefined);
        return;
    }

    custom = self.shield_custom[role];
    ShieldLog("^3MP custom put on " + self.name + " (character " + role + ": outfit " + (isdefined(custom[0]) ? custom[0] : 0)
        + ", war paint outfit " + (isdefined(custom[1]) ? custom[1] : 0) + ", war paint " + (isdefined(custom[8]) ? custom[8] : 0) + ")");
    if(isdefined(custom[0]))
     self setcharacteroutfit(custom[0]);
    if(isdefined(custom[1]))
     self setcharacterwarpaintoutfit(custom[1]);

    types = CustomItemTypes();
    for(i = 0; i < types.size; i++)
    {
        if(isdefined(custom[i + 2]))
         self function_ab96a9b5(types[i], custom[i + 2]);
    }
    self SetShieldCustomFields(role, custom);
}

// a field of the picks, 0 when it doesn't fit its bits
ShieldCustomValue(custom, field, limit)
{
    value = isdefined(custom[field]) ? int(custom[field]) : 0;
    return (value >= 0 && value < limit) ? value : 0;
}

/*
    The draft shows a player's look from their public profile (none for characters past the 17): the picks go to every
    client in clientfields, Support.csc puts them on the draft's character.
    a: valid 1, role 7, outfit 6, war paint outfit 6, war paint 10; b: head, headgear, arms, torso, legs 6 each; c: palette, decal 8 each
*/
SetShieldCustomFields(role, custom)
{
    if(!sessionmodeismultiplayergame())
     return;

    a = 0;
    b = 0;
    c = 0;
    if(isdefined(role) && isdefined(custom) && role >= 0 && role < 128)
    {
        a = 1 + 2 * role + 256 * ShieldCustomValue(custom, 0, 64) + 16384 * ShieldCustomValue(custom, 1, 64) + 1048576 * ShieldCustomValue(custom, 8, 1024);
        b = ShieldCustomValue(custom, 2, 64) + 64 * ShieldCustomValue(custom, 3, 64) + 4096 * ShieldCustomValue(custom, 4, 64)
            + 262144 * ShieldCustomValue(custom, 5, 64) + 16777216 * ShieldCustomValue(custom, 6, 64);
        c = ShieldCustomValue(custom, 7, 256) + 256 * ShieldCustomValue(custom, 9, 256);
    }
    self clientfield::set("shield_custom_a", a);
    self clientfield::set("shield_custom_b", b);
    self clientfield::set("shield_custom_c", c);
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