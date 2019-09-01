local LibBase = import(".lib_base")
import("core.game_util")
local PlayerCardGroup = import("core.player_cardgroup")
local ScoreRecord = import("core.score_record")

local stGameState = nil
local stRoundInfo = nil
local LibGame = class("LibGame", LibBase)
function LibGame:ctor()
    self.m_stScoreRecord = ScoreRecord.new()
end

function LibGame:CreateInit(strSlotName)
    stGameState = GGameState
    stRoundInfo = GRoundInfo
    return true
end

function LibGame:OnGameStart()
    self.m_stScoreRecord:Init()
    self.m_bGameOver = false
end

function LibGame:GetScoreRecord()
    return self.m_stScoreRecord
end

--比牌
function LibGame:CompareResult()
    if GGameCfg.GameSetting.nGamePlay == BULL_BANKER_ORDER then
    elseif GGameCfg.GameSetting.nGamePlay == BULL_BANKER_OWNER then
    elseif GGameCfg.GameSetting.nGamePlay == BULL_BANKER_FREE_ROB then
    elseif GGameCfg.GameSetting.nGamePlay == BULL_BANKER_LOOK_ROB then
    end
end

function LibGame:NotifyCompareResult()
end

function LibGame:RewardThisGame() 
end

return LibGame