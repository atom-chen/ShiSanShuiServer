-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_check_is_compare_wait(dealer, msg)
    -- LOG_DEBUG("Run LogicStep check_is_compare_wait")
    if GRoundInfo:IsCompareWait() then
        LOG_DEBUG("Run LogicStep check_is_compare_wait....yes")
        return "yes"
    end
    return "no"
end


return logic_check_is_compare_wait