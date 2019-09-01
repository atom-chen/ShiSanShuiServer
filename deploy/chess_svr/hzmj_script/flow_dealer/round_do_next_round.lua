
-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_round_do_next_round(dealer, msg)
    local stRoundInfo = GRoundInfo
    local stGameState = GGameState

    local is_first_card

    local thisTurn = stRoundInfo:GetWhoIsNextTurn()
    LOG_DEBUG("===111=Run LogicStep round_do_next_round thisTurn:%d", thisTurn)
    stRoundInfo:SetWhoIsOnTurn(thisTurn)
    LOG_DEBUG("===222=Run LogicStep round_do_next_round thisTurn:%d", thisTurn)

    local stPlayer = GGameState:GetPlayerByChair(thisTurn)
    if stPlayer == nil then
        LOG_ERROR("stPlayer == nil thisTurn:%s", vardump(thisTurn));
        return STEP_FAILED
    end

    if stGameState:IsPlayStart() == false then
        LOG_DEBUG("=======first  is true now")
        is_first_card = true
        stGameState:SetPlayStart(true)
        CSMessage.NotifyAllPlayStart()
    end
-- 需不需要发一张牌给玩家 吃碰之后不摸牌
    local nDealerCardLeft = dealer:GetDealerCardGroup():GetCurrentLength()
    --杠牌后从牌尾摸的牌
	local nDealerCardLeftEXceptGang = dealer:GetDealerCardGroup():GetCurrentCardLeftEXceptGang() 
    --现有的牌树+从尾部拿掉的牌
    local nCardLocation = nDealerCardLeft+nDealerCardLeftEXceptGang
    if is_first_card then
        SSMessage.CallPlayerGiveCard(stPlayer)
        is_first_card = false
    else
        LOG_DEBUG("======nLeftCardNeedQuict = %d\n", GGameCfg.nLeftCardNeedQuict)
        if stRoundInfo:IsNeedDraw() == true and nDealerCardLeft > 0 then
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
            if stRoundInfo:GetGang() == true then
                stRoundInfo:SetDrawStatus(DRAW_STATUS_GANG)
            else
                stRoundInfo:SetDrawStatus(DRAW_STATUS_NONE)
            end
            if stPlayer:GetPlayerCardGroup():GetCurrentLength() > 14 then
	    	-- LOG_ERROR("%d xianggong %s", stPlayer:GetChairID(), vardump(stPlayer:GetPlayerCardGroup()))
	    	LOG_ERROR("XIANGGONG\n");
            end
            CSMessage.NotifyPlayerGiveCard(stPlayer,stCards,nDealerCardLeft)
            SSMessage.CallPlayerGiveCard(stPlayer)
        else
            --CSMessage.NotifyPlayerGiveCard(stPlayer, stCards, nDealerCardLeft )
            SSMessage.CallPlayerAskPlay(stPlayer)
        end
    end   
    return STEP_SUCCEED
end


return logic_round_do_next_round
