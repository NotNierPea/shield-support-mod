// Black Market rewards of the live service (shield-client live_rewards.cpp): the game reports these in online matches only, so they're reported here
LiveRewards()
{
    if(TargetRangeIsMatch())
     return;

    if(SessionModeIsZombiesGame())
    {
        level thread LiveRewardsRound15();
        return;
    }

    [[ @challenges<scripts\core_common\challenges_shared.gsc>::registerchallengescallback ]]("gameEnd", &LiveRewardsGameEnd);
    if(sessionmodeiswarzonegame())
     level thread LiveRewardsWarzone();
}

// one value for a real player, through the builtin zm_stats reports its daily callings with
ReportLiveReward(player, event, value)
{
    if(isplayer(player) && !isbot(player))
     player function_e8f77739(event, value);
}

// a won match (multiplayer) or progress (Blackout) is marked on the player: the live service paid a tier skip a day for it
LiveRewardsTierSkip(player)
{
    if(!isplayer(player) || isbot(player) || !isdefined(player.pers))
     return;

    marked = player.pers[#"hash_6344af0b142ed0b6"];
    if(!isdefined(marked) || !marked || isdefined(player.pers[#"shield_tier_skip_sent"]))
     return;

    // multiplayer paid nothing to a player who didn't take part (challenges_shared function_90185171)
    participation = player.pers[#"participation"];
    if(!sessionmodeiswarzonegame() && (!isdefined(participation) || participation < 1))
     return;

    player.pers[#"shield_tier_skip_sent"] = 1;
    ReportLiveReward(player, #"shield_tier_skip", sessionmodeiswarzonegame() ? 2 : 1);
}

// challenges' gameEnd: the game's own callbacks mark the winners in the same frame
LiveRewardsGameEnd(data)
{
    player = data.player;
    waitframe(1);
    LiveRewardsTierSkip(player);
}

// Blackout marks progress during the match, and a player who is out can leave before it ends
LiveRewardsWarzone()
{
    level endon(#"game_ended");

    while(true)
    {
        wait 5;
        foreach(player in getplayers())
         LiveRewardsTierSkip(player);
    }
}

// zombies paid a tier skip a day for round 15 of a classic match (zm_challenges round_tracking)
LiveRewardsRound15()
{
    level endon(#"end_game");

    while(true)
    {
        level waittill(#"end_of_round");
        if(level.round_number != 15)
         continue;

        if(![[ @zm_utility<scripts\zm_common\zm_utility.gsc>::is_classic ]]() || (isdefined(level.zm_disable_recording_stats) && level.zm_disable_recording_stats))
         return;

        foreach(player in getplayers())
         ReportLiveReward(player, #"shield_tier_skip", 3);
        return;
    }
}

// a gauntlet round's reward, as stock: its plasma was reported in online matches only, here it goes to shield-client
detour zm_trial_give_reward<scripts\zm_common\trials\zm_trial_give_reward.gsc>::function_e7254828()
{
    gauntlet = level.var_5335b66f[level.var_6d87ac05.name];
    curr_time = gettime() - level.var_21e22beb;
    rewarded = isdefined(level.var_ee7ca64[level.round_number]) && level.var_ee7ca64[level.round_number];

    if(isdefined(self.trial_completed) && self.trial_completed)
     level.var_bccd8271 = curr_time;

    foreach(player in getplayers())
    {
        best_time = player [[ @zm_stats<scripts\zm_common\zm_stats.gsc>::function_8e274b32 ]](self.var_c2964c77);

        if(best_time == 0 && !rewarded)
        {
            level.var_ee7ca64[level.round_number] = 1;
            player luinotifyevent(#"hash_8d33c3be569f08", 1, self.row);

            if(level.onlinegame)
            {
                player function_cce105c8(#"zm_gauntlet_reward", 1, gauntlet, 2, level.round_number);
                player function_4835d26a();
            }
            else if(isdefined(gauntlet))
             ReportLiveReward(player, #"shield_gauntlet_reward", gauntlet * 100 + level.round_number);
        }

        player [[ @zm_stats<scripts\zm_common\zm_stats.gsc>::function_31931250 ]](self.var_c2964c77, curr_time);
        best_time = player [[ @zm_stats<scripts\zm_common\zm_stats.gsc>::function_b1520544 ]](self.var_c2964c77);

        if(best_time == 0 || curr_time < best_time)
         player [[ @zm_stats<scripts\zm_common\zm_stats.gsc>::function_49469f35 ]](self.var_c2964c77, curr_time);

        best_time = [[ @zm_stats<scripts\zm_common\zm_stats.gsc>::get_match_stat ]](self.var_c2964c77);

        if(best_time == 0 || curr_time < best_time)
         [[ @zm_stats<scripts\zm_common\zm_stats.gsc>::set_match_stat ]](self.var_c2964c77, curr_time);

        best_time = player [[ @zm_stats<scripts\zm_common\zm_stats.gsc>::function_e4358abd ]](self.var_c2964c77);

        if(best_time == 0 || curr_time < best_time)
         player [[ @zm_stats<scripts\zm_common\zm_stats.gsc>::function_9daadcaa ]](self.var_c2964c77, curr_time);

        if(isdefined(self.trial_completed) && self.trial_completed)
         player notify(#"stop_player_monitor_time_played");

        player [[ @zm_stats<scripts\zm_common\zm_stats.gsc>::increment_challenge_stat ]](self.challenge_stat, 1);

        if(level.round_number == 20)
         player [[ @contracts<scripts\zm_common\zm_contracts.gsc>::increment_zm_contract ]](#"contract_zm_gauntlet_silver");

        if([[ @zm_trial<scripts\zm_common\zm_trial.gsc>::function_ba9853db ]]() == 0)
        {
            if(isdefined(self.var_191009a6))
             player [[ @zm_stats<scripts\zm_common\zm_stats.gsc>::increment_challenge_stat ]](self.var_191009a6, 1);

            if(level.round_number == 10)
             player [[ @contracts<scripts\zm_common\zm_contracts.gsc>::increment_zm_contract ]](#"contract_zm_gauntlet_bronze");
        }
    }
}
