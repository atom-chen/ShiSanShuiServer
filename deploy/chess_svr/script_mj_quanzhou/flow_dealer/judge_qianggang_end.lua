local function logic_judge_qianggang_end(dealer, msg)
    LOG_DEBUG("Run LogicStep judge_qianggang_end")
    local stGameState = GGameState
    local stRoundInfo = GRoundInfo

    local thisTurn = stRoundInfo:GetWhoIsNextTurn()

    local IsAllGiveUp =true   -- 是否所有玩放弃抢杠，或者不存在抢杠
    local stPengGangPlayer =stRoundInfo:GetPengGangPlayer()
    local stPengGangHuPlayerList =stRoundInfo:GetPengGangHuPlayer()
    for i=1, #stPengGangHuPlayerList do
        if stPengGangHuPlayerList[i] ~=0 then
            local stPlayerQiangGangHuPlayer = GGameState:GetPlayerByChair(stPengGangHuPlayerList[i])
            local GangStatus = stPlayerQiangGangHuPlayer:GetPlayerQiangGangStatus()
            if GangStatus == QIANGGANG_STATUS_OK then
                IsAllGiveUp = false
                stPlayerQiangGangHuPlayer:SetPlayerQiangGangStatus(QIANGGANG_STATUS_NONE)
            end
        end
    end
    if stPengGangPlayer ~=0 and IsAllGiveUp == true then
        stRoundInfo:SetWhoIsOnTurn(stPengGangPlayer)
        stRoundInfo:SetIsQiangGang(false) 

        local nGameStyle = GGameCfg.RoomSetting.nGameStyle

        if nGameStyle == GAME_STYLE_FUZHOU then
            LibGameLogicFuzhou:ProcessOPQuadruplet(ACTION_QUADRUPLET_REVEALED, stPengGangPlayer, stPengGangPlayer)

        elseif nGameStyle == GAME_STYLE_QUANZHOU then
            local nCard = stRoundInfo:GetPengGangCard()
            LOG_DEBUG("ACTION_QUADRUPLET_REVEALED card ==%d  turn = %d", nCard, thisTurn)
            LibGameLogicQuanZhou:ProcessOPQuadruplet(ACTION_QUADRUPLET_REVEALED, stPengGangPlayer, stPengGangPlayer, nCard)
        end
    end
    stRoundInfo:SetPengGangCard(0)
    stRoundInfo:SetPengGangPlayer(0)

    return STEP_SUCCEED
end

return logic_judge_qianggang_end