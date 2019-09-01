-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止

-- 其实这个函数应该叫 call_player_enter，事件应该叫call_enter
local function logic_notify_player_ready(stPlayer, event)
    LOG_DEBUG("Run LogicStep notify_player_ready, nCurrJu: %d, (nPlayerStatus: %d == 1) ", GGameCfg.nCurrJu, stPlayer:GetPlayerStatus())
    -- LOG_DEBUG("Run LogicStep notify_player_ready, GGameCfg: %s", vardump(GGameCfg))
    -- 第一局才下发，否则只问
    if GGameCfg.nCurrJu == 1 then
        -- 下发游戏配置
        CSMessage.NoitfyPlayerGameCfg(stPlayer, GGameCfg)
        -- 通知其他玩家 玩家进入
        CSMessage.NotifyPlayerEnterToAll(stPlayer)
    end

    -- 第一局才下发，否则只问
    if stPlayer:GetPlayerStatus() == PLAYER_STATUS_SIT and GGameCfg.nCurrJu == 1 then
        -- 同步其他玩家的状态
        local nChair = stPlayer:GetChairID()
        for i=1,PLAYER_NUMBER do
            local stPlayerOther = GGameState:GetPlayerByChair(i)
            if i ~= nChair and stPlayerOther ~= nil then
                 if stPlayerOther:GetPlayerStatus() == PLAYER_STATUS_SIT then
                    -- 通知本玩家，其它玩家已经进入
                    CSMessage.NotifyPlayerEnterTo(stPlayerOther, stPlayer)
                 elseif stPlayerOther:GetPlayerStatus() == PLAYER_STATUS_READY then
                    -- 通知本玩家，其它玩家已ready
                    CSMessage.NotifyPlayerEnterTo(stPlayerOther, stPlayer)
                    CSMessage.NotifyPlayerReadyTo(stPlayerOther, stPlayer)
                 end
            end
        end
    end

    -- 通知玩家 举手操作
    CSMessage.NotifyPlayerAskReady(stPlayer)
    

    return STEP_SUCCEED
end


return logic_notify_player_ready
