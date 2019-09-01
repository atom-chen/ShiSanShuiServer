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
    --计算杠牌后从牌未摸的牌数
    self.m_nCurrentCardLeftEXceptGang = 0
    --金牌在剩余牌堆的位置
    self.m_nGoldCardPos = 0
end

-- 清除当前牌
function DealerCardGroup:Clear()
     for i=1,MAX_TOTAL_CARD_NUM do
        self.m_cards[i] = 0
    end
    self.m_nCurrentLength = 0
    self.m_nCurrentCardLeftEXceptGang  = 0
    self.m_nGoldCardPos = 0
end

-- 荷官选择牌堆
function DealerCardGroup:PrepareCards()
    -- 加载slot 获取牌堆
    self.m_cards = LibCardPool:GetCardSet()
    self.m_nCurrentLength = #self.m_cards
    MAX_TOTAL_CARD_NUM = #self.m_cards
    self.m_nCurrentCardLeftEXceptGang =0
    self.m_nGoldCardPos = 0
end

-- 荷官洗牌逻辑
function DealerCardGroup:PrepareDeal()
    self:PrepareCards()
    self.m_cards = LibCardDeal:DoDeal(self.m_cards)
    self.m_nCurrentLength = #self.m_cards
    self.m_nCurrentCardLeftEXceptGang =0
    self.m_nGoldCardPos = 0
end

-- 拷贝 DealerCardGroup
function DealerCardGroup:Clone(other)
    self.m_nCurrentLength = other.m_nCurrentLength
    for i=1,other.m_nCurrentLength do
        self.m_cards[i] = other.m_cards[i]
    end
end
function DealerCardGroup:ToArray()
    local t = {}
    for i=1,self.m_nCurrentLength do
        table.insert(t, self.m_cards[i])
    end
    return t
end

-- 获取一张牌
function DealerCardGroup:GetOneCard(bLast)
    if self.m_nCurrentLength == 0 or self.m_nCurrentLength > MAX_TOTAL_CARD_NUM then
        LOG_DEBUG("DealerCardGroup:GetOneCard() :%s ", vardump( self.m_cards))
        return 0
    end
    local card = self.m_cards[1]
    if bLast then
        --牌尾摸牌
        local nGetPos = self.m_nCurrentLength
        --跳过金牌
        --if self.m_nGoldCardPos > 0 and nGetPos == self.m_nGoldCardPos then
        --    nGetPos = self.m_nCurrentLength - 1
        --   --金牌位置变化
        --    self.m_nGoldCardPos = self.m_nGoldCardPos - 1
        --end
        card = table.remove(self.m_cards, nGetPos)
        --
        self.m_nCurrentCardLeftEXceptGang = self.m_nCurrentCardLeftEXceptGang + 1
    else
        --牌首摸牌
        card = table.remove(self.m_cards, 1)
        -- --金牌位置变化
        -- if self.m_nGoldCardPos > 0 then
        --     self.m_nGoldCardPos = self.m_nGoldCardPos - 1
        -- end
    end
    self.m_nCurrentLength = #self.m_cards

    return card
end

-- 获取当前牌堆中牌个数
function DealerCardGroup:GetCurrentLength()
    if self.m_nCurrentLength < 0 or self.m_nCurrentLength > MAX_TOTAL_CARD_NUM then
        return 0
    end
    return self.m_nCurrentLength
end
function DealerCardGroup:GetCurrentCardLeftEXceptGang()
    return self.m_nCurrentCardLeftEXceptGang
end

--金牌在剩余牌堆的位置
function DealerCardGroup:SetGoldCardPos(nGOldCard, nPos)
    -- self.m_nCurrentLength = self.m_nCurrentLength + 1
    -- if nPos < 0 or nPos > MAX_TOTAL_CARD_NUM then
    --     nPos = self.m_nCurrentLength
    -- end
    --self.m_cards[self.m_nCurrentLength] = nGOldCard
    --self.m_nGoldCardPos = self.m_nCurrentLength
end
function DealerCardGroup:GetGoldCardPos()
    return self.m_nGoldCardPos
end

-- 将某个位置上的牌设置为card
function DealerCardGroup:SetCard(nIndex, card)
    if nIndex <= 0 or nIndex > MAX_TOTAL_CARD_NUM then
        return false
    end
    self.m_cards[nIndex] = card
end

-- 获取某个位置上的牌
function DealerCardGroup:GetCardAt(nIndex)
    if nIndex <= 0 or nIndex > MAX_TOTAL_CARD_NUM then
        return nil
    end
    return self.m_cards[nIndex]
end


return DealerCardGroup