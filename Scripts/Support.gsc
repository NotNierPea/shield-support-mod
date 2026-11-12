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
    {
        // freerun's HUD and music on zombies maps too (Support.csc's, same place)
        FreerunRegisterFields();
        thread ZMChanges();
    }

    if(SessionModeIsMultiplayerGame() || sessionmodeiswarzonegame())
    {
        level thread CustomCharacterDialog();
        callback::on_spawned(&CharacterOutfitOnSpawned);
        if(sessionmodeismultiplayergame())
        {
            // picks of characters past the 17 for the draft (Support.csc PatchDraftCharacter)
            clientfield::register("allplayers", "shield_custom_a", 1, 30, "int");
            clientfield::register("allplayers", "shield_custom_b", 1, 30, "int");
            clientfield::register("allplayers", "shield_custom_c", 1, 16, "int");
            callback::on_connect(&ShieldCustomizationOnConnect);
            // freerun's HUD and music, every match (Support.csc's after the same three)
            FreerunRegisterFields();
        }
    }
}

// enemies' kill lines for our characters' dialog bundles (shield-client "dialog"): a key no bundle has (no line), not
// an undefined one (dialog_shared get_random_key indexes the key counts with it); a crew bundle's own name is its
// shieldcallout, as Blackout's DOTN ones (crew_<who>_wz) share their MP callout lines
CustomCharacterDialog()
{
    while(!isdefined(level.bcsounds) || !isdefined(level.bcsounds[#"kill_dialog"]))
     waitframe(1);

    // our characters: the dialog bundles with "shieldcallout" (their own name, the prefix of their callout aliases
    // vox_<prefix>_sgc_<kind>; Wesker, BO4 Custom Maps' build_crew_vox.py crews)
    level.shield_callout_voices = [];
    foreach(bundle in getscriptbundles("mpdialog_player"))
    {
        if(!isdefined(bundle) || !isdefined(bundle.shieldcallout))
         continue;
        // (by its own name: getmpdialogname)
        name = hash(isdefined(bundle.name) ? bundle.name : bundle.shieldcallout);
        level.shield_callout_voices[name] = bundle.shieldcallout;
        level.bcsounds[#"kill_dialog"][name] = "killShieldCharacter";
    }
    // (Wesker's bundle before it had the field)
    if(!isdefined(level.shield_callout_voices[#"wesker"]))
     level.shield_callout_voices[#"wesker"] = "wesker";
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

// each player's character and outfit for the HUDs (OutfitPortraits.lua: an outfit of ours' own pictures, Peeks'): the
// spawned player's to everyone, everyone's to them (not every pair at every spawn: Blackout has a hundred players)
CharacterOutfitOnSpawned()
{
    self endon(#"disconnect");
    waitframe(1);

    // a multiplayer character past the loadout's 17: its picks put on again at each spawn (MenuReponses.gsc
    // SetShieldCustomization), before its outfit is told to the HUDs
    if(sessionmodeismultiplayergame())
     self ApplyShieldCustomization();

    players = getplayers();
    foreach(other in players)
    {
        if(!isdefined(other))
         continue;
        SendCharacterOutfit(self, other);
        if(other != self)
         SendCharacterOutfit(other, self);
    }
}

/*
    A multiplayer character past the loadout's 17: the draft and ready screens show each player's look as the server has it
    (bots' random looks too), not their picks: asked of the client at the connection (they come during the draft) and put
    on as soon as the player picks the character, before any spawn
*/
ShieldCustomizationOnConnect()
{
    self endon(#"disconnect");

    if(!isdefined(self.shield_custom_asked))
    {
        self.shield_custom_asked = 1;
        self thread AskShieldCustomization();
    }

    last = -1;
    for(;;)
    {
        role = self getspecialistindex();
        if(isdefined(role) && role !== last)
        {
            last = role;
            self thread ReapplyShieldCustomization();
        }
        wait 0.25;
    }
}

// a character picked: its look put on, then again a few times (the game puts the profile's back on after a pick)
ReapplyShieldCustomization()
{
    self notify(#"shield_reapply");
    self endon(#"shield_reapply", #"disconnect");

    foreach(delay in array(0, 0.5, 1, 2, 3))
    {
        if(delay > 0)
         wait delay;
        self ApplyShieldCustomization();
    }
}

// the client's picks asked until they come (the host's HUD may not listen yet)
AskShieldCustomization()
{
    self endon(#"disconnect");

    // (a few seconds apart: the client sends its picks a few at a time, its end marker stops this)
    for(tries = 0; tries < 6 && !isdefined(self.shield_custom_done); tries++)
    {
        self luinotifyevent(#"shield_custom_request", 0);
        wait 5;
    }
}

// a player's character (getspecialistindex) and outfit to another's HUD: client, character, outfit
SendCharacterOutfit(player, to)
{
    if(!isdefined(player) || !isdefined(to) || !isplayer(player) || !isplayer(to))
     return;
    role = player getspecialistindex();
    if(!isdefined(role))
     return;
    outfit = player getcharacteroutfit();
    if(!isdefined(outfit))
     outfit = 0;
    to luinotifyevent(#"shield_outfit", 3, player getentitynumber(), role, outfit);
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

// the prefix of the player's callout lines when they're one of ours (level.shield_callout_voices), else undefined
CharacterCalloutVoice(player)
{
    dialog = player getmpdialogname();
    if(!isdefined(dialog) || !isdefined(level.shield_callout_voices))
     return undefined;
    if(isstring(dialog))
     dialog = hash(dialog);
    return level.shield_callout_voices[dialog];
}

// a callout (an sgc_* bundle: acknowledge, need help, flanking...) in our character's voice, else the game's
CustomCharacterCallout(callout, teamonly)
{
    voice = (isdefined(self) && isplayer(self) && isdefined(callout)) ? CharacterCalloutVoice(self) : undefined;
    if(isdefined(voice))
    {
        self thread CharacterCallout(callout, voice);
        return;
    }

    self [[level.shield_stock_callout]](callout, teamonly);
}

CharacterCallout(callout, voice)
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

    kind = undefined;
    switch(name)
    {
        case #"sgc_acknowledge":
            kind = "acknowledge";
            break;
        case #"sgc_coverme":
        case #"sgc_needhelp":
        case #"sgc_needhelp_ffa":
            kind = "help";
            break;
        case #"sgc_groupup":
            kind = "groupup";
            break;
        case #"sgc_hello":
            kind = "hello";
            break;
        case #"sgc_nicework":
        case #"sgc_thanks":
        case #"sgc_ffa_gg":
            kind = "nicework";
            break;
        case #"sgc_ffa_bringit":
        case #"sgc_ffa_nicetry":
        case #"sgc_warzone_taunt":
            kind = "taunt";
            break;
        case #"sgc_flanking_tdm":
        case #"sgc_bounty_flanking":
        case #"sgc_control_flanking":
        case #"sgc_ctf_flanking":
        case #"sgc_escort_flank":
        case #"sgc_sd_flanking":
            kind = "flanking";
            break;
        case #"sgc_ctf_defending":
        case #"sgc_koth_defending":
        case #"sgc_escort_base":
            kind = "defending";
            break;
        case #"sgc_warzone_item":
            kind = "item";
            break;
        default:
            // the objectives (dom, sd, control, koth, ctf grabbing, bounty, escort robot): moving on one
            kind = "attacking";
            break;
    }

    // its alias vox_<voice>_sgc_<kind>, hashed as the bank names it
    self playsoundontag(hash("vox_" + voice + "_sgc_" + kind), "J_Head");
}

// a scorestreak's request line (killstreaks.gsc: its requestdialogkey, the futz one), logged for ours
CustomCharacterStreakDialog(dialogkey, futzkey)
{
    if(isdefined(self) && isplayer(self) && IsDialogOf(self, #"wesker"))
    {
        // (the key is a hash: not put in the text, a hash in a string is "unmatching types")
        bundle = getscriptbundle(#"wesker");
        alias = (isdefined(bundle) && isdefined(dialogkey)) ? bundle.(dialogkey) : undefined;
        ShieldLog("^3Wesker scorestreak line: key " + (isdefined(dialogkey) ? "set" : "undefined") + ", alias " + (isdefined(alias) ? "found" : "undefined")
            + ", specialist dialog " + (isdefined(level.allowspecialistdialog) && level.allowspecialistdialog ? "on" : "off") + ", current " + (isdefined(self.currentkillstreakdialog) ? "set" : "none"));
    }

    self [[level.shield_stock_streak_dialog]](dialogkey, futzkey);
}

// the game's own roles of this mode's table (multiplayer 17, Blackout 76): ours come after them (shield-client custom_zones)
ShieldStockRoleCount()
{
    return sessionmodeiswarzonegame() ? 76 : 17;
}

/*
    Our characters' roles for bots (the random bot looks were the game's characters only): the enabled roles after the
    table's (multiplayer from 15: 15 is a placeholder that's off, 16 Wesker's replaced row)
*/
ShieldBotRoles()
{
    if(isdefined(level.shield_bot_roles))
     return level.shield_bot_roles;
    mode = currentsessionmode();
    roles = [];
    first = sessionmodeiswarzonegame() ? ShieldStockRoleCount() : 15;
    count = getplayerroletemplatecount(mode);
    for(i = first; i < count; i++)
    {
        fields = getplayerrolefields(i, mode);
        if(isdefined(fields) && isdefined(fields.var_422e172f) && fields.var_422e172f)
         roles[roles.size] = i;
    }
    level.shield_bot_roles = roles;
    ShieldLog("^3Bot characters of ours: " + roles.size);
    return roles;
}

/*
    Our characters' specialist lines where the game has none for them: a kill with the specialist weapon (the Ripper, the
    War Machine at their kill count...) and an equipment that worked play the weapon's sound events (playsoundevent),
    silent for ours; a specialist weapon of ours (Wesker's Samurai Edge) has no case in the ready / activate lines. Their
    kill line (their bundle's killGeneric) instead. The kit's ready / activate keys are in their bundles
    (BO4 Custom Maps/Core/tools/ability_dialog.py)
*/
IsShieldCharacter(player)
{
    return isdefined(player) && isplayer(player) && isdefined(CharacterCalloutVoice(player)) && !player hasperk(#"specialty_quieter");
}

IsShieldSpecialistWeapon(weapon)
{
    if(!isdefined(weapon))
     return false;
    custom = array(#"wesker_samurai_edge", #"jacket_the_punch", #"jacket_the_punch_projectile");
    return isinarray(custom, weapon.name) || (isdefined(weapon.rootweapon) && isinarray(custom, weapon.rootweapon.name));
}

/*
    Bots use a specialist weapon only when its name is registered (mp_bot_action.gsc: Seraph's Annihilator, Spectre's
    Ripper...): our copies as the weapons they copy (Wesker's Samurai Edge the Annihilator, Jacket's bat the Ripper)
*/
RegisterShieldBotWeapons()
{
    level endon(#"game_ended");
    // (after mp_bot_action's main: its actions and weapons registered, the Ripper's among them)
    for(i = 0; i < 1200 && !(isdefined(level.botweapons) && isdefined(level.botweapons[#"sig_blade"])); i++)
     waitframe(1);
    if(!isdefined(level.botweapons) || !isdefined(level.botweapons[#"sig_blade"]))
     return;

    weapons = [];
    weapons[#"wesker_samurai_edge"] = @bot_action<scripts\core_common\bots\bot_action.gsc>::function_2c39b990;
    weapons[#"jacket_the_punch"] = @bot_action<scripts\core_common\bots\bot_action.gsc>::function_1879a202;
    foreach(name, activate in weapons)
    {
        [[ @bot_action<scripts\core_common\bots\bot_action.gsc>::function_f4302f2a ]](name, activate, @bot_action<scripts\core_common\bots\bot_action.gsc>::function_ec16df22);
        [[ @bot_action<scripts\core_common\bots\bot_action.gsc>::function_7e847a84 ]](name, #"hash_5397239dd3c8da8d");
        [[ @bot_action<scripts\core_common\bots\bot_action.gsc>::function_a2c83569 ]](name, #"hash_7aaeac32a4e1bf84");
        [[ @bot_action<scripts\core_common\bots\bot_action.gsc>::function_a2c83569 ]](name, #"hash_434716893aa869f3");
    }
}

ShieldKillLine(delay, victim)
{
    self endon(#"death", #"disconnect", #"cancel_kill_dialog");
    level endon(#"game_ended");
    if(isdefined(delay) && delay > 0)
     wait delay;
    if(!isdefined(self) || !isalive(self))
     return;
    self thread [[ @battlechatter<scripts\mp_common\gametypes\battlechatter.gsc>::play_dialog ]]("killGeneric", 2, undefined, victim);
}

detour battlechatter<scripts\mp_common\gametypes\battlechatter.gsc>::function_e6457410(attacker, victim, weapon, inflictor)
{
    played = [[ @battlechatter<scripts\mp_common\gametypes\battlechatter.gsc>::function_e6457410 ]](attacker, victim, weapon, inflictor);
    if(!IsShieldCharacter(attacker) || !isplayer(victim) || !isdefined(weapon))
     return played;
    if(played || (isdefined(weapon.isheroweapon) && weapon.isheroweapon) || IsShieldSpecialistWeapon(weapon))
    {
        attacker thread ShieldKillLine(0.5, victim);
        return 1;
    }
    return played;
}

detour battlechatter<scripts\mp_common\gametypes\battlechatter.gsc>::play_gadget_success(weapon, waitkey, victim, var_5d738b56)
{
    if(!IsShieldCharacter(self))
    {
        [[ @battlechatter<scripts\mp_common\gametypes\battlechatter.gsc>::play_gadget_success ]](weapon, waitkey, victim, var_5d738b56);
        return;
    }
    // (the stock marks a played success: it played for ours only when it set the mark again)
    before = self.playedgadgetsuccess;
    self.playedgadgetsuccess = undefined;
    [[ @battlechatter<scripts\mp_common\gametypes\battlechatter.gsc>::play_gadget_success ]](weapon, waitkey, victim, var_5d738b56);
    if(isdefined(self) && self.playedgadgetsuccess === 1)
     self thread ShieldKillLine(0, victim);
    else if(isdefined(self))
     self.playedgadgetsuccess = before;
}

detour battlechatter<scripts\mp_common\gametypes\battlechatter.gsc>::play_gadget_ready(weapon, userflip = 0)
{
    if(IsShieldCharacter(self) && IsShieldSpecialistWeapon(weapon))
    {
        self thread ShieldKillLine(0, undefined);
        return;
    }
    [[ @battlechatter<scripts\mp_common\gametypes\battlechatter.gsc>::play_gadget_ready ]](weapon, userflip);
}

detour battlechatter<scripts\mp_common\gametypes\battlechatter.gsc>::play_gadget_activate(weapon)
{
    if(IsShieldCharacter(self) && IsShieldSpecialistWeapon(weapon))
    {
        self thread ShieldKillLine(0, undefined);
        return;
    }
    [[ @battlechatter<scripts\mp_common\gametypes\battlechatter.gsc>::play_gadget_activate ]](weapon);
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
    // a freerun match (Freerun.gsc): only when the client says so
    level thread FreerunInit();

    // the skill of the bots, from the bot settings of the menu
    level BotSkillInit();

    // our characters' specialist weapons for bots
    level thread RegisterShieldBotWeapons();

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
    // a freerun match (Freerun.gsc): only when the client says so
    level thread FreerunInit();
    // for zm reactive camo fix
    callback::on_spawned(&ZMReactiveFix);

    // outfits of ours picked (MenuReponses.gsc): zm_characters sets outfit 0 at each spawn
    callback::on_spawned(&ZombiesOutfitOnSpawned);
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