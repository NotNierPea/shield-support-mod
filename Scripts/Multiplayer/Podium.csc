/*
    The end of match podium's client side (Podium.gsc): the three best players stand on the map's draft stage as the
    draft shows players (character_customization models with each player's look, a standing idle of the draft), the
    draft camera and lights on them.
    Stage 1 (game ended): the characters are made, hidden, so they stream in during the final killcam. Stage 2 (the
    match is leaving): shown, their idle from the start, the camera on.
    The characters are made on the draft slots, then moved in a row in front of the camera when shown (PodiumPlaces).
*/

// (Podium.gsc's place in the order: every MP match but freerun)
PodiumRegisterFields()
{
    if(!sessionmodeismultiplayergame() || FreerunIsMatch())
     return;
    clientfield::register("world", "shield_podium", 1, 26, "int", &PodiumChanged, 0, 0);
    clientfield::register("world", "shield_podium_g0", 1, 10, "int", &PodiumGesture0, 0, 0);
    clientfield::register("world", "shield_podium_g1", 1, 10, "int", &PodiumGesture1, 0, 0);
    clientfield::register("world", "shield_podium_g2", 1, 10, "int", &PodiumGesture2, 0, 0);
}

PodiumGesture0(localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump)
{
    PodiumGesture(localclientnum, 0, newval, binitialsnap);
}

PodiumGesture1(localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump)
{
    PodiumGesture(localclientnum, 1, newval, binitialsnap);
}

PodiumGesture2(localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump)
{
    PodiumGesture(localclientnum, 2, newval, binitialsnap);
}

/*
    A pick of the place's player (Podium.gsc PodiumGesture: (item + 1) * 2 + toggle). A gesture plays the character's lobby
    gesture (as frontend_draft.csc; play_gesture stops the idle and plays it again after). A spray plays the spray can
    gesture of a match (PodiumSpray): the lobby's spray animation (get_gesture(-1)) isn't loaded in a match, the engine
    played its stand-in (a dance) instead.
*/
PodiumGesture(localclientnum, place, value, binitialsnap)
{
    if(!isdefined(value) || value < 2 || (isdefined(binitialsnap) && binitialsnap))
     return;
    podium = isdefined(level.shield_podium) ? level.shield_podium[localclientnum] : undefined;
    if(!isdefined(podium) || !isdefined(podium.shown) || !isdefined(podium.byplace) || !isdefined(podium.byplace[place]))
     return;

    character = podium.byplace[place];
    item = int(value / 2) - 1;
    if(!isgesture(item))
    {
        ShieldLog("[podium] " + (place + 1) + ": item " + item + " (spray)");
        character thread PodiumSpray(character);
        return;
    }

    gesture = character [[ @namespace_7da27482<scripts\core_common\character_customization.csc>::get_gesture ]](item);
    if(!isdefined(gesture) || !isdefined(gesture.animation))
    {
        ShieldLog("[podium] " + (place + 1) + ": item " + item + " has no animation for this character");
        return;
    }

    // (no hash in the text: a hash in a string is a script error)
    ShieldLog("[podium] " + (place + 1) + ": item " + item + " (gesture)");
    character notify(#"cancel_gesture");
    character thread [[ @namespace_7da27482<scripts\core_common\character_customization.csc>::play_gesture ]](item, 0, 1, 0);
}

/*
    The spray can gesture of mp_common's spray table (gesture hash_2b7bf0994d95c434: its third person anims, 0xC0 for
    male bodies, 0x108 for female ones; the can comes with the anim's "attach player model" markup), then the idle again
*/
PodiumSpray(character)
{
    character notify(#"cancel_gesture");
    character endon(#"cancel_gesture", #"deleted");

    body = character.var_228f64da;
    data = character [[ @namespace_7da27482<scripts\core_common\character_customization.csc>::function_82e05d64 ]]();
    if(!isdefined(body) || !isdefined(data))
     return;

    sprayanim = #"hash_4a8ac6c20248d6cb";
    if(isdefined(data.shield_gender) && data.shield_gender == #"female")
     sprayanim = #"hash_18d469e682773b84";

    character [[ @namespace_7da27482<scripts\core_common\character_customization.csc>::function_39a68bf2 ]](1, 1);
    body [[ @animation<scripts\core_common\animation_shared.csc>::play ]](sprayanim, body);
    character [[ @namespace_7da27482<scripts\core_common\character_customization.csc>::function_ef064067 ]](data.params, 1);
}

PodiumChanged(localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump)
{
    if(!isdefined(newval) || newval === oldval)
     return;

    stage = newval % 4;
    if(stage == 0)
     return;

    nums = [];
    scale = 4;
    for(i = 0; i < 3; i++)
    {
        nums[i] = int(newval / scale) % 256 - 1;
        scale *= 256;
    }

    if(!isdefined(level.shield_podium))
     level.shield_podium = [];

    // (stage 2 straight away when the client came late: made, then shown)
    if(!isdefined(level.shield_podium[localclientnum]))
     PodiumMake(localclientnum, nums);
    if(stage == 2)
     level thread PodiumShow(localclientnum);
}

// the draft stage: its camera struct and player spots (draft.csc's, the allies' first as draft.csc's own fallback)
PodiumStage()
{
    if(!isdefined(level.draftstructs) || !isdefined(level.playerscriptstructs))
     return undefined;

    foreach(team in array(#"allies", #"free", #"axis"))
    {
        if(!isdefined(level.draftstructs[team]) || !isdefined(level.playerscriptstructs[team]))
         continue;
        root = struct::get(level.draftstructs[team], "targetname");
        spots = level.playerscriptstructs[team];
        if(!isdefined(root) || !isdefined(spots[0]) || !isdefined(spots[1]) || !isdefined(spots[2]))
         continue;

        stage = spawnstruct();
        stage.team = team;
        stage.root = root;
        stage.spots = spots;
        return stage;
    }
    return undefined;
}

PodiumMake(localclientnum, nums)
{
    podium = spawnstruct();
    podium.characters = [];
    level.shield_podium[localclientnum] = podium;

    podium.stage = PodiumStage();
    if(!isdefined(podium.stage))
    {
        ShieldLog("[podium] no draft stage on this map: nothing shown");
        return;
    }

    podium.nums = nums;
    podium.made = [];
    podium.byplace = [];
    PodiumRetry(localclientnum, podium);
    level thread PodiumWait(localclientnum, podium);
}

// players not in this client's snapshot yet (dead, in the killcam): tried again until the podium shows
PodiumWait(localclientnum, podium)
{
    while(!isdefined(podium.shown))
    {
        wait(0.25);
        PodiumRetry(localclientnum, podium);
    }
}

PodiumRetry(localclientnum, podium)
{
    // (made on the draft slots, moved in front of the camera when shown)
    slots = array(1, 0, 2);
    for(i = 0; i < 3; i++)
    {
        if(podium.nums[i] < 0 || isdefined(podium.made[i]))
         continue;
        player = getentbynum(localclientnum, podium.nums[i]);
        if(!isdefined(player))
        {
            if(!isdefined(podium.shown))
             continue;
            ShieldLog("[podium] " + (i + 1) + ": client " + podium.nums[i] + " never came");
            continue;
        }
        podium.made[i] = 1;
        character = PodiumCharacter(localclientnum, player, podium.stage.spots[slots[i]], i);
        if(isdefined(character))
        {
            podium.characters[podium.characters.size] = character;
            podium.byplace[i] = character;
        }
        ShieldLog("[podium] " + (i + 1) + ": client " + podium.nums[i] + " made");
    }
}

// a draft character (draft.csc setup_team, update_team, function_93a4f3c5, function_a1c71160, function_6b532f83)
PodiumCharacter(localclientnum, player, spot, index)
{
    model = util::spawn_model(localclientnum, "tag_origin", spot.origin, spot.angles);
    model.targetname = "shield_podium_" + index;
    character = [[ @character_customization<scripts\core_common\character_customization.csc>::function_dd295310 ]](model, localclientnum, 0);
    if(!isdefined(character))
     return undefined;

    mode = currentsessionmode();
    character [[ @namespace_7da27482<scripts\core_common\character_customization.csc>::set_character_mode ]](mode);
    data = character [[ @namespace_7da27482<scripts\core_common\character_customization.csc>::function_82e05d64 ]]();
    data.positionindex = index;
    data.params = spawnstruct();
    data.params.sessionmode = mode;
    data.player = player;
    data.var_c018da16 = player function_79a48799();
    // characters past the 17 (Support.csc)
    PatchDraftCharacter(character);

    look = data.var_c018da16;
    gender = #"male";
    if(isdefined(look) && isdefined(look.charactertype) && look.charactertype > 0)
    {
        character [[ @namespace_7da27482<scripts\core_common\character_customization.csc>::function_1ec9448d ]](0);
        character [[ @namespace_7da27482<scripts\core_common\character_customization.csc>::function_15a8906a ]](look);
        gender = getherogender(look.charactertype, mode);
    }
    else
    {
        character [[ @namespace_7da27482<scripts\core_common\character_customization.csc>::function_1ec9448d ]](1);
        character [[ @namespace_7da27482<scripts\core_common\character_customization.csc>::set_character_index ]](0);
        ShieldLog("[podium] client " + player getentitynumber() + " has no look: the default character");
    }

    // the weapon in hand: the primary, else the secondary
    weapon = player getprimaryweapon();
    options = player function_519bc773();
    if(!isdefined(weapon) || weapon == level.weaponnone)
    {
        weapon = player getsecondaryweapon();
        options = player function_64c66c4b();
    }
    data.activeweapon = weapon;
    data.params.activeweapon = weapon;
    data.params.var_b8f20727 = options;

    // a standing idle of the draft's weapon group, no intro: shield_podium_anim preready (the not yet ready stand,
    // default), select (the character select hold) or readyidle (the ready poses)
    data.shield_gender = gender;
    data.params.anim_intro_name = undefined;
    data.params.anim_name = PodiumIdle([[ @draft<scripts\mp_common\draft.csc>::function_bb0565d0 ]](data), gender, index);

    character [[ @namespace_7da27482<scripts\core_common\character_customization.csc>::hide_model ]]();
    character [[ @namespace_7da27482<scripts\core_common\character_customization.csc>::update ]](data.params);
    return character;
}

PodiumIdle(groups, gender, index)
{
    kind = getdvarstring(#"shield_podium_anim", "preready");
    key = #"preready";
    if(kind == "select")
     key = #"select";
    else if(kind == "readyidle")
     key = #"readyidle";
    if(!isdefined(groups) || !isdefined(groups[key]) || !isdefined(groups[key][gender]))
     return "pb_rifle_male_draft_preready_1";

    anims = groups[key][gender];
    // (select is one name, the others a list)
    if(!isarray(anims))
     return anims;
    return anims[index % anims.size];
}

PodiumShow(localclientnum)
{
    podium = level.shield_podium[localclientnum];
    if(!isdefined(podium) || isdefined(podium.shown) || !isdefined(podium.stage))
     return;
    podium.shown = 1;
    // last try for players that weren't here at stage 1
    PodiumRetry(localclientnum, podium);

    stage = podium.stage;
    if(isdefined(level.var_1f0933dc) && isdefined(level.var_1f0933dc[stage.team]))
     playradiantexploder(localclientnum, level.var_1f0933dc[stage.team]);

    // the draft's in game camera (the map's xcam, level.var_bbb8810e)
    if(isdefined(level.var_bbb8810e))
     playmaincamxcam(localclientnum, level.var_bbb8810e, 0, "cam_draft_ingame", "", stage.root.origin, stage.root.angles);
    else
     ShieldLog("[podium] the map has no draft camera");

    // the draft slots crowd 5 players right at the camera: the 3 go in a row in front of it instead
    wait(0.1);
    places = PodiumPlaces(localclientnum, stage);
    foreach(character in podium.characters)
    {
        data = character [[ @namespace_7da27482<scripts\core_common\character_customization.csc>::function_82e05d64 ]]();
        place = places[data.positionindex];
        if(isdefined(place))
        {
            data.params.align_struct = place;
            // (its current model too: a gesture plays where the model is; the class replaced the one made here)
            body = character.var_228f64da;
            if(isdefined(body))
            {
                body.origin = place.origin;
                body.angles = place.angles;
            }
        }
        // moved, the idle again from its start
        character [[ @namespace_7da27482<scripts\core_common\character_customization.csc>::function_ef064067 ]](data.params, 1);
        character [[ @namespace_7da27482<scripts\core_common\character_customization.csc>::show_model ]]();
    }

    ShieldLog("[podium] shown, " + podium.characters.size + " characters");
}

/*
    Where the 3 stand: shield_podium_dist units in front of the camera (flat), 1st in the middle, 2nd left and 3rd right
    shield_podium_spacing apart and a little back, facing the camera, on the draft stage's floor height.
*/
PodiumPlaces(localclientnum, stage)
{
    campos = getcamposbylocalclientnum(localclientnum);
    camang = getcamanglesbylocalclientnum(localclientnum);
    if(!isdefined(campos) || !isdefined(camang))
     return [];

    yaw = (0, camang[1], 0);
    forward = anglestoforward(yaw);
    right = anglestoright(yaw);
    dist = getdvarfloat(#"shield_podium_dist", 110);
    spacing = getdvarfloat(#"shield_podium_spacing", 62);
    back = getdvarfloat(#"shield_podium_back", 12);
    z = stage.spots[1].origin[2];

    sides = array(0, -1, 1);
    places = [];
    for(i = 0; i < 3; i++)
    {
        pos = campos + forward * (dist + (i > 0 ? back : 0)) + right * (sides[i] * spacing);
        place = spawnstruct();
        place.origin = (pos[0], pos[1], z);
        place.angles = (0, camang[1] + 180, 0);
        places[i] = place;
    }
    ShieldLog("[podium] camera " + campos + " " + camang + ", 1st at " + places[0].origin);
    return places;
}
