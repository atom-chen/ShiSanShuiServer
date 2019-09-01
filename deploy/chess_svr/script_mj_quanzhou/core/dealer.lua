--[[
-- 荷官  描述荷官的操作
--]]
print("testttt")
import("core.core_define")
local GameState = import("core.game_state")
local DealerCardGroup = import("core.dealer_cardgroup")
local FlowObject = import("framework.flow_object")
local RoundInfo = import(".round_info")

local Dealer = class("Dealer",FlowObject )
function Dealer:ctor()
    Dealer.super.ctor(self, "Dealer")
    self.m_stGameState = GameState.new()
    self.m_stRoundInfo = RoundInfo.new()
    self.m_stDealerCardGroup = DealerCardGroup.new()

    self.m_bRoundEnd = false            --该局是否已经结束
    self.m_strCurrStage = "prepare"     --当前阶段 默认prepare
    self.m_stageNext = {
        prepare      = "banker",        --定庄
        banker       = "deal",          --抓牌
        deal         = "changeflower",  --补花
        changeflower = "opengold",      --开金
        opengold     = "round",         --游戏阶段
        round        = "reward",        --结算
        reward       = "gameend",       --结束
        gameend      = "prepare",       --开始
    }

    self:InitStage()
end

function Dealer:Init()
    self.m_stRoundInfo:InitRoundInfo()
    self.m_stGameState:InitGameInfo()
    return 0
end

function Dealer:InitStage()
    if GGameCfg.RoomSetting.nGameStyle == GAME_STYLE_FUZHOU or GGameCfg.RoomSetting.nGameStyle ==GAME_STYLE_QUANZHOU then
        self.m_stageNext = {
            prepare      = "banker",        --定庄
            banker       = "deal",          --抓牌
            deal         = "changeflower",  --补花
            changeflower = "opengold",      --开金
            opengold     = "round",         --游戏阶段
            round        = "reward",        --结算
            reward       = "gameend",       --结束
            gameend      = "prepare",       --开始
        }
    end
end

function Dealer:InitBeforeGame()
    self.m_stRoundInfo:InitRoundInfo()
    self.m_stGameState:InitGameInfo()
    self.m_bRoundEnd = false
end

function Dealer:SetGameStart()
    self.m_strCurrStage = self.m_stageNext["prepare"]
end

function Dealer:IsGameStart()
    return self.m_strCurrStage ~= "prepare"
end

--跳到结算
function Dealer:SetGameReward()
    self.m_strCurrStage = self.m_stageNext["round"]
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

function Dealer:SetPlayerWind()
    -- 位置 东
    local bankerChair =  self.m_stRoundInfo:GetBanker()
    local stPlayer = self.m_stGameState:GetPlayerByChair(bankerChair)
    stPlayer:SetSeatWind(1)

    -- 位置 南西北
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
