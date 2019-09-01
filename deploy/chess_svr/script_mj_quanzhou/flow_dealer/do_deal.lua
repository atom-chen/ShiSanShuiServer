-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_do_deal(dealer, msg)
    LOG_DEBUG("Run LogicStep do_deal")
    local stGameState = GGameState
    local stRoundInfo = GRoundInfo
    local stDealerCardGroup = dealer:GetDealerCardGroup()

    local stCardCount = {}
    -- 发牌
    for i=1, PLAYER_NUMBER do
        local stPlayer = stGameState:GetPlayerByChair(i)
        local stPlayerCardGroup = stPlayer:GetPlayerCardGroup()
        for j=1,16 do
            stPlayerCardGroup:AddCard(stDealerCardGroup:GetOneCard())
        end
        -- dealer 多一张牌
        if i == stRoundInfo:GetBanker() then
            local nCard = stDealerCardGroup:GetOneCard()
            stPlayerCardGroup:AddCard(nCard)
            stRoundInfo:SetLastDraw(nCard)
        end
        stCardCount["p" .. i] = stPlayerCardGroup:GetCurrentLength()
    end
    -- 开局不需要再抓牌
    stRoundInfo:SetNeedDraw(false)
    -- 通知玩家发牌了
    local nDealerCardLeft = stDealerCardGroup:GetCurrentLength()
    for i=1,PLAYER_NUMBER do
        local stPlayer = stGameState:GetPlayerByChair(i)
        CSMessage.NotifyPlayerDeal(stPlayer, stCardCount,nDealerCardLeft)
    end

    stRoundInfo:SetWhoIsOnTurn(stRoundInfo:GetBanker())
    stRoundInfo:SetWhoIsNextTurn(stRoundInfo:GetBanker())

    dealer:ToNextStage()
    
    return STEP_SUCCEED
end


return logic_do_deal
