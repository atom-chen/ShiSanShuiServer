
require "common.socket"

local TimerMng = {}
local mt = { __index = TimerMng }
function TimerMng.new()
    local s = setmetatable( {}, mt)
    s.m_stAllTimer =  {}
     s.m_stTimeoutList =  {}
    return s
end

function TimerMng:RegistTimerEvent(nChairID, nTimerID, iIntervalSecond, iTimes)

    local timeNow =  math.floor(socket.gettime()*1000) --os.time()
    self.m_stAllTimer[nChairID] = self.m_stAllTimer[nChairID] or  {}
    local timer = {
        id = nTimerID, 
        interval = iIntervalSecond,
        doTimes = 0,
        creatTime = timeNow, -- tmp
        lastDoTime = timeNow,
        maxTimes = iTimes
    }
    LOG_DEBUG("to add timer. chair=%d, id=%d\n", nChairID, nTimerID);
    local len = #self.m_stAllTimer[nChairID] 
    self.m_stAllTimer[nChairID][len+1] =  timer
end
function TimerMng:DelTimer(nChairID,nTimerID )
    LOG_DEBUG("to remove timer. chair=%d, id=%d\n", nChairID, nTimerID);
    local timers = self.m_stAllTimer[nChairID]
    if timers == nil then return end

    local index = 1
    while index <= #timers do
        local timer = timers[index]
        if timer.id == nTimerID then
            LOG_DEBUG("remove timer. chair=%d, id=%d, ntimers=%d, idx=%d\n", nChairID, nTimerID, #timers, index);
            table.remove(timers, index)
            LOG_DEBUG("remove timer. chair=%d, id=%d, ntimers=%d\n", nChairID, nTimerID, #timers);
        else
            index = index+1
        end
    end
end
function TimerMng:GetTimerLeftSecond(nChairID ,nTimerID)
    local timers = self.m_stAllTimer[nChairID]
    if timers == nil then return 0 end

    local timeNow =  math.floor(socket.gettime()*1000) --os.time()
    for i=1,#timers do
        local this_timer = timers[i];
        if this_timer.id == nTimerID then
            local nLeftTime = this_timer.lastDoTime + this_timer.interval - timeNow
            if nLeftTime <0  or nLeftTime > this_timer.interval  then
                LOG_DEBUG("GetTimerLeftSecond===nLeftTime=%d=interval=%d==-1.\n",nLeftTime,this_timer.interval);
                return 0
            else
                return nLeftTime / 1000
            end
        end
    end
    return 0;
end
function TimerMng:OnTimer()
    local timeNow =  math.floor(socket.gettime()*1000) --os.time()
    
    for nChair,stChairTimers in pairs(self.m_stAllTimer) do
        local index = 1
        while index <= #stChairTimers do
            local stTimer = stChairTimers[index]
            LOG_DEBUG("Last:%d, now:%d, interval:%d,char:%d\n", stTimer.lastDoTime, timeNow, stTimer.interval , nChair)
            if timeNow - stTimer.lastDoTime >= stTimer.interval then
                stTimer.doTimes = stTimer.doTimes + 1
                stTimer.lastDoTime = timeNow
              
                -- post
                --timeid为-1时不发timeout事件
                if stTimer.id ==-1 then
                    LOG_DEBUG("OnTimer===timeid====-1.\n");
                else
                    LOG_DEBUG("chair:%d SendEvent.\n", nChair);

                    self:SendTimerEvent(nChair, stTimer.id)
                end
                FlowFramework.Dispath()
                if stTimer.doTimes == stTimer.maxTimes then
                    table.remove(stChairTimers, index)
                else
                    index = index + 1
                end
            else
                index = index + 1
            end
        end

    end
end

function TimerMng:SendTimerEvent(nChair, nTimerID)
    local event = {
        _cmd = "timeout",
        _src = "",
        _para = "",
        _st = "event"
    }
    local stUserObject = GGameState:GetPlayerByChair(nChair)
    if stUserObject == nil then
        LOG_DEBUG("NILLLLLLLLLLLLLLLLLLLLLLLLLL, chair=%d\n", nChair)
        stUserObject = GDealer
    end

    FlowFramework.FlowEventTrigger(stUserObject, event)
end

function TimerMng:CheckHaveTimer(nChairID ,nTimerID)
    local timers = self.m_stAllTimer[nChairID]
    if timers == nil then 
        return false
    end

    local timeNow =  math.floor(socket.gettime()*1000) --os.time()
    for i=1,#timers do
        local this_timer = timers[i]
        if this_timer.id == nTimerID then
            local nLeftTime = this_timer.lastDoTime + this_timer.interval - timeNow
            if nLeftTime <0  or nLeftTime > this_timer.interval  then
                LOG_DEBUG("GetTimerLeftSecond===nLeftTime=%d=interval=%d==-1.\n",nLeftTime,this_timer.interval);
                return true, 0
            else
                return true, nLeftTime
            end
        end
    end
    return false
end
return TimerMng