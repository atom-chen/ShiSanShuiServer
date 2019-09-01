local LibBase = import(".lib_base")
local stGameState = nil
local stRoundInfo = nil
local CURRENT_MODULE_NAME = ...
local LibFanCounter = class("LibFanCounter", LibBase)

function LibFanCounter:ctor()
end
function LibFanCounter:CreateInit(strSlotName)
    local stSlotFuncNames = {"Init", "SetEnv", "GetCount", "GetScore", "InitForNext"}
    self.m_slot  = self:LoadSlot(strSlotName, stSlotFuncNames)
    if self.m_slot == nil then
        return false
    end

     local nMinWin = GGameCfg.RoomSetting.nMinFan
     local nBaseBet = GGameCfg.RoomSetting.nBaseBet
    if self.m_slot.Init(nMinWin, nBaseBet) == false then
        return false
    end


    if GGameCfg.RoomSetting.nGameStyle == GAME_STYLE_CHENGDU  then
        local nStyle = GGameCfg.RoomSetting.nSubGameStyle 
        local bZiMoJiaDi = GGameCfg.RoomSetting.bZiMoJiaDi
        local bJiaJiaYou = GGameCfg.RoomSetting.bJiaJiaYou
        if self.m_slot.InitFanChengDuCounter(nStyle, bZiMoJiaDi, bJiaJiaYou) == false then
            return false
        end
      end

    return true
end
function LibFanCounter:OnGameStart()
    self.m_slot.InitForNext()
end

function LibFanCounter:CollectEnv(nChair, nTurn, nFlag, nLast)
    local stGameState = GGameState
    local stRoundInfo = GRoundInfo
    local env = import(".environment", CURRENT_MODULE_NAME)
    if nChair > 4 or nChair < 1 then
        LOG_ERROR("LibFanCounter:CollectEnv nChair:%d", nChair)
        return nil
    end    
    --  还剩多少张牌，用来计算海底等
    env.byTilesLeft = GDealer:GetDealerCardGroup():GetCurrentLength()
    local stPlayer = stGameState:GetPlayerByChair(nChair)
    if stPlayer == nil  then
        LOG_ERROR("LibFanCounter:CollectEnv nChair:%d", nChair)
        return nil
    end
    --  圈风
    env.byRoundWind = stRoundInfo:GetRoundWind()
    -- 门风
    env.byPlayerWind = stPlayer:GetSeatWind()
    -- 检查谁的
    env.byChair = nChair - 1
    -- 轮到谁，如果是点炮，则是点炮的那个人
    if nTurn ~= nil then
        env.byTurn = nTurn  - 1
    else
         env.byTurn = stRoundInfo:GetWhoIsOnTurn()  - 1
     end
   

    for i=1,8 do
        local byWho = stRoundInfo:GetFlower(i)
        if byWho <= 4  and byWho > 0 then
            env.byFlowerCount[byWho] = env.byFlowerCount[byWho] + 1
        end
    end

    for i=1,PLAYER_NUMBER do
        env.byTing[i] = stGameState:GetPlayerByChair(i):GetTing()
    end
    if nFlag  ~= nil  then
         env.byFlag = nFlag
         env.tLast = nLast
    else
        if nChair == stRoundInfo:GetWhoIsOnTurn() then
            -- 自摸
             if stRoundInfo:GetDrawStatus() == DRAW_STATUS_GANG then
                env.byFlag = WIN_GANGDRAW
            else
                env.byFlag = WIN_SELFDRAW
            end
            env.tLast = stRoundInfo:GetLastDraw() -- 最后和的那张牌

        else
            -- 和别人的
             if stRoundInfo:GetDrawStatus() == GIVE_STATUS_GANG then
                  env.byFlag = WIN_GANG
             elseif stRoundInfo:GetDrawStatus() == GIVE_STATUS_GANGGIVE then
                env.byFlag = WIN_GANGGIVE
             else
                env.byFlag = WIN_GUN
            end
             env.tLast = stRoundInfo:GetLastGive()  -- 最后和的那张牌
        end
    end
    for i=1,PLAYER_NUMBER do
        -- 手上的牌
        local stPlayer = stGameState:GetPlayerByChair(i)
        local stPlayerCardGroup = stPlayer:GetPlayerCardGroup()
        local nHandCount = stPlayerCardGroup:GetCurrentLength()
        env.byHandCount[i] = nHandCount
        for j=1, nHandCount do
             env.tHand[i][j] = stPlayerCardGroup:GetCardAt(j)
        end
        -- set有几手牌
        local stPlayerCardSet = stPlayer:GetPlayerCardSet()
        env.bySetCount[i] = stPlayerCardSet:GetCurrentLength()
        for j=1,4 do
            if j < env.bySetCount[i] then
                local sets = stPlayerCardSet:GetCardSetAt(j)
                env.tSet[i][j][0] = sets.ucFlag
                env.tSet[i][j][1] = sets.card
                env.tSet[i][j][2] = sets.value
                if env.tSet[i][j][2]  > 0 then
                    env.tSet[i][j][2] =env.tSet[i][j][2]  - 1
                end
            end
        end 
        --// give
        local stPlayerGiveGroup = stPlayer:GetPlayerGiveGroup()
        env.byGiveCount[i] = stPlayerGiveGroup:GetCurrentLength()

    end
    for i=1,PLAYER_NUMBER do
        if  env.byGiveCount[i] > 0 then
            env.byDoFirstGive[i] = 1
        else
             env.byDoFirstGive[i] = 0
        end
    end
    if env.byFlag ~= WIN_SELFDRAW and  env.byFlag ~= WIN_GANGDRAW then
        env.tHand[nChair][env.byHandCount[nChair] + 1] = env.tLast
        env.byHandCount[nChair] = env.byHandCount[nChair] + 1
    end
    env.byDealer = stRoundInfo:GetBanker() - 1
    -- end
    return env
end

function LibFanCounter:SetEnv(env)
     self.m_slot.SetEnv(env)
end

function LibFanCounter:GetCount()
    return self.m_slot.GetCount()
end
function LibFanCounter:GetScore()
    return self.m_slot.GetScore()
end
function LibFanCounter:CheckWin(arrPlayerCards,nlaizicount,laizicard)
    return self.m_slot.CheckWin(arrPlayerCards,nlaizicount,laizicard)
end
return LibFanCounter