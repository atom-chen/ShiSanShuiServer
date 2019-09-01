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
    local bCheckMissRes = LibConfirmMiss:CheckHasMissCard(nChairID, stCardArray)
    if bCheckMissRes == true then
        return false
    end

    local bResult = false
    for _,cardRemove in ipairs(arrCards) do
        local oneChoice = {}
        oneChoice.give = cardRemove  -- 出哪张牌
        oneChoice.win  = {}  -- 和牌信息

        local cards = Array.Clone(arrCards)
        -- 删除一张牌 
        Array.RemoveOne(cards, cardRemove)
        local nCheckCount = 0
        for card=CARD_BEGIN,CARD_END do
            if LibFlowerCheck:IsFlowerCard(card) == false 
                and LibConfirmMiss:CheckIsMissCard(nChairID, card ) == false then
                local t = Array.Clone(cards)
                table.insert(t, card)
                nCheckCount = nCheckCount + 1
                if LibRuleWin:CanWin(t) then
                    -- 算番
                    local env  = LibFanCounter:CollectEnv(nChairID)
                    LibFanCounter:SetEnv(env)
                    local stFanCount = LibFanCounter:GetCount()
                    local count = 0
                    for i=1,#stFanCount do
                        count = count + stFanCount[i].byFanNumber
                    end
                     -- oneChoice.win[#oneChoice.win + 1] = { card = card, num = stRoundInfo:GetCardNotShowNum(card) or 0, fan=count}
                     oneChoice.win[#oneChoice.win + 1] = {card, stRoundInfo:GetCardNotShowNum(card) or 0, count}
                     bResult = true
                end
            end
        end
        if #oneChoice.win > 0 then
            self.m_stWinGroup[#self.m_stWinGroup + 1] = oneChoice 
        end

    end

    
    return bResult

end
function LibRuleTing:GetTingGroup()
    return self.m_stWinGroup
end

return LibRuleTing