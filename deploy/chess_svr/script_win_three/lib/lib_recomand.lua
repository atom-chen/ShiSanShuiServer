local LibBase = import(".lib_base")
local libRecomand = class("libRecomand", LibBase)

function libRecomand:ctor()
end

function libRecomand:CreateInit(strSlotName)
    return true
end

function libRecomand:OnGameStart()
end

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

--3条
function libRecomand:Get_Pt_Three(cards)
    return self:Get_Same_Poker(cards, 3)  
end

--同花顺 
function libRecomand:Get_Pt_Straight_Flush(cards)
    local bFind = false
    local bSuc1, t1 = self.Get_Pt_Flush(cards)
    if bSuc1 then
        local bSuc2, t2 = self.Get_Pt_Straight(t1)
        if bSuc2 then
            bFind = true
            return bFind, t2  
        end
    end
    return bFind
end

--同花
function libRecomand:Get_Pt_Flush(cards)
    if #cards == 0 then
        return false
    end
    local bFind = true
    local tempColor = GetCardColor(cards[1])
    for k, v in ipairs(cards) do
        local Color = GetCardColor(v)
        if tempColor ~= Color then
            return false
        end
    end
    return bFind, Array.Clone(cards)
end


--顺子
function libRecomand:Get_Pt_Straight(cards)
    self:Sort(cards)
    local nLen = #cards
    local a1, an = GetCardValue(cards[1]), GetCardValue(cards[nLen])
    if a1 == 2 and an ==14 then
        local a = a1
        for i=2, nLen-1 do
            local rank = GetCardValue(cards[i])
            if rank-a ~= 1 then
                return false
            end
            a = rank
        end
        return true, Array.Clone(cards)
    else
        local a = a1
        for i=2, nLen do
            local rank = GetCardValue(cards[i])
            if rank-a ~= 1 then
                return false
            end
            a = rank
        end
        return true, Array.Clone(cards)
    end
end

--1对
function libRecomand:Get_Pt_One_Pair(cards)
    return self:Get_Same_Poker(cards, 2)
end

--判断是否是2 3 5
function libRecomand:Get_Little_One(cards)
    self.Sort(cards)
    if #cards <3 then
        return false
    end
    local a1, a2, a3 = GetCardValue(cards[1]), GetCardValue(cards[2]), GetCardValue(cards[3])  
    if a1 ~= 2 or a2 ~= 3 or a3 ~= 5 then
        return false
    end
    return true 
end

function libRecomand:GetCardType(cards)
    local bSuc1, t1 = self.Get_Pt_Three(cards)
    if bSuc1 then
        return 6, t1 
    end
    local bSuc2, t2 = self.Get_Pt_Straight_Flush(cards)
    if bSuc2 then
        return 5, t2
    end
    local bSuc3, t3 = self.Get_Pt_Flush(cards)
    if bSuc3 then
        return 4, t3 
    end
    local bSuc4, t4 = self.Get_Pt_Straight(cards)
    if bSuc4 then
        return 3, t4
    end
    local bSuc5, t5 = self.Get_Pt_One_Pair(cards)
    if bSuc5 then
        return 2, t5
    end
    return 1, Array.Clone(cards)
     
end 


--比较散牌：从大到小 一对一比较
function libRecomand:CompareSingle(cardsA, cardsB)
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
    local n = va - vb
    if n ~= 0 then
        return n
    else
        table.remove(cardsA)
        table.remove(cardsB)
        return self:CompareSingle(cardsA, cardsB) 
    end
end

--比较花色
function libRecomand:CompareColor(cardsA, cardsB)
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


--普通牌型比牌(对外接口)
function libRecomand:CompareCards(cardsA, cardsB)
    -- LOG_DEBUG("LibNormalCardLogic:CompareCards.., cardsA: %s, cardsB: %s\n", TableToString(cardsA), TableToString(cardsB))
    local tempA = Array.Clone(cardsA)
    local tempB = Array.Clone(cardsB)
    local type1, tA = self:GetCardType(tempA)
    local type2, tB = self:GetCardType(tempB)
    -- LOG_DEBUG("LibNormalCardLogic:CompareCards.., type1: %d, type1: %d\n", type1, type2)

    if type1 == type2 then
        if type1 == 6 then
            local p1 = GetCardValue(tA[#tA])
            local p2 = GetCardValue(tB[#tB])
            if p1 ~= p2 then
                return p1 - p2
            end
        elseif type1 == 2 then
            --对子比较（对子相等，单张也相等，比最大的牌的花色）
            local p1 = GetPairValue(tA)
            local p2 = GetPairValue(tB)
            if p1 ~= p2 then
                return p1 - p2
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
        if type1 == 6 and type2 == 1 then 
            local temp2 = self.Get_Little_One(tempB)
            if temp2 then
                return -1
            end
        elseif type2 == 6 and type1 == 1 then
            local temp1 = self.Get_Little_One(tempA)
            if temp1 then
                return 1
            end
        end

        return type1 - type2
    end
end


return libRecomand