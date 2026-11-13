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
    // a freerun match (Freerun.gsc): the characters say nothing
    if(isdefined(level.shield_freerun) && isplayer(self))
     return;

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

/*
    Tag der Toten: after Stuhlinger's line, Richtofen's voice in his head (<suffix>_plr_5_<n>, to him only) when that take
    exists. The crews' port (build_crew_vox PORT_MAPS) put Blood of the Dead's Richtofen takes in support.all under those
    names, so he answered nearly every line with an unrelated one. Those takes, minus Tag's own, are left out here
    (generated from en_zm_orange's bank and crew_vox_zm_escape: PORT_TAKES 4).
*/
TagPortedRichtofen()
{
    if(isdefined(level.shield_tag_ported_rich))
     return level.shield_tag_ported_rich;

    table = [];
    table[#"hash_112938160e7b4685"] = array(0, 1, 2);
    table[#"hash_1550216483f19c05"] = array(0, 1, 2, 3);
    table[#"hash_177f84e5ae1e8fb0"] = array(0, 1, 2, 3);
    table[#"hash_1aaf29f9cf9eef2d"] = array(0, 1, 2, 3);
    table[#"hash_1ad536f33d26c1e"] = array(0, 1, 2);
    table[#"hash_1af1cb6f41edb6aa"] = array(0, 1, 2);
    table[#"hash_1efab4e86747e0f6"] = array(0, 1, 2, 3);
    table[#"hash_21a1f69b7e5aaeb5"] = array(0, 1, 2, 3);
    table[#"hash_27d522e5c7eeb98e"] = array(0, 1, 2, 3);
    table[#"hash_2827e3552e08123a"] = array(0, 1, 2, 3);
    table[#"hash_2993a1bebafd90da"] = array(0, 1, 2, 3);
    table[#"hash_2bf1a19afc40c22"] = array(0, 1, 2, 3);
    table[#"hash_2dd5b49e52028171"] = array(0, 1, 2, 3);
    table[#"hash_3275aa90df6248e5"] = array(0, 1, 2, 3);
    table[#"hash_3551fbc9b3f5944f"] = array(0, 1, 2, 3);
    table[#"hash_3cf43f66b71287e5"] = array(0, 1, 2, 3);
    table[#"hash_413d2b04ac7f26f5"] = array(0, 1, 2, 3);
    table[#"hash_43bbef358d7a1d56"] = array(0, 1, 3);
    table[#"hash_43d252dd310e2faa"] = array(0, 1, 2, 3);
    table[#"hash_4786995ab050fb66"] = array(0, 1);
    table[#"hash_4d495ea70e8796d2"] = array(0, 1, 2, 3);
    table[#"hash_4e13db19dbbf2c1b"] = array(0, 1, 2, 3);
    table[#"hash_502a3f3d1bfa0eb4"] = array(0, 1, 2, 3);
    table[#"hash_590768598ed5de66"] = array(0, 1, 3);
    table[#"hash_5a7e23f64d8bf2d0"] = array(1, 2, 3);
    table[#"hash_5d2536424f8ba08f"] = array(0, 1, 2, 3);
    table[#"hash_606bb418a1c0c4ab"] = array(0, 2, 3);
    table[#"hash_60ee94b66b1e2a2c"] = array(0, 1, 2, 3);
    table[#"hash_61ee7a1e5b4c68c7"] = array(0, 1, 2, 3);
    table[#"hash_63607819569316e2"] = array(0, 1, 2, 3);
    table[#"hash_64cec410aa8c7c07"] = array(0, 1, 2, 3);
    table[#"hash_6a3bc88911e7d909"] = array(0, 1, 2, 3);
    table[#"hash_6b40a7049f54fb5a"] = array(0, 1, 2, 3);
    table[#"hash_6ca1deacc4f61926"] = array(0, 1, 2, 3);
    table[#"hash_6ebb5fa1f7952f56"] = array(2, 3);
    table[#"hash_6f4d706590e9b576"] = array(0, 1, 2, 3);
    table[#"hash_6f559168aa8ea661"] = array(0, 1, 2, 3);
    table[#"hash_71ef2a712e8d604e"] = array(0, 1, 2, 3);
    table[#"hash_76e6219b46c03451"] = array(0, 1, 2);
    table[#"hash_76f4575ce0e25a41"] = array(0, 1, 2);
    table[#"hash_7ac52bd1c0323ee4"] = array(0, 1, 2, 3);
    table[#"hash_7ca7854be193ea3a"] = array(0, 1, 2, 3);
    table[#"hash_7de6d37e9ad03518"] = array(0, 1, 2, 3);
    table[#"hash_7e030fccc2c5a121"] = array(0, 1, 2, 3);
    table[#"hash_9106b6f37a4fff0"] = array(0, 1, 2);
    table[#"hash_ba7882c4633fd2"] = array(0, 1, 2, 3);
    table[#"hash_cddf5fea0108c90"] = array(0, 1, 2, 3);

    level.shield_tag_ported_rich = [];
    foreach(suffix, variants in table)
    {
        foreach(n in variants)
         level.shield_tag_ported_rich[suffix + "_plr_5_" + n] = 1;
    }
    return level.shield_tag_ported_rich;
}

// zm_orange_util's line of a common / map table category for Stuhlinger: his take, then Richtofen's when Tag has one
detour zm_orange_util<scripts\zm\zm_orange_util.gsc>::function_8123b826(str_category, var_39acfdda)
{
    self [[ @zm_audio<scripts\zm_common\zm_audio.gsc>::play_vo_internal ]](self.str_vo_being_spoken, undefined);
    if(isdefined(self.var_fbbeefe6) && isdefined(level.sndplayervox[str_category]) && isdefined(level.sndplayervox[str_category][var_39acfdda]))
    {
        vox = level.sndplayervox[str_category][var_39acfdda];
        str_alias = vox.suffix + "_plr_5_" + self.var_fbbeefe6;
        if(!isdefined(TagPortedRichtofen()[str_alias]) && soundexists(str_alias))
         self [[ @zm_audio<scripts\zm_common\zm_audio.gsc>::play_vo_internal ]](str_alias, self);
    }
    return 1;
}
