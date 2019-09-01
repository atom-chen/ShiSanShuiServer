-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_do_notify_other_player_quadruplet(stPlayer, event)
    LOG_DEBUG("Run LogicStep logic_do_notify_other_player_quadruplet")
    return STEP_SUCCEED
end


return logic_do_notify_other_player_quadruplet
