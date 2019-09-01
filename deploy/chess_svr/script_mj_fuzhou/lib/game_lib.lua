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
    self.m_stScoreRecord = ScoreRecord.new()
end
function LibGameLogic:CreateInit(strSlotName)
    for i=1,PLAYER_NUMBER do
        self.m_stBlockState[i] = PlayerBlockState.new()
    end
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
end

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
    -- if stPlayer:IsTing() == true then
    --     if LibRuleTing:IsTingCanPlayOther() == false then
    --         if nCard ~= stPlayerCardGroup:GetLastDraw() then
    --             return ERROR_PLAYER_TING_PLAY_OTHERCARD
    --         end
    --     end
    -- end

    --闲金的牌形限制：只能自摸胡

       stPlayer:SetOnlyHuType(0)    --重置
    -- local nLaiZiCount = stPlayer:GetGoldCardNums()
    -- if nLaiZiCount >=1 then
    --     local envtest  = LibFanCounter:CollectEnv(stPlayer:GetChairID())
    --     LibFanCounter:SetEnv(envtest)
    --     local stTingInfo =LibFanCounter:GetTingInfo()
    --     local bIsYouJin =false


    --     if #stTingInfo>0 then

    --         LOG_DEBUG(":ProcessOPCollect..xianjinlimit.stTingInfo:%s\n",vardump(stTingInfo))
    --         for i=1,#stTingInfo do
    --             if stTingInfo[i].bIsYouJin then
    --                 stPlayer:SetOnlyHuType(GOLD_HU_SELFDRAW)
    --             end
    --         end
    --     end
    -- end

    stPlayerCardGroup:DelCard(nCard)
    stPlayerGiveGroup:AddCard(nCard)
    if stRoundInfo:GetGang() == true then
        stRoundInfo:SetGiveStatus(GIVE_STATUS_GANGGIVE)
        stRoundInfo:SetGang(false)
    else
        stRoundInfo:SetGiveStatus(GIVE_STATUS_NONE)
    end
    stRoundInfo:SetLastGive(nCard)

    stRoundInfo:SetLastGiveChair(nChair)

    nChair = stRoundInfo:GetWhoIsOnTurn()
    stRoundInfo:SetNeedDraw(true)
    stRoundInfo:SetWhoIsNextTurn(LibTurnOrder:GetNextTurn(nChair))
    stRoundInfo:AddCardShowNum(nCard)
    --
    CSMessage.NotifyPlayerPlayCard(stPlayer, {nCard})
    --福州麻将有抢金
    if GRoundInfo:IsDealerFirstTurn()  and GGameCfg.RoomSetting.nGameStyle == GAME_STYLE_FUZHOU then
        LOG_DEBUG("ProcessOPPlay....CallRobGold")
        GRoundInfo:SetPlayFirstCard(true)
        local nGoldCard = LibGoldCard:GetOpenGoldCard()
        local bCanRobGold =false
        for i=1,PLAYER_NUMBER do
            local stPlayer = GGameState:GetPlayerByChair(i)
            local stPlayerCardGroup = stPlayer:GetPlayerCardGroup()
            local arrPlayerCards = stPlayerCardGroup:ToArray()
            local stPlayerBlockState = self:GetPlayerBlockState(i)
            stPlayerBlockState:Clear()
            arrPlayerCards[#arrPlayerCards+1] = nGoldCard
            local bCanWin = LibRuleWin:CanWin(arrPlayerCards)
            if bCanWin then
                local stWinCard = nGoldCard
                stPlayerBlockState:SetCanWin(bCanWin, stWinCard, nFanNum,0)
                stPlayerBlockState:SetWinFalg(1)
                GRoundInfo:SetNotifyRobGold(true)
                bCanRobGold =true
                GRoundInfo:SetSkipRob(false)
                SSMessage.CallRobGold(stPlayer, nCard)
            else
                stPlayer:SetRobEnd(true)
            end
        end
        if bCanRobGold ==false then
            GRoundInfo:SetDealerFirstTurn(false)
            SSMessage.CallOtherPlayerGive(stPlayer, nCard)
        end
    else
        LOG_DEBUG("ProcessOPPlay....CallOtherPlayerGive")
        SSMessage.CallOtherPlayerGive(stPlayer, nCard)
    end
    return 0
end

-- 吃
function LibGameLogic:ProcessOPCollect(stPlayer, nCardFirst)
    local nGiveCard = stRoundInfo:GetLastGive()
    LOG_DEBUG("ProcessOPCollect...nCardFirst:%d, nGiveCard:%d", nCardFirst, nGiveCard)
    local stUseCards = {}
    -- 上家
    local nGiveChair = stRoundInfo:GetWhoIsOnTurn()
    local stGivePlayer = GGameState:GetPlayerByChair(nGiveChair)
    local stGvieCardGroup = stGivePlayer:GetPlayerGiveGroup()
    stGvieCardGroup:DelCardLast(nGiveCard)

    -- me
    local stPlayerCardGroup = stPlayer:GetPlayerCardGroup()
    local stPlayerCardCardSet = stPlayer:GetPlayerCardSet()
    LOG_DEBUG("ProcessOPCollect...before:%s", vardump(stPlayerCardGroup:ToArray()))
    local nIndex = 0
    for i=0,2 do
        if nCardFirst + i == nGiveCard then
            --找出被吃牌的位置
            nIndex = i
        else
            local nNextCard = nCardFirst + i
            table.insert(stUseCards, nNextCard)
            stPlayerCardGroup:DelCard(nNextCard)
            stRoundInfo:AddCardShowNum(nNextCard)
        end
    end
    LOG_DEBUG("ProcessOPCollect...after:%s", vardump(stPlayerCardGroup:ToArray()))

    LOG_DEBUG("ProcessOPCollect...nIndex:%d, stUseCards:%s", nIndex, vardump(stUseCards))
    stPlayerCardCardSet:AddSetCard(ACTION_COLLECT, nCardFirst, nIndex)

    stRoundInfo:SetGiveStatus(GIVE_STATUS_COLLECT)  --吃的牌和出的牌不能一样
    stRoundInfo:SetNeedDraw(false)
    stPlayerCardGroup:SetLastDraw(0)
    stRoundInfo:SetWhoIsNextTurn(stPlayer:GetChairID())

    --通知其他玩家吃牌
    CSMessage.NotifyBlockCollect(stPlayer, nGiveChair, nGiveCard, stUseCards)
    self:ClearAllBlock()

    --听牌提示  TODO: 需要重新计算
   --[[] if LibRuleTing:IsSupportTing() then
        local stPlayerBlockState = self:GetPlayerBlockState(stPlayer:GetChairID())
        local arrPlayerCards = stPlayerCardGroup:ToArray()
        LOG_DEBUG("ProcessOPCollect...arrPlayerCards:%s", vardump(arrPlayerCards))
        local bCanTing = LibRuleTing:CanTing(stPlayer, arrPlayerCards)
        local stCardTingGroup = {}
        if bCanTing == true then
            stCardTingGroup = LibRuleTing:GetTingGroup()
            CSMessage.NotifyPlayerBlockTing(stPlayer, stCardTingGroup)
        end
        stPlayerBlockState:SetTing(bCanTing, stCardTingGroup)
        LOG_DEBUG("ProcessOPCollect...bCanTing:%s, stCardTingGroup:%s", tostring(bCanTing), vardump(stCardTingGroup))
    end
--]]

    --[[
    local envtest  = LibFanCounter:CollectEnv(stPlayer:GetChairID())
    LibFanCounter:SetEnv(envtest)
    local stTingInfo =LibFanCounter:GetTingInfo()
    --LOG_DEBUG(":ProcessOPCollect...stTingInfo:%s\n",vardump(stTingInfo))


    if stPlayer:IsWin() == false and #stTingInfo>0 then
        LOG_DEBUG(":ProcessOPCollect..111.stTingInfo:%s\n",vardump(stTingInfo))
        CSMessage.NotifyPlayerBlockTing(stPlayer, stTingInfo)
    end
    --]]
end

-- 碰
function LibGameLogic:ProcessOPTriplet(stPlayer, nCard)
    LOG_DEBUG("ProcessOPTriplet before, nCard: %d", nCard)

    local nTurn = stRoundInfo:GetWhoIsOnTurn()
    local stPlayerCardGroup = stPlayer:GetPlayerCardGroup()
    LOG_DEBUG("ProcessOPTriplet...before:%s", vardump(stPlayerCardGroup:ToArray()))
    if stPlayerCardGroup:IsHaveDouble(nCard) then
        --
        local stPlayerCardSet = stPlayer:GetPlayerCardSet()
        stPlayerCardSet:AddSetCard(ACTION_TRIPLET, nCard, nTurn)
        stPlayerCardGroup:DelCard(nCard)
        stPlayerCardGroup:DelCard(nCard)
        stRoundInfo:AddCardShowNum(nCard)
        stRoundInfo:AddCardShowNum(nCard)

        -- 清除被碰玩家台面牌
        local nGiveChair = stRoundInfo:GetWhoIsOnTurn()
        local stGivePlayer = GGameState:GetPlayerByChair(nGiveChair)
        local stGvieCardGroup = stGivePlayer:GetPlayerGiveGroup()
        LOG_DEBUG("to clean triplet, before=%s", vardump(stGvieCardGroup:ToArray()))
        stGvieCardGroup:DelCardLast(nCard)
        LOG_DEBUG("to clean triplet, after=%s", vardump(stGvieCardGroup:ToArray()))
    end
    LOG_DEBUG("ProcessOPTriplet...after:%s", vardump(stPlayerCardGroup:ToArray()))
    LOG_DEBUG("ProcessOPTriplet end")

    stRoundInfo:SetGiveStatus(GIVE_STATUS_TRIPLE)
    stRoundInfo:SetNeedDraw(false)
    stPlayerCardGroup:SetLastDraw(0)
    stRoundInfo:SetWhoIsNextTurn(stPlayer:GetChairID())
    -- 通知其他玩家碰牌
    CSMessage.NotifyBlockTriplet(stPlayer, nTurn, nCard)
    self:ClearAllBlock()

    --听牌提示  TODO: 需要重新计算
    --[[if LibRuleTing:IsSupportTing() then
        local stPlayerBlockState = self:GetPlayerBlockState(stPlayer:GetChairID())
        local arrPlayerCards = stPlayerCardGroup:ToArray()
        LOG_DEBUG("ProcessOPTriplet...arrPlayerCards:%s", vardump(arrPlayerCards))
        local bCanTing = LibRuleTing:CanTing(stPlayer, arrPlayerCards)
        local stCardTingGroup = {}
        if bCanTing == true then
            stCardTingGroup = LibRuleTing:GetTingGroup()
            local stPlayerBlockState = self:GetPlayerBlockState(stPlayer:GetChairID())
            CSMessage.NotifyPlayerBlockTing(stPlayer, stCardTingGroup)
        end
        stPlayerBlockState:SetTing(bCanTing, stCardTingGroup)
        LOG_DEBUG("ProcessOPTriplet...bCanTing:%s, stCardTingGroup:%s", tostring(bCanTing), vardump(stCardTingGroup))
    end
    --]]


    --[[
    local envtest  = LibFanCounter:CollectEnv(stPlayer:GetChairID())
    LibFanCounter:SetEnv(envtest)
    local stTingInfo =LibFanCounter:GetTingInfo()
    --LOG_DEBUG(":ProcessOPTriplet...stTingInfo:%s\n",vardump(stTingInfo))


    if stPlayer:IsWin() == false and #stTingInfo>0 then
        LOG_DEBUG(":ProcessOPTriplet..111.stTingInfo:%s\n",vardump(stTingInfo))
        CSMessage.NotifyPlayerBlockTing(stPlayer, stTingInfo)
    end
    --]]
end

-- 杠
function LibGameLogic:ProcessOPQuadruplet(stPlayer, nCard)
    LOG_DEBUG("LibGameLogic:ProcessOPQuadruplet before, nCard: %d", nCard)
    local nTurn = stRoundInfo:GetWhoIsOnTurn()
    local nChair = stPlayer:GetChairID()
    local stQuadrupletCardGroup = PlayerCardGroup.new()
    stQuadrupletCardGroup:AddCard(nCard)
    stQuadrupletCardGroup:AddCard(nCard)
    stQuadrupletCardGroup:AddCard(nCard)
    stQuadrupletCardGroup:AddCard(nCard)
    local stPlayerCardSet = stPlayer:GetPlayerCardSet()

    local nGangType = 0    --杠的类型

    --参数 nType : 0--下雨 , 1--自己刮风, 2--他人给自己刮风
    local ntype =-1

    local stPlayerCardGroup = stPlayer:GetPlayerCardGroup()
    if  nTurn == nChair then
        -- 自己杠
        if stQuadrupletCardGroup:IsSubSet(stPlayerCardGroup) then
            --暗杠
            LOG_DEBUG("ProcessOPQuadruplet group begin ")
            stPlayerCardGroup:Print()
            LOG_DEBUG("stQuadrupletCardGroup:IsSubSet(stPlayerCardGroup) ")
            -- 都在手牌  暗杠
            stPlayerCardGroup:DelCardGroup(stQuadrupletCardGroup)

            --暗杆时不再显示给别人
            --stRoundInfo:AddCardShowNum(nCard)
            --stRoundInfo:AddCardShowNum(nCard)
            --stRoundInfo:AddCardShowNum(nCard)
            --stRoundInfo:AddCardShowNum(nCard)

            LOG_DEBUG("ProcessOPQuadruplet group end")
            stPlayerCardGroup:Print()
            stPlayerCardSet:AddSetCard(ACTION_QUADRUPLET_CONCEALED, nCard, nTurn)
            -- 通知 杠
            CSMessage.NotifyBlockQuadruplet(stPlayer, nCard, nTurn, ACTION_QUADRUPLET_CONCEALED)
            --
            nGangType = ACTION_QUADRUPLET_CONCEALED
            ntype =0

        elseif stPlayerCardSet:Triplet2Quadruplet(nCard) == true then
            -- 碰上加杠
            LOG_DEBUG("Triplet2Quadruplet group begin ")
            stPlayerCardGroup:Print()
            LOG_DEBUG("stPlayerCardSet:Triplet2Quadruplet(nCard) == true")
            stPlayerCardGroup:DelCard(nCard)
            stRoundInfo:AddCardShowNum(nCard)
            stPlayerCardGroup:Print()
            LOG_DEBUG("Triplet2Quadruplet group end ")
            -- 通知 杠
            CSMessage.NotifyBlockQuadruplet(stPlayer, nCard, nTurn, ACTION_QUADRUPLET_REVEALED)
            --
            nGangType = ACTION_QUADRUPLET_REVEALED

            ntype = 1
        else
            LOG_DEBUG("ERROR_BLOCK_QUADRUPLET")
            return ERROR_BLOCK_QUADRUPLET
        end
    else
        --点杠
        LOG_DEBUG(" nTurn ~= nChair ")
        --  杠 别人的  三张牌在自己的手牌  
        -- 如果先碰了 不是自己摸到的，是不能杠的
        LOG_DEBUG("nTurn ~= nChair Quadruplet group begin give")
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
        stRoundInfo:AddCardShowNum(nCard)
        stRoundInfo:AddCardShowNum(nCard)
        stRoundInfo:AddCardShowNum(nCard)
        LOG_DEBUG("nTurn ~= nChair Quadruplet group end")
        stPlayerCardSet:AddSetCard(ACTION_QUADRUPLET, nCard, nTurn)
        CSMessage.NotifyBlockQuadruplet(stPlayer, nCard, nTurn, ACTION_QUADRUPLET)
        --
        nGangType = ACTION_QUADRUPLET
        ntype = 2
    end

    stRoundInfo:SetGang(true)
    stRoundInfo:SetGiveStatus(GIVE_STATUS_GANG)
    stRoundInfo:SetNeedDraw(true)
    stPlayerCardGroup:SetLastDraw(0)
    stRoundInfo:SetWhoIsNextTurn(stPlayer:GetChairID())

    if ntype ==1 then
        stRoundInfo:SetIsQiangGang(true)
        stRoundInfo:SetPengGangPlayer(nChair)     
    end
    --处理杠分
    LibGameLogicFuzhou:ProcessOPQuadruplet(nGangType,nChair,nTurn)
    self:ClearAllBlock()

    if ntype ==1 then
        SSMessage.CallOtherPlayerQiangGang(stPlayer, nCard)       
    end

    return 0
end

-- 听
function LibGameLogic:ProcessOPTing(stPlayer, nCard)
    stPlayer:SetTing(TING_CONCEALED)
end

--  处理玩家赢
-- [ {winner = nChair, winWho = nOnTurn, cardWin = nWinCard}]
function LibGameLogic:DoProcessOPWin(stWinList)
    LOG_DEBUG("LibGameLogic:DoProcessOPWin...stWinList:%s", vardump(stWinList))
    local stDelRecord =  {}
    for i=1,#stWinList do
        local stOneWin = stWinList[i]
        local nFlag = 0
        local nWhoGun = 0
        local stPlayerWin = stGameState:GetPlayerByChair(stOneWin.winner)
        if stOneWin.winner == stOneWin.winWho  then
            nFlag = WIN_SELFDRAW
            stPlayerWin:AddPlayerWinCard(stOneWin.cardWin)
            --stPlayerWin:GetPlayerCardGroup():DelCard(stOneWin.cardWin)
            stRoundInfo:AddCardShowNum(stOneWin.cardWin)
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
        stRoundInfo:SetWhoIsNextTurn(LibTurnOrder:GetNextTurn(stPlayerWin:GetChairID()))
    end
    self:ClearAllBlock()
end

function LibGameLogic:ProcessOPWin(stPlayer, nCard)
    --win chair
    local nWinner = stPlayer:GetChairID()
    -- 最后出牌的人
    local lastTurnChair = stRoundInfo:GetWhoIsOnTurn()
    --如果是抢金则是自摸
    if stRoundInfo:IsRobGolgHu() then
        lastTurnChair = nWinner
    end
    -- 设置当前胡
    stRoundInfo:SetLastWinner(stPlayer:GetChairID())

    -- if  GGameCfg.RoomSetting.nGameStyle ==  GAME_STYLE_CHENGDU then
    --     -- 成都麻将 和操作
    --     LibGameLogicChengdu:ProcessOPWin()
    -- elseif GGameCfg.RoomSetting.nGameStyle == GAME_STYLE_LUOYANG then
    --     --洛阳杠次麻将 和操作
    --     LibGameLogicLuoyang:ProcessOPWin()
    --     stRoundInfo:SetNeedDraw(false)
    --     stPlayer:GetPlayerCardGroup():SetLastDraw(0)

    -- elseif GGameCfg.RoomSetting.nGameStyle == GAME_STYLE_SHIJIAZHUANG then

    --     LibGameLogicShiJiaZhuang:ProcessOPWin()
    --     stRoundInfo:SetNeedDraw(false)
    --     stPlayer:GetPlayerCardGroup():SetLastDraw(0)
    -- else
        -- 游戏结束
        
        local stWinData = {}
        table.insert(stWinData, {winner = nWinner, winWho = lastTurnChair, cardWin = nCard})
        LOG_DEBUG("LibGameLogic:ProcessOPWin...stWinData:%s", vardump(stWinData))

        LibGameLogicFuzhou:ProcessOPWin(stWinData)

        stRoundInfo:SetNeedDraw(false)
        stPlayer:GetPlayerCardGroup():SetLastDraw(0)
    -- end

    self:ClearAllBlock()
end

--结算
function LibGameLogic:RewardThisGame()
    local nGameStyle = GGameCfg.RoomSetting.nGameStyle
    LOG_DEBUG("LibGameLogic:RewardThisGame...nGameStyle: %d", nGameStyle)
    if nGameStyle == GAME_STYLE_FUZHOU then
        LibGameLogicFuzhou:RewardThisGame()
    elseif nGameStyle == GAME_STYLE_QUANZHOU then

    elseif nGameStyle == GAME_STYLE_XIAMEN then

    elseif nGameStyle == GAME_STYLE_ZHANGZHOU then

    end
end

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

        if stBlockState:GetBlockRecordFlag() == ACTION_WIN then
            -- 找到可以胡大牌的玩家
            local nBigType= stBlockState:GetCurrWinBigType()
            if nBigType ~=ACTION_WIN and nBigType ~=0 then
                LOG_DEBUG("SwitchBlock...user play... nBigType:%d", nBigType)
                nFlag = nBigType
                nLevel = nFlag  --优先级
                nWho = nChair   --谁
            end
        end

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
                local nBigType = stBlockState:GetCurrWinBigType()
                LOG_DEBUG("SwitchBlock...user play... nRecordCard:%d", nBigType)
                if nBigType ~=0 then
                    LOG_DEBUG("SwitchBlock...1111user play... nRecordCard:")
                    nThisLevel = nBigType
                else
                    nThisLevel = nWin
                end
            end
            --玩家当前可以操作的最高等级 和 其他玩家操作的最高等级比较
            if nThisLevel > nLevel then
                --4.1如果自己等级高  其他人的操作不响应。
                LOG_DEBUG("SwitchBlock User No Action _chair:%d nThisLevel:%d\n", i, nThisLevel)
                return  false
            elseif nThisLevel == nLevel then
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
        local nextChair = LibTurnOrder:GetNextTurn(stRoundInfo:GetWhoIsOnTurn())
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
            --SSMessage.CallPlayerGiveup(stPlayer)
            --return  false
        end
    end
    --6.0: 金雀的优先级最高 只有胡别人的牌才会有这个判断

    local bIsProcessed = true
    --6.1处理和
    nChair = stRoundInfo:GetWhoIsOnTurn()
    for i=1,PLAYER_NUMBER do
        nChair = LibTurnOrder:GetNextTurn( nChair )
        stBlockState = self:GetPlayerBlockState(nChair)
        
        if stBlockState:GetBlockRecordFlag() == ACTION_WIN  and nLevel==stBlockState:GetCurrWinBigType() and nWho==nChair then
            local stPlayer = stGameState:GetPlayerByChair(nChair)
            LOG_DEBUG("--==GetBlockRecordFlag()-ACTION_WIN, WhoIsOnTurn:%d !!!!!!GetCurrWinBigType=%d!!!!!!!nLevel=%d\n", stRoundInfo:GetWhoIsOnTurn(),nLevel,stBlockState:GetCurrWinBigType())
            self:ProcessOPWin(stPlayer, stBlockState:GetBlockaRecordCard())
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
            local nRecordCard = stBlockState:GetBlockaRecordCard()
            self:ProcessOPQuadruplet(stPlayer, nRecordCard)
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
            LOG_DEBUG("--==GetBlockRecordFlag()-ACTION_TRIPLET---nchair=====:%d !!!!!!!!!!!!!\n", nChair)
            local nRecordCard = stBlockState:GetBlockaRecordCard()
            self:ProcessOPTriplet(stPlayer, nRecordCard)
            return bIsProcessed
        end
    end
    
    --6.4处理吃
    nChair = stRoundInfo:GetWhoIsOnTurn()
    for i=1,PLAYER_NUMBER do
        nChair = LibTurnOrder:GetNextTurn( nChair )
        local stPlayer = stGameState:GetPlayerByChair(nChair)
        stBlockState = self:GetPlayerBlockState(nChair)
        LOG_DEBUG("--==GetBlockRecordFlag()-ACTION_COLLECT---nchair=====:%d !!!!!!!!!!!!!\n", nChair)
        if stBlockState:GetBlockRecordFlag() == ACTION_COLLECT then
            local nRecordCard = stBlockState:GetBlockaRecordCard()
            self:ProcessOPCollect(stPlayer, nRecordCard)
            return bIsProcessed
        end
    end
    return bIsProcessed
end

--抢金阶段
function LibGameLogic:ProcessOPRobGoldBlock()
    LOG_DEBUG("ProcessOPRobGoldBlock")
    local stBlockState = nil
    local bIsHasBlock = false

    --1.检查玩家是否有block
    for i=1,PLAYER_NUMBER do
        stBlockState = self:GetPlayerBlockState(i)
        if stBlockState:IsBlocked() then
            bIsHasBlock = true
            LOG_DEBUG("ProcessOPRobGoldBlock...stBlockState:IsBlocked() true")
            break
        end
    end
    if bIsHasBlock == false then
         LOG_DEBUG("ProcessOPRobGoldBlock...stBlockState:IsBlocked() false")
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

    --4.检查没有操作的玩家优先级，比较已经操作玩家的优先级nWho--nLevel
    local nWin = 0
    for i=1,PLAYER_NUMBER do
        stBlockState = self:GetPlayerBlockState(i)
        nFlag = stBlockState:GetBlockRecordFlag()

        if nFlag == 0 then
            nWin = stBlockState:GetWin()
            local nThisLevel = 0
            if nWin  > 0 then
                nThisLevel = nWin
            end
            --玩家当前可以操作的最高等级 和 其他玩家操作的最高等级比较
            if nThisLevel > nLevel then
                --4.1如果自己等级高  其他人的操作不响应。
                LOG_DEBUG("ProcessOPRobGoldBlock User No Action _chair:%d nThisLevel:%d\n", i, nThisLevel)
                return  false
            elseif nThisLevel == nLevel then
                --4.2优先级相等 从出牌人的下家开始检查，看谁在前面
                nChair = stRoundInfo:GetWhoIsOnTurn() 
                for j=1,PLAYER_NUMBER do
                    nChair = LibTurnOrder:GetNextTurn(nChair)
                    if i == nChair then
                        -- 自己在前面，大家再等等吧
                        LOG_DEBUG("ProcessOPRobGoldBlock User No Action _chair:%d\n", nChair)
                        return false
                    end
                    if nWho == nChair then
                        break
                    end
                end
            end
        end
    end

    --5.检查是否所有人都give up了
    local nResult = 0
    for i=1, PLAYER_NUMBER do
        stBlockState = self:GetPlayerBlockState(i)
        nWin = stBlockState:GetWin()
        nResult = nResult + nWin
    end
    if nResult == 0 then
        -- 所有玩家都give up了 则继续游戏
        LOG_DEBUG("ProcessOPRobGoldBlock...all give up ")
        return true
    end

    local bIsProcessed = true
    --6.1处理和

    --2.检查是否还有block没有操作
    for i=1,PLAYER_NUMBER do
        stBlockState = self:GetPlayerBlockState(i)
        if stBlockState:IsBlocked() and stBlockState:GetBlockRecordFlag() == 0 then
            --return  false
            FlowFramework.SetTimer(i, 0)
        end
    end

    nChair = stRoundInfo:GetWhoIsOnTurn()
    for i=1,PLAYER_NUMBER do
        nChair = LibTurnOrder:GetNextTurn(nChair)
        stBlockState = self:GetPlayerBlockState(nChair)
        if stBlockState:GetBlockRecordFlag() == ACTION_WIN then
            local stPlayer = stGameState:GetPlayerByChair(nChair)
            LOG_DEBUG("--==ProcessOPRobGoldBlock-ACTION_WIN, WhoIsOnTurn:%d, whoWin:%d !!!!!!!!!!!!!\n", stRoundInfo:GetWhoIsOnTurn(), nChair)
            self:ProcessOPWin(stPlayer, stBlockState:GetBlockaRecordCard())
            return bIsProcessed
        end
    end

    return bIsProcessed
end

-- 重连 牌桌信息
function LibGameLogic:CollectAllTableCardInfo(nChair)
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

    --牌堆剩余多少张牌
    stSync.tileLeft = GDealer:GetDealerCardGroup():GetCurrentLength()
    --金牌
    stSync.nOpenGoldCard = LibGoldCard:GetOpenGoldCard()
    --金牌在剩余牌堆的位置
    local stDealerCardGroup = GDealer:GetDealerCardGroup()
    stSync.nGoldCardPos = stDealerCardGroup:GetGoldCardPos()
    LOG_DEBUG("CollectAllTableCardInfo...nOpenGoldCard:%d, nGoldCardPos:%d, nDealerCaerdLeft:%d", stSync.nOpenGoldCard, stSync.nGoldCardPos, stSync.tileLeft)

    --玩家手牌
    stSync.tileList = stPlayer:GetPlayerCardGroup():ToArray()
	--轮到谁出牌
    local nTurn = stRoundInfo:GetWhoIsOnTurn()
    stSync.whoisOnTurn = nTurn

    --分为轮到自己和不是自己，轮到我则需要把最后摸的牌找出   
    if  nTurn == nChair then
        --断线玩家最后摸的牌
        local stPlayerCardGroup = stPlayer:GetPlayerCardGroup()
        stSync.cardLastDraw = stPlayerCardGroup:GetLastDraw() 
    end

    --获取当前剩余时间
    stSync.nleftTime = stRoundInfo:GetReenterTime()
    LOG_DEBUG("Run GetTimerLeftSecond23222244 ===%d\n",stSync.nleftTime) 


    --各个玩家的手牌数量
    stSync.tileCount  = {}
    -- 状态:  0, 1, 2; 没人，坐着，已准备
    stSync.player_state = {}
    -- 玩家uid
    stSync.player_uin = {}
    -- 弃牌
    stSync.discardTile   = {}
    -- 吃碰杠
    stSync.combineTile  = {}
    -- 胡牌
    stSync.winTile  = {}
    -- 各个玩家拥有的花牌及数量
    stSync.flowerTile = {}

    for i=1,PLAYER_NUMBER do
        local stPlayerOne =  stGameState:GetPlayerByChair(i)
        if stPlayerOne ~= nil then
            stSync.player_state[i] = stPlayerOne:GetPlayerStatus()
            stSync.player_uin[i] = stPlayerOne:GetUin()
            stSync.tileCount[i]  = stPlayerOne:GetPlayerCardGroup():GetCurrentLength()
            stSync.discardTile[i] = stPlayerOne:GetPlayerGiveGroup():ToArray()
            stSync.combineTile[i] = stPlayerOne:GetPlayerCardSet():ToArray()
            stSync.winTile[i] = stPlayerOne:GetPlayerWinCards()
            stSync.flowerTile[i] = stPlayerOne:GetFlowerCards()
            -- else
            --LOG_DEBUG("FFFFFFFFFFFFFFFFFFFFF %d", i)
        end
    end
    LOG_DEBUG("CollectAllTableCardInfo...stSync:%s", vardump(stSync))
    return stSync
end

return LibGameLogic