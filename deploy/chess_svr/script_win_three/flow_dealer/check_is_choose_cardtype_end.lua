-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_check_is_choose_cardtype_end(dealer, msg)
    -- LOG_DEBUG("Run LogicStep check_is_choose_cardtype_end")
    local stGameState = GGameState
    local bChooseEnd = true
    for i=1,PLAYER_NUMBER do
        local stPlayer = stGameState:GetPlayerByChair(i)
        if stPlayer ~= nil then
            -- LOG_DEBUG("check_is_choose_cardtype_end...uid:%d, p%d, isChoose:%s",  stPlayer:GetUin(), i, tostring(stPlayer:IsChooseCardType()))
            if not stPlayer:IsChooseCardType() then
                bChooseEnd = false
                break
            end
        end
    end
    -- LOG_DEBUG("check_is_choose_cardtype_end...result:%s", tostring(bChooseEnd))

    if bChooseEnd then
        return "yes"
    end
    return "no"
end
return logic_check_is_choose_cardtype_end