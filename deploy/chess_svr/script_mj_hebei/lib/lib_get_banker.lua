-- 加载 slot/change_card
local LibBase = import(".lib_base")
local LibGetBanker = class("LibGetBanker", LibBase)
function LibGetBanker:ctor()
    self.m_stBankerRecord = {}
end

function LibGetBanker:CreateInit(strSlotName)
    local stSlotFuncNames = {"GetBanker"}
    self.m_slot  = self:LoadSlot(strSlotName, stSlotFuncNames)
    if self.m_slot == nil then
        return false
    end   
    self.m_stBankerRecord = {}
    return true
end
function LibGetBanker:OnGameStart()
    self.m_stBankerRecord = {}
end

function LibGetBanker:GetBanker()
    local nLastBanker = 0
    if #self.m_stBankerRecord > 0 then
        nLastBanker = self.m_stBankerRecord[#self.m_stBankerRecord]
    end
    return self.m_slot.GetBanker(nLastBanker)
end

function LibGetBanker:GetLastBanker()
    local nLastBanker = 0
    if #self.m_stBankerRecord > 0 then
        nLastBanker = self.m_stBankerRecord[#self.m_stBankerRecord]
    end
    return nLastBanker
end

function LibGetBanker:AddBankerRecord(nBanker)
    self.m_stBankerRecord[#self.m_stBankerRecord + 1] = nBanker 
end

function LibGetBanker:DoDealer(bCounterLian, bFirstRound)
    local stRoundInfo = GRoundInfo
    local nLastWinner = stRoundInfo:GetLastWinner()
    local nBanker = stRoundInfo:GetBanker()
    LOG_DEBUG("LibGetBanker:DoDealer...nLastWinner: %d, nBanker: %d, bFirstRound:%s", nLastWinner, nBanker, tostring(bFirstRound))

    if nLastWinner ~= nBanker then
        --不是第一轮 轮到此庄家下一个玩家
        if not bFirstRound then
            local nNextBanker = LibTurnOrder:GetNextTurn(nBanker)
            LOG_DEBUG("LibGetBanker:DoDealer...nNextBanker: %d", nNextBanker)
            stRoundInfo:SetBanker(nNextBanker)
        end
        stRoundInfo:SetLianZhuangCount(0)
    else
        local nCount = stRoundInfo:GetLianZhuangCount()
        if bFirstRound then
            stRoundInfo:SetLianZhuangCount(nCount)
        else
            stRoundInfo:SetLianZhuangCount(nCount + 1)
        end
    end
end


return LibGetBanker