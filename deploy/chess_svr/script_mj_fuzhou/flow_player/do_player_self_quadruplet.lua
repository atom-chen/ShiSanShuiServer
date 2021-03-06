-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_do_player_self_quadruplet(stPlayer, msg)
    LOG_DEBUG("Run LogicStep logic_do_player_self_quadruplet")
    local arrCardQuadruplt = msg._para.cardQuadruplet
    if type(arrCardQuadruplt) ~= 'table' then
        CSMessage.NotifyError(stPlayer, ERROR_PARAM_ERR)
        return STEP_FAILED
    end
    local nCard = arrCardQuadruplt[1]
    if nCard == nil or  type(nCard) ~= 'number' then
        CSMessage.NotifyError(stPlayer, ERROR_PARAM_ERR)
        return STEP_FAILED
    end
    -- 检查玩家挡牌状态中是否可以杠这张牌
    local stPlayerBlockState = LibGameLogic:GetPlayerBlockState(stPlayer:GetChairID())
    if  stPlayerBlockState:IsCanQuadruplet(nCard) == false then
        return STEP_FAILED
    end

    -- 这里设置 杠状态标识
    stPlayerBlockState:SetBlockFlag(ACTION_QUADRUPLET, nCard)
    FlowFramework.DelTimer(stPlayer:GetChairID(), 0)
    return STEP_SUCCEED
end


return logic_do_player_self_quadruplet
