local LibBase = import(".lib_base")
local LibNormalCardLogic = class("LibNormalCardLogic", LibBase)

function LibNormalCardLogic:ctor()
end

function LibNormalCardLogic:CreateInit(strSlotName)
    return true
end

function LibNormalCardLogic:OnGameStart()
end

--移除
function LibNormalCardLogic:RemoveCard(srcCards, rmCards)
    if type(srcCards) ~= "table" then
        return
    end
    if type(rmCards) ~= "table" then
        return
    end
    if #srcCards == 0 or #rmCards == 0 then
        return
    end

    for _, v in ipairs(rmCards) do
        Array.RemoveOne(srcCards, v)
    end
end

--按值升序 2-14(A)
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
--分花色排序 花色相同按值升序
function LibNormalCardLogic:Sort_By_Color(cards)
    -- LOG_DEBUG("LibNormalCardLogic:Sort_By_Color..before, cards: %s\n", TableToString(cards))
    table.sort(cards, function(a,b)
        local valueA,colorA = GetCardValue(a), GetCardColor(a)
        local valueB,colorB = GetCardValue(b), GetCardColor(b)
        if colorA == colorB then
            return valueA < valueB
        else
            return colorA < colorB
        end
    end)
    cards.isSorted = false
    -- LOG_DEBUG("LibNormalCardLogic:Sort_By_Color..end, cards: %s\n", TableToString(cards))
end
--按值排序  从小到大
function LibNormalCardLogic:Sort_By_Value(values)
    if not values.isSorted then
        table.sort(values, function(a, b)
            return a < b
        end)
        values.isSorted = true
    end
end


--===================获取手牌的牛数==================

--获取点数相同的所有数据
function libRecomand:Get_Same_Poker(cards, count)
    local hash = {}
    for i=1, 14 do
        hash[i] = {}
    end

    for i, v in ipairs(cards) do
        local nV = GetCardValue(v)
        table.insert(hash[nV], v)
    end

    local t = {}
    for i, v in ipairs(hash) do
        if #v == count then
            table.insert(t, v)
        end
    end

    if #t > 0 then
        return true, t[#t]
    else
        return false
    end
end

--获取五花牛
function  LibNormalCardLogic:GetFiveFloarCow(cards)
    local stCards = Array.Clone(cards)
    for k, v in ipairs(stCards) do
        local tempVal = GetCardValue(v)
        if tempVal < 10 then
            return false
        end
    end
    return true
end

--获取炸弹牛
function  LibNormalCardLogic:GetBombCow(cards)
    return self:Get_Same_Poker(cards, 4)
end

--获取五小牛
function  LibNormalCardLogic:GetFiveLittleCow(cards)
    local stCards = Array.Clone(cards)
    local TotalCardVal = 0
    for k, v in ipairs(stCards) do
        local tempVal = GetCardValue(v)
        if tempVal > 5 then
            return false
        end
        TotalCardVal = TotalCardVal + tempVal
    end
    if TotalCardVal > 10 then
        return false
    end
    return true
end



--判断是否有牛并返回对应三张牌
function LibNormalCardLogic:IsCow(cards)
    local t = {}
    local bSuc = false
    local stCards = Array.Clone(cards) 
    for i=1, #stCards-2 do
        for j=i+1, #stCards-1 do
            for k=j+1, #stCards do
                local TempCard1 = GetCardValue(stCards[i])
                local TempCard2 = GetCardValue(stCards[j])
                local TempCard3 = GetCardValue(stCards[k])
                if TempCard1 > 10 then
                    TempCard1 = 10
                end
                if TempCard2 > 10 then
                    TempCard2 = 10
                end
                if TempCard3 > 10 then
                    TempCard3 = 10
                end
                if (TempCard1 + TempCard2 +TempCard3)%10 == 0 then
                    bSuc = true
                    table.insert(t, stCards[i]) 
                    table.insert(t, stCards[j])
                    table.insert(t, stCards[k])
                    return bSuc, t 
                end 
            end
        end
    end
    return bSuc
end

--获取牛数及按规则排序的牌（对外接口）
function LibNormalCardLogic:GetCowNum(cards)
    local stCards = Array.Clone(cards)

    local ret = {}
    local CowNum = 0
    if LibNormalCardLogic:GetFiveLittleCow(cards) then
        CowNum = 13
        return CowNum, Array.Clone(cards)
    end
    if LibNormalCardLogic:GetBombCow(cards) then
        CowNum = 12
        return CowNum, Array.Clone(cards)
    end
    if LibNormalCardLogic:GetFiveFloarCow(cards) then
        CowNum = 11
        return CowNum, Array.Clone(cards)
    end
   
    local bSuc, t = LibNormalCardLogic:IsCow(stCards)
    if bSuc then
        LibNormalCardLogic:RemoveCard(stCards, t)
        local tempVal = 0
        for k, v in ipairs(stCards)
            local cardVal = GetCardValue(v)
            if cardVal > 10 then
                cardVal = 10
            end
            tempVal = tempVal + cardVal
        end
        for k1, v1 in ipairs(t) do
            table.insert(ret, v1)
        end
        for k2, v2 in ipairs(stCards) do
            table.insert(ret, v2)
        end
        
        CowNum = tempVal%10
        if CowNum == 0 then
            CowNum = 10
        end
        return CowNum, ret
    end
    return CowNum, Array.Clone(cards)
end


--============================================================
--比牌(对外接口)
function LibNormalCardLogic:CompareCards(cardsA, cardsB)
    LOG_DEBUG("LibNormalCardLogic:CompareCards.., cardsA: %s, cardsB: %s\n", TableToString(cardsA), TableToString(cardsB))
    local tempA = Array.Clone(cardsA)
    local tempB = Array.Clone(cardsB)
    local CowNum1 = self:GetCowNum(tempA)
    local CowNum2 = self:GetCowNum(tempB)
    -- LOG_DEBUG("LibNormalCardLogic:CompareCards.., type1: %d, type2: %d\n", type1, type2)

    if CowNum1 == CowNum2 then
        --比炸弹牛
        if CowNum1 == 12 then
            local bSuc1, t1 = self.GetBombCow(tempA)
            local bSuc2, t2 = self.GetBombCow(tempB)
            if t1[1] > t2[1] then
                return 1
            else
                return -1
            end
        end
            --比单张大小
        local tempVal = self:CompareSingle(tempA, tempB)
        if tempVal ~= 0 then
            return tempVal
        else
            --大小相等比花色
            return self.CompareColor(tempA, tempB)
        end
    else
        return CowNum1 - CowNum2
    end
end

function LibNormalCardLogic:CompareColor(cardsA, cardsB)
    if #cardsA == 0 and #cardsB == 0 then
        return 0
    elseif #cardsA == 0 then
        return -1
    elseif #cardsB == 0 then
        return 1
    end

    self:Sort(cardsA)
    self:Sort(cardsB)

    local ca = GetCardColor(cardsA[#cardsA])
    local cb = GetCardColor(cardsB[#cardsB])
    local n = ca - cb
    if n ~= 0 then
        return n
    end
end 

--比较散牌：从大到小 一对一比较
function LibNormalCardLogic:CompareSingle(cardsA, cardsB)
    if #cardsA == 0 and #cardsB == 0 then
        return 0
    elseif #cardsA == 0 then
        return -1
    elseif #cardsB == 0 then
        return 1
    end

    self:Sort(cardsA)
    self:Sort(cardsB)

    local va = GetCardValue(cardsA[#cardsA])
    local vb = GetCardValue(cardsB[#cardsB])
    local ca = GetCardColor(cardsA[#cardsA])
    local cb = GetCardColor(cardsB[#cardsB])
    local n = va - vb
    local m = ca - cb 
    if n ~= 0 then
        --比值大小
        return n
    else
        --比花色大小
        return m
    end
end


return LibNormalCardLogic