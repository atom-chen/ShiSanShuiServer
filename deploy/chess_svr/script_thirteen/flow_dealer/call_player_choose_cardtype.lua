-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_call_player_choose_cardtype(dealer, msg)
    LOG_DEBUG("Run LogicStep call_player_choose_cardtype")
    local stGameState = GGameState
    for i=1,PLAYER_NUMBER do
        local stPlayer = stGameState:GetPlayerByChair(i)
        if stPlayer ~= nil then
            -- LOG_DEBUG("call_player_choose_cardtype...p%d, isChoose:%s", i, tostring(stPlayer:IsChooseCardType()))
            if not stPlayer:IsChooseCardType() then
                SSMessage.CallPlayerChooseCardType(stPlayer)
            end
        end
    end
    return STEP_SUCCEED
end

return logic_call_player_choose_cardtype