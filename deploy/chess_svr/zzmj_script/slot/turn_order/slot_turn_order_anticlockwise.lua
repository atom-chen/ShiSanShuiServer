local slot = {}

-- 实现 GetNextTurn  函数 。
-- 座位 1 2 3 4   顺时针坐下
-- 不考虑下一家玩家是否可以出牌，由玩法决定
-- 参数1  nThisTurn 当前轮操作玩家
-- 返回值  下一次出牌玩家
-- 逆时针出牌
function slot.GetNextTurn(nThisTurn)
	-- 改为全部按逆时针
    return (nThisTurn + 1 + PLAYER_NUMBER -1) %  PLAYER_NUMBER + 1
    -- return (nThisTurn - 1 + PLAYER_NUMBER -1) %  PLAYER_NUMBER + 1
end


function slot.Sort(stTurn)
    table.sort(stTurn, function(a, b ) return a > b end)
end
return slot