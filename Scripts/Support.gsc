#include scripts\core_common\system_shared;
#include scripts\core_common\clientfield_shared;
#include scripts\core_common\util_shared;
#include scripts\core_common\flag_shared;
#include scripts\core_common\bots\bot.gsc;
#include scripts\core_common\array_shared.gsc;
#include scripts\core_common\callbacks_shared.gsc;
#include scripts\core_common\player\player_role;
#include scripts\core_common\gestures;

#namespace SupportGSC;

autoexec InitSystem() 
{
    if(util::is_frontend_map())
     return;

    // fix specialists hq mode
    if(IsSubStr(GetDvarString("ls_gametype", "none"), "COMBAT") || function_bea73b01() == 4)
    {
        ShieldLog("^1HQ Mode, Returned.... (GSC)");
        return;
    }

    compiler::detour();
    system::register("SupportGSC", &Init, &PostInit, undefined);

    if(SessionModeIsZombiesGame())
     thread PreZMChanges();
}

PreZMChanges()
{
    if (getDvarInt(#"shield_offline_perks", 1))
    {
        setDvar(#"hash_49EF5478510B5AF3", 0); // perk_zombshell
        setDvar(#"hash_4E1190045EF3588B", 0); // perk_wolf_protector
        setDvar(#"hash_1C1A8ED8D0BF271C", 0); // perk_death_dash

        ShieldLog("^2Online Perks Disabled..");
    }
}

Init()
{
    ShieldLog("^1Support GSC Loaded!");

    if (sessionmodeiswarzonegame())
     thread WZChanges();

    if(SessionModeIsMultiplayerGame())
     thread MPChanges();

    if(SessionModeIsZombiesGame())
     thread ZMChanges();

    if(SessionModeIsMultiplayerGame() || sessionmodeiswarzonegame())
     level thread CustomCharacterDialog();
}

// enemies' kill lines for our characters' dialog bundles (shield-client "dialog"): a key no bundle has (no line), not
// an undefined one (dialog_shared get_random_key indexes the key counts with it)
CustomCharacterDialog()
{
    while(!isdefined(level.bcsounds) || !isdefined(level.bcsounds[#"kill_dialog"]))
     waitframe(1);

    level.bcsounds[#"kill_dialog"][#"wesker"] = "killWesker";

    // battlechatter's callout (level.var_17d1b660) picks a line by the specialist's name and has none for ours; its
    // scorestreak request (level.var_cb4eb1d1) is wrapped to log what ours resolve
    while(!isdefined(level.var_17d1b660) || !isdefined(level.var_cb4eb1d1))
     waitframe(1);

    level.shield_stock_callout = level.var_17d1b660;
    level.var_17d1b660 = &CustomCharacterCallout;
    level.shield_stock_streak_dialog = level.var_cb4eb1d1;
    level.var_cb4eb1d1 = &CustomCharacterStreakDialog;
}

// the player's dialog bundle is this one (getmpdialogname: its name, a string or a hash)
IsDialogOf(player, name)
{
    dialog = player getmpdialogname();
    if(!isdefined(dialog))
     return false;
    if(isstring(dialog))
     dialog = hash(dialog);
    return dialog == name;
}

// a callout (an sgc_* bundle: acknowledge, need help, flanking...) in our character's voice, else the game's
CustomCharacterCallout(callout, teamonly)
{
    if(isdefined(self) && isplayer(self) && isdefined(callout) && IsDialogOf(self, #"wesker"))
    {
        self thread WeskerCallout(callout);
        return;
    }

    self [[level.shield_stock_callout]](callout, teamonly);
}

WeskerCallout(callout)
{
    self notify(#"shield_callout");
    self endon(#"shield_callout", #"death", #"disconnect");

    // (battlechatter's calloutTriggerDelay)
    wait 0.2;

    if(!isdefined(self) || !isalive(self) || self isplayerunderwater() || (isdefined(self.playingdialog) && self.playingdialog))
     return;

    name = callout.name;
    if(isstring(name))
     name = hash(name);

    alias = undefined;
    switch(name)
    {
        case #"sgc_acknowledge":
            alias = #"vox_wesker_sgc_acknowledge";
            break;
        case #"sgc_coverme":
        case #"sgc_needhelp":
        case #"sgc_needhelp_ffa":
            alias = #"vox_wesker_sgc_help";
            break;
        case #"sgc_groupup":
            alias = #"vox_wesker_sgc_groupup";
            break;
        case #"sgc_hello":
            alias = #"vox_wesker_sgc_hello";
            break;
        case #"sgc_nicework":
        case #"sgc_thanks":
        case #"sgc_ffa_gg":
            alias = #"vox_wesker_sgc_nicework";
            break;
        case #"sgc_ffa_bringit":
        case #"sgc_ffa_nicetry":
        case #"sgc_warzone_taunt":
            alias = #"vox_wesker_sgc_taunt";
            break;
        case #"sgc_flanking_tdm":
        case #"sgc_bounty_flanking":
        case #"sgc_control_flanking":
        case #"sgc_ctf_flanking":
        case #"sgc_escort_flank":
        case #"sgc_sd_flanking":
            alias = #"vox_wesker_sgc_flanking";
            break;
        case #"sgc_ctf_defending":
        case #"sgc_koth_defending":
        case #"sgc_escort_base":
            alias = #"vox_wesker_sgc_defending";
            break;
        case #"sgc_warzone_item":
            alias = #"vox_wesker_sgc_item";
            break;
        default:
            // the objectives (dom, sd, control, koth, ctf grabbing, bounty, escort robot): moving on one
            alias = #"vox_wesker_sgc_attacking";
            break;
    }

    self playsoundontag(alias, "J_Head");
}

// a scorestreak's request line (killstreaks.gsc: its requestdialogkey, the futz one), logged for ours
CustomCharacterStreakDialog(dialogkey, futzkey)
{
    if(isdefined(self) && isplayer(self) && IsDialogOf(self, #"wesker"))
    {
        bundle = getscriptbundle(#"wesker");
        alias = (isdefined(bundle) && isdefined(dialogkey)) ? bundle.(dialogkey) : undefined;
        ShieldLog("^3Wesker scorestreak line: key " + (isdefined(dialogkey) ? dialogkey : "undefined") + ", alias " + (isdefined(alias) ? "found" : "undefined")
            + ", specialist dialog " + (isdefined(level.allowspecialistdialog) && level.allowspecialistdialog ? "on" : "off") + ", current " + (isdefined(self.currentkillstreakdialog) ? "set" : "none"));
    }

    self [[level.shield_stock_streak_dialog]](dialogkey, futzkey);
}

PostInit() 
{
    callback::on_connect(&AddMenuReponses);
}

WZChanges()
{
    // no dvar means the slider was never moved: no bots
    if (getDvarInt(#"shield_wz_bots_num", 0) > 0)
        level BotsInitWZ();
}

MPChanges()
{
    // the skill of the bots, from the bot settings of the menu
    level BotSkillInit();

    // lua option...
    if (getdvarint(#"shield_botsrandom", 1))
    {
        // make sure
        ShieldLog("^3Bots Random Check Passed");

        callback::on_spawned(&MpBotOnSpawned);
    }
}

ZMChanges()
{
    // for zm reactive camo fix
    callback::on_spawned(&ZMReactiveFix);
}

ZMOnSpawned()
{
    
}

MpBotOnSpawned()
{
    self endon(#"disconnect", #"spawned_player");
    level endon(#"end_game", #"game_ended");

    if(!IsBot(self))
     return;

    // bot funcs here
    self thread SetRandomSkin();
    self thread SetRandomCamos();
    self thread SetRandomAttachments();
}

detour serversettings<scripts\mp_common\gametypes\serversettings.gsc>::init()
{
    ShieldLog("^2Server Settings Init...");

    [[ @serversettings<scripts\mp_common\gametypes\serversettings.gsc>::init ]]();

    // force it with gamesetting in lua
    level.allow_teamchange = getgametypesetting(#"allowingameteamchange");
}

detour bot<scripts\mp_common\bots\mp_bot.gsc>::init()
{
    // fix specialists hq mode
    if(IsSubStr(GetDvarString("ls_gametype", "none"), "COMBAT") || function_bea73b01() == 4)
    {
        ShieldLog("^1HQ Bot Mode, Returned....");

        [[ @bot<scripts\mp_common\bots\mp_bot.gsc>::init ]]();

        return;
    }

    level endon(#"game_ended");

    ShieldLog("^2Bot Init -> Called");

    // the plan of the bots, for every variant of an objective mode
    level thread BotObjectiveCommander();
    botsoak = getdvarint(#"sv_botsoak", 0);

    if (!isdedicated()) 
    {
        //if (level.rankedmatch) {
            //return;
        //}
    }
    
    if (!botsoak)
        level flag::wait_till("all_players_connected");
    
    level thread [[ @bot<scripts\core_common\bots\bot.gsc>::populate_bots ]]();
    level thread [[ @region_utility<scripts\core_common\ai\region_utility.gsc>::function_755c26d1 ]]();
}

detour util<scripts\core_common\util_shared.gsc>::function_8570168d()
{
    // fix specialists hq mode
    if(IsSubStr(GetDvarString("ls_gametype", "none"), "COMBAT") || function_bea73b01() == 4)
    {
        //ShieldLog("^1HQ Mode, Returned....");
        return [[ @util<scripts\core_common\util_shared.gsc>::function_8570168d ]]();
    }

    //ShieldLog("^2Gamemode Check -> Called (GSC)");

    /*
    if (sessionmodeismultiplayergame()) 
    {
        mode = function_bea73b01();
        if (mode == 4)
            return true;
    }
    */

    // by the skill of the menu when one is picked there
    difficulty = BotSkillGameDifficulty();

    switch (difficulty)
    {
        case 0:
            level.var_df0a0911 = "bot_tacstate_mp_easy";
            break;
        case 1:
        default:
            level.var_df0a0911 = "bot_tacstate_mp_normal";
            break;
        case 2:
            level.var_df0a0911 = "bot_tacstate_mp_hard";
            break;
        case 3:
            level.var_df0a0911 = "bot_tacstate_mp_veteran";
            break;
    }

    if (difficulty == 0) {
        level.var_6679b27c = 202500;
    } else if (difficulty == 1) {
        level.var_6679b27c = 360000;
    } else if (difficulty == 2) {
        level.var_6679b27c = 640000;
    } else if (difficulty == 3) {
        level.var_6679b27c = 1000000;
    }

    // ruthless: a dog tag is picked up from further away
    if (getDvarInt(#"shield_bot_skill", 0) >= 5)
        level.var_6679b27c = 2250000;

    // return false anyways
    return false;
}

detour stats<scripts\core_common\player\player_stats.gsc>::function_f94325d3()
{
    //ShieldLog("^3try stat...");
    player = self;
    //assert(isplayer(player), "<dev string:x59>");

    if (isbot(player))
        return false;

    if (isdefined(level.disablestattracking) && level.disablestattracking) {
        ShieldLog("^3return false called, but return true anyways...");

        // return true anyways
        return true;
    }

    // no dedicated server check: a host of ours is never one, and the stats (character unlocks too) would not save
    if (sessionmodeiswarzonegame()) {
        if (getdvarint(#"scr_disable_merits", 0) == 1) {
            return false;
        }
        if (!isdefined(game.state) || game.state == "pregame") {
            return false;
        }
    }
    return true;
}

// the character missions run in online ranked matches only: in ours too, unless the game setting turns them off
detour character_unlock<scripts\wz_common\character_unlock.gsc>::function_b3681acb()
{
    return !isdefined(level.var_b3681acb) || level.var_b3681acb;
}

detour challenges<scripts\core_common\challenges_shared.gsc>::canprocesschallenges()
{
    /#
        if (getdvarint(#"scr_debug_challenges", 0)) {
            return true;
        }
    #/

    //ShieldLog("^1canprocesschallenges return true...");

    //if (level.rankedmatch || level.arenamatch || sessionmodeiscampaigngame()) {
        return true;
    //}
    //return false;
}