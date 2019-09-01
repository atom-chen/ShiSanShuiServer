-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local SetGameEnd = _GameModule._TableLogic.SetGameEnd or function() end
local SetGameEndKe = _GameModule._TableLogic.SetGameEndKe or function() end

local function logic_do_thisgame_end(dealer, msg)
    LOG_DEBUG("Run LogicStep do_thisgame_end")
    
    CSMessage.NotifyAllPlayerGameEnd()

    local nIsGameEnd =0
	if GGameCfg.GameSetting.bSupportJu then
		SetGameEnd(G_TABLEINFO.tableptr)
	elseif GGameCfg.GameSetting.bSupportKe then   -- 打课时，有一个玩家分数小于0，牌局结束
		local stScoreRecord = LibGameLogic:GetScoreRecord()
	    for i = 1, PLAYER_NUMBER do
	        if stScoreRecord:GetPlayerSumScore(i) <=0 then
	       		nIsGameEnd = 1
	        end
	    end
	    LOG_DEBUG("Run LogicStep SetGameEndKe==nIsGameEnd=%d", nIsGameEnd)
		SetGameEndKe(G_TABLEINFO.tableptr,nIsGameEnd)  
	end
    
    dealer:SetGameEnd(true)

    return STEP_SUCCEED
end


return logic_do_thisgame_end
