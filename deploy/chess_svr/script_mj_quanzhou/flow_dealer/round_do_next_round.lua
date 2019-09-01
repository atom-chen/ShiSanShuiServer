
-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_round_do_next_round(dealer, msg)
    local stRoundInfo = GRoundInfo
    local stGameState = GGameState

    local is_first_card = false

    -- 轮到谁操作
    local thisTurn = stRoundInfo:GetWhoIsNextTurn()
    stRoundInfo:SetWhoIsOnTurn(thisTurn)
    LOG_DEBUG("Run LogicStep round_do_next_round thisTurn:%d", thisTurn)

    local stPlayer = stGameState:GetPlayerByChair(thisTurn)
    if stPlayer == nil then
        LOG_DEBUG("stPlayer == nil thisTurn:%d", thisTurn)
        return STEP_FAILED
    end

    if stGameState:IsPlayStart() == false then
        LOG_DEBUG("=======first  is true now")
        is_first_card = true
        stGameState:SetPlayStart(true)
        -- 设置庄家第一次出牌  抢金用到
        stRoundInfo:SetDealerFirstTurn(true)
        -- 通知玩家开始打牌
        CSMessage.NotifyAllPlayStart()
    end
    LOG_DEBUG("logic_round_do_next_round...is_first_card: %s, IsPlayFirstCard: %s", tostring(is_first_card), tostring(GRoundInfo:IsPlayFirstCard()))

    if is_first_card then
        LOG_DEBUG("logic_round_do_next_round....play first card...SSMessage.CallPlayerGiveCard")
        -- 出第一张牌 注意抢金操作
        SSMessage.CallPlayerGiveCard(stPlayer)
        is_first_card = false
    else
        -- 剩余的牌数量+从尾部拿掉的牌
        local nDealerCardLeft = dealer:GetDealerCardGroup():GetCurrentLength()
        local nDealerCardLeftEXceptGang = 0   -- dealer:GetDealerCardGroup():GetCurrentCardLeftEXceptGang() 
        local nCardLocation = nDealerCardLeft + nDealerCardLeftEXceptGang

        LOG_DEBUG("======nLeftCardNeedQuict = %d\n", GGameCfg.nLeftCardNeedQuict)
        if stRoundInfo:IsNeedDraw()
            and nDealerCardLeft > 0 
            and nCardLocation > GGameCfg.nLeftCardNeedQuict then
            -- 发一张牌
            LOG_DEBUG("=======first card is false and need")
            stRoundInfo:SetNeedDraw(false)
            local bLast = stRoundInfo:GetGang()
            local card = dealer:GetDealerCardGroup():GetOneCard(bLast)
            nDealerCardLeft = nDealerCardLeft -1
            LOG_DEBUG("_chair:%d Draw Card:%d", stPlayer:GetChairID(), card)

            local stCards = {card}
            stRoundInfo:SetLastDraw(card)
            stPlayer:GetPlayerCardGroup():AddCard(card)
            if bLast then
                stRoundInfo:SetDrawStatus(DRAW_STATUS_GANG)
            else
                stRoundInfo:SetDrawStatus(DRAW_STATUS_NONE)
            end
            LOG_DEBUG("logic_round_do_next_round...gangDraw:%s", tostring(bLast))
            
            if stPlayer:GetPlayerCardGroup():GetCurrentLength() > MAX_HAND_CARD_NUM then
                LOG_ERROR("%d xianggong %s", stPlayer:GetChairID(), vardump(stPlayer:GetPlayerCardGroup()))
            end
            -- 通知玩家拿的是什么牌
            CSMessage.NotifyPlayerGiveCard(stPlayer,stCards,nDealerCardLeft)
            -- 拿牌后操作：检查 杠 听 胡逻辑
            SSMessage.CallPlayerGiveCard(stPlayer)
        else
            LOG_DEBUG("=========logic_round_do_next_round, SSMessage.CallPlayerAskPlay...chairid:%d", stPlayer:GetChairID())
            -- 通知玩家出牌
            SSMessage.CallPlayerAskPlay(stPlayer)
        end
    end   
    return STEP_SUCCEED
end


return logic_round_do_next_round
