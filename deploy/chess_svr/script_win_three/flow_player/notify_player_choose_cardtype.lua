-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_notify_player_choose_cardtype(stPlayer, msg)
    LOG_DEBUG("Run LogicStep notify_player_choose_cardtype, spCancle:%s", tostring(stPlayer:IsCancleSpecial()))
    -- local nTimeout = FlowFramework.CheckHaveTimer(stPlayer:GetChairID(), PLAYER_TIMER_ID_CHOOSE)
    if not stPlayer:IsCancleSpecial() then
        CSMessage.NotifyAskChooseCardType(stPlayer)
    end
    
    return STEP_SUCCEED
end


return logic_notify_player_choose_cardtype
