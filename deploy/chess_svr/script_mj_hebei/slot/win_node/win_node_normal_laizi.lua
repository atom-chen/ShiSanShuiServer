

local function CheckWinNormalLaiZi(arrPlayerCards, nLaiZiCount)
    local nSize = #arrPlayerCards
    if nSize < 2 or nSize > 17 or nSize % 3 ~= 2 then
        return false
    end
    if nSize == 2  then
        if nLaiZiCount > 0 then
            return true
        else
            return arrPlayerCards[1] == arrPlayerCards[2]
        end
    end
    local arrCards = clone(arrPlayerCards)
    Array.Sort(arrCards)
    local nLaiZiLastCount = 0
    -- 检查顺子
    for i=1,nSize do
        local card = arrPlayerCards[i]
        if card > CARD_BALL_9 then
            -- 到箭牌了
            break
        end
        local arrCardTmp = Array.Clone(arrPlayerCards)
        --正常情况
        if Array.Exist(arrCards, card + 1) and Array.Exist(arrCards, card + 2) then
            Array.RemoveOne(arrCardTmp, card)
            Array.RemoveOne(arrCardTmp, card + 1)
            Array.RemoveOne(arrCardTmp, card + 2)
            nLaiZiLastCount = nLaiZiCount
            if CheckWinNormalLaiZi(arrCardTmp,nLaiZiLastCount) then
                return true
            end
        -- 只有后面一张，需要癞子填充
        elseif Array.Exist(arrCards, card + 1) and nLaiZiCount >= 1 then
            Array.RemoveOne(arrCardTmp, card)
            Array.RemoveOne(arrCardTmp, card + 1)
            nLaiZiLastCount = nLaiZiCount - 1
            if CheckWinNormalLaiZi(arrCardTmp,nLaiZiLastCount) then
                return true
            end
        -- 有后面第2张，缺中间一张，要判断下这张不能为9
        elseif Array.Exist(arrCards, card + 2) and nLaiZiCount >= 1 and card % 10 ~= 9 then
            Array.RemoveOne(arrCardTmp, card)
            Array.RemoveOne(arrCardTmp, card + 2)
            nLaiZiLastCount = nLaiZiCount - 1
            if CheckWinNormalLaiZi(arrCardTmp,nLaiZiLastCount) then
                return true
            end
        elseif nLaiZiCount >= 2  then
            Array.RemoveOne(arrCardTmp, card)
            nLaiZiLastCount = nLaiZiCount - 2
            if CheckWinNormalLaiZi(arrCardTmp,nLaiZiLastCount) then
                return true
            end
        end
    end
    
    -- 检查刻子
    for i=1,nSize do
        local card = arrPlayerCards[i]
        if not (i > 1 and card == arrPlayerCards[i - 1] ) then
            local cardTriplet = {card, card, card}
            local cardTripletTwo = {card, card}
            local cardTripletOne = {card}
            local arrCardTmp = Array.Clone(arrPlayerCards)
            if Array.IsSubSet(cardTriplet, arrPlayerCards) then
                Array.RemoveOne(arrCardTmp, card)
                Array.RemoveOne(arrCardTmp, card)
                Array.RemoveOne(arrCardTmp, card)
                nLaiZiLastCount = nLaiZiCount
                if CheckWinNormalLaiZi(arrCardTmp,nLaiZiLastCount) then
                    return true
                end
            --只有2个和一个的情况
            elseif Array.IsSubSet(cardTripletTwo, arrPlayerCards)  and nLaiZiCount >= 1 then
                Array.RemoveOne(arrCardTmp, card)
                Array.RemoveOne(arrCardTmp, card)
                nLaiZiLastCount = nLaiZiCount - 1
                if CheckWinNormalLaiZi(arrCardTmp,nLaiZiLastCount) then
                    return true
                end
            elseif Array.IsSubSet(cardTripletOne, arrPlayerCards)  and nLaiZiCount >= 2 then
                Array.RemoveOne(arrCardTmp, card)
                nLaiZiLastCount = nLaiZiCount - 2
                if CheckWinNormalLaiZi(arrCardTmp,nLaiZiLastCount) then
                    return true
                end
            end
        end
    end
    return false
end


return CheckWinNormalLaiZi