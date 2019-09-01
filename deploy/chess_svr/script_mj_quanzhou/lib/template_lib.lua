local LibBase = import(".lib_base")
local LibTemplate = class("LibTemplate", LibBase)

function LibTemplate:ctor()

end

function LibTemplate:CreateInit(strSlotName)
    local stSlotFuncNames = {}
    self.m_slot  = self:LoadSlot(strSlotName, stSlotFuncNames)
    if self.m_slot == nil then
        return false
    end

    return true
end

function LibTemplate:OnGameStart()
    
end


return LibTemplate