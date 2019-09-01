-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_notify_compare_start(dealer, msg)
    LOG_DEBUG("Run LogicStep notify_compare_start")
    for i=1,PLAYER_NUMBER do
        local stPlayer = GGameState:GetPlayerByChair(i)
        if stPlayer ~= nil then
            stPlayer:SetCancleCompare(false)
        end
    end
    --设置等待比牌
    GRoundInfo:SetCompareWait(true)
    --通知玩家比牌开始
    CSMessage.NotifyPlayerCompareStart()

    return STEP_SUCCEED
end


return logic_notify_compare_start