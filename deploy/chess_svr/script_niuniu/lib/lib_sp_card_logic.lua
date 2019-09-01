local LibBase = import(".lib_base")
local LibSpCardLogic = class("LibSpCardLogic", LibBase)

function LibSpCardLogic:ctor()
end

function LibSpCardLogic:CreateInit(strSlotName)
    return true
end

function LibSpCardLogic:OnGameStart()
end

--=========下面是特殊牌型判断================


--获取点数相同的所有数据
function libRecomand:Get_Same_Poker(cards, count)
    local hash = {}
    for i=1, 14 do
        hash[i] = {}
    end

    for i, v in ipairs(cards) do
        local nV = GetCardValue(v)
        table.insert(hash[nV], v)
    end

    local t = {}
    for i, v in ipairs(hash) do
        if #v == count then
            table.insert(t, v)
        end
    end

    if #t > 0 then
        return true, t
    else
        return false
    end
end

--获取五花牛
function  LibNormalCardLogic:GetFiveFloarCow(cards)
    local stCards = Array.Clone(cards)
    for k, v in ipairs(stCards) do
        local tempVal = GetCardValue(v)
        if tempVal < 10 then
            return false
        end
    end
    return true
end

--获取炸弹牛
function  LibNormalCardLogic:GetBombCow(cards)
    local bSuc, t = self:Get_Same_Poker(cards, 4)
    if not bSuc then
        return false
    end
    return true
end

--获取五小牛
function  LibNormalCardLogic:GetFiveLittleCow(cards)
    local stCards = Array.Clone(cards)
    local TotalCardVal = 0
    for k, v in ipairs(stCards) do
        local tempVal = GetCardValue(v)
        if tempVal > 5 then
            return false
        end
        TotalCardVal = TotalCardVal + tempVal
    end
    if TotalCardVal > 10 then
        return false
    end
    return true
end
return LibSpCardLogic