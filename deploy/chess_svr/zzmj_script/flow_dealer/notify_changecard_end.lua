-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
-- 处理换张结果
local function logic_notify_changecard_end(dealer, msg)
    LOG_DEBUG("Run LogicStep notify_changecard_end")
    local stGameState = GGameState
    for i=1,PLAYER_NUMBER do
        local stNewCards  = LIbChangeCard:GetChangeCardResCard(i)
        local stPlayer = stGameState:GetPlayerByChairID(i)
        local stPlayerCardGroup = stPlayer:GetPlayerCardGroup()
        for j=1,#stNewCards do
            stPlayerCardGroup:AddCard(stNewCards[j])
        end
        local stOldCards = LIbChangeCard:GetChangedCard()
        CSMessage.NotifyChangeCard(stPlayer,  stOldCards, stNewCards)
    end
    dealer:ToNextStage()
    return STEP_SUCCEED
end


return logic_notify_changecard_end
