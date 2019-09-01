-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
-- 发送游戏开始通知
local SetGameStart = _GameModule._TableLogic.SetGameStart or function() end
local function logic_start_game(dealer, msg)
    LOG_DEBUG("Run logic_start_game")
    SetGameStart(G_TABLEINFO.tableptr)
    CSMessage.NotifyAllPlayerStartGame()
    LoaderLib.StartGameInitAll()
    dealer:SetGameStart()
    return STEP_SUCCEED
end


return logic_start_game
