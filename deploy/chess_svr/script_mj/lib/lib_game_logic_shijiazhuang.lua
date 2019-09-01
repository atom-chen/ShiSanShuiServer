local LibBase = import(".lib_base")
local PlayerBlockState = import("core.player_block_state")



local LibGameLogicShiJiaZhuang = class("LibGameLogicShiJiaZhuang", LibBase)

local stGangInfo= {
    stAnGangCount = 0, 
    stMingGangCount = 0,  
    stPengGangCount = 0,  
    stBeiAnGangCount = 0, 
    stBeiMingGangCount = 0,  
    stBeiPengGangCount = 0,
    nGangScore = 0,
} 
local stHuInfo= {
    nWinChair = 0, 
    nFanNum = 0,  
    nQinYise = 0,  
    nGangFlower = 0, 
    nGodwin = 0,  
    nGroundwin = 0,
    nSelfDraw = 0,
    nGun = 0, 
    nMenqing = 0,  
    nBian = 0,  
    nKa = 0, 
    nDiao = 0,  
    nIsBanker = 0,
    nDragon = 0,
    nHaidihu = 0, 
    nCHQidui = 0,  
    nHQidui = 0,  
    nWukui = 0, 
    nShiSanyao = 0,  
} 
function LibGameLogicShiJiaZhuang:ctor()
    self.m_stBalanceList = {}
    self.m_nBalanceIndex = 0
    self.m_nHuInfo ={}
    self.m_nGangInfo ={}
    self.m_nHuScore ={}
    for i=1,PLAYER_NUMBER do
        self.m_nGangInfo[i] = clone(stGangInfo)
        self.m_nHuInfo[i] = clone(stHuInfo)
        self.m_nHuScore[i] ={0,0,0,0}
    end
end
function LibGameLogicShiJiaZhuang:CreateInit()
   self.m_stCHDHu = {}
   self.m_stFanCountSum = {0, 0, 0, 0}
    self.m_nHuScore ={}
    for i=1,PLAYER_NUMBER do
        self.m_nGangInfo[i] = clone(stGangInfo)
        self.m_nHuInfo[i] = clone(stHuInfo)
        self.m_nHuScore[i] ={0,0,0,0}
    end
   return true
end
function LibGameLogicShiJiaZhuang:OnGameStart()
    self.m_stCHDHu = {}
    self.m_stFanCountSum = {0, 0, 0, 0}
    self.m_nHuScore ={}
    for i=1,PLAYER_NUMBER do
        self.m_nGangInfo[i] = clone(stGangInfo)
        self.m_nHuInfo[i] = clone(stHuInfo)
        self.m_nHuScore[i] ={0,0,0,0}
    end
    self:ClearBalance()
     return true
end


function LibGameLogicShiJiaZhuang:ClearBalance()
    self.m_stBalanceList = {}
    self.m_nBalanceIndex = 0
end

function LibGameLogicShiJiaZhuang:ProcessShiJiaZhuang(nGangValue,nChair,nTurn)
     LOG_DEBUG("=====Get ProcessOPQuadrupletShiJiaZhuang=====%d %d %d=====",nGangValue,nChair,nTurn)
    local stGameState = GGameState
    local  stPlayer = stGameState:GetPlayerByChair(nChair)
    -- report
    --  算分
    local stFanCount = {0, 0, 0, 0}

    local stMingGangCount = {0, 0, 0, 0}
    local stBeiMingGangCount = {0, 0, 0, 0}
    local stAnGangCount = {0, 0, 0, 0}
    local stBeiAnGangCount = {0, 0, 0, 0}
    local stPengGangCount = {0, 0, 0, 0}
    local stBeiPengGangCount = {0, 0, 0, 0}

    if nGangValue == ACTION_QUADRUPLET_CONCEALED then
        stAnGangCount[nChair] =1
    elseif nGangValue == ACTION_QUADRUPLET_REVEALED then
        stMingGangCount[nChair] =1
    elseif nGangValue == ACTION_QUADRUPLET then
        stPengGangCount[nChair] =1
    end
     for i=1,PLAYER_NUMBER do
        if i ~= nChair then
            if nGangValue == ACTION_QUADRUPLET_CONCEALED then -- 下雨两倍
                stFanCount[i] = -1
                stFanCount[nChair] = stFanCount[nChair] +1 
                stBeiAnGangCount[i] =1

            elseif nGangValue == ACTION_QUADRUPLET_REVEALED then -- 刮风，自己摸到和自己碰过的刻子杠。一倍
                stFanCount[i] = -1
                stFanCount[nChair] = stFanCount[nChair] + 1
                stBeiPengGangCount[i] =1

            elseif nGangValue == ACTION_QUADRUPLET then -- 刮风，别人出牌给自己明杠。 一倍
                if i == nTurn then
                   stFanCount[i] = -1
                   stFanCount[nChair] = stFanCount[nChair] + 1
                   stBeiMingGangCount[i] =1
                end
            end
        end
    end
    LOG_DEBUG("=====Get ProcessOPQuadrupletShiJiaZhuang stFanCount:%s", vardump(stFanCount))
    for i=1,PLAYER_NUMBER do
        self.m_nGangInfo[i].nGangScore =self.m_nGangInfo[i].nGangScore+stFanCount[i]

        self.m_nGangInfo[i].stAnGangCount =self.m_nGangInfo[i].stAnGangCount+stAnGangCount[i]
        self.m_nGangInfo[i].stMingGangCount =self.m_nGangInfo[i].stMingGangCount+stMingGangCount[i]
        self.m_nGangInfo[i].stPengGangCount =self.m_nGangInfo[i].stPengGangCount+stPengGangCount[i]

        self.m_nGangInfo[i].stBeiAnGangCount =self.m_nGangInfo[i].stBeiAnGangCount+stBeiAnGangCount[i]
        self.m_nGangInfo[i].stBeiMingGangCount =self.m_nGangInfo[i].stBeiMingGangCount+stBeiMingGangCount[i]
        self.m_nGangInfo[i].stBeiPengGangCount =self.m_nGangInfo[i].stBeiPengGangCount+stBeiPengGangCount[i]
    end
    LOG_DEBUG("=====Get ProcessOPQuadrupletShiJiaZhuang self.m_nGangInfo:%s", vardump(self.m_nGangInfo))
end






-- 处理成都胡
function LibGameLogicShiJiaZhuang:ProcessOPWin()
    self:ClearBalance()
    local stRoundInfo = GRoundInfo
    --/这里要支持一炮多响，发现一个人胡，则把查找出所以可以胡的人。
    local byActionTemp = 0
    local k = 1
    self.m_stCHDHu = {0, 0, 0}
    --找出所以可以胡的人，放入结构m_cCHDHu[k]中。
    local nOnTurn = stRoundInfo:GetWhoIsOnTurn()
    local nLastGive = stRoundInfo:GetLastGive() or 0
    local nLastDraw = stRoundInfo:GetLastDraw() or 0
    local nWinCard = nLastGive

    local cCheckChair = nOnTurn
    for x=1,PLAYER_NUMBER do
        cCheckChair =  LibTurnOrder:GetNextTurn(cCheckChair)
       local stPlayerBlockState = LibGameLogic:GetPlayerBlockState(cCheckChair)
        if stPlayerBlockState:GetWin()  == ACTION_WIN then
            -- CheckWin  这里暂时不做检查
            LOG_DEBUG("ACTION_WIN WhoIsOnTurn:%d !!!!!!!!!!!!!\n", cCheckChair)
            self.m_stCHDHu[k] = cCheckChair
            k = k + 1
        end
    end
    -- 这里取到的是有效的 和  不存在血战以和以及认输的玩家
    if self.m_stCHDHu[1] == 0 and self.m_stCHDHu[2] == 0 and self.m_stCHDHu[3] == 0 then
        LOG_ERROR("no win")
        return 
    end
    -- 自摸
    if self.m_stCHDHu[1] == nOnTurn then
        nWinCard = nLastDraw 
    else
        nWinCard = nLastGive
    end

    -- 先处理胡消息 这里有一炮多响的情况 一起处理
    local stWinList = {}
    local stWinChairs = {}
    for i=1,#self.m_stCHDHu do
        local nChair = self.m_stCHDHu[i]
        if nChair > 0 then
            stWinChairs[#stWinChairs + 1] = nChair
        end
   end    
    LibTurnOrder:Sort(stWinChairs)
    for i=1,#stWinChairs do
        local nChair = stWinChairs[i]
        stWinList[#stWinList + 1] = {winner = nChair, winWho = nOnTurn, cardWin = nWinCard}
    end
               
    -- 通知胡逻辑
   LibGameLogic:DoProcessOPWin(stWinList)

   self:DoHuBalance()


    self.m_stCHDHu = {-1, -1, -1}
end


function LibGameLogicShiJiaZhuang:DoHuBalance()
      -- 算番
    local stRoundInfo = GRoundInfo
    self.m_stWinChairs = {}
    self.m_stFanInfo = {}
    local nBaseBet = GGameCfg.RoomSetting.nBaseBet

    for i=1,#self.m_stCHDHu do
        local nChair = self.m_stCHDHu[i]
        if nChair > 0 and nChair < PLAYER_NUMBER then
            self.m_stWinChairs[#self.m_stWinChairs + 1] = nChair
        end
   end    
    LibTurnOrder:Sort(self.m_stWinChairs)


    -- 每个胡开始 顺序算番

    for k=1, #self.m_stWinChairs do
        local nWin = self.m_stWinChairs[k]
        stRoundInfo:SetLastWinner(nWin)
        local env = LibFanCounter:CollectEnv(self.m_stWinChairs[k])
        LibFanCounter:SetEnv(env)
        local stScore = {0, 0,0,0}
        -- 用score 反查fan
        local stFanInfo = LibFanCounter:GetCount()
        stScore = LibFanCounter:GetScore()  
        if stScore == nil then
            LOG_ERROR(" LibFanCounter:GetScore()  Failed.")
            return 
        end
        local nFanNum = 0

        LOG_DEBUG("=====Get DoHuBalance stFanInfo:%s,stScore===%s", vardump(stFanInfo),vardump(stScore))
        self.m_nHuScore[k] =stScore
        LOG_DEBUG("=====Get DoHuBalance k:%d,self.m_nHuScore[k]===%s", k,vardump(self.m_nHuScore[k]))

        self.m_nHuInfo.nFanDetailInfo =stFanInfo
        
        self.m_nHuInfo[k].nWinChair =nWin
        for j=1, #stFanInfo do

            self.m_nHuInfo[k].nFanNum = self.m_nHuInfo[k].nFanNum + stFanInfo[j].byFanNumber

            if stFanInfo[j].byFanType == 2 then
                self.m_nHuInfo[k].nQinYise =1

            elseif stFanInfo[j].byFanType == 4 then
                self.m_nHuInfo[k].nQiDui =1
            
            elseif stFanInfo[j].byFanType ==13 then
                self.m_nHuInfo[k].nGangFlower =1
            
            elseif stFanInfo[j].byFanType == 16 then
                self.m_nHuInfo[k].nGodwin =1
            
            elseif stFanInfo[j].byFanType == 17 then
                self.m_nHuInfo[k].nGroundwin =1
            
            elseif stFanInfo[j].byFanType == 18 then
                self.m_nHuInfo[k].nSelfDraw =1
            
            elseif stFanInfo[j].byFanType == 19 then
                self.m_nHuInfo[k].nGun =1
           
            elseif stFanInfo[j].byFanType == 20 then
                self.m_nHuInfo[k].nMenqing =1
           
            elseif stFanInfo[j].byFanType == 21 then
                self.m_nHuInfo[k].nBian =1
            
            elseif stFanInfo[j].byFanType == 22 then
                self.m_nHuInfo[k].nKa =1
            
            elseif stFanInfo[j].byFanType ==23 then
                self.m_nHuInfo[k].nDiao =1
            
            elseif stFanInfo[j].byFanType ==24 then
                self.m_nHuInfo[k].nIsBanker =1
            
            elseif stFanInfo[j].byFanType == 25 then
                self.m_nHuInfo[k].nDragon =1
            
            elseif stFanInfo[j].byFanType == 26 then
                self.m_nHuInfo[k].nHaidihu =1
            
            elseif stFanInfo[j].byFanType == 27 then
                self.m_nHuInfo[k].nHQidui =1
            
            elseif stFanInfo[j].byFanType == 28 then
                self.m_nHuInfo[k].nCHQidui =1
            
            elseif stFanInfo[j].byFanType == 29 then
                self.m_nHuInfo[k].nWukui =1
            
            elseif stFanInfo[j].byFanType == 30 then
                self.m_nHuInfo[k].nShiSanyao =1
            end
        end
    end
LOG_DEBUG("=====Get self.m_nHuInfo===%s",vardump(self.m_nHuInfo))
end



 function LibGameLogicShiJiaZhuang:CHD_GetFanCount(nChair, nCard)
    local nTurn = LibTurnOrder:GetNextTurn(nChair) 
    local nFlag = WIN_GUN
    local nLast = nCard
    local env = LibFanCounter:CollectEnv(nChair, nTurn, nFlag, nLast)
    env.byChair = nChair - 1
    env.byTurn = LibTurnOrder:GetNextTurn(nChair) -1 -- 非自摸
    env.byFlag = WIN_GUN
    env.tLast  = nCard
    LibFanCounter:SetEnv(env)
    local stFanCount = LibFanCounter:GetCount()
    print("stFanCount:%s", vardump(stFanCount))
    local nFanNum = 0
    for i=1,#stFanCount do
        nFanNum = nFanNum + stFanCount[i].byFanNumber
    end
    return nFanNum
 end



function LibGameLogicShiJiaZhuang:RewardThisGame()
    -- todo: 荒牌，是否要退回原先减去的杠分
    --荒牌放到另外一个函数处理



    local base_score = 1 -- 底分
    local gang_score = {}
    local hu_score = {}      -- 几个人的得分
    local  win_type ={}
    local set_cards = {}
    local cards = {}
    local win_card = {}
    local wininfo ={}

    local is_no_winner = true
    for i=1,PLAYER_NUMBER do
        gang_score[i] = self.m_nGangInfo[i].nGangScore;
        hu_score[i] = 0;
        win_type[i] = ""
        local stPlayer = GGameState:GetPlayerByChair(i)
        set_cards[i] = stPlayer:GetPlayerCardSet():ToArray()
        cards[i] = stPlayer:GetPlayerCardGroup():ToArray()

        if stPlayer:IsWin() then
            is_no_winner = false;
        end
        for j=1,#self.m_nHuScore do
            hu_score[i] =hu_score[i] + self.m_nHuScore[j][i] 
            LOG_DEBUG("=====Get DoHuBalance i:%d,hu_score[i]===%s", i,hu_score[i])
        end

    end
    if is_no_winner == true then
        for i=1,PLAYER_NUMBER do
            gang_score[i] =0
            hu_score[i] =0
        end
    end

    local stScoreRecord = LibGameLogic:GetScoreRecord()
    LOG_DEBUG("WHEN rec==================,  self.m_nHuInfo=%s",vardump(self.m_nHuInfo))
    for i=1, PLAYER_NUMBER do
        local stPlayer = GGameState:GetPlayerByChair(i)
        local uinfo = stPlayer:GetUserInfo()
        local rec ={}
        if stPlayer:IsWin() then
            if GRoundInfo:GetWhoIsOnTurn()==i then
                win_type[i] = "selfdraw"--"自摸"--"selfdraw"
            else
                win_type[i] = "gunwin"--"放枪"--"gunwin"
            end
            win_card[i] = stPlayer:GetPlayerWinCards()[1]
            for k=1, #self.m_nHuInfo do
                if self.m_nHuInfo[k].nWinChair== i then
                    wininfo[i] =self.m_nHuInfo[k]
                end
            end
        end

        rec = {
            _chair       = "p" ..i,
            _uid         = uinfo._uid,
            an_gang     =self.m_nGangInfo[i].stAnGangCount,
            ming_gang     =self.m_nGangInfo[i].stMingGangCount,
            peng_gang     =self.m_nGangInfo[i].stPengGangCount,
            beian_gang     =self.m_nGangInfo[i].stBeiAnGangCount,
            beiming_gang     =self.m_nGangInfo[i].stBeiMingGangCount,
            beipeng_gang     =self.m_nGangInfo[i].stBeiPengGangCount,

            gang_score  = gang_score[i],
            hu_score    = hu_score[i],
            all_score   = gang_score[i] + hu_score[i],

            combineTile = set_cards[i],
            discardTile = stPlayer:GetPlayerGiveGroup():ToArray(),
            cards       = cards[i],
            win_card    = {win_card[i]},
            win_type    = win_type[i],
            win_info    =wininfo[i],
        }

        LOG_DEBUG("WHEN rec==================,  rec=%s",vardump(rec))
        stScoreRecord:SetRecordByChair(i, rec)

        --test 更新金币积分
        local nScore = gang_score[i] + hu_score[i]
        local nCoin = nScore   --TODO:这个需要怎么计算
        local nWin, nLose, nEqual = 0, 0, 0
        if is_no_winner then
            nEqual = 1
        else
            if stPlayer:IsWin() then
                nWin = nWin + 1
            else
                nLose = nLose + 1
            end
        end
        stPlayer:UpdataGameScore(nCoin, nScore, nWin, nLose, nEqual)
    end
end
return LibGameLogicShiJiaZhuang

