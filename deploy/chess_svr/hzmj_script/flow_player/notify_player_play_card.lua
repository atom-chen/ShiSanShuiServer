-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_notify_player_play_card(stPlayer, msg)
    LOG_DEBUG("Run LogicStep notify_player_play_card")

    local bIsQuick = stPlayer:IsTrust() or  stPlayer:IsWin()
    CSMessage.NotifyAskPlay(stPlayer, bIsQuick)
    
    local nCount = LibConfirmMiss:GetMissCardCount(stPlayer)
    if nCount < 2 then  -- 缺牌少于2张
        local stPlayerBlockState = LibGameLogic:GetPlayerBlockState(stPlayer:GetChairID())
        local envtest = LibFanCounter:CollectEnv(stPlayer:GetChairID())
        LibFanCounter:SetEnv(envtest)
        local stTingInfo = LibFanCounter:GetTingInfo()
        
        if stPlayer:IsWin() == false and #stTingInfo > 0 then
            CSMessage.NotifyPlayerBlockTing(stPlayer, stTingInfo)
            stPlayerBlockState:SetHuFanInfo(stTingInfo)
        end
    end
    
    return STEP_SUCCEED
end


return logic_notify_player_play_card
