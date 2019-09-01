-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_do_compare_wait(dealer, msg)
    --是否全部取消动画
    local bAllCancle = false
    for i=1,PLAYER_NUMBER do
        local stPlayer = GGameState:GetPlayerByChair(i)
        -- LOG_DEBUG("logic_do_compare_wait..p%d, uid:%d, IsCancleCompare:%s", i, stPlayer:GetUin(), tostring(stPlayer:IsCancleCompare()))
        if stPlayer ~= nil and stPlayer:IsCancleCompare() == true then
            bAllCancle = true
            break
        end
    end

    local nExpiredTime = GRoundInfo:GetCompareExpiredTime()
    local nowTime = os.time()
    LOG_DEBUG("Run LogicStep do_compare_wait nowTime: %d -- nExpiredTime: %d, bAllCancle:%s", nowTime, nExpiredTime, tostring(bAllCancle))
    if bAllCancle or (nExpiredTime >0 and nowTime >= nExpiredTime) then
        CSMessage.NotifyPlayerCompareEnd()
        -- LOG_DEBUG("logic_do_compare_wait before, stage=%s", dealer:GetCurrStage())
        dealer:ToNextStage()
        -- LOG_DEBUG("logic_do_compare_wait next, stage=%s", dealer:GetCurrStage())
        GRoundInfo:SetCompareWait(false) 
    end

    return STEP_SUCCEED
end


return logic_do_compare_wait