-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_do_player_self_ting(stPlayer, msg)
    LOG_DEBUG("Run LogicStep do_player_self_ting")
    local nChair = stPlayer:GetChairID()
    local stPlayerBlockState = LibGameLogic:GetPlayerBlockState(stPlayer:GetChairID())
    local stPlayerCardGroup = stPlayer:GetPlayerCardGroup()
    local nCard = msg._para.card
    if stPlayerBlockState:IsCardCanTing(nCard) == false then
        CSMessage.NotifyError(stPlayer, ERROR_PARAM_ERR)
        return STEP_FAILED
    end
    if  stPlayerCardGroup:IsHave(nCard) == false then
        CSMessage.NotifyError(stPlayer, ERROR_PLAYER_CARDGROUP)
        return STEP_FAILED
    end
    -- 打一张牌
    stPlayerCardGroup:SetTing(true)
    local iResult = LibGameLogic:ProcessOPPlay(stPlayer, nCard)
    if iResult ~= 0 then
        CSMessage.NotifyError(stPlayer, iResult)
        return STEP_FAILED
    end
    CSMessage.NotifyPlayerBlockTing(stPlayer, stPlayerBlockState:GetTingGroup(nCard))

    FlowFramework.DelTimer(stPlayer:GetChairID(), 0)
    return STEP_SUCCEED
end


return logic_do_player_self_ting
