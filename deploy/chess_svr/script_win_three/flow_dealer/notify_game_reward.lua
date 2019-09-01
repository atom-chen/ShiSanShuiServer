-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local SetGameReward = _GameModule._TableLogic.SetGameReward or function(...) end

local function logic_notify_game_reward(dealer, msg)
    LOG_DEBUG("Run LogicStep notify_game_reward")

    local stGameState = GGameState
    local stScoreRecord = LibGame:GetScoreRecord()
    local stRoundInfo = GRoundInfo
    local rewards = {}
    for i=1,PLAYER_NUMBER do
        rewards[i] = stScoreRecord:GetRecordByChair(i)
    end

    local report_reward = {
        uri       = GGameCfg.uri,
        rid       = GGameCfg.rid,
        ju_num    = GGameCfg.nJuNum,
        curr_ju   = GGameCfg.nCurrJu,
        banker    = dealer:GetBanker(),
        rewards   = rewards,
        ts        = os.time()
    }
    LOG_DEBUG("RRRRID = %d=%d, nCurrJu=%d\n report_reward: %s \n", report_reward.rid, GGameCfg.rid, GGameCfg.nCurrJu, vardump(report_reward))
    
    --结束时通知积分变化
--    CSMessage.NotifyBanlanceChangeListToAll()
    for i=1,PLAYER_NUMBER do
        local stPlayer = stGameState:GetPlayerByChair(i)
        if stPlayer then
            CSMessage.SendRoundResultToPlayer(stPlayer, report_reward)
        end
    end
    LOG_DEBUG("WHEN REWARD before, stage=%s", dealer:GetCurrStage())
    -- 进入下一阶段
    dealer:ToNextStage()
    LOG_DEBUG("WHEN REWARD next, stage=%s, tbl=%s", dealer:GetCurrStage(), vardump(G_TABLEINFO))
    
    -- 交给C++
    SetGameReward(G_TABLEINFO.tableptr, report_reward)

    return STEP_SUCCEED
end


return logic_notify_game_reward
