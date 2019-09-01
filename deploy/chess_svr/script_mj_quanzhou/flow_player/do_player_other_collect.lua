-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_do_player_other_collect(stPlayer, msg)
    LOG_DEBUG("Run LogicStep do_player_other_collect")

    local cardCollect = msg._para.cardCollect
    if type(cardCollect) ~= 'table' then
        CSMessage.NotifyError(stPlayer, ERROR_PARAM_ERR)
        return STEP_FAILED
    end
    LOG_DEBUG("do_player_other_collect...cardCollect:%s", vardump(cardCollect))
    local nCard = cardCollect[1]
    if type(nCard) ~= 'number' then
        CSMessage.NotifyError(stPlayer, ERROR_PARAM_ERR)
        return STEP_FAILED
    end
    -- 检查玩家挡牌状态中是否可以吃这张牌
    local stPlayerBlockState = LibGameLogic:GetPlayerBlockState(stPlayer:GetChairID())
    if  stPlayerBlockState:IsCanCollect(nCard) == false then
        CSMessage.NotifyError(stPlayer, ERROR_BLOCK_COLLECT)
        return STEP_FAILED
    end

    -- 这里设置 吃状态标识
    stPlayerBlockState:SetBlockFlag(ACTION_COLLECT, nCard)
    FlowFramework.DelTimer(stPlayer:GetChairID(), 0)
    return STEP_SUCCEED
end


return logic_do_player_other_collect
