local FlowEventMng = import("framework.flow_event_mng")
local TimerMng = import("framework.timer_mng")
local stFlowEventMng = nil
local stTimerMng = nil
local stGameCfg = {}
FlowFramework = FlowFramework or {}

function FlowFramework.Init(str_gsc, _gid, cfgjson, gamejson)
    FlowFramework.LoadGameCfg(str_gsc, _gid, cfgjson, gamejson)

    stFlowEventMng = FlowEventMng.new() 
    stTimerMng = TimerMng.new()
    return 0
end

function FlowFramework.LoadGameCfg(str_gsc, gid, cfgjson, gamejson)
    stGameCfg = import(str_gsc)
end
function FlowFramework.GetGameCfg()
    return stGameCfg
end


function FlowFramework.FlowEventTrigger(stFlowObj, stEvent)
    stFlowEventMng:AddEvent(stFlowObj, stEvent)
end

function FlowFramework.Dispath()
    stFlowEventMng:Dispath()

end
function FlowFramework.OnTimer()
    stTimerMng:OnTimer()
end
function FlowFramework.SetTimer(nChair, nInterval, nTimerID, nTimers)
    if nInterval < 0 then
        return
    end
    --LOG_ERROR("SetTimer nChair : %d", nChair)
    nTimerID = nTimerID or 0
    nTimers = nTimers or 1
    stTimerMng:RegistTimerEvent(nChair, nTimerID, nInterval * 1000, nTimers)
end

function FlowFramework.SetTimer_mi(nChair, nInterval, nTimerID, nTimers)
    if nInterval < 0 then
        return
    end
    --LOG_ERROR("SetTimer nChair : %d", nChair)
    nTimerID = nTimerID or 0
    nTimers = nTimers or 1
    -- --先删除
    -- stTimerMng:DelTimer(nChair, nTimerID)
    --再添加
    stTimerMng:RegistTimerEvent(nChair, nTimerID, nInterval, nTimers)
end

function FlowFramework.DelTimer(nChair, nTimerID)
    --LOG_ERROR("DelTimer nChair : %d", nChair)
    stTimerMng:DelTimer(nChair, nTimerID)
end

function FlowFramework.GetTimerLeftSecond(nChairID , nTimerID)
    nTimerID = nTimerID or 0
    return stTimerMng:GetTimerLeftSecond(nChairID , nTimerID)
end
function FlowFramework.CheckHaveTimer(nChairID , nTimerID)
    nTimerID = nTimerID or 0
    return stTimerMng:CheckHaveTimer(nChairID , nTimerID)
end