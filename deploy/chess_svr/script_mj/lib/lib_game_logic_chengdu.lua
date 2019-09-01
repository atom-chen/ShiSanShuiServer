local LibBase = import(".lib_base")
local PlayerBlockState = import("core.player_block_state")


function BalanceTypeToScoreType(nBalanceType)
    if nBalanceType == BALANCE_TYPE_QUADRUPLET_CONCEALED then
        return SCORE_RECORD_TYPE_WIND
    elseif nBalanceType == BALANCE_TYPE_RETURN_QUADRUPLET then
         return SCORE_RECORD_TYPE_TAX  -- 退税
    elseif nBalanceType == BALANCE_TYPE_WIN then
        return SCORE_RECORD_TYPE_GUN 
    elseif nBalanceType == BALANCE_TYPE_UNTING_TO_TING then
        return SCORE_RECORD_TYPE_DAJIAO
    elseif nBalanceType == BALANCE_TYPE_HUAZHU then
        return SCORE_RECORD_TYPE_HUAZHU
    end
    LOG_ERROR("BalanceTypeToScoreType Error nBalanceType:%d", nBalanceType)
    return 0
end



local LibGameLogicChengdu = class("LibGameLogicChengdu", LibBase)

function LibGameLogicChengdu:ctor()
    self.m_stBalanceList = {}
    self.m_nBalanceIndex = 0
end
function LibGameLogicChengdu:CreateInit()
   self.m_stCHDHu = {}
   self.m_stFanCountSum = {0, 0, 0, 0}
   return true
end
function LibGameLogicChengdu:OnGameStart()
    self.m_stCHDHu = {}
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
-- 
function LibGameLogicChengdu:AddOneBalance(nType, nWinner, nLosser, nFan, bTriggerAddMoney, stFanInfo)
    if nFan <= 0 then
        LOG_ERROR("Error fan", nFan);

        return 
    end
    bTriggerAddMoney = bTriggerAddMoney or false
    stFanInfo = stFanInfo or {}

    local balance = {}
    balance.nType = nType
    balance.name = GameUtil.GetBalanceName(nType)
    balance.nWinner = nWinner
    balance.nLosser = nLosser
    balance.nFan = nFan
    balance.stFanInfo = stFanInfo or {}
    balance.nScore = 0

    local nBaseBet = GGameCfg.RoomSetting.nBaseBet
    if GGameCfg.nMoneyMode == MONEY_MODE_MONEY then
        -- 计算金币
        local nScoreToMoney = GGameCfg.RoomSetting.nScoreToMoney
        local nMaxMoney = GGameCfg.RoomSetting.nMaxMoney
        local nRate =  GGameCfg.RoomSetting.nShareRate
        local nMul = self:FanToMul(nFan)
        local money = nMul * nScoreToMoney
        if nMaxMoney > 0 and money > nMaxMoney then
            money  = nMaxMoney
        end
        local stPlayer = GGameState:GetPlayerByChair(nLosser)
        local nPlayerMoney =  stPlayer:GetMoney()
        if money >  nPlayerMoney then
            money =  nPlayerMoney
        end
        balance.nScore = money
    else
        balance.nScore = nBaseBet * nFan
    end

    print("balance:%s", vardump(balance))
    local index = self.m_nBalanceIndex
    self.m_stBalanceList[index] = self.m_stBalanceList[index] or {}
    local len = # self.m_stBalanceList[index]
    self.m_stBalanceList[index][len+1] = balance
    --CSMessage.NotifyBanlanceChangeListToAll({balance})
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
]]


-- 计算最终扣费
function LibGameLogicChengdu:SubmitBalance()
    print(vardump(self.m_stBalanceList, "self.m_stBalanceList"))
    local arrLosserChairs = {}
    for index=1,#self.m_stBalanceList do
        local stBalanceGroup = self.m_stBalanceList[index]
        for i=1,#stBalanceGroup do
             local balance =stBalanceGroup[i]
             self:RecordOneBalance(balance)
            if GGameCfg.nMoneyMode == MONEY_MODE_MONEY then
                -- 赢家 抽水？
                --[[
                for i=1,#balance.scoreList do
                    if balance.scoreList[i] > 0 then
                        local money = -1* nTotalMoneyCost
                         -- 计算抽水
                        if nRate > 0 and nRate < 100  then
                            local lSharedMoney = money * nRate / 100
                            money = money - lSharedMoney
                        end
                        balance.scoreList[i] = money
                    end
                end
                 ]]
                 local stPlayerWinner = GGameState:GetPlayerByChair(balance.nWinner)
                 stPlayerWinner:AddMoney(balance.nScore)
                 local stPlayerLosser = GGameState:GetPlayerByChair(balance.nLosser)
                 stPlayerLosser:AddMoney(-1*balance.nScore)
                arrLosserChairs[balance.nLosser] = 1
            else
                for j=1,#balance.scoreList do
                    local stPlayer = GGameState:GetPlayerByChair(j)
                    local nScore = balance.scoreList[j]
                    stPlayer:AddScore(nScore)
                end
            end
        end
    end      
    --if #self.m_stBalanceList > 0 then
        local stAccountList = self:TransBalanceToClient(self.m_stBalanceList)
        CSMessage.NotifyBanlanceChangeListToAll(stAccountList)
    --end
    

     -- 如果是血流模式 扣费到0 触发等待认输或充值操作
    if LOCAL_CHENGDU_XUELIU == GGameCfg.RoomSetting.nSubGameStyle
        and MONEY_MODE_MONEY == GGameCfg.nMoneyMode then
        for nChair,_ in pairs(arrLosserChairs) do
             local stPlayer = GGameState:GetPlayerByChair(nChair)
            if stPlayer:GetMoney() == 0 then
                self:ProcessOPPlayerNoMoney(stPlayer)
            end
        end
       
    end
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
]]
function LibGameLogicChengdu:RecordOneBalance(balance)
    local nWinner = balance.nWinner 
    local nLosser = balance.nLosser 
    local nScore = balance.nScore 
    local nFan = balance.nFan 
    local stScoreRecord = LibGameLogic:GetScoreRecord()
    
    -- 
    if balance.nType ==  BALANCE_TYPE_QUADRUPLET_CONCEALED or
        balance.nType ==  BALANCE_TYPE_QUADRUPLET_REVEALED  then
        local nType = SCORE_RECORD_TYPE_WIND
        if balance.nType ==  BALANCE_TYPE_QUADRUPLET_REVEALED  then
            nType = SCORE_RECORD_TYPE_RAIN
        end

        stScoreRecord:AddScoreByQuadruplet(nType, nWinner, nLosser,  nFan, nScore)
        stScoreRecord:LossScoreByQuadruplet(nType, nLosser, nWinner, nFan, -1 * nScore)
      
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
    end
end


-- 这里按index 合并扣费 到 accountList
--  结果
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
    end
    return stAccountList

end



-- 处理四川麻将 杠成功的 
-- --参数 nType : 0--下雨 , 1--自己刮风, 2--他人给自己刮风
--CHD, 在这里处理成都麻将下雨，赢取所有未胡玩家各2番。 
function LibGameLogicChengdu:ProcessOPQuadrupletChengdu(nType, nChair, nChairGive)
    self:ClearBalance()
    --     --  注:等游戏结束了才记分刮风下雨。
    if GGameCfg.RoomSetting.nGameStyle ~= GAME_STYLE_CHENGDU  then
        return
    end
 
    local stGameState = GGameState
    local  stPlayer = stGameState:GetPlayerByChair(nChair)
    -- report
    --  算分
    local stFanCount = {0, 0, 0, 0}
    local bJiaJiaYou = GGameCfg.RoomSetting.bJiaJiaYou
    local byFanGang = 0
     for i=1,PLAYER_NUMBER do
        if i ~= nChair then
            local stPlayerOther = stGameState:GetPlayerByChair(i)
            -- 非 血战并且玩家已胡
            if not ( LOCAL_CHENGDU_XUEZHAN == GGameCfg.RoomSetting.nSubGameStyle 
                and stPlayerOther:IsWin() ) then
                if nType == 0 then -- 下雨两倍
                    stFanCount[i] = -2
                    byFanGang = byFanGang +2 
                elseif nType == 1 then -- 刮风，自己摸到和自己碰过的刻子杠。一倍
                    stFanCount[i] = -1
                    byFanGang = byFanGang + 1
                elseif nType == 2 then -- 刮风，别人出牌给自己明杠。 一倍
                    if i == nChairGive then
                       --引杠者2倍基础分
                       stFanCount[i] = -2
                       byFanGang = byFanGang + 2
                    elseif bJiaJiaYou == true then 
                        stFanCount[i] = -1
                        byFanGang = byFanGang + 1
                    end
                end
            end
        end
    end
    stFanCount[nChair] = byFanGang
    local nBalanceType = BALANCE_TYPE_QUADRUPLET_REVEALED
    if nType == 0 then
        nBalanceType = BALANCE_TYPE_QUADRUPLET_CONCEALED
    end
    -- 结算一次刮风下雨
    self:IncreaceBalanceIndex()
    for i=1,#stFanCount do
        if stFanCount[i] < 0 then
            self:AddOneBalance(nBalanceType,  nChair, i, -1 * stFanCount[i], true)
        end
    end
    
    self:SubmitBalance()
end






-- 处理成都胡
function LibGameLogicChengdu:ProcessOPWin()
    self:ClearBalance()
    local stRoundInfo = GRoundInfo
    --成都麻将血战模式。
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
    -- 是抢杠胡牌的 todo

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

   -- 处理积分等变更
    if LOCAL_CHENGDU_XUEZHAN == GGameCfg.RoomSetting.nSubGameStyle then
        self:DoCHD_HuXZ() -- 血战模式胡 
    elseif LOCAL_CHENGDU_XUELIU == GGameCfg.RoomSetting.nSubGameStyle then
        self:DoCHD_HuXL()  -- 血流模式胡
    end

    self.m_stCHDHu = {-1, -1, -1}
end


function LibGameLogicChengdu:DoHuBalance()
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
        local stFanCount = {0, 0,0,0}
        for i=1,#stScore do
            stFanCount[i] = stScore[i] / nBaseBet
        end
        self:IncreaceBalanceIndex()
        LOG_DEBUG("DoHuBalance stFanInfo:%s stFanCount:%s", vardump(stFanInfo), vardump(stFanCount))
        for i=1,#stFanCount do
            if stFanCount[i] < 0 then
                 self:AddOneBalance(BALANCE_TYPE_WIN, nWin, i, -1*stFanCount[i], true, stFanInfo)
            end
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
          local stPlayer = GGameState:GetPlayerByChair(i)
          stPlayer:SetPlayEnd(true)
    end
  

   -- 判断是否可以继续血战。
    local nNotHu = 0 
    for i=1,PLAYER_NUMBER do
        local stPlayer = stGameState:GetPlayerByChair(i)
        if stPlayer:IsWin() == false then
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
        if stPlayer:IsWin() == false then
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
     local stFanHuaZhu = {0, 0, 0, 0}
     local nWinCount = 4
     -- 查花猪 
     for i=1,PLAYER_NUMBER do
         local stPlayer = stGameState:GetPlayerByChair(i)
         if stPlayer:IsWin() == false then
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
          if stIsWin[i] == false then
             -- 获取四个人中听牌玩家的大叫的番数
             local stPlayer = stGameState:GetPlayerByChair(i)
             local arrPlayerCards = stPlayer:GetPlayerCardGroup():ToArray()
             arrPlayerCards[#arrPlayerCards + 1] = 0
             for j=1,30 do
                 if j % 10 ~= 0 then
                     -- 检查座位为i的玩家手上的牌加上j牌是否试胡牌牌型。 
                     arrPlayerCards[#arrPlayerCards] = j
                     if LibConfirmMiss:CheckHasMissCard(i, arrPlayerCards) == false and
                        LibRuleWin:CanWin(arrPlayerCards) then
                            local nFan = self:CHD_GetFanCount(i, j)    --算算座位i上玩家手牌加牌j一起的番数。 
                            if nFan > stFanTingMax[i] then
                                stFanTingMax[i] = nFan
                            end
                     end
                 end
             end
             if stFanTingMax[i] >= 1 and  stFanTingMax[i] >= nMinFan then
                 stIsTing[i] = true
             end
          end
     end
     -- 退税
     local stScoreRecord = LibGameLogic:GetScoreRecord()
     local stScoreGainAll = {} -- 四个玩家获得分数记录
     for nChair=1,PLAYER_NUMBER do
          if stIsWin[nChair] == false then
            -- 花猪或者没有听，应该退税（退刮风下雨）。
            if stIsHuaZhu[nChair]  == true or stIsTing[nChair] == false then
                local stScoreGain  = stScoreRecord:GetAllQuadrupletScoreGain(nChair)
                -- 处理退税
                if #stScoreGain > 0 then
                    stScoreGainAll[nChair] = stScoreGain
                end
                
            end
          end
     end
     --  先退税
    self:PorcessReturnTax(stScoreGainAll)
    LOG_DEBUG("stIsWin:%s stIsTing:%s stFanTingMax:%s", vardump(stIsWin), vardump(stIsTing), vardump(stFanTingMax))
     -- 算大叫各人该得和该赔的分。 i:听的人
     local stFanTingList ={}
     for _chair=1,PLAYER_NUMBER do
         if stIsWin[_chair] == true then
            do end
         elseif (stIsTing[_chair] == false or stFanTingMax[_chair] < 1)  then
            do end
        else
            -- _chair  听, 其他未听的 给钱
            local stFanTingOne = {0,0,0,0}
            stFanTingOne[_chair] = 0
            for other=1,PLAYER_NUMBER do
                if other ~= _chair then
                    if not (stIsWin[other]  or  stIsHuaZhu[other] or stIsTing[other]  )then
                        stFanTingOne[other] =  -1*  stFanTingMax[_chair]
                        stFanTingOne[_chair] = stFanTingOne[_chair] + stFanTingMax[_chair]
                    end
                end
             end
             stFanTingList[_chair] = stFanTingOne
         end
     end
     LOG_DEBUG("stFanTingList:%s", vardump(stFanTingList))
     -- 处理花猪
     if nHuaZhuCount > 0 then
        --  一个一个算花猪
         --if stIsWin[i] == false then
         for i=1,4 do
            if stIsHuaZhu[i]  == true then
                local stFanHuaZhu = {}
                for j=1,4 do
                    if i == j then
                        stFanHuaZhu[i] = -1 * 15
                    else
                        stFanHuaZhu[i] = 5
                    end
                end
                self:ProcessHuaZhuAccount(i, stFanHuaZhu)
            end
        end
     end
     -- 处理大叫
     self:IncreaceBalanceIndex()
     for nTingChair, stFanTing in pairs(stFanTingList) do
          self:ProcessNoTingToTingAccount(nTingChair, stFanTing)
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
    print("stFanCount:%s", vardump(stFanCount))
    local nFanNum = 0
    for i=1,#stFanCount do
        nFanNum = nFanNum + stFanCount[i].byFanNumber
    end
    return nFanNum
 end


function LibGameLogicChengdu:PorcessReturnTax(stScoreGainList)
     local stScoreRecord = LibGameLogic:GetScoreRecord()
     for nChair,stScoreGain in ipairs(stScoreGainList) do
        if #stScoreGain > 0 then
            local stFan = {0, 0,0,0}
            local stScore = {0, 0,0,0}
            local nTotalFan = 0
            local nTotalScore = 0
            for _,stRecord in ipairs(stScoreGain) do
                 --stScoreRecord:AddScoreByTax(stRecord.nTarget, nChair,  stRecord.nScore)
                 --stScoreRecord:LossScoreByTax(nChair, stRecord.nTarget, stScore[nChair])
                 stFan[stRecord.nTarget] = stFan[stRecord.nTarget] + stRecord.nScore
                 nTotalFan = nTotalFan + stRecord.nFan
                 nTotalScore = nTotalScore + stRecord.nScore
            end
            stFan[nChair] = -1 * nTotalFan
            stScore[nChair] = -1 * nTotalScore

             self:IncreaceBalanceIndex()
            for i=1,#stFan do
                if stFan[i] > 0 then
                    self:AddOneTaxBalance( i, nChair, stFan[i], stScore[i] )
                end
            end
            
        end
     end


--[[
     local name = GameUtil.GetScoreRecordName(SCORE_RECORD_TYPE_TAX)
     local accountList = {}
    for nChair,stScoreGain in ipairs(stScoreGainList) do
        if #stScoreGain > 0 then
            local account = {}
            account.nType = SCORE_RECORD_TYPE_TAX
            account.name = name
            account.nFrom = "p" .. nChair
            local scoreList = {0, 0,0,0}
            local nTotal = 0
            for _,stRecord in ipairs(stScoreGain) do
                scoreList[stRecord.nTarget] = scoreList[stRecord.nTarget] + stRecord.nScore
                nTotal = nTotal + stRecord.nScore
            end
            scoreList[nChair] = -1 * nTotal
            account. scoreList = scoreList
            accountList[#accountList + 1] =  account
        end
    end

    CSMessage.NotifyReturnTaxToAll(accountList)

 ]]






        --[[
         local  stRecord = {
        bIsLoss = true,
        nType = nType,
        nTarget = nTarget,
        nScore = nScore,
        stFanInfo = stFanInfo
    }
    ]]
    --[[



    -- 总的退税结果
    local stScoreSum = {0, 0,0,0}
    for nChair,stScoreGain in ipairs(stScoreGainList) do
        for _,stRecord in ipairs(stScoreGain) do
            stScoreSum[nChair] = stScoreSum[nChair]  - stRecord.nScore
            stScoreSum[stRecord.nTarget] = stScoreSum[stRecord.nTarget]  + stRecord.nScore
        end
    end
    local stScoreRecord = LibGameLogic:GetScoreRecord()
    for nChair=1,PLAYER_NUMBER do
        if stScoreSum[nChair] > 0 then
            stScoreRecord:AddScoreByTax(nChair, 0, stScoreSum[nChair])
        elseif stScoreSum[nChair] < 0 then
            stScoreRecord:LossScoreByTax(nChair, 0, stScoreSum[nChair])
        end
    end
    -- 扣费 todo
    CSMessage.NotifyReturnTaxToAll(stScoreSum)
     ]]
end

function LibGameLogicChengdu:ProcessHuaZhuAccount(nHuazhuChair, stFanHuaZhu)
    LOG_DEBUG("stFanHuaZhu:%s", vardump(stFanHuaZhu))
    local stFan = stFanHuaZhu
     self:IncreaceBalanceIndex()
    for i=1,#stFan do
        if stFan[i] < 0 then
           self:AddOneBalance( BALANCE_TYPE_HUAZHU, i, nHuazhuChair, -1* stFan[i] )
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

