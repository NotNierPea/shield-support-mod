GetBotSkinRandom() 
{
    // temp fix 
    
    while(true)
    {
        random_roll = randomIntRange(1, 134); // 1 - 134 row lists (random skin data)
        randomskin_data = tablelookuprow(#"gamedata/shield/randomutils/mp_randombots.csv", random_roll);

        if(!isDefined(randomskin_data))
         continue;

        ShieldLog("^6Bot Random Data Enter... -> " + int(randomskin_data[0]) + " " + int(randomskin_data[1]) + " " + int(randomskin_data[2]));

        // returns an array of the current row..
        return randomskin_data;
    }
}

GetBotCamoRandom() 
{
    random_roll = randomIntRange(1, 87); // 1 - 119 row lists (random camo data)
    randomscamo_data = tablelookuprow(#"gamedata/shield/randomutils/mp_randombots_camos.csv", random_roll);
    
    return randomscamo_data;
}

/*
    A bot's look, picked once a match: half of them one of ours (ShieldBotLook: our characters in any outfit, our outfits on
    the game's; the table's rows are the game's only). It was kept on the entity, which a round's restart clears: each round
    a new look, while the game kept the last character elsewhere (a Scarlett bot spoke with a Blackout Default Character's
    voice). Now in pers, which lasts the match
*/
BotPickLook()
{
    if(!isDefined(self.pers[#"shield_bot_look"]))
    {
        look = undefined;
        if(randomint(2) == 0)
         look = ShieldBotLook();
        if(!isDefined(look))
         look = GetBotSkinRandom();
        self.pers[#"shield_bot_look"] = look;
    }
    self.random_data = self.pers[#"shield_bot_look"];
}

// bots take their look's character in the draft, where the game gives them theirs, and the same way (player_role::set)
BotTakeLook()
{
    if(!isbot(self))
     return;
    self BotPickLook();
    role = int(self.random_data[0]);
    if(self getspecialistindex() != role)
     self [[ @player_role<scripts\core_common\player\player_role.gsc>::set ]](role, true);
}

detour draft<scripts\mp_common\draft.gsc>::assign_remaining_players(only_assign_player)
{
    result = [[ @draft<scripts\mp_common\draft.gsc>::assign_remaining_players ]](only_assign_player);
    if(isDefined(only_assign_player))
     only_assign_player BotTakeLook();
    else
    {
        foreach(player in level.players)
         player BotTakeLook();
    }
    return result;
}

SetRandomSkin()
{
    self endon(#"disconnect", #"spawned_player");
    level endon(#"end_game", #"game_ended");
    
    wait 0.35; // delay a little

    /* <- BROKEN!

        if (!IsVec(self.random_data))
        {
            ShieldLog("^1what the fuck? -> " + self.random_data[0] + " " + self.random_data[1] + " " + self.random_data[2]);
            return;
        }

    */

    self BotPickLook();

    // the char id: a bot without a draft (in mid-match) takes it here, with what player_role::set keeps beside it (no class)
    role = int(self.random_data[0]);
    if(self getspecialistindex() != role)
    {
        self.pers[#"characterindex"] = role;
        self setspecialistindex(role);
        self.playerrole = self getrolefields();
        if(isDefined(world.playerroles))
         world.playerroles[self getentitynumber()] = role;
    }

    // skin id
    self setcharacteroutfit(int(self.random_data[1]));

    // skin palette id
    self function_ab96a9b5("palette", int(self.random_data[2]));
}

SetRandomCamos()
{
    self endon(#"spawned_player", #"disconnect", #"death");
    level endon(#"end_game", #"game_ended");

    // setcamo is a gsc func..

    self waittill(#"WeaponRandomChanged");

    wait 1;

    weapon = self GetCurrentWeapon();
    offhand = self GetCurrentOffhand();

    if (isdefined(weapon)) 
    {
        // its a fucking array somehow
        camo_id = GetBotCamoRandom();

        if(isdefined(camo_id))
            self setcamo(weapon, camo_id[0]);

        //ShieldLog("Camo Bot Change -> " + camo_id[0]);
    }

    if (isdefined(offhand)) 
    {
        camo_id = GetBotCamoRandom();

        if(isdefined(camo_id))
            self setcamo(offhand, camo_id[0]);

        //ShieldLog("Camo Bot Change -> " + camo_id[0]);
    }

    //if(isdefined(weapon))
        //ShieldLog("^2Weapon Camo Change -> " + camo_id[0]);
}

SetRandomAttachments()
{
    self endon(#"spawned_player", #"disconnect", #"death");
    level endon(#"end_game", #"game_ended");

    weapon = self GetCurrentWeapon();
    offhand = self GetCurrentOffhand();

    if (!isdefined(weapon) || !isdefined(weapon.supportedattachments) && isDefined(self.no_randomattch) && self.no_randomattch)
    {
        self notify(#"WeaponRandomChanged");
        //ShieldLog("^1No Attch");
        return;
    }

    attachments = getWeaponAttachments(weapon);
    weapon_options = self getweaponoptions(weapon);

    // if already done
    if(isDefined(self.random_attachments))
    {
        new_weapon = getweapon(weapon.name, self.random_attachments);

        self takeweapon(weapon);
        self giveweapon(new_weapon, weapon_options);

        //ShieldLog("^3Attch Reuse");

        self notify(#"WeaponRandomChanged");
        return;
    }

    // roll
    if(randomIntRange(1, 20) < 6)
    {
        self.no_randomattch = true;
        self notify(#"WeaponRandomChanged");
        return;
    }

    if (!isdefined(attachments))
        attachments = array();

    foreach (attachment in weapon.supportedattachments) 
    {
        if (attachment == "null" || attachment == "none")
         continue; // we don't want them
        
        if (array::contains(attachments, attachment))
         continue;
        
        // roll ig
        if(randomIntRange(1, 20) < 7)
         continue;

        array::add(attachments, attachment, true);
    }
    
    new_weapon = getweapon(weapon.name, attachments);

    // no randoms everytime
    self.random_attachments = attachments;
    
    if (!isdefined(new_weapon))
    {
        self notify(#"WeaponRandomChanged");
        return;
    }
    
    self takeweapon(weapon);
    self giveweapon(new_weapon, weapon_options);

    //ShieldLog("^4Attch New");
    self notify(#"WeaponRandomChanged");
}