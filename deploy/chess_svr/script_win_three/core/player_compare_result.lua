--[[
-- 玩家比牌结果 
--]]
local PlayerCompareResult = class("PlayerCompareResult")
function PlayerCompareResult:ctor()
    self.m_stShoot = {}         --打枪列表 保存是对方椅子号chairid
    self.m_stScoreResult = {}        --详细比牌积分结果(保存除自己外所有玩家的比牌结果)
    self.m_nAllShoot = 0        --是否是全垒打:-1被全垒打，1自己全垒打，0没有全垒打
    self.m_nTotallScore = 0     --最终积分
    self:Clear()
end

function PlayerCompareResult:Clear()
    self.m_stShoot_list = {}
    self.m_stScoreResult = {}
    self.m_nAllShoot = 0
    self.m_nTotallScore = 0
end

--打枪
function PlayerCompareResult:AddShoot(nChairID)
    table.insert(self.m_stShoot, nChairID)
end
function PlayerCompareResult:GetShootCount()
    return #self.m_stShoot
end
function PlayerCompareResult:GetShootList()
    local t = Array.Clone(self.m_stShoot)
    return t
end

--比牌结果
function PlayerCompareResult:AddScoreResult(stResult)
    table.insert(self.m_stScoreResult, stResult)
end
function PlayerCompareResult:GetScoreResult()
    local t = {}
    for _, v in pairs(self.m_stScoreResult) do
        local result = {}
        result.toChairid = v.toChairid
        result.nFirstScore = v.nFirstScore
        result.nFirstScoreExt = v.nFirstScoreExt
        result.nSecondScore = v.nSecondScore
        result.nSecondScoreExt = v.nSecondScoreExt
        result.nThirdScore = v.nThirdScore
        result.nThirdScoreExt = v.nThirdScoreExt
        result.nSpecialScore = v.nSpecialScore

        result.nShoot = v.nShoot
        result.nShootMult = v.nShootMult
        result.nHasCode = v.nHasCode
        result.nCodeMult = v.nCodeMult
        result.nWanterMult = v.nWanterMult
        result.nFinalScore = v.nFinalScore

        table.insert(t, result)
    end
    return t
end

--全垒打
function PlayerCompareResult:SetAllShoot(nAllShoot)
    self.m_nAllShoot = nAllShoot
end
function PlayerCompareResult:IsAllShoot()
    return self.m_nAllShoot > 0
end

--最终积分
function PlayerCompareResult:GetTotallScore()
    return self.m_nTotallScore
end
function PlayerCompareResult:SetTotallScore(nTotall)
    self.m_nTotallScore = nTotall
end
function PlayerCompareResult:CalculateTotallScore()
    local nTotall = 0
    for _, v in pairs(self.m_stScoreResult) do
        nTotall = nTotall + v.nFinalScore
    end
    --水庄不支持全垒打
    if GGameCfg.GameSetting.bSupportWaterBanker == false and self.m_nAllShoot ~= 0 then
        nTotall = nTotall * 2
    end

    self.m_nTotallScore = nTotall

    return self.m_nTotallScore
end

return PlayerCompareResult