#include scripts\core_common\system_shared.csc;
#include scripts\core_common\clientfield_shared.csc;
#include scripts\core_common\util_shared.csc;
#include scripts\core_common\flag_shared.csc;
#include scripts\core_common\struct.csc;

#namespace SupportCSC;

autoexec InitSystem() 
{
    if(util::is_frontend_map())
     return;

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