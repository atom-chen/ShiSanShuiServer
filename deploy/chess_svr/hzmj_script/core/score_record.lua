-- 流水
--[[
local stRecord = {
        bIsLoss = true,
        nTarget = 0,            -- 扣分者  或得分者
        nType = 0,              -- 1 刮风 2 下雨 3 点炮 4 自摸 5 花猪
        nScore = 0 ,            -- 分数或者金币
        stFanInfo = {}          -- 番数
    }
--]]

local ScoreRecord = class("ScoreRecord")
function ScoreRecord:ctor() 
    --self.m_stRecords = {}
    self.m_stSumScore = {}
    self.m_stGangScore = {}
    self.m_stDetailScore = {}
    self.m_stPlayerRecords = {}
    for i=1,PLAYER_NUMBER do
        self.m_stSumScore[i] = 0
        self.m_stGangScore[i] = 0
        self.m_stDetailScore[i] = {}
    end
end

function ScoreRecord:Init()
    for i=1,PLAYER_NUMBER do
        self.m_stDetailScore[i] = {}
        self.m_stPlayerRecords[i] = {}
        self.m_stGangScore[i] = self.m_stSumScore[i]
    end
end

function ScoreRecord:Dump()
    LOG_DEBUG("ScoreRecord:Dump %s", vardump(self.m_stPlayerRecords))
end

--[[
function ScoreRecord:GetRecordByChair(nChair)
    return self.m_stRecords[nChair]
end

function ScoreRecord:SetRecordByChair(nChair, stRecord)
    self.m_stRecords[nChair] = stRecord
end
--]]

function ScoreRecord:GetPlayerRecordsByChair(nChair)
    return self.m_stPlayerRecords[nChair]
end

function ScoreRecord:GetPlayerRecordDetail(nChair)
    local stDetail = {}

    if nChair <= 0 or nChair > PLAYER_NUMBER then
        return stDetail
    end

    -- 这里需要整理一下  如果是番 将番展开
    local stRecords = self.m_stPlayerRecords[nChair]
    local stPlayer = GGameState:GetPlayerByChair(nChair)
    if not stPlayer then
        return stDetail
    end
    local uinfo = stPlayer:GetUserInfo()
    LOG_DEBUG("=======ScoreRecord:======uinfo %s", vardump(uinfo))
    for _,stRecord in ipairs(stRecords) do
        if stRecord.nType == SCORE_RECORD_TYPE_GUN 
            or stRecord.nType == SCORE_RECORD_TYPE_SELFWIN   then
            local nScoreTotal = stRecord.nScore
            local nFanCountTotal = 0
            for _,stFanInfo in ipairs(stRecord.stFanInfo) do
                nFanCountTotal = nFanCountTotal + stFanInfo.byCount *  stFanInfo.byFanNumber
            end
            if nFanCountTotal >= 0 then
                for _,stFanInfo in ipairs(stRecord.stFanInfo) do
                    local nFanOne = stFanInfo.byCount *  stFanInfo.byFanNumber
                    local item = {}
                    item.type = stRecord.nType
                    --[[
                    item.score = math.pow(2,nFanOne)
                    --如果平胡番是0，不计分
                    if nFanOne ==0 then
                        item.score =0
                    end
                    if stRecord.bIsLoss then
                        item.score = -1* item.score
                    end
                    --]]
                    item.name = stFanInfo.szFanName
                    item.fantype = stFanInfo.szFanType
                    item.to = stRecord.nTarget
                    item.fan  = nFanOne
                    if stRecord.bIsLoss then
                        item.winOrloss  = -1
                    else
                        item.winOrloss  = 1
                    end
                    stDetail[#stDetail + 1] = item
                end
            end
        elseif stRecord.nType == SCORE_RECORD_BUY_CODE then
            local item = {}
            item.type = stRecord.nType
            item.name = GameUtil.GetScoreRecordName(stRecord.nType)
            item.score = stRecord.nScore
            stDetail[#stDetail + 1] = item
        else
            local item = {}
            item.type = stRecord.nType
            item.name = GameUtil.GetScoreRecordName(stRecord.nType)
            item.fan = stRecord.nFan
            item.score = stRecord.nScore
            if stRecord.bIsLoss then
                item.score = -1* item.score
            end
            item.to = stRecord.nTarget
            stDetail[#stDetail + 1] = item
        end 
    end
    local fullDetail ={}
    fullDetail.stDetail =stDetail
    fullDetail._chair = "p" .. nChair
    fullDetail._uid = uinfo._uid
    fullDetail.cards = stPlayer:GetPlayerCardGroup():ToArray()
    fullDetail.discardTile = stPlayer:GetPlayerGiveGroup():ToArray()
    fullDetail.combineTile = stPlayer:GetPlayerCardSet():ToArray()
    fullDetail.win_card = stPlayer:GetPlayerWinCards()[1]
    
    return fullDetail
end

function ScoreRecord:GetPlayerScore(nChair)
    local nScore = 0
    if nChair <= 0 or nChair > PLAYER_NUMBER then
        return nScore
    end

    local stRecords = self.m_stPlayerRecords[nChair]

    LOG_DEBUG("=======GetPlayerScore:======stRecords %s", vardump(stRecords))
    --此处需要判断是否为空表，否则可能会报错
    if  stRecords  then
        for _, stRecord in ipairs(stRecords) do
            if stRecord.bIsLoss == true then
                nScore = nScore - stRecord.nScore
            else
                nScore = nScore + stRecord.nScore
            end
        end
    end 

    return nScore
end

function ScoreRecord:GetPlayerMaxFanNumber(nChair)
    local nFan = 0
    local stFanInfo = self:GetPlayerMaxFanInfo(nChair)
    if stFanInfo ~= nil then
        return stFanInfo.byCount *  stFanInfo.byFanNumber
    end
    return 0
end

function ScoreRecord:GetPlayerMaxFanName(nChair)
    local stFanInfo = self:GetPlayerMaxFanInfo(nChair)
    if stFanInfo ~= nil then
        return stFanInfo.szFanName
    end
    return ""
end

function ScoreRecord:GetPlayerMaxFanInfo(nChair)
    local nFan = 0
    local stFanInfo = nil
    if nChair <= 0 or nChair > PLAYER_NUMBER then
        return nFan
    end
    local stRecords = self.m_stPlayerRecords[nChair]
    for _, stRecord in ipairs(stRecords) do

        if stRecord.nType == SCORE_RECORD_TYPE_GUN 
            or stRecord.nType == SCORE_RECORD_TYPE_SELFWIN   then
            for _, _stFanInfo in ipairs(stRecord.stFanInfo) do
                if  _stFanInfo.byCount *  _stFanInfo.byFanNumber > nFan then
                    nFan =  _stFanInfo.byCount *  _stFanInfo.byFanNumber
                    stFanInfo = _stFanInfo
                end
            end
        end
    end
    return stFanInfo
end

function ScoreRecord:AddScoreByQuadruplet(nTypeQuadruplet, nChair, nTarget, nFan, nScore)
    
    local  stRecord = {
        bIsLoss = false,
        nType = nTypeQuadruplet,
        nTarget = nTarget,
        nScore = nScore,
        nFan =nFan,
        stFanInfo = {} 
    }

    self:AddOneRecord(nChair, stRecord)
end

function ScoreRecord:LossScoreByQuadruplet(nTypeQuadruplet, nChair, nTarget, nFan, nScore)
    
    local  stRecord = {
        bIsLoss = true,
        nType = nTypeQuadruplet,
        nTarget = nTarget,
        nFan =nFan,
        nScore = nScore,
        stFanInfo = {}  
    }

    self:AddOneRecord(nChair, stRecord)
end

function ScoreRecord:AddScoreByWin( nTypeWin, nChair, nTarget,nFan, nScore,  stFanInfo)

    local nType = SCORE_RECORD_TYPE_GUN
    if nTypeWin == 0 then
        nType = SCORE_RECORD_TYPE_SELFWIN
    end
    local  stRecord = {
        bIsLoss = false,
        nType = nType,
        nTarget = nTarget,
        nFan =nFan,
        nScore = nScore,
        stFanInfo = stFanInfo
    }
    self:AddOneRecord(nChair, stRecord)
end

function ScoreRecord:LossScoreByWin( nTypeWin, nChair, nTarget, nFan,nScore, stFanInfo)
    local nType = SCORE_RECORD_TYPE_GUN
    if nTypeWin == 0 then
        nType = SCORE_RECORD_TYPE_SELFWIN
    end
    local  stRecord = {
        bIsLoss = true,
        nType = nType,
        nTarget = nTarget,
        nFan =nFan,
        nScore = nScore,
        stFanInfo = stFanInfo
    }

    self:AddOneRecord(nChair, stRecord)
end

function ScoreRecord:GetAllQuadrupletScoreGain(nChair)
    local stRes = {}
    local stRecords = self.m_stPlayerRecords[nChair]
    for i=1,#stRecords do
        if stRecords[i].bIsLoss == false and ( stRecords[i].nType ==  SCORE_RECORD_TYPE_WIND or stRecords[i].nType ==  SCORE_RECORD_TYPE_RAIN or stRecords[i].nType ==  SCORE_RECORD_TYPE_BUWIND) then
            stRes[#stRes + 1] = stRecords[i]
        end
    end 
    return stRes
end

--[[ 
-- 删除所有刮风下雨记录
function ScoreRecord:RemoveQuadrupletScoreGain(nChair)

    for i=1,PLAYER_NUMBER do
        local stRecords = self.m_stPlayerRecords[i] 
        if i == nChair then
            for i = #stRecords,1, -1 do
                -- 得分的
                if stRecords[i].bIsLoss == false and ( stRecords[i].nType ==  SCORE_RECORD_TYPE_WIND or
                    stRecords[i].nType ==  SCORE_RECORD_TYPE_RAIN )
                    then
                    table.remove(stRecords, i)
                end
            end
        else
            for i = #stRecords,1, -1 do
                -- 扣分的
                if stRecords[i].bIsLoss == true and stRecords[i].nTarget == nChair and ( stRecords[i].nType ==  SCORE_RECORD_TYPE_WIND or
                    stRecords[i].nType ==  SCORE_RECORD_TYPE_RAIN ) 
                    then
                    table.remove(stRecords, i)
                end
            end
        end
    end
end
--]]

function ScoreRecord:AddScoreByTax(nChair, nTarget, nFan, nScore)
    local  stRecord = {
        bIsLoss = false,
        nType = SCORE_RECORD_TYPE_TAX,
        nTarget = nTarget,
        nScore = nScore,
        nFan =nFan,
        stFanInfo = {}
    }
    self:AddOneRecord(nChair, stRecord)
end

function ScoreRecord:LossScoreByTax(nChair, nTarget, nFan, nScore)
    local  stRecord = {
        bIsLoss = true,
        nType = SCORE_RECORD_TYPE_TAX,
        nTarget = nTarget,
        nFan =nFan,
        nScore = nScore,
        stFanInfo = {}
    }
    self:AddOneRecord(nChair, stRecord)
end

function ScoreRecord:AddScoreByHuaZhu(nChair, nTarget, nFan, nScore)
    local  stRecord = {
        bIsLoss = false,
        nType = SCORE_RECORD_TYPE_HUAZHU,
        nTarget = nTarget,
        nFan =nFan,
        nScore = nScore,
        stFanInfo = {}
    }
    self:AddOneRecord(nChair, stRecord)
end

function ScoreRecord:LossScoreByHuaZhu(nChair, nTarget, nFan, nScore)
     local  stRecord = {
        bIsLoss = true,
        nType = SCORE_RECORD_TYPE_HUAZHU,
        nTarget = nTarget,
        nFan =nFan,
        nScore = nScore,
        stFanInfo = {}
    }
    self:AddOneRecord(nChair, stRecord)
end

function ScoreRecord:AddScoreByDaJiao(nChair, nTarget, nFan, nScore)
    local  stRecord = {
        bIsLoss = false,
        nType = SCORE_RECORD_TYPE_DAJIAO,
        nTarget = nTarget,
        nFan =nFan,
        nScore = nScore,
        stFanInfo = {}
    }
    self:AddOneRecord(nChair, stRecord)
end

function ScoreRecord:LossScoreByDaJiao(nChair, nTarget, nFan, nScore)
    local  stRecord = {
        bIsLoss = true,
        nType = SCORE_RECORD_TYPE_DAJIAO,
        nTarget = nTarget,
        nFan =nFan,
        nScore = nScore,
        stFanInfo = {}
    }
    self:AddOneRecord(nChair, stRecord)
end

function ScoreRecord:AddScore( nType, nChair, nTarget, nFan, nScore, stFanInfo)
    local  stRecord = {
        bIsLoss = false,
        nType = nType,
        nTarget = nTarget or 0, 
        nFan =nFan,
        nScore = nScore,
        stFanInfo = stFanInfo or  {}
    }
    self:AddOneRecord(nChair, stRecord)
end

function ScoreRecord:LossScore( nType, nChair, nTarget, nFan, nScore, stFanInfo)
    local  stRecord = {
        bIsLoss = true,
        nType = nType,
        nTarget = nTarget,
        nFan =nFan,
        nScore = nScore,
        stFanInfo = stFanInfo
    }
    self:AddOneRecord(nChair, stRecord)
end

function ScoreRecord:AddOneRecord(nChair, stRecord)
    if nChair <=0 or  nChair > PLAYER_NUMBER then
        return false
    end

    local len = #self.m_stPlayerRecords[nChair]
    self.m_stPlayerRecords[nChair][len + 1] = stRecord

    if stRecord.bIsLoss then
        self.m_stSumScore[nChair] = self.m_stSumScore[nChair] - stRecord.nScore  -- 记录总分
        self.m_stDetailScore[nChair][stRecord.nTarget] = (self.m_stDetailScore[nChair][stRecord.nTarget] or 0) + stRecord.nScore  -- 分数来源
    else
        self.m_stSumScore[nChair] = self.m_stSumScore[nChair] + stRecord.nScore  -- 记录总分
        self.m_stDetailScore[nChair][stRecord.nTarget] = (self.m_stDetailScore[nChair][stRecord.nTarget] or 0) - stRecord.nScore  -- 分数来源
    end

    --[[
    -- 记录部分类型的分数(在未结算时 其他类型的分数暂时不展示)
    if stRecord.nType == SCORE_RECORD_TYPE_RAIN or stRecord.nType == SCORE_RECORD_TYPE_BUWIND or stRecord.nType == SCORE_RECORD_TYPE_WIND or stRecord.nType == SCORE_RECORD_TYPE_WIND or stRecord.nType == SCORE_RECORD_TYPE_WIND then
        if stRecord.bIsLoss then
            self.m_stGangScore[nChair] = self.m_stGangScore[nChair] - stRecord.nScore
        else
            self.m_stGangScore[nChair] = self.m_stGangScore[nChair] + stRecord.nScore
        end
    end
    --]]
    return true
end

-- 结算时的累计总分
function ScoreRecord:GetPlayerSumScore(nChair)
	local nSumScore = 0
	if nChair <= 0 or nChair > PLAYER_NUMBER then
		return nSumScore
	end
	if self.m_stSumScore then
		nSumScore = self.m_stSumScore[nChair]
	end
	return nSumScore
end

function ScoreRecord:SetPlayerGangScore(nChair, nGangScore)
	self.m_stGangScore[nChair] = nGangScore
end

-- 获取未结算时可以展示部分的分数
function ScoreRecord:GetPlayerGangScore(nChair)
	local nGangScore = 0
	if nChair <= 0 or nChair > PLAYER_NUMBER then
		return nGangScore
	end
	if self.m_stGangScore then
		nGangScore = self.m_stGangScore[nChair]
	end
	return nGangScore
end

-- 获取玩家结算时分数的组成结构
function ScoreRecord:GetPlayerDetailScore(nChair)
	local stDetailScore = {}
	if nChair <= 0 or nChair > PLAYER_NUMBER then
		return stDetailScore
	end
	if self.m_stDetailScore[nChair] then
		stDetailScore = self.m_stDetailScore[nChair]
	end
	return stDetailScore
end

-- 增加一条买马记录
function ScoreRecord:AddBuyCodeRecord(nChair)
    local nBuyCodeScore = LibBuyCode:GetBuyCodeScore(nChair)
    if not nBuyCodeScore or nChair <= 0 or nChair > PLAYER_NUMBER then
        return
    end

    local stRecord = { nType = SCORE_RECORD_BUY_CODE, nScore = nBuyCodeScore }

    if not table.keyof(self.m_stPlayerRecords[nChair], stRecord) then
        local len = #self.m_stPlayerRecords[nChair]
        self.m_stPlayerRecords[nChair][len + 1] = stRecord
        self.m_stSumScore[nChair] = self.m_stSumScore[nChair] + stRecord.nScore  -- 记录总分
    end
end


return ScoreRecord