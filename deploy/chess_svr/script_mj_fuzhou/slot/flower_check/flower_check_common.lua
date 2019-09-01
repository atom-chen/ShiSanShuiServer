local slot = {}

--检测是否是花牌（不同的地方有不同的范围）
function slot.IsFlowerCard(nCard)
    if type(nCard) ~= 'number' then
        return false
    end
    -- 福州 东南西北中发白也算花牌
    if GGameCfg.RoomSetting.nGameStyle == GAME_STYLE_FUZHOU then
        if nCard >= CARD_EAST and nCard <= CARD_BAI then
            return true
        end
    end
    -- 
    if nCard >= CARD_FLOWER_CHUN and nCard <= CARD_FLOWER_JU then
        return true
    end
    return false
end

return slot