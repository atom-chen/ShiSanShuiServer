-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_check_to_start_game(dealer, msg)
    local count = 0
    for i=1,PLAYER_NUMBER do
        local stPlayer = GGameState:GetPlayerByChair(i)
        if stPlayer~=nil then
            LOG_DEBUG("failed logic_check_to_start_game stPlayer:GetPlayerStatus()==%d ",stPlayer:GetPlayerStatus())
        end
        if  stPlayer == nil or stPlayer:GetPlayerStatus()  ~=  PLAYER_STATUS_READY then
            LOG_DEBUG("=====logic_check_to_start_game ready i====:%d", i)
            LOG_DEBUG("failed logic_check_to_start_game  count:%d ",count)
            return STEP_FAILED
        end
        count = count +  1
    end
    LOG_DEBUG("logic_check_to_start_game ready count:%d", count)
    return STEP_SUCCEED
end

return logic_check_to_start_game
