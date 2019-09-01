import("core.error_msg_define")
local CSMessage = CSMessage or {}
local stGameState = nil
local stRoundInfo = nil

_GameModule = _GameModule or {}
_GameModule._TableLogic = _GameModule._TableLogic or  {}
_GameModule._TableLogic.SendEvent = _GameModule._TableLogic.SendEvent or function (...) end

local SendEvent = _GameModule._TableLogic.SendEvent
function CSMessage.CreateInit()
    stGameState = GGameState
    stRoundInfo = GRoundInfo
    return true
end

-- PRIVATE FUNCTION START
function CSMessage.NotifyOnePlayerTo (stPlayer, event, para, fromChairID, timeo)
    local notify = {
        _cmd = event,
        _st = "nti",
        _src = "s",
        timeo = timeo,
        _para = para or {}
    }
    if fromChairID ~= nil then
        notify._src = "p" ..fromChairID
    end
    SendEvent(G_TABLEINFO.tableptr,stPlayer:GetChairID(), stPlayer:GetPlayerID(), notify)
end

function CSMessage.NotifyOnePlayer (stPlayer, event, para, timeo)
    local chairID = stPlayer:GetChairID()
    CSMessage.NotifyOnePlayerTo(stPlayer, event, para, chairID, timeo)
end

function CSMessage.NotifyExceptPlayer (fromPlayer, event, para, timeo)
    local chairID = fromPlayer:GetChairID()
    -- LOG_DEBUG("NotifyExceptPlayer: event:%s, para:%s, from:%d, to:%d", event, vardump(para), chairID, 0);
    for i=1, PLAYER_NUMBER do
        local stPlayer = stGameState:GetPlayerByChair(i)
        if i ~= chairID and stPlayer ~= nil then
            -- LOG_DEBUG("==NotifyExceptPlayer: event:%s, para:%s, from:%d, to:%d", event, vardump(para), chairID, i);
            CSMessage.NotifyOnePlayerTo(stPlayer, event, para, chairID, timeo)
        end
    end
end

function CSMessage.NotifyAllPlayer (fromPlayer, event, para, timeo)
    local chairID
    if fromPlayer ~= nil then
        chairID = fromPlayer:GetChairID()
    end

    for i=1, PLAYER_NUMBER do
        local stPlayer = stGameState:GetPlayerByChair(i)
        if stPlayer ~= nil then
            local fromChairID = chairID or i
            CSMessage.NotifyOnePlayerTo(stPlayer, event, para, fromChairID, timeo)
        end
    end  
end

function CSMessage.NotifyError(stPlayer, nErrorID, msg)
    local para = {
        id = nErrorID,
        msg = msg
    }
    CSMessage.NotifyOnePlayer(stPlayer, "error", para)
end
-- PRIVATE FUNCTION END

-- PUBLIC FUNCTION START 
--通知玩家进入桌子
function CSMessage.NotifyPlayerEnterTo(stPlayerEnter, stPlayerTo)
    local para = stPlayerEnter:GetUserInfo()
    para.gid = GGameCfg._gid
    -- LOG_DEBUG("GID=%d, cfg=%s", GGameCfg._gid, vardump(GGameCfg));
    CSMessage.NotifyOnePlayerTo(stPlayerTo, "enter", para, stPlayerEnter:GetChairID())
end
function CSMessage.NotifyPlayerEnterToAll(stPlayerEnter)
    local para = stPlayerEnter:GetUserInfo()
    para.gid = GGameCfg._gid
    LOG_DEBUG("GID= 2 %d, cfg=%s", para.gid, vardump(para));
    CSMessage.NotifyAllPlayer(stPlayerEnter, "enter", para);
end

--通知玩家准备
function CSMessage.NotifyPlayerReadyTo(stPlayerReady, stPlayerTo)
    local para = {
        _chair = stPlayerReady:GetChairID(),
        _uid = stPlayerReady:GetUin()
    }
    CSMessage.NotifyOnePlayerTo(stPlayerTo, "ready", para, stPlayerReady:GetChairID())
end
function CSMessage.NotifyPlayerAskReady(stPlayer)
    -- ready 的消息金币场是不需要超时的, 为-1
    local nTimeout = -1
    -- 是在房卡的非第一局时，才做超时处理,  第一局不做定时器
    if GGameCfg.nMoneyMode == ROOM_MODE_SCORE and GGameCfg.nCurrJu ~= 1 then
        nTimeout = GGameCfg.nClearTableReadyTimeOut
        if GGameCfg.nClearTableReadyTimeOut > 0 then
            FlowFramework.SetTimer(stPlayer:GetChairID(), nTimeout, PLAYER_TIMER_ID_READY)
        end
    end
    CSMessage.NotifyOnePlayer(stPlayer, "ask_ready", {}, nTimeout)
end
function CSMessage.NotifyPlayerReadyToAll(stPlayer)
    local para = {
        _chair = stPlayer:GetChairID(),
        _uid = stPlayer:GetUin(),
    }
    CSMessage.NotifyAllPlayer(stPlayer, "ready", para)
end
--重连
function CSMessage.ReNotifyPlayerAskReady(stPlayer,nTime)
    local nTimeout = -1
    -- 是在房卡的非第一局时，才做超时处理， 第一局不做定时器
    if GGameCfg.nMoneyMode == ROOM_MODE_SCORE and GGameCfg.nCurrJu ~= 1 then
        nTimeout = nTime or 0
        if GGameCfg.nClearTableReadyTimeOut > 0 then
            FlowFramework.SetTimer(stPlayer:GetChairID(), nTimeout, PLAYER_TIMER_ID_READY)
        end
    end
    CSMessage.NotifyOnePlayer(stPlayer, "ask_ready", {}, nTimeout)
end

--下发游戏配置
function CSMessage.NoitfyPlayerGameCfg(stPlayer, stGameCfg)
    local cfg = {
        chairID = stPlayer:GetChairID(),
        rno = stGameCfg.rno,
        rid = stGameCfg.rid,
        _gid = stGameCfg._gid,
        owner_uid = stGameCfg.uid,   --房主uid
        nMoneyMode = stGameCfg.nMoneyMode,
        nPlayerNum = stGameCfg.nPlayerNum,
        nJuNum = stGameCfg.nJuNum,
        nCurrJu = stGameCfg.nCurrJu,
        TimerSetting = stGameCfg.TimerSetting,
        GameSetting = stGameCfg.GameSetting,
    }
    CSMessage.NotifyOnePlayer(stPlayer, "game_cfg", cfg)
end

--通知所有玩家游戏开始
function CSMessage.NotifyAllPlayerStartGame()
    CSMessage.NotifyAllPlayer(nil, "game_start")
end

--通知闲家选择倍数
function CSMessage.NotifyAskMult(stPlayer, stMultOptinal)
    local para = {
        optional = stMultOptinal
    }
    --定时器
    local nTimeout = GGameCfg.TimerSetting.multTimeOut
    FlowFramework.SetTimer(stPlayer:GetChairID(), nTimeout, PLAYER_TIMER_ID_MULT)

    CSMessage.NotifyOnePlayer(stPlayer, "ask_mult", para, nTimeout)
end
function CSMessage.NotifyPlayerMult(stPlayer, nBeishu)
    local para = {}
    for i=1,PLAYER_NUMBER do
        if (GGameState:GetPlayerByChair(i) == stPlayer) then
            para["p" ..i] = nBeishu
            break
        end
    end
    CSMessage.NotifyAllPlayer(stPlayer, "mult", para)
end
function CSMessage.NotifyMultResult(stPlayer, stMultResult)
    local para = {}
    for i=1,PLAYER_NUMBER do
        local nMult = stMultResult[i] or 1
        table.insert(para, nMult)
    end

    if stPlayer ~= nil then
        CSMessage.NotifyOnePlayer(stPlayer, "all_mult", para)
    else
        CSMessage.NotifyAllPlayer(nil, "all_mult", para)
    end
end
--重连
function CSMessage.ReNotifyAskMult(stPlayer, stMultOptinal, nTimeout)
    local para = {
        optional = stMultOptinal
    }
    --定时器
    nTimeout = nTimeout or 0
    FlowFramework.SetTimer(stPlayer:GetChairID(), nTimeout, PLAYER_TIMER_ID_MULT)

    CSMessage.NotifyOnePlayer(stPlayer, "ask_mult", para, nTimeout)
end
--重连时通知自己, 别人包括自己的选择倍数状态
function CSMessage.ReNotifyPlayerMult(stPlayer)
    for i=1,PLAYER_NUMBER do
        local nBeishu = LibMult:GetPlayerMult(i)
        if nBeishu ~= -1 then
            local para = {}
            para["p" ..i] = nBeishu
            CSMessage.NotifyOnePlayer(stPlayer, "mult", para)
        end
    end
end

--把牌发给玩家
function CSMessage.NotifyPlayerDeal(stPlayer, nDealerCardLeft)
    local stPlayerCardGroup = stPlayer:GetPlayerCardGroup()
    local stCards = stPlayerCardGroup:ToArray()
    local nSpecialType = stPlayerCardGroup:GetSpecialType()
    local nSpecialScore = GetSpecialScore(nSpecialType)
    local para = {
        -- banker = GDealer:GetBanker(),  -- 水庄，庄家
        stCards = stCards,
        nSpecialType = nSpecialType,
        nSpecialScore = nSpecialScore,
        nNeedRecommend = GGameCfg.nNeedRecommend or 0,
        nLeftCardNums = nDealerCardLeft,
    }

    -- LOG_DEBUG("NotifyPlayerDeal ---: %s\n", vardump(para))
    CSMessage.NotifyOnePlayer(stPlayer, "deal", para)
end

--推荐牌型
function CSMessage.NotifyPlayerRecommend(stPlayer)
    local stPlayerCardGroup = stPlayer:GetPlayerCardGroup()
    local recommend2 = stPlayerCardGroup:GetRecommendCards()
    local para = {
        recommendCards = recommend2,
    }

    -- LOG_DEBUG("NotifyPlayerRecommend ---: %s\n", vardump(para))
    CSMessage.NotifyOnePlayer(stPlayer, "recommend", para)
end

--通知玩家可以选择牌型(摆牌)
function CSMessage.NotifyAskChooseCardType(stPlayer)
    -- local nTimeout = GGameCfg.TimerSetting.chooseCardTypeTimeOut + GGameCfg.TimerSetting.startTime + GGameCfg.TimerSetting.shuffTime
    local nTimeout = 0
    if stPlayer:GetOpChooseNums() == 0 then
        nTimeout = GGameCfg.TimerSetting.chooseCardTypeTimeOut
    else
        --玩家点击出牌会触发退出行为树  (相公的时候需要ask_choose)需要重新设置行为树
        nTimeout = FlowFramework.GetTimerLeftSecond(stPlayer:GetChairID(), PLAYER_TIMER_ID_CHOOSE)
    end
    FlowFramework.SetTimer(stPlayer:GetChairID(), nTimeout, PLAYER_TIMER_ID_CHOOSE)
    CSMessage.NotifyOnePlayer(stPlayer, "ask_choose", {}, nTimeout)
end
--通知玩家 有人已经摆好牌了
function CSMessage.NotifyPlayerChooseCardType(stPlayer)
    local para = {}
    CSMessage.NotifyAllPlayer(stPlayer, "choose_ok", para)
end
--重连，通知玩家可以选择牌型(摆牌)
function CSMessage.ReNotifyAskChooseCardType(stPlayer, nTimeout)
    nTimeout = nTimeout or 0
    FlowFramework.SetTimer(stPlayer:GetChairID(), nTimeout, PLAYER_TIMER_ID_CHOOSE)
    CSMessage.NotifyOnePlayer(stPlayer, "ask_choose", {}, nTimeout)
end
--重连时通知自己, 别人包括自己的摆牌状态
function CSMessage.ReNotifyPlayerChooseCardTypeTo(stPlayerChoose, stPlayerTo)
    local para = {}
    CSMessage.NotifyOnePlayerTo(stPlayerTo, "choose_ok", para, stPlayerChoose:GetChairID())
end

--通知玩家 比牌开始
function CSMessage.NotifyPlayerCompareStart()
    local para = {}
    CSMessage.NotifyAllPlayer(nil, "compare_start", para)
end
--通知玩家 比牌结果
function CSMessage.NotifyPlayerCompareResult(stPlayer, notifyData)
    -- LOG_DEBUG("CSMessage.NotifyPlayerCompareResult...")
    CSMessage.NotifyOnePlayer(stPlayer, "compare_result", notifyData)
end
--通知玩家 比牌结束
function CSMessage.NotifyPlayerCompareEnd()
    -- LOG_DEBUG("CSMessage.NotifyPlayerCompareEnd...")
    local para = {}
    CSMessage.NotifyAllPlayer(nil, "compare_end", para)
end

--把游戏结果发给玩家
function CSMessage.SendRoundResultToPlayer(stPlayer, notifyData)
    CSMessage.NotifyOnePlayer(stPlayer, "rewards", notifyData)
end

--通知游戏结束
function CSMessage.NotifyAllPlayerGameEnd()
    local para = {}
    CSMessage.NotifyAllPlayer(nil, "gameend", para)
end

--
function CSMessage.NotifyRoomSumScoreToPlayer(stPlayerFrom, stPlayerTo)
    -- LOG_DEBUG("CSMessage.NotifyRoomSumScoreToPlayer...from:%d, to:%d", stPlayerFrom:GetChairID(), stPlayerTo:GetChairID())
    if stPlayerFrom then
        local para = {
            -- _chair = stPlayerFrom:GetChairID(),
            nRoomSumScore = stPlayerFrom:GetRoomSumScore(),          --开房后房间游戏累计积分
        }
        CSMessage.NotifyOnePlayerTo(stPlayerTo, "room_sum_score", para,  stPlayerFrom:GetChairID())
    end
end
function CSMessage.NotifyPlayerRoomSumScoreToAll(stPlayer)
    if stPlayer then
        local para = {
            -- _chair = stPlayer:GetChairID(),
            nRoomSumScore = stPlayer:GetRoomSumScore(),          --开房后房间游戏累计积分
        }
        CSMessage.NotifyAllPlayer(stPlayer, "room_sum_score", para)
    end
end



--ext

--断线重连==========================================
function CSMessage.SendSyncBeginNotify(stPlayer)
    CSMessage.NotifyOnePlayer(stPlayer, "sync_begin")
end
function CSMessage.NotifySyncAllCards(stPlayer, stSyncAllCards)
    CSMessage.NotifyOnePlayer(stPlayer, "sync_table", stSyncAllCards)
end
function CSMessage.SendSyncEndNotify(stPlayer)
    CSMessage.NotifyOnePlayer(stPlayer, "sync_end")
end
--==================================================

--聊天
function CSMessage.SendChatMessageToOther(stPlayer,content,contenttype,givewho)
    local para = {
        content = content,
        contenttype = contenttype
    }
    if contenttype==4 then
        para.givewho =givewho
    end
    LOG_DEBUG("Run LogicStep do_chat=send==%s",vardump(para))
    CSMessage.NotifyAllPlayer(stPlayer, "chat", para)
end

--获取玩家信息
function CSMessage.ResponsePlayerInfo(stPlayer, _chair , stPlayerRsp)
    local para = {
        stPlayerRsp
    }
    CSMessage.NotifyOnePlayerTo(stPlayer, "player_info", para, _chair)
end

--金币积分刷新变更
function CSMessage.NotifyPlayerPointsRefresh(stPlayer)
    local para = {
        stPlayer:GetPlayerPointsSt()
    }
    CSMessage.NotifyAllPlayer(stPlayer, "points_refresh", para)
end

--玩家托管
function CSMessage.NotifyTrustToAll(stPlayerTrust, nStatus)
    local para = {
        setStatus = nStatus
    }
    CSMessage.NotifyAllPlayer(stPlayerTrust, "autoplay", para)
end

--离开游戏
function CSMessage.NotifyPlayerLeave(stPlayer, reason)
    local para = stPlayer:GetUserInfo()
    para.reason = reason
    CSMessage.NotifyAllPlayer(stPlayer, "leave", para)
end

--玩家离线
function CSMessage.NotifyPlayerOffline(stPlayer,nActive)
      local para = stPlayer:GetUserInfo()
    para.active = nActive
    CSMessage.NotifyExceptPlayer(stPlayer, "offline", para)
end
--玩家重连进来后发送其他玩家的断线情况给重连玩家
function CSMessage.NotifyPlayerOfflineTo(stPlayerOffline, stPlayerTo)
    local para = stPlayerOffline:GetUserInfo()
    para.active = stPlayerOffline:GetPlayOfflineStatus()
    CSMessage.NotifyOnePlayerTo(stPlayerTo, "offline", para, stPlayerOffline:GetChairID())
end

--实时同步分数
function CSMessage.NotifyBanlanceChangeListToAll()
    local stScoreRecord = LibGame:GetScoreRecord()
    local xxscore = {}
    for i = 1, PLAYER_NUMBER do
        xxscore[i] = stScoreRecord:GetPlayerSumScore(i)
    end
    local para = {
        totalscore = xxscore              --当前各个玩家的总分数
    }
    CSMessage.NotifyAllPlayer(nil, "account", para)
end


return CSMessage