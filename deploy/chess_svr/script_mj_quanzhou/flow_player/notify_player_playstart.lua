-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_notify_player_playstart(stPlayer, msg)
    LOG_DEBUG("Run LogicStep notify_player_playstart")

    CSMessage.NotifyOnePlayStart(stPlayer)
    return STEP_SUCCEED
end


return logic_notify_player_playstart
