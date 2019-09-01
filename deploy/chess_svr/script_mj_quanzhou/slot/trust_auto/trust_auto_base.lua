local slot = {}

-- 实现 TrustPlayCard  函数 。
-- 托管打牌
-- 返回值  出牌
function slot.TrustPlayCard(arrPlayerCards, bIsTing, bIsTingCanPlayerOther)
    return arrPlayerCards[#arrPlayerCards]
end

return slot
