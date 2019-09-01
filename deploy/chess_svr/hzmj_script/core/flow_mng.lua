local FlowMng = class("FlowMng")

function FlowMng:ctor()
    self.m_stAllFlow = {}
end
function FlowMng:AddFlow(nChair, pFlow)
    self.m_stAllFlow[nChair] = pFlow
end
function FlowMng:GetFlowByGameUser(nChair)
    return self.m_stAllFlow[nChair] 
    --[[
    for _user,pFlow in pairs(self.m_stAllFlow) do
        if _user.nSeatID == stGameUser.nSeatID and 
            _user.nSeatID == stGameUser.nSeatID and 
            _user.nSeatID == stGameUser.nSeatID then
            return pFlow
        end
    end
     ]]
    return nil
end
return FlowMng