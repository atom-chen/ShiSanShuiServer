--[[
-- 荷官  描述荷官的操作
--]]
print("testttt")
import("core.core_define")
local GameState = import("core.game_state")
local DealerCardGroup = import("core.dealer_cardgroup")
local FlowObject = import("framework.flow_object")
local RoundInfo = import(".round_info")

local Dealer = class("Dealer",FlowObject ) -- , function () return _FlowTreeCtrl.CreateObject() end)
function Dealer:ctor()
    Dealer.super.ctor(self, "Dealer")
    self.m_stGameState = GameState.new()
    self.m_stRoundInfo = RoundInfo.new()

    self.m_stDealerCardGroup = DealerCardGroup.new()


    self.m_pFanCounter = nil -- 番计算
    self.m_stFanGuoBiao = nil  -- 番 国标
    self.m_stFanNormal = nil   -- 番 不记番场
    self.m_stFanPop = nil        -- 番 大众
    self.m_stFanLuxury = nil    --  豪华麻将


    self.m_nPredealer = 0  -- 初始值为0,预庄家。出牌前的阶段都是庄家是预庄家
    self.m_bOnceStart = false
    self.m_stCmdSetTile = {
        nTileNum = 0,
        arrCards = {}
    }
    self.m_strCurrStage = "prepare"
    --[[self.m_stageNext = {
        prepare = "deal",
        deal = "changecard",
        changecard = "confirmmiss",
        confirmmiss = "round",
        round       = "reward",
        reward      = "gameend",
        gameend     = "prepare"
    }--]]
    --暂时先不管混牌
    if GGameCfg.GameSetting.bSupportChangeCard then
        self.m_stageNext = {
            prepare = "deal",
            deal = "changecard",
            changecard = "confirmmiss",
            confirmmiss = "buycode",
            buycode     = "round",
            round       = "reward",
            reward      = "gameend",
            gameend     = "prepare"
        }
    else
        self.m_stageNext = {
        prepare = "deal",
        deal = "confirmmiss",
        confirmmiss = "buycode",
        buycode     = "round",
        round       = "reward",
        reward      = "gameend",
        gameend     = "prepare"
        }
    end
    self.m_bRoundEnd = false
end

function Dealer:Init()
    self.m_stRoundInfo:InitRoundInfo()
    self.m_stGameState:InitGameInfo()
    return 0
end



function Dealer:InitBeforeGame()
    self.m_stRoundInfo:InitRoundInfo()
     self.m_stGameState:InitGameInfo()
    self.m_stRoundInfo:SetRoundWind(0)
    --self.m_stRoundInfo:SetSubRoundWind(0)
    self.m_stRoundInfo:SetBanker(0)
    self.m_stRoundInfo:SetLastGameNoCard(false)
    self.m_bRoundEnd = false
end

function Dealer:SetGameStart()
    -- if self.m_strCurrStage ~= "prepare" then
    --     LOG_ERROR("GameStart Error Status=%s\n", self.m_strCurrStage)
    --     return
    -- end

    -- self:ToNextStage()
    self.m_strCurrStage = self.m_stageNext["prepare"]
end
function Dealer:IsGameStart()
    return self.m_strCurrStage ~= "prepare"
end

function Dealer:SetGameEnd(bEnd)
    self.m_bRoundEnd = bEnd
end
function Dealer:IsGameEnd()
    return self.m_bRoundEnd
end

function Dealer:CheckPlayerMoney(nPlayerID)
    return true
end


function Dealer:GetDealerCardGroup()
    return self.m_stDealerCardGroup
end
function Dealer:GetGameState()
    return self.m_stGameState
end
function Dealer:GetRoundInfo()
    return self.m_stRoundInfo
end


function Dealer:SetOnceStart(bOnceStart)
    self.m_bOnceStart = bOnceStart
end

function Dealer:SetPlayerWind()
    local bankerChair =  self.m_stRoundInfo:GetBanker()
    local stPlayer = self.m_stGameState:GetPlayerByChair(bankerChair)
    stPlayer:SetSeatWind(1)

    for i=2,GGameCfg.nPlayerNum do
        stPlayer = self.m_stGameState:GetPlayerByChair((bankerChair+GGameCfg.nPlayerNum+1-i)%GGameCfg.nPlayerNum + 1)
        stPlayer:SetSeatWind(i)
    end


    self.m_stRoundInfo:SetWhoIsOnTurn(bankerChair)
end

function Dealer:ToNextStage()

    self.m_strCurrStage = self.m_stageNext[self.m_strCurrStage]
end
function Dealer:SetCurrStage(strStage)
    self.m_strCurrStage = strStage
end
function Dealer:GetCurrStage()
    return self.m_strCurrStage
end



return Dealer
