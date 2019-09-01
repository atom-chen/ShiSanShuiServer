-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_do_player_xiapao_timeout(stPlayer, event)
    LOG_DEBUG("Run LogicStep player_xiapao_timeout")
    
	local nPlayerBeiShu = 0
	LibXiaPao:ProcessPlayerXiaPao(stPlayer:GetChairID(), nPlayerBeiShu)

	return STEP_SUCCEED
end


return logic_do_player_xiapao_timeout
