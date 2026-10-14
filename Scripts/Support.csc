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