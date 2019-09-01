-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_player_re_enter(stPlayer, msg)
    LOG_DEBUG("Run LogicStep player_re_enter")
    if GDealer:IsGameEnd() == true then
        LOG_DEBUG("logic_player_re_enter re_enter, Game End.\n");
        SSMessage.CallPlayerReady(stPlayer)
        return STEP_SUCCEED
    end
    --刷新玩家数据？
    stPlayer:RefreshScore()
    --设置托管(目前没这个功能)
    stPlayer:SetIsTrust(false)

    local nChairid = stPlayer:GetChairID()
    local stGameState = GGameState
    local stPlayerCardGroup = stPlayer:GetPlayerCardGroup()

    --1.通知同步开始
    CSMessage.SendSyncBeginNotify(stPlayer)
    --gamecfg必须第一下发
    CSMessage.NoitfyPlayerGameCfg(stPlayer, GGameCfg)

    --2.通知同步数据
    local sCurrStage = GDealer:GetCurrStage()
    local nBanker = GDealer:GetBanker()
    LOG_DEBUG("logic_player_re_enter...nBanker: %d", nBanker)
    local nWaterBanker = 0
    if GGameCfg.GameSetting.bSupportWaterBanker then
        nWaterBanker = 1
    end
    local nSpecialType = stPlayerCardGroup:GetSpecialType()
    local nSpecialScore = GetSpecialScore(nSpecialType)
    local nMult = LibMult:GetPlayerMult(nChairid)
    local nChoose = 0
    if stPlayer:IsChooseCardType() then
        nChoose = 1
        if stPlayerCardGroup:GetSpecialType() > 0 then
            nChoose = 2
        end
    end
    local stDealerCardGroup = GDealer:GetDealerCardGroup()
    local nDealerCardLeft = stDealerCardGroup:GetCurrentLength()

    local syncTbl = {
        sCurrStage = sCurrStage,    --游戏当前处于哪个阶段
        nWaterBanker = nWaterBanker,--水庄：0不是 1是
        banker = nBanker,           --庄家(水庄是要确定)

        stPlayerState = {},         --玩家状态列表:0没人, 1坐着, 2已准备
        stPlayerUid = {},           --玩家uid列表
        stPlayerChoose ={},         --玩家摆牌阶段玩家的摆牌状态：0没摆，1已摆

        nMult = nMult,              --(对庄家无效)，自己是否已经选择倍数, -1表示没有选
        nChoose = nChoose,          --自己的摆牌状态：0没摆，1已出牌，2出特殊牌
        nSpecialType = nSpecialType,--自己特殊牌型：0不是
        nSpecialScore = nSpecialScore,--特殊牌型对应的积分
        stCards = {},               --自己的牌墩信息，根据摆牌状态来确定：1已出牌(1-5是后墩,6-11是中墩,11-13后墩)
        stCardTypes = {},           --自己的牌墩牌型(依次为后墩，中墩，前墩)
        stCompare = {},             --自己与其他玩家的比牌详细信息
        recommendCards = {},        --推荐牌型
        stLeftCards = {},           --剩余牌
        nLeftCardNums = nDealerCardLeft,           --剩余牌的数量

        nleftTime = 0,              --时钟倒计时
    }
    --2.1把所有玩家的基本信息告诉我
    for i=1,PLAYER_NUMBER do
        local stPlayerAll = GGameState:GetPlayerByChair(i)
        if stPlayerAll then
            local stPlayerCardGroupAll = stPlayerAll:GetPlayerCardGroup()
            --玩家状态列表
            local nState = stPlayerAll:GetPlayerStatus()
            table.insert(syncTbl.stPlayerState, nState)
            --玩家uid列表
            local nUid = stPlayerAll:GetUin()
            table.insert(syncTbl.stPlayerUid, nUid)
            --玩家摆牌状态
            local nChooseState = 0
            if stPlayerAll:IsChooseCardType() then
                nChooseState = 1
            end
            table.insert(syncTbl.stPlayerChoose, nChooseState)

            CSMessage.NotifyPlayerEnterTo(stPlayerAll, stPlayer)
            --玩家重连进来后发送其他玩家的断线情况给重连玩家,只发离线的吧
            if  stPlayerAll:GetPlayOfflineStatus() == 1 then
                CSMessage.NotifyPlayerOfflineTo(stPlayerAll, stPlayer)
            end
            --通知房间累计积分
            LOG_DEBUG("===========NotifyRoomSumScoreToPlayer=====%d, ", stPlayerAll:GetRoomSumScore())
            CSMessage.NotifyRoomSumScoreToPlayer(stPlayerAll, stPlayer)
        end
    end

    --2.2 获取自己牌墩信息
    if sCurrStage == "deal" then
        --自己的牌墩信息
        syncTbl.stCards = stPlayerCardGroup:ToArray()
        syncTbl.recommendCards = stPlayerCardGroup:GetRecommendCards()
    elseif sCurrStage == "choose" then
        if stPlayer:IsChooseCardType() then
            --已摆好牌：已摆的牌+各墩牌型
            syncTbl.stCards = stPlayerCardGroup:GetChooseCardArray()
            for i=3, 1, -1 do
                local nType = stPlayerCardGroup:GetNormalCardtype(i)
                table.insert(syncTbl.stCardTypes, nType)
            end
        else
            --未摆好牌：手牌+推荐牌型 + 摆牌通知？？？
            syncTbl.stCards = stPlayerCardGroup:ToArray()
            syncTbl.recommendCards = stPlayerCardGroup:GetRecommendCards()
        end
        syncTbl.nleftTime = FlowFramework.GetTimerLeftSecond(nChairid,PLAYER_TIMER_ID_CHOOSE)

    elseif sCurrStage == "compare" then
        --比牌结果
        syncTbl.stCompare = stPlayer:GetCompareResult()
        syncTbl.stLeftCards = stDealerCardGroup:ToArray()
    end

    LOG_DEBUG("logic_player_re_enter...%s", vardump(syncTbl))
    CSMessage.NotifySyncAllCards(stPlayer, syncTbl)

    --3.各种阶段通知 准备 选择倍数 摆牌
    --当前玩家的状态如果是坐下，通知其准备
    if stPlayer:GetPlayerStatus() == PLAYER_STATUS_SIT then
        --通知准备+准备时钟
        local nTimeout = FlowFramework.GetTimerLeftSecond(stPlayer:GetChairID(), PLAYER_TIMER_ID_READY)
        CSMessage.ReNotifyPlayerAskReady(stPlayer, nTimeout)
    else

        --水庄 要把选择的倍数做通知
        if GGameCfg.GameSetting.bSupportWaterBanker then
            CSMessage.ReNotifyPlayerMult(stPlayer)
            --如果没有选择 则提醒玩家选择
            if nBanker ~= nChairid and LibMult:IsPlayerMult(nChairid) == false then
                local nTimeout = FlowFramework.GetTimerLeftSecond(nChairid, PLAYER_TIMER_ID_MULT)
                local stMult = {}
                local nMaxMult = GGameCfg.GameSetting.nSupportMaxMult
                for i=1, nMaxMult do
                    table.insert(stMult, i)
                end
                CSMessage.ReNotifyAskMult(stPlayer, stMult, nTimeout)
            end
        end

        if sCurrStage == "deal" then
            -- LOG_DEBUG("logic_player_re_enter...deal,NotifyPlayerDeal..")
            -- CSMessage.NotifyPlayerDeal(stPlayer)
        end
    end

    --4.通知同步结束
    CSMessage.SendSyncEndNotify(stPlayer)
    return STEP_SUCCEED
end


return logic_player_re_enter
