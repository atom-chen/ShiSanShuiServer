local LibBase = import(".lib_base")
local LibAutoPlay = class("LibAutoPlay", LibBase)

function LibAutoPlay:ctor()
    self.m_iTimeOutCount = {}
end

function LibAutoPlay:OnGameStart()
    for i=1,PLAYER_NUMBER do
        self.m_iTimeOutCount[i] = 0
    end
end

function LibAutoPlay:AddPlayerTimeOut(nChairID)
    self.m_iTimeOutCount[nChairID] = self.m_iTimeOutCount[nChairID] + 1
end

function LibAutoPlay:ResetPlayerTimeOut(nChairID)
    self.m_iTimeOutCount[nChairID] = 0
end

function LibAutoPlay:GetPlayerTimeOutCount( nChairID )
    return self.m_iTimeOutCount[nChairID]
end

function LibAutoPlay:GetPlayerNeedTrust( nChairID )
    -- 不超时的情况
    if GGameCfg.GameSetting.nTimeOutCountToAuto == -1 then
        return false;
    end
    
    return self.m_iTimeOutCount[nChairID] >= GGameCfg.GameSetting.nTimeOutCountToAuto
end

return LibAutoPlay