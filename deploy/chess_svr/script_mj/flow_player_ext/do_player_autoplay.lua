-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_do_player_autoplay(stPlayer, msg)
    LOG_DEBUG("Run LogicStep do_player_autoplay")
    local nStatus = msg._para.setStatus
      if type(nStatus) ~= 'boolean'  then
        LOG_ERROR("logic_do_player_autoplay Error msg._para. msg._para:%s\n", vardump(msg))
        CSMessage.NotifyError(stPlayer, ERROR_PARAM_ERR)
        return STEP_FAILED
    end
    stPlayer:SetIsTrust(nStatus)

    -- 通知 托管
    CSMessage.NotifyTrustToAll(stPlayer, nStatus)
    local nTurn = GRoundInfo:GetWhoIsOnTurn()
    local nChair = stPlayer:GetChairID()
    if nStatus and nTurn== nChair then
        CSMessage.NotifyAskPlay(stPlayer, true,true)
        --FlowFramework.DelTimer(stPlayer:GetChairID(), 0)
    end
    return STEP_SUCCEED
end


return logic_do_player_autoplay
