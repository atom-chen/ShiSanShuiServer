local LibBase = import(".lib_base")
local PlayerBlockState = import("core.player_block_state")


local LibGameLogicQuanZhou = class("LibGameLogicQuanZhou", LibBase)


local stPanInfo = {
    nXuKeZi = 0, 
    nZiKeZi = 0, 
    nTripleNum = 0, 
    nLaiZiCount = 0, 
    nFlowerCount = 0, 
    nflower_flag_cxqd = 0, 
    nflower_flag_mlzj = 0, 
    nGangFan = 0,
    }

function LibGameLogicQuanZhou:ctor()
    self.m_stPanInfo = {}
    self.m_nGangInfo = {}
    for i=1,PLAYER_NUMBER do
        -- 杠数量
        self.m_stPanInfo[i] = {panCount = 0, panInfo = clone(stPanInfo)}
        self.m_nGangInfo[i] = {
            stAnGangCount = 0, 
            stMingGangCount = 0,  
            stPengGangCount = 0,  
            stBeiAnGangCount = 0, 
            stBeiMingGangCount = 0,  
            stBeiPengGangCount = 0,
            nGangScore = 0,
        }
    end
    -- 胡详细信息
    self.m_nHuInfo = {}
    -- 胡分
    self.m_nHuScore = {0,0,0,0}
    -- 杠番信息
    self.m_stGangFan = {0,0,0,0}
end

function LibGameLogicQuanZhou:CreateInit()
    return true
end

function LibGameLogicQuanZhou:OnGameStart()
    self.m_stPanInfo = {}
    self.m_nGangInfo = {}
    for i=1,PLAYER_NUMBER do
        self.m_stPanInfo[i] = {panCount = 0, panInfo = clone(stPanInfo)}
        self.m_nGangInfo[i] = {
            stAnGangCount = 0, 
            stMingGangCount = 0,  
            stPengGangCount = 0,  
            stBeiAnGangCount = 0, 
            stBeiMingGangCount = 0,  
            stBeiPengGangCount = 0,
            nGangScore = 0,
        }
    end
    self.m_nHuInfo = {}
    self.m_nHuScore = {0,0,0,0}
    self.m_stGangFan = {0,0,0,0}
    return true
end

--处理保存杠信息
function LibGameLogicQuanZhou:ProcessOPQuadruplet(nGangValue,nChair,nTurn,nCard)
    LOG_DEBUG("=====Get ProcessOPQuadruplet=====%d %d %d==%d===",nGangValue,nChair,nTurn,nCard)
    local stGameState = GGameState
    local stPlayer = stGameState:GetPlayerByChair(nChair)

    if GRoundInfo:GetIsQiangGang() == true then   
        return
    end

    -- 打“课”模式               打“局”模式
    -- “序数”光杠：2盘          光杠：1盘
    -- “字牌”光杠：3盘          暗杠：2盘
    -- “序数”暗杠：3盘          春夏秋冬1套花：2盘
    -- “字牌”暗杠：4盘          梅兰竹菊1套花：2盘

    local stFanCount = {0, 0, 0, 0}

    local stMingGangCount = {0, 0, 0, 0}
    local stBeiMingGangCount = {0, 0, 0, 0}
    local stAnGangCount = {0, 0, 0, 0}
    local stBeiAnGangCount = {0, 0, 0, 0}
    local stPengGangCount = {0, 0, 0, 0}
    local stBeiPengGangCount = {0, 0, 0, 0}

    local nGameStyle = GGameCfg.RoomSetting.nGameStyle
    local nCardType  = GetCardType(nCard, nGameStyle)

    for i=1,PLAYER_NUMBER do
        if i ~= nChair then
            if nGangValue == ACTION_QUADRUPLET_CONCEALED then     -- 暗杠
                stBeiAnGangCount[i] = 1
    
            elseif nGangValue == ACTION_QUADRUPLET_REVEALED then  -- 补杠 先碰后杠
                stBeiPengGangCount[i] = 1
    
            elseif nGangValue == ACTION_QUADRUPLET then           -- 直杠
                if i == nTurn then
                    stBeiMingGangCount[i] = 1
                end
            end
        elseif i == nChair then
            if nGangValue == ACTION_QUADRUPLET_CONCEALED then     -- 暗杠
                stAnGangCount[nChair] = 1
                
                if GGameCfg.GameSetting.bSupportKe then
                    if nCardType == CARDTYPE_CHAR or nCardType == CARDTYPE_BAMBOO or nCardType == CARDTYPE_BALL then
                        stFanCount[nChair] = 3 
                    elseif nCardType == CARDTYPE_WIND or nCardType == CARDTYPE_JIAN  then
                        stFanCount[nChair] = 4 
                    end
                elseif GGameCfg.GameSetting.bSupportJu then
                    stFanCount[nChair] = 2
                end
                
            elseif nGangValue == ACTION_QUADRUPLET_REVEALED then     -- 补杠 先碰后杠
                stPengGangCount[nChair] = 1
                
                if GGameCfg.GameSetting.bSupportKe then
                    if nCardType == CARDTYPE_CHAR or nCardType == CARDTYPE_BAMBOO or nCardType == CARDTYPE_BALL then
                        stFanCount[nChair] = 2 
                    elseif nCardType == CARDTYPE_WIND or nCardType == CARDTYPE_JIAN  then
                        stFanCount[nChair] = 3 
                    end
                elseif GGameCfg.GameSetting.bSupportJu then
                    stFanCount[nChair] = 1
                end
                
            elseif nGangValue == ACTION_QUADRUPLET then               -- 直杠
                stMingGangCount[nChair] = 1
                
                if GGameCfg.GameSetting.bSupportKe then
                    if nCardType == CARDTYPE_CHAR or nCardType == CARDTYPE_BAMBOO or nCardType == CARDTYPE_BALL then
                        stFanCount[nChair] = 2 
                    elseif nCardType == CARDTYPE_WIND or nCardType == CARDTYPE_JIAN  then
                        stFanCount[nChair] = 3 
                    end
                elseif GGameCfg.GameSetting.bSupportJu then
                    stFanCount[nChair] = 1
                end
            end
            
        end  
    end
    
    for i=1,PLAYER_NUMBER do
        self.m_stGangFan[i] = self.m_stGangFan[i] + stFanCount[i]
        LOG_DEBUG("===ProcessOPQuadruplet===self.m_stGangFan[%d]: %d\n", i, self.m_stGangFan[i])
    end
    
    for i=1,PLAYER_NUMBER do
        self.m_nGangInfo[i].nGangScore = self.m_nGangInfo[i].nGangScore + stFanCount[i]

        self.m_nGangInfo[i].stAnGangCount = self.m_nGangInfo[i].stAnGangCount + stAnGangCount[i]
        self.m_nGangInfo[i].stMingGangCount = self.m_nGangInfo[i].stMingGangCount + stMingGangCount[i]
        self.m_nGangInfo[i].stPengGangCount = self.m_nGangInfo[i].stPengGangCount + stPengGangCount[i]

        self.m_nGangInfo[i].stBeiAnGangCount = self.m_nGangInfo[i].stBeiAnGangCount + stBeiAnGangCount[i]
        self.m_nGangInfo[i].stBeiMingGangCount = self.m_nGangInfo[i].stBeiMingGangCount + stBeiMingGangCount[i]
        self.m_nGangInfo[i].stBeiPengGangCount = self.m_nGangInfo[i].stBeiPengGangCount + stBeiPengGangCount[i]
    end
end

-- 处理胡
function LibGameLogicQuanZhou:ProcessOPWin(stWinData)
    LOG_DEBUG("LibGameLogicQuanZhou:ProcessOPWin...stWinData:%s", vardump(stWinData))
    
    local nWinner = stWinData[1].winner
    local stPlayerWin = GGameState:GetPlayerByChair(nWinner)
    if stPlayerWin:GetPlayerQiangGangStatus() == QIANGGANG_STATUS_OK then
        stPlayerWin:SetPlayerIsQiangGangHu(false)
        GRoundInfo:SetIsQiangGang(false)
    end
    
    -- 处理胡
    local winType = ""
    local bQiangGangHu = GRoundInfo:IsQiangGangHu()
    if GRoundInfo:GetWhoIsOnTurn() == nWinner then
        winType = "selfdraw"        -- "自摸"
    else
        winType = "gunwin"          -- "放枪"
        if bQiangGangHu then
            winType = "robgangwin"  -- 抢杠胡
        end
        
    end
    
    stWinData[1].winType = winType
    CSMessage.NotifyPlayerWin(stWinData)
    LibGameLogic:DoProcessOPWin(stWinData)

    -- 番计算
    self:DoHuBalance(stWinData)
end

-- 番计算
function LibGameLogicQuanZhou:DoHuBalance(stWinData)
    LOG_DEBUG("QuanZhou:DoHuBalance stWinData = %s", vardump(stWinData))
    
    self.m_stFanInfo = {}
    self.m_stWinChairs = {}

    -- 计算加盘信息
    local nSumPan, stPanInfo = 0, {}
    for i=1, PLAYER_NUMBER do
        local panCount, panInfo = self:CalculatePan(i)
        self.m_stPanInfo[i].panCount = panCount
        self.m_stPanInfo[i].panInfo = panInfo
        LOG_DEBUG("QuanZhou:CalculatePan panCount = %d panInfo = %s", panCount, vardump(panInfo))
        if i == stWinData[1].winner then
            nSumPan, stPanInfo = self.m_stPanInfo[i].panCount, self.m_stPanInfo[i].panInfo
        end
    end

    -- local nLaiZiCount = stPanInfo.nLaiZiCount              -- 金牌
    -- local nFlowerCount = stPanInfo.nFlowerCount            -- 花数
    -- local nflower_flag_cxqd = stPanInfo.nflower_flag_cxqd  -- 春夏秋冬1套花
    -- local nflower_flag_mlzj = stPanInfo.nflower_flag_mlzj  -- 梅兰竹菊1套花
    
    self.m_nHuInfo.nXuKeZi = stPanInfo.nXuKeZi             -- 赢家序数课子数
    self.m_nHuInfo.nZiKeZi = stPanInfo.nZiKeZi             -- 赢家字牌课子数
    self.m_nHuInfo.nTripleNum = stPanInfo.nTripleNum       -- 赢家碰的数目
    self.m_nHuInfo.nflower_flag_cxqd = stPanInfo.nflower_flag_cxqd  -- 春夏秋冬1套花
    self.m_nHuInfo.nflower_flag_mlzj = stPanInfo.nflower_flag_mlzj  -- 梅兰竹菊1套花

    local nBanker = GRoundInfo:GetBanker()
    -- local nGameStyle = GGameCfg.RoomSetting.nGameStyle
    local bJiaJiaYou = GGameCfg.GameSetting.bSupportGunAll
    
    -- 连庄次数
    local nLianZhuangCount = GRoundInfo:GetLianZhuangCount()
    for i=1,#stWinData do
        local nChair = stWinData[i].winner
        if nChair > 0 and nChair <= PLAYER_NUMBER then
            self.m_stWinChairs[#self.m_stWinChairs + 1] = nChair
        end
    end
    
    -- 每个胡开始 顺序算番
    for k=1, #self.m_stWinChairs do
        local nWin = self.m_stWinChairs[k]
        GRoundInfo:SetLastWinner(nWin)

        local env = LibFanCounter:CollectEnv(self.m_stWinChairs[k])
        LibFanCounter:SetEnv(env)
        local stFanInfo = LibFanCounter:GetCount()
        LOG_DEBUG("QuanZhou:DoHuBalance stFanInfo: %s", vardump(stFanInfo))

        self.m_nHuInfo.nFanNum = 0
        self.m_nHuInfo.nWinChair = nWin
        self.m_nHuInfo.nFanDetailInfo = stFanInfo
        for j=1, #stFanInfo do
            self.m_nHuInfo.nFanNum = self.m_nHuInfo.nFanNum + stFanInfo[j].byFanNumber
            -- 抢金
            if stFanInfo[j].byFanType == 38 then
                self.m_nHuInfo.nYouJin = 1
            -- 双游
            elseif stFanInfo[j].byFanType == 39 then
                self.m_nHuInfo.nDoubleYou = 1           
            -- 三游
            elseif stFanInfo[j].byFanType == 40 then
                self.m_nHuInfo.nTribleYou = 1            
            -- 八张花
            elseif stFanInfo[j].byFanType == 41 then
                self.m_nHuInfo.nEightFlower = 1            
            -- 三金倒
            elseif stFanInfo[j].byFanType == 42 then
                self.m_nHuInfo.nSanJinDao = 1
            end 
        end
    end

    -- 花：  1盘。
    -- 金牌：1盘。
    -- "字牌"碰：  1盘。  self.m_nHuInfo.nTripleNum  赢家碰的数目
    -- "序数"刻子：1盘。  self.m_nHuInfo.nXuKeZi     赢家序数课子数
    -- "字牌"刻子：2盘。  self.m_nHuInfo.nZiKeZi     赢家字牌课子数

    -- "序数"光杠：2盘。
    -- "字牌"光杠：3盘。
    -- "序数"暗杠：3盘。
    -- "字牌"暗杠：4盘。  self.m_stGangFan[i]各个玩家杠所得盘数

    -- 平胡 =（底+加盘）*特殊胡牌倍数（非特殊牌型时此处=1）
    -- 自摸 = "平胡"*2 

    -- 在"课"模式下，牌局底分为“庄10分，闲5分”。
    -- 在"课"模式下，如果臭庄或连庄，那么下一局“庄+5分，闲+0分”。

    -- 在"局"模式下，牌局底分为“庄2分，闲1分”。
    -- 在"局"模式下，如果臭庄或连庄，那么下一局“庄+1分，闲+0分”。

    -- 泉州麻将抢杠胡算自摸
    local nBaseScore = 0
    local nBankBaseScore = 0
    local stWinOne = stWinData[1]  -- 泉州只有一个人胡
    if GGameCfg.GameSetting.bSupportJu then
        if stWinOne.winner == nBanker then
            nBaseScore = 2 + nLianZhuangCount*1
        else
            nBaseScore = 1
        end
        nBankBaseScore = 2 + nLianZhuangCount*1
    elseif GGameCfg.GameSetting.bSupportKe then
        if stWinOne.winner == nBanker then
            nBaseScore = 10 + nLianZhuangCount*5
        else
            nBaseScore = 5
        end
        nBankBaseScore = 10 + nLianZhuangCount*5
    end
    
    local nTmpBaseScore = nBaseScore  -- 记录保存底分
	if stWinOne.winner == stWinOne.winWho or GRoundInfo:IsQiangGangHu() then
        -- 自摸时，有特殊牌形时，*特殊牌形番数，否则*2
		for i=1,PLAYER_NUMBER do
		    if i ~= stWinOne.winner then
                if i ~= nBanker then  -- 处理庄 输 底分翻倍
                    nBaseScore = nTmpBaseScore
                else
                    nBaseScore = nBankBaseScore
                end
                
                if self.m_nHuInfo.nFanNum == 1 then
                    if GGameCfg.GameSetting.bSupportKe then
                        self.m_nHuScore[stWinOne.winner] = self.m_nHuScore[stWinOne.winner] + (nSumPan + nBaseScore)*self.m_nHuInfo.nFanNum*2
                        self.m_nHuScore[i] = -(nSumPan + nBaseScore)*self.m_nHuInfo.nFanNum*2
                    elseif GGameCfg.GameSetting.bSupportJu then
                        self.m_nHuScore[stWinOne.winner] = self.m_nHuScore[stWinOne.winner] + (nSumPan + nBaseScore*self.m_nHuInfo.nFanNum*2)
                        self.m_nHuScore[i] = -(nSumPan + nBaseScore*self.m_nHuInfo.nFanNum*2)
                    end
                else
                    if GGameCfg.GameSetting.bSupportKe then
                        self.m_nHuScore[stWinOne.winner] = self.m_nHuScore[stWinOne.winner] + (nSumPan + nBaseScore)*self.m_nHuInfo.nFanNum
                        self.m_nHuScore[i] = -(nSumPan + nBaseScore)*self.m_nHuInfo.nFanNum 
                    elseif GGameCfg.GameSetting.bSupportJu then
                        self.m_nHuScore[stWinOne.winner] = self.m_nHuScore[stWinOne.winner] + (nSumPan + nBaseScore*self.m_nHuInfo.nFanNum)
                        self.m_nHuScore[i] = -(nSumPan + nBaseScore*self.m_nHuInfo.nFanNum)
                    end
                end
		    end
		end
        LOG_DEBUG("QuanZhou:QiangGangHu self.m_nHuScore: %s\n", vardump(self.m_nHuScore))
	else
        -- 接炮者
        -- 点炮时，只是1番
        self.m_nHuInfo.nGunWho = stWinOne.winWho 
		for i=1,PLAYER_NUMBER do
			if bJiaJiaYou == true then
				if i ~= stWinOne.winner then
                    if i ~= nBanker then  -- 处理庄 输 底分翻倍
                        nBaseScore = nTmpBaseScore
                    else
                        nBaseScore = nBankBaseScore
                    end
                    
                    if GGameCfg.GameSetting.bSupportKe then
                        self.m_nHuScore[stWinOne.winner] = self.m_nHuScore[stWinOne.winner] + (nSumPan + nBaseScore)*self.m_nHuInfo.nFanNum
                        self.m_nHuScore[i] = -(nSumPan + nBaseScore)*self.m_nHuInfo.nFanNum
                    elseif GGameCfg.GameSetting.bSupportJu then
                        self.m_nHuScore[stWinOne.winner] = self.m_nHuScore[stWinOne.winner] + (nSumPan + nBaseScore*self.m_nHuInfo.nFanNum)
                        self.m_nHuScore[i] = -(nSumPan + nBaseScore*self.m_nHuInfo.nFanNum)
                    end
                end
			else
				if i == stWinOne.winWho then
                    if i ~= nBanker then  -- 处理庄 输 底分翻倍
                        nBaseScore = nTmpBaseScore
                    else
                        nBaseScore = nBankBaseScore
                    end
                    
                    if GGameCfg.GameSetting.bSupportKe then
                        self.m_nHuScore[stWinOne.winner] = (nSumPan + nBaseScore)*self.m_nHuInfo.nFanNum
                        self.m_nHuScore[i] = -(nSumPan + nBaseScore)*self.m_nHuInfo.nFanNum
                    elseif GGameCfg.GameSetting.bSupportJu then
                        self.m_nHuScore[stWinOne.winner] = (nSumPan + nBaseScore*self.m_nHuInfo.nFanNum)
                        self.m_nHuScore[i] = -(nSumPan + nBaseScore*self.m_nHuInfo.nFanNum)
                    end
                end
			end
		end
        LOG_DEBUG("QuanZhou:WIN_GUN self.m_nHuScore: %s\n", vardump(self.m_nHuScore))
	end
	    
    -- 输家之间 盘数结算 BEGIN
    local stPlayer = {}
    local nSumAddPan = 0
    for i=1, PLAYER_NUMBER do
        if stWinOne.winner ~= i then
            local nLoseAddPan, stLoseInfo = self.m_stPanInfo[i].panCount, self.m_stPanInfo[i].panInfo
            nSumAddPan = nSumAddPan + nLoseAddPan
            stPlayer[#stPlayer + 1] = {i, nLoseAddPan, stLoseInfo}
            LOG_DEBUG("HHHHH1111 [nSumAddPan = %d]  [nLoseAddPan = %d]  stLoseInfo = %s", nSumAddPan, nLoseAddPan, vardump(stLoseInfo))
        end
    end
    LOG_DEBUG("HHHHH2222  stPlayer = %s   self.m_nHuScore = %s", vardump(stPlayer), vardump(self.m_nHuScore))
    if #stPlayer > 1 then
        for i=1, #stPlayer do
            local nChair = stPlayer[i][1]
            local nAddPan = stPlayer[i][2]
            self.m_nHuScore[nChair] = self.m_nHuScore[nChair] + (nAddPan * (#stPlayer) - nSumAddPan)
        end
    end
    LOG_DEBUG("HHHHH3333  self.m_nHuScore = %s", vardump(self.m_nHuScore))
    -- 输家之间 盘数结算 END
    
    -- 打“课”模式下不存在小于0的分数
    if GGameCfg.GameSetting.bSupportKe then
        local nSumScore = 0
        local stDelScore = {}
        local stScoreRecord = LibGameLogic:GetScoreRecord()
        for i=1, #stPlayer do
            local nChair = stPlayer[i][1]
            local nScore = stScoreRecord:GetPlayerSumScore(nChair)
            local nAllScore = nScore + self.m_nHuScore[nChair]
            if nAllScore < 0 then
                self.m_nHuScore[nChair] = self.m_nHuScore[nChair] - nAllScore   -- 输家减少应扣的分数
                nSumScore = nSumScore + nAllScore
            end
            
            if self.m_nHuScore[nChair] > 0 then
                table.inser(stDelScore, {chair = nChair, score = self.m_nHuScore[nChair]})
            end
        end
        
        if nSumScore < 0 and #stDelScore > 0 then
            table.sort(stDelScore, function(a,b) return a.score > b.score end)
            
            for nChair, val in pairs(stDelScore) do
                if val.score + nSumScore < 0 then
                    self.m_nHuScore[nChair] = 0
                    nSumScore = val.score + nSumScore
                else
                    nSumScore = 0
                    self.m_nHuScore[nChair] = val.score + nSumScore
                    break
                end
            end
        end
        if nSumScore < 0 then
            self.m_nHuScore[stWinOne.winner] = self.m_nHuScore[stWinOne.winner] + nSumScore
        end
    end
    LOG_DEBUG("HHHHH4444  self.m_nHuScore = %s", vardump(self.m_nHuScore))
end

-- 自摸胡这张牌 可胡几番
function LibGameLogicQuanZhou:GetFanCount(nChair, nCard)
    local nTurn = LibTurnOrder:GetNextTurn(nChair) 
    local nFlag = WIN_SELFDRAW
    local nLast = nCard
    local env = LibFanCounter:CollectEnv(nChair, nTurn, nFlag, nLast)
    env.byChair = nChair - 1
    env.byTurn = LibTurnOrder:GetNextTurn(nChair) -1 -- 非自摸
    env.byFlag = WIN_SELFDRAW
    env.tLast  = nCard
    LibFanCounter:SetEnv(env)
    local stFanCount = LibFanCounter:GetCount()
    LOG_DEBUG("GetFanCount:%s", vardump(stFanCount))
    local nFanNum = 0
    for i=1,#stFanCount do
        nFanNum = nFanNum + stFanCount[i].byFanNumber
    end
    return nFanNum, stFanCount
end

-- 放炮胡：手牌+炮牌
function LibGameLogicQuanZhou:GetFanCount_Gun(nChair, nCard)
    local nTurn = LibTurnOrder:GetNextTurn(nChair) 
    local nFlag = WIN_GUN
    local nLast = nCard
    local env = LibFanCounter:CollectEnv(nChair, nTurn, nFlag, nLast)
    env.byChair = nChair - 1    --C++ 从0开始 lua从1开始
    env.byTurn = LibTurnOrder:GetNextTurn(nChair) -1 -- 非自摸
    env.byFlag = WIN_GUN
    env.tLast  = nCard
    LibFanCounter:SetEnv(env)
    local stFanCount = LibFanCounter:GetCount()
    local nFanNum = 0

    local bYouJin, bShuangYou, bSanYou = false, false, false
    for i=1,#stFanCount do
        nFanNum = nFanNum + stFanCount[i].byFanNumber
        if stFanCount[i].byFanType == 38 then
            bYouJin = true
        elseif stFanCount[i].byFanType == 39 then
            bShuangYou = true
        elseif stFanCount[i].byFanType == 40 then
            bSanYou = true
        end
    end
    LOG_DEBUG("GetFanCount_Gun...nFanNum:%d, stFanCount:%s", nFanNum, vardump(stFanCount))

    return nFanNum, bYouJin, bShuangYou, bSanYou
end

-- 检查胡的牌型
function LibGameLogicQuanZhou:ChectFanCount(nChair, nCard, byFanType)
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
    LOG_DEBUG("ChectFanCount:%s", vardump(stFanCount))

    local bFind = false
    if stFanCount and #stFanCount > 0 then
        local nCount = #stFanCount
        for k, v in ipairs(stFanCount) do
            if v.byFanType == byFanType then
                bFind = true
                break
            end
        end
    end
    return bFind
end

function LibGameLogicQuanZhou:RewardThisGame()
    -- 荒牌，不处理
    local gang_score = {}
    local hu_score = {}      -- 几个人的得分
    local win_type = {}
    local set_cards = {}
    local cards = {}
    local win_card = {}

    local nWinTripleNum = 0
    local nWinXuKeZi = 0
    local nWinZiKeZi = 0
    local nWinGangFan = 0
    local nflower_flag_cxqd = 0  -- 春夏秋冬1套花
    local nflower_flag_mlzj = 0  -- 梅兰竹菊1套花

    local is_no_winner = true
    for i=1,PLAYER_NUMBER do
        -- 目前不需要计算杠分
        hu_score[i] = 0
        win_type[i] = ""
        gang_score[i] = 0   -- self.m_nGangInfo[i].nGangScore
        local stPlayer = GGameState:GetPlayerByChair(i)
        cards[i] = stPlayer:GetPlayerCardGroup():ToArray()
        set_cards[i] = stPlayer:GetPlayerCardSet():ToArray()

        if stPlayer:IsWin() then
            is_no_winner = false
        end

        hu_score[i] = self.m_nHuScore[i]
        LOG_DEBUG("=====Get DoHuBalance i:%d, hu_score[i]===%s", i, hu_score[i])
    end
    
    if is_no_winner == true then
        for i=1,PLAYER_NUMBER do
            gang_score[i] = 0
            hu_score[i] = 0
        end
    end

    local nLaiZiCount = 0
    local nGunWho = 0
    nGunWho = self.m_nHuInfo.nGunWho
    LOG_DEBUG("WHEN rec==================, self.m_nHuInfo = %s", vardump(self.m_nHuInfo))
    for i=1, PLAYER_NUMBER do
        local stPlayer = GGameState:GetPlayerByChair(i)
        local uinfo = stPlayer:GetUserInfo()
        local rec = {}
        local wininfo = {}
        local nJiePao = 0
        if nGunWho == i then
            nJiePao = 1
        end
        if stPlayer:IsWin() then
            local bQiangGangHu = GRoundInfo:IsQiangGangHu()
            if GRoundInfo:GetWhoIsOnTurn() == i then
                win_type[i] = "selfdraw"        --"自摸"
            else
                win_type[i] = "gunwin"          --"放枪"
                if bQiangGangHu then
                    win_type[i] = "robgangwin"  --抢杠胡
                end
            end
            
            win_card[i] = stPlayer:GetPlayerWinCards()[1]
            wininfo = self.m_nHuInfo
        end
        local nFlowerFan = stPlayer:GetFlowerNums()
        local nLianZhuangFan = 0
        local nBanker = GRoundInfo:GetBanker()
        if nBanker == i then
            nLianZhuangFan = GRoundInfo:GetLianZhuangCount()
        end
        
        nWinGangFan = self.m_stGangFan[i]
        nLaiZiCount = stPlayer:GetGoldCardNums()
        
        local panInfo = self.m_stPanInfo[i].panInfo
        nflower_flag_cxqd = panInfo.nflower_flag_cxqd  -- 春夏秋冬1套花
        nflower_flag_mlzj = panInfo.nflower_flag_mlzj  -- 梅兰竹菊1套花
        nWinTripleNum = panInfo.nTripleNum
        nWinXuKeZi = panInfo.nXuKeZi
        nWinZiKeZi = panInfo.nZiKeZi

        rec = {
            _chair          = "p" ..i,
            _uid            = uinfo._uid,
            flowerFan       = nFlowerFan,
            lianZhuangFan   = nLianZhuangFan,

            hu_score        = hu_score[i],
            all_score       = gang_score[i] + hu_score[i],
            combineTile     = set_cards[i],
            discardTile     = stPlayer:GetPlayerGiveGroup():ToArray(),
            cards           = cards[i],

            win_card        = {win_card[i]},
            win_type        = win_type[i],
            win_info        = wininfo,
            laizi_count     = nLaiZiCount,
            nJiePao         = nJiePao,

            nWinTripleNum   = nWinTripleNum,
            nWinXuKeZi      = nWinXuKeZi,
            nWinZiKeZi      = nWinZiKeZi,
            nWinGangFan     = nWinGangFan,
            nflower_flag_cxqd = nflower_flag_cxqd,
            nflower_flag_mlzj = nflower_flag_mlzj,
        }

        LOG_DEBUG("WHEN rec==================,  rec=%s", vardump(rec))
        
        local stScoreRecord = LibGameLogic:GetScoreRecord()
        stScoreRecord:SetRecordByChair(i, rec)
        stScoreRecord:SetPlayerSumScore(i, rec.all_score)
        
        --更新金币积分
        local nScore = gang_score[i] + hu_score[i]
        local nCoin = nScore
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

--加盘数目计算
function LibGameLogicQuanZhou:CalculatePan(nChair)
    local nAddPan = 0            -- 总加盘数
    local stPanInfo = {}         -- 加盘信息
    
    local nXuKeZi = 0            -- 序牌课子
    local nZiKeZi = 0            -- 字牌课子
    local nTripleNum = 0         -- 碰的数目

    local nLaiZiCount = 0        -- 癞子数目
    local nFlowerCount = 0       -- 花牌数目
    local nflower_flag_cxqd = 0  -- 春夏秋冬1套花
    local nflower_flag_mlzj = 0  -- 梅兰竹菊1套花
    
    local nGangFan = self.m_stGangFan[nChair]  -- 杠加盘数
    local nGameStyle = GGameCfg.RoomSetting.nGameStyle
    
    if nChair > 0 and nChair <= PLAYER_NUMBER then
        local stPlayer = GGameState:GetPlayerByChair(nChair)
        nLaiZiCount = stPlayer:GetGoldCardNums()   -- 金牌：1盘
        nFlowerCount = stPlayer:GetFlowerNums()    -- 花：1盘

        -- set有几手牌,计算字牌碰牌的数量
        local combineTile = stPlayer:GetPlayerCardSet():ToArray()
        for j =1,#combineTile do
            if combineTile[j].ucFlag == ACTION_TRIPLET then
                local nCardType = GetCardType(combineTile[j].card, nGameStyle)
                if nCardType == CARDTYPE_WIND or nCardType == CARDTYPE_JIAN then
                    nTripleNum = nTripleNum + 1   -- 字牌”碰“：1盘
                end
            end
        end

        --手牌有几个刻子 “序数”刻子：字牌刻子数
        local stPlayerCardHands = stPlayer:GetPlayerCardGroup():ToArray()
                
        local stCardNum = {}
        for i=1, #stPlayerCardHands do
            local nCard = stPlayerCardHands[i]
            stCardNum[nCard] = (stCardNum[nCard] or 0) + 1
        end
        for card, num in pairs(stCardNum) do
            if num >= 3 then
                local nCardType = GetCardType(card, nGameStyle)
                if nCardType == CARDTYPE_WIND or nCardType ==CARDTYPE_JIAN then
                    nZiKeZi = nZiKeZi + 1    -- 手牌中 字牌 刻子数
                elseif nCardType == CARDTYPE_CHAR or nCardType == CARDTYPE_BAMBOO or nCardType == CARDTYPE_BALL then
                    nXuKeZi = nXuKeZi + 1    -- 手牌中 序牌 刻子数
                end
            end
        end
    
        --花牌是否满足一套
        local stFlowerCards = stPlayer:GetFlowerCards()
        --春夏秋冬1套花  2盘
        if table.keyof(stFlowerCards, CARD_FLOWER_CHUN) and table.keyof(stFlowerCards, CARD_FLOWER_XIA) and table.keyof(stFlowerCards, CARD_FLOWER_QIU) and table.keyof(stFlowerCards, CARD_FLOWER_DONG) then
            nflower_flag_cxqd = 2
        end
        --梅兰竹菊1套花  2盘
        if table.keyof(stFlowerCards, CARD_FLOWER_MEI) and table.keyof(stFlowerCards, CARD_FLOWER_LAN) and table.keyof(stFlowerCards, CARD_FLOWER_ZHU) and table.keyof(stFlowerCards, CARD_FLOWER_JU) then
            nflower_flag_mlzj = 2
        end
    end
    
    if GGameCfg.GameSetting.bSupportKe then      -- 打“课”模式
        nAddPan = nLaiZiCount + nFlowerCount + nTripleNum*1 + nXuKeZi*1 + nZiKeZi*2 + nGangFan
    elseif GGameCfg.GameSetting.bSupportJu then  -- 打“局”模式
        nAddPan = nLaiZiCount + nflower_flag_cxqd + nflower_flag_mlzj + nGangFan
    end
    
    stPanInfo = {nXuKeZi = nXuKeZi, nZiKeZi = nZiKeZi, nTripleNum = nTripleNum, nLaiZiCount = nLaiZiCount, nFlowerCount = nFlowerCount, nflower_flag_cxqd = nflower_flag_cxqd, nflower_flag_mlzj = nflower_flag_mlzj, nGangFan = nGangFan}
    
    return nAddPan, stPanInfo
end


return LibGameLogicQuanZhou

