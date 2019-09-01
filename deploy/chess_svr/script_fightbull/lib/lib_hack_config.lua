local LibLoadConfig = LibLoadConfig or {}

function LibLoadConfig.ModifyGameConfig(cfg)
    if cfg.pnum > 1 and cfg.pnum < 7 then
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

    --游戏game_config_11.json配置
    gamejson = gamejson or {}
    GGameCfg.nMoneyMode = gamejson.nMoneyMode or GGameCfg.nMoneyMode
    GGameCfg.RoomSetting.nGameStyle = gamejson.RoomSetting_nGameStyle or GGameCfg.RoomSetting.nGameStyle
    GGameCfg.RoomSetting.nChargeMode = gamejson.RoomSetting_nChargeMode or GGameCfg.RoomSetting.nChargeMode

    LOG_DEBUG("LibLoadConfig.HackGameCfg...GGameCfg: %s", vardump(GGameCfg))
end

return LibLoadConfig