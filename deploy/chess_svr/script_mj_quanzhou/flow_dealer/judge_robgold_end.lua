-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_judge_robgold_end(dealer, msg)
    LOG_DEBUG("Run LogicStep judge_robgold_end")

    -- 如果是还没出牌的话，不走这里
    if GRoundInfo:IsSkipRob() then
        return STEP_SUCCEED
    end
    LOG_DEBUG("logic_judge_robgold_end...IsDealerFirstTurn: %s, IsPlayFirstCard:%s", tostring(GRoundInfo:IsDealerFirstTurn()), tostring(GRoundInfo:IsPlayFirstCard()))
    if GRoundInfo:IsDealerFirstTurn() and GRoundInfo:IsPlayFirstCard() then
        local IsAllGiveUp = true    -- 是否所有玩放弃抢杠，或者不存在抢杠
        for i=1, PLAYER_NUMBER do
            local stPlayer = GGameState:GetPlayerByChair(i)
            if not stPlayer:IsRobEnd() then
                LOG_DEBUG("logic_judge_curr_round...player rob gold not end, chairid: %d", i)
                IsAllGiveUp = false
                return STEP_FAILED
            end
        end
        LOG_DEBUG("logic_judge_robgold_end....IsAllGiveUp:%s", tostring(IsAllGiveUp))
        if IsAllGiveUp then
            GRoundInfo:SetDealerFirstTurn(false)
            local nChair = GRoundInfo:GetWhoIsOnTurn()
            local stPlayer = GGameState:GetPlayerByChair(nChair)
            local nCard = GRoundInfo:GetLastGive()
            LOG_DEBUG("logic_judge_robgold_end....nChair:%d, nCard:%d", nChair, nCard)
            SSMessage.CallOtherPlayerGive(stPlayer, nCard)
            GRoundInfo:SetSkipRob(true)
        end
        return STEP_FAILED
    end

    return STEP_SUCCEED
end

return logic_judge_robgold_end