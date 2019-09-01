-- ????STEP_SUCCEED ????0???
-- ????STEP_FAILED ??????
local function logic_is_card_flower(stPlayer, event)
    LOG_DEBUG("Run LogicStep is_card_flower")
    local cardPlayerLastDraw = stPlayer:GetPlayerCardGroup():GetLastDraw()



    --local slotCheckFlower = import(GGameSlotCfg.strCheckFlower)
    local bIsFlower = LibFlowerCheck:IsFlowerCard(cardPlayerLastDraw)
    if  bIsFlower == true then
        return "no"
    end
    return "no"
end


return logic_is_card_flower
