-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_do_player_gangci_func_timeout(stPlayer, event)
    LOG_DEBUG("Run LogicStep do_player_gangci_func_timeout")
    FlowFramework.DelTimer(stPlayer:GetChairID(), 0)

    local stPlayerBlockState = LibGameLogic:GetPlayerBlockState(stPlayer:GetChairID())
    local stPlayerCards = stPlayer:GetPlayerCardGroup():ToArray()
    
    if stPlayerBlockState:IsCanWin() then
        local nWinCard = stPlayerBlockState:GetCurrWinCard()
        LOG_DEBUG("logic_do_player_gangci_func_timeout  nWinCard = %d", nWinCard)
        stPlayerBlockState:SetBlockFlag(ACTION_WIN, nWinCard)
        return STEP_SUCCEED
    end
    -- 不做任何操作 通知dealer补牌
    stPlayerBlockState:Clear()
    GRoundInfo:SetGangciHu()
    GRoundInfo:SetNeedDraw(true)
    stPlayerCardGroup:SetLastDraw(0)

    return STEP_SUCCEED
end


return logic_do_player_gangci_func_timeout
