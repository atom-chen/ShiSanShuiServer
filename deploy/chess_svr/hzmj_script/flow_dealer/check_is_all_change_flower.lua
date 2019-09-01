-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_check_is_all_change_flower(dealer, msg)
    LOG_DEBUG("Run LogicStep check_is_all_change_flower")
    local stGameState = GGameState
    for i=1,PLAYER_NUMBER do
        local stPlayer = stGameState:GetPlayerInfoByChair(i)
        if stPlayer:GetPlayerCardGroup():IsHaveFlower() == true then
            return "yes"
        end
    end
    return "no"
end


return logic_check_is_all_change_flower
