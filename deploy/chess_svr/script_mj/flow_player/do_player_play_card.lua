-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_do_player_play_card(stPlayer, msg)
    LOG_DEBUG("Run LogicStep do_player_play_card")
    if type(msg._para.cards) ~= 'table' or #msg._para.cards ~= 1 then
        LOG_ERROR("do_player_play_card Error msg._para. msg._para:%s\n", vardump(msg))
         CSMessage.NotifyError(stPlayer, ERROR_PARAM_ERR)
        return STEP_FAILED
    end
    local card = msg._para.cards[1]
    if type(card) ~= 'number' then
        CSMessage.NotifyError(stPlayer, ERROR_PARAM_ERR)
        return STEP_FAILED
    end

    local nChair = stPlayer:GetChairID()
    local stPlayerCardGroup = stPlayer:GetPlayerCardGroup()
    if  stPlayerCardGroup:IsHave(card) == false then
        LOG_DEBUG("card is false====%d",card)
        CSMessage.NotifyError(stPlayer, ERROR_PLAYER_CARDGROUP)
    end
    -- 重置超时次数
    LibAutoPlay:ResetPlayerTimeOut(nChair)

    local iResult = LibGameLogic:ProcessOPPlay(stPlayer, card)
    if iResult ~= 0 then
        return STEP_FAILED
    end
    if GGameCfg.nMoneyMode ~= ROOM_MODE_SCORE or GGameCfg.TimerSetting.TimeOutLimit ~= -1 then
        FlowFramework.DelTimer(nChair, 0)
    else 
        FlowFramework.DelTimer(nChair, -1)
    end
    -- SSMessage.WakeupDealer()
    return STEP_SUCCEED
end


return logic_do_player_play_card
