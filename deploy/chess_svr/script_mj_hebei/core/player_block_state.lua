local PlayerBlockState = class("PlayerBlockState")

function PlayerBlockState:ctor()
    self.m_nCanCollect = 0       -- 是可以吃牌
    self.m_nCanTriplet  = 0      -- 是可以碰
    self.m_nCanQuadruplet = 0    -- 是可以杠
    self.m_nCanTing = 0          -- 是否可以听
    self.m_nCanWin = 0           -- 是可以和

    self.m_stCardCollect  = {}     -- 吃牌选择
    self.m_nCardTriplet  = {}    -- 碰牌
    self.m_cardQuadruplet  = {}  -- 杠牌
    self.m_cardTingGroup = {}    -- 听牌方式
    self.m_nCardWin = 0
    self.m_tbGuoShouHu = {}      -- 漏胡 过手胡
    self.m_tbGuoShouPeng = {}    -- 过手碰
    
    self.m_nBlockRecordFlag = 0  -- 玩家申请过哪种block
    self.m_nBlockRecordCard = 0  -- 玩家申请block的参数
end

function PlayerBlockState:Clear()
    self.m_nCanCollect = 0       -- 是可以吃牌
    self.m_nCanTriplet  = 0      -- 是可以碰
    self.m_nCanQuadruplet = 0    -- 是可以杠
    self.m_nCanTing = 0          -- 是否可以听
    self.m_nCanWin = 0           -- 是可以和

    self.m_stCardCollect  = {}   -- 吃牌选择
    self.m_nCardTriplet  = 0     -- 碰牌
    self.m_stCardTingGroup = {}  -- 听牌方式
    self.m_nCardWin = 0

    self.m_cardQuadruplet  = {}  -- 杠牌
    self.m_nQuadrupletType = 0
        
    self.m_nBlockRecordFlag = 0  -- 玩家申请过哪种block
    self.m_nBlockRecordCard = 0  -- 玩家申请block的参数
end

function PlayerBlockState:GetBlockRecordFlag()
    return self.m_nBlockRecordFlag
end
function PlayerBlockState:GetBlockaRecordCard()
    return self.m_nBlockRecordCard
end
--吃
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
function PlayerBlockState:GetCollectCard()
    return self.m_stCardCollect
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
function PlayerBlockState:GetTripletCard()
    return self.m_nCardTriplet
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

function PlayerBlockState:SetQuadruplet(bCanQuadruplet, cardQuadruplet, nQuadrupletType)
    if bCanQuadruplet == true then
        self.m_nCanQuadruplet = ACTION_QUADRUPLET
    else
        self.m_nCanQuadruplet  = 0
    end
    self.m_cardQuadruplet = cardQuadruplet
    self.m_nQuadrupletType = nQuadrupletType
end

--杠
function PlayerBlockState:GetQuadruplet()
    return self.m_nCanQuadruplet
end
function PlayerBlockState:IsCanQuadruplet(  )
    return self.m_nCanQuadruplet ~= 0
end
function PlayerBlockState:GetQuadrupletCard()   
    return self.m_cardQuadruplet
end

function PlayerBlockState:SetTing(bCanTing, stCardTingGroup)
     if bCanTing == true then
        self.m_nCanTing = ACTION_TING
    else
        self.m_nCanTing  = 0
    end

    self.m_stCardTingGroup = stCardTingGroup    
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

function PlayerBlockState:SetCanWin(bCanWin , nCard)
    if bCanWin == true then
        self.m_nCanWin = ACTION_WIN
        self.m_nCardWin = nCard
    else
        self.m_nCanWin  = 0
    end
end
function PlayerBlockState:GetCurrWinCard()
    return self.m_nCardWin 
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

function PlayerBlockState:GetReuslt()
    local stResult =  {
        bCanCollect = ( self.m_nCanCollect > 0),
        bCanTriplet  = (self.m_nCanTriplet > 0),
        bCanQuadruplet = ( self.m_nCanQuadruplet > 0),
        bCanTing = (self.m_nCanTing > 0),
        bCanWin = (self.m_nCanWin > 0),
        cardCollect  = self.m_stCardCollect,
        cardTriplet  = {},
        cardQuadruplet  = {},
        --cardTingGroup = self.m_stCardTingGroup,
        cardWin = {card = self.m_nCardWin}
    }

    if self.m_nCardTriplet > 0 then
        local tripletCard = self.m_nCardTriplet
         stResult.cardTriplet = { tripletCard, tripletCard, tripletCard}
    end
    if #self.m_cardQuadruplet > 0 then
        for _,card in ipairs(self.m_cardQuadruplet) do
            stResult.cardQuadruplet = {card, card,card, card }    
        end
    end
    return stResult
end

-- 是否存在挡牌
function PlayerBlockState:IsBlocked()
    local bBlock = (self.m_nCanCollect > 0)
        or (self.m_nCanTriplet > 0 )
        or (self.m_nCanQuadruplet > 0)
        or (self.m_nCanTing > 0 )
        or (self.m_nCanWin > 0)

    return bBlock
end
function PlayerBlockState:SetBlockFlag(nFlag, nCard)
    self.m_nBlockRecordFlag = nFlag      
    self.m_nBlockRecordCard = nCard
end

-- 漏胡 过手胡
function PlayerBlockState:DelGuoShouHu()
    self.m_tbGuoShouHu = {}
end
function PlayerBlockState:IsGuoShouHu(nCard)
    return self.m_tbGuoShouHu[nCard]
end
function PlayerBlockState:SetGuoShouHu(nCard)
    self.m_tbGuoShouHu[nCard] = nCard
end

-- 过手碰
function PlayerBlockState:DelGuoShouPeng()
    self.m_tbGuoShouPeng = {}
end
function PlayerBlockState:IsGuoShouPeng(nCard)
    return self.m_tbGuoShouPeng[nCard]
end
function PlayerBlockState:SetGuoShouPeng(nCard)
    self.m_tbGuoShouPeng[nCard] = nCard
end


return PlayerBlockState