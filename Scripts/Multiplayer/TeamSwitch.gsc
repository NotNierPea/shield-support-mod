/*
    Changing teams in a match, from the Change Team tab of the pause menu (TeamChangeFixes.lua).

    The game's switch (globallogic_ui::menuteam) kills the player, empties their class and opens the draft of
    specialists again: they pick one, then wait the whole respawn delay counted from that death, some ten seconds.
    Here the player keeps the specialist and the class they had and spawns on the new team at once. Only when their
    specialist is taken on the new team (the gametype allows so many of each per team) do they pick again, as before.
    The game's thread of the death ends when the player spawns (callback_playerkilled ends on "spawned"), so it does
    not spawn them a second time.
*/
detour globallogic_ui<scripts\mp_common\gametypes\globallogic_ui.gsc>::menuteam(team)
{
    role = self [[ @player_role<scripts\core_common\player\player_role.gsc>::get ]]();
    class = self.curclass;

    [[ @globallogic_ui<scripts\mp_common\gametypes\globallogic_ui.gsc>::menuteam ]](team);

    // the switch was made: the player died for it and is on a team that plays
    if (isalive(self) || !isdefined(self.pers[#"team"]) || !isdefined(level.teams[self.pers[#"team"]]))
    {
        return;
    }

    if (!isdefined(role) || !isdefined(class) || class == "" || !([[ @player_role<scripts\core_common\player\player_role.gsc>::is_valid ]](role)))
    {
        return;
    }

    // the specialist is free on the new team, or the draft stays open to pick another
    if (!(self [[ @draft<scripts\mp_common\draft.gsc>::can_select_character ]](role)))
    {
        ShieldLog("^3Team switch: " + self.name + " picks a new specialist, theirs is taken on the new team");
        return;
    }

    self [[ @player_role<scripts\core_common\player\player_role.gsc>::set ]](role);
    self [[ @draft<scripts\mp_common\draft.gsc>::close ]]();

    self.pers[#"class"] = class;
    self.curclass = class;

    self thread SpawnAfterSwitch();
}

// Spawns the player at once. A respawn that was under way (from the death of the switch) is ended by the switch
// ("end_respawn") before it could reset waitingtospawn, which would keep this one out.
SpawnAfterSwitch()
{
    self endon(#"disconnect");
    level endon(#"game_ended");

    waitframe(1);

    if (isalive(self))
    {
        return;
    }

    // no delay and no "press to spawn": both are for a player who spawned before
    self.hasspawned = 0;
    self.waitingtospawn = 0;

    self thread [[ level.spawnclient ]]();
}
