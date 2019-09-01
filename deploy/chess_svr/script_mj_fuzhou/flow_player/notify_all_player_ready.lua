-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_notify_all_player_ready(stPlayer, msg)
    LOG_DEBUG("Run LogicStep notify_all_player_ready")
    CSMessage.NotifyPlayerReadyToAll(stPlayer)

    return STEP_SUCCEED
end


return logic_notify_all_player_ready
