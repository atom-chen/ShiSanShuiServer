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
    self.m_nCurrentCardLeftEXceptGang =0
end
--[[
-- 荷官选择牌堆
--]]
function DealerCardGroup:PrepareCards()
    -- 加载slot 获取牌堆
    self.m_cards = LibCardPool:GetCardSet()
    self.m_nCurrentLength = #self.m_cards
    MAX_TOTAL_CARD_NUM = #self.m_cards
    self.m_nCurrentCardLeftEXceptGang =0
end
--[[
-- 荷官洗牌逻辑
--]]
function DealerCardGroup:PrepareDeal()
    self:PrepareCards()
    self.m_cards = LibCardDeal:DoDeal(self.m_cards)
    self.m_nCurrentLength = #self.m_cards
    self.m_nCurrentCardLeftEXceptGang =0

end

--[[
-- 拷贝 DealerCardGroup
--]]
function DealerCardGroup:ToArray()
    local t = {}
    for i=1,self.m_nCurrentLength do
        table.insert(t, self.m_cards[i])
    end
    return t
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
    if bLast == true then
        card = self.m_cards[1]
        for i=1,self.m_nCurrentLength-1 do
            self.m_cards[i] = self.m_cards[i+1]
        end
        self.m_nCurrentCardLeftEXceptGang = self.m_nCurrentCardLeftEXceptGang + 1
    end
    self.m_nCurrentLength = self.m_nCurrentLength - 1

    return card
end

--[[
-- 清除当前牌
--]]
function DealerCardGroup:Clear()
    for i=1,MAX_TOTAL_CARD_NUM do
        self.m_cards[i] = 0
    end
    self.m_nCurrentLength = 0
    self.m_nCurrentCardLeftEXceptGang  = 0
end

--[[
-- 获取当前牌堆中牌个数
--]]
function DealerCardGroup:GetCurrentLength()
    if self.m_nCurrentLength < 0 or self.m_nCurrentLength > MAX_TOTAL_CARD_NUM then
        return 0
    end
    return self.m_nCurrentLength
end
function DealerCardGroup:GetCurrentCardLeftEXceptGang()
    return self.m_nCurrentCardLeftEXceptGang
end
--[[
-- 将某个位置上的牌设置为card
--]]
function DealerCardGroup:SetCard(nIndex, card)
    if nIndex <= 0 or nIndex > MAX_TOTAL_CARD_NUM then
        return false
    end
    self.m_cards[nIndex] = card
end

--[[
-- 获取某个位置上的牌
--]]
function DealerCardGroup:GetCardAt(nIndex)
    if nIndex <= 0 or nIndex > MAX_TOTAL_CARD_NUM then
        return nil
    end
    return self.m_cards[nIndex]
end

--[[
-- 查看下一张牌
--]]
function DealerCardGroup:QueryNext()
    if self.m_nCurrentLength <= 0 then
        return nil
    end
    return self.m_cards[self.m_nCurrentLength]
end

--[[
-- 查询这张牌在后面第几张
--]]
function DealerCardGroup:QueryCardAt(card)
    for i=1,self.m_nCurrentLength do
        if self.m_tiles[self.m_nCurrentLength - i+1] == tile then
            return i
        end
    end
    return 0
end

--[[
-- 换牌 将牌堆里第一个 cardDst  换成 cardSrc
--]]
function DealerCardGroup:Change(cardSrc, cardDst)
    for i=1,self.m_nCurrentLength do
        if self.m_tiles[i] == cardDst then
            self.m_tiles[i] = cardSrc
            return true
        end
    end
    return false
end
return DealerCardGroup