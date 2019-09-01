-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_do_player_mult(stPlayer, msg)
    LOG_DEBUG("Run LogicStep do_player_mult, %s", vardump(msg))
    local nPlayerBeiShu = msg._para.nBeishu
    LibMult:ProcessPlayerMult(stPlayer:GetChairID(), nPlayerBeiShu)

    -- 先不要告诉其他人
    --只回复该玩家选择倍数成功
    CSMessage.NotifyPlayerMult(stPlayer, nPlayerBeiShu)
    --记得删除定时器
    FlowFramework.DelTimer(stPlayer:GetChairID(), PLAYER_TIMER_ID_MULT)
    return STEP_SUCCEED
end



return logic_do_player_mult