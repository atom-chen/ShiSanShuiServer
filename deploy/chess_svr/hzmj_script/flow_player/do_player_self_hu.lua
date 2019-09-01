-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_do_player_self_hu(stPlayer, msg)
    LOG_DEBUG("Run LogicStep do_player_self_hu")

    -- if type(msg._para.cardWin) ~= 'table' or #msg._para.cardWin ~= 1 then
    --     LOG_ERROR("do_player_play_card Error msg._para. msg._para:%s\n", vardump(msg))
    --      CSMessage.NotifyError(stPlayer, ERROR_PARAM_ERR)
    -- end

    local nCard = msg._para.cardWin -- [1]
   
    if type(nCard) ~= 'number' then
        CSMessage.NotifyError(stPlayer, ERROR_PARAM_ERR)
        return STEP_FAILED
    end
    -- 检查玩家挡牌状态中是否可以杠这张牌
    local stPlayerBlockState = LibGameLogic:GetPlayerBlockState(stPlayer:GetChairID())
    if  stPlayerBlockState:IsCanWin() == false then
        CSMessage.NotifyError(stPlayer, ERROR_BLOCK_WIN)
        return STEP_FAILED
    end

    -- 这里设置 杠状态标识
    stPlayerBlockState:SetBlockFlag(ACTION_WIN, nCard)

    FlowFramework.DelTimer(stPlayer:GetChairID(), 0)

    return STEP_SUCCEED
end


return logic_do_player_self_hu
