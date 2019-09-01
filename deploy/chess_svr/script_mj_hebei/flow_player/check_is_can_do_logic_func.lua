-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_check_is_can_do_logic_func(stPlayer, msg)
    LOG_DEBUG("Run LogicStep check_is_can_do_logic_func msg:%s", vardump(msg))
    local nCard = msg._para.card
    local nTurn = msg._para.playChair
    local nChair = stPlayer:GetChairID()

    if LibConfirmMiss:GetPlayerMissCard(nChair) == GetCardType(nCard) then
        return "no"
    end

    -- 别人打出的牌 检查自己能不能 胡 杠 碰 吃 
    -- 郑州麻将暂不支持放炮胡，这个判断流程有问题；先检查是否可以胡（支持放炮胡的前提下），然后杠、碰、吃
    local stPlayerCardGroup = stPlayer:GetPlayerCardGroup()
    local arrPlayerCards = stPlayerCardGroup:ToArray()
    local arrPlayerCardstEMP = stPlayerCardGroup:ToArray()
    local stPlayerBlockState = LibGameLogic:GetPlayerBlockState(nChair)
    stPlayerBlockState:Clear()

    -- 检查是否可以 赢
    if GGameCfg.GameSetting.bSupportGunWin then
        if LibLaiZi:IsLaiZi(nCard) then
            nCard = nCard + 1000
        end
        arrPlayerCardstEMP[#arrPlayerCardstEMP+1] = nCard
        local bCanWin = LibRuleWin:CanWin(arrPlayerCardstEMP)
        local stWinCard = 0
        if bCanWin then
            stWinCard = nCard
        end
        -- LOG_DEBUG("111111logic_check_is_can_do_logic_func...uid:%d, p%d, bCanWin:%s,stWinCard:%d", stPlayer:GetUin(), nChair, tostring(bCanWin), stWinCard)
        
        if stPlayerBlockState:IsGuoShouHu(nCard) then
            bCanWin, stWinCard = false, 0
        end
        -- LOG_DEBUG("222222logic_check_is_can_do_logic_func...uid:%d, p%d, bCanWin:%s,stWinCard:%d", stPlayer:GetUin(), nChair, tostring(bCanWin), stWinCard)
        --廊坊混吊只能自摸
        if bCanWin and GGameCfg.RoomSetting.nGameStyle == GAME_STYLE_LANGFANG then
            local stFindFanTypes = { [44] = 44, }
            local bFind = LibGameLogicLangFang:ChectFanCount(nChair, nCard, stFindFanTypes)
            if bFind then
                 bCanWin, stWinCard = false, 0
            end
        end

        stPlayerBlockState:SetCanWin(bCanWin, stWinCard)
    end

    -- 检查是否可以杠 只有一种情况 就是自己手上有三张牌 才可以杠
    if LibRuleQuadruplet:IsSupportQuadruplet() then
        local bCanQuadruplet = LibRuleQuadruplet:CanQuadrupletCard(arrPlayerCards, nCard)
        local stCardQuadruplet = {}
        if bCanQuadruplet == true then
            table.insert(stCardQuadruplet, nCard)
        end
        stPlayerBlockState:SetQuadruplet(bCanQuadruplet, stCardQuadruplet, ACTION_QUADRUPLET_CONCEALED)
    end
    
    -- 检查是否可以碰, 不判断是否赢  石家庄检查过手碰 廊坊不检查
    if LibRuleTriplet:IsSupportTriplet() and not stPlayerBlockState:IsGuoShouPeng(nCard) then
        local bCanTriplet = LibRuleTriplet:CanTriplet(arrPlayerCards, nCard)
        if bCanTriplet then
            --过滤吃碰后出不了牌卡死问题
            if not GGameCfg.GameSetting.bSupportPlayLaizi then
                local stDelOne = {nCard, nCard}
                local stDelAll = LibLaiZi:GetLaiZi()
                bCanTriplet = stPlayer:CanPlayCardAfterBlockOp(stDelOne, stDelAll)
            end
        end
        stPlayerBlockState:SetTriplet(bCanTriplet, nCard)
    end

    -- 检查是否可以吃
    if stPlayer:IsWin() == false and LibTurnOrder:GetNextTurn(nTurn) == nChair and LibRuleCollect:IsSupportCollect() then
        local bCanCollect = LibRuleCollect:CanCollect(arrPlayerCards, nCard)
        local stCollectGroup = {}
        if bCanCollect == true then
            stCollectGroup = LibRuleCollect:GetCollectGroup(arrPlayerCards,nCard)
            --过滤吃碰后出不了牌卡死问题
            local stDelOne = {}
            local stDelAll = {}
            if not GGameCfg.GameSetting.bSupportPlayCollect then
                --只需一组就行
                stDelOne = stCollectGroup[1] or {}
                table.insert(stDelAll, nCard)
            end
            if not GGameCfg.GameSetting.bSupportPlayLaizi then
                local t = LibLaiZi:GetLaiZi()
                for _, v in pairs(t) do
                    table.insert(stDelAll, v)
                end
            end
            bCanCollect = stPlayer:CanPlayCardAfterBlockOp(stDelOne, stDelAll)
        end
        stPlayerBlockState:SetCollect(bCanCollect, stCollectGroup)
    end

    if stPlayerBlockState:IsBlocked() then
        return "yes"
    end
    
    return "no"
end


return logic_check_is_can_do_logic_func
