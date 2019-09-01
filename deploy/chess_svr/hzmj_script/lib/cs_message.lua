
local CSMessage = CSMessage or {}
local stGameState = nil
local stRoundInfo = nil

_GameModule = _GameModule or {}
_GameModule._TableLogic = _GameModule._TableLogic or  {}
_GameModule._TableLogic.SendEvent = _GameModule._TableLogic.SendEvent or function (...)
end


local SendEvent = _GameModule._TableLogic.SendEvent
import("core.error_msg_define")
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
        -- if timeo and timeo > 0 then
        --     FlowFramework.SetTimer(fromChairID, timeo)
        -- end
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
        -- if timeo and timeo > 0 then
        --     FlowFramework.SetTimer(chairID, timeo)
        -- end
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

function CSMessage.NotifyPlayerAskReady(stPlayer)
    -- ready 的消息金币场是不需要超时的, 为-1
    local nTimeout = -1

    -- todo: 是在房卡的非第一局时，才做超时处理
    if GGameCfg.nMoneyMode == ROOM_MODE_SCORE and GGameCfg.nCurrJu ~= 1 then
        nTimeout = GGameCfg.TimerSetting.readyTimeOut
        FlowFramework.SetTimer(stPlayer:GetChairID(), nTimeout)
    end

    CSMessage.NotifyOnePlayer(stPlayer, "ask_ready", {}, nTimeout)
end
function CSMessage.NotifyPlayerReAskReady(stPlayer,nTime)
    -- ready 的消息金币场是不需要超时的, 为-1
    local nTimeout = -1

    -- todo: 是在房卡的非第一局时，才做超时处理
    if GGameCfg.nMoneyMode == ROOM_MODE_SCORE and GGameCfg.nCurrJu ~= 1 then
        nTimeout = nTime
        FlowFramework.SetTimer(stPlayer:GetChairID(), nTimeout)
    end

    CSMessage.NotifyOnePlayer(stPlayer, "ask_ready", {}, nTimeout)
end
function CSMessage.NoitfyPlayerGameCfg(stPlayer, stGameCfg)
    local cfg = {
        nMoneyMode = stGameCfg.nMoneyMode,
        nPlayerNum = stGameCfg.nPlayerNum,
        nJuNum = stGameCfg.nJuNum,
        nCurrJu = stGameCfg.nCurrJu,
        rno = stGameCfg.rno,
        rid = stGameCfg.rid,
        gid = stGameCfg._gid,
        owner_uid = stGameCfg.uid,
        CardPoolType = stGameCfg.CardPoolType,
        TimerSetting = stGameCfg.TimerSetting,
        GameSetting = stGameCfg.GameSetting,
        chairID = stPlayer:GetChairID(),
    }
    CSMessage.NotifyOnePlayer(stPlayer, "game_cfg", cfg)
end

function CSMessage.NotifyPlayerEnterTo(stPlayerEnter, stPlayerTo)
    local para = stPlayerEnter:GetUserInfo()
    para.gid = GGameCfg._gid
    CSMessage.NotifyOnePlayerTo(stPlayerTo, "enter", para, stPlayerEnter:GetChairID())
end

function CSMessage.NotifyPlayerReadyTo(stPlayerReady, stPlayerTo)
    local para = {
        _chair = stPlayerReady:GetChairID(),
        _uid = stPlayerReady:GetUin()
    }
    CSMessage.NotifyOnePlayerTo(stPlayerTo, "ready", para, stPlayerReady:GetChairID())
end

function CSMessage.NotifyPlayerEnterToAll(stPlayerEnter)
    local para = stPlayerEnter:GetUserInfo()
    para.gid = GGameCfg._gid or 0--tonumber(GGameCfg._gid)
    LOG_DEBUG("GID= 2 %d, cfg=%s", para.gid, vardump(para));
    CSMessage.NotifyAllPlayer(stPlayerEnter, "enter", para);
end

function CSMessage.NotifyPlayerReadyToAll(stPlayer)
    local para = {
        _chair = stPlayer:GetChairID(),
        _uid = stPlayer:GetUin()
    }
    CSMessage.NotifyAllPlayer(stPlayer, "ready", para)
end

function CSMessage.NotifyPlayerLeave(stPlayer, reason)
    -- CSMessage.NotifyExceptPlayer(stPlayer, "leave", stPlayer:GetUserInfo())
    local para = stPlayer:GetUserInfo();
    para.reason = reason;
    CSMessage.NotifyAllPlayer(stPlayer, "leave", para)
end

function CSMessage.NotifyPlayerOffline(stPlayer,nActive)
      local para = stPlayer:GetUserInfo();
    para.active = nActive;
    CSMessage.NotifyExceptPlayer(stPlayer, "offline", para)
end

--玩家重连进来后发送其他玩家的断线情况给重连玩家
function CSMessage.NotifyPlayerOfflineTo(stPlayerTo, stPlayerOffline)
    local para = stPlayerOffline:GetUserInfo();
    para.active = stPlayerOffline:GetPlayOfflineStatus()
    CSMessage.NotifyOnePlayerTo(stPlayerTo, "offline", para, stPlayerOffline:GetChairID())
end

function CSMessage.NotifyAllPlayerStartGame()
    CSMessage.NotifyAllPlayer(nil, "game_start")
end
function CSMessage.NotifyOnePlayerStartGame(stPlayer)
    CSMessage.NotifyOnePlayer(stPlayer, "game_start")
end

function CSMessage.NotifyPlayerBanker(stPlayer)
    local para = {
        banker = stRoundInfo:GetBanker(),  -- 庄家  
        dice = stRoundInfo:GetDice()      --色子
    }
    CSMessage.NotifyOnePlayer(stPlayer, "banker", para);
end
function CSMessage.NotifyPlayerDealDice(stPlayer)
    local para = {
        dice = stRoundInfo:GetDealDice()      --色子
    }
    CSMessage.NotifyOnePlayer(stPlayer, "dealdice", para);
end
function CSMessage.NotifyPlayerDeal(stPlayer, stCardCount, nDealerCardLeft)
    local para = {
        cards = stPlayer:GetPlayerCardGroup():ToArray(),
        --currentCardsNum = #arrCards,
        banker = stRoundInfo:GetBanker()  ,  -- 庄家
        roundWind = stRoundInfo:GetRoundWind(),   -- 圈风
        subRound = stRoundInfo:GetSubRoundWind(),    -- 该圈的第几轮
        dice = stRoundInfo:GetDice(),
        cardCount = stCardCount,
        cardLeft = nDealerCardLeft       
    }
    CSMessage.NotifyOnePlayer(stPlayer, "deal", para);
end


function CSMessage.NotifyAllPlayStart()
    CSMessage.NotifyAllPlayer(nil, "play_start");
end
function CSMessage.NotifyOnePlayStart(stPlayer)
    CSMessage.NotifyOnePlayer(stPlayer, "play_start");
end

-- 给牌玩家了
function CSMessage.NotifyPlayerGiveCard(stPlayer, stCards, nDealCardLeft)
    local para = {
        cards = stCards,
        cardLeft = nDealCardLeft
    }
    CSMessage.NotifyOnePlayer(stPlayer, "give_card", para)

    local para = {
        nCardNum = #stCards,
        cardLeft = nDealCardLeft
    }
    CSMessage.NotifyExceptPlayer(stPlayer, "give_card", para)

    -- 要求stPlayer出牌的逻辑是否直接关联
    --CSMessage.NotifyAllPlayer(stPlayer, "ask_play")
end

function CSMessage.NotifyAskPlay(stPlayer, bIsQuick)
    -- 问了，就得要求超时
    local nTimeout = GGameCfg.TimerSetting.AutoPlayTimeOut
    if not bIsQuick then
        nTimeout = GGameCfg.TimerSetting.giveTimeOut
    end
    --房卡房间并且有限制时不设置超时
    if GGameCfg.nMoneyMode ~= ROOM_MODE_SCORE or GGameCfg.TimerSetting.TimeOutLimit ~= -1 then
        FlowFramework.SetTimer(stPlayer:GetChairID(), nTimeout)
    else
        --房卡房间也设置超时timeid设为-1，在Time_mng做判断，不发超时事件
        FlowFramework.SetTimer(stPlayer:GetChairID(), nTimeout,-1)

        --test
        -- FlowFramework.SetTimer(stPlayer:GetChairID(), 5)
    end
    --机器人的话发给客户端显示的时间
    if stPlayer:IsRobot()  then
        nTimeout = GGameCfg.TimerSetting.giveTimeOut
    end
    CSMessage.NotifyAllPlayer(stPlayer, "ask_play", {}, nTimeout)

end

function CSMessage.NotifyPlayerAskBlock(stPlayer, stBlockResut, bNeedTimer, bIsQuick)
    local nTimeout = GGameCfg.TimerSetting.blockTimeOut

    if bNeedTimer then
        nTimeout = GGameCfg.TimerSetting.AutoPlayTimeOut
        if not bIsQuick then
            nTimeout = GGameCfg.TimerSetting.blockTimeOut
        end
        -- 房卡房间并且有限制时不设置超时---block时还是设置超时
        -- if GGameCfg.nMoneyMode ~= ROOM_MODE_SCORE or GGameCfg.TimerSetting.TimeOutLimit ~= -1 then
        FlowFramework.SetTimer(stPlayer:GetChairID(), nTimeout)
        -- end
    else
        FlowFramework.SetTimer(stPlayer:GetChairID(), nTimeout, -1)
    end
    CSMessage.NotifyOnePlayer(stPlayer, "ask_block", stBlockResut, nTimeout)
end
--重进时
function CSMessage.NotifyAskRePlay(stPlayer, bIsQuick,nTime)
    -- 问了，就得要求超时
    local nTimeout = GGameCfg.TimerSetting.AutoPlayTimeOut
    if not bIsQuick then
        nTimeout = nTime
    end
    --房卡房间并且有限制时不设置超时
    if GGameCfg.nMoneyMode ~= ROOM_MODE_SCORE or GGameCfg.TimerSetting.TimeOutLimit ~= -1 then
        FlowFramework.SetTimer(stPlayer:GetChairID(), nTimeout)
    else
        --房卡房间也设置超时timeid设为-1，在Time_mng做判断，不发超时事件
         FlowFramework.SetTimer(stPlayer:GetChairID(), nTimeout,-1)
    end
    CSMessage.NotifyOnePlayer(stPlayer, "ask_play", {}, nTimeout)
end

function CSMessage.NotifyPlayerReAskBlock(stPlayer, stBlockResut, bNeedTimer, bIsQuick, nTime)
    local nTimeout = nTime
    if bNeedTimer then
        nTimeout = GGameCfg.TimerSetting.AutoPlayTimeOut
        if not bIsQuick then
            nTimeout = nTime
        end
        -- if GGameCfg.nMoneyMode ~= ROOM_MODE_SCORE or GGameCfg.TimerSetting.TimeOutLimit ~= -1 then
        FlowFramework.SetTimer(stPlayer:GetChairID(), nTimeout)
        -- end
    else
        FlowFramework.SetTimer(stPlayer:GetChairID(), nTimeout, -1)
    end
    CSMessage.NotifyOnePlayer(stPlayer, "ask_block", stBlockResut, nTimeout)
end
-- who  碰谁的 牌
function CSMessage.NotifyBlockTriplet(stPlayer, nTurn, nCard)
    local para = {
        tripletWho = nTurn,
        cardTriplet = {triplet=nCard, useCards={nCard, nCard}},
    }
    CSMessage.NotifyAllPlayer(stPlayer, "triplet", para)
end
function CSMessage.NotifyBlockQuadruplet(stPlayer, nCard, nTurn, nType)
    local quadrupletType = 1
    local cardQuadruplet = {}
    -- 杠别人
    local stQuadruplet = {}
    if nType == ACTION_QUADRUPLET then
        quadrupletType = 1
        stQuadruplet = {quadruplet = nCard, useCards = {nCard, nCard, nCard}}
    elseif nType == ACTION_QUADRUPLET_REVEALED then
        -- 2 碰上加杠 明杠
        quadrupletType = 2
        stQuadruplet = { useCards = {nCard}}
    elseif nType == ACTION_QUADRUPLET_CONCEALED then
        -- 3 暗杠，现在也让别人看到的
        quadrupletType = 3
        stQuadruplet = {useCards = {nCard, nCard, nCard, nCard}}
    end

    local para = {
        quadrupletWho = nTurn,
        quadrupletType = quadrupletType,
        cardQuadruplet = stQuadruplet,
    }
    CSMessage.NotifyAllPlayer(stPlayer, "quadruplet", para)
end

--增加呼叫转移结果通知

function CSMessage.NotifyGangMoveResultToAll(stScoreRecord)
    local ScoreRecord = {}
    for i=1,PLAYER_NUMBER do
        ScoreRecord["p" ..i] = stScoreRecord[i]
    end
    CSMessage.NotifyAllPlayer(nil, "GangMove", ScoreRecord)
end

function CSMessage.NotifyPlayerBlockTing(stPlayer, stTingCards)
    local para = {
        cardWin = stTingCards
    }
    CSMessage.NotifyOnePlayer(stPlayer, "ting", para)
end

function CSMessage.NotifyPlayerOtherPlayerPlay(stPlayer, playChairID, stCards)
    local para = {
        cards = stCards
    }
    CSMessage.NotifyOnePlayerTo(stPlayer, "play", para, playChairID);    
end


function CSMessage.NotifyPlayerPlayCard(stPlayer, stCards)
    LOG_DEBUG("NotifyPlayerPlayCard, %d, %s", stPlayer:GetChairID(), vardump(stCards))
    local para = {
        cards = stCards
    }
    CSMessage.NotifyAllPlayer(stPlayer, "play", para);
end

function CSMessage.NotifyPlayerLaizi(stPlayer, sit, card, laizi)
    local para = {
        sits = sit,
        cards= card,
        laizi= laizi
    }
    if stPlayer ~= nil then
        CSMessage.NotifyOnePlayer(stPlayer, "laizi", para);
    else
        CSMessage.NotifyAllPlayer(nil, "laizi", para);
    end
end

function CSMessage.NotifyPlayerBuyCode(stPlayer, bInfo)
    local stInfo = {}
    if bInfo then
        stInfo = LibBuyCode:GetBuyCodeInfo()
    end

    local nDealCardLeft = GDealer:GetDealerCardGroup():GetCurrentLength()
    local para = { buyCodeInfo = stInfo, cardLeft = nDealCardLeft, buyCodeType = GGameCfg.GameSetting.nBuyCodeType }
    
    if stPlayer ~= nil then
        CSMessage.NotifyOnePlayer(stPlayer, "buycode", para);
    else
        CSMessage.NotifyAllPlayer(nil, "buycode", para);
    end
end




function CSMessage.NotifyBanlanceChangeListToAll(stBalanceList)
    local stScoreRecord = LibGameLogic:GetScoreRecord()
    local xxscore ={}
    local gangscore = {}
    for i=1,PLAYER_NUMBER do
        xxscore[i] = stScoreRecord:GetPlayerSumScore(i)
        gangscore[i] = stScoreRecord:GetPlayerGangScore(i)
    end
    local para = {
        accountList = stBalanceList,
        totalscore = xxscore,              --当前各个玩家的总分数
        gangscore = gangscore
    }
    CSMessage.NotifyAllPlayer(nil, "account", para)
end
function CSMessage.NotifyPlayerWin(stWinList)
    local stRoundInfo = GRoundInfo
    local para = {
        winList = stWinList,
        winList_all = stRoundInfo:GetWinList()
    }
    CSMessage.NotifyAllPlayer(nil, "win", para)   
end
function CSMessage.SendRoundResultToPlayer(stPlayer, notifyData)
    notifyData.nMaxFanCoun = GGameCfg.GameSetting.nMaxFan
    LOG_DEBUG("-----maxfansendto----%s",notifyData.nMaxFanCoun)
    CSMessage.NotifyOnePlayer(stPlayer, "rewards", notifyData)
end
function CSMessage.SendAllRoundResultToPlayer(stPlayer, notifyData)
    CSMessage.NotifyOnePlayer(stPlayer, "total_rewards", notifyData)
end
function CSMessage.NotifySyncAllCards(stPlayer, stSyncAllCards)
    CSMessage.NotifyOnePlayer(stPlayer, "sync_table", stSyncAllCards)
end

function CSMessage.NotifyWinHint(stPlayer, stWinNotice)
    local para = {
        hintList = stWinNotice
    }
    CSMessage.NotifyOnePlayer(stPlayer, "win_hint", para)
end


function CSMessage.NotifyTrustToAll(stPlayerTrust, nStatus)
    local para = {
        setStatus = nStatus
    }
    CSMessage.NotifyAllPlayer(stPlayerTrust, "autoplay", para)
end


function CSMessage.SendSyncBeginNotify(stPlayer)
    CSMessage.NotifyOnePlayer(stPlayer, "sync_begin")
end
function CSMessage.SendSyncEndNotify(stPlayer)
    CSMessage.NotifyOnePlayer(stPlayer, "sync_end")
end

function CSMessage.NotifyPlayerPointsRefresh(stPlayer)
    local para = {
        stPlayer:GetPlayerPointsSt()
    }
    CSMessage.NotifyAllPlayer(stPlayer, "points_refresh", para)
end

function CSMessage.NotifyResultBeforeToAll(stHands)
    local para = {
        handTile = stHands
    }
    CSMessage.NotifyAllPlayer(nil, "show_all_hands", para)
end

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
function CSMessage.NotifyPlayerAddMoneyToContinue(stPlayer)
    local para = {
        reason = CONTINUE_PLAY_REASON_MONEY
    }
    CSMessage.NotifyAllPlayer(stPlayer, "ask_continue_play", para)
end
function CSMessage.NotifyAllPlayerGiveupPlay(stPlayerGiveup)
    local para = {
        giveup = true
    }
    CSMessage.NotifyAllPlayer(stPlayerGiveup, "continue_play", para)
end

function CSMessage.ResponsePlayerInfo(stPlayer, _chair , stPlayerRsp)
    local para = {
        stPlayerRsp
    }
    CSMessage.NotifyOnePlayerTo(stPlayer, "player_info", para, _chair)
end




function CSMessage.NotifyAllPlayerGameEnd()
    CSMessage.NotifyAllPlayer(nil, "gameend")
end

function CSMessage.NotifyReEnterMessageToOther(stPlayer, nLeftTime)
    local para = {
        nLeftTime = nLeftTime
    }
    CSMessage.NotifyExceptPlayer(stPlayer, "reenter", para)
end
function CSMessage.NotifyAskChangeCard(stPlayer, nChangeNum, bSameCardType, stBest,ntimeout)
    local stPlayerCardGroup = stPlayer:GetPlayerCardGroup()
    local para = {
            nNum = nChangeNum,
            bSameCardType = bSameCardType,
            recommend =stBest  
    }
        --房卡房间并且有限制时不设置超时
    if GGameCfg.nMoneyMode ~= ROOM_MODE_SCORE or GGameCfg.TimerSetting.TimeOutLimit ~= -1 then
        FlowFramework.SetTimer(stPlayer:GetChairID(), ntimeout)
    else
        --房卡房间也设置超时timeid设为-1，在Time_mng做判断，不发超时事件
         FlowFramework.SetTimer(stPlayer:GetChairID(), ntimeout,-1)
    end
    LOG_DEBUG("GGameCfg.TimerSetting.changeCardTimeOut :%d", ntimeout)
    CSMessage.NotifyOnePlayer(stPlayer, "changecard", para, ntimeout)
end
 --通知换张结果
function CSMessage.NotifyChangeCard(stPlayer, nType, stOldCards, stNewCards)
    local para = {
            stNewCards = stNewCards,
            stOldCards = stOldCards, 
            nType = nType
    }
    CSMessage.NotifyOnePlayerTo(stPlayer, "changecard_result", para)
end

function CSMessage.NotifyAskConfirmMiss(stPlayer, stOptional, nRecommend,ntimeout)
    local para = {
            optional = stOptional,
            recommend = nRecommend
    }
    --房卡房间并且有限制时不设置超时
    if GGameCfg.nMoneyMode ~= ROOM_MODE_SCORE or GGameCfg.TimerSetting.TimeOutLimit ~= -1 then
        FlowFramework.SetTimer(stPlayer:GetChairID(), ntimeout)
    else
        --房卡房间也设置超时timeid设为-1，在Time_mng做判断，不发超时事件
         FlowFramework.SetTimer(stPlayer:GetChairID(), ntimeout,-1)
    end
    CSMessage.NotifyOnePlayer(stPlayer, "confirmmiss", para, ntimeout)
end
function CSMessage.NotifyConfimMissResult(stResult)
    local para = {}
    for i=1,PLAYER_NUMBER do
        para["p" ..i] = stResult[i]
    end

    CSMessage.NotifyAllPlayer(nil, "confirmmiss_result", para)
end

function CSMessage.NotifyOneConfimMiss(stPlayer,stResult)
    local nChair = stPlayer:GetChairID()
    local para = {}
	para["p"..nChair] =  stResult 

    CSMessage.NotifyOnePlayerTo(stPlayer, "confirmmiss_reenter", para)
end

--重入时通知玩家手牌信息
function CSMessage.NotifyOneCardGroup(stPlayer)
    local stPlayerCardGroup = stPlayer:GetPlayerCardGroup()
    local nChair = stPlayer:GetChairID()
    local para = {}
    para["p"..nChair] =  stPlayerCardGroup 

    CSMessage.NotifyOnePlayerTo(stPlayer, "cardgroup_reenter", para)
end

--重入时通知等待别人换张
function CSMessage.NotifyOneWaitChangeCard(stPlayer)
    local nChair = stPlayer:GetChairID()
    local para = {
        nleftTime = FlowFramework.GetTimerLeftSecond(nChair,-1)
    }

    CSMessage.NotifyOnePlayerTo(stPlayer, "changcardwait_reenter", para)
end

--重入时通知玩家胡牌列表
function CSMessage.NotifyOneWin(stPlayer,stWinList)
    CSMessage.NotifyOnePlayerTo(stPlayer, "win_reenter", stWinList)
end

-- 听牌显示：胡的牌-番数
function CSMessage.NotifyTingInfoToSelf(stPlayer, nFlag, stCardTing)
    local para = {
        nFlag = nFlag,
        stCardTing =stCardTing,
    }
    CSMessage.NotifyOnePlayer(stPlayer, "gettinginfo", para)
end

-- 抢杠成功后 通知客户端将杠变为peng
function CSMessage.NotifyAllPlayerQuadruplet2Triplet(stPlayer, nTurn, nCard, nPengGangPlayer)
    local para = {
        tripletWho = nTurn,
        nPengGangPlayer = nPengGangPlayer,
        cardTriplet = { triplet = nCard, useCards = {nCard, nCard} },
    }
    CSMessage.NotifyAllPlayer(nil, "quadruplet2triplet", para)
end

return CSMessage
