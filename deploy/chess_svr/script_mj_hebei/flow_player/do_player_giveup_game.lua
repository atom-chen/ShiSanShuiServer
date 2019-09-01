-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_do_player_giveup_game(stPlayer, msg)
    LOG_DEBUG("Run LogicStep do_player_giveup_game")
    stPlayer:SetPlayEnd(true)
    CSMessage.NotifyAllPlayerGiveupPlay(stPlayer)
    return STEP_SUCCEED
end


return logic_do_player_giveup_game
