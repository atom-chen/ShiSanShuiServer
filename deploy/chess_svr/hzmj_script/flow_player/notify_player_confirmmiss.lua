-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_notify_player_confirmmiss(stPlayer, msg)
    LOG_DEBUG("Run LogicStep notify_player_confirmmiss")
    local stPlayerCardGroup = stPlayer:GetPlayerCardGroup()
    local stOptional = LibConfirmMiss:GetMissOptional()
    local nRecommend = LibConfirmMiss:GetBestMiss(stPlayerCardGroup:ToArray())
    local ntime = GGameCfg.TimerSetting.confirmMissTimeOut
    CSMessage.NotifyAskConfirmMiss(stPlayer, stOptional, nRecommend,ntime)
    return STEP_SUCCEED
end


return logic_notify_player_confirmmiss
