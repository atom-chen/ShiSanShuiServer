-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_player_re_enter(stPlayer, msg)
    LOG_DEBUG("Run LogicStep player_re_enter")
    if GDealer:IsGameEnd() == true then
        LOG_DEBUG("WHEN re_enter, isGameEnd.\n");
        SSMessage.CallPlayerReady(stPlayer)
        return STEP_SUCCEED
    end
    local nChair = stPlayer:GetChairID()
    local stDealerCardGroup = GDealer:GetDealerCardGroup()
    local stGameState = GGameState

    stPlayer:RefreshScore()
    stPlayer:SetIsTrust(false)
    CSMessage.NotifyTrustToAll(stPlayer, false)
    --断线回来请掉超时次数
    LibAutoPlay:ResetPlayerTimeOut(nChair)
    --设置该玩家状态为在线
    stPlayer:SetPlayOfflineStatus(0)

    --sync_begin
    CSMessage.SendSyncBeginNotify(stPlayer)

    game_state = GDealer:GetCurrStage()
    local syncTbl = {
        game_state = game_state,
        player_state = {},
        player_uin = {},
    }
    -- gamecfg必须第一下发
    CSMessage.NoitfyPlayerGameCfg(stPlayer, GGameCfg)
    LOG_DEBUG("Run GGameCfg =nCurrJu==%d,nJuNum==%d\n",GGameCfg.nCurrJu,GGameCfg.nJuNum)  
    -- status必须下发: 0, 1, 2; 没人，坐着，已准备
    for i=1,PLAYER_NUMBER do
        local stPlayerAll = GGameState:GetPlayerByChair(i)
        local player_state = PLAYER_STATUS_NOLOGIN
        local player_uin = 0
        if stPlayerAll ~= nil then
            player_state = stPlayerAll:GetPlayerStatus()
            player_uin = stPlayerAll:GetUin()
            
            CSMessage.NotifyPlayerEnterTo(stPlayerAll, stPlayer)
            --玩家重连进来后发送其他玩家的断线情况给重连玩家
            CSMessage.NotifyPlayerOfflineTo(stPlayer,stPlayerAll)
        end
        table.insert(syncTbl.player_state, player_state)
        table.insert(syncTbl.player_uin, player_uin)
    end
    if game_state == "round" or game_state == "reward" or game_state == "deal" then
        syncTbl.laizi = {
            sit = LibLaiZi:GetSit(),
            card = LibLaiZi:GetCard(),
            laizi = LibLaiZi:GetLaiZi()
        }
        --洛阳次牌
        local nCard = stDealerCardGroup:GetCardAt(1)
        syncTbl.ci = {
            sits = {1},
            cards= nCard
        }
    end
    if game_state ~= "prepare" then
        syncTbl.xiapao = {}
        for i=1,PLAYER_NUMBER do
            local nPlayerXiaPao = LibXiaPao:GetPlayerXiaPao(i)
            table.insert(syncTbl.xiapao, nPlayerXiaPao)
        end
    end
    -- 同步所有台面 sync_table
    local stSyncAll = LibGameLogic:CollectAllTableCardInfo(nChair)
    table.merge(syncTbl, stSyncAll)
    CSMessage.NotifySyncAllCards(stPlayer, syncTbl)

    --获取当前剩余时间
    --房卡场设置timeid为-1
    local nTimeID = 0
    if GGameCfg.nMoneyMode ~= ROOM_MODE_SCORE or GGameCfg.TimerSetting.TimeOutLimit ~= -1 then
        nTimeID =0
    else
        nTimeID =-1
    end

    local nleftTime = 0
    local stRoundInfo = GRoundInfo
    --
    for i=1,1 do
        --当前玩家的状态如果是坐下，通知其准备
        if stPlayer:GetPlayerStatus() == PLAYER_STATUS_SIT then
            local nLeftSeconds = FlowFramework.GetTimerLeftSecond(nChair)
            CSMessage.NotifyPlayerReAskReady(stPlayer, nLeftSeconds)
        end
        if game_state == "prepare" then
            break
        end
        if game_state == "xiapao" then
            nleftTime = FlowFramework.GetTimerLeftSecond(nChair, nTimeID) 
            local nPlayerXiaPao = LibXiaPao:GetPlayerXiaPao(nChair)
            if  GGameCfg.GameSetting.bSupportXiaPao then
                --通知该玩家下跑结果
                CSMessage.ReNotifyPlayerXiaPao(stPlayer)
                if nPlayerXiaPao ~=-1 then
                     break
                else 
                    CSMessage.NotifyAskReXiaPao(stPlayer, {0,1,2,3}, nleftTime)
                    break
                end
            end
        end
        -- 正在下跑，还没跑完的
        if game_state == "deal" then
            break
        end
        -- 有发牌了
        if game_state == "laizi" then
            break
        end
        --
        if game_state == "round" then
            --是否轮到自己
            local nTurn = stRoundInfo:GetWhoIsOnTurn()
            local bIsQuick = stPlayer:IsTrust() or stPlayer:IsWin()
            --当前玩家状态：要出牌、杠胡碰牌
            if  nTurn == nChair then
                nleftTime = FlowFramework.GetTimerLeftSecond(nChair,nTimeID)
                ----轮到自己出牌 但是已经打出去一张牌，别人能碰杠胡，取别人的时间做显示
                for j=1,PLAYER_NUMBER do
                    --TODO：应该排除自己
                    if j ~= nChair then
                        if (LibGameLogic:GetPlayerBlockState(j):IsBlocked()) then
                            nleftTime = FlowFramework.GetTimerLeftSecond(j)
                            LOG_DEBUG("Run MY TURN ======%d\n",nleftTime) 
                        end
                    end
                end
                LOG_DEBUG("Run MY TURN 111======%d\n",nleftTime) 
                local stPlayerBlockState = LibGameLogic:GetPlayerBlockState(nChair)
                -- no timeout
                CSMessage.NotifyPlayerReAskBlock(stPlayer, stPlayerBlockState:GetReuslt(), false)
                CSMessage.NotifyAskRePlay(stPlayer, bIsQuick, nleftTime)
            else
                --别人出牌，断线玩家等待、block状态
                local stPlayerBlockState = LibGameLogic:GetPlayerBlockState(nChair)
                if stPlayerBlockState:IsBlocked() then
                    nleftTime = FlowFramework.GetTimerLeftSecond(nChair)
                    if nleftTime >0 then
                        CSMessage.NotifyPlayerReAskBlock(stPlayer, stPlayerBlockState:GetReuslt(), true, bIsQuick, nleftTime) 
                    end 
                else
                    nleftTime = FlowFramework.GetTimerLeftSecond(nTurn, nTimeID)
                end
                LOG_DEBUG("Run GetTimerLeftSecond ===%d\n",nleftTime)               
            end  
            break
        end
        -- 正在玩
        if game_state == "reward" then
            break
        end
        -- 正在结算
        if game_state == "gameend" then
            break
        end
    end
    stRoundInfo:SetReenterTime(nleftTime)

    --sync_end
    CSMessage.SendSyncEndNotify(stPlayer)
  
    return STEP_SUCCEED
end


return logic_player_re_enter
