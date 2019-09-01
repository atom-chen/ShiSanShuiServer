-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_player_ready_timeout(stPlayer, event)
    LOG_DEBUG("Run LogicStep player_ready_timeout")
    -- 改为自动ready
    stPlayer:SetPlayerStatus(PLAYER_STATUS_READY)
    CSMessage.NotifyPlayerReadyToAll(stPlayer)

    return STEP_SUCCEED
end


return logic_player_ready_timeout
