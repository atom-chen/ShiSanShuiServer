-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_do_mult_end(dealer, msg)
    LOG_DEBUG("Run LogicStep do_mult_end")

    local stPlayerMult = {}
    local banker = GDealer:GetBanker()
    for i=1,PLAYER_NUMBER do
        local stPlayer = GGameState:GetPlayerByChair(i)
        if stPlayer then
            local nMult = LibMult:GetPlayerMult(i)
            table.insert(stPlayerMult, nMult)
            if i ~= banker then
                CSMessage.NotifyPlayerMult(stPlayer, nMult)
            end
        end
    end
    CSMessage.NotifyMultResult(nil, stPlayerMult)

    dealer:ToNextStage()
    return STEP_SUCCEED
end


return logic_do_mult_end