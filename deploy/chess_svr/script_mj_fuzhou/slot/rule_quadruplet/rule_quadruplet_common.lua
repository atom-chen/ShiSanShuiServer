local slot = {}

-- 实现 IsSupportQuadruplet  函数 。
-- 返回值  是否支持杠操作
function slot.IsSupportQuadruplet()
    return GGameCfg.GameSetting.bSupportQuadruplet == true
end

-- 实现 IsSupportHiddenQuadruplet  函数 。
-- 返回值  是否支持杠操作
function slot.IsSupportHiddenQuadruplet()
    return GGameCfg.GameSetting.bSupportHiddenQuadruplet == true
end

function slot.IsSupportTriplet2Quadruplet()
     return GGameCfg.GameSetting.bSupportTriplet2Quadruplet == true
end
-- 实现 CanQuadrupletCard  函数 。
-- 检查是否可以杠nCard
-- 参数1 玩家手牌 
-- 参数2  nCard 检查的牌
-- 返回值  是否可以杠
function slot.CanQuadrupletCard(stCardArray, nCard)
    if type(nCard) ~= 'number' or type(stCardArray) ~= 'table' then
        return false
    end
    local quadrupletCards = {nCard, nCard, nCard}
    if Array.IsSubSet(quadrupletCards, stCardArray) == true then
        return true
    end
    return false
end

-- 实现 CanQuadrupletGroup 函数
-- 检查牌型是否可以杠
function slot.IsQuadrupletGroup(stCardArray)
    local stCardNum = {}
    local size = #stCardArray
    local nCard = 0
    for i=1,size do
        nCard = stCardArray[i]
        if stCardNum[nCard] == nil then stCardNum[nCard]  = 0 end
        stCardNum[nCard] = stCardNum[nCard]  + 1
    end
    for card,num in pairs(stCardNum) do
        if num == 4 then
            return true
        end
    end
    return false
end


-- 实现 GetQuadrupletCard  函数 。
-- 获取杠牌
-- 参数1 玩家手牌
-- 返回值  杠牌
-- 检查所有手牌中可以杠的牌
function slot.GetQuadrupletCard(arrCards)
    -- todo fix
    local slotCheckFlower = import(GGameCfg.GameSlotSetting.strCheckFlower)
    local t = {}
    for i=1,#arrCards do
        local card = arrCards[i]
        if slotCheckFlower.IsFlowerCard(card) == false then
            if t[card]  == nil then 
                t[card] = 1 
            else
                t[card] =  t[card] + 1
            end
        end
    end
    local res = {}
    for card,count in pairs(t) do
        if count == 4 then
            res[#res + 1] = card
        end
    end
    return res

end


return slot