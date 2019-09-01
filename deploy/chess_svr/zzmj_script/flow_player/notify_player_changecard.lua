-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_notify_player_changecard(stPlayer, msg)
    LOG_DEBUG("Run LogicStep notify_player_changecard")
    local stPlayerCardGroup = stPlayer:GetPlayerCardGroup()
    local nChangeNum = LibChangeCard:GetChangeCardNum()
    local bSameCardType = LibChangeCard:IsNeedChangeSame()
    local stBest = LibChangeCard:SelectCardChange(stPlayerCardGroup:ToArray())         
    
    CSMessage.NotifyAskChangeCard(stPlayer, nChangeNum, bSameCardType, stBest)
    LOG_DEBUG("GGameCfg.TimerSetting.changeCardTimeOut :%d", GGameCfg.TimerSetting.changeCardTimeOut)
    FlowFramework.SetTimer(stPlayer:GetChairID(), GGameCfg.TimerSetting.changeCardTimeOut)
    return STEP_SUCCEED
end


return logic_notify_player_changecard
