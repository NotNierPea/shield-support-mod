
detour activecamo<scripts\core_common\activecamo_shared.gsc>::set_stage_activecamo(activecamo, stagenum)
{
    if (!isdefined(level.reactive_camos_force))
    {
        return [[ @activecamo<scripts\core_common\activecamo_shared.gsc>::set_stage_activecamo ]](activecamo, stagenum);
    }

    SetReactiveForcedStage(activecamo, stagenum);
}

// fix kills error in zm
detour activecamo<scripts\core_common\activecamo_shared.gsc>::function_896ac347(oweapon, statname, value)
{
    if (!isdefined(self.forced_reactive))
    {
        return [[ @activecamo<scripts\core_common\activecamo_shared.gsc>::function_896ac347 ]](oweapon, statname, value);
    }

    return;
}


SetReactiveForcedStage(activecamo, stagenum)
{
    // check if player has a force option for stage
    request = undefined;
    b_found = false;
    foreach(player_request in level.reactive_camos_force)
    {
        if (player_request.player === self)
        {
            request = player_request;
            b_found = true;
        }
    }

    // not in array
    if (!b_found)
        return [[ @activecamo<scripts\core_common\activecamo_shared.gsc>::set_stage_activecamo ]](activecamo, stagenum);

    // get the player's dvar from lua menu's response
    dvar_val = request.reactive_stage;
    if (dvar_val == 0)
    {
        return [[ @activecamo<scripts\core_common\activecamo_shared.gsc>::set_stage_activecamo ]](activecamo, stagenum);
    }
    if (dvar_val == 99)
    {
        return [[ @activecamo<scripts\core_common\activecamo_shared.gsc>::set_stage_activecamo ]](activecamo, (activecamo.stages.size - 1)); // should be last stage
    }

    // get stage
    stage = activecamo.stages[dvar_val];
    if (!isdefined(stage))
    {
        return [[ @activecamo<scripts\core_common\activecamo_shared.gsc>::set_stage_activecamo ]](activecamo, (activecamo.stages.size - 1)); // return last stage if not
    }

    return [[ @activecamo<scripts\core_common\activecamo_shared.gsc>::set_stage_activecamo ]](activecamo, dvar_val); // exact stage key
}
