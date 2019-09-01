local LibBase = import(".lib_base")
local LibFlowerCheck = class("LibFlowerCheck", LibBase)

function LibFlowerCheck:ctor()
end
function LibFlowerCheck:CreateInit(strSlotName)
    local stSlotFuncNames = {"IsFlowerCard"}
    self.m_slot  = self:LoadSlot(strSlotName, stSlotFuncNames)
    if self.m_slot == nil then
        return false
    end

    return true
end

function LibFlowerCheck:OnGameStart()   
end

function LibFlowerCheck:IsFlowerCard(nCard)
    return self.m_slot.IsFlowerCard(nCard)
end
return LibFlowerCheck