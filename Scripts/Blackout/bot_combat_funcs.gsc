InsertionDisarmCombat()
{
    if (!isDefined(self.bo_insertion_active) || !self.bo_insertion_active)
        return;

    self clearentitytarget();

    if (isDefined(self.angles))
        self botsetlookangles((0, self.angles[1], 0));

    self botsetmovemagnitude(0.0);

    self bottapbutton(0);
    self bottapbutton(1);
    self bottapbutton(11);
}

ShouldSuppressCombatNow()
{
    if (!isAlive(self))
        return true;

    if (self isonground())
        return false;

    if (self isinvehicle())
        return true;

    if (isDefined(self.bo_insertion_active) && self.bo_insertion_active)
        return true;

    if (isDefined(self.bo_air_combat_suppress_until) && gettime() < self.bo_air_combat_suppress_until)
        return true;

    return false;
}

BO_SWIM_UP()
{
    return 67;
}

BO_SWIM_DOWN()
{
    return 68;
}

EnableBotSprint()
{
    if (!self isTestClient())
        return;

    ai::createinterfaceforentity(self);

    if (ai::hasaiattribute(self, #"sprint"))
        ai::setaiattribute(self, #"sprint", 1);

    if (isDefined(self.bo_sprint_thread))
        return;

    self.bo_sprint_thread = true;
    self thread SprintWhileMovingLoop();
}

CanEngageCombatNow()
{
    if (!isAlive(self) || !isDefined(self.origin))
        return false;

    if (self isinvehicle())
        return false;

    if (isDefined(self.bo_insertion_active) && self.bo_insertion_active)
        return false;

    if (self isonground())
        return IsLandedStable();

    return IsLandedStable();
}

BotSprintController()
{
    self endon("disconnect");
    self endon("death");
    level endon("game_ended");

    for (;;)
    {
        if (!CanEngageCombatNow())
        {
            wait 0.15;
            continue;
        }

        if (self attackbuttonpressed() || isDefined(self.bo_target))
        {
            wait 0.15;
            continue;
        }

        if (isDefined(self.bo_search_goal))
        {
            dSq = distanceSquared(self.origin, self.bo_search_goal);

            if (dSq > (650 * 650))
            {
                self bottapbutton(10);
            }
        }

        wait 0.15;
    }
}

SprintWhileMovingLoop()
{
    self endon("disconnect");
    self endon("death");
    level endon("game_ended");

    for (;;)
    {
        if (!isAlive(self) || !isDefined(self.origin))
        {
            wait 0.20;
            continue;
        }

        if (self isinvehicle() || (isDefined(self.bo_insertion_active) && self.bo_insertion_active))
        {
            self botreleasebutton(1);
            wait 0.10;
            continue;
        }

        movingFar = isDefined(self.bo_search_goal) && distanceSquared(self.origin, self.bo_search_goal) > (900 * 900);

        fighting = isDefined(self.bo_target) && isAlive(self.bo_target);

        // isonground: a ground trace ten times a second for every bot was too dear
        if (movingFar && !fighting && self isonground()){
            self botreleasebutton(9);
            self botreleasebutton(8);
            self botreleasebutton(39);
            self botpressbutton(1);
        }
        else { self botreleasebutton(1); }

        wait 0.10;
    }
}

GetAimPointForDifficulty(enemy)
{
    if (!isDefined(enemy) || !isDefined(enemy.origin))
        return undefined;

    diff = self GetBotDifficulty();

    z = 52;
    j = 8;

    if (diff == 2)
    {
        z = 58;
        j = 6;
    }
    else if (diff == 3)
    {
        z = 64;
        j = 4;
    }

    // a downed, prone or crouched body is lower: aim as high on it as on a standing one
    body = TargetBodyHeight(enemy);
    if (body < 56)
        z = int(body * z / 56);

    aim = enemy.origin;
    aim = (aim[0] + randomFloatRange(0.0 - j, j), aim[1] + randomFloatRange(0.0 - j, j), aim[2] + z + randomFloatRange(-2, 2));
    return aim;
}

// how high the body of a target is over its feet
TargetBodyHeight(ent)
{
    if (IsDownedLike(ent))
        return 14;

    if (isPlayer(ent))
    {
        stance = ent getstance();

        if (stance == "prone")
            return 14;

        if (stance == "crouch")
            return 36;
    }

    return 56;
}

DoSlideTap()
{
    if (!self isonground())
        return;

    self botreleasebutton(9);
    self botreleasebutton(8);
    self botreleasebutton(39);

    self botpressbutton(1);
    wait 0.05;

    self bottapbutton(39);
    wait 0.05;

    self botreleasebutton(1);
}

DifficultyCombatTactics(enemy)
{
    diff = self GetBotDifficulty();
    if (diff <= 1)
        return;

    if (!isDefined(enemy) || !isAlive(enemy) || !isDefined(enemy.origin))
        return;

    if (self isinvehicle())
        return;

    if (isDefined(self.bo_insertion_active) && self.bo_insertion_active)
        return;

    if (gettime() - self.bo_diff_last_action_time < 350)
        return;

    self.bo_diff_last_action_time = gettime();

    if (!self isonground())
        return;

    // rare hops and slides: every one threw the aim off
    if (CanSeeTarget(enemy))
    {
        if (diff == 2) hopChance = 3;
        else hopChance = 5;

        if (randomint(100) < hopChance)
            self bottapbutton(10);
    }

    if (diff == 2)
    {
        slideChance = 2;
        crouchChance = 10;
    }
    else
    {
        slideChance = 4;
        crouchChance = 12;
    }

    r = randomint(100);
    if (r < slideChance)
        self DoSlideTap();
    else if (r < slideChance + crouchChance)
        self bottapbutton(9);
}

ThreatScore(p)
{
    if (!isDefined(p) || !isAlive(p) || !isDefined(p.origin) || !isDefined(self.origin))
        return -999999999;

    if (isDefined(self.team) && isDefined(p.team))
    {
        if (!util::function_fbce7263(p.team, self.team))
            return -999999999;
    }

    if (isDefined(self.botteam) && isDefined(p.botteam) && p.botteam == self.botteam)
        return -999999999;

    dSq = distanceSquared(self.origin, p.origin);
    if (dSq > (7000 * 7000))
        return -999999999;

    fwd = anglesToForward((0, self.angles[1], 0));
    dir = vectorNormalize(p.origin - self.origin);
    frontDot = vectorDot(dir, fwd);

    // far off a bot cannot hit them anyway: no trace for those
    visible = false;
    if (dSq < (4000 * 4000))
        visible = CanSeeTarget(p);

    score = 0;
    score += visible ? 120000 : 0;
    score += int(52000000 / (dSq + 1));
    score += int(frontDot * 14000);

    if (!visible) score -= 25000;

    diff = self GetBotDifficulty();
    host = util::gethostplayerforbots();
    if (isDefined(host) && p == host)
    {
        if (diff == 2) score += 22000;
        else if (diff == 3) score += 52000;
    }

    return score;
}

PickBestThreatNow(maxDist)
{
    
    if (ShouldSuppressCombatNow())
        return undefined;
    if (!isDefined(maxDist))
        maxDist = 7000;

    if (!isDefined(self.origin) || !isDefined(self.angles))
        return undefined;

    maxSq = maxDist * maxDist;

    players = getplayers();
    best = undefined;
    bestScore = -999999999;

    foreach (p in players)
    {
        if (!isDefined(p) || p == self || !isAlive(p) || !isDefined(p.origin))
            continue;

        dSq = distanceSquared(self.origin, p.origin);
        if (dSq > maxSq)
            continue;

        s = ThreatScore(p);
        if (s > bestScore)
        {
            bestScore = s;
            best = p;
        }
    }

    return best;
}

UpdateTargetSmart()
{
    if (!isDefined(self.bo_target))
        self.bo_target = undefined;

    if (isDefined(self.bo_target) && (!isAlive(self.bo_target) || !isDefined(self.bo_target.origin)))
    {
        self.bo_target = undefined;
        self.bo_target_lost_time = undefined;
    }

    best = PickBestThreatNow(7000);
    if (!isDefined(best))
        return;

    if (!isDefined(self.bo_target))
    {
        self.bo_target = best;
        self.bo_target_lost_time = undefined;
        return;
    }

    curScore = ThreatScore(self.bo_target);
    bestScore = ThreatScore(best);

    curVis = CanSeeTarget(self.bo_target);
    bestVis = CanSeeTarget(best);

    if (bestVis && !curVis)
    {
        self.bo_target = best;
        self.bo_target_lost_time = undefined;
        return;
    }

    if (bestScore > curScore + 18000)
    {
        self.bo_target = best;
        self.bo_target_lost_time = undefined;
        return;
    }
}

DoJuke(goal, strength)
{
    if (!isDefined(strength))
        strength = 1;

    if (!isDefined(self.origin) || !isDefined(self.angles))
        return;

    if (!isDefined(self.bo_last_juke_time))
        self.bo_last_juke_time = 0;

    if (gettime() - self.bo_last_juke_time < 900)
        return;

    self.bo_last_juke_time = gettime();

    fwd = anglesToForward((0, self.angles[1], 0));
    rx = 0.0 - fwd[1];
    ry = fwd[0];

    backDist = randomFloatRange(120, 200) * float(strength);
    back = (self.origin[0] - fwd[0] * backDist, self.origin[1] - fwd[1] * backDist, self.origin[2]);
    back = NavSnap(back);

    if (isDefined(back))
    {
        self ManualMovePoint(back);
        self botsetmovemagnitude(1.0);
        if (randomint(100) < 70) self bottapbutton(10);
        wait 0.08;
    }

    side = (randomint(2) == 0) ? 1 : -1;
    sideDist = randomFloatRange(320, 520) * float(side) * float(strength);

    step = (self.origin[0] + rx * sideDist, self.origin[1] + ry * sideDist, self.origin[2]);
    step = NavSnap(step);

    if (isDefined(step))
    {
        self ManualMovePoint(step);
        self botsetmovemagnitude(1.0);
        if (randomint(100) < 85) self bottapbutton(10);
        wait 0.12;
    }

    if (isDefined(goal))
    {
        newGoal = PickGoalNear(goal, 900 + (250 * strength));
        if (isDefined(newGoal))
        {
            self.bo_search_goal = newGoal;
            self ManualMovePoint(newGoal);
            self botsetmovemagnitude(1.0);
        }
    }

    self.bo_goal_last_progress_time = gettime();
    self.bo_goal_last_dist = 999999999;
}

SmartMoveTo(goal, isCombat, lookPos)
{
    if (!isDefined(goal))
        return false;

    goal = NavSnap(goal);
    if (!isDefined(goal))
        return false;

    self ManualMovePoint(goal);
    self botsetmovemagnitude(1.0);

    if (!isCombat && isDefined(self.origin))
    {
        dir = vectorNormalize(goal - self.origin);
        yaw = vectortoangles(dir)[1];
        self botsetmoveangles((0, yaw, 0));

        if (!isDefined(lookPos))
            self botsetlookangles((0, yaw, 0));
    }

    if (isDefined(lookPos))
        self botsetlookpoint(lookPos);
    else if (!isCombat && isDefined(self.angles))
        self botsetlookangles((0, self.angles[1], 0));

    if (!isDefined(self.bo_nav_goal_last) || distanceSquared(self.bo_nav_goal_last, goal) > (220 * 220))
    {
        self.bo_nav_goal_last = goal;
        self StartGoalProgress(goal, "bo_nav");
    }

    blocked = IsBlockedAheadWide(110);
    failing = GoalProgressFailing(goal, "bo_nav", isCombat ? 650 : 900, isCombat ? (120 * 120) : (160 * 160));

    if (blocked || failing)
    {
        fails = isDefined(self["bo_nav_fails"]) ? self["bo_nav_fails"] : 0;
        fails++;
        self["bo_nav_fails"] = fails;

        strength = 1;
        if (fails >= 2) strength = 2;
        if (fails >= 4) strength = 3;

        self DoJuke(goal, strength);
        return true;
    }

    self["bo_nav_fails"] = 0;

    return true;
}

GetEyePos(ent)
{
    if (!isDefined(ent) || !isDefined(ent.origin))
        return undefined;

    return (ent.origin[0], ent.origin[1], ent.origin[2] + 56);
}

CanSeeTarget(target)
{
    if (self isinvehicle())
        return false;
    if (isDefined(self.bo_insertion_active) && self.bo_insertion_active)
        return false;
    if (!isDefined(target) || !isAlive(target))
        return false;

    if (!isDefined(self.origin) || !isDefined(target.origin))
        return false;

    // one trace per target every 150 ms: a pass of the brain asks for the same one several times
    n = target getentitynumber();

    if (!isDefined(self.bo_sight_time))
    {
        self.bo_sight_time = [];
        self.bo_sight_seen = [];
    }

    if (isDefined(self.bo_sight_time[n]) && gettime() - self.bo_sight_time[n] < 150)
        return self.bo_sight_seen[n];

    start = GetEyePos(self);
    end = (target.origin[0], target.origin[1], target.origin[2] + TargetBodyHeight(target));

    seen = false;

    tr = bullettrace(start, end, 0, self);
    if (isDefined(tr))
    {
        if (isDefined(tr["entity"]) && tr["entity"] == target)
            seen = true;
        else if (isDefined(tr["fraction"]) && tr["fraction"] >= 0.98)
            seen = true;
    }

    self.bo_sight_time[n] = gettime();
    self.bo_sight_seen[n] = seen;

    return seen;
}

PickVisibleThreat()
{
    players = getplayers();

    if (!isDefined(self.origin) || !isDefined(self.angles))
        return undefined;

    fwd = anglesToForward((0, self.angles[1], 0));

    best = undefined;
    bestScore = -999999999;

    foreach (p in players)
    {
        if (!isDefined(p) || !isAlive(p) || p == self || !isDefined(p.origin))
            continue;

        if (isDefined(self.team) && isDefined(p.team))
        {
            if (!util::function_fbce7263(p.team, self.team))
                continue;
        }

        if (isDefined(self.botteam) && isDefined(p.botteam) && p.botteam == self.botteam)
            continue;

        if (!CanSeeTarget(p))
            continue;

        dSq = distanceSquared(self.origin, p.origin);
        if (dSq > (5200 * 5200))
            continue;

        dir = vectorNormalize(p.origin - self.origin);
        inFront = (vectorDot(dir, fwd) > 0.15);

        score = 0;
        score += inFront ? 14000 : 0;
        score += int(38000000 / (dSq + 1));

        if (score > bestScore)
        {
            bestScore = score;
            best = p;
        }
    }

    return best;
}

FindEnemy()
{
    if (self isinvehicle()) return undefined;

    // a sight trace to every player: once every 1.5 s, the answer kept between
    if (isDefined(self.bo_findenemy_until) && gettime() < self.bo_findenemy_until)
    {
        if (isDefined(self.bo_findenemy_last) && isAlive(self.bo_findenemy_last))
            return self.bo_findenemy_last;

        return undefined;
    }

    self.bo_findenemy_until = gettime() + 1500;
    self.bo_findenemy_last = self FindEnemyNow();

    return self.bo_findenemy_last;
}

FindEnemyNow()
{
    if (isDefined(self.bo_insertion_active) && self.bo_insertion_active)
        return undefined;
    players = getplayers();

    if (!isDefined(self.origin) || !isDefined(self.angles))
        return undefined;

    fwd = anglesToForward((0, self.angles[1], 0));

    best = undefined;
    bestScore = -999999999;

    foreach (p in players)
    {
        if (!isDefined(p) || !isAlive(p) || p == self || !isDefined(p.origin))
            continue;

        if (isDefined(self.team) && isDefined(p.team))
        {
            if (!util::function_fbce7263(p.team, self.team))
                continue;
        }

        if (isDefined(self.botteam) && isDefined(p.botteam) && p.botteam == self.botteam)
            continue;

        dSq = distanceSquared(self.origin, p.origin);
        if (dSq > (7000 * 7000))
            continue;

        dir = vectorNormalize(p.origin - self.origin);
        frontDot = vectorDot(dir, fwd);

        visible = CanSeeTarget(p);

        score = 0;
        score += visible ? 60000 : 0;
        score += int(52000000 / (dSq + 1));
        score += int(frontDot * 12000);

        if (score > bestScore)
        {
            bestScore = score;
            best = p;
        }
    }

    return best;
}

// the nearest AI of the map close by that the bot sees (the zombies of Alcatraz, on team world)
PickZombieThreat(maxDist)
{
    if (ShouldSuppressCombatNow() || !isDefined(self.origin))
        return undefined;

    team = isDefined(level.zombie_team) ? level.zombie_team : #"world";
    ai = getaiteamarray(team);

    if (!isDefined(ai) || ai.size <= 0)
        return undefined;

    maxSq = maxDist * maxDist;
    best = undefined;
    bestSq = maxSq;
    second = undefined;
    secondSq = maxSq;

    foreach (z in ai)
    {
        if (!isDefined(z) || !isAlive(z) || !isDefined(z.origin))
            continue;

        dSq = distanceSquared(self.origin, z.origin);

        if (dSq < bestSq)
        {
            second = best;
            secondSq = bestSq;
            best = z;
            bestSq = dSq;
        }
        else if (dSq < secondSq)
        {
            second = z;
            secondSq = dSq;
        }
    }

    // a sight trace for the two nearest only
    if (isDefined(best) && CanSeeTarget(best))
        return best;

    if (isDefined(second) && CanSeeTarget(second))
        return second;

    return undefined;
}

GetRandomAliveEnemyEntity()
{
    list = array();
    players = getplayers();

    foreach (p in players)
    {
        if (!isDefined(p) || !isAlive(p) || p == self || !isDefined(p.origin))
            continue;

        if (isDefined(self.team) && isDefined(p.team))
        {
            if (!util::function_fbce7263(p.team, self.team))
                continue;
        }

        if (isDefined(self.botteam) && isDefined(p.botteam) && p.botteam == self.botteam)
            continue;

        if (HasDeathCircle() && !IsPosInsideCircle(p.origin))
            continue;

        list[list.size] = p;
    }

    if (list.size <= 0)
        return undefined;

    return list[randomint(list.size)];
}

ScanLook()
{
    self endon("disconnect");
    self endon("death");
    level endon("game_ended");

    baseYaw = self.angles[1];

    self botsetlookangles((0, baseYaw + randomFloatRange(-80, 80), 0));
    wait 0.10;

    self botsetlookangles((0, baseYaw + randomFloatRange(-80, 80), 0));
    wait 0.10;

    self botsetlookangles((0, baseYaw, 0));
}

ShootBurst(enemy)
{
    if (self isinvehicle())
        return;

    if (isDefined(self.bo_insertion_active) && self.bo_insertion_active)
        return;

    if (isDefined(self.sessionstate) && self.sessionstate != "playing")
        return;
    if (!isDefined(enemy) || !isAlive(enemy) || !isDefined(enemy.origin))
        return;

    if (!HasGun())
        return;

    self SetBotEntityTarget(enemy);
    aimPt = self GetAimPointForDifficulty(enemy);
    if (isDefined(aimPt))
        self botsetlookpoint(aimPt);
    else
        self botsetlookpoint(enemy.origin);

    if (isDefined(self.origin))
    {
        dSq = distanceSquared(self.origin, enemy.origin);

    diff = self GetBotDifficulty();
    maxShoot = ShootRange(diff);

    if (dSq > (maxShoot * maxShoot))
    {
        self botsetmovemagnitude(1.0);
        return;
    }
    }

    // a pause between bursts, longer far away: every bot firing nonstop used up the sound voices of the game
    if (isDefined(self.bo_next_burst_time) && gettime() < self.bo_next_burst_time)
        return;

    // where a player hears it, a few bots fire at the same moment and the others wait their turn
    heard = self IsNearHumanPlayer(3500);

    if (heard && CountBotsFiring() >= 3)
    {
        self.bo_next_burst_time = gettime() + randomintRange(200, 500);
        return;
    }
    diff = self GetBotDifficulty();

    if (diff >= 2 && self isonground())
    {
        if (diff == 2) dsChance = 10;
        else dsChance = 18;

        if (randomint(100) < dsChance)
            self bottapbutton(8);
    }

    // standing still for the burst: moving spoiled the aim
    self botsetmovemagnitude(0.0);

    // 2 to 4 shots: aim down sights held, the trigger pulled every 0.12 s
    burstMs = 260;
    if (diff == 2)
        burstMs = 340;
    else if (diff == 3)
        burstMs = 420;

    // far from every player: longer and faster, a fight between two bots took ages
    step = 0.12;
    if (!heard)
    {
        burstMs = burstMs + 250;
        step = 0.08;
    }

    if (!isDefined(level.bo_fire_until))
        level.bo_fire_until = [];

    level.bo_fire_until[self getentitynumber()] = gettime() + burstMs;

    self botpressbutton(11);

    endTime = gettime() + burstMs;
    while (gettime() < endTime)
    {
        self bottapbutton(0);
        wait step;
    }

    self botreleasebutton(11);
    self botsetmovemagnitude(1.0);
    self.bo_last_burst_time = gettime();

    // the enemy may be gone after the burst (a zombie is deleted)
    dist = 1000;
    if (isDefined(enemy) && isDefined(enemy.origin) && isDefined(self.origin))
        dist = distance(self.origin, enemy.origin);

    if (heard)
        self.bo_next_burst_time = gettime() + 550 + int(dist * 0.3) + randomint(350);
    else
        self.bo_next_burst_time = gettime() + 200 + int(dist * 0.08) + randomint(150);
}

// a human player within that distance
IsNearHumanPlayer(dist)
{
    if (!isDefined(self.origin))
        return true;

    distSq = dist * dist;

    foreach (p in getplayers())
    {
        if (!isDefined(p) || isbot(p) || !isAlive(p) || !isDefined(p.origin))
            continue;

        if (distanceSquared(self.origin, p.origin) < distSq)
            return true;
    }

    return false;
}

// how far a bot shoots from
ShootRange(diff)
{
    if (diff == 3)
        return 2800;

    if (diff == 2)
        return 2500;

    return 2200;
}

// how many bots are in a burst right now
CountBotsFiring()
{
    if (!isDefined(level.bo_fire_until) || !isDefined(level.BotsInGame))
        return 0;

    now = gettime();
    count = 0;

    foreach (b in level.BotsInGame)
    {
        if (!isDefined(b) || b == self)
            continue;

        n = b getentitynumber();
        if (isDefined(level.bo_fire_until[n]) && level.bo_fire_until[n] > now)
            count++;
    }

    return count;
}

/*
    The entity target of the engine only for players. A zombie is deleted soon after it dies, and the
    engine aiming at a deleted one read its missing model: the crash of 2026-10-17 on the server thread.
*/
SetBotEntityTarget(enemy)
{
    if (isDefined(enemy) && isPlayer(enemy) && isAlive(enemy))
        self setentitytarget(enemy, 1);
    else
        self clearentitytarget();
}

IsDownedLike(ent)
{
    if (!isDefined(ent))
        return false;

    if (!isDefined(ent.origin))
        return false;

    if (!isAlive(ent))
        return false;

    if (isDefined(ent.laststand) && ent.laststand)
        return true;

    if (isDefined(ent.inlaststand) && ent.inlaststand)
        return true;

    if (isDefined(ent.isDown) && ent.isDown)
        return true;

    if (isDefined(ent.bo_is_downed) && ent.bo_is_downed)
        return true;

    if (isDefined(ent.sessionstate) && (ent.sessionstate == "down" || ent.sessionstate == "laststand"))
        return true;

    return false;
}

// the nearest downed teammate within 3000 that nobody is reviving
FindDownedTeammate()
{
    if (!isDefined(self.team) || !isDefined(self.origin))
        return undefined;

    best = undefined;
    bestSq = 3000 * 3000;

    foreach (p in getplayers(self.team))
    {
        if (!isDefined(p) || p == self || !isAlive(p) || !isDefined(p.origin) || !isDefined(p.revivetrigger))
            continue;

        if (isDefined(p.revivetrigger.beingrevived) && p.revivetrigger.beingrevived)
            continue;

        dSq = distanceSquared(self.origin, p.origin);
        if (dSq < bestSq)
        {
            best = p;
            bestSq = dSq;
        }
    }

    return best;
}

/*
    As the stock bots revive: into the revive trigger of the downed player, then looking at it with the
    use button held until the trigger is gone (revived) or the bot left it. 12 s to get there, 10 s for it.
*/
DoReviveTeammate(target)
{
    if (!isDefined(target))
        return;

    t0 = gettime();

    while (gettime() - t0 < 12000)
    {
        self.bo_brain_beat = gettime();

        if (!isAlive(self) || !isDefined(target) || !isAlive(target) || !isDefined(target.revivetrigger))
            return;

        if (self istouching(target.revivetrigger))
            break;

        self clearentitytarget();
        self BotMoveTo(target.origin, true);
        self botsetlookpoint(target.origin);

        wait 0.10;
    }

    if (!isDefined(target) || !isDefined(target.revivetrigger) || !self istouching(target.revivetrigger))
        return;

    t1 = gettime();
    self botsetmovemagnitude(0.0);
    self botpressbutton(3);

    while (gettime() - t1 < 10000)
    {
        self.bo_brain_beat = gettime();

        if (!isAlive(self) || !isDefined(target) || !isAlive(target) || !isDefined(target.revivetrigger))
            break;

        if (!self istouching(target.revivetrigger))
            break;

        self botsetlookpoint(target.revivetrigger.origin);
        waitframe(1);
    }

    self botreleasebutton(3);
    self botsetmovemagnitude(1.0);
}

BotHoldButton(button, holdTime)
{
    endT = gettime() + int(holdTime * 1000);
    while (gettime() < endT)
    {
        self bottapbutton(button);
        wait 0.05;
    }
}