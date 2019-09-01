-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_do_xiapao_end(dealer, msg)
    LOG_DEBUG("Run LogicStep do_xiapao_end")

    local stPlayerXiaPao = {}
    for i=1,PLAYER_NUMBER do
    	local nPlayerXiaPao = LibXiaPao:GetPlayerXiaPao(i)
    	table.insert(stPlayerXiaPao, nPlayerXiaPao)
    end
    CSMessage.NotifyXiaPaoResult(nil, stPlayerXiaPao)

    dealer:ToNextStage()
    return STEP_SUCCEED
end


return logic_do_xiapao_end
