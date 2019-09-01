local LibBase = import(".lib_base")
local LibCardPool = class("LibCardPool", LibBase)

function LibCardPool:ctor()
end
function LibCardPool:CreateInit(strSlotName)
    local stSlotFuncNames = {"GetCardSet"}
    self.m_slot  = self:LoadSlot(strSlotName, stSlotFuncNames)
    if self.m_slot == nil then
        return false
    end

    return true
end
function LibCardPool:OnGameStart() 
end

function LibCardPool:GetCardSet()
    return self.m_slot.GetCardSet()
end

return LibCardPool