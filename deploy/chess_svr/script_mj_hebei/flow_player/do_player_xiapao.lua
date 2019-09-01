-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_do_player_xiapao(stPlayer, msg)
    LOG_DEBUG("Run LogicStep do_player_xiapao")
    local nPlayerBeiShu = msg._para.beishu
	LibXiaPao:ProcessPlayerXiaPao(stPlayer:GetChairID(), nPlayerBeiShu)

	--只回复该玩家下跑成功
	CSMessage.NotifyPlayerXiaPao(stPlayer, nPlayerBeiShu)
    if GGameCfg.nMoneyMode ~= ROOM_MODE_SCORE or GGameCfg.TimerSetting.TimeOutLimit ~= -1 then
        FlowFramework.DelTimer(stPlayer:GetChairID(), 0)
    else 
        FlowFramework.DelTimer(stPlayer:GetChairID(), -1)
    end
    return STEP_SUCCEED
end



return logic_do_player_xiapao
