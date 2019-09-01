-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_notify_player_op_logic_func(stPlayer, msg)
    LOG_DEBUG("Run LogicStep notify_player_op_logic_func")

    local stPlayerBlockState = LibGameLogic:GetPlayerBlockState(stPlayer:GetChairID())

    -- no timeout
    CSMessage.NotifyPlayerAskBlock(stPlayer, stPlayerBlockState:GetReuslt(), false)

    --听牌提示
    if stPlayer:IsWin() == false and stPlayerBlockState:IsCanTing() then
        LOG_DEBUG("notify_player_op_logic_func...NotifyPlayerBlockTing...p%d, TingGroupAll:%s", stPlayer:GetChairID(), vardump(stPlayerBlockState:GetTingGroupAll()))
        --CSMessage.NotifyPlayerBlockTing(stPlayer, stPlayerBlockState:GetTingGroupAll())
    end

    local bIsQuick = stPlayer:IsTrust() or stPlayer:IsWin()
    CSMessage.NotifyAskPlay(stPlayer, bIsQuick)
    
--[[if GGameCfg.nNeedTingInfo == 1 then
        local envtest  = LibFanCounter:CollectEnv(stPlayer:GetChairID())
        LibFanCounter:SetEnv(envtest)
        local stTingInfo =LibFanCounter:GetTingInfo()
        --LOG_DEBUG(":ProcessOPTriplet...stTingInfo:%s\n",vardump(stTingInfo))


        if stPlayerBlockState:IsCanWin() == false and #stTingInfo>0 then
            LOG_DEBUG(":notify_player_op_logic_func..111.stTingInfo:%s\n",vardump(stTingInfo))
            CSMessage.NotifyPlayerBlockTing(stPlayer, stTingInfo)
        end
    end
--]]
    return STEP_SUCCEED
end



return logic_notify_player_op_logic_func
