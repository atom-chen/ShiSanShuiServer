-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_do_change_flower_end(dealer, msg)
    LOG_DEBUG("Run LogicStep do_change_flower_end")
    LOG_DEBUG("==============nCurrJu:%d", GGameCfg.nCurrJu)
    LOG_DEBUG("do_change_flower_end 11111...strCurrStage:%s", dealer:GetCurrStage())
    dealer:ToNextStage()
    LOG_DEBUG("do_change_flower_end 22222...strCurrStage:%s", dealer:GetCurrStage())
    
    return STEP_SUCCEED
end


return logic_do_change_flower_end