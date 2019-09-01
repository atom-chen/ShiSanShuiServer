-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_do_player(stPlayer, event)
    LOG_DEBUG("Run LogicStep do_player")
    return STEP_SUCCEED
end


return logic_do_player
