local LibBase = import(".lib_base")
local LibGameEndJudge = class("LibGameEndJudge", LibBase)

function LibGameEndJudge:ctor()

end

function LibGameEndJudge:CreateInit(strSlotName)
    local stSlotFuncNames = {}
    self.m_slot  = self:LoadSlot(strSlotName, stSlotFuncNames)
    if self.m_slot == nil then
        return false
    end
    return true
end

function LibGameEndJudge:OnGameStart()

end

function LibGameEndJudge:IsGameEnd(nWinPlayerNums, nDealCardLeft, nDealerCardLeftEXceptGang)
    return self.m_slot.IsGameEnd(nWinPlayerNums, nDealCardLeft, nDealerCardLeftEXceptGang)
end


return LibGameEndJudge