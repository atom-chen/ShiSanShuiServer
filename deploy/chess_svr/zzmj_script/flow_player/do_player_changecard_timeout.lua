-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_do_player_changecard_timeout(stPlayer, event)
    LOG_DEBUG("Run LogicStep do_player_changecard_timeout")
    local stPlayerCardGroup = stPlayer:GetPlayerCardGroup()
    local stBest = LibChangeCard:SelectCardChange(stPlayerCardGroup:ToArray())
    local iRetCode = LibChangeCard:ProcessChangeCard(stPlayer, stBest)
    if iRetCode ~= 0 then
        LOG_ERROR("do_player_changecard_timeout Failed. iRetCode:%d\n", iRetCode)
        -- 严重错误 需要重新开局？
        
        return STEP_FAILED
    end

    return STEP_SUCCEED
end


return logic_do_player_changecard_timeout
