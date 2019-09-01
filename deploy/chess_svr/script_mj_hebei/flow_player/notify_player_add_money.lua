-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_notify_player_add_money(stPlayer, msg)
    LOG_DEBUG("Run LogicStep notify_player_add_money")
    CSMessage.NotifyPlayerAddMoneyToContinue(stPlayer)
    FlowFramework.SetTimer(stPlayer:GetChairID(), GGameCfg.TimerSetting.addMoneyTimeout)
    return STEP_SUCCEED
end


return logic_notify_player_add_money
