local slot = {}
-- 实现 DoDeal 函数
-- 参数1  cards 牌堆中所有的牌
-- 返回值  返回洗好的牌
function slot.DoDeal(cards)
    if type(cards) ~= "table" then
        return {}
    end
    local newCards = {}

    -- 庄家 胡
    --[[
    local stCardsPlayer1 = {CARD_CHAR_1, CARD_CHAR_1,
            CARD_CHAR_2, CARD_CHAR_3,CARD_CHAR_4,
            CARD_CHAR_5, CARD_CHAR_6,CARD_CHAR_7,
            CARD_CHAR_5, CARD_CHAR_6,CARD_CHAR_7,
            CARD_CHAR_9, CARD_CHAR_9, CARD_CHAR_9, 
            --CARD_BALL_1, CARD_BALL_2,CARD_BALL_3
    }
    local stCardsPlayer2= {
            CARD_CHAR_1,
            CARD_CHAR_2, CARD_CHAR_3,CARD_CHAR_4,
            CARD_CHAR_5, CARD_CHAR_6,CARD_CHAR_7,
            CARD_CHAR_5, CARD_CHAR_6,CARD_CHAR_7,
            CARD_BALL_1, CARD_BALL_2,CARD_BALL_3
    }
    local stCardsPlayer3 = {
            CARD_BAMBOO_1,
            CARD_BAMBOO_2, CARD_BAMBOO_3,CARD_BAMBOO_4,
            CARD_BAMBOO_5, CARD_BAMBOO_6,CARD_BAMBOO_7,
            CARD_BAMBOO_5, CARD_BAMBOO_6,CARD_BAMBOO_7,
            CARD_BALL_1, CARD_BALL_2,CARD_BALL_3
    }
    local stCardsPlayer4 = {
            CARD_BAMBOO_1,
            CARD_BAMBOO_2, CARD_BAMBOO_3,CARD_BAMBOO_4,
            CARD_BAMBOO_5, CARD_BAMBOO_6,CARD_BAMBOO_7,
            CARD_BAMBOO_5, CARD_BAMBOO_6,CARD_BAMBOO_7,
            CARD_BALL_1, CARD_BALL_2,CARD_BALL_3
    }
    --]]
    
    --[[
    -- 庄家 可杠 
    local stCardsPlayer1 = {
        CARD_BALL_1,CARD_BALL_1, CARD_BALL_1, CARD_BALL_1,CARD_CHAR_1, CARD_CHAR_1,
        CARD_BAMBOO_1, CARD_BAMBOO_2, CARD_BAMBOO_3, CARD_BAMBOO_4, CARD_BAMBOO_5, CARD_BAMBOO_6,
        CARD_BAMBOO_1,CARD_CHAR_2,
    }

    local stCardsPlayer2 = {
        CARD_BALL_2,CARD_BALL_3,  CARD_BALL_4, CARD_BALL_5,CARD_BALL_6, CARD_BALL_7,CARD_BALL_8, CARD_BALL_9,
        CARD_BAMBOO_1, CARD_BAMBOO_2, CARD_BAMBOO_3, CARD_BAMBOO_4, CARD_BAMBOO_5, 
    }
    local stCardsPlayer3 = {
        CARD_BAMBOO_1, CARD_BAMBOO_2, CARD_BAMBOO_3, CARD_BAMBOO_4, CARD_BAMBOO_5, CARD_BAMBOO_6, 
        CARD_CHAR_1, CARD_CHAR_2, CARD_CHAR_3, CARD_CHAR_4, CARD_CHAR_5, CARD_CHAR_6, 
        CARD_CHAR_7, 
    }
    local stCardsPlayer4 = {
         CARD_CHAR_1, CARD_BAMBOO_2, CARD_BAMBOO_3, CARD_BAMBOO_4, CARD_BAMBOO_5, CARD_BAMBOO_6, 
         CARD_CHAR_2, CARD_CHAR_3, CARD_CHAR_4, CARD_CHAR_5, CARD_CHAR_6, CARD_CHAR_7,
        CARD_CHAR_7, 
    }
    --]]
    
    --[[ 
    -- 庄家 可听
    local stCardsPlayer1 = {
        CARD_BALL_2,CARD_BALL_3,  CARD_BALL_4, CARD_BALL_5,CARD_BALL_6, CARD_BALL_7, 
        CARD_BALL_8, CARD_BALL_9,
        CARD_BAMBOO_1, CARD_BAMBOO_2, CARD_BAMBOO_3, CARD_BAMBOO_9, CARD_BAMBOO_9, 
        CARD_BAMBOO_9, 
    }
    local stCardsPlayer2 = {
        CARD_BALL_1,CARD_BALL_1, CARD_BALL_1, CARD_BALL_1,CARD_CHAR_1, CARD_CHAR_1,
        CARD_BAMBOO_1, CARD_BAMBOO_2, CARD_BAMBOO_3, CARD_BAMBOO_4, CARD_BAMBOO_5, CARD_BAMBOO_6,
        CARD_CHAR_2,
    }

    local stCardsPlayer3 = {
        CARD_BAMBOO_1, CARD_BAMBOO_2, CARD_BAMBOO_3, CARD_BAMBOO_4, CARD_BAMBOO_5, CARD_BAMBOO_6, 
        CARD_CHAR_1, CARD_CHAR_2, CARD_CHAR_3, CARD_CHAR_4, CARD_CHAR_5, CARD_CHAR_6, 
        CARD_CHAR_7, 
    }
    local stCardsPlayer4 = {
         CARD_CHAR_1, CARD_BAMBOO_2, CARD_BAMBOO_3, CARD_BAMBOO_4, CARD_BAMBOO_5, CARD_BAMBOO_6, 
         CARD_CHAR_2, CARD_CHAR_3, CARD_CHAR_4, CARD_CHAR_5, CARD_CHAR_6, CARD_CHAR_7,
        CARD_CHAR_7, 
    }
    --]]
    -- 添加
    local cjson = require"cjson"

    local jsonDate =[[{"hand_cards":{"p1":[1,1,1,2,2,2,3,3,4,4,5,5,5,6,6,7,7],"p2":[41,42,43,44,45,46,47,48,11,11,11,12,12,12,13,13],"p3":[31,31,31,32,32,32,33,33,33,34,34,34,35,35,36,36],"p4":[21,21,21,22,22,22,23,23,23,24,24,24,25,25,25,26]},"other_cards":[18,11,17,25,37,16,9,29,23,14,26,35,17,9,21,6,27,6,16,16,18,9,35,3,2,28,26,14,8,34,8,28,3,13,37,5,13,27,7,29,36,29,15,19,32,19,4,14,9,16,29,14,18,18,28,17,8,31,27,26,37,22,15,12,37,36,4,27,15,7,33,1,15,19,19,24,28,17,8]}]]

    --local jsonDate = [[{"hand_cards":{"p1":[1,1,1,2,2,2,3,3,3,4,4,4,5,5,5,6,6],"p2":[33,41,19,13,26,42,32,29,31,32,37,3,11,21,22,46],"p3":[18,43,13,44,27,21,29,28,32,36,27,37,36,31,36,9],"p4":[19,45,26,23,47,31,33,18,23,21,8,34,26,8,2,35]},"other_cards":[1,6,15,37,11,32,37,35,16,5,22,15,24,21,12,25,13,9,17,18,25,31,12,35,14,8,12,34,12,19,34,33,29,7,15,23,48,17,24,22,9,34,14,16,7,15,23,29,27,13,24,4,36,6,19,25,17,9,14,18,27,26,35,24,7,7,22,8,17,14,28,11,33,25,16,11,28,28,16]}]]

    -- local jsonDate = [[{"hand_cards":{"p1":[1,1,1,1,13,23,2,2,2,2,3,3,3,3,4,4,4],"p2":[11,11,11,11,12,12,12,12,13,13,14,14,14,15,15,15],"p3":[31,31,31,8,32,32,32,32,39,33,33,33,39,34,34,34],"p4":[35,35,35,8,36,41,41,41,41,42,42,42,43,43,43,43]},"other_cards":[5,37,43,18,6,34,19,45,17,27,45,47,9,17,46,13,21,48,34,25,36,9,9,18,14,4,15,7,16,25,5,21,36,28,28,26,22,18,16,24,4,46,46,26,17,4,6,27,37,9,48,19,8,24,43,19,36,24,22,28,42,4,47,23,28,8,48,6,27,23,29,29,17,48,21,15,29,8,27,25,44,47,46,43,16,8,34,7,25,22,21,23,15,5,19,37,7,45,44,5,47,45,18,22,6,15,29,37,16,24,26,44,26,44,7]}]]
    local PeipaiDate = cjson.decode(jsonDate)

    local stCardsPlayer1 = PeipaiDate["hand_cards"]["p1"]
    local stCardsPlayer2 = PeipaiDate["hand_cards"]["p2"]
    local stCardsPlayer3 = PeipaiDate["hand_cards"]["p3"]
    local stCardsPlayer4 = PeipaiDate["hand_cards"]["p4"]
    --local stOtherCards = PeipaiDate["other_cards"]

    local stPlayers = {stCardsPlayer1, stCardsPlayer2, stCardsPlayer3, stCardsPlayer4}
    for i=1,#stPlayers do
        local stCardsPlayer = stPlayers[i]
        for j=1,#stCardsPlayer do
            newCards[#newCards + 1] = stCardsPlayer[j]
            --LOG_DEBUG("newCards----fffffff----other:%d ",newCards[j])
        end
    end
    LOG_DEBUG("\n =========111=======newcars lentth =%d",#newCards)

    local tmpCards = clone(cards)
    for i=1,#newCards do
        local card = newCards[i]
        local bRet = Array.RemoveOne(tmpCards, card)
        if bRet == false then
            LOG_ERROR("GM Player Cards Error, index:%d card:%d", i, card)
            return cards
        end
    end
    -- 添加剩下的牌型 添加两张牌 
    -- #tmpCards
    for i=1,#tmpCards do
        newCards[#newCards + 1] = tmpCards[i]
    end

    -- for j=1,#stCardsPlayer3 do
    --     newCards[#newCards + 1] = stCardsPlayer3[j]
    --     --LOG_DEBUG("newCards----fffffff----other:%d ",newCards[j])
    -- end

    LOG_DEBUG("\n =========222=======newcars lentth =%d",#newCards)
    LOG_DEBUG("\n =========222=======newcars  =%s",vardump(newCards))
    -- 翻转以下
    --Array.Reverse(newCards)
   
    return newCards
end

return slot
