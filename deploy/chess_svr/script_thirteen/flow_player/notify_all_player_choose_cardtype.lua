-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_notify_all_player_choose_cardtype(stPlayer, msg)
    LOG_DEBUG("Run LogicStep notify_all_player_choose_cardtype...p%d, uid:%d, IsChooseCardType:%s", stPlayer:GetChairID(), stPlayer:GetUin(), tostring(stPlayer:IsChooseCardType()))
    if stPlayer:IsChooseCardType() then
    	CSMessage.NotifyPlayerChooseCardType(stPlayer)
    end
    
    return STEP_SUCCEED
end

return logic_notify_all_player_choose_cardtype