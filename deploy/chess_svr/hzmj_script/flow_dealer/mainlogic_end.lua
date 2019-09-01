-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_mainlogic_end(dealer, msg)
    LOG_DEBUG("Run LogicStep mainlogic_end")
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
    local nDealCardLeft = dealer:GetDealerCardGroup():GetCurrentLength()
    if nDealCardLeft ==0 and nWinPlayerNums ~=PLAYER_NUMBER-1 then
    	LibGameLogic:GameOverNoCard()
	end
    dealer:ToNextStage()
    SSMessage.WakeupDealer();
    return STEP_SUCCEED
end


return logic_mainlogic_end
