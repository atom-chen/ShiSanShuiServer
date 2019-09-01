function check_int(n)

 if(n - math.floor(n) > 0) then
  error("trying to use bitwise operation on non-integer!")
 end
end
function to_bits(n)
 check_int(n)
 if(n < 0) then
 
  return to_bits(bit.bnot(math.abs(n)) + 1)
 end

 local tbl = {}
 local cnt = 1
 while (n > 0) do
  local last = math.mod(n,2)
  if(last == 1) then
   tbl[cnt] = 1
  else
   tbl[cnt] = 0
  end
  n = (n-last)/2
  cnt = cnt + 1
 end

 return tbl
end
function tbl_to_number(tbl)
 local n = table.getn(tbl)

 local rslt = 0
 local power = 1
 for i = 1, n do
  rslt = rslt + tbl[i]*power
  power = power*2
 end
 
 return rslt
end

function expand(tbl_m, tbl_n)
 local big = {}
 local small = {}
 if(table.getn(tbl_m) > table.getn(tbl_n)) then
  big = tbl_m
  small = tbl_n
 else
  big = tbl_n
  small = tbl_m
 end

 for i = table.getn(small) + 1, table.getn(big) do
  small[i] = 0
 end

end

 function bit_or(m, n)
 local tbl_m = to_bits(m)
 local tbl_n = to_bits(n)
 expand(tbl_m, tbl_n)

 local tbl = {}
 local rslt = math.max(table.getn(tbl_m), table.getn(tbl_n))
 for i = 1, rslt do
  if(tbl_m[i]== 0 and tbl_n[i] == 0) then
   tbl[i] = 0
  else
   tbl[i] = 1
  end
 end
 
 return tbl_to_number(tbl)
end

function bit_and(m, n)
 local tbl_m = to_bits(m)
 local tbl_n = to_bits(n)
 expand(tbl_m, tbl_n) 

 local tbl = {}
 local rslt = math.max(table.getn(tbl_m), table.getn(tbl_n))
 for i = 1, rslt do
  if(tbl_m[i]== 0 or tbl_n[i] == 0) then
   tbl[i] = 0
  else
   tbl[i] = 1
  end
 end

 return tbl_to_number(tbl)
end

function bit_not(n)
 
 local tbl = to_bits(n)
 local size = math.max(table.getn(tbl), 32)
 for i = 1, size do
  if(tbl[i] == 1) then 
   tbl[i] = 0
  else
   tbl[i] = 1
  end
 end
 return tbl_to_number(tbl)
end

function bit_xor(m, n)
 local tbl_m = to_bits(m)
 local tbl_n = to_bits(n)
 expand(tbl_m, tbl_n) 

 local tbl = {}
 local rslt = math.max(table.getn(tbl_m), table.getn(tbl_n))
 for i = 1, rslt do
  if(tbl_m[i] ~= tbl_n[i]) then
   tbl[i] = 1
  else
   tbl[i] = 0
  end
 end


 return tbl_to_number(tbl)
end

function bit_rshift(n, bits)
 check_int(n)
 
 local high_bit = 0
 if(n < 0) then

  n = bit_not(math.abs(n)) + 1
  high_bit = 2147483648 
 end

 for i=1, bits do
  n = n/2
  n = bit_or(math.floor(n), high_bit)
 end
 return math.floor(n)
end


function bit_logic_rshift(n, bits)
 check_int(n)
 if(n < 0) then

  n = bit_not(math.abs(n)) + 1
 end
 for i=1, bits do
  n = n/2
 end
 return math.floor(n)
end

 function bit_lshift(n, bits)
 check_int(n)
 
 if(n < 0) then

  n = bit_not(math.abs(n)) + 1
 end

 for i=1, bits do
  n = n*2
 end
 return bit_and(n, 4294967295) -- 0xFFFFFFFF
end

 function bit_xor2(m, n)
 local rhs = bit_or(bit_not(m), bit_not(n))
 local lhs = bit_or(m, n)
 local rslt = bit_and(lhs, rhs)
 return rslt
end


bit = {

 bnot = bit_not,
 band = bit_and,
 bor  = bit_or,
 bxor = bit_xor,
 brshift = bit_rshift,
 blshift = bit_lshift,
 bxor2 = bit_xor2,
 blogic_rshift = bit_logic_rshift,

 tobits = to_bits,
 tonumb = tbl_to_number,
}

function clone(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for key, value in pairs(object) do
            new_table[_copy(key)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(object))
    end
    return _copy(object)
end
function TableToString(t)
    local str = ""
    if type(t) == "table" then
        for i=1,#t  do
            str = str .. string.format("0x%X, ", t[i])
	    print("  ",t[i])
        end
    end
    return str
end
function Clone(arr)
    local copy = {}
    for _,item in ipairs(arr) do
       table.insert(copy, item)
    end
    return copy
end
function RemoveOne(tbArray, val)
    local len = #tbArray
    for i=1,len do
        if tbArray[i] == val then
            table.remove(tbArray, i)
            return true
        end
    end
    
    return false
end
function GetCardColor(nCard)
    if nCard == nil or type(nCard) ~= "number" then
        return -1
    else
        local ot = bit.band(nCard, 0x0F)
        return bit_rshift(ot, 4)
    end
end

function GetCardValue(nCard)
    if nCard == nil or type(nCard) ~= "number" then
        return -1
    else
        return bit_and(nCard, 0x0F)
    end

end
function GetCardByColorValue(nColor, nValue)
   -- »¨ɫ£º0-3
    if nColor < 0 or nColor > 3 then
        nColor = nColor % 3
    end

    --A
    if nValue == 1 then
        nValue = 14
    end
    --µã2-14
    if nValue < 2 or nValue > 14 then
        nValue = 0
    end

    return (bit_lshift(nColor, 4) + nValue)
end

function RemoveCard(srcCards, rmCards)
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
        RemoveOne(srcCards, v)
    end
end

--按值升序 2-14(A)
function Sort(cards)
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
function Sort_By_Color(cards)
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
function Sort_By_Value(values)
    if not values.isSorted then
        table.sort(values, function(a, b)
            return a < b
        end)
        values.isSorted = true
    end
end


--===================获取手牌的牛数==================

function Get_Same_Poker(cards, count)
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
        return true, t
    else
        return false
    end
end

--»ñ廨ţ
function  GetFiveFloarCow(cards)
    local stCards = Clone(cards)
    for k, v in ipairs(stCards) do
        local tempVal = GetCardValue(v)
        if tempVal < 10 then
            return false
        end
    end
    return true
end

--»ñ¨µ¯ţ
function GetBombCow(cards)
    local bSuc, t = Get_Same_Poker(cards, 4)
    if not bSuc then
        return false
    end
    return true
end

--»ñåţ
function  GetFiveLittleCow(cards)
    local stCards = Clone(cards)
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
function IsCow(cards)
    local t = {}
    local bSuc = false
    local stCards = Clone(cards) 
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
function GetCowNum(cards)

    local stCards = Clone(cards)
    local ret = {}
    local CowNum = 0
    if GetFiveFloarCow(cards) then
        CowNum = 13
        print("FiveFloarCow =", CowNum)
	TableToString(Clone(cards))
	return CowNum, Clone(cards)
    elseif GetBombCow(cards) then
        CowNum = 12
	print("BombCow =", CowNum)
	TableToString(Clone(cards))
	return CowNum, Clone(cards)
    elseif GetFiveLittleCow(cards) then
        CowNum = 11
	print("FiveLittleCow =", CowNum)
	TableToString(Clone(cards))
	return COwNum, Clone(cards)
    else
        local bSuc, t = IsCow(stCards)
        if bSuc then
            RemoveCard(stCards, t)
            local tempVal = 0
            for k, v in ipairs(stCards) do
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
            print("CowNum =", CowNum)
	    TableToString(ret)
            return CowNum, ret
        else
            print("NoCow =", CowNum)
        end
        return CowNum, stCards
    end
end


function CompareSingle(cardsA, cardsB)
      if #cardsA == 0 and #cardsB == 0 then
          return 0
      elseif #cardsA == 0 then
          return -1
      elseif #cardsB == 0 then
          return 1
      end
 
      Sort(cardsA)
      Sort(cardsB)
      local va = GetCardValue(cardsA[#cardsA])
      local vb = GetCardValue(cardsB[#cardsB])
      local ca = GetCardColor(cardsA[#cardsA])
      local cb = GetCardColor(cardsB[#cardsB])
      local n = va - vb
      local m = ca - cb
      if n ~= 0 then
          --æ<80>¼å?25       
         return n
      else
          --æ.?²å?28     
         return m
      end
 end




--============================================================
--比牌(对外接口)
--function CompareCards(cardsA, cardsB)
    --LOG_DEBUG("LibNormalCardLogic:CompareCards.., cardsA: %s, cardsB: %s\n", TableToString(cardsA), TableToString(cardsB))  
     local cardsA = { 0x8, 0x18,0x28,0x38,0x3 }
     local cardsB = { 0x2, 0x35,0x3,0xB,0x9 }
   -- local cardsB = { 0x1, 0x12,0x33,0x2,0x12 }
    local tempA = Clone(cardsA)
    local tempB = Clone(cardsB)
    local CowNum1 = GetCowNum(tempA)
    local CowNum2 = GetCowNum(tempB)
    -- LOG_DEBUG("LibNormalCardLogic:CompareCards.., type1: %d, type2: %d\n", type1, type2)

    if CowNum1 == CowNum2 then
        --比单张
        local singA = {}
        local singB = {}
        CompareSingle(tempA, tempB)
    else
	print("CowNum1", CowNum1)
	print("CowNum2", CowNum2)
	print("CowNum1-CowNum2", CowNum1 - CowNum2)
        --return CowNum1 - CowNum2
    end
--end


