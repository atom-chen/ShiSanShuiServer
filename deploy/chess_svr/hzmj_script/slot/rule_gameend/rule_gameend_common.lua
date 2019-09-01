local slot = {}

-- 实现 IsGameEnd  函数 。
-- 大众玩法 有人和牌或者流局 为游戏结束
-- 参数1  游戏状态
-- 返回值  true 游戏结束   false 游戏未结束
-- 逆时针出牌
function slot.IsGameEnd(nWinPlayerNums, nDealCardLeft)
    if nDealCardLeft == 0 then
        return true
    end

    if nWinPlayerNums >= PLAYER_NUMBER-1 then 
        return true
    end

    return false

end

return slot