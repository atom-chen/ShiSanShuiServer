-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_judge_qianggang_end(dealer, msg)
    LOG_DEBUG("Run LogicStep judge_qianggang_end")
    local stGameState = GGameState
    local stRoundInfo = GRoundInfo

    local thisTurn = stRoundInfo:GetWhoIsNextTurn()

    local IsAllGiveUp = true  -- 是否所有玩放弃抢杠，或者不存在抢杠
    local stPengGangPlayer = stRoundInfo:GetPengGangPlayer()
    local stPengGangHuPlayerList = stRoundInfo:GetPengGangHuPlayer()
    for i=1, #stPengGangHuPlayerList do
        if stPengGangHuPlayerList[i] ~=0 then
            local stPlayerQiangGangHuPlayer = GGameState:GetPlayerByChair(stPengGangHuPlayerList[i])
            local GangStatus = stPlayerQiangGangHuPlayer:GetPlayerQiangGangStatus()
            if  GangStatus == QIANGGANG_STATUS_OK then
                IsAllGiveUp = false
                stPlayerQiangGangHuPlayer:SetPlayerQiangGangStatus(QIANGGANG_STATUS_NONE)
            end
        end
    end
    
    if stPengGangPlayer ~= 0 and IsAllGiveUp == true then
        stRoundInfo:SetWhoIsOnTurn(stPengGangPlayer)
        stRoundInfo:SetIsQiangGang(false)
        local nOldTurn = stRoundInfo:GetPengGangChair()
        
        if GGameCfg.RoomSetting.nGameStyle == GAME_STYLE_SHIJIAZHUANG then
            LibGameLogicShiJiaZhuang:ProcessOPQuadruplet(ACTION_QUADRUPLET_REVEALED, stPengGangPlayer, nOldTurn)
        elseif GGameCfg.RoomSetting.nGameStyle == GAME_STYLE_LANGFANG then
            LibGameLogicLangFang:ProcessOPQuadruplet(ACTION_QUADRUPLET_REVEALED, stPengGangPlayer, stPengGangPlayer)
        elseif GGameCfg.RoomSetting.nGameStyle == GAME_STYLE_TAGNSHAN then
            LibGameLogicLangFang:ProcessOPQuadruplet(ACTION_QUADRUPLET_REVEALED, stPengGangPlayer, stPengGangPlayer)
        end
    end
    stRoundInfo:SetPengGangPlayer(0)

    return STEP_SUCCEED
end

return logic_judge_qianggang_end
