-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_do_changecard_end(dealer, msg)
    LOG_DEBUG("Run LogicStep do_changecard_end")
    local nChangeType = LibChangeCard:GetChangeCardType()
    local stGameState = GGameState
    for i=1,PLAYER_NUMBER do
        local stNewCards  = LibChangeCard:GetChangeCardResCard(i)
        local stPlayer = stGameState:GetPlayerByChair(i)
        local stPlayerCardGroup = stPlayer:GetPlayerCardGroup()
        for j=1,#stNewCards do
            stPlayerCardGroup:AddCard(stNewCards[j])
        end
        local stOldCards = LibChangeCard:GetChangedCard(i)
        CSMessage.NotifyChangeCard(stPlayer,  nChangeType, stOldCards, stNewCards)
    end
    dealer:ToNextStage()
    return STEP_SUCCEED
end


return logic_do_changecard_end
