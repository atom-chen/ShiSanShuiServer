-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_check_is_opengold_end(dealer, msg)
    LOG_DEBUG("Run LogicStep check_is_opengold_end...IsOpenGoldEnd:%s", tostring(LibGoldCard:IsOpenGoldEnd()))
    -- if LibGoldCard:IsOpenGoldEnd() then
    --     dealer:ToNextStage()
    --     return STEP_FAILED
    -- end

    return STEP_SUCCEED  
end

return logic_check_is_opengold_end
