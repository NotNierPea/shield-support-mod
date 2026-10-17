IsBadAnchorEnt(ent)
{
    if (!isDefined(ent) || !isAlive(ent) || !isDefined(ent.origin))
        return true;

    if (IsActuallySwimmingOrWater(ent))
        return true;

    if (IsWaterNear(ent.origin, 650))
        return true;

    start = (ent.origin[0], ent.origin[1], ent.origin[2] + 60);
    end = (ent.origin[0], ent.origin[1], ent.origin[2] - 20000);
    tr = bullettrace(start, end, 0, ent);
    if (!isDefined(tr) || !isDefined(tr["position"]))
        return true;

    dz = abs(ent.origin[2] - tr["position"][2]);
    if (dz > 180)
        return true;

    return false;
}

IsBadLandCandidate(pos)
{
    if (!isDefined(pos))
        return true;

    // IsBadLandingPos looks for water 900 around already
    return IsBadLandingPos(pos);
}

IsActuallySwimmingOrWater(ent)
{
    if (!isDefined(ent)) ent = self;
    if (!isDefined(ent.origin)) return false;

    if (ent isplayerswimming())
        return true;

    // one trace: the ring of IsWaterNear around every bot twice a second was too dear
    return IsWaterAt(ent.origin);
}

PickNearestDryLandGoal(fromPos)
{
    if (!isDefined(fromPos))
        return undefined;

    land = FindNearestDryNavFrom(fromPos);
    land = FixBadSpawnLocation(land);

    if (isDefined(land) && !IsBadLandingPos(land) && !IsWaterNear(land, 520))
        return land;

    poi = PickClosestPOIInsideStorm(fromPos);
    poi = FixBadSpawnLocation(poi);

    if (isDefined(poi) && !IsBadLandingPos(poi) && !IsWaterNear(poi, 520))
        return poi;

    if (HasDeathCircle())
    {
        g = GetCircleSafeGoal();
        g = FixBadSpawnLocation(g);
        if (isDefined(g) && !IsBadLandingPos(g) && !IsWaterNear(g, 520))
            return g;

        c = FixBadSpawnLocation(level.deathcircle.origin);
        if (isDefined(c) && !IsBadLandingPos(c) && !IsWaterNear(c, 520))
            return c;
    }

    return undefined;
}

SwimToLand(dest, maxMs)
{
    self endon("disconnect");
    self endon("death");
    level endon("game_ended");

    // one swim at a time: a newer one replaces it
    self notify("bo_swim_to_land");
    self endon("bo_swim_to_land");

    if (!isDefined(maxMs))
        maxMs = 9000;

    if (!isDefined(dest))
        return false;

    t0 = gettime();

    for (;;)
    {
        if (!isAlive(self) || !isDefined(self.origin))
            return false;

        // the brain leaves the moving to this while it lasts
        self.bo_swim_until = gettime() + 600;

        if (!self isplayerswimming() && self isonground() && !IsWaterAt(self.origin))
            return true;

        if (gettime() - t0 > maxMs)
            return false;

        self clearentitytarget();
        self ManualMovePoint(dest);
        self botsetmovemagnitude(1.0);

        dir = vectorNormalize((dest[0] - self.origin[0], dest[1] - self.origin[1], 0));
        yaw = vectortoangles(dir)[1];

        self botsetmoveangles((0, yaw, 0));
        self botsetlookangles((-10, yaw, 0));

        // up when under the surface or out of air, as the stock bots do
        if (self isplayerunderwater() || (isDefined(self.drownstage) && self.drownstage != 0))
            self bottapbutton(BO_SWIM_UP());

        wait 0.10;
    }

    return false;
}

// the surface a trace hit is water
IsWaterTrace(tr)
{
    if (!isDefined(tr) || !isDefined(tr["surfacetype"]))
        return false;

    st = tr["surfacetype"];

    if (st == #"water" || st == #"water_shallow" || st == #"water_deep" || st == #"slime")
        return true;

    if (st == "water" || st == "water_shallow" || st == "water_deep" || st == "slime")
        return true;

    return false;
}

/*
    The nearest land around a swimmer: rings of 12 directions, nearest first. A trace down finds the
    ground there and whether it is water, the navmesh near it is the spot to swim to. No rule against
    water near it: every shore is near water.
*/
FindLandFromWater(pos)
{
    if (!isDefined(pos))
        return undefined;

    dists = array(500, 1100, 2000, 3500, 6000);
    tries = 0;

    foreach (d in dists)
    {
        for (i = 0; i < 12; i++)
        {
            tries++;
            if (tries % 12 == 0)
                waitframe(1);

            fwd = anglesToForward((0, (i * 30) + randomFloatRange(-10, 10), 0));
            p = (pos[0] + fwd[0] * d, pos[1] + fwd[1] * d, pos[2]);

            tr = bullettrace((p[0], p[1], p[2] + 3000), (p[0], p[1], p[2] - 3000), 0, self);
            if (!isDefined(tr) || !isDefined(tr["position"]) || !isDefined(tr["fraction"]) || tr["fraction"] >= 0.999)
                continue;

            if (IsWaterTrace(tr))
                continue;

            nav = getclosestpointonnavmesh(tr["position"], 300, 24);
            if (!isDefined(nav))
                continue;

            return (nav[0], nav[1], nav[2] + 10);
        }
    }

    return undefined;
}

SafeRandomFloatRange(a, b)
{
    if (!isDefined(a) || !isDefined(b))
        return 0;

    if (b <= a)
        return float(a);

    return randomFloatRange(a, b);
}

IsBlockedAheadWide(dist)
{
    if (!isDefined(dist))
        dist = 110;

    if (!isDefined(self.origin) || !isDefined(self.angles))
        return false;

    fwd = anglesToForward((0, self.angles[1], 0));
    rx = 0.0 - fwd[1];
    ry = fwd[0];

    lane = array((0,0,0), (rx * 22, ry * 22, 0), (rx * -22, ry * -22, 0));

    for (i = 0; i < lane.size; i++)
    {
        o = lane[i];

        start = (self.origin[0] + o[0], self.origin[1] + o[1], self.origin[2] + 56);
        end = (start[0] + fwd[0] * dist, start[1] + fwd[1] * dist, start[2]);

        tr = bullettrace(start, end, 0, self);
        if (isDefined(tr) && isDefined(tr["fraction"]) && tr["fraction"] < 0.82)
            return true;
    }

    start2 = (self.origin[0], self.origin[1], self.origin[2] + 18);
    end2   = (start2[0] + fwd[0] * dist, start2[1] + fwd[1] * dist, start2[2]);

    tr2 = bullettrace(start2, end2, 0, self);
    if (isDefined(tr2) && isDefined(tr2["fraction"]) && tr2["fraction"] < 0.82)
        return true;

    return false;
}

StartGoalProgress(goal, key)
{
    if (!isDefined(key)) key = "bo_prog";

    if (!isDefined(goal) || !isDefined(self.origin))
        return;

    self[key + "_goal"] = goal;
    self[key + "_dist"] = distanceSquared(self.origin, goal);
    self[key + "_time"] = gettime();
    self[key + "_fails"] = 0;

    if (!isDefined(self[key + "_lastPos"]))
        self[key + "_lastPos"] = self.origin;

    self[key + "_lastPosTime"] = gettime();
}

GoalProgressFailing(goal, key, graceMs, minImproveSq)
{
    if (!isDefined(key))
        key = "bo_prog";
    if (!isDefined(graceMs))
        graceMs = 900;
    if (!isDefined(minImproveSq))
        minImproveSq = 160 * 160;

    if (!isDefined(goal) || !isDefined(self.origin))
        return false;

    if (!isDefined(self[key + "_time"]))
        return true;

    g0 = self[key + "_goal"];
    if (!isDefined(g0) || distanceSquared(g0, goal) > (220 * 220))
    {
        self StartGoalProgress(goal, key);
        return false;
    }

    dt = gettime() - self[key + "_time"];
    if (dt < graceMs)
        return false;

    dNow = distanceSquared(self.origin, goal);
    dWas = self[key + "_dist"];

    improved = (dWas - dNow);

    movedSq = 0;
    if (isDefined(self[key + "_lastPos"]))
        movedSq = distanceSquared(self.origin, self[key + "_lastPos"]);

    if (gettime() - self[key + "_lastPosTime"] > 650)
    {
        self[key + "_lastPos"] = self.origin;
        self[key + "_lastPosTime"] = gettime();
    }

    if (improved < minImproveSq || movedSq < (28 * 28))
    {
        self[key + "_fails"]++;
        self[key + "_dist"] = dNow;
        self[key + "_time"] = gettime();
        return true;
    }

    self[key + "_fails"] = 0;
    self[key + "_dist"] = dNow;
    self[key + "_time"] = gettime();
    return false;
}

AllowHardTeleport()
{
    if (!isDefined(self.bo_hardtp_until))
        self.bo_hardtp_until = 0;

    if (gettime() > self.bo_hardtp_until)
        return false;

    return IsEmergencyBrokenPos();
}

IsEmergencyBrokenPos()
{
    if (!isDefined(self.origin))
        return true;

    if (self.origin[2] < -8000)
        return true;

    dz = GetDzToGroundSafe(self);
    if (dz >= 9000000)
        return true;

    return false;
}

ClampInt(val, lo, hi)
{
    if (!isDefined(val)) return int(lo);

    v = int(val);
    if (v < int(lo)) return int(lo);
    if (v > int(hi)) return int(hi);

    return v;
}

NoGroundAt(pos)
{
    if (!isDefined(pos))
        return true;

    start = (pos[0], pos[1], pos[2] + 128);
    end = (pos[0], pos[1], pos[2] - 20000);

    tr = bullettrace(start, end, 0, self);

    if (!isDefined(tr))
        return true;

    if (!isDefined(tr["fraction"]) || tr["fraction"] >= 0.999)
        return true;

    if (!isDefined(tr["position"]))
        return true;

    return false;
}

TryForceJumpOut()
{
    self BotHoldButton(3, 1.35);

    self bottapbutton(3);
    self bottapbutton(3);

    self bottapbutton(4);
    if (randomint(100) < 65) self bottapbutton(10);

    self bottapbutton(7);
    if (randomint(100) < 55) self bottapbutton(7);
}

WaterOrOutOfMapRescueLoop()
{
    self endon("disconnect");
    self endon("death");
    level endon("game_ended");

    self.bo_rescue_next_time = 0;
    self.bo_bad_water_since = 0;
    self.bo_bad_nonav_since = 0;
    self.bo_swim_land = undefined;

    if (!isDefined(self.bo_hardtp_until))
        self.bo_hardtp_until = 0;

    for (;;)
    {
        if (!isAlive(self) || !isDefined(self.origin))
        {
            wait 0.25;
            continue;
        }

        dzToGround = GetDzToGroundSafe(self);
        if (!IsLandedStable() && !self isplayerswimming() && (self isinvehicle() || dzToGround > 1400))
        {
            wait 0.25;
            continue;
        }

        if (gettime() < self.bo_rescue_next_time)
        {
            wait 0.20;
            continue;
        }

        self.bo_rescue_next_time = gettime() + 450;

        pos = self.origin;

        inWater = IsActuallySwimmingOrWater(self);
        nav = getclosestpointonnavmesh(pos, 256, 16);
        noNav = !isDefined(nav) && !IsSparseNavMap();

        if (inWater)
        {
            if (self.bo_bad_water_since == 0) self.bo_bad_water_since = gettime();
        }
        else
        {
            self.bo_bad_water_since = 0;
            self.bo_swim_land = undefined;
        }

        if (noNav && !inWater)
        {
            if (self.bo_bad_nonav_since == 0) self.bo_bad_nonav_since = gettime();
        }
        else self.bo_bad_nonav_since = 0;

        if (!inWater && !noNav)
        {
            wait 0.25;
            continue;
        }

        if (inWater)
        {
            // still in the water after 6 s: put on land, the one it swims to or the nearest found now
            if (gettime() - self.bo_bad_water_since > 6000 && !isDefined(self.bo_swim_land))
            {
                self.bo_swim_land = FindLandFromWater(pos);

                if (!isDefined(self.bo_swim_land))
                    self.bo_swim_land = FindNearestDryNavFrom(pos);
            }

            if (gettime() - self.bo_bad_water_since > 6000 && isDefined(self.bo_swim_land))
            {
                self setorigin(self.bo_swim_land);
                self.bo_bad_water_since = 0;
                self.bo_swim_land = undefined;
                self.bo_search_goal = undefined;
                self.bo_next_goal_time = 0;

                wait 0.50;
                continue;
            }

            // the way to land is looked for again every 2 s, not on every check
            if (!isDefined(self.bo_swim_replan_time) || gettime() >= self.bo_swim_replan_time)
            {
                self.bo_swim_replan_time = gettime() + 2000;

                dest = FindLandFromWater(pos);
                if (!isDefined(dest))
                    dest = PickNearestDryLandGoal(pos);

                if (isDefined(dest))
                {
                    self.bo_swim_land = dest;
                    self thread SwimToLand(dest, 8500);
                }
            }

            wait 0.25;
            continue;
        }

        land = FindNearestDryNavFrom(pos);
        land = FixBadSpawnLocation(land);

        if (isDefined(land) && !IsBadLandingPos(land) && !IsWaterNear(land, 320))
        {
            self clearentitytarget();
            self ManualMovePoint(land);
            self botsetmovemagnitude(1.0);

            wait 3.25;
        }

        badLong = (self.bo_bad_nonav_since != 0 && (gettime() - self.bo_bad_nonav_since) > 9000);

        if (badLong && AllowHardTeleport())
        {
            fallback = PickLocalEmergencyRescuePos(pos);

            if (isDefined(fallback))
            {
                self setorigin(fallback);

                self.bo_search_goal = PickGoalNear(fallback, 900);
                self.bo_next_goal_time = gettime() + randomintRange(2500, 4500);
                self.bo_goal_last_dist = 999999999;
                self.bo_goal_last_progress_time = gettime();

                self.bo_bad_nonav_since = 0;

                wait 0.25;
            }
        }

        wait 0.25;
    }
}

IsLandPlayable(pos)
{
    if (!isDefined(pos))
        return false;

    if (pos[2] < -2500)
        return false;

    nav = getclosestpointonnavmesh(pos, 512, 24);
    if (!isDefined(nav))
    {
        if (!IsSparseNavMap())
            return false;
        nav = TerrainSnap(pos);
    }

    gs = GroundSnap(nav);
    if (!isDefined(gs))
        return false;

    if (NoGroundAt(gs))
        return false;

    if (IsWaterAt(gs))
        return false;

    if (HasDeathCircle() && !IsPosInsideCircle(gs))
        return false;

    return true;
}

IsBadLandingPos(pos)
{
    if (!isDefined(pos))
        return true;

    if (pos[2] < -2500)
        return true;

    // the cheap test first: out of the circle needs no trace
    if (HasDeathCircle() && !IsPosInsideCircle(pos))
        return true;

    nav = getclosestpointonnavmesh(pos, 384, 24);
    if (!isDefined(nav))
    {
        // the big map has navmesh only around the zombie spots: open ground is fine there
        if (!IsSparseNavMap())
            return true;
        nav = TerrainSnap(pos);
    }

    gs = GroundSnap(nav);
    if (!isDefined(gs))
        return true;

    if (HasDeathCircle() && !IsPosInsideCircle(gs))
        return true;

    if (abs(gs[2] - nav[2]) > 900)
        return true;

    if (NoGroundAt(gs))
        return true;

    if (IsWaterAt(gs))
        return true;

    if (IsWaterNear(gs, 900))
        return true;

    return false;
}

FixBadSpawnLocation(desired)
{
    if (!isDefined(desired))
        return undefined;

    // a small circle has no room to search in: its middle it is
    if (HasDeathCircle() && level.deathcircle.radius < 1500)
        return CircleCenterGoal();

    if (HasDeathCircle())
    {
        c = IsEscapeMap() ? GetLandBiasedCircleCenter() : level.deathcircle.origin;
        if (!isDefined(c)) c = level.deathcircle.origin; r = level.deathcircle.radius;

        if (!IsPosInsideCircle(desired))
        {
            vx = desired[0] - c[0];
            vy = desired[1] - c[1];

            if (abs(vx) > 1 || abs(vy) > 1)
            {
                dir = vectorNormalize((vx, vy, 0));
                safeR = r - 900;

                if (safeR < 600) safeR = r * 0.60;
                if (safeR < 250) safeR = 250;

                desired = (c[0] + dir[0] * safeR, c[1] + dir[1] * safeR, c[2]);
            }
            else
            {
                desired = c;
            }
        }
    }

    base = NavSnap(desired);
    if (isDefined(base) && !IsBadLandCandidate(base))
        return base;

    // at most 32 tries around it, a frame between every 8 so many bots do not stall the server
    tries = 0;

    for (ring = 0; ring < 4; ring++)
    {
        minR = 250 + (ring * 560);
        maxR = 650 + (ring * 840);

        for (i = 0; i < 8; i++)
        {
            tries++;
            if (tries % 8 == 0)
                waitframe(1);

            ang = randomFloatRange(0, 360);
            rr = SafeRandomFloatRange(minR, maxR);
            fwd = anglesToForward((0, ang, 0));

            p = (desired[0] + fwd[0] * rr, desired[1] + fwd[1] * rr, desired[2]);
            p = NavSnap(p);

            if (!isDefined(p))
                continue;

            if (IsBadLandCandidate(p))
                continue;

            if (MinDistSqToOtherBots(p) < (850 * 850))
                continue;

            return p;
        }
    }

    if (HasDeathCircle())
    {
        c = level.deathcircle.origin;
        r = level.deathcircle.radius;

        minCircleR = 650;
        maxCircleR = r - 1100;

        if (maxCircleR > minCircleR)
        {
            for (k = 0; k < 12; k++)
            {
                if (k % 6 == 5)
                    waitframe(1);

                ang = randomFloatRange(0, 360);
                rr  = SafeRandomFloatRange(minCircleR, maxCircleR);
                fwd = anglesToForward((0, ang, 0));

                cand = (c[0] + fwd[0] * rr, c[1] + fwd[1] * rr, c[2]);
                cand = NavSnap(cand);

                if (!isDefined(cand))
                    continue;

                if (IsBadLandCandidate(cand))
                    continue;

                if (MinDistSqToOtherBots(cand) < (850 * 850))
                    continue;

                return cand;
            }
        }

        center = NavSnap(c);
        if (isDefined(center) && !IsBadLandCandidate(center))
            return center;
    }

    return undefined;
}

SpawnSanityRescueLoop()
{
    self endon("disconnect");
    self endon("death");
    level endon("game_ended");

    endTime = gettime() + 20000;

    if (!isDefined(self.bo_spawn_bad_since))
        self.bo_spawn_bad_since = 0;

    if (!isDefined(self.bo_nonav_since))
        self.bo_nonav_since = 0;

    if (!isDefined(self.bo_hardtp_until))
        self.bo_hardtp_until = 0;

    for (;;)
    {
        if (isDefined(self.bo_insertion_active) && self.bo_insertion_active)
        {
            wait 0.25;
            continue;
        }

        if (gettime() > endTime)
            return;

        if (!isAlive(self) || !isDefined(self.origin))
        {
            wait 0.25;
            continue;
        }

        dzToGround = GetDzToGroundSafe(self);
        if (!IsLandedStable() && (self isinvehicle() || dzToGround > 1800))
        {
            wait 0.25;
            continue;
        }

        nav = getclosestpointonnavmesh(self.origin, 256, 16);
        noNav = !isDefined(nav) && !IsSparseNavMap();

        if (noNav)
        {
            if (self.bo_nonav_since == 0)
                self.bo_nonav_since = gettime();
        }
        else
        {
            self.bo_nonav_since = 0;
        }

        noNavLong = (self.bo_nonav_since != 0 && (gettime() - self.bo_nonav_since) > 6000);

        bad = (self.origin[2] < -5000) || NoGroundAt(self.origin) || IsWaterAt(self.origin) || noNavLong;

        if (!bad)
        {
            self.bo_spawn_bad_since = 0;
            wait 0.50;
            continue;
        }

        if (self.bo_spawn_bad_since == 0)
            self.bo_spawn_bad_since = gettime();

        land = FindNearestDryNavFrom(self.origin);
        if (isDefined(land))
        {
            self clearentitytarget();
            self ManualMovePoint(land);
            self botsetmovemagnitude(1.0);

            wait 1.25;

            nav2 = getclosestpointonnavmesh(self.origin, 256, 16);
            if (isDefined(nav2) && !IsWaterAt(self.origin) && !NoGroundAt(self.origin))
            {
                self.bo_spawn_bad_since = 0;
                self.bo_nonav_since = 0;
                wait 0.25;
                continue;
            }
        }

        if ((gettime() - self.bo_spawn_bad_since) > 6500 && AllowHardTeleport())
        {
            fallback = PickLocalEmergencyRescuePos(self.origin);

            if (isDefined(fallback))
            {
                self setorigin(fallback);

                self.bo_search_goal = PickGoalNear(fallback, 900);
                self.bo_next_goal_time = gettime() + randomintRange(2500, 4500);
                self.bo_goal_last_dist = 999999999;
                self.bo_goal_last_progress_time = gettime();

                self.bo_spawn_bad_since = 0;
                self.bo_nonav_since = 0;
            }
        }

        wait 0.50;
    }
}

PickBestNavGoalNear(center, radius, samples)
{
    best = undefined;

    if (!isDefined(samples))
        samples = 8;

    for (i = 0; i < samples; i++)
    {
        offX = randomFloatRange(0 - radius, radius);
        offY = randomFloatRange(0 - radius, radius);
        candidate = (center[0] + offX, center[1] + offY, center[2]);

        snapped = NavSnap(candidate);
        if (!isDefined(snapped))
            continue;

        if (distanceSquared(snapped, center) < (140 * 140))
            continue;

        if (distanceSquared(snapped, center) > ((radius * 1.35) * (radius * 1.35)))
            continue;

        best = snapped;
        break;
    }

    if (!isDefined(best))
        best = NavSnap(center);

    return best;
}

PickGoalNear(center, radius)
{
    return PickBestNavGoalNear(center, radius, 10);
}

PickSearchSpiralGoal(center, baseRadius)
{
    if (!isDefined(baseRadius)) baseRadius = 650;

    ang = randomFloatRange(0, 360);
    r = randomFloatRange(baseRadius * 0.55, baseRadius * 1.15);
    fwd = anglesToForward((0, ang, 0));

    pos = (center[0] + fwd[0] * r, center[1] + fwd[1] * r, center[2]);
    return NavSnap(pos);
}

GetRandomAliveEntityInsideCircle()
{
    list = array();
    players = getplayers();

    foreach (p in players)
    {
        if (!isDefined(p) || !isAlive(p) || p == self || !isDefined(p.origin))
            continue;

        if (!IsPosInsideCircle(p.origin))
            continue;

        if (IsBadAnchorEnt(p))
            continue;

        list[list.size] = p;
    }

    if (list.size <= 0)
        return undefined;

    return list[randomint(list.size)];
}

IsWaterNear(pos, radius)
{
    if (!isDefined(pos))
        return true;

    if (!isDefined(radius))
        radius = 220;

    // nine points: the middle, four at half the radius, four on the diagonals
    half = int(radius * 0.5);
    negHalf = 0 - half;
    diag = int(radius * 0.7);
    negDiag = 0 - diag;

    offs = array((0,0,0), (half,0,0), (negHalf,0,0), (0,half,0), (0,negHalf,0), (diag,diag,0), (diag,negDiag,0), (negDiag,diag,0), (negDiag,negDiag,0));

    foreach (o in offs)
    {
        p = (pos[0] + o[0], pos[1] + o[1], pos[2]);
        if (IsWaterAt(p))
            return true;
    }

    return false;
}

FindDryRedirectFromHere()
{
    if (!isDefined(self.origin))
        return undefined;

    dry = FindNearestDryNavFrom(self.origin);
    if (isDefined(dry) && !IsWaterNear(dry, 260) && !IsBadLandingPos(dry))
        return dry;

    fromNow = self.origin;
    poi = PickDryPOIInsideStorm(fromNow, isDefined(self.bo_bot_index) ? self.bo_bot_index : randomint(9999));
    if (isDefined(poi) && !IsWaterNear(poi, 320) && !IsBadLandingPos(poi))
        return poi;

    if (HasDeathCircle())
    {
        c = FixBadSpawnLocation(level.deathcircle.origin);
        if (isDefined(c) && !IsWaterNear(c, 320) && !IsBadLandingPos(c))
            return c;
    }

    return undefined;
}

TeleportNearEntity(ent)
{
    if (!isDefined(ent) || !isDefined(ent.origin) || !isAlive(self))
        return;

    minR = 450;
    maxR = 950;

    for (i = 0; i < 16; i++)
    {
        ang = randomFloatRange(0, 360);
        r = randomFloatRange(minR, maxR);

        fwd = anglesToForward((0, ang, 0));
        pos = (ent.origin[0] + fwd[0] * r, ent.origin[1] + fwd[1] * r, ent.origin[2]);

        pos = FixBadSpawnLocation(pos);
        if (!isDefined(pos))
            continue;

        if (distanceSquared(pos, ent.origin) < (280 * 280))
            continue;

        if (HasDeathCircle() && !IsPosInsideCircle(pos))
            continue;

        self setorigin(pos);
        return;
    }

    pos = FixBadSpawnLocation(ent.origin);
    if (isDefined(pos))
        self setorigin(pos);
}

MinDistSqToAnyPlayer(pos)
{
    if (!isDefined(pos))
        return 0;

    best = 999999999;
    players = getplayers();

    foreach (p in players)
    {
        if (!isDefined(p) || !isAlive(p) || !isDefined(p.origin))
            continue;

        d = distanceSquared(pos, p.origin);
        if (d < best)
            best = d;
    }

    return best;
}

FindFarNavPointFromPlayers(samples, minDist)
{
    if (!isDefined(samples))
        samples = 24;

    if (!isDefined(minDist))
        minDist = 2200;

    minDistSq = minDist * minDist;

    center = (isDefined(level.deathcircle) && isDefined(level.deathcircle.origin)) ? level.deathcircle.origin : self.origin;
    safeRad = (isDefined(level.deathcircle) && isDefined(level.deathcircle.radius)) ? level.deathcircle.radius : 12000;

    best = undefined;
    bestScore = -1;

    for (i = 0; i < samples; i++)
    {
        ang = randomFloatRange(0, 360);
        maxR = safeRad - 600;
        if (maxR <= 1200) maxR = 1201;
        r = SafeRandomFloatRange(1200, maxR);

        fwd = anglesToForward((0, ang, 0));
        candidate = (center[0] + fwd[0] * r, center[1] + fwd[1] * r, center[2]);

        candidate = NavSnap(candidate);
        if (!isDefined(candidate))
            continue;

        dSq = MinDistSqToAnyPlayer(candidate);

        if (dSq < minDistSq)
            continue;

        if (dSq > bestScore)
        {
            bestScore = dSq;
            best = candidate;
        }
    }

    return best;
}

IsBlockedAhead(dist)
{
    if (!isDefined(dist))
        dist = 96;

    if (!isDefined(self.origin) || !isDefined(self.angles))
        return false;

    fwd = anglesToForward((0, self.angles[1], 0));

    start1 = (self.origin[0], self.origin[1], self.origin[2] + 56);
    end1   = (start1[0] + fwd[0] * dist, start1[1] + fwd[1] * dist, start1[2]);

    start2 = (self.origin[0], self.origin[1], self.origin[2] + 18);
    end2   = (start2[0] + fwd[0] * dist, start2[1] + fwd[1] * dist, start2[2]);

    tr1 = bullettrace(start1, end1, 0, self);
    tr2 = bullettrace(start2, end2, 0, self);

    if (isDefined(tr1) && isDefined(tr1["fraction"]) && tr1["fraction"] < 0.80)
        return true;

    if (isDefined(tr2) && isDefined(tr2["fraction"]) && tr2["fraction"] < 0.80)
        return true;

    return false;
}

BreakWallContactAndRepath(goal)
{
    if (!isDefined(self.origin))
        return;

    if (!isDefined(self.bo_last_wall_repath_time))
        self.bo_last_wall_repath_time = 0;

    if (gettime() - self.bo_last_wall_repath_time < 1100)
        return;

    self.bo_last_wall_repath_time = gettime();

    fwd = anglesToForward((0, self.angles[1], 0));
    rx = 0.0 - fwd[1];
    ry = fwd[0];

    backDist = randomFloatRange(120, 210);
    back = (self.origin[0] - fwd[0] * backDist, self.origin[1] - fwd[1] * backDist, self.origin[2]);
    back = NavSnap(back);

    if (isDefined(back))
    {
        self ManualMovePoint(back);
        self botsetmovemagnitude(1.0);
    }

    wait 0.10;

    side = (randomint(2) == 0) ? 1 : -1;
    sideDist = randomFloatRange(260, 420) * float(side);

    step = (self.origin[0] + rx * sideDist, self.origin[1] + ry * sideDist, self.origin[2]);
    step = NavSnap(step);

    if (isDefined(step))
    {
        self ManualMovePoint(step);
        self botsetmovemagnitude(1.0);
    }

    if (randomint(100) < 70)
        self bottapbutton(10);

    if (isDefined(goal))
    {
        newGoal = PickGoalNear(goal, 1200);
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

UnstuckCheck(goal)
{
    if (!isDefined(goal) || !isDefined(self.origin))
        return;

    if (!isDefined(self.bo_goal_last_dist))
        self.bo_goal_last_dist = 999999999;

    if (!isDefined(self.bo_goal_last_progress_time))
        self.bo_goal_last_progress_time = gettime();

    if (!isDefined(self.bo_wall_stuck_time))
        self.bo_wall_stuck_time = gettime();

    if (!isDefined(self.bo_wall_last_origin))
        self.bo_wall_last_origin = self.origin;

    dSq = distanceSquared(self.origin, goal);

    if (IsBlockedAhead(96))
    {
        BreakWallContactAndRepath(goal);
        self.bo_goal_last_progress_time = gettime();
        self.bo_goal_last_dist = 999999999;
        self.bo_wall_stuck_time = gettime();
        self.bo_wall_last_origin = self.origin;
        return;
    }

    if (dSq + (120 * 120) < self.bo_goal_last_dist)
    {
        self.bo_goal_last_dist = dSq;
        self.bo_goal_last_progress_time = gettime();
        self.bo_wall_stuck_time = gettime();
        self.bo_wall_last_origin = self.origin;
        return;
    }

    movedSq = distanceSquared(self.origin, self.bo_wall_last_origin);

    if (movedSq > (35 * 35))
    {
        if (gettime() - self.bo_wall_stuck_time > 1800)
        {
            BreakWallContactAndRepath(goal);
            self.bo_goal_last_progress_time = gettime();
            self.bo_goal_last_dist = 999999999;
            self.bo_wall_stuck_time = gettime();
            self.bo_wall_last_origin = self.origin;
            return;
        }

        self.bo_wall_last_origin = self.origin;
    }

    if (gettime() - self.bo_goal_last_progress_time > 2250)
    {
        dir = vectorNormalize(goal - self.origin);

        rx = 0.0 - dir[1];
        ry = dir[0];

        side = (randomint(2) == 0) ? 1 : -1;
        dist = 260.0 * float(side);

        nudge = (self.origin[0] + (rx * dist), self.origin[1] + (ry * dist), self.origin[2]);
        nudge = NavSnap(nudge);

        if (isDefined(nudge))
        {
            self ManualMovePoint(nudge);
            self botsetmovemagnitude(1.0);
        }

        self bottapbutton(10);

        self.bo_goal_last_progress_time = gettime();
        self.bo_goal_last_dist = 999999999;
        self.bo_wall_stuck_time = gettime();
        self.bo_wall_last_origin = self.origin;
    }
}

FindNearestDryNavFrom(pos)
{
    if (!isDefined(pos))
        return undefined;

    base = NavSnap(pos);
    if (isDefined(base) && !IsBadLandingPos(base))
        return base;

    // at most 32 tries, a frame between every 8
    tries = 0;

    for (ring = 0; ring < 4; ring++)
    {
        minR = 250 + (ring * 610);
        maxR = 550 + (ring * 790);

        for (i = 0; i < 6; i++)
        {
            tries++;
            if (tries % 8 == 0)
                waitframe(1);

            ang = randomFloatRange(0, 360);
            r = randomFloatRange(minR, maxR);
            fwd = anglesToForward((0, ang, 0));

            cand = (pos[0] + fwd[0] * r, pos[1] + fwd[1] * r, pos[2]);
            cand = NavSnap(cand);

            if (!isDefined(cand))
                continue;

            if (IsBadLandingPos(cand))
                continue;

            return cand;
        }
    }

    if (HasDeathCircle())
    {
        c = level.deathcircle.origin;

        for (k = 0; k < 8; k++)
        {
            if (k == 4)
                waitframe(1);

            ang = randomFloatRange(0, 360);
            maxR = level.deathcircle.radius - 700;
            if (maxR <= 600) maxR = 601;
            r = SafeRandomFloatRange(600, maxR);
            fwd = anglesToForward((0, ang, 0));

            cand = (c[0] + fwd[0] * r, c[1] + fwd[1] * r, c[2]);
            cand = NavSnap(cand);

            if (!isDefined(cand))
                continue;

            if (IsBadLandingPos(cand))
                continue;

            return cand;
        }
    }
    return undefined;
}

PickLocalEmergencyRescuePos(fromPos)
{
    if (!isDefined(fromPos))
        return undefined;

    local = FindNearestDryNavFrom(fromPos);
    local = FixBadSpawnLocation(local);

    if (!isDefined(local))
    {
        for (i = 0; i < 10; i++)
        {
            ang = randomFloatRange(0, 360);
            r = randomFloatRange(350, 1600);
            fwd = anglesToForward((0, ang, 0));

            cand = (fromPos[0] + fwd[0] * r, fromPos[1] + fwd[1] * r, fromPos[2]);
            cand = NavSnap(cand);

            if (!isDefined(cand)) continue;
            if (IsBadLandingPos(cand)) continue;
            if (IsWaterNear(cand, 900)) continue;

            local = cand;
            break;
        }
    }

    if (!isDefined(local))
        local = NavSnap(fromPos);

    if (isDefined(local) && IsBadLandingPos(local))
        return undefined;

    return local;
}

NavSnap(pos)
{
    if (!isDefined(pos))
        return undefined;

    // the navmesh point is on the floor already: a trace from above would land on the roof over it
    nav = getclosestpointonnavmesh(pos, 384, 24);
    if (isDefined(nav))
        return (nav[0], nav[1], nav[2] + 10);

    if (IsSparseNavMap())
        return TerrainSnap(pos);

    return GroundSnap(pos);
}

// maps where most of the ground has no navmesh, so goals there are steered to in a straight line
IsSparseNavMap()
{
    if (!isDefined(level.bo_sparse_nav))
    {
        map = util::get_map_name();
        level.bo_sparse_nav = (map == "wz_open_skyscrapers" || map == "wz_open_skyscrapers_alt");
    }

    return level.bo_sparse_nav;
}

/*
    The ground under a point whose height is a guess (a circle middle, a point around a POI): from 3000
    above, as from just over it the trace starts inside a hill and finds nothing. That can land on a roof,
    which matters little for a straight walk across open ground.
*/
TerrainSnap(pos)
{
    if (!isDefined(pos))
        return undefined;

    start = (pos[0], pos[1], pos[2] + 3000);
    end = (pos[0], pos[1], pos[2] - 20000);

    tr = bullettrace(start, end, 0, self);
    if (isDefined(tr) && isDefined(tr["position"]) && isDefined(tr["fraction"]) && tr["fraction"] < 0.999)
    {
        hit = tr["position"];
        return (hit[0], hit[1], hit[2] + 10);
    }

    return undefined;
}

// the navmesh near a point, searched further than NavSnap does
NavSnapWide(pos)
{
    if (!isDefined(pos))
        return undefined;

    nav = getclosestpointonnavmesh(pos, 1024, 24);
    if (isDefined(nav))
        return (nav[0], nav[1], nav[2] + 10);

    return NavSnap(pos);
}

MinDistSqToOtherBots(pos)
{
    if (!isDefined(pos) || !isDefined(level.BotsInGame))
        return 999999999;

    best = 999999999;

    foreach (b in level.BotsInGame)
    {
        if (!isDefined(b) || b == self || !isDefined(b.origin))
            continue;

        d = distanceSquared(pos, b.origin);
        if (d < best)
            best = d;
    }

    return best;
}

IsWaterAt(pos)
{
    if (!isDefined(pos))
        return true;

    for (i = 0; i < 3; i++)
    {
        up = 128 + (i * 192);
        start = (pos[0], pos[1], pos[2] + up);
        end = (pos[0], pos[1], pos[2] - 20000);

        tr = bullettrace(start, end, 0, self);
        if (!isDefined(tr))
            continue;

        if (!isDefined(tr["fraction"]) || tr["fraction"] >= 0.999)
            continue;

        if (isDefined(tr["surfacetype"]))
        {
            st = tr["surfacetype"];

            if (st == #"water" || st == #"water_shallow" || st == #"water_deep" || st == #"slime")
                return true;

            if (st == "water" || st == "water_shallow" || st == "water_deep" || st == "slime")
                return true;
        }

        // the first surface hit is not water: the higher starts only help when this one hit nothing
        return false;
    }

    return false;
}

InsertionAirSteerWatchdog()
{
    self endon("disconnect");
    self endon("death");
    level endon("game_ended");
    self endon("bo_brain_restart");

    lastDist = 999999999;
    badSince = 0;

    for (;;)
    {
        if (!isDefined(self.bo_insertion_active) || !self.bo_insertion_active)
            return;

        if (!isAlive(self) || !isDefined(self.origin))
        {
            wait 0.15;
            continue;
        }

        if (IsLandedStable() && !IsHighAltitudeInsertion())
            return;

        goal = self GetCurrentPOIObjective();
        if (!isDefined(goal))
        {
            self UpdateDropPOIForThisLife();
            wait 0.20;
            continue;
        }

        if (HasDeathCircle())
            goal = ClampPosInsideCircle(goal, 750);

        airGoal = self GetAirSteerGoal(goal);
        if (!isDefined(airGoal))
        {
            wait 0.20;
            continue;
        }

        d = distance2d(self.origin, airGoal);

        if (IsWaterNear(self.origin, 900))
        {
            from2 = HasDeathCircle() ? level.deathcircle.origin : self.origin;
            self.bo_drop_poi = PickDryPOIInsideStorm(from2, isDefined(self.bo_bot_index) ? self.bo_bot_index : randomint(9999));
        }

        if (d > lastDist + 140)
        {
            if (badSince == 0) badSince = gettime();
        }
        else
        {
            badSince = 0;
        }

        lastDist = d;

        if (badSince != 0 && (gettime() - badSince) > 1400)
        {
            self UpdateDropPOIForThisLife();

            self bottapbutton(7);
            if (randomint(100) < 50) self bottapbutton(7);

            if (self isinvehicle())
            {
                self TryForceJumpOut();
                self TryForceJumpOut();
            }

            badSince = 0;
        }

        wait 0.20;
    }
}

/*
    Movement along the navmesh, as the game's own bots move: a forced goal, and the engine finds and walks
    the path to it (stairs, doors, mantles). Where it cannot (no navmesh under the bot, water, a path
    that keeps failing) the bot steers straight at the goal as it used to.
*/

// a straight move the engine does not path, marked so the path is given back afterwards
ManualMovePoint(point)
{
    self.bo_manual_move_time = gettime();
    self botsetmovepoint(point);
}

CanPathNow()
{
    if (isDefined(self.bo_manual_until) && gettime() < self.bo_manual_until)
        return false;

    if (!isAlive(self) || !isDefined(self.origin) || self isinvehicle())
        return false;

    if (isDefined(self.bo_insertion_active) && self.bo_insertion_active)
        return false;

    if (self isplayerswimming())
        return false;

    // asked every pass: the answer is kept half a second
    if (!isDefined(self.bo_onnav_time) || gettime() - self.bo_onnav_time > 500)
    {
        self.bo_onnav = isDefined(getclosestpointonnavmesh(self.origin, 128, 24));
        self.bo_onnav_time = gettime();
    }

    return self.bo_onnav;
}

// urgent goals (gas, a fight) may get a new path every 0.7 s, others every 1.5 s
BotMoveTo(goal, urgent)
{
    if (!isDefined(goal) || !isDefined(self.origin))
        return;

    if (!isDefined(self.bo_path_fails))
        self.bo_path_fails = 0;

    // SwimToLand moves a swimmer
    if (isDefined(self.bo_swim_until) && gettime() < self.bo_swim_until)
        return;

    self botsetmovemagnitude(1.0);

    // the engine is taking the bot over a ledge, or it is in the air: leave the move as it is
    if (isDefined(self.bot) && isDefined(self.bot.traversal))
        return;

    if (!self isonground() && !self isplayerswimming())
        return;

    // the same goal as last time needs no new navmesh query
    navGoal = undefined;
    if (self CanPathNow())
    {
        if (isDefined(self.bo_nav_raw) && isDefined(self.bo_nav_snap) && distanceSquared(goal, self.bo_nav_raw) < (64 * 64))
            navGoal = self.bo_nav_snap;
        else
        {
            navGoal = getclosestpointonnavmesh(goal, 256, 24);
            self.bo_nav_raw = goal;
            self.bo_nav_snap = navGoal;
        }
    }

    if (!isDefined(navGoal))
    {
        self.bo_path_goal = undefined;
        self ManualMovePoint(goal);
        UnstuckCheck(goal);
        return;
    }

    now = gettime();
    minGap = (isDefined(urgent) && urgent) ? 700 : 1500;

    reissue = !isDefined(self.bo_path_goal) || !isDefined(self.bo_path_time);

    if (!reissue && distanceSquared(self.bo_path_goal, navGoal) > (200 * 200) && now - self.bo_path_time > minGap)
        reissue = true;

    // a juke or a step aside took the move over: the path again once it had its moment
    if (!reissue && isDefined(self.bo_manual_move_time) && self.bo_manual_move_time > self.bo_path_time && now - self.bo_manual_move_time > 400)
        reissue = true;

    if (!reissue)
    {
        // no headway for 2 s counts as a failed path
        if (now - self.bo_path_moved_time > 2000)
        {
            if (distanceSquared(self.origin, self.bo_path_moved_pos) < (48 * 48) && distanceSquared(self.origin, self.bo_path_target) > (160 * 160))
                self PathFailed();

            self.bo_path_moved_pos = self.origin;
            self.bo_path_moved_time = now;
        }

        return;
    }

    target = navGoal;

    // after a failure a nearer point on the way: a long path on the big map can fail where a short one does not
    if (self.bo_path_fails > 0)
    {
        step = 4000 / (self.bo_path_fails + 1);

        if (distance2d(self.origin, navGoal) > step)
        {
            dir = vectorNormalize((navGoal[0] - self.origin[0], navGoal[1] - self.origin[1], 0));
            mid = getclosestpointonnavmesh((self.origin[0] + dir[0] * step, self.origin[1] + dir[1] * step, self.origin[2]), 512, 24);

            if (isDefined(mid))
                target = mid;
        }
    }

    self botreleasemanualcontrol();
    self.goalradius = 128;
    self setgoal(target, 1);

    self.bo_path_goal = navGoal;
    self.bo_path_target = target;
    self.bo_path_time = now;
    self.bo_path_moved_pos = self.origin;
    self.bo_path_moved_time = now;
}

// stands where it is: a forced goal on its own spot, set once while it stays there
BotHoldPosition()
{
    if (!isDefined(self.origin))
        return;

    if (isDefined(self.bo_hold_pos) && isDefined(self.bo_path_goal) && self.bo_path_goal == self.bo_hold_pos && distanceSquared(self.origin, self.bo_hold_pos) < (100 * 100))
        return;

    nav = getclosestpointonnavmesh(self.origin, 128, 24);
    if (!isDefined(nav))
    {
        self botsetmovemagnitude(0.0);
        return;
    }

    self botreleasemanualcontrol();
    self.goalradius = 32;
    self setgoal(nav, 1);

    now = gettime();
    self.bo_hold_pos = nav;
    self.bo_path_goal = nav;
    self.bo_path_target = nav;
    self.bo_path_time = now;
    self.bo_path_moved_pos = self.origin;
    self.bo_path_moved_time = now;
}

PathFailed()
{
    self.bo_path_fails++;
    self.bo_path_goal = undefined;

    /*
        Three in a row: the goal is out of reach (inside a closed house, on a roof). A new goal, and
        straight steering for 3 s to get loose, then the navmesh again.
    */
    if (self.bo_path_fails >= 3)
    {
        self.bo_path_fails = 0;
        self.bo_manual_until = gettime() + 3000;

        self.bo_search_goal = undefined;
        self.bo_next_goal_time = 0;
        self.bo_roam_commit_until = 0;
        self.bo_enemy_goal = undefined;
        self.bo_gas_goal_until = 0;
    }
}

PathFailedWatcher()
{
    self endon("disconnect");
    self endon("death");
    level endon("game_ended");
    self endon("bo_brain_restart");

    for (;;)
    {
        self waittill("bot_path_failed");

        // the path just given replaced the last one: that one ending is no failure
        if (!isDefined(self.bo_path_time) || gettime() - self.bo_path_time > 300)
            self PathFailed();
        waitframe(1);
    }
}

PathSuccessWatcher()
{
    self endon("disconnect");
    self endon("death");
    level endon("game_ended");
    self endon("bo_brain_restart");

    for (;;)
    {
        self waittill("bot_path_success");
        self.bo_path_fails = 0;
        waitframe(1);
    }
}