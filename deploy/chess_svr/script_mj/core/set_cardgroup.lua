--[[
-- 吃碰的牌的表示
--]]
local stSetCard = {
    ucFlag = 0, -- 标记 ACTION_
    card = 0,  -- 牌，吃的时候是最小的一张，碰的时候就是那张
    value = 0,  -- 碰谁的   -- 吃的哪一张 (0, 1, 2)
} 
local SetCardGroup = class("SetCardGroup")
function SetCardGroup:ctor()
    self.m_setcards = {}
    self.m_nCurrentLength = 0
    for i=1,4 do
        self.m_setcards[i] = clone(stSetCard)
    end
    self:Clear()
end

function SetCardGroup:Clone(other)
    self.m_nCurrentLength = other.m_nCurrentLength
    for i=1,other.m_nCurrentLength do
        self.m_setcards[i].ucFlag = other.m_setcards[i].ucFlag
        self.m_setcards[i].card = other.m_setcards[i].card
        self.m_setcards[i].value = other.m_setcards[i].value
    end
end
function SetCardGroup:Clear()
    self.m_nCurrentLength = 0
    for _, setCards in ipairs(self.m_setcards) do
        setCards.ucFlag = 0
        setCards.card = 0
        setCards.value = 0
    end
end
function SetCardGroup:ToArray()
    local arr = {}
    for i=1,self.m_nCurrentLength do
        local item  ={
            ucFlag = self.m_setcards[i].ucFlag,
            card = self.m_setcards[i].card,
            value = self.m_setcards[i].value,
        }
        arr[#arr+1] = item
    end
    return arr
end
function SetCardGroup:ToStyledArray()
    local arr = {}
    for i=1,self.m_nCurrentLength do

        local item = self.m_setcards[i]
        local card = item.card
        local ucFlag = item.ucFlag
        if ucFlag == ACTION_QUADRUPLET or 
            ucFlag == ACTION_QUADRUPLET_CONCEALED or 
           ucFlag == ACTION_QUADRUPLET_REVEALED 
         then
            arr[#arr + 1] = {card, card, card,card }
        elseif ucFlag == ACTION_TRIPLET then
             arr[#arr + 1] = {card, card, card}
        elseif ucFlag == ACTION_COLLECT then
            arr[#arr + 1] = {card, card + 1, card+2}
        end
    end
    return arr
end
-- 
-- 添加吃碰记录
-- 
function SetCardGroup:AddSetCard(ucFlag, card, value)
    if self.m_nCurrentLength < 0 or self.m_nCurrentLength > 4 then
        return false
    end
    self.m_setcards[self.m_nCurrentLength+1].ucFlag = ucFlag
    self.m_setcards[self.m_nCurrentLength+1].card = card
    self.m_setcards[self.m_nCurrentLength+1].value = value
    self.m_nCurrentLength = self.m_nCurrentLength + 1
end

function SetCardGroup:SetCurrentLength(nCurrentLength)
    if nCurrentLength <= 0 or nCurrentLength > 4 then
        return false
    end
    self.m_nCurrentLength = nCurrentLength
    return true
end
function SetCardGroup:GetCurrentLength()
    return self.m_nCurrentLength
end

function SetCardGroup:SetSetCard(nIndex, setCard)
    if nIndex <= 0 or nIndex > 4 then
        return false
    end
    local target = self.m_setcards[nIndex]
    target.ucFlag = setCard.ucFlag
    target.card = setCard.card
    target.value = setCard.value
    return true
end
function SetCardGroup:GetCardSetAt(nIndex)
    if nIndex <= 0 or nIndex > 4 then
        return nil
    end
    return self.m_setcards[nIndex]
end
-- 将碰升级为杠
function SetCardGroup:Triplet2Quadruplet(nCard)
    for i=1,self.m_nCurrentLength do
        if self.m_setcards[i].ucFlag == ACTION_TRIPLET and self.m_setcards[i].card == nCard then
            self.m_setcards[i].ucFlag = ACTION_QUADRUPLET_REVEALED
            return true
        end
    end
    return false
end

function SetCardGroup:IsCardCan2Quadruplet(nCard)
    --local t = {}
    for i=1,self.m_nCurrentLength do
        if self.m_setcards[i].ucFlag == ACTION_TRIPLET   and self.m_setcards[i].card == nCard then
            return true
        end
    end
    return false
end
return SetCardGroup