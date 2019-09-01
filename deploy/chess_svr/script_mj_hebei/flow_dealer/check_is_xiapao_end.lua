-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_check_is_xiapao_end(dealer, msg)
    LOG_DEBUG("Run LogicStep check_is_xiapao_end")
    if LibXiaPao:IsAllXiaPao() == true then
        return "yes"
    end
    return "no"
end
return logic_check_is_xiapao_end
