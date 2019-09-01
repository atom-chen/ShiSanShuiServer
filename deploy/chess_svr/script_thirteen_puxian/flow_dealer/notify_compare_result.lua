-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_notify_compare_result(dealer, msg)
    LOG_DEBUG("Run LogicStep notify_compare_result")
    LibGame:NotifyCompareResult()
    
    return STEP_SUCCEED
end


return logic_notify_compare_result