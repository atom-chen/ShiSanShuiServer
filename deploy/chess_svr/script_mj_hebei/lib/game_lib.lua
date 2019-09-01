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


-- 处理玩家打牌
function LibGameLogic:ProcessOPPlay(stPlayer, nCard)
    -- 清除自己的 block
    local stRoundInfo = GRoundInfo
    local nChair = stPlayer:GetChairID()
    
    if LibLaiZi:IsLaiZi(nCard) then  -- 河北麻将不允许打混牌
        return STEP_FAILED
    end
    
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
    -- 只要出过牌都设为true，作为判断天地胡的依据之一
    stPlayer:SetPlayCardsAlready()

    if GRoundInfo:IsDealerFirstTurn()  then
        GRoundInfo:SetDealerFirstTurn(false)
    end
    
    if stPlayer:IsTing() == true then
        if LibRuleTing:IsTingCanPlayOther() == false then
            if nCard ~= stPlayerCardGroup:GetLastDraw() then
                return ERROR_PLAYER_TING_PLAY_OTHERCARD
            end
        end
    end

    stPlayerCardGroup:DelCard(nCard)
    stPlayerGiveGroup:AddCard(nCard)
    
    local num = stRoundInfo:SetFollowBanker(nCard)  -- 设置跟庄
    LOG_DEBUG("SetFollowBanker():num:%d\n", num)
    if num > 0 then
        CSMessage.NotifyPlayerFollowNum(num)
    end  
    
    if stRoundInfo:GetGang() == true then
        stRoundInfo:SetGiveStatus(GIVE_STATUS_GANGGIVE)
        stRoundInfo:SetGang(false)
    else
        stRoundInfo:SetGiveStatus(GIVE_STATUS_NONE)
    end
    
    stRoundInfo:SetLastGive(nCard)
    nChair = stRoundInfo:GetWhoIsOnTurn()
    stRoundInfo:SetNeedDraw(true)
    stRoundInfo:SetWhoIsNextTurn(LibTurnOrder:GetNextTurn(nChair))
    stRoundInfo:AddCardShowNum(nCard)
    
    CSMessage.NotifyPlayerPlayCard(stPlayer, {nCard})
    SSMessage.CallOtherPlayerGive(stPlayer, nCard)
    
    -- 手牌有变动清除 漏胡 过手胡 过手碰
    stPlayerBlockState:DelGuoShouHu()
    stPlayerBlockState:DelGuoShouPeng()
    
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

    -- 听牌信息
    --[[
    local envtest  = LibFanCounter:CollectEnv(stPlayer:GetChairID())
    LibFanCounter:SetEnv(envtest)
    local stTingInfo =LibFanCounter:GetTingInfo()
    -- LOG_DEBUG(":ProcessOPCollect...stTingInfo:%s\n",vardump(stTingInfo))
    if stPlayer:IsWin() == false and #stTingInfo>0 then
        LOG_DEBUG(":ProcessOPCollect..111.stTingInfo:%s\n",vardump(stTingInfo))
        CSMessage.NotifyPlayerBlockTing(stPlayer, stTingInfo)
    end
    --]]

end

--碰
function LibGameLogic:ProcessOPTriplet(stPlayer, nCard)
    local nTurn = stRoundInfo:GetWhoIsOnTurn()
    LOG_DEBUG("ProcessOPTriplet")
    local stPlayerCardGroup = stPlayer:GetPlayerCardGroup()
    stPlayerCardGroup:Print()
    if stPlayerCardGroup:IsHaveDouble(nCard) then
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

    CSMessage.NotifyBlockTriplet(stPlayer, nTurn, nCard)
    self:ClearAllBlock()

--[[
    local envtest  = LibFanCounter:CollectEnv(stPlayer:GetChairID())
    LibFanCounter:SetEnv(envtest)
    local stTingInfo =LibFanCounter:GetTingInfo()
    -- LOG_DEBUG(":ProcessOPTriplet...stTingInfo:%s\n",vardump(stTingInfo))

    if stPlayer:IsWin() == false and #stTingInfo>0 then
        LOG_DEBUG(":ProcessOPTriplet..111.stTingInfo:%s\n",vardump(stTingInfo))
        CSMessage.NotifyPlayerBlockTing(stPlayer, stTingInfo)
    end
    --]]
end

--杠
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

    local nGangValue = 0
    --参数 nType : 0--下雨 , 1--自己刮风, 2--他人给自己刮风
    local ntype = -1
    
    local stPlayerCardGroup = stPlayer:GetPlayerCardGroup()
    --碰杠时，之前被碰的玩家nOldTurn
    local nOldTurn = 0

    if GRoundInfo:IsDealerFirstTurn()  then
        GRoundInfo:SetDealerFirstTurn(false)
    end
    if  nTurn == nChair then
        -- 自己杠 暗杠 碰上加杠
        if stQuadrupletCardGroup:IsSubSet(stPlayerCardGroup) then
            LOG_DEBUG("ProcessOPQuadruplet group begin ");
            stPlayerCardGroup:Print()
            LOG_DEBUG("stQuadrupletCardGroup:IsSubSet(stPlayerCardGroup) ")
            -- 都在手牌  暗杠
            stPlayerCardGroup:DelCardGroup(stQuadrupletCardGroup)

            -- 暗杆时不再显示给别人
            -- stRoundInfo:AddCardShowNum(nCard)
            -- stRoundInfo:AddCardShowNum(nCard)
            -- stRoundInfo:AddCardShowNum(nCard)
            -- stRoundInfo:AddCardShowNum(nCard)

            LOG_DEBUG("ProcessOPQuadruplet group end");
            stPlayerCardGroup:Print()
            stPlayerCardSet:AddSetCard(ACTION_QUADRUPLET_CONCEALED, nCard, nTurn)  
            -- 通知 杠
            CSMessage.NotifyBlockQuadruplet(stPlayer, nCard, nTurn, ACTION_QUADRUPLET_CONCEALED)
    
            nGangValue = ACTION_QUADRUPLET_CONCEALED
            ntype = 0

        elseif stPlayerCardSet:Triplet2Quadruplet(nCard) == true then
            --碰杠时，取出被碰的玩家
            local combineTile = stPlayer:GetPlayerCardSet():ToArray()
            for j =1,#combineTile do
                if combineTile[j].ucFlag == ACTION_QUADRUPLET_REVEALED and combineTile[j].card == nCard then
                    nOldTurn = combineTile[j].value
                    stRoundInfo:SetPengGangChair(nOldTurn)
                end
            end

            LOG_DEBUG("Triplet2Quadruplet group begin ");
            stPlayerCardGroup:Print()
            LOG_DEBUG("stPlayerCardSet:Triplet2Quadruplet(nCard) == true")
            stPlayerCardGroup:DelCard(nCard)
            stRoundInfo:AddCardShowNum(nCard)
            stPlayerCardGroup:Print()
            LOG_DEBUG("Triplet2Quadruplet group end ");
            -- 通知 杠
            CSMessage.NotifyBlockQuadruplet(stPlayer, nCard, nTurn, ACTION_QUADRUPLET_REVEALED)
            
            nGangValue = ACTION_QUADRUPLET_REVEALED
            ntype = 1
        else
            LOG_DEBUG("ERROR_BLOCK_QUADRUPLET")
            return ERROR_BLOCK_QUADRUPLET
        end
    else
        LOG_DEBUG(" nTurn ~= nChair ");
        -- 杠 别人的 三张牌在自己的手牌  
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

        stRoundInfo:AddCardShowNum(nCard)
        stRoundInfo:AddCardShowNum(nCard)
        stRoundInfo:AddCardShowNum(nCard)

        LOG_DEBUG("nTurn ~= nChair Quadruplet group end");
        stPlayerCardSet:AddSetCard(ACTION_QUADRUPLET, nCard, nTurn)
        CSMessage.NotifyBlockQuadruplet(stPlayer, nCard, nTurn, ACTION_QUADRUPLET)
        
        nGangValue = ACTION_QUADRUPLET
        ntype = 2
    end

    stRoundInfo:SetGang(true)
    stRoundInfo:SetGiveStatus(GIVE_STATUS_GANG)
    -- 连杠次数
    stPlayer:AddLianGangTimes()

    -- 检查是否可胡 杠次
    local arrPlayerCards = stPlayerCardGroup:ToArray()
    LOG_DEBUG("LibGameLogic:ProcessOPQuadruplet ...arrPlayerCards=%s", vardump(arrPlayerCards))
    if GGameCfg.GameSetting.bSupportGangCi and LibRuleWin:CanGangCi(arrPlayerCards) then
        -- 清除所有人的block
        stPlayerCardGroup:SetLastDraw(0)
        self:ClearAllBlock()

        stRoundInfo:SetGangciHu(nGangValue, nTurn)
        stRoundInfo:SetWhoIsOnTurn(nChair)
        stRoundInfo:SetWhoIsNextTurn(nChair)
        -- 设置新的杠次block no timeout
        local stPlayerBlockState = self:GetPlayerBlockState(nChair)
        local nWinCard = LibCi:GetCi()
        stPlayerBlockState:SetCanWin(true, nWinCard)
        -- 玩家行为数操作call_gangci
        SSMessage.CallPlayerGangCi(stPlayer)
    else
        stRoundInfo:SetNeedDraw(true)
        stRoundInfo:SetWhoIsNextTurn(nChair)
        stPlayerCardGroup:SetLastDraw(0)
        self:ClearAllBlock()
    end
    
    if ntype == 1 then  -- 抢杠
        stRoundInfo:SetIsQiangGang(true)
        stRoundInfo:SetPengGangPlayer(nChair)
    end
    
    LOG_DEBUG("nTurn ~= nChair Quadruplet====%d====%d====%d group end", nGangValue, nChair, nTurn);
    --碰杠时取出被碰的玩家计算杠分
    if nOldTurn ~= 0 then
        nTurn = nOldTurn
    end
    if GGameCfg.RoomSetting.nGameStyle == GAME_STYLE_SHIJIAZHUANG then
        LibGameLogicShiJiaZhuang:ProcessOPQuadruplet(nGangValue, nChair, nTurn)
    elseif GGameCfg.RoomSetting.nGameStyle == GAME_STYLE_LANGFANG then
        LibGameLogicLangFang:ProcessOPQuadruplet(nGangValue, nChair, nTurn)
    elseif GGameCfg.RoomSetting.nGameStyle == GAME_STYLE_TANGSHAN then
        LibGameLogicTangShan:ProcessOPQuadruplet(nGangValue, nChair, nTurn)
    end
    
    if ntype == 1 then  -- 抢杠
        SSMessage.CallOtherPlayerQiangGang(stPlayer, nCard)
    end
    
    return 0
end

function LibGameLogic:ProcessOPTing(stPlayer, nCard)
    stPlayer:SetTing(TING_CONCEALED)
end

function LibGameLogic:DoSetWinner(stWinList)
    --有一炮多响  连庄设置
    local nChair = GRoundInfo:GetLastWinner()
    LOG_DEBUG("LibGameLogic:DoSetWinner...LastWinner:%d, stWinList:%s", nChair, vardump(stWinList))
    local nBanker = nChair
    for i=1,#stWinList do
        local stOneWin = stWinList[i]
        if stOneWin.winner == nChair then
            nBanker = nChair
            break
        end
        nBanker = stOneWin.winner
    end

    GRoundInfo:SetLastWinner(nBanker)
end

-- [ {winner = nChair, winWho = nOnTurn, cardWin = nWinCard} ]
function LibGameLogic:DoProcessOPWin(stWinList)
    local stDelRecord =  {}
    local stGameState = GGameState
    --设置赢家
    self:DoSetWinner(stWinList)
    
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
    --郑州麻将不用发win，其他麻将有一炮多响的情况需要发
    --if GGameCfg.RoomSetting.nGameStyle == GAME_STYLE_SHIJIAZHUANG then
    CSMessage.NotifyPlayerWin(stWinList) 
    --end
end

-- 处理玩家赢
function LibGameLogic:ProcessOPWin(stPlayer, nCard)
    -- 最后出牌的人
    local lastTurnChair = stRoundInfo:GetWhoIsOnTurn() 
    -- 设置当前胡 DoProcessOPWin设置
    
    if GGameCfg.RoomSetting.nGameStyle == GAME_STYLE_LUOYANG then
        -- 洛阳杠次麻将 和操作
        LibGameLogicLuoyang:ProcessOPWin()
        GRoundInfo:SetNeedDraw(false)
        stPlayer:GetPlayerCardGroup():SetLastDraw(0)

    elseif GGameCfg.RoomSetting.nGameStyle == GAME_STYLE_SHIJIAZHUANG then
        LibGameLogicShiJiaZhuang:ProcessOPWin(nCard)
        GRoundInfo:SetNeedDraw(false)
        stPlayer:GetPlayerCardGroup():SetLastDraw(0)
    elseif GGameCfg.RoomSetting.nGameStyle == GAME_STYLE_LANGFANG then
        LibGameLogicLangFang:ProcessOPWin(nCard)
        GRoundInfo:SetNeedDraw(false)
        stPlayer:GetPlayerCardGroup():SetLastDraw(0)
    elseif GGameCfg.RoomSetting.nGameStyle == GAME_STYLE_TANGSHAN then
        LibGameLogicTangShan:ProcessOPWin(nCard)
        GRoundInfo:SetNeedDraw(false)
        stPlayer:GetPlayerCardGroup():SetLastDraw(0)
    else
        -- 游戏结束
        local winType = ""
        if GRoundInfo:GetWhoIsOnTurn() == stPlayer:GetChairID() then
            winType = "selfdraw"    -- "自摸"
        else
            winType = "gunwin"      -- "放枪"
        end
        
        if GRoundInfo:GetGang() and GRoundInfo:GetWhoIsOnTurn() == stPlayer:GetChairID() then
            winType = "gangflower"  -- "杠上花"
        end

        local stWinData= {winner = stPlayer:GetChairID(), winWho = lastTurnChair, cardWin = nCard, winType = winType}
        self:DoProcessOPWin({stWinData})

        GRoundInfo:SetNeedDraw(false)
        stPlayer:GetPlayerCardGroup():SetLastDraw(0)
    end
    
    self:ClearAllBlock()
end

function LibGameLogic:RewardThisGame()
    LOG_DEBUG("=============LibGameLogic:RewardThisGame-----nGameStyle=%d", GGameCfg.RoomSetting.nGameStyle)
    if GGameCfg.RoomSetting.nGameStyle == GAME_STYLE_SHIJIAZHUANG then
        LibGameLogicShiJiaZhuang:RewardThisGame()
    elseif GGameCfg.RoomSetting.nGameStyle == GAME_STYLE_LANGFANG then
        LibGameLogicLangFang:RewardThisGame()
    elseif GGameCfg.RoomSetting.nGameStyle == GAME_STYLE_TANGSHAN then
        LibGameLogicTangShan:RewardThisGame()
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
end

-- 根据当前状态判断是否已经能够Block了
-- 结算一次挡牌过程
-- return true  挡牌得到处理 或者没有挡牌
-- return false 挡牌没有处理 需要等待
function LibGameLogic:ProcessOPSwitchBlock()
    LOG_DEBUG("ProcessOPSwitchBlock")
    local stBlockState = nil
    local bIsHasBlock = false

    -- 1.检查玩家是否有block
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
    -- 3.检查玩家已经操作(也就是点击了吃碰杠胡)的最高优先级
    nChair = stRoundInfo:GetWhoIsOnTurn()
    for i=1, PLAYER_NUMBER do
        -- 从出牌人的下家开始检查
        nChair = LibTurnOrder:GetNextTurn(nChair)
        stBlockState = self:GetPlayerBlockState(nChair)
        nFlag = stBlockState:GetBlockRecordFlag()
        if nFlag > nLevel then
            nLevel = nFlag
            nWho = nChair
        end
    end

    -- 4.检查是否有玩家还没操作
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
            -- 玩家当前可以操作的最高等级 和 其他玩家操作的最高等级比较
            if nThisLevel > nLevel then
                -- 4.1如果自己等级高  其他人的操作不响应。
                LOG_DEBUG("SwitchBlock User No Action _chair:%d nThisLevel:%d\n", i, nThisLevel);
                return  false
            elseif nThisLevel == nLevel then
                if nThisLevel == ACTION_WIN and GGameCfg.RoomSetting.nGameStyle == GAME_STYLE_SHIJIAZHUANG  then
                    -- 石家庄麻将在这里要支持一炮多响
                    LOG_DEBUG("还有人可以胡,ucItLevel == ACTION_WIN && ucLevel == ACTION_WIN\r\n");
                    return false
                end
                
                -- 4.2优先级相等 从出牌人的下家开始检查，看谁在前面
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
    -- 5.检查是否所有人都Cancel了
    local nResult = 0
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

    -- 2.检查是否所有可以block的人都反应了，如果没有则直接退出
    for i=1, PLAYER_NUMBER do
        stBlockState = self:GetPlayerBlockState(i)
        if stBlockState:IsBlocked() and stBlockState:GetBlockRecordFlag() == 0 then
            LOG_DEBUG("stBlockState:have player not do")
            FlowFramework.SetTimer(i, 0)
        end
    end
    
    -- 6.有玩家拦牌，则按优先级查询
    -- 从出牌的人下家开始检查
    -- 6.1处理和
    local bIsProcessed = true
    nChair = stRoundInfo:GetWhoIsOnTurn()
    for i=1,PLAYER_NUMBER do
        nChair = LibTurnOrder:GetNextTurn( nChair )
        stBlockState = self:GetPlayerBlockState(nChair)
        if stBlockState:GetBlockRecordFlag() == ACTION_WIN then
            local stPlayer = stGameState:GetPlayerByChair(nChair)
            LOG_DEBUG("WhoIsOnTurn:%d !!!!!!!!!!!!!\n", stRoundInfo:GetWhoIsOnTurn());
            self:ProcessOPWin(stPlayer, stBlockState:GetBlockaRecordCard())
            return bIsProcessed
        end
    end
    
    -- 6.2处理杠
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
        --连杠次数重置
        stPlayer:ResetLianGangTimes()
    end

    -- 6.3处理碰
    nChair = stRoundInfo:GetWhoIsOnTurn()
    for i=1,PLAYER_NUMBER do
        nChair = LibTurnOrder:GetNextTurn( nChair )
        local stPlayer = stGameState:GetPlayerByChair(nChair)
        stBlockState = self:GetPlayerBlockState(nChair)
        if stBlockState:GetBlockRecordFlag() == ACTION_TRIPLET then
            LOG_DEBUG("--==GetBlockRecordFlag()-ACTION_TRIPLET---nchair=====:%d !!!!!!!!!!!!!\n", nChair);
            local nRecordCard = stBlockState:GetBlockaRecordCard()
            self:ProcessOPTriplet(stPlayer, nRecordCard)
            return bIsProcessed
        end
    end
    
    -- 6.4处理吃
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

function LibGameLogic:CollectAllTableCardInfo(nChair)
    local stGameState = GGameState
    local stRoundInfo = GRoundInfo
    local stSync = {}
    local stPlayer = stGameState:GetPlayerByChair(nChair)

    stSync.dealer = "p" .. stRoundInfo:GetBanker()
    stSync.roundWind =  stRoundInfo:GetRoundWind()    -- 圈风
    stSync.subRound =  stRoundInfo:GetSubRoundWind()  -- 该圈的第几轮
    stSync.dice =  stRoundInfo:GetDice()
    stSync.game_state = GDealer:GetCurrStage()

    stSync.tileLeft = GDealer:GetDealerCardGroup():GetCurrentLength()
    stSync.tileList = stPlayer:GetPlayerCardGroup():ToArray()
	-- 轮到谁出牌
    local nTurn = stRoundInfo:GetWhoIsOnTurn()
    stSync.whoisOnTurn = nTurn

    -- 分为轮到自己和不是自己  获取当前剩余时间
    if  nTurn ==nChair then
        -- 断线玩家最后摸的牌
        local stPlayerCardGroup = stPlayer:GetPlayerCardGroup()
        stSync.cardLastDraw = stPlayerCardGroup:GetLastDraw() 
    else
    end

    stSync.nleftTime = stRoundInfo:GetReenterTime()
    LOG_DEBUG("Run GetTimerLeftSecond23222244 ===%d\n", stSync.nleftTime) 

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
        end
    end
    return stSync
end


return LibGameLogic