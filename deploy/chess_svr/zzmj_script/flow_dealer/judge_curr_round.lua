-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_judge_curr_round(dealer, msg)
    LOG_DEBUG("Run LogicStep judge_curr_round")
    --local stRoundInfo = GRoundInfo
     --if GGameState:IsPlayStart() == true then
     --    local nChair = stRoundInfo:GetWhoIsOnTurn()
      --   stRoundInfo:SetNeedDraw(true)
      --   stRoundInfo:SetWhoIsOnTurn(LibTurnOrder:GetNextTurn(nChair))
      -- end
    return STEP_SUCCEED
    
end


return logic_judge_curr_round
