-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_do_player_ready(stPlayer, msg)
    LOG_DEBUG("Run LogicStep do_player_ready")
    local nChair = stPlayer:GetChairID()
    FlowFramework.DelTimer(nChair, 0)
    
    if GGameCfg.RoomSetting.nChargeMode ~= CHARGE_MODE_FREE then
        if GDealer:CheckPlayerMoney(stPlayer:GetPlayerID()) ~= 0 then 
            stPlayer:Logout()
            return STEP_FAILED
        end
    end
    stPlayer:SetPlayerStatus(PLAYER_STATUS_READY)

    return STEP_SUCCEED
end


return logic_do_player_ready
