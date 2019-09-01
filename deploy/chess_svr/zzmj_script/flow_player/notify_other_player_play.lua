-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_notify_other_player_play(stPlayer, msg)
    LOG_DEBUG("Run LogicStep notify_other_player_play")
    local stPlayerCardGroup = stPlayer:GetPlayerCardGroup()

    CSMessage.NotifyPlayerOtherPlayerPlay(stPlayer, msg._para.playChair, {msg._para.card})
   
    return STEP_SUCCEED
end


return logic_notify_other_player_play
