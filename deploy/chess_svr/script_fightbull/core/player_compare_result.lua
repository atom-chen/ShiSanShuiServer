--[[
-- 玩家比牌结果 
--]]
local PlayerCompareResult = class("PlayerCompareResult")
function PlayerCompareResult:ctor()
    self.m_stScoreResult = {}        --详细比牌积分结果(保存除自己外所有玩家的比牌结果)
    self.m_nTotallScore = 0     --最终积分
    self:Clear()
end

function PlayerCompareResult:Clear()
    self.m_stScoreResult = {}
    self.m_nTotallScore = 0
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
        -- result.nFirstScore = v.nFirstScore
        -- result.nFirstScoreExt = v.nFirstScoreExt
        -- result.nSecondScore = v.nSecondScore
        -- result.nSecondScoreExt = v.nSecondScoreExt
        -- result.nThirdScore = v.nThirdScore
        -- result.nThirdScoreExt = v.nThirdScoreExt
        -- result.nSpecialScore = v.nSpecialScore

        -- result.nShoot = v.nShoot
        -- result.nShootMult = v.nShootMult
        -- result.nHasCode = v.nHasCode
        -- result.nCodeMult = v.nCodeMult
        -- result.nWanterMult = v.nWanterMult
        result.nFinalScore = v.nFinalScore

        table.insert(t, result)
    end
    return t
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

    self.m_nTotallScore = nTotall

    return self.m_nTotallScore
end

return PlayerCompareResult