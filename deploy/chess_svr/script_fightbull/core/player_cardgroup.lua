--[[
-- 玩家手牌 
--]]
local PlayerCardGroup = class("PlayerCardGroup")

function PlayerCardGroup:ctor()
    self.m_nCurrentLength = 0
    self.m_cards = {}       --原始手牌

    self:Clear()
end

function PlayerCardGroup:Clear()
    self.m_nCurrentLength = 0
    self.m_cards = {}
    for i=1,MAX_HAND_CARD_NUM do
        self.m_cards[i] = 0
    end
end

function PlayerCardGroup:ToArray()
    local t = {}
    for i=1,self.m_nCurrentLength do
        t[#t+1] =  self.m_cards[i]
    end
    return t
end

function PlayerCardGroup:Clone(otherPlayerCardGroup)
    self.m_nCurrentLength = otherPlayerCardGroup.m_nCurrentLength
    for i=1,otherPlayerCardGroup.m_nCurrentLength do
        self.m_cards[i] = otherPlayerCardGroup.m_cards[i]
    end
end

function PlayerCardGroup:Print()
    local str = string.format("len: %d  :", self.m_nCurrentLength)
    for i=1,self.m_nCurrentLength  do
        str = str .. string.format("%d ", self.m_cards[i])
    end
    LOG_DEBUG("PlayerCardGroup:%s \n", str)
end

function PlayerCardGroup:AddCard(card)
    if self.m_nCurrentLength > MAX_TOTAL_CARD_NUM then
        return 
    end
    self.m_cards[self.m_nCurrentLength+1] = card
    self.m_nCurrentLength = self.m_nCurrentLength + 1
end

function PlayerCardGroup:AddCardGroup(cards)
    self.m_cards = cards
    self.m_nCurrentLength = #cards
end

return PlayerCardGroup