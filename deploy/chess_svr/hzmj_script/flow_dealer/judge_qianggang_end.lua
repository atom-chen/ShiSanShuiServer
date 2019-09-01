-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_judge_qianggang_end(dealer, msg)
    LOG_DEBUG("Run LogicStep judge_qianggang_end")
    local stGameState = GGameState
    local stRoundInfo = GRoundInfo
    LOG_DEBUG("11111Run LogicStep judge_qianggang_end===thisTurn==%d",stRoundInfo:GetWhoIsOnTurn())
    local thisTurn = stRoundInfo:GetWhoIsNextTurn()
    LOG_DEBUG("2222Run LogicStep judge_qianggang_end===thisTurn==%d",thisTurn)

   --[[ local IsProcePengGang =true 
    LOG_DEBUG("11111Run LogicStep judge_qianggang_end===thisTurn==%d",stRoundInfo:GetWhoIsOnTurn())
    local thisTurn = stRoundInfo:GetWhoIsNextTurn()
    LOG_DEBUG("2222Run LogicStep judge_qianggang_end===thisTurn==%d",thisTurn)
    for i=1, PLAYER_NUMBER do
        if i~=thisTurn then
            stPlayerOther = GGameState:GetPlayerByChair(i)
            local GangStatus = stPlayerOther:GetPlayerQiangGangStatus()
            if GangStatus ==QIANGGANG_STATUS_OK and stPlayerOther:GetPlayerCanGang() == true then
                IsProcePengGang = false
            end
        end
    end
    --抢杠过程结束的话，如果抢杠成功不再处理碰杠的玩家的碰，进入胡牌玩家下一个
    --如果放弃抢杠，需要设置当前轮到的玩家为碰杠玩家并处理碰杠
    if IsProcePengGang == true and stRoundInfo:GetIsQiangGang() ==true then
        stRoundInfo:SetIsQiangGang(false) 
        LibGameLogicChengdu:ProcessOPQuadrupletChengdu(1, thisTurn, thisTurn)
    end--]]
    --chairid

    local IsAllGiveUp = true      --是否所有玩放弃抢杠，或者不存在抢杠
    local nPengGangPlayer = stRoundInfo:GetPengGangPlayer()
    local stPengGangHuPlayerList = stRoundInfo:GetPengGangHuPlayer()
    for i=1, #stPengGangHuPlayerList do
        if stPengGangHuPlayerList[i] ~= 0 then
            local stPlayerQiangGangHuPlayer = GGameState:GetPlayerByChair(stPengGangHuPlayerList[i])
            if not stPlayerQiangGangHuPlayer then
                return STEP_FAILED
            end
            local GangStatus = stPlayerQiangGangHuPlayer:GetPlayerQiangGangStatus()
            if  GangStatus == QIANGGANG_STATUS_OK then
                IsAllGiveUp = false
                LOG_DEBUG("3333333333333Run LogicStep ProcessOPQuadrupletChengdu===ProcessOPQuadrupletChengdu==")
                stPlayerQiangGangHuPlayer:SetPlayerQiangGangStatus(QIANGGANG_STATUS_NONE)

                local nCard = stRoundInfo:GetPengGangCard()
                local stPlayer = GGameState:GetPlayerByChair(nPengGangPlayer)
                local stPlayerCardSet = stPlayer:GetPlayerCardSet()
				local bResult = stPlayerCardSet:Quadruplet2Triplet(nCard)
                local combineTile = stPlayerCardSet:ToArray()
                LOG_DEBUG("HHHHHH  nCard = %d  PengGangPlayer = %d bResult = %s combineTile = %s", nCard, nPengGangPlayer, tostring(bResult), vardump(combineTile))
                for j =1, #combineTile do
                    if bResult and combineTile[j].card == nCard then
                        local nValue = combineTile[j].value
                        CSMessage.NotifyAllPlayerQuadruplet2Triplet(stPlayer, nValue, nCard, nPengGangPlayer)
                    end
                end
            end
        end
    end
    if nPengGangPlayer ~= 0 and IsAllGiveUp == true then
        stRoundInfo:SetWhoIsOnTurn(nPengGangPlayer)
        stRoundInfo:SetIsQiangGang(false) 
        LOG_DEBUG("444444444Run LogicStep ProcessOPQuadrupletChengdu===ProcessOPQuadrupletChengdu==")
        if not stRoundInfo:GetGuoShouGang() then  -- 不是过手杠加分
            LibGameLogicChengdu:ProcessOPQuadrupletChengdu(1, nPengGangPlayer, nPengGangPlayer)
        end
    end
    stRoundInfo:SetPengGangPlayer(0)
    
    return STEP_SUCCEED
end


return logic_judge_qianggang_end
