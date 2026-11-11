/*
    Forced zombies character: a player picks one in the zombies character list (F, ZMForcedCharacter.lua), their HUD sends
    its role index (zm_character, 0 = none) and they play it on every map; without one, the map's cast as the game does.
    The support zone's zombies characters (every MP / Blackout character, shield-client custom_zones) are only reached
    this way: no map cast lists them.
*/
SetForcedZombiesCharacter(params)
{
    if(!sessionmodeiszombiesgame() || !isdefined(self) || !isdefined(params))
     return;

    if(params.menu !== #"shield_support_menu" || params.response !== #"zm_character")
     return;

    forced = params.intpayload;
    if(!ZombiesRoleExists(forced))
     forced = undefined;

    changed = self.shield_forced_role !== forced;
    self.shield_forced_role = forced;
    if(!isdefined(forced) || !changed || self.characterindex === forced)
     return;

    ShieldLog("^3Forced zombies character of " + self.name + ": " + forced);
    self [[ @zm_characters<scripts\zm_common\zm_characters.gsc>::set_character ]]();
    // its lines (ZombiesVox.gsc: zm_audio made the list at the spawn, with the last character's voice)
    self [[ @zm_audio<scripts\zm_common\zm_audio.gsc>::function_654ec86b ]]();
    self ApplyZombiesOutfit();
    BroadcastZombiesOutfits();
}

// a role of the zombies table (player_role::is_valid knows only the map's cast, level.validcharacters)
ZombiesRoleExists(index)
{
    return isdefined(index) && index > 0 && index < getplayerroletemplatecount(currentsessionmode()) && isdefined(getplayerrolefields(index, currentsessionmode()));
}

// a role outside the map's cast made valid (is_valid, zm_characters' voice and names read it)
AllowZombiesRole(index)
{
    [[ @zm_characters<scripts\zm_common\zm_characters.gsc>::get_characters ]]();
    if(!isdefined(level.validcharacters))
     level.validcharacters = [];
    if(!isinarray(level.validcharacters, index))
     level.validcharacters[level.validcharacters.size] = index;
}

// zm_characters' own, with the forced character first (over the map cast and the quest scripts' picks)
detour zm_characters<scripts\zm_common\zm_characters.gsc>::set_character(character)
{
    self detachall();
    [[ @zm_characters<scripts\zm_common\zm_characters.gsc>::get_characters ]]();
    if(ZombiesRoleExists(self.shield_forced_role))
    {
        AllowZombiesRole(self.shield_forced_role);
        self.characterindex = self.shield_forced_role;
    }
    else if(isdefined(character))
    {
        if(isarray(character))
         self.characterindex = [[ @zm_characters<scripts\zm_common\zm_characters.gsc>::function_9004475c ]](character);
        else
         self.characterindex = character;
    }

    if(!isdefined(self.characterindex) || !player_role::is_valid(self.characterindex))
    {
        self.characterindex = self function_b3a116a1();
        // a lobby pick outside the cast: the player's forced character (HostTeamSwitch.lua lets it through the lobby)
        if(self.characterindex != 0 && !player_role::is_valid(self.characterindex) && ZombiesRoleExists(self.characterindex))
         AllowZombiesRole(self.characterindex);
        if(self.characterindex == 0)
         self.characterindex = [[ @zm_characters<scripts\zm_common\zm_characters.gsc>::function_b04c6f1f ]]();
        self.pers[#"characterindex"] = self.characterindex;
    }

    player_role::set(self.characterindex);
    self.favorite_wall_weapons_list = [];
    self.talks_in_danger = 0;
    self setcharacterbodytype(self.characterindex);
    self setcharacteroutfit(0);

    // the per-character banter names: none for a character the game doesn't know (they'd stay the last one's)
    self.revivevox = undefined;
    self [[ @zm_characters<scripts\zm_common\zm_characters.gsc>::function_50b1ae32 ]]();
    if(!isdefined(self.revivevox))
    {
        self.revivevox = "shld";
        self.var_ff5f8752 = "self";
        self.var_c107ed3 = "support_shld";
        self.var_d10fb794 = "surrounded_shld";
        self.var_eee02beb = "streak_shld";
    }

    if(!isdefined(level.var_6f14e9e1))
     level.var_6f14e9e1 = [];
    else if(!isarray(level.var_6f14e9e1))
     level.var_6f14e9e1 = array(level.var_6f14e9e1);
    if(!isinarray(level.var_6f14e9e1, self))
     level.var_6f14e9e1[level.var_6f14e9e1.size] = self;

    voice = self [[ @zm_characters<scripts\zm_common\zm_characters.gsc>::function_dc232a80 ]]();
    if(!isdefined(voice))
     return;

    // ours (40 up) don't fit the charindex clientfield (4 bits): the client's exerts stay the default ones
    if(voice >= 40)
    {
        self.player_exert_id = voice;
        self clientfield::set("charindex", 0);
        SetZombiesVoxExerts(voice);
        return;
    }
    self [[ @zm_audio<scripts\zm_common\zm_audio.gsc>::setexertvoice ]](voice);
}
