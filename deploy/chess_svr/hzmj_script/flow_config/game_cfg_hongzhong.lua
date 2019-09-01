--[[
-- 游戏相关的的配置
--]]
import("core.core_define")
local GameCfg =  {
       nLeftCardNeedQuict = 14,         --剩余多少张牌算荒局
       nMoneyMode = MONEY_MODE_MONEY, --默认是金币声，传配置则是房卡场
       nPlayerNum = 4,
       nJuNum     = 2,      -- 一圈多少局（房卡模式）
       nCurrJu    = 1,      -- 当前是第几局
       rno        = 0,      -- 房号
       CardPoolType =  {"char", "bamboo", "ball"} ,--  "wind", "fabai", "flower"},
       RoomSetting = {
            nChargeMode = CHARGE_MODE_FREE,
            nGameStyle = GAME_STYLE_CHENGDU,           -- 游戏类型  大众 四川等
            nSubGameStyle = LOCAL_CHENGDU_XUEZHAN,        -- /游戏子类型（如成都麻将有血战非血战之分）
            nMinFan = 0,          --最少多少番和牌
            nScoreToMoney = 100,         --每分对应多少游戏币
            nBaseBet = 1,                      -- 底分, 各个地区规则计算完底分后，再计算这里的
            nEscapeScore = 100,               -- 逃跑扣分
            nEscapeMoney = 1000,            --             逃跑扣游戏币
            nShareRate = 0,                        -- 抽水多少，0 表示不抽
            bJiaJiaYou = false,                  -- 家家有
            bZiMoJiaDi = false,
            nMaxMoney = -1,
            nHuaZhuFan = 4,
            nNoCardWinCount = 1,
            nNoCardGangCount = 0,
            stringEncoding = "flow_config.string_encoding_cn"
        },
        TimerSetting = {
            -- readyTimeOut = 20,       -- 房卡模式等待举手超时
            readyTimeOut = 10,          -- -1为不超时一直等
            giveTimeOut = 15, --30,  -- 出牌超时时间(秒)
            blockTimeOut = 10, --10,   -- 处理挡牌时间
            changeCardTimeOut = 15,--15, -- 换张超时时间
            confirmMissTimeOut = 15, --10, -- 定缺超时时间
            -- addMoneyTimeout = 10,
            AutoPlayTimeOut = 2,         -- 自动托管时超时时间
            TimeOutLimit = -1,         -- 房卡场除ready外不设置超时
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
            bSupportTing = true,

            -- 听状态下是否可以打其他牌
            bTingCanPlayOther = false,

            bSupportHun = false, --- 混牌

            -- 是否支持放炮胡
            bSupportGunWin = true, -- 胡牌

            -- 多少次超时就设置成自动托管, -1表示永不托管
            nTimeOutCountToAuto = -1,    
            --是否是连庄
            bCounterLian = false,

            --是否支持换3张
            bSupportChangeCard = true,

            --是否支持 呼叫转移
            bSupportGangMove = true,

            --是否支持自摸翻倍
            bSupportSelfDrawDouble = true,

            --是否支持天地胡

            bSupportGodGroundWin = true,

            --是否支持门清中张

             bSupportMenQingZhongZhang = true,
           

            --是否支持幺九将对

            bSupportYaoJiuJiangDui = true,

            --是否支持杠上花（点炮）

            bSupportGangDrawGun = false,

            --是否支持杠上花（自摸）

            bSupportGangDrawSelf = false,   

            -- 是否支持扫底胡            
            bSupportSaoDiHu  = true,

            -- 是否支持金钩胡            
            bSupportJinGouHu = true,

            -- 是否支持海底炮
            bSupportHaiDiPao = true,
			
            -- 买马类型
            nBuyCodeType = 1,

            --封顶番数
            nMaxFan =256,

        },
        FlowSetting = {
            strDealer = "core.dealer",
            strFlowDealer = "../hzmj_script/flow_config/flow_dealer.json",
            strFlowPlayer = "../hzmj_script/flow_config/flow_player.json",
            strFlowPlayerExt = "../hzmj_script/flow_config/flow_player_ext.json",
        },
        -- slot
        GameSlotSetting = {
            strCardPool = "slot.card_pool.slot_card_pool_default",
            stCardDeal = {
                strCardDeal = "slot.card_deal.slot_card_deal_default",
                --strCardDeal = "slot.card_deal.slot_card_deal_gm_gameend_chengdu",
                --strCardDeal = "slot.card_deal.slot_card_deal_gm_gameend",
                -- 配牌相关
                nConfigureTiles  = 0,              -- 配牌几率 0-100
                nConfigTilesRan = {},               -- 22种配牌几率
                nConfigTilesRanAdd = 0             --  各种牌几率的和
            },
            strTurnOrder = "slot.turn_order.slot_turn_order_anticlockwise",

            stChangeCard = {
                strChangeCard = "slot.change_card.slot_change_card_random",
                bIsNeedChangeSame = true,
                nChangeCardNum = 3,
            },

            strConfirmMiss = "slot.lack_card.slot_confirm_miss_common",

            --strGetBanker = "slot.get_banker.slot_get_banker_random",
            strGetBanker = "slot.get_banker.slot_get_banker_bysaizi",

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
