--[[
-- 出牌的表达
--]]

local GiveCardGroup = class("GiveCardGroup")
function GiveCardGroup:ctor()
    -- 牌数组
    self.m_cards = {}
    self.m_nCurrentLength = 0
    self:Clear()
end
--[[
-- 拷贝 stOtherGiveCardGroup 内容
--]]
function GiveCardGroup:Clone(stOtherGiveCardGroup)
    self.m_nCurrentLength = stOtherGiveCardGroup.m_nCurrentLength
    for i=1,stOtherGiveCardGroup.m_nCurrentLength do
        self.m_cards[i] = stOtherGiveCardGroup.m_cards[i]
    end
end
function GiveCardGroup:ToArray()
    local t = {}
     for i=1,self.m_nCurrentLength do
        t[#t+1] =  self.m_cards[i]
     end
     return t
end


--[[
-- 清除
--]]
function GiveCardGroup:Clear()
    self.m_nCurrentLength = 0
    for i=1,40 do
        self.m_cards[i] = 0
    end
end
function GiveCardGroup:GetCurrentLength()
    return self.m_nCurrentLength
end
--[[
-- 添加一张牌到 GiveCardGroup
-- GiveCardGroup 长度不大于40张 一副牌逻辑
--]]
function GiveCardGroup:AddCard(card)
    if self.m_nCurrentLength > 40 then
        return
    end
    self.m_cards[self.m_nCurrentLength+1] = card
    self.m_nCurrentLength = self.m_nCurrentLength + 1
end

--[[
-- 删除一张牌
-- 返回删除的牌
--]]
function GiveCardGroup:DelCard()
    if self.m_nCurrentLength <= 0 then
        return 0
    end
    local card = self.m_cards[self.m_nCurrentLength]
    self.m_nCurrentLength = self.m_nCurrentLength - 1
    return card
end
function GiveCardGroup:DelCardLast(nCard)
    if self.m_cards[self.m_nCurrentLength] == nCard then
        self.m_nCurrentLength = self.m_nCurrentLength - 1
    end
end
--[[
-- 获取 一张牌
-- 返回 某个Index位置上的牌
--]]
function GiveCardGroup:GetCardAt(nIndex)
    if nIndex <=0 or nIndex > self.m_nCurrentLength then
        return 0
    end
    return self.m_cards[nIndex]
end



return GiveCardGroup
