-- 加载
local LibBase = import(".lib_base")
local LibBuyCode = class("LibBuyCode", LibBase)

--[[
    self.m_stBuyCode = {
                            [1] = {card = 0, point = 0, owner = 0, score = 0},
                            [2] = {card = 0, point = 0, owner = 0, score = 0}
                       }
--]]

function LibBuyCode:ctor()
    self.m_stBuyCode = {}
    self.m_stBuyCodeScore = {}
end

function LibBuyCode:CreateInit(strSlotName)
	return true
end

function LibBuyCode:OnGameStart()
    self.m_stBuyCode = {}
    self.m_stBuyCodeScore = {}
end

function LibBuyCode:GetBuyCodeInfo()
    return self.m_stBuyCode
end

function LibBuyCode:SetBuyCodeInfo()
    local stRoundInfo = GRoundInfo
    local nBanker = stRoundInfo:GetBanker()
    local nBuyCodeType = GGameCfg.GameSetting.nBuyCodeType
    
    if BUY_CODE_BANKER_ONE == nBuyCodeType then
        self.m_stBuyCode[1] = {}
        self.m_stBuyCode[1].owner = nBanker
        self.m_stBuyCode[1].card  = GDealer:GetDealerCardGroup():BuyCodeOneCard()
    elseif BUY_CODE_BANKER_TWO == nBuyCodeType then
        for i=1, 2 do
            self.m_stBuyCode[i] = {}
            self.m_stBuyCode[i].owner = nBanker
            self.m_stBuyCode[i].card  = GDealer:GetDealerCardGroup():BuyCodeOneCard()
        end
    elseif BUY_CODE_EVERYONE == nBuyCodeType then
        local nChair = nBanker
        for i=1, PLAYER_NUMBER do
            self.m_stBuyCode[i] = {}
            self.m_stBuyCode[i].owner = nChair
            self.m_stBuyCode[i].card  = GDealer:GetDealerCardGroup():BuyCodeOneCard()
            nChair = LibTurnOrder:GetNextTurn(nChair)
        end
    end
      
    for i=1, #self.m_stBuyCode do
        local nCard = self.m_stBuyCode[i].card
        local nOwner = self.m_stBuyCode[i].owner
        local nValue = (nCard % 10 - 1) % PLAYER_NUMBER
        local nPoint = nOwner + nValue
        if nPoint > PLAYER_NUMBER then
            nPoint = nPoint % PLAYER_NUMBER
        end
        self.m_stBuyCode[i].point = nPoint
    end
    LOG_DEBUG("BUYCODE TYPE BUYCODETYPE == %d @@@@ BANKER == %d PLAYERNUM == %d @@@@ m_stBuyCode %s", nBuyCodeType, nBanker, PLAYER_NUMBER, vardump(self.m_stBuyCode))
end

-- 获得买马的分数
function LibBuyCode:GetBuyCodeScore(nChair)
	return self.m_stBuyCodeScore[nChair]
end

-- 计算买马各玩家得分
function LibBuyCode:CalBuyCodeScore()
    local stScoreRecord = LibGameLogic:GetScoreRecord()
    if not stScoreRecord or #self.m_stBuyCodeScore > 1 then 
        return 
    end

    for i=1, #self.m_stBuyCode do
        local nPoint = self.m_stBuyCode[i].point
        local nOwner = self.m_stBuyCode[i].owner
        local stDetailScore = stScoreRecord:GetPlayerDetailScore(nPoint)
        for k, val in pairs(stDetailScore) do
            self.m_stBuyCodeScore[k] = (self.m_stBuyCodeScore[k] or 0) + val
            self.m_stBuyCodeScore[nOwner] = (self.m_stBuyCodeScore[nOwner] or 0) + (-1*val)
        end
        self.m_stBuyCode[i].score = self.m_stBuyCodeScore[nOwner] -- 该匹马所获得的分数
    end
    LOG_DEBUG("CalBuyCodeScore  m_stBuyCodeScore = %s", vardump(self.m_stBuyCodeScore))
end


return LibBuyCode