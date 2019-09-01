local slot = {}
-- 定缺三张
function slot.GetMissOptional()
    return {CARDTYPE_CHAR, CARDTYPE_BAMBOO, CARDTYPE_BALL}
end
-- 选择牌型中 牌最少的类型
function slot.GetBestMiss(stPlayerCards)
    local stCardTypeCount = {
        [CARDTYPE_CHAR] = 0,
        [CARDTYPE_BAMBOO] = 0,
        [CARDTYPE_BALL] = 0,
    }
    for _,nCard in ipairs(stPlayerCards) do
        local nType = GetCardType(nCard)
        --if stCardTypeCount[nType]  == nil then stCardTypeCount[nType]  = 0 end
        if stCardTypeCount[nType]  ~= nil  then
            stCardTypeCount[nType] = stCardTypeCount[nType] + 1
        end
    end
    local minType = 0 
    local minNum = 13
    for _type,count in pairs(stCardTypeCount) do
        if count < minNum then
            minNum = count
            minType = _type
        end
    end
    return minType
end
return slot
