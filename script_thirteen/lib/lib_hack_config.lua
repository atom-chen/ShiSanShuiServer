local LibLoadConfig = LibLoadConfig or {}

function LibLoadConfig.ModifyGameConfig(cfg)
    --[[--暂时先这样，具体字段与客户端的为准
    "nGhostAdd" : 0,     --加鬼牌(0不加，1加)
    "nColorAdd" : 0,     --加色(0不加，1加一色，2加二色)
    "pnum" : 4,    --人数
    "rounds" : 8,        --局数
    "nBuyCode": 0,       --买码(0不买，1买)
    "nWaterBanker": 0    --水庄：0不是 1是
    "nMaxMult": 1         --水庄，闲家最大倍数
    --]]
    GGameCfg.GameSetting.nSupportAddColor = cfg.nColorAdd
    GGameCfg.GameSetting.bSupportGhostCard = (cfg.nGhostAdd == 1)
    GGameCfg.GameSetting.bSupportWaterBanker = (cfg.nWaterBanker == 1)
    GGameCfg.GameSetting.bSupportBuyCode = (cfg.nBuyCode > 1)
    GGameCfg.GameSetting.nBuyCodeCard = cfg.nBuyCode
    GGameCfg.GameSetting.nSupportMaxMult = cfg.nMaxMult

    if cfg.nChooseCardTypeTimeOut > 0 and cfg.nChooseCardTypeTimeOut < 300 then
	GGameCfg.TimerSetting.chooseCardTypeTimeOut = cfg.nChooseCardTypeTimeOut
    end

    if cfg.nReadyTimeOut > 0 and cfg.nReadyTimeOut < 300 then
        GGameCfg.TimerSetting.readyTimeOut = cfg.nReadyTimeOut
    end

    if cfg.pnum > 1 and cfg.pnum < 7 then
        GGameCfg.nPlayerNum = cfg.pnum
    end
    GGameCfg.nJuNum = cfg.rounds

    --根据人数来做判断是否加色  防止客户端传输数据出错
    if GGameCfg.nPlayerNum == 5 then
        --5人至少加一色
        if GGameCfg.GameSetting.nSupportAddColor == 0 then
            GGameCfg.GameSetting.nSupportAddColor = 1
        end
    end
    if GGameCfg.nPlayerNum == 6 then
        --6人必须加2色
        GGameCfg.GameSetting.nSupportAddColor = 2
    end
    --水庄至少加一色
    if GGameCfg.GameSetting.bSupportWaterBanker then
        if GGameCfg.GameSetting.nSupportAddColor < 1 then
            GGameCfg.GameSetting.nSupportAddColor = 1
        end
    end
end

function LibLoadConfig.HackGameCfg(str_gsc, _gid, cfgjson, gamejson)
    
    --房卡配置
    cfgjson = cfgjson or {}
    if cfgjson ~= nil and cfgjson.cfg ~= nil then
        LibLoadConfig.ModifyGameConfig(cfgjson.cfg)
        LOG_DEBUG("loaded")
    end

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
    GGameCfg.RoomSetting.nMaxWaterScore = gamejson.RoomSetting_nMaxWaterScore or GGameCfg.RoomSetting.nMaxWaterScore
    --服务端控制是否下发推荐牌型:0不下发 1下发
    GGameCfg.nNeedRecommend = gamejson.nNeedRecommend or 0
    --清桌时间
    GGameCfg.nClearTableReadyTimeOut = GGameCfg.TimerSetting.readyTimeOut or 0

    LOG_DEBUG("LibLoadConfig.HackGameCfg...GGameCfg: %s", vardump(GGameCfg))
end

return LibLoadConfig
