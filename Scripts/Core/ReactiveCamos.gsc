
detour activecamo<scripts\core_common\activecamo_shared.gsc>::set_stage_activecamo(activecamo, stagenum)
{
    if (!isdefined(self.reactive_stage))
    {
        return [[ @activecamo<scripts\core_common\activecamo_shared.gsc>::set_stage_activecamo ]](activecamo, stagenum);
    }

    SetReactiveForcedStage(activecamo, stagenum);
}

// fix kills error in zm
detour activecamo<scripts\core_common\activecamo_shared.gsc>::function_896ac347(oweapon, statname, value)
{
    if (!isdefined(self.reactive_stage))
    {
        return [[ @activecamo<scripts\core_common\activecamo_shared.gsc>::function_896ac347 ]](oweapon, statname, value);
    }

    return;
}

SetReactiveForcedStage(activecamo, stagenum)
{
    // check if player has a force option for stage
    if (!isdefined(self.reactive_stage))
    {
        return [[ @activecamo<scripts\core_common\activecamo_shared.gsc>::set_stage_activecamo ]](activecamo, stagenum);
    }

    // get the player's dvar from lua menu's response
    dvar_val = self.reactive_stage;
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

ZMReactiveFix()
{
    level flag::wait_till("initial_blackscreen_passed");

    // force it to refresh
    if (isalive(self) && isdefined(self.reactive_stage)) {
        weapon = self getCurrentWeapon();
        if (isdefined(weapon) && isdefined(self.pers) && isdefined(self.pers[#"activecamo"]))
        {
            self setcamo(weapon, 0);

            wait 0.5;

            foreach (activecamo in self.pers[#"activecamo"])
            {
                SetReactiveForcedStage(activecamo, self.reactive_stage);
            }
        }
    }
}