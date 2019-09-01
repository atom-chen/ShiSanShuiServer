-- 加载 slot/change_card
local LibBase = import(".lib_base")
local LibGoldCard = class("LibGoldCard", LibBase)

function LibGoldCard:ctor()
    self.m_stGoldCards = {}     -- 金牌列表,可以有多个:如开的金牌是春,则春夏秋冬都是金牌
    self.m_nOpenGoldCard = 0    -- 翻开的金牌
end

function LibGoldCard:CreateInit(strSlotName)
    self.m_stGoldCards = {}
    self.m_nOpenGoldCard = 0
    return true
end

function LibGoldCard:OnGameStart()
    self.m_stGoldCards = {}
    self.m_nOpenGoldCard = 0
end

--开金
function LibGoldCard:SetOpenGoldCard(nGoldCard)
    if nGoldCard and nGoldCard > 0 then
        self.m_nOpenGoldCard = nGoldCard
    end
end

function LibGoldCard:GetOpenGoldCard()
    return self.m_nOpenGoldCard
end

function LibGoldCard:IsGoldCard(nCard)
    local bGoldCard = false
    for _, v in pairs(self.m_stGoldCards) do
        if v == nCard then
            bGoldCard =true
            break
        end
    end

    return bGoldCard
end

--金牌列表 可以有多个
function LibGoldCard:AddGoldCards(nGoldCard)
    if nGoldCard and nGoldCard > 0 then
        table.insert(self.m_stGoldCards, nGoldCard)
    end
end

function LibGoldCard:IsOpenGoldEnd()
    LOG_DEBUG("LibGoldCard:IsOpenGoldEnd...nCurrJu:%d...%d", GGameCfg.nCurrJu, #self.m_stGoldCards)
    return #self.m_stGoldCards > 0
end

function LibGoldCard:GetGoldCards()
    local t = Array.Clone(self.m_stGoldCards)
    return t
end

return LibGoldCard