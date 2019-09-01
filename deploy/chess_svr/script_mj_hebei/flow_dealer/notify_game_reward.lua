-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local SetGameReward = _GameModule._TableLogic.SetGameReward or function(...) end

local function logic_notify_game_reward(dealer, msg)
    local stGameState = GGameState
    local stScoreRecord = LibGameLogic:GetScoreRecord()
    LOG_DEBUG("Run LogicStep notify_game_reward")
    local stRoundInfo = GRoundInfo
	local who_win = {}                                     --谁赢
    local win_type = "huangpai"
    local rewards = {}
    -- local total_rewards = {}
    for i=1,PLAYER_NUMBER do
        local stPlayer = stGameState:GetPlayerByChair(i)
        rewards[i] = stScoreRecord:GetRecordByChair(i)
        if stPlayer:IsWin(i) then
            table.insert (who_win, i)
            win_type = rewards[i].win_type -- 只取赢的最后一人
        end
    end
    local laizicards ={}
    laizicards = LibLaiZi:GetLaiZi()
    local nLianCount = 0
    if GGameCfg.RoomSetting.nGameStyle ~= GAME_STYLE_SHIJIAZHUANG then
        nLianCount = stRoundInfo:GetLianZhuangCount()
    end
    local report_reward = {
        uri       = GGameCfg.uri,
        rid       = GGameCfg.rid,
        ju_num    = GGameCfg.nJuNum,
        curr_ju   = GGameCfg.nCurrJu,
        who_win   = who_win,
        who_onturn= stRoundInfo:GetWhoIsOnTurn(),
        win_type  = win_type,
        banker    = stRoundInfo:GetBanker(),
        dice      = stRoundInfo:GetDice(),
        roundWind = stRoundInfo:GetRoundWind(),
        subRound  = stRoundInfo:GetSubRoundWind(),
        tileLeft  = GDealer:GetDealerCardGroup():GetCurrentLength(),
        rewards   = rewards,
        nLianCount = nLianCount,
        laizicards = laizicards,
        ts        = os.time()
    }
    -- 金币场会nil
    -- LOG_DEBUG("RRRRID = %d=%d, nCurrJu=%d\n", report_reward.rid, GGameCfg.rid, GGameCfg.nCurrJu);

    for i=1,PLAYER_NUMBER do
        local stPlayer = stGameState:GetPlayerByChair(i)
        CSMessage.SendRoundResultToPlayer(stPlayer, report_reward)
    end

    LOG_DEBUG("WHEN REWARD 1, stage=%s", dealer:GetCurrStage())
    dealer:ToNextStage()
    LOG_DEBUG("WHEN REWARD, stage=%s, tbl=%s", dealer:GetCurrStage(), vardump(G_TABLEINFO))
    
    SetGameReward(G_TABLEINFO.tableptr, report_reward);

    return STEP_SUCCEED
end


return logic_notify_game_reward
