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
    if GGameCfg.GameSetting.bSupportGangCi then
        local nCard = LibCi:GetCi()
        local nciCount = 0
        for i=1,#tPlayerCardArray do
            if nCard == tPlayerCardArray[i] then
                nciCount = nciCount + 1
            end
        end
        if nciCount >= 3 then
            return true
        end
    end

    local laizicard = LibLaiZi:GetLaiZi()
    local nlaizicount = 0
    for i=1,#tPlayerCardArray do
        for j=1,#laizicard do
            if laizicard[j] ==tPlayerCardArray[i] then
            nlaizicount= nlaizicount +1
            end
        end
    end
    local ngamestyle = GGameCfg.RoomSetting.nGameStyle
    LOG_DEBUG("\n =========laizicount is======= ===================================== =%d",nlaizicount)
    return LibFanCounter:CheckWin(tPlayerCardArray,nlaizicount,laizicard,ngamestyle)
    --return self.m_slot.CanWin(tPlayerCardArray)
end

function LibRuleWin:CanGangCi(tPlayerCardArray)
    local nCard = LibCi:GetCi()
    tPlayerCardArray[#tPlayerCardArray + 1] = nCard
    return LibFanCounter:CheckWin(tPlayerCardArray,0,{},GAME_STYLE_LUOYANG)
end


return LibRuleWin