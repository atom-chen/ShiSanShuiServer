-- 加载 slot/change_card
local LibBase = import(".lib_base")
local LibChangeCard = class("LibChangeCard", LibBase)
function LibChangeCard:ctor()
    self.m_stState = {}
    for i=1,PLAYER_NUMBER do
        table.insert(self.m_stState, { stCards = {} })
    end
end

function LibChangeCard:CreateInit(strSlotName)
    local stSlotFuncNames = {"GetChangeCardType", "GetChangeCardNum", "IsNeedChangeSame"}
    self.m_slot  = self:LoadSlot(strSlotName, stSlotFuncNames)
    if self.m_slot == nil then
        return false
    end
    return true
end
function LibChangeCard:OnGameStart()
    self.m_nChangeCardType  = self.m_slot.GetChangeCardType()
    self.m_nChangeCardNum = self.m_slot.GetChangeCardNum()
    self.m_bNeedChangeSame = self.m_slot.IsNeedChangeSame()
    self.m_stState = {}
    for i=1,PLAYER_NUMBER do
        table.insert(self.m_stState, { stCards = {} })
    end

end

-- 获取换张类型
function LibChangeCard:GetChangeCardType()
    return self.m_nChangeCardType
end
-- 获取换张个数
function LibChangeCard:GetChangeCardNum()
    return self.m_nChangeCardNum
end

-- 换张是否需要换同型牌
function LibChangeCard:IsNeedChangeSame()
    return self.m_bNeedChangeSame
end
-- 处理换张操作
function LibChangeCard:ProcessChangeCard(stPlayer, stCards)
    local nChairID = stPlayer:GetChairID()
    if type(stCards) ~= 'table' then
        LOG_ERROR("ProcessChangeCard stCards Param Err. type:%s\n", type(stCards))
        return 
    end
    if #stCards ~= self.m_nChangeCardNum then
        LOG_ERROR("LibChangeCard:ProcessChangeCard Failed. ChangeCardNum Error. ReqCardNum:%d Required:%d\n",
                                #stCards, self.m_nChangeCardNum)
        return ERROR_PARAM_ERR
    end
    if nChairID < 1 or nChairID > PLAYER_NUMBER then
        LOG_ERROR("LibChangeCard:ProcessChangeCard Failed. nChairID Error. nChairID:%d\n", nChairID)
        return ERROR_INTERNAL
    end
    --  检查牌 是否符合规则
    if self.m_bNeedChangeSame then
        local nFirstCardType = GetCardType(stCards[1])
        for i=1,#stCards do
            if  GetCardType(stCards[i]) ~= nFirstCardType then
                LOG_ERROR("LibChangeCard:ProcessChangeCard Failed. NeedChangeSame CardType\n")
                return ERROR_CHANGECARD_NEEDSAME
            end
        end
    end
    local stPlayerCardGroup = stPlayer:GetPlayerCardGroup()
    if Array.IsSubSet(stCards, stPlayerCardGroup:ToArray()) == false then
        LOG_ERROR("stCards:%s stPlayerCardGroup:%s\n", vardump(stCards), vardump(stPlayerCardGroup:ToArray()))
        CSMessage.NotifyError(stPlayer, ERROR_PLAYER_CARDGROUP)
        return ERROR_PLAYER_CARDGROUP
    end
    -- 删除手牌
    for i=1,#stCards do
        stPlayerCardGroup:DelCard(stCards[i])
    end

    self.m_stState[nChairID].stCards = stCards
    return 0
end

-- 检查换张是否完成
function LibChangeCard:IsChangeCardEnd()
    for i=1,PLAYER_NUMBER do
        if # self.m_stState[i].stCards ~= self.m_nChangeCardNum then 
            return false
        end
    end
    return true
end
function LibChangeCard:GetChangeCardResCard(nChairID)
    local nNewIndex = 0
    if self.m_nChangeCardType == EN_CHANGCARDTYPE_CLOCKWISE then
        -- 顺时针交换
        nNewIndex = (nChairID + 1) % PLAYER_NUMBER  + 1
    elseif  self.m_nChangeCardType == EN_CHANGCARDTYPE_ANTI_CLOCKWISE then
        -- 逆时针
        nNewIndex = (nChairID - 1 + PLAYER_NUMBER) % PLAYER_NUMBER  + 1
    elseif  self.m_nChangeCardType == EN_CHANGCARDTYPE_OPPOSITE then
        -- 对家交换
        nNewIndex = (nChairID + 2) % PLAYER_NUMBER  + 1
    end
    return  self.m_stState[nNewIndex].stCards

end
function LibChangeCard:GetChangedCard(nChairID)
    return self.m_stState[nChairID].stCards
end
function LibChangeCard:IsPlayerSubmitChangeCard(nChairID)
    --print(vardump(self.m_stState[nChairID].stCards))
    return #self.m_stState[nChairID].stCards ~= 0
end

-- 从玩家手牌取选择 换牌
function LibChangeCard:SelectCardChange(stPlayerCards)
    return  self.m_slot.SelectCardChange(stPlayerCards)
end




return LibChangeCard