
-- 全不靠
local function CheckWinChaos(arrPlayerCards)
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

    -- 东南西北中发白
    local stCardGragon = {31, 32, 33, 34, 35, 36, 37}
    for i=1,#stCardStyles do
        for _,gragon in ipairs(stCardGragon) do
            table.insert(stCardStyles[i], gragon)
        end
    end

   for i=1,#stCardStyles do
        if Array.IsSunSet(arrPlayerCards, stCardStyles[i]) then
            LOG_DEBUG("CheckWinNormal win :%s", vardump(arrPlayerCards));
            return true
        end
   end

    return false
end


return CheckWinChaos