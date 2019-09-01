local RoundInfo = class("RoundInfo")
-- 回合内 牌面对局信息
-- 对局内记录  
function RoundInfo:ctor()  
    --目前没有用到
    self.m_nFlower  = {}    --8张花牌都在谁手上, 5表示不在谁手上,0-3表示座位
    for i=1,8 do
        self.m_nFlower[i] = 5
    end
    self.m_nGun = 0
    self.m_nPrepareBanker = -1  -- 预庄家 temp
    self.m_nLastBanker = 0      -- 上一轮庄家



    self.m_stDice = {}          -- 两个骰子
    self.m_nWhoIsOnTurn = 0     -- 轮到谁出牌
    self.m_nWhoIsNextTurn = 0   -- 下一个
    self.m_bGang = false        -- 上一张是不是杠牌

    self.m_nRoundWind  = 0      -- 圈风
    self.m_nSubRoundWind  = 0   -- 本圈的第几盘
    self.m_nBanker  = 0         -- 庄家
    self.m_nWin = 0             -- 上次胡是谁,第一局默认庄家。主要用来判断是否连庄    
    self.m_nLianZhuangCount = 0 -- 连庄数量

    self.m_nLastDraw = 0        -- 最近拿的一张牌
    self.m_nDrawStatus = 0      -- 什么原因拿牌：主要是要来区分--正常胡和杠上花
    self.m_nLastGive = 0         --最近出的一张牌
    self.m_nGiveStatus = 0       -- 什么原因出牌：主要是要来区分--正常放炮和杠后出炮
   

    self.m_stCardShowNum = {}   -- 听牌 用到
    self.m_nlefttime = 0        -- 重连 用到
    self.m_bNeedDraw = false    -- 是否需要抓牌
    self.m_bIsDealerFirstTurn = false -- 庄家第一次出牌
    self.m_bIsPlayFirstCard = false   -- 是否已经出了第一张牌

    --抢杠
    self.m_nIsQiangGang =false
    self.m_nPengGangPlayer =0
    self.m_nPengGangHuPlayer ={0,0,0}


    self.m_nHuWay = 0           --胡牌方式：0正常自摸胡，1抢金胡(算自摸)，2点炮胡, 3抢杠胡(算点炮)
    self.m_bNotifyRobGold = false --抢金通知
    self.m_gamestart =0
    self.m_bIsSkipRob =true
    self.m_nLastGiveChair = 0
    self.m_bThreeGoldGiveUp =false
end

function RoundInfo:InitRoundInfo()
    self.m_stDice = {}
    self.m_bGang = false
    self.m_nWhoIsOnTurn = 0
    self.m_nLastGive = 0
    self.m_nGiveStatus = 0
    self.m_nLastDraw = 0
    self.m_nDrawStatus = 0
    self.m_stCardShowNum = {}
    self.m_nlefttime =0
    self.m_bNeedDraw = false
    self.m_bIsDealerFirstTurn = false
    self.m_bIsPlayFirstCard = false
    self.m_nIsQiangGang =false
    self.m_nPengGangPlayer =0
    self.m_nPengGangHuPlayer ={0,0,0}
    self.m_nHuWay = 0
    self.m_bNotifyRobGold = false
    self.m_nLastGiveChair = 0

end

function RoundInfo:SetJuStart(nstart)
    self.m_gamestart = nstart
end
function RoundInfo:GetJuStart()
    return self.m_gamestart
end

function RoundInfo:SetLastWinner(nWin)
    self.m_nWin = nWin
end
function RoundInfo:GetLastWinner()
    return self.m_nWin
end

function RoundInfo:GetGang()
    return self.m_bGang
end
function RoundInfo:SetGang(bGang)
    self.m_bGang = bGang
end

function RoundInfo:SetBanker(nBanker)
    self.m_nBanker = nBanker
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

function RoundInfo:SetSkipRob(bIsSkip)
    self.m_bIsSkipRob = bIsSkip
end
function RoundInfo:IsSkipRob()
    return self.m_bIsSkipRob
end

function RoundInfo:SetPlayFirstCard(bIsPlayFirstCard)
    self.m_bIsPlayFirstCard = bIsPlayFirstCard
end
function RoundInfo:IsPlayFirstCard()
    return self.m_bIsPlayFirstCard
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
    return self.m_nLastGive
end
function RoundInfo:SetLastGive(nLastGive)
    self.m_nLastGive = nLastGive
end

function RoundInfo:GetLastGiveChair()
    return self.m_nLastGiveChair
end
function RoundInfo:SetLastGiveChair(nChair)
    self.m_nLastGiveChair = nChair
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

function RoundInfo:GetIsQiangGang()
    return self.m_nIsQiangGang
end
function RoundInfo:SetIsQiangGang(nStatus)
    self.m_nIsQiangGang = nStatus
end

--碰杠玩家
function RoundInfo:GetPengGangPlayer()
    return self.m_nPengGangPlayer
end
function RoundInfo:SetPengGangPlayer(nChair)
    self.m_nPengGangPlayer = nChair
end

--抢杠胡玩家,最多可以有三个
function RoundInfo:GetPengGangHuPlayer()
    return self.m_nPengGangHuPlayer
end
function RoundInfo:SetPengGangHuPlayer(nChair)
    self.m_nPengGangHuPlayer[#self.m_nPengGangHuPlayer+1] = nChair
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

    local nLeft = 4 - self.m_stCardShowNum[nCard]
    if nLeft < 0 then
        nLeft = 0
    end
    if nLeft > 4 then
        nLeft = 4
    end
    return nLeft
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

--胡牌方式
function RoundInfo:SetHuWay(nWay)
    self.m_nHuWay = nWay
end
function RoundInfo:GetHuWay()
    return self.m_nHuWay
end
function RoundInfo:IsSelfDrawHu()
    return (self.m_nHuWay == 0)
end
function RoundInfo:IsRobGolgHu()
    return (self.m_nHuWay == 1)
end
function RoundInfo:IsGunHu()
    return (self.m_nHuWay == 2)
end
function RoundInfo:IsQiangGangHu()
    return (self.m_nHuWay == 3)
end


--抢金通知
function RoundInfo:SetNotifyRobGold(bSend)
    self.m_bNotifyRobGold = bSend
end
function RoundInfo:GetNotifyRobGold()
    return self.m_bNotifyRobGold
end


function RoundInfo:SetThreeGoldGiveUp(bThreeGoldGiveUpEnd)
    self.m_bThreeGoldGiveUp= bThreeGoldGiveUpEnd
end
function RoundInfo:IsThreeGoldGiveUp()
    return self.m_bThreeGoldGiveUp
end
return RoundInfo
