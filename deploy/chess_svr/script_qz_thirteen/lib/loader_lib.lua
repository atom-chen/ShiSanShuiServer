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

    LibCardDeal = import("lib.lib_card_deal").new()
    LibCardPool = import("lib.lib_card_pool").new()
    LibNormalCardLogic = import("lib.lib_normal_card_logic").new()
    LibSpCardLogic = import("lib.lib_sp_card_logic").new()
    LibGame = import("lib.lib_game").new()
    LibMult = import("lib.lib_mult").new()
    LibLaiZi = import("lib.lib_laizi").new()
    libRecomand = import("lib.lib_recomand").new()
    return 0
end

function LoaderLib.CreateInitAll()
    local stGameSlotCfg = GGameCfg.GameSlotSetting
    local bRetCode = false
    bRetCode =  CSMessage.CreateInit()
                        and SSMessage.CreateInit()
                        and LibCardDeal:CreateInit()
                        and LibCardPool:CreateInit()
                        and LibNormalCardLogic:CreateInit()
                        and LibSpCardLogic:CreateInit()
                        and LibGame:CreateInit()
                        and LibMult:CreateInit()
                        and LibLaiZi:CreateInit()
                        and libRecomand:CreateInit()
    if bRetCode == true then
        return 0
    end
    return -1
end
function LoaderLib.StartGameInitAll()
    LibCardDeal:OnGameStart()
    LibNormalCardLogic:OnGameStart()
    LibSpCardLogic:OnGameStart()
    LibGame:OnGameStart()
    LibMult:OnGameStart()
    LibLaiZi:OnGameStart()
    libRecomand:OnGameStart()

    return 0;
end