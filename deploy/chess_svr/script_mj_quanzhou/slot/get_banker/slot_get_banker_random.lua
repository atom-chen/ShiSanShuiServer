local slot = {}
slot.name = "slot_get_banker_random"
-- 实现 GetBanker  函数
-- 参数1  nLastBankerChair 上一轮庄家
-- 返回值  nThisBankerChair 本轮次庄家

-- 随机选取庄家
function slot.GetBanker(nLastBankerChair)
    math.randomseed (os.time())
    local _chair =   math.random(137) % PLAYER_NUMBER + 1
    return _chair
end
return slot
