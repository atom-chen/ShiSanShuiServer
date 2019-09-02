-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_check_to_start_game(dealer, msg)
    --300秒不准备则清桌 字段在game_config_11.json中的ClearTableReadyTimeOut，==0表示不生效
    local bClearTable = dealer:IsCanClearTable()
    if bClearTable then
        dealer:SendClearTable()
        LOG_DEBUG("logic_check_to_start_game..clear table :%s", tostring(bClearTable))
        return STEP_FAILED 
    end

    -- local readyCount = 0
    -- for i=1,PLAYER_NUMBER do
    --     local stPlayer = GGameState:GetPlayerByChair(i)
    --     if stPlayer == nil then
    --         break
    --     end
    --     if  stPlayer:GetPlayerStatus()  ==  PLAYER_STATUS_READY then
    --         readyCount = readyCount + 1
    --     end
    -- end
    -- --判断准备的人数是否和当前在桌子的人数一样多
    -- if readyCount ~= GameCfg.nPlayerNum and bClearTable == false then
    --     return STEP_FAILED
    -- end

    -- PLAYER_NUMBER = GameCfg.nPlayerNum

    local count = 0
    for i=1,PLAYER_NUMBER do
        local stPlayer = GGameState:GetPlayerByChair(i)
      --  if  stPlayer == nil or stPlayer:GetPlayerStatus()  ~=  PLAYER_STATUS_READY then
	if  stPlayer == nil or (stPlayer:GetPlayerStatus()  ~=  PLAYER_STATUS_READY and bClearTable == false) then
            -- LOG_DEBUG("failed logic_check_to_start_game ready count:%d, PLAYER_NUMBER:%d ", count, PLAYER_NUMBER)
            return STEP_FAILED
        end
        count = count +  1
    end
    --水庄  要判断是否有庄家
    if GGameCfg.GameSetting.bSupportWaterBanker then
        local nBanker = dealer:GetBanker()
        local stPlayer = GGameState:GetPlayerByChair(nBanker)
        if stPlayer == nil then
            LOG_DEBUG("failed logic_check_to_start_game ready, water no banker: %d, ownerUid: %d ", nBanker, GGameCfg.uid)
            -- for i=1,PLAYER_NUMBER do
            --     local stPlayerOne = GGameState:GetPlayerByChair(i)
            --     if stPlayerOne then
            --         CSMessage.NotifyError(stPlayerOne, ERROR_NO_BANKER)
            --     end
            -- end
            return STEP_FAILED
        end
    end

    LOG_DEBUG("logic_check_to_start_game ready count:%d, PLAYER_NUMBER:%d ", count, PLAYER_NUMBER)
    return STEP_SUCCEED
end

return logic_check_to_start_game
