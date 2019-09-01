--[[
-- 荷官  描述荷官的操作
--]]
-- print("testttt")
import("core.core_define")
local DealerCardGroup = import("core.dealer_cardgroup")
local FlowObject = import("framework.flow_object")
local GameState = import("core.game_state")
local RoundInfo = import(".round_info")

local ClearTable = _GameModule._TableLogic.ClearTable or function(...) end
local Dealer = class("Dealer",FlowObject )
function Dealer:ctor()
    Dealer.super.ctor(self, "Dealer")
    --玩家游戏状态 保存player
    self.m_stGameState = GameState.new()
    self.m_stRoundInfo = RoundInfo.new()
    --dealer对牌堆的各个操作动作
    self.m_stDealerCardGroup = DealerCardGroup.new()

    self.m_bRoundEnd = false    --该局游戏是否已经结束
    self.m_nSpecialNums = 0   --有特殊牌人数
    self.m_nShootNums = 0     --打枪人数
    self.m_bAllShoot = false  --是否有全垒打
    self.m_nAllShootChairid = 0  --全垒打椅子ID
    self.m_nCodeCardChairid = 0  --拥有码牌的玩家椅子ID (目前用不上 以后看是否用上 没用就删除)
    self.m_nBanker = 0           --庄家(房主)，不会变的

    self.m_bClearTableFlag = false  --是否清桌标志
    self.m_nClearTableTimeOut = 0   --清桌到期时间
    self.m_bSendClearTable = false  --是否已经发送清桌命令

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
    self.m_nSpecialNums = 0
    self.m_nShootNums = 0
    self.m_bAllShoot = false
    self.m_nAllShootChairid = 0
    self.m_nCodeCardChairid = 0

    self.m_bClearTableFlag = false
    self.m_nClearTableTimeOut = 0
    self.m_bSendClearTable = false
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

function Dealer:AddSpecialNums()
    self.m_nSpecialNums = self.m_nSpecialNums + 1
end

function Dealer:SetShootNums(nNums)
    self.m_nShootNums = nNums or self.m_nShootNums
end

function Dealer:SetAllShoot(bAllShoot)
    self.m_bAllShoot = bAllShoot
end

function Dealer:SetAllShootChairID(nChairid)
    self.m_nAllShootChairid = nChairid
end

function Dealer:GetAllShootChairID()
    return self.m_nAllShootChairid
end

function Dealer:SetCodeCardChairID(nChairid)
    self.m_nCodeCardChairid = nChairid
end

function Dealer:GetCodeCardChairID()
    return self.m_nCodeCardChairid
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
    -- LOG_DEBUG("Dealer:CalculateCompareWaitTime...nSeconds: %d\n", nSeconds)

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

--清桌
function Dealer:IsCanClearTable()
    if self.m_bClearTableFlag == false then
        local nNow = os.time()
        if self.m_nClearTableTimeOut > 0 and self.m_nClearTableTimeOut <= nNow then
            self.m_bClearTableFlag = true
            self.m_nClearTableTimeOut = 0
        end
    end
    return self.m_bClearTableFlag
end
function Dealer:SetClearTableDatas()
    self.m_bClearTableFlag = false
    self.m_bSendClearTable = false
    self.m_nClearTableTimeOut = 0
    if GGameCfg.nClearTableReadyTimeOut > 0 then
        self.m_nClearTableTimeOut = os.time() + GGameCfg.nClearTableReadyTimeOut
    end
end
function Dealer:SendClearTable()
    if self.m_bSendClearTable == false then
        self.m_bSendClearTable = true
        ClearTable(G_TABLEINFO.tableptr)
    end
end
function Dealer:GetLeftSeconds()
    local nLeftSenconds = self.m_nClearTableTimeOut - os.time()
    if nLeftSenconds < 0 then
        nLeftSenconds = 0
    end
    return nLeftSenconds
end

return Dealer
