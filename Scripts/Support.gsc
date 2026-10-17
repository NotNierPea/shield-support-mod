#include scripts\core_common\system_shared;
#include scripts\core_common\clientfield_shared;
#include scripts\core_common\util_shared;
#include scripts\core_common\flag_shared;
#include scripts\core_common\bots\bot.gsc;
#include scripts\core_common\array_shared.gsc;
#include scripts\core_common\callbacks_shared.gsc;
#include scripts\core_common\player\player_role;

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