-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_do_player_changecard(stPlayer, msg)
    LOG_DEBUG("Run LogicStep do_player_changecard")
    local stCards = msg._para.cards
    if type(stCards) ~= "table" or #stCards == 0 then 
        CSMessage.NotifyError(stPlayer, ERROR_PARAM_ERR)
        return STEP_FAILED
    end
    local iRetCode = LibChangeCard:ProcessChangeCard(stPlayer, stCards)
    if iRetCode ~= 0 then
        LOG_ERROR("do_player_changecard Failed. iRetCode:%d\n", iRetCode)
        CSMessage.NotifyError(stPlayer, iRetCode)
        return STEP_FAILED
    end
    if GGameCfg.nMoneyMode ~= ROOM_MODE_SCORE or GGameCfg.TimerSetting.TimeOutLimit ~= -1 then
        FlowFramework.DelTimer(stPlayer:GetChairID(), 0)
    else 
        FlowFramework.DelTimer(stPlayer:GetChairID(), -1)
    end
    return STEP_SUCCEED
end


return logic_do_player_changecard
