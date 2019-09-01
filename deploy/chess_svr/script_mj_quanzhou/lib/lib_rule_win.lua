local LibBase = import(".lib_base")
local LibRuleWin = class("LibRuleWin", LibBase)

function LibRuleWin:ctor()

end

function LibRuleWin:CreateInit(strSlotName)
    local stSlotFuncNames = {"CanWin"}
    self.m_slot = self:LoadSlot(strSlotName, stSlotFuncNames)
    if self.m_slot == nil then
        return false
    end

    return true
end

function LibRuleWin:OnGameStart()
  
end

function LibRuleWin:CanWin(tPlayerCardArray)
    local laizicard = LibGoldCard:GetGoldCards()
    -- LOG_DEBUG("LibRuleWin:CanWin...laizicard:%s, tPlayerCardArray:%s", vardump(laizicard), vardump(tPlayerCardArray))
    local nlaizicount = 0
    for i=1,#tPlayerCardArray do
        for j=1,#laizicard do
            if laizicard[j] == tPlayerCardArray[i] then
                nlaizicount= nlaizicount +1
            end
        end
    end
    -- LOG_DEBUG("\n =========laizicount is========%d",nlaizicount)
    local ngamestyle = GGameCfg.RoomSetting.nGameStyle
    return LibFanCounter:CheckWin(tPlayerCardArray,nlaizicount,laizicard,ngamestyle)
end

--自摸时：检查三金倒
function LibRuleWin:CanWinThreeGold(tPlayerCardArray)
    if GGameCfg.RoomSetting.nGameStyle == GAME_STYLE_QUANZHOU then
        if not GGameCfg.GameSetting.bSupportSanJinDao then
            return false
        end
    end
    
    local stGoldCards = LibGoldCard:GetGoldCards()
    local nGoldCount = 0
    for i=1,#tPlayerCardArray do
        for j=1,#stGoldCards do
            if stGoldCards[j] == tPlayerCardArray[i] then
                nGoldCount= nGoldCount +1
            end
        end
    end
    LOG_DEBUG("LibRuleWin:CanWinThreeGold...nGoldCount:%d, stGoldCards:%s\n, tPlayerCardArray:%s\n", nGoldCount, vardump(stGoldCards), vardump(tPlayerCardArray))
    return (nGoldCount >= 3)
end

return LibRuleWin