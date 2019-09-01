-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_round_is_round_end(dealer, msg)
    LOG_DEBUG("Run LogicStep round_is_round_end")
    local stGameState = GGameState
    local nWinPlayerNums  = 0
    for i=1,PLAYER_NUMBER do
        local  stPlayer = stGameState:GetPlayerByChair(i)
        if stPlayer ~= nil then
            if stPlayer:IsWin() == true then
                nWinPlayerNums = nWinPlayerNums + 1
            end
        end
    end
    
    local nDealCardLeft = GDealer:GetDealerCardGroup():GetCurrentLength()
    if LibGameEndJudge:IsGameEnd(nWinPlayerNums, nDealCardLeft) then
        LOG_DEBUG("nWinPlayerNums, nDealCardLeft %d %d", nWinPlayerNums, nDealCardLeft)
        return "yes"
    end
    return "no"
   
end


return logic_round_is_round_end
