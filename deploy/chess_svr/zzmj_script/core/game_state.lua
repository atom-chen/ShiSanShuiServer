--[[
-- 当前游戏状态
--  玩家、旁观者、游戏本身状态、对局内状态
--  为了一致  都用 class 方式定义
--]]
-- local Player = import(".player")

local GameState = class("GameState")
function GameState:ctor()
    --GameState.super.ctor(self, "GameState")
    self:initial()
end
function GameState:initial()
    self.m_nGameStatus = GAME_STATUS_NOSTART                     -- 游戏状态
    self.m_stPlayerInfo = {}
    for i = 1,PLAYER_NUMBER do
        --self.m_stPlayerInfo[i] = Player.new()
    end
    self.m_stWatcherInfo = {}
    for i=1,WATCHER_NUMBER do
        --self.m_stWatcherInfo[i] = Player.new()
    end
    

    
    

    -- 番数
    --[[
    self.m_nFans = {}
    for i=1,MAX_FAN_NUMBER do
        self.m_nFans[i] = 0
    end
     ]]
     --[[
    self.m_stWin = {}
    for i=1,PLAYER_NUMBER do
        self.m_stWin[i] = false
    end
     ]]



    -- 保存最近一局的输赢信息
    --[[
    self.m_nWLPlayerID = {}
    self.m_nWLPlayerStatus = {}
    for i=1,PLAYER_NUMBER do
        self.m_nWLPlayerID[i] = 0
        self.m_nWLPlayerStatus[i] = 0
    end
]]

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


function GameState:GetWatchPlayer(index)
    if index > 0 and index <= #self.m_stWatcherInfo then
        return self.m_stWatcherInfo[index]
    end
    return nil
end
function GameState:GetPlayerByChair(nChair)
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