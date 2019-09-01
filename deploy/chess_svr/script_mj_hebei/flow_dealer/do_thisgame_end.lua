-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local SetGameEnd = _GameModule._TableLogic.SetGameEnd or function() end

local function logic_do_thisgame_end(dealer, msg)
    LOG_DEBUG("Run LogicStep do_thisgame_end")
    
    CSMessage.NotifyAllPlayerGameEnd();

    SetGameEnd(G_TABLEINFO.tableptr)
    dealer:SetGameEnd(true);

    return STEP_SUCCEED
end


return logic_do_thisgame_end
