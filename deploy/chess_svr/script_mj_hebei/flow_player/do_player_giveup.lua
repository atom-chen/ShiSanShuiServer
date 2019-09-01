-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_do_player_giveup(stPlayer, msg)
    LOG_DEBUG("Run LogicStep do_player_giveup")
    local nChair = stPlayer:GetChairID()
    local stPlayerBlockState = LibGameLogic:GetPlayerBlockState(nChair)
    
    -- 记录漏胡
    if stPlayerBlockState and stPlayerBlockState:IsCanWin() then
        local nCard = stPlayerBlockState:GetCurrWinCard()
        stPlayerBlockState:SetGuoShouHu(nCard)
    end
    -- 记录过手碰
    if stPlayerBlockState and stPlayerBlockState:GetTriplet() == ACTION_TRIPLET and GGameCfg.RoomSetting.nGameStyle == GAME_STYLE_SHIJIAZHUANG then
        local nCard = stPlayerBlockState:GetTripletCard()
        stPlayerBlockState:SetGuoShouPeng(nCard)
    end
    stPlayerBlockState:Clear()

    --抢杠胡 放弃
    if stPlayer:GetPlayerIsQiangGangHu() ==true then
        stPlayer:SetPlayerQiangGangStatus(QIANGGANG_STATUS_GIVEUP)
    end

    LOG_DEBUG("--do_player_giveup----nchair=====:%d !!!!!!!!!!!!!\n", nChair)
    FlowFramework.DelTimer(nChair, 0)
    return STEP_SUCCEED
end


return logic_do_player_giveup
