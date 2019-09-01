-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_init_fan_counter(dealer, msg)
    LOG_DEBUG("Run LogicStep init_fan_counter")
     LibFanCounter:InitFanCounter()

    return STEP_SUCCEED
end


return logic_init_fan_counter
