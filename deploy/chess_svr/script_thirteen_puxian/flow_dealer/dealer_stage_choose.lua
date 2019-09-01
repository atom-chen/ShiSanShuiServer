-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_dealer_stage_choose(dealer, msg)
    -- LOG_DEBUG("Run LogicStep dealer_stage_choose:%s\n",  dealer:GetCurrStage())
    return dealer:GetCurrStage()
end


return logic_dealer_stage_choose
