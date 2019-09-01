-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_do_player_other_triplet(stPlayer, msg)
    LOG_DEBUG("Run LogicStep do_player_other_triplet")

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
    local stPlayerBlockState = LibGameLogic:GetPlayerBlockState(stPlayer:GetChairID())
    if  stPlayerBlockState:IsCanTriplet(nCard) == false then
        CSMessage.NotifyError(stPlayer, ERROR_BLOCK_TRIPLET)
        return STEP_FAILED
    end

    -- 这里设置 杠状态标识
    stPlayerBlockState:SetBlockFlag(ACTION_TRIPLET, nCard)
    FlowFramework.DelTimer(stPlayer:GetChairID(), 0)

    --碰之后通知出牌
    --CSMessage.NotifyAllPlayer(stPlayer, "ask_play", {}, GGameCfg.TimerSetting.giveTimeOut)
    return STEP_SUCCEED
end


return logic_do_player_other_triplet
