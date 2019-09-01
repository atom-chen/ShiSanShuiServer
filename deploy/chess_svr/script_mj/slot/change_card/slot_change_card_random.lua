local slot = {}
import("core.card_define")
EN_CHANGCARDTYPE_CLOCKWISE = 1
EN_CHANGCARDTYPE_ANTI_CLOCKWISE = 2
EN_CHANGCARDTYPE_OPPOSITE = 3


-- 是否是正确的type
local function IsValidCardType(nType)
    return nType == CARDTYPE_CHAR 
            or nType == CARDTYPE_BAMBOO 
            or nType == CARDTYPE_BALL
end



local stChangeCard = GGameCfg.GameSlotSetting.stChangeCard

function slot.GetChangeCardType()
    return math.random(EN_CHANGCARDTYPE_CLOCKWISE,EN_CHANGCARDTYPE_OPPOSITE)
end
function slot.GetChangeCardNum()
    return stChangeCard.nChangeCardNum
end
function slot.IsNeedChangeSame()
    return stChangeCard.bIsNeedChangeSame
end


function slot.IsCanSubmitChange(stCards)
    if #stCards ~= slot.GetChangeCardNum() then
        return false
    end
     local nCardTypeAll = GetCardType(stCards[1])
    for i=1,#stCards do
        local nCardType = GetCardType(stCards[i])
        if IsValidCardType(nCardType)  == false then
            return false
        end
        if nCardType ~= nCardTypeAll then
            return false
        end

    end
    return true

end
function slot.SelectCardChange(stPlayerCards)
    local stCardTypeCount = {
        [CARDTYPE_CHAR] = 0,
        [CARDTYPE_BAMBOO] = 0,
        [CARDTYPE_BALL] = 0,
    }
    
    local num = slot.GetChangeCardNum()
    
    for _,nCard in ipairs(stPlayerCards) do
        local nType = GetCardType(nCard)
        if stCardTypeCount[nType]  ~= nil then
            stCardTypeCount[nType] = stCardTypeCount[nType] + 1
        end
    end
    local minType = CARDTYPE_NONE
    local minCount = 15
    for type,count in pairs(stCardTypeCount) do
        if count >= 3 and count < minCount then
            minType = type
            minCount = count
        end
    end
    -- 从 mintype 中取三张牌
    local stCards = {}
    for _,nCard in ipairs(stPlayerCards) do
        if GetCardType(nCard) == minType then
            table.insert(stCards, nCard)
            if #stCards == num then
                break
            end
        end
    end
    
    return stCards
end
return slot
