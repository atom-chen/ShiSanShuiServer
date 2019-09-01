-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_do_opengold(dealer, msg)
    LOG_DEBUG("Run LogicStep do_opengold")
    local stDealerCardGroup = dealer:GetDealerCardGroup()
    local nGameStyle = GGameCfg.RoomSetting.nGameStyle
    local dice =  {math.random(1, 6), math.random(1, 6)} 

    local function fuzhou()
        -- 牌尾摸一张
        local bFindGold = false
        while not bFindGold do
            local bGoldCard = false
            local nCard = stDealerCardGroup:GetOneCard(true)
            LOG_DEBUG("logic_do_opengold, fuzhou...nCard: %d", nCard)
            -- 判断是否是花牌
            if LibFlowerCheck:IsFlowerCard(nCard) then
                -- 花牌 则给庄家
                local nBanker = GRoundInfo:GetBanker()
                local stPlayer = GGameState:GetPlayerByChair(nBanker)
                LOG_DEBUG("logic_do_opengold, fuzhou...nBanker: %d, stPlayer==%s", nBanker, type(stPlayer))
                if stPlayer then
                    local nDealerCardLeft = stDealerCardGroup:GetCurrentLength()
                    local stFlowerCards = {}
                    table.insert(stFlowerCards, nCard)
                    -- 花牌给庄家
                    stPlayer:AddFlowerCard(nCard)

                    -- CSMessage.NotifyChangeFlower(stPlayer, stFlowerCards, stNewCards, nDealerCardLeft)
                    -- CSMessage.NotifyChangeFlowerToOther(stPlayer, stFlowerCards, nDealerCardLeft)  
                end
                bFindGold = false
            else
                bGoldCard = true
                bFindGold = true
                -- 翻开的金牌
                LibGoldCard:SetOpenGoldCard(nCard)
                -- 添加到金牌列表
                LibGoldCard:AddGoldCards(nCard)
                -- 位置在牌尾
                stDealerCardGroup:SetGoldCardPos(nCard, stDealerCardGroup:GetCurrentLength())
            end
            -- 通知开的牌给所有玩家
            CSMessage.NotifyOpenGoldToAll(nCard, bGoldCard, dice)
        end
    end

    local function quanzhou()
        local nIndex = 1
        local nCard = stDealerCardGroup:GetCardAt(nIndex)
        
        while LibFlowerCheck:IsFlowerCard(nCard) do
            nIndex = nIndex + 1
            nCard = stDealerCardGroup:GetCardAt(nIndex)
        end
        LOG_DEBUG("quanzhou OpenGold nIndex = %d, nCard = %d", nIndex, nCard)
        
        local nCardGold = stDealerCardGroup:GetCardByIndex(nIndex)
        if nCardGold == nCard then
            LibGoldCard:SetOpenGoldCard(nCard)
            LibGoldCard:AddGoldCards(nCard)
            CSMessage.NotifyOpenGoldToAll(nCard, true, dice)
        else
            LOG_DEBUG("LUA ERR quanzhou OpenGold")
        end
    end

    local function xiamen()
    end

    local function zhangzhou()
    end

    if nGameStyle == GAME_STYLE_FUZHOU then
        fuzhou()
    elseif nGameStyle == GAME_STYLE_QUANZHOU then
        -- 如果开出来的是花牌，顺延开金直到开出不是花牌的那张牌为止，
        -- 花牌按照顺序留着直到下一个补花或是开缸的人补走
        quanzhou()
    elseif nGameStyle == GAME_STYLE_XIAMEN then
        -- 庄家扔出2个色子，根据点数从牌堆最后一张牌开始数，最后落在哪张上翻开即为金
        -- 一摞算2张牌。金牌如果在该摞的下方，展示上面把上方牌做透明处理
        -- 白板是用来代替金牌的牌。即，如果金牌是一万，则白板为一万，
        -- 可以和二三万组成顺子。也可以和二万一起吃三万
        xiamen()
    elseif nGameStyle == GAME_STYLE_ZHANGZHOU then
        -- 庄家扔出2个色子，根据点数从牌堆最后一张牌开始数，最后落在哪张上翻开即为金
        -- 一摞算2张牌。金牌如果在该摞的下方，展示上面把上方牌做透明处理
        -- 当花为金时，春夏秋冬视为一套，梅兰竹菊视为一套。
        -- 例：翻到“春”为金，此时夏秋冬就也是金牌
        zhangzhou()
    end

    dealer:ToNextStage()

    return STEP_SUCCEED  
end

return logic_do_opengold
