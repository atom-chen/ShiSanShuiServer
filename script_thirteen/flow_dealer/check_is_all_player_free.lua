-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_check_is_all_player_free(dealer, msg)
    -- LOG_DEBUG("Run LogicStep check_is_all_player_free")
    local count = 0
    for i=1,PLAYER_NUMBER do
        local stPlayer = GGameState:GetPlayerByChair(i)
        if stPlayer ~= nil and stPlayer:IsAllFlowFree() == false then
            -- LOG_DEBUG("logic_check_is_all_player_free count :%d return STEP_FAILED:%d ", count , STEP_FAILED)
            return STEP_FAILED
        end
        count = count + 1
    end
    -- LOG_DEBUG("logic_check_is_all_player_free count :%d ", count)
    return STEP_SUCCEED
end


return logic_check_is_all_player_free
