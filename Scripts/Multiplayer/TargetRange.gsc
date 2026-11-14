/*
    Target range (TargetRange.lua's button): a free for all on a small map, alone with bots that stand still, never
    shoot and come back where they stood when killed. No draft, no prematch countdown, no time or score limit; the
    player spawns at once with the last specialist and class used here (the first custom class the first time) and
    can change them from the pause menu. Each hit and kill goes to TargetRangeHud.lua (damage, distance, hits, time).
    Leave Match goes straight back to the menus.

    A target range match: gametype "targetrange" (shield-client's, in place of the unused warzone_deposit row) or dvar
    shield_targetrange 1 (an older client's launch through a plain dm custom game, cleared by the menu when the
    frontend loads again).
    Dvars: shield_targetrange_bots (6, at most 12), shield_targetrange_role / _class (the last picks, kept here).
*/

TargetRangeIsMatch()
{
    return getdvarstring(#"g_gametype") == "targetrange" || getdvarint(#"shield_targetrange", 0) == 1;
}

TargetRangeInit()
{
    if(!TargetRangeIsMatch())
    {
        // a match after a target range: the draft back (a freerun match sets its own pick)
        if(getdvarint(#"shield_targetrange_autoselect", 0) && !getdvarint(#"shield_freerun_match", 0))
         setdvar(#"auto_select_character", -1);
        setdvar(#"shield_targetrange_autoselect", 0);
        return;
    }

    level.shield_targetrange = 1;
    level.shield_targetrange_role = TargetRangeRole();

    // a set character turns the draft off (draft::is_enabled, read before the prematch)
    setdvar(#"auto_select_character", level.shield_targetrange_role);
    setdvar(#"shield_targetrange_autoselect", 1);

    // no bots of the lobby's settings, ours only
    setdvar(#"botfill", 0);
    setdvar(#"bot_maxfree", 0);
    setdvar(#"bot_maxallies", 0);
    setdvar(#"bot_maxaxis", 0);

    // bots without a brain (bot::update_loop takes manual control): they stand and never shoot
    level.var_fa5cacde = 1;

    // no time or score limit (updategametypedvars reads the settings again every pass)
    setgametypesetting(#"timelimit", 0);
    setgametypesetting(#"scorelimit", 0);
    // no announcer (the leader dialog's own switch; the detours below catch what skips it)
    setgametypesetting(#"allowannouncer", 0);

    callback::on_start_gametype(&TargetRangeStartGametype);
    callback::on_spawned(&TargetRangeOnSpawned);
    callback::on_player_damage(&TargetRangeOnDamage);
    callback::on_player_killed(&TargetRangeOnKilled);
    level thread TargetRangeKeepRules();

    ShieldLog("^2Target range: specialist " + level.shield_targetrange_role + ", class " + TargetRangeClass());
}

// the last specialist used here, else the first real one (Freerun.gsc's pick)
TargetRangeRole()
{
    role = getdvarint(#"shield_targetrange_role", -1);
    if(role >= 0 && [[ @player_role<scripts\core_common\player\player_role.gsc>::is_valid ]](role))
     return role;
    return FreerunCharacter();
}

// the last class used here ("custom" + it, 12-17 the default ones), else the first custom class
TargetRangeClass()
{
    index = getdvarint(#"shield_targetrange_class", 0);
    if(index < 0 || index > 17)
     return 0;
    return index;
}

// after the gametype's setup read its settings, before startgame: no countdown, respawns at once
TargetRangeStartGametype()
{
    level.prematchperiod = 0;
    level.playerrespawndelay = 0;
    level.waverespawndelay = 0;
    level.timelimit = 0;
    level.scorelimit = 0;
    level.allowannouncer = 0;
    // no battle chatter (kills, enemies spotted, abilities, the start conversation): the detours below catch the rest
    level.allowbattlechatter[#"bc"] = 0;
    level.allowspecialistdialog = 0;
    level.playstartconversation = 0;
}

TargetRangeNoLimit()
{
    return 0;
}

TargetRangeKeepRules()
{
    level endon(#"game_ended");
    while(true)
    {
        level.var_fa5cacde = 1;
        level.gettimelimit = &TargetRangeNoLimit;
        level.allowannouncer = 0;
        TargetRangeKickStrangers();
        wait(1);
    }
}

// bots the lobby added all the same
TargetRangeKickStrangers()
{
    if(!isdefined(level.shield_targetrange_placed))
     return;
    foreach(player in level.players)
    {
        if(isdefined(player) && isbot(player) && !isdefined(player.shield_targetrange_slot))
         [[ @bot<scripts\core_common\bots\bot.gsc>::remove_bot ]](player);
    }
}

/*
    The first class choice of a player: the role and class straight away (player_role::set runs menuclass with
    "custom" + pers loadoutindex, which spawns), no draft. The pause menu's choice (comingfrommenu) is the game's.
*/
detour globallogic_ui<scripts\mp_common\gametypes\globallogic_ui.gsc>::beginclasschoice(comingfrommenu)
{
    if(!isdefined(level.shield_targetrange) || isbot(self) || (isdefined(comingfrommenu) && comingfrommenu))
    {
        self [[ @globallogic_ui<scripts\mp_common\gametypes\globallogic_ui.gsc>::beginclasschoice ]](comingfrommenu);
        return;
    }
    self thread TargetRangeChooseClass();
}

TargetRangeChooseClass()
{
    self endon(#"disconnect");
    self.pers[#"loadoutindex"] = TargetRangeClass();
    role = level.shield_targetrange_role;
    if(isdefined(self.pers[#"characterindex"]) && [[ @player_role<scripts\core_common\player\player_role.gsc>::is_valid ]](self.pers[#"characterindex"]))
     role = self.pers[#"characterindex"];
    self [[ @player_role<scripts\core_common\player\player_role.gsc>::set ]](role);

    // (menuclass spawns, but not when the class was set already; spawnclient skips a second spawn)
    waitframe(1);
    if(self.sessionstate != "playing" && (game.state == "playing" || game.state == "pregame"))
     self thread [[ level.spawnclient ]]();
    level thread [[ @globallogic<scripts\mp_common\gametypes\globallogic.gsc>::updateteamstatus ]]();
}

TargetRangeOnSpawned()
{
    if(isbot(self))
    {
        if(!isdefined(self.shield_targetrange_slot))
         return;
        // back where it stood, facing the range's start
        slot = self.shield_targetrange_slot;
        self setorigin(slot.origin);
        self setplayerangles((0, slot.yaw, 0));
        self dontinterpolate();
        self.shield_targetrange_hits = 0;
        self.shield_targetrange_damage = 0;
        return;
    }

    // a map made for it: every spawn on its start (side by side for a party)
    start = [[ @struct<scripts\core_common\struct.gsc>::get ]]("shield_targetrange_start", "targetname");
    if(isdefined(start))
    {
        yaw = isdefined(start.angles) ? start.angles[1] : 0;
        side = anglestoright((0, yaw, 0)) * (48 * (self getentitynumber() % 8));
        self setorigin(start.origin + side);
        self setplayerangles((0, yaw, 0));
        self dontinterpolate();
    }

    // back from a specialist change: where the player stood
    if(isdefined(self.shield_targetrange_keep_origin))
    {
        self setorigin(self.shield_targetrange_keep_origin);
        self setplayerangles(self.shield_targetrange_keep_angles);
        self dontinterpolate();
        self.shield_targetrange_keep_origin = undefined;
        self.shield_targetrange_keep_angles = undefined;
    }

    if(isdefined(self.shield_targetrange_spawned))
     return;
    self.shield_targetrange_spawned = 1;

    // no intro music: the spawn's marked played (doinitialspawnmessaging), MP's silent state over the rest (as freerun)
    if(isdefined(self.pers[#"music"]))
     self.pers[#"music"].spawn = 1;
    self [[ @globallogic_audio<scripts\mp_common\gametypes\globallogic_audio.gsc>::set_music_on_player ]]("silent");

    if(self ishost())
     self thread TargetRangeRemember();

    if(!isdefined(level.shield_targetrange_placing))
    {
        level.shield_targetrange_placing = 1;
        level thread TargetRangePlaceBots(self.origin, self.angles[1]);
    }
}

// the host's picks, for the next target range
TargetRangeRemember()
{
    self endon(#"disconnect");
    while(true)
    {
        role = self.pers[#"characterindex"];
        if(isdefined(role) && role != getdvarint(#"shield_targetrange_role", -1))
         setdvar(#"shield_targetrange_role", role);
        index = self.pers[#"loadoutindex"];
        if(isdefined(index) && index != getdvarint(#"shield_targetrange_class", -1))
         setdvar(#"shield_targetrange_class", index);
        wait(1);
    }
}

// ---- the targets ----

TargetRangePlaceBots(origin, yaw)
{
    level endon(#"game_ended");
    count = getdvarint(#"shield_targetrange_bots", 6);
    if(count < 1)
     count = 1;
    if(count > 12)
     count = 12;

    slots = TargetRangeMapSlots();
    if(!slots.size)
     slots = TargetRangeSlots(origin, yaw, count);
    ShieldLog("^2Target range: " + slots.size + " targets");
    foreach(slot in slots)
    {
        bot = [[ @bot<scripts\core_common\bots\bot.gsc>::add_bot ]]();
        if(!isdefined(bot))
         break;
        bot.shield_targetrange_slot = slot;
        wait(0.2);
    }
    level.shield_targetrange_placed = 1;
}

// a map made for it places its targets: structs "shield_targetrange_target" (origin, angles: the way it faces), 16 at most
TargetRangeMapSlots()
{
    slots = [];
    // (not "structs": the compiler takes that name for a global)
    marks = [[ @struct<scripts\core_common\struct.gsc>::get_array ]]("shield_targetrange_target", "targetname");
    if(!isdefined(marks))
     return slots;
    foreach(mark in marks)
    {
        if(slots.size >= 16)
         break;
        slot = spawnstruct();
        slot.origin = mark.origin;
        slot.yaw = isdefined(mark.angles) ? mark.angles[1] : 0;
        slots[slots.size] = slot;
    }
    return slots;
}

/*
    Where the targets stand: a fan in front of the player's first spawn, nearer to farther, each on the navmesh and in
    sight of the player's eye (pulled closer until it is), not on top of another.
*/
TargetRangeSlots(origin, yaw, count)
{
    slots = [];
    distances = array(350, 600, 850, 1150, 1500, 1900, 2400);
    eye = origin + (0, 0, 60);

    for(i = 0; i < count; i++)
    {
        // alternate sides, wider for the nearer ones
        side = (i % 2 == 0) ? 1 : -1;
        spread = 6 + (i % 4) * 7;
        dir = anglestoforward((0, yaw + side * spread, 0));
        dist = distances[i % distances.size];

        found = undefined;
        for(scale = 1; scale > 0.25; scale -= 0.15)
        {
            point = getclosestpointonnavmesh(origin + dir * (dist * scale), 200);
            if(!isdefined(point))
             continue;
            if(!sighttracepassed(eye, point + (0, 0, 50), 0, undefined))
             continue;
            if(TargetRangeCrowded(point, slots))
             continue;
            found = point;
            break;
        }
        if(!isdefined(found))
         continue;

        slot = spawnstruct();
        slot.origin = found;
        // (no vectortoyaw in BO4: the yaw of vectortoangles)
        slot.yaw = vectortoangles(origin - found)[1];
        slots[slots.size] = slot;
    }

    // no navmesh in sight: straight ahead on the ground
    if(!slots.size)
    {
        dir = anglestoforward((0, yaw, 0));
        start = origin + dir * 300;
        trace = bullettrace(start + (0, 0, 100), start - (0, 0, 400), 0, undefined);
        slot = spawnstruct();
        slot.origin = trace[#"position"];
        slot.yaw = yaw + 180;
        slots[0] = slot;
    }
    return slots;
}

TargetRangeCrowded(point, slots)
{
    foreach(slot in slots)
    {
        if(distancesquared(point, slot.origin) < 96 * 96)
         return 1;
    }
    return 0;
}

// each hit on a target: its damage and where, to the shooter
TargetRangeOnDamage(params)
{
    if(!isbot(self) || !isdefined(self.shield_targetrange_slot) || !isdefined(params) || !isdefined(params.eattacker))
     return;
    attacker = params.eattacker;
    if(!isplayer(attacker) || isbot(attacker))
     return;

    damage = int(params.idamage);
    if(!isdefined(self.shield_targetrange_hits) || !self.shield_targetrange_hits)
    {
        self.shield_targetrange_hits = 0;
        self.shield_targetrange_damage = 0;
        self.shield_targetrange_first = gettime();
    }
    self.shield_targetrange_hits++;
    self.shield_targetrange_damage += damage;
    self.shield_targetrange_attacker = attacker;

    head = 0;
    if(isdefined(params.shitloc) && (params.shitloc == "head" || params.shitloc == "helmet"))
     head = 1;
    left = self.health - damage;
    if(left < 0)
     left = 0;
    meters = int(distance(attacker.origin, self.origin) * 0.0254);
    // TargetRangeHud.lua: the number by the crosshair and the panel
    attacker luinotifyevent(#"shield_targetrange_hit", 6, damage, left, self.shield_targetrange_hits, self.shield_targetrange_damage, head, meters);
}

// a target down: how many hits and how long it took; it comes back at once
TargetRangeOnKilled()
{
    if(!isbot(self) || !isdefined(self.shield_targetrange_slot))
     return;

    attacker = self.shield_targetrange_attacker;
    if(isdefined(attacker) && isplayer(attacker) && isdefined(self.shield_targetrange_hits) && self.shield_targetrange_hits)
    {
        ms = gettime() - self.shield_targetrange_first;
        attacker luinotifyevent(#"shield_targetrange_kill", 3, self.shield_targetrange_hits, ms, self.shield_targetrange_damage);
    }
    self.shield_targetrange_hits = 0;
    self.shield_targetrange_damage = 0;
    self.shield_targetrange_attacker = undefined;
    self thread TargetRangeRespawn();
}

TargetRangeRespawn()
{
    self endon(#"disconnect");
    wait(1);
    if(isdefined(self) && !isalive(self) && self.sessionstate != "playing")
     self thread [[ level.spawnclient ]]();
}

// Leave Match (the host's "endround", Freerun.gsc's on_menu_response detour): straight out, as freerun's
TargetRangeLeave()
{
    ShieldLog("^2Target range: leaving");
    changeadvertisedstatus(0);
    setmatchflag("game_ended", 1);
    game.state = "postgame";
    waitframe(1);
    exitlevel(0);
}

// ---- no announcer ----

// the announcer's queue per player: match start, leads, time, killstreaks of others (intro lines skip allowannouncer)
detour globallogic_audio<scripts\mp_common\gametypes\globallogic_audio.gsc>::leader_dialog_on_player(dialogkey, objectivekey, killstreakid, dialogbufferkey, introdialog)
{
    if(isdefined(level.shield_targetrange))
     return;
    self [[ @globallogic_audio<scripts\mp_common\gametypes\globallogic_audio.gsc>::leader_dialog_on_player ]](dialogkey, objectivekey, killstreakid, dialogbufferkey, introdialog);
}

// the player's own scorestreak lines (ready, inbound, destroyed)
detour globallogic_audio<scripts\mp_common\gametypes\globallogic_audio.gsc>::killstreak_dialog_on_player(dialogkey, killstreaktype, killstreakid, pilotindex, var_46bd7973, var_8a6b001a, weapon, priority)
{
    if(isdefined(level.shield_targetrange))
     return;
    self [[ @globallogic_audio<scripts\mp_common\gametypes\globallogic_audio.gsc>::killstreak_dialog_on_player ]](dialogkey, killstreaktype, killstreakid, pilotindex, var_46bd7973, var_8a6b001a, weapon, priority);
}

// team-wide 2d lines (winning, losing)
detour globallogic_audio<scripts\mp_common\gametypes\globallogic_audio.gsc>::play_2d_on_team(alias, team)
{
    if(isdefined(level.shield_targetrange))
     return;
    [[ @globallogic_audio<scripts\mp_common\gametypes\globallogic_audio.gsc>::play_2d_on_team ]](alias, team);
}

// ---- no battle chatter ----

// a character's lines by key (kill, enemy spotted, abilities; the mod's own characters' too: ShieldKillLine)
detour battlechatter<scripts\mp_common\gametypes\battlechatter.gsc>::play_dialog(dialogkey, dialogflags, dialogbuffer, enemy)
{
    if(isdefined(level.shield_targetrange))
     return;
    self [[ @battlechatter<scripts\mp_common\gametypes\battlechatter.gsc>::play_dialog ]](dialogkey, dialogflags, dialogbuffer, enemy);
}

// the same by alias
detour battlechatter<scripts\mp_common\gametypes\battlechatter.gsc>::function_a48c33ff(dialogalias, dialogflags, dialogbuffer, enemy)
{
    if(isdefined(level.shield_targetrange))
     return;
    self [[ @battlechatter<scripts\mp_common\gametypes\battlechatter.gsc>::function_a48c33ff ]](dialogalias, dialogflags, dialogbuffer, enemy);
}

// ---- class and specialist changes at any time ----

/*
    Every menu response of a target range player (Freerun.gsc's on_menu_response detour): a class picked applies at
    once (menuclass and loadout's supply station path, usingsupplystation); a new specialist keeps the stock respawn
    (globallogic_ui's suicide: the body only changes with a spawn), back on the same spot.
*/
TargetRangeMenuResponse(params)
{
    if(!isalive(self))
     return;
    self.usingsupplystation = 1;
    if(isdefined(params) && params.response === "change_specialist")
    {
        self.shield_targetrange_keep_origin = self.origin;
        self.shield_targetrange_keep_angles = self getplayerangles();
    }
}
