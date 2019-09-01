-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_check_is_can_do_qianggang(stPlayer, msg)
    LOG_DEBUG("Run LogicStep check_is_can_do_qianggang msg:%s", vardump(msg))
    local nCard = msg._para.card

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
    if bCanWin then
        stWinCard = nCard
        if GGameCfg.RoomSetting.nGameStyle == GAME_STYLE_FUZHOU then
            --福州过滤掉闲金
            nFanNum = LibGameLogicFuzhou:GetFanCount_Gun(stPlayer:GetChairID(), stWinCard)

        --泉州麻将抢杠算自摸
        elseif GGameCfg.RoomSetting.nGameStyle == GAME_STYLE_QUANZHOU then
            nFanNum = LibGameLogicQuanZhou:GetFanCount(stPlayer:GetChairID(), stWinCard)
        end
    end
    LOG_DEBUG("check_is_can_do_qianggang2222...bCanWin:%s, nWinCard:%d, nFanNum:%d", tostring(bCanWin), stWinCard, nFanNum)
    if nFanNum <= 0 then
        bCanWin = false
    end
    stPlayerBlockState:SetCanWin(bCanWin , stWinCard, nFanNum)
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