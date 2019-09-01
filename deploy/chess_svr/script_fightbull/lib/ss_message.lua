local SSMessage = SSMessage or {}
local  stGameState = nil
local stRoundInfo = nil
function SSMessage.CreateInit()
    stGameState = GGameState
    stRoundInfo = GRoundInfo
    return true
end

function SSMessage.FlowInternalEvent (stTarget, event, para)
    local call = {
        _cmd = event,
        _st = "event",
        _para = para or {}
    }
    FlowFramework.FlowEventTrigger(stTarget, call)
end

function SSMessage.WakeupDealer()
    SSMessage.FlowInternalEvent(GDealer, "timeout")
end

function SSMessage.CallPlayerReady(stPlayer)
    SSMessage.FlowInternalEvent(stPlayer, "call_ready");
end

function SSMessage.CallPlayerGameStart(stPlayer)
    SSMessage.FlowInternalEvent(stPlayer, "call_startgame");
end

return SSMessage