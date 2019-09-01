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
    SSMessage.FlowInternalEvent(stPlayer, "call_ready")
end

function SSMessage.CallPlayerGameStart(stPlayer)
    SSMessage.FlowInternalEvent(stPlayer, "call_startgame")
end

function SSMessage.CallPlayerChangeFlower(stPlayer)
    SSMessage.FlowInternalEvent(stPlayer, "call_changeflower")
end

function SSMessage.CallPlayerChangeCard(stPlayer)
    SSMessage.FlowInternalEvent(stPlayer, "call_changecard")
end

function SSMessage.CallPlayerConfirmMiss(stPlayer)
    SSMessage.FlowInternalEvent(stPlayer, "call_confirmmiss")
end

function SSMessage.CallPlayerXiaPao(stPlayer)
    SSMessage.FlowInternalEvent(stPlayer, "call_xiapao")
end

function SSMessage.CallPlayerPlayStart(stPlayer)
    SSMessage.FlowInternalEvent(stPlayer, "call_startplay")
end

function SSMessage.CallPlayerGiveCard(stPlayer)
    SSMessage.FlowInternalEvent(stPlayer, "call_givecard")
end

function SSMessage.CallPlayerAskPlay(stPlayer)
    SSMessage.FlowInternalEvent(stPlayer, "call_askplay")
end

function SSMessage.CallOtherPlayerGive(stPlayer, nCard)
    local para = { 
        card = nCard,
        playChair = stPlayer:GetChairID(),
    }
    -- SSMessage.FlowInternalEvent(stPlayer, "call_other_player_givecard", para);

    for i=1, PLAYER_NUMBER do
        if i ~= stPlayer:GetChairID() then
            local stOther = stGameState:GetPlayerByChair(i)
            SSMessage.FlowInternalEvent(stOther, "call_other_player_givecard", para)
        end
    end
end

function SSMessage.CallOtherPlayerQiangGang(stPlayer, nCard)
    local para = { 
        card = nCard,
        playChair = stPlayer:GetChairID(),
    }

    for i=1, PLAYER_NUMBER do
        if i ~= stPlayer:GetChairID()  and stPlayer:IsPlayEnd() ~=true  then
            local stOther = stGameState:GetPlayerByChair(i)
            SSMessage.FlowInternalEvent(stOther, "call_other_player_qianggang", para);
        end
    end
end

function SSMessage.CallRobGold(stPlayer, nCard)
    local para = { 
        -- card = nCard,
        -- playChair = stPlayer:GetChairID(),
    }

    SSMessage.FlowInternalEvent(stPlayer, "call_robgold", para)
end

function SSMessage.CallThreeGold(stPlayer, nCard)
    local para = { 
        -- card = nCard,
        -- playChair = stPlayer:GetChairID(),
    }

    SSMessage.FlowInternalEvent(stPlayer, "call_threegold", para)
end

function SSMessage.CallPlayerAddMoney(stPlayer)
    SSMessage.FlowInternalEvent(stPlayer, "call_ask_paymoney")
end

function SSMessage.CallPlayerGangCi(stPlayer)
    SSMessage.FlowInternalEvent(stPlayer, "call_gangci")
end

return SSMessage