local LibBase = import(".lib_base")
local LibXiaPao = class("LibXiaPao", LibBase)

function LibXiaPao:ctor()
    self.m_stMiss = {}
    for i=1,PLAYER_NUMBER do
        self.m_stMiss[i] = -1
    end
end

function LibXiaPao:OnGameStart()
    for i=1,PLAYER_NUMBER do
        self.m_stMiss[i] = -1
    end
end

function LibXiaPao:CreateInit()
   return true
end

function LibXiaPao:IsAllXiaPao() 
    for i=1,PLAYER_NUMBER do
        LOG_DEBUG("GET player %d Xiapao value:%d\n", i, self.m_stMiss[i] )
        if self.m_stMiss[i] == -1 then
            return false
        end
    end
    return true
end

function LibXiaPao:IsPlayerXiaPao(nChairID)
    return self.m_stMiss[nChairID] ~= -1 
end

function LibXiaPao:GetPlayerXiaPao(nChairID)
--  没有超时，不设置默认
    if not GGameCfg.GameSetting.bSupportXiaPao then
        if self.m_stMiss[nChairID] == -1 then
           return 0;
        end
    else
        return self.m_stMiss[nChairID]
    end
    return 0
end

function LibXiaPao:ProcessPlayerXiaPao(nChair, Radio)
    if  self.m_stMiss[nChair] ~= -1 then
         LOG_DEBUG("player is Xiapao miss:%d\n", self.m_stMiss[nChair] )
        return -1
    end
    LOG_DEBUG("SET player %d Xiapao value:%d\n", nChair, Radio )
    self.m_stMiss[nChair] = Radio
    return 0
end

return LibXiaPao