-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_do_player_robgold_timeout(stPlayer, msg)
    LOG_DEBUG("Run LogicStep do_player_robgold_timeout")
    --玩家超时没反应时，清除该玩家block状态
    local nChair = stPlayer:GetChairID()
    local stPlayerBlockState = LibGameLogic:GetPlayerBlockState(nChair)
    stPlayerBlockState:Clear()
    stPlayer:SetRobEnd(true)

    FlowFramework.DelTimer(stPlayer:GetChairID(), 0)
    return STEP_SUCCEED
end


return logic_do_player_robgold_timeout