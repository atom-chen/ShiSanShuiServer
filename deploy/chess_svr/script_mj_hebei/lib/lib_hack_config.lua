
local LibLoadConfig = LibLoadConfig or {}

-- 需要装载的so
require "mjfancounter1001"

function LibLoadConfig.ModifyGameConfig(cfg)
    GGameCfg.GameSetting.bSupportDealerAdd = (cfg.dealeradd == 1)
    GGameCfg.GameSetting.bSupportGangPao = (cfg.gangrun == 1)
    GGameCfg.GameSetting.bSupportGangFlowAdd = (cfg.gfadd == 1)
    GGameCfg.GameSetting.bSupportHun = (cfg.hun == 1)
    GGameCfg.GameSetting.bSupportGunWin = (cfg.hutype == 1)
    GGameCfg.GameSetting.bSupportXiaPao = (cfg.lowrun == 1)
    -- 河北麻将选择项
    GGameCfg.GameSetting.bSupportQiangGangHu = (cfg.qghu == 1)
    GGameCfg.GameSetting.bSupportMenWQing = (cfg.menqing == 1)
    GGameCfg.GameSetting.bSupportBKD = (cfg.bkd == 1)
    GGameCfg.GameSetting.bSupportZhuoWuKui = (cfg.wukui == 1)

    GGameCfg.GameSetting.bSupportSevenDoubleAdd = (cfg.spadd == 1)
    GGameCfg.GameSetting.bSupportWind = (cfg.wind == 1)
    if not GGameCfg.GameSetting.bSupportWind then
        GGameCfg.CardPoolType = {"char", "bamboo", "ball"}
    end

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

    LOG_DEBUG("LibLoadConfig.HackGameCfg...GGameCfg: %s", vardump(GGameCfg))
end

return LibLoadConfig