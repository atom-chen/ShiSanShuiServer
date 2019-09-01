-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_player_re_enter(stPlayer, msg)
    LOG_DEBUG("Run LogicStep player_re_enter")
    if GDealer:IsGameEnd() == true then
        LOG_DEBUG("WHEN re_enter, isGameEnd.\n");
        SSMessage.CallPlayerReady(stPlayer)
        return STEP_SUCCEED
    end
    stPlayer:RefreshScore()
    stPlayer:SetIsTrust(false)
    --设置该玩家状态为在线
    stPlayer:SetPlayOfflineStatus(0)

    local nChair = stPlayer:GetChairID()
    local stDealerCardGroup = GDealer:GetDealerCardGroup()
    local stGameState = GGameState
    local stWinListRe = {}

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

            --玩家重连进来后发送其他玩家的断线情况给重连玩家,只发离线的吧
            CSMessage.NotifyPlayerOfflineTo(stPlayer,stPlayerAll)
        end
        table.insert(syncTbl.player_state, player_state)
        table.insert(syncTbl.player_uin, player_uin)
    end
    --获取当前剩余时间

    local nleftTime
    local stRoundInfo = GRoundInfo
    --
    for i=1,1 do
        -- if game_state == "nostart" then
        --     break;
        -- end
        
        --当前玩家的状态如果是坐下，通知其准备
        if stPlayer:GetPlayerStatus() == PLAYER_STATUS_SIT then
            CSMessage.NotifyPlayerReAskReady(stPlayer,FlowFramework.GetTimerLeftSecond(stPlayer:GetChairID()))
        end
        if game_state == "prepare" then
            break;
        end
		
        if game_state == "deal" then
            break;
        end
        -- 有发牌了
		
        --todo 换张 定缺

        --通知玩家手牌信息
        --CSMessage.NotifyOneCardGroup(stPlayer)
	
		if  GGameCfg.GameSetting.bSupportChangeCard then
				
			if game_state == "changecard" then 
			
				local nChair = stPlayer:GetChairID()
			
				if LibChangeCard:IsPlayerSubmitChangeCard(nChair) == false then  --还未提交换张
				
					nleftTime = FlowFramework.GetTimerLeftSecond(nChair,-1)
					local nChangeNum =  LibChangeCard:GetChangeCardNum()
					local bSameCardType = LibChangeCard:GetChangeCardType() 
					local stPlayerCardGroup = stPlayer:GetPlayerCardGroup()
					local stBest = LibChangeCard:SelectCardChange(stPlayerCardGroup:ToArray())
					CSMessage.NotifyAskChangeCard(stPlayer,nChangeNum,bSameCardType,stBest,nleftTime)
					break;
				else
					--玩家此时为等待其他人换张状态，通知即可
					nleftTime = FlowFramework.GetTimerLeftSecond(nChair,-1)
					CSMessage.NotifyOneWaitChangeCard(stPlayer,nleftTime)
				end
			end 				
		end	
        
        if game_state == "confirmmiss" then			
			local nChair = stPlayer:GetChairID()
            nleftTime = FlowFramework.GetTimerLeftSecond(nChair,-1) 
			local stOptional = LibConfirmMiss:GetMissOptional()
            local stPlayerCardGroup = stPlayer:GetPlayerCardGroup()
			local nRecommend = LibConfirmMiss:GetBestMiss(stPlayerCardGroup:ToArray())
            local nPlayerConfirmMiss = LibConfirmMiss:GetPlayerMissCard(stPlayer:GetChairID())
			
			if nPlayerConfirmMiss ~= 0 then
                CSMessage.NotifyOneConfimMiss(stPlayer,nPlayerConfirmMiss)
				break;
			else 
				CSMessage.NotifyAskConfirmMiss(stPlayer, stOptional,nRecommend,nleftTime)
				break;
			end	
        end

        if game_state == "round" then
            --增加是否已经胡牌判断，如果已经胡牌则通知客户端显示胡
            local nChair = stPlayer:GetChairID()

            for i=1,PLAYER_NUMBER do
                local  stPlayerWin = stGameState:GetPlayerByChair(i)
                if stPlayerWin:IsWin() == true then
                    local winList_all = stRoundInfo:GetWinList()
                    table.insert(stWinListRe, {i, stPlayerWin:GetWinType(), table.keyof(winList_all, i)})		
                    CSMessage.NotifyOneWin(stPlayer, stWinListRe)
                end
            end
            
            if stPlayer ~= nil then
                --通知定缺结果
                local stPlayerMiss = {}
                for i=1,PLAYER_NUMBER do
                    local nPlayerMiss = LibConfirmMiss:GetPlayerMissCard(i)
                    stPlayerMiss["p" ..i] = nPlayerMiss
                end

                CSMessage.NotifyOnePlayerTo(stPlayer, "confirmmiss_result", stPlayerMiss)
                
                if stPlayer:IsWin() == true then
                    break
                else
                    --CSMessage.NotifyConfimMissResult(stPlayerMiss)
                    -- 当前人，当前动作,shengyushijian

                    --是否轮到自己                    
                    local nTurn = stRoundInfo:GetWhoIsOnTurn()

                    --当前玩家状态：要出牌、杠胡碰牌
                    if  nTurn ==nChair then
                        nleftTime = FlowFramework.GetTimerLeftSecond(nChair,-1)
                        ----轮到自己出牌 但是已经打出去一张牌，别人能碰杠胡，取别人的时间做显示
                        for i=1,PLAYER_NUMBER do
                            --TODO：应该排除自己
                            if i ~= nChair then
                                if (LibGameLogic:GetPlayerBlockState(i):IsBlocked()) then
                                    nleftTime = FlowFramework.GetTimerLeftSecond(i)
                                    LOG_DEBUG("Run MY TURN ======%d\n",nleftTime) 
                                end
                            end
                        end
                        LOG_DEBUG("Run MY TURN 111======%d\n",nleftTime) 
                        local bIsQuick = stPlayer:IsTrust() or  stPlayer:IsWin();
                        local stPlayerBlockState = LibGameLogic:GetPlayerBlockState(stPlayer:GetChairID())
                        -- no timeout
                        CSMessage.NotifyPlayerReAskBlock(stPlayer, stPlayerBlockState:GetReuslt(), false, bIsQuick, nleftTime)
                        local bIsQuick = stPlayer:IsTrust() or stPlayer:IsWin()
                        CSMessage.NotifyAskRePlay(stPlayer, bIsQuick,nleftTime)
                    --别人出牌，断线玩家等待、block状态
                    else
                        local bIsQuick = stPlayer:IsTrust() or  stPlayer:IsWin();
                        local stPlayerBlockState = LibGameLogic:GetPlayerBlockState(stPlayer:GetChairID())
                        if stPlayerBlockState:IsBlocked() then
                            nleftTime = FlowFramework.GetTimerLeftSecond(nChair)
                            -- if nleftTime >0 then
                            CSMessage.NotifyPlayerReAskBlock(stPlayer, stPlayerBlockState:GetReuslt(), false, bIsQuick,nleftTime) 
                            -- end
                        else
                            nleftTime = FlowFramework.GetTimerLeftSecond(nTurn,-1)
                        end
                        LOG_DEBUG("Run GetTimerLeftSecond ===%d\n",nleftTime)               
                    end  
                    break
                end
            end
        end
        
        -- 正在玩
        if game_state == "reward" then
            --通知定缺结果
            local stPlayerMiss = {}
            for i=1,PLAYER_NUMBER do
                local nPlayerMiss = LibConfirmMiss:GetPlayerMissCard(i)
                stPlayerMiss["p" ..i] = nPlayerMiss
            end
            CSMessage.NotifyOnePlayerTo(stPlayer, "confirmmiss_result", stPlayerMiss)

            ---通知结算结果
            local stScoreRecord = LibGameLogic:GetScoreRecord()
            LOG_DEBUG("Run LogicStep notify_game_reward")
            local stRoundInfo = GRoundInfo
            local who_win = {}                                     --谁赢
            local rewards = {}

            if GGameCfg.GameSetting.nBuyCodeType ~= BUY_CODE_ALL_NONE then
                LibBuyCode:CalBuyCodeScore()  -- 计算买马得分
            end

            for i=1,PLAYER_NUMBER do
                if GGameCfg.GameSetting.nBuyCodeType ~= BUY_CODE_ALL_NONE then
                    stScoreRecord:AddBuyCodeRecord(i) -- 添加买马记录和分数
                end
                local stPlayer = GGameState:GetPlayerByChair(i)
                rewards[i] = stScoreRecord:GetPlayerRecordDetail(i)
                rewards[i].all_score = stScoreRecord:GetPlayerScore(i)  -- 当前局分数
                if stPlayer:IsWin(i) then
                    table.insert(who_win, i)
                end
                rewards[i].sum_score = stScoreRecord:GetPlayerSumScore(i)  -- 累计所有局总分
                stScoreRecord:SetPlayerGangScore(i, stScoreRecord:GetPlayerSumScore(i))
            end

            LOG_DEBUG("========================rewards%s", vardump(rewards))
            local report_reward = {
                uri       = GGameCfg.uri,
                rid       = GGameCfg.rid,
                ju_num    = GGameCfg.nJuNum,
                curr_ju   = GGameCfg.nCurrJu,
                who_win   = who_win,
                who_onturn= stRoundInfo:GetWhoIsOnTurn(),
                banker    = stRoundInfo:GetBanker(),
                dice      = stRoundInfo:GetDice(),
                roundWind = stRoundInfo:GetRoundWind(),
                subRound  = stRoundInfo:GetSubRoundWind(),
                tileLeft  = GDealer:GetDealerCardGroup():GetCurrentLength(),
                buyCode   = LibBuyCode:GetBuyCodeInfo(),
                rewards   = rewards,
                ts        = os.time()
            }
            LOG_DEBUG("RRRRID = %d=%d, nCurrJu=%d\n", report_reward.rid, GGameCfg.rid, GGameCfg.nCurrJu);

            CSMessage.SendRoundResultToPlayer(stPlayer, report_reward)
            
            if stPlayer:GetPlayerStatus() == PLAYER_STATUS_SIT then
                CSMessage.NotifyPlayerReAskReady(stPlayer,FlowFramework.GetTimerLeftSecond(stPlayer:GetChairID()))
            end

            break;
        end
    
    --[[
        -- 正在结算
        if game_state == "gameend" then
            break;
        end
    --]]      
    end
    stRoundInfo:SetReenterTime(nleftTime)

    --通知玩家所有人的当前分数
    local stScoreRecord = LibGameLogic:GetScoreRecord()
    local xxscore ={}
    local gangscore = {}
    for i=1,PLAYER_NUMBER do
        xxscore[i] = stScoreRecord:GetPlayerSumScore(i)
        gangscore[i] = stScoreRecord:GetPlayerGangScore(i)
    end
    syncTbl.score = xxscore
    syncTbl.gangscore = gangscore

    -- 同步所有台面
    local stSyncAll = LibGameLogic:CollectAllTableCardInfo(nChair)
    table.merge(syncTbl, stSyncAll)

    if stPlayer:IsWin() == true then

        if stPlayer:GetWinType() == 1 then

            local st_list = syncTbl.tileList

            local n_stcard = stPlayer:GetPlayerWinCards()[1]

            syncTbl.tileList[#st_list + 1] = n_stcard
        end

    end
 
    CSMessage.NotifySyncAllCards(stPlayer, syncTbl)
    if game_state == "buycode" or game_state == "round" then
        CSMessage.NotifyPlayerBuyCode(stPlayer, false)
    end
    
    CSMessage.SendSyncEndNotify(stPlayer)
  
    return STEP_SUCCEED
end


return logic_player_re_enter
