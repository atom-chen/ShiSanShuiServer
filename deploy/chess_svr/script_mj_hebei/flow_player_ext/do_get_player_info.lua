-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_do_get_player_info(stPlayer, msg)
    LOG_DEBUG("Run LogicStep do_get_player_info")
    -- 临时实现
    local stPlayerInfoReq = msg._para.body_player_info
    if stPlayerInfoReq == nil then
        CSMessage.NotifyError(stPlayer, ERROR_PARAM_ERR)
        return STEP_FAILED
    end
    if type(stPlayerInfoReq._chair ) ~= 'number'  or stPlayerInfoReq._chair  < 1 or stPlayerInfoReq._chair > PLAYER_NUMBER then
        CSMessage.NotifyError(stPlayer, ERROR_PARAM_ERR)
        return STEP_FAILED
    end
    local stPlayerRsp = {}
    stPlayerRsp.body_player_info = {}
    if stPlayerInfoReq.base_info ~= nil and stPlayerInfoReq.base_info.b_set == true then
        local stPlayer1 = GGameState:GetPlayerByChair(stPlayerInfoReq._chair)

        stPlayerRsp.body_player_info.base_info = stPlayer1:GetUserInfoAllSt()
    end
    if stPlayerInfoReq.best_fight ~= nil and stPlayerInfoReq.best_fight.b_set == true then
        stPlayerRsp.body_player_info.best_fight = {}
    end
    CSMessage.ResponsePlayerInfo(stPlayer, stPlayerInfoReq._chair , stPlayerRsp)
    return STEP_SUCCEED
end


return logic_do_get_player_info
