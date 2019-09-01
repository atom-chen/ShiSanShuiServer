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
    local timeNow =  math.floor(socket.gettime()*1000)
    self.m_stAllTimer[nChairID] = self.m_stAllTimer[nChairID] or  {}
    local timer = {
        id = nTimerID, 
        interval = iIntervalSecond,
        doTimes = 0,
        creatTime = timeNow, -- tmp
        lastDoTime = timeNow,
        maxTimes = iTimes
    }
    local len = #self.m_stAllTimer[nChairID] 
    self.m_stAllTimer[nChairID][len+1] =  timer
end
function TimerMng:DelTimer(nChairID,nTimerID )
    local timers = self.m_stAllTimer[nChairID]
    if timers == nil then
        return
    end

    local index = 1
    while index <= #timers do
        local timer = timers[index]
        if timer.id == nTimerID then
            table.remove(timers, index)
        else
            index = index+1
        end
    end
end
function TimerMng:GetTimerLeftSecond(nChairID ,nTimerID)
    local timers = self.m_stAllTimer[nChairID]
    if timers == nil then
        return 0
    end

    local timeNow =  math.floor(socket.gettime()*1000)
    for i=1,#timers do
        local this_timer = timers[i]
        if this_timer.id == nTimerID then
            local nLeftTime = this_timer.lastDoTime + this_timer.interval - timeNow
            -- LOG_DEBUG("GetTimerLeftSecond==SSSSSSSSSSSSS=nLeftTime=%d=interval=%d==-1.\n",nLeftTime,this_timer.interval);
            if nLeftTime < 0  or nLeftTime > this_timer.interval  then
                -- LOG_DEBUG("GetTimerLeftSecond===nLeftTime=%d=interval=%d==-1.\n",nLeftTime,this_timer.interval);
                return 0
            else
                return math.floor(nLeftTime / 1000)
            end
        end
    end
    return 0
end
function TimerMng:OnTimer()
    local timeNow =  math.floor(socket.gettime()*1000)
    
    for nChair,stChairTimers in pairs(self.m_stAllTimer) do
        local index = 1
        while index <= #stChairTimers do
            local stTimer = stChairTimers[index]
            if timeNow - stTimer.lastDoTime >= stTimer.interval then
                stTimer.doTimes = stTimer.doTimes + 1
                stTimer.lastDoTime = timeNow
              
                -- post
                --timeid为-1时不发timeout事件
                if stTimer.id == -1 then
                    -- LOG_DEBUG("OnTimer===timeid====-1.\n")
                else
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
        stUserObject = GDealer
    end

    FlowFramework.FlowEventTrigger(stUserObject, event)
end

function TimerMng:CheckHaveTimer(nChairID ,nTimerID)
    local timers = self.m_stAllTimer[nChairID]
    if timers == nil then 
        return false
    end

    local timeNow =  math.floor(socket.gettime()*1000)
    for i=1,#timers do
        local this_timer = timers[i]
        if this_timer.id == nTimerID then
            local nLeftTime = this_timer.lastDoTime + this_timer.interval - timeNow
            if nLeftTime <0  or nLeftTime > this_timer.interval  then
                -- LOG_DEBUG("GetTimerLeftSecond===nLeftTime=%d=interval=%d==-1.\n",nLeftTime,this_timer.interval);
                return true, 0
            else
                return true, nLeftTime
            end
        end
    end
    return false
end
return TimerMng