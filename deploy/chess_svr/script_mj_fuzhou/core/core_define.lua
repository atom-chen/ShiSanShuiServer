import(".card_define")
import(".error_msg_define")


STEP_SUCCEED = 1
STEP_FAILED = 2

-- DEALER_ID = 10000
-- DEALER_TIMER_ID_0 = 0

-- 桌上玩家数
PLAYER_NUMBER    = 4 -- G_TABLEINFO.nPlayerNum

-- 最多可以旁观的人数
WATCHER_NUMBER =16

-- 手上最多可以有多少张牌
MAX_HAND_CARD_NUM = 17 
-- 桌上最大的牌数 
MAX_TOTAL_CARD_NUM  = 144

-- 最多有多少种番
MAX_FAN_NUMBER =128 

--退出原因
-- KICK_CANNOT_LOCK_MONEY          = 1010
-- KICK_NOMONEY                    = 1011
-- KICK_EXCEED_MONEY               = 1012
 


-- 扣费方式
CHARGE_MODE_FREE                = 0     -- 免费
CHARGE_MODE_PUMP                = 11    -- 抽水
CHARGE_MODE_TICKET              = 12    -- 门票
CHARGE_MODE_SERVICE             = 13    -- 服务费

-- 玩家游戏状态
PLAYER_STATUS_NOLOGIN           = 0     --用户未进入
PLAYER_STATUS_SIT               = 1     --用户坐在座位上，没点开始
PLAYER_STATUS_READY             = 2     --用户已经点了开始，等待其他玩家

-- 游戏状态
GAME_STATUS_NOSTART             = 0     --未开始


--定义吃、碰、杠
ACTION_EMPTY                    = 0x0
ACTION_COLLECT                  = 0x10  -- 吃
ACTION_TRIPLET                  = 0x11  -- 碰
ACTION_QUADRUPLET               = 0x12	-- 明杠
ACTION_QUADRUPLET_CONCEALED     = 0x13  -- 暗杠
ACTION_QUADRUPLET_REVEALED      = 0x14  -- 补杠  先碰后杠
ACTION_WIN                      = 0x15  -- 胡



--胡大牌的优先级 清一色>金龙>混一色>金雀>无花无杠
ACTION_NOHUAGANG                     =0x18
ACTION_BIRD                     =0x19
ACTION_HALFQYS                    =0x20
ACTION_LONG                     =0x21
ACTION_QYS                    =0x22


--抢金阶段三金倒优先级最高>抢金
ACTION_THREEGOLD                    =0x23





--ACTION_TING                     = 0x16  -- 听
--ACTION_FLOWER                   = 0x17  -- 补花？？

-- 听牌
TING_NONE                       = 0x00
-- TING_REQUEST_REVEALED           = 0x1
-- TING_REQUEST_CONCEALED          = 0x2
-- TING_REVEALED                   = 0x3
-- TING_CONCEALED                  = 0x4

-- 胡方式
WIN_SELFDRAW                    = 0     -- 自摸
WIN_GUN                         = 1     -- 点炮
WIN_GANGDRAW                    = 2     -- 杠上花
WIN_GANG                        = 3     -- 抢杠
WIN_GANGGIVE                    = 4     -- 杠上炮
WIN_CHD_NOTILE                  = 5     -- 成都麻将荒牌查大叫查花猪
WIN_CHD_EXIT                    = 6     -- 有人逃跑
WIN_ROBGOLG                     = 7     -- 抢金胡
              
-- 出牌状态(什么原因出牌)                 
GIVE_STATUS_NONE                = 0     -- 普通
GIVE_STATUS_GANG                = 1     -- 明杠
GIVE_STATUS_GANGGIVE            = 2     -- 开杠后打出来的
GIVE_STATUS_COLLECT             = 3     -- 吃牌后打出来的
GIVE_STATUS_TRIPLE              = 4     -- 碰牌后打出来的

--拿牌状态(什么原因拿牌)                               
DRAW_STATUS_NONE                = 0     -- 普通
DRAW_STATUS_GANG                = 1     -- 杠起来的

--抢杠
QIANGGANG_STATUS_NONE           = 0
QIANGGANG_STATUS_START          = 1 
QIANGGANG_STATUS_OK             = 2     -- 抢杠c成功
QIANGGANG_STATUS_GIVEUP         = 3     -- 抢杠放弃 

--打金牌 胡牌限制
GOLD_HU_SELFDRAW                = 1     --打了金牌 只可以自摸
GOLD_HU_GANGDRAW                = 2     --打了金牌 只可以杠上花

--====房间类型
GAME_STYLE_FUZHOU               = 0x24    -- 地方麻将:福州麻将36
GAME_STYLE_QUANZHOU             = 0x25    -- 地方麻将:泉州州麻将37
GAME_STYLE_XIAMEN               = 0x26    -- 地方麻将: 厦门麻将38
GAME_STYLE_ZHANGZHOU            = 0x27    -- 地方麻将:漳州麻将39
--玩法
LOCAL_PLAY_ROUND                = 1       --打局
LOCAL_PLAY_SCORE                = 2       --打课

--游戏场分类
MONEY_MODE_SCORE                = 1       --积分场
MONEY_MODE_MONEY                = 2       -- 货币场
ROOM_MODE_SCORE                 = 11      -- 房卡场

--各个阶段的timerid 定义  以免搞混了
--DEALER_TIMER_ID_XX
--PLAYER_TIMER_ID_XX
PLAYER_TIMER_ID_READY = 100     --准备


CONTINUE_PLAY_REASON_MONEY = 1


function GetCardType(nCard, nGameStyle)
    if nCard >=CARD_CHAR_1 and nCard <= CARD_CHAR_9 then
        return CARDTYPE_CHAR
    elseif nCard >=CARD_BAMBOO_1 and nCard <= CARD_BAMBOO_9 then
        return CARDTYPE_BAMBOO
    elseif nCard >=CARD_BALL_1 and nCard <= CARD_BALL_9 then
        return CARDTYPE_BALL
    end

    if nGameStyle == GAME_STYLE_FUZHOU then
        if nCard >=CARD_EAST and nCard <= CARD_ZHONG then
            return CARDTYPE_FLOWER
        elseif nCard == CARD_FA then
            return CARDTYPE_FLOWER
        elseif nCard == CARD_BAI then
            return CARDTYPE_FLOWER
        elseif nCard >=CARD_FLOWER_CHUN and nCard <= CARD_FLOWER_JU then
            return CARDTYPE_FLOWER
        end
    else
        if nCard >=CARD_EAST and nCard <= CARD_ZHONG then
            return CARDTYPE_WIND
        elseif nCard == CARD_FA then
            return CARDTYPE_FA
        elseif nCard == CARD_BAI then
            return CARDTYPE_BAI
        elseif nCard >=CARD_FLOWER_CHUN and nCard <= CARD_FLOWER_JU then
            return CARDTYPE_FLOWER
        end
    end

    return CARDTYPE_NONE
end