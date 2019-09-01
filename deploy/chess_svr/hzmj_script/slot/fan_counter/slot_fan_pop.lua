local slot = {}

function slot.Init(nMinWin, nBaseBet)
    slot.m_stFanCounter = _GameModule.MJCounter.CreateFanCounterPop()
    if slot.m_stFanCounter == nil then
        return false;
    end
    local iRet = slot.m_stFanCounter:InitFanCounter(nMinWin, nBaseBet)
    if iRet ~= 0 then
        LOG_ERROR("FanCounterPop InitFanCounter Failed. ");
        return false
    end
    return true
end


function slot.SetEnv(env)
    return slot.m_stFanCounter:SetEnvironment(env)
end

function slot.GetCount()
    return slot.m_stFanCounter:GetCount()
end
function slot.GetScore()
    return slot.m_stFanCounter:GetScore()
end
function slot.CheckWin(arrPlayerCards)
    return slot.m_stFanCounter:CheckWin(arrPlayerCards)
end
function slot.InitForNext()
     slot.m_stFanCounter:InitForNext()
end
return slot
