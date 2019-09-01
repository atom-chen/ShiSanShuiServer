
local slot = {}
slot.name = "slot_card_pool_default"
slot.GetCardSet = function()
    local tbCardPoolType = GGameCfg.CardPoolType
    local i = 1
    local  cards = {}
    -- 万
    if  Array.Exist(tbCardPoolType, "char") then
        for k=1,4 do
            for j=1,9 do
                cards[i] = j 
                i = i + 1
            end
        end
    end

    -- 条
    if  Array.Exist(tbCardPoolType, "bamboo") then
        for k=1,4 do
            for j=1,9 do
                cards[i] = j + 10
                i = i + 1
            end
        end
    end

    -- 筒
    if  Array.Exist(tbCardPoolType, "ball") then
         for k=1,4 do
            for j=1,9 do
                cards[i] = j + 20
                i = i + 1
            end
        end
    end


    if GGameCfg.RoomSetting.nGameStyle == GAME_STYLE_QUANZHOU then
        -- 风牌
        if Array.Exist(tbCardPoolType, "wind") then
            for k=1,4 do
                for j=1,4 do
                    cards[i] = j + 30
                    i = i + 1
                end
            end
        end
            -- 中 發 白
        if Array.Exist(tbCardPoolType, "jian") then
            for k=1,4 do
                for j=1,3 do
                    cards[i] = j + 34
                    i = i + 1
                end
            end
        end

        -- 花牌
        if Array.Exist(tbCardPoolType, "flower") then
            for j=1,8 do
                cards[i] = j + 40
                 i = i + 1
            end
        end
    else
        -- 风牌
        if Array.Exist(tbCardPoolType, "wind") then
            for k=1,4 do
                for j=1,5 do
                    cards[i] = j + 30
                    i = i + 1
                end
            end
        end
        -- 發 白
        if Array.Exist(tbCardPoolType, "fabai") then
            for k=1,4 do
                for j=1,2 do
                    cards[i] = j + 35
                    i = i + 1
                end
            end
        end

        -- 花牌
        if Array.Exist(tbCardPoolType, "flower") then
            for j=1,8 do
                cards[i] = j + 40
                 i = i + 1
            end
        end
    end
    return cards
end

return slot
