--[[
-- 玩家手牌 
--]]
local PlayerCardGroup = class("PlayerCardGroup")

function PlayerCardGroup:ctor()
    self.m_nSpecialType = GStars_Special_Type.PT_SP_NIL     --特殊牌型类型0表示不是
    self.m_nCurrentLength = 0
    self.m_bHasCodeCard = false                         --是否有码牌
    self.m_cards = {}                                   --原始手牌
    self.m_choose_cards = { [1]={}, [2]={}, [3]={} }    --1前墩 2中墩 3后墩  3个数组 存放牌
    self.m_choose_values = { [1]={}, [2]={}, [3]={} }   --1前墩 2中墩 3后墩  3个数组 存放牌值
    self.m_choose_array = {}                            --1-5是后墩 6-10是中墩 11-13是前墩
    self.m_cards_type = { [1]=0, [2]=0, [3]=0 }         --1前墩牌型 2中墩牌型 3后墩牌型
    self.m_recommend_cards = {}                         --推荐牌型:Cards后中前墩，Types后中前牌型 { {Cards={}, Types={} },... }

    self:Clear()
end

function PlayerCardGroup:Clear()
    self.m_nSpecialType = GStars_Special_Type.PT_SP_NIL
    self.m_nCurrentLength = 0
    self.m_bHasCodeCard = false
    self.m_cards = {}
    for i=1,MAX_HAND_CARD_NUM do
        self.m_cards[i] = 0
    end
    self.m_choose_cards = { [1]={}, [2]={}, [3]={} }
    self.m_choose_values = { [1]={}, [2]={}, [3]={} }
    self.m_choose_array = {}
    self.m_cards_type = { [1]=0, [2]=0, [3]=0 }
    self.m_recommend_cards = {}
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

function PlayerCardGroup:SetSpecialType(nSpecialType)
    self.m_nSpecialType = nSpecialType or 0
end

function PlayerCardGroup:GetSpecialType()
    return self.m_nSpecialType
end

function PlayerCardGroup:GetNormalCardtype(nIndex)
    return self.m_cards_type[nIndex] or GStars_Normal_Type.PT_ERROR
end

--设置牌型
function PlayerCardGroup:SetCardtype(nIndex, nType)
    if nIndex >= 1 and  nIndex <= 3 then
        self.m_cards_type[nIndex] = nType
    end
end

--保存 出牌的牌
function PlayerCardGroup:SetChooseCard(nIndex, cards)
    if nIndex >= 1 and  nIndex <= 3 then
        self.m_choose_cards[nIndex] = cards
    end
end
function PlayerCardGroup:GetChooseCard(nIndex)
    if nIndex < 1 or nIndex > 3 then
        return nil
    end
    local t = Array.Clone(self.m_choose_cards[nIndex])
    return t
end

function PlayerCardGroup:SetChooseValue(nIndex, values)
    if nIndex >= 1 and  nIndex <= 3 then
        self.m_choose_values[nIndex] = values
    end
end
function PlayerCardGroup:GetChooseValue(nIndex)
    if nIndex < 1 or nIndex > 3 then
        return nil
    end
    local t = Array.Clone(self.m_choose_values[nIndex])
    return t
end

function PlayerCardGroup:SetChooseCardArray(cards)
    -- LOG_DEBUG("PlayerCardGroup:SetChooseCardArray...cards:%s", TableToString(cards))
    self.m_choose_array = cards
end
function PlayerCardGroup:GetChooseCardArray()
    local t = Array.Clone(self.m_choose_array) or {}
    -- LOG_DEBUG("PlayerCardGroup:GetChooseCardArray...t:%s", TableToString(t))
    return t
end

--设置是否有码牌
function PlayerCardGroup:SetHasCodeCard(bHasCodeCard)
    self.m_bHasCodeCard = bHasCodeCard
end
function PlayerCardGroup:IsHasCodeCard()
    return self.m_bHasCodeCard
end

--自动配牌
function PlayerCardGroup:AutoChooseCard()
    --获取推荐牌型
    local cards = self:ToArray()
    local recommend_cards = {}
    if #self.m_recommend_cards == 0 then
        recommend_cards = libRecomand:SetRecommandLaizi(cards)
    else
        recommend_cards = self.m_recommend_cards
    end

    local bFind = false
    for i=1, #recommend_cards do
        local tempCards = recommend_cards[i].Cards
        local tempTypes = recommend_cards[i].Types
        local tempValues = recommend_cards[i].Values

        -- LOG_DEBUG("AutoChooseCard...tempCards:%s\n", TableToString(tempCards))
        -- LOG_DEBUG("AutoChooseCard...tempTypes:%s\n", vardump(tempTypes))

        local t = { [1] = {}, [2] = {}, [3] = {} }
        for i=1,5 do
            table.insert(t[3],tempCards[i])
        end
        for i=6,10 do
            table.insert(t[2],tempCards[i])
        end
        for i=11,13 do
            table.insert(t[1],tempCards[i])
        end

        if #t[1] == 3 and #t[2] == 5 and #t[3] == 5 then
            self:SetChooseCard(1, t[1])
            self:SetChooseCard(2, t[2])
            self:SetChooseCard(3, t[3])

            self:SetChooseValue(1, tempValues[3])
            self:SetChooseValue(2, tempValues[2])
            self:SetChooseValue(3, tempValues[1])
            
            self.m_cards_type[1] = tempTypes[3]
            self.m_cards_type[2] = tempTypes[2]
            self.m_cards_type[3] = tempTypes[1]
            self.m_choose_array = Array.Clone(tempCards)
            bFind = true
            break
        end
    end
    return bFind
end

function PlayerCardGroup:SetRecommendCards()
    local tempCards = self:ToArray()
    self.m_recommend_cards = libRecomand:SetRecommandLaizi(tempCards)
end

function PlayerCardGroup:GetRecommendCards()
    local t = {}
    local count = 0
    for i=1, #self.m_recommend_cards do
        local tempCards = self.m_recommend_cards[i].Cards
        local tempTypes = self.m_recommend_cards[i].Types

        local stFinds = { Cards = tempCards, Types = tempTypes }

        table.insert(t, stFinds)

        --只要前5副牌
        count = count + 1
        if count == 5 then
            break
        end
    end
    return t
end

return PlayerCardGroup