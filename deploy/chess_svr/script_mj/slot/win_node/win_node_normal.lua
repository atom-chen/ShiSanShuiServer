

local function CheckWinNormal(arrPlayerCards)
    local nSize = #arrPlayerCards
    if nSize < 2 or nSize > 17 or nSize % 3 ~= 2 then
        return false
    end
    if nSize == 2 then
        return arrPlayerCards[1] == arrPlayerCards[2]
    end
    local arrCards = clone(arrPlayerCards)
    Array.Sort(arrCards)
    -- 检查顺子
    for i=1,nSize - 2 do
        local card = arrPlayerCards[i]
        if  card > CARD_BALL_9 then
            -- 到箭牌了
            break
        end
        if Array.Exist(arrCards, card + 1) and Array.Exist(arrCards, card + 2) then
            local arrCardTmp = Array.Clone(arrPlayerCards)
            Array.RemoveOne(arrCardTmp, card)
            Array.RemoveOne(arrCardTmp, card + 1)
            Array.RemoveOne(arrCardTmp, card + 2)
            if CheckWinNormal(arrCardTmp) then
                --LOG_DEBUG("CheckWinNormal win :%s", vardump(arrPlayerCards));
                return true
            end
        end
    end
    --  检查刻子

    for i=1,nSize - 2 do
        local card = arrPlayerCards[i]
        if not (i > 1 and card == arrPlayerCards[i - 1] ) then
            local cardTriplet = {card, card, card}
            if Array.IsSubSet(cardTriplet, arrPlayerCards) then
                local arrCardTmp = Array.Clone(arrPlayerCards)
                Array.RemoveOne(arrCardTmp, card)
                Array.RemoveOne(arrCardTmp, card)
                Array.RemoveOne(arrCardTmp, card)
                if CheckWinNormal(arrCardTmp) then
                    --LOG_DEBUG("CheckWinNormal win :%s", vardump(arrPlayerCards));
                    return true
                end
            end
        end
    end
    return false
end


return CheckWinNormal