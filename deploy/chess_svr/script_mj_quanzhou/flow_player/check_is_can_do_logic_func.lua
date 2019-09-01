-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_check_is_can_do_logic_func(stPlayer, msg)
    LOG_DEBUG("Run LogicStep check_is_can_do_logic_func msg:%s", vardump(msg))
    local nCard = msg._para.card
    local nTurn = msg._para.playChair

    -- 金牌 不能:胡 杠 碰 吃 
    if LibGoldCard:IsGoldCard(nCard) then
        LOG_DEBUG("check_is_can_do_logic_func...gold card no(hu,peng,gang,chi)..nCard:%d, stGoldCards:%s", nCard, vardump(LibGoldCard:GetGoldCards()))
        return "no"
    end

    -- 别人打出的牌  检查自己能不能 胡 杠 碰 吃 
    local nChairId = stPlayer:GetChairID()
    local stPlayerCardGroup = stPlayer:GetPlayerCardGroup()
    local arrPlayerCards = stPlayerCardGroup:ToArray()
    local arrPlayerCardstEMP = stPlayerCardGroup:ToArray()
    local stPlayerBlockState = LibGameLogic:GetPlayerBlockState(nChairId)
    stPlayerBlockState:Clear()

    -- 检查是否可以 赢
    local function checkWin_fuzhou()
        local nOnlyHuType = stPlayer:GetOnlyHuType()
        -- 出过金牌  只能自摸
        -- 闲金 三金倒只能自摸(三金倒C++没有做处理  所以这只须过滤掉闲金)
        if GGameCfg.GameSetting.bSupportGunWin and nOnlyHuType ~= GOLD_HU_SELFDRAW then
            arrPlayerCardstEMP[#arrPlayerCardstEMP+1] = nCard
            local bCanWin = LibRuleWin:CanWin(arrPlayerCardstEMP)
            LOG_DEBUG("checkWin_fuzhou1111...bCanWin:%s", tostring(bCanWin))
            local nWinCard = 0
            local nFanNum = 0
            if bCanWin then
                nWinCard = nCard
                -- 过滤掉闲金
                local nGameStyle = GGameCfg.RoomSetting.nGameStyle

                if nGameStyle == GAME_STYLE_FUZHOU then
                    nFanNum = LibGameLogicFuzhou:GetFanCount_Gun(nChairId, nWinCard)
                        
                elseif nGameStyle == GAME_STYLE_QUANZHOU then
                    nFanNum =  LibGameLogicQuanZhou:GetFanCount_Gun(nChairId, nWinCard)
                end
            end
            if nFanNum <= 0 then
                bCanWin = false
            end
            LOG_DEBUG("checkWin_fuzhou2222...bCanWin:%s, nWinCard:%d, nFanNum:%d", tostring(bCanWin), nWinCard, nFanNum)
            stPlayerBlockState:SetCanWin(bCanWin, nWinCard, nFanNum)
            if bCanWin then
                stPlayerBlockState:SetWinFalg(0)
            end
        end
    end
   
    local function checkWin_quanzhou()
        local nLaiZiCount = stPlayer:GetGoldCardNums()
        local nOnlyHuType = stPlayer:GetOnlyHuType() 
        if GGameCfg.GameSetting.bNoSupportPingHuByOneGold == true and nLaiZiCount>=1 then
            nOnlyHuType =GOLD_HU_SELFDRAW
        end
        if GGameCfg.GameSetting.bMustYouJinByTwoGold == true and nLaiZiCount>=2 then
            nOnlyHuType =GOLD_HU_SELFDRAW
        end
        if GGameCfg.GameSetting.bSupportGunWin and nOnlyHuType ~= GOLD_HU_SELFDRAW  then
            arrPlayerCardstEMP[#arrPlayerCardstEMP+1] = nCard
            local bCanWin = LibRuleWin:CanWin(arrPlayerCardstEMP)
            LOG_DEBUG("checkWin_quanzhou1111...bCanWin:%s", tostring(bCanWin))
            local nWinCard = 0
            local nFanNum = 0
            local bYouJin, bShuangYou, bSanYou = false, false, false
            if bCanWin then
                nWinCard = nCard
                -- 过滤掉闲金
                nFanNum, bYouJin, bShuangYou, bSanYou = LibGameLogicQuanZhou:GetFanCount_Gun(nChairId, nWinCard)
            end
            if bYouJin then
                nFanNum = nFanNum - 4
            end
            if bShuangYou then
                nFanNum = nFanNum - 8
            end
            if bSanYou then
                nFanNum = nFanNum - 16
            end
            if nFanNum <= 0 then
                bCanWin = false
            end
            LOG_DEBUG("checkWin_quanzhou1111...bCanWin:%s, nWinCard:%d, nFanNum:%d", tostring(bCanWin), nWinCard, nFanNum)
            stPlayerBlockState:SetCanWin(bCanWin, nWinCard, nFanNum)
            if bCanWin then
                stPlayerBlockState:SetWinFalg(0)
            end
        end
    end
    
    local function checkWin_xiamen()
    end
    
    local function checkWin_zhangzhou()
    end
    
    -- 检查是否可以杠
    local function checkQuadruplet()
        -- 只有一种情况 就是自己手上有三张牌 才可以杠
        if LibRuleQuadruplet:IsSupportQuadruplet() then
            local bCanQuadruplet = LibRuleQuadruplet:CanQuadrupletCard(arrPlayerCards, nCard)
            local stCardQuadruplet = {}
            if bCanQuadruplet then
                table.insert(stCardQuadruplet, nCard)
            end
            LOG_DEBUG("checkTriplet...bCanQuadruplet:%s, stCardQuadruplet:%s", tostring(bCanQuadruplet), vardump(stCardQuadruplet))
            stPlayerBlockState:SetQuadruplet(bCanQuadruplet, stCardQuadruplet, ACTION_QUADRUPLET_CONCEALED)
        end
    end
    -- 检查是否可以碰
    local function checkTriplet( )
        if LibRuleTriplet:IsSupportTriplet() then
            local bCanTriplet = LibRuleTriplet:CanTriplet(arrPlayerCards, nCard)
            LOG_DEBUG("checkTriplet1111...bCanTriplet:%s, nCard:%d", tostring(bCanTriplet), nCard)
            if bCanTriplet then
                --过滤吃碰后出不了牌卡死问题
                if not GGameCfg.GameSetting.bSupportPlayLaizi then
                    local stDelOne = {nCard, nCard}
                    local stDelAll = LibGoldCard:GetGoldCards()
                    bCanTriplet = stPlayer:CanPlayCardAfterBlockOp(stDelOne, stDelAll)
                end
            end
            LOG_DEBUG("checkTriplet2222...bCanTriplet:%s, nCard:%d", tostring(bCanTriplet), nCard)
            stPlayerBlockState:SetTriplet(bCanTriplet, nCard)
        end
    end
    -- 检查是否可以吃
    local function checkCollect()
        if not stPlayer:IsWin()
            and LibTurnOrder:GetNextTurn(nTurn) == nChairId    --是下一个玩家
            and LibRuleCollect:IsSupportCollect() then
            local bCanCollect = LibRuleCollect:CanCollect(arrPlayerCards, nCard)
            -- 吃牌列表 {{牌1，牌2},{}...}
            local stCollectGroup = {}
            if bCanCollect then
                stCollectGroup = LibRuleCollect:GetCollectGroup(arrPlayerCards, nCard)
                if #stCollectGroup == 0 then
                    bCanCollect = false
                else
                    --过滤吃碰后出不了牌卡死问题
                    local stDelOne = {}
                    local stDelAll = {}
                    if not GGameCfg.GameSetting.bSupportPlayCollect then
                        --只需一组就行
                        stDelOne = stCollectGroup[1] or {}
                        table.insert(stDelAll, nCard)
                    end
                    if not GGameCfg.GameSetting.bSupportPlayLaizi then
                        local t = LibGoldCard:GetGoldCards()
                        for _, v in pairs(t) do
                            table.insert(stDelAll, v)
                        end
                    end
                    bCanCollect = stPlayer:CanPlayCardAfterBlockOp(stDelOne, stDelAll)
                end
            end
            LOG_DEBUG("checkCollect...stCollectGroup:%s", vardump(stCollectGroup))
            stPlayerBlockState:SetCollect(bCanCollect, stCollectGroup)
        end
    end

    -- 胡
    local nGameStyle = GGameCfg.RoomSetting.nGameStyle
    if nGameStyle == GAME_STYLE_FUZHOU then
        checkWin_fuzhou()
    elseif nGameStyle == GAME_STYLE_QUANZHOU then
        checkWin_quanzhou()
    elseif nGameStyle == GAME_STYLE_XIAMEN then
        checkWin_xiamen()
    elseif nGameStyle == GAME_STYLE_ZHANGZHOU then
        checkWin_zhangzhou()
    else
        LOG_ERROR("check_is_can_do_logic_func, no this game style. nGameStyle:%d", nGameStyle)
    end
    -- 杠
    checkQuadruplet()
    -- 碰
    checkTriplet()
    -- 吃
    checkCollect()

    -- check block
    if stPlayerBlockState:IsBlocked() then
        return "yes"
    end
    
    return "no"
end


return logic_check_is_can_do_logic_func
