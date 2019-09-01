-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_prepare_next(dealer, msg)
    LOG_DEBUG("Run LogicStep prepare_next")
    --FlowFramework.DelTimer(DEALER_ID, 0)
    -- return STEP_SUCCEED
    
    -- 房卡模式
    if GGameCfg.nMoneyMode == ROOM_MODE_SCORE then
        if GGameCfg.nCurrJu == GGameCfg.nJuNum then
            LOG_DEBUG("ROOM END, total ju=%d.\n", GGameCfg.nJuNum);
            FlowFramework.DelTimer(DEALER_ID, 0)
            return STEP_SUCCEED
        end
    end

    GGameCfg.nCurrJu = GGameCfg.nCurrJu + 1

    for i=1,PLAYER_NUMBER do
        local stPlayer = GGameState:GetPlayerByChair(i)
        if not stPlayer then
            return STEP_FAILED
        end
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
        -- SSMessage.CallPlayerReady(stPlayer)
    end

    -- LoaderLib.StartGameInitAll() -- 在start_game的时候会调用
    dealer:InitBeforeGame()

    for i=1,PLAYER_NUMBER do
        local stPlayer = GGameState:GetPlayerByChair(i)
        if not stPlayer then
            return STEP_FAILED
        end
        -- stPlayer:SetPlayerStatus(PLAYER_STATUS_SIT)
        -- LOG_DEBUG("stPlayer:GetChairID() :%d", stPlayer:GetChairID())
        -- GGameState:SetPlayer(stPlayer:GetChairID(), stPlayer)
        SSMessage.CallPlayerReady(stPlayer)
        -- CSMessage.NotifyPlayerAskReady(stPlayer)
    end


    dealer:SetCurrStage("prepare")
    return STEP_SUCCEED
end


return logic_prepare_next
