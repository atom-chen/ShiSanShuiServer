-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_do_player_changeflower(stPlayer, msg)
    LOG_DEBUG("Run LogicStep do_player_changeflower")
    local flowerReqList = msg._para.cards
    local num = #flowerReqList 
    if num == 0 then
        return STEP_FAILED
    end

    for i=1,#flowerReqList do
        if flowerReqList[i] < TILE_FLOWER_CHUN or flowerReqList > TILE_FLOWER_JU then
            return STEP_FAILED
        end
    end

    local stRoundInfo = GRoundInfo
    local stDealerCardGroup = GDealer:GetDealerCardGroup()
    local stPlayerCardGroup = stPlayer:GetPlayerCardGroup()
    local stNewCards = {}
    local stFlowerCards = {}
    --[[
    for i=1,#flowerReqList do
        local flowerCard = flowerReqList[i] 
        if stPlayerCardGroup:IsHave(flowerCard) then
                stGameState:SetFlower(flowerCard - TILE_FLOWER_CHUN, stPlayer:GetChairID())
                stPlayerCardGroup:DeCard(flowerCard)
                local newCard = stDealerCardGroup:GetOneCard()
                stPlayerCardGroup:AddCard(newCard)
                table.insert(stNewCards, newCard)
        end
    end
    ]]
    -- 忽略请求部分 以本地为准
    for i=1,stPlayerCardGroup:GetCurrentLength() do
        local card = stPlayerCardGroup:GetCardAt(i)
        if LibFlowerCheck:IsFlowerCard(card) then
                stRoundInfo:SetFlower(flowerCard - TILE_FLOWER_CHUN, stPlayer:GetChairID())
                stFlowerCards[#stFlowerCards+1] = card
                stPlayerCardGroup:DelCard(flowerCard)
                local newCard = stDealerCardGroup:GetOneCard()
                stPlayerCardGroup:AddCard(newCard)
                table.insert(stNewCards, newCard)
        end
    end
   CSMessage.NotifyChangeFlower(stPlayer, stNewCards)
   CSMessage.NotifyChangeFlowerToOther(stPlayer, stFlowerCards)

   FlowFramework.DelTimer(stPlayer:GetChairID(), 0)
   return STEP_SUCCEED
  
end


return logic_do_player_changeflower
