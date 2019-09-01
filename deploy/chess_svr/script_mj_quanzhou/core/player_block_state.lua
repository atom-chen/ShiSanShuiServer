local PlayerBlockState = class("PlayerBlockState")

function PlayerBlockState:ctor()
    self.m_nCanCollect = 0           -- 是可以吃牌
    self.m_nCanTriplet  = 0          -- 是可以碰
    self.m_nCanQuadruplet = 0        -- 是可以杠
    self.m_nCanTing = 0              -- 是否可以听
    self.m_nCanWin = 0               -- 是可以和

    self.m_stCardCollect  = {}       -- 吃牌选择
    self.m_nCardTriplet  = 0         -- 碰牌
    self.m_stCardQuadruplet  = {}    -- 杠牌
    self.m_cardTingGroup = {}        -- 听牌方式
    self.m_nCardWin = 0              -- 胡哪张牌
    self.m_nFanNum = 0               -- 胡这张牌的番数
    self.m_nWinFalg = 0              -- 胡牌方式：0正常胡 1抢金胡

    self.m_nBlockRecordFlag = 0      -- 玩家申请过哪种block
    self.m_nBlockRecordCard = 0      -- 玩家申请block的参数
end

function PlayerBlockState:Clear()
    self.m_nCanCollect = 0           -- 是可以吃牌
    self.m_nCanTriplet  = 0          -- 是可以碰
    self.m_nCanQuadruplet = 0        -- 是可以杠
    self.m_nCanTing = 0              -- 是否可以听
    self.m_nCanWin = 0               -- 是可以和
    self.m_nWinFalg = 0              -- 胡牌方式：0正常胡 1抢金胡

    self.m_stCardCollect  = {}       -- 吃牌选择
    self.m_nCardTriplet  = 0         -- 碰牌
    self.m_stCardTingGroup = {}      -- 听牌方式
    self.m_nCardWin = 0
    self.m_nFanNum = 0

    self.m_stCardQuadruplet  = {}    -- 杠牌
    self.m_nQuadrupletType = 0
    self.m_nCanQuadruplet  = 0

    self.m_nBlockRecordFlag = 0      -- 玩家申请过哪种block：0表示没block操作
    self.m_nBlockRecordCard = 0      -- 玩家申请block的参数：胡/碰/杠/吃哪张牌
end

-- 吃牌列表
function PlayerBlockState:SetCollect(bCanCollect, cardCollect)
    if bCanCollect == true then
        self.m_nCanCollect = ACTION_COLLECT
        self.m_stCardCollect = cardCollect
    else
        self.m_nCanCollect  = 0
        self.m_stCardCollect = {}
    end
end

function PlayerBlockState:GetCollect()
    return self.m_nCanCollect
end

function PlayerBlockState:IsCanCollect(cardCollect)
    if self.m_nCanCollect == 0 then
        return false
    end
    for _,collect in ipairs(self.m_stCardCollect) do
        if collect[1] == cardCollect then
            return true
        end
    end
    return false
end

--碰
function PlayerBlockState:GetTriplet()
    return self.m_nCanTriplet
end

function PlayerBlockState:SetTriplet(bCanTriplet, cardTriplet)
    if bCanTriplet == true then
        self.m_nCanTriplet = ACTION_TRIPLET
        self.m_nCardTriplet = cardTriplet
    else
        self.m_nCanTriplet  = 0
        self.m_nCardTriplet =  0
    end
end

function PlayerBlockState:IsCanTriplet(cardTriplet)
    return self.m_nCanTriplet == ACTION_TRIPLET and self.m_nCardTriplet == cardTriplet
end

--杠
function PlayerBlockState:SetQuadruplet(bCanQuadruplet, cardQuadruplet, nQuadrupletType)
    if bCanQuadruplet == true then
        self.m_nCanQuadruplet = ACTION_QUADRUPLET
        self.m_stCardQuadruplet = cardQuadruplet
        self.m_nQuadrupletType = nQuadrupletType
    else
        self.m_nCanQuadruplet  = 0
        self.m_stCardQuadruplet = {}
        self.m_nQuadrupletType = 0
    end
end

function PlayerBlockState:GetQuadruplet()
    return self.m_nCanQuadruplet
end

function PlayerBlockState:IsCanQuadruplet(  )
    return self.m_nCanQuadruplet ~= 0
end

function PlayerBlockState:GetQuadrupletCard()   
    return self.m_stCardQuadruplet
end

--听
function PlayerBlockState:SetTing(bCanTing, stCardTingGroup)
    if bCanTing == true then
        self.m_nCanTing = ACTION_TING
        self.m_stCardTingGroup = stCardTingGroup 
    else
        self.m_nCanTing  = 0
        self.m_stCardTingGroup = {} 
    end      
end

function PlayerBlockState:IsCardCanTing(nCard)
    return self.m_nCanTing == ACTION_TING and self.m_stCardTingGroup[nCard] ~= nil
end

function PlayerBlockState:IsCanTing()
    return self.m_nCanTing == ACTION_TING
end

function PlayerBlockState:GetTingGroup(nCard)
    return self.m_stCardTingGroup[nCard]
end

function PlayerBlockState:GetTingGroupAll()
    return self.m_stCardTingGroup
end

--胡
function PlayerBlockState:SetCanWin(bCanWin, nCard, nFanNum)
    if bCanWin == true then
        self.m_nCanWin = ACTION_WIN
        self.m_nCardWin = nCard
        self.m_nFanNum = nFanNum
    else
        self.m_nCanWin = 0
        self.m_nCardWin = 0
        self.m_nFanNum = 0
    end
end

function PlayerBlockState:GetCurrWinCard()
    return self.m_nCardWin, self.m_nFanNum
end

function PlayerBlockState:GetWin()
    return self.m_nCanWin
end

function PlayerBlockState:IsCanWin()
    if self.m_nCanWin == 0 then 
        return false
    end  
    return true 
end

function PlayerBlockState:SetWinFalg(nWinFalg)
    self.m_nWinFalg = nWinFalg
end

--block
function PlayerBlockState:GetReuslt()
    local stResult =  {
        bCanCollect = ( self.m_nCanCollect > 0),
        bCanTriplet  = (self.m_nCanTriplet > 0),
        bCanQuadruplet = ( self.m_nCanQuadruplet > 0),
        -- bCanTing = (self.m_nCanTing > 0),
        bCanWin = (self.m_nCanWin > 0),
        cardCollect  = self.m_stCardCollect,
        cardTriplet  = {},
        cardQuadruplet  = {},
        -- cardTingGroup = self.m_stCardTingGroup,
        cardWin = {nCard = self.m_nCardWin, nFan = self.m_nFanNum},
        nWinFalg = self.m_nWinFalg,   --胡牌标志：0是正常的胡, 1是抢金
    }

    if self.m_nCardTriplet > 0 then
        local tripletCard = self.m_nCardTriplet
        stResult.cardTriplet = { tripletCard, tripletCard, tripletCard}
    end
    if #self.m_stCardQuadruplet > 0 then
        for _,card in ipairs(self.m_stCardQuadruplet) do
            table.insert(stResult.cardQuadruplet, { card, card, card, card })
        end
    end
    return stResult
end

-- 是否存在挡牌
function PlayerBlockState:IsBlocked()
    local bBlock = (self.m_nCanCollect > 0)
        or (self.m_nCanTriplet  > 0 )
        or (self.m_nCanQuadruplet  > 0)
        -- or (self.m_nCanTing > 0 )
        or (self.m_nCanWin  > 0)

    return bBlock
end

function PlayerBlockState:SetBlockFlag(nFlag, nCard)
    self.m_nBlockRecordFlag = nFlag      
    self.m_nBlockRecordCard = nCard
end

function PlayerBlockState:GetBlockRecordFlag()
    return self.m_nBlockRecordFlag
end

function PlayerBlockState:GetBlockaRecordCard()
    return self.m_nBlockRecordCard
end


return PlayerBlockState