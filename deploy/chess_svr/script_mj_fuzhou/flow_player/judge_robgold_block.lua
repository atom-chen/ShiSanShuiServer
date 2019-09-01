-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_judge_robgold_block(player, msg)
    LOG_DEBUG("Run LogicStep judge_robgold_block")
     if LibGameLogic:ProcessOPRobGoldBlock() == false then
        return STEP_FAILED
    end
    return STEP_SUCCEED
end


return logic_judge_robgold_block