-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_do_player_gangci_giveup(stPlayer, msg)
    LOG_DEBUG("Run LogicStep do_player_gangci_giveup")

    --1.清除所有block
    local nChair = stPlayer:GetChairID()
    local stPlayerBlockState = LibGameLogic:GetPlayerBlockState(nChair)
    stPlayerBlockState:Clear()
    FlowFramework.DelTimer(stPlayer:GetChairID(), 0)

    --杠次标志
    GRoundInfo:SetGangciHu()

    --2.通知dealer补牌
    GRoundInfo:SetNeedDraw(true)
    stPlayer:GetPlayerCardGroup():SetLastDraw(0)

    return STEP_SUCCEED
end


return logic_do_player_gangci_giveup