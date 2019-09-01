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
    if GGameCfg.GameSetting.bSupportWaterBanker then
        self.m_stageNext = {
            prepare     = "mult",       --加倍
            mult        = "deal",       --发牌
            deal        = "choose",     --出牌(选择牌型)
            choose      = "compare",    --比牌
            compare     = "reward",     --结算
            reward      = "gameend",    --游戏结算
            gameend     = "prepare",    --下一局
        }
    else
        self.m_stageNext = {
            prepare     = "deal",       --发牌
            deal        = "choose",     --出牌(选择牌型)
            choose      = "compare",    --比牌
            compare     = "reward",     --结算
            reward      = "gameend",    --游戏结算
            gameend     = "prepare",    --下一局
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
    ---注意有特殊牌  则表明没有打枪和全垒打
    local normalNums = GGameCfg.nPlayerNum -- - self.m_nSpecialNums
    nSeconds = nSeconds + GGameCfg.TimerSetting.oneCompareTime * normalNums * 3
    --打枪时间 全垒打时间
    nSeconds = nSeconds + GGameCfg.TimerSetting.oneShootTime * self.m_nShootNums
    --特殊牌型
    nSeconds = nSeconds + GGameCfg.TimerSetting.oneSpecialTime * self.m_nSpecialNums
    if self.m_bAllShoot then
        nSeconds = nSeconds + GGameCfg.TimerSetting.allShootTime
    end
    LOG_DEBUG("Dealer:CalculateCompareWaitTime...nSeconds: %d\n", nSeconds)

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
