-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_get_game_cfg(stPlayer, msg)
    LOG_DEBUG("Run LogicStep get_game_cfg")
    return STEP_SUCCEED
end


return logic_get_game_cfg
