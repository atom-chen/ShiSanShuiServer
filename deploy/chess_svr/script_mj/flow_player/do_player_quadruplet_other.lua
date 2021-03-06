-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_do_player_quadruplet_other(stPlayer, msg)
    LOG_DEBUG("Run LogicStep do_player_quadruplet_other")
    local arrCardQuadruplt = msg._para.cardQuadruplet
    if type(arrCardQuadruplt) ~= 'table' then
        CSMessage.NotifyError(stPlayer, ERROR_PARAM_ERR)
        return STEP_FAILED
    end
    local nCard = arrCardQuadruplt[1]
    if type(nCard) ~= 'number' then
        CSMessage.NotifyError(stPlayer, ERROR_PARAM_ERR)
        return STEP_FAILED
    end
    -- 检查玩家挡牌状态中是否可以杠这张牌
    local nChair = stPlayer:GetChairID()
    local stPlayerBlockState = LibGameLogic:GetPlayerBlockState(nChair)
    if  stPlayerBlockState:IsCanQuadruplet(nCard) == false then
        return STEP_FAILED
    end
    -- 这里设置 杠状态标识
    stPlayerBlockState:SetBlockFlag(ACTION_QUADRUPLET, nCard)
    FlowFramework.DelTimer(nChair, 0)
    return STEP_SUCCEED
end


return logic_do_player_quadruplet_other
