-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_do_player_gangci_hu(stPlayer, msg)
    LOG_DEBUG("Run LogicStep do_player_gangci_hu")
    local nCard = msg._para.cardWin
    if type(nCard) ~= 'number' then
        CSMessage.NotifyError(stPlayer, ERROR_PARAM_ERR)
        return STEP_FAILED
    end

    -- 检查玩家挡牌状态中是否可以胡
    local nChair = stPlayer:GetChairID()
    local stPlayerBlockState = LibGameLogic:GetPlayerBlockState(nChair)
    if  stPlayerBlockState:IsCanWin() == false then
        CSMessage.NotifyError(stPlayer, ERROR_BLOCK_WIN)
        return STEP_FAILED
    end
    -- 这里设置 胡状态标识
    stPlayerBlockState:SetBlockFlag(ACTION_WIN, nCard)
    FlowFramework.DelTimer(nChair, 0)

    return STEP_SUCCEED
end


return logic_do_player_gangci_hu