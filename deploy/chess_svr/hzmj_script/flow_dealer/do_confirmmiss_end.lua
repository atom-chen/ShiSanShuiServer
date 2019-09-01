-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_do_confirmmiss_end(dealer, msg)
    LOG_DEBUG("Run LogicStep do_confirmmiss_end")
    local stPlayerMiss = {}
    for i=1,PLAYER_NUMBER do
        --local stPlayer = GGameState:GetPlayerByChair(i)
        local nPlayerMiss = LibConfirmMiss:GetPlayerMissCard(i)
        table.insert(stPlayerMiss, nPlayerMiss)
    end
    CSMessage.NotifyConfimMissResult(stPlayerMiss)
    dealer:ToNextStage()
    return STEP_SUCCEED
end


return logic_do_confirmmiss_end
