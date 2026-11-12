/*
    Freerun's client side (Freerun.gsc): its HUD fields, registered as the server does, and the race music, played
    here so it can be stopped (the server's stoplocalsound didn't stop a streamed alias on mp_bully).
    shield_freerun_music: 0 none, 1 the race, 2 a new best, 3 finished.
*/

FreerunRegisterFields()
{
    clientfield::register("toplayer", "shield_freerun_music", 1, 2, "int", &FreerunMusic, 0, 0);
    clientfield::register("clientuimodel", "hudItems.shieldFreerun.state", 1, 3, "int", undefined, 0, 0);
    clientfield::register("clientuimodel", "hudItems.shieldFreerun.count", 1, 3, "int", undefined, 0, 0);
    clientfield::register("clientuimodel", "hudItems.shieldFreerun.cp", 1, 7, "int", undefined, 0, 0);
    clientfield::register("clientuimodel", "hudItems.shieldFreerun.cps", 1, 7, "int", undefined, 0, 0);
    clientfield::register("clientuimodel", "hudItems.shieldFreerun.time", 1, 22, "int", undefined, 0, 0);
    clientfield::register("clientuimodel", "hudItems.shieldFreerun.best", 1, 22, "int", undefined, 0, 0);
    clientfield::register("clientuimodel", "hudItems.shieldFreerun.msg", 1, 4, "int", undefined, 0, 0);
    clientfield::register("clientuimodel", "hudItems.shieldFreerun.category", 1, 2, "int", undefined, 0, 0);
}

FreerunMusic(localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump)
{
    if(!isdefined(level.freerun_music))
     level.freerun_music = [];

    if(isdefined(level.freerun_music[localclientnum]))
    {
        stopsound(level.freerun_music[localclientnum]);
        level.freerun_music[localclientnum] = undefined;
    }

    if(newval == 1)
     level.freerun_music[localclientnum] = playsound(localclientnum, #"shield_freerun_music");
    else if(newval == 2)
     level.freerun_music[localclientnum] = playsound(localclientnum, #"shield_freerun_victory");
    else if(newval == 3)
     level.freerun_music[localclientnum] = playsound(localclientnum, #"shield_freerun_failure");
}

// IX's crowd in a zombies freerun match: its sounds (snd_crowd_react, which also plays a round of crowd oneshots on the
// first snapshot) and its reactions. Known from the gametype (set before the load: the server's dvar came too late for
// the first snapshot, so the crowd spoke at random)
FreerunCrowdOff()
{
    return getdvarstring(#"g_gametype") == "zfreerun" || getdvarint(#"shield_freerun_match", 0) == 1;
}

detour zm_towers<scripts\zm\zm_towers.csc>::snd_crowd_react(localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump)
{
    if(FreerunCrowdOff())
     return;
    [[ @zm_towers<scripts\zm\zm_towers.csc>::snd_crowd_react ]](localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump);
}

detour zm_towers<scripts\zm\zm_towers.csc>::crowd_react(localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump)
{
    if(FreerunCrowdOff())
     return;
    self [[ @zm_towers<scripts\zm\zm_towers.csc>::crowd_react ]](localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump);
}

detour zm_towers<scripts\zm\zm_towers.csc>::crowd_react_wave(localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump)
{
    if(FreerunCrowdOff())
     return;
    self [[ @zm_towers<scripts\zm\zm_towers.csc>::crowd_react_wave ]](localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump);
}

detour zm_towers<scripts\zm\zm_towers.csc>::crowd_react_boss(localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump)
{
    if(FreerunCrowdOff())
     return;
    self [[ @zm_towers<scripts\zm\zm_towers.csc>::crowd_react_boss ]](localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump);
}
