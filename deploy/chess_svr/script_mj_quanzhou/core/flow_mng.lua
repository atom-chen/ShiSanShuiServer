local FlowMng = class("FlowMng")

function FlowMng:ctor()
    self.m_stAllFlow = {}
end

function FlowMng:AddFlow(nChair, pFlow)
    self.m_stAllFlow[nChair] = pFlow
end

function FlowMng:GetFlowByGameUser(nChair)
    return self.m_stAllFlow[nChair] 
end


return FlowMng