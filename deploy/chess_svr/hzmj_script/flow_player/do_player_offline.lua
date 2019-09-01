-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_do_player_offline(stPlayer, msg)
    LOG_DEBUG("Run LogicStep do_player_offline")
    local nActive = msg._para.active
    stPlayer:SetPlayOfflineStatus(nActive)
    LOG_DEBUG("Run LogicStep do_player_nActive%d",nActive)
    CSMessage.NotifyPlayerOffline(stPlayer,nActive)

    -- 金币场离线了也不托管？房卡场离线也不应该托管
    -- stPlayer:SetIsTrust(true)
    -- CSMessage.NotifyTrustToAll(stPlayer, true)
    return STEP_SUCCEED
end


return logic_do_player_offline
