--[[
-- 玩家手牌 
--]]
local PlayerCardGroup = class("PlayerCardGroup")

function PlayerCardGroup:ctor()
    self.m_nCurrentLength = 0   --手牌还剩下几张
    self.m_cards = {}           --手牌
    self.m_cardLastDraw = 0     --最后一张抓的牌
    self.m_bIsWin = false       --是否胡
    self.m_bIsTing = false      --是否听(目前没做处理)
    self:Clear()
end

function PlayerCardGroup:Clone(otherPlayerCardGroup)
    self.m_nCurrentLength = otherPlayerCardGroup.m_nCurrentLength
    for i=1,otherPlayerCardGroup.m_nCurrentLength do
        self.m_cards[i] = other.m_cards[i]
    end
    self.m_bIsWin = otherCardGroup.m_bIsWin
end

function PlayerCardGroup:Clear()
    self.m_nCurrentLength = 0
    self.m_cards = {}
    for i=1,MAX_HAND_CARD_NUM do
        self.m_cards[i] = 0
    end
    self.m_bIsWin = false
end

function PlayerCardGroup:ToArray()
    local t = {}
    for i=1,self.m_nCurrentLength do
        t[#t+1] = self.m_cards[i]
    end
    return t
end

function PlayerCardGroup:Print()
    local str = string.format("len: %d  :", self.m_nCurrentLength)
    for i=1,self.m_nCurrentLength  do
        str = str .. string.format("%d ", self.m_cards[i])
    end
    LOG_DEBUG("PlayerCardGroup:%s \n", str)
end

--[[
-- 交换两个位置的牌
--]]
function PlayerCardGroup:Swap(nTilePosOne, nTilePosTwo)
    if nTilePosOne <=0 or nTilePosOne > MAX_HAND_CARD_NUM or
        nTilePosTwo <=0 or nTilePosTwo > MAX_HAND_CARD_NUM then
        return 
    end
    local tmp = self.m_cards[nTilePosOne]
    self.m_cards[nTilePosOne] = self.m_cards[nTilePosTwo]
    self.m_cards[nTilePosTwo] = tmp
end

--[[
-- 是不是 otherCardGroup 的子集
-- 即 是不是 otherCardGroup包含 当前的牌组
--]]
function PlayerCardGroup:IsSubSet( otherCardGroup )
    if self.m_nCurrentLength <= 0 then
        return true
    end
    if self.m_nCurrentLength > otherCardGroup:GetCurrentLength() then
        return false
    end
    -- 计算方法。 曲一个空的牌堆 先放入 otherCardGroup  然后删除 self的内容。 检查剩下的长度
    local dupcards = PlayerCardGroup.new()
    dupcards:AddCardGroup(otherCardGroup)
    dupcards:DelCardGroup(self)
    LOG_DEBUG("dupcards %d otherCardGroup%d self:%d", dupcards:GetCurrentLength(), otherCardGroup:GetCurrentLength(), self.m_nCurrentLength );
    if dupcards:GetCurrentLength() == otherCardGroup:GetCurrentLength() - self.m_nCurrentLength then
        return true
    end
    return false
end

--[[
-- 添加一张牌到 PlayerCardGroup
--]]
function PlayerCardGroup:AddCard(card)
    if self.m_nCurrentLength > MAX_TOTAL_CARD_NUM then
        self.m_cardLastDraw = 0
        return 
    end
    self.m_cards[self.m_nCurrentLength+1] = card
    self.m_nCurrentLength = self.m_nCurrentLength + 1
    self.m_cardLastDraw = card
end

function PlayerCardGroup:SetLastDraw(nLastDraw)
    self.m_cardLastDraw = nLastDraw
end

function PlayerCardGroup:GetLastDraw()
    return self.m_cardLastDraw
end

--[[
-- 添加otherPlayerGroup 到 PlayerCardGroup
--]]
function PlayerCardGroup:AddCardGroup(otherPlayerGroup)
    --local card = 0
    for i=1,otherPlayerGroup:GetCurrentLength() do
        local card = otherPlayerGroup:GetCardAt(i)
        if card then
            self:AddCard(card)
        end
    end
end

--[[
-- 删除一张牌到 PlayerCardGroup
--]]
function PlayerCardGroup:DelCard(card)
    for i=1,self.m_nCurrentLength do
        if card == self.m_cards[i] then
            self:Swap(i, self.m_nCurrentLength)
            self.m_nCurrentLength = self.m_nCurrentLength - 1
            return
        end
    end
    -- LOG_ERROR("PlayerCardGroup:DelCard errr self.m_cards:%s len %d card:%d ", vardump(self.m_cards), self.m_nCurrentLength, card);
end

function PlayerCardGroup:DelCardGroup(stCardGroup)
    for i=1,stCardGroup:GetCurrentLength() do
        local nCard = stCardGroup:GetCardAt(i)
        self:DelCard(nCard)
    end
end

--[[
-- 删除nPos 位置上的牌
--]]
function PlayerCardGroup:RemoveAt(nPos)
    if nPos <= 0 or nPos > MAX_HAND_CARD_NUM or self.m_nCurrentLength <= 0 then
        return 
    end
    self:Swap(nPos, self.m_nCurrentLength)
    self.m_nCurrentLength =  self.m_nCurrentLength - 1
end

--[[
-- 排序
--]]
function PlayerCardGroup:Sort()
    if self.m_nCurrentLength <= 2 or self.m_nCurrentLength > MAX_HAND_CARD_NUM then
        return
    end
    --冒泡排序
    for i=1,self.m_nCurrentLength do
        for j = i + 1, self.m_nCurrentLength do
            if self.m_cards[i] > self.m_cards[j] then
                self:Swap(i, j)
            end
        end
    end
end

--[[
-- 是否存在某张牌
--]]
function PlayerCardGroup:IsHave(card) 
    for i=1,self.m_nCurrentLength do
        if self.m_cards[i] == card then
            return true
        end
    end
    return false
end

--[[
-- 手上是否有暗杠的牌
--]]
function PlayerCardGroup:IsQuadrupletConcealed(  )
    self:Sort()
    for i=1,self.m_nCurrentLength - 3 do
        if self.m_cards[i] == self.m_cards[i+1] and self.m_cards[i] == self.m_cards[i+2] and
            self.m_cards[i] == self.m_cards[i+3]   then
            return true
        end
    end
    return false
end

--[[
--是否有两张 tDouble
--]]
function PlayerCardGroup:IsHaveDouble(tDouble)
    local cards = PlayerCardGroup.new()
    cards:AddCard(tDouble)
    cards:AddCard(tDouble)
    return cards:IsSubSet(self)
end

--[[
--是否可以吃tDes，第一张是tFirst
--]]
function PlayerCardGroup:IsCanCollect(tFirst, tDes)
    for i=1,3 do
        if tFirst + i ~= tDes then
            if not self:IsHave(tFirst+i) then
                return false
            end
        end
    end
    return true
end

function PlayerCardGroup:SetWin(bWin)
    self.m_bIsWin = bWin
end

function PlayerCardGroup:GetWin()
    return self.m_bIsWin
end

function PlayerCardGroup:GetTing()
    return self.m_bIsTing
end

function PlayerCardGroup:SetTing(bTing)
    self.m_bIsTing = bTing
end

--[[
-- 设置当前手牌大小
--]]
function PlayerCardGroup:SetCurrentLength(nCurrentLength)
    if nCurrentLength <= 0 or nCurrentLength > MAX_HAND_CARD_NUM then
        return false
    end
    self.m_nCurrentLength = nCurrentLength
    return true
end

--[[
-- 获取当前手牌长度
--]]
function PlayerCardGroup:GetCurrentLength()
    return self.m_nCurrentLength
end

--[[
--  将nIndex位置的牌 设置为 card
--]]
function PlayerCardGroup:SetCardAt(nIndex, card)
    if nIndex <= 0 or nIndex > MAX_HAND_CARD_NUM then
        return false
    end
    self.m_cards[nIndex] = card
    return true
end

--[[
--  获取nIndex位置的牌
--]]
function PlayerCardGroup:GetCardAt(nIndex)
    if nIndex <= 0 or nIndex > MAX_TOTAL_CARD_NUM then
        return nil
    end
    return self.m_cards[nIndex]
end

--[[
--  是否有花牌
--]]
function PlayerCardGroup:IsHaveFlower()
    for i=1,self.m_nCurrentLength do
        if LibFlowerCheck:IsFlowerCard(self.m_cards[i]) then
            return true
        end
    end
    return false
end

--[[
--  计算指定牌的数量
--]]
function PlayerCardGroup:GetCardCount(nCard)
    local count = 0
    for i=1, self.m_nCurrentLength do
        if self.m_cards[i] == nCard then
            count = count + 1
        end
    end
    return count
end


return PlayerCardGroup