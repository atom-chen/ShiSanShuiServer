--[[
-- 当前游戏状态
--  玩家、旁观者、游戏本身状态、对局内状态
--  为了一致  都用 class 方式定义
--]]
local GameState = class("GameState")
function GameState:ctor()
    self:initial()
end
function GameState:initial()
    self.m_nGameStatus = GAME_STATUS_NOSTART    -- 游戏状态
    self.m_stPlayerInfo = {}        --玩家
    self.m_stWatcherInfo = {}       --旁观者
end

function GameState:InitGameInfo()
    self.m_nGameStatus = GAME_STATUS_NOSTART
    self.m_bIsPlayStart = false

end

function GameState:IsPlayStart()
    return self.m_bIsPlayStart
end
function GameState:SetPlayStart(bIsStart)
    self.m_bIsPlayStart = bIsStart
end

function GameState:GetPlayerByChair(nChair)
    LOG_DEBUG("GameState:GetPlayerByChair...type(nChair):%s", type(nChair))
    if nChair > 0 and nChair <= PLAYER_NUMBER then
        return self.m_stPlayerInfo[nChair]
    end
    return nil
end
function GameState:RemovePlayer(nChair)
     self.m_stPlayerInfo[nChair] = nil
end
function GameState:SetPlayer(nChair, stPlayer)
    self.m_stPlayerInfo[nChair] = stPlayer
end

function GameState:GetWatchPlayer(index)
    if index > 0 and index <= #self.m_stWatcherInfo then
        return self.m_stWatcherInfo[index]
    end
    return nil
end

function GameState:SetGameStatus(nGameStatus)
    self.m_nGameStatus = nGameStatus
end
function GameState:GetGameStatus()
    return self.m_nGameStatus
end

function GameState:GetPlayerWinInfo()
    local stWin = {}
    for i=1,PLAYER_NUMBER do
        stWin[i] = self.m_stPlayerInfo[i]:IsWin()
    end
    return stWin
end

return GameState 