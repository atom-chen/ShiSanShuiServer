--[[
-- 玩家手牌 
--]]
local PlayerCardGroup = class("PlayerCardGroup")
-- local card_algrithm_test = require "card_algrithm_test"

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

function PlayerCardGroup:SetNormalCardtype()
    --三墩牌牌型
    for i=1, 3 do
        LOG_DEBUG("PlayerCardGroup:SetNormalCardtype...k%d ---v:%s", i, TableToString(self.m_choose_cards[i]))
        self.m_cards_type[i] = LibNormalCardLogic:GetCardType(self.m_choose_cards[i])
    end
    LOG_DEBUG("PlayerCardGroup:SetLaiziCardtype...cardtype= %s\n", vardump(self.m_cards_type))
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

function PlayerCardGroup:IsHaveThisTypes(sameTypes)
    for k, v in ipairs(self.m_recommend_cards) do
        local stTypes = v.Types
        if stTypes[1] == sameTypes[1] 
            and stTypes[2] == sameTypes[2] 
            and stTypes[3] == sameTypes[3] then
            return true
        end
    end
    return false
end


return PlayerCardGroup