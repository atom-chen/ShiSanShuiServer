-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_do_player_self_hu(stPlayer, msg)
    LOG_DEBUG("Run LogicStep do_player_self_hu")
    local nCard = msg._para.cardWin
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
    --胡牌方式：0正常自摸胡，1抢金胡(算自摸)，2点炮胡, 3抢杠胡(算点炮),4起手三金倒
    if stPlayerBlockState:GetCurrWinBigType() ==ACTION_THREEGOLD then
        GRoundInfo:SetHuWay(4)
    else
        GRoundInfo:SetHuWay(0)
    end

    FlowFramework.DelTimer(stPlayer:GetChairID(), 0)
    return STEP_SUCCEED
end


return logic_do_player_self_hu
