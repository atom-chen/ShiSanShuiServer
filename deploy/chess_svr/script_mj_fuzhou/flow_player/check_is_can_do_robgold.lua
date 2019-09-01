-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_check_is_can_do_robgold(stPlayer, msg)
    LOG_DEBUG("Run LogicStep check_is_can_do_robgold")
    --检查是否可以胡
    --没有三金倒牌型
    --没有金雀优先级
    local ntime =os.time()
    LOG_DEBUG("check_is_can_do_robgold..start time.%d", ntime)
    local nChairId = stPlayer:GetChairID()
    local nGoldCard = LibGoldCard:GetOpenGoldCard()


    local stPlayerCardGroup = stPlayer:GetPlayerCardGroup()
    local arrPlayerCards = stPlayerCardGroup:ToArray()
    local stPlayerBlockState = LibGameLogic:GetPlayerBlockState(nChairId)
    stPlayerBlockState:Clear()

    LOG_DEBUG("check_is_can_do_robgold...before, arrPlayerCards:%s", vardump(arrPlayerCards))
    -- 检查是否可以 赢
    arrPlayerCards[#arrPlayerCards+1] = nGoldCard
    LOG_DEBUG("check_is_can_do_robgold...after, arrPlayerCards:%s", vardump(arrPlayerCards))
    local bCanWin = LibRuleWin:CanWin(arrPlayerCards)
    local nFanNum = 0
    --没有三金倒这个胡牌牌型
    if bCanWin then
        CSMessage.NotifyRobGoldToAll()
        --{ { byFanType=0, byFanNumber=0, byCount=0 },....}
        nFanNum = LibGameLogicFuzhou:GetFanCount_RobGold(nChairId, nGoldCard)
        if nFanNum > 0 then
            local stWinCard = nGoldCard
            stPlayerBlockState:SetCanWin(bCanWin, stWinCard, nFanNum,0)
            stPlayerBlockState:SetWinFalg(1)
            --通知抢金开始
            LOG_DEBUG("logic_check_is_can_do_robgold...NotifyRobGoldToAll:%s", tostring(GRoundInfo:GetNotifyRobGold()))
            -- if not GRoundInfo:GetNotifyRobGold() then
                -- CSMessage.NotifyRobGoldToAll()
                GRoundInfo:SetNotifyRobGold(true)
            -- end
        end
    end
    LOG_DEBUG("logic_check_is_can_do_robgold...p%d, bCanWin:%s, nFanNum:%d, IsBlocked:%s, stReuslt:%s", nChairId, tostring(bCanWin), nFanNum, tostring(stPlayerBlockState:IsBlocked()), vardump(stPlayerBlockState:GetReuslt()))

    ntime =os.time()
    LOG_DEBUG("check_is_can_do_robgold..end time.%d", ntime)
    if stPlayerBlockState:IsBlocked() then
        return "yes"
    end
    
    return "no"
end


return logic_check_is_can_do_robgold