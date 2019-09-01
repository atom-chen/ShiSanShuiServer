--[[
-- 荷官  描述荷官的操作
--]]
print("testttt")
import("core.core_define")
local DealerCardGroup = import("core.dealer_cardgroup")
local FlowObject = import("framework.flow_object")
local GameState = import("core.game_state")
local RoundInfo = import(".round_info")

local Dealer = class("Dealer",FlowObject )
function Dealer:ctor()
    Dealer.super.ctor(self, "Dealer")
    --玩家游戏状态 保存player
    self.m_stGameState = GameState.new()
    self.m_stRoundInfo = RoundInfo.new()
    --dealer对牌堆的各个操作动作
    self.m_stDealerCardGroup = DealerCardGroup.new()

    self.m_bRoundEnd = false    --该局游戏是否已经结束
    self.m_nBanker = 0           --庄家(房主)，不会变的

    self.m_strCurrStage = "prepare"
    self:InitStage()
end

function Dealer:Init()
    self.m_stRoundInfo:InitRoundInfo()
    self.m_stGameState:InitGameInfo()
    return 0
end

function Dealer:InitStage()
    if GGameCfg.GameSetting.nGamePlay == BULL_BANKER_ORDER then
        self.m_stageNext = {
            prepare     = "banker",     --定庄
            banker      = "bet",        --下注
            bet         = "deal",       --发牌
            deal        = "compare",    --比牌
            compare     = "reward",     --结算
            reward      = "gameend",    --游戏结算
            gameend     = "prepare",    --下一局
        }
    elseif GGameCfg.GameSetting.nGamePlay == BULL_BANKER_OWNER then
        self.m_stageNext = {
            prepare     = "banker",     --定庄
            banker      = "bet",        --下注
            bet         = "deal",       --发牌
            deal        = "compare",    --比牌
            compare     = "reward",     --结算
            reward      = "gameend",    --游戏结算
            gameend     = "prepare",    --下一局
        }
    elseif GGameCfg.GameSetting.nGamePlay == BULL_BANKER_FREE_ROB then
    elseif GGameCfg.GameSetting.nGamePlay == BULL_BANKER_LOOK_ROB then
    end
end

function Dealer:InitBeforeGame()
    self.m_stRoundInfo:InitRoundInfo()
    self.m_stGameState:InitGameInfo()
    self.m_bRoundEnd = false
    --TODO: self.m_nBanker = 0
end

function Dealer:SetGameStart()
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

function Dealer:ToNextStage()
    self.m_strCurrStage = self.m_stageNext[self.m_strCurrStage]
end

function Dealer:SetCurrStage(strStage)
    self.m_strCurrStage = strStage
end

function Dealer:GetCurrStage()
    return self.m_strCurrStage
end

function Dealer:CalculateCompareWaitTime()
    --计算比牌时间
    local nSeconds = 0

    nSeconds = nSeconds + os.time()
    --保存比牌时间
    self.m_stRoundInfo:SetCompareExpiredTime(nSeconds)
end

function Dealer:SetBanker(nBanker)
    self.m_nBanker = nBanker
end

function Dealer:GetBanker()
    return self.m_nBanker
end

return Dealer
