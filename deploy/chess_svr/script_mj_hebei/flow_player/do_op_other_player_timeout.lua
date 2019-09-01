-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_do_op_other_player_timeout(stPlayer, event)
    LOG_DEBUG("Run LogicStep do_op_other_player_timeout")
    stPlayer:AddTimeoutTimes()

    --玩家超时没反应时，清除该玩家block状态
    local nChair = stPlayer:GetChairID()
    local stPlayerBlockState = LibGameLogic:GetPlayerBlockState(nChair)

    -- 记录漏胡
    if stPlayerBlockState and stPlayerBlockState:IsCanWin() then
        local nCard = stPlayerBlockState:GetCurrWinCard()
        stPlayerBlockState:SetGuoShouHu(nCard)
    end
    -- 记录过手碰
    if stPlayerBlockState:GetTriplet() == ACTION_TRIPLET and GGameCfg.RoomSetting.nGameStyle == GAME_STYLE_SHIJIAZHUANG then
        local nCard = stPlayerBlockState:GetTripletCard()
        stPlayerBlockState:SetGuoShouPeng(nCard)
    end

    stPlayerBlockState:Clear()
    FlowFramework.DelTimer(stPlayer:GetChairID(), 0)
    --[[
    if stPlayer:IsWin() then
        local stPlayerBlockState = LibGameLogic:GetPlayerBlockState(stPlayer:GetChairID())
        local stPlayerCards = stPlayer:GetPlayerCardGroup():ToArray()
        -- 可赢则赢
        if stPlayerBlockState:IsCanWin() then
            local nWinCard = stPlayerBlockState:GetCurrWinCard()
            LOG_DEBUG("do ACTION_WIN")
             stPlayerBlockState:SetBlockFlag(ACTION_WIN, nWinCard)
             return STEP_SUCCEED
        end
        -- 有杠则杠
        if stPlayerBlockState:IsCanQuadruplet() then
            local stCards = stPlayerBlockState:GetQuadrupletCard()
            LOG_DEBUG("do ACTION_QUADRUPLET")
            stPlayerBlockState:SetBlockFlag(ACTION_QUADRUPLET, stCards[1])
            return STEP_SUCCEED
        end
    end
    --]]
    return STEP_SUCCEED
end


return logic_do_op_other_player_timeout
