--[[
-- 游戏相关的的配置
--]]
import("core.core_define")
local GameCfg =  {
        nLeftCardNeedQuict = 14,         -- 剩余多少张牌算荒局
        nMoneyMode = MONEY_MODE_MONEY,   -- 默认是金币声，传配置则是房卡场
        nPlayerNum = 4,
        nJuNum     = 2,      -- 一圈多少局（房卡模式）
        nCurrJu    = 1,      -- 当前是第几局
        rno        = 0,      -- 房号
        CardPoolType = {"char", "bamboo", "ball", "wind", "fabai"} ,  -- "wind", "fabai", "flower"},
        RoomSetting = {
            nChargeMode = CHARGE_MODE_FREE,
            nGameStyle = GAME_STYLE_ZHENGZHOU,           -- 游戏类型  大众 四川等
            nSubGameStyle = LOCAL_CHENGDU_XUELIU,        -- 游戏子类型（如成都麻将有血战非血战之分）
            nMinFan = 1,               -- 最少多少番和牌
            nScoreToMoney = 100,       -- 每分对应多少游戏币
            nBaseBet = 1,              -- 底分, 各个地区规则计算完底分后，再计算这里的
            nEscapeScore = 100,        -- 逃跑扣分
            nEscapeMoney = 1000,       -- 逃跑扣游戏币
            nShareRate = 0,            -- 抽水多少，0 表示不抽
            bJiaJiaYou = false,        -- 家家有
            bZiMoJiaDi = false,
            nMaxMoney = -1,
            nHuaZhuFan = 16,
            nNoCardWinCount = 1,
            nNoCardGangCount = 0,
            stringEncoding = "flow_config.string_encoding_cn"
        },
        TimerSetting = {
            -- readyTimeOut = 20,       -- 房卡模式等待举手超时
            readyTimeOut = 10,          -- -1为不超时一直等
            giveTimeOut = 15, --30,     -- 出牌超时时间(秒)
            blockTimeOut = 10, --10,    -- 处理挡牌时间
            -- changeCardTimeOut = 15,  -- 换张超时时间
            -- confirmMissTimeOut = 15, -- 定缺超时时间
            -- addMoneyTimeout = 10,
			XiaPaoTimeOut = 10,         -- 下跑超时时间
            AutoPlayTimeOut = 2,        -- 自动托管时超时时间
            TimeOutLimit = -1,          -- 房卡场除ready外不设置超时
        },
        GameSetting = {
            --这2字段必须加上
            bSupportPlayLaizi = false,      --是否支持打癞子牌
            bSupportPlayCollect = false,    --是否支持打吃过的牌

            -- 是否可以吃
            bSupportCollect = false,
            -- 是否可以碰
            bSupportTriplet = true,
            -- 是否可以杠
            bSupportQuadruplet = true,
            -- 是否可以暗杠
            bSupportHiddenQuadruplet = true,
            -- 是否支持碰上杠 摸牌杠
            bSupportTriplet2Quadruplet = true,
            -- 是否支持听
            bSupportTing = false,
            -- 听状态下是否可以打其他牌
            bTingCanPlayOther = true,

            bSupportDealerAdd = true,      -- 庄家加底
            -- 是否杠跑
            bSupportGangPao = true, 

            bSupportGangFlowAdd = true,    -- 杠上花加倍

            bSupportSevenDoubleAdd = true, -- 七对加倍

            bSupportHun = true,     -- 混牌
            
            -- 是否支持放炮胡
            bSupportGunWin = true, -- 胡牌

            bSupportXiaPao = true,  -- 下跑
 
            bSupportWind = true,    -- 是否带 东南西北中发白
            -- 多少次超时就设置成自动托管, -1表示永不托管
            nTimeOutCountToAuto = 2,    
            -- 是否是连庄
            bCounterLian = false,


            --=======下面是杠次选择项=====================================================
            bSupportGangCi = false,     --是否支持杠次,支持的话要为true
            -- --胡牌的方式，软次可自摸胡、也可杠次胡；硬次只能杠次胡；点炮胡则可以点炮胡也可自摸胡更可以杠次胡
            -- bOnlyGangCiHu = false,  --是否只有杠次胡 这个是检查胡牌的一个前提，用来过滤掉自摸胡及放炮胡
            -- bSupportPiCi = false,   --是否支持皮次
            -- bSupportBaoCi = false,  --是否支持包次
            -- bSupportBankerDoubleAdd = false,    --是否支持庄家加倍
            --============================================================================

            --河北麻将选择项
            bSupportQiangGangHu = true,      -- 抢杠胡
            bSupportMenWQing = true,         -- 门清
            bSupportBKD = true,              -- 边卡吊
            bSupportZhuoWuKui = true,        -- 捉五魁(五筒五万五条)
        },
        FlowSetting = {
            strDealer = "core.dealer",
            strFlowDealer = "../script_mj_hebei/flow_config/flow_dealer.json",
            strFlowPlayer = "../script_mj_hebei/flow_config/flow_player.json",
            strFlowPlayerExt = "../script_mj_hebei/flow_config/flow_player_ext.json",
        },
        -- slot
        GameSlotSetting = {
            strCardPool = "slot.card_pool.slot_card_pool_default",
            stCardDeal = {
                strCardDeal = "slot.card_deal.slot_card_deal_default",
                -- strCardDeal = "slot.card_deal.slot_card_deal_gm_test",
                --strCardDeal = "slot.card_deal.slot_card_deal_gm_gameend_zhengzhou",
                -- 配牌相关
                nConfigureTiles  = 0,              -- 配牌几率 0-100
                nConfigTilesRan = {},              -- 22种配牌几率
                nConfigTilesRanAdd = 0             -- 各种牌几率的和
            },
            strTurnOrder = "slot.turn_order.slot_turn_order_anticlockwise",

            stChangeCard = {
                strChangeCard = "slot.change_card.slot_change_card_random",
                bIsNeedChangeSame = true,
                nChangeCardNum = 3,
            },

            strConfirmMiss = "slot.lack_card.slot_confirm_miss_common",
            -- 规则slot 随机庄家
            -- strGetBanker = "slot.get_banker.slot_get_banker_random",
            -- 规则slot 第一个进房玩家为庄家
            strGetBanker = "slot.get_banker.slot_get_banker_gm_chair1",

            strGameEnd = "slot.rule_gameend.rule_gameend_common",
            strCheckFlower = "slot.flower_check.flower_check_common",
            -- 规则slot 吃
            strRuleCollect = "slot.rule_collect.rule_collect_common",
            -- 规则slot 碰
            strRuleTriplet = "slot.rule_triplet.rule_triplet_common",
            -- 规则slot 杠
            strRuleQuadruplet = "slot.rule_quadruplet.rule_quadruplet_common",

            strRuleTing = "slot.rule_ting.rule_ting_common",
            -- 规则slot 胡
            strRuleWin = "slot.rule_win.rule_win_common",

            strTrustAuto = "slot.trust_auto.trust_auto_base",

            stWin = {
                strNodeWinNormal = "slot.win_node.win_node_normal",
                -- 是否可以7对胡
                bSupportWinSevenDouble = true,
                strNodeWinSevenDouble = "slot.win_node.win_node_seven_double",
                -- 是否可以13幺
                bSupportWinCard13Yao = false,
                strNodeWinCard13Yao = "slot.win_node.win_node_yao",
                -- 是否可以全不靠胡
                bSupportChaos = false,
                strNodeWinChaos = "slot.win_node.win_node_chaos",
                -- 是否可以 组合龙
                bSupportAssemble = false,
                strNodeWinAssemble = "slot.win_node.win_node_assemble",
                strFanCounter = "slot.fan_counter.slot_fan_chengdu",
            }
        }
}


-- return readonly(GameCfg)
return GameCfg
