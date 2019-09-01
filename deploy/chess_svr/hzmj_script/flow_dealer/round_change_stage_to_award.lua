-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_round_change_stage_to_award(dealer, msg)
    LOG_DEBUG("Run LogicStep round_change_stage_to_award")
    dealer:ToNextStage()
    return STEP_SUCCEED
end


return logic_round_change_stage_to_award
