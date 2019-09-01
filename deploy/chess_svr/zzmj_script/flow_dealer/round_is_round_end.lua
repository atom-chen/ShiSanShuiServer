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
    
    --荒牌判断，加上杠牌的手牌数为14
        local nDealerCardLeft = GDealer:GetDealerCardGroup():GetCurrentLength()
         --杠牌后从牌尾摸的牌
        local nDealerCardLeftEXceptGang = GDealer:GetDealerCardGroup():GetCurrentCardLeftEXceptGang() 
        --现有的牌树+从尾部拿掉的牌
        -- local nCardLocation = nDealerCardLeft+nDealerCardLeftEXceptGang
    if LibGameEndJudge:IsGameEnd(nWinPlayerNums, nDealerCardLeft, nDealerCardLeftEXceptGang) then
        LOG_DEBUG("nWinPlayerNums, nDealerCardLeft, nDealerCardLeftEXceptGang %d ===%d====%d", nWinPlayerNums, nDealerCardLeft, nDealerCardLeftEXceptGang)
        return "yes"
    end
    return "no"
   
end


return logic_round_is_round_end
