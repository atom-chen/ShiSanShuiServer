-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_do_player_leave(stPlayer, msg)
    -- LOG_DEBUG("Run LogicStep do_player_leave")
    local reason = msg._para.reason

    stPlayer:Logout()
    local nChair = stPlayer:GetChairID()
    CSMessage.NotifyPlayerLeave(stPlayer, reason)
    GGameState:RemovePlayer(nChair)
    -- stPlayer:SetIsTrust(true)
    -- CSMessage.NotifyTrustToAll(stPlayer, true)
    return STEP_SUCCEED
end


return logic_do_player_leave
