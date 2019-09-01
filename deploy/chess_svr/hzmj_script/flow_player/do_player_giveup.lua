-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_do_player_giveup(stPlayer, msg)
    LOG_DEBUG("Run LogicStep do_player_giveup")
    local nChair = stPlayer:GetChairID()
    local stPlayerBlockState = LibGameLogic:GetPlayerBlockState(nChair)

    if stPlayerBlockState:GetWin() == ACTION_WIN then
        local nFanCount = stPlayerBlockState:GetHuFanInfo(stPlayerBlockState:GetCurrWinCard())  -- 赢的番数
        if nFanCount then stPlayerBlockState:SetGuoShouHu(nFanCount) end
        LOG_DEBUG("GuoShouHu ACTION_WIN Set Success nWinCard = %d ", stPlayerBlockState:GetCurrWinCard())
    end
   
    stPlayerBlockState:Clear()
    
     if stPlayer:GetPlayerIsQiangGangHu() ==true then
        stPlayer:SetPlayerQiangGangStatus(QIANGGANG_STATUS_GIVEUP)
     end
     
    FlowFramework.DelTimer(stPlayer:GetChairID(), 0)
    return STEP_SUCCEED
end


return logic_do_player_giveup
