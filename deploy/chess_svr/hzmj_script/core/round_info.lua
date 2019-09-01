local RoundInfo = class("RoundInfo")
-- 回合内 牌面对局信息
-- 对局内记录  
function RoundInfo:ctor()
    self.m_stDice = {}  -- 两个骰子
    self.m_sDealtDice = {} 
    self.m_nFlower  = {}    --8张花牌都在谁手上, 5表示不在谁手上,0-3表示座位
    for i=1,8 do
        self.m_nFlower[i] = 5
    end

    self.m_bGang = false -- 上一张是不是杠牌
    self.nGangType = -1 -- 上一张牌的杠牌类型0--下雨 , 1--自己刮风, 2--他人给自己刮风
    self.nGangWinWho = 0 -- 直杠标记被杠玩家
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
    self.m_nGangScorelast = {} --玩家上次刮风下雨情况统计，下一次统计的时候直接覆盖，不会叠加
    self.m_nGangScoreAll = {}  --玩家刮风下雨得分统计，便于结算处理（此处叠加统计，不会清空）
    self.m_nIsQiangGang =false
    self.m_nPengGangPlayer =0
    self.m_nPengGangHuPlayer ={0,0,0}
    self.m_nLastGiveChair = 0
    self.m_nNextBanker = 0  -- 下一局庄家信息(一炮多响点炮玩家 或 第一个赢的玩家)
    self.m_nWinList = {}    -- 胡牌玩家顺序
    self.m_nGuoShouGang = false
    self.m_nPengGangCard = 0  -- 记录碰杠的哪张牌
end

function RoundInfo:InitRoundInfo()
    self.m_stDice = {}
    self.m_sDealtDice = {} 
    self.m_nFlower  = {}    --8张花牌都在谁手上, 5表示不在谁手上,0-3表示座位
    for i=1,8 do
        self.m_nFlower[i] = 5
    end

    self.m_bGang = false -- 上一张是不是杠牌
    self.nGangType = -1 -- 上一张牌的杠牌类型0--下雨 , 1--自己刮风, 2--他人给自己刮风
    self.nGangWinWho = 0 -- 只标记直杠情况中的被杠玩家，用于区分点杠花

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

    self.m_nGangScoreAll = {0,0,0,0}  --玩家刮风下雨得分统计，便于结算处理（此处叠加统计，不会清空）
    self.m_nGangScorelast = {0,0,0,0} --玩家上次刮风下雨情况统计，下一次统计的时候直接覆盖，不会叠加
    self.m_nIsQiangGang =false
    self.m_nPengGangPlayer =0
    self.m_nPengGangHuPlayer ={0,0,0}
    self.m_nLastGiveChair = 0
    self.m_nWinList = {}  -- 胡牌玩家顺序
    self.m_nGuoShouGang = false
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

function RoundInfo:GetGangType()
    return self.nGangType
end
function RoundInfo:SetGangType(nGangType)
    self.nGangType = nGangType
end

function RoundInfo:GetGangWho()   --只标记直杠情况中的被杠玩家，用于区分点杠花
    return self.nGangWinWho
end
function RoundInfo:SetGangWho(nGangWho)   --只标记直杠情况中的被杠玩家，用于区分点杠花
    self.nGangWinWho = nGangWho
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

function RoundInfo:GetLastGiveChair()
    return self.m_nLastGiveChair
end
function RoundInfo:SetLastGiveChair(nChair)
    self.m_nLastGiveChair = nChair
end

function RoundInfo:GetNextBankder()
    return self.m_nNextBanker
end

-- bNext 默认false 一炮多响时true
function RoundInfo:SetNextBankder(nNextBanker, bNext)
    if self.m_nNextBanker == 0 or bNext then
        self.m_nNextBanker = nNextBanker
    end
end


-- 两个骰子
function RoundInfo:SetDice(dice)
    self.m_stDice = dice
end
function RoundInfo:GetDice()
    return self.m_stDice
end
-- 两个骰子
function RoundInfo:SetDealDice(dice)
    self.m_sDealtDice = dice
end
function RoundInfo:GetDealDice()
    return self.m_sDealtDice
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

function RoundInfo:GetWinList()
    return self.m_nWinList
end

function RoundInfo:SetWinList(nChair)
    table.insert(self.m_nWinList, nChair)
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

function RoundInfo:GetGuoShouGang()
    return self.m_nGuoShouGang
end
function RoundInfo:SetGuoShouGang(bGSGang)
    self.m_nGuoShouGang = bGSGang
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

--获取玩家最近一次的杠分统计（单次不叠加）
function RoundInfo:GetGangScoreLast()
    return self.m_nGangScorelast
end

--更新玩家最近一次的杠分统计（单次不叠加）
function RoundInfo:UpdateGangScoreLast(m_ScoreLast)
    for i=1,PLAYER_NUMBER do
        self.m_nGangScorelast[i] = m_ScoreLast[i]
    end
end

--获取刮风下雨得分统计，格式为{0，0，0，0}，对应为每个玩家的得分统计
function RoundInfo:GetGangScoreAll()
    return self.m_nGangScoreAll
end

--同时处理玩家刮风下雨得分增减情况，输入为得分玩家chairID和底分基数，返回自动增删后刮风下雨统计
function RoundInfo:UpdateGangScoreAll(nChair,stBase)
    --self.m_nGangScoreAll[nChair] = self.m_nGangScoreAll[nChair] + stBase

    for i=1,PLAYER_NUMBER do
        if i == nChair then
            self.m_nGangScoreAll[i] = self.m_nGangScoreAll[i] + stBase*(PLAYER_NUMBER-1)
        else
            self.m_nGangScoreAll[i] = self.m_nGangScoreAll[i] - stBase
        end
    end

    return self.m_nGangScoreAll
end

function RoundInfo:UpdateGangScore(GangScoreAll)

    for i=1,PLAYER_NUMBER do
        self.m_nGangScoreAll[i] = GangScoreAll[i]       
    end

    return self.m_nGangScoreAll
end

function RoundInfo:GetPengGangCard()
    return self.m_nPengGangCard
end

function RoundInfo:SetPengGangCard(nCard)
    self.m_nPengGangCard = nCard
end


return RoundInfo
