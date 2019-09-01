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

function LibGetBanker:DoDealer(bCounterLian)
    local stRoundInfo = GRoundInfo
    local nPrepare = stRoundInfo:GetPrepareBanker()
    --local stRoundInfo = GRoundInfo
    local nGameStyle = GGameCfg.RoomSetting.nGameStyle
    if nGameStyle == GAME_STYLE_GUOBIAO then
        stRoundInfo:SetBanker(stRoundInfo:GetPrepareBanker())
        stRoundInfo:SetLianZhuangCount(0)
    elseif nGameStyle == GAME_STYLE_CHENGDU then
        if nPrepare <=0 or nPrepare > PLAYER_NUMBER then
            nPrepare = stRoundInfo:GetBanker()
            stRoundInfo:SetPrepareBanker(nPrepare)
        end
        if nPrepare ~= stRoundInfo:GetBanker() then
            stRoundInfo:SetLianZhuangCount(0)
        end
        stRoundInfo:SetBanker(nPrepare)
    else
        -- 设置为预庄家
        stRoundInfo:SetBanker(nPrepare)
    end
    if bCounterLian then
         stRoundInfo:SetLianZhuangCount(stRoundInfo:GetLianZhuangCount() + 1)
    end
     stRoundInfo:SetPrepareBanker(-1)
end


return LibGetBanker