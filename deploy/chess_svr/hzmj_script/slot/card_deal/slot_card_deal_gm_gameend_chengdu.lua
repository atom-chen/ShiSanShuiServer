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
    local jsonDate = [[{"hand_cards":{"p1":[1,1,1,11,11,11,21,21,21,3,3,3,1,11],"p2":[12,13,13,14,14,14,15,16,16,16,18,18,18],"p3":[7,7,8,8,8,8,9,9,9,6,7,7,6],"p4":[27,27,27,28,28,28,28,29,29,26,26,27,29]},"other_cards":[17,21,29,16,4,4,36,25,37,19,24,3,36,14,12,2,23,12,18,22,5,9,35,36,2,17,17,35,23,6,19,25,2,4,23,2,19,5,24,24,22,6,37,15,22,13,25,15,23,13,15,26,37,35,19,35,5,5,17,37,24,26,12,36,22,25,4]}]]
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

     -- 翻转以下
     Array.Reverse(newCards)
   
    return newCards
end

return slot
