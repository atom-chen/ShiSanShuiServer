-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_notify_do_logic_func(stPlayer, msg)
    LOG_DEBUG("Run LogicStep notify_do_logic_func")
    return STEP_SUCCEED
end


return logic_notify_do_logic_func
