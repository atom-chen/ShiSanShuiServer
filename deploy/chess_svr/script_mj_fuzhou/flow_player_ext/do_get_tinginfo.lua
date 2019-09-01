-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_do_get_tinginfo(stPlayer, msg)
    LOG_DEBUG("Run LogicStep do_chat")
    local stRoundInfo = GRoundInfo
    local stGameState = GGameState

    local thisTurn = stRoundInfo:GetWhoIsOnTurn()
    local nChair = stPlayer:GetChairID()
    local stPlayerBlockState = LibGameLogic:GetPlayerBlockState(nChair)

    local nFlag = 0
    local stCardTing ={}
    local arrPlayerCards = stPlayer:GetPlayerCardGroup():ToArray()
    local nCardNums = 37

    local nGameStyle = GGameCfg.RoomSetting.nGameStyle
    if nGameStyle == GAME_STYLE_FUZHOU then
        nCardNums = 30
    end

    -- 不是轮到自己出牌时.并且不是拦牌阶段
    -- 获取听牌的详细数据：听得牌，对应的番数
    if nChair ~= thisTurn then
        arrPlayerCards[#arrPlayerCards + 1] = 0
        for j=1, nCardNums do
            if j % 10 ~= 0 then
                -- 检查座位为i的玩家手上的牌加上j牌是否试胡牌牌型。 
                arrPlayerCards[#arrPlayerCards] = j
                if LibRuleWin:CanWin(arrPlayerCards) then
                    nFlag = 1
                    local nFan = LibGameLogicFuzhou:GetFanCount(nChair, j)    --算算玩家手牌加牌j一起的番数。 
                    table.insert(stCardTing, { nCard = j, nFan = nFan })
                end
            end
        end
    end
    if #stCardTing == nCardNums then
        nFlag = 2
        stCardTing = {}
    end

    CSMessage.NotifyTingInfoToSelf(stPlayer, nFlag, stCardTing)

    return STEP_SUCCEED
end


return logic_do_get_tinginfo
