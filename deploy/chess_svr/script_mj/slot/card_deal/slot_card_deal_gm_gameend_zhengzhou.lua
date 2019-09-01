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
     --- ]]
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
    local jsonDate = [[{"hand_cards":{"p1":[1,1,2,2,2,3,3,3,4,4,4,5,5,1],"p2":[2,3,4,6,7,7,7,8,8,8,9,9,8],"p3":[1,9,11,19,21,29,31,32,33,34,35,36,37],"p4":[21,22,23,24,25,26,27,28,29,24,24,25,25]},"other_cards":[22,6,23,7,28,13,26,12,25,18,21,19,27,21,17,36,29,32,35,15,27,36,13,16,12,6,13,34,23,11,31,9,14,29,33,14,26,35,34,31,37,22,15,5,16,18,14,12,32,18,12,16,18,37,17,26,13,11,24,6,22,37,28,34,27,19,17,14,16,5,33,15,23,31,28,35,33,36,17,11,19,32,15]}]]
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


 LOG_DEBUG("\n =========222=======newcars lentth =%d",#newCards)
     -- 翻转以下
     Array.Reverse(newCards)
   
    return newCards
end

return slot
