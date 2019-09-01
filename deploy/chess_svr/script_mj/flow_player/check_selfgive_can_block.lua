-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_check_selfgive_can_block(stPlayer, msg)
    local nChair = stPlayer:GetChairID()
    local stPlayerCardGroup = stPlayer:GetPlayerCardGroup()
    local arrPlayerCards = stPlayerCardGroup:ToArray()
    local cardLastDraw = stPlayerCardGroup:GetLastDraw() 
    --LOG_DEBUG("Run LogicStep check_selfgive_can_block: cards:%s", vardump(arrPlayerCards))

    -- 自己摸牌情况下，只检查 杠 听 胡逻辑
    local stPlayerBlockState = LibGameLogic:GetPlayerBlockState(nChair)
    stPlayerBlockState:Clear()
     -- 检查是否可以杠
    if LibRuleQuadruplet:IsSupportQuadruplet() then
        local bCanQuadruplet = LibRuleQuadruplet:IsQuadrupletGroup(arrPlayerCards)
        local stCardQuadruplet = {}
        if bCanQuadruplet == true then
            stCardQuadruplet = LibRuleQuadruplet:GetQuadrupletCard(arrPlayerCards)
        end
        --检查碰牌是否可以加杠（只要是玩家自己回合，随时可以补杠）
        if LibRuleQuadruplet:IsSupportTriplet2Quadruplet() then
            local nCanPengGang = false
            local nGangIndex = 0
            for i=1,#arrPlayerCards do
               if stPlayer:GetPlayerCardSet():IsCardCan2Quadruplet(arrPlayerCards[i]) then
                    nCanPengGang = true
                    nGangIndex = i
                    LOG_DEBUG("===========logic_check_selfgive_can_block arrPlayerCards ======%d ",arrPlayerCards[i])
                    break
                end
            end
            if nCanPengGang == true then
                LOG_DEBUG("===========logic_check_selfgive_can_block arrPlayerCards[nGangIndex] ======%d ",arrPlayerCards[nGangIndex])
                stCardQuadruplet[#stCardQuadruplet + 1] = arrPlayerCards[nGangIndex]
                bCanQuadruplet = true
            end
  
        end
        if #stCardQuadruplet > 0 then 
            stPlayerBlockState:SetQuadruplet(bCanQuadruplet, stCardQuadruplet, ACTION_QUADRUPLET_CONCEALED)      
        end 
    end
    -- 检查是否可以听
    if stPlayer:IsWin() == false and LibRuleTing:IsSupportTing() and stPlayer:IsTing() == false then
        local bCanTing = LibRuleTing:CanTing(stPlayer, arrPlayerCards)
        local stCardTingGroup = {}
        if bCanTing == true then
            stCardTingGroup = LibRuleTing:GetTingGroup()
        end
        stPlayerBlockState:SetTing(bCanTing, stCardTingGroup)
   
    end
    -- 检查是否可以 赢
    local bCanWin = LibRuleWin:CanWin(arrPlayerCards)
    local nWinCards = 0
    if bCanWin then
        LOG_DEBUG("CANWIN yes %s", vardump(arrPlayerCards))
        nWinCard = cardLastDraw
    else
        LOG_DEBUG("CANWIN no %s", vardump(arrPlayerCards))
    end
    stPlayerBlockState:SetCanWin(bCanWin, nWinCard)

    
    if stPlayerBlockState:IsBlocked() == true then
        return "yes"
    end
    
    return "no"
end


return logic_check_selfgive_can_block
