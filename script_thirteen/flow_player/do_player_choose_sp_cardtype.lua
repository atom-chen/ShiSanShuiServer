-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_do_player_choose_sp_cardtype(stPlayer, msg)
    LOG_DEBUG("Run LogicStep do_player_choose_sp_cardtype  msg:%s", vardump(msg))

    local nSelect = msg._para.nSelect
    local stPlayerCardGroup = stPlayer:GetPlayerCardGroup()
    if nSelect > 0 then
        --1.检查是否是特殊牌型
        local nSpecialType = stPlayerCardGroup:GetSpecialType()
        if nSpecialType <= GStars_Special_Type.PT_SP_NIL then
            LOG_DEBUG("logic_do_player_choose_sp_cardtype...not special type: %d", nSpecialType)
            CSMessage.NotifyError(stPlayer, ERROR_PLAYER_CARDGROUP)

            -- --ask choose
            -- SSMessage.CallPlayerChooseCardType(stPlayer)
            return STEP_FAILED
        end
        --特殊牌型也要保存出牌的数据
        local tempCards = stPlayerCardGroup:ToArray()
        -- LOG_DEBUG("CCCCC, %d\n",#tempCards);
        stPlayerCardGroup:SetChooseCardArray(tempCards)
        --删除定时器
        local nChairID = stPlayer:GetChairID()
        FlowFramework.DelTimer(nChairID, PLAYER_TIMER_ID_CHOOSE)
        --2.设置已选择牌型 以便dealer进入下一阶段
        stPlayer:SetChooseCardType(true)
    else
        --没选特殊牌型
        stPlayerCardGroup:SetSpecialType(GStars_Special_Type.PT_SP_NIL)
        --
        stPlayer:SetCancleSpecial(true)
        --ask choose
        SSMessage.CallPlayerChooseCardType(stPlayer)
        return STEP_FAILED
    end

    return STEP_SUCCEED
end


return logic_do_player_choose_sp_cardtype