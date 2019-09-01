--普通52张牌 无大小鬼 A最大
GStars_Normal_Cards = {
    0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x0A,0x0B,0x0C,0x0D,0x0E,   --方块 2 - A
    0x12,0x13,0x14,0x15,0x16,0x17,0x18,0x19,0x1A,0x1B,0x1C,0x1D,0x1E,   --梅花 2 - A
    0x22,0x23,0x24,0x25,0x26,0x27,0x28,0x29,0x2A,0x2B,0x2C,0x2D,0x2E,   --红桃 2 - A
    0x32,0x33,0x34,0x35,0x36,0x37,0x38,0x39,0x3A,0x3B,0x3C,0x3D,0x3E,    --黑桃 2 - A
}
-- --普通52张牌 无大小鬼 A最小
-- GStars_Normal_Cards = {
--     0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x0A,0x0B,0x0C,0x0D,   --方块 1(A) - K
--     0x11,0x12,0x13,0x14,0x15,0x16,0x17,0x18,0x19,0x1A,0x1B,0x1C,0x1D,   --梅花 1(A) - K
--     0x21,0x22,0x23,0x24,0x25,0x26,0x27,0x28,0x29,0x2A,0x2B,0x2C,0x2D,   --红桃 1(A) - K
--     0x31,0x32,0x33,0x34,0x35,0x36,0x37,0x38,0x39,0x3A,0x3B,0x3C,0x3D,   --黑桃 1(A) - K
-- }
--鬼牌
GStars_Ghost_Cards = {
    0x4F,   --小鬼
    0x5F,   --大鬼
} 

--普通牌型
GStars_Normal_Type = {
    PT_NIL                  = 0,
    PT_BULL_NONE            = 1,    --无牛
    PT_BULL_ONE             = 2,    --牛一
    PT_BULL_TWO             = 3,    --牛二
    PT_BULL_THREE           = 4,    --牛三
    PT_BULL_FOUR            = 5,    --牛四
    PT_BULL_FIVE            = 6,    --牛五
    PT_BULL_SIX             = 7,    --牛六
    PT_BULL_SEVEN           = 8,    --牛七
    PT_BULL_EIGHT           = 9,    --牛八
    PT_BULL_NINE            = 10,   --牛九
    PT_BULL_TEN             = 11,   --牛牛
    PT_BULL_SMALL           = 12,   --五小牛
    PT_BULL_BOMB            = 13,   --炸弹牛
    PT_BULL_FLOWER          = 14,   --五花牛
}

--特殊牌型
GStars_Special_Type = {
    PT_SP_NIL = 0,
}

--基础分
GStars_Normal_Score = 
{
}

--特殊分
GStars_Special_Score = {
}

--额外加成分
GStars_Ext_Score = {
}

MASK_COLOR = 0xF0   --花色掩码
MASK_VALUE = 0x0F   --数值掩码
--获取牌的花色
function GetCardColor(nCard)
    if nCard == nil or type(nCard) ~= "number" then
        return -1
    else
        local ot = bit.band(nCard, MASK_COLOR)
        return bit.brshift(ot, 4)
    end
end
--获取牌的点数
function GetCardValue(nCard)
    if nCard == nil or type(nCard) ~= "number" then
        return -1
    else
        local nValue = bit.band(nCard, MASK_VALUE)
        --A最小
        if nValue == 14 then
            nValue = 1
        end
        return nValue
    end
end
--根据花色和点数  获取牌
function GetCardByColorValue(nColor, nValue)
    --花色：0-3
    if nColor < 0 or nColor > 3 then
        nColor = nColor % 3
    end

    --A
    if nValue == 1 then
        nValue = 14
    end
    --点数2-14
    if nValue < 2 or nValue > 14 then
        nValue = 0
    end

    return (bit.blshift(nColor, 4) + nValue)
end
--判断是否是鬼牌
function IsGhostCard(nCard)
    local bRet = false
    for _, v in pairs(GStars_Ghost_Cards) do
        if nCard == v then
            bRet = true
            break
        end
    end
    return bRet
end
--获取手牌鬼牌数量
function GetGhostCard(cards)
    if type(cards) ~= "table" then
        return 0
    end

    local count = 0
    for _, v in pairs(cards) do
        if IsGhostCard(v) then
            count = count + 1
        end
    end
    return count
end
--获取特殊积分
function GetSpecialScore(nSpType)
    return GStars_Special_Score[nSpType] or 0
end
--获取加成分 nIndex:1前墩 2中墩 3后墩
function GetExtScore(nIndex, nType)
    if GStars_Ext_Score[nIndex] then
        return GStars_Ext_Score[nIndex][nType] or 0
    else
        return 0
    end
end
--获取基础分
function GetBaseScore(nType)
    if GStars_Normal_Score[nType] then
        return GStars_Normal_Score[nType] or 0
    else
        return 0
    end
end

--只是显示16进制格式  table格式 t={1,2,3,3}
function TableToString(t)
    local str = ""
    if type(t) == "table" then
        for i=1,#t  do
            str = str .. string.format("0x%X, ", t[i])
        end
    end
    return str
end