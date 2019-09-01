-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_do_player_ready(stPlayer, msg)
    LOG_DEBUG("Run LogicStep do_player_ready")
    --if GGameState:GetGameStatus() ~= GAME_STATUS_NOSTART then
    --        LOG_ERROR("logic_do_player_ready GameStatus:%d uin:%d _chair:%d\n" , 
    --       GGameState:GetGameStatus(), stPlayer:GetUin(),  stPlayer:GetChairID())
    --    return STEP_FAILED
    --end    
    --if stPlayer:GetPlayerStatus() == PLAYER_STATUS_READY then
    --    ERRLOG( "logic_do_player_ready Already done uin:%d _chair:%d\n" ,stPlayer:GetUin(),  stPlayer:GetChairID());
    --    return STEP_FAILED
    --end
    FlowFramework.DelTimer(stPlayer:GetChairID(), 0)
    
    -- if GGameCfg.RoomSetting.nChargeMode ~= CHARGE_MODE_FREE then
    --     if GDealer:CheckPlayerMoney(stPlayer:GetPlayerID()) ~= 0 then 
    --         stPlayer:Logout()
    --         return STEP_FAILED
    --     end
    -- end
    
     stPlayer:SetPlayerStatus(PLAYER_STATUS_READY)

    return STEP_SUCCEED
end


return logic_do_player_ready
