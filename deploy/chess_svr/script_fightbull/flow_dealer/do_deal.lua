-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
require "common.socket"

local function logic_do_deal(dealer, msg)
    LOG_DEBUG("Run LogicStep do_deal...PLAYER_NUMBER:%d", PLAYER_NUMBER)
    local t1 = math.floor(socket.gettime()*1000)
    local stGameState = GGameState
    local stRoundInfo = GRoundInfo
    local stDealerCardGroup = dealer:GetDealerCardGroup()
    -- 洗牌
    stDealerCardGroup:PrepareDeal()

    -- 发牌
    local function do_deal()
        for i=1, PLAYER_NUMBER do
            local stPlayer = stGameState:GetPlayerByChair(i)
            if stPlayer then
                local stPlayerCardGroup = stPlayer:GetPlayerCardGroup()
                local cards = {}
                for j=1, MAX_HAND_CARD_NUM do
                    local nCard = stDealerCardGroup:GetOneCard()
                    table.insert(cards, nCard)
                end
                stPlayerCardGroup:AddCardGroup(cards)
            end
        end
    end

    --测试版
    local function test_deal()
        -- local tempCards = {
        --     { 0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x0A,0x0B,0x0C,0x0D,0x0E, },   --方块 2 - A
        --     { 0x12,0x13,0x14,0x15,0x16,0x17,0x18,0x19,0x1A,0x1B,0x1C,0x1D,0x1E, },   --梅花 2 - A
        --     { 0x22,0x23,0x24,0x25,0x26,0x27,0x28,0x29,0x2A,0x2B,0x2C,0x2D,0x2E, },   --红桃 2 - A
        --     { 0x32,0x33,0x34,0x35,0x36,0x37,0x38,0x39,0x3A,0x3B,0x3C,0x3D,0x3E, },    --黑桃 2 - A
        -- }

        local tempCards = {
        }
        for i=1, PLAYER_NUMBER do
            local stPlayer = stGameState:GetPlayerByChair(i)
            if stPlayer then
                local stPlayerCardGroup = stPlayer:GetPlayerCardGroup()
                local cards = tempCards[i]
                LOG_DEBUG("test_deal...p%d, cards:%s", i, TableToString(cards))
                if cards and #cards >= MAX_HAND_CARD_NUM then
                    for j=1, MAX_HAND_CARD_NUM do
                        local nCard = cards[j]
                        stDealerCardGroup:DelOneCard(nCard)
                    end
                    stPlayerCardGroup:AddCardGroup(cards)
                else
                    local cards = {}
                    for j=1, MAX_HAND_CARD_NUM do
                        local nCard = stDealerCardGroup:GetOneCard()
                        table.insert(cards, nCard)
                    end
                    stPlayerCardGroup:AddCardGroup(cards)
                end
            end
        end
    end
    -- --测试版
    -- test_deal()

    -- --正常版本
    do_deal()

    -- 通知玩家发牌了
    local nDealerCardLeft = stDealerCardGroup:GetCurrentLength()
    for i=1,PLAYER_NUMBER do
        local stPlayer = stGameState:GetPlayerByChair(i)
        if stPlayer then
            CSMessage.NotifyPlayerDeal(stPlayer, nDealerCardLeft)
        end
    end
    
    local t2 = math.floor(socket.gettime()*1000)

    -- 通知玩家发牌了
    LOG_DEBUG("==============subtime:%d, nCurrJu:%d, nNeedRecommend:%d", (t2-t1), GGameCfg.nCurrJu, GGameCfg.nNeedRecommend)

    --进入下一阶段
    dealer:ToNextStage()

    return STEP_SUCCEED
end


return logic_do_deal
