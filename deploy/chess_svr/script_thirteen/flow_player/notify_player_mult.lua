-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_notify_player_mult(stPlayer, msg)
    LOG_DEBUG("Run LogicStep notify_player_mult, %d", GGameCfg.TimerSetting.multTimeOut)
    local stMult = {}
    local nMaxMult = GGameCfg.GameSetting.nSupportMaxMult
    for i=1, nMaxMult do
        table.insert(stMult, i)
    end
    CSMessage.NotifyAskMult(stPlayer, stMult)
    return STEP_SUCCEED
end


return logic_notify_player_mult