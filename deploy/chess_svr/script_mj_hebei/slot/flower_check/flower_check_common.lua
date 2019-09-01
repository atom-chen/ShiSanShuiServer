local slot = {}

-- 实现 GetNextTurn  函数 。
-- 座位 1 2 3 4   顺时针坐下
-- 不考虑下一家玩家是否可以出牌，由玩法决定
-- 参数1  nThisTurn 当前轮操作玩家
-- 返回值  下一次出牌玩家
-- 逆时针出牌
function slot.IsFlowerCard(nCard)
    if type(nCard) ~= 'number' then
        return false
    end
    if nCard >= CARD_FLOWER_CHUN and nCard <= CARD_FLOWER_JU then
        return true
    end
    return false
end

return slot