-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_notify_player_op_logic_func_other(stPlayer, msg)
    LOG_DEBUG("Run LogicStep notify_player_op_logic_func_other")

    local stPlayerBlockState = LibGameLogic:GetPlayerBlockState(stPlayer:GetChairID())

    local bIsQuick = stPlayer:IsTrust() or  stPlayer:IsWin()
    local stBlockResut = stPlayerBlockState:GetReuslt()
    LOG_DEBUG("notify_player_op_logic_func_other..uid:%d, stBlockResut:%s \n", stPlayer:GetUin(), vardump(stBlockResut))
    CSMessage.NotifyPlayerAskBlock(stPlayer, stBlockResut, true, bIsQuick)

    -- if  stPlayer:IsWin() == false and stPlayerBlockState:IsCanTing() then
    --     --
    --     -- CSMessage.NotifyWinHint(stPlayer, stPlayerBlockState:GetTingGroupAll())
    -- end
    return STEP_SUCCEED
end


return logic_notify_player_op_logic_func_other
