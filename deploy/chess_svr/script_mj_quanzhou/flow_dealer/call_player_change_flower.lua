-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_call_player_change_flower(dealer, msg)
    LOG_DEBUG("Run LogicStep call_player_change_flower")
    local stGameState = GGameState
    for i=1,PLAYER_NUMBER do
        local stPlayer = stGameState:GetPlayerByChair(i)
        if stPlayer:GetPlayerCardGroup():IsHaveFlower() == true then
            SSMessage.CallPlayerChangeFlower(stPlayer)
        end
    end

    return STEP_SUCCEED
end


return logic_call_player_change_flower
