local LibBase = import(".lib_base")
local LibRuleCollect = class("LibRuleCollect", LibBase)

function LibRuleCollect:ctor()
end
function LibRuleCollect:CreateInit(strSlotName)
    local stSlotFuncNames = {"IsSupportCollect", "CanCollect", "GetCollectGroup"}
    self.m_slot  = self:LoadSlot(strSlotName, stSlotFuncNames)
    if self.m_slot == nil then
        return false
    end

    return true
end
function LibRuleCollect:OnGameStart()
    
end
function LibRuleCollect:IsSupportCollect()
    return self.m_slot.IsSupportCollect()
end

function LibRuleCollect:CanCollect(stPlayerCardArray, nCard)
    return self.m_slot.CanCollect(stPlayerCardArray, nCard)
end
function LibRuleCollect:GetCollectGroup(stPlayerCardArray,nCard)
    return self.m_slot.GetCollectGroup(stPlayerCardArray,nCard)
end


return LibRuleCollect