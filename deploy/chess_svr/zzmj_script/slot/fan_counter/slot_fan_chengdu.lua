local slot = {}
local CURRENT_MODULE_NAME = ...

function slot.Init(nMinWin, nBaseBet)
    
    slot.m_stFanCounter = _GameModule.MJCounter.CreateFanHongZhongYH()

    if slot.m_stFanCounter == nil then
        LOG_ERROR("CreateFanHongZhongYH  Failed. ");
        return false
    end
    local iRet = slot.m_stFanCounter:InitFanCounter(nMinWin, nBaseBet)
    if iRet ~= 0 then
        LOG_ERROR("FanCounterChengDu InitFanCounter Failed. ");
        return false
    end
    return true
end
function slot.InitFanChengDuCounter(nStyle, bZiMoJiaDi, bJiaJiaYou)
    local iRet = slot.m_stFanCounter:InitFanChengDuCounter(nStyle, bZiMoJiaDi, bJiaJiaYou)
    if iRet ~= 0 then
        LOG_ERROR("FanCounterChengDu InitFanChengDuCounter Failed. ")
        return false
    end
    return true
end
function slot.SetEnv(env)
    slot.m_stFanCounter:SetEnvironment(env)
    return 0
end

function slot.GetCount()
    return slot.m_stFanCounter:GetCount()
end
--[[
--   四家胡情况 血战情况下 需要设置 lua层做过滤
function slot.SetHuInfo(stHuInfo)
    slot.m_stFanCounter:SetHuInfoBeforeGetScore(stHuInfo)
end
 ]]

function slot.GetScore()
    return slot.m_stFanCounter:GetScore()
end
function slot.CheckWin(arrPlayerCards,nlaizicount,laizicard)
    return slot.m_stFanCounter:CheckWin(arrPlayerCards,nlaizicount,laizicard)
end
function slot.InitForNext()
     slot.m_stFanCounter:InitForNext()
end
return slot
