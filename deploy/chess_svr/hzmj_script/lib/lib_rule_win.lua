local LibBase = import(".lib_base")
local LibRuleWin = class("LibRuleWin", LibBase)

function LibRuleWin:ctor()
end
function LibRuleWin:CreateInit(strSlotName)
    local stSlotFuncNames = {"CanWin"}
    self.m_slot  = self:LoadSlot(strSlotName, stSlotFuncNames)
    if self.m_slot == nil then
        return false
    end

    return true
end
function LibRuleWin:OnGameStart()
    
end

function LibRuleWin:CanWin(tPlayerCardArray)

    local laizicard = LibLaiZi:GetLaiZi()
    local nlaizicount = 0
    for i=1,#tPlayerCardArray do
        for j=1,#laizicard do
            if laizicard[j] ==tPlayerCardArray[i] then
            nlaizicount= nlaizicount +1
            end
        end
    end
    LOG_DEBUG("\n =========laizicount is======= ===================================== =%d",nlaizicount)
    return LibFanCounter:CheckWin(tPlayerCardArray,nlaizicount,laizicard)
    --return self.m_slot.CanWin(tPlayerCardArray)
end

return LibRuleWin