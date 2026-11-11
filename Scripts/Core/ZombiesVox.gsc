/*
    Voice lines of the zombies copies of the MP / Blackout characters (voices 40 up, shield-client custom_zones): they have
    no <suffix>_plr_<voice>_<n> takes, but aliases a kind (ZombiesVoxTable.gsc, BO4 Custom Maps build_zm_vox.py: their
    crew lines in support.all, the MP specialists' vox_zmc_<specialist>_<line>). A vox category (zm_audio's tables) is
    played as its kind, the quests' lines and any category no kind fits as "unsure"; the locations' and banter's none.
*/
ZombiesVoxKind(category, subcategory)
{
    if(subcategory === #"react" || subcategory === #"react_first")
     return "spot";

    switch(category)
    {
        case #"kill":
            if(subcategory === #"streak_self")
             return "taunt";
            if(isinarray(array(#"stoker", #"blight_father", #"specialround", #"wonder", #"homunculus", #"raygun", #"revenge"), subcategory))
             return "kill_special";
            return "kill";
        case #"revive":
            if(subcategory === #"down")
             return "downed";
            if(subcategory === #"support")
             return "revive";
            return "revived";
        case #"plr_ghost":
            return "revived";
        case #"general":
            if(subcategory === #"attacked")
             return "taking_fire";
            if(subcategory === #"outofmoney")
             return "fail";
            if(subcategory === #"rebuild_boards")
             return "success";
            if(subcategory === #"crawl_spawn")
             return "spot";
            return "taunt";
        case #"ammo":
            if(subcategory === #"buy")
             return "pickup";
            return "reload";
        case #"surrounded":
            return "taking_fire";
        case #"magicbox":
        case #"box":
            return "box";
        case #"perk":
            return "perk";
        case #"pap":
        case #"golden_pap":
            return "pap";
        case #"ww":
        case #"wonder":
            return "wonder";
        case #"weapon_pickup":
        case #"powerup":
        case #"component_pickup":
        case #"shield_pickup":
        case #"shield_piece":
        case #"pickup_catalyst":
            return "pickup";
        case #"shield":
            return "fail";
        case #"roundstart":
            return "ready";
        case #"challenge":
        case #"trap_activate":
            return "success";
        // the specialist weapon ready / out, an elixir (their characters have no lines of these: a kill line)
        case #"hero_ready":
        case #"hero_activate":
        case #"elixir":
        case #"bgb":
            return "kill";
        case #"boss":
        case #"blight_father":
        case #"stoker":
        case #"brutus":
        case #"werewolf":
        case #"nosferatu":
            return "spot";
        case #"location_enter":
        case #"gondola_banter":
        case #"crowd":
        case #"zomb_pers":
            return undefined;
    }
    return "unsure";
}

// a line of a kind of one of our voices, undefined without one
ZombiesVoxAlias(voice, kind)
{
    if(!isdefined(level.shield_zm_vox))
     level.shield_zm_vox = ZombiesVoxTable();
    if(!isdefined(voice) || !isdefined(kind) || !isdefined(level.shield_zm_vox[voice]))
     return undefined;
    // (the box, perks... as pickups for a table without them)
    if(!isdefined(level.shield_zm_vox[voice][kind]) && isinarray(array("box", "perk", "pap", "wonder"), kind))
     kind = "pickup";
    if(!isdefined(level.shield_zm_vox[voice][kind]))
     return undefined;
    return array::random(level.shield_zm_vox[voice][kind]);
}

// a player's zombies voice when it's one of ours
ZombiesVoxVoice()
{
    voice = self [[ @zm_characters<scripts\zm_common\zm_characters.gsc>::function_dc232a80 ]]();
    return (isdefined(voice) && voice >= 40) ? voice : undefined;
}

// zm_audio's: the takes each category's suffix has; ours one line a kind (vox.suffix -> kind)
detour zm_audio<scripts\zm_common\zm_audio.gsc>::function_654ec86b()
{
    if(!isdefined(level.sndplayervox))
     return;

    voice = self ZombiesVoxVoice();
    index = self [[ @zm_characters<scripts\zm_common\zm_characters.gsc>::function_dc232a80 ]]();
    prefix = "plr_" + index;
    self.shield_vox_voice = voice;
    self.shield_vox_kinds = [];
    foreach(category, a_category in level.sndplayervox)
    {
        foreach(subcategory, vox in a_category)
        {
            count = 0;
            if(isdefined(voice))
            {
                kind = ZombiesVoxKind(category, subcategory);
                if(isdefined(kind) && isdefined(ZombiesVoxAlias(voice, kind)))
                {
                    self.shield_vox_kinds[vox.suffix] = kind;
                    count = 1;
                }
            }
            else
            {
                count = [[ @zm_audio<scripts\zm_common\zm_audio.gsc>::get_number_variants ]](vox.suffix + "_" + prefix);
            }

            self.sound_dialog[vox.suffix] = [];
            self.sound_dialog_available[vox.suffix] = [];
            for(i = 0; i < count; i++)
            {
                self.sound_dialog[vox.suffix][i] = i;
                self.sound_dialog_available[vox.suffix][i] = i;
            }
            self.var_a9a870e2[category][subcategory] = 0;
        }
    }
}

// zm_audio's: the line of a suffix; ours its kind's alias
detour zm_audio<scripts\zm_common\zm_audio.gsc>::zmbvoxgetlinevariant(prefix, suffix, var_651f2941, force_variant)
{
    if(!isdefined(self.sound_dialog[suffix]) || !self.sound_dialog[suffix].size)
     return undefined;

    if(isdefined(force_variant))
    {
        variation = force_variant;
    }
    else
    {
        if(!(isdefined(var_651f2941) && var_651f2941) && !self.sound_dialog_available[suffix].size)
        {
            for(i = 0; i < self.sound_dialog[suffix].size; i++)
             self.sound_dialog_available[suffix][i] = self.sound_dialog[suffix][i];
        }
        if(!self.sound_dialog_available[suffix].size)
         return undefined;
        variation = array::random(self.sound_dialog_available[suffix]);
    }
    arrayremovevalue(self.sound_dialog_available[suffix], variation);
    self.var_fbbeefe6 = variation;

    if(isdefined(self.shield_vox_voice) && isdefined(self.shield_vox_kinds) && isdefined(self.shield_vox_kinds[suffix]))
     return ZombiesVoxAlias(self.shield_vox_voice, self.shield_vox_kinds[suffix]);
    return suffix + "_" + prefix + "_" + variation;
}

// zm_vo's quest line of the player (<line>_plr_<voice>): ours an "unsure" one
detour zm_vo<scripts\zm_common\zm_vo.gsc>::function_a2bd5a0c(var_cadd3b0c, n_delay = 0, b_wait_if_busy = 0, n_priority = 0, var_34e7887 = 0, var_d7714e4e = 0, var_67fee570 = 0)
{
    if(!isdefined(self) || !isplayer(self))
     return;

    voice = self ZombiesVoxVoice();
    if(isdefined(voice))
     str_vo_alias = ZombiesVoxAlias(voice, "unsure");
    else
     str_vo_alias = var_cadd3b0c + "_" + "plr_" + self [[ @zm_characters<scripts\zm_common\zm_characters.gsc>::function_dc232a80 ]]();

    if(!isdefined(str_vo_alias))
     return 0;
    a_variants = [[ @zm_audio<scripts\zm_common\zm_audio.gsc>::get_valid_lines ]](str_vo_alias);
    b_ret = self [[ @zm_vo<scripts\zm_common\zm_vo.gsc>::vo_say ]](array::random(a_variants), n_delay, b_wait_if_busy, n_priority, var_34e7887, var_d7714e4e, 0, var_67fee570);
    return isdefined(b_ret) && b_ret;
}

// the grunts of ours (zm_audio playerexert: hitmed / hitlrg of the player's voice)
SetZombiesVoxExerts(voice)
{
    alias = ZombiesVoxAlias(voice, "pain");
    if(!isdefined(alias))
     return;
    if(!isdefined(level.exert_sounds))
     level.exert_sounds = [];
    if(!isdefined(level.exert_sounds[voice]))
     level.exert_sounds[voice] = [];
    level.exert_sounds[voice][#"hitmed"] = alias;
    level.exert_sounds[voice][#"hitlrg"] = alias;
}

/*
    zm_audio's line playing: a line of ours (vox_zmc_ / vox_crew_ / vox_wesker_ / vox_kagan_) waits its time instead of the
    sound's "vo_done", which never came for them: the player stayed "speaking" after the first line and never spoke again
*/
detour zm_audio<scripts\zm_common\zm_audio.gsc>::play_vo_internal(str_sound, e_to_player)
{
    if(isdefined(self.shield_vox_voice) && isstring(str_sound))
    {
        self.str_vo_being_spoken = str_sound;
        self.var_4377124 = undefined;
        if(isplayer(self) && isentity(e_to_player))
         self playsoundtoplayer(str_sound, e_to_player);
        else if(isdefined(self gettagorigin("J_head")))
         self playsoundontag(str_sound, "J_head");
        else
         self playsound(str_sound);
        n_time = soundgetplaybacktime(str_sound);
        n_time = (isdefined(n_time) && n_time > 0) ? min(float(n_time) / 1000, 8) : 2.5;
        s = self waittilltimeout(n_time, #"vo_clear");
        if(s._notify != "vo_clear")
         self.var_4377124 = 1;
        return;
    }

    if(isstring(str_sound) || ishash(str_sound))
    {
        self.str_vo_being_spoken = str_sound;
        self.var_4377124 = undefined;
        if(isplayer(self) && isentity(e_to_player))
        {
            self playsoundtoplayer(str_sound, e_to_player);
            n_time = float(max(isdefined(soundgetplaybacktime(str_sound)) ? soundgetplaybacktime(str_sound) : 500, 500)) / 1000;
            s = self waittilltimeout(n_time, #"vo_clear");
        }
        else
        {
            if(isdefined(self gettagorigin("J_head")))
             self playsoundwithnotify(str_sound, "vo_done", "J_head");
            else
             self playsoundwithnotify(str_sound, "vo_done");
            s = self waittill(#"vo_done", #"vo_clear");
        }
        if(s._notify != "vo_clear")
         self.var_4377124 = 1;
    }
    else
    {
        waitframe(1);
    }
}
