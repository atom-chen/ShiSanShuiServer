-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_check_is_can_do_qianggang(stPlayer, msg)
    LOG_DEBUG("Run LogicStep check_is_can_do_qianggang msg:%s", vardump(msg))
    local nCard = msg._para.card
    local nTurn = msg._para.playChair

    -- 别人打出的牌  检查自己能不能 胡
    local stPlayerCardGroup = stPlayer:GetPlayerCardGroup()
    local arrPlayerCards = stPlayerCardGroup:ToArray()
    local stPlayerBlockState = LibGameLogic:GetPlayerBlockState(stPlayer:GetChairID())
    stPlayerBlockState:Clear()

    -- 检查是否可以 赢
    arrPlayerCards[#arrPlayerCards+1] = nCard
    --闲金 三金倒只能自摸(三金倒C++没有做处理  所以这只须过滤掉闲金)
    local bCanWin = LibRuleWin:CanWin(arrPlayerCards)
    LOG_DEBUG("check_is_can_do_qianggang1111...bCanWin:%s", tostring(bCanWin))
    local stWinCard = 0
    local nFanNum = 0

    local bDragon =false
    local bBird =false
    local bLong =false
    local bHalfQYS =false
    local bQYS =false
    local bWuHuaWuGang =false
    local bxianjin =false
    local nBigType =0
    if bCanWin then
        stWinCard = nCard
        --过滤掉闲金
        nFanNum,bDragon,bBird,bLong,bHalfQYS,bQYS,bxianjin,bWuHuaWuGang = LibGameLogicFuzhou:GetFanCount_Gun(stPlayer:GetChairID(), stWinCard)

        if bxianjin then
            nFanNum =nFanNum -1
        end
    end
    LOG_DEBUG("check_is_can_do_qianggang2222...bCanWin:%s, nWinCard:%d, nFanNum:%d", tostring(bCanWin), stWinCard, nFanNum)
    if nFanNum <= 0 then
        bCanWin = false
    end
        --胡大牌的优先级
    if  bWuHuaWuGang then
        nBigType = ACTION_NOHUAGANG
    end
    if  bBird then
        nBigType = ACTION_BIRD
    end
    if  bHalfQYS then
        nBigType = ACTION_HALFQYS
    end
    if  bLong then
        nBigType = ACTION_LONG
    end
    if  bQYS then
        nBigType = ACTION_QYS
    end
    stPlayerBlockState:SetCanWin(bCanWin , stWinCard, nFanNum,nBigType)
    if bCanWin then
        stPlayerBlockState:SetWinFalg(0)
    end

    --设置抢杠玩家以及设置抢杠开始
    local stRoundInfo = GRoundInfo
    local nChair = stPlayer:GetChairID()
    if stPlayerBlockState:IsBlocked() then
        stPlayer:SetPlayerIsQiangGangHu(true)
        stPlayer:SetPlayerQiangGangStatus(QIANGGANG_STATUS_START)
        stRoundInfo:SetPengGangHuPlayer(nChair)
        return "yes"
    end
    
    return "no"
end


return logic_check_is_can_do_qianggang