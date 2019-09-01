-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_notify_player_robgold_op_logic_func(stPlayer, msg)
    LOG_DEBUG("Run LogicStep notify_player_robgold_op_logic_func")

    local stPlayerBlockState = LibGameLogic:GetPlayerBlockState(stPlayer:GetChairID())
    local bIsQuick = stPlayer:IsTrust() or stPlayer:IsWin()
    local stResult =  stPlayerBlockState:GetReuslt()
    stResult.nWinFalg = 1
    LOG_DEBUG("notify_player_robgold_op_logic_func...p%d, stResult:%s", stPlayer:GetChairID(), vardump(stResult))
    CSMessage.NotifyPlayerAskBlock(stPlayer, stResult, false, bIsQuick)
    
    return STEP_SUCCEED
end


return logic_notify_player_robgold_op_logic_func