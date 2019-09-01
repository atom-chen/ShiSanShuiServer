--普通52张牌 无大小鬼
GStars_Normal_Cards = {
    0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x0A,0x0B,0x0C,0x0D,0x0E,   --方块 2 - A
    0x12,0x13,0x14,0x15,0x16,0x17,0x18,0x19,0x1A,0x1B,0x1C,0x1D,0x1E,   --梅花 2 - A
    0x22,0x23,0x24,0x25,0x26,0x27,0x28,0x29,0x2A,0x2B,0x2C,0x2D,0x2E,   --红桃 2 - A
    0x32,0x33,0x34,0x35,0x36,0x37,0x38,0x39,0x3A,0x3B,0x3C,0x3D,0x3E,    --黑桃 2 - A
}


--牌型
GStars_Normal_Type = {
    PT_ERROR = -1,
    PT_NO_COW = 0,                         --无牛
    PT_COW_ONE= 1,                         --牛一    
    PT_COW_TWO = 2,                        --牛二
    PT_COW_THREE = 3,                      --牛三
    PT_COW_FOUR = 4,                       --牛四
    PT_COW_FIVE = 5,                       --牛五
    PT_COW_SIX = 6,                        --牛六
    PT_COW_SEVEN = 7,                      --牛七
    PT_COW_EIGHT = 8,                      --牛八
    PT_COW_NINE = 9,                       --牛九
    PT_COW_TEN = 10,                       --牛牛
    PT_COW_FIVE_FLOAR = 11,                --五花牛
    PT_COW_BOMB = 12,                      --炸弹牛
    PT_COW_FIVE_LITTLE = 13,               --五小牛
}


--每种牌的倍数
GStars_Normal_Score = 
{
    [GStars_Normal_Type.PT_NO_COW]                =  1,
    [GStars_Normal_Type.PT_COW_ONE]               =  1,
    [GStars_Normal_Type.PT_COW_TWO]               =  1,
    [GStars_Normal_Type.PT_COW_THREE]             =  1,
    [GStars_Normal_Type.PT_COW_FOUR]              =  1,
    [GStars_Normal_Type.PT_COW_FIVE]              =  1,
    [GStars_Normal_Type.PT_COW_SIX]               =  1,
    [GStars_Normal_Type.PT_COW_SEVEN]             =  2,
    [GStars_Normal_Type.PT_COW_EIGHT]             =  2,
    [GStars_Normal_Type.PT_COW_NINE]              =  3,
    [GStars_Normal_Type.PT_COW_TEN]               =  4,
    [GStars_Normal_Type.PT_COW_FIVE_FLOAR]        =  5,
    [GStars_Normal_Type.PT_COW_BOMB]              =  6,
    [GStars_Normal_Type.PT_COW_FIVE_LITTLE]       =  8,
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
        return bit.band(nCard, MASK_VALUE)
    end
end
--根据花色和点数  获取牌
function GetCardByColorValue(nColor, nValue)
    花色：0-3
    if nColor < 0 or nColor > 3 then
        nColor = nColor % 3
    end

    A
    if nValue == 1 then
        nValue = 14
    end
    点数2-14
    if nValue < 2 or nValue > 14 then
        nValue = 0
    end

    return (bit.blshift(nColor, 4) + nValue)
end

--获取特殊积分
function GetSpecialScore(nSpType)
    return GStars_Special_Score[nSpType] or 0
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