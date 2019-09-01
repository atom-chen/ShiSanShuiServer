local LibBase = import(".lib_base")
local LibTurnOrder = class("LibTurnOrder", LibBase)

function LibTurnOrder:ctor()

end

function LibTurnOrder:CreateInit(strSlotName)
    local stSlotFuncNames = {"GetNextTurn"}
    self.m_slot  = self:LoadSlot(strSlotName, stSlotFuncNames)
    if self.m_slot == nil then
        return false
    end

    return true
end

function LibTurnOrder:OnGameStart()
    
end

function LibTurnOrder:GetNextTurn(nThisTurn)
    return self.m_slot.GetNextTurn(nThisTurn)
end

function LibTurnOrder:Sort(stTurn)
    self.m_slot.Sort(stTurn)
end

return LibTurnOrder