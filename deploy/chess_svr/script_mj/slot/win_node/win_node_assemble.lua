
-- 组合龙
local function CheckWinAssemble(arrPlayerCards)
    if #arrPlayerCards ~= 14 then
        return false
    end

    --local arrCards = clone(arrPlayerCards)
    --local bResult = true

    --       万              条                   筒
    --      147             258                 369
    --      147             369                 258
    --      258             147                 369
    --      258             369                 147
    --      369             147                 258
    --      369             258                 147
    local stCardStyles = {}
    stCardStyles[1] = {1, 4, 7, 12, 15, 18,23, 26, 29}
    stCardStyles[2] = {1, 4, 7, 22, 25, 28,13, 16, 19}
    stCardStyles[3] = {2, 5, 8, 11, 14, 17,23, 26, 29}
    stCardStyles[4] = {2, 5, 8, 21, 24, 27,13, 16, 19}
    stCardStyles[4] = {3, 6, 9, 11, 14, 17,22, 25, 28}
    stCardStyles[5] = {3, 6, 9, 21, 24, 27,12, 15, 18}

    local CheckWinNormal = function() return false end -- import("");

   for i=1,#stCardStyles do
        if Array.IsSubSet(stCardStyles[i], arrPlayerCards ) then
            --/检查剩下的牌可不可以和
            local stLeft = clone(arrPlayerCards)
            Array.DelElements(stLeft, stCardStyles[i])
            if  CheckWinNormal(stLeft) == true then
                LOG_DEBUG("CheckWinNormal win :%s", vardump(arrPlayerCards));
                return true
            end
            
        end
   end

    return false
end


return CheckWinAssemble