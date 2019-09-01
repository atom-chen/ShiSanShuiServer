-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local SetGameReward = _GameModule._TableLogic.SetGameReward or function(...) end

local function logic_notify_game_reward(dealer, msg)
    local stGameState = GGameState
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
        local stPlayer = stGameState:GetPlayerByChair(i)
        rewards[i] = stScoreRecord:GetPlayerRecordDetail(i)
        rewards[i].all_score = stScoreRecord:GetPlayerScore(i) -- 当局总分
        if stPlayer:IsWin(i) then
            table.insert (who_win, i)
        end
        rewards[i].sum_score = stScoreRecord:GetPlayerSumScore(i)  -- 累计总分
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
    LOG_DEBUG("REWARDS STATE buyCodeType = %d @@@ buyCodeInfo = %s", GGameCfg.GameSetting.nBuyCodeType, vardump(LibBuyCode:GetBuyCodeInfo()))

    for i=1,PLAYER_NUMBER do
        local stPlayer = stGameState:GetPlayerByChair(i)
        if not stPlayer then
            return STEP_FAILED
        end
        CSMessage.SendRoundResultToPlayer(stPlayer, report_reward)
    end

    LOG_DEBUG("WHEN REWARD, stage=%s, tbl=%s", dealer:GetCurrStage(), vardump(G_TABLEINFO))
    
    SetGameReward(G_TABLEINFO.tableptr, report_reward);
        
    dealer:ToNextStage()
    return STEP_SUCCEED
end


return logic_notify_game_reward
