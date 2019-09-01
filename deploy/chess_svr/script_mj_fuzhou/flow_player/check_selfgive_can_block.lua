-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_check_selfgive_can_block(stPlayer, msg)
    local stPlayerCardGroup = stPlayer:GetPlayerCardGroup()
    local arrPlayerCards = stPlayerCardGroup:ToArray()
    local cardLastDraw = stPlayerCardGroup:GetLastDraw() 


    -- 自己摸牌情况下，只检查 杠 听 胡逻辑
    local stPlayerBlockState = LibGameLogic:GetPlayerBlockState(stPlayer:GetChairID())
    stPlayerBlockState:Clear()

    -- 检查是否可以杠
    local function checkQuadruplet()
        if LibRuleQuadruplet:IsSupportQuadruplet() then
            local bCanQuadruplet = LibRuleQuadruplet:IsQuadrupletGroup(arrPlayerCards)
            local stCardQuadruplet = {}
            if bCanQuadruplet == true then
                stCardQuadruplet = LibRuleQuadruplet:GetQuadrupletCard(arrPlayerCards)
            end

            --检查碰牌是否可以加杠（只要是玩家自己回合，随时可以补杠）
            if LibRuleQuadruplet:IsSupportTriplet2Quadruplet() then

                local nCanPengGang =false
                local nGangIndex =0

                for i=1,#arrPlayerCards do
            
                   if stPlayer:GetPlayerCardSet():IsCardCan2Quadruplet(arrPlayerCards[i]) then
                        nCanPengGang =true
                        nGangIndex =i
                        LOG_DEBUG("===========logic_check_selfgive_can_block arrPlayerCards ======%d ",arrPlayerCards[i])
                        break;
                    end
                end
                if nCanPengGang==true then
                    LOG_DEBUG("===========logic_check_selfgive_can_block arrPlayerCards[nGangIndex] ======%d ",arrPlayerCards[nGangIndex])
                    stCardQuadruplet[#stCardQuadruplet + 1] = arrPlayerCards[nGangIndex]
                    bCanQuadruplet = true
                end
      
            end
            if #stCardQuadruplet > 0 then 
                stPlayerBlockState:SetQuadruplet(bCanQuadruplet, stCardQuadruplet, ACTION_QUADRUPLET_CONCEALED)      
            end 
        end
    end
    -- 检查是否可以听
   --[[ local function checkTing()
        -- 检查是否可以听
        if stPlayer:IsWin() == false
            -- and stPlayer:IsTing() == false
            and LibRuleTing:IsSupportTing() then
            
            local bCanTing = LibRuleTing:CanTing(stPlayer, arrPlayerCards)
            local stCardTingGroup = {}
            if bCanTing == true then
                stCardTingGroup = LibRuleTing:GetTingGroup()
            end
            LOG_DEBUG("logic_check_selfgive_can_block...checkTing...bCanTing:%s, stCardTingGroup:%s", tostring(bCanTing), vardump(stCardTingGroup))
            stPlayerBlockState:SetTing(bCanTing, stCardTingGroup)
        end
    end
    --]]
    -- 检查是否可以 赢
    local function checkWin_fuzhou()
        -- 检查是否可以 赢
        --1.先判断三金倒 C++没有对这个牌型做处理
        local nWinCard = 0
        local nFanNum = 0
        local nFanNumNormal = 0
        local bCanWin = LibRuleWin:CanWinThreeGold(arrPlayerCards)
        LOG_DEBUG("logic_check_selfgive_can_block...CanWinThreeGold:%s", tostring(bCanWin))
        --2.没三金倒再判断是否有其他胡牌类型
        if not bCanWin then
            bCanWin = LibRuleWin:CanWin(arrPlayerCards)
            if bCanWin then
                nFanNumNormal = LibGameLogicFuzhou:GetFanCount(stPlayer:GetChairID(), cardLastDraw)
            end
            LOG_DEBUG("logic_check_selfgive_can_block...other,CanWin:%s", tostring(bCanWin))
        else
            bCanWin = LibRuleWin:CanWin(arrPlayerCards)
            if bCanWin then
                nFanNumNormal = LibGameLogicFuzhou:GetFanCount(stPlayer:GetChairID(), cardLastDraw)
            end
            bCanWin =true
            nFanNum = 50
        end

        if bCanWin then
            nWinCard = cardLastDraw
            if nFanNum>nFanNumNormal then
                nFanNum = nFanNum
            else
                nFanNum =nFanNumNormal
            end
            stPlayerBlockState:SetWinFalg(0)
        else
            LOG_DEBUG("CANWIN no %s", vardump(arrPlayerCards))
        end
        LOG_DEBUG("logic_check_selfgive_can_block..checkWin_fuzhou...bCanWin:%s, nWinCard:%d, nFanNum:%d", tostring(bCanWin), nWinCard, nFanNum)
        stPlayerBlockState:SetCanWin(bCanWin, nWinCard, nFanNum,0)
    end
    local function checkWin_quanzhou()
    end
    local function checkWin_xiamen()
    end
    local function checkWin_zhangzhou()
    end

    --杠
    checkQuadruplet()
    --听
--    checkTing()
    --胡
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
        LOG_ERROR("logic_check_selfgive_can_block, no this game style. nGameStyle:%d", nGameStyle)
    end

    --check block
    if stPlayerBlockState:IsBlocked() == true then
        return "yes"
    end
    
    return "no"
end


return logic_check_selfgive_can_block
