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

local stTestUserInfo = {}
local function TestSetUserInfo(stTableUserInfo)
    local user = {}
    user.user = stTableUserInfo or {}
    user.user.score = {
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
    stTestUserInfo[nChair].user.score = stScore
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
    self.m_nOfflinestatus = 0  --0不掉线 1掉线
    self.m_nRoomSumScore = 0   --开局以来房间累计积分
end

function Player:initial()
    self.m_stUserInfo = {}
    -- 牌类 对象 创建
    self.m_stPlayerCardGroup = PlayerCardGroup.new()
    self.m_stPlayerCompareResult = PlayerCompareResult.new()
    -- 是否已出牌(选择牌型)
    self.m_bChooseCardType = false
    self.m_bCancleSpecial = false
    self.m_nCancleCompare = false
    self.m_nOpChooseNums = 0   
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
    self.m_bChooseCardType = false  -- 是否已出牌(选择牌型)
    self.m_bCancleSpecial = false   -- 是否已经选择取消特殊牌型
    self.m_nCancleCompare = false   -- 是否取消比牌动画
    self.m_nOpChooseNums = 0        --客户端点击出牌的次数  相公牌出牌会ask_choose重置timer
    self.m_bTest = false
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

function Player:SetTest(bSetTest)
    self.m_bTest = bSetTest
end
function Player:IsTest()
    return self.m_bTest
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
    -- -- test
    -- TestSetUserInfo(stTableUserInfo)

    --self.m_stUserInfo.user.score.coin
    local stUserInfo  = GetUserInfo(G_TABLEINFO.tableptr, stTableUserInfo._chair, stTableUserInfo._pid)
    LOG_DEBUG("stUserInfo:%s", vardump(stUserInfo))

    -- -- test
    -- stUserInfo.user.score.coin = 1000
    -- local upScore = { score = 100, win = 1, lose = 0, equ = 0 }
    -- SetUserGameScore(G_TABLEINFO.tableptr, stUserInfo.user._chair, stUserInfo.user._pid, upScore)

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

-- 获取玩家比牌结果
function Player:GetPlayerCompareResult()
    return self.m_stPlayerCompareResult
end
-- 设置玩家比牌结果
function Player:SetPlayerCompareResult(stPlayerCompareResult)
    -- self.m_stPlayerCompareResult:Clone(stPlayerCompareResult)
end

-- 设置是否选择牌型
function Player:SetChooseCardType(bChoose)
    self.m_bChooseCardType = bChoose
end
function Player:IsChooseCardType()
    return self.m_bChooseCardType
end

--是否取消特殊牌型
function Player:SetCancleSpecial(bCancle)
    self.m_bCancleSpecial = bCancle
end
function Player:IsCancleSpecial()
    return self.m_bCancleSpecial
end

--是否取消比牌动画
function Player:SetCancleCompare(bCancle)
    self.m_nCancleCompare = bCancle
end
function Player:IsCancleCompare()
    return self.m_nCancleCompare
end

function Player:AddOpChooseNums()
    self.m_nOpChooseNums = self.m_nOpChooseNums + 1
end
function Player:GetOpChooseNums()
    return self.m_nOpChooseNums
end

-- 填充都可以看到的信息
function Player:FillCardInfoOpen(stSync)
    return stSync
end

-- 填充自己的牌面信息给其他人看
function Player:GetAllCardInfoSyncForOther()
    local stSync = {
        handsNum = {}, -- 手牌数
    }
    local nHands = self.m_stPlayerCardGroup:GetCurrentLength()
    stSync.handsNum = nHands
    self:FillCardInfoOpen(stSync)
    return stSync
end

function  Player:AddTimeoutTimes()
    -- self.m_nTimeoutTimes = self.m_nTimeoutTimes + 1
    -- if self.m_nTimeoutTimes == 2 and self:IsWin() == false then
    --    self:SetIsTrust(true)
    --    CSMessage.NotifyTrustToAll(self, true)
    --    self.m_nTimeoutTimes = 0
    -- end
end

--检查出的牌是否是相公
function Player:IsXianggong(cards, tempCards)
    if not cards[1] or not cards[2] or not cards[3]
        or #cards[1] ~= 3 or #cards[2] ~= 5 or #cards[3] ~= 5 then
        return false
    end
    --这个需要clone一份  防止被原值t被篡改
    local temp1 = Array.Clone(cards[1])
    local temp2 = Array.Clone(cards[2])
    local temp3 = Array.Clone(cards[3])

    local bSuc1, type1, values1 = LibNormalCardLogic:GetCardTypeByLaizi(temp1)
    local bSuc2, type2, values2 = LibNormalCardLogic:GetCardTypeByLaizi(temp2)
    local bSuc3, type3, values3 = LibNormalCardLogic:GetCardTypeByLaizi(temp3)

    LOG_DEBUG("IsXianggong....uid: %d, bSuc1:%s, type1:%d, values1:%s\n", self:GetUin(), tostring(bSuc1), type1, vardump(values1))
    LOG_DEBUG("IsXianggong....uid: %d, bSuc2:%s, type2:%d, values2:%s\n", self:GetUin(), tostring(bSuc2), type2, vardump(values2))
    LOG_DEBUG("IsXianggong....uid: %d, bSuc3:%s, type3:%d, values3:%s\n", self:GetUin(), tostring(bSuc3), type3, vardump(values3))

    if LibNormalCardLogic:CompareCardsLaizi(type1, type2, values1, values2) > 0 then
        return true --一二蹲相公
    end
    if LibNormalCardLogic:CompareCardsLaizi(type2, type3, values2, values3) > 0 then
        return true --二三蹲相公
    end

    self.m_stPlayerCardGroup:SetChooseCard(1, temp1)
    self.m_stPlayerCardGroup:SetChooseCard(2, temp2)
    self.m_stPlayerCardGroup:SetChooseCard(3, temp3)

    self.m_stPlayerCardGroup:SetCardtype(1, type1)
    self.m_stPlayerCardGroup:SetCardtype(2, type2)
    self.m_stPlayerCardGroup:SetCardtype(3, type3)

    self.m_stPlayerCardGroup:SetChooseValue(1, values1)
    self.m_stPlayerCardGroup:SetChooseValue(2, values2)
    self.m_stPlayerCardGroup:SetChooseValue(3, values3)

    LOG_DEBUG("IsXianggong....save======tempCards:%s", TableToString(tempCards))
    self.m_stPlayerCardGroup:SetChooseCardArray(tempCards)

    return false  
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
            result.nSpecialType = stPlayerCardGroup:GetSpecialType()
            result.nFirstType = stPlayerCardGroup:GetNormalCardtype(1)
            result.nSecondType = stPlayerCardGroup:GetNormalCardtype(2)
            result.nThirdType = stPlayerCardGroup:GetNormalCardtype(3)
            result.nOpenFirst = 0
            result.nOpenSecond = 0
            result.nOpenThird = 0
            result.nOpenSpecial = 0
            result.nTotallScore = stPlayerCompareResult:GetTotallScore()
            --牌墩:1-5是后墩 6-10是中墩 11-13是前墩
            result.stCards = stPlayerCardGroup:GetChooseCardArray()
            --打枪列表
            result.stShoots = stPlayerCompareResult:GetShootList()

            table.insert(allCompareData, result)
        end
    end
    local nAllShootChairID = GDealer:GetAllShootChairID() or 0

    --
    local nChairid = self:GetChairID()
    local notifyData = {
        _chair = "p" .. nChairid,
        _uid = self:GetUin(),
        nAllShootChairID = nAllShootChairID,    --全垒打玩家
        stAllCompareData = {},     --所有人的牌信息：各个玩家的牌、牌型、打枪列表
        stCompareScores = {},      --我与所有人的比牌详细积分
    }
    notifyData.stAllCompareData = allCompareData
    notifyData.stCompareScores = self.m_stPlayerCompareResult:GetScoreResult()

    return notifyData
end

return Player
