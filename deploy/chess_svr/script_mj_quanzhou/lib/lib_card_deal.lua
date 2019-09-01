local LibBase = import(".lib_base")
local LibCardDeal = class("LibCardDeal", LibBase)

function LibCardDeal:ctor()

end

function LibCardDeal:CreateInit(strSlotName)
    local stSlotFuncNames = {"DoDeal"}
    self.m_slot  = self:LoadSlot(strSlotName, stSlotFuncNames)
    if self.m_slot == nil then
        return false
    end

    return true
end

function LibCardDeal:OnGameStart()
    
end

function LibCardDeal:DoDeal(cards)
    return self.m_slot.DoDeal(cards)
end


return LibCardDeal