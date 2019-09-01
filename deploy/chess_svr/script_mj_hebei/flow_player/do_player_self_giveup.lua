-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_do_player_self_giveup(stPlayer, msg)
    LOG_DEBUG("Run LogicStep do_player_self_giveup")
    local nChair = stPlayer:GetChairID()
    local stPlayerBlockState = LibGameLogic:GetPlayerBlockState(nChair)

    --检查手牌只有两张牌 并且是癞子牌, 玩家只能胡，防止卡死
    if not GGameCfg.GameSetting.bSupportPlayLaizi then
        local bCanWin = stPlayerBlockState:IsCanWin()
        local bAllLaizi = stPlayer:IsLeft2CardsLaizi()
        LOG_DEBUG("do_player_self_giveup...bCanWin:%s, bAllLaizi:%s, bSupportPlayLaizi:%s", tostring(bCanWin), tostring(bAllLaizi), tostring(GGameCfg.GameSetting.bSupportPlayLaizi))
        if bCanWin and bAllLaizi then
            local nleftTime = FlowFramework.GetTimerLeftSecond(nChair, 0)
            local stBlockResut = stPlayerBlockState:GetReuslt()
            LOG_DEBUG("do_player_self_giveup..uid:%d, nleftTime:%d, stBlockResut:%s \n", stPlayer:GetUin(), nleftTime, vardump(stBlockResut))
            CSMessage.NotifyPlayerAskBlock(stPlayer, stBlockResut, true, false)
            return STEP_FAILED
        end
    end

    stPlayerBlockState:Clear()
    FlowFramework.DelTimer(nChair, 0)
    stPlayer:SetIsUserSelfGiveup(true)
    if GRoundInfo:IsDealerFirstTurn()  then
        GRoundInfo:SetDealerFirstTurn(false)
    end
    SSMessage.CallPlayerAskPlay(stPlayer)
    
    return STEP_SUCCEED
end


return logic_do_player_self_giveup
