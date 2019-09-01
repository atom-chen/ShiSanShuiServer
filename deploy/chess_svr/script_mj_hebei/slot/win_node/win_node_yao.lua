local function CheckWinYao(arrPlayerCards)
    local stCard13Yao = {1, 9, 11, 19, 21, 29, 31, 32, 33, 34, 35, 36, 37}
    if #arrPlayerCards == 14 and Array.IsSubSet(stCard13Yao, arrPlayerCards) then
        local arrCardTmp = clone(arrPlayerCards)
        Array.DelElements(allCardTmp, stCard13Yao)
        if Array.IsSubSet(allCardTmp, stCard13Yao) then
            LOG_DEBUG("CheckWinYao win :%s", vardump(arrPlayerCards));
            return true
        end
    end

    return false
end


return CheckWinYao