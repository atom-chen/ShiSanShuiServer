-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_check_is_can_do_qianggang(stPlayer, msg)
    LOG_DEBUG("Run LogicStep check_is_can_do_qianggang msg:%s", vardump(msg))
    local nCard = msg._para.card
    -- local nTurn = msg._para.playChair
    local nChair = stPlayer:GetChairID()

    -- 别人打出的牌  检查自己能不能 胡
    local stPlayerCardGroup = stPlayer:GetPlayerCardGroup()
    local arrPlayerCards = stPlayerCardGroup:ToArray()
    local stPlayerBlockState = LibGameLogic:GetPlayerBlockState(nChair)
    stPlayerBlockState:Clear()

    -- 检查是否可以 赢
    arrPlayerCards[#arrPlayerCards+1] = nCard
    local bCanWin = LibRuleWin:CanWin(arrPlayerCards)
    LOG_DEBUG("check_is_can_do_qianggang1111...bCanWin:%s", tostring(bCanWin))
    
    local stWinCard = 0
    if bCanWin then
        stWinCard = nCard
    end
    LOG_DEBUG("check_is_can_do_qianggang2222...bCanWin:%s, nWinCard:%d", tostring(bCanWin), stWinCard)
    
    stPlayerBlockState:SetCanWin(bCanWin, stWinCard)
    
    --设置抢杠玩家以及设置抢杠开始
    local stRoundInfo = GRoundInfo
    if stPlayerBlockState:IsBlocked() then
        stPlayer:SetPlayerIsQiangGangHu(true)
        stPlayer:SetPlayerQiangGangStatus(QIANGGANG_STATUS_START)
        stRoundInfo:SetPengGangHuPlayer(nChair)
        return "yes"
    end
    
    return "no"
end


return logic_check_is_can_do_qianggang