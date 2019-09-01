import(".card_define")
import(".error_msg_define")


STEP_SUCCEED = 1
STEP_FAILED = 2

-- DEALER_ID = 10000

CONTINUE_PLAY_REASON_MONEY = 1

PLAYER_NUMBER          = 4    -- 桌上玩家数 G_TABLEINFO.nPlayerNum
WATCHER_NUMBER         = 16   -- 最多可以旁观的人数
MAX_FAN_NUMBER         = 128  -- 最多有多少种番
MAX_HAND_CARD_NUM      = 17   -- 手上最多可以有多少张牌
MAX_TOTAL_CARD_NUM     = 144  -- 桌上最大的牌数



KICK_CANNOT_LOCK_MONEY         = 1010
KICK_NOMONEY                   = 1011
KICK_EXCEED_MONEY              = 1012


-- 扣费方式
CHARGE_MODE_FREE               = 0  -- 免费
CHARGE_MODE_PUMP               = 11 -- 抽水
CHARGE_MODE_TICKET             = 12 -- 门票
CHARGE_MODE_SERVICE            = 13 -- 服务费

-- 玩家游戏状态
PLAYER_STATUS_NOLOGIN          = 0     -- 用户未进入
PLAYER_STATUS_SIT              = 1     -- 用户坐在座位上，没点开始
PLAYER_STATUS_READY            = 2     -- 用户已经点了开始，等待其他玩家
-- PLAYER_STATUS_FLOWER        = 3     -- 补花，刚收到牌时做的
-- PLAYER_STATUS_GIVE          = 4     -- 出牌
-- PLAYER_STATUS_WAIT          = 5     -- 等待别人出牌或者选择吃、碰
-- PLAYER_STATUS_BLOCK         = 6     -- 选择是否吃碰
-- PLAYER_STATUS_LOOKON        = 7     -- 旁观
-- PLAYER_STATUS_OFFLINE       = 8     -- 掉线
-- PLAYER_STATUS_RE_SIT        = 9     -- 重新坐下
-- PLAYER_STATUS.psQiangZhuang = 9     -- 抢庄

-- 游戏状态
GAME_STATUS_NOSTART            = 0   -- 未开始
-- GAME_STATUS_PREPARE		   = 10	 -- 已准备
-- GAME_STATUS_DEAL		       = 20	 -- 已开始
-- GAME_STATUS_LAIZI		   = 30	 -- 已开始
-- GAME_STATUS_XIAPAO		   = 40	 -- 下跑
-- GAME_STATUS_ROUND		   = 50	 -- 开始出牌
-- GAME_STATUS_REWARD		   = 60	 -- 结算
-- GAME_STATUS_GAMEEND		   = 70	 -- 游戏结束
  
-- GAME_STATUS_FLOWER          = 1     -- 补花
-- GAME_STATUS_GIVE            = 2     -- 等待某玩家出牌，即玩家下一步该出牌
-- GAME_STATUS_BLOCK           = 3     -- 等待玩家拦牌：吃、碰、杠、和，即下一步该抓牌
-- GAME_STATUS_SELFBLOCK       = 4     -- 自己抓牌后能碰、和
-- GAME_STATUS_QIANGZHUANG     = 5     -- 抢庄


--定义吃、碰、杠
ACTION_EMPTY                   = 0x0
ACTION_COLLECT                 = 0x10
ACTION_TRIPLET                 = 0x11
ACTION_QUADRUPLET              = 0x12   -- 明杠
ACTION_QUADRUPLET_CONCEALED    = 0x13   -- 暗杠
ACTION_QUADRUPLET_REVEALED     = 0x14   -- 补杠 先碰后杠
ACTION_WIN                     = 0x15
ACTION_TING                    = 0x16
ACTION_FLOWER                  = 0x17


-- 听牌
TING_NONE                = 0x00
TING_REQUEST_REVEALED    = 0x1
TING_REQUEST_CONCEALED   = 0x2
TING_REVEALED            = 0x3
TING_CONCEALED           = 0x4
TING_NORMAL              = 0X5  -- 听牌
TING_TIAN                = 0X6  -- 天听
TING_DI                  = 0X7  -- 地听
TING_XIAOSA              = 0X8  -- 潇洒


-- 胡方式
WIN_SELFDRAW                = 0  -- 自摸
WIN_GUN                     = 1  -- 点炮
WIN_GANGDRAW                = 2  -- 杠上花
WIN_GANG                    = 3  -- 抢杠
WIN_GANGGIVE                = 4  -- 杠上炮
  
-- 出牌状态                 
GIVE_STATUS_NONE            = 0  -- 普通
GIVE_STATUS_GANG            = 1  -- 明杠
GIVE_STATUS_GANGGIVE        = 2  -- 开杠后打出来的
GIVE_STATUS_COLLECT         = 3  -- 吃牌后打出来的

DRAW_STATUS_NONE            = 0
DRAW_STATUS_GANG            = 1  -- 杠起来的

-- 抢杠
QIANGGANG_STATUS_NONE                       = 0
QIANGGANG_STATUS_START                      = 1  -- 抢杠开始 
QIANGGANG_STATUS_OK                         = 2  -- 抢杠成功
QIANGGANG_STATUS_GIVEUP                     = 3  -- 抢杠放弃

-- 定时器                   
TIMER_STATUS_NONE           = 0
TIMER_STATUS_FLOWER         = 1
TIMER_STATUS_GIVE           = 2
TIMER_STATUS_BLOCK          = 3

  
-- 房间类型                 
GAME_STYLE_NORMAL           =  0x01    -- 不记番场
GAME_STYLE_GUOBIAO          =  0x02    -- 国标
GAME_STYLE_POP              =  0x03    -- 大众麻将
-- GAME_STYLE_LUXURY        =  0x04    -- 豪华麻将

GAME_STYLE_CHENGDU          =  0X04    -- 地方麻将:成都麻将
GAME_STYLE_HANGZHOU         =  0x05    -- 地方麻将:杭州麻将
GAME_STYLE_WUHAN            =  0x06    -- 地方麻将:武汉麻将
  
GAME_STYLE_ZHENGZHOU        =  0x11    -- 地方麻将:郑州麻将17
GAME_STYLE_ZHUMADIAN        =  0x12	   -- 地方麻将:驻马店麻将18
GAME_STYLE_LUOYANG          =  0x13	   -- 地方麻将:洛阳麻将19

GAME_STYLE_SHIJIAZHUANG     =  0x21	   -- 地方麻将:石家庄麻将33
GAME_STYLE_BAZHOU           =  0x22	   -- 地方麻将:霸州麻将34
GAME_STYLE_LANGFANG         =  0x23	   -- 地方麻将:廊坊麻将35


GAME_STYLE_FUZHOU               = 0x24    -- 地方麻将:福州麻将36
GAME_STYLE_QUANZHOU             = 0x25    -- 地方麻将:泉州州麻将37
GAME_STYLE_XIAMEN               = 0x26    -- 地方麻将: 厦门麻将38
GAME_STYLE_ZHANGZHOU            = 0x27    -- 地方麻将:漳州麻将39

GAME_STYLE_TANGSHAN        		=  0x28	   -- 地方麻将:唐山麻将40

  
LOCAL_CHENGDU_NOT_XUEZHAN   = 0        -- 成都麻将，非血战模式。
LOCAL_CHENGDU_XUEZHAN       = 1        -- 成都麻将，血战模式。 
LOCAL_CHENGDU_XUELIU        = 2        -- 成都麻将，血流模式。 

MONEY_MODE_SCORE  = 1       -- 积分场
MONEY_MODE_MONEY  = 2       -- 货币场
ROOM_MODE_SCORE   = 11		-- 房卡场


BALANCE_TYPE_QUADRUPLET_CONCEALED   = 1   -- 刮风结算
BALANCE_TYPE_QUADRUPLET_REVEALED    = 2   -- 下雨结算
BALANCE_TYPE_WIN                    = 3   -- 和牌结算
BALANCE_TYPE_RETURN_QUADRUPLET      = 5   -- 退税
BALANCE_TYPE_UNTING_TO_TING         = 6   -- 未听牌 补偿
BALANCE_TYPE_HUAZHU                 = 7   -- 查花猪


SCORE_RECORD_TYPE_WIND     = 1
SCORE_RECORD_TYPE_RAIN     = 2
SCORE_RECORD_TYPE_GUN      = 3
SCORE_RECORD_TYPE_SELFWIN  = 4   -- 自摸
SCORE_RECORD_TYPE_HUAZHU   = 5
SCORE_RECORD_TYPE_DAJIAO   = 6
SCORE_RECORD_TYPE_TAX      = 7


--todo :根据gid来确定麻将类型 房间类型？？？ 这个应该直接发过来就行
GID_GOLD_ZHENGZHOU       = 1    -- 郑州金币	
GID_GOLD_ZHUMADIAN       = 2    -- 驻马店金币
GID_GOLD_LUOYANG         = 3    -- 洛阳金币
GID_ROOM_ZHENGZHOU       = 4    -- 郑州房卡
GID_ROOM_ZHUMADIAN       = 5    -- 驻马店房卡
GID_ROOM_LUOYANG         = 6    -- 洛阳房卡

GID_GOLD_SHIJIAZHUANG    = 12   -- 石家庄金币
GID_GOLD_BAZHOU          = 13   -- 霸州金币
GID_GOLD_LANGFANG        = 14   -- 廊坊金币
GID_ROOM_SHIJIAZHUANG    = 15   -- 石家庄房卡
GID_ROOM_BAZHOU          = 16   -- 霸州房卡
GID_ROOM_LANGFANG        = 17   -- 廊坊房卡