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
    LibGame = import("lib.lib_game").new()
    LibNormalCardLogic = import("lib.lib_normal_card_logic").new()
    return 0
end

function LoaderLib.CreateInitAll()
    local stGameSlotCfg = GGameCfg.GameSlotSetting
    local bRetCode = false
    bRetCode =  CSMessage.CreateInit()
                        and SSMessage.CreateInit()
                        and LibCardDeal:CreateInit()
                        and LibCardPool:CreateInit()
                        and LibGame:CreateInit()
                        and LibNormalCardLogic:CreateInit()
    if bRetCode == true then
        return 0
    end
    return -1
end
function LoaderLib.StartGameInitAll()
    LibCardDeal:OnGameStart()
    LibGame:OnGameStart()
    LibNormalCardLogic:OnGameStart()
    return 0
end