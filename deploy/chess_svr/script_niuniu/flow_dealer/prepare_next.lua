-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_prepare_next(dealer, msg)
    LOG_DEBUG("Run LogicStep prepare_next")

    -- 房卡模式 -- 其实在check_to_game_end时已经删除了
    if GGameCfg.nMoneyMode == ROOM_MODE_SCORE then
        if GGameCfg.nCurrJu == GGameCfg.nJuNum then
            LOG_DEBUG("ROOM END, total ju=%d.\n", GGameCfg.nJuNum);
            FlowFramework.DelTimer(DEALER_ID, DEALER_TIMER_ID_0)
            return STEP_SUCCEED
        end
    end

    GGameCfg.nCurrJu = GGameCfg.nCurrJu + 1

    for i=1,PLAYER_NUMBER do
        local stPlayer = GGameState:GetPlayerByChair(i)
        if stPlayer then
            local allSt = stPlayer:GetUserInfo();
            local saveChairID = stPlayer:GetChairID();
            -- LOG_DEBUG ("allSt: %s", vardump(allSt))
            stPlayer:Logout()
            stPlayer:initial()
            LOG_DEBUG ("allSt 2: %s", vardump(allSt))
            stPlayer:Login(allSt)

            stPlayer:SetPlayerStatus(PLAYER_STATUS_SIT)
            LOG_DEBUG("stPlayer:GetChairID() :%d", saveChairID)
            GGameState:SetPlayer(saveChairID, stPlayer)
        end
    end

    --dealer 管理的数据初始化
    dealer:InitBeforeGame()

    for i=1,PLAYER_NUMBER do
        local stPlayer = GGameState:GetPlayerByChair(i)
        if stPlayer then
            --通知玩家行为树 执行"case": "call_ready"
            LOG_DEBUG("prepare_next..CallPlayerReady. uid: %d, p%d", stPlayer:GetUin(), i)
            SSMessage.CallPlayerReady(stPlayer)
        end
    end

    --从头开始一局
    dealer:SetCurrStage("prepare")
    return STEP_SUCCEED
end


return logic_prepare_next
