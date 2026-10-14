/*
    The skill of the bots in multiplayer, as the "Bot Settings" of the Shield options picked it.

    The game has four difficulties that differ little: all of them aim perfectly and see as far, they
    only turn a bit faster and miss a bit less. Here five levels are laid over whatever the game picked:

        shield_bot_skill       0 the game's own, 1 recruit, 2 regular, 3 hardened, 4 veteran, 5 ruthless
        shield_bot_aim         0 by the skill, 1 to 5: how exact and how fast they aim. 5 locks on and fires.
        shield_bot_reaction    0 by the skill, 1 to 5: how soon they do something else, and fire
        shield_bot_awareness   0 by the skill, 1 to 5: how wide they see and how close they notice
        shield_bot_headshots   0 by the skill, 1 to 5: how often they go for the head
        shield_bot_objectives  1: an objective plan for every variant of an objective mode, and a bot
                               that does not get to the objective by it is sent there

    A bot keeps its settings in a bundle the game reads all the time (self.bot.tacbundle), and some of
    them the engine holds for the bot itself. Both are written, and written again every second: the
    game puts its own back whenever a bot changes bundle.
*/

BotSkillInit()
{
    level.shield_bot_skill = BotSkillDvar(#"shield_bot_skill");
    level.shield_bot_aim = BotSkillPick(BotSkillDvar(#"shield_bot_aim"));
    level.shield_bot_reaction = BotSkillPick(BotSkillDvar(#"shield_bot_reaction"));
    level.shield_bot_awareness = BotSkillPick(BotSkillDvar(#"shield_bot_awareness"));
    level.shield_bot_headshots = BotSkillPick(BotSkillDvar(#"shield_bot_headshots"));
    level.shield_bot_objectives = getDvarInt(#"shield_bot_objectives", 1);

    level.shield_bot_active = level.shield_bot_aim > 0 || level.shield_bot_reaction > 0 || level.shield_bot_awareness > 0 || level.shield_bot_headshots > 0;

    ShieldLog("^2Bot Skill -> skill " + level.shield_bot_skill + ", aim " + level.shield_bot_aim + ", reaction " + level.shield_bot_reaction
        + ", awareness " + level.shield_bot_awareness + ", headshots " + level.shield_bot_headshots + ", objectives " + level.shield_bot_objectives);

    if (!level.shield_bot_active && !level.shield_bot_objectives)
        return;

    // 1 to 5. What a bot misses by at the start of a fight, in units: the game has 160 down to 20
    level.shield_bot_inaccuracy = array(0, 220, 80, 45, 15, 0);
    // how fast it turns: the game has 0.6 to 2
    level.shield_bot_turn = array(0, 0.5, 0.8, 1.2, 2.5, 10);
    // and how fast that builds up, as a factor of the game's own
    level.shield_bot_turn_build = array(0, 1, 1, 1.5, 2, 8);

    // How long a bot stays with what it is doing before it thinks again, from and to, in seconds. The game
    // has 1 to 3: a bot that reloads or looks around does so that long with an enemy in front of it.
    level.shield_bot_think_min = array(0, 1.5, 1, 0.6, 0.3, 0.1);
    level.shield_bot_think_max = array(0, 3.5, 3, 1.8, 1, 0.3);
    // the wait of a sniper before the shot, from and to
    level.shield_bot_wait_min = array(0, 0.8, 0.5, 0.35, 0.2, 0);
    level.shield_bot_wait_max = array(0, 1.4, 1, 0.7, 0.45, 0.05);
    // how often there is no wait at all
    level.shield_bot_no_wait = array(0, 0, 0.2, 0.4, 0.6, 1);

    // the field of view, and with something else to do: the engine takes no more than half a turn
    level.shield_bot_fov = array(0, 100, 140, 160, 179, 180);
    level.shield_bot_fov_busy = array(0, 70, 90, 110, 140, 180);
    // An enemy this close is noticed whatever the bot looks at. Not far: a bot that notices one behind a
    // wall takes it for its enemy, and runs past the one in front of it.
    level.shield_bot_notice = array(0, 48, 128, 192, 320, 700);

    level.shield_bot_head = array(0, 0, 0.1, 0.25, 0.4, 0.6);

    callback::on_spawned(&BotSkillOnSpawned);
}

// a setting of the menu, kept to what it can be
BotSkillDvar(name)
{
    value = getDvarInt(name, 0);

    if (value < 0)
        return 0;
    if (value > 5)
        return 5;

    return value;
}

// one of the four, or what the skill says for it when it is left at "by the skill"
BotSkillPick(value)
{
    if (value > 0)
        return value;

    return level.shield_bot_skill;
}

// The difficulty of the game that goes with the skill, 0 to 3: it picks the bundle, and the plans of the
// bots read it. Without a skill of the mod it is the game's own setting.
BotSkillGameDifficulty()
{
    skill = BotSkillDvar(#"shield_bot_skill");

    if (skill == 0)
        return getdvarint(#"bot_difficulty", 1);

    difficulty = skill - 1;

    if (difficulty > 3)
        difficulty = 3;

    setdvar(#"bot_difficulty", difficulty);

    return difficulty;
}

BotSkillOnSpawned()
{
    self endon(#"disconnect", #"spawned_player");
    level endon(#"end_game", #"game_ended");

    if (!IsBot(self))
        return;

    if (level.shield_bot_objectives)
        self thread BotObjectivePush();

    if (!level.shield_bot_active)
        return;

    if (level.shield_bot_aim >= 5)
        self thread BotSkillLockOn();

    while (isalive(self))
    {
        self BotSkillApply();
        self BotSkillPerks();

        wait 1;
    }
}

BotSkillApply()
{
    // the game gives a bot its bundle on its first think
    if (!isdefined(self.bot) || !isdefined(self.bot.tacbundle))
        return;

    bundle = self.bot.tacbundle;

    aim = level.shield_bot_aim;

    if (aim > 0)
    {
        bundle.inaccuracy = level.shield_bot_inaccuracy[aim];
        bundle.movingads = aim > 1;

        self.perfectaim = 1;
        self.accuracy = 1;

        self botsetlooksensitivity(level.shield_bot_turn[aim], level.shield_bot_turn[aim]);
        // the game's own: 7.5 up and down, 15 to the sides
        self function_4f0b9564(7.5 * level.shield_bot_turn_build[aim], 15 * level.shield_bot_turn_build[aim]);
    }

    reaction = level.shield_bot_reaction;

    if (reaction > 0)
    {
        bundle.var_5eaa9e02 = level.shield_bot_think_min[reaction];
        bundle.var_bc0b2a06 = level.shield_bot_think_max[reaction];
        bundle.var_b9f05fc = level.shield_bot_wait_min[reaction];
        bundle.var_c850085f = level.shield_bot_wait_max[reaction];
        bundle.var_6ef48dfa = level.shield_bot_no_wait[reaction];
    }

    awareness = level.shield_bot_awareness;

    if (awareness > 0)
    {
        self.fovcosine = BotSkillFovCosine(level.shield_bot_fov[awareness]);
        self.fovcosinebusy = BotSkillFovCosine(level.shield_bot_fov_busy[awareness]);
        self.highlyawareradius = level.shield_bot_notice[awareness];
    }

    if (level.shield_bot_headshots > 0)
        bundle.headshotchance = level.shield_bot_head[level.shield_bot_headshots];
}

// A bot that reacts fast does not wait for its gun either: out of a sprint, into the sights, on a reload.
// Set every second: a loadout given after the spawn takes perks away.
BotSkillPerks()
{
    if (level.shield_bot_reaction < 4)
        return;

    self setperk("specialty_fastads");
    self setperk("specialty_fastreload");
    self setperk("specialty_sprintrecovery");
    self setperk("specialty_fastweaponswitch");

    if (level.shield_bot_reaction < 5)
        return;

    // fires out of a sprint
    self setperk("specialty_sprintfire");
    self setperk("specialty_sprintfirerecovery");
}

// The cosine the engine wants of a field of view: of half of it. Never under 0, which is half a turn:
// a negative one is a script error that ends the match.
BotSkillFovCosine(fov)
{
    if (fov >= 180)
        return 0;

    return cos(fov / 2);
}

BotSkillHeadChance()
{
    if (level.shield_bot_headshots > 0)
        return level.shield_bot_head[level.shield_bot_headshots];

    return 0.25;
}

// the other is someone this bot fights: alive, playing, and not of its team
BotSkillIsEnemy(other)
{
    if (!isdefined(other) || other == self || !isalive(other))
        return false;

    if (!isdefined(other.sessionstate) || other.sessionstate != "playing")
        return false;

    if (level.teambased && isdefined(other.team) && isdefined(self.team) && other.team == self.team)
        return false;

    return true;
}

// Where on an enemy this bot aims: the chest, or the head when it was picked for that enemy. The head only
// down the sights: from the hip and on the way into them the shots spread wider than a head, and all missed.
BotSkillAimPoint(enemy)
{
    point = undefined;

    if (isdefined(self.shield_lock_head) && self.shield_lock_head && self playerads() >= 1)
        point = enemy gettagorigin("j_head");
    else
        point = enemy gettagorigin("j_spineupper");

    if (!isdefined(point))
        point = enemy getcentroid();

    return point;
}

// the nearest enemy this bot has a clear line to, all around it, or nothing
BotSkillNearestVisible()
{
    eye = self geteye();
    best = undefined;
    bestDist = 0;

    foreach (player in getplayers())
    {
        if (!self BotSkillIsEnemy(player))
            continue;

        dist = distancesquared(self.origin, player.origin);

        // 4000 units: further than a fight goes
        if (dist > 16000000)
            continue;

        if (isdefined(best) && dist >= bestDist)
            continue;

        // as the game asks it: players do not block the line
        if (!sighttracepassed(eye, player getcentroid(), 0, self))
            continue;

        best = player;
        bestDist = dist;
    }

    return best;
}

/*
    Aim 5. The game picks one enemy for a bot and only fires at that one, once what the bot was doing is
    over: a bot ran into a player it was not after without a shot. Here the bot takes the nearest enemy
    it has a clear line to, whichever way it looks, is turned onto it every frame, and fires.
*/
BotSkillLockOn()
{
    self endon(#"disconnect", #"spawned_player", #"death");
    level endon(#"end_game", #"game_ended");

    target = undefined;
    nextLook = 0;

    while (true)
    {
        waitframe(1);

        // not while the game holds the bots still, before a round and after it
        if (!isdefined(self.bot) || self arecontrolsfrozen())
            continue;

        // who to shoot at is looked for a few times a second, not every frame
        if (gettime() >= nextLook)
        {
            nextLook = gettime() + 50;
            found = self BotSkillNearestVisible();

            if (!isdefined(found))
            {
                target = undefined;
                continue;
            }

            if (!isdefined(target) || target != found)
            {
                target = found;
                self.shield_lock_head = randomfloat(1) < BotSkillHeadChance();
            }
        }

        if (!isdefined(target) || !isalive(target))
        {
            target = undefined;
            continue;
        }

        point = self BotSkillAimPoint(target);

        self setplayerangles(vectortoangles(point - self geteye()));
        self botsetlookpoint(point);

        // Fire, as a player holds the button. Down the sights only from further away: up close that
        // takes longer than the fight, and the hip hits.
        if (distancesquared(self.origin, target.origin) > 360000)
            self bottapbutton(11);

        self bottapbutton(0);
    }
}

// the gametype is that mode: "dom", or a variant of it as the public playlists have them, "dom_bb"
BotGametypeIs(mode)
{
    if (level.gametype == mode)
        return true;

    return getsubstr(level.gametype, 0, mode.size + 1) == mode + "_";
}

/*
    The plan a team of bots plays by. The game picks it by the exact name of the gametype and knows the
    plain, the hardcore and the CWL ones: with any other variant of an objective mode (barebones, snipers
    only, and the like, which only the public playlists use) the bots got the plan of team deathmatch and
    left the objective alone.
*/
BotObjectiveCommander()
{
    if (isdefined(level.var_fa5cacde) && level.var_fa5cacde)
    {
        ShieldLog("^3Bot Plan -> none, the gametype settings turn it off");
        return;
    }

    if (!isdefined(level.gametype) || !isdefined(level.teams))
        return;

    // as the game picks it
    if (!getDvarInt(#"shield_bot_objectives", 1))
    {
        ShieldLog("^3Bot Plan -> the game's own for " + level.gametype);
        level thread [[ @bot<scripts\mp_common\bots\mp_bot.gsc>::init_strategic_command ]]();
        return;
    }

    plan = "tdm";

    if (BotGametypeIs("control"))
        plan = "control";
    else if (BotGametypeIs("dom"))
        plan = "dom";
    else if (BotGametypeIs("koth"))
        plan = "koth";
    else if (BotGametypeIs("sd"))
        plan = "sd";

    ShieldLog("^2Bot Plan -> " + plan + " for " + level.gametype);

    foreach (team in level.teams)
    {
        if (plan == "control")
            [[ @plannermpcontrolcommander<scripts\mp_common\ai\planner_mp_control_commander.gsc>::createcommander ]](team);
        else if (plan == "dom")
            [[ @plannermpdomcommander<scripts\mp_common\ai\planner_mp_dom_commander.gsc>::createcommander ]](team);
        else if (plan == "koth")
            [[ @plannermpkothcommander<scripts\mp_common\ai\planner_mp_koth_commander.gsc>::createcommander ]](team);
        else if (plan == "sd")
            [[ @plannermpsdcommander<scripts\mp_common\ai\planner_mp_sd_commander.gsc>::createcommander ]](team);
        else
            [[ @plannermptdmcommander<scripts\mp_common\ai\planner_mp_tdm_commander.gsc>::createcommander ]](team);
    }
}

// Where this bot's team plays for in this mode right now: the zones of control, the hardpoint, and of
// domination the flags the team does not hold, or all of them when it holds them all.
BotObjectivePoints()
{
    points = [];
    held = [];

    if (BotGametypeIs("control"))
    {
        if (isdefined(level.zones))
        {
            foreach (zone in level.zones)
            {
                if (isdefined(zone) && isdefined(zone.origin) && isdefined(zone.trigger) && zone.trigger istriggerenabled())
                    points[points.size] = zone.origin;
            }
        }
    }
    else if (BotGametypeIs("dom"))
    {
        if (isdefined(level.domflags))
        {
            foreach (flag in level.domflags)
            {
                if (!isdefined(flag) || !isdefined(flag.origin) || !isdefined(flag.trigger) || !flag.trigger istriggerenabled())
                    continue;

                owner = flag [[ @gameobjects<scripts\core_common\gameobjects_shared.gsc>::get_owner_team ]]();

                if (isdefined(owner) && isdefined(self.team) && owner == self.team)
                    held[held.size] = flag.origin;
                else
                    points[points.size] = flag.origin;
            }

            if (points.size == 0)
                points = held;
        }
    }
    else if (BotGametypeIs("koth"))
    {
        if (isdefined(level.zone) && isdefined(level.zone.origin))
            points[points.size] = level.zone.origin;
    }

    return points;
}

// how far this bot is from the nearest of those places
BotObjectiveDistance(points)
{
    nearest = -1;

    foreach (point in points)
    {
        dist = distance(self.origin, point);

        if (nearest < 0 || dist < nearest)
            nearest = dist;
    }

    return nearest;
}

/*
    The game's plan moves a squad of bots to the objective. When it does not (it did not in a public
    match of control, and the reason is not known), the bots roam as in team deathmatch. A bot that is
    not near an objective and has not come closer to one in four seconds is taken out of the plan and
    sent to one, and stays out of it for the match: the plan would send it elsewhere again.
*/
BotObjectivePush()
{
    self endon(#"disconnect", #"spawned_player", #"death");
    level endon(#"end_game", #"game_ended");

    // a bot sent before goes again at once, and is given less time to get on
    sent = isdefined(self.shield_objective_sent) && self.shield_objective_sent;
    sendNow = sent;
    patience = 4;

    if (sent)
    {
        patience = 2;
        wait 0.5;
    }
    else
    {
        wait 2;
    }

    lastDist = -1;
    stalled = 0;

    while (true)
    {
        points = self BotObjectivePoints();

        if (points.size == 0 || !isdefined(self.bot) || self arecontrolsfrozen())
        {
            lastDist = -1;
            stalled = 0;
            wait 2;
            continue;
        }

        dist = self BotObjectiveDistance(points);

        // at the objective: it holds it
        if (dist < 250)
        {
            lastDist = -1;
            stalled = 0;
            wait 2;
            continue;
        }

        // on its way, by the plan or by the last send
        if (lastDist < 0 || dist < lastDist - 150)
        {
            lastDist = dist;
            stalled = 0;
        }
        else
        {
            stalled += 2;
        }

        // no closer for too long: its objective is gone, or the plan does not take it there
        if (sendNow || stalled >= patience)
        {
            self BotObjectiveSend(points);
            sendNow = false;
            patience = 2;
            lastDist = -1;
            stalled = 0;
        }

        wait 2;
    }
}

// to one of the objectives: mostly the nearest, sometimes another, so that a team spreads over them
BotObjectiveSend(points)
{
    target = undefined;
    nearest = -1;

    foreach (point in points)
    {
        dist = distance(self.origin, point);

        if (nearest < 0 || dist < nearest)
        {
            nearest = dist;
            target = point;
        }
    }

    if (points.size > 1 && randomint(100) < 35)
        target = points[randomint(points.size)];

    if (!isdefined(target))
        return;

    navpoint = getclosestpointonnavmesh(target, 200);

    if (isdefined(navpoint))
        target = navpoint;

    if (!isdefined(self.shield_objective_sent) || !self.shield_objective_sent)
        ShieldLog("^3Bot Plan -> " + self.name + " was not getting to the objective, sent there");

    self.shield_objective_sent = true;

    // as the game's own debug commands move a bot: out of the plan, then the goal
    self ai::set_behavior_attribute("control", "autonomous");
    // into the objective, not to somewhere around it: the game's own 512 stops a bot short of a zone
    self.goalradius = 96;
    self setgoal(target);

    // where the game sends it again after a respawn
    self.bot.var_bd883a25 = target;
    self.bot.var_4e3a654 = 0;
}
