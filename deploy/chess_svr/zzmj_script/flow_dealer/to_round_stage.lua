-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_to_round_stage(dealer, msg)
    LOG_DEBUG("Run LogicStep to_round_stage")
    dealer:SetCurrStage("round")
    return STEP_SUCCEED
end


return logic_to_round_stage
