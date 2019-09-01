-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_do_player_changeflower(stPlayer, msg)
    LOG_DEBUG("Run LogicStep do_player_changeflower")
    -- 剩余17张牌  不管摸到的牌是否是花牌强制结束
    -- 花牌是所有人都可以看到的
    local function checkGameEnd()
        --荒牌判断，加上杠牌的手牌数
        local nDealerCardLeft = GDealer:GetDealerCardGroup():GetCurrentLength()
        --杠牌后从牌尾摸的牌
        local nDealerCardLeftEXceptGang = 0
        local nWinPlayerNums = 0
        -- 判断是否游戏结束
        if LibGameEndJudge:IsGameEnd(nWinPlayerNums, nDealerCardLeft, nDealerCardLeftEXceptGang) then
            return true
        end
        return false
    end

    local bGameEnd = false
    local stFlowerCards = {}
    local stNewCards = {}
    local stDealerCardGroup = GDealer:GetDealerCardGroup()
    local stPlayerCardGroup = stPlayer:GetPlayerCardGroup()
    for i=1,stPlayerCardGroup:GetCurrentLength() do
        local nCard = stPlayerCardGroup:GetCardAt(i)
        if LibFlowerCheck:IsFlowerCard(nCard) then
            --检查是否牌局结束  把已换好的牌，发送给玩家
            if checkGameEnd() then
                LOG_DEBUG("do_player_changeflower....checkGameEnd() == true")
                GRoundInfo:SetNeedDraw(false)
                stPlayerCardGroup:SetLastDraw(nNewCard)
                bGameEnd = true
                break
            end
            table.insert(stFlowerCards, nCard)
            --牌尾补花
            local nNewCard = stDealerCardGroup:GetOneCard(true)
            table.insert(stNewCards, nNewCard)
        end
    end
    LOG_DEBUG("logic_do_player_changeflower...stFlowerCards: %s, stNewCards: %s", vardump(stFlowerCards), vardump(stNewCards))
    --有花牌 则换
    local nDealerCardLeft = stDealerCardGroup:GetCurrentLength()
    if #stFlowerCards > 0 
        and #stNewCards > 0 
        and #stFlowerCards == #stNewCards then
        --手牌去掉花牌
        for _, v in ipairs(stFlowerCards) do
            stPlayerCardGroup:DelCard(v)
            --保存花牌 结算计番用到
            stPlayer:AddFlowerCard(v)
        end
        --手牌加上补牌
        for _, v in ipairs(stNewCards) do
            stPlayerCardGroup:AddCard(v)
        end

        CSMessage.NotifyChangeFlower(stPlayer, stFlowerCards, stNewCards, nDealerCardLeft)
        CSMessage.NotifyChangeFlowerToOther(stPlayer, stFlowerCards, nDealerCardLeft)
    end
    --游戏结束 跳到结算部分
    if bGameEnd then
        GDealer:SetGameReward()
        return STEP_SUCCEED
    end

    -- ask give
    if GDealer:GetCurrStage() ~= "changeflower" then
        SSMessage.CallPlayerGiveCard(stPlayer)
    end

   return STEP_SUCCEED
  
end


return logic_do_player_changeflower
