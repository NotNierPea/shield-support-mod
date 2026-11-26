// Check if the host is on a dedicated server and force them to spectator if so
detour globallogic_ui<scripts\mp_common\gametypes\globallogic_ui.gsc>::menuautoassign(comingfrommenu, var_4c542e39)
{
    if (getDvarInt(#"shield_dedicated", 0) && self IsHost())
    {
        ShieldLog("^3Dedicated: the host watches, it is on no team");

        self [[ @teams<scripts\core_common\teams.gsc>::function_dc7eaabd ]](#"spectator");
        return;
    }

    return [[ @globallogic_ui<scripts\mp_common\gametypes\globallogic_ui.gsc>::menuautoassign ]](comingfrommenu, var_4c542e39);
}

// a dedicated server's players in the match: neither bots nor the server itself
DedicatedHumans()
{
    humans = 0;
    foreach (player in getplayers())
    {
        if (!player isTestClient() && !player IsHost())
            humans++;
    }
    return humans;
}

// bots beside that many players: shield_dedicated_bots fills them up, within the places but one (the server has one, one stays free for joins)
DedicatedBotsWanted(humans)
{
    fill = getDvarInt(#"shield_dedicated_bots", 0);
    places = getDvarInt(#"com_maxclients", 0) - 1;
    if (places > 0 && fill > places - 1)
        fill = places - 1;
    if (fill <= humans)
        return 0;
    return fill - humans;
}

// a dedicated server's time before a multiplayer match (shield_dedicated_prematch): the draft and its start countdown, or the pre-match period
DedicatedPrematch()
{
    seconds = getDvarInt(#"shield_dedicated_prematch", 0);
    if (seconds <= 0)
        return;
    start = getgametypesetting(#"draftmatchstarttime");
    half = int(seconds / 2);
    if (!isDefined(start) || start > half)
        start = half;
    setgametypesetting(#"draftmatchstarttime", start);
    setgametypesetting(#"drafttime", seconds - start);
    setgametypesetting(#"prematchperiod", seconds);
    ShieldLog("^3Dedicated: " + seconds + " s before the match, draft " + (seconds - start) + " + " + start);
}

// a dedicated server's console ends the match (shield-client dedicated.cpp sets shield_dedicated_end): as the host's own end game does
DedicatedEndMatch()
{
    level endon(#"game_ended", #"end_game");

    while (true)
    {
        wait 0.5;
        if (!getDvarInt(#"shield_dedicated_end", 0))
            continue;

        setDvar(#"shield_dedicated_end", 0);
        ShieldLog("^3Dedicated: the match is ended from the server's console");
        [[ @globallogic<scripts\mp_common\gametypes\globallogic.gsc>::forceend ]]();
        return;
    }
}

// a dedicated server runs a match's end (final killcam, Best Play) without its frame cap, which sped them up (shield-client dedicated.cpp count_frame)
DedicatedUncapAtEnd()
{
    setDvar(#"shield_dedicated_uncapped", 0);
    level waittill(#"game_ended");
    setDvar(#"shield_dedicated_uncapped", 1);
}

// a dedicated server's bots through a multiplayer match (shield-client dedicated.cpp sets shield_dedicated_bots, also mid-match)
DedicatedBots()
{
    level endon(#"game_ended", #"end_game");

    while (true)
    {
        wait 2;

        bots = array();
        foreach (player in getplayers())
        {
            if (player isTestClient())
                bots[bots.size] = player;
        }

        wanted = DedicatedBotsWanted(DedicatedHumans());
        // bots join only while a round is played (the server's main thread hung 30 s at a round's end with this thread on)
        playing = isDefined(game.state) && game.state == "playing" && !(isDefined(level.gameended) && level.gameended);
        if (bots.size < wanted && playing)
        {
            ShieldLog("^3Dedicated: " + (wanted - bots.size) + " bot(s) in");
            for (i = bots.size; i < wanted; i++)
            {
                if (!isDefined([[ @bot<scripts\core_common\bots\bot.gsc>::add_bot ]]()))
                    break;
                waitframe(1);
            }
        }
        else if (bots.size > wanted)
        {
            ShieldLog("^3Dedicated: " + (bots.size - wanted) + " bot(s) out, room for players");
            for (i = 0; i < bots.size - wanted; i++)
                [[ @bot<scripts\core_common\bots\bot.gsc>::remove_bot ]](bots[i]);
        }
    }
}
