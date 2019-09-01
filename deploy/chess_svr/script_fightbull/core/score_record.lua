-- 流水
local ScoreRecord = class("ScoreRecord")
function ScoreRecord:ctor() 
    self.m_stRecords = {}
    self.m_stSumScore = {0, 0, 0, 0,0, 0}
end

function ScoreRecord:Init()
    self.m_stRecords = {}
end

function ScoreRecord:Dump()
    -- LOG_DEBUG("ScoreRecord:Dump m_stRecords: %s", vardump(self.m_stRecords))
end

function ScoreRecord:GetRecordByChair(nChair)
    return self.m_stRecords[nChair]
end

function ScoreRecord:SetRecordByChair(nChair, stRecord)
    self.m_stRecords[nChair] = stRecord
end

function ScoreRecord:GetPlayerSumScore(nChair)
    local nSumScore = 0
    if nChair <= 0 or  nChair > PLAYER_NUMBER then
        return nSumScore
    end

    if self.m_stSumScore[nChair] then
        nSumScore = self.m_stSumScore[nChair]
    end
    return nSumScore
end

function ScoreRecord:SetPlayerSumScore(nChair, nScore)
    self.m_stSumScore[nChair] = self.m_stSumScore[nChair] + nScore
end

return ScoreRecord