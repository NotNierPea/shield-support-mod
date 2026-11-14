/*
    The end of match podium (Podium.csc, PodiumHud.lua): the three best players by score stand on the map's draft stage
    with their own looks, the draft camera on them, before the match leaves.
    At game_ended the top three are sent (stage 1: the clients build the characters, hidden, so they stream in during
    the final killcam); when the match would leave (exit_level, after the outro movie if any) stage 2 shows them for
    shield_podium_time seconds. shield_podium 0 turns it off.
    shield_podium (world): stage 2 bits, then the three entity numbers + 1 (0 none), 8 bits each.
    While shown, the three can play their sprays and gestures (PodiumHud.lua's bar sends podium_gesture with the item
    index): shield_podium_g<place> (world) = (item + 1) * 2 + a toggle bit, so the same pick plays again.
*/

// (the fields on every MP match but freerun, as the clients register them; the dvar is the host's choice)
PodiumRegisterFields()
{
    if(!sessionmodeismultiplayergame() || FreerunIsMatch())
     return;
    clientfield::register("world", "shield_podium", 1, 26, "int");
    clientfield::register("world", "shield_podium_g0", 1, 10, "int");
    clientfield::register("world", "shield_podium_g1", 1, 10, "int");
    clientfield::register("world", "shield_podium_g2", 1, 10, "int");
    if(getdvarint(#"shield_podium", 1) != 0)
     level thread PodiumWatchEnd();
}

PodiumWatchEnd()
{
    level waittill(#"game_ended");
    level.shield_podium = PodiumTop();
    if(level.shield_podium.size == 0)
    {
        ShieldLog("[podium] nobody to show");
        return;
    }
    level clientfield::set("shield_podium", PodiumValue(1));
    foreach(i, player in level.shield_podium)
     ShieldLog("[podium] " + (i + 1) + ": " + player.name + " (" + player getentitynumber() + ") score " + player.score);
}

// the three best players by score, ties by entity number (display_transition's team pose order)
PodiumTop()
{
    players = [];
    foreach(player in level.players)
    {
        if(isdefined(player) && isdefined(player.team) && player.team != #"spectator")
         players[players.size] = player;
    }

    top = [];
    for(n = 0; n < 3 && players.size > 0; n++)
    {
        best = 0;
        for(i = 1; i < players.size; i++)
        {
            if(PodiumBefore(players[i], players[best]))
             best = i;
        }
        top[top.size] = players[best];
        arrayremoveindex(players, best);
    }
    return top;
}

PodiumBefore(a, b)
{
    sa = isdefined(a.score) ? a.score : 0;
    sb = isdefined(b.score) ? b.score : 0;
    if(sa != sb)
     return sa > sb;
    return a getentitynumber() < b getentitynumber();
}

PodiumValue(stage)
{
    value = stage;
    scale = 4;
    for(i = 0; i < 3; i++)
    {
        num = 0;
        if(isdefined(level.shield_podium[i]))
         num = level.shield_podium[i] getentitynumber() + 1;
        value += num * scale;
        scale *= 256;
    }
    return value;
}

PodiumStat(player, field)
{
    value = player.pers[field];
    if(!isdefined(value))
     return 0;
    return int(min(max(value, 0), 999));
}

PodiumShow()
{
    level clientfield::set("shield_podium", PodiumValue(2));
    time = getdvarint(#"shield_podium_time", 8);

    /*
        The HUD's cards: count + 4 * seconds shown, then per place the client number + 128 * (deaths + 1000 * kills)
        (-1 none) and the score
    */
    args = [];
    for(i = 0; i < 3; i++)
    {
        player = level.shield_podium[i];
        args[i * 2] = -1;
        args[i * 2 + 1] = 0;
        if(!isdefined(player))
         continue;
        args[i * 2] = player getentitynumber() + 128 * (PodiumStat(player, "deaths") + 1000 * PodiumStat(player, "kills"));
        args[i * 2 + 1] = isdefined(player.score) ? player.score : 0;
    }
    head = level.shield_podium.size + 4 * time;
    foreach(player in level.players)
    {
        if(!isdefined(player) || isbot(player))
         continue;
        // the game's HUD off (player_end_game turned it on); PodiumHud.lua hides the rest
        player setclientuivisibilityflag("hud_visible", 0);
        player luinotifyevent(#"shield_podium", 7, head, args[0], args[1], args[2], args[3], args[4], args[5]);
    }

    level.shield_podium_live = 1;
    level thread PodiumBots();
    ShieldLog("[podium] showing for " + time + " s");
    wait(time);
    level.shield_podium_live = undefined;
}

// a pick of one of the three (podium_gesture, the item index of the sprays and gestures list)
PodiumMenuResponse(params)
{
    if(!sessionmodeismultiplayergame() || !isdefined(self) || !isdefined(params))
     return;
    if(params.menu !== #"shield_support_menu" || params.response !== #"podium_gesture")
     return;
    if(!isdefined(level.shield_podium_live) || !isdefined(level.shield_podium))
     return;

    foreach(place, player in level.shield_podium)
    {
        if(player == self)
        {
            PodiumGesture(place, params.intpayload);
            return;
        }
    }
}

PodiumGesture(place, item)
{
    player = level.shield_podium[place];
    if(!isdefined(player) || !isdefined(item) || item < 0 || item > 510)
     return;
    // (one a second: each pick restarts the animation on every client)
    now = gettime();
    if(isdefined(player.shield_podium_next) && now < player.shield_podium_next)
     return;
    player.shield_podium_next = now + 1000;

    if(!isdefined(level.shield_podium_toggle))
     level.shield_podium_toggle = [];
    toggle = (isdefined(level.shield_podium_toggle[place]) && level.shield_podium_toggle[place] == 1) ? 0 : 1;
    level.shield_podium_toggle[place] = toggle;

    fields = array("shield_podium_g0", "shield_podium_g1", "shield_podium_g2");
    level clientfield::set(fields[place], (item + 1) * 2 + toggle);
    ShieldLog("[podium] " + (place + 1) + " (" + player.name + ") plays item " + item);
}

// bots on the podium play one of shield_podium_bot_items (item indexes, space separated) once, at a random moment
PodiumBots()
{
    items = strtok(getdvarstring(#"shield_podium_bot_items", ""), " ");
    if(items.size == 0)
     return;
    foreach(place, player in level.shield_podium)
    {
        if(isdefined(player) && isbot(player))
         level thread PodiumBotGesture(place, int(items[randomint(items.size)]));
    }
}

PodiumBotGesture(place, item)
{
    wait(randomfloatrange(1.5, 5));
    if(isdefined(level.shield_podium_live))
     PodiumGesture(place, item);
}

// the match leaves here once it is over (globallogic's end, after the outro movie): the podium first
detour globallogic<scripts\mp_common\gametypes\globallogic.gsc>::exit_level()
{
    if(isdefined(level.shield_podium) && level.shield_podium.size > 0 && !isdefined(level.shield_podium_shown) && isdefined(level.intermission) && level.intermission && !(isdefined(level.exitlevel) && level.exitlevel))
    {
        level.shield_podium_shown = 1;
        PodiumShow();
    }
    [[ @globallogic<scripts\mp_common\gametypes\globallogic.gsc>::exit_level ]]();
}
