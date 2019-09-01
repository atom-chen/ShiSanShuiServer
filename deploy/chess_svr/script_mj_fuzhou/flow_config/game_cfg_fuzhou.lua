--[[
-- 游戏相关的的配置
--]]
import("core.core_define")
local GameCfg =  {
       nLeftCardNeedQuict = 0,         --剩余多少张牌算荒局
       nMoneyMode = MONEY_MODE_MONEY,   --默认是金币声，传配置则是房卡场
       nPlayerNum = 4,
       nJuNum     = 2,      -- 一圈多少局（房卡模式）
       nCurrJu    = 1,      -- 当前是第几局
       rno        = 0,      -- 房号
       CardPoolType =  {"char", "bamboo", "ball","wind", "fabai", "flower"},
       RoomSetting = {
            nChargeMode = CHARGE_MODE_FREE,
            nGameStyle = GAME_STYLE_FUZHOU,         -- 游戏类型  大众 四川等
            nSubGameStyle = LOCAL_PLAY_ROUND,       -- 游戏子类型（打局、打课玩法）
            -- nScoreToMoney = 100,                    -- 每分对应多少游戏币
            nMinFan = 0,                            --最少多少番和牌
            nBaseBet = 1,                         -- 底分, 各个地区规则计算完底分后，再计算这里的
            -- nEscapeScore = 100,                     -- 逃跑扣分
            -- nEscapeMoney = 1000,                    -- 逃跑扣游戏币
            -- nShareRate = 0,                         -- 抽水多少，0 表示不抽
            bJiaJiaYou = false,                     -- 家家有
            bZiMoJiaDi = false,
            -- nMaxMoney = -1,
            -- nHuaZhuFan = 16,
            -- nNoCardWinCount = 1,
            -- nNoCardGangCount = 0,
            stringEncoding = "flow_config.string_encoding_cn_fuzhou"
        },
        TimerSetting = {
            readyTimeOut = 100,          -- 准备：-1为不超时一直等
            giveTimeOut = 15,           -- 出牌：出牌超时时间(秒)
            blockTimeOut = 10,          -- block：处理挡牌时间
            robGoldTimeOut = 10,        -- 抢金：-1为不超时一直等

            autoPlayTimeOut = 2,        -- 自动托管时超时时间
            timeOutLimit = -1,          -- 房卡场除ready外不设置超时
        },
        GameSetting = {
            --这2字段必须加上
            bSupportPlayLaizi = true,      --是否支持打癞子牌
            bSupportPlayCollect = false,    --是否支持打吃过的牌


            -- 是否可以吃
            bSupportCollect = true,
            -- 是否可以碰
            bSupportTriplet = true,
            -- 是否可以杠
            bSupportQuadruplet = true,
            -- 是否可以暗杠
            bSupportHiddenQuadruplet = true,
            -- 是否支持碰上杠 摸牌杠
            bSupportTriplet2Quadruplet = true,
            -- 是否支持听(目前听暂时不需要)
            bSupportTing = true,
            -- 听状态下是否可以打其他牌
            bTingCanPlayOther = true,
            -- 支持放炮胡
            bSupportGunWin = true,
            --是否是连庄(福建麻将都支持连庄)
            bCounterLian = true,


            --============福州开房选择============--
            --半清一色(默认)
            bSupportHalfColor = true,
            --全清一色(默认)
            bSupportOneColor = true,
            --金龙(默认)--不算特殊分只算普通分
            bSupportGoldDragon = true,
            --单钓剩金不平胡---闲金只能自摸
            bSupportSingleGold = false,
            --放炮三家赔(默认)
            bSupportGunAll = true,
            --放炮单家赔
            bSupportGunOne = false,
            --====================================--
            --============泉州开房选择============--
            --打局(默认)
            bSupportJu = true,
            --打课(默认)
            bSupportKe = false,

            --单金不能平胡（默认）
            bNoSupportPingHuByOneGold = true,
            
            --双金以上要游金（默认）
            bMustYouJinByTwoGold = true,
            --====================================--
        },
        FlowSetting = {
            strDealer = "core.dealer",
            strFlowDealer = "../script_mj_fuzhou/flow_config/flow_dealer_fuzhou.json",
            strFlowPlayer = "../script_mj_fuzhou/flow_config/flow_player_fuzhou.json",
            strFlowPlayerExt = "../script_mj_fuzhou/flow_config/flow_player_ext_fuzhou.json",
        },
        -- slot
        GameSlotSetting = {
            --牌库
            strCardPool = "slot.card_pool.slot_card_pool_default",
            --洗牌
            strCardDeal = "slot.card_deal.slot_card_deal_default",
            -- strCardDeal = "slot.card_deal.slot_card_deal_gm_test",
            -- strCardDeal = "slot.card_deal.slot_card_deal_gm_gameend_fuzhou",
            
            --出牌顺序，逆时针出牌
            strTurnOrder = "slot.turn_order.slot_turn_order_anticlockwise",

            --骰子定庄(算法需修改)
            strGetBanker = "slot.get_banker.slot_get_banker_dice",
            -- strGetBanker = "slot.get_banker.slot_get_banker_random",
            -- strGetBanker = "slot.get_banker.slot_get_banker_gm_chair1",

            --花牌检测(不同地方 花牌定义范围有所不同  算法需修改)
            strCheckFlower = "slot.flower_check.flower_check_common",

            -- 规则slot 吃
            strRuleCollect = "slot.rule_collect.rule_collect_common",
            -- 规则slot 碰
            strRuleTriplet = "slot.rule_triplet.rule_triplet_common",
            -- 规则slot 杠
            strRuleQuadruplet = "slot.rule_quadruplet.rule_quadruplet_common",
            -- 规则slot 胡
            strRuleWin = "slot.rule_win.rule_win_common",
            -- 规则slot 听(暂时不用)
            strRuleTing = "slot.rule_ting.rule_ting_common",

            -- 托管 自动出牌(暂时不用)
            strTrustAuto = "slot.trust_auto.trust_auto_base",
            -- 判断是否游戏结束
            strGameEnd = "slot.rule_gameend.rule_gameend_common",

            -- 胡牌算法(调用C++算法)
            strFanCounter = "slot.fan_counter.slot_fan_chengdu",
        }
}


-- return readonly(GameCfg)
return GameCfg
