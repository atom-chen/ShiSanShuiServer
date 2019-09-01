-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_do_player_offline(stPlayer, msg)
    LOG_DEBUG("Run LogicStep do_player_offline")
    local nActive = msg._para.active
    LOG_DEBUG("Run LogicStep do_player_offline nActive: %d",nActive)

    --在比牌阶段  玩家离线重回  跳过播放动画
    local sCurrStage = GDealer:GetCurrStage()
    LOG_DEBUG("Run LogicStep do_player_offline p%d, uid:%d, sCurrStage:%s, nCurrJu:%d, nJuNum:%d",stPlayer:GetChairID(), stPlayer:GetUin(), sCurrStage, GGameCfg.nCurrJu, GGameCfg.nJuNum)
    if sCurrStage == "compare" 
        or sCurrStage == "reward" 
        or sCurrStage == "gameend" then
        stPlayer:SetCancleCompare(true)
    end

    stPlayer:SetPlayOfflineStatus(nActive)
    CSMessage.NotifyPlayerOffline(stPlayer,nActive)
    return STEP_SUCCEED
end


return logic_do_player_offline
