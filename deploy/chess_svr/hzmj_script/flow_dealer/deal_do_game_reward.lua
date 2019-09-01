-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_deal_do_game_reward(dealer, msg)
    LOG_DEBUG("Run LogicStep deal_do_game_reward")
    return STEP_SUCCEED
end


return logic_deal_do_game_reward
