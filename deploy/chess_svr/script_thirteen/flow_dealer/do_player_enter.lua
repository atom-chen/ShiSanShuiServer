-- 旁观进入
local Player = import("core.player")


-- 游戏者进入
local function doGamerEnter(dealer, msg)
    LOG_DEBUG("doGamerEnter\n")
    local userInfo  = msg._para

    if dealer:IsGameStart() then
        LOG_DEBUG("Game Is Already Start. player Sit failed. %s", dealer:GetCurrStage())
        return STEP_FAILED
    end

    -- 配置非免费方式 需要检查 money
    if GGameCfg.RoomSetting.nChargeMode ~= CHARGE_MODE_FREE then 
        if dealer:CheckPlayerMoney(msg._pid) == false then
            return STEP_FAILED
        end
    end

    --1.new player
    local stPlayer = Player.new()
     if stPlayer:Login(userInfo) == false then
        LOG_DEBUG("Player Enter Login Failed.\n");
        return STEP_FAILED
    end
    --2.创建玩家独有的行为树
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

    --设置玩家为坐下状态
    stPlayer:SetPlayerStatus(PLAYER_STATUS_SIT)
    -- LOG_DEBUG("stPlayer:GetChairID() :%d", stPlayer:GetChairID())
    --保存玩家
    GGameState:SetPlayer(stPlayer:GetChairID(), stPlayer)
    --初始化该局游戏数据
    dealer:InitBeforeGame()
    --设置庄家
    -- LOG_DEBUG("doGamerEnter, myUid: %d, bankerUid: %d, type: %s", stPlayer:GetUin(), GGameCfg.uid, type(GGameCfg.uid))
    if stPlayer:GetUin() == GGameCfg.uid then
        dealer:SetBanker(stPlayer:GetChairID())
    end

    --通知player行为树 call_ready
    SSMessage.CallPlayerReady(stPlayer)
    
    return STEP_SUCCEED
end

-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_do_player_enter(dealer, msg)
    return doGamerEnter(dealer, msg)
end

return logic_do_player_enter
