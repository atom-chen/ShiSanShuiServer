-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_do_player_xiapao_timeout_zhengzhou(stPlayer, event)
    LOG_DEBUG("Run LogicStep player_xiapao_timeout_zhengzhou")
    
	local nPlayerBeiShu = 0
	LibXiaPao:ProcessPlayerXiaPao(stPlayer:GetChairID(), nPlayerBeiShu)

	-- 让dealer来通知总体结果
	-- CSMessage.NotifyAllPlayerXiaPao (stPlayer, nPlayerBeiShu)

	return STEP_SUCCEED
end


return logic_do_player_xiapao_timeout_zhengzhou
