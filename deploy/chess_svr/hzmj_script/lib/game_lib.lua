local LibBase = import(".lib_base")
import("core.game_util")
local PlayerBlockState = import("core.player_block_state")
local PlayerCardGroup =  import("core.player_cardgroup")
local ScoreRecord = import("core.score_record")

local stGameState = nil
local stRoundInfo = nil
local LibGameLogic = class("LibGameLogic", LibBase)
function LibGameLogic:ctor()
    self.m_stBlockState = {}              -- 吃碰杠胡 状态
    --self.m_bNeedDraw = false
    self.m_stScoreRecord = ScoreRecord.new()
end
function LibGameLogic:CreateInit(strSlotName)
    for i=1,PLAYER_NUMBER do
        self.m_stBlockState[i] = PlayerBlockState.new()
    end
    --self.m_bNeedDraw = true
    stGameState = GGameState
    stRoundInfo = GRoundInfo
    return true
end
function LibGameLogic:OnGameStart()
    self.m_stScoreRecord:Init()
    for i=1,PLAYER_NUMBER do
        self.m_stBlockState[i]:Clear()
    end
    self.m_bGameOver = false
   -- self.m_bNeedDraw = true
end


--[[ 
function LibGameLogic:SetNeedDraw(bNeedDraw)
    self.m_bNeedDraw = bNeedDraw
end
--]]
function LibGameLogic:GetScoreRecord()
    return self.m_stScoreRecord
end

function LibGameLogic:GetPlayerBlockState(nChair)
    return self.m_stBlockState[nChair]
end

function LibGameLogic:ClearAllBlock()
     for i=1,PLAYER_NUMBER do
        if self.m_stBlockState[i]:IsBlocked() then
            self.m_stBlockState[i]:Clear()
        end
     end
end

--  处理玩家打牌
function LibGameLogic:ProcessOPPlay(stPlayer, nCard)
    -- 清除自己的 block
    local nChair = stPlayer:GetChairID()

    local stPlayerBlockState = self.m_stBlockState[nChair]
    if stPlayerBlockState:IsBlocked() then
        stPlayerBlockState:Clear()
    end

    LOG_DEBUG("LibGameLogic:ProcessOPGive Chair:%d Card:%d\n", nChair, nCard)
    local stPlayerCardGroup = stPlayer:GetPlayerCardGroup()
    local stPlayerGiveGroup = stPlayer:GetPlayerGiveGroup()

    if stPlayerCardGroup:IsHave(nCard) == false then
        LOG_DEBUG("stPlayerCardGroup:IsHave(nCard) == false card:%d\n", nCard)
        return ERROR_PLAYER_NOT_HAVE_THISCARD
    end

    --只要出过牌都设为true，作为判断天地胡的依据之一
    stPlayer:SetPlayCardsAlready()
    
    if stPlayer:IsTing() == true then
        if LibRuleTing:IsTingCanPlayOther() == false then
            if nCard ~= stPlayerCardGroup:GetLastDraw() then
                return ERROR_PLAYER_TING_PLAY_OTHERCARD
            end
        end
    end
    stPlayerCardGroup:DelCard(nCard)
    -- todo
    stPlayerGiveGroup:AddCard(nCard)
    local stRoundInfo = GRoundInfo
    if stRoundInfo:GetGang() == true then
        LOG_DEBUG("===check ganggive ===")
        stRoundInfo:SetGiveStatus(GIVE_STATUS_GANGGIVE)
        stRoundInfo:SetGang(false)
    else
        stRoundInfo:SetGiveStatus(GIVE_STATUS_NONE)
    end
	
    stRoundInfo:SetLastGive(nCard)
	stRoundInfo:SetLastGiveChair(nChair)
	
    local nChair = stRoundInfo:GetWhoIsOnTurn()
    LOG_DEBUG("==========stRoundInfo:GetWhoIsOnTurn() Chair:%d \n", nChair)
    stRoundInfo:SetNeedDraw(true)
    stRoundInfo:SetWhoIsNextTurn(LibTurnOrder:GetNextTurn(nChair))
    stRoundInfo:AddCardShowNum(nCard)
    --stRoundInfo:SetNeedDraw(true)
    --stRoundInfo:SetWhoIsOnTurn(LibTurnOrder:GetNextTurn(nChair))
    -- send call to other.
    CSMessage.NotifyPlayerPlayCard(stPlayer, {nCard})
    SSMessage.CallOtherPlayerGive(stPlayer, nCard)

    return 0
end


function LibGameLogic:ProcessOPCollect(stPlayer, nCard, nCardFirst)
    -- check

    local nGiveChair = stRoundInfo:GetWhoIsOnTurn()
    local stGivePlayer = GGameState:GetPlayerByChair(nGiveChair)
    local stGvieCardGroup = stGivePlayer:GetPlayerGiveGroup()
    stGvieCardGroup:DelCardLast(nCard)
    local stPlayerCardGroup = stPlayer:GetPlayerCardGroup()
    local stPlayerCardCardSet = stPlayer:GetPlayerCardSet()
    local nIndex = 0
    for i=0,2 do
        if nCardFirst + i == nCard then
            nIndex = i
            break
        end
    end
    stPlayerCardCardSet:AddSetCard(ACTION_COLLECT, nCardFirst, nIndex)
    for i=0,2 do
        if i ~= nIndex then
            stPlayerCardGroup:DelCard(nCardFirst+i)
            --stRoundInfo:AddCardShowNum(nCardFirst+i)
        end
    end

    stRoundInfo:SetNeedDraw(false)
    stRoundInfo:SetWhoIsNextTurn(stPlayer:GetChairID())
    --增加吃状态下发（吃的牌和组成的牌组）
    local stPlayerBlockState = LibGameLogic:GetPlayerBlockState(stPlayer:GetChairID())
    local nCollectCardGroup = stPlayerBlockState:GetCardCollectGroup()
    CSMessage.NotifyBlockCollect(stPlayer, nGiveChair, nCard,nCollectCardGroup)
    self:ClearAllBlock()
end
function LibGameLogic:ProcessOPTriplet(stPlayer, nCard)
    -- todo
    local nTurn = stRoundInfo:GetWhoIsOnTurn()
    LOG_DEBUG("ProcessOPTriplet")
    local stPlayerCardGroup = stPlayer:GetPlayerCardGroup()
    stPlayerCardGroup:Print()
    if stPlayerCardGroup:IsHaveDouble(nCard) then
        local stPlayerCardSet = stPlayer:GetPlayerCardSet()
        stPlayerCardSet:AddSetCard(ACTION_TRIPLET, nCard, nTurn)
        stPlayerCardGroup:DelCard(nCard)
        stPlayerCardGroup:DelCard(nCard)

        -- 清除被碰玩家台面牌
        
        local nGiveChair = stRoundInfo:GetWhoIsOnTurn()
        local stGivePlayer = GGameState:GetPlayerByChair(nGiveChair)
        local stGvieCardGroup = stGivePlayer:GetPlayerGiveGroup()
        LOG_DEBUG("to clean triplet, before=%s", vardump(stGvieCardGroup:ToArray()));
        stGvieCardGroup:DelCardLast(nCard)
        LOG_DEBUG("to clean triplet, after=%s", vardump(stGvieCardGroup:ToArray()));

        -- 通知其他玩家碰牌
    end
    stPlayerCardGroup:Print()
    LOG_DEBUG("ProcessOPTriplet end")
    stRoundInfo:SetNeedDraw(false)
    stPlayerCardGroup:SetLastDraw(0)
    stRoundInfo:SetWhoIsNextTurn(stPlayer:GetChairID())
    stRoundInfo:AddCardShowNum(nCard)
    stRoundInfo:AddCardShowNum(nCard)
    CSMessage.NotifyBlockTriplet(stPlayer, nTurn, nCard)
    self:ClearAllBlock()
    
    local nCount = LibConfirmMiss:GetMissCardCount(stPlayer)
    if nCount < 2 then  -- 缺牌少于2张
        local envtest = LibFanCounter:CollectEnv(stPlayer:GetChairID())
        LibFanCounter:SetEnv(envtest)
        local stTingInfo = LibFanCounter:GetTingInfo()

        if stPlayer:IsWin() == false and #stTingInfo > 0 then
            CSMessage.NotifyPlayerBlockTing(stPlayer, stTingInfo)
        end
    end
end
function LibGameLogic:ProcessOPQuadruplet(stPlayer, nCard)
    LOG_DEBUG("LibGameLogic:ProcessOPQuadruplet");
    local nTurn = stRoundInfo:GetWhoIsOnTurn()
    local nChair = stPlayer:GetChairID()
    local stQuadrupletCardGroup = PlayerCardGroup.new()
    stQuadrupletCardGroup:AddCard(nCard)
    stQuadrupletCardGroup:AddCard(nCard)
    stQuadrupletCardGroup:AddCard(nCard)
    stQuadrupletCardGroup:AddCard(nCard)
    local stPlayerCardSet = stPlayer:GetPlayerCardSet()

    --参数 nType : 0--下雨 , 1--自己刮风, 2--他人给自己刮风
    local stPlayerCardGroup = stPlayer:GetPlayerCardGroup()
    local ntype =-1
	local nBaseBet = GGameCfg.RoomSetting.nBaseBet  --杠分底分
	
    if  nTurn == nChair then
        -- 自己杠  暗杠 碰上加杠
        if  stQuadrupletCardGroup:IsSubSet(stPlayerCardGroup) then
            LOG_DEBUG("ProcessOPQuadruplet group begin ");
            stPlayerCardGroup:Print()
            LOG_DEBUG("stQuadrupletCardGroup:IsSubSet(stPlayerCardGroup) ")
            -- 都在手牌  暗杠
            stPlayerCardGroup:DelCardGroup(stQuadrupletCardGroup)
            LOG_DEBUG("ProcessOPQuadruplet group end");
            stPlayerCardGroup:Print()
            stPlayerCardSet:AddSetCard(ACTION_QUADRUPLET_CONCEALED, nCard, nTurn)  
            -- 通知 杠
            --下雨
            GRoundInfo:SetGiveStatus(GIVE_STATUS_GANG)
            ntype =0
            GRoundInfo:SetGangType(ntype)  --记录杠牌类型
            CSMessage.NotifyBlockQuadruplet(stPlayer, nCard, nTurn, ACTION_QUADRUPLET_CONCEALED)
        elseif stPlayerCardSet:Triplet2Quadruplet(nCard) == true then
            LOG_DEBUG("Triplet2Quadruplet group begin ");
            stPlayerCardGroup:Print()
            LOG_DEBUG("stPlayerCardSet:Triplet2Quadruplet(nCard) == true")
            stPlayerCardGroup:DelCard(nCard)
            stPlayerCardGroup:Print()
            LOG_DEBUG("Triplet2Quadruplet group end ");
            GRoundInfo:SetGiveStatus(GIVE_STATUS_GANG)
            --碰后杠
            ntype = 1
            GRoundInfo:SetGangType(ntype)  --记录杠牌类型
            -- 通知 杠
            CSMessage.NotifyBlockQuadruplet(stPlayer, nCard, nTurn, ACTION_QUADRUPLET_REVEALED)
            stRoundInfo:AddCardShowNum(nCard)
        else
            LOG_DEBUG("ERROR_BLOCK_QUADRUPLET")
            return ERROR_BLOCK_QUADRUPLET
        end
    else
        LOG_DEBUG(" nTurn ~= nChair ");
        -- 杠 别人的  三张牌在自己的手牌  
        -- 如果先碰了 不是自己摸到的，是不能杠的
        LOG_DEBUG("nTurn ~= nChair Quadruplet group begin give");
        local stTripletGroup = PlayerCardGroup.new()
        stTripletGroup:AddCard(nCard)
        stTripletGroup:AddCard(nCard)
        stTripletGroup:AddCard(nCard)
        if stTripletGroup:IsSubSet(stPlayerCardGroup) == false then
            return ERROR_BLOCK_QUADRUPLET
        end
        -- 清除被杠玩家台面牌
        local stGivePlayer = GGameState:GetPlayerByChair(nTurn)
        local stGvieCardGroup = stGivePlayer:GetPlayerGiveGroup()
        stGvieCardGroup:DelCardLast(nCard)

        stPlayerCardGroup:DelCardGroup(stTripletGroup)
        LOG_DEBUG("nTurn ~= nChair Quadruplet group end");
        stPlayerCardSet:AddSetCard(ACTION_QUADRUPLET, nCard, nTurn)
        CSMessage.NotifyBlockQuadruplet(stPlayer, nCard, nTurn, ACTION_QUADRUPLET)
        GRoundInfo:SetGiveStatus(GIVE_STATUS_GANG)
        --引杠
        ntype = 2

        GRoundInfo:SetGangType(ntype)  --记录杠牌类型
        GRoundInfo:SetGangWho(stGivePlayer:GetChairID())  --直杠刮风记录被杠玩家

        stRoundInfo:AddCardShowNum(nCard)
        stRoundInfo:AddCardShowNum(nCard)
        stRoundInfo:AddCardShowNum(nCard)
    end

    stRoundInfo:SetGang(true)

    local arrPlayerCards = stPlayerCardGroup:ToArray()
    LOG_DEBUG("LibGameLogic:ProcessOPQuadruplet ...arrPlayerCards=%s", vardump(arrPlayerCards))

    GRoundInfo:SetNeedDraw(true)
    stRoundInfo:SetWhoIsNextTurn(stPlayer:GetChairID())
    LOG_DEBUG("===LibGameLogic:ProcessOPQuadruplet ...gang type=%d", ntype)

    if ntype == 1 then
        stRoundInfo:SetIsQiangGang(true)
        stRoundInfo:SetPengGangCard(nCard)
        stRoundInfo:SetPengGangPlayer(nChair)
        -- 设置 记录 过手杠
        stRoundInfo:SetGuoShouGang(false)
        if stPlayerCardGroup:GetLastDraw() ~= nCard then
            stRoundInfo:SetGuoShouGang(true)    -- 设置过手杠标志
            LOG_DEBUG("GUOSHOUGANG chair = %d @@@ Gangcard = %d @@@ LastCard = %d", nChair, nCard, stPlayerCardGroup:GetLastDraw())
        end
    end
    
    LibGameLogicChengdu:ProcessOPQuadrupletChengdu(ntype, nChair, nTurn)
        
    stPlayerCardGroup:SetLastDraw(0)
    self:ClearAllBlock()
    if ntype ==1 then
        SSMessage.CallOtherPlayerQiangGang(stPlayer, nCard)       
    end

    return 0
end

function LibGameLogic:ProcessOPTing(stPlayer, nCard)
    stPlayer:SetTing(TING_CONCEALED)
end

-- [ {winner = nChair, winWho = nOnTurn, cardWin = nWinCard}]
function LibGameLogic:DoProcessOPWin(stWinList)
    local stDelRecord =  {}
    local stGameState = GGameState
    for i=1,#stWinList do
        local stOneWin = stWinList[i]
        local nFlag = 0
        local nWhoGun = 0
        local stPlayerWin = stGameState:GetPlayerByChair(stOneWin.winner)
        local cards = stPlayerWin:GetPlayerCardGroup():ToArray()
        stWinList[i].cards =cards
        LOG_DEBUG("=========111===stWinList[i].cards:%s",vardump(stWinList[i].cards))
        if stOneWin.winner == stOneWin.winWho  then
            nFlag = WIN_SELFDRAW
            stPlayerWin:AddPlayerWinCard(stOneWin.cardWin)
        else
            nFlag = WIN_GUN
            nWhoGun = stOneWin.winWho
            stPlayerWin:AddPlayerWinCard(stOneWin.cardWin)
            local stPlayerGun = stGameState:GetPlayerByChair(stOneWin.winWho)
            -- 最多扣一张牌
            if stDelRecord[stOneWin.winWho] == nil then
                stPlayerGun:GetPlayerGiveGroup():DelCardLast(stOneWin.cardWin)
                stDelRecord[stOneWin.winWho]  = 1
            end
        end
        stPlayerWin:SetIsWin(true)
        stRoundInfo:SetWinList(stPlayerWin:GetChairID())
        stRoundInfo:SetWhoIsNextTurn(LibTurnOrder:GetNextTurn(stPlayerWin:GetChairID()))
    end
    self:ClearAllBlock()
    --郑州麻将不用发win，其他麻将有一炮多响的情况需要发
    CSMessage.NotifyPlayerWin(stWinList)
end
--  处理玩家赢
function LibGameLogic:ProcessOPWin(stPlayer, nCard)
    
    -- 最后出牌的人
    local lastTurnChair = stRoundInfo:GetWhoIsOnTurn() 
    -- 算番等结算
    -- 检查是否可胡
    -- 设置当前胡
    GRoundInfo:SetLastWinner(stPlayer:GetChairID())
    if  GGameCfg.RoomSetting.nGameStyle ==  GAME_STYLE_CHENGDU then
        -- 成都麻将 和操作
        LibGameLogicChengdu:ProcessOPWin(nCard)
    else
        -- 游戏结束
         local stWinData= {winner = stPlayer:GetChairID(), winWho = lastTurnChair, cardWin = nCard}
        self:DoProcessOPWin({stWinData})

        GRoundInfo:SetNeedDraw(false)
        --stPlayer:GetPlayerCardGroup():SetLastDraw(0)
    end
    
    self:ClearAllBlock()
end

function LibGameLogic:RewardThisGame()
    if  GGameCfg.RoomSetting.nGameStyle ==  GAME_STYLE_CHENGDU then
        LibGameLogicChengdu:RewardThisGame()
    else
        local nWinPlayerNums  = 0
        for i=1,PLAYER_NUMBER do
            
            if stRoundInfo:IsWin(i) == true then
                nWinPlayerNums = nWinPlayerNums + 1
            end
        end
        if nWinPlayerNums > 0 then
            self:RewardWinner()
        else
            self:GameOverNoCard()
        end
     end
end
function LibGameLogic:RewardWinner()
end

-- 荒牌
function LibGameLogic:GameOverNoCard()
    if  GGameCfg.RoomSetting.nGameStyle ==  GAME_STYLE_CHENGDU then
        LibGameLogicChengdu:CHD_GameNoCard()
    else

    end
end


-- winner = stPlayer:GetChairID(), winWho = lastTurnChair, cardWin = nCard
--[[
function LibGameLogic:ProcessGameOver(stWinData)
    -- 处理游戏结束
    -- 算番 
    -- 
end
--]]
-- 根据当前状态判断是否已经能够Block了
-- 结算一次挡牌过程
-- return true  挡牌得到处理 或者没有挡牌
-- return false 挡牌没有处理 需要等待
function LibGameLogic:ProcessOPSwitchBlock()
    LOG_DEBUG("ProcessOPSwitchBlock")
    local stBlockState = nil
    local bIsHasBlock = false

    --1.检查玩家是否有block
    for i=1,PLAYER_NUMBER do
        stBlockState = self:GetPlayerBlockState(i)
        if stBlockState:IsBlocked() then
            bIsHasBlock = true
            LOG_DEBUG("stBlockState:IsBlocked() ")
            break
        end
    end
    if bIsHasBlock == false then
        LOG_DEBUG("stBlockState:IsBlocked() false")
        return true
    end

    local nChair = 0
    local nWho = 0
    local nLevel = ACTION_EMPTY
    local nFlag = ACTION_EMPTY
    local stBlockStates = {}
    --3.检查玩家已经操作(也就是点击了吃碰杠胡)的最高优先级
    nChair = stRoundInfo:GetWhoIsOnTurn()
    for i=1, PLAYER_NUMBER do
        -- 从出牌人的下家开始检查
        nChair = LibTurnOrder:GetNextTurn(nChair)
        stBlockState = self:GetPlayerBlockState(nChair)
        nFlag = stBlockState:GetBlockRecordFlag()
        if nFlag > nLevel then
            nLevel = nFlag  --优先级
            nWho = nChair   --谁
        end
    end
    LOG_DEBUG("SwitchBlock...user play... nWho:%d , nLevel:%d", nWho, nLevel)

    --4.检查没有操作的玩家优先级，比较已经操作玩家的优先级nWho--nLevel
    local nCollect, nTriplet, nQuadruplet, nWin  = 0, 0, 0, 0
    for i=1,PLAYER_NUMBER do
        stBlockState = self:GetPlayerBlockState(i)
        nFlag = stBlockState:GetBlockRecordFlag()

        if nFlag == 0 then
            nCollect = stBlockState:GetCollect()
            nTriplet = stBlockState:GetTriplet()
            nQuadruplet = stBlockState:GetQuadruplet ()
            nWin = stBlockState:GetWin()
            local nThisLevel = 0
            if nCollect > 0 then
                nThisLevel = nCollect
            end
            if nTriplet  > 0 then
                nThisLevel = nTriplet
            end
            if nQuadruplet  > 0 then
                nThisLevel = nQuadruplet
            end
            if nWin  > 0 then
                nThisLevel = nWin
            end
            --玩家当前可以操作的最高等级 和 其他玩家操作的最高等级比较
            if nThisLevel > nLevel then
                --4.1如果自己等级高  其他人的操作不响应。
                LOG_DEBUG("SwitchBlock User No Action _chair:%d nThisLevel:%d\n", i, nThisLevel)
                return  false
            elseif nThisLevel == nLevel then
                if nThisLevel == ACTION_WIN 
                    and GGameCfg.RoomSetting.nGameStyle == GAME_STYLE_CHENGDU  then
                    --成都麻将在这里要支持一炮多响
                    LOG_DEBUG("还有人可以胡,ucItLevel == ACTION_WIN && ucLevel == ACTION_WIN\r\n");
                    return false
                end

                --4.2优先级相等 从出牌人的下家开始检查，看谁在前面
                nChair = stRoundInfo:GetWhoIsOnTurn() 
                for j=1,PLAYER_NUMBER do
                    nChair = LibTurnOrder:GetNextTurn(nChair)
                    if i == nChair then
                        -- 自己在前面，大家再等等吧
                        LOG_DEBUG("SwitchBlock User No Action _chair:%d\n", nChair)
                        return false
                    end
                    if nWho == nChair then
                        break
                    end
                end
            end
        end
    end

    -- 下面所有玩家都已经操作了
    local nResult = 0
    --5.检查是否所有人都Cancel了
    for i=1, PLAYER_NUMBER do
        stBlockState = self:GetPlayerBlockState(i)
        nCollect = stBlockState:GetCollect()
        nTriplet = stBlockState:GetTriplet()
        nQuadruplet = stBlockState:GetQuadruplet ()
        nWin = stBlockState:GetWin()
        nResult = nResult + nCollect
        nResult = nResult + nTriplet
        nResult = nResult + nQuadruplet
        nResult = nResult + nWin
    end
    if nResult == 0 then
        -- 所有玩家都Cancel了 则继续游戏
        LOG_DEBUG("nResult == 0 ")
        local nextChair = LibTurnOrder:GetNextTurn(stRoundInfo:GetWhoIsOnTurn() )
        stBlockState:SetWhoIsNextTurn(nextChair)
        return true
    end

    --6.有玩家拦牌，则按优先级查询
    -- 从出牌的人下家开始检查

    --2.检查是否还有block没有操作
    for i=1,PLAYER_NUMBER do
        stBlockState = self:GetPlayerBlockState(i)
        if stBlockState:IsBlocked() and stBlockState:GetBlockRecordFlag() == 0 then
            LOG_DEBUG("stBlockState:have player not do")
            FlowFramework.SetTimer(i, 0)
            --return  false
        end
    end

    --6.1处理和
    bIsProcessed = true
    nChair = stRoundInfo:GetWhoIsOnTurn()
    for i=1,PLAYER_NUMBER do
        nChair = LibTurnOrder:GetNextTurn( nChair )
        stBlockState = self:GetPlayerBlockState(nChair)
        if stBlockState:GetBlockRecordFlag() == ACTION_WIN then
            local stPlayer = stGameState:GetPlayerByChair(nChair)
            LOG_DEBUG("WhoIsOnTurn:%d !!!!!!!!!!!!!\n", stRoundInfo:GetWhoIsOnTurn());
            self:ProcessOPWin(stPlayer, stBlockState:GetBlockaRecordCard())
            stBlockState:ClearGuoShouHu()  -- 胡后清除 过手胡标志
            return bIsProcessed
        end
    end
    --6.2处理杠
    nChair = stRoundInfo:GetWhoIsOnTurn()
    for i=1,PLAYER_NUMBER do
        nChair = LibTurnOrder:GetNextTurn( nChair )
        local stPlayer = stGameState:GetPlayerByChair(nChair)
        stBlockState = self:GetPlayerBlockState(nChair)
        if stBlockState:GetBlockRecordFlag() == ACTION_QUADRUPLET then
            LOG_DEBUG("==111111=LibGameLogic:ACTION_QUADRUPLET true...")
            local nRecordCard = stBlockState:GetBlockaRecordCard()
            self:ProcessOPQuadruplet(stPlayer, nRecordCard)
            stBlockState:ClearGuoShouHu()  -- 杠后清除上一轮 过手胡标志
            return bIsProcessed
        end
    end

    --6.3处理碰
    nChair = stRoundInfo:GetWhoIsOnTurn()
    for i=1,PLAYER_NUMBER do
        nChair = LibTurnOrder:GetNextTurn( nChair )
        local stPlayer = stGameState:GetPlayerByChair(nChair)
        stBlockState = self:GetPlayerBlockState(nChair)
        if stBlockState:GetBlockRecordFlag() == ACTION_TRIPLET then
            local nRecordCard = stBlockState:GetBlockaRecordCard()
            self:ProcessOPTriplet(stPlayer, nRecordCard)
            stBlockState:ClearGuoShouHu()   -- 碰后清除上一轮 过手胡标志
            return bIsProcessed
        end
    end
    
    --6.4处理吃
    nChair = stRoundInfo:GetWhoIsOnTurn()
    for i=1,PLAYER_NUMBER do
        nChair = LibTurnOrder:GetNextTurn( nChair )
        local stPlayer = stGameState:GetPlayerByChair(nChair)
        stBlockState = self:GetPlayerBlockState(nChair)
        if stBlockState:GetBlockRecordFlag() == ACTION_COLLECT then
            local nRecordCard = stBlockState:GetBlockaRecordCard()
            self:ProcessOPCollect(stPlayer, nRecordCard)
            return bIsProcessed
        end
    end
    return bIsProcessed
end

function LibGameLogic:IsPlayerCanDoBlock(stPlayer)
     if GGameCfg.RoomSetting.nGameStyle == GAME_STYLE_CHENGDU 
        and GGameCfg.RoomSetting.nSubGameStyle ==  LOCAL_CHENGDU_XUEZHAN then
        if stPlayer:IsWin() then
            return false
        end

    end
    return true
end


--[[
 dealer = "p1", 
        tileList = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14},
        tileCount = { p2 = 11, p3 = 11, p4 = 11},
        discardTile = 
        {
            p1 = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18},
            p2 = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18},
            p3 = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18},
            p4 = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18},
        },     
        combineTile = 
        {
            -- p1 = {{ 1, 2, 3, 4}, },
            p2 = {{ 1, 2, 3, 4}, },
            p3 = {{ 1, 2, 3, 4}, },
            p4 = {{ 1, 2, 3, 4}, },
        },
        winTile = 
        {
            p1 = {1, 2, 3, 4, 5, 6, 7 },
            p2 = {1, 2, 3, 4, 5, 6, 7 },
            p3 = {1, 2, 3, 4, 5, 6, 7 },
            p4 = {1, 2, 3, 4, 5, 6, 7 },
        },
--]]
function LibGameLogic:CollectAllTableCardInfo(nChair)
    local stGameState = GGameState
    local stRoundInfo = GRoundInfo
    local stSync = {}
    local stPlayer = stGameState:GetPlayerByChair(nChair)
    local nLastGiveChair =stRoundInfo:GetLastGiveChair()

    stSync.dealer = "p" .. stRoundInfo:GetBanker()
    stSync.roundWind =  stRoundInfo:GetRoundWind()   -- 圈风
    stSync.subRound =  stRoundInfo:GetSubRoundWind()    -- 该圈的第几轮
    stSync.dice =  stRoundInfo:GetDice()
    stSync.game_state = GDealer:GetCurrStage()
	
    --最后一个出牌的是谁
    stSync.nLastGiveChair = nLastGiveChair

    stSync.tileLeft = GDealer:GetDealerCardGroup():GetCurrentLength()
    stSync.tileList = stPlayer:GetPlayerCardGroup():ToArray()
	--轮到谁出牌
    local nTurn = stRoundInfo:GetWhoIsOnTurn()
    stSync.whoisOnTurn = nTurn

    local nleftTime
    --分为轮到自己和不是自己    --获取当前剩余时间
    if  nTurn ==nChair then
        --断线玩家最后摸的牌
        local stPlayerCardGroup = stPlayer:GetPlayerCardGroup()
        stSync.cardLastDraw = stPlayerCardGroup:GetLastDraw() 
    else
    end

    stSync.nleftTime = stRoundInfo:GetReenterTime()
    LOG_DEBUG("Run GetTimerLeftSecond23222244 ===%d\n",stSync.nleftTime) 


    -- 状态
    -- stSync.status = {}
    stSync.tileCount  = {}
    stSync.player_state = {}
    -- 弃牌
    stSync.discardTile   = {}
    -- 吃碰杠
    stSync.combineTile  = {}
    -- 胡牌
    stSync.winTile  = {}
    for i=1,PLAYER_NUMBER do
        local stPlayerOne =  stGameState:GetPlayerByChair(i)
        if stPlayerOne ~= nil then
            stSync.player_state[i] = stPlayerOne:GetPlayerStatus()
            stSync.tileCount[i]  = stPlayerOne:GetPlayerCardGroup():GetCurrentLength()
            stSync.discardTile[i] = stPlayerOne:GetPlayerGiveGroup():ToArray()
            stSync.combineTile[i] = stPlayerOne:GetPlayerCardSet():ToArray()
            stSync.winTile[i] = stPlayerOne:GetPlayerWinCards()
            -- else
            --LOG_DEBUG("FFFFFFFFFFFFFFFFFFFFF %d", i);
        end
    end
    return stSync
end
return LibGameLogic