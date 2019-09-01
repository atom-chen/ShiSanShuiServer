local slot = {}

-- 实现 TrustPlayCard  函数 。
-- 托管打牌
-- 返回值  出牌
function slot.TrustPlayCard(arrPlayerCards, bIsTing, bIsTingCanPlayerOther)
    local nCard =arrPlayerCards[#arrPlayerCards]
    LOG_DEBUG("slot.TrustPlayCard()----arrPlayerCards:%s, nCard:%d ", vardump(arrPlayerCards), nCard)
	if LibLaiZi:IsLaiZi(nCard) then
        if not GGameCfg.GameSetting.bSupportPlayLaizi then
            for i=1, #arrPlayerCards do
                if not LibLaiZi:IsLaiZi(arrPlayerCards[i]) then
                    return arrPlayerCards[i]
                end
            end
        end
    end
    return arrPlayerCards[#arrPlayerCards]
end

return slot
