-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
-- 发送游戏开始通知
local SetGameStart = _GameModule._TableLogic.SetGameStart or function() end
local function logic_start_game(dealer, msg)
    LOG_DEBUG("Run logic_start_game")
    --调用C++函数
    SetGameStart(G_TABLEINFO.tableptr)
    --通知客户端 游戏开始
    CSMessage.NotifyAllPlayerStartGame(GGameCfg.nNeedTingInfo)
    --游戏逻辑初始化
    LoaderLib.StartGameInitAll()
    --dealer 设置下一阶段阶段prepare
    dealer:SetGameStart()
    -- 洗牌
    local stDealerCardGroup = dealer:GetDealerCardGroup()
    stDealerCardGroup:PrepareDeal()

    return STEP_SUCCEED
end


return logic_start_game
