local LibBase = import(".lib_base")
local LibConfirmMiss = class("LibConfirmMiss", LibBase)

function LibConfirmMiss:ctor()
    self.m_stMiss = {}
    for i=1,PLAYER_NUMBER do
        self.m_stMiss[i] = 0
    end
end
function LibConfirmMiss:CreateInit(strSlotName)
    local stSlotFuncNames = {"GetMissOptional", "GetBestMiss"}
    self.m_slot  = self:LoadSlot(strSlotName, stSlotFuncNames)
    if self.m_slot == nil then
        return false
    end

    return true
end
function LibConfirmMiss:OnGameStart()
    for i=1,PLAYER_NUMBER do
        self.m_stMiss[i] = 0
    end
end
function LibConfirmMiss:IsAllConfirmed() 
    for i=1,PLAYER_NUMBER do
        if self.m_stMiss[i] == 0 then
            return false
        end
    end
    return true
end
function LibConfirmMiss:IsPlayerConfirmed(nChairID)
    return self.m_stMiss[nChairID] ~= 0 
end

function LibConfirmMiss:ProcessPlayerConfirmMiss(nChair, nMissCardType)
    if  self.m_stMiss[nChair] ~= 0 then
         LOG_ERROR("player is confirmed miss:%d\n", self.m_stMiss[nChair] )
        return ERROR_CONFIRMMISS_CONFIRMED
    end
    local bIsAcceptVal = false
    local arrOptional = self:GetMissOptional()
    for _,optional in pairs(arrOptional) do
         if optional == nMissCardType then
             bIsAcceptVal= true
             break
         end
    end
    if bIsAcceptVal == false then
        LOG_ERROR("nMissCardType:%d arrOptional:%s\n", nMissCardType, vardump(arrOptional))
        return ERROR_CONFIRMMISS_MISSTYPE
    end
    self.m_stMiss[nChair] = nMissCardType
    return 0
end
function LibConfirmMiss:GetPlayerMissCard(nChair)
    if nChair < 0 or nChair > PLAYER_NUMBER then
        return 0
    end
    return self.m_stMiss[nChair]
end

function LibConfirmMiss:GetBestMiss(stCardArr)
    return self.m_slot.GetBestMiss(stCardArr)
end
function LibConfirmMiss:GetMissOptional()
    return self.m_slot.GetMissOptional()
end

-- 检查 arrCards 中是否有定缺牌
function LibConfirmMiss:CheckHasMissCard(nChair, arrCards)
    if self.m_stMiss[nChair] == 0 then
        return false
    end
    for i=1,#arrCards do
        if GetCardType(arrCards[i]) == self.m_stMiss[nChair] then
            return true
        end
    end
    return false
end
-- 检查 nCard 是不是定缺牌
function LibConfirmMiss:CheckIsMissCard(nChair, nCard)
     if self.m_stMiss[nChair] == 0 then
        return false
    end
     if GetCardType(nCard) == self.m_stMiss[nChair] then
        return true
    end
    return false

end

return LibConfirmMiss