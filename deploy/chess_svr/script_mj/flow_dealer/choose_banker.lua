-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_choose_banker(dealer, msg)
    LOG_DEBUG("Run LogicStep choose_banker")
    local stRoundInfo = GRoundInfo
    --定色子
    local ucDice =  {math.random(1, 6), math.random(1, 6)} 
    stRoundInfo:SetDice(ucDice)

    if stRoundInfo:GetRoundWind() == 0 and stRoundInfo:GetSubRoundWind() == 0 then
        -- 第一盘，随机产生庄家(现在是房主是第一轮庄家，理论上第一个进入房间的人)
        local nBanker = LibGetBanker:GetBanker()
        stRoundInfo:SetPrepareBanker(nBanker)
        --保存第一轮的庄家，连庄时用
        stRoundInfo:SetLastBanker(nBanker)

        LibGetBanker:DoDealer(GGameCfg.GameSetting.bCounterLian)
        stRoundInfo:SetLastWinner(stRoundInfo:GetBanker())              --//如果该盘流局，则下盘还是他当庄
        --if GGameCfg.RoomSetting.nGameStyle == GAME_STYLE_CHENGDU then
        --   stRoundInfo:SetGun(stRoundInfo:GetBanker())           --  //流局则下盘连庄
        --end
        dealer:SetPlayerWind()
        --一轮结束后增加轮数
        stRoundInfo:SetSubRoundWind(stRoundInfo:GetSubRoundWind() + 1)
    else
        if stRoundInfo:GetSubRoundWind() == 4 then
            stRoundInfo:SetSubRoundWind(0)
            stRoundInfo:SetRoundWind(stRoundInfo:GetRoundWind() + 1)
        end
        if stRoundInfo:GetRoundWind() == 4 then
            stRoundInfo:SetRoundWind(0)
        end
        local stPreparedealer = stRoundInfo:GetLastWinner()

        --连庄的话，设置预庄家为上一轮庄家
        if GGameCfg.GameSetting.bCounterLian ==true then
            stPreparedealer = stRoundInfo:GetLastBanker()
        end
        stRoundInfo:SetPrepareBanker(stPreparedealer)
        LibGetBanker:DoDealer(GGameCfg.GameSetting.bCounterLian)
        stRoundInfo:SetSubRoundWind(stRoundInfo:GetSubRoundWind() + 1)

    end
    local stGameState = GGameState
    for i=1,PLAYER_NUMBER do
        local stPlayer = stGameState:GetPlayerByChair(i)
        CSMessage.NotifyPlayerBanker(stPlayer)
    end
    stRoundInfo:SetWhoIsOnTurn(stRoundInfo:GetBanker())
    dealer:ToNextStage()
    return STEP_SUCCEED
end


return logic_choose_banker
