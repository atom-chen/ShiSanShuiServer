local LibBase = import(".lib_base")
local LibNormalCardLogic = class("LibNormalCardLogic", LibBase)

function LibNormalCardLogic:ctor()
end

function LibNormalCardLogic:CreateInit(strSlotName)
    return true
end

function LibNormalCardLogic:OnGameStart()
end

--按值升序 A-k
function LibNormalCardLogic:Sort(cards)
    -- LOG_DEBUG("LibNormalCardLogic:Sort..before, cards: %s\n", TableToString(cards))
    if not cards.isSorted then
        table.sort(cards, function(a,b)
            local valueA,colorA = GetCardValue(a), GetCardColor(a)
            local valueB,colorB = GetCardValue(b), GetCardColor(b)
            if valueA == valueB then
                return colorA < colorB
            else
                return valueA < valueB
            end
        end)
        cards.isSorted = true
    end
    -- LOG_DEBUG("LibNormalCardLogic:Sort..end, cards: %s\n", TableToString(cards))
end

function LibNormalCardLogic:Get_Same_Poker(cards, count)
    local hash = {}
    for i=1, 14 do
        hash[i] = {}
    end

    for i, v in ipairs(cards) do
        local nV = GetCardValue(v)
        table.insert(hash[nV], v)
    end

    for i, v in ipairs(hash) do
        if #v >= count then
            return true
        end
    end
    return false
end

--五花牛
function LibNormalCardLogic:Is_Pt_Bull_Flower(cards)
    for i=1, 5 do
        local nValue = GetCardValue(cards[i])
        --任意一张不为JQK则返回false
        if nValue < 10 or nValue > 13 then
            return false
        end
    end
    return true
end

--炸弹牛
function LibNormalCardLogic:Is_Pt_Bull_Bomb(cards)
    return self:Get_Same_Poker(cards, 4)
end

--五小牛
function LibNormalCardLogic:Is_Pt_Bull_Small(cards)
    local nSum = 0
    for i=1, 5 do
        local nValue = GetCardValue(cards[i])
        --所有牌均小于5
        if nValue >= 5 then
            return false
        end

        nSum = nSum + nValue
        --点数总和小于10
        if nSum > 10 then
            return false
        end
    end
    return true
end

--牌型
function LibNormalCardLogic:GetCardType(cards)
    local cardType = GStars_Normal_Type.PT_BULL_NONE
    local tempCards = Array.Clone(cards)

    --五花牛
    if self:Is_Pt_Bull_Flower(tempCards) then
        return GStars_Normal_Type.PT_BULL_FLOWER
    --炸弹牛
    elseif self:Is_Pt_Bull_Bomb(tempCards) then
        return GStars_Normal_Type.PT_BULL_BOMB
    --五小牛
    elseif self:Is_Pt_Bull_Small(tempCards) then
        return GStars_Normal_Type.PT_BULL_SMALL
    else
        --牛1~9 牛牛
        for i=1,3 do
            for j=i+1,4 do
                for k=j+1,5 do
                    --计算3张牌点数之和是否为10的倍数
                    local nSum = GetCardValue(tempCards[i]) + GetCardValue(tempCards[j]) + GetCardValue(tempCards[k])
                    if nSum % 10 == 0 then
                        local nLeftSum = 0
                        for m=1,5 do
                            if m~=i and m~=j and m~=k then
                                nLeftSum = nLeftSum + GetCardValue(tempCards[m])
                            end
                        end
                        nLeftSum = nLeftSum % 10

                        if nLeftSum == 0 then
                            return GStars_Normal_Type.PT_BULL_TEN
                        elseif nLeftSum == 1 then
                            return GStars_Normal_Type.PT_BULL_ONE
                        elseif nLeftSum == 2 then
                            return GStars_Normal_Type.PT_BULL_TWO
                        elseif nLeftSum == 3 then
                            return GStars_Normal_Type.PT_BULL_THREE
                        elseif nLeftSum == 4 then
                            return GStars_Normal_Type.PT_BULL_FOUR
                        elseif nLeftSum == 5 then
                            return GStars_Normal_Type.PT_BULL_FIVE
                        elseif nLeftSum == 6 then
                            return GStars_Normal_Type.PT_BULL_SIX
                        elseif nLeftSum == 7 then
                            return GStars_Normal_Type.PT_BULL_SEVEN
                        elseif nLeftSum == 8 then
                            return GStars_Normal_Type.PT_BULL_EIGHT
                        elseif nLeftSum == 9 then
                            return GStars_Normal_Type.PT_BULL_NINE
                        end
                    end
                end
            end
        end
    end

    -- LOG_DEBUG("LibNormalCardLogic:GetCardType.., cardType: %d\n", cardType)
    return cardType
end

--比牌
function LibNormalCardLogic:CompareCards(typeA, typeB, cardsA, cardsB)
    --1.先比牌型
    if typeA == typeB then
        local tempA = Array.Clone(cardsA)
        local tempB = Array.Clone(cardsB)
        self:Sort(tempA)
        self:Sort(tempB)

        --炸弹牛比较
        if typeA == GStars_Normal_Type.PT_BULL_BOMB then
            local nValueA = GetCardValue(tempA[3])
            local nValueB = GetCardValue(tempB[3])
            return nValueA - nValueB
        else
            local nValueA = GetCardValue(tempA[#tempA])
            local nValueB = GetCardValue(tempB[#tempB])
            --2.再比点数
            if nValueA == nValueB then
                --3.最后比花色
                local nColorA = GetCardColor(tempA[#tempA])
                local nColorB = GetCardColor(tempB[#tempB])
                return nColorA - nColorB
            else
                return nValueA - nValueB
            end
        end
    else
        return typeA - typeB
    end
end

return LibNormalCardLogic