local slot = {}

-- 实现 IsSupportTriplet  函数 。
-- 返回值  是否支持碰操作
function slot.IsSupportTriplet()
    return GGameCfg.GameSetting.bSupportTriplet == true
end


-- 实现 CanTriplet  函数 。
-- 检查是否可以碰
-- 参数1 玩家手牌
-- 参数2 其他玩家打出的牌
-- 返回值 是否可以碰
function slot.CanTriplet(stPlayerCardArray, nCard)
    if type(nCard) ~= 'number' or type(stPlayerCardArray) ~= 'table' then
        return false
    end
    local tripletCards = {nCard, nCard}
    if Array.IsSubSet(tripletCards, stPlayerCardArray) == true then
        return true
    end
    return false

end

-- 实现 GetTripletCard  函数 。
-- 获取可碰的牌
-- 参数1 玩家手牌
-- 参数2 打出的牌
-- 返回值  牌
function slot.GetTripletCard(stPlayerCardArray, nCard)
    --if slot.CanTriplet(stPlayerCardArray, nCard) == false then
    --    return nil
    --end
    return nCard
end

return slot