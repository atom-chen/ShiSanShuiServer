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

function LibRuleWin:CanWinByLaizi(tPlayerCardArray)
    if GGameCfg.RoomSetting.nGameStyle ~= GAME_STYLE_LANGFANG then
        return false
    end
    
    local laizicard = LibLaiZi:GetLaiZi()
    local nlaizicount = 0
    for i=1,#tPlayerCardArray do
        for j=1,#laizicard do
            if laizicard[j] == tPlayerCardArray[i] then
            nlaizicount = nlaizicount + 1
            end
        end
    end
    
    if nlaizicount == 4 then
        return true   -- 4个混 混杠胡 加10分
    end
    
    return false
end

function LibRuleWin:CanWin(tPlayerCardArray)

    local laizicard = LibLaiZi:GetLaiZi()
    local nlaizicount = 0
    for i=1,#tPlayerCardArray do
        for j=1,#laizicard do
            if laizicard[j] == tPlayerCardArray[i] then
            nlaizicount = nlaizicount + 1
            end
        end
    end
    local ngamestyle = GGameCfg.RoomSetting.nGameStyle
    LOG_DEBUG("\n =========laizicount is======= ===================================== =%d",nlaizicount)
    return LibFanCounter:CheckWin(tPlayerCardArray,nlaizicount,laizicard,ngamestyle)
end

function LibRuleWin:CanGangCi(tPlayerCardArray)
    local nCard = LibCi:GetCi()
    tPlayerCardArray[#tPlayerCardArray + 1] = nCard
    return LibFanCounter:CheckWin(tPlayerCardArray,0,{},GAME_STYLE_LUOYANG)
end


return LibRuleWin