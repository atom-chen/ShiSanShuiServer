-- 旁观进入
local Player = import("core.player")

-- 游戏者进入
local function doGamerEnter(dealer, msg)
    LOG_DEBUG("doGamerEnter\n")
    local userInfo  = msg._para

    if GDealer:IsGameStart() then
        LOG_DEBUG("Game Is Already Start. player Sit failed. %s", GDealer:GetCurrStage())
        return STEP_FAILED
    end

    -- 配置非免费方式 需要检查 money
    if GGameCfg.RoomSetting.nChargeMode ~= CHARGE_MODE_FREE then 
        if dealer:CheckPlayerMoney(msg._pid) == false then
            return STEP_FAILED
        end
    end

    -- new Player并创建玩家行为树
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

    --房主进房后自动准备 其他人需通知
    GGameState:SetPlayer(stPlayer:GetChairID(), stPlayer)
    dealer:InitBeforeGame()
    LOG_DEBUG("stPlayer:GetChairID() :%d", stPlayer:GetChairID())
    stPlayer:SetPlayerStatus(PLAYER_STATUS_SIT)

    if stPlayer:IsOwner() then
        LOG_DEBUG("doGamerEnter...owerer..")
        stPlayer:SetPlayerStatus(PLAYER_STATUS_READY)
        if GGameCfg.nCurrJu == 1 then
            CSMessage.NoitfyPlayerGameCfg(stPlayer, GGameCfg)
            CSMessage.NotifyPlayerEnterToAll(stPlayer)
            CSMessage.NotifyPlayerReadyToAll(stPlayer)
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
    else
        LOG_DEBUG("doGamerEnter...other..")
        --通知玩家 举手操作
        SSMessage.CallPlayerReady(stPlayer)
    end
    
    return STEP_SUCCEED
end

-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_do_player_enter(dealer, msg)
    -- local userInfo = msg._para
    return doGamerEnter(dealer, msg)
end


return logic_do_player_enter
