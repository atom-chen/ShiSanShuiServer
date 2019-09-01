-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_do_deal(dealer, msg)
    LOG_DEBUG("Run LogicStep do_deal")
    local stGameState = GGameState
    local stRoundInfo = GRoundInfo
    local stDealerCardGroup = dealer:GetDealerCardGroup()
    -- 洗牌
    stDealerCardGroup:PrepareDeal()
    -- 发牌
    local stCardCount = {}
    for i=1, PLAYER_NUMBER do
        local stPlayer = stGameState:GetPlayerByChair(i)
        if stPlayer then
            local stPlayerCardGroup = stPlayer:GetPlayerCardGroup()
            for _=1,13 do
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
    end
    stRoundInfo:SetNeedDraw(false)
    
   -- 通知玩家发牌了
   local nDealerCardLeft = stDealerCardGroup:GetCurrentLength()
    for i=1,PLAYER_NUMBER do
        local stPlayer = stGameState:GetPlayerByChair(i)
        if stPlayer then
            CSMessage.NotifyPlayerDeal(stPlayer, stCardCount,nDealerCardLeft)
        end
    end
    stRoundInfo:SetWhoIsOnTurn(stRoundInfo:GetBanker())
    stRoundInfo:SetWhoIsNextTurn(stRoundInfo:GetBanker())
    dealer:ToNextStage()
    return STEP_SUCCEED
end


return logic_do_deal
