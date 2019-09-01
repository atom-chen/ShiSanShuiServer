-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_call_player_mult(dealer, msg)
    LOG_DEBUG("Run LogicStep call_player_mult")
    local stGameState = GGameState
    for i=1,PLAYER_NUMBER do
        local stPlayer = stGameState:GetPlayerByChair(i)
        if stPlayer ~= nil then 
            if i ~= GDealer:GetBanker() then
                SSMessage.CallPlayerMult(stPlayer)
            else
                ---庄家只做通知
                local stMult = {}
                local nMaxMult = GGameCfg.GameSetting.nSupportMaxMult
                for i=1, nMaxMult do
                    table.insert(stMult, i)
                end
                local para = {
                    optional = stMult
                }
                local nTimeout = GGameCfg.TimerSetting.multTimeOut
                CSMessage.NotifyOnePlayer(stPlayer, "ask_mult", para, nTimeout)
            end
        end
    end
    return STEP_SUCCEED
end

return logic_call_player_mult