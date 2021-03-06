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

    self.m_pFanCounter = nil   -- 番计算
    self.m_stFanGuoBiao = nil  -- 番 国标
    self.m_stFanNormal = nil   -- 番 不记番场
    self.m_stFanPop = nil      -- 番 大众
    self.m_stFanLuxury = nil   -- 豪华麻将

    self.m_nPredealer = 0  -- 初始值为0,预庄家。出牌前的阶段都是庄家是预庄家
    self.m_bOnceStart = false
    self.m_stCmdSetTile = {
        nTileNum = 0,
        arrCards = {}
    }
    
    self.m_strCurrStage = "prepare"
    self.m_stageNext = {
        prepare     = "banker",
        banker      = "xiapao",
        xiapao      = "deal",
        deal        = "laizi",
        laizi       = "round",
        round       = "reward",
        reward      = "gameend",
        gameend     = "prepare"
    }

    self.m_bRoundEnd = false

    if not GGameCfg.GameSetting.bSupportHun then
        -- SKIP laizi
        self.m_stageNext.deal = self.m_stageNext.laizi;
        self.m_stageNext.laizi = nil;
    end

    if not GGameCfg.GameSetting.bSupportXiaPao then
        -- SKIP xiapao
        self.m_stageNext.banker = self.m_stageNext.xiapao;
        self.m_stageNext.xiapao = nil;
    end

    self:InitStage()
end

function Dealer:Init()
    self.m_stRoundInfo:InitRoundInfo()
    self.m_stGameState:InitGameInfo()
    return 0
end

function Dealer:InitStage()
    if GGameCfg.RoomSetting.nGameStyle == GAME_STYLE_ZHENGZHOU then
        GGameCfg.GameSetting.bSupportQiangGangHu = false
        GGameCfg.GameSetting.bSupportMenWQing = false
        GGameCfg.GameSetting.bSupportBKD = false
        GGameCfg.GameSetting.bSupportZhuoWuKui = false
        
    elseif GGameCfg.RoomSetting.nGameStyle == GAME_STYLE_ZHUMADIAN then
        self.m_stageNext = {
            prepare     = "banker",
            banker      = "xiapao",
            xiapao      = "deal",
            deal        = "round",
            round       = "reward",
            reward      = "gameend",
            gameend     = "prepare"
        }

        -- 洛阳没癞子
        GGameCfg.GameSetting.bSupportHun = false
        GGameCfg.GameSetting.bSupportQiangGangHu = false
        GGameCfg.GameSetting.bSupportMenWQing = false
        GGameCfg.GameSetting.bSupportBKD = false
        GGameCfg.GameSetting.bSupportZhuoWuKui = false
        GGameCfg.nLeftCardNeedQuict = 0 

    elseif GGameCfg.RoomSetting.nGameStyle == GAME_STYLE_LUOYANG then
        self.m_stageNext = {
            prepare     = "deal",
            deal        = "ci",
            ci          = "round",
            round       = "reward",
            reward      = "gameend",
            gameend     = "prepare"
        }
        GGameCfg.GameSetting.bSupportHun = false
        GGameCfg.GameSetting.bSupportDealerAdd = false
        GGameCfg.GameSetting.bSupportGangPao = false
        GGameCfg.GameSetting.bSupportGangFlowAdd = false
        GGameCfg.GameSetting.bSupportSevenDoubleAdd = false
        GGameCfg.GameSetting.bSupportGangCi = true
        GGameCfg.nLeftCardNeedQuict = 1 --次牌不能摸

        -- 河北
        GGameCfg.GameSetting.bSupportQiangGangHu = false
        GGameCfg.GameSetting.bSupportMenWQing = false
        GGameCfg.GameSetting.bSupportBKD = false
        GGameCfg.GameSetting.bSupportZhuoWuKui = false
    
    elseif GGameCfg.RoomSetting.nGameStyle == GAME_STYLE_SHIJIAZHUANG then  -- 石家庄麻将
        self.m_stageNext = {
            prepare     = "banker",
            banker      = "deal",
            deal        = "round",
            round       = "reward",
            reward      = "gameend",
            gameend     = "prepare"
        }
        GGameCfg.GameSetting.bSupportHun = false
        GGameCfg.GameSetting.bSupportHun = false
        GGameCfg.GameSetting.bSupportDealerAdd = false
        GGameCfg.GameSetting.bSupportGangPao = false
        GGameCfg.GameSetting.bSupportGangFlowAdd = false
        GGameCfg.GameSetting.bSupportSevenDoubleAdd = false
        GGameCfg.GameSetting.bSupportGangCi = false
        GGameCfg.GameSetting.bSupportGunWin = true
        GGameCfg.nLeftCardNeedQuict = 0 --牌可以摸完
                
    elseif GGameCfg.RoomSetting.nGameStyle == GAME_STYLE_LANGFANG then  -- 廊坊麻将
        self.m_stageNext = {
            prepare     = "banker",
            banker      = "deal",
            deal        = "laizi",
            laizi       = "round",
            round       = "reward",
            reward      = "gameend",
            gameend     = "prepare"
        }
		GGameCfg.GameSetting.bSupportCollect = true
        GGameCfg.nLeftCardNeedQuict = 0 -- 牌可以摸完
        GGameCfg.GameSetting.bCounterLian = true  -- 开启连庄
        GGameCfg.GameSetting.bSupportGunWin = true
        GGameCfg.GameSlotSetting.strGetBanker = "slot.get_banker.slot_get_banker_random"  -- 设置首轮庄随机   

    elseif GGameCfg.RoomSetting.nGameStyle == GAME_STYLE_TANGSHAN then  -- 唐山麻将
        self.m_stageNext = {
            prepare     = "banker",
            banker      = "deal",
            deal        = "laizi",
            laizi       = "round",
            round       = "reward",
            reward      = "gameend",
            gameend     = "prepare"
        }
        GGameCfg.nLeftCardNeedQuict = 14
        GGameCfg.GameSetting.bSupportGunWin = true
        GGameCfg.GameSetting.bSupportCollect = true
        GGameCfg.GameSetting.bSupportTing = false
        GGameCfg.GameSetting.bTingCanPlayOther = false
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

function Dealer:SetOnceStart(bOnceStart)
    self.m_bOnceStart = bOnceStart
end

function Dealer:SetPlayerWind()
    local bankerChair =  self.m_stRoundInfo :GetBanker()
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
