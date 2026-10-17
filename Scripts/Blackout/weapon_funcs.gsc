// fix random weapon camo giving error for some weapons
detour item_inventory<scripts\mp_common\item_inventory.gsc>::equip_weapon(item, switchweapon = 1, var_9fa01da8 = 0, var_a3a17c55 = 0, initialweaponraise = 0) {
    //assert(isplayer(self));
    itementry = item.itementry;
    itemtype = itementry.itemtype;
    //assert(itemtype == #"weapon");
    currentweapon = level.weaponbasemeleeheld;
    var_68dc9720 = 16 + 1;
    var_6073ab7b = 0;
    if ([[ @item_inventory<scripts\mp_common\item_inventory.gsc>::function_bad4a3a5 ]]() == 2) {
        if (var_9fa01da8) {
            currentweapon = self getstowedweapon();
        } else {
            currentweapon = self.currentweapon;
        }
        foreach (slotid in array(16 + 1, 16 + 1 + 6 + 1)) {
            var_b8c2759f = self.inventory.items[slotid];
            if (var_b8c2759f.networkid === 32767) {
                continue;
            }
            equippedweapon = [[ @item_inventory_util<scripts\mp_common\item_inventory_util.gsc>::function_2b83d3ff ]](var_b8c2759f);
            if (currentweapon == equippedweapon) {
                var_68dc9720 = slotid;
                [[ @item_inventory<scripts\mp_common\item_inventory.gsc>::function_60706bdb ]](var_b8c2759f.networkid);
                [[ @item_inventory<scripts\mp_common\item_inventory.gsc>::function_d019bf1d ]](var_b8c2759f.networkid);
                break;
            }
        }
        currentweapon = level.weaponbasemeleeheld;
    } else {
        if ([[ @item_inventory<scripts\mp_common\item_inventory.gsc>::function_bad4a3a5 ]]() == 0) {
            if (function_8b1a219a() && (self getcurrentweapon() != level.weaponnone || self getcurrentweapon() != currentweapon)) {
                var_6073ab7b = 1;
            } else {
                currentweapon = level.weaponnone;
            }
        }
        var_68dc9720 = undefined;
        foreach (slotid in array(16 + 1, 16 + 1 + 6 + 1)) {
            if (self.inventory.items[slotid].networkid === item.networkid) {
                var_68dc9720 = slotid;
                break;
            }
        }
        if (!isdefined(var_68dc9720)) {
            foreach (slotid in array(16 + 1, 16 + 1 + 6 + 1)) {
                if (self.inventory.items[slotid].networkid === 32767) {
                    var_68dc9720 = slotid;
                    break;
                }
            }
        }
    }
    weapon = [[ @item_inventory_util<scripts\mp_common\item_inventory_util.gsc>::function_2b83d3ff ]](item);
    if (isdefined(weapon) && weapon != level.weaponnone) {
        var_346dc077 = self getweaponammostock(weapon);
        item.var_42caf41a = slotid == 16 + 1 + 6 + 1;
        [[ @item_inventory_util<scripts\mp_common\item_inventory_util.gsc>::function_6e9e7169 ]](item);
        weapon = [[ @item_inventory_util<scripts\mp_common\item_inventory_util.gsc>::function_2b83d3ff ]](item);
        slotid = [[ @item_inventory<scripts\mp_common\item_inventory.gsc>::function_b246c573 ]](item.networkid);
        if (!isdefined(slotid)) {
            return;
        }
        self [[ @item_inventory<scripts\mp_common\item_inventory.gsc>::function_26c87da8 ]](slotid, var_68dc9720);
        if (initialweaponraise && !isdefined(item.weaponoptions) && !isdefined(item.charmindex) && !isdefined(item.deathfxindex)) {
            weaponoptions = undefined;
            charmindex = undefined;
            deathfxindex = undefined;
            if (isdefined(getgametypesetting(#"wzrandomcamo")) ? getgametypesetting(#"wzrandomcamo") : 0) {
                renderoptions = function_ea647602("camo", weapon);
                if (isdefined(renderoptions) && renderoptions.size > 0) {
                    var_9412af4a = randomint(renderoptions.size);
                    if (isdefined(renderoptions[var_9412af4a]) && isdefined(renderoptions[var_9412af4a].item_index)) {
                        buildkitweapon = [[ @activecamo<scripts\core_common\activecamo_shared_util.gsc>::function_385ef18d ]](weapon);
                        weaponoptions = self calcweaponoptions(renderoptions[var_9412af4a].item_index, 0, 0);
                        charmindex = self function_9826b353(buildkitweapon);
                        deathfxindex = self function_74829bcf(buildkitweapon);
                    }
                }
            } else {
                buildkitweapon = [[ @activecamo<scripts\core_common\activecamo_shared_util.gsc>::function_385ef18d ]](weapon);
                weaponoptions = self getbuildkitweaponoptions(buildkitweapon);
                charmindex = self function_9826b353(buildkitweapon);
                deathfxindex = self function_74829bcf(buildkitweapon);
            }

            if (!isdefined(weaponoptions))
            {
                buildkitweapon = [[ @activecamo<scripts\core_common\activecamo_shared_util.gsc>::function_385ef18d ]](weapon);
                weaponoptions = self getbuildkitweaponoptions(buildkitweapon);
                charmindex = self function_9826b353(buildkitweapon);
                deathfxindex = self function_74829bcf(buildkitweapon);
            }

            if (weaponoptions != self getbuildkitweaponoptions(level.weaponnone)) {
                item.weaponoptions = weaponoptions;
            }
            item.charmindex = charmindex;
            item.deathfxindex = deathfxindex;
        }
        item.weaponoptions = self [[ @item_inventory<scripts\mp_common\item_inventory.gsc>::function_fc04b237 ]](weapon, item.weaponoptions);
        self [[ @item_inventory<scripts\mp_common\item_inventory.gsc>::replace_weapon ]](currentweapon, weapon, 1, initialweaponraise, var_a3a17c55, item.weaponoptions, item.charmindex, item.deathfxindex);
        if (var_6073ab7b) {
            self [[ @item_inventory<scripts\mp_common\item_inventory.gsc>::replace_weapon ]](level.weaponnone, level.weaponbasemeleeheld);
        }
        self function_b00db06(6, item.networkid);
        inventoryitem = [[ @item_inventory<scripts\mp_common\item_inventory.gsc>::get_inventory_item ]](item.networkid);
        if (!isdefined(inventoryitem)) {
            return;
        }
        if (weapon !== currentweapon) {
            var_b917b36f = int(min(var_346dc077, weapon.clipsize));
            self function_fc9f8b05(weapon, var_b917b36f);
        }
        var_954e19c7 = [[ @item_inventory<scripts\mp_common\item_inventory.gsc>::get_weapon_count ]](weapon);
        if (var_a3a17c55) {
            self function_c9a111a(weapon);
        } else {
            self shoulddoinitialweaponraise(weapon, initialweaponraise);
        }
        self setweaponammoclip(weapon, int(inventoryitem.amount));
        if (switchweapon || var_954e19c7 == 1) {
            if (self [[ @item_inventory<scripts\mp_common\item_inventory.gsc>::can_switch_weapons ]]()) {
                self switchtoweapon(weapon, 1);
                self.currentweapon = weapon;
            }
        }
        self [[ @item_inventory<scripts\mp_common\item_inventory.gsc>::function_db2abc4 ]](item);
        return;
    }
    //assertmsg("<dev string:x11f>" + itementry.name + "<dev string:x55>");
}

CanArmNow()
{
    if (!isAlive(self) || !isDefined(self.origin))
        return false;

    if (self isinvehicle())
        return false;

    if (isDefined(self.bo_insertion_active) && self.bo_insertion_active)
        return false;

    if (!IsLandedStable())
        return false;

    return true;
}

CanArmNowFast()
{
    if (!isAlive(self) || !isDefined(self.origin))
        return false;

    if (self isinvehicle())
        return false;

    if (isDefined(self.bo_insertion_active) && self.bo_insertion_active)
        return false;

    if (self isonground())
        return true;

    return IsLandedStable();
}

// the weapons as Blackout items
BlackoutWeaponItems()
{
    if (!isDefined(level.bo_weapon_items))
    {
        level.bo_weapon_items = array(
            #"ar_accurate_t8_item",
            #"ar_fastfire_t8_item",
            #"ar_an94_t8_item",
            #"ar_peacekeeper_t8_item",
            #"ar_doublebarrel_t8_item",
            #"ar_damage_t8_item",
            #"ar_stealth_t8_item",
            #"ar_modular_t8_item",
            #"ar_standard_t8_item",
            #"ar_galil_t8_item",
            #"smg_vmp_t8_item",
            #"smg_minigun_t8_item",
            #"smg_standard_t8_item",
            #"smg_handling_t8_item",
            #"smg_fastfire_t8_item",
            #"smg_capacity_t8_item",
            #"smg_accurate_t8_item",
            #"smg_fastburst_t8_item",
            #"smg_folding_t8_item",
            #"tr_powersemi_t8_item",
            #"tr_longburst_t8_item",
            #"tr_midburst_t8_item",
            #"tr_flechette_t8_item",
            #"tr_damageburst_t8_item",
            #"lmg_spray_t8_item",
            #"lmg_stealth_t8_item",
            #"lmg_standard_t8_item",
            #"lmg_heavy_t8_item",
            #"shotgun_pump_t8_item",
            #"shotgun_semiauto_t8_item",
            #"shotgun_fullauto_t8_item",
            #"shotgun_precision_t8_item",
            #"sniper_powerbolt_t8_item",
            #"sniper_damagesemi_t8_item",
            #"sniper_locus_t8_item",
            #"sniper_mini14_t8_item",
            #"sniper_quickscope_t8_item",
            #"sniper_fastrechamber_t8_item",
            #"sniper_powersemi_t8_item",
            #"pistol_standard_t8_item",
            #"pistol_fullauto_t8_item",
            #"pistol_burst_t8_item",
            #"pistol_revolver_t8_item"
        );
    }

    return level.bo_weapon_items;
}

// a random gun in the hands, an item gun only when that fails
GiveRandomPrimary()
{
    // in the hands, given straight: as items they piled up in the backpack
    if (isDefined(level.AllBlackoutWeapons) && level.AllBlackoutWeapons.size > 0)
    {
        for (i = 0; i < 3; i++)
        {
            wname = level.AllBlackoutWeapons[randomint(level.AllBlackoutWeapons.size)];
            if (!isDefined(wname) || wname == "")
                continue;

            self GivePrimarySafe(wname);
            waitframe(1);

            if (self HasRealGun())
                return;
        }
    }

    // that failed: one as an item
    items = BlackoutWeaponItems();
    self GiveInventoryItem(items[randomint(items.size)], 1);
}

GivePrimarySafe(weaponName)
{
    if (!isDefined(weaponName))
        return;

    w = getweapon(weaponName);
    if (!isDefined(w))
        return;

    self enableweapons();

    prims = self getweaponslistprimaries();
    if (isDefined(prims))
    {
        foreach (pw in prims)
            self takeweapon(pw);
    }

    self enableweapons();
    self giveweapon(w);
    self givemaxammo(w);
    self switchtoweaponimmediate(w);
    self enableweapons();
}

PickLandingWeaponName()
{
    weapons = array(
        "smg_standard_t8",
        "smg_handling_t8",
        "smg_fastfire_t8",
        "ar_fastfire_t8",
        "ar_accurate_t8",
        "ar_modular_t8",
        "tr_damageburst_t8"
    );

    if (!isDefined(weapons) || weapons.size <= 0)
        return "smg_standard_t8";

    return weapons[randomint(weapons.size)];
}

IsOnRealSurface()
{
    if (!isAlive(self) || !isDefined(self.origin))
        return false;

    if (!self isonground())
        return false;

    now = gettime();

    if (isDefined(self.bo_ground_cache_t) && (now - self.bo_ground_cache_t) < 250)
    {
        if (isDefined(self.bo_ground_cache_val))
            return self.bo_ground_cache_val;
    }

    self.bo_ground_cache_t = now;

    start = (self.origin[0], self.origin[1], self.origin[2] + 60);
    end = (self.origin[0], self.origin[1], self.origin[2] - 20000);

    tr = bullettrace(start, end, 0, self);

    if (isDefined(tr) && isDefined(tr["position"]))
    {
        dz = abs(self.origin[2] - tr["position"][2]);

        self.bo_ground_cache_val = (dz <= 220);
        return self.bo_ground_cache_val;
    }

    self.bo_ground_cache_val = true;
    return true;
}

LandingLoadoutWatcher()
{
    self endon("disconnect");
    self endon("death");
    level endon("game_ended");
    self endon("bo_brain_restart");

    t0 = gettime();

    while (!IsOnRealSurface() && gettime() - t0 < 45000)
        wait 0.20;

    if (!isAlive(self))
        return;

    if (isDefined(self.bo_landing_loadout_done) && self.bo_landing_loadout_done)
        return;

    self.bo_landing_loadout_done = true;

    self GiveArmor();
    self GiveRandomLoot();

    if (!isDefined(self.bo_landing_gun_done) || !self.bo_landing_gun_done)
    {
        self.bo_landing_gun_done = true;
        w = PickLandingWeaponName();
        if (isDefined(w))
            self GivePrimarySafe(w);
    }
}

ForceArmBurst(msTotal)
{
    if (!isDefined(msTotal))
        msTotal = 4500;

    if (!isAlive(self))
        return;

    endT = gettime() + msTotal;

    while (gettime() < endT)
    {
        if (!isAlive(self) || !isDefined(self.origin))
            return;

        if (!CanArmNow())
        {
            self disableweapons();
            wait 0.12;
            continue;
        }

        self enableweapons();

        if (HasGun())
            return;

        self enableweapons();
        self GiveRandomPrimary();
        self enableweapons();

        prims2 = self getweaponslistprimaries();
        if (isDefined(prims2) && prims2.size > 0)
            self switchtoweaponimmediate(prims2[0]);

        if (HasGun())
            return;

        wait 0.12;
    }
}

HasGun()
{
    if (!isDefined(self) || !isPlayer(self) || !isAlive(self) || !isDefined(self.origin))
        return false;

    if (self isinvehicle())
        return false;

    if (isDefined(self.bo_insertion_active) && self.bo_insertion_active)
        return false;

    if (isDefined(self.sessionstate) && self.sessionstate != "playing")
        return false;

    // the empty hands of Blackout are a primary weapon too: only a real gun counts
    prims = self getweaponslistprimaries();
    if (isDefined(prims))
    {
        foreach (w in prims)
        {
            if (IsRealGun(w))
                return true;
        }
    }

    return IsRealGun(self getcurrentweapon());
}

// a real gun in its hands or slots, whatever the bot is doing
HasRealGun()
{
    if (!isAlive(self))
        return false;

    prims = self getweaponslistprimaries();
    if (isDefined(prims))
    {
        foreach (w in prims)
        {
            if (IsRealGun(w))
                return true;
        }
    }

    return IsRealGun(self getcurrentweapon());
}

// the first real gun in its slots, or undefined
FirstRealGun()
{
    prims = self getweaponslistprimaries();
    if (!isDefined(prims))
        return undefined;

    foreach (w in prims)
    {
        if (IsRealGun(w))
            return w;
    }

    return undefined;
}

/*
    Every 1.5 s, for a bot on the ground: it gets a gun if it has none, and draws the one on its back
    while its hands are empty (after the drop the game puts the bare hands in them). It also clears an
    insertion flag still set 4 s after landing, and starts the brain again if it stopped. Now and then
    a status line goes to project-bo4.log.
*/
ArmWatcher()
{
    self notify("bo_arm_watcher");
    self endon("bo_arm_watcher");
    self endon("disconnect");
    self endon("death");
    level endon("game_ended");

    n = self getentitynumber();
    logs = 0;
    groundSince = 0;
    nextState = gettime() + 6000;
    stuckPos = undefined;
    stuckSince = 0;

    for (;;)
    {
        wait 1.5;

        if (!isAlive(self))
            continue;

        // near the ground, not on it: a bot hopping in place is down too
        onGround = !self isinvehicle() && GetDzToGroundSafe(self) < 150;

        if (gettime() >= nextState && logs < 12)
        {
            logs++;
            nextState = gettime() + 20000;

            ins = isDefined(self.bo_insertion_active) && self.bo_insertion_active;
            brainAge = isDefined(self.bo_brain_beat) ? gettime() - self.bo_brain_beat : -1;
            state = isDefined(self.sessionstate) ? self.sessionstate : "none";

            ShieldLog("^3[bo state] bot " + n + " ground " + onGround + " vehicle " + self isinvehicle() + " insertion " + ins + " gun " + self HasRealGun() + " in hand " + IsRealGun(self getcurrentweapon()) + " brain age " + brainAge + " state " + state);
        }

        if (!onGround)
        {
            groundSince = 0;
            continue;
        }

        if (groundSince == 0)
            groundSince = gettime();

        // landed 4 s ago: the insertion is over, whatever its threads think
        if (gettime() - groundSince > 4000 && isDefined(self.bo_insertion_active) && self.bo_insertion_active)
        {
            self.bo_insertion_active = false;
            ShieldLog("^3[bo arm] bot " + n + " insertion flag cleared on the ground");
        }

        // the brain stopped: again, without the start of a life (no spawn teleport)
        if (isDefined(self.bo_brain_beat) && gettime() - self.bo_brain_beat > 6000)
        {
            ShieldLog("^3[bo arm] bot " + n + " brain restarted, it stopped " + (gettime() - self.bo_brain_beat) + " ms ago");
            self.bo_brain_beat = gettime();
            self thread Brain(true);
        }

        if (isDefined(self.sessionstate) && self.sessionstate != "playing")
            continue;

        /*
            In one place for 10 s without a fight (or a revive, or a swim): set it on the navmesh close by.
            The last way out when steering could not get it loose.
        */
        busy = (isDefined(self.bo_last_burst_time) && gettime() - self.bo_last_burst_time < 4000) || self isplayerswimming() || IsPregame();

        if (busy || !isDefined(stuckPos) || distanceSquared(self.origin, stuckPos) > (120 * 120))
        {
            stuckPos = self.origin;
            stuckSince = gettime();
        }
        else if (gettime() - stuckSince > 10000)
        {
            free = getclosestpointonnavmesh(self.origin + (randomFloatRange(-200, 200), randomFloatRange(-200, 200), 0), 512, 24);
            if (!isDefined(free))
                free = FindNearestDryNavFrom(self.origin);

            if (isDefined(free))
            {
                ShieldLog("^3[bo arm] bot " + n + " stuck 10 s, set on the navmesh close by");
                self setorigin((free[0], free[1], free[2] + 10));

                self.bo_search_goal = undefined;
                self.bo_next_goal_time = 0;
                self.bo_path_goal = undefined;
                self.bo_path_fails = 0;
            }

            stuckPos = self.origin;
            stuckSince = gettime();
        }

        if (!self HasRealGun())
        {
            self enableweapons();
            self GiveRandomPrimary();

            ShieldLog("^3[bo arm] bot " + n + " given a gun: " + self HasRealGun());
            continue;
        }

        // a gun on the back and empty hands: take it out
        if (!IsRealGun(self getcurrentweapon()) && !self isswitchingweapons())
        {
            gun = self FirstRealGun();

            if (isDefined(gun))
            {
                self enableweapons();
                self switchtoweapon(gun);
            }
        }
    }
}

// a weapon that shoots: not none, not the bare hands everyone holds after the drop
IsRealGun(w)
{
    if (!isDefined(w))
        return false;

    if (isDefined(level.weaponnone) && w == level.weaponnone)
        return false;

    if (isDefined(level.weaponbasemeleeheld) && w == level.weaponbasemeleeheld)
        return false;

    if (!isDefined(level.bo_bare_hands))
        level.bo_bare_hands = getweapon(#"bare_hands");

    if (isDefined(level.bo_bare_hands) && w == level.bo_bare_hands)
        return false;

    if (isDefined(w.name) && (w.name == #"none" || w.name == #"bare_hands" || w.name == #"null_offhand_primary"))
        return false;

    return true;
}

EnsureArmedImmediate()
{
    if (!isAlive(self))
        return;

    if (!CanArmNowFast())
    {
        self disableweapons();
        return;
    }

    self enableweapons();

    if (HasGun())
        return;

    t0 = gettime();
    while (gettime() - t0 < 4500)
    {
        if (!isAlive(self))
            return;

        if (!CanArmNowFast())
        {
            self disableweapons();
            return;
        }

        self enableweapons();

        if (HasGun())
            return;

        self enableweapons();
        self GiveRandomPrimary();
        self enableweapons();

        prims = self getweaponslistprimaries();
        if (isDefined(prims) && prims.size > 0)
            self switchtoweaponimmediate(prims[0]);

        if (HasGun())
            return;

        wait 0.18;
    }
}

EnsureArmedAfterLanding()
{
    self endon("disconnect");
    self endon("death");
    level endon("game_ended");

    self WaitForLanding_Safe();

    self ForceArmBurst(5000);

    burstStart = gettime();
    while (gettime() - burstStart < 4500)
    {
        if (!isAlive(self))
            return;

        if (!CanArmNow())
        {
            self disableweapons();
            wait 0.20;
            continue;
        }

        if (HasGun())
        {
            self enableweapons();
            break;
        }

        self enableweapons();
        self GiveRandomPrimary();
        self enableweapons();

        prims = self getweaponslistprimaries();
        if (isDefined(prims) && prims.size > 0)
            self switchtoweaponimmediate(prims[0]);

        if (HasGun())
            break;

        wait 0.20;
    }

    for (;;)
    {
        wait 7.0;

        if (!isAlive(self))
            continue;

        if (!CanArmNow())
        {
            self disableweapons();
            continue;
        }

        if (!HasGun())
        {
            self enableweapons();
            self GiveRandomPrimary();
            continue;
        }

        // ammo for the gun it has: a new random gun every 7 s meant a weapon swap, model and sound each time
        weapon = self getcurrentweapon();
        if (isDefined(weapon))
            self givemaxammo(weapon);
    }
}

WeaponWatchdogLoop()
{
    self endon("disconnect");
    self endon("death");
    level endon("game_ended");

    if (!isDefined(self.bo_weapon_watch_next))
        self.bo_weapon_watch_next = 0;

    for (;;)
    {
        if (isDefined(self.bo_insertion_active) && self.bo_insertion_active)
        {
            wait 0.25;
            continue;
        }
        if (!isAlive(self) || !isDefined(self.origin))
        {
            wait 0.25;
            continue;
        }

        if (gettime() < self.bo_weapon_watch_next)
        {
            wait 0.25;
            continue;
        }

        if (!IsLandedStable())
        {
            wait 0.25;
            continue;
        }

        if (!HasGun())
        {
            self.bo_weapon_watch_next = gettime() + 4500;

            wait 0.75;

            t0 = gettime();
            while (gettime() - t0 < 6000)
            {
                if (!isAlive(self))
                    return;

                if (HasGun())
                    break;

                self enableweapons();
                self GiveRandomPrimary();
                self enableweapons();

                prims = self getweaponslistprimaries();
                if (isDefined(prims) && prims.size > 0)
                    self switchtoweaponimmediate(prims[0]);

                if (HasGun())
                    break;

                wait 0.25;
            }
        }
        else
        {
            self.bo_weapon_watch_next = gettime() + 2500;
        }

        wait 0.25;
    }
}

ArmNow_OnSpawn()
{
    self endon("disconnect");
    self endon("death");
    level endon("game_ended");

    self WaitForLanding_Safe();

    wait 0.05;

    self ForceArmBurst(5500);
}

GroundSnap(pos)
{
    if (!isDefined(pos))
        return undefined;

    // from just over the point: from far up the trace stops on the roof above it
    start = (pos[0], pos[1], pos[2] + 72);
    end = (pos[0], pos[1], pos[2] - 20000);

    tr = bullettrace(start, end, 0, self);
    if (isDefined(tr) && isDefined(tr["position"]) && isDefined(tr["fraction"]) && tr["fraction"] < 0.999)
    {
        hit = tr["position"];
        return (hit[0], hit[1], hit[2] + 10);
    }

    return (pos[0], pos[1], pos[2] + 10);
}

RearmAfterRedeployLanding()
{
    self endon("disconnect");
    self endon("death");
    level endon("game_ended");

    if (!isDefined(self.bo_land_arm_cooldown_until))
        self.bo_land_arm_cooldown_until = 0;

    landedCount = 0;

    for (;;)
    {
        if (!isAlive(self) || !isDefined(self.origin))
        {
            wait 0.15;
            continue;
        }

        if (HasGun())
        {
            landedCount = 0;
            wait 0.35;
            continue;
        }

        if (IsLandedStable())
            landedCount++;
        else
            landedCount = 0;

        if (landedCount >= 8)
        {
            if (gettime() < self.bo_land_arm_cooldown_until)
            {
                wait 0.25;
                continue;
            }

            self.bo_land_arm_cooldown_until = gettime() + 4000;

            wait 0.90;

            t0 = gettime();
            while (gettime() - t0 < 5000)
            {
                if (!isAlive(self))
                    return;

                if (HasGun())
                    break;

                self enableweapons();
                self GiveRandomPrimary();
                self enableweapons();

                prims = self getweaponslistprimaries();
                if (isDefined(prims) && prims.size > 0)
                    self switchtoweaponimmediate(prims[0]);

                if (HasGun())
                    break;

                wait 0.25;
            }

            landedCount = 0;
        }

        wait 0.25;
    }
}