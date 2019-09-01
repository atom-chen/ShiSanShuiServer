-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_do_player_triplet_other(stPlayer, msg)
    LOG_DEBUG("Run LogicStep do_player_triplet_other")
    local cardTriplet = msg._para.cardTriplet
    if type(cardTriplet) ~= 'table' then
        CSMessage.NotifyError(stPlayer, ERROR_PARAM_ERR)
        return STEP_FAILED
    end
    local nCard = cardTriplet[1]
    if type(nCard) ~= 'number' then
        CSMessage.NotifyError(stPlayer, ERROR_PARAM_ERR)
        return STEP_FAILED
    end
    -- 检查玩家挡牌状态中是否可以杠这张牌
    local nChair = stPlayer:GetChairID()
    local stPlayerBlockState = LibGameLogic:GetPlayerBlockState(nChair)
    if  stPlayerBlockState:IsCanTriplet(nCard) == false then
        CSMessage.NotifyError(stPlayer, ERROR_BLOCK_TRIPLET)
        return STEP_FAILED
    end
    -- 这里设置 杠状态标识
    stPlayerBlockState:SetBlockFlag(ACTION_TRIPLET, nCard)
    FlowFramework.DelTimer(nChair, 0)

    return STEP_SUCCEED
end

return logic_do_player_triplet_other
