-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_notify_player_changecard(stPlayer, msg)
    LOG_DEBUG("Run LogicStep notify_player_changecard")
    local stPlayerCardGroup = stPlayer:GetPlayerCardGroup()
    local nChangeNum = LibChangeCard:GetChangeCardNum()
    local bSameCardType = LibChangeCard:IsNeedChangeSame()
    local stBest = LibChangeCard:SelectCardChange(stPlayerCardGroup:ToArray())         
    local ntimeout = GGameCfg.TimerSetting.changeCardTimeOut
    CSMessage.NotifyAskChangeCard(stPlayer, nChangeNum, bSameCardType, stBest,ntimeout)
    return STEP_SUCCEED
end


return logic_notify_player_changecard
