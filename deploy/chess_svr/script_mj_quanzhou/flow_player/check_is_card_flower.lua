-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_check_is_card_flower(stPlayer, event)
    LOG_DEBUG("Run LogicStep check_is_card_flower")
    local cardPlayerLastDraw = stPlayer:GetPlayerCardGroup():GetLastDraw()
    if LibFlowerCheck:IsFlowerCard(cardPlayerLastDraw) then
        return "yes"
    end
    return "no"
end

return logic_check_is_card_flower
