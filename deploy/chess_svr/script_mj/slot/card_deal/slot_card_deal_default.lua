local slot = {}
-- 实现 DoDeal 函数
-- 参数1  cards 牌堆中所有的牌
-- 返回值  返回洗好的牌
require "common.socket"
function slot.DoDeal(cards)
    if type(cards) ~= "table" then
        return {}
    end
    if #cards == 0 then
        return {}
    end
    local newCards = clone(cards)
    local maxCardLen = #newCards
    -- math.randomseed(socket.gettime()*1317)
    local z = (math.random(0, 1317) % 20 + 17) * (math.random(0,1317) % 20 + 17)
    local swapChar = 0
    while z > 0 do
        local i = math.random(0,1317) % maxCardLen +1
        local j = math.random(0,1317) % maxCardLen + 1
        swapChar = newCards[i]
        newCards[i] = newCards[j]
        newCards[j] = swapChar
        z = z - 1
    end
    return newCards
end

return slot
