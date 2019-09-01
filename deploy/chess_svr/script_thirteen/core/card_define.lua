--普通52张牌 无大小鬼
GStars_Normal_Cards = {
    0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x0A,0x0B,0x0C,0x0D,0x0E,   --方块 2 - A
    0x12,0x13,0x14,0x15,0x16,0x17,0x18,0x19,0x1A,0x1B,0x1C,0x1D,0x1E,   --梅花 2 - A
    0x22,0x23,0x24,0x25,0x26,0x27,0x28,0x29,0x2A,0x2B,0x2C,0x2D,0x2E,   --红桃 2 - A
    0x32,0x33,0x34,0x35,0x36,0x37,0x38,0x39,0x3A,0x3B,0x3C,0x3D,0x3E,    --黑桃 2 - A
}
--鬼牌
GStars_Ghost_Cards = {
    0x4F,   --小鬼
    0x5F,   --大鬼
} 
--加一色
GStars_One_Color = {
    0x12,0x13,0x14,0x15,0x16,0x17,0x18,0x19,0x1A,0x1B,0x1C,0x1D,0x1E,   --梅花 2 - A
}
--加二色
GStars_Two_Color = {
    0x12,0x13,0x14,0x15,0x16,0x17,0x18,0x19,0x1A,0x1B,0x1C,0x1D,0x1E,   --梅花 2 - A
    0x22,0x23,0x24,0x25,0x26,0x27,0x28,0x29,0x2A,0x2B,0x2C,0x2D,0x2E,   --红桃 2 - A
}
--码牌 红桃8
GStars_Code_Card = 0x28

--普通牌型
GStars_Normal_Type = {
    PT_ERROR = 0,
    PT_SINGLE = 1,                          --散牌(乌龙)    
    PT_ONE_PAIR = 2,                        --一对
    PT_TWO_PAIR = 3,                        --两对
    PT_THREE = 4,                           --三条
    PT_STRAIGHT = 5,                        --顺子
    PT_FLUSH = 6,                           --同花
    PT_FULL_HOUSE = 7,                      --葫芦
    PT_FOUR = 8,                            --铁支(炸弹)
    PT_STRAIGHT_FLUSH = 9,                  --同花顺
    PT_FIVE = 10,                           -- 五同
}

--特殊牌型
GStars_Special_Type = {
    PT_SP_NIL = 0,
    PT_SP_THREE_FLUSH = 1,              --三同花
    PT_SP_THREE_STRAIGHT = 2,           --三顺子
    PT_SP_SIX_PAIRS = 3,                --六对半   6对+散牌
    PT_SP_FIVE_PAIR_AND_THREE = 4,      --五队冲三 5对+3条
    PT_SP_SAME_SUIT = 5,                --凑一色
    PT_SP_ALL_SMALL = 6,                --全小
    PT_SP_ALL_BIG = 7,                  --全大
    PT_SP_SIX = 8,                      --六六大顺  6同
    PT_SP_THREE_STRAIGHT_FLUSH = 9,     --三同花顺
    PT_SP_ALL_KING = 10,                --十二皇族
    PT_SP_FIVE_AND_THREE_KING = 11,     --三皇五帝 2个5同+3条
    PT_SP_THREE_BOMB = 12,              --三炸弹   3个铁枝
    PT_SP_FOUR_THREE = 13,              --四套三条  4个3条
    PT_SP_STRAIGHT = 14,                --一条龙
    PT_SP_STRAIGHT_FLUSH = 15,          --至尊清龙
    PT_SP_SEVEN = 16,                   --7同
    PT_SP_EIGHT = 17,                   --8同
}

--普通牌型每一墩算1水
GStars_Normal_Score = 
{
    [GStars_Normal_Type.PT_SINGLE]              =  1,
    [GStars_Normal_Type.PT_ONE_PAIR]            =  1,
    [GStars_Normal_Type.PT_TWO_PAIR]            =  1,
    [GStars_Normal_Type.PT_THREE]               =  1,
    [GStars_Normal_Type.PT_STRAIGHT]            =  1,
    [GStars_Normal_Type.PT_FLUSH]               =  1,
    [GStars_Normal_Type.PT_FULL_HOUSE]          =  1,
    [GStars_Normal_Type.PT_FOUR]                =  4,
    [GStars_Normal_Type.PT_STRAIGHT_FLUSH]      =  5,
    [GStars_Normal_Type.PT_FIVE]                =  10,
}

--特殊分
GStars_Special_Score = {
    [GStars_Special_Type.PT_SP_NIL]                     = 0,
    [GStars_Special_Type.PT_SP_THREE_FLUSH]             = 6,
    [GStars_Special_Type.PT_SP_THREE_STRAIGHT]          = 6,
    [GStars_Special_Type.PT_SP_SIX_PAIRS]               = 6,
    [GStars_Special_Type.PT_SP_FIVE_PAIR_AND_THREE]     = 6,
    [GStars_Special_Type.PT_SP_SAME_SUIT]               = 6,
    [GStars_Special_Type.PT_SP_ALL_SMALL]               = 6,
    [GStars_Special_Type.PT_SP_ALL_BIG]                 = 6,
    [GStars_Special_Type.PT_SP_SIX]                     = 20,
    [GStars_Special_Type.PT_SP_THREE_STRAIGHT_FLUSH]    = 26,
    [GStars_Special_Type.PT_SP_ALL_KING]                = 26,
    [GStars_Special_Type.PT_SP_FIVE_AND_THREE_KING]     = 26,
    [GStars_Special_Type.PT_SP_SEVEN]                   = 40,   --7
    [GStars_Special_Type.PT_SP_THREE_BOMB]              = 52,
    [GStars_Special_Type.PT_SP_FOUR_THREE]              = 52,
    [GStars_Special_Type.PT_SP_STRAIGHT]                = 52,
    [GStars_Special_Type.PT_SP_EIGHT]                   = 80,   --8
    [GStars_Special_Type.PT_SP_STRAIGHT_FLUSH]          = 104,
}

--加成分
PT_THREE_GHOST = 1000       --前墩 鬼牌冲三
GStars_Ext_Score = {
    --前墩加成
    [1] = {
        [GStars_Normal_Type.PT_THREE] = 2,
        [PT_THREE_GHOST] = 19,
    },
    --中墩加成
    [2] = {
        [GStars_Normal_Type.PT_FIVE] = 10,
        [GStars_Normal_Type.PT_STRAIGHT_FLUSH] = 5,
        [GStars_Normal_Type.PT_FOUR] = 4,
        [GStars_Normal_Type.PT_FULL_HOUSE] = 1,
    },
    --后墩加成
    [3] = {
        [GStars_Normal_Type.PT_FIVE] = 0,
        [GStars_Normal_Type.PT_STRAIGHT_FLUSH] = 0,
        [GStars_Normal_Type.PT_FOUR] = 0,
    },
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
--是否是码牌
function IsCodeCard(nCard)
    return (GStars_Code_Card == nCard)
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