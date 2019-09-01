local FlowObject = class("FlowObject")
function FlowObject:ctor()
    self.m_stFlowProcess = {}
end
function FlowObject:AddFlow(stFlowProcess)
        self.m_stFlowProcess[#self.m_stFlowProcess+ 1] = stFlowProcess
end
function FlowObject:ClearFlow()
    self.m_stFlowProcess = {}
end
function FlowObject:OnEvent(stEvent)
    for _,stFlowProcess in pairs(self.m_stFlowProcess) do
        stFlowProcess:OnEvent(self, stEvent._cmd, stEvent)
        LOG_DEBUG("OnEvent:%s ", stEvent._cmd)
    end
end
function FlowObject:IsAllFlowFree()
    for _,stFlowProcess in pairs(self.m_stFlowProcess) do
        if stFlowProcess:IsFree() == false then
            return false
        end
    end
    return true
end

return FlowObject