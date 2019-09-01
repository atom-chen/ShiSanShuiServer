-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_choose_banker(dealer, msg)
    LOG_DEBUG("Run LogicStep choose_banker")
    local stRoundInfo = GRoundInfo
    -- 定色子
    local ucDice =  {math.random(1, 6), math.random(1, 6)} 
    stRoundInfo:SetDice(ucDice)

    if stRoundInfo:GetRoundWind() == 0 and stRoundInfo:GetSubRoundWind() == 0 then
        -- 第一盘，随机产生庄家
        -- 泉州麻将、如果是打课玩法，第一局开局时给每人100分
        LOG_DEBUG("Run LogicStep choose_bankernGameStyle ==%d,nGameStyle ==%s",GGameCfg.RoomSetting.nGameStyle,tostring(GGameCfg.GameSetting.bSupportKe))
        if GGameCfg.RoomSetting.nGameStyle == GAME_STYLE_QUANZHOU  and GGameCfg.GameSetting.bSupportKe==true then
            local stScoreRecord = LibGameLogic:GetScoreRecord()
            for i=1,PLAYER_NUMBER do
                stScoreRecord:SetPlayerSumScore(i, 100)
            end
            CSMessage.NotifyBanlanceChangeListToAll()
        end
        local nBanker = LibGetBanker:GetBanker()
        -- 庄家
        stRoundInfo:SetBanker(nBanker)
        -- 庄家处理
        LibGetBanker:DoDealer(GGameCfg.GameSetting.bCounterLian, true)
        -- 上次胡是谁,第一局默认庄家
        stRoundInfo:SetLastWinner(stRoundInfo:GetBanker())
        -- 设置东南西北
        dealer:SetPlayerWind()
    else
        -- subroundwind 用来判断当前的局
        -- roundwind  圈数暂时无用，GGameCfg.nJuNum局为一圈
        if GGameCfg.RoomSetting.nGameStyle == GAME_STYLE_FUZHOU then
            if stRoundInfo:GetSubRoundWind() == GGameCfg.nJuNum then
                stRoundInfo:SetSubRoundWind(0)
                stRoundInfo:SetRoundWind(stRoundInfo:GetRoundWind() + 1)
            end
            if stRoundInfo:GetRoundWind() == 4 then
            	stRoundInfo:SetRoundWind(0)
            end
        end

        LibGetBanker:DoDealer(GGameCfg.GameSetting.bCounterLian, false)
    end
    -- 一轮结束后增加轮数
    stRoundInfo:SetSubRoundWind(stRoundInfo:GetSubRoundWind() + 1)

    -- 通知玩家庄家是谁
    LOG_DEBUG("logic_choose_banker...banker: %d, dice: %s", stRoundInfo:GetBanker(), vardump(stRoundInfo:GetDice()))
    for i=1,PLAYER_NUMBER do
        local stPlayer = GGameState:GetPlayerByChair(i)
        CSMessage.NotifyPlayerBanker(stPlayer)
    end

    stRoundInfo:SetWhoIsOnTurn(stRoundInfo:GetBanker())

    dealer:ToNextStage()

    return STEP_SUCCEED
end


return logic_choose_banker
