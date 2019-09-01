local slot = {}
-- 实现 DoDeal 函数
-- 参数1  cards 牌堆中所有的牌
-- 返回值  返回洗好的牌
function slot.DoDeal(cards)
    if type(cards) ~= "table" then
        return {}
    end
    local newCards = {}
    --[[
    -- 庄家 胡
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
    local stPlayers = {stCardsPlayer1, stCardsPlayer2, stCardsPlayer3, stCardsPlayer4}
    for i=1,#stPlayers do
        local stCardsPlayer = stPlayers[i]
         for j=1,#stCardsPlayer do
            newCards[#newCards + 1] = stCardsPlayer[j]
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
    -- 添加剩下的牌型
    for i=1,#tmpCards do
        newCards[#newCards + 1] = tmpCards[i]
    end

     -- 翻转以下
     Array.Reverse(newCards)
   
    return newCards
end

return slot
