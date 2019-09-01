local LibBase = import(".lib_base")
local PlayerBlockState = import("core.player_block_state")



local LibGameLogicFuzhou = class("LibGameLogicFuzhou", LibBase)

-- local stGangInfo = {
--     stAnGangCount = 0, 
--     stMingGangCount = 0,  
--     stPengGangCount = 0,  
--     stBeiAnGangCount = 0, 
--     stBeiMingGangCount = 0,  
--     stBeiPengGangCount = 0,
--     nGangScore = 0,  --杠分目前不用 只算番
-- }

-- local stFanInfo = {
-- 	nFanType = 0,
-- 	nFanCount = 0,
-- }

function LibGameLogicFuzhou:ctor()
    self.m_nGangInfo ={}
    for i=1,PLAYER_NUMBER do
        --杠数量
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
    --胡分
    self.m_nHuScore ={0,0,0,0}
    --胡详细信息
    self.m_nHuInfo = {}
    --杠番信息
    self.m_stGangFan = {0,0,0,0}
end

function LibGameLogicFuzhou:CreateInit()
    self.m_nGangInfo = {}
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
    end
    self.m_nHuScore ={0,0,0,0}
    self.m_nHuInfo = {}
    self.m_stGangFan = {0,0,0,0}
    return true
end

function LibGameLogicFuzhou:OnGameStart()
    self.m_nGangInfo = {}
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
    end
    self.m_nHuInfo = {}
    self.m_nHuScore ={0,0,0,0}
    self.m_stGangFan = {0,0,0,0}
    return true
end

--处理保存杠信息
function LibGameLogicFuzhou:ProcessOPQuadruplet(nGangValue,nChair,nTurn)
    LOG_DEBUG("=====Get ProcessOPQuadruplet=====%d %d %d=====",nGangValue,nChair,nTurn)
    local stGameState = GGameState
    local  stPlayer = stGameState:GetPlayerByChair(nChair)

    if GRoundInfo:GetIsQiangGang() ==true then   
        return
    end

    -- report
    -- 算分
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
                --stFanCount[i] = -2
                stFanCount[nChair] = 2 
                stBeiAnGangCount[i] =1

            elseif nGangValue == ACTION_QUADRUPLET_REVEALED then -- 刮风，自己摸到和自己碰过的刻子杠。一倍
                --stFanCount[i] = -1
                stFanCount[nChair] = 1
                stBeiPengGangCount[i] =1

            elseif nGangValue == ACTION_QUADRUPLET then -- 刮风，别人出牌给自己明杠。 一倍
                if i == nTurn then
                   --stFanCount[i] = -1
                   stFanCount[nChair] = 1
                   stBeiMingGangCount[i] =1
                end
            end
        end
        
        LOG_DEBUG("===ProcessOPQuadruplet===self.m_stGangFan[i]:%d\n", self.m_stGangFan[i])
    end

    for i=1,PLAYER_NUMBER do
        self.m_stGangFan[i] = self.m_stGangFan[i]  + stFanCount[i]
    end
    --LOG_DEBUG("=====Get ProcessOPQuadrupletFuzhou stFanCount:%s", vardump(stFanCount))
    for i=1,PLAYER_NUMBER do
        self.m_nGangInfo[i].nGangScore =self.m_nGangInfo[i].nGangScore+stFanCount[i]

        self.m_nGangInfo[i].stAnGangCount =self.m_nGangInfo[i].stAnGangCount+stAnGangCount[i]
        self.m_nGangInfo[i].stMingGangCount =self.m_nGangInfo[i].stMingGangCount+stMingGangCount[i]
        self.m_nGangInfo[i].stPengGangCount =self.m_nGangInfo[i].stPengGangCount+stPengGangCount[i]

        self.m_nGangInfo[i].stBeiAnGangCount =self.m_nGangInfo[i].stBeiAnGangCount+stBeiAnGangCount[i]
        self.m_nGangInfo[i].stBeiMingGangCount =self.m_nGangInfo[i].stBeiMingGangCount+stBeiMingGangCount[i]
        self.m_nGangInfo[i].stBeiPengGangCount =self.m_nGangInfo[i].stBeiPengGangCount+stBeiPengGangCount[i]
    end
    --LOG_DEBUG("=====Get ProcessOPQuadruplet self.m_nGangInfo:%s", vardump(self.m_nGangInfo))
end

-- 处理胡
function LibGameLogicFuzhou:ProcessOPWin(stWinData)
    LOG_DEBUG("LibGameLogicFuzhou:ProcessOPWin...stWinData:%s", vardump(stWinData))
    local nWinner = stWinData[1].winner
   -- LOG_DEBUG("LibGameLogicFuzhou:ProcessOPWin...nWinner:%d", nWinner)
    local stPlayerWin =GGameState:GetPlayerByChair(nWinner)
    if stPlayerWin:GetPlayerQiangGangStatus() == QIANGGANG_STATUS_OK then
        stPlayerWin:SetPlayerIsQiangGangHu(false)
        GRoundInfo:SetIsQiangGang(false)
    end
    --处理胡
    local winType = ""
    local bGoldHu = GRoundInfo:IsRobGolgHu()
    local bQiangGangHu = GRoundInfo:IsQiangGangHu()
    if GRoundInfo:GetWhoIsOnTurn() == nWinner 
        or bGoldHu then
        winType = "selfdraw"        --"自摸"
        if bGoldHu then
            winType = "robgoldwin"  --抢金胡
        end
    else
        winType = "gunwin"          --"放枪"
        if bQiangGangHu then
            winType = "robgangwin"  --抢杠胡
        end
        
    end
    stWinData[1].winType =winType
    CSMessage.NotifyPlayerWin(stWinData)
    LibGameLogic:DoProcessOPWin(stWinData)

    --番计算
    self:DoHuBalance(stWinData)
end

--番计算
function LibGameLogicFuzhou:DoHuBalance(stWinData)
    --算番
    local stRoundInfo = GRoundInfo
    self.m_stWinChairs = {}
    self.m_stFanInfo = {}
    local nBaseBet = GGameCfg.RoomSetting.nBaseBet

    --金牌、花数、连庄次数  是否计算三金倒
    local nLaiZiCount = 0
    local nFlowerCount = 0
    local nLianZhuangCount = 0
    local bIsSanJinDao = true

    --放炮时是否每家都要扣分，开房可选
    local bJiaJiaYou = GGameCfg.GameSetting.bSupportGunAll 
    for i=1,#stWinData do
        local nChair = stWinData[i].winner
        local nBanker = GRoundInfo:GetBanker()
        if nChair > 0 and nChair <= PLAYER_NUMBER then
            local stPlayerWin =GGameState:GetPlayerByChair(nChair)
            nLaiZiCount = stPlayerWin:GetGoldCardNums()
            nFlowerCount = stPlayerWin:GetFlowerNums()
            if nBanker == nChair then
                nLianZhuangCount = GRoundInfo:GetLianZhuangCount()
            end
            --点炮胡和抢金胡不支持三金倒
            LOG_DEBUG("LibGameLogicFuzhou:DoHuBalance....IsGunHu:%s, IsQiangGangHu:%s, IsRobGolgHu:%s", tostring(GRoundInfo:IsGunHu()), tostring(GRoundInfo:IsQiangGangHu()), tostring(GRoundInfo:IsRobGolgHu()))
            if GRoundInfo:IsGunHu() 
                or GRoundInfo:IsQiangGangHu()
                or GRoundInfo:IsRobGolgHu() then
                bIsSanJinDao = false
            elseif GRoundInfo:IsSelfDrawHu() then
                --自摸胡：判断是否有三金倒
                local nGoldNums = stPlayerWin:GetGoldCardNums()
                if nGoldNums < 3 then
                    bIsSanJinDao = false
                end
            end
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

        local stFanInfo = LibFanCounter:GetCount()

        --点炮胡 不支持闲金 c++做
        --[[ 
        LOG_DEBUG("======LibGameLogicFuzhou:DoHuBalance1111....#stFanInfo:%d", #stFanInfo)
        local bGunHu = false
        if GRoundInfo:IsGunHu() or GRoundInfo:IsQiangGangHu() then
            bGunHu = true
        end
        local stDelete = {}
        for i=1, #stFanInfo do
            if bGunHu and stFanInfo[i].byFanType == 38 then
                table.insert(stDelete, i)
            end
        end
        for _, index in ipairs(stDelete) do
            table.remove(stFanInfo, index)
        end
        --]]
        --LOG_DEBUG("======LibGameLogicFuzhou:DoHuBalance2222....#stFanInfo:%d, ", #stFanInfo)
        LOG_DEBUG("=====Get DoHuBalance stFanInfo:%s", vardump(stFanInfo))
        -- self.m_nHuScore[k] =stScore
        -- LOG_DEBUG("=====Get DoHuBalance k:%d,self.m_nHuScore[k]===%s", k,vardump(self.m_nHuScore[k]))

        self.m_nHuInfo.nWinChair =nWin
        self.m_nHuInfo.nFanNum =0
        self.m_nHuInfo.nFanDetailInfo =stFanInfo
        for j=1, #stFanInfo do

            self.m_nHuInfo.nFanNum = self.m_nHuInfo.nFanNum + stFanInfo[j].byFanNumber

            --抢金
            if stFanInfo[j].byFanType == 31 then
                self.m_nHuInfo.nQiangJin =1

            --无花无杠
            elseif stFanInfo[j].byFanType == 32 then
                self.m_nHuInfo.nWuHuaWuGang =1
            
            --一张花
            elseif stFanInfo[j].byFanType == 33 then
                self.m_nHuInfo.nOneFlower =1
            
            --金雀
            elseif stFanInfo[j].byFanType == 34 then
                self.m_nHuInfo.nGoldBird =1
            
            --金龙
            elseif stFanInfo[j].byFanType == 35 then
                self.m_nHuInfo.nGoldDragon =1
            
            --半清一色
            elseif stFanInfo[j].byFanType == 36 then
                self.m_nHuInfo.nHalfQYS =1
            
            --清一色
            elseif stFanInfo[j].byFanType == 37 then
                self.m_nHuInfo.nQYS  =1
           
            --闲金
            elseif stFanInfo[j].byFanType == 38 then
                self.m_nHuInfo.nXianJin  =1
            end
        end
    end
    -- 放胡 = 花+杠+连庄数+金+特殊胡牌的奖励
	-- 自摸 =（花+杠+连庄数+金）*2 +特殊胡牌的奖励

	-- 三金倒加入faninfo
	local nSanJinDaoInfo ={}
	nSanJinDaoInfo.byFanType =39
	nSanJinDaoInfo.byFanNumber =50
	nSanJinDaoInfo.byCount =1

	if bIsSanJinDao then
		self.m_nHuInfo.nSanJinDao = 1
		self.m_nHuInfo.nFanDetailInfo[#self.m_nHuInfo.nFanDetailInfo+1] =nSanJinDaoInfo
		self.m_nHuInfo.nFanNum = self.m_nHuInfo.nFanNum +50
	end

    --福州只有一个人胡
    local stWinOne = stWinData[1]
    --LOG_DEBUG("===1===stWinOne.winner:%d\n", stWinOne.winner)
    --LOG_DEBUG("===1===stWinOne.winWho:%d\n", stWinOne.winWho)
    --LOG_DEBUG("=====Get self.m_nHuScore===%s",vardump(self.m_nHuScore))
	if stWinOne.winner == stWinOne.winWho then
		for i=1,PLAYER_NUMBER do
		    if i ~= stWinOne.winner then
                self.m_nHuScore[stWinOne.winner] = self.m_nHuScore[stWinOne.winner]+nBaseBet*((nLaiZiCount+nFlowerCount+nLianZhuangCount+self.m_stGangFan[stWinOne.winner])*2+self.m_nHuInfo.nFanNum)
		    	self.m_nHuScore[i] = -nBaseBet*((nLaiZiCount+nFlowerCount+nLianZhuangCount+self.m_stGangFan[stWinOne.winner])*2+self.m_nHuInfo.nFanNum)

		    end
            --LOG_DEBUG("===1===nLaiZiCount:%d\n", nLaiZiCount)
           -- LOG_DEBUG("===1===nFlowerCount:%d\n", nFlowerCount)
            --LOG_DEBUG("===1===nLianZhuangCount:%d\n", nLianZhuangCount)
            LOG_DEBUG("===1===self.m_stGangFan[i]:%d\n", self.m_stGangFan[i])
           -- LOG_DEBUG("===1===self.m_nHuInfo.nFanNum:%d\n", self.m_nHuInfo.nFanNum)
		end
	else
        --接炮者
        self.m_nHuInfo.nGunWho =stWinOne.winWho 
		for i=1,PLAYER_NUMBER do

			if bJiaJiaYou ==true then
				if i ~= stWinOne.winner then
					self.m_nHuScore[stWinOne.winner] = self.m_nHuScore[stWinOne.winner]+nBaseBet*(nLaiZiCount+nFlowerCount+nLianZhuangCount+self.m_stGangFan[stWinOne.winner]+self.m_nHuInfo.nFanNum)
		    		self.m_nHuScore[i] = -nBaseBet*(nLaiZiCount+nFlowerCount+nLianZhuangCount+self.m_stGangFan[stWinOne.winner]+self.m_nHuInfo.nFanNum)
		    	end
			else
				if i == stWinOne.winWho then
					self.m_nHuScore[stWinOne.winner] = nBaseBet*(nLaiZiCount+nFlowerCount+nLianZhuangCount+self.m_stGangFan[stWinOne.winner]+self.m_nHuInfo.nFanNum)
		    		self.m_nHuScore[i] = -nBaseBet*(nLaiZiCount+nFlowerCount+nLianZhuangCount+self.m_stGangFan[stWinOne.winner]+self.m_nHuInfo.nFanNum)
		    	end
			end
			--LOG_DEBUG("====2==nLaiZiCount:%d\n", nLaiZiCount)
		    --LOG_DEBUG("===2===nFlowerCount:%d\n", nFlowerCount)
		   -- LOG_DEBUG("====2==nLianZhuangCount:%d\n", nLianZhuangCount)
		   LOG_DEBUG("====2==self.m_stGangFan[i]:%d\n", self.m_stGangFan[i])
		   -- LOG_DEBUG("====2==self.m_nHuInfo.nFanNum:%d\n", self.m_nHuInfo.nFanNum)
		end
	end
	LOG_DEBUG("====111=Get self.m_nHuScore===%s",vardump(self.m_nHuScore))
	LOG_DEBUG("=====Get self.m_nHuInfo===%s",vardump(self.m_nHuInfo))
end

--自摸胡这张牌 可胡几番
function LibGameLogicFuzhou:GetFanCount(nChair, nCard)
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

--抢金胡：手牌+金牌
function LibGameLogicFuzhou:GetFanCount_RobGold(nChair, nCard)
    local nTurn = LibTurnOrder:GetNextTurn(nChair) 
    local nFlag = WIN_ROBGOLG
    local nLast = nCard
    local env = LibFanCounter:CollectEnv(nChair, nTurn, nFlag, nLast)
    env.byChair = nChair - 1    --C++ 从0开始 lua从1开始
    env.byTurn = LibTurnOrder:GetNextTurn(nChair) -1 -- 非自摸
    env.byFlag = WIN_ROBGOLG
    env.tLast  = nCard
    LibFanCounter:SetEnv(env)
    local stFanCount = LibFanCounter:GetCount()

    -- LOG_DEBUG("GetFanCount_RobGold11111...stFanCount:%s", vardump(stFanCount))
    --过滤掉三金倒 C++没有主动过滤掉了

    local nFanNum = 0
    for i=1,#stFanCount do
        nFanNum = nFanNum + stFanCount[i].byFanNumber
    end
    LOG_DEBUG("GetFanCount_RobGold22222...nFanNum:%d, stFanCount:%s", nFanNum, vardump(stFanCount))

    return nFanNum
end

--放炮胡：手牌+炮牌
function LibGameLogicFuzhou:GetFanCount_Gun(nChair, nCard)
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

    LOG_DEBUG("GetFanCount_RobGold11111...stFanCount:%s", vardump(stFanCount))
    --过滤掉三金倒 C++没有主动过滤掉了

    local nFanNum = 0
    for i=1,#stFanCount do
        nFanNum = nFanNum + stFanCount[i].byFanNumber
    end
    LOG_DEBUG("GetFanCount_RobGold22222...nFanNum:%d, stFanCount:%s", nFanNum, vardump(stFanCount))

    return nFanNum
end

--检查胡的牌型
function LibGameLogicFuzhou:ChectFanCount(nChair, nCard, byFanType)
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

function LibGameLogicFuzhou:RewardThisGame()
    --荒牌，不处理
    local gang_score = {}
    local hu_score = {}      -- 几个人的得分
    local win_type = {}
    local set_cards = {}
    local cards = {}
    local win_card = {}

    local is_no_winner = true
    for i=1,PLAYER_NUMBER do
        --目前不需要计算杠分
        gang_score[i] = 0--self.m_nGangInfo[i].nGangScore
        hu_score[i] = 0
        win_type[i] = ""
        local stPlayer = GGameState:GetPlayerByChair(i)
        set_cards[i] = stPlayer:GetPlayerCardSet():ToArray()
        cards[i] = stPlayer:GetPlayerCardGroup():ToArray()

        if stPlayer:IsWin() then
            is_no_winner = false
        end
        hu_score[i] =self.m_nHuScore[i]
        LOG_DEBUG("=====Get DoHuBalance i:%d,hu_score[i]===%s", i,hu_score[i])

    end
    if is_no_winner == true then
        for i=1,PLAYER_NUMBER do
            gang_score[i] =0
            hu_score[i] =0
        end
    end

    local stScoreRecord = LibGameLogic:GetScoreRecord()
    local nLaiZiCount =0
    local nGunWho =0
    nGunWho =self.m_nHuInfo.nGunWho
    LOG_DEBUG("WHEN rec==================,  self.m_nHuInfo=%s",vardump(self.m_nHuInfo))
    for i=1, PLAYER_NUMBER do
        local stPlayer = GGameState:GetPlayerByChair(i)
        local uinfo = stPlayer:GetUserInfo()
        local rec ={}
        local wininfo ={}
        local nJiePao =0
        if nGunWho ==i then
            nJiePao =1
        end
        if stPlayer:IsWin() then
            --抢金算自摸
            local bGoldHu = GRoundInfo:IsRobGolgHu()
            local bQiangGangHu = GRoundInfo:IsQiangGangHu()
            if GRoundInfo:GetWhoIsOnTurn() == i 
                or bGoldHu then
                win_type[i] = "selfdraw"        --"自摸"
                if bGoldHu then
                    win_type[i] = "robgoldwin"  --抢金胡
                end
            else
                win_type[i] = "gunwin"          --"放枪"
                if bQiangGangHu then
                    win_type[i] = "robgangwin"  --抢杠胡
                end
                
            end
            win_card[i] = stPlayer:GetPlayerWinCards()[1]
            wininfo = self.m_nHuInfo
            nLaiZiCount = stPlayer:GetGoldCardNums()
        end
        local nFlowerFan = stPlayer:GetFlowerNums()
        local nGangFan = self.m_stGangFan[i]
        local nLianZhuangFan = 0
        local nBanker = GRoundInfo:GetBanker()
        if nBanker == i then
            nLianZhuangFan = GRoundInfo:GetLianZhuangCount()
        end

        rec = {
            _chair          = "p" ..i,
            _uid            = uinfo._uid,
            flowerFan       = nFlowerFan,
            gangFan         = nGangFan,
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
        }

        LOG_DEBUG("WHEN rec==================,  rec=%s",vardump(rec))
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


return LibGameLogicFuzhou

