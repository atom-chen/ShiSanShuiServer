-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_do_svr_refresh(stPlayer, msg)
    LOG_DEBUG("Run LogicStep do_svr_refresh")
    stPlayer:RefreshScore()
    CSMessage.NotifyPlayerPointsRefresh(stPlayer)
    return STEP_SUCCEED
end


return logic_do_svr_refresh
