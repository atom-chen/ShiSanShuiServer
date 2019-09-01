

local function CheckWin(arrPlayerCards,nLaiZiCount,LaiZiCard)
    local bResult = true
    local arrCards = Array.Clone(arrPlayerCards)
    if #arrCards == 14 then
        for i=1,#nLaiZiCount do
            Array.RemoveOne(arrCards, LaiZiCard)
        end
        local nCountEqual = 0
        arrCards = Array.Sort(arrCards)
        for i=1,14-nLaiZiCount do
            if arrCards[i] == arrCards[i+1] then
                nCountEqual = nCountEqual+1
            end
        end
        if nCountEqual == 7-nLaiZiCount then
            return true
        end
    else
        bResult = false
    end

    return bResult
end


return CheckWin