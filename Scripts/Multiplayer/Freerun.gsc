/*
    Freerun (shield-client freerun.cpp): a custom game of free for all started from the Freerun menu. ShieldFreerun()
    answers only then, with the run as JSON: the map, the movement category, the course (its start and checkpoints, the
    last one the finish) or none (free roam), and whether the course editor is on.

    The match: no time limit, no damage, the knife and the grapple, whose cooldown is the course's (or 3).
    A run: 3, 2, 1 at the start, the rings in order, the time at the finish (to the leaderboard by the client, the host's
    only), then the start again. Hold Use: back to the last checkpoint; hold it longer: the start. A fall far below the
    course puts the player back on the last checkpoint.

    The editor (free roam with the course's tools): tap Use to place the start, then each checkpoint where the player
    stands; tap Melee to take the last one off; hold Use to save the course (project-bo4/freerun/courses).

    The HUD (FreerunHud.lua) reads hudItems.shieldFreerun.*, registered for every MP match (the client's must match):
    state 0 off, 1 countdown, 2 running, 3 finished, 4 free roam, 5 editor; msg 1 new best, 2 finished, 3 back on the
    checkpoint, 4 restart, 5 start placed, 6 checkpoint placed, 7 point removed, 8 course saved, 9 save failed, 10 nothing
    to remove. Tunables: cooldown 3 s (no course's own), ring radius 160, a fall 1500 below the course, Use held 0.5 s
    (checkpoint) / 1.5 s (restart), held 2 s in the editor (save).
*/

// a freerun match's gametype (freerun.cpp's rows, known before the scripts on both sides): the fields only there,
// so other matches keep their clientfield bits
FreerunIsMatch()
{
    gametype = getdvarstring(#"g_gametype");
    return gametype == "freerun" || gametype == "zfreerun";
}

FreerunRegisterFields()
{
    if(!FreerunIsMatch())
     return;
    clientfield::register("toplayer", "shield_freerun_music", 1, 2, "int");
    clientfield::register_clientuimodel("hudItems.shieldFreerun.state", 1, 3, "int", 0);
    clientfield::register_clientuimodel("hudItems.shieldFreerun.count", 1, 3, "int", 0);
    clientfield::register_clientuimodel("hudItems.shieldFreerun.cp", 1, 7, "int", 0);
    clientfield::register_clientuimodel("hudItems.shieldFreerun.cps", 1, 7, "int", 0);
    clientfield::register_clientuimodel("hudItems.shieldFreerun.time", 1, 22, "int", 0);
    clientfield::register_clientuimodel("hudItems.shieldFreerun.best", 1, 22, "int", 0);
    clientfield::register_clientuimodel("hudItems.shieldFreerun.msg", 1, 4, "int", 0);
    clientfield::register_clientuimodel("hudItems.shieldFreerun.category", 1, 2, "int", 0);
}

FreerunInit()
{
    text = ShieldFreerun();
    if(!isdefined(text))
    {
        // a match after a freerun one: the draft back
        if(getdvarint(#"shield_freerun_autoselect", 0))
        {
            setdvar(#"auto_select_character", -1);
            setdvar(#"shield_freerun_autoselect", 0);
        }
        setdvar(#"shield_freerun_match", 0);
        return;
    }

    // (the HUD's Lua asks: the prematch countdown says RACE STARTING IN)
    setdvar(#"shield_freerun_match", 1);

    // No draft (it errored): a set character turns it off (draft::is_enabled, read before the prematch), and
    // disableclassselection has beginclasschoice give that role and the default class and spawn at once. The next
    // match without freerun puts the dvar back (shield_freerun_autoselect).
    if(SessionModeIsMultiplayerGame() && (getdvarint(#"auto_select_character", -1) < 0 || getdvarint(#"shield_freerun_autoselect", 0)))
    {
        setdvar(#"auto_select_character", FreerunCharacter());
        setdvar(#"shield_freerun_autoselect", 1);
    }

    info = ShieldParseJson(text);
    if(!isdefined(info))
     return;

    level.shield_freerun = info;
    level.shield_freerun_cooldown = 3;
    if(isdefined(info.cooldown) && info.cooldown > 0)
     level.shield_freerun_cooldown = info.cooldown;

    level.shield_freerun_rings = [];
    level.shield_freerun_floor = undefined;
    if(isdefined(info.checkpoints))
    {
        level.shield_freerun_start = FreerunPoint(info.start);
        foreach(cp in info.checkpoints)
         level.shield_freerun_rings[level.shield_freerun_rings.size] = FreerunPoint(cp);

        // a fall this far below the lowest point of the course
        low = level.shield_freerun_start.origin[2];
        foreach(ring in level.shield_freerun_rings)
        {
            if(ring.origin[2] < low)
             low = ring.origin[2];
        }
        level.shield_freerun_floor = low - 1500;
    }

    level.shield_freerun_models = [];
    foreach(part in array("ring", "chev1", "chev2", "chev3", "arrows", "final", "flash1", "flash2", "flags", "beam", "marker"))
     level.shield_freerun_models[part] = FreerunModel(part);

    // MP's grapple, or zombies' copy of it (BO4 Custom Maps' enh_grapple: in our maps' zones, none in the stock ones yet)
    level.shield_freerun_grapple = SessionModeIsZombiesGame() ? getweapon(#"enh_grapple") : getweapon(#"eq_grapple");
    level.shield_freerun_knife = getweapon(#"knife_loadout");
    // a gun in hand: with the knife alone there was no sprint
    level.shield_freerun_pistol = getweapon(#"pistol_standard_t8");

    // no time limit, nothing hurts, the loadout is ours (zombies: no zombies, its own loadout and the grapple)
    if(SessionModeIsZombiesGame())
    {
        level.shield_freerun_crowd_off = 1;
        // no zombies stats from a freerun match (zm_stats' own switch)
        level.zm_disable_recording_stats = 1;
    }
    level thread FreerunKeepRules();
    if(SessionModeIsZombiesGame())
    {
        level thread FreerunNoZombies();
        level thread FreerunSettingsWatch();
    }

    callback::on_spawned(&FreerunOnSpawned);

    ShieldLog("^2Freerun: " + (isdefined(info.course) ? info.course + ", " + level.shield_freerun_rings.size + " checkpoints" : "free roam") + (info.edit ? ", editor" : "") + ", category " + info.category);
}

// The first real specialist, as the draft's pick (assign_remaining_players): a "default" role (index 1 was one) has
// no sprint
FreerunCharacter()
{
    mode = currentsessionmode();
    count = getplayerroletemplatecount(mode);
    for(i = 0; i < count; i++)
    {
        fields = getplayerrolefields(i, mode);
        if(!isdefined(fields) || !(isdefined(fields.var_422e172f) && fields.var_422e172f))
         continue;
        if(!([[ @player_role<scripts\core_common\player\player_role.gsc>::is_valid ]](i)))
         continue;
        if([[ @player_role<scripts\core_common\player\player_role.gsc>::get_category_for_index ]](i) == "default")
         continue;
        ShieldLog("^2Freerun: specialist " + i);
        return i;
    }
    return 1;
}

// a course point as the client sends it: origin [x, y, z], yaw, radius
FreerunPoint(p)
{
    s = spawnstruct();
    s.origin = (p.origin[0], p.origin[1], p.origin[2]);
    s.yaw = isdefined(p.yaw) ? p.yaw : 0;
    s.radius = isdefined(p.radius) ? p.radius : 160;
    return s;
}

// the support zone's ring models (shield_freerun_<part>), a stock flag pole when it has none
FreerunModel(part)
{
    name = "shield_freerun_" + part;
    if(ShieldPrecacheModel(name))
     return name;
    return "p8_mp_flag_pole_1";
}

FreerunNoLimit()
{
    return 0;
}

// the gametype's setup (globallogic) sets these after the support script starts: put ours back over them
FreerunKeepRules()
{
    while(true)
    {
        if(isdefined(level.callbackplayerdamage) && level.callbackplayerdamage != &FreerunPlayerDamage)
         level.callbackplayerdamage = &FreerunPlayerDamage;
        if(!SessionModeIsMultiplayerGame())
        {
            // zombies: no character lines (zm_audio create_and_play_dialog returns on it), no music states (round
            // music, IX's): sndmusicsystem_playstate returns on the override, what played already is flushed once
            level.var_d555ff19 = 1;
            level.musicsystemoverride = 1;
            // no announcer (sndannouncerplayvox exits on it: IX's crowd lines, power-ups)
            level.var_bec5bf67 = &FreerunNoAnnouncer;
            if(!isdefined(level.shield_freerun_music_flushed) && isdefined(level.musicsystem))
            {
                level.shield_freerun_music_flushed = 1;
                level [[ @zm_audio<scripts\zm_common\zm_audio.gsc>::sndmusicsystem_stopandflush ]]();
            }
            // what plays is the client's music state: the loading music stops only when a map state takes over (IX's first,
            // its crowd chant, looped on), "none" kept the loading music: support_zm's silent state instead
            if(level flag::exists("initial_blackscreen_passed") && level flag::get("initial_blackscreen_passed") && level.musicstate !== "shield_freerun_silent")
             [[ @music<scripts\core_common\music_shared.gsc>::setmusicstate ]]("shield_freerun_silent");
            wait(0.25);
            continue;
        }
        level.gettimelimit = &FreerunNoLimit;
        level.givecustomloadout = &FreerunLoadout;
        level.disableclassselection = 1;
        // no announcer (match start, leads, time warnings)
        level.allowannouncer = 0;
        if(isdefined(level.callbackplayerdamage) && level.callbackplayerdamage != &FreerunPlayerDamage)
         level.callbackplayerdamage = &FreerunPlayerDamage;
        wait(0.25);
    }
}

// zombies: no zombie spawns (the flag Trials hold them with) and none left standing
FreerunNoZombies()
{
    while(true)
    {
        if(level flag::exists("spawn_zombies") && level flag::get("spawn_zombies"))
         level flag::clear("spawn_zombies");
        foreach(ai in getaiteamarray(#"axis"))
        {
            if(isdefined(ai) && isalive(ai))
             ai kill();
        }
        wait(0.5);
    }
}

// (debug) zombies' gametype settings went undefined mid-match (pause, ~40 s in): the time they stop and come back
FreerunSettingsWatch()
{
    level endon(#"end_game");
    ShieldLog("^3Freerun settings: roundlimit min " + (isdefined(level.roundlimitmin) ? level.roundlimitmin : "undefined") + " max " + (isdefined(level.roundlimitmax) ? level.roundlimitmax : "undefined"));
    gone = 0;
    while(true)
    {
        roundlimit = getgametypesetting(#"roundlimit");
        friendlyfire = getgametypesetting(#"zmfriendlyfiretype");
        lost = !isdefined(roundlimit) || !isdefined(friendlyfire);
        if(lost != gone)
        {
            gone = lost;
            ShieldLog((lost ? "^1" : "^2") + "Freerun settings: " + (lost ? "gone" : "back") + " at " + gettime() + " (roundlimit " + (isdefined(roundlimit) ? roundlimit : "undefined") + ", friendlyfire " + (isdefined(friendlyfire) ? friendlyfire : "undefined") + ", g_gametype " + getdvarstring(#"g_gametype") + ")");
        }
        wait(0.5);
    }
}

FreerunNoAnnouncer(type)
{
    return 1;
}

FreerunPlayerDamage(einflictor, eattacker, idamage, idflags, smeansofdeath, weapon, vpoint, vdir, shitloc, vdamageorigin, psoffsettime, boneindex, vsurfacenormal)
{
    // a kill trigger (out of the map) puts the player back, nothing else hurts
    if(smeansofdeath == "MOD_TRIGGER_HURT" || smeansofdeath == "MOD_SUICIDE")
     self thread FreerunToCheckpoint();
}

FreerunLoadout()
{
    // sprint and slide are perks in BO4 (a class's defaults): a custom loadout gives them itself, as oic.gsc does
    self clearperks();
    foreach(perk in array("specialty_sprint", "specialty_slide", "specialty_fastmantle", "specialty_fastladderclimb", "specialty_fallheight"))
    {
        if(!self hasperk(perk))
         self setperk(perk);
    }

    self takeallweapons();
    self giveweapon(level.shield_freerun_knife);
    spawn_weapon = level.shield_freerun_knife;
    if(level.shield_freerun_pistol != level.weaponnone)
    {
        self giveweapon(level.shield_freerun_pistol);
        self givemaxammo(level.shield_freerun_pistol);
        spawn_weapon = level.shield_freerun_pistol;
    }
    self setspawnweapon(spawn_weapon);
    if(level.shield_freerun_grapple != level.weaponnone)
    {
        self giveweapon(level.shield_freerun_grapple);
        self setweaponammoclip(level.shield_freerun_grapple, self getweaponammoclipsize(level.shield_freerun_grapple));
        slot = self gadgetgetslot(level.shield_freerun_grapple);
        if(slot >= 0)
         self gadgetpowerset(slot, 100);
    }
    return spawn_weapon;
}

FreerunOnSpawned()
{
    self endon(#"disconnect");

    self clientfield::set_player_uimodel("hudItems.shieldFreerun.category", level.shield_freerun.category);
    self clientfield::set_player_uimodel("hudItems.shieldFreerun.cps", level.shield_freerun_rings.size);

    // a gun in hand (no sprint without one); zombies: its loadout, the grapple added, nothing hurts
    if(SessionModeIsMultiplayerGame())
     self thread FreerunHands();
    else
     self thread FreerunZombiesLoadout();

    if(!isdefined(self.shield_freerun_threads))
    {
        self.shield_freerun_threads = 1;
        // no match music: the spawn's skipped (doinitialspawnmessaging), MP's silent state for the rest
        if(SessionModeIsMultiplayerGame())
        {
            if(isdefined(self.pers[#"music"]))
             self.pers[#"music"].spawn = 1;
            self [[ @globallogic_audio<scripts\mp_common\gametypes\globallogic_audio.gsc>::set_music_on_player ]]("silent");
        }
        self thread FreerunGrappleCooldown();
        if(level.shield_freerun.edit)
         self thread FreerunEditor();
        else if(level.shield_freerun_rings.size)
         self thread FreerunCourse();
        else
         self clientfield::set_player_uimodel("hudItems.shieldFreerun.state", 4);
    }
    else if(isdefined(self.shield_freerun_next) && !level.shield_freerun.edit)
    {
        // a respawn in a run: on the last checkpoint
        self thread FreerunToCheckpoint();
    }
}

// every door, airlock and debris of the map open, as bought by this player (zm_blockers: a forced "trigger")
FreerunOpenDoors(player)
{
    if(isdefined(level.shield_freerun_doors))
     return;
    level.shield_freerun_doors = 1;
    count = 0;
    foreach(name in array("zombie_door", "zombie_airlock_buy", "zombie_debris"))
    {
        foreach(door in getentarray(name, "targetname"))
        {
            if(!isdefined(door))
             continue;
            door notify(#"trigger", {#is_forced:1, #activator:player});
            count++;
            waitframe(1);
        }
    }
    ShieldLog("^2Freerun: " + count + " doors opened");
}

FreerunZombiesLoadout()
{
    self endon(#"disconnect", #"death");
    wait(0.5);
    level thread FreerunOpenDoors(self);
    self enableinvulnerability();
    w = level.shield_freerun_grapple;
    if(w == level.weaponnone)
    {
        ShieldLog("^1Freerun: zombies loadout, no grapple weapon");
        return;
    }
    // the grapple as the lethal grenade (as zm_park): the stock one taken, the map's start loadout (IX's intro) gives
    // the grapple then; kept so while alive
    logged = 0;
    while(true)
    {
        lethal = self [[ @zm_loadout<scripts\zm_common\zm_loadout.gsc>::get_player_lethal_grenade ]]();
        if(isdefined(lethal) && lethal != level.weaponnone && lethal != w && self hasweapon(lethal))
         self takeweapon(lethal);
        if(lethal !== w)
         self [[ @zm_loadout<scripts\zm_common\zm_loadout.gsc>::set_player_lethal_grenade ]](w);
        if(!self hasweapon(w))
        {
            self giveweapon(w);
            self setweaponammoclip(w, self getweaponammoclipsize(w));
            slot = self gadgetgetslot(w);
            if(slot >= 0)
             self gadgetpowerreset(slot, 1);
            ShieldLog("^2Freerun: zombies grapple given, slot " + slot);
        }
        if(!logged)
        {
            logged = 1;
            ShieldLog("^2Freerun: zombies loadout, grapple held " + self hasweapon(w));
        }
        wait(1);
    }
}

FreerunHands()
{
    self endon(#"disconnect", #"death");
    wait(0.5);
    w = level.shield_freerun_pistol;
    if(w != level.weaponnone && self getcurrentweapon() != w)
    {
        if(!self hasweapon(w))
         self giveweapon(w);
        self switchtoweaponimmediate(w);
    }
    w_now = self getcurrentweapon();
    ShieldLog("^2Freerun: pistol in hand " + (w_now == w));
}

// ---- the grapple's cooldown: counted from the end of a pull, the gadget's bar shows it filling ----

FreerunGrappleCooldown()
{
    self endon(#"disconnect");

    w = level.shield_freerun_grapple;
    if(w == level.weaponnone)
     return;

    grappling = 0;
    ready_at = 0;
    while(true)
    {
        waitframe(1);
        if(!isalive(self) || !self hasweapon(w))
         continue;

        slot = self gadgetgetslot(w);
        now = self isgrappling();
        if(grappling && !now)
         ready_at = gettime() + int(level.shield_freerun_cooldown * 1000);
        grappling = now;

        if(grappling)
         continue;

        left = ready_at - gettime();
        if(left > 0)
        {
            self setweaponammoclip(w, 0);
            if(slot >= 0)
             self gadgetpowerset(slot, 100 - 100 * left / (level.shield_freerun_cooldown * 1000));
        }
        else
        {
            clip = self getweaponammoclipsize(w);
            if(self getweaponammoclip(w) < clip)
             self setweaponammoclip(w, clip);
            if(slot >= 0 && self gadgetpowerget(slot) < 100)
             self gadgetpowerset(slot, 100);
        }
    }
}

// ---- a course ----

FreerunCourse()
{
    self endon(#"disconnect");

    self.shield_freerun_best = isdefined(level.shield_freerun.best) ? level.shield_freerun.best : 0;
    self clientfield::set_player_uimodel("hudItems.shieldFreerun.best", FreerunClamp(self.shield_freerun_best));
    self thread FreerunHoldWatch();
    self thread FreerunFallWatch();

    // zombies: the run once the blackscreen and the map's intro are over (gameplay_started; IX puts the players on its
    // own spawns in between), then its countdown keeps them on the start
    if(!SessionModeIsMultiplayerGame())
    {
        if(level flag::exists("gameplay_started"))
         level flag::wait_till("gameplay_started");
        wait(1);
        self thread FreerunLoop(0);
        return;
    }

    // on the start at once, its first ring in view, while the match counts down
    self.shield_freerun_next = 0;
    self FreerunPlace(level.shield_freerun_start);
    self FreerunShowRing();

    // the match's own countdown first: one countdown at a time
    while(isdefined(level.inprematchperiod) && level.inprematchperiod)
     wait(0.1);
    // (the game's countdown, matchstarttimer's detour below, was this run's: it goes at once)
    self thread FreerunLoop(SessionModeIsMultiplayerGame());
}

// runs one after another; a restart ends this thread and starts it again
FreerunLoop(go = 0)
{
    self endon(#"disconnect", #"freerun_restart");
    while(true)
    {
        self FreerunRun(go);
        go = 0;
        wait(4);
    }
}

// one run: the start, 3 2 1 (not after the game's countdown: go), the rings, the finish
FreerunRun(go = 0)
{
    self.shield_freerun_next = 0;
    self.shield_freerun_started = undefined;
    self FreerunPlace(level.shield_freerun_start);
    self FreerunShowRing();
    self clientfield::set_player_uimodel("hudItems.shieldFreerun.cp", 0);
    self clientfield::set_player_uimodel("hudItems.shieldFreerun.time", 0);
    self clientfield::set_player_uimodel("hudItems.shieldFreerun.msg", 0);
    self clientfield::set_player_uimodel("hudItems.shieldFreerun.state", 1);
    self clientfield::set_to_player("shield_freerun_music", 0);

    if(!go)
    {
        self freezecontrols(1);
        self FreerunHoldStart(0.5);
        foreach(n in array(3, 2, 1))
        {
            self clientfield::set_player_uimodel("hudItems.shieldFreerun.count", n);
            self playlocalsound(#"shield_freerun_countbeep");
            self FreerunHoldStart(0.75);
        }
        self clientfield::set_player_uimodel("hudItems.shieldFreerun.count", 4);
        self playlocalsound(#"shield_freerun_gobeep");
        self freezecontrols(0);
    }
    self.shield_freerun_started = gettime();
    self clientfield::set_player_uimodel("hudItems.shieldFreerun.state", 2);
    // (not once the match is being left: a run whose countdown ended after the leave started its music for the menus)
    if(!isdefined(level.shield_freerun_leaving))
     self clientfield::set_to_player("shield_freerun_music", 1);
    self thread FreerunClearCount();

    while(self.shield_freerun_next < level.shield_freerun_rings.size)
    {
        waitframe(1);
        if(!isalive(self))
         continue;

        ring = level.shield_freerun_rings[self.shield_freerun_next];
        if(distance(self.origin, ring.origin) > ring.radius)
         continue;

        self.shield_freerun_next++;
        self clientfield::set_player_uimodel("hudItems.shieldFreerun.cp", self.shield_freerun_next);
        if(self.shield_freerun_next < level.shield_freerun_rings.size)
        {
            self playlocalsound(#"shield_freerun_checkpoint");
            self FreerunShowRing();
        }
    }

    ms = gettime() - self.shield_freerun_started;
    self.shield_freerun_started = undefined;
    self FreerunHideRing();
    self clientfield::set_player_uimodel("hudItems.shieldFreerun.time", FreerunClamp(ms));
    self clientfield::set_player_uimodel("hudItems.shieldFreerun.state", 3);

    // the host's time is this game's: the client keeps the best and sends it to the leaderboard
    best = self.shield_freerun_best;
    if(self == util::gethostplayer())
     best = ShieldFreerunFinish(ms);

    record = !best || ms < best;
    if(record)
     self.shield_freerun_best = ms;
    self clientfield::set_player_uimodel("hudItems.shieldFreerun.best", FreerunClamp(self.shield_freerun_best));
    self thread FreerunMsg(record ? 1 : 2, 4);
    if(!isdefined(level.shield_freerun_leaving))
     self clientfield::set_to_player("shield_freerun_music", record ? 2 : 3);
}

// a text of the HUD for a while (the same text twice in a row shows again: 0 between)
FreerunMsg(msg, seconds = 2.5)
{
    self notify(#"freerun_msg");
    self endon(#"freerun_msg", #"disconnect");
    self clientfield::set_player_uimodel("hudItems.shieldFreerun.msg", 0);
    waitframe(1);
    self clientfield::set_player_uimodel("hudItems.shieldFreerun.msg", msg);
    wait(seconds);
    self clientfield::set_player_uimodel("hudItems.shieldFreerun.msg", 0);
}

// the countdown's wait, the player put back on the start whenever something moved them (a map's own spawn teleport)
FreerunHoldStart(seconds)
{
    for(t = 0; t < seconds; t += 0.05)
    {
        if(isalive(self) && distance(self.origin, level.shield_freerun_start.origin) > 48)
         self FreerunPlace(level.shield_freerun_start);
        wait(0.05);
    }
}

FreerunClearCount()
{
    self endon(#"disconnect");
    wait(1);
    self clientfield::set_player_uimodel("hudItems.shieldFreerun.count", 0);
}

// the time's 22 bits: some 70 minutes
FreerunClamp(ms)
{
    return ms > 4194303 ? 4194303 : int(ms);
}

FreerunPlace(point)
{
    self setorigin(point.origin);
    self setplayerangles((0, point.yaw, 0));
    self setvelocity((0, 0, 0));
}

// back on the last checkpoint passed (the start before the first), the clock running on
FreerunToCheckpoint()
{
    self endon(#"disconnect");
    waitframe(1);
    if(!isalive(self) || !isdefined(self.shield_freerun_next))
     return;

    point = self.shield_freerun_next > 0 ? level.shield_freerun_rings[self.shield_freerun_next - 1] : level.shield_freerun_start;
    self FreerunPlace(point);
    self thread FreerunMsg(3);
}

// Use held: the last checkpoint, held longer: the run again
FreerunHoldWatch()
{
    self endon(#"disconnect");
    while(true)
    {
        waitframe(1);
        if(!self usebuttonpressed())
         continue;

        t = gettime();
        back = 0;
        while(self usebuttonpressed())
        {
            held = (gettime() - t) / 1000;
            if(!back && held >= 0.5 && isdefined(self.shield_freerun_started))
            {
                back = 1;
                self thread FreerunToCheckpoint();
            }
            if(held >= 1.5)
            {
                self thread FreerunMsg(4);
                self notify(#"freerun_restart");
                self freezecontrols(0);
                self thread FreerunLoop();
                break;
            }
            waitframe(1);
        }
        while(self usebuttonpressed())
         waitframe(1);
    }
}

FreerunFallWatch()
{
    self endon(#"disconnect");
    while(true)
    {
        wait(0.25);
        if(isalive(self) && isdefined(level.shield_freerun_floor) && self.origin[2] < level.shield_freerun_floor)
         self thread FreerunToCheckpoint();
    }
}

// the next ring for this player only: a waypoint ring with its arrows, the finish's own with flags and its beam
FreerunShowRing()
{
    self FreerunHideRing();
    if(!isdefined(self.shield_freerun_next) || self.shield_freerun_next >= level.shield_freerun_rings.size)
     return;

    ring = level.shield_freerun_rings[self.shield_freerun_next];
    angles = (0, ring.yaw, 0);
    last = self.shield_freerun_next == level.shield_freerun_rings.size - 1;
    parts = last ? array("final", "flags", "beam") : array("ring", "arrows");
    // the parts that light in turn: Bully's chevrons in the ring, the finish's two inner rings
    blinks = last ? array("flash1", "flash2") : array("chev1", "chev2", "chev3");

    self.shield_freerun_ring_models = [];
    foreach(part in parts)
     self FreerunRingPart(part, ring.origin, angles);
    lit = [];
    foreach(part in blinks)
     lit[lit.size] = self FreerunRingPart(part, ring.origin, angles);
    self thread FreerunRingBlink(lit, last);

    // its waypoint on the HUD: the support zone's objective. Visible to all (a freerun match is one player's): visible to
    // one player only, no team saw it, and the HUD's waypoint hides on its team check (IsObjectiveVisibleForMyTeam)
    if(!isdefined(self.shield_freerun_obj))
    {
        self.shield_freerun_obj = [[ @gameobjects<scripts\core_common\gameobjects_shared.gsc>::get_next_obj_id ]]();
        objective_add(self.shield_freerun_obj, "active", ring.origin, #"shield_freerun_waypoint");
        objective_setvisibletoall(self.shield_freerun_obj);
        // its team mask: any team (gameobjects' visibleteam "any"); setvisibletoall is the players' alone
        function_da7940a3(self.shield_freerun_obj, 1);
    }
    objective_setposition(self.shield_freerun_obj, ring.origin + (0, 0, 40));
    objective_setstate(self.shield_freerun_obj, "active");
}

FreerunRingPart(part, origin, angles)
{
    model = spawn("script_model", origin);
    model.angles = angles;
    model setmodel(level.shield_freerun_models[part]);
    model hide();
    model showtoplayer(self);
    self.shield_freerun_ring_models[self.shield_freerun_ring_models.size] = model;
    return model;
}

/*
    Bully's RaceWaypoint: its three chevrons lit in turn on a 1 s loop (the first 0.25-0.75, the second 0.5-0.75, the
    third 0.75-0.9); RaceWaypointFinal: its inner rings lit the first half of each second. Shown only on a change.
*/
FreerunRingBlink(lit, last)
{
    self endon(#"disconnect", #"freerun_ring_changed");
    if(last)
     on = array(array(0, 0.5), array(0, 0.5));
    else
     on = array(array(0.25, 0.75), array(0.5, 0.75), array(0.75, 0.9));
    shown = [];
    t = 0;
    while(true)
    {
        foreach(i, model in lit)
        {
            if(!isdefined(model))
             continue;
            want = t >= on[i][0] && t < on[i][1];
            if(shown[i] === want)
             continue;
            shown[i] = want;
            if(want)
             model showtoplayer(self);
            else
             model hide();
        }
        wait(0.05);
        t += 0.05;
        if(t >= 1)
         t = 0;
    }
}

FreerunHideRing()
{
    self notify(#"freerun_ring_changed");
    if(isdefined(self.shield_freerun_obj))
     objective_setstate(self.shield_freerun_obj, "invisible");
    if(!isdefined(self.shield_freerun_ring_models))
     return;
    foreach(model in self.shield_freerun_ring_models)
    {
        if(isdefined(model))
         model delete();
    }
    self.shield_freerun_ring_models = undefined;
}

// ---- the editor ----

FreerunEditor()
{
    self endon(#"disconnect");

    self clientfield::set_player_uimodel("hudItems.shieldFreerun.state", 5);
    self.shield_freerun_points = [];
    self.shield_freerun_marks = [];
    self clientfield::set_player_uimodel("hudItems.shieldFreerun.cps", 0);

    while(true)
    {
        waitframe(1);
        if(!isalive(self))
         continue;

        if(self meleebuttonpressed())
        {
            self FreerunEditUndo();
            while(self meleebuttonpressed())
             waitframe(1);
            continue;
        }

        if(!self usebuttonpressed())
         continue;

        t = gettime();
        saved = 0;
        while(self usebuttonpressed())
        {
            if((gettime() - t) / 1000 >= 2)
            {
                saved = 1;
                self FreerunEditSave();
                break;
            }
            waitframe(1);
        }
        while(self usebuttonpressed())
         waitframe(1);

        if(!saved)
         self FreerunEditPlace();
    }
}

FreerunEditPlace()
{
    if(self.shield_freerun_points.size >= 64)
     return;

    point = spawnstruct();
    point.origin = self.origin + (0, 0, 2);
    angles = self getplayerangles();
    point.yaw = angles[1];
    point.radius = 160;
    self.shield_freerun_points[self.shield_freerun_points.size] = point;

    first = self.shield_freerun_points.size == 1;
    mark = spawn("script_model", point.origin);
    mark.angles = (0, point.yaw, 0);
    mark setmodel(level.shield_freerun_models[first ? "marker" : "ring"]);
    self.shield_freerun_marks[self.shield_freerun_marks.size] = mark;

    self clientfield::set_player_uimodel("hudItems.shieldFreerun.cps", self.shield_freerun_points.size - 1);
    self thread FreerunMsg(first ? 5 : 6);
    self playlocalsound(#"shield_freerun_checkpoint");
}

FreerunEditUndo()
{
    if(!self.shield_freerun_points.size)
    {
        self thread FreerunMsg(10);
        return;
    }

    last = self.shield_freerun_points.size - 1;
    if(isdefined(self.shield_freerun_marks[last]))
     self.shield_freerun_marks[last] delete();
    // (the last index undefined: the array is one shorter)
    self.shield_freerun_marks[last] = undefined;
    self.shield_freerun_points[last] = undefined;
    self clientfield::set_player_uimodel("hudItems.shieldFreerun.cps", self.shield_freerun_points.size > 0 ? self.shield_freerun_points.size - 1 : 0);
    self thread FreerunMsg(7);
}

// the start and at least one checkpoint (the last is the finish)
FreerunEditSave()
{
    if(self.shield_freerun_points.size < 2)
    {
        self thread FreerunMsg(9);
        return;
    }

    start = self.shield_freerun_points[0];
    ShieldFreerunEditStart(start.origin, float(start.yaw));
    for(i = 1; i < self.shield_freerun_points.size; i++)
    {
        p = self.shield_freerun_points[i];
        ShieldFreerunEditPoint(p.origin, float(p.yaw), float(p.radius));
    }

    id = ShieldFreerunEditSave(level.shield_freerun.map + " course");
    if(!isdefined(id) || id == "")
    {
        self thread FreerunMsg(9);
        return;
    }

    ShieldLog("^2Freerun: course saved as " + id);
    self thread FreerunMsg(8);
    self playlocalsound(#"shield_freerun_gobeep");
}

// ---- the game's countdown as the race's ----

/*
    The prematch countdown of a freerun match: the game's own (matchstarttimer), its ticks our beeps and its end the go
    beep, no music rising into it (spawnPreRise); its text says RACE STARTING IN (FreerunHud.lua). Other matches: the
    game's as it is.
*/
detour globallogic<scripts\mp_common\gametypes\globallogic.gsc>::matchstarttimer()
{
    if(!isdefined(level.shield_freerun))
    {
        [[ @globallogic<scripts\mp_common\gametypes\globallogic.gsc>::matchstarttimer ]]();
        return;
    }

    [[ @globallogic<scripts\mp_common\gametypes\globallogic.gsc>::mpintro_visionset_activate_func ]]();
    [[ @globallogic<scripts\mp_common\gametypes\globallogic.gsc>::waitforplayers ]]();
    counttime = int(level.prematchperiod);
    shown = counttime >= 2;
    level.var_5654073f = shown;
    level.var_fd167bf6 = gettime() + int(counttime * 1000);
    luinotifyevent(#"create_prematch_timer", 2, level.var_fd167bf6, shown);
    if(shown)
    {
        while(counttime > 0 && !level.gameended)
        {
            if(counttime == 2)
             [[ @globallogic<scripts\mp_common\gametypes\globallogic.gsc>::mpintro_visionset_deactivate_func ]]();
            counttime--;
            foreach(player in level.players)
             player playlocalsound(#"shield_freerun_countbeep");
            wait(1);
        }
    }
    else
     [[ @globallogic<scripts\mp_common\gametypes\globallogic.gsc>::mpintro_visionset_deactivate_func ]]();

    foreach(player in level.players)
     player playlocalsound(#"shield_freerun_gobeep");
    luinotifyevent(#"prematch_timer_ended", 1, shown);
}

// no "eliminate other players" (the gametype's objective hint) in a freerun match
detour globallogic<scripts\mp_common\gametypes\globallogic.gsc>::showobjectivenotificationuiforallplayers(missiontype, delay)
{
    if(isdefined(level.shield_freerun))
     return;
    [[ @globallogic<scripts\mp_common\gametypes\globallogic.gsc>::showobjectivenotificationuiforallplayers ]](missiontype, delay);
}

/*
    Leave Match as the host is the menu response "endround" (CoDShared.QuitGame): the match ends through its scoreboard
    and killcam. In a freerun match: the race music stopped on the clients (a streamed sound outlived the match), then
    straight out of the level, back to the menus (the client opens the Freerun menu there).
*/
detour menus<scripts\mp_common\gametypes\menus.gsc>::on_menu_response(params)
{
    if(isdefined(level.shield_freerun) && isdefined(params) && params.response === "endround")
    {
        if(!isdefined(level.shield_freerun_leaving))
        {
            level.shield_freerun_leaving = 1;
            level thread FreerunLeave();
        }
        return;
    }
    self [[ @menus<scripts\mp_common\gametypes\menus.gsc>::on_menu_response ]](params);
}

FreerunLeave()
{
    if(SessionModeIsZombiesGame())
    {
        level thread FreerunLeaveZombies();
        return;
    }
    foreach(player in level.players)
    {
        if(!isdefined(player))
         continue;
        player clientfield::set_to_player("shield_freerun_music", 0);
        player clientfield::set_player_uimodel("hudItems.shieldFreerun.state", 0);
    }
    ShieldLog("^2Freerun: leaving");
    // ended as the game's own end does (zombies' end_game): the lobby otherwise took the match as running and failed
    // "downloading game settings" in the menus
    changeadvertisedstatus(0);
    setmatchflag("game_ended", 1);
    game.state = "postgame";
    // (the music's stop reaching the client)
    wait(0.3);
    exitlevel(0);
}

/*
    Zombies' leave: its own end_game (an exitlevel of ours left the lobby "downloading game settings" in a loop), made
    quick and quiet: no outro music (FreerunMusicState), no intermission (FreerunIntermission), its 15 s wait 0.05.
*/
FreerunLeaveZombies()
{
    foreach(player in level.players)
    {
        if(!isdefined(player))
         continue;
        player clientfield::set_to_player("shield_freerun_music", 0);
        player clientfield::set_player_uimodel("hudItems.shieldFreerun.state", 0);
        player val::set(#"game_end", "freezecontrols");
    }
    ShieldLog("^2Freerun: leaving (zombies)");
    if(!isdefined(level.zombie_vars))
     level.zombie_vars = [];
    level.zombie_vars[#"zombie_intermission_time"] = 0.05;
    level.host_ended_game = 1;
    wait(0.3);
    level notify(#"end_game");
}

detour zm<scripts\zm_common\zm.gsc>::intermission()
{
    if(!isdefined(level.shield_freerun_leaving))
    {
        [[ @zm<scripts\zm_common\zm.gsc>::intermission ]]();
        return;
    }
    level.intermission = 1;
    level notify(#"intermission");
}

detour zm_audio<scripts\zm_common\zm_audio.gsc>::sndmusicsystem_playstate(state, var_ceca37b)
{
    if(FreerunCrowdOff())
     return;
    level [[ @zm_audio<scripts\zm_common\zm_audio.gsc>::sndmusicsystem_playstate ]](state, var_ceca37b);
}

// IX's crowd (zm_towers_crowd, its quest): its reactions, cheers, loops and crowd music are these fields, none set in
// a zombies freerun match (known from the gametype, so from the map's start)
FreerunCrowdOff()
{
    if(!isdefined(level.shield_freerun_crowd_off))
     level.shield_freerun_crowd_off = getdvarstring(#"g_gametype") == "zfreerun";
    return level.shield_freerun_crowd_off;
}

FreerunCrowdField(name)
{
    if(!isstring(name))
     return 0;
    if(!(name == "snd_crowd_react" || name == "crowd_react" || name == "crowd_react_boss" || name == "" + #"crowd_react_wave"))
     return 0;
    if(!isdefined(level.shield_freerun_crowd_logged))
     level.shield_freerun_crowd_logged = [];
    if(!isdefined(level.shield_freerun_crowd_logged[name]))
    {
        level.shield_freerun_crowd_logged[name] = 1;
        ShieldLog("^2Freerun: crowd field " + name + " blocked");
    }
    return 1;
}

detour clientfield<scripts\core_common\clientfield_shared.gsc>::set(str_field_name, n_value)
{
    if(FreerunCrowdOff() && FreerunCrowdField(str_field_name))
     return;
    self [[ @clientfield<scripts\core_common\clientfield_shared.gsc>::set ]](str_field_name, n_value);
}

detour clientfield<scripts\core_common\clientfield_shared.gsc>::set_to_player(str_field_name, n_value)
{
    if(FreerunCrowdOff() && FreerunCrowdField(str_field_name))
     return;
    self [[ @clientfield<scripts\core_common\clientfield_shared.gsc>::set_to_player ]](str_field_name, n_value);
}

// zombies' limits check (started when the game is paused): zfreerun's round and score limits clamp to an error
// ("unmatching types" in math::clamp, a cascade then a crash); no limits in a freerun match
detour globallogic<scripts\zm_common\gametypes\globallogic.gsc>::updategametypedvars()
{
    if(FreerunCrowdOff())
     return;
    [[ @globallogic<scripts\zm_common\gametypes\globallogic.gsc>::updategametypedvars ]]();
}

// its server settings loop (every 5 s) hit the same undefined settings mid-match
detour serversettings<scripts\zm_common\gametypes\serversettings.gsc>::updateserversettings()
{
    if(FreerunCrowdOff())
     return;
    [[ @serversettings<scripts\zm_common\gametypes\serversettings.gsc>::updateserversettings ]]();
}

/*
    Every zombies music state in a freerun match is our silent one (support_zm): a map's state for one player
    (setmusicstate(state, player)) skips level.musicstate, so IX's crowd intro sometimes came after ours and played.
*/
detour music<scripts\core_common\music_shared.gsc>::setmusicstate(state, player)
{
    if(FreerunCrowdOff())
     state = "shield_freerun_silent";
    [[ @music<scripts\core_common\music_shared.gsc>::setmusicstate ]](state, player);
}

// zombies' end of match stats: zfreerun has none (its gametype's stats: "unmatching types"), and no after action
// report (afteractionreportstats: the menus' summary of a match, whose round stats errored for zfreerun)
detour zm_stats<scripts\zm_common\zm_stats.gsc>::update_players_stats_at_match_end(players)
{
    if(FreerunCrowdOff())
     return;
    [[ @zm_stats<scripts\zm_common\zm_stats.gsc>::update_players_stats_at_match_end ]](players);
}

detour zm_stats<scripts\zm_common\zm_stats.gsc>::function_9daadcaa(stat_name, value)
{
    if(FreerunCrowdOff())
     return;
    self [[ @zm_stats<scripts\zm_common\zm_stats.gsc>::function_9daadcaa ]](stat_name, value);
}

// IX's crowd meter (its HUD): never opened, closed if it was before the gametype was known
detour zm_towers_crowd_meter<script_6334bf874cddcc13>::open(player, persistent)
{
    if(FreerunCrowdOff())
    {
        if(self [[ @zm_towers_crowd_meter<script_6334bf874cddcc13.gsc>::is_open ]](player))
         self [[ @zm_towers_crowd_meter<script_6334bf874cddcc13.gsc>::close ]](player);
        return;
    }
    self [[ @zm_towers_crowd_meter<script_6334bf874cddcc13.gsc>::open ]](player, persistent);
}

detour zm_towers_crowd_meter<script_6334bf874cddcc13>::set_visible(player, value)
{
    if(FreerunCrowdOff())
     value = 0;
    self [[ @zm_towers_crowd_meter<script_6334bf874cddcc13.gsc>::set_visible ]](player, value);
}

// the crowd's thrown gifts (their whoosh and landing sounds) and its lines
detour zm_towers_crowd<scripts\zm\zm_towers_crowd.gsc>::crowd_throw_item(var_2bd26cff)
{
    if(FreerunCrowdOff())
     return;
    self [[ @zm_towers_crowd<scripts\zm\zm_towers_crowd.gsc>::crowd_throw_item ]](var_2bd26cff);
}

detour zm_towers_crowd<scripts\zm\zm_towers_crowd.gsc>::function_1d9a9b89(str_category, b_announcer, var_ac39950d)
{
    if(FreerunCrowdOff())
     return;
    self [[ @zm_towers_crowd<scripts\zm\zm_towers_crowd.gsc>::function_1d9a9b89 ]](str_category, b_announcer, var_ac39950d);
}

// zombies' Leave Match (the host's "endround", zm_gametype's loop ended the game: its outro music and screens): out at
// once in a freerun match, as MP's
detour zm_gametype<scripts\zm_common\gametypes\zm_gametype.gsc>::menu_onmenuresponse()
{
    // (started at connect, maybe before FreerunInit: the gametype tells)
    if(!FreerunCrowdOff())
    {
        self [[ @zm_gametype<scripts\zm_common\gametypes\zm_gametype.gsc>::menu_onmenuresponse ]]();
        return;
    }

    self endon(#"disconnect");
    while(true)
    {
        waitresult = self waittill(#"menuresponse");
        if(waitresult.response == "back")
        {
            self closeingamemenu();
        }
        else if(waitresult.response == "endround" || waitresult.response == "endgame")
        {
            self closeingamemenu();
            if(!isdefined(level.shield_freerun_leaving))
            {
                level.shield_freerun_leaving = 1;
                level thread FreerunLeave();
            }
        }
    }
}
