
local LibLoadConfig = LibLoadConfig or {}

-- 需要装载的so
require "mjfz"

function LibLoadConfig.ModifyGameConfig(cfg)
    GGameCfg.GameSetting.bSupportHalfColor = (cfg.nHalfColor == 1)
    GGameCfg.GameSetting.bSupportOneColor = (cfg.nOneColor == 1)
    GGameCfg.GameSetting.bSupportGoldDragon = (cfg.nGoldDragon == 1)
    GGameCfg.GameSetting.bSupportSingleGold = (cfg.nSingleGold == 1)

    --福州泉州通用
    GGameCfg.GameSetting.bSupportGunAll = (cfg.nGunAll == 1)
    GGameCfg.GameSetting.bSupportGunOne = (cfg.nGunOne == 1)

    --泉州开房规则
    --打局、打课、单金不能平胡（默认）、双金以上要游金（默认）
    GGameCfg.GameSetting.bSupportJu = (cfg.bsupportju == 1)
    GGameCfg.GameSetting.bSupportKe = (cfg.bsupportke == 1)
    GGameCfg.GameSetting.bNoSupportPingHuByOneGold = (cfg.nonegold == 1)
    GGameCfg.GameSetting.bMustYouJinByTwoGold = (cfg.ntwogold == 1)

    if cfg.pnum > 1 and cfg.pnum < 4 then
        GGameCfg.nPlayerNum = cfg.pnum
    end
    GGameCfg.nJuNum = cfg.rounds
end

function LibLoadConfig.HackGameCfg(str_gsc, _gid, cfgjson, gamejson)
    --房卡配置
    cfgjson = cfgjson or {}
    if cfgjson ~= nil and cfgjson.cfg ~= nil then
        LibLoadConfig.ModifyGameConfig(cfgjson.cfg)
        LOG_DEBUG("loaded")
    end
    PLAYER_NUMBER = GGameCfg.nPlayerNum

    --
    GGameCfg._gid = _gid
    GGameCfg.rid = cfgjson.rid
    GGameCfg.uri = cfgjson.uri
    GGameCfg.rno = cfgjson.rno
    --房主uid
    cfgjson.uid = cfgjson.uid or 0
    GGameCfg.uid = tonumber(cfgjson.uid)

    --游戏game_config_xx.json配置
    gamejson = gamejson or {}
    GGameCfg.nMoneyMode = gamejson.nMoneyMode or GGameCfg.nMoneyMode
    GGameCfg.RoomSetting.nGameStyle = gamejson.RoomSetting_nGameStyle or GGameCfg.RoomSetting.nGameStyle
    GGameCfg.RoomSetting.nChargeMode = gamejson.RoomSetting_nChargeMode or GGameCfg.RoomSetting.nChargeMode
    --服务端控制是否下发听牌消息:0不下发 1下发
    GGameCfg.nNeedTingInfo = gamejson.nNeedTingInfo or 0

    LOG_DEBUG("LibLoadConfig.HackGameCfg...GGameCfg: %s", vardump(GGameCfg))
end

return LibLoadConfig