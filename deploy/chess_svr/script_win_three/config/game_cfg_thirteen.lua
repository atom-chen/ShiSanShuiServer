--[[
-- 游戏相关的的配置
--]]
local GameCfg =  {
       nMoneyMode = MONEY_MODE_MONEY, --默认是金币场，传配置则是房卡场
       nPlayerNum = 4,      --默认4人
       nJuNum     = 10,     -- 一圈多少局（房卡模式）
       nCurrJu    = 1,      -- 当前是第几局
       rno        = 0,      -- 房号

       --房间设置
       RoomSetting = {
            nChargeMode = CHARGE_MODE_FREE,          -- 扣费方式
            nGameStyle = GAME_STYLE_THIRTEEN,        -- 游戏类型  十三张等
            nSubGameStyle = SUB_GAME_STYLE_NORMAL,   --游戏子类型：普通，水庄等。。。
            nBaseBet = 100,                          -- 底分, 各个地区规则计算完底分后，再计算这里的
            nMaxWaterScore = 8,
            stringEncoding = "config.string_encoding_cn_thirteen"
        },

        --定时时间
        TimerSetting = {
            readyTimeOut = -1,              -- -1则不设定定时器 不超时一直等
            multTimeOut = 30,               --水庄闲家加倍选择 -1为不超时一直等

            chooseCardTypeTimeOut = 300,     -- 选择牌型超时时间(秒)
            -- startTime = 1,                  --开始动画
            -- shuffTime = 2,                  --洗牌动画

            --compareTimeOut = 30,            -- 比牌超时时间(秒)
            oneCompareTime = 3,               -- 翻开一墩牌时间
            --时间计算1：比牌时间+打枪时间(打枪人数*oneShootTime)+全垒打时间(全垒打人数*allShootTime)
            oneShootTime = 9,               -- 打一次枪的时间
            allShootTime = 3,               -- 全垒打的时间
            ---注意有特殊牌  则表明没有打枪和全垒打
            --时间计算2：比牌时间+特殊时间(特殊牌数量*specialCardTime)
            oneSpecialTime = 9,            -- 每个特殊牌展示时间
            --时间计算3(特殊比牌即最多只有一个玩家不是特殊牌):特殊时间(特殊牌数量*oneSpecialTime)

            TimeOutLimit = -1,              -- 房卡场除ready外不设置超时
        },

        --游戏设置
        GameSetting = {
            nSupportAddColor = 0,           --0不加色， 1加一色， 2加二色
            bSupportGhostCard = false,      --是否加鬼牌
            bSupportWaterBanker = false,    --是否加一色坐庄(水庄)
            bSupportBuyCode = false,        --是否买码
            nSupportMaxMult = 1,            --水庄，支持闲家最大倍数
        },

        --行为树
        FlowSetting = {
            strFlowDealer = "../script_thirteen/config/flow_dealer_thirteen.json",
            strFlowPlayer = "../script_thirteen/config/flow_player_thirteen.json",
            strFlowPlayerExt = "../script_thirteen/config/flow_player_thirteen_ext.json",
        },
}

return GameCfg
