

local function CheckWin(arrPlayerCards)
    local arrCards = Array.Clone(arrPlayerCards)
     local bResult = true
    arrCards = Array.Sort(arrCards)
    if #arrCards == 14 then
        for i=1,7 do
            if arrCards[i*2 -1 ] ~= arrCards[i*2] then
                bResult = false
                break
            end
        end
    else
        bResult = false
    end

   
    return bResult

end


return CheckWin