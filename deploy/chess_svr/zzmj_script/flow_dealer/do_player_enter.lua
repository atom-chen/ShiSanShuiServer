-- 旁观进入
local Player = import("core.player")


-- 游戏者进入
local function doGamerEnter(dealer, msg)
    LOG_DEBUG("doGamerEnter\n")
    local userInfo  = msg._para


    -- local nGameStatus = GGameState:GetGameStatus()
    -- if nGameStatus ~= GAME_STATUS_NOSTART then
    if GDealer:IsGameStart() then
        LOG_DEBUG("Game Is Already Start. player Sit failed. %s", GDealer:GetCurrStage())
        return STEP_FAILED
    end

    dealer:SetOnceStart(false)
    -- 配置非免费方式 需要检查 money
    if GGameCfg.RoomSetting.nChargeMode ~= CHARGE_MODE_FREE then 
        if dealer:CheckPlayerMoney(msg._pid) == false then
            return STEP_FAILED
        end
    end


    local stPlayer = Player.new()
     if stPlayer:Login(userInfo) == false then
        LOG_DEBUG("Player Enter Login Failed.\n");
        return STEP_FAILED
    end

    local stProcess = _FlowTreeCtrl.CreateFlowTree()
    if stProcess == nil or stProcess:Init(G_TABLEINFO.tableptr, GGameCfg.FlowSetting.strFlowPlayer) ~= 0 then
        return STEP_FAILED
    end

    local stProcessExt = _FlowTreeCtrl.CreateFlowTree()
    if stProcessExt == nil or stProcessExt:Init(G_TABLEINFO.tableptr, GGameCfg.FlowSetting.strFlowPlayerExt) ~= 0 then
        return STEP_FAILED
    end

    stPlayer:AddFlow(stProcess)
    stPlayer:AddFlow(stProcessExt)

    stPlayer:SetPlayerStatus(PLAYER_STATUS_SIT)
    LOG_DEBUG("stPlayer:GetChairID() :%d", stPlayer:GetChairID())
    GGameState:SetPlayer(stPlayer:GetChairID(), stPlayer)
    dealer:InitBeforeGame()
    SSMessage.CallPlayerReady(stPlayer)
    

  
    return STEP_SUCCEED
end

-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_do_player_enter(dealer, msg)
    local userInfo  = msg._para
    return doGamerEnter(dealer, msg)
    --[[
    if userInfo.state == USER_STATUS_LOOKON then
        return doWatchEnter(dealer, msg)
    elseif userInfo.state == USER_STATUS_SIT then
        return doGamerEnter(dealer, msg)
    end

    return STEP_FAILED
    ]]
end


return logic_do_player_enter
