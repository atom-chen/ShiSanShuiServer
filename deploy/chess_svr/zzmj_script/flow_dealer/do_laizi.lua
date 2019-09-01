-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_do_laizi(dealer, msg)
    LOG_DEBUG("Run LogicStep do_laizi")
    
    local stGameState = GGameState
    local stRoundInfo = GRoundInfo
    local stDealerCardGroup = dealer:GetDealerCardGroup()



    -- 翻开第杠牌第14张
    local card = stDealerCardGroup:GetCardAt(14);
    local laizi = card
    local cardType = GetCardType(card)
    if cardType == CARDTYPE_CHAR or cardType == CARDTYPE_BAMBOO or cardType == CARDTYPE_BALL then
        laizi = card + 1;
        if (laizi%10 == 0) then
            laizi = card - 8
        end
    else
        -- todo: 风、字先处理成同一种
        laizi = card + 1;
        if (laizi == 38) then
            laizi = 31
        end
    end

    -- todo: 保存进lib.laizi
    LibLaiZi:SetLaiZi({14}, {card}, {laizi})
    CSMessage.NotifyPlayerLaizi(nil, {14}, {card}, {laizi})

    dealer:ToNextStage()
    return STEP_SUCCEED
end


return logic_do_laizi
