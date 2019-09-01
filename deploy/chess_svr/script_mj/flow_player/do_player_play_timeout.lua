-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_do_player_play_timeout(stPlayer, event)
    LOG_DEBUG("Run LogicStep do_player_play_timeout")
    local nChairID = stPlayer:GetChairID()
    
    -- 打出最后一张摸牌
    local arrPlayerCards = stPlayer:GetPlayerCardGroup():ToArray()
    local nCard = LibTrustAuto:TrustPlayCard(arrPlayerCards, stPlayer:IsTing(), LibRuleTing:IsTingCanPlayOther())
    local iResult = LibGameLogic:ProcessOPPlay(stPlayer, nCard)
    -- 开始托管
    if not stPlayer:IsTrust() then
        if LibAutoPlay:GetPlayerNeedTrust(nChairID) then
            LOG_DEBUG("I HAVE START AUTUPLAY. _chair=%d", nChairID)
            stPlayer:SetIsTrust(true)
            CSMessage.NotifyTrustToAll(stPlayer, true)
        else
            LibAutoPlay:AddPlayerTimeOut(nChairID)
        end
    end
    if iResult ~= 0 then
        return STEP_FAILED
    end

    --
    stPlayer:AddTimeoutTimes()
    FlowFramework.DelTimer(nChairID, 0)

    return STEP_SUCCEED 
end


return logic_do_player_play_timeout
