local list = import("common.list")
local FlowEventMng = {}
local mt = { __index = FlowEventMng }

function FlowEventMng.new()
    local s = setmetatable( {}, mt)
    s.m_stEventQueue =  list.new()
    return s
end

function FlowEventMng:AddEvent(obj, stEvent)
    -- LOG_DEBUG("FlowEventMng:AddEvent stEvent._cmd:%s", stEvent._cmd)
    self.m_stEventQueue:PushBack({obj = obj, event = stEvent})
end

function FlowEventMng:Dispath()
    while self.m_stEventQueue:Size() > 0 do
        local st = self.m_stEventQueue:PopFront()
        if st and st.obj then
            st.obj:OnEvent( st.event)
        end
    end
end

return FlowEventMng