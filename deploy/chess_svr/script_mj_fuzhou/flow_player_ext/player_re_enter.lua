-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_player_re_enter(stPlayer, msg)
    LOG_DEBUG("Run LogicStep player_re_enter")
    if GDealer:IsGameEnd() == true then
        LOG_DEBUG("WHEN re_enter, isGameEnd.\n");
        SSMessage.CallPlayerReady(stPlayer)
        return STEP_SUCCEED
    end
    --刷新玩家游戏信息
    stPlayer:RefreshScore()
    --取消托管(目前没有这个功能)
    stPlayer:SetIsTrust(false)
    --设置该玩家状态为在线
    stPlayer:SetPlayOfflineStatus(0)

    local nChair = stPlayer:GetChairID()
    local stDealerCardGroup = GDealer:GetDealerCardGroup()
    local stGameState = GGameState

    --通知同步开始
    CSMessage.SendSyncBeginNotify(stPlayer)
    --游戏处于哪个极端
    game_state = GDealer:GetCurrStage()

    -- gamecfg必须第一下发
    CSMessage.NotifyOnePlayerStartFlag(stPlayer,GGameCfg.nNeedTingInfo)
    CSMessage.NoitfyPlayerGameCfg(stPlayer, GGameCfg)
    for i=1,PLAYER_NUMBER do
        local stPlayerAll = GGameState:GetPlayerByChair(i)
        if stPlayerAll ~= nil then
            CSMessage.NotifyPlayerEnterTo(stPlayerAll, stPlayer)
            --玩家重连进来后发送其他玩家的断线情况给重连玩家
            CSMessage.NotifyPlayerOfflineTo(stPlayer,stPlayerAll)
        end
    end
    LOG_DEBUG("logic_player_re_enter.... nCurrJu: %d, nJuNum: %d, game_state:%s\n",GGameCfg.nCurrJu,GGameCfg.nJuNum, game_state) 
    local syncTbl = LibGameLogic:CollectAllTableCardInfo(nChair)
    syncTbl.game_state = game_state
    LOG_DEBUG("logic_player_re_enter....syncTbl:%s", vardump(syncTbl))
    --牌桌数据同步
    CSMessage.NotifySyncAllCards(stPlayer, syncTbl)

    ---其他通知 block
    local nLeftTime = 0
    local stRoundInfo = GRoundInfo
    --当前玩家的状态如果是坐下，通知其准备
    if stPlayer:GetPlayerStatus() == PLAYER_STATUS_SIT then
        local nReadyTimeLeft = FlowFramework.GetTimerLeftSecond(nChair)
        LOG_DEBUG("logic_player_re_enter...nReadyTimeLeft: %d", nReadyTimeLeft)
        CSMessage.NotifyPlayerReAskReady(stPlayer, nReadyTimeLeft)
    end

    --[[
    self.m_stageNext = {
        prepare      = "banker",        --定庄
        banker       = "deal",          --抓牌
        deal         = "changeflower",  --补花
        changeflower = "opengold",      --开金
        opengold     = "round",         --游戏阶段
        round        = "reward",        --结算
        reward       = "gameend",       --结束
        gameend      = "prepare",       --开始
    }
    --]]

    if game_state == "prepare" then

    elseif game_state == "banker" then

    elseif game_state == "deal" then

    elseif game_state == "changeflower" then

    elseif game_state == "opengold" then
        
    elseif game_state == "round" then
        local nTurn = stRoundInfo:GetWhoIsOnTurn()
        --当前玩家状态：要出牌、杠胡碰牌
        if  nTurn == nChair then
            local bNeedGive =true
            --轮到自己出牌 但是已经打出去一张牌，别人能碰杠胡，取别人的时间做显示
            nLeftTime = FlowFramework.GetTimerLeftSecond(nChair,-1)
            for j=1, PLAYER_NUMBER do
                --应该排除自己
                if j ~= nChair then
                    if (LibGameLogic:GetPlayerBlockState(j):IsBlocked()) then
                        nLeftTime = FlowFramework.GetTimerLeftSecond(j)
                        bNeedGive = false
                        LOG_DEBUG("Run MY TURN ======%d\n",nLeftTime) 
                    end
                end
            end
            LOG_DEBUG("Run MY TURN 111======%d\n",nLeftTime) 
            local stPlayerBlockState = LibGameLogic:GetPlayerBlockState(nChair)
            LOG_DEBUG("logic_player_re_enter111...nChair:%d, nTurn:%d, nLeftTime:%d, IsBlocked:%s\n, blockReuslt:%s", nChair, nTurn, nLeftTime, tostring(stPlayerBlockState:IsBlocked()), vardump(stPlayerBlockState:GetReuslt()))
            if stPlayerBlockState:IsBlocked() then
                -- no timeout
                CSMessage.NotifyPlayerReAskBlock(stPlayer, stPlayerBlockState:GetReuslt(), false,false,nLeftTime)
            end

            --通知出牌
            --比人可以block时时不通知ask-play
            if bNeedGive then
                local bIsQuick = stPlayer:IsTrust() or stPlayer:IsWin()
                CSMessage.NotifyAskRePlay(stPlayer, bIsQuick, nLeftTime)
            end
        else
            --别人出牌，断线玩家等待、block状态
            local bIsQuick = stPlayer:IsTrust() or stPlayer:IsWin()
            local stPlayerBlockState = LibGameLogic:GetPlayerBlockState(nChair)
            LOG_DEBUG("logic_player_re_enter222...nChair:%d, nTurn:%d, IsBlocked:%s\n, blockReuslt:%s", nChair, nTurn, tostring(stPlayerBlockState:IsBlocked()), vardump(stPlayerBlockState:GetReuslt()))
            if stPlayerBlockState:IsBlocked() then
                nLeftTime = FlowFramework.GetTimerLeftSecond(nChair)
                -- if nLeftTime >0 then
                    -- CSMessage.NotifyPlayerReAskBlock(stPlayer, stPlayerBlockState:GetReuslt(), true, bIsQuick,nLeftTime)
                    -- no time out
                    LOG_DEBUG("logic_player_re_enter333...nChair:%d, nTurn:%d, nLeftTime:%d, blockReuslt:%s", nChair, nTurn, nLeftTime, vardump(stPlayerBlockState:GetReuslt()))
                    CSMessage.NotifyPlayerReAskBlock(stPlayer, stPlayerBlockState:GetReuslt(), false, bIsQuick, nLeftTime) 
                -- end 
            else
                nLeftTime = FlowFramework.GetTimerLeftSecond(nTurn,-1)
            end
            LOG_DEBUG("Run GetTimerLeftSecond ===%d\n",nLeftTime)               
        end 
    elseif game_state == "reward" then

    elseif game_state == "gameend" then

    end

    CSMessage.NotifyBanlanceChangeListToAll()

    stRoundInfo:SetReenterTime(nLeftTime)
    --通知同步结束
    CSMessage.SendSyncEndNotify(stPlayer)
  
    return STEP_SUCCEED
end


return logic_player_re_enter
