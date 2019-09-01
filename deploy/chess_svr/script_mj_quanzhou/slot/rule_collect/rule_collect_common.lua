local slot = {}

-- 实现 IsSupportCollect  函数 。
-- 返回值  是否支持吃操作
function slot.IsSupportCollect()
    return GGameCfg.GameSetting.bSupportCollect == true
end


-- 实现 CanCollect  函数 。
-- 检查是否可以吃
-- 参数1 玩家手牌
-- 参数2 上一家打出的牌
-- 返回值  是否可以吃
function slot.CanCollect(stPlayerCardArray, nCard)
    if type(nCard) ~= 'number' or type(stPlayerCardArray) ~= 'table' then
        return false
    end
    if nCard > CARD_BALL_9 then
        return false
    end

    if LibGoldCard:IsGoldCard(nCard) then
        return false
    end
    
    if Array.Exist(stPlayerCardArray, nCard - 1) and
        Array.Exist(stPlayerCardArray, nCard - 2)  then
        --有金牌就不能吃
        if LibGoldCard:IsGoldCard(nCard - 1) == false and  LibGoldCard:IsGoldCard(nCard - 2) == false then
            return true
        end
    end

    if Array.Exist(stPlayerCardArray, nCard - 1) and
        Array.Exist(stPlayerCardArray, nCard + 1)  then
        if LibGoldCard:IsGoldCard(nCard - 1) == false and LibGoldCard:IsGoldCard(nCard + 1) == false then
            return true
        end
    end

    if Array.Exist(stPlayerCardArray, nCard + 1) and
        Array.Exist(stPlayerCardArray, nCard + 2)  then
        if LibGoldCard:IsGoldCard(nCard + 1) == false and LibGoldCard:IsGoldCard(nCard + 2) == false then
            return true
        end
    end

    return false
end



-- 实现 GetCollectGroup  函数 。
-- 获取吃的选择方案
-- 参数1 玩家手牌
-- 参数2 上一家打出的牌
-- 返回值  table
function slot.GetCollectGroup( stPlayerCardArray, nCard )
     if type(nCard) ~= 'number' or type(stPlayerCardArray) ~= 'table' then
        return {}
    end
    local group = {}
    if nCard > CARD_BALL_9 then
        return group
    end
    -- group.nCollectCard = nCard

    if LibGoldCard:IsGoldCard(nCard) then
        return group
    end
    
    if Array.Exist(stPlayerCardArray, nCard - 1) and
        Array.Exist(stPlayerCardArray, nCard - 2)  then
        if LibGoldCard:IsGoldCard(nCard - 1) == false and  LibGoldCard:IsGoldCard(nCard - 2) == false then
            table.insert(group, { nCard - 2,  nCard - 1, nCard})
        end
    end

    if Array.Exist(stPlayerCardArray, nCard - 1) and
        Array.Exist(stPlayerCardArray, nCard + 1)  then
        if LibGoldCard:IsGoldCard(nCard - 1) == false and  LibGoldCard:IsGoldCard(nCard + 1) == false then
            table.insert(group, { nCard - 1, nCard, nCard +1})
        end
    end

    if Array.Exist(stPlayerCardArray, nCard + 1) and
        Array.Exist(stPlayerCardArray, nCard + 2)  then
        if LibGoldCard:IsGoldCard(nCard + 1) == false and  LibGoldCard:IsGoldCard(nCard + 2) == false then
            table.insert(group, { nCard, nCard + 1,  nCard + 2})
        end
    end
    return group
end
return slot