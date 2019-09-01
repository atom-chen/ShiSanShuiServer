-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
require "common.socket"
local function logic_notify_player_play_card(stPlayer, msg)
    LOG_DEBUG("Run LogicStep notify_player_play_card")

    --听牌提示
    local bIsQuick = stPlayer:IsTrust() or  stPlayer:IsWin()
    CSMessage.NotifyAskPlay(stPlayer, bIsQuick)

    local envtest  = LibFanCounter:CollectEnv(stPlayer:GetChairID())

    --第一轮通知出牌的时候，获取听牌信息时把抢金置为1
    if GRoundInfo:IsDealerFirstTurn()  and GGameCfg.RoomSetting.nGameStyle == GAME_STYLE_FUZHOU then
        LOG_DEBUG(":notify_player_play_card..IsDealerFirstTurn.\n")
		envtest.bankerfirst=1
    end
    local timeNow =  math.floor(socket.gettime()*1000)
    LibFanCounter:SetEnv(envtest)
    local stTingInfo =LibFanCounter:GetTingInfo()
    --LOG_DEBUG(":notify_player_play_card...stTingInfo:%s\n",vardump(stTingInfo))
    local timeNow1 =  math.floor(socket.gettime()*1000)

    LOG_DEBUG(":notify_player_play_card...time:%d\n",timeNow1-timeNow)
    local stPlayerBlockState = LibGameLogic:GetPlayerBlockState(stPlayer:GetChairID())
    if stPlayer:IsWin() == false and #stTingInfo>0 then
        LOG_DEBUG(":notify_player_play_card..111.stTingInfo:%s\n",vardump(stTingInfo))
        CSMessage.NotifyPlayerBlockTing(stPlayer, stTingInfo)
    end

    return STEP_SUCCEED
end


return logic_notify_player_play_card
