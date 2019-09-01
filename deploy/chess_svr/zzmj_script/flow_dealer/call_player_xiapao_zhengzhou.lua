-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_call_player_xiapao_zhengzhou(dealer, msg)
    LOG_DEBUG("Run LogicStep call_player_xiapao_zhengzhou")
    local stGameState = GGameState
    for i=1,PLAYER_NUMBER do
        local stPlayer = stGameState:GetPlayerByChair(i)
        SSMessage.CallPlayerXiaPao(stPlayer)
    end
    return STEP_SUCCEED
end

return logic_call_player_xiapao_zhengzhou
