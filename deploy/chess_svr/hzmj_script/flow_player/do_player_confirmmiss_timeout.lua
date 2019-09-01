-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_do_player_confirmmiss_timeout(stPlayer, event)
    LOG_DEBUG("Run LogicStep do_player_confirmmiss_timeout")

    local stPlayerCardGroup = stPlayer:GetPlayerCardGroup()
    local nPlayerMiss = LibConfirmMiss:GetBestMiss(stPlayerCardGroup:ToArray())

    local iResult = LibConfirmMiss:ProcessPlayerConfirmMiss(stPlayer:GetChairID(), nPlayerMiss)

    if iResult ~= 0 then
         -- 逻辑上这里不会到
         LOG_ERROR("logic_do_player_confirmmiss_timeout Err")
         CSMessage.NotifyError(stPlayer, iResult)
         return STEP_FAILED
    end

    return STEP_SUCCEED
end


return logic_do_player_confirmmiss_timeout
