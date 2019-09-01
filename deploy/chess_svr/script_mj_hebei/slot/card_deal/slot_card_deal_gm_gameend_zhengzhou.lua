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
    --local jsonDate = [[{"hand_cards":{"p1":[1,2,3,4,5,6,7,8,9,4,5,6,8,34],"p2":[13,13,13,13,12,12,14,14,15,15,23,23,34],"p3":[22,22,22,24,25,25,26,26,34,33,32,36,37],"p4":[36,35,37,33,32,34,31,21,11,1,9,29,19]},"other_cards":[27,19,1,28,21,17,35,32,14,36,31,26,16,12,28,8,3,9,18,27,21,21,6,4,7,23,17,4,16,9,26,15,44,24,7,2,17,12,29,35,1,11,41,42,22,23,18,45,19,37,31,2,28,27,33,24,46,48,14,3,25,7,32,33,8,16,11,31,43,24,5,5,25,2,19,17,6,18,37,3,35,28,36,18,29,11,29,47,15,27,16]}]]
    local jsonDate = [[{"hand_cards":{"p1":[1,1,1,1,2,2,2,2,4,5,6,7,8,9],"p2":[11,11,11,11,12,12,12,13,14,15,16,17,12],"p3":[31,31,31,31,32,32,32,32,33,33,33,33,19],"p4":[35,35,35,35,36,36,36,36,37,37,37,37,34]},"other_cards":[25,3,22,18,26,27,17,19,21,26,21,9,24,25,7,14,4,22,23,6,29,19,16,4,7,34,25,17,18,16,15,18,34,8,29,24,8,27,4,8,5,27,7,22,13,13,24,29,17,9,28,14,21,29,34,3,23,5,26,26,3,13,15,6,15,25,21,18,28,5,22,23,14,28,16,3,19,28,27,9,6,23,24]}]]
    --local jsonDate = [[{"hand_cards":{"p1":[2,2,2,2,3,3,4,4,5,5,6,6,7,34],"p2":[13,23,34,31,36,36,37,23,25,27,27,15,15],"p3":[22,22,22,24,34,12,12,13,13,15,14,16,17],"p4":[36,35,37,33,32,34,31,21,25,26,28,28,28]},"other_cards":[7,9,17,8,13,1,23,42,29,4,9,26,11,24,28,5,11,22,21,14,48,16,25,16,21,12,31,36,14,18,44,24,7,17,37,35,45,35,3,3,32,1,18,19,19,32,41,15,7,35,27,19,6,24,46,11,1,25,26,11,26,23,9,27,9,33,21,29,37,43,14,33,6,12,31,4,16,17,8,8,19,33,29,29,8,5,1,32,18,47,18]}]]
    --local jsonDate = [[{"hand_cards":{"p1":[2,2,2,2,3,3,4,4,5,5,6,6,7,34],"p2":[13,23,34,31,36,36,37,23,25,27,27,15,15],"p3":[22,22,22,24,34,12,12,13,13,15,14,16,17],"p4":[36,35,37,33,32,34,31,21,25,26,28,28,28]},"other_cards":[7,9,17,8,13,1,23,42,29,4,9,26,11,24,28,5,11,22,21,14,48,16,25,16,21,12,31,36,14,18,44,24,7,17,37,35,45,35,3,3,32,1,18,19,19,32,41,15,7,35,27,19,6,24,46,11,1,25,26,11,26,23,9,27,9,33,21,29,37,43,14,33,6,12,31,4,16,17,8,8,19,33,29,29,8,5,1,32,18,47,18]}]]
    --local jsonDate = [[{"hand_cards":{"p1":[2,2,2,2,3,3,5,5,7,34,3,3,5,5],"p2":[13,23,34,31,36,36,37,23,25,27,27,15,15],"p3":[22,22,22,24,34,12,12,13,13,15,14,16,17],"p4":[36,35,37,33,32,34,31,21,25,26,28,28,28]},"other_cards":[47,8,24,13,18,9,35,11,4,1,17,33,32,33,11,1,29,21,25,31,11,17,4,36,35,21,8,9,14,18,14,9,27,25,37,8,31,16,33,26,9,41,29,23,19,42,48,26,6,26,45,24,7,18,1,4,7,23,44,7,22,15,28,12,4,21,1,27,16,24,19,8,6,35,37,6,29,32,18,19,6,11,29,12,14,17,46,43,19,32,16]}]]
    --local jsonDate = [[{"hand_cards":{"p1":[35,36,37,32,31,33,34,21,9,11,1,19,29,12],"p2":[13,23,34,31,36,36,37,23,25,27,27,15,15],"p3":[22,22,22,24,34,12,12,13,13,15,14,16,17],"p4":[36,35,37,33,32,34,31,21,25,26,28,28,28]},"other_cards":[7,32,29,23,21,45,26,48,17,16,9,3,2,8,14,17,4,22,5,14,8,33,35,17,18,32,28,6,7,19,3,8,43,23,2,46,29,1,11,4,25,7,19,21,47,7,9,13,19,26,27,1,2,14,31,18,4,42,9,25,24,16,5,24,2,3,11,37,5,41,12,26,6,1,5,18,33,16,35,24,15,11,6,4,27,29,6,44,8,18,3]}]]

    local PeipaiDate = cjson.decode(jsonDate)


    local stCardsPlayer1 = PeipaiDate["hand_cards"]["p1"]
    local stCardsPlayer2 = PeipaiDate["hand_cards"]["p2"]
    local stCardsPlayer3 = PeipaiDate["hand_cards"]["p3"]
    local stCardsPlayer4 = PeipaiDate["hand_cards"]["p4"]
    -- local stOtherCards = PeipaiDate["other_cards"]

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
