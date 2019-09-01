local LibBase = import(".lib_base")
local PlayerBlockState = import("core.player_block_state")
local LibGameLogicTangShan = class("LibGameLogicTangShan", LibBase)

local stGangInfo= {
    nGangScore = 0,
    stAnGangCount = 0, 
    stMingGangCount = 0,  
    stPengGangCount = 0,  
    stBeiAnGangCount = 0, 
    stBeiMingGangCount = 0,  
    stBeiPengGangCount = 0,
}

local stHuInfo= {
    nFanDetailInfo = {},
    nWinChair = 0,
    nGunWho = 0,
    nFanNum = 0,
    nGangFlower = 0,
    nGangWin = 0,      -- 杠上炮
    nQiangGangHu = 0,  -- 抢杠胡
    nGodwin = 0,
    nGroundwin = 0,
    nSelfDraw = 0,
    nGun = 0,
    nMenqing = 0,
    nBian = 0,  
    nKa = 0, 
    nDiao = 0,
    nHaidihu = 0,      -- 海底捞月
    nSuHu = 0,
    nWukui = 0,
    nDragon = 0,
    nQiDui = 0,
    nHQidui = 0,
    nCHQidui = 0,
    nPengPengHu = 0,
    nQinYise = 0,
    nBenHunLong = 0,
    nHaiDiPao = 0,
    nTianTing = 0,
    nDiTing = 0,
    nXiaoSa = 0,
}

function LibGameLogicTangShan:ResetWinDatas()
    self.m_nHuInfo = {}
    self.m_nGangInfo = {}
    for i=1, PLAYER_NUMBER do
        self.m_nHuInfo[i] = clone(stHuInfo)
        self.m_nGangInfo[i] = clone(stGangInfo)
    end
    self.m_stWinChairs = {}
    self.m_nHuScore = {0,0,0,0}
    self.m_nFollowScore = {0,0,0,0}
end

function LibGameLogicTangShan:ctor()
    self:ResetWinDatas()
end

function LibGameLogicTangShan:CreateInit()
    self:ResetWinDatas()
    return true
end

function LibGameLogicTangShan:OnGameStart()
    self:ResetWinDatas()
    return true
end

function LibGameLogicTangShan:ProcessOPQuadruplet(nGangValue, nChair, nTurn)
    LOG_DEBUG("=====Get ProcessOPQuadrupletTangShan=====%d %d %d=====", nGangValue, nChair, nTurn)
    if GRoundInfo:GetIsQiangGang() == true then
        return
    end
    
    -- report 算分
    local stFanCount = {0, 0, 0, 0}
    local stAnGangCount = {0, 0, 0, 0}
    local stPengGangCount = {0, 0, 0, 0}
    local stMingGangCount = {0, 0, 0, 0}
    local stBeiAnGangCount = {0, 0, 0, 0}
    local stBeiPengGangCount = {0, 0, 0, 0}
    local stBeiMingGangCount = {0, 0, 0, 0}

    if nGangValue == ACTION_QUADRUPLET_CONCEALED then
        stAnGangCount[nChair] = 1    -- 暗杠
    elseif nGangValue == ACTION_QUADRUPLET_REVEALED then
        stPengGangCount[nChair] = 1  -- 碰杠
    elseif nGangValue == ACTION_QUADRUPLET then
        stMingGangCount[nChair] = 1  -- 直杠
    end
    
    for i=1, PLAYER_NUMBER do
        if i ~= nChair then
            if nGangValue == ACTION_QUADRUPLET_CONCEALED then     -- 暗杠 1对3结算
                stFanCount[i] = -2
                stFanCount[nChair] = stFanCount[nChair] + 2
                stBeiAnGangCount[i] = 1
            elseif nGangValue == ACTION_QUADRUPLET_REVEALED then  -- 碰杠 1对3结算
                stFanCount[i] = -1
                stFanCount[nChair] = stFanCount[nChair] + 1
                stBeiPengGangCount[i] = 1
            elseif nGangValue == ACTION_QUADRUPLET then           -- 直杠 1对3结算
                stFanCount[i] = -1
                stFanCount[nChair] = stFanCount[nChair] + 1
                stBeiMingGangCount[i] = 1
            end
        end
    end
    LOG_DEBUG("=====Get ProcessOPQuadrupletTangShan stFanCount:%s", vardump(stFanCount))
    
    for i=1, PLAYER_NUMBER do
        self.m_nGangInfo[i].nGangScore = self.m_nGangInfo[i].nGangScore + stFanCount[i]

        self.m_nGangInfo[i].stAnGangCount = self.m_nGangInfo[i].stAnGangCount + stAnGangCount[i]
        self.m_nGangInfo[i].stMingGangCount = self.m_nGangInfo[i].stMingGangCount + stMingGangCount[i]
        self.m_nGangInfo[i].stPengGangCount = self.m_nGangInfo[i].stPengGangCount + stPengGangCount[i]

        self.m_nGangInfo[i].stBeiAnGangCount = self.m_nGangInfo[i].stBeiAnGangCount + stBeiAnGangCount[i]
        self.m_nGangInfo[i].stBeiMingGangCount = self.m_nGangInfo[i].stBeiMingGangCount + stBeiMingGangCount[i]
        self.m_nGangInfo[i].stBeiPengGangCount = self.m_nGangInfo[i].stBeiPengGangCount + stBeiPengGangCount[i]
    end
    LOG_DEBUG("=====Get ProcessOPQuadrupletTangShan self.m_nGangInfo:%s", vardump(self.m_nGangInfo))
end

-- 处理唐山胡 不支出一炮多响
function LibGameLogicTangShan:ProcessOPWin(nCard)
    local nWinCard = nCard

    -- 这里要支持一炮多响，发现一个人胡，则把查找出所以可以胡的人
    local stWinList = {}
    local nOnTurn = GRoundInfo:GetWhoIsOnTurn()
    local nChair = nOnTurn
    for x=1, PLAYER_NUMBER do
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
    -- 算番
    self:DoHuBalance(stWinList)
    -- 算跟庄
    self:DoFollowBanker()
end

-- 跟庄分
function LibGameLogicTangShan:DoFollowBanker()
    local nBanker = GRoundInfo:GetBanker()
    local nCount = GRoundInfo:GetFollowBankerCount()
    if nCount > 0 then
        for i=1, PLAYER_NUMBER do
            if i ~= nBanker then
                self.m_nFollowScore[i] = nCount * 2
                self.m_nFollowScore[nBanker] = self.m_nFollowScore[nBanker] - (nCount * 2)
            end
        end
    end
    LOG_DEBUG("LibGameLogicTangShan:DoFollowBanker %s", vardump(self.m_nFollowScore))
end

-- 算番
function LibGameLogicTangShan:DoHuBalance(stWinList)
    local banker = GRoundInfo:GetBanker()

    -- 每个胡开始 顺序算番
    for k=1, #self.m_stWinChairs do
        local nWin = self.m_stWinChairs[k]
        local env = LibFanCounter:CollectEnv(nWin)

        local stPlayerWin = GGameState:GetPlayerByChair(nWin)
        -- 如果是抢杠胡成功的话，设置胡类型，重置抢杠胡
        if stPlayerWin and stPlayerWin:GetPlayerQiangGangStatus() == QIANGGANG_STATUS_OK then
            env.byFlag = WIN_GANG 
            stPlayerWin:SetPlayerIsQiangGangHu(false)
            GRoundInfo:SetIsQiangGang(false)
        end

        LibFanCounter:SetEnv(env)
        local stFanInfo = LibFanCounter:GetCount()
        
        LOG_DEBUG("DoHuBalance...k:%d, p%d, stFanInfo:%s\n", k, nWin, vardump(stFanInfo))

        self.m_nHuInfo[nWin].nFanNum = 0
        self.m_nHuInfo[nWin].nWinChair = nWin
        self.m_nHuInfo[nWin].nFanDetailInfo = clone(stFanInfo)

        for j=1, #stFanInfo do

            if stFanInfo[j].byFanType == 13 then      -- 杠上花
                self.m_nHuInfo[nWin].nGangFlower = 1
                
            elseif stFanInfo[j].byFanType == 14 then  -- 杠上炮
                self.m_nHuInfo[nWin].nGangWin = 1
                
            elseif stFanInfo[j].byFanType == 15 then  -- 抢杠胡
                self.m_nHuInfo[nWin].nQiangGangHu = 1
                
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
                
            elseif stFanInfo[j].byFanType == 21 then  -- 边
                self.m_nHuInfo[nWin].nBian = 1
                
            elseif stFanInfo[j].byFanType == 22 then  -- 卡
                self.m_nHuInfo[nWin].nKa = 1
                
            elseif stFanInfo[j].byFanType == 23 then  -- 吊
                self.m_nHuInfo[nWin].nDiao = 1
                
            elseif stFanInfo[j].byFanType == 26 then  -- 海底捞月
                self.m_nHuInfo[nWin].nHaidihu = 1
                
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

            elseif stFanInfo[j].byFanType == 46 then  -- 碰碰胡
                self.m_nHuInfo[nWin].nPengPengHu = 1

            elseif stFanInfo[j].byFanType == 47 then  -- 清一色
                self.m_nHuInfo[nWin].nQinYise = 1

            elseif stFanInfo[j].byFanType == 51 then  -- 本混龙
                self.m_nHuInfo[nWin].nBenHunLong = 1
                
            elseif stFanInfo[j].byFanType == 52 then  -- 海底炮
                self.m_nHuInfo[nWin].nHaiDiPao = 1
                
            elseif stFanInfo[j].byFanType == 53 then  -- 天听
                self.m_nHuInfo[nWin].nTianTing = 1
                
            elseif stFanInfo[j].byFanType == 54 then  -- 地听
                self.m_nHuInfo[nWin].nDiTing = 1
                
            elseif stFanInfo[j].byFanType == 55 then  -- 潇洒
                self.m_nHuInfo[nWin].nXiaoSa = 1  
            end
            
            self.m_nHuInfo[nWin].nFanNum = self.m_nHuInfo[nWin].nFanNum + stFanInfo[j].byFanNumber
        end
    end
    LOG_DEBUG("=====Get self.m_nHuInfo===%s\n", vardump(self.m_nHuInfo))
    
    LOG_DEBUG("DoHuBalance  stWinList = %s @@@ m_stWinChairs = %s", vardump(stWinList), vardump(self.m_stWinChairs))
    
    local nLianCount = GRoundInfo:GetLianZhuangCount()
    -- 计算基础胡分 庄底分2 闲底分0
    for k=1, #stWinList do
        local stWinOne = stWinList[k]
        -- 自摸
        if stWinOne.winner == stWinOne.winWho then
            local nWinScore = self.m_nHuInfo[stWinOne.winner].nFanNum
            for i=1, PLAYER_NUMBER do
                if i ~= stWinOne.winner then
                    local nTempScore = nWinScore
                    if stWinOne.winner == banker or i == banker then   -- 庄自摸 所有闲+2  闲自摸 庄+2
                        nTempScore = nWinScore + 2 + nLianCount
                    end
                    self.m_nHuScore[stWinOne.winner] = self.m_nHuScore[stWinOne.winner] + nTempScore
                    self.m_nHuScore[i] = (-1) * nTempScore
                end
            end    
        else
            -- 点炮 包三家
            self.m_nHuInfo[stWinOne.winner].nGunWho = stWinOne.winWho
            local nWinScore = self.m_nHuInfo[stWinOne.winner].nFanNum
            local nSumWinScore = nWinScore * (PLAYER_NUMBER - 1) + 2  
            for i=1, PLAYER_NUMBER do
                if i ~= stWinOne.winner then
                    local nTempScore = nWinScore
                    if stWinOne.winner == banker or i == banker then
                        nTempScore = nWinScore + 2 + nLianCount
                    end
                    self.m_nHuScore[stWinOne.winner] = self.m_nHuScore[stWinOne.winner] + nTempScore
                    self.m_nHuScore[stWinOne.winWho] = self.m_nHuScore[stWinOne.winWho] - nTempScore
                end
            end
        end
        
    end
    LOG_DEBUG("DoHuBalance...m_nHuScore:%s\n", vardump(self.m_nHuScore))
end

function LibGameLogicTangShan:CHD_GetFanCount(nChair, nCard)
    local nTurn = LibTurnOrder:GetNextTurn(nChair) 
    local env = LibFanCounter:CollectEnv(nChair, nTurn, WIN_GUN, nCard)
    env.byChair = nChair - 1
    env.byTurn = LibTurnOrder:GetNextTurn(nChair) - 1    -- 非自摸
    env.byFlag = WIN_GUN
    env.tLast  = nCard
    
    LibFanCounter:SetEnv(env)
    local stFanCount = LibFanCounter:GetCount()
    print("stFanCount:%s", vardump(stFanCount))
    
    local nFanNum = 0
    for i=1, #stFanCount do
        nFanNum = nFanNum + stFanCount[i].byFanNumber
    end
    
    return nFanNum
end

function LibGameLogicTangShan:RewardThisGame()
    local hu_score = {}     -- 胡分
    local gang_score = {}   -- 杠分
    local follow_score = {} -- 跟庄分
    local wininfo = {}
    local win_type = {}
    local cards = {}
    local win_card = {}
    local set_cards = {}
    local is_no_winner = true
    local nGunWho = 0

    --计算杠分
    for i=1, PLAYER_NUMBER do
        local stPlayer = GGameState:GetPlayerByChair(i)
        if stPlayer then
            hu_score[i] = self.m_nHuScore[i]
            gang_score[i] = self.m_nGangInfo[i].nGangScore
            follow_score[i] = self.m_nFollowScore[i]

            win_type[i] = ""
            set_cards[i] = stPlayer:GetPlayerCardSet():ToArray()
            cards[i] = stPlayer:GetPlayerCardGroup():ToArray()

            if stPlayer:IsWin() then
                is_no_winner = false
                nGunWho = self.m_nHuInfo[i].nGunWho
                
                if GRoundInfo:GetWhoIsOnTurn() == i then
                    win_type[i] = "selfdraw"   -- 自摸
                else
                    win_type[i] = "gunwin"     -- 放枪
                end
                wininfo[i] = self.m_nHuInfo[i]
                win_card[i] = stPlayer:GetPlayerWinCards()[1]
            end
        end
    end
    
    --荒局结算 算跟庄分
    if is_no_winner == true then
        self:DoFollowBanker()
        GRoundInfo:SetLiuJuState(true)    -- 记录当前局是否流局 下一局使用
        for i=1,PLAYER_NUMBER do
            gang_score[i] = 0
            hu_score[i] = 0
        end
    else
        GRoundInfo:SetLiuJuState(false)   -- 记录当前局是否流局 下一局使用
    end

    --胡牌结算
    local stScoreRecord = LibGameLogic:GetScoreRecord()
    LOG_DEBUG("WHEN rec==================,  self.m_nHuInfo=%s", vardump(self.m_nHuInfo))
    for i=1, PLAYER_NUMBER do
        local stPlayer = GGameState:GetPlayerByChair(i)
        if stPlayer then
            local uinfo = stPlayer:GetUserInfo()
            local nLianCount = GRoundInfo:GetLianZhuangCount()
            
            local nJiePao = 0
            if nGunWho == i then
                nJiePao = 1
            end
            LOG_DEBUG("p%d, nGunWho:%d, nJiePao:%d", i, nGunWho, nJiePao)
            
            local rec = {}
            rec = {
                _chair       = "p" ..i,
                _uid         = uinfo._uid,
                an_gang      = self.m_nGangInfo[i].stAnGangCount,
                ming_gang    = self.m_nGangInfo[i].stMingGangCount,
                peng_gang    = self.m_nGangInfo[i].stPengGangCount,
                beian_gang   = self.m_nGangInfo[i].stBeiAnGangCount,
                beiming_gang = self.m_nGangInfo[i].stBeiMingGangCount,
                beipeng_gang = self.m_nGangInfo[i].stBeiPengGangCount,

                hu_score     = hu_score[i],
                gang_score   = gang_score[i],
                follow_score = follow_score[i],
                all_score    = gang_score[i] + hu_score[i] + follow_score[i],

                nLianCount   = nLianCount,
                combineTile  = set_cards[i],
                discardTile  = stPlayer:GetPlayerGiveGroup():ToArray(),
                cards        = cards[i],
                win_card     = {win_card[i]},
                win_type     = win_type[i],
                win_info     = wininfo[i],
                nJiePao      = nJiePao,
            }

            LOG_DEBUG("WHEN rec==================, rec=%s", vardump(rec))
            stScoreRecord:SetRecordByChair(i, rec)

            --test 更新金币积分
            local nScore = gang_score[i] + hu_score[i] + follow_score[i]
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


return LibGameLogicTangShan

