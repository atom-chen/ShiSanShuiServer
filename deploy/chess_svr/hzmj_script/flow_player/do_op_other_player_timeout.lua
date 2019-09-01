-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_do_op_other_player_timeout(stPlayer, event)
    LOG_DEBUG("Run LogicStep do_op_other_player_timeout")
    stPlayer:AddTimeoutTimes()
    --超时过

    --[[if stPlayer:IsWin() then
        local stPlayerBlockState = LibGameLogic:GetPlayerBlockState(stPlayer:GetChairID())
        local stPlayerCards = stPlayer:GetPlayerCardGroup():ToArray()
        -- 可赢则赢
        if stPlayerBlockState:IsCanWin() then
            local nWinCard = stPlayerBlockState:GetCurrWinCard()
            LOG_DEBUG("do ACTION_WIN")
             stPlayerBlockState:SetBlockFlag(ACTION_WIN, nWinCard)

             if stPlayer:GetPlayerCanGang() ==true then
                stPlayer:SetPlayerGangStatus(QIANGGANG_STATUS_OK)
             end
             return STEP_SUCCEED
        end
        -- 有杠则杠
        if stPlayerBlockState:IsCanQuadruplet() then
            local stCards = stPlayerBlockState:GetQuadrupletCard()
            LOG_DEBUG("do ACTION_QUADRUPLET")
            stPlayerBlockState:SetBlockFlag(ACTION_QUADRUPLET, stCards[1])
            return STEP_SUCCEED
        end
    --end--]]
  
    local nChair = stPlayer:GetChairID()
    local stPlayerBlockState = LibGameLogic:GetPlayerBlockState(nChair)
    stPlayerBlockState:Clear()

    if stPlayer:GetPlayerIsQiangGangHu() ==true then
        stPlayer:SetPlayerQiangGangStatus(QIANGGANG_STATUS_GIVEUP)
    end

    FlowFramework.DelTimer(stPlayer:GetChairID(), 0)
    return STEP_SUCCEED
end


return logic_do_op_other_player_timeout
