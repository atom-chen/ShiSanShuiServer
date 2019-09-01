-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_do_player_self_giveup(stPlayer, msg)
    LOG_DEBUG("Run LogicStep do_player_self_giveup")
    local nChair = stPlayer:GetChairID()
    local stPlayerBlockState = LibGameLogic:GetPlayerBlockState(nChair)
    stPlayerBlockState:Clear()
    FlowFramework.DelTimer(nChair, 0)
    stPlayer:SetIsUserSelfGiveup(true)
    if GRoundInfo:IsDealerFirstTurn()  then
        GRoundInfo:SetDealerFirstTurn(false)
    end
    SSMessage.CallPlayerAskPlay(stPlayer)
    return STEP_SUCCEED
end


return logic_do_player_self_giveup
