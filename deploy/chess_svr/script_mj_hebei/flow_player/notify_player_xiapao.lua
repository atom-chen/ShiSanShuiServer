-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_notify_player_xiapao(stPlayer, msg)
    LOG_DEBUG("Run LogicStep notify_player_xiapao, %d", GGameCfg.TimerSetting.XiaPaoTimeOut)
    CSMessage.NotifyAskXiaPao(stPlayer, {0,1,2,3})

    return STEP_SUCCEED
end


return logic_notify_player_xiapao
