-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_do_player_confirmmiss(stPlayer, msg)
    LOG_DEBUG("Run LogicStep do_player_confirmmiss")
    local nPlayerMiss = msg._para.playerMiss
    if type(nPlayerMiss) ~= 'number' then
         CSMessage.NotifyError(stPlayer, ERROR_PARAM_ERR)
        return STEP_FAILED
    end
    local iResult = LibConfirmMiss:ProcessPlayerConfirmMiss(stPlayer:GetChairID(), nPlayerMiss)

    if iResult ~= 0 then
         CSMessage.NotifyError(stPlayer, iResult)
         return STEP_FAILED
    end
    if GGameCfg.nMoneyMode ~= ROOM_MODE_SCORE or GGameCfg.TimerSetting.TimeOutLimit ~= -1 then
        FlowFramework.DelTimer(stPlayer:GetChairID(), 0)
    else 
        FlowFramework.DelTimer(stPlayer:GetChairID(), -1)
    end
    return STEP_SUCCEED
end


return logic_do_player_confirmmiss
