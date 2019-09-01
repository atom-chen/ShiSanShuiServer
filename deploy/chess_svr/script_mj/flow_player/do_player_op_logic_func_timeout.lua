-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_do_player_op_logic_func_timeout(stPlayer, event)
    LOG_DEBUG("Run LogicStep do_player_op_logic_func_timeout")
    local nChair = stPlayer:GetChairID()
    FlowFramework.DelTimer(nChair, 0)

    local stPlayerBlockState = LibGameLogic:GetPlayerBlockState(nChair)
    local stPlayerCards = stPlayer:GetPlayerCardGroup():ToArray()
    if stPlayerBlockState:IsCanWin() then
        local nWinCard = stPlayerBlockState:GetCurrWinCard()
        LOG_DEBUG("do ACTION_WIN")
        stPlayerBlockState:SetBlockFlag(ACTION_WIN, nWinCard)
        return STEP_SUCCEED
    end
    --[[
    -- 有杠则杠
    if stPlayerBlockState:IsCanQuadruplet() then
        local stCards = stPlayerBlockState:GetQuadrupletCard()
        LOG_DEBUG("do ACTION_QUADRUPLET")
        stPlayerBlockState:SetBlockFlag(ACTION_QUADRUPLET, stCards[1])
        return STEP_SUCCEED
    end
    --]]
    -- 不做任何操作 打一张牌
    local arrPlayerCards = stPlayer:GetPlayerCardGroup():ToArray()
    local nCard = LibTrustAuto:TrustPlayCard(arrPlayerCards, stPlayer:IsTing(), LibRuleTing:IsTingCanPlayOther())
    if nCard == nil then
        LOG_ERROR("arrPlayerCards:%s", vardump(stPlayer:GetPlayerCardGroup()));
    end
    local iResult = LibGameLogic:ProcessOPPlay(stPlayer, nCard)
    LOG_DEBUG("_chair %d do play card %d, process ret=%d", nChair, nCard, iResult)

    if iResult ~= 0 then
        return STEP_FAILED
    end
    stPlayer:AddTimeoutTimes()
    
    return STEP_SUCCEED
end


return logic_do_player_op_logic_func_timeout
