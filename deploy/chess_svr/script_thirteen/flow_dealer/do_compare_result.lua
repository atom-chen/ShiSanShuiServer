-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
require "common.socket"
local function logic_do_compare_result(dealer, msg)
    -- LOG_DEBUG("Run LogicStep do_compare_result")
    local t1 = math.floor(socket.gettime()*1000)
    LibGame:CompareResult()
    local t2 = math.floor(socket.gettime()*1000)
    LOG_DEBUG("==================compare time: %d===============", (t2-t1))
    --计算比牌时间
    dealer:CalculateCompareWaitTime()
     
    return STEP_SUCCEED
end

return logic_do_compare_result