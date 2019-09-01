-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_do_player_choose_cardtype_timeout(stPlayer, event)
    LOG_DEBUG("Run LogicStep do_player_choose_cardtype_timeout")
    --删除定时器
    local nChairID = stPlayer:GetChairID()
    FlowFramework.DelTimer(nChairID, PLAYER_TIMER_ID_CHOOSE)

    local stPlayerCardGroup = stPlayer:GetPlayerCardGroup()
    -- LOG_DEBUG("do_player_choose_cardtype_timeout...SpecialType:%d, csrds:%s", stPlayerCardGroup:GetSpecialType(), TableToString(stPlayerCardGroup:GetChooseCardArray()))
    --不是特殊牌型才要系统自动配牌
    if stPlayerCardGroup:GetSpecialType() <= GStars_Special_Type.PT_SP_NIL then
        --1.系统自动配置牌型
        local stPlayerCardGroup = stPlayer:GetPlayerCardGroup()
        --TODO:  need test
        if not stPlayerCardGroup:AutoChooseCard() then
            LOG_DEBUG("================ERROR auto choose card error===========================")
            CSMessage.NotifyError(stPlayer, ERROR_CARD_POOL)

            --不能卡死要继续下去
            -- return STEP_FAILED
        end
        --自动配牌是不会设特殊牌的
        stPlayerCardGroup:SetSpecialType(GStars_Special_Type.PT_SP_NIL)
    else
        local tempCards = stPlayerCardGroup:ToArray()
        -- LOG_DEBUG("do_player_choose_cardtype_timeout, sptype %s\n",TableToString(tempCards))
        stPlayerCardGroup:SetChooseCardArray(tempCards)
    end

    --
    CSMessage.NotifyPlayerChooseCardType(stPlayer)

    --2.设置已选择牌型 以便dealer进入下一阶段
    stPlayer:SetChooseCardType(true)

    return STEP_SUCCEED
   
end


return logic_do_player_choose_cardtype_timeout
