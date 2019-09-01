-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_do_player_offline(stPlayer, msg)
    LOG_DEBUG("Run LogicStep do_player_offline")
    local nActive = msg._para.active
    LOG_DEBUG("Run LogicStep do_player_nActive nActive: %d",nActive)

    --在比牌阶段  玩家离线重回  跳过播放动画
    local sCurrStage = GDealer:GetCurrStage()
    if sCurrStage == "compare" then
        stPlayer:SetCancleCompare(true)
    end

    stPlayer:SetPlayOfflineStatus(nActive)
    CSMessage.NotifyPlayerOffline(stPlayer,nActive)
    return STEP_SUCCEED
end


return logic_do_player_offline
