--[[
-- 玩家类 描述玩家的操作和属性
--]]

import(".core_define")
import(".table_game")

local PlayerCardGroup = import(".player_cardgroup")
local GiveCardGroup = import(".give_cardgroup")
local SetCardGroup = import(".set_cardgroup")
local FlowObject = import("framework.flow_object")

local stTestUserInfo = {}
local function TestSetUserInfo(stTableUserInfo)
    local user = {}
    user.user = stTableUserInfo
    user.score= {
        win = 100,
        lose = 0,
        equ = 1,
        esc = 1,
        score = 100,
        coin = 10000,
        time = 100,
    }

    stTestUserInfo[stTableUserInfo._chair] = user
end
local function TestSetUserGameScore(_, nChair, pid, stScore)
    stTestUserInfo[nChair].score = stScore
end
local function TestGetUserInfo(_,nChair, pid)
    return stTestUserInfo[nChair]
end


local GetUserInfo = _GameModule._TableLogic.GetUserInfo  or TestGetUserInfo
local SetUserGameScore = _GameModule._TableLogic.SetUserGameScore  or TestSetUserGameScore

local Player = class("Player", FlowObject) -- ,  function () return _FlowTreeCtrl.CreateObject() end)
function Player:ctor()
    Player.super.ctor(self, "Player")
    self:initial()
    self.offlinestatus = 0
end

function Player:initial()
    self.m_stWins = {}
    self.m_stUserInfo = {}
    -- 牌类 对象 创建

    self.m_stPlayerCardGroup = PlayerCardGroup.new()
    self.m_stPlayerGive = GiveCardGroup.new()
    self.m_stPlayerSet = SetCardGroup.new()
    -- 初始化
    self:InitPlayerGameInfo()
end
function Player:InitPlayerGameInfo()
    self.m_stWins = {}
    self.m_stPlayerCardGroup:Clear();
    self.m_stPlayerSet:Clear();
    self.m_stPlayerGive:Clear();
    self.m_nSeatWind = 0 -- 门风
    self.m_nPlayerStatus = 0
    self.m_bOffLine = false
    self.m_bLogin = false
    self.m_bTrust = false                 -- 被托管
    self.m_bAllowWatch = false
    self.m_nTing = TING_NONE
    self.m_bWin = false
    self.m_stWins = {}
    self.m_bIsPlayEnd = false
    self.m_nTimeoutTimes = 0
    self.bis_self_giveup = false

end
function Player:InitBeforeGame()
    self:InitPlayerGameInfo()
end

function Player:SetPlayEnd()
    self.m_bIsPlayEnd = true
end

function Player:IsPlayEnd()
    return self.m_bIsPlayEnd
end
function Player:SetPlayOfflineStatus(nstatus)
    self.offlinestatus= nstatus
end

function Player:GetPlayOfflineStatus()
     return self.offlinestatus
end
function Player:GetChairID()
    return self.m_stUserInfo.user._chair
end
function Player:GetPlayerID()
    return self.m_stUserInfo.user._pid
end
function Player:GetUserInfo()
    return self.m_stUserInfo.user
end
function Player:GetIsUserSelfGiveup()
    return self.bis_self_giveup
end
function Player:SetIsUserSelfGiveup(bIsGiveUp)

    self.bis_self_giveup = bIsGiveUp
end
function Player:GetUin()
    return self.m_stUserInfo.user._uid
end
--[[
-- 玩家登录 操作
-- 初始化 状态数据 牌数据
--]]
function Player:Login(stTableUserInfo)

    if self.m_nPlayerStatus ~= PLAYER_STATUS_NOLOGIN or stTableUserInfo == nil then
        return false
    end
    self:InitPlayerGameInfo()
    if stTableUserInfo.state == USER_STATUS_SIT then
        self.m_nPlayerStatus = PLAYER_STATUS_SIT
    elseif  stTableUserInfo.state == USER_STATUS_LOOKON then
        -- self.m_nPlayerStatus = PLAYER_STATUS_LOOKON
    end
    self.m_bAllowWatch  = true
    self.m_bOffLine      = false
    self.m_bLogin        = true
    LOG_DEBUG("stTableUserInfo:%s", vardump(stTableUserInfo))
    -- -- test
    -- TestSetUserInfo(stTableUserInfo)

    --self.m_stUserInfo.score.coin
    local stUserInfo  = GetUserInfo(G_TABLEINFO.tableptr, stTableUserInfo._chair, stTableUserInfo._pid)
    LOG_DEBUG("stUserInfo:%s", vardump(stUserInfo))

    -- -- test
    -- stUserInfo.score.coin = 1000
    -- SetUserGameScore(G_TABLEINFO.tableptr, stUserInfo.user._chair, stUserInfo.user._pid, {coin = 1000})

    self:SetUserInfo(stUserInfo)

    return true
end
function Player:SetUserInfo(stUserInfo)
    self.m_stUserInfo =clone( stUserInfo)
end
function Player:GetPlayerPointsSt()
    return self.m_stUserInfo.score
end

function Player:GetUserInfoAllSt()
    return self.m_stUserInfo
end
function Player:GetMoney()
    return self.m_stUserInfo.score.coin
end
function Player:AddMoney(nAdd)
    --self.m_stUserInfo = GetUserInfo(G_TABLEINFO.tableptr, self.m_stUserInfo.user._chair, self.m_stUserInfo.user._pid)
    local nMoneyAdd = 0
    if nAdd > 0 then
        nMoneyAdd = nAdd
    elseif nAdd < 0 then
         -- 减到0
         nMoneyAdd = nAdd
         nAdd = nAdd * -1
         if  self:GetMoney() < nAdd then
              nMoneyAdd = -1 * self:GetMoney() 
        end
    end
    -- set score
    self.m_stUserInfo.score.coin = self.m_stUserInfo.score.coin + nMoneyAdd
    LOG_DEBUG("SetUserGameScore AddMoney :%d now:%d", nMoneyAdd, self.m_stUserInfo.score.coin)
    SetUserGameScore(G_TABLEINFO.tableptr, self.m_stUserInfo.user._chair, self.m_stUserInfo.user._pid, {coin = nMoneyAdd })
end


function Player:RefreshScore()
    self.m_stUserInfo = GetUserInfo(G_TABLEINFO.tableptr, self.m_stUserInfo.user._chair, self.m_stUserInfo.user._pid)
end
function Player:GetScore()
    return self.m_stUserInfo.score.score
end
function Player:AddScore(nAdd)
    self.m_stUserInfo = GetUserInfo(G_TABLEINFO.tableptr, self.m_stUserInfo.user._chair, self.m_stUserInfo.user._pid)
    local nScoreAdd = nAdd

    self.m_stUserInfo.score.score =  self.m_stUserInfo.score.score + nScoreAdd
    LOG_DEBUG("SetUserGameScore AddScore :%d now:%d", nScoreAdd, self.m_stUserInfo.score.score)
    SetUserGameScore(G_TABLEINFO.tableptr, self.m_stUserInfo.user._chair, self.m_stUserInfo.user._pid, {score = nScoreAdd})
end


--[[
-- 玩家登出
--]]
function Player:Logout()
    self.m_bLogin    = false
    if self.m_nPlayerStatus == PLAYER_STATUS_NOLOGIN then
        return false
    end
    self:InitPlayerGameInfo()
    self.m_bAllowWatch = true
    self.m_nPlayerStatus         = PLAYER_STATUS_NOLOGIN
    self.m_bLock                 = false
    self.m_bOffLine              = false
    --self:ClearUserInfo()
    return true
end


--[[
-- 获取玩家当前状态 取值 PLAYER_STATUS_XXX
-- core_define.lua  定义
--]]
function Player:GetPlayerStatus()
    return self.m_nPlayerStatus
end

--[[
-- 设置玩家当前状态 取值 PLAYER_STATUS_XXX
-- core_define.lua  定义
--]]
function Player:SetPlayerStatus(nPlayerStatus)
    self.m_nPlayerStatus = nPlayerStatus
end
--[[
-- 当前玩家数是否允许旁观
--]]
function Player:IsAllowWatch()
    return self.m_bAllowWatch
end

--[[
-- 是否托管状态
--]]
function Player:IsTrust()
    return self.m_bTrust
end
--[[
-- 设置托管状态
--]]
function Player:SetIsTrust(bTrust)

    self.m_bTrust = bTrust
end
--[[
-- 获取玩家的门风
--]]
function Player:GetSeatWind()
    return self.m_nSeatWind
end

--[[
-- 设置玩家的门风
--]]
function Player:SetSeatWind(nSeatWind)
    if nSeatWind >= 4 then
        return false
    end
    self.m_nSeatWind = nSeatWind
    return true
end
--[[
-- 获取玩家听状态
--]]
function Player:GetTing()
    return self.m_nTing
end
function Player:IsTing()
    return self.m_nTing ~= 0
end
--[[
-- 设置玩家听状态
--]]
function Player:SetTing(nTing)
    if nTing > TING_CONCEALED then
        return false
    end
    self.m_nTing = nTing
    return true
end

--[[
-- 获取玩家手牌
--]]
function Player:GetPlayerCardGroup()
    return self.m_stPlayerCardGroup
end
--[[
-- 设置玩家手牌
--]]
function Player:SetPlayerCardGroup(stPlayerCardGroup)
    self.m_stPlayerCardGroup:Clone(stPlayerCardGroup)
end
--[[
-- 获取玩家吃碰的牌
--]]
function Player:GetPlayerCardSet()
    return self.m_stPlayerSet
end
--[[
-- 设置玩家吃碰的牌
--]]
function Player:SetPlayerCardSet(stPlayerSet)
    self.m_stPlayerSet:Clone(stPlayerSet)
end

--[[
-- 获取玩家出过牌
--]]
function Player:GetPlayerGiveGroup()
    return self.m_stPlayerGive
end
--[[
-- 设置玩家出过牌
--]]
function Player:SetPlayerCardGive(stPlayerGive)
    self.m_stPlayerGive:Clone(stPlayerGive)
end

function Player:SetIsWin(bWin)
    self.m_bWin = bWin
end
function Player:IsWin()
    return self.m_bWin
end
function Player:AddPlayerWinCard(nCard)
    self.m_stWins[#self.m_stWins + 1] = nCard
end
function Player:GetPlayerWinCards()
    return self.m_stWins
end

-- 填充自己的所有牌面信息
function Player:GetAllCardInfoSync()
    local stSync = {
        hands = {}, -- 手牌
        gives = {},   -- 打出去的牌区
        sets = {},  -- 吃碰杠区
        wins = {},  -- 赢的牌
    }
    local nHands = self.m_stPlayerCardGroup:GetCurrentLength()
    for i=1,nHands do
        stSync.hands[#stSync.hands + 1] = self.m_stPlayerCardGroup:GetCardAt(i)
    end
    self:FillCardInfoOpen(stSync)
    return stSync
end

-- 填充都可以看到的信息
function Player:FillCardInfoOpen(stSync)
      --
    local nGives = self.m_stPlayerGive:GetCurrentLength()
    for i=1,nGives do
        stSync.gives[#stSync.gives + 1] = self.m_stPlayerGive:GetCardAt(i)
    end
    --
    stSync.sets = self.m_stPlayerSet:ToStyledArray()
    --[[ 
    local nSets = self.m_stPlayerSet:GetCurrentLength()
    for i=1,nSets do
        local oneSet = self.m_stPlayerSet:GetCardSetAt(i)
        stSync.sets[#stSync.sets + 1] = { flag = oneSet.ucFlag, card = oneSet.card, value = oneSet.value }
    end
    ]]
    --
    for i=1,#self.m_stWins do
        stSync.wins[#stSync.wins + 1] = self.m_stWins[i]
    end
    return stSync
end

-- 填充自己的牌面信息给其他人看
function Player:GetAllCardInfoSyncForOther()
    local stSync = {
        handsNum = {}, -- 手牌数
        gives = {},   -- 打出去的牌区
        sets = {},  -- 吃碰杠区
        wins = {},  -- 赢的牌
    }
    local nHands = self.m_stPlayerCardGroup:GetCurrentLength()
    stSync.handsNum = nHands
    self:FillCardInfoOpen(stSync)
    return stSync
end


function Player:SetIsHu(bHu)
    self.m_bHu = bHu
end
function Player:SetHuFlag(nFlag)
    self.m_nHuFlag = nFlag
end
function Player:SetHuCard(nCard)
    self.m_nHuCard = nCard
end
function Player:SetHuFan(nFan)
    self.m_nHunFan = nFan
end
function  Player:AddTimeoutTimes()
    -- self.m_nTimeoutTimes = self.m_nTimeoutTimes + 1
    -- if self.m_nTimeoutTimes == 2 and self:IsWin() == false then
    --    self:SetIsTrust(true)
    --    CSMessage.NotifyTrustToAll(self, true)
    --    self.m_nTimeoutTimes = 0
    -- end
end

--检查吃碰后 剩余牌是否可以出牌(癞子牌 被吃的牌)
function Player:CanPlayCardAfterBlockOp(stDelOne, stDelAll)
    if stDelOne == nil and stDelAll == nil then
        return true
    end
    if next(stDelOne) == nil and next(stDelAll) == nil then
        return true
    end

    local bCan = false
    local t = self.m_stPlayerCardGroup:ToArray()
    local nSize = #t
    if nSize > 0 then
        --del one
        for _, del in pairs(stDelOne) do
            for i, has in ipairs(t) do
                if del == has then
                    t[i] = -1
                    break
                end
            end
        end
        -- del all
        for _, del in pairs(stDelAll) do
            for i, has in ipairs(t) do
                if del == has then
                    t[i] = -1
                end
            end
        end 

        for _, has in ipairs(t) do
            if has > 0 then
                bCan = true
                break
            end
        end
    end
    return bCan
end

return Player
