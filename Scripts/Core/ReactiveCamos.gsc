
detour activecamo<scripts\core_common\activecamo_shared.gsc>::set_stage_activecamo( activecamo, stagenum )
{
    //ShieldLog("^set_stage_activecamo -> activecamo");

    dvar_val = getDvarInt(#"shield_active_camo_last", 0);
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

    return [[ @activecamo<scripts\core_common\activecamo_shared.gsc>::set_stage_activecamo ]](activecamo, (dvar_val + 1)); // exact stage key
}