local LibBase = import(".lib_base")
local LibTurnOrder = class("LibTurnOrder", LibBase)

function LibTurnOrder:ctor()
end
function LibTurnOrder:CreateInit(strSlotName)
    local stSlotFuncNames = {"GetNextTurn"}
    self.m_slot  = self:LoadSlot(strSlotName, stSlotFuncNames)
    if self.m_slot == nil then
        return false
    end

    return true
end
function LibTurnOrder:OnGameStart()
    
end
function LibTurnOrder:GetNextTurn(nThisTurn)
    -- -- 血战模式下 赢了就不摸牌了 然后也就不能打牌了
    -- if GGameCfg.RoomSetting.nGameStyle == GAME_STYLE_CHENGDU 
    --     and GGameCfg.RoomSetting.nSubGameStyle ==   LOCAL_CHENGDU_XUEZHAN  then
    --     local stGameState = GGameState
    --     for i=1,PLAYER_NUMBER do
    --         nThisTurn = self.m_slot.GetNextTurn(nThisTurn)
    --         local stPlayer = stGameState:GetPlayerByChair(nThisTurn)
    --         if stPlayer:IsPlayEnd() == false then
    --             return nThisTurn
    --         end
    --     end
    --     LOG_ERROR("LibTurnOrder:GetNextTurn Errror");
    --     return 0
    -- end
    return self.m_slot.GetNextTurn(nThisTurn)
end

function LibTurnOrder:Sort(stTurn)
    self.m_slot.Sort(stTurn)
end

return LibTurnOrder