local LibBase = import(".lib_base")
local LibRuleTriplet = class("LibRuleTriplet", LibBase)

function LibRuleTriplet:ctor()
end
function LibRuleTriplet:CreateInit(strSlotName)
    local stSlotFuncNames = {"IsSupportTriplet", "CanTriplet", "GetTripletCard"}
    self.m_slot = self:LoadSlot(strSlotName, stSlotFuncNames)
    if self.m_slot == nil then
        return false
    end

    return true
end
function LibRuleTriplet:OnGameStart()
    
end

function LibRuleTriplet:IsSupportTriplet()
    return self.m_slot.IsSupportTriplet()
end

function LibRuleTriplet:CanTriplet(stPlayerCardArray, nCard)
    return self.m_slot.CanTriplet(stPlayerCardArray, nCard)
end

function LibRuleTriplet:GetTripletCard(stPlayerCardArray, nCard)
    return self.m_slot.GetTripletCard(stPlayerCardArray, nCard)
end


return LibRuleTriplet