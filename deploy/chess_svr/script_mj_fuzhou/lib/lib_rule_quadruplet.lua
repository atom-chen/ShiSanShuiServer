local LibBase = import(".lib_base")
local LibRuleQuadruplet = class("LibRuleQuadruplet", LibBase)

function LibRuleQuadruplet:ctor()
end
function LibRuleQuadruplet:CreateInit(strSlotName)
    local stSlotFuncNames = {
            "IsSupportQuadruplet",
            "IsSupportHiddenQuadruplet",
            "CanQuadrupletCard", 
            "IsQuadrupletGroup",
            "GetQuadrupletCard",
        }
    self.m_slot  = self:LoadSlot(strSlotName, stSlotFuncNames)
    if self.m_slot == nil then
        return false
    end

    return true
end
function LibRuleQuadruplet:OnGameStart()
    
end

function LibRuleQuadruplet:IsSupportQuadruplet()
    return self.m_slot.IsSupportQuadruplet()
end
function LibRuleQuadruplet:IsSupportTriplet2Quadruplet()
    return self.m_slot.IsSupportTriplet2Quadruplet()
end

function LibRuleQuadruplet:IsSupportHiddenQuadruplet()
    return self.m_slot.IsSupportHiddenQuadruplet()
end

function LibRuleQuadruplet:CanQuadrupletCard(arrPlayerCards, nCard)
    return self.m_slot.CanQuadrupletCard(arrPlayerCards, nCard)
end
function LibRuleQuadruplet:IsQuadrupletGroup(arrCards)
    return self.m_slot.IsQuadrupletGroup(arrCards)
end
function LibRuleQuadruplet:GetQuadrupletCard(arrCards)
    return self.m_slot.GetQuadrupletCard(arrCards)
end


return LibRuleQuadruplet