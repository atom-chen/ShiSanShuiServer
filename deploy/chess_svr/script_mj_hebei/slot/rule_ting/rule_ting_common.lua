local slot = {}

-- 实现 IsSupportTing  函数 。
-- 返回值  是否支持听操作
function slot.IsSupportTing()
    return GGameCfg.GameSetting.bSupportTing == true
end

-- 实现 IsTingCanPlayOther  函数 。
-- 听状态下是否可以打非手牌
-- 参数1 玩家手牌
-- 参数2 新的牌
-- 返回值  听状态下是否可以打牌
function slot.IsTingCanPlayOther()
    return GGameCfg.GameSetting.bTingCanPlayOther == true
end

--[[
-- 实现 CanTing  函数 。
-- 是否可听
-- 参数1 判定是否可以赢
-- 参数2 判定是否是花牌
-- 参数3 牌型
-- 返回值  是否可以听
function slot.CanTing(stCardArray)
    local arrCards = Array.Clone(stCardArray)

    local bResult = false
    for _,cardRemove in ipairs(arrCards) do
        local cards = Array.Clone(arrCards)
        -- 删除一张牌 
        Array.RemoveOne(cards, cardRemove)
        for card=CARD_BEGIN,CARD_END do
            if LibFlowerCheck:IsFlowerCard(card) == false then
                local t = Array.Clone(cards)
                table.insert(t, card)
                if LibCheckWin:CanWin(t) then
                    return true
                end
            end
        end
    end
    
    return false
end
--]]

--[[
-- 实现 GetTingGroup  函数 。
-- 获取听的牌
-- 参数1 玩家手牌
-- 参数2 新的牌
-- 返回值  听的牌 数组
function slot.GetTingGroup(stCardLeft, stCardArray)
    local arrCards = Array.Clone(stCardArray)
    --arrCards[#arrCards + 1] = nCard

    --local slotCheckWin = import(GGameSlotCfg.strRuleWin)
    --local slotCheckFlower = import(GGameSlotCfg.strCheckFlower)
    local stCardLeftNum = {}
    for _,card in ipairs(stCardLeft) do
        stCardLeftNum[card] = stCardLeftNum[card] or 0
        stCardLeftNum[card] = stCardLeftNum[card] + 1
    end
    local bResult = false
    local group = {}
    for _,cardRemove in ipairs(arrCards) do
        local oneChoice = {}
        oneChoice.give = cardRemove  -- 出哪张牌
        oneChoice.win  = {}  -- 和牌信息
        local cards = Array.Clone(arrCards)
        -- 删除一张牌 
        Array.RemoveOne(cards, cardRemove)
        for card=CARD_BEGIN,CARD_END do
            if LibFlowerCheck:IsFlowerCard(card) == false then
                local t = Array.Clone(cards)
                table.insert(t, card)
                if LibCheckWin:CanWin(t) == true then
                    --table.insert(oneChoice.win,  { card = card, num = stCardLeftNum[card], fan=0})
                    oneChoice.win[#oneChoice.win + 1] = { card = card, num = stCardLeftNum[card] or 0, fan=0}
                end
            end
        end
        if #oneChoice.win > 0 then
            table.insert(group, oneChoice)
        end
    end
    return group
end
--]]

return slot