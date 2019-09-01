-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_do_player_play_card(stPlayer, msg)
    LOG_DEBUG("Run LogicStep do_player_play_card")
    if type(msg._para.cards) ~= 'table' or #msg._para.cards ~= 1 then
        LOG_ERROR("do_player_play_card Error msg._para. msg._para:%s\n", vardump(msg))
         CSMessage.NotifyError(stPlayer, ERROR_PARAM_ERR)
        return STEP_FAILED
    end
    local nCard = msg._para.cards[1]
    if type(nCard) ~= 'number' then
        CSMessage.NotifyError(stPlayer, ERROR_PARAM_ERR)
        return STEP_FAILED
    end

    local stPlayerCardGroup = stPlayer:GetPlayerCardGroup()
    --手牌是否有这张牌
    if stPlayerCardGroup:IsHave(nCard) == false then
        LOG_DEBUG("logic_do_player_play_card...palyer no this card====%d",nCard)
        CSMessage.NotifyError(stPlayer, ERROR_PLAYER_CARDGROUP)
        return STEP_FAILED
    end
    --花牌不能打
    if LibFlowerCheck:IsFlowerCard(nCard) then
        LOG_DEBUG("logic_do_player_play_card...flower card donot play. nCard: %d", nCard)
        CSMessage.NotifyError(stPlayer, ERROR_PLAY_FLOWER)
        return STEP_FAILED
    end
    --出的牌是不是吃的牌
    local nLastCard = GRoundInfo:GetLastGive()
    local nGiveStatus = GRoundInfo:GetGiveStatus()
    if nGiveStatus == GIVE_STATUS_COLLECT and nLastCard == nCard then
        LOG_DEBUG("logic_do_player_play_card...donot paly same card! nGiveStatus: %d, nLastCard: %d, nCard: %d", nGiveStatus, nLastCard, nCard)
        CSMessage.NotifyError(stPlayer, ERROR_PLAY_COLLECT)
        return STEP_FAILED
    end
    --出的牌是金牌
    --if LibGoldCard:IsGoldCard(nCard) then
        -- LOG_DEBUG("logic_do_player_play_card...gold card donot play. nCard: %d", nCard)
        -- CSMessage.NotifyError(stPlayer, ERROR_PLAY_GOLD)
        -- return STEP_FAILED

    --    local nGameStyle = GGameCfg.RoomSetting.nGameStyle

      --客户要求去掉打了金牌后只能自摸的限制
       -- if nGameStyle == GAME_STYLE_FUZHOU then
       --    --本局游戏内打金牌的人只能自摸，不能胡别人的牌
       --    stPlayer:SetOnlyHuType(GOLD_HU_SELFDRAW)
       -- else
            --TODO:
            --[[
            --2)“双游”情况下：其他人在不可以吃、碰、杠、胡这张牌的基础上，还需要自摸才可以胡牌，
                此限制为打出金牌当圈，下一圈起取消限制。
            --3)“三游”情况下：其他人在不可以吃、碰、杠、胡这张牌的基础上，还需要杠上开花才可以胡牌，
                此限制为打出金牌当圈有效，下一圈起取消限制。
            --]]
       --end
    --end
  

    local iResult = LibGameLogic:ProcessOPPlay(stPlayer, nCard)
    LOG_DEBUG("logic_do_player_play_card...ProcessOPPlay iResult:%d", iResult)
    if iResult ~= 0 then
        return STEP_FAILED
    end

    -- 重置超时次数
    LibAutoPlay:ResetPlayerTimeOut(stPlayer:GetChairID())
    if GGameCfg.nMoneyMode ~= ROOM_MODE_SCORE or GGameCfg.TimerSetting.timeOutLimit ~= -1 then
        FlowFramework.DelTimer(stPlayer:GetChairID(), 0)
    else 
        FlowFramework.DelTimer(stPlayer:GetChairID(), -1)
    end

    return STEP_SUCCEED
end


return logic_do_player_play_card
