import(".card_define")
import(".error_msg_define")


STEP_SUCCEED = 1
STEP_FAILED = 2

-- DEALER_ID = 10000
-- DEALER_TIMER_ID_0 = 0

-- 桌上玩家数 G_TABLEINFO.nPlayerNum
PLAYER_NUMBER = 4
-- 手牌数量
MAX_HAND_CARD_NUM = 13
-- 桌上最大的牌数 默认
MAX_TOTAL_CARD_NUM  = 52

-- 扣费方式
CHARGE_MODE_FREE = 0    -- 免费
CHARGE_MODE_PUMP = 1    -- 抽水
CHARGE_MODE_TICKET = 2  -- 门票
CHARGE_MODE_SERVICE = 3 -- 服务费

--游戏场次：金币 房卡
MONEY_MODE_SCORE  = 1      --积分场
MONEY_MODE_MONEY = 2       -- 货币场
ROOM_MODE_SCORE = 3        -- 房卡场

-- 玩家游戏状态
PLAYER_STATUS_NOLOGIN = 0   --用户未进入
PLAYER_STATUS_SIT = 1       --用户坐在座位上，没点开始
PLAYER_STATUS_READY = 2     --用户已经点了开始，等待其他玩家

-- 游戏类型
GAME_STYLE_THIRTEEN = 0x01    --十三张
--游戏子类型
SUB_GAME_STYLE_NORMAL = 1        --普通 默认
SUB_GAME_STYLE_SHUIZHUANG = 2    --水庄

--各个阶段的timerid 定义  以免搞混了
--DEALER_TIMER_ID_XX
--PLAYER_TIMER_ID_XX
PLAYER_TIMER_ID_READY = 100     --准备
PLAYER_TIMER_ID_CHOOSE = 101    --选择牌型
PLAYER_TIMER_ID_MULT = 102      --选择倍数


ALL_SHOOT_PLAYER_NUM = 3        --几人可以全垒打