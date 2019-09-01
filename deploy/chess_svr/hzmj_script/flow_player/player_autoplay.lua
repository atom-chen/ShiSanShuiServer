-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_player_autoplay(stPlayer, msg)
    LOG_DEBUG("Run LogicStep player_autoplay")
    return STEP_SUCCEED
end


return logic_player_autoplay
