local LibBase = import(".lib_base")
local PlayerBlockState = import("core.player_block_state")
local LibGameLogicLangFang = class("LibGameLogicLangFang", LibBase)

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
    nGangFlower = 0,
    nGodwin = 0,
    nGroundwin = 0,
    nSelfDraw = 0,
    nGun = 0,
    nMenqing = 0,
    nSuHu = 0,
    nWukui = 0,
    nDragon = 0,
    nQiDui = 0,
    nHQidui = 0,
    nCHQidui = 0,
    nZZQidui = 0,
    nHunDiao = 0,
    nHunDHun = 0,
    nPengPengHu = 0,
    nQinYise = 0,
    nShiSanyao = 0,
    nHunYou = 0,
    nHunGangHu = 0,
}

function LibGameLogicLangFang:ResetWinDatas()
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
            nGangFlower = 0,
            nGodwin = 0,
            nGroundwin = 0,
            nSelfDraw = 0,
            nGun = 0,
            nMenqing = 0,
            nSuHu = 0,
            nWukui = 0,
            nDragon = 0,
            nQiDui = 0,
            nHQidui = 0,
            nCHQidui = 0,
            nZZQidui = 0,
            nHunDiao = 0,
            nHunDHun = 0,
            nPengPengHu = 0,
            nQinYise = 0,
            nShiSanyao = 0,
            nHunYou = 0,
            nHunGangHu = 0,
        }
    end
    self.m_nHuScore = {0,0,0,0}
    self.m_nFollowScore = {0,0,0,0}
    self.m_stWinChairs = {}
end

function LibGameLogicLangFang:ClearBalance()
    self.m_stBalanceList = {}
    self.m_nBalanceIndex = 0
end

function LibGameLogicLangFang:ctor()
    self:ResetWinDatas()
    self:ClearBalance()
end

function LibGameLogicLangFang:CreateInit()
    self:ResetWinDatas()
    self:ClearBalance()
    return true
end

function LibGameLogicLangFang:OnGameStart()
    self:ResetWinDatas()
    self:ClearBalance()
    return true
end

function LibGameLogicLangFang:GetGangCount()
    local nCount = 0
    for i=1,PLAYER_NUMBER do
        nCount = nCount + self.m_nGangInfo[i].stAnGangCount + self.m_nGangInfo[i].stMingGangCount + self.m_nGangInfo[i].stPengGangCount
    end
    return nCount
end

function LibGameLogicLangFang:ProcessOPQuadruplet(nGangValue, nChair, nTurn)
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
                stFanCount[i] = -2
                stFanCount[nChair] = stFanCount[nChair] +2
                stBeiAnGangCount[i] =1
            elseif nGangValue == ACTION_QUADRUPLET_REVEALED then -- 刮风，自己摸到和自己碰过的刻子杠。一倍
                stFanCount[i] = -1
                stFanCount[nChair] = stFanCount[nChair] + 1
                stBeiPengGangCount[i] =1
            elseif nGangValue == ACTION_QUADRUPLET then -- 刮风，别人出牌给自己明杠。 一倍
                if i == nTurn then
                    stFanCount[i] = -3
                    stFanCount[nChair] = stFanCount[nChair] + 3
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
function LibGameLogicLangFang:ProcessOPWin(nCard)
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
            break
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
function LibGameLogicLangFang:DoFollowBanker()
    local nBanker = GRoundInfo:GetBanker()
    local nCount = GRoundInfo:GetFollowBankerCount()
    if nCount > 0 then
        for i=1, PLAYER_NUMBER do
            if i ~= nBanker then
                self.m_nFollowScore[i] = nCount
                self.m_nFollowScore[nBanker] = self.m_nFollowScore[nBanker] - nCount
            end
        end
    end
    LOG_DEBUG("LibGameLogicLangFang:DoFollowBanker %s", vardump(self.m_nFollowScore))

end

--混杠胡
function LibGameLogicLangFang:IsHunGangHu(nChair)
    local stPlayer = GGameState:GetPlayerByChair(nChair)
    if stPlayer then
        local arrPlayerCards = stPlayer:GetPlayerCardGroup():ToArray()
        if LibRuleWin:CanWinByLaizi(arrPlayerCards) then
            return true
        end
    end
    return false
end

-- 算番
function LibGameLogicLangFang:DoHuBalance(stWinList)
    local stRoundInfo = GRoundInfo
    local banker  = stRoundInfo:GetBanker()

    -- 每个胡开始 顺序算番
    for k=1, #self.m_stWinChairs do
        local nWin = self.m_stWinChairs[k]
        local env = LibFanCounter:CollectEnv(nWin)

        local stPlayerWin = GGameState:GetPlayerByChair(nWin)
        --如果是抢杠胡成功的话，设置胡类型，重置抢杠胡
        -- LOG_DEBUG("=========000111===LibGameLogicLangFang:DoHuBalance=====GetPlayerQiangGangStatus===:%d",stPlayerWin:GetPlayerQiangGangStatus())  
        if stPlayerWin and stPlayerWin:GetPlayerQiangGangStatus() ==QIANGGANG_STATUS_OK then
            env.byFlag = WIN_GANG
            -- LOG_DEBUG("=========000===LibGameLogicLangFang:DoHuBalance=====env.byFlag===:%d",env.byFlag)  
            stPlayerWin:SetPlayerIsQiangGangHu(false)
            GRoundInfo:SetIsQiangGang(false)
        end
        -- LOG_DEBUG("=========111===LibGameLogicLangFang:DoHuBalance=====env.byFlag===:%d",env.byFlag)   

        LibFanCounter:SetEnv(env)
        local stFanInfo = LibFanCounter:GetCount()
        -- 此处添加混杠胡
        if self:IsHunGangHu(nWin) then
            table.insert(stFanInfo, {szFanName = "混杠胡", byFanType = 50, byFanNumber = 10})
        end
        LOG_DEBUG("DoHuBalance...k:%d, p%d, stFanInfo:%s\n", k, nWin, vardump(stFanInfo))

        self.m_nHuInfo[nWin].nFanNum = 0
        self.m_nHuInfo[nWin].nWinChair = nWin
        self.m_nHuInfo[nWin].nFanDetailInfo = {}

        local nFanScore = 1
        for j=1, #stFanInfo do
            nFanScore = nFanScore * stFanInfo[j].byFanNumber

            if stFanInfo[j].byFanType == 13 then      -- 杠上花
                self.m_nHuInfo[nWin].nGangFlower = 1

            elseif stFanInfo[j].byFanType == 16 then  -- 天胡
                self.m_nHuInfo[nWin].nGodwin = 1

            elseif stFanInfo[j].byFanType == 17 then  -- 地胡
                self.m_nHuInfo[nWin].nGroundwin = 1

            elseif stFanInfo[j].byFanType == 18 then  -- 自摸
                self.m_nHuInfo[nWin].nSelfDraw = 1

            elseif stFanInfo[j].byFanType == 19 then  -- 点炮
                self.m_nHuInfo[nWin].nGun = 1

            elseif stFanInfo[j].byFanType == 20 then  -- 门清
                self.m_nHuInfo[nWin].nMenqing = 1

            elseif stFanInfo[j].byFanType == 37 then  -- 素胡
                self.m_nHuInfo[nWin].nSuHu = 1

            elseif stFanInfo[j].byFanType == 38 then  -- 捉五魁
                self.m_nHuInfo[nWin].nWukui = 1

            elseif stFanInfo[j].byFanType == 39 then  -- 一条龙
                self.m_nHuInfo[nWin].nDragon = 1

            elseif stFanInfo[j].byFanType == 40 then  -- 七小对
                self.m_nHuInfo[nWin].nQiDui = 1

            elseif stFanInfo[j].byFanType == 41 then  -- 豪华七对
                self.m_nHuInfo[nWin].nHQidui = 1

            elseif stFanInfo[j].byFanType == 42 then  -- 超豪华七对
                self.m_nHuInfo[nWin].nCHQidui = 1

            elseif stFanInfo[j].byFanType == 43 then  -- 至尊豪华七对
                self.m_nHuInfo[nWin].nZZQidui = 1

            elseif stFanInfo[j].byFanType == 44 then  -- 混吊
                self.m_nHuInfo[nWin].nHunDiao = 1

            elseif stFanInfo[j].byFanType == 45 then  -- 混吊混
                self.m_nHuInfo[nWin].nHunDHun = 1

            elseif stFanInfo[j].byFanType == 46 then  -- 碰碰胡
                self.m_nHuInfo[nWin].nPengPengHu = 1

            elseif stFanInfo[j].byFanType == 47 then  -- 清一色
                self.m_nHuInfo[nWin].nQinYise = 1

            elseif stFanInfo[j].byFanType == 48 then  -- 十三幺
                self.m_nHuInfo[nWin].nShiSanyao = 1

            elseif stFanInfo[j].byFanType == 49 then  -- 混悠
                self.m_nHuInfo[nWin].nHunYou = 1

            elseif stFanInfo[j].byFanType == 50 then  -- 混杠胡
                self.m_nHuInfo[nWin].nHunGangHu = 1
            end

            self.m_nHuInfo[nWin].nFanDetailInfo[#self.m_nHuInfo[nWin].nFanDetailInfo+1] = stFanInfo[j]
        end
        self.m_nHuInfo[nWin].nFanNum = nFanScore
    end
    LOG_DEBUG("=====Get self.m_nHuInfo===%s\n",vardump(self.m_nHuInfo))

    --计算基础胡分
    LOG_DEBUG("DoHuBalance -----------m_stWinChairs==%s\n", vardump(self.m_stWinChairs))
    LOG_DEBUG("DoHuBalance !!!!!!!!!!!!!stWinList==%s\n", vardump(stWinList))
    --牌局中，无论庄家输牌或者赢牌，与庄家结算，底分都是以庄家的为准

    -- 底分 庄2 闲1
    local nLianCount = stRoundInfo:GetLianZhuangCount()
    local nBaseScore = GGameCfg.RoomSetting.nBaseBet
    local nBaseBankeScore = 2 * nBaseScore * math.pow(2, nLianCount)
    for k=1, #stWinList do
        local stWinOne = stWinList[k]
        --自摸
        if stWinOne.winner == stWinOne.winWho then
            local nWinScore = self.m_nHuInfo[stWinOne.winner].nFanNum
            for i=1,PLAYER_NUMBER do
                if i ~= stWinOne.winner then
                    local nTempScore = nWinScore * nBaseScore
                    if stWinOne.winner ~= banker then
                        if i == banker then
                            nTempScore = nWinScore * nBaseBankeScore
                        end
                    else
                        nTempScore = nWinScore * nBaseBankeScore
                    end
                    self.m_nHuScore[stWinOne.winner] = self.m_nHuScore[stWinOne.winner] + nTempScore
                    self.m_nHuScore[i] = (-1) * nTempScore
                end
            end
        else
            --接炮者  三家输
            self.m_nHuInfo[stWinOne.winner].nGunWho = stWinOne.winWho
            local nWinScore = self.m_nHuInfo[stWinOne.winner].nFanNum
            for i=1,PLAYER_NUMBER do
                if i ~= stWinOne.winner then
                    local nTempScore = nWinScore * nBaseScore
                    if stWinOne.winner ~= banker then
                        if i == banker then
                            nTempScore = nWinScore * nBaseBankeScore
                        end
                    else 
                        nTempScore = nWinScore * nBaseBankeScore
                    end
                    self.m_nHuScore[stWinOne.winner] = self.m_nHuScore[stWinOne.winner] + nTempScore
                    self.m_nHuScore[i] = (-1) * nTempScore
                end
            end
        end
    end
    LOG_DEBUG("DoHuBalance...m_nHuScore:%s\n", vardump(self.m_nHuScore))
end

--检查胡的牌型stFindFanTypes = {[xx] = xx, [yy] = yy, ....}
function LibGameLogicLangFang:ChectFanCount(nChair, nCard, stFindFanTypes)
    local nTurn = LibTurnOrder:GetNextTurn(nChair) 
    local nFlag = WIN_GUN
    local nLast = nCard
    local env = LibFanCounter:CollectEnv(nChair, nTurn, nFlag, nLast)
    env.byChair = nChair - 1
    env.byTurn = LibTurnOrder:GetNextTurn(nChair) -1 -- 非自摸
    env.byFlag = WIN_SELFDRAW
    env.tLast  = nCard
    LibFanCounter:SetEnv(env)
    local stFanCount = LibFanCounter:GetCount()
    LOG_DEBUG("ChectFanCount:%s", vardump(stFanCount))

    local bFind = false
    if stFanCount and #stFanCount > 0 then
        local nCount = #stFanCount
        for k, v in ipairs(stFanCount) do
            if stFindFanTypes[v.byFanType] then
                bFind = true
                break
            end
        end
    end
    return bFind
end

function LibGameLogicLangFang:RewardThisGame()
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
    
    --荒局结算  算跟庄分
    if is_no_winner == true then
        for i=1,PLAYER_NUMBER do
            gang_score[i] = 0
            hu_score[i] = 0
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


return LibGameLogicLangFang

