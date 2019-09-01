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
    nGunWho = 0,
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

function LibGameLogicShiJiaZhuang:ResetWinDatas()
    self.m_nHuInfo ={}
    self.m_nGangInfo ={}
    for i=1,PLAYER_NUMBER do
        self.m_nGangInfo[i] = {
            stAnGangCount = 0, 
            stMingGangCount = 0,  
            stPengGangCount = 0,  
            stBeiAnGangCount = 0, 
            stBeiMingGangCount = 0,  
            stBeiPengGangCount = 0,
            nGangScore = 0,
        }
        self.m_nHuInfo[i] = {
            nWinChair = 0,
            nGunWho = 0,
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
    end
    self.m_nHuScore = {0,0,0,0}
    self.m_nFollowScore = {0,0,0,0}
    self.m_stWinChairs = {}
end

function LibGameLogicShiJiaZhuang:ClearBalance()
    self.m_stBalanceList = {}
    self.m_nBalanceIndex = 0
end

function LibGameLogicShiJiaZhuang:ctor()
    self:ResetWinDatas()
    self:ClearBalance()
end

function LibGameLogicShiJiaZhuang:CreateInit()
    self:ResetWinDatas()
    self:ClearBalance()
    return true
end

function LibGameLogicShiJiaZhuang:OnGameStart()
    self:ResetWinDatas()
    self:ClearBalance()
    return true
end

function LibGameLogicShiJiaZhuang:GetGangCount()
    local nCount = 0
    for i=1,PLAYER_NUMBER do
        nCount = nCount + self.m_nGangInfo[i].stAnGangCount + self.m_nGangInfo[i].stMingGangCount + self.m_nGangInfo[i].stPengGangCount
    end
    return nCount
end

function LibGameLogicShiJiaZhuang:ProcessOPQuadruplet(nGangValue, nChair, nTurn)
    LOG_DEBUG("=====Get ProcessOPQuadrupletShiJiaZhuang=====%d %d %d=====",nGangValue,nChair,nTurn)
    if GRoundInfo:GetIsQiangGang() == true then   
        return
    end
    
    -- report 算分
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
        stPengGangCount[nChair] =1
    elseif nGangValue == ACTION_QUADRUPLET then
        stMingGangCount[nChair] =1
    end
    for i=1,PLAYER_NUMBER do
        if i ~= nChair then
            if nGangValue == ACTION_QUADRUPLET_CONCEALED then -- 下雨两倍
                stFanCount[i] = -1
                stFanCount[nChair] = stFanCount[nChair] +1 
                stBeiAnGangCount[i] =1
            elseif nGangValue == ACTION_QUADRUPLET_REVEALED then -- 刮风，自己摸到和自己碰过的刻子杠。一倍
                if i == nTurn then
                    stFanCount[i] = -1
                    stFanCount[nChair] = stFanCount[nChair] + 1
                    stBeiPengGangCount[i] =1
                end
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

-- 处理石家庄胡 支出一炮多响
function LibGameLogicShiJiaZhuang:ProcessOPWin(nCard)
    local nWinCard = nCard
    local stRoundInfo = GRoundInfo

    -- 这里要支持一炮多响，发现一个人胡，则把查找出所以可以胡的人
    local stWinList = {}
    local nOnTurn = stRoundInfo:GetWhoIsOnTurn()
    local nChair = nOnTurn
    for x=1,PLAYER_NUMBER do
        nChair = LibTurnOrder:GetNextTurn(nChair)
        local stPlayerBlockState = LibGameLogic:GetPlayerBlockState(nChair)
        if stPlayerBlockState:GetWin() == ACTION_WIN then
            -- CheckWin 这里暂时不做检查
            LOG_DEBUG("ACTION_WIN WhoIsOnTurn:%d !!!!!!!!!!!!!\n", nChair)
            self.m_stWinChairs[#self.m_stWinChairs + 1] = nChair
            stWinList[#stWinList + 1] = {winner = nChair, winWho = nOnTurn, cardWin = nWinCard}
        end
    end
    -- 这里取到的是有效的 和
    if #self.m_stWinChairs == 0 then
        LOG_ERROR("no win")
        return 
    end
    LOG_DEBUG("ProcessOPWin !!!!!!!!!!!!!stWinList==%s\n", vardump(stWinList))
    -- 通知胡逻辑
    LibGameLogic:DoProcessOPWin(stWinList)
    --算番
    self:DoHuBalance(stWinList)
    --算跟庄
    self:DoFollowBanker()
end

--跟庄分
function LibGameLogicShiJiaZhuang:DoFollowBanker()
    local nCount = GRoundInfo:GetFollowBankerCount()
    local nBaseBet = GGameCfg.RoomSetting.nBaseBet
    local nBanker = GRoundInfo:GetBanker()
    if nCount > 0 then
        local nFirstSore = nBaseBet
        local nFanScore = 0
        if nCount - 1 > 0 then
            nFanScore = nBaseBet * math.pow(2, nCount - 1)
        end

        for i=1,PLAYER_NUMBER do
            if i ~= nBanker then
                self.m_nFollowScore[i] = nFirstSore + nFanScore
                self.m_nFollowScore[nBanker] = self.m_nFollowScore[nBanker] + (-1) * (nFirstSore + nFanScore)
            end
        end
    end
    LOG_DEBUG("DoFollowBanker...nCount:%d, nBanker:%d, m_nFollowScore:%s", nCount, nBanker, vardump(self.m_nFollowScore))
end

-- 算番
function LibGameLogicShiJiaZhuang:DoHuBalance(stWinList)
    local stRoundInfo = GRoundInfo
    local nBaseBet = GGameCfg.RoomSetting.nBaseBet

    -- 每个胡开始 顺序算番
    for k=1, #self.m_stWinChairs do
        local nWin = self.m_stWinChairs[k]
        local env = LibFanCounter:CollectEnv(nWin)

        local stPlayerWin = GGameState:GetPlayerByChair(nWin)
        --如果是抢杠胡成功的话，设置胡类型，重置抢杠胡
        -- LOG_DEBUG("=========000111===LibGameLogicShiJiaZhuang:DoHuBalance=====GetPlayerQiangGangStatus===:%d",stPlayerWin:GetPlayerQiangGangStatus())  
        if stPlayerWin and stPlayerWin:GetPlayerQiangGangStatus() ==QIANGGANG_STATUS_OK then
            env.byFlag = WIN_GANG
            -- LOG_DEBUG("=========000===LibGameLogicShiJiaZhuang:DoHuBalance=====env.byFlag===:%d",env.byFlag)  
            stPlayerWin:SetPlayerIsQiangGangHu(false)
            GRoundInfo:SetIsQiangGang(false)
        end
        -- LOG_DEBUG("=========111===LibGameLogicShiJiaZhuang:DoHuBalance=====env.byFlag===:%d",env.byFlag)   

        LibFanCounter:SetEnv(env)
        local stFanInfo = LibFanCounter:GetCount()
        LOG_DEBUG("DoHuBalance...k:%d, p%d, stFanInfo:%s\n", k, nWin, vardump(stFanInfo))

        self.m_nHuInfo[nWin].nFanNum = 0
        self.m_nHuInfo[nWin].nWinChair = nWin
        self.m_nHuInfo[nWin].nFanDetailInfo = {}
        for j=1, #stFanInfo do
            self.m_nHuInfo[nWin].nFanNum = self.m_nHuInfo[nWin].nFanNum + stFanInfo[j].byFanNumber

            if stFanInfo[j].byFanType == 0 then
                self.m_nHuInfo[nWin].nPinghu = 1

            elseif stFanInfo[j].byFanType == 2 then
                self.m_nHuInfo[nWin].nQinYise = 1

            elseif stFanInfo[j].byFanType == 4 then
                self.m_nHuInfo[nWin].nQiDui = 1

            elseif stFanInfo[j].byFanType == 7 then
                self.m_nHuInfo[nWin].nQinQidui = 1

            elseif stFanInfo[j].byFanType == 13 then
                self.m_nHuInfo[nWin].nGangFlower = 1
            
            elseif stFanInfo[j].byFanType == 16 then
                self.m_nHuInfo[nWin].nGodwin = 1
            
            elseif stFanInfo[j].byFanType == 17 then
                self.m_nHuInfo[nWin].nGroundwin = 1
            
            elseif stFanInfo[j].byFanType == 18 then
                self.m_nHuInfo[nWin].nSelfDraw = 1
            
            elseif stFanInfo[j].byFanType == 19 then
                self.m_nHuInfo[nWin].nGun = 1
           
            elseif stFanInfo[j].byFanType == 20 then
                self.m_nHuInfo[nWin].nMenqing = 1
           
            elseif stFanInfo[j].byFanType == 21 then
                self.m_nHuInfo[nWin].nBian = 1
            
            elseif stFanInfo[j].byFanType == 22 then
                self.m_nHuInfo[nWin].nKa = 1
            
            elseif stFanInfo[j].byFanType == 23 then
                self.m_nHuInfo[nWin].nDiao =1
            
           -- elseif stFanInfo[j].byFanType == 24 then
           --     self.m_nHuInfo[nWin].nIsBanker = 1
            
            elseif stFanInfo[j].byFanType == 25 then
                self.m_nHuInfo[nWin].nDragon = 1
            
            elseif stFanInfo[j].byFanType == 26 then
                self.m_nHuInfo[nWin].nHaidihu = 1
            
            elseif stFanInfo[j].byFanType == 27 then
                self.m_nHuInfo[nWin].nHQidui = 1
            
            elseif stFanInfo[j].byFanType == 28 then
                self.m_nHuInfo[nWin].nQinHQidui = 1
            
            elseif stFanInfo[j].byFanType == 29 then
                self.m_nHuInfo[nWin].nCHQidui = 1
            
            elseif stFanInfo[j].byFanType == 30 then
                self.m_nHuInfo[nWin].nQinCHQidui = 1

            elseif stFanInfo[j].byFanType == 31 then
                self.m_nHuInfo[nWin].nZZQidui = 1

            elseif stFanInfo[j].byFanType == 32 then
                self.m_nHuInfo[nWin].nQinZZnQidui = 1

            -- elseif stFanInfo[j].byFanType == 33 then
            --     self.m_nHuInfo[nWin].nWukui = 1

            elseif stFanInfo[j].byFanType == 34 then
                self.m_nHuInfo[nWin].nShiSanyao = 1

            elseif stFanInfo[j].byFanType == 35 then
                self.m_nHuInfo[nWin].nQinDragon = 1

            elseif stFanInfo[j].byFanType == 36 then
                self.m_nHuInfo[nWin].nGangGanghu = 1

            end
            if stFanInfo[j].byFanType ~= 24 then
                self.m_nHuInfo[nWin].nFanDetailInfo[#self.m_nHuInfo[nWin].nFanDetailInfo+1] = stFanInfo[j]
            end
        end
    end
    LOG_DEBUG("=====Get self.m_nHuInfo===%s\n",vardump(self.m_nHuInfo))

    --计算基础胡分
    LOG_DEBUG("DoHuBalance -----------m_stWinChairs==%s\n", vardump(self.m_stWinChairs))
    LOG_DEBUG("DoHuBalance !!!!!!!!!!!!!stWinList==%s\n", vardump(stWinList))
    --牌局中，无论庄家输牌或者赢牌，结算时，庄家需加1番，即底分×2。庄家赢的话已经在番型中
    local banker  = stRoundInfo:GetBanker()
    for k=1, #stWinList do
        local stWinOne = stWinList[k]
        --自摸
        if stWinOne.winner == stWinOne.winWho then
            local nFanNum = self.m_nHuInfo[stWinOne.winner].nFanNum
            --底分 * 2^nFanNum
            local nWinScore = nBaseBet * math.pow(2, nFanNum)
            for i=1,PLAYER_NUMBER do
                if i ~= stWinOne.winner then
                    local nTempScore = nWinScore
                    if stWinOne.winner ~= banker and i == banker then
                        nTempScore = nTempScore * 2
                    end
                    self.m_nHuScore[stWinOne.winner] = self.m_nHuScore[stWinOne.winner] + nTempScore
                    self.m_nHuScore[i] = (-1) * nTempScore
                end
            end
        else
            --接炮者
            self.m_nHuInfo[stWinOne.winner].nGunWho = stWinOne.winWho 
            local nFanNum = self.m_nHuInfo[stWinOne.winner].nFanNum
            --底分 * 2^nFanNum
            local nWinScore = nBaseBet * math.pow(2, nFanNum)
            local nTempScore = nWinScore
            if stWinOne.winWho == banker then
                nTempScore = nWinScore*2
            end       
            self.m_nHuScore[stWinOne.winner] = self.m_nHuScore[stWinOne.winner] + nTempScore
            self.m_nHuScore[stWinOne.winWho] = self.m_nHuScore[stWinOne.winWho] + (-1) * nTempScore
        end
    end
    LOG_DEBUG("DoHuBalance...m_nHuScore:%s\n", vardump(self.m_nHuScore))
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
    local base_score = 1    -- 底分
    local gang_score = {}   -- 杠分
    local hu_score = {}     -- 几个人的得分
    local follow_score = {} -- 跟庄分
    local win_type ={}
    local set_cards = {}
    local cards = {}
    local win_card = {}
    local wininfo ={}
    local is_no_winner = true
    local nGunWho = 0

    --计算杠分
    local nBaseBet = GGameCfg.RoomSetting.nBaseBet
    for i=1,PLAYER_NUMBER do
        local stPlayer = GGameState:GetPlayerByChair(i)
        LOG_DEBUG("WHEN rec==================self.m_nGangInfo[i].nGangScore=%d",self.m_nGangInfo[i].nGangScore)
        if stPlayer then
            --gang_score[i] = self.m_nGangInfo[i].nGangScore * (nBaseBet/2)
            gang_score[i] = self.m_nGangInfo[i].nGangScore
            LOG_DEBUG("WHEN rec==================gang_score[i].nGangScore=%d",gang_score[i])
            hu_score[i] = self.m_nHuScore[i]
            follow_score[i] = self.m_nFollowScore[i]

            win_type[i] = ""
            set_cards[i] = stPlayer:GetPlayerCardSet():ToArray()
            cards[i] = stPlayer:GetPlayerCardGroup():ToArray()

            if stPlayer:IsWin() then
                is_no_winner = false
                if GRoundInfo:GetWhoIsOnTurn() == i then
                    win_type[i] = "selfdraw"--"自摸"
                else
                    win_type[i] = "gunwin"--"放枪"
                end
                wininfo[i] = self.m_nHuInfo[i]
                win_card[i] = stPlayer:GetPlayerWinCards()[1]
                
                nGunWho = self.m_nHuInfo[i].nGunWho
            end
        end
    end
    
    --荒局结算
    if is_no_winner == true then
        for i=1,PLAYER_NUMBER do
            gang_score[i] = 0
            hu_score[i] = 0
            follow_score[i] = 0
        end
    end

    --胡牌结算
    local stScoreRecord = LibGameLogic:GetScoreRecord()
    LOG_DEBUG("WHEN rec==================,  self.m_nHuInfo=%s",vardump(self.m_nHuInfo))
    for i=1, PLAYER_NUMBER do
        local stPlayer = GGameState:GetPlayerByChair(i)
        if stPlayer then
            local uinfo = stPlayer:GetUserInfo()
            local rec = {}
            local nJiePao = 0
            if nGunWho == i then
                nJiePao =1
            end
            LOG_DEBUG("p%d, nGunWho:%d, nJiePao:%d", i, nGunWho, nJiePao)

            rec = {
                _chair       = "p" ..i,
                _uid         = uinfo._uid,
                an_gang      = self.m_nGangInfo[i].stAnGangCount,
                ming_gang    = self.m_nGangInfo[i].stMingGangCount,
                peng_gang    = self.m_nGangInfo[i].stPengGangCount,
                beian_gang   = self.m_nGangInfo[i].stBeiAnGangCount,
                beiming_gang = self.m_nGangInfo[i].stBeiMingGangCount,
                beipeng_gang = self.m_nGangInfo[i].stBeiPengGangCount,

                gang_score  = gang_score[i],
                hu_score    = hu_score[i],
                follow_score = follow_score[i],
                all_score   = gang_score[i] + hu_score[i] + follow_score[i],

                combineTile = set_cards[i],
                discardTile = stPlayer:GetPlayerGiveGroup():ToArray(),
                cards       = cards[i],
                win_card    = {win_card[i]},
                win_type    = win_type[i],
                win_info    = wininfo[i],
                nJiePao     = nJiePao,
            }

            LOG_DEBUG("WHEN rec==================, rec=%s",vardump(rec))
            stScoreRecord:SetRecordByChair(i, rec)

            --test 更新金币积分
            local nScore = gang_score[i] + hu_score[i]+ follow_score[i]
            local nCoin = nScore   -- TODO:这个需要怎么计算
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
end


return LibGameLogicShiJiaZhuang

