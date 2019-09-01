local LibLoadConfig = LibLoadConfig or {}
require "mjhzyh"

function LibLoadConfig.GetGameStyle(_gid)
    -- 游戏类型
    local gid = tonumber(_gid)
    local nGameStyle, nMoneyMode = 0, 0
    if gid == GID_GOLD_ZHENGZHOU then
        nGameStyle = GAME_STYLE_ZHENGZHOU
        nMoneyMode = MONEY_MODE_MONEY
    elseif gid == GID_GOLD_ZHUMADIAN then
        nGameStyle = GAME_STYLE_ZHUMADIAN
        nMoneyMode = MONEY_MODE_MONEY
    elseif gid == GID_GOLD_LUOYANG then
        nGameStyle = GAME_STYLE_LUOYANG
        nMoneyMode = MONEY_MODE_MONEY

    elseif gid == GID_ROOM_ZHENGZHOU then
        nGameStyle = GAME_STYLE_ZHENGZHOU
        nMoneyMode = ROOM_MODE_SCORE
    elseif gid == GID_ROOM_ZHUMADIAN then
        nGameStyle = GAME_STYLE_ZHUMADIAN
        nMoneyMode = ROOM_MODE_SCORE
    elseif gid == GID_ROOM_LUOYANG then
        nGameStyle = GAME_STYLE_LUOYANG
        nMoneyMode = ROOM_MODE_SCORE
    end
    LOG_DEBUG("LibLoadConfig.GetGameStyle...nGameStyle=%d, nMoneyMode=%d, gid=%d", nGameStyle, nMoneyMode, gid)

    --test
    -- nGameStyle = GAME_STYLE_LUOYANG
    -- nMoneyMode = ROOM_MODE_SCORE

    return nGameStyle, nMoneyMode
end


function LibLoadConfig.ModifyGameConfig(cfg)
    GGameCfg.GameSetting.bSupportDealerAdd = (cfg.dealeradd == 1)
    GGameCfg.GameSetting.bSupportGangPao = (cfg.gangrun == 1)
    GGameCfg.GameSetting.bSupportGangFlowAdd = (cfg.gfadd == 1)
    GGameCfg.GameSetting.bSupportHun = (cfg.hun == 1)
    GGameCfg.GameSetting.bSupportGunWin = (cfg.hutype == 1)
    GGameCfg.GameSetting.bSupportXiaPao = (cfg.lowrun == 1)
    GGameCfg.GameSetting.bSupportSevenDoubleAdd = (cfg.spadd == 1)
    GGameCfg.GameSetting.bSupportWind = (cfg.wind == 1)
    if not GGameCfg.GameSetting.bSupportWind then
        GGameCfg.CardPoolType = {"char", "bamboo", "ball"}--,"wind", "fabai"} 
    end

    if cfg.pnum > 0 and cfg.pnum < 10 then
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
    GGameCfg.uid = cfgjson.uid

    --游戏类型
    local nGameStyle, nMoneyMode = LibLoadConfig.GetGameStyle(_gid)
    if nGameStyle > 0 and nMoneyMode > 0 then
        GGameCfg.nMoneyMode = nMoneyMode
        GGameCfg.RoomSetting.nGameStyle = nGameStyle
    end

    LOG_DEBUG("LibLoadConfig.HackGameCfg...GGameCfg: %s", vardump(GGameCfg))
end

return LibLoadConfig