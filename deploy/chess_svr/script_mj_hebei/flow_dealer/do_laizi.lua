-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_do_laizi(dealer, msg)
    LOG_DEBUG("Run LogicStep do_laizi")
    
    local stGameState = GGameState
    local stRoundInfo = GRoundInfo
    local stDealerCardGroup = dealer:GetDealerCardGroup()

    -- 翻开第杠牌第14张
    local laiziPos = 14  -- 确定癞子牌的哪张牌
    if GGameCfg.RoomSetting.nGameStyle == GAME_STYLE_TANGSHAN then  -- 唐山麻将
        laiziPos = 2 * math.random(1, 6)
    end

    local card = stDealerCardGroup:GetCardAt(laiziPos)
    if GGameCfg.RoomSetting.nGameStyle == GAME_STYLE_LANGFANG then  -- 廊坊麻将
        card = stDealerCardGroup:GetOneCard()
    end
    
    local laizi = card
    local cardType = GetCardType(card)
    if cardType == CARDTYPE_CHAR or cardType == CARDTYPE_BAMBOO or cardType == CARDTYPE_BALL then
        laizi = card + 1;
        if (laizi%10 == 0) then
            laizi = card - 8
        end
    elseif cardType == CARDTYPE_WIND then
        -- todo: 风牌处理
        laizi = card + 1;
        if (laizi == 35) then
            laizi = 31
        end
    else
        -- todo: 字牌处理
        laizi = card + 1;
        if (laizi == 38) then
            laizi = 35
        end
    end

    -- todo: 保存进lib.laizi
    if GGameCfg.RoomSetting.nGameStyle == GAME_STYLE_LANGFANG then  -- 廊坊麻将
        LibLaiZi:SetLaiZi({0}, {card}, {laizi})
        CSMessage.NotifyPlayerLaizi(nil, {0}, {card}, {laizi})
        
        local nChair = stRoundInfo:GetBanker()
        local stPlayer = stGameState:GetPlayerByChair(nChair)
        if stPlayer then
            stPlayer:GetPlayerGiveGroup():AddCard(card)
            stRoundInfo:AddCardShowNum(card)
        else
            return STEP_FAILED
        end
    else
        LibLaiZi:SetLaiZi({laiziPos}, {card}, {laizi})
        CSMessage.NotifyPlayerLaizi(nil, {laiziPos}, {card}, {laizi})
    end
    
    dealer:ToNextStage()
    
    return STEP_SUCCEED
end


return logic_do_laizi
