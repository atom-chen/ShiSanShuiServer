-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_mainlogic_end(dealer, msg)
    LOG_DEBUG("Run LogicStep mainlogic_end")
    -- 直接结算，或者黄牌，不需要查牌了
    -- LibGameLogic:GameOverNoCard()
    dealer:ToNextStage()
    SSMessage.WakeupDealer()
    return STEP_SUCCEED
end


return logic_mainlogic_end
