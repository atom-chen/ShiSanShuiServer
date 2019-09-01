--[[
-- 荷官的牌， 即牌堆。
--]]
import(".core_define")

local DealerCardGroup = class("DealerCardGroup")
function DealerCardGroup:ctor()
    self.m_nCurrentLength = 0
    self.m_cards = {}
    for i=1,MAX_HAND_CARD_NUM do
        self.m_cards[i] = 0
    end
end

function DealerCardGroup:Clear()
     for i=1,MAX_TOTAL_CARD_NUM do
        self.m_cards[i] = 0
    end
    self.m_nCurrentLength = 0
end

--[[
-- 荷官选择牌堆
--]]
function DealerCardGroup:PrepareCards()
    -- 加载slot 获取牌堆
    local bSupportGhostCard = GGameCfg.GameSetting.bSupportGhostCard or false
    local nSupportAddColor = GGameCfg.GameSetting.nSupportAddColor or 0
    self.m_cards = LibCardPool:GetCardSet(bSupportGhostCard, nSupportAddColor)
    self.m_nCurrentLength = #self.m_cards
    MAX_TOTAL_CARD_NUM = #self.m_cards
end
--[[
-- 荷官洗牌逻辑
--]]
function DealerCardGroup:PrepareDeal()
    --1 选择牌堆
    self:PrepareCards()
    --2.洗牌 
    self.m_cards = LibCardDeal:DoDeal(self.m_cards)
    self.m_nCurrentLength = #self.m_cards
end
--[[
-- 获取一张牌
--]]
function DealerCardGroup:GetOneCard(bLast) 
    if self.m_nCurrentLength == 0 or self.m_nCurrentLength > MAX_TOTAL_CARD_NUM then
        LOG_DEBUG("DealerCardGroup:GetOneCard() :%s ", vardump( self.m_cards))
        return 0
    end

    local card = self.m_cards[self.m_nCurrentLength]
    -- 从后面往发牌
    if bLast then
        card = table.remove(self.m_cards, 1)
    end
    self.m_nCurrentLength = self.m_nCurrentLength - 1

    return card
end

function DealerCardGroup:DelOneCard(nCard)
    for k, v in ipairs(self.m_cards) do
        if v == nCard then
            card = table.remove(self.m_cards, k)
            self.m_nCurrentLength = self.m_nCurrentLength - 1
            break
        end
    end
end

function DealerCardGroup:ToArray()
    local t = {}
    for i=1,self.m_nCurrentLength do
        table.insert(t, self.m_cards[i])
    end
    return t
end

-- 获取当前牌堆中牌个数
function DealerCardGroup:GetCurrentLength()
    if self.m_nCurrentLength < 0 or self.m_nCurrentLength > MAX_TOTAL_CARD_NUM then
        return 0
    end
    return self.m_nCurrentLength
end

return DealerCardGroup