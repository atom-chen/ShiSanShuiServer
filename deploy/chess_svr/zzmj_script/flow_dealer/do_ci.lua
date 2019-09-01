-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_do_ci(dealer, msg)
    LOG_DEBUG("Run LogicStep do_ci")

    local stDealerCardGroup = dealer:GetDealerCardGroup()
    --最后一张为次牌
    local nCard = stDealerCardGroup:GetCardAt(1);

    LibCi:SetCi(nCard)
    CSMessage.NotifyPlayerCi(nil, {1}, {nCard})

    LOG_DEBUG("Run LogicStep do_ci nCard = %d", nCard)

    dealer:ToNextStage()

    return STEP_SUCCEED
end


return logic_do_ci