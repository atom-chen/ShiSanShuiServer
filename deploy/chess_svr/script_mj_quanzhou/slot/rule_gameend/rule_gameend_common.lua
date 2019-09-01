local slot = {}

-- 实现 IsGameEnd  函数 。
-- 大众玩法 有人和牌或者流局 为游戏结束
-- 参数1  游戏状态
-- 返回值  true 游戏结束   false 游戏未结束
-- 逆时针出牌
function slot.IsGameEnd(nWinPlayerNums, nDealCardLeft, nDealerCardLeftEXceptGang)
	LOG_DEBUG("slot.IsGameEnd...nWinPlayerNums=%d, nDealCardLeft=%d, nDealerCardLeftEXceptGang=%d", nWinPlayerNums, nDealCardLeft, nDealerCardLeftEXceptGang)
	--流局
	if nDealerCardLeftEXceptGang >= GGameCfg.nLeftCardNeedQuict then
		--杠了的牌数量 >= 荒局需要的剩余牌数,则要把牌都要摸完,才算流局
		if nDealCardLeft <= 0 then
			return true
		end
	else
		--杠了的牌数量 + 剩余的牌数量 <= 荒局需要的剩余牌数,才算流局
		if nDealCardLeft + nDealerCardLeftEXceptGang <= GGameCfg.nLeftCardNeedQuict then
			return true
		end
	end

	--和牌
    if nWinPlayerNums > 0 then 
        return true
    end

    return false

end

return slot