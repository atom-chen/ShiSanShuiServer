local slot = {}
slot.name = "slot_get_banker_dice"
-- 实现 GetBanker  函数
-- 参数1  nLastBankerChair 上一轮庄家
-- 返回值  nThisBankerChair 本轮次庄家

-- 随机选取庄家
function slot.GetBanker(nLastBankerChair)
    local stRoundInfo = GRoundInfo
    local dice = stRoundInfo:GetDice()
    local ndiceNum = dice[1]+dice[2]
    LOG_DEBUG("Run ndiceNum=======%d",ndiceNum)
    local _chair = ndiceNum % PLAYER_NUMBER
    if _chair == 0 then
    	_chair = PLAYER_NUMBER
    end
    LOG_DEBUG("Run _chair=======%d",_chair)
    return _chair
end
return slot
