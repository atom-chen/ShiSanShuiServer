LoaderLib = LoaderLib or {}
-- 加载所有lib
-- lib 实现具体的 槽逻辑和 游戏相关的逻辑
-- lib 相当于一个全局的对象， 持有状态数据  重新开始游戏 时 需要根据需要进行初始化
function LoaderLib.LoadAll()
    LOG_DEBUG("LoaderLib.LoadAll()")
    -- 改了GGameCfg
    local LibHackConfig = import("lib.lib_hack_config")
    LibHackConfig.HackGameCfg(G_TABLEINFO._gsc, G_TABLEINFO._gid, GExtCfg, GAppCfg.GameCfg)
    
    CSMessage = import("lib.cs_message")
    SSMessage = import("lib.ss_message")
    LibGetBanker = import("lib.lib_get_banker").new()
    LibCardDeal = import("lib.lib_card_deal").new()
    LibCardPool = import("lib.lib_card_pool").new()
    LibFlowerCheck = import("lib.lib_flower_check").new()
    LibGoldCard = import("lib.lib_gold_card").new()
    LibGameEndJudge = import("lib.lib_game_end_judge").new()
    LibAutoPlay = import("lib.lib_autoplay").new()
    LibRuleCollect = import("lib.lib_rule_collect").new()
    LibRuleTriplet = import("lib.lib_rule_triplet").new()
    LibRuleQuadruplet = import("lib.lib_rule_quadruplet").new()
    LibRuleTing = import("lib.lib_rule_ting").new()
    LibRuleWin = import("lib.lib_rule_win").new()
    LibTrustAuto = import("lib.lib_trust_auto").new()
    LibTurnOrder = import("lib.lib_turn_order").new()
    LibGameLogic = import("lib.game_lib").new()
    LibFanCounter = import("lib.lib_fan_counter").new()
    LibGameLogicFuzhou =  import("lib.lib_game_logic_fuzhou").new()
    return 0
end

function LoaderLib.CreateInitAll()
    local stGameSlotCfg = GGameCfg.GameSlotSetting
    local bRetCode = false
    bRetCode =  CSMessage.CreateInit()
                        and SSMessage.CreateInit()
                        and LibCardPool:CreateInit(stGameSlotCfg.strCardPool)
                        and LibGetBanker:CreateInit(stGameSlotCfg.strGetBanker)
                        and LibCardDeal:CreateInit(stGameSlotCfg.strCardDeal)
                        and LibFlowerCheck:CreateInit(stGameSlotCfg.strCheckFlower)
                        and LibGoldCard:CreateInit()
                        and LibGameEndJudge:CreateInit(stGameSlotCfg.strGameEnd)
                        and LibRuleCollect:CreateInit(stGameSlotCfg.strRuleCollect)
                        and LibRuleTriplet:CreateInit(stGameSlotCfg.strRuleTriplet)
                        and LibRuleQuadruplet:CreateInit(stGameSlotCfg.strRuleQuadruplet)
                        and LibRuleTing:CreateInit(stGameSlotCfg.strRuleTing)
                        and LibRuleWin:CreateInit(stGameSlotCfg.strRuleWin)
                        and LibTrustAuto:CreateInit(stGameSlotCfg.strTrustAuto)
                        and LibTurnOrder:CreateInit(stGameSlotCfg.strTurnOrder)
                        and LibGameLogic:CreateInit()
                        and LibFanCounter:CreateInit(stGameSlotCfg.strFanCounter)
                        and LibGameLogicFuzhou:CreateInit()
    if bRetCode == true then
        return 0
    end
    return -1
end
function LoaderLib.StartGameInitAll()
    LibGetBanker:OnGameStart()
    LibCardDeal:OnGameStart()
    LibCardPool:OnGameStart()
    LibFlowerCheck:OnGameStart()
    LibGoldCard:OnGameStart()
    LibAutoPlay:OnGameStart()
    LibGameEndJudge:OnGameStart()
    LibRuleCollect:OnGameStart()
    LibRuleTriplet:OnGameStart()
    LibRuleQuadruplet:OnGameStart()
    LibRuleTing:OnGameStart()
    LibRuleWin:OnGameStart()
    LibTrustAuto:OnGameStart()
    LibTurnOrder:OnGameStart()
    LibGameLogic:OnGameStart()
    LibFanCounter:OnGameStart()
    LibGameLogicFuzhou:OnGameStart()
    return 0;
end