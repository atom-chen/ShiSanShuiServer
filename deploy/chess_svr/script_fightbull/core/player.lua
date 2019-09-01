--[[
-- 玩家类 描述玩家的操作和属性
--]]

import(".core_define")
import(".table_game")

local PlayerCardGroup = import(".player_cardgroup")
local PlayerCompareResult = import(".player_compare_result")
local FlowObject = import("framework.flow_object")
--[[
stUserInfo = {
    user = {
        _uid = 12532427,
        _pid = 1,
        _chair = 1,

        score = {
            equ = 0,
            lose = 0,
            win = 0,
            time = 0,
            score = 0,
            coin = 0,
        },
    },
}
--]]
local GetUserInfo = _GameModule._TableLogic.GetUserInfo
local SetUserGameScore = _GameModule._TableLogic.SetUserGameScore

local Player = class("Player", FlowObject)
function Player:ctor()
    Player.super.ctor(self, "Player")
    self:initial()
    self.m_nOfflinestatus = 0  --0不掉线 1掉线
    self.m_nRoomSumScore = 0   --开局以来房间累计积分
end

function Player:initial()
    self.m_stUserInfo = {}
    -- 牌类 对象 创建
    self.m_stPlayerCardGroup = PlayerCardGroup.new()
    self.m_stPlayerCompareResult = PlayerCompareResult.new()

    self.m_nCancleCompare = false
    -- 初始化
    self:InitPlayerGameInfo()
end
function Player:InitPlayerGameInfo()
    self.m_stPlayerCardGroup:Clear()
    self.m_stPlayerCompareResult:Clear()
    self.m_nPlayerStatus = 0        --玩家游戏状态
    self.m_bOffLine = false         --是否离线
    self.m_bLogin = false
    self.m_bTrust = false           -- 被托管
    self.m_bAllowWatch = false      --允许旁观
    self.m_bIsPlayEnd = false
    self.m_nTimeoutTimes = 0        --超时几次，就设置为托管
    self.m_nCancleCompare = false   -- 是否取消比牌动画
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
    self.m_nOfflinestatus= nstatus
end

function Player:GetPlayOfflineStatus()
     return self.m_nOfflinestatus
end

function Player:AddRoomSumScore(nScore)
    self.m_nRoomSumScore = self.m_nRoomSumScore + nScore
end

function Player:GetRoomSumScore()
     return self.m_nRoomSumScore
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

function Player:GetUin()
    return self.m_stUserInfo.user._uid
end

function Player:SetUserInfo(stUserInfo)
    self.m_stUserInfo =clone( stUserInfo)
end

function Player:GetPlayerPointsSt()
    return self.m_stUserInfo.user.score
end

function Player:GetUserInfoAllSt()
    return self.m_stUserInfo
end

function Player:GetMoney()
    return self.m_stUserInfo.user.score.coin
end

function Player:AddMoney(nAdd)
    --self.m_stUserInfo = GetUserInfo(G_TABLEINFO.tableptr, self.m_stUserInfo.user._chair, self.m_stUserInfo.user._pid)
    nAdd = nAdd or 0
    if nAdd < 0 then
        local nMyCoin = self:GetMoney()
        if nMyCoin < math.abs(nAdd) then
            nAdd = -1 * nMyCoin
        end
    end
    -- set score
    self.m_stUserInfo.user.score.coin = self.m_stUserInfo.user.score.coin + nAdd
    LOG_DEBUG("SetUserGameScore AddMoney :%d now:%d", nAdd, self.m_stUserInfo.user.score.coin)
    SetUserGameScore(G_TABLEINFO.tableptr, self.m_stUserInfo.user._chair, self.m_stUserInfo.user._pid, { coin = nAdd })
end

function Player:RefreshScore()
    self.m_stUserInfo = GetUserInfo(G_TABLEINFO.tableptr, self.m_stUserInfo.user._chair, self.m_stUserInfo.user._pid)
end

function Player:GetScore()
    return self.m_stUserInfo.user.score.score
end

function Player:AddScore(nAdd)
    self.m_stUserInfo = GetUserInfo(G_TABLEINFO.tableptr, self.m_stUserInfo.user._chair, self.m_stUserInfo.user._pid)
    local nScoreAdd = nAdd

    self.m_stUserInfo.user.score.score =  self.m_stUserInfo.user.score.score + nScoreAdd
    LOG_DEBUG("SetUserGameScore AddScore :%d now:%d", nScoreAdd, self.m_stUserInfo.user.score.score)
    SetUserGameScore(G_TABLEINFO.tableptr, self.m_stUserInfo.user._chair, self.m_stUserInfo.user._pid, {score = nScoreAdd})
end

function Player:UpdataGameScore(nCoin, nScore, nWin, nLose, nEqual)
    --里面字段要和C++那边的一一对应起来，否则是拿不到数据的
    nCoin = nCoin or 0
    nScore = nScore or 0
    nWin = nWin or 0
    nLose = nLose or 0
    nEqual = nEqual or 0
    if nCoin < 0 then
        local nMyCoin = self:GetMoney()
        if nMyCoin < math.abs(nCoin) then
            nCoin = -1 * nMyCoin
        end
    end
    self.m_stUserInfo.user.score.coin =  self.m_stUserInfo.user.score.coin + nCoin
    self.m_stUserInfo.user.score.score =  self.m_stUserInfo.user.score.score + nScore
    self.m_stUserInfo.user.score.win =  self.m_stUserInfo.user.score.win + nWin
    self.m_stUserInfo.user.score.lose =  self.m_stUserInfo.user.score.lose + nLose
    self.m_stUserInfo.user.score.equ =  self.m_stUserInfo.user.score.equ + nEqual

    local scoreinfo = {
        coin = nCoin,
        score = nScore,
        win = nWin,
        lose = nLose,
        equal = nEqual,
    }
    LOG_DEBUG("Player:UpdataGameScore uid: %d  scoreinfo: %s \n", self.m_stUserInfo.user._uid, vardump(scoreinfo))
    SetUserGameScore(G_TABLEINFO.tableptr, self.m_stUserInfo.user._chair, self.m_stUserInfo.user._pid, scoreinfo)
end

-- 玩家登录 操作 初始化 状态数据 牌数据
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

    --self.m_stUserInfo.user.score.coin
    local stUserInfo  = GetUserInfo(G_TABLEINFO.tableptr, stTableUserInfo._chair, stTableUserInfo._pid)
    LOG_DEBUG("stUserInfo:%s", vardump(stUserInfo))

    self:SetUserInfo(stUserInfo)

    return true
end

-- 玩家登出
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


-- 获取玩家当前状态 取值 PLAYER_STATUS_XXX
-- core_define.lua  定义
function Player:GetPlayerStatus()
    return self.m_nPlayerStatus
end


-- 设置玩家当前状态 取值 PLAYER_STATUS_XXX
-- core_define.lua  定义
function Player:SetPlayerStatus(nPlayerStatus)
    self.m_nPlayerStatus = nPlayerStatus
end

-- 当前玩家数是否允许旁观
function Player:IsAllowWatch()
    return self.m_bAllowWatch
end

-- 是否托管状态
function Player:IsTrust()
    return self.m_bTrust
end
-- 设置托管状态
function Player:SetIsTrust(bTrust)
    self.m_bTrust = bTrust
end

-- 获取玩家手牌
function Player:GetPlayerCardGroup()
    return self.m_stPlayerCardGroup
end
-- 设置玩家手牌
function Player:SetPlayerCardGroup(stPlayerCardGroup)
    self.m_stPlayerCardGroup:Clone(stPlayerCardGroup)
end

--是否取消比牌动画
function Player:SetCancleCompare(bCancle)
    self.m_nCancleCompare = bCancle
end
function Player:IsCancleCompare()
    return self.m_nCancleCompare
end

function  Player:AddTimeoutTimes()
    -- self.m_nTimeoutTimes = self.m_nTimeoutTimes + 1
    -- if self.m_nTimeoutTimes == 2 and self:IsWin() == false then
    --    self:SetIsTrust(true)
    --    CSMessage.NotifyTrustToAll(self, true)
    --    self.m_nTimeoutTimes = 0
    -- end
end

-- 获取玩家比牌结果
function Player:GetPlayerCompareResult()
    return self.m_stPlayerCompareResult
end

--获取自己与其他人的比牌信息
function Player:GetCompareResult()
    local allCompareData = {}
    for i=1, PLAYER_NUMBER do
        local stPlayer = GGameState:GetPlayerByChair(i)
        if stPlayer then
            local stPlayerCardGroup = stPlayer:GetPlayerCardGroup()
            local stPlayerCompareResult = stPlayer:GetPlayerCompareResult()

            --牌墩及牌型
            local result = {}
            result.chairid = stPlayer:GetChairID()

            table.insert(allCompareData, result)
        end
    end

    --
    local nChairid = self:GetChairID()
    local notifyData = {
        _chair = "p" .. nChairid,
        _uid = self:GetUin(),
        stAllCompareData = {},     --所有人的牌信息：各个玩家的牌、牌型、打枪列表
        stCompareScores = {},      --我与所有人的比牌详细积分
    }
    notifyData.stAllCompareData = allCompareData
    notifyData.stCompareScores = self.m_stPlayerCompareResult:GetScoreResult()

    return notifyData
end

return Player
