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



local LibGameLogicZhengzhou = class("LibGameLogicZhengzhou", LibBase)

function LibGameLogicZhengzhou:ctor()
    self.m_stBalanceList = {}
    self.m_nBalanceIndex = 0
end
function LibGameLogicZhengzhou:CreateInit()
   self.m_stCHDHu = {}
   self.m_stFanCountSum = {0, 0, 0, 0}
   return true
end
function LibGameLogicZhengzhou:OnGameStart()
    self.m_stCHDHu = {}
    self.m_stFanCountSum = {0, 0, 0, 0}
    self:ClearBalance()
     return true
end


function LibGameLogicZhengzhou:ClearBalance()
    self.m_stBalanceList = {}
    self.m_nBalanceIndex = 0
end

function LibGameLogicZhengzhou:FanToMul(nFan)
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
-- 结算一次番
-- 参数 类型   BALANCE_TYPE
-- 参数 番数 {3, -1, -1, -1}
-- 包括 刮风下雨 和
-- 血流模式下 如果玩家金币扣到0  将触发 认输流程
-- 扣费 最多扣到0 不做负数
-- 
function LibGameLogicZhengzhou:AddOneBalance(nType, nWinner, nLosser, nFan, bTriggerAddMoney, stFanInfo)
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
function LibGameLogicZhengzhou:SubmitBalance()
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
 
     -- 如果是血流模式 扣费到0 触发等待认输或充值操作
    if LOCAL_Zhengzhou_XUELIU == GGameCfg.RoomSetting.nSubGameStyle
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
function LibGameLogicZhengzhou:RecordOneBalance(balance)
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
function LibGameLogicZhengzhou:TransBalanceToClient(stBalanceList)

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
function LibGameLogicZhengzhou:ProcessOPQuadrupletZhengzhou(nType, nChair, nChairGive)
    self:ClearBalance()
    --     --  注:等游戏结束了才记分刮风下雨。
    if GGameCfg.RoomSetting.nGameStyle ~= GAME_STYLE_Zhengzhou  then
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
            if not ( LOCAL_Zhengzhou_XUEZHAN == GGameCfg.RoomSetting.nSubGameStyle 
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
function LibGameLogicZhengzhou:ProcessOPWin()
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
    local win_type = "selfdraw"  
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
        stWinList[#stWinList + 1] = {winner = nChair, winWho = nOnTurn, cardWin = nWinCard, wintype = win_type}
    end
               
    -- 通知胡逻辑
   LibGameLogic:DoProcessOPWin(stWinList)

   self:DoHuBalance()

   -- 处理积分等变更
    if LOCAL_Zhengzhou_XUEZHAN == GGameCfg.RoomSetting.nSubGameStyle then
        self:DoCHD_HuXZ() -- 血战模式胡 
    elseif LOCAL_Zhengzhou_XUELIU == GGameCfg.RoomSetting.nSubGameStyle then
        self:DoCHD_HuXL()  -- 血流模式胡
    end

    self.m_stCHDHu = {-1, -1, -1}
end


function LibGameLogicZhengzhou:DoHuBalance()
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
--function LibGameLogicZhengzhou:SubmitCloseWinBanlace(bTriggerAddMoney)
 --   self:AddOneBalance(BALANCE_TYPE_WIN, self.m_stFanCountSum, bTriggerAddMoney, self.m_stFanInfo)
--end

-- 血战模式胡 
function LibGameLogicZhengzhou:DoCHD_HuXZ()
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
function LibGameLogicZhengzhou:DoCHD_HuXL()
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
function LibGameLogicZhengzhou:CHD_GameNoCard()
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



 function LibGameLogicZhengzhou:CHD_GetFanCount(nChair, nCard)
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

function LibGameLogicZhengzhou:CheckQiDuiType(nChair, nCard)
    local env = LibFanCounter:CollectEnv(nChair)
    env.byChair = nChair - 1

    LibFanCounter:SetEnv(env)
    local stFanCount = LibFanCounter:GetCount()
    LOG_DEBUG("_chair:%d, card:%d, stFanCount:%s", nChair, nCard, vardump(stFanCount))
    local nFanNum = 0


    local qiduiType = 0
    local qiduiName = ""
    for i=1,#stFanCount do
        nFanNum = nFanNum + stFanCount[i].byFanNumber
        if stFanCount[i].byFanType == 4 then
            if qiduiType < 1 then
                qiduiType = 1
                qiduiName = "qidui"--"七对"
            end
        end
    end
    -- return nFanNum
    return qiduiType, qiduiName
end


function LibGameLogicZhengzhou:PorcessReturnTax(stScoreGainList)
     local stScoreRecord = LibGameLogic:GetScoreRecord()
     for nChair,stScoreGain in ipairs(stScoreGainList) do
        if #stScoreGain > 0 then
            local stFan = {0, 0,0,0}
            local nTotal = 0
            for _,stRecord in ipairs(stScoreGain) do
                 --stScoreRecord:AddScoreByTax(stRecord.nTarget, nChair,  stRecord.nScore)
                 --stScoreRecord:LossScoreByTax(nChair, stRecord.nTarget, stScore[nChair])
                 stFan[stRecord.nTarget] = stFan[stRecord.nTarget] + stRecord.nScore
                 nTotal = nTotal + stRecord.nScore
            end
            stFan[nChair] = -1 * nTotal

             self:IncreaceBalanceIndex()
            for i=1,#stFan do
                if stFan[i] > 0 then
                    self:AddOneBalance( BALANCE_TYPE_RETURN_QUADRUPLET, i, nChair, stFan[i] )
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

function LibGameLogicZhengzhou:ProcessHuaZhuAccount(nHuazhuChair, stFanHuaZhu)
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
function LibGameLogicZhengzhou:IncreaceBalanceIndex()
     self.m_nBalanceIndex = self.m_nBalanceIndex + 1
end
function LibGameLogicZhengzhou:ProcessNoTingToTingAccount(nTingChair, stScoreTing)
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



function LibGameLogicZhengzhou:ProcessOPPlayerNoMoney(stPlayer)
    LOG_DEBUG("ProcessOPPlayerNoMoney")
    SSMessage.CallPlayerAddMoney(stPlayer)
end

function LibGameLogicZhengzhou:RewardThisGame()
    -- todo: 荒牌，是否要退回原先减去的杠分
    --荒牌放到另外一个函数处理

    local nWinPlayerNums  = 0
    local bSupportGangPao = GGameCfg.GameSetting.bSupportGangPao
    local bSupportDealerAdd = GGameCfg.GameSetting.bSupportDealerAdd
    local bSupportGangFlowAdd = GGameCfg.GameSetting.bSupportGangFlowAdd
    local bSupportSevenDoubleAdd = GGameCfg.GameSetting.bSupportSevenDoubleAdd
    local bGangFlower = 0
    local bQiDui = 0

    local gang_score = {}
    local hu_score = {}      -- 几个人的得分
    local desc = {}   -- 几个人的得失分描述
    local desc_arr = {}  -- 得分详情
    local set_cards = {}
    local cards = {}
    local win_card = {}
    local win_type = {}

    --依次为自摸，点炮、明杠、暗杠、庄家加底、杠上花、七对、杠跑、荒牌次数
    local self_draw_count ={}
    local self_gun_count ={}
    local revealed_gang_count ={}
    local conceled_gang_count ={}
    local dealer_add_count ={}
    local gangflower_count ={}
    local qidui_count ={}
    local gangpao_count ={}
    local huang_pai_count ={}

    local is_no_winner = true
    for i=1,PLAYER_NUMBER do
        gang_score[i] = 0;
        hu_score[i] = 0;
        desc[i] = "";
        desc_arr[i] = {
            ming_gang_count = 0,
            an_gang_count = 0,
            hu_count = 0,
            selfdraw_count = 0
        }
        self_draw_count[i] =0
        self_gun_count[i] =0
        revealed_gang_count[i] =0
        conceled_gang_count[i] =0
        dealer_add_count[i] =0
        gangflower_count[i] =0
        qidui_count[i] =0
        gangpao_count[i] =0
        huang_pai_count[i] =0
        -- win_card[i] = 0 -- 不要用值，后面需要用数组
        win_type[i] = ""
        local stPlayer = GGameState:GetPlayerByChair(i)
        set_cards[i] = stPlayer:GetPlayerCardSet():ToArray()
        cards[i] = stPlayer:GetPlayerCardGroup():ToArray()

        if stPlayer:IsWin() then
            is_no_winner = false;
        end
    end
    --荒庄时，庄家赔底分分，若加底，加倍

    local base_score = 1 -- 底分

    --庄家加底
    if bSupportDealerAdd then
        for i=1,PLAYER_NUMBER do
            if (GRoundInfo:GetBanker() == i) then
                dealer_add_count[i] = dealer_add_count[i] +1
            end
        end
    end

    --荒牌

    if is_no_winner then
        for i=1,PLAYER_NUMBER do
            huang_pai_count[i] =huang_pai_count[i] +1
            if (GRoundInfo:GetBanker() == i) then
                hu_score[i] = -PLAYER_NUMBER*base_score+base_score
                if bSupportDealerAdd then
                    hu_score[i] = hu_score[i] *2
                end
            else
                hu_score[i] = base_score
                if bSupportDealerAdd then
                    hu_score[i] = hu_score[i] *2
                end
            end
        end
    else
        for i=1,PLAYER_NUMBER do
            local stPlayer = GGameState:GetPlayerByChair(i)
            

            -- 算杠分
    --    杠分分为明杠和暗杠，明杠和被杠人计算杠分，暗杠和三家都计算杠分
    --    杠分均为1分
    --    如果计算基数，则杠分=杠分*基数
    --    杠跑为玩家开房时的勾选项，如果玩家勾选了，则在牌局结束时，杠分的计算公式如下：
    --    杠分=底分+赢方跑数+输方跑数
    --      庄家家底时，和庄家结算底分*2
            local stCardSet = stPlayer:GetPlayerCardSet()
            for n=1,stCardSet:GetCurrentLength() do
                local sets = stCardSet:GetCardSetAt(n)
                
                for j=1,PLAYER_NUMBER do

                    --玩家i不是庄家，j是庄家时，底分*2
                    local new_base_score = base_score
                    if bSupportDealerAdd and ((GRoundInfo:GetBanker() == j) or (GRoundInfo:GetBanker() == i))then 
                        new_base_score =base_score*2
                    end

                    if sets.ucFlag == ACTION_QUADRUPLET or sets.ucFlag == ACTION_QUADRUPLET_REVEALED then
                        -- 明杠补杠，只跟输方结算
                        if j ~= i then
                            if j == sets.value then
                                local this_core = new_base_score
                                if bSupportGangPao then
                                    this_core = this_core + LibXiaPao:GetPlayerXiaPao(i) + LibXiaPao:GetPlayerXiaPao(j)
                                end
                                gang_score[j] = gang_score[j] - this_core
                                gang_score[i] = gang_score[i] + this_core
                                -- desc[i] = desc[i] .."明杠+1,"
                                desc_arr[i].ming_gang_count = desc_arr[i].ming_gang_count + 1
                                revealed_gang_count[i] =revealed_gang_count[i] +1
                                if bSupportGangPao then
                                    gangpao_count[i] = gangpao_count[i]+1
                                end
                            end
                        end
                    elseif sets.ucFlag == ACTION_QUADRUPLET_CONCEALED then
                        -- ACTION_QUADRUPLET_CONCEALED --暗杠
                        if j ~= i then
                            local this_core = new_base_score
                            if bSupportGangPao then
                                this_core = this_core + LibXiaPao:GetPlayerXiaPao(i) + LibXiaPao:GetPlayerXiaPao(j)
                            end
                            gang_score[j] = gang_score[j] - this_core
                            gang_score[i] = gang_score[i] + this_core
                        else
                            desc_arr[i].an_gang_count = desc_arr[i].an_gang_count + 1
                            conceled_gang_count[i] = conceled_gang_count[i] +1
                            if bSupportGangPao then
                                gangpao_count[i] = gangpao_count[i]+1
                            end
                        end
                    else
                        -- 其它，不算分
                        -- continue;
                    end
                end
            end-- for player gangscore
        end
            -- 算胡分
    -- 5.3杠上花加倍
    --    杠上花为玩家开房时的勾选项，玩家勾选后生效
    --    杠上花为玩家杠牌（包括明杠和暗杠）后，下一次摸牌的时候刚好胡，因此杠上花是胡牌玩家的专利
    --    当玩家开房时勾选了杠上花，则在牌局结束，结算时，胡牌分*2

    -- 5.4七对加倍
    --    七对加倍为玩家开房时的勾选项，玩家勾选后生效
    --    七对为胡牌牌型的一种，即玩家胡牌时，全是对子（14张牌刚好7对）
    --    当玩家开房时勾选了七对加倍，则在牌局结束，结算时，胡牌分*2


    --      胡牌分=底分+赢方跑数+输方跑数
    --      和庄家结算时 ：胡牌分=底分*2+赢方跑数+输方跑数
        for i=1,PLAYER_NUMBER do
            local stPlayer = GGameState:GetPlayerByChair(i)

            if stPlayer:IsWin() == true then

                win_card[i] = stPlayer:GetPlayerWinCards()[1] -- wins
                
                if GRoundInfo:GetWhoIsOnTurn()==i then
                    win_type[i] = "selfdraw"--"自摸"--"selfdraw"
                    desc_arr[i].selfdraw_count = desc_arr[i].selfdraw_count + 1
                    self_draw_count[i] = self_draw_count[i] +1
                else
                    win_type[i] = "gunwin"--"放枪"--"gunwin"
                    desc_arr[i].hu_count = desc_arr[i].hu_count + 1
                    self_gun_count[i] = self_gun_count[i] +1
                end
                
                -- todo: 杠上花
                bGangFlower = false
                if GRoundInfo:GetGang() and GRoundInfo:GetWhoIsOnTurn()==i then
                    bGangFlower = true;
                    win_type[i] = "gangflower"--"杠上花"--"gangflower"
                    gangflower_count[i] = gangflower_count[i] +1
                end

                -- todo: 七对
                local qiduiType, qiduiName = LibGameLogicZhengzhou:CheckQiDuiType(i, win_card[i]);

                bQiDui = 0
                if qiduiType ~= 0 then
                    bQiDui = qiduiType;
                    win_type[i] = qiduiName --"qidui"
                    qidui_count[i] = qidui_count[i]+1
                end

                for j=1,PLAYER_NUMBER do
                    if i ~= j then
                        --玩家i不是庄家，j是庄家时，底分*2
                        local new_base_score = base_score
                        if bSupportDealerAdd and ((GRoundInfo:GetBanker() == j) or (GRoundInfo:GetBanker() == i))then 
                            new_base_score =base_score*2
                        end
                        local this_core = new_base_score + LibXiaPao:GetPlayerXiaPao(i) + LibXiaPao:GetPlayerXiaPao(j)

                        if bSupportGangFlowAdd and bGangFlower then
                            this_core = this_core * 2
                        end
                        if bSupportSevenDoubleAdd and bQiDui ~= 0 then
                            this_core = this_core * (2 ^ bQiDui)
                        end
                        LOG_DEBUG(" %d + %d + %d = %d", new_base_score, LibXiaPao:GetPlayerXiaPao(i), LibXiaPao:GetPlayerXiaPao(j), this_core)

                        hu_score[j] = hu_score[j] - this_core
                        hu_score[i] = hu_score[i] + this_core
                    end
                end

                -- nWinPlayerNums = nWinPlayerNums + 1
            end
        end-- for player huscore

    end -- is_no_winner

    local stScoreRecord = LibGameLogic:GetScoreRecord()
    for i=1, PLAYER_NUMBER do
        local stPlayer = GGameState:GetPlayerByChair(i)
        local uinfo = stPlayer:GetUserInfo()
        if desc_arr[i].ming_gang_count ~= 0 then
            if string.len(desc[i]) > 0 then
                desc[i] = desc[i] ..", "
            end
            desc[i] = desc[i] .."明杠+".. desc_arr[i].ming_gang_count
        end
        if desc_arr[i].an_gang_count ~= 0 then
            if string.len(desc[i]) > 0 then
                desc[i] = desc[i] ..", "
            end
            desc[i] = desc[i] .."暗杠+".. desc_arr[i].an_gang_count
        end
        if desc_arr[i].hu_count ~= 0 then
            if string.len(desc[i]) > 0 then
                desc[i] = desc[i] ..", "
            end
            desc[i] = desc[i] .."胡牌+".. desc_arr[i].hu_count
        end
        if desc_arr[i].selfdraw_count ~= 0 then
            if string.len(desc[i]) > 0 then
                desc[i] = desc[i] ..", "
            end
            desc[i] = desc[i] .."自摸+".. desc_arr[i].selfdraw_count
        end
        local rec = {
            _chair       = "p" ..i,
            _uid         = uinfo._uid,
            xiapao      = LibXiaPao:GetPlayerXiaPao(i),
            gang_score  = gang_score[i],
            hu_score    = hu_score[i],
            all_score   = gang_score[i] + hu_score[i],
            score_desc  = desc[i],
            combineTile = set_cards[i],
            discardTile = stPlayer:GetPlayerGiveGroup():ToArray(),
            cards       = cards[i],
            win_card    = {win_card[i]},
            win_type    = win_type[i],
            self_draw_count     =self_draw_count[i],
            self_gun_count      =self_gun_count[i],
            revealed_gang_count =revealed_gang_count[i],
            conceled_gang_count =conceled_gang_count[i],
            huang_pai_count     =huang_pai_count[i],
        }
        if bSupportGangPao then
           rec.gangpao_count    =gangpao_count[i]
        end
        if bSupportDealerAdd then
           rec.dealer_add_count =dealer_add_count[i]
        end 
        if bSupportGangFlowAdd then
           rec.gangflower_count =gangflower_count[i]
        end 
        if bSupportSevenDoubleAdd then
           rec.qidui_count      =qidui_count[i]
        end 
        LOG_DEBUG("WHEN rec==================,  rec=%s",vardump(rec))
        stScoreRecord:SetRecordByChair(i, rec)
        stScoreRecord:SetPlayerSumScore(i, rec.all_score)
        --test 更新金币积分
        local nAdd = gang_score[i] + hu_score[i]
        --stPlayer:AddScore(nAdd)
        --stPlayer:AddMoney(nAdd * 10)
    end
end

-- function LibGameLogicZhengzhou:RewardThisGameNoCard()
--     --荒牌，杠分不扣；庄家负一分
--     LOG_DEBUG("huangpai ======")
--     local nWinPlayerNums  = 0
--     local bSupportGangPao = GGameCfg.GameSetting.bSupportGangPao
--     local bGangFlower = 0
--     local bQiDui = 0

--     local gang_score = {0,0,0,0}
--     local hu_score = {0, 0, 0, 0}      -- 几个人的得分
--     local desc = {"", "", "", ""}   -- 几个人的得失分描述
--     local set_cards = {}
--     local cards = {}
--     local win_card = {}

--     -- todo: 杠上花
--     --  荒牌无
--     -- todo: 七对
--     -- 荒牌无
--     for i=1,PLAYER_NUMBER do
--         local base_score = 1 -- 底分
--         local stPlayer = GGameState:GetPlayerByChair(i)
--         set_cards[i] = stPlayer:GetPlayerCardSet():ToArray()
--         cards[i] = stPlayer:GetPlayerCardGroup():ToArray()
--         win_card[i] = 0

--         LOG_DEBUG("huangpai cards[%d]=%s", i, vardump(cards[i]))
--         LOG_DEBUG("huangpai set_cards[%d]=%s, len=%d", i, vardump(set_cards[i]), stPlayer:GetPlayerCardSet():GetCurrentLength())

--         -- 庄家加底
--         if GRoundInfo:GetBanker() == i then
--             base_score = base_score * 2
--         end
--         -- 算杠分
-- --    荒牌时 杠分不计
--         gang_score[i] = GGameCfg.RoomSetting.nNoCardGangCount

--         -- 算胡分
-- --      荒牌时，庄家扣3分，其余得一分
--         hu_score[i] = GGameCfg.RoomSetting.nNoCardWinCount
--         if GRoundInfo:GetBanker() == i then
--             hu_score[i] = -(GGameCfg.RoomSetting.nNoCardWinCount)*(PLAYER_NUMBER-1)
--         end
--     end -- for player

--     local stScoreRecord = LibGameLogic:GetScoreRecord()
--     for i=1, PLAYER_NUMBER do
--         local rec = {
--             _chair = "p" ..i,
--             xiapao = LibXiaPao:GetPlayerXiaPao(i),
--             gang_score = gang_score[i],
--             hu_score = hu_score[i],
--             score_desc = desc[i],
--             set_cards = set_cards[i],
--             cards = cards[i],
--             win_card = win_card[i]
--         }

--         stScoreRecord:SetRecordByChair(i, rec)
--     end
-- end
return LibGameLogicZhengzhou

