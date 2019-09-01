-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_notify_player_op_logic_func(stPlayer, msg)
    LOG_DEBUG("Run LogicStep notify_player_op_logic_func")
    local nChair = stPlayer:GetChairID()
    local stPlayerBlockState = LibGameLogic:GetPlayerBlockState(nChair)
    -- no timeout
    CSMessage.NotifyPlayerAskBlock(stPlayer, stPlayerBlockState:GetReuslt(), false)

    local bIsQuick = stPlayer:IsTrust() or stPlayer:IsWin()
   	CSMessage.NotifyAskPlay(stPlayer, bIsQuick)
    return STEP_SUCCEED
end



return logic_notify_player_op_logic_func
