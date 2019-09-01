-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_do_thisgame_reward(dealer, msg)
    LOG_DEBUG("Run LogicStep do_thisgame_reward")
    LibGameLogic:RewardThisGame()

    -- 下一步，gameend-->SetGameEnd-->KickUser-->LeaveOneGamer-->PostEvent-->DeleteOneTable
    -- dealer:ToNextStage() //在notify_game_reward里做了
    return STEP_SUCCEED
end


return logic_do_thisgame_reward
