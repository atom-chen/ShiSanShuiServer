-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_do_player_continue_play(stPlayer, msg)
    LOG_DEBUG("Run LogicStep do_player_continue_play")

    local bGiveUp = msg._para.giveup
    if type(bGiveUp) ~= 'boolean' then
        CSMessage.NotifyError(stPlayer, ERROR_PARAM_ERR)
        return STEP_FAILED
    end
    if bGiveUp == true then
        stPlayer:SetPlayEnd(true)
        CSMessage.NotifyAllPlayerGiveupPlay(stPlayer)
    else
        return STEP_FAILED
    end

    return STEP_SUCCEED
end


return logic_do_player_continue_play
