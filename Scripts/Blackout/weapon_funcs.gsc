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

GiveRandomPrimary()
{
    if (!isDefined(level.AllBlackoutWeapons))
        return;

    if (level.AllBlackoutWeapons.size <= 0)
        return;

    idx = randomint(level.AllBlackoutWeapons.size);
    wname = level.AllBlackoutWeapons[idx];

    if (!isDefined(wname) || wname == "")
        return;

    self GivePrimarySafe(wname);
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

        prims = self getweaponslistprimaries();
        if (isDefined(prims))
        {
            foreach (pw in prims)
                self takeweapon(pw);
        }

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

    prims = self getweaponslistprimaries();
    if (isDefined(prims) && prims.size > 0)
        return true;

    cw = self getcurrentweapon();
    if (isDefined(cw) && cw != "none")
        return true;

    all = self getweaponslist();
    if (isDefined(all) && all.size > 0)
        return true;

    return false;
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

        prims = self getweaponslistprimaries();
        if (isDefined(prims))
        {
            foreach (pw in prims)
                self takeweapon(pw);
        }

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

        self GiveRandomPrimary();
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

    start = (pos[0], pos[1], pos[2] + 4096);
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