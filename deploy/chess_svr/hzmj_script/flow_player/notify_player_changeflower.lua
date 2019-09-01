-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_notify_player_changeflower(stPlayer, msg)
    LOG_DEBUG("Run LogicStep notify_player_changeflower")

    local stFlowerCards = {}
    local stPlayerCardGroup = stPlayer:GetPlayerCardGroup()
    for i=1,stPlayerCardGroup:GetCurrentLength() do
        local card = stPlayerCardGroup:GetCardAt(i)
        if LibFlowerCheck:IsFlowerCard(card) then
            table.insert(stFlowerCards, card)   
        end
    end

    CSMessage.NotifyAskChangeFlower(stPlayer. stFlowerCards)

    return STEP_SUCCEED
end


return logic_notify_player_changeflower
