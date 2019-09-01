-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_notify_player_play_card(stPlayer, msg)
    LOG_DEBUG("Run LogicStep notify_player_play_card")
    local nChair = stPlayer:GetChairID()
    local bIsQuick = stPlayer:IsTrust() or  stPlayer:IsWin()
    CSMessage.NotifyAskPlay(stPlayer, bIsQuick)
    
    local envtest  = LibFanCounter:CollectEnv(nChair)
    LibFanCounter:SetEnv(envtest)
    local stTingInfo = LibFanCounter:GetTingInfo()

    local stPlayerBlockState = LibGameLogic:GetPlayerBlockState(nChair)
    if stPlayer:IsWin() == false and #stTingInfo > 0 then
        LOG_DEBUG(":notify_player_play_card..111.stTingInfo:%s\n",vardump(stTingInfo))
        CSMessage.NotifyPlayerBlockTing(stPlayer, stTingInfo)
    end
    return STEP_SUCCEED
end


return logic_notify_player_play_card
