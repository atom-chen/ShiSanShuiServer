-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_judge_threegold_block(player, msg)
    LOG_DEBUG("Run LogicStep judge_threegold_block")


	local nChair = player:GetChairID()
    stBlockState = LibGameLogic:GetPlayerBlockState(nChair)
    if stBlockState:GetBlockRecordFlag() == ACTION_WIN then
        LOG_DEBUG("--==judge_threegold_block-ACTION_WIN, WhoIsOnTurn:%d, whoWin:%d !!!!!!!!!!!!!\n", GRoundInfo:GetWhoIsOnTurn(), nChair)
        LibGameLogic:ProcessOPWin(player, stBlockState:GetBlockaRecordCard())
    end
    return STEP_SUCCEED
end


return logic_judge_threegold_block