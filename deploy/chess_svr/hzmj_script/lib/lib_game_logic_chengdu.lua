local LibBase = import(".lib_base")
local PlayerBlockState = import("core.player_block_state")


function BalanceTypeToScoreType(nBalanceType)
    if nBalanceType == BALANCE_TYPE_QUADRUPLET_REVEALED then
        return SCORE_RECORD_TYPE_WIND
    elseif nBalanceType == BALANCE_TYPE_QUADRUPLET then
        return SCORE_RECORD_TYPE_BUWIND
    elseif nBalanceType == BALANCE_TYPE_QUADRUPLET_CONCEALED then
        return SCORE_RECORD_TYPE_RAIN
    elseif nBalanceType == BALANCE_TYPE_RETURN_QUADRUPLET then
         return SCORE_RECORD_TYPE_TAX  -- 退税
    elseif nBalanceType == BALANCE_TYPE_WIN then
        return SCORE_RECORD_TYPE_GUN 
    elseif nBalanceType == BALANCE_TYPE_UNTING_TO_TING then
        return SCORE_RECORD_TYPE_DAJIAO
    elseif nBalanceType == BALANCE_TYPE_HUAZHU then
        return SCORE_RECORD_TYPE_HUAZHU
    elseif nBalanceType == BALANCE_TYPE_ADD_DI then
        return SCORE_RECORD_TYPE_ADD_DI -- 自摸加底
    end
    LOG_ERROR("BalanceTypeToScoreType Error nBalanceType:%d", nBalanceType)
    return 0
end



local LibGameLogicChengdu = class("LibGameLogicChengdu", LibBase)

function LibGameLogicChengdu:ctor()
    self.m_stBalanceList = {}
    self.m_nBalanceIndex = 0
    self.m_stCHDHuNum = 0
end
function LibGameLogicChengdu:CreateInit()
   self.m_stCHDHu = {}
   self.m_stFanCountSum = {0, 0, 0, 0}
   self.m_stCHDHuNum = 0
   return true
end
function LibGameLogicChengdu:OnGameStart()
    self.m_stCHDHu = {}
    self.m_stCHDHuNum = 0
    self.m_stFanCountSum = {0, 0, 0, 0}
    self:ClearBalance()
     return true
end


function LibGameLogicChengdu:ClearBalance()
    self.m_stBalanceList = {}
    self.m_nBalanceIndex = 0
end

function LibGameLogicChengdu:FanToMul(nFan)
    if nFan < 0 then
        nFan = -1 * nFan
        val = 1
        for i=1,nFan - 1 do
            val = val * 2
        end
        return -1* val
    elseif nFan > 0 then
        val = 1
        for i=1,nFan - 1 do
            val = val * 2
        end
        return val
    end
    return 0
end
function  LibGameLogicChengdu:AddOneTaxBalance(nWinner, nLosser, nFan, nScore)
    local nType = BALANCE_TYPE_RETURN_QUADRUPLET
    local balance = {}
    balance.nType = nType
    balance.name = GameUtil.GetBalanceName(nType)
    balance.nWinner = nWinner
    balance.nLosser = nLosser
    balance.nFan = nFan
    balance.stFanInfo =  {}
    balance.nScore = nScore

    local index = self.m_nBalanceIndex
    self.m_stBalanceList[index] = self.m_stBalanceList[index] or {}
    local len = # self.m_stBalanceList[index]
    self.m_stBalanceList[index][len+1] = balance
end
-- 结算一次番
-- 参数 类型   BALANCE_TYPE
-- 参数 番数 {3, -1, -1, -1}
-- 包括 刮风下雨 和
-- 血流模式下 如果玩家金币扣到0  将触发 认输流程
-- 扣费 最多扣到0 不做负数
function LibGameLogicChengdu:AddOneBalance(nType, nWinner, nLosser, nFan, bTriggerAddMoney, stFanInfo)
    if nFan < 0 then
        LOG_ERROR("Error fan", nFan);
        return 
    end
    bTriggerAddMoney = bTriggerAddMoney or false
    stFanInfo = stFanInfo or {}

    local balance = {}
    balance.nFan = nFan
    balance.nType = nType
    balance.name = GameUtil.GetBalanceName(nType)
    balance.nWinner = nWinner
    balance.nLosser = nLosser
    --0番的情况
    if nFan ==1001 then
        if nType == BALANCE_TYPE_WIN then
            balance.nFan = 0
        else
            balance.nFan = nFan
        end
    end
    if nFan == 1002 then
        if nType == BALANCE_TYPE_QUADRUPLET then
            balance.nFan = 0
        else
            balance.nFan = nFan
        end
    end
    balance.nScore = 0
    balance.stFanInfo = stFanInfo or {}

    local nBaseBet = GGameCfg.RoomSetting.nBaseBet
    if GGameCfg.nMoneyMode == MONEY_MODE_MONEY then
        -- 计算金币
    else
        balance.nScore = math.pow(2,balance.nFan)
        balance.nScore = nBaseBet * balance.nScore
    end

    LOG_DEBUG("===balance:%s", vardump(balance))
    local index = self.m_nBalanceIndex
    self.m_stBalanceList[index] = self.m_stBalanceList[index] or {}
    local len = # self.m_stBalanceList[index]
    self.m_stBalanceList[index][len+1] = balance
    LOG_DEBUG("===m_stBalanceList:%s", vardump(self.m_stBalanceList))
end

--[[
    local balance = {}
    balance.nType = nType
    balance.name = GameUtil.GetBalanceName(nType)
    balance.nWinner = nWinner
    balance.nLosser = nLosser
    balance.nFan = nFan
    balance.stFanInfo = stFanInfo or {}
    balance.nScore = 0
--]]


-- 计算最终扣费
function LibGameLogicChengdu:SubmitBalance()
    LOG_DEBUG("===SubmitBalance--m_stBalanceList:%s", vardump(self.m_stBalanceList))
    local arrLosserChairs = {}
    for index=1,#self.m_stBalanceList do
        local stBalanceGroup = self.m_stBalanceList[index]
        for i=1,#stBalanceGroup do
             local balance =stBalanceGroup[i]
             self:RecordOneBalance(balance)
        end
    end      
    --if #self.m_stBalanceList > 0 then
        local stAccountList = self:TransBalanceToClient(self.m_stBalanceList)
        LOG_DEBUG("==============SubmitBalance:%s", vardump(stAccountList))
        CSMessage.NotifyBanlanceChangeListToAll(stAccountList)

    --end
    
    self:ClearBalance()
end

--[[
    balance.nType = nType
    balance.name = GameUtil.GetBalanceName(nType)
    balance.nWinner = nWinner
    balance.nLosser = nLosser
    balance.nFan = nFan
    balance.stFanInfo = stFanInfo or {}
    balance.nScore = 0
--]]
function LibGameLogicChengdu:RecordOneBalance(balance)
    LOG_DEBUG("===RecordOneBalance--m_stBalanceList:%s", vardump(balance))
    local nWinner = balance.nWinner 
    local nLosser = balance.nLosser 
    local nScore = balance.nScore 
    local nFan = balance.nFan 
    local stScoreRecord = LibGameLogic:GetScoreRecord()

    if balance.nType ==  BALANCE_TYPE_QUADRUPLET_CONCEALED or
        balance.nType ==  BALANCE_TYPE_QUADRUPLET or
        balance.nType ==  BALANCE_TYPE_QUADRUPLET_REVEALED  then
        local nType = SCORE_RECORD_TYPE_WIND
        if balance.nType ==  BALANCE_TYPE_QUADRUPLET_CONCEALED  then
            nType = SCORE_RECORD_TYPE_RAIN
        end
        if balance.nType ==  BALANCE_TYPE_QUADRUPLET  then
            nType = SCORE_RECORD_TYPE_BUWIND
        end
        stScoreRecord:AddScoreByQuadruplet(nType, nWinner, nLosser,  nFan, nScore)
        stScoreRecord:LossScoreByQuadruplet(nType, nLosser, nWinner, nFan, nScore)
      
    elseif balance.nType ==  BALANCE_TYPE_WIN then
        -- win
        stScoreRecord:AddScoreByWin(SCORE_RECORD_TYPE_SELFWIN, nWinner, nLosser, nFan, nScore, balance.stFanInfo)
        stScoreRecord:LossScoreByWin(SCORE_RECORD_TYPE_SELFWIN, nLosser, nWinner, nFan, nScore, balance.stFanInfo)
    elseif balance.nType == BALANCE_TYPE_RETURN_QUADRUPLET
        or  balance.nType == BALANCE_TYPE_UNTING_TO_TING
        or balance.nType == BALANCE_TYPE_HUAZHU
     then
        local nType = BalanceTypeToScoreType(balance.nType)

        stScoreRecord:AddScore(nType, nWinner, nLosser, nFan, nScore)
        stScoreRecord:LossScore(nType, nLosser, nWinner, nFan, nScore)
    elseif balance.nType == BALANCE_TYPE_ADD_DI then   -- 自摸加底
        stScoreRecord:AddScore(SCORE_RECORD_TYPE_ADD_DI, nWinner, nLosser, 0, 1)
        stScoreRecord:LossScore(SCORE_RECORD_TYPE_ADD_DI, nLosser, nWinner, 0, 1)
    end
end


-- 这里按index 合并扣费 到 accountList
-- 结果
function LibGameLogicChengdu:TransBalanceToClient(stBalanceList)

    local stAccountList = {}
    for _,stBalanceGroup in ipairs(stBalanceList) do
        local stAccount = {}
        stAccount.score = {0,0,0,0}
        stAccount.owner = {}  -- 认领者  谁胡 谁杠 谁退税
        stAccount.type = nil
        stAccount.name = nil
        local setOwner = {}
        for i=1,#stBalanceGroup do
            local stBalance = stBalanceGroup[i]
            stAccount.type = stAccount.type or stBalance.nType
            stAccount.name = stAccount.name or stBalance.name
            stAccount.stFanInfo = stAccount.stFanInfo or stBalance.stFanInfo
            stAccount.score[stBalance.nWinner] = stAccount.score[stBalance.nWinner] + stBalance.nScore
            stAccount.score[stBalance.nLosser] = stAccount.score[stBalance.nLosser] - stBalance.nScore

            if stAccount.type < BALANCE_TYPE_RETURN_QUADRUPLET then
                setOwner[stBalance.nWinner] = 1
            else
                 setOwner[stBalance.nLosser] = 1
            end
        end
        for owner,_ in pairs(setOwner) do
            stAccount.owner[#stAccount.owner+1] = "p" .. owner
        end
         stAccountList[#stAccountList + 1] = stAccount
	 
        --此处添加单次杠分记录，添加到round_info
        if stAccount.type ==  BALANCE_TYPE_QUADRUPLET_CONCEALED or
            stAccount.type ==  BALANCE_TYPE_QUADRUPLET or
            stAccount.type ==  BALANCE_TYPE_QUADRUPLET_REVEALED  then
            GRoundInfo:UpdateGangScoreLast(stAccount.score)
            LOG_DEBUG("---dancigangfen---stAccount.score: %s", vardump(stAccount.score))
        end
    end
    return stAccountList

end



-- 处理四川麻将 杠成功的 
-- --参数 nType : 0--下雨 , 1--自己刮风, 2--他人给自己刮风
--CHD, 在这里处理成都麻将下雨，赢取所有未胡玩家各2番。 
function LibGameLogicChengdu:ProcessOPQuadrupletChengdu(nType, nChair, nChairGive)
    self:ClearBalance()
    --  注:等游戏结束了才记分刮风下雨。
    if GGameCfg.RoomSetting.nGameStyle ~= GAME_STYLE_CHENGDU  then
        return
    end

    local stGameState = GGameState
    local  stPlayer = stGameState:GetPlayerByChair(nChair)
    --设置抢杠状态，刚开始的话，退出不结算
    if GRoundInfo:GetIsQiangGang() == true then   
        return
    end
    -- report
    --  算分
    local stFanCount = {0, 0, 0, 0}
    local bJiaJiaYou = GGameCfg.RoomSetting.bJiaJiaYou
    local byFanGang = 0
    for i=1,PLAYER_NUMBER do
        if i ~= nChair then
            local stPlayerOther = stGameState:GetPlayerByChair(i)
            if not stPlayerOther then
                return
            end
            --血战玩法增加刮风下雨
            --if not ( LOCAL_CHENGDU_XUEZHAN == GGameCfg.RoomSetting.nSubGameStyle 
            if not stPlayerOther:IsWin() then
                if nType == 0 then -- 下雨两倍
                    stFanCount[i] = -1
                    byFanGang = byFanGang + 1
                elseif nType == 1 then -- 刮风，自己摸到和自己碰过的刻子杠。一倍
                    stFanCount[i] = -1002
                    byFanGang = byFanGang + 0
                elseif nType == 2 then -- 刮风，别人出牌给自己明杠。 一倍
                    if i == nChairGive then
                       --引杠者2倍基础分?
                       --现在要求也是一倍
                       stFanCount[i] = -1
                       byFanGang = byFanGang + 1
                    elseif bJiaJiaYou == true then 
                        stFanCount[i] = -1
                        byFanGang = byFanGang + 1
                    end
                end
            end
        end
    end
    stFanCount[nChair] = byFanGang
    -- 结算一次刮风下雨
    self:IncreaceBalanceIndex()
    for i=1,#stFanCount do
        if stFanCount[i] < 0 then
            local stLosserPlayer = GGameState:GetPlayerByChair(i)
            if stLosserPlayer and stLosserPlayer:IsPlayEnd() == false then
                 self:AddOneBalance(nType,  nChair, i, -1 * stFanCount[i], true)
            end
        end
    end
    
    self:SubmitBalance()
end


-- 处理成都胡
function LibGameLogicChengdu:ProcessOPWin(winCard)
    self:ClearBalance()
    local nWinCard = winCard
    local stRoundInfo = GRoundInfo
    --成都麻将血战模式。
    --/这里要支持一炮多响，发现一个人胡，则把查找出所以可以胡的人。
    local byActionTemp = 0
    local k = 1
    self.m_stCHDHu = {0, 0, 0}
    --找出所以可以胡的人，放入结构m_cCHDHu[k]中。
    local nOnTurn = stRoundInfo:GetWhoIsOnTurn()
        
    local cCheckChair = nOnTurn
    for x=1,PLAYER_NUMBER do
        --修改胡牌玩家会跳过，保持2次同一个玩家的问题
        cCheckChair =  (cCheckChair + 1 + PLAYER_NUMBER -1) %  PLAYER_NUMBER + 1
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
        LOG_DEBUG("no win")
        return 
    end

    -- 先处理胡消息 这里有一炮多响的情况 一起处理
    local stWinList = {}
    local stWinChairs = {}
    for i=1,#self.m_stCHDHu do
        local nChair = self.m_stCHDHu[i]
        if nChair > 0 then
            stWinChairs[#stWinChairs + 1] = nChair
            self.m_stCHDHuNum = self.m_stCHDHuNum + 1
        end
    end

    if #stWinChairs == 1 then
        stRoundInfo:SetNextBankder(stWinChairs[1], false) -- 记录第一个赢玩家为下轮庄家
    elseif #stWinChairs > 1 then
        stRoundInfo:SetNextBankder(nOnTurn, true)  -- 一炮多响 记录点炮玩家为下轮庄家
    end

    local stFanInfo ={}    
    LOG_DEBUG("=========111===LibGameLogicChengdu:ProcessOPWin=====stWinChairs===:%s",vardump(stWinChairs))
    -- LibTurnOrder:Sort(stWinChairs)
    for i=1,#stWinChairs do
        local nChair = stWinChairs[i]
        local env = LibFanCounter:CollectEnv(nChair)
        local stPlayerWin = GGameState:GetPlayerByChair(nChair)

        --如果是抢杠胡成功的话，设置胡类型，重置抢杠胡
        LOG_DEBUG("=========000111===LibGameLogicChengdu:ProcessOPWin=====GetPlayerQiangGangStatus===:%d",stPlayerWin:GetPlayerQiangGangStatus())  
        if stPlayerWin and stPlayerWin:GetPlayerQiangGangStatus() ==QIANGGANG_STATUS_OK then
            env.byFlag = WIN_GANG
            LOG_DEBUG("=========000===LibGameLogicChengdu:ProcessOPWin=====env.byFlag===:%d",env.byFlag)  
            stPlayerWin:SetPlayerIsQiangGangHu(false)
			GRoundInfo:SetIsQiangGang(false)
        end
        LOG_DEBUG("=========111===LibGameLogicChengdu:ProcessOPWin=====env.byFlag===:%d",env.byFlag)   
        LibFanCounter:SetEnv(env)
        stFanInfo = LibFanCounter:GetCount()
        --LOG_DEBUG("=========111===LibGameLogicChengdu:ProcessOPWin:%s",vardump(stFanInfo))
        --增加赢得类型-- 胡方式0 -- 自摸1 -- 点炮2 -- 杠上花3 -- 抢杠4 -- 杠上炮,赢得番型
        if env.byFlag  ==  0 or env.byFlag == 2 then
            stPlayerWin:SetWinType(0)
        else
            stPlayerWin:SetWinType(1)
        end
        
        stWinList[#stWinList + 1] = {stCHDHuNum = self.m_stCHDHuNum,winner = nChair, winWho = nOnTurn, cardWin = nWinCard,winType =env.byFlag,fanInfo =stFanInfo}
        LOG_DEBUG("=========111===LibGameLogicChengdu:ProcessOPWin:%s",vardump(stFanInfo))
    end
    LOG_DEBUG("=========111===LibGameLogicChengdu:ProcessOPWin=====stWinList===:%s",vardump(stWinList))      

    -- 通知胡逻辑
    LibGameLogic:DoProcessOPWin(stWinList)

    --通知呼叫转移
    if  GGameCfg.GameSetting.bSupportGangMove then

        --此处更改杠分，用于呼叫转移（杠上炮存在的一炮多响一起处理，点杠玩家赔付给每家点炮玩家本次杠所得杠分）

        local stGangScoreLast = GRoundInfo:GetGangScoreLast()  --获取上次杠分（如果是杠上炮则次杠已经先结算过了，这里进行呼叫转移）

        local stScoreRecord = LibGameLogic:GetScoreRecord()   --获取之前的杠分记录

        local stGangScoreOne = {0,0,0,0}   --本次呼叫转移调整分数（用于客户端飘分）

        local nNum = 0 --上次杠分被扣分者数量

        for n =  1,#stGangScoreLast do
            if stGangScoreLast[n] < 0 then
                nNum = nNum + 1
            end
        end

        LOG_DEBUG("=====hujiaozhuanyi==nNum====== %s",nNum)

        local blogGangMove = -1   --呼叫转移标记

        local nType = SCORE_RECORD_TYPE_GANGMOVE  --呼叫转移类型

        local nBaseBet = GGameCfg.RoomSetting.nBaseBet

        for i=1,#stWinList do
            if(stWinList[i].winType == 4) then
                blogGangMove = 1
                LOG_DEBUG("---hujiaozhuanyi---stGangScoreLast: %s", vardump(stGangScoreLast))
                LOG_DEBUG("---hujiaozhuanyi---stScoreRecord: %s", vardump(stScoreRecord))
                if stGangScoreLast[stWinList[i].winWho] > 0  then

                    local nScore = stGangScoreLast[stWinList[i].winWho]
                    local nWinner = stWinList[i].winner
                    local nLosser = stWinList[i].winWho
                    local nFan = 0

                    stGangScoreOne[nWinner] = stGangScoreOne[nWinner] + nScore
                    stGangScoreOne[nLosser] = stGangScoreOne[nLosser] - nScore

                    for n =  1,#stGangScoreLast do
                        if stGangScoreLast[n] < 0 then
                            nNum = nNum + 1
                        end
                    end
                    
                    --番数对应调整
                    local nst_score = nScore / nBaseBet / nNum
                    LOG_DEBUG("=====hujiaozhuanyi==nst_score====== %s",nst_score)

                    if nst_score > 1 then
                        while(nst_score > 1) do
                               nst_score = nst_score/2
                               nFan = nFan + 1  
                        end
                    end

                    nFan =  nFan*nNum

                    LOG_DEBUG("=====hujiaozhuanyi==nFan====== %s",nFan)

                    stScoreRecord:AddScore(nType, nWinner, nLosser, nFan, nScore)
                    stScoreRecord:LossScore(nType, nLosser, nWinner, nFan, nScore)    
                end
            end
        end


        if blogGangMove == 1  then
            LOG_DEBUG("=====hujiaozhuanyi==SendTOClient======stGangScoreOne %s", vardump(stGangScoreOne))
            CSMessage.NotifyGangMoveResultToAll(stGangScoreOne)
        end
    end

    self:DoHuBalance()

    -- 处理积分等变更
    if LOCAL_CHENGDU_XUEZHAN == GGameCfg.RoomSetting.nSubGameStyle then
        LOG_DEBUG("=========111===DoCHD_HuXZn:%s",vardump(stFanInfo))
        self:DoCHD_HuXZ() -- 血战模式胡 
    elseif LOCAL_CHENGDU_XUELIU == GGameCfg.RoomSetting.nSubGameStyle then
        self:DoCHD_HuXL()  -- 血流模式胡
    end

    self.m_stCHDHu = {-1, -1, -1}
end


function LibGameLogicChengdu:DoHuBalance()
    -- 算番
    local stRoundInfo = GRoundInfo
    local stGameState = GGameState
    self.m_stWinChairs = {}
    self.m_stFanInfo = {}
    local nBaseBet = GGameCfg.RoomSetting.nBaseBet

    for i=1,#self.m_stCHDHu do
        local nChair = self.m_stCHDHu[i]
        if nChair > 0 and nChair <= PLAYER_NUMBER then
            self.m_stWinChairs[#self.m_stWinChairs + 1] = nChair
        end
    end    
    LibTurnOrder:Sort(self.m_stWinChairs)

    local env ={}
    local nWin =0
    local stScore ={0, 0,0,0}
    -- 每个胡开始 顺序算番
    for k=1, #self.m_stWinChairs do
        nWin = self.m_stWinChairs[k]
        stRoundInfo:SetLastWinner(nWin)
        
        local stPlayerWin = GGameState:GetPlayerByChair(nWin)
        env = LibFanCounter:CollectEnv(self.m_stWinChairs[k])
        if stPlayerWin and stPlayerWin:GetPlayerQiangGangStatus() ==QIANGGANG_STATUS_OK then
            env.byFlag = WIN_GANG
        end
        LibFanCounter:SetEnv(env)
        stScore = {0, 0,0,0}
        -- 用score 反查fan
        local stFanInfo = LibFanCounter:GetCount()
        stScore = LibFanCounter:GetScore()
        LOG_DEBUG("c++---score:%s,faninfo:%s",vardump(stScore), vardump(stFanInfo))  
        if stScore == nil then
            LOG_ERROR(" LibFanCounter:GetScore()  Failed.")
            return 
        end

        --如果是杠上花且此杠为直杠的话，此处添加杠上花（自摸）和杠上花（点炮）区分
        local nFlag = 0   --杠上花（点炮）分数调整标志，为nFlag=1时，表示确定为点杠花（点炮）

        if env.byFlag == 2 then   ---判断是否为杠上花
                if  GGameCfg.GameSetting.bSupportGangDrawSelf  then  --判断是否支持点杠花（自摸）
                    nFlag = 0
                elseif GGameCfg.GameSetting.bSupportGangDrawGun then --判断是否支持点杠花（点炮）
                        if stRoundInfo:GetGangType() ~= 2  then--再判断是否为直杠
                            nFlag = 0
                        else                                --这里真正进行点杠花（点炮操作）
                            LOG_DEBUG("dianganghua----ready to changescore ")
                            nFlag = 1
                        end 
                end
        end


        local nScoreWin = 0          
        local nlosser = stRoundInfo:GetGangWho()   --被点杠玩家
        local nwinnner = 0                         --胡牌者

        if nFlag == 1 then          --点杠花分数调整，因为C++是直接算杠上花自摸

            --调整点杠花自摸加倍分（因为算点炮，删减番型记录，同时调整胡分）
            if  GGameCfg.GameSetting.bSupportSelfDrawDouble  then
                for i = 1,#stScore do
                    stScore[i] = stScore[i] / 2          --去除胡分自摸翻倍影响
                end

                for j = 1,#stFanInfo do
                    if stFanInfo[j].szFanType == 21 then   --删除自摸翻倍番型记录
                        table.remove(stFanInfo,j)
                        break
                    end
                end
            end

           
            if stScore[nlosser] < 0 then
                LOG_DEBUG("dianganghua----losser:%s ",nlosser)
                nScoreWin = math.abs(stScore[nlosser])
            end

            for i = 1,#stScore do
                
                if stScore[i] < 0 and i ~= nlosser then
                    stScore[i] = 0
                elseif stScore[i] > 0 then
                    nwinnner = i
                    stScore[i] = nScoreWin   
                end
            end 

            LOG_DEBUG("dianganghua--have changed score---score:%s",vardump(stScore)) 
        end


        --此处进行最大番型限制，只针对两个人之间结算进行最大番比较
        local  nMaxFanSvr = GGameCfg.GameSetting.nMaxFan
        local  nMaxFlag = 0   --最大番调整标志
        local   nLosserSvr = 0 --扣分者数量
        local nScoreSvr = 0   --负分者得分
        for i = 1,#stScore do
            if stScore[i] < 0 then
                nScoreSvr = math.abs(stScore[i])
                if nScoreSvr / nBaseBet > 2^nMaxFanSvr then
                    LOG_DEBUG("---maxfan over ---maxfan = %s",nMaxFanSvr)
                    nMaxFlag = 1
                    stScore[i] = -(2^nMaxFanSvr)
                    nLosserSvr = nLosserSvr + 1
                end
            end
        end

        if nMaxFlag == 1 then
            LOG_DEBUG("---maxfan---formalscore(winner) = %s",stScore[nWin])
            stScore[nWin] = (2^nMaxFanSvr)*nLosserSvr
            LOG_DEBUG("---maxfan---afterchangescore(winner) = %s",stScore[nWin])
        end 

        LOG_DEBUG("------afterchangescore = %s",vardump(stScore))

        local stFanCount = {0, 0,0,0}
		--只算丢分者的番,如果得分是-1，番数为0，不管
        for i=1,#stScore do
            stScore[i] = stScore[i] / nBaseBet  
            if  stScore[i]<-1 then
                while(stScore[i]~=-1)
                do
                   stScore[i] = stScore[i]/2
                   stFanCount[i] = stFanCount[i]-1   
                end
            elseif stScore[i]==-1 then
                --平胡0番的时候
                stFanCount[i] =-1001
            end
	    end
        self:IncreaceBalanceIndex()
        LOG_DEBUG("DoHuBalance stFanInfo:%s stFanCount:%s", vardump(stFanInfo), vardump(stFanCount))
        for i=1,#stFanCount do
            if stFanCount[i] < 0 then
                local stLosserPlayer = stGameState:GetPlayerByChair(i)
                if stLosserPlayer~=nil then
                    if stLosserPlayer:IsPlayEnd() == false then
                        self:AddOneBalance(BALANCE_TYPE_WIN, nWin, i, -1*stFanCount[i], true, stFanInfo)
                        -- 自摸加底 0番=1分
                        local stPlayer = GGameState:GetPlayerByChair(nWin)
                        if GGameCfg.GameSetting.bSupportSelfDrawDouble == false and stPlayer:GetWinType() == WIN_SELFDRAW then
                            self:AddOneBalance(BALANCE_TYPE_ADD_DI, nWin, i, 0, true)
                        end
                    end
                end
            end
        end
    local stWinnerPlayer = stGameState:GetPlayerByChair(self.m_stWinChairs[k])
	if stWinnerPlayer then
		stWinnerPlayer:GetPlayerCardGroup():SetLastDraw(0)
	end
    end

    self:SubmitBalance()
end
--function LibGameLogicChengdu:SubmitCloseWinBanlace(bTriggerAddMoney)
 --   self:AddOneBalance(BALANCE_TYPE_WIN, self.m_stFanCountSum, bTriggerAddMoney, self.m_stFanInfo)
--end

-- 血战模式胡 
function LibGameLogicChengdu:DoCHD_HuXZ()
  local stGameState = GGameState
  local stRoundInfo = GRoundInfo
    -- 血战模式 赢的玩家 后续不再参与摸大牌
    for i=1,#self.m_stWinChairs do
        local stPlayer = GGameState:GetPlayerByChair(self.m_stWinChairs[i])
        if stPlayer then
            stPlayer:SetPlayEnd(true)
        end
    end
  

   -- 判断是否可以继续血战。
    local nNotHu = 0 
    for i=1,PLAYER_NUMBER do
        local stPlayer = stGameState:GetPlayerByChair(i)
        if stPlayer and stPlayer:IsWin() == false then
            nNotHu = nNotHu + 1
        end
    end
    -- 有两家没和 并且还有牌发
    --//3.为继续血战做工作。 
    local nDealerCardLeft = GDealer:GetDealerCardGroup():GetCurrentLength() 
    if nNotHu >=2 and nDealerCardLeft >= 1 then
        --local nLastWinner = self.m_stWinChairs[#self.m_stWinChairs]
        local nNextTurn = LibTurnOrder:GetNextTurn(stRoundInfo:GetLastWinner())
        stRoundInfo:SetWhoIsOnTurn(nNextTurn)
        LOG_DEBUG("LibGameLogicChengdu:DoCHD_HuXZ:%d", nNextTurn)
        stRoundInfo:SetNeedDraw(true)
        stRoundInfo:SetLastGive(0)
    end
     --self:SubmitCloseWinBanlace(true)
    --[[
    -- 这里不做检查
    elseif nNotHu < 2 then
        self:SubmitCloseWinBanlace(false)
        self:CHD_GameOver() -- 结算
        return 
    elseif nDealerCardLeft < 1 then
        self:SubmitCloseWinBanlace(false)
        self:CHD_GameNoCard()  -- 有人胡了后，后面的人没牌打了，也算留局。
        return 
    end
     ]]

end
function LibGameLogicChengdu:DoCHD_HuXL()
    local stGameState = GGameState
    local stRoundInfo = GRoundInfo
      -- 算番
    -- 判断是否可以继续血流
    local nNotHu = 0 
    for i=1,PLAYER_NUMBER do
        local stPlayer = stGameState:GetPlayerByChair(i)
        if stPlayer and stPlayer:IsWin() == false then
            nNotHu = nNotHu + 1
        end
    end
    -- 有两家没和 并且还有牌发
    --//3.为继续血流做工作。 
    local nDealerCardLeft = GDealer:GetDealerCardGroup():GetCurrentLength() 
    if nNotHu >=2 and nDealerCardLeft >= 1 then
        local nNextTurn = LibTurnOrder:GetNextTurn(stRoundInfo:GetLastWinner())
        LOG_DEBUG("XueLiu Win nDealerCardLeft: %d" , nDealerCardLeft)
        stRoundInfo:SetWhoIsOnTurn(nNextTurn)
        stRoundInfo:SetNeedDraw(true)
        stRoundInfo:SetLastGive(0)
    end
    --[[ 
    elseif nNotHu < 2 then
        self:SubmitCloseWinBanlace(false)
        self:CHD_GameOver() -- 结算
        return 
    elseif nDealerCardLeft < 1 then
        self:SubmitCloseWinBanlace(false)
        self:CHD_GameNoCard()  -- 有人胡了后，后面的人没牌打了，也算留局。
        return 
    end
    ]]
end


-- 荒牌
-- 成都麻将荒牌前的处理。(查局)
function LibGameLogicChengdu:CHD_GameNoCard()
    LOG_DEBUG("CHD_GameNoCard")
    self:ClearBalance()

    local stGameState = GGameState
     local stIsHuaZhu = {false, false, false, false}
     local stIsWin = {false, false, false, false}
     local nHuaZhuCount = 0
     local nNoTingCount = 0
     local stFanHuaZhu = {0, 0, 0, 0}
     local nWinCount = 4
     -- 查花猪 
     for i=1,PLAYER_NUMBER do
         local stPlayer = stGameState:GetPlayerByChair(i)
         if stPlayer and stPlayer:IsWin() == false then
             local stPlayerCardArr = stPlayer:GetPlayerCardGroup():ToArray()
            if LibConfirmMiss:CheckHasMissCard(i, stPlayerCardArr) then
                 stIsHuaZhu[i] = true
                 nHuaZhuCount = nHuaZhuCount + 1
             end
             stIsWin[i] = false
             nWinCount = nWinCount - 1
        else
            stIsWin[i] = true
        end
     end
     LOG_DEBUG("stIsHuaZhu:%s", vardump(stIsHuaZhu))
     local nBaseBet = GGameCfg.RoomSetting.nBaseBet
     local nMinFan = GGameCfg.RoomSetting.nMinFan
     local nHuaZhuFan = GGameCfg.RoomSetting.nHuaZhuFan

   


     -- 查大叫 (查听的人，其他没听者按照最大番赔，花猪不用再陪 )
     
     local stIsTing = {false, false, false, false}
     local stFanTingMax = {0, 0, 0, 0}
     for i=1,PLAYER_NUMBER do
          local biscanwin =false
          if stIsWin[i] == false then
             -- 获取四个人中听牌玩家的大叫的番数
             local stPlayer = stGameState:GetPlayerByChair(i)
             if not stPlayer then
                 return
             end
             local arrPlayerCards = stPlayer:GetPlayerCardGroup():ToArray()
             arrPlayerCards[#arrPlayerCards + 1] = 0
             for j=1,30 do
                 if j % 10 ~= 0 then
                     -- 检查座位为i的玩家手上的牌加上j牌是否试胡牌牌型。 
                     arrPlayerCards[#arrPlayerCards] = j
                     if LibConfirmMiss:CheckHasMissCard(i, arrPlayerCards) == false and
                        LibRuleWin:CanWin(arrPlayerCards) then
                            biscanwin = true
                            local nFan = self:CHD_GetFanCount(i, j)    --算算座位i上玩家手牌加牌j一起的番数。 
                            if nFan >= stFanTingMax[i] then
                                stFanTingMax[i] = nFan
                            end
                     end
                 end
             end
             if biscanwin ==true and stFanTingMax[i] >= 0 and  stFanTingMax[i] >= nMinFan then
                 stIsTing[i] = true
             end
          end
     end
     LOG_DEBUG("=====================stFanTingMax:%d===%d==%d==%d", stFanTingMax[1],stFanTingMax[2],stFanTingMax[3],stFanTingMax[4])
     -- 退税
     local stScoreRecord = LibGameLogic:GetScoreRecord()
     local stScoreGainAll = {} -- 四个玩家获得分数记录
     for nChair=1,PLAYER_NUMBER do
          if stIsWin[nChair] == false then
            --流局查叫时，未下叫者（包括花猪）将退回所有刮风下雨的所得,此处按策划规则进行调整
            if  stIsTing[nChair] == false then
                local stScoreGain  = stScoreRecord:GetAllQuadrupletScoreGain(nChair)
                -- 处理退税
                LOG_DEBUG("=====stScoreGain:%s", vardump(stScoreGain))
                if #stScoreGain > 0 then
                    stScoreGain.nChair =nChair
                    table.insert(stScoreGainAll,stScoreGain)
                   -- stScoreGainAll[#stScoreGainAll+1] = stScoreGain
                    --self:PorcessReturnTax(stScoreGainAll,nChair)
                end
                
            end
          end
     end
     --  先退税
     LOG_DEBUG("===stScoreGainAll ===%s====stIsWin:%s stIsTing:%s stFanTingMax:%s",vardump(stScoreGainAll), vardump(stIsWin), vardump(stIsTing), vardump(stFanTingMax))
    self:PorcessReturnTax(stScoreGainAll)
    
     LOG_DEBUG("stFanTingList:%s", vardump(stFanTingList))
     -- 处理花猪
     if nHuaZhuCount > 0 then
        --  一个一个算花猪
         --if stIsWin[i] == false then
         for i=1,PLAYER_NUMBER do
            local stFanHuaZhu = {0,0,0,0}
            if stIsHuaZhu[i]  == true then
                stFanHuaZhu[i] =  -nHuaZhuFan 
                for j=1,PLAYER_NUMBER do
                    if j ~= i then
                        if stIsHuaZhu[j]  ~= true then
                            stFanHuaZhu[j]  = nHuaZhuFan 
                        end
                    end
                end
                self:ProcessHuaZhuAccount(i, stFanHuaZhu)
            end
        end
     end
     -- 算大叫各人该得和该赔的分。 i:听的人
     local stFanTingList ={}
     for _chair=1,PLAYER_NUMBER do
         if stIsWin[_chair] == true then
            do end
         elseif (stIsTing[_chair] == false)  then
            do end
        else
            -- _chair  听, 其他未听的 给钱
            self:IncreaceBalanceIndex()
            local stFanTingOne = {0,0,0,0}
            stFanTingOne[_chair] = 0
            for other=1,PLAYER_NUMBER do
                if other ~= _chair then
                    if stIsWin[other]==false and (stIsTing[other]==false or stIsHuaZhu[other] ==true) then
                        stFanTingOne[other] =  -1*  stFanTingMax[_chair]
                        stFanTingOne[_chair] = stFanTingMax[_chair]
                        self:AddOneBalance(BALANCE_TYPE_UNTING_TO_TING, _chair, other, stFanTingOne[_chair] )
                    end
                end
             end
         end
     end

     self:SubmitBalance()
--[[ 
     local stFanNoCard = {}
     for i=1,PLAYER_NUMBER do
        stFanNoCard[i] = stFanHuaZhu[i] * stScoreTing[i]
     end
]]
--     LibFanCounter:SetNoCardScore(stIsHuaZhu, stIsTing,stFanTing, stScoreNoCard)

--[[ 
    LOG_DEBUG("bHuaZhu[1] =%d,bHuaZhu[2] =%d,bHuaZhu[3] =%d,bHuaZhu[4] =%d\r\n", 
        stIsHuaZhu[1],stIsHuaZhu[2],stIsHuaZhu[3],stIsHuaZhu[4]); 
    LOG_DEBUG("bTing[1] =%d,bTing[2] =%d,bTing[3] =%d,bTing[4] =%d\r\n", 
        stIsTing[1],stIsTing[2],stIsTing[3],stIsTing[4]); 
    LOG_DEBUG("nScoreTing[1] =%d,nScoreTing[2] =%d,nScoreTing[3] =%d,nScoreTing[4] =%d\r\n", 
        stScoreTing[1],stScoreTing[2],stScoreTing[3],stScoreTing[4]); 
--]]
end



 function LibGameLogicChengdu:CHD_GetFanCount(nChair, nCard)
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
    LOG_DEBUG("============stFanCount:%s", vardump(stFanCount))
    local nFanNum = 0
    for i=1,#stFanCount do
        nFanNum = nFanNum + stFanCount[i].byFanNumber*stFanCount[i].byCount
    end
    if nFanNum > GGameCfg.GameSetting.nMaxFan then
        nFanNum =GGameCfg.GameSetting.nMaxFan
    end
    return nFanNum
 end


function LibGameLogicChengdu:PorcessReturnTax(stScoreGainList)

    LOG_DEBUG("============stScoreGainList:%s", vardump(stScoreGainList))
     local stScoreRecord = LibGameLogic:GetScoreRecord()
     for _,stScoreGain in ipairs(stScoreGainList) do
        if #stScoreGain > 0 then
            local nChair =stScoreGain.nChair
            local stFan = {0, 0,0,0}
            local stScore = {0, 0,0,0}
            local nTotalFan = 0
            local nTotalScore = 0
            self:IncreaceBalanceIndex()
            for _,stRecord in ipairs(stScoreGain) do
                 stFan[stRecord.nTarget] =  stRecord.nFan
                 stScore[stRecord.nTarget]= stRecord.nScore

                 nTotalFan = nTotalFan + stRecord.nFan
                 nTotalScore = nTotalScore + stRecord.nScore

                 self:AddOneTaxBalance( stRecord.nTarget, nChair, stFan[stRecord.nTarget], stScore[stRecord.nTarget] )
            end
            stFan[nChair] = -1 * nTotalFan
            stScore[nChair] = -1 * nTotalScore
            LOG_DEBUG("============stFan:%s======stScore:%s", vardump(stFan),vardump(stScore))
            -- self:IncreaceBalanceIndex()
            --for i=1,#stFan do
             --   if stFan[i] > 0 then
            --        self:AddOneTaxBalance( i, nChair, stFan[i], stScore[i] )
             --   end
            --end
            
        end
     end
end

function LibGameLogicChengdu:ProcessHuaZhuAccount(nHuazhuChair, stFanHuaZhu)
    LOG_DEBUG("stFanHuaZhu:%s", vardump(stFanHuaZhu))
    local stFan = stFanHuaZhu
     self:IncreaceBalanceIndex()
    for i=1,#stFan do
        if stFan[i] > 0 then
           self:AddOneBalance( BALANCE_TYPE_HUAZHU, i, nHuazhuChair, stFan[i] )
        end
        
    end
    
    --[[ 
    local stScore = {0, 0,0, 0}
    local nScoreToMoney = GGameCfg.RoomSetting.nScoreToMoney
    local nBaseBet = GGameCfg.RoomSetting.nBaseBet
    if GGameCfg.nMoneyMode == MONEY_MODE_MONEY then
        for i=1,PLAYER_NUMBER do
            stScore[i] = stFanHuaZhu[i] * nScoreToMoney
        end
    end
    local stScoreRecord = LibGameLogic:GetScoreRecord()
    for nChair=1,PLAYER_NUMBER do
        if stScore[nChair] > 0 then
            stScoreRecord:AddScoreByHuaZhu(nChair, 0, stScore[nChair])
        elseif stScore[nChair] < 0 then
            stScoreRecord:LossScoreByHuaZhu(nChair, 0, stScore[nChair])
        end
    end
    CSMessage.NotifyHuaZhuAccountToAll(stScore)
    ]]
end
function LibGameLogicChengdu:IncreaceBalanceIndex()
     self.m_nBalanceIndex = self.m_nBalanceIndex + 1
end
function LibGameLogicChengdu:ProcessNoTingToTingAccount(nTingChair, stScoreTing)
    LOG_DEBUG("ProcessNoTingToTingAccount: stScoreTing %s",  vardump(stScoreTing))
    for i=1,#stScoreTing do
        if i ~= nTingChair and stScoreTing[i] < 0 then
            self:AddOneBalance(BALANCE_TYPE_UNTING_TO_TING, nTingChair, i, -1*stScoreTing[i] )
        end
    end
    
    --[[
     local stScore = {0, 0,0, 0}
    local nScoreToMoney = GGameCfg.RoomSetting.nScoreToMoney
    local nBaseBet = GGameCfg.RoomSetting.nBaseBet
    if GGameCfg.nMoneyMode == MONEY_MODE_MONEY then
        for i=1,PLAYER_NUMBER do
            stScore[i] = stScoreTing[i] * nScoreToMoney
        end
    end
    local stScoreRecord = LibGameLogic:GetScoreRecord()
    for nChair=1,PLAYER_NUMBER do
        if stScore[nChair] > 0 then
            stScoreRecord:AddScoreByDaJiao(nChair, 0, stScore[nChair])
        elseif stScore[nChair] < 0 then
            stScoreRecord:LossScoreByDaJiao(nChair, 0, stScore[nChair])
        end
    end
    CSMessage.NotifyDaJiaoAccountToAll(stScore)
     ]]
end



function LibGameLogicChengdu:ProcessOPPlayerNoMoney(stPlayer)
    LOG_DEBUG("ProcessOPPlayerNoMoney")
    SSMessage.CallPlayerAddMoney(stPlayer)
end

function LibGameLogicChengdu:RewardThisGame()
    --[[
     local nDealCardLeft = GDealer:GetDealerCardGroup():GetCurrentLength()
     if nDealCardLeft == 0 then
        -- 荒牌结算
         self:CHD_GameNoCard()
     else
        local nWinPlayerNums  = 0
        for i=1,PLAYER_NUMBER do
            if stRoundInfo:IsWin(i) == true then
                nWinPlayerNums = nWinPlayerNums + 1
            end
        end
        if nWinPlayerNums ~= 3 then
            LOG_ERROR("run time error. nDealCardLeft:%d nWinPlayerNums:%d chengdu not end", nDealCardLeft, nWinPlayerNums)
        end
     end
      ]]
end
return LibGameLogicChengdu

