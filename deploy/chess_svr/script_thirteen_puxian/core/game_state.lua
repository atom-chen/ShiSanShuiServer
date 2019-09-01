--[[
-- 当前游戏状态
--  玩家、旁观者、游戏本身状态、对局内状态
--  为了一致  都用 class 方式定义
--]]
local Player = import(".player")

local GameState = class("GameState")
function GameState:ctor()
    self:initial()
end
function GameState:initial()
    self.m_nGameStatus = GAME_STATUS_NOSTART                     -- 游戏状态
    self.m_stPlayerInfo = {}
    self.m_stWatcherInfo = {}
end


function GameState:InitGameInfo()
    self.m_nGameStatus = GAME_STATUS_NOSTART
    self.m_bIsPlayStart = false
    self.m_stUserCards = {}
    self.m_nUserChair = -1
end

function GameState:IsPlayStart()
    return self.m_bIsPlayStart
end

function GameState:SetPlayStart(bIsStart)
    self.m_bIsPlayStart = bIsStart
end

function GameState:GetWatchPlayer(index)
    if index > 0 and index <= #self.m_stWatcherInfo then
        return self.m_stWatcherInfo[index]
    end
    return nil
end

function GameState:GetPlayerByChair(nChair)
    if nChair > 0 and nChair <= PLAYER_NUMBER then
        return self.m_stPlayerInfo[nChair]
    end
    return nil
end

function GameState:RemovePlayer(nChair)
     self.m_stPlayerInfo[nChair] = nil
end

function GameState:SetPlayer(nChair, stPlayer)
    self.m_stPlayerInfo[nChair] = stPlayer
end


function GameState:SetGameStatus(nGameStatus)
    self.m_nGameStatus = nGameStatus
end

function GameState:GetGameStatus()
    return self.m_nGameStatus
end

function GameState:SetUserData(datas)
    if type(datas) ~= "table" then
        return
    end
    if datas and datas.test and datas.test.chair and datas.test.cards then
        local nChair = datas.test.chair
        local stCards = datas.test.cards
        if nChair <= 0 or nChair > PLAYER_NUMBER then
            return
        end
        if #stCards ~= MAX_HAND_CARD_NUM then
            return
        end

        self.m_nUserChair = nChair
        self.m_stUserCards = Array.Clone(stCards)
        -- LOG_DEBUG("GameState:SetUserData...m_nUserChair:%d", self.m_nUserChair)
        -- LOG_DEBUG("GameState:SetUserData...m_stUserCards:%s", TableToString(self.m_stUserCards))
    end
end

function GameState:DealUserData()
    local stDealerCardGroup = GDealer:GetDealerCardGroup()
    local stAllCards = stDealerCardGroup:ToArray()

    if self.m_nUserChair <= 0 or self.m_nUserChair > PLAYER_NUMBER then
        return
    end

    if #self.m_stUserCards ~= MAX_HAND_CARD_NUM
        or #stAllCards < MAX_HAND_CARD_NUM 
        or Array.IsSubSet(self.m_stUserCards, stAllCards) == false then
        return 
    end

    local stPlayer = self:GetPlayerByChair(self.m_nUserChair)
    if stPlayer then
        local stPlayerCardGroup = stPlayer:GetPlayerCardGroup()
        local cards = self.m_stUserCards
        LOG_DEBUG("DealUserData...p%d, cards:%s", self.m_nUserChair, TableToString(cards))
        if cards and #cards >= MAX_HAND_CARD_NUM then
            for j=1, MAX_HAND_CARD_NUM do
                local nCard = cards[j]
                stDealerCardGroup:DelOneCard(nCard)
                --判断是否有码牌
                if GGameCfg.GameSetting.bSupportBuyCode and IsCodeCard(nCard) then
                    stPlayerCardGroup:SetHasCodeCard(true)
                    GDealer:SetCodeCardChairID(stPlayer:GetChairID())
                end
            end
            --获取特殊牌型
            local nSpecialType = LibSpCardLogic:GetSpecialType(cards)
            LOG_DEBUG("DealUserData===have===p%d, nSpecialType:%d", self.m_nUserChair, nSpecialType)
            stPlayerCardGroup:SetSpecialType(nSpecialType)
            --特殊牌型人数+1
            if nSpecialType > GStars_Special_Type.PT_SP_NIL then
                GDealer:AddSpecialNums()
            end
            stPlayerCardGroup:AddCardGroup(cards)
            stPlayer:SetTest(true)
        end
    end    
end

return GameState 