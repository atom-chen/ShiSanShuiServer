local LibBase = import(".lib_base")
local LibTrustAuto = class("LibTrustAuto", LibBase)

function LibTrustAuto:ctor()
end
function LibTrustAuto:CreateInit(strSlotName)
    local stSlotFuncNames = {"TrustPlayCard"}
    self.m_slot  = self:LoadSlot(strSlotName, stSlotFuncNames)
    if self.m_slot == nil then
        return false
    end

    return true
end
function LibTrustAuto:OnGameStart()
    
end
function LibTrustAuto:TrustPlayCard(arrPlayerCards, bIsTing, bIsTingCanPlayerOther)
    return self.m_slot.TrustPlayCard(arrPlayerCards, bIsTing, bIsTingCanPlayerOther)
end


return LibTrustAuto