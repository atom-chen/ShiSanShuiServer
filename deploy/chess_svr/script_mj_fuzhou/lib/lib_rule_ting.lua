local LibBase = import(".lib_base")
local LibRuleTing = class("LibRuleTing", LibBase)

function LibRuleTing:ctor()
end
function LibRuleTing:CreateInit(strSlotName)
    local stSlotFuncNames = {"IsSupportTing", "IsTingCanPlayOther"}
    self.m_slot  = self:LoadSlot(strSlotName, stSlotFuncNames)
    if self.m_slot == nil then
        return false
    end

    return true
end
function LibRuleTing:OnGameStart()
    self.m_stWinGroup = {}
end

function LibRuleTing:IsSupportTing()
    return self.m_slot.IsSupportTing()
end
function LibRuleTing:IsTingCanPlayOther()
    return self.m_slot.IsTingCanPlayOther()
end

function LibRuleTing:CanTing(stPlayer, stCardArray)


    -- 检查ting 同时记录听组合
    self.m_stWinGroup = {}
    local arrCards = Array.Clone(stCardArray)
    local nChairID = stPlayer:GetChairID()
    local stRoundInfo = GRoundInfo

    -- 有定缺牌 不能听
    -- local bCheckMissRes = LibConfirmMiss:CheckHasMissCard(nChairID, stCardArray)
    -- if bCheckMissRes == true then
    --     return false
    -- end
    local function getHandCardsHasCardNums(nNeedCard)
        local nCount = 0
        for _, v in ipairs(arrCards) do
            if v == nNeedCard then
                nCount = nCount + 1
            end
        end
        return nCount
    end

    LOG_DEBUG("LibRuleTing:CanTing....p%d, uid:%d, arrCards:%s\n", nChairID, stPlayer:GetUin(), vardump(arrCards))
    local bResult = false
    for k,cardRemove in ipairs(arrCards) do
        local oneChoice = {}
        oneChoice.give = cardRemove -- 出哪张牌
        oneChoice.flag = 0          --0普通胡 1任意胡
        oneChoice.win  = {}         -- 和牌信息

        local cards = Array.Clone(arrCards)
        -- 删除一张牌 
        Array.RemoveOne(cards, cardRemove)
        local nCardNums = 37
        local nGameStyle = GGameCfg.RoomSetting.nGameStyle
        if nGameStyle == GAME_STYLE_FUZHOU then
            nCardNums = 30
        end
        LOG_DEBUG("LibRuleTing:CanTing...cardRemove:%d, cards:%s\n", cardRemove, vardump(cards))

        for nCard=1,nCardNums do
            if (LibFlowerCheck:IsFlowerCard(nCard) == false) and (nCard % 10 ~= 0) then
                -- and LibConfirmMiss:CheckIsMissCard(nChairID, nCard ) == false then
                local t = Array.Clone(cards)
                table.insert(t, nCard)
                if LibRuleWin:CanWin(t) then
                    -- 算番
                    local env  = LibFanCounter:CollectEnv(nChairID)
                    LibFanCounter:SetEnv(env)
                    local stFanCount = LibFanCounter:GetCount()
                    local nFan = 0
                    for i=1,#stFanCount do
                        nFan = nFan + stFanCount[i].byFanNumber
                    end

                    local nNotShowNum = stRoundInfo:GetCardNotShowNum(nCard) or 0
                    local nMyHave = getHandCardsHasCardNums(nCard)
                    local nSubCount = nNotShowNum - nMyHave
                    if nSubCount < 0 then
                        nSubCount = 0
                    end
                    LOG_DEBUG("LibRuleTing:CanTing...p%d, nCard:%d, nNotShowNum:%d, nMyHave:%d", nChairID, nCard, nNotShowNum, nMyHave)
                    oneChoice.win[#oneChoice.win + 1] = { nCard = nCard, nFan = nFan, nLeft = nSubCount }
                    bResult = true
                end
            end
        end
        LOG_DEBUG("LibRuleTing:CanTing...k:%d, #oneChoice.win:%d\n", k, #oneChoice.win)

        if #oneChoice.win > 0 then
            --如果是胡任意牌
            if #oneChoice.win >= nCardNums then
                oneChoice.win = {}
                oneChoice.flag = 1
            end
            self.m_stWinGroup[#self.m_stWinGroup + 1] = oneChoice 
        end
    end
    LOG_DEBUG("LibRuleTing:CanTing....stWinGroup", vardump(self.m_stWinGroup))
    
    return bResult
end

function LibRuleTing:GetTingGroup()
    return self.m_stWinGroup
end

return LibRuleTing