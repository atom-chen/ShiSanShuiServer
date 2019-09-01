-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_judge_curr_round(dealer, msg)
    LOG_DEBUG("Run LogicStep judge_curr_round")

    -- if GRoundInfo:IsDealerFirstTurn() then
    --     --1.判断是否抢金结束
    --     for i=1, PLAYER_NUMBER do
    --         local stPlayer = GGameState:GetPlayerByChair(i)
    --         if not stPlayer:IsRobEnd() then
    --             LOG_DEBUG("logic_judge_curr_round...player rob gold not end, chairid: %d", i)
    --             return STEP_FAILED
    --         end
    --     end

    --     GRoundInfo:SetDealerFirstTurn(false)
    --     --2.结束 通知其他玩家操作：吃 碰 杠 胡
    --     local nChair = GRoundInfo:GetWhoIsOnTurn()
    --     local stPlayer = GGameState:GetPlayerByChair(nChair)
    --     local nCard = GRoundInfo:GetLastGive()

    --     LOG_DEBUG("logic_judge_curr_round...player continue to SSMessage.CallOtherPlayerGive()...whoPlay: %d, nLastGiveCard: %d", nChair, nCard)
    --     SSMessage.CallOtherPlayerGive(stPlayer, nCard)

    --     return STEP_FAILED
    -- end

    return STEP_SUCCEED 
end


return logic_judge_curr_round
