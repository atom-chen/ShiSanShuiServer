local slot = {}



-- 实现 CanWin  函数 。
-- 是否可听
-- 参数1 玩家手牌
-- 参数2 新的牌
-- 返回值  是否可以胡
function slot.CanWin(stCardArray)
    local bResult = false
    local arrCards = Array.Clone(stCardArray)
    local stWin = GGameCfg.GameSlotSetting.stWin
    --增加2个变量获取癞子数目及癞子牌；从lib.laizi里取出癞子牌，然后遍历手牌取出癞子牌数目
    local nLaiZiCount = 0
    local nLaiZiCard = LibLaiZi:GetLaiZi()
    local stWinScripts = {}
    for i=1,#stCardArray do
        if nLaiZiCard == stCardArray[i] then
            nLaiZiCount = nLaiZiCount+1
        end
    end
    LOG_DEBUG("CheckWin ==================================================laizi==:%d",nLaiZiCard)
    table.insert(stWinScripts, stWin.strNodeWinNormal)

    if stWin.bSupportWinSevenDouble == true then
        table.insert(stWinScripts, stWin.strNodeWinSevenDouble)
    end
    --[[
    if stWin.bSupportWinCard13Yao == true then
        table.insert(stWinScripts, stWin.strNodeWinCard13Yao)
    end
    if stWin.bSupportWinChaos == true then
        table.insert(stWinScripts, stWin.strNodeWinChaos)
    end
    if stWin.bSupportAssemble == true then
         table.insert(stWinScripts, stWin.strNodeWinAssemble)
    end
    --]]


    for i,scripts in ipairs(stWinScripts) do
        local CheckWin = import(scripts)
        bResult = CheckWin(arrCards)
        if bResult == true then
            --LOG_DEBUG("CheckWin win:%s", scripts)
            return bResult
        end
    end

    return false
end



return slot