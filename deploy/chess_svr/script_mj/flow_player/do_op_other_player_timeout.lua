-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_do_op_other_player_timeout(stPlayer, event)
    LOG_DEBUG("Run LogicStep do_op_other_player_timeout")
    --超时次数
    stPlayer:AddTimeoutTimes()

    --玩家超时没反应时，清除该玩家block状态
    local nChair = stPlayer:GetChairID()
    local stPlayerBlockState = LibGameLogic:GetPlayerBlockState(nChair)
    stPlayerBlockState:Clear()
    FlowFramework.DelTimer(nChair, 0)
    return STEP_SUCCEED
end


return logic_do_op_other_player_timeout
