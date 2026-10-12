// Check if the host is on a dedicated server and force them to spectator if so
detour globallogic_ui<scripts\mp_common\gametypes\globallogic_ui.gsc>::menuautoassign(comingfrommenu, var_4c542e39)
{
    if (getDvarInt(#"shield_dedicated", 0) && self IsHost())
    {
        ShieldLog("^3Dedicated: the host watches, it is on no team");

        self [[ @teams<scripts\core_common\teams.gsc>::function_dc7eaabd ]](#"spectator");
        return;
    }

    return [[ @globallogic_ui<scripts\mp_common\gametypes\globallogic_ui.gsc>::menuautoassign ]](comingfrommenu, var_4c542e39);
}
