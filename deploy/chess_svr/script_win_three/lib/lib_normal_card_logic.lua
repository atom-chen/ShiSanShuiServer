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

--有几张不同点数的牌
function LibNormalCardLogic:Uniqc(cards)
    self:Sort(cards)
    local n, uniq, val = 0, 0, 0
    for _,v in ipairs(cards) do
        val = GetCardValue(v)
        if val ~= uniq then
            uniq = val
            n = n + 1
        end
    end
    return n
end

--是否是同花
function LibNormalCardLogic:IsFlush(cards)
    if #cards == 0 then
        return false
    end
    -- LOG_DEBUG("LibNormalCardLogic:IsFlush.., cards: %s\n", TableToString(cards))

    local color = GetCardColor(cards[1])
    for i=2, #cards do
        if color ~= GetCardColor(cards[i]) then
            return false
        end
    end
    return true
end

-- 是否顺子 普通情况
function LibNormalCardLogic:IsStraight_Common(cards)
    self:Sort(cards)
    local nLen = #cards
    local a1, an = GetCardValue(cards[1]), GetCardValue(cards[nLen])
    if an - a1 ~= nLen - 1 then
        return false
    end
    local a = a1
    for i=2, nLen do
        local rank = GetCardValue(cards[i])
        if rank-a ~= 1 then
            return false
        end
        a = rank
    end
    return true
end

--是否是顺子(A值是1的情况) 2 3 4 5 A
function LibNormalCardLogic:IsStraight(cards)
    self:Sort(cards)
    local nLen = #cards
    local a1, an = GetCardValue(cards[1]), GetCardValue(cards[nLen])
    if a1 ~= 2 or an ~= 14 then
        return self:IsStraight_Common(cards)
    else
        local a = a1
        for i=2, nLen-1 do
            local rank = GetCardValue(cards[i])
            if rank-a ~= 1 then
                return false
            end
            a = rank
        end
        return true
    end
end

--各墩牌的类型(对内外接口)--要加个癞子在cards的位置 代表
function LibNormalCardLogic:GetCardType(cards)
    local cardType = GStars_Normal_Type.PT_ERROR
    local tempCards = Array.Clone(cards)
    -- LOG_DEBUG("LibNormalCardLogic:GetCardType.., cards: %s\n", TableToString(cards))

    self:Sort(tempCards)
    local tempValues = {}
    for i=1, #tempCards do
        local nV = GetCardValue(tempCards[i])
        table.insert(tempValues, nV)
    end
    -- --值排序
    -- self:Sort_By_Value(tempValues)

    if #tempCards == 3 then
        --前墩
        local n = self:Uniqc(tempCards)
        if n == 1 then
            cardType = GStars_Normal_Type.PT_THREE
        elseif n == 2 then
            cardType = GStars_Normal_Type.PT_ONE_PAIR
        elseif n == 3 then
            cardType = GStars_Normal_Type.PT_SINGLE
        else
            cardType = GStars_Normal_Type.PT_ERROR
        end
    elseif #tempCards == 5 then
        --中墩 后墩
        local bFlush = self:IsFlush(tempCards)
        local bStraight = self:IsStraight(tempCards)
        if bFlush then
            --判断是否是同花顺
            if bStraight then
                cardType = GStars_Normal_Type.PT_STRAIGHT_FLUSH
            else
                cardType = GStars_Normal_Type.PT_FLUSH
            end
        elseif bStraight then
            cardType = GStars_Normal_Type.PT_STRAIGHT
        else
            local n = self:Uniqc(tempCards)
            if n == 1 then
                cardType = GStars_Normal_Type.PT_FIVE
            elseif n == 2 then
                local v1 = GetCardValue(tempCards[1])
                local v2 = GetCardValue(tempCards[2])
                local v4 = GetCardValue(tempCards[4])
                local v5 = GetCardValue(tempCards[5])
                if v1 == v2 and v4 == v5 then
                    cardType = GStars_Normal_Type.PT_FULL_HOUSE
                else
                    cardType = GStars_Normal_Type.PT_FOUR
                end
            elseif n == 3 then
                local v1 = GetCardValue(tempCards[1])
                local v2 = GetCardValue(tempCards[2])
                local v3 = GetCardValue(tempCards[3])
                local v4 = GetCardValue(tempCards[4])
                local v5 = GetCardValue(tempCards[5])
                if v1 == v3 or v2 == v4 or v3 == v5 then
                    cardType = GStars_Normal_Type.PT_THREE
                else
                    cardType = GStars_Normal_Type.PT_TWO_PAIR
                end
            elseif n == 4 then
                cardType = GStars_Normal_Type.PT_ONE_PAIR
            elseif n == 5 then
                cardType = GStars_Normal_Type.PT_SINGLE
            else
                cardType = GStars_Normal_Type.PT_ERROR
            end
        end
    else
        cardType = GStars_Normal_Type.PT_ERROR
    end

    -- LOG_DEBUG("LibNormalCardLogic:GetCardType.., cardType: %d\n", cardType)
    return cardType, tempValues
end



--==================配牌库 普通牌型=========================
--注意： 目前这些普通牌型库 不使用  主要原因是不支持癞子牌
--============================================================
--普通牌型比牌(对外接口)
function LibNormalCardLogic:CompareCards(cardsA, cardsB)
    -- LOG_DEBUG("LibNormalCardLogic:CompareCards.., cardsA: %s, cardsB: %s\n", TableToString(cardsA), TableToString(cardsB))
    local tempA = Array.Clone(cardsA)
    local tempB = Array.Clone(cardsB)
    local type1 = self:GetCardType(tempA)
    local type2 = self:GetCardType(tempB)
    -- LOG_DEBUG("LibNormalCardLogic:CompareCards.., type1: %d, type1: %d\n", type1, type2)

    if type1 == type2 then
        if type1 == GStars_Normal_Type.PT_ONE_PAIR then
            local p1 = self:GetPairValue(tempA)
            local p2 = self:GetPairValue(tempB)
            if p1 ~= p2 then
                return p1 - p2
            end

        elseif type1 == GStars_Normal_Type.PT_TWO_PAIR then
            --先比较大对子，大对子相等比较小对子
            local pa1, pb1 = self:GetPairValue(tempA)
            local pa2, pb2 = self:GetPairValue(tempB)
            local n = pb1 - pb2
            if n == 0 then
                n = pa1 - pa2
            end
            if n ~= 0 then
                return n
            end

        elseif type1 == GStars_Normal_Type.PT_THREE
            or type1 == GStars_Normal_Type.PT_FULL_HOUSE
            or type1 == GStars_Normal_Type.PT_FOUR then
            --只需要比较中间这张牌
            local p1 = GetCardValue(tempA[3])
            local p2 = GetCardValue(tempB[3])
            if p1 ~= p2 then
                return p1 - p2
            end
        elseif type1 == GStars_Normal_Type.PT_FLUSH then
            --比较对同花
            --if GGameCfg.GameSetting.bSupportWaterBanker then
                local pa1, pb1 = self:GetPairValue(tempA)
                local pa2, pb2 = self:GetPairValue(tempB)
                --先比大对子  再比小对 最后比单张大小
                local n = pb1 - pb2
                if n == 0 then
                    n = pa1 - pa2
                end
                -- LOG_DEBUG("flush compare,  n= %d", n)
                if n ~= 0 then
                    return n
                end 
            --end
        end
        --比单张
        local singA = {}
        local singB = {}
        return self:CompareSingle(tempA, tempB)
    else
        return type1 - type2
    end
end

--返回值0表示没对子, 值是按从小到大返回的
function LibNormalCardLogic:GetPairValue(cards)
    self:Sort(cards)
    local ret = {}
    local tempVal = nil
    for _, v in ipairs(cards) do
        local val = GetCardValue(v)
        if tempVal == val and ret[#ret] ~= val then
            table.insert(ret, val)
        else
            tempVal = val
        end
    end

    -- LOG_DEBUG("LibNormalCardLogic:GetPairValue..ret: %s\n", vardump(ret))
    --return table.unpack(ret)
    return (ret[1] or 0), (ret[2] or 0)
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
    local n = va - vb
    if n ~= 0 then
        return n
    else
        table.remove(cardsA)
        table.remove(cardsB)
        return self:CompareSingle(cardsA, cardsB) 
    end
end
--==============================================================




--====下面是配牌函数=========


--同花顺
function LibNormalCardLogic:Get_Max_Pt_Straight_Flush(cards, skipType)
    -- LOG_DEBUG("Get_Max_Pt_Straight_Flush..before, cards: %s\n", TableToString(cards))
    if (type(cards) ~= "table") then
        return false
    end
    if #cards < 5 then
        return false
    end
    -- LOG_DEBUG("======Get_Max_Pt_Straight_Flush======skipType:%d, myType:%d\n", skipType, GStars_Normal_Type.PT_STRAIGHT_FLUSH)
    if GStars_Normal_Type.PT_STRAIGHT_FLUSH > skipType then
        return false
    end
    --先按花色排序
    local flush = {}
    self:Sort_By_Color(cards)
    --按花色分组
    for k, v in ipairs(cards) do
        local color = GetCardColor(v)
        if not flush[color] then
            flush[color] = {}
        end
        table.insert(flush[color], v)
    end
    --
    local bFound = false
    local temp = nil
    for _, v in pairs(flush) do
        -- LOG_DEBUG("Get_Max_Pt_Straight_Flush..color, cards: %s\n", TableToString(v))
        local bSuc, t = self:Get_Max_Pt_Straight(v, skipType)
        if bSuc then
            if temp then
                --比较 找最大的顺子
                local nRet = self:CompareCards(temp, t)
                if nRet < 0 then
                    temp = t
                end
            else
                temp = t
            end
            bFound = true
        end
    end
    if bFound then
        self:RemoveCard(cards, temp)
    end

    -- LOG_DEBUG("Get_Max_Pt_Straight_Flush..end, cards: %s\n", TableToString(cards))
    -- if bFound then
    --     LOG_DEBUG("Get_Max_Pt_Straight_Flush..get table t: %s\n", TableToString(temp))
    -- end

    return bFound, temp, GStars_Normal_Type.PT_STRAIGHT_FLUSH
end


--同花
function LibNormalCardLogic:Get_Max_Pt_Flush(cards, skipType)
    -- LOG_DEBUG("Get_Max_Pt_Flush..before, cards: %s\n", TableToString(cards))
    if (type(cards) ~= "table") then
        return false
    end
    if #cards < 5 then
        return false
    end
    -- LOG_DEBUG("======Get_Max_Pt_Flush======skipType:%d, myType:%d\n", skipType, GStars_Normal_Type.PT_FLUSH)
    if GStars_Normal_Type.PT_FLUSH > skipType then
        return false
    end
    --先按花色排序
    local flush = {}
    self:Sort_By_Color(cards)
    --按花色分组
    for k, v in ipairs(cards) do
        local color = GetCardColor(v)
        if not flush[color] then
            flush[color] = {}
        end
        table.insert(flush[color], v)
    end
    --再遍历找同花
    local bFound = false
    local t = {}
    for _, v in pairs(flush) do
        local len = #v
        if len >= 5 then
            table.insert(t, v[len])
            table.insert(t, v[len-1])
            table.insert(t, v[len-2])
            table.insert(t, v[len-3])
            table.insert(t, v[len-4])
            bFound = true
            break
        end
    end
    if bFound then
        self:RemoveCard(cards, t)
    end  

    -- LOG_DEBUG("Get_Max_Pt_Flush..end, cards: %s\n", TableToString(cards))
    -- if bFound then
    --     LOG_DEBUG("Get_Max_Pt_Flush..get table t: %s\n", TableToString(t))
    -- end  

    return bFound, t, GStars_Normal_Type.PT_FLUSH
end

--顺子 10JQKA > A2345 > 910JQK > ...> 23456
function LibNormalCardLogic:Get_Max_Pt_Straight(cards, skipType)
    -- LOG_DEBUG("Get_Max_Pt_Straight..before, cards: %s\n", TableToString(cards))
    if (type(cards) ~= "table") then
        return false
    end
    if #cards < 5 then
        return false
    end
    -- LOG_DEBUG("======Get_Max_Pt_Straight======skipType:%d, myType:%d\n", skipType, GStars_Normal_Type.PT_STRAIGHT)
    if GStars_Normal_Type.PT_STRAIGHT > skipType then
        return false
    end

    local tempCards = Array.Clone(cards) 
    local bSuc1, t1 = self:Get_Max_Pt_Straight_Normal(tempCards)
    if bSuc1 and GetCardValue(t1[1]) == 14 then
        --10JQKA
        -- LOG_DEBUG("Get_Max_Pt_Straight..end, cards: %s\n", TableToString(cards))
        -- LOG_DEBUG("Get_Max_Pt_Straight..get table t1: %s\n", TableToString(t1))
        self:RemoveCard(cards, t1)
        return true, t1, GStars_Normal_Type.PT_STRAIGHT
    end

    --2345A
    local tempCards = Array.Clone(cards) 
    local bSuc2, t2 = self:Get_Max_Pt_Straight_A(tempCards, 5)
    if bSuc2 then
        -- LOG_DEBUG("Get_Max_Pt_Straight..end, cards: %s\n", TableToString(cards))
        -- LOG_DEBUG("Get_Max_Pt_Straight..get table t2: %s\n", TableToString(t2))
        self:RemoveCard(cards, t2)
        return true, t2, GStars_Normal_Type.PT_STRAIGHT
    end

    if bSuc1 then
        -- LOG_DEBUG("Get_Max_Pt_Straight..end, cards: %s\n", TableToString(cards))
        -- LOG_DEBUG("Get_Max_Pt_Straight..get table t3: %s\n", TableToString(t1))
        self:RemoveCard(cards, t1)
        return true, t1, GStars_Normal_Type.PT_STRAIGHT
    end

    -- LOG_DEBUG("Get_Max_Pt_Straight..end, cards: %s\n", TableToString(cards))
    return false
end

--普通顺子 不包括A2345
function LibNormalCardLogic:Get_Max_Pt_Straight_Normal(cards)
    -- LOG_DEBUG("Get_Max_Pt_Straight_Normal..before, cards: %s\n", TableToString(cards))
    if (type(cards) ~= "table") then
        return false
    end
    if #cards < 5 then
        return false
    end

    self:Sort(cards)
    --遍历找到能组成顺子的 开始和结束位置
    --24 34 35 26 36 37 18 1D
    local bSuc1 = false
    local t = {}
    local len = #cards
    
    local nLastValue = GetCardValue(cards[len])
    table.insert(t, cards[len])
    for i=len-1, 1, -1 do
        local nValue = GetCardValue(cards[i])
        --值相同则跳过这张牌
        if nLastValue ~= nValue then
            if nLastValue ~= nValue + 1 then
                t = {}
                table.insert(t, cards[i])
            else
                table.insert(t, cards[i])
            end
        end
        nLastValue = nValue
        if #t >= 5 then
            bSuc1 = true
            break
        end
    end
    if bSuc1 then
        --从牌库移除
        self:RemoveCard(cards, t)
    end

    -- LOG_DEBUG("Get_Max_Pt_Straight_Normal..end, cards: %s\n", TableToString(cards))
    -- if bSuc1 then
    --     LOG_DEBUG("Get_Max_Pt_Straight_Normal..get table t: %s\n", TableToString(t))
    -- end

    return bSuc1, t
end

--A2345 顺子中第二大  nFindValue必须填，5则是找A2345, 3则是找A23
function LibNormalCardLogic:Get_Max_Pt_Straight_A(cards, nFindValue)
    -- LOG_DEBUG("Get_Max_Pt_Straight_A..before, nFindValue: %d, cards: %s\n", nFindValue, TableToString(cards))
    if (type(cards) ~= "table") then
        return false
    end
    if #cards < 5 then
        return false
    end
    if nFindValue == nil then
        return false
    end

    self:Sort(cards)

    local len = #cards
    if GetCardValue(cards[len]) ~= 14 then
        return false
    end

    local t = {}
    table.insert(t, cards[len])
    for i=len, 1, -1 do
        --找5432
        if nFindValue == GetCardValue(cards[i]) then
            nFindValue = nFindValue - 1
            table.insert(t, cards[i])
            if nFindValue == 1 then
                break
            end
        end
    end
    if nFindValue ~= 1 then
        return false
    end
    if nFindValue ~= 1 then
        return false
    end

    --从牌库移除
    self:RemoveCard(cards, t)

    -- LOG_DEBUG("Get_Max_Pt_Straight_A..end, nFindValue: %d, cards: %s\n", nFindValue, TableToString(cards))
    -- LOG_DEBUG("Get_Max_Pt_Straight_A..get table nFindValue: %d, t: %s\n", nFindValue, TableToString(t))

    return true, t
end

--3条
function LibNormalCardLogic:Get_Max_Pt_Three(cards, skipType)
    -- LOG_DEBUG("Get_Max_Pt_Three..before, cards: %s\n", TableToString(cards))
    if (type(cards) ~= "table") then
        return false
    end
    if #cards < 3 then
        return false
    end
    -- LOG_DEBUG("======Get_Max_Pt_Three======skipType:%d, myType:%d\n", skipType, GStars_Normal_Type.PT_THREE)
    if GStars_Normal_Type.PT_THREE > skipType then
        return false
    end
    self:Sort(cards)
    for i = #cards - 2, 1 , -1 do
        local v1 = GetCardValue(cards[i])
        local v2 = GetCardValue(cards[i+1])
        local v3 = GetCardValue(cards[i+2])

        if v1 == v2 and v1 == v3 then
            local t = {}
            for k=1,3 do
                table.insert(t,table.remove(cards,i))
            end
            -- LOG_DEBUG("Get_Max_Pt_Three..end, cards: %s\n", TableToString(cards))
            -- LOG_DEBUG("Get_Max_Pt_Three..get table t: %s\n", TableToString(t))
            return true, t, GStars_Normal_Type.PT_THREE
        end
    end
    -- LOG_DEBUG("Get_Max_Pt_Three..end, cards: %s\n", TableToString(cards))
    return false
end

--一对
function LibNormalCardLogic:Get_Max_Pt_One_Pair(cards, skipType)
    -- LOG_DEBUG("Get_Max_Pt_One_Pair..before, cards: %s\n", TableToString(cards))
    if (type(cards) ~= "table") then
        return false
    end
    if #cards < 2 then
        return false
    end
    -- LOG_DEBUG("======Get_Max_Pt_One_Pair======skipType:%d, myType:%d\n", skipType, GStars_Normal_Type.PT_ONE_PAIR)
    if GStars_Normal_Type.PT_ONE_PAIR > skipType then
        return false
    end

    self:Sort(cards)
    for i = #cards - 1, 1 , -1 do
        local v1 = GetCardValue(cards[i])
        local v2 = GetCardValue(cards[i+1])

        if v1 == v2 then
            local t = {}
            for k=1,2 do
                table.insert(t,table.remove(cards,i))
            end
            -- LOG_DEBUG("Get_Max_Pt_One_Pair..end, cards: %s\n", TableToString(cards))
            -- LOG_DEBUG("Get_Max_Pt_One_Pair..get table t: %s\n", TableToString(t))
            return true, t, GStars_Normal_Type.PT_ONE_PAIR
        end
    end
    -- LOG_DEBUG("Get_Max_Pt_One_Pair..end, cards: %s\n", TableToString(cards))
    return false
end

--散牌
function LibNormalCardLogic:Get_Max_Pt_Single(cards)
    -- LOG_DEBUG("Get_Max_Pt_Single..before, cards: %s\n", TableToString(cards))
    if (type(cards) ~= "table") then
        return false
    end
    if #cards == 0 then
        return false
    end

    self:Sort(cards)
    return true,table.remove(cards,#cards)
end



return LibNormalCardLogic