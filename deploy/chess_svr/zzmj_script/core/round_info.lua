local RoundInfo = class("RoundInfo")
-- 回合内 牌面对局信息
-- 对局内记录  
function RoundInfo:ctor()
    self.m_stDice = {}  -- 两个骰子
    self.m_nFlower  = {}    --8张花牌都在谁手上, 5表示不在谁手上,0-3表示座位
    for i=1,8 do
        self.m_nFlower[i] = 5
    end

    self.m_nGang = false -- 上一张是不是杠牌
    self.m_nWhoIsOnTurn = 0       --轮到谁出牌
    self.m_nWhoIsNextTurn = 0
    self.m_bIsDealerFirstTurn = true -- 庄家第一次出牌
    self.m_nRoundWind  = 0          --圈风
    self.m_nSubRoundWind  = 0           --本圈的第几盘
    self.m_nBanker  = 0              --庄家
    self.m_nPrepareBanker = 0 -- tmp 
    self.m_nLianZhuangCount = 0


    self.m_nLastGive = 0               --出的最近一张牌
    self.m_nGiveStatus = 0           --最近出牌的状态
    self.m_nLastDraw = 0
    self.m_nDrawStatus = 0
    self.m_nWin = 0
    self.m_nGun = 0
    self.m_stCardShowNum = {}
    self.m_nLastBanker = 0 
    self.m_nlefttime = 0

    self.m_nGangci = 0          --ACTION_QUADRUPLET_CONCEALED暗次 ACTION_QUADRUPLET包次 ACTION_QUADRUPLET_REVEALED明次
    self.m_nWhoBaoci = 0        --谁包次(只用于ACTION_QUADRUPLET包次)
end
function RoundInfo:SetLastWinner(nWin)
    self.m_nWin = nWin
end
function RoundInfo:GetLastWinner()
    return self.m_nWin
end
function RoundInfo:InitRoundInfo()
    self.m_stDice = {}
    self.m_nFlower  = {}    --8张花牌都在谁手上, 5表示不在谁手上,0-3表示座位
    for i=1,8 do
        self.m_nFlower[i] = 5
    end

    self.m_bGang = false -- 上一张是不是杠牌
    self.m_nWhoIsOnTurn = 0       --轮到谁出牌
    self.m_bIsDealerFirstTurn = true -- 庄家第一次出牌
    self.m_nRoundWind  = 0          --圈风
   -- self.m_nSubRoundWind  = 0           --本圈的第几盘
    self.m_nBanker  = 0              --庄家
    self.m_nPrepareBanker = -1 -- tmp 
    self.m_nLianZhuangCount = 0

    self.m_nLastGive = 0               --出的最近一张牌 
    self.m_nGiveStatus = 0           --最近出牌的状态  GIVE_STATUS_GANG
    self.m_nLastDraw = 0             --拿的最近一张牌 
    self.m_nDrawStatus = 0             -- DRAW_STATUS_GANG
    self.m_stCardShowNum = {}
    self.m_nGun = 0
    self.m_nlefttime =0

    --杠次
    self.m_nGangci = 0
    self.m_nWhoBaoci = 0
end
function RoundInfo:GetGang()
    return self.m_bGang
end
function RoundInfo:SetGang(bGang)
    self.m_bGang = bGang
end
function RoundInfo:SetBanker(nBanker)
    self.m_nBanker = nBanker
    --self.m_nWhoIsOnTurn = nBanker
end
function RoundInfo:GetBanker()
    return self.m_nBanker
end

function RoundInfo:SetPrepareBanker(nBanker)
    if self.m_nPrepareBanker < 0 then
        self.m_nPrepareBanker = nBanker
    end
end
function RoundInfo:GetPrepareBanker()
    return self.m_nPrepareBanker
end
--上一次的庄家
function RoundInfo:SetLastBanker(nBanker)
    self.m_nLastBanker = nBanker
end
function RoundInfo:GetLastBanker()
    return self.m_nLastBanker
end

function RoundInfo:SetLianZhuangCount(nLianZhuangCount)
    self.m_nLianZhuangCount = nLianZhuangCount
end
function RoundInfo:GetLianZhuangCount()
    return self.m_nLianZhuangCount
end







-- 两个骰子
function RoundInfo:SetDice(dice)
    self.m_stDice = dice
end
function RoundInfo:GetDice()
    return self.m_stDice
end

function RoundInfo:GetFlower(index)
    return self.m_nFlower[index] or 0
end


function RoundInfo:SetRoundWind(nRoundWind)
    self.m_nRoundWind = nRoundWind
end
function RoundInfo:GetRoundWind()
    return self.m_nRoundWind
end


function RoundInfo:SetSubRoundWind(nSubRound)
    self.m_nSubRoundWind = nSubRound
end
function RoundInfo:GetSubRoundWind()
    return self.m_nSubRoundWind
end




function RoundInfo:SetWhoIsOnTurn(turn)
    self.m_nWhoIsOnTurn = turn
end

function RoundInfo:GetWhoIsOnTurn()
    return self.m_nWhoIsOnTurn
end

function RoundInfo:SetWhoIsNextTurn(nTurn)
    self.m_nWhoIsNextTurn = nTurn
end

function RoundInfo:GetWhoIsNextTurn()
    return self.m_nWhoIsNextTurn
end


function RoundInfo:SetDealerFirstTurn(bIsDealerFirstTurn)
    self.m_bIsDealerFirstTurn = bIsDealerFirstTurn
end
function RoundInfo:IsDealerFirstTurn()
    return self.m_bIsDealerFirstTurn
end
function RoundInfo:SetNeedDraw(bNeedDraw)
    self.m_bNeedDraw = bNeedDraw
end

function RoundInfo:IsNeedDraw()
    return self.m_bNeedDraw 
end
function RoundInfo:SetLastGameNoCard(bLastGameNoCard)
    self.m_bLastGameNoCard = bLastGameNoCard
end
function RoundInfo:GetLastGameNoCard()
    return self.m_bLastGameNoCard
end


function RoundInfo:SetLastDraw (nLastDraw )
    self.m_nLastDraw = nLastDraw
end
function RoundInfo:GetLastDraw ( )
    return self.m_nLastDraw
end

function RoundInfo:GetLastGive()
    return self.m_tLastGive
end
function RoundInfo:SetLastGive(tLastGive)
    self.m_tLastGive = tLastGive
end



function RoundInfo:SetGun(nGun)
    self.m_nGun = nGun
end
function RoundInfo:GetGun()
    return self.m_nGun
end

-- GIVE_STATUS_GANG
function RoundInfo:GetDrawStatus()
    return self.m_nDrawStatus
end
function RoundInfo:SetDrawStatus(nStatus)
    self.m_nDrawStatus = nStatus
end
function RoundInfo:GetGiveStatus()
    return self.m_nGiveStatus
end
function RoundInfo:SetGiveStatus(nStatus)
    self.m_nGiveStatus = nStatus
end

function RoundInfo:AddCardShowNum(nCard)
    if  self.m_stCardShowNum[nCard]  == nil then
         self.m_stCardShowNum[nCard] = 0
    end
    if  self.m_stCardShowNum[nCard] == 4 then
        LOG_ERROR("AddCardShowNum Error")
         return
    end
    self.m_stCardShowNum[nCard]  =  self.m_stCardShowNum[nCard]  + 1

end
function RoundInfo:GetCardNotShowNum(nCard)
    if self.m_stCardShowNum[nCard] == nil then
        return 4
    end
    return 4 - self.m_stCardShowNum[nCard]
end

function RoundInfo:IsWin(nChair)
    return false
end
function RoundInfo:SetReenterTime(ntime)
    self.m_nlefttime = ntime
end

function RoundInfo:GetReenterTime()
    return self.m_nlefttime
end



function RoundInfo:SetGangciHu(nHuValue, nChair)
    self.m_nGangci = nHuValue or 0
    self.m_nWhoBaoci = nChair or 0
end
function RoundInfo:GetGangciHu()
    return self.m_nGangci, self.m_nWhoBaoci
end

return RoundInfo
