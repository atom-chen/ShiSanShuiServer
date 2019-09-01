-- 返回 STEP_SUCCEED 流程继续
-- 返回 STEP_FAILED 流程终止
local function logic_do_player_choose_normal_cardtype(stPlayer, msg)
    LOG_DEBUG("Run LogicStep do_player_choose_normal_cardtype msg:%s\n", vardump(msg))

    stPlayer:AddOpChooseNums()
    --1-5是后墩,6-11是中墩,11-13后墩
    local cards = msg._para.cards
    -- LOG_DEBUG("do_player_choose_normal_cardtype...len:%d", #cards)
    --1.检查参数
    if type(cards) ~= 'table' then
        LOG_DEBUG("do_player_choose_normal_cardtype...error type table ~= %s", type(cards))
        CSMessage.NotifyError(stPlayer, ERROR_PARAM_ERR)

        -- --ask_chhoose ??
        -- SSMessage.CallPlayerChooseCardType(stPlayer)
        return STEP_FAILED
    end
    if #cards ~= 13 then
        LOG_DEBUG("do_player_choose_normal_cardtype...error size 13 ~= %d", #cards)
        CSMessage.NotifyError(stPlayer, ERROR_PARAM_ERR)

        -- --ask_chhoose ??
        -- SSMessage.CallPlayerChooseCardType(stPlayer)
        return STEP_FAILED
    end
    for _, v in ipairs(cards) do
        if type(v) ~= 'number' then
            LOG_DEBUG("do_player_choose_normal_cardtype...error type number ~= %s", type(v))
            CSMessage.NotifyError(stPlayer, ERROR_PARAM_ERR)

            -- --ask_chhoose ??
            -- SSMessage.CallPlayerChooseCardType(stPlayer)
            return STEP_FAILED
        end
    end

    local stPlayerCardGroup = stPlayer:GetPlayerCardGroup()
    --2.检查出的牌是否是手牌
    local myCards = stPlayerCardGroup:ToArray()
    if #myCards ~= #cards or not Array.IsSubSet(cards, myCards) then
        LOG_DEBUG("do_player_choose_normal_cardtype...error no this card, myCards:%s, cards:%s", TableToString(myCards), TableToString(cards))
        CSMessage.NotifyError(stPlayer, ERROR_PLAYER_NOT_HAVE_THISCARD)
        
        -- --ask_chhoose ??
        -- SSMessage.CallPlayerChooseCardType(stPlayer)
        return STEP_FAILED
    end
    LOG_DEBUG("do_player_choose_normal_cardtype....choose======cards:%s", TableToString(cards))
    --3.检查牌是否是相公
    local t = { [1] = {}, [2] = {}, [3] = {} }
    for i=1,5 do
        table.insert(t[3],cards[i])
    end
    for i=6,10 do
        table.insert(t[2],cards[i])
    end
    for i=11,13 do
        table.insert(t[1],cards[i])
    end

    local tempCards = Array.Clone(cards)
    if stPlayer:IsXianggong(t, tempCards) then
        LOG_DEBUG("do_player_choose_normal_cardtype...error xiang gong")
        CSMessage.NotifyError(stPlayer, ERROR_PLAYER_XIANGGONG)
        --防止卡死
        SSMessage.CallPlayerChooseCardType(stPlayer)
        return STEP_FAILED
    end

    --6.自己主动出牌,表示放弃特殊牌  特殊牌在do_player_choose_sp_cardtype设置
    stPlayerCardGroup:SetSpecialType(GStars_Special_Type.PT_SP_NIL)
    --7.删除定时器
    local nChairID = stPlayer:GetChairID()
    FlowFramework.DelTimer(nChairID, PLAYER_TIMER_ID_CHOOSE)
    --8.设置已选择牌型 以便dealer进入下一阶段
    stPlayer:SetChooseCardType(true)

    return STEP_SUCCEED
end


return logic_do_player_choose_normal_cardtype