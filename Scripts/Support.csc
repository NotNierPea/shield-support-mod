#include scripts\core_common\system_shared.csc;
#include scripts\core_common\clientfield_shared.csc;
#include scripts\core_common\util_shared.csc;
#include scripts\core_common\flag_shared.csc;
#include scripts\core_common\struct.csc;

#namespace SupportCSC;

autoexec InitSystem() 
{
    if(util::is_frontend_map())
    {
        // the camera of the cookbook menu of the zombies laboratory, see Cookbook.lua
        level thread CookbookCamera(0);
        // the zombies lobby's character plays the lobby gesture wheel's picks, see ZMLobbyGestures.lua
        level thread ZombiesLobbyGestures(0);
        return;
    }

    // fix specialists hq mode
    if(IsSubStr(GetDvarString("ls_gametype", "none"), "COMBAT") || function_bea73b01() == 4)
    {
        ShieldLog("^1HQ Mode, Returned.... (CSC)");
        return;
    }

    compiler::detour();
    
    system::register("SupportCSC", &Init, &PostInit, undefined);
}

Init()
{
    ShieldLog("^1Support CSC Loaded!");

    if(SessionModeIsMultiplayerGame())
    {
        // (Support.gsc's, same order)
        clientfield::register("allplayers", "shield_custom_a", 1, 30, "int", &ShieldCustomChanged, 0, 0);
        clientfield::register("allplayers", "shield_custom_b", 1, 30, "int", &ShieldCustomChanged, 0, 0);
        clientfield::register("allplayers", "shield_custom_c", 1, 16, "int", &ShieldCustomChanged, 0, 0);
        // freerun's (Freerun.csc), Support.gsc's order
        FreerunRegisterFields();
        // the end of match podium (Podium.csc), Support.gsc's order
        PodiumRegisterFields();
    }
    else if(SessionModeIsZombiesGame())
    {
        // freerun's on zombies maps (Support.gsc's)
        FreerunRegisterFields();
    }
}

// a player's picks changed: the draft reads its players again (as at a pick)
ShieldCustomChanged(localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump)
{
    if(oldval === newval)
     return;
    s = spawnstruct();
    s.localclientnum = localclientnum;
    level notify(#"positiondraft_update", s);
}

/*
    The draft's character of a player (its data: function_82e05d64, var_d781e2e4) puts on the look of their public profile
    (var_c018da16, function_79a48799), which has no picks for characters past the 17: those of the clientfields
    (MenuReponses.gsc SetShieldCustomFields) put in it first. Its items go by the engine's order: arms, decal, head,
    headgear, legs, palette, torso, war paint.
*/
detour draft<scripts\mp_common\draft.csc>::function_93a4f3c5(localclientnum, draftcharacter)
{
    PatchDraftCharacter(draftcharacter);
    return [[ @draft<scripts\mp_common\draft.csc>::function_93a4f3c5 ]](localclientnum, draftcharacter);
}

/*
    The zombies ready-up screen stands each player's character at the spot of its scene (its role's draftscene): two
    characters with the same spot stood in each other (a bot's Bruno and our characters on Bruno IX, a forced Shadow Man
    and a cast character, a leftover Scarlett). The whole lobby's spots are worked out together (ZombiesLobbyScenes):
    each keeps its own when free, else takes a free one; this one gets its spot, and the others whose spot changed are
    updated too (they would wait for their own next update, standing in each other until then).
*/
detour draft<scripts\core\gametypes\frontend_draft.csc>::function_93a4f3c5(localclientnum, draftcharacter, characterselected = 0)
{
    // update_team gives every local xuid local client 0's focused character (function_89e574c): the splitscreen guest
    // showed the host's, in the host's scene and spot. The guest shows its own pick
    if(isdefined(draftcharacter) && isdefined(draftcharacter.var_d781e2e4) && ZombiesIsGuestXuid(draftcharacter.var_d781e2e4.xuid))
     draftcharacter.var_d781e2e4.focusedcharacterindex = undefined;

    result = [[ @draft<scripts\core\gametypes\frontend_draft.csc>::function_93a4f3c5 ]](localclientnum, draftcharacter, characterselected);
    if(!sessionmodeiszombiesgame() || !isdefined(draftcharacter) || !isdefined(draftcharacter.var_d781e2e4))
     return result;

    spots = ZombiesLobbyScenes(localclientnum);
    if(!isdefined(spots))
     return result;

    if(ZombiesTakeScene(draftcharacter, spots))
     result = 1;

    foreach(other in level.draftcharacters)
    {
        // (one without a role keeps the spot for its own next update: updating it here is an "invalid session mode")
        if(isdefined(other) && other !== draftcharacter && ZombiesTakeScene(other, spots) && ZombiesHasRole(other))
         other [[ @namespace_7da27482<scripts\core_common\character_customization.csc>::update ]](other.var_d781e2e4.params);
    }
    ZombiesLogDraft();
    ZombiesPublishSpots();
    // and once the scenes have placed the models
    level notify(#"shield_draft_log");
    level thread ZombiesLogDraftSoon();
    return result;
}

ZombiesLogDraftSoon()
{
    level endon(#"shield_draft_log");
    wait 1;
    ZombiesLearnSpots();
    // two seen in one place: the spots again, with what was learned
    spots = ZombiesLobbyScenes(0);
    if(isdefined(spots))
    {
        foreach(character in level.draftcharacters)
        {
            if(isdefined(character) && ZombiesTakeScene(character, spots) && ZombiesHasRole(character))
             character [[ @namespace_7da27482<scripts\core_common\character_customization.csc>::update ]](character.var_d781e2e4.params);
        }
    }
    ZombiesLogDraft();
    ZombiesPublishSpots();
}

/*
    Splitscreen lobby spots (diagnostics): every draft character's slot, xuid, focused index (the local player's
    highlighted character, put on every local xuid), shown role, visibility, scene (its place in level.shield_zm_scenes,
    -1 none, -2 not listed) and model position. Logged when any of it changes.
*/
ZombiesLogDraft()
{
    if(!isdefined(level.draftcharacters))
     return;
    line = "";
    foreach(i, character in level.draftcharacters)
    {
        if(!isdefined(character) || !isdefined(character.var_d781e2e4))
         continue;
        data = character.var_d781e2e4;
        shown = data.var_435f68bc;
        type = (isdefined(shown) && isdefined(shown.charactertype)) ? shown.charactertype : -1;
        scene = -1;
        if(isdefined(data.params) && isdefined(data.params.scene))
        {
            scene = -2;
            if(isdefined(level.shield_zm_scenes))
            {
                foreach(k, known in level.shield_zm_scenes)
                {
                    if(known === data.params.scene)
                     scene = k;
                }
            }
        }
        visible = character [[ @namespace_7da27482<scripts\core_common\character_customization.csc>::is_visible ]]();
        origin = isdefined(character.var_228f64da) ? character.var_228f64da.origin : (0, 0, 0);
        line = line + " [" + i + " xuid " + (isdefined(data.xuid) ? data.xuid : 0) + " focus " + (isdefined(data.focusedcharacterindex) ? data.focusedcharacterindex : -1)
            + " role " + type + " vis " + visible + " scene " + scene + " at " + origin + "]";
    }
    if(line !== level.shield_draft_log)
    {
        level.shield_draft_log = line;
        ShieldLog("^3zm lobby draft:" + line);
    }
}

// a splitscreen guest's xuid (shield-client splitscreen.cpp): the controller in the high byte, never set for a real one
ZombiesIsGuestXuid(xuid)
{
    if(!isdefined(xuid) || xuid == 0)
     return 0;
    return ((xuid >> 56) & 255) != 0;
}

// whether a draft character shows a role (charactertype > 0)
ZombiesHasRole(draftcharacter)
{
    shown = draftcharacter.var_d781e2e4.var_435f68bc;
    return isdefined(shown) && isdefined(shown.charactertype) && shown.charactertype > 0;
}

// a draft character to its lobby spot (from ZombiesLobbyScenes); whether its scene changed
ZombiesTakeScene(draftcharacter, spots)
{
    data = draftcharacter.var_d781e2e4;
    if(!isdefined(data) || !isdefined(data.params))
     return 0;

    foreach(spot in spots)
    {
        if(spot.character === draftcharacter)
        {
            if(data.params.scene === spot.scene)
             return 0;
            data.params.scene = spot.scene;
            ShieldLog("^3zm lobby spot: draft slot " + (isdefined(data.var_fb564576) ? data.var_fb564576 : -1) + " xuid " + (isdefined(data.xuid) ? data.xuid : 0) + " moved");
            return 1;
        }
    }
    return 0;
}

/*
    Splitscreen: the draft's updates come from each local client's own events (positiondraft_update), and the guest's ran
    the update as local client 1: its xuid order and PositionDraftClients against local client 0's draft characters, the
    guest's character stood in the host's spot with both name tags on it. The draft is local client 0's in the frontend.
*/
detour draft<scripts\core\gametypes\frontend_draft.csc>::update_team(localclientnum, characterselected = 0)
{
    if(localclientnum != 0)
    {
        ShieldLog("^3zm lobby: draft update of local client " + localclientnum + " run as local client 0");
        localclientnum = 0;
    }
    return [[ @draft<scripts\core\gametypes\frontend_draft.csc>::update_team ]](localclientnum, characterselected);
}

/*
    The lobby's 3D widgets (the select class one, the tags) follow LobbyClients.<n>.entNum, and LobbyClients.<n> is the
    player frontend.csc put in LobbyClientPose.<n-1> (its own xuid list). frontend_draft gives draft character i
    LobbyClients.<i+1> instead (its update_team's list, another order with a splitscreen guest or bots), and writes
    entNum only once: a player's widget stood at whoever had their number (nobody's, the guest's or the host's spot).
    A zombies draft character takes the LobbyClients entry of its own xuid, and its entNum is written every time.
*/
detour draft<scripts\core\gametypes\frontend_draft.csc>::function_e1f85a64(var_87c045d1, index, var_3f0e790b)
{
    data = isdefined(var_87c045d1) ? var_87c045d1.var_d781e2e4 : undefined;
    if(!sessionmodeiszombiesgame() || !isdefined(data) || !isdefined(data.xuid) || data.xuid == 0)
     return [[ @draft<scripts\core\gametypes\frontend_draft.csc>::function_e1f85a64 ]](var_87c045d1, index, var_3f0e790b);

    poses = getuimodel(getglobaluimodel(), "LobbyClientPose");
    if(isdefined(poses))
    {
        for(k = 0; k < 16; k++)
        {
            pose = getuimodel(poses, k);
            if(isdefined(pose) && ZombiesSameXuid(getuimodelvalue(pose), data.xuid))
            {
                if(k != index)
                 ShieldLog("^3zm lobby: draft slot " + index + " xuid " + data.xuid + " takes lobby client " + (k + 1));
                index = k;
                break;
            }
        }
    }
    result = [[ @draft<scripts\core\gametypes\frontend_draft.csc>::function_e1f85a64 ]](var_87c045d1, index, var_3f0e790b);
    if(isdefined(data.var_90ba8f6f))
     setuimodelvalue(data.var_90ba8f6f, var_87c045d1 [[ @namespace_7da27482<scripts\core_common\character_customization.csc>::function_47cb6b19 ]]());
    return result;
}

// the scene of a zombies role (its draftscene, as frontend_draft.csc reads it), undefined without one
ZombiesRoleScene(index)
{
    fields = getcharacterfields(index, currentsessionmode());
    if(isdefined(fields) && isdefined(fields.draftscene))
     return fields.draftscene;
    return (isdefined(fields) && isdefined(fields.var_e297151a)) ? fields.var_e297151a : undefined;
}

/*
    Every shown draft character's spot, [{character, scene}]: the game's characters first (the cast, bots), then ours
    (roles 30 up), each in slot order its own spot when free, else the first free one. From the draft's characters, not
    the lobby's xuids: those were another list than the draft's in a game lobby, and bots stood in players' spots.
*/
ZombiesLobbyScenes(localclientnum)
{
    if(!isdefined(level.shield_zm_scenes))
    {
        // the IX crew's spots first
        level.shield_zm_scenes = [];
        foreach(index in array(13, 14, 15, 16, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29))
        {
            scene = ZombiesRoleScene(index);
            if(isdefined(scene) && !isinarray(level.shield_zm_scenes, scene))
             level.shield_zm_scenes[level.shield_zm_scenes.size] = scene;
        }
    }

    if(!isdefined(level.draftcharacters))
     return undefined;
    players = [];
    foreach(character in level.draftcharacters)
    {
        if(!isdefined(character) || !isdefined(character.var_d781e2e4))
         continue;
        shown = character.var_d781e2e4.var_435f68bc;
        // (the class's method by its namespace: an empty slot's model is hidden)
        if(!(character [[ @namespace_7da27482<scripts\core_common\character_customization.csc>::is_visible ]]()))
         continue;
        type = (isdefined(shown) && isdefined(shown.charactertype) && shown.charactertype > 0) ? shown.charactertype : 0;
        // a player's one without a role (a splitscreen guest before its pick) still takes a free spot, not the host's;
        // an empty slot (no xuid, no session mode to update with) is left alone
        if(type == 0)
        {
            data = character.var_d781e2e4;
            if(!isdefined(data.xuid) || data.xuid == 0 || !isdefined(data.params) || !isdefined(data.params.sessionmode))
             continue;
        }
        xuid = character.var_d781e2e4.xuid;
        // (function_89e574c: a local player's xuid, as frontend_draft's update_team asks)
        mine = isdefined(xuid) && xuid != 0 && function_89e574c(xuid);
        players[players.size] = {#character:character, #type:type, #mine:mine};
    }

    /*
        (taken: the places the scenes stand their character at, not the scenes: the crews' scenes share 4 places.) This PC's
        players keep their own first: the select class widget stays at a local player's own spot, a forced character moved
        off it stood away from its widget. Then the game's characters, then ours.
    */
    spots = [];
    taken = [];
    foreach(pass in array(0, 1, 2))
    {
        foreach(player in players)
        {
            if(pass == 0 ? !player.mine : (player.mine || (player.type >= 30) != (pass == 2)))
             continue;
            scene = player.type > 0 ? ZombiesRoleScene(player.type) : undefined;
            if(isdefined(scene) && isinarray(taken, ZombiesSceneSpot(scene)))
             scene = undefined;
            if(!isdefined(scene))
            {
                foreach(free in level.shield_zm_scenes)
                {
                    if(!isinarray(taken, ZombiesSceneSpot(free)))
                    {
                        scene = free;
                        break;
                    }
                }
            }
            if(!isdefined(scene))
             continue;
            taken[taken.size] = ZombiesSceneSpot(scene);
            spots[spots.size] = {#character:player.character, #scene:scene};
        }
    }
    return spots;
}

/*
    Where a draft scene stands its character: the scene bundle's align target (the crews' scenes use the same 4 places, a
    bot's Bruno and the host's Scarlett IX stood in one), else the place it was seen putting one (ZombiesLearnSpots), else
    the scene itself.
*/
ZombiesSceneSpot(scene)
{
    if(!isdefined(level.shield_scene_spots))
     level.shield_scene_spots = [];
    if(isdefined(level.shield_scene_spots[scene]))
     return level.shield_scene_spots[scene];

    spot = undefined;
    bundle = getscriptbundle(scene);
    if(isdefined(bundle))
    {
        if(isdefined(bundle.aligntarget))
         spot = bundle.aligntarget;
        if(!isdefined(spot) && isdefined(bundle.objects))
        {
            foreach(object in bundle.objects)
            {
                if(isdefined(object.aligntarget))
                 spot = object.aligntarget;
                if(!isdefined(spot) && isdefined(object.shots))
                {
                    foreach(shot in object.shots)
                    {
                        if(isdefined(shot.aligntarget))
                        {
                            spot = shot.aligntarget;
                            break;
                        }
                    }
                }
                if(isdefined(spot))
                 break;
            }
        }
    }
    if(isdefined(spot))
    {
        level.shield_scene_spots[scene] = spot;
        // (a scene name or align target may be a hash: only its place in the list is printed)
        ShieldLog("^3zm lobby: scene " + ZombiesSceneIndex(scene) + " has an align target");
        return spot;
    }
    if(isdefined(level.shield_scene_seen) && isdefined(level.shield_scene_seen[scene]))
     return level.shield_scene_seen[scene];
    return scene;
}

/*
    The select class widget stands in one of 4 columns, by the stock crew place of the local player's character
    (CoD.ZombieUtility.OrderCharacterButtonZMList: niko / scar column 1, demp / brun 2...): a character moved to another
    place, or one of ours, was in column 1. For each shown character (by its character index, unique in a lobby), the
    stock role whose scene it plays goes in ShieldDraftSpotRole.<character>, and ShieldDraftSpotRole.changed counts the
    changes: ZMForcedCharacter.lua orders the columns by them.
*/
ZombiesPublishSpots()
{
    if(!sessionmodeiszombiesgame() || !isdefined(level.draftcharacters))
     return;
    out = createuimodel(getglobaluimodel(), "ShieldDraftSpotRole");
    changed = 0;
    line = "";
    foreach(character in level.draftcharacters)
    {
        data = isdefined(character) ? character.var_d781e2e4 : undefined;
        if(!isdefined(data) || !ZombiesHasRole(character) || !isdefined(data.params) || !isdefined(data.params.scene))
         continue;
        type = data.var_435f68bc.charactertype;
        role = ZombiesSceneRole(data.params.scene);
        model = createuimodel(out, "" + type);
        if(getuimodelvalue(model) !== role)
        {
            setuimodelvalue(model, role);
            changed = 1;
        }
        line = line + " [character " + type + " at role " + role + "'s place]";
    }
    if(changed)
    {
        ShieldLog("^3zm lobby spots for the select class columns:" + line);
        counter = createuimodel(out, "changed");
        value = getuimodelvalue(counter);
        setuimodelvalue(counter, (isdefined(value) ? value : 0) + 1);
    }
}

// a LobbyClientPose value (a string of the xuid: the menus compare it with Engine.XUIDToString) against a draft xuid
ZombiesSameXuid(value, xuid)
{
    if(!isdefined(value) || !isdefined(xuid) || xuid == 0)
     return 0;
    if(value === xuid)
     return 1;
    return isstring(value) && value == ("" + xuid);
}

// the stock role a scene belongs to (the first of the crews' list that plays it), 0 none
ZombiesSceneRole(scene)
{
    foreach(index in array(13, 14, 15, 16, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29))
    {
        if(ZombiesRoleScene(index) === scene)
         return index;
    }
    return 0;
}

// a scene's place in level.shield_zm_scenes, -1 when not listed
ZombiesSceneIndex(scene)
{
    if(isdefined(level.shield_zm_scenes))
    {
        foreach(k, known in level.shield_zm_scenes)
        {
            if(known === scene)
             return k;
        }
    }
    return -1;
}

// the place each shown draft character's scene put it (once settled): for scenes without an align target
ZombiesLearnSpots()
{
    if(!isdefined(level.draftcharacters))
     return;
    if(!isdefined(level.shield_scene_seen))
     level.shield_scene_seen = [];
    foreach(character in level.draftcharacters)
    {
        if(!isdefined(character) || !isdefined(character.var_d781e2e4) || !isdefined(character.var_228f64da) || !ZombiesHasRole(character))
         continue;
        scene = character.var_d781e2e4.params.scene;
        if(!isdefined(scene) || (isdefined(level.shield_scene_spots) && isdefined(level.shield_scene_spots[scene])))
         continue;
        origin = character.var_228f64da.origin;
        place = "" + int(origin[0] / 8) + " " + int(origin[1] / 8);
        if(level.shield_scene_seen[scene] !== place)
        {
            level.shield_scene_seen[scene] = place;
            ShieldLog("^3zm lobby: scene " + ZombiesSceneIndex(scene) + " seen at " + place);
        }
    }
}

PatchDraftCharacter(draftcharacter)
{
    if(!isdefined(draftcharacter) || !isdefined(draftcharacter.var_d781e2e4))
     return;
    data = draftcharacter.var_d781e2e4;
    if(!isdefined(data.player) || !isdefined(data.var_c018da16) || !isdefined(data.var_c018da16.charactertype))
     return;

    a = data.player clientfield::get("shield_custom_a");
    if(!isdefined(a) || a % 2 == 0 || int(a / 2) % 128 != data.var_c018da16.charactertype)
     return;
    b = data.player clientfield::get("shield_custom_b");
    c = data.player clientfield::get("shield_custom_c");
    if(!isdefined(b))
     b = 0;
    if(!isdefined(c))
     c = 0;

    character = data.var_c018da16;
    character.outfit = int(a / 256) % 64;
    character.warpaintoutfit = int(a / 16384) % 64;
    if(!isdefined(character.outfititems))
     character.outfititems = [];
    character.outfititems[0] = int(b / 4096) % 64; // arms
    character.outfititems[1] = int(c / 256) % 256; // decal
    character.outfititems[2] = b % 64; // head
    character.outfititems[3] = int(b / 64) % 64; // headgear
    character.outfititems[4] = int(b / 16777216) % 64; // legs
    character.outfititems[5] = c % 256; // palette
    character.outfititems[6] = int(b / 262144) % 64; // torso
    character.outfititems[7] = int(a / 1048576) % 1024; // war paint
}

PostInit()
{

}

/*
    The map of the frontend has a key frame for a camera on the cookbook of the laboratory, zm_lab_book_camera at
    (-1259, -3547, 764) looking (350, 166, 0), which no xcam with a known name plays. An xcam is played from a
    place and a direction, so the xcam of the laboratory is used, turned and moved until its camera stands there:
    that camera is the key frame zm_lab_camera, (-1259, -3536, 763) looking (349, 261, 0), played from
    tag_align_zm_lab at (-1282, -3565, 634). Turned by 166 - 261 = -95 around that place, the camera is 26.9 and
    -25.4 from it, and 129 over it: the place is the key frame of the book less that.
    The menu of the cookbook says when it opens and closes. The four dvars move the camera while it is tried out.

    The menu shows the elixirs of its recipe as their bottles, the models of the game: it names them in models of
    the UI and says "models", and they are put in front of the camera, where the menu left windows for them. With
    "mix" the three of the recipe go into the book, and "made" brings them back with the one they made turning.
    The bottles are placed again every frame by where the camera is: they are there at once and go with the camera
    while it moves to the book, and the dvars that tune them work while they are shown.
*/
/*
    The zombies lobby (room "zombie") shows one character, the frozen moment's: ZMLobbyGestures.lua sends the lobby
    wheel's picks (-1 stops). A spray plays the spraying animation only (play_gesture -1): no overhead name there to
    show its icon on. play_gesture stops the character's scene and plays it again after, as on the draft's characters.
*/
ZombiesLobbyGestures(localclientnum)
{
    level endon(#"disconnect");

    for(;;)
    {
        waitresult = level waittill("shield_zm_lobby_gesture" + localclientnum);
        character = level.frozen_moment_character;

        if(level.lastlobbystate !== "zombie" || !isdefined(character) || !isdefined(waitresult.gesture_index))
            continue;

        index = waitresult.gesture_index;
        character notify(#"cancel_gesture");

        if(index < 0)
            continue;

        // (the class's method by its namespace: the compiler has no class calls)
        character thread [[ @namespace_7da27482<scripts\core_common\character_customization.csc>::play_gesture ]](isgesture(index) ? index : -1, 1, 1, 0);
    }
}

CookbookCamera(localclientnum)
{
    level.shield_cookbook_bottles = [];

    // The dvars of the bottles get their values, so the console shows them. What was set before is kept, unless it
    // was for windows of the menu that have since moved: shield_cookbook_layout says for which.
    layout = 4;
    renew = getdvarint(#"shield_cookbook_layout", 0) != layout;

    // the four bottles, then the burst and the glow
    for(i = 0; i < 6; i++)
    {
        if(i < 4)
        {
            dvars = CookbookBottleDvars(i);
            values = CookbookBottleDefaults(i);
        }
        else
        {
            dvars = CookbookFxDvars(i - 4);
            values = CookbookFxDefaults(i - 4);
        }

        for(j = 0; j < dvars.size; j++)
        {
            if(renew || getdvarstring(dvars[j], "") == "")
            {
                setdvar(dvars[j], values[j]);
            }
        }
    }

    setdvar(#"shield_cookbook_layout", layout);

    for(;;)
    {
        waitresult = level waittill("shield_cookbook" + localclientnum);

        camera_ent = struct::get("tag_align_zm_lab");

        if(!isdefined(camera_ent))
        {
            ShieldLog("^1Cookbook: the laboratory has no camera to move");
            continue;
        }

        if(waitresult.status === "opened")
        {
            origin = (-1285.9 + getdvarfloat(#"shield_cookbook_x", 0), -3521.6 + getdvarfloat(#"shield_cookbook_y", 0), 635 + getdvarfloat(#"shield_cookbook_z", 0));
            angles = (0, -95 + getdvarfloat(#"shield_cookbook_yaw", 0), 0);

            // A little to the right and up of the key frame: a stand-in bottle of the game is left of the book, and the
            // book is to be in the middle between the panels. The camera looks along 166, so its right is (0.242, 0.970).
            shift_right = getdvarfloat(#"shield_cookbook_right", 6);
            shift_up = getdvarfloat(#"shield_cookbook_up", 3.5);
            origin += (0.242 * shift_right, 0.97 * shift_right, shift_up);

            ShieldLog("^3Cookbook: camera on the book");
            level.shield_cookbook_opened = gettime();
            playmaincamxcam(localclientnum, "ui_scene_cam_zm_lab", 400, "", "", origin, angles);
        }
        else if(waitresult.status === "models")
        {
            level thread CookbookShowBottles(localclientnum, waitresult.controller, false, waitresult.rarity);
        }
        else if(waitresult.status === "made")
        {
            level thread CookbookShowBottles(localclientnum, waitresult.controller, true, waitresult.rarity);
        }
        else if(waitresult.status === "mix")
        {
            CookbookMixBottles(localclientnum);
        }
        else
        {
            // bottles that still wait for the camera are not put any more
            level notify("shield_cookbook_show");
            CookbookRemoveBottles();

            ShieldLog("^3Cookbook: camera back on the laboratory");
            playmaincamxcam(localclientnum, "ui_scene_cam_zm_lab", 400, "", "", camera_ent.origin, camera_ent.angles);
        }
    }
}

/*
    A place in front of the camera, by where it is on the screen: across and up from the middle, 1 at the edge.
    The camera is asked where it is and how it looks, the key frame of the book is only taken when it does not say.
    Half of the view across has a tangent of about 0.7, found by trying it in the game, and the height of a screen of
    16 by 9 is 0.5625 of its width.
    shield_cookbook_depth is how far from the camera the bottles are, shield_cookbook_fov that tangent. The book and
    the table are some 25 to 40 from the camera: the bottles are nearer than that, or they are behind them.
*/
CookbookScreenOrigin(localclientnum, across, up)
{
    return CookbookScreenOriginAt(localclientnum, across, up, getdvarfloat(#"shield_cookbook_depth", 9));
}

CookbookScreenOriginAt(localclientnum, across, up, depth)
{
    cam_origin = getcamposbylocalclientnum(localclientnum);
    cam_angles = getcamanglesbylocalclientnum(localclientnum);

    if(!isdefined(cam_origin) || !isdefined(cam_angles))
    {
        cam_origin = (-1259, -3547, 764);
        cam_angles = (350, 166, 0);
    }

    spread = getdvarfloat(#"shield_cookbook_fov", 0.7);

    forward = anglestoforward(cam_angles);
    right = anglestoright(cam_angles);
    upward = anglestoup(cam_angles);

    return cam_origin + forward * depth + right * (across * depth * spread) + upward * (up * depth * spread * 0.5625);
}

CookbookRemoveBottles()
{
    foreach(bottle in level.shield_cookbook_bottles)
    {
        if(isdefined(bottle))
        {
            bottle delete();
        }
    }

    level.shield_cookbook_bottles = [];
    level.shield_cookbook_mix_start = undefined;

    CookbookStopGlow();
}

/*
    The effects are those of the laboratory: the burst it plays on a bottle it fills ("wipe"), and the glow of each
    rarity. They are named by their files, as the script of the laboratory names them in level._effect.
    They are played where the bottles are, at their distance from the camera: the burst where the three of the
    recipe go to, the glow on the one they make. A distance of their own put them inside the camera, where
    nothing is drawn, or behind the book.
*/
/*
    Where the effects are played, as the bottles are placed: x and y on the screen, -1 to 1, and depth from the camera.
    The burst (shield_cookbook_fx_...) is where the three of the recipe fly into the book and are gone, the glow
    (shield_cookbook_glow_...) is on the one they make, at first where bottle 4 stands.
    The three of the recipe fly into the one they make: across and as far as bottle 4, and as high as the burst
    looks to be. It was made for a bottle that stands at its place, so it is mostly over it: shield_cookbook_fx_mix_up
    higher on the screen.
*/
CookbookFxDvars(i)
{
    if(i == 0)
    {
        return array(#"shield_cookbook_fx_x", #"shield_cookbook_fx_y", #"shield_cookbook_fx_depth", #"shield_cookbook_fx_mix_up");
    }

    return array(#"shield_cookbook_glow_x", #"shield_cookbook_glow_y", #"shield_cookbook_glow_depth");
}

CookbookFxDefaults(i)
{
    if(i == 0)
    {
        return array(1, -0.2, 9, 0.5);
    }

    return array(0.67, 0.027, 9);
}

// where the three of the recipe fly to: the one they make, at the height of the middle of the burst
CookbookMixTarget(localclientnum)
{
    dvars = CookbookFxDvars(0);
    values = CookbookFxDefaults(0);
    result_dvars = CookbookBottleDvars(3);
    result_values = CookbookBottleDefaults(3);

    across = getdvarfloat(result_dvars[0], result_values[0]);
    up = getdvarfloat(dvars[1], values[1]) + getdvarfloat(dvars[3], values[3]);
    depth = getdvarfloat(result_dvars[2], result_values[2]);

    return CookbookScreenOriginAt(localclientnum, across, up, depth);
}

// 0 the burst, 1 the glow
CookbookFxOrigin(localclientnum, i)
{
    dvars = CookbookFxDvars(i);
    values = CookbookFxDefaults(i);

    return CookbookScreenOriginAt(localclientnum, getdvarfloat(dvars[0], values[0]), getdvarfloat(dvars[1], values[1]), getdvarfloat(dvars[2], values[2]));
}

CookbookBurst(localclientnum)
{
    origin = CookbookFxOrigin(localclientnum, 0);

    ShieldLog("^3Cookbook: burst at " + origin);
    playfx(localclientnum, "maps/core_frontend/fx8_frontend_zombie_lab_elixir_wipe", origin);
}

/*
    The glow the laboratory gives a bottle of that rarity, on the one the recipe makes, and its sound when it was just
    made. It is played on a tag_origin that goes with the bottle. Turned up: an effect played without a direction
    points up, and an effect on a tag points where the tag does.
*/
CookbookGlow(localclientnum, origin, rarity, made)
{
    names = array("maps/core_frontend/fx8_frontend_zombie_lab_elixir_common", "maps/core_frontend/fx8_frontend_zombie_lab_elixir_rare",
        "maps/core_frontend/fx8_frontend_zombie_lab_elixir_legendary", "maps/core_frontend/fx8_frontend_zombie_lab_elixir_epic");

    if(!isdefined(rarity) || !isdefined(names[rarity]))
    {
        ShieldLog("^1Cookbook: no glow, the rarity of what is made was not told");
        return;
    }

    level.shield_cookbook_localclient = localclientnum;
    level.shield_cookbook_glow_tag = util::spawn_model(localclientnum, "tag_origin", origin, (-90, 0, 0));

    if(isdefined(level.shield_cookbook_glow_tag))
    {
        level.shield_cookbook_glow_tag thread CookbookGlowOnTag(localclientnum, names[rarity]);
    }
    else
    {
        ShieldLog("^1Cookbook: no tag for the glow, it stays where it is played");
        level.shield_cookbook_glow = playfx(localclientnum, names[rarity], origin);
    }

    if(made)
    {
        sounds = array(#"hash_49d438d1a1ba28b9", #"hash_7d9e04c47d70ca1d", #"hash_2ff41d0510d442c8", #"hash_2c8d10ab46ff7e64");

        if(isdefined(sounds[rarity]))
        {
            playsound(localclientnum, sounds[rarity], origin);
        }
    }
}

// an effect goes on a tag only once the model of it is made, a frame or a few after it is spawned
CookbookGlowOnTag(localclientnum, name)
{
    self endon(#"death");

    for(i = 0; i < 60 && !self hasdobj(localclientnum); i++)
    {
        waitframe(1);
    }

    level.shield_cookbook_glow = util::playfxontag(localclientnum, name, self, "tag_origin");

    if(!isdefined(level.shield_cookbook_glow))
    {
        ShieldLog("^1Cookbook: the glow could not go on its tag, it stays where it is played");
        level.shield_cookbook_glow = playfx(localclientnum, name, self.origin);
    }
}

CookbookStopGlow()
{
    if(isdefined(level.shield_cookbook_glow))
    {
        stopfx(level.shield_cookbook_localclient, level.shield_cookbook_glow);
        level.shield_cookbook_glow = undefined;
    }

    if(isdefined(level.shield_cookbook_glow_tag))
    {
        level.shield_cookbook_glow_tag delete();
        level.shield_cookbook_glow_tag = undefined;
    }
}

// The bottles of the recipe as the menu names them: the three it takes, then the one they make. made: that one was just made.
CookbookShowBottles(localclientnum, controller, made, rarity)
{
    // the last asking is the one that counts
    level notify("shield_cookbook_show");
    level endon("shield_cookbook_show");

    CookbookRemoveBottles();

    if(!isdefined(controller))
    {
        return;
    }

    root = createuimodel(getuimodelforcontroller(controller), "ShieldCookbook");

    for(i = 0; i < 4; i++)
    {
        name_model = getuimodel(root, "model" + (i + 1));

        if(!isdefined(name_model))
        {
            continue;
        }

        name = getuimodelvalue(name_model);

        if(!isdefined(name) || name === "" || name === #"")
        {
            continue;
        }

        bottle = util::spawn_model(localclientnum, name, CookbookScreenOrigin(localclientnum, 0, 0));

        if(!isdefined(bottle))
        {
            ShieldLog("^1Cookbook: no model for bottle " + i);
            continue;
        }

        bottle hide();
        level.shield_cookbook_bottles[i] = bottle;
    }

    CookbookWaitForCamera(localclientnum);

    level.shield_cookbook_shown = gettime();
    level.shield_cookbook_fresh = made;

    // in its place before it is drawn
    CookbookPlaceBottles(localclientnum);

    foreach(bottle in level.shield_cookbook_bottles)
    {
        if(isdefined(bottle))
        {
            bottle show();
        }
    }

    // the one they make turns in the glow of its rarity, with one more burst where the three went in when it was just made
    if(isdefined(level.shield_cookbook_bottles[3]))
    {
        CookbookGlow(localclientnum, CookbookFxOrigin(localclientnum, 1), rarity, made);

        if(made)
        {
            CookbookBurst(localclientnum);
        }
    }

    ShieldLog("^3Cookbook: " + level.shield_cookbook_bottles.size + " bottle(s) shown");

    for(;;)
    {
        waitframe(1);
        CookbookPlaceBottles(localclientnum);
    }
}

/*
    The bottles are shown once the camera stands on the book: they went with it while it moved there, which looked
    wrong. It stands when it has not moved for two frames, at least 150 milliseconds after it was sent to the book
    (it may not have started yet). A second and a half at most, should it never stand quite still.
*/
CookbookWaitForCamera(localclientnum)
{
    start = gettime();
    last = getcamposbylocalclientnum(localclientnum);
    still = 0;

    for(;;)
    {
        waitframe(1);

        now = gettime();
        here = getcamposbylocalclientnum(localclientnum);

        if(isdefined(here) && isdefined(last) && distance(here, last) < 0.05)
        {
            still++;
        }
        else
        {
            still = 0;
        }

        last = here;

        if(now - start > 1500)
        {
            return;
        }

        if(still >= 2 && (!isdefined(level.shield_cookbook_opened) || now - level.shield_cookbook_opened >= 150))
        {
            return;
        }
    }
}

/*
    The dvars of each bottle, 1 to 3 the ones of the recipe from the top and 4 the one they make:
    x and y where it stands on the screen, -1 to 1 from the left and the bottom edge to the right and the top one (a
    bottle is held by its foot, so it stands over that place); depth how far from the camera, in units, nearer than
    the book some 25 away; scale its size; pitch, yaw and roll in degrees, yaw from facing the camera.
*/
CookbookBottleDvars(i)
{
    switch(i)
    {
        case 0:
            return array(#"shield_cookbook_b1_x", #"shield_cookbook_b1_y", #"shield_cookbook_b1_depth", #"shield_cookbook_b1_scale", #"shield_cookbook_b1_pitch", #"shield_cookbook_b1_yaw", #"shield_cookbook_b1_roll");
        case 1:
            return array(#"shield_cookbook_b2_x", #"shield_cookbook_b2_y", #"shield_cookbook_b2_depth", #"shield_cookbook_b2_scale", #"shield_cookbook_b2_pitch", #"shield_cookbook_b2_yaw", #"shield_cookbook_b2_roll");
        case 2:
            return array(#"shield_cookbook_b3_x", #"shield_cookbook_b3_y", #"shield_cookbook_b3_depth", #"shield_cookbook_b3_scale", #"shield_cookbook_b3_pitch", #"shield_cookbook_b3_yaw", #"shield_cookbook_b3_roll");
        default:
            return array(#"shield_cookbook_b4_x", #"shield_cookbook_b4_y", #"shield_cookbook_b4_depth", #"shield_cookbook_b4_scale", #"shield_cookbook_b4_pitch", #"shield_cookbook_b4_yaw", #"shield_cookbook_b4_roll");
    }
}

/*
    The values for the windows of Cookbook.lua, in the order of the dvars. The front of a bottle is a quarter turn
    from where its model looks: at a yaw of -90 it faces the camera, at -60 it is turned a little to the book, and
    tipped back a little.
    Tuned in the game for windows of before, then moved as far as the windows moved since: down the screen by about
    1.04 times as much (what the tuned ones stood apart by against their windows), across 0.01 out on each side.
*/
CookbookBottleDefaults(i)
{
    switch(i)
    {
        case 0:
            return array(-0.85, 0.212, 9, 0.2, -4, -60, 0);
        case 1:
            return array(-0.85, -0.334, 9, 0.2, -4, -60, 0);
        case 2:
            return array(-0.85, -0.831, 9, 0.2, -4, -60, 0);
        default:
            return array(0.67, 0.027, 9, 0.3, -4, -60, 0);
    }
}

// how far the one they make has turned: slowly, and fast at first when it was just made
CookbookSpin(ms, fresh)
{
    t = ms / 1000;

    if(!fresh)
    {
        return t * 40;
    }

    if(t < 0.9)
    {
        k = 1 - t / 0.9;
        return 720 * (1 - k * k);
    }

    return 720 + (t - 0.9) * 40;
}

/*
    Every bottle where it belongs on the screen, as the camera is now. While they mix, the three of the recipe go
    up a little and turn, then fly in an arc into the book getting small and turning faster, one after the other,
    and are gone in a burst. The one they make shrinks away as they start.
*/
CookbookPlaceBottles(localclientnum)
{
    cam_origin = getcamposbylocalclientnum(localclientnum);
    cam_angles = getcamanglesbylocalclientnum(localclientnum);

    if(!isdefined(cam_origin) || !isdefined(cam_angles))
    {
        cam_origin = (-1259, -3547, 764);
        cam_angles = (350, 166, 0);
    }

    forward = anglestoforward(cam_angles);
    right = anglestoright(cam_angles);
    upward = anglestoup(cam_angles);

    spread = getdvarfloat(#"shield_cookbook_fov", 0.7);

    // where they go into the book, and how high they go up first and over on their way
    target = CookbookMixTarget(localclientnum);
    lift = getdvarfloat(#"shield_cookbook_mix_lift", 0.2);
    arc = getdvarfloat(#"shield_cookbook_mix_arc", 0.1);

    now = gettime();

    for(i = 0; i < 4; i++)
    {
        bottle = level.shield_cookbook_bottles[i];

        if(!isdefined(bottle) || isdefined(bottle.shield_gone))
        {
            continue;
        }

        dvars = CookbookBottleDvars(i);
        values = CookbookBottleDefaults(i);

        for(j = 0; j < dvars.size; j++)
        {
            values[j] = getdvarfloat(dvars[j], values[j]);
        }

        // the screen of 16 by 9 is 0.5625 as high as it is wide
        depth = values[2];
        origin = cam_origin + forward * depth + right * (values[0] * depth * spread) + upward * (values[1] * depth * spread * 0.5625);
        size = values[3];
        spin = 0;

        if(i == 3)
        {
            spin = CookbookSpin(now - level.shield_cookbook_shown, level.shield_cookbook_fresh);
        }

        // they come up out of nothing, growing and rising a little to their place
        age = (now - level.shield_cookbook_shown) / 1000;

        if(age < 0.25)
        {
            k = 1 - age / 0.25;
            e = 1 - k * k;
            size *= max(e, 0.01);
            origin -= upward * (0.3 * (1 - e));
        }

        if(isdefined(level.shield_cookbook_mix_start))
        {
            if(i < 3)
            {
                t = (now - level.shield_cookbook_mix_start - i * 150) / 1000;

                if(t >= 0.6)
                {
                    bottle hide();
                    bottle.shield_gone = 1;
                    CookbookBurst(localclientnum);
                    continue;
                }

                if(t >= 0.2)
                {
                    k = (t - 0.2) / 0.4;
                    e = k * k;
                    lifted = origin + upward * lift;
                    origin = lifted + (target - lifted) * e + upward * (sin(k * 180) * arc);
                    size *= 1 - 0.9 * e;
                    spin = 180 + 900 * e;
                }
                else if(t >= 0)
                {
                    k = t / 0.2;
                    origin += upward * (lift * (1 - (1 - k) * (1 - k)));
                    spin = 180 * k * k;
                }
            }
            else
            {
                t = (now - level.shield_cookbook_mix_start) / 1000;

                if(t >= 0.3)
                {
                    bottle hide();
                    bottle.shield_gone = 1;
                    continue;
                }

                k = t / 0.3;
                size *= 1 - k * k;
                spin += 540 * k;
            }
        }

        bottle.origin = origin;
        bottle.angles = (values[4], cam_angles[1] + values[5] + spin, values[6]);
        bottle setscale(size);

        if(i == 3 && isdefined(level.shield_cookbook_glow_tag))
        {
            level.shield_cookbook_glow_tag.origin = CookbookFxOrigin(localclientnum, 1);
        }
    }
}

// the three of the recipe go into the book, see CookbookPlaceBottles, and what they make goes with them
CookbookMixBottles(localclientnum)
{
    level.shield_cookbook_mix_start = gettime();
    CookbookStopGlow();
}

detour frontend<scripts\core\gametypes\frontend.csc>::lobby_main(localclientnum, menu_name, state)
{
    ShieldLog("^3Lobby MAIN Called");

    if (getDvarInt(#"shield_performance_frontend", 0))
    {
        ShieldLog("^2Performance Mode Enabled, Returning lobby scenes");

        level [[ @frontend<scripts\core\gametypes\frontend.csc>::function_a71254a9 ]](localclientnum, 0);
        playmaincamxcam(localclientnum, #"ui_cam_character_customization", 0, "cam_preview", "", (-9000, 0, 0), (0, 0, -9000));

        return;
    }

    return [[ @frontend<scripts\core\gametypes\frontend.csc>::lobby_main ]](localclientnum, menu_name, state);
}

detour util<scripts\core_common\util_shared.csc>::function_8570168d()
{
    // fix specialists hq mode
    if(IsSubStr(GetDvarString("ls_gametype", "none"), "COMBAT") || function_bea73b01() == 4)
    {
        //ShieldLog("^1HQ Mode, Returned.... (CSC)");
        return [[ @util<scripts\core_common\util_shared.csc>::function_8570168d ]]();
    }

    //ShieldLog("^2Gamemode Check -> Called (CSC)");

    /*
    if (sessionmodeismultiplayergame()) 
    {
        mode = function_bea73b01();
        if (mode == 4)
            return true;
    }
    */

    // return false anyways
    return false;
}