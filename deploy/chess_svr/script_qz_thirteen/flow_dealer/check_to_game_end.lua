-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_check_to_game_end(dealer, msg)
    LOG_DEBUG("Run LogicStep check_to_game_end, %d ? %d\n", GGameCfg.nCurrJu, GGameCfg.nJuNum)

    -- 只控制最后一局要等 
    if GGameCfg.nCurrJu ~= GGameCfg.nJuNum then
        return STEP_SUCCEED
    end

    local count = 0
    for i=1,PLAYER_NUMBER do
        local stPlayer = GGameState:GetPlayerByChair(i)
        -- 在线而又不cancel，则等
        if  stPlayer ~= nil and stPlayer:IsCancleCompare() ~= true and stPlayer:GetPlayOfflineStatus() ~= 1 then
            LOG_DEBUG("failed logic_check_to_game_end uid:%d, count:%d, IsCancleCompare:%s, OfflineStatus:%d ", stPlayer:GetUin(), count, tostring(stPlayer:IsCancleCompare()), stPlayer:GetPlayOfflineStatus())

            return STEP_FAILED
        end
        count = count +  1
    end

    LOG_DEBUG("succeed logic_check_to_game_end count:%d, tbid=%d", count, G_TABLEINFO.tableid);
    return STEP_SUCCEED
end

return logic_check_to_game_end
