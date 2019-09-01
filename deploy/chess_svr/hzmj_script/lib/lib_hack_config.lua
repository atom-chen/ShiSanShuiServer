local LibLoadConfig = LibLoadConfig or {}
require "mjhzyh"

function LibLoadConfig.GetGameStyle(gid)
    -- 游戏类型
    local gid = tonumber(gid)
    local nGameStyle, nMoneyMode = 0, 0
    if gid == GID_GOLD_HONGZHONG then
        nGameStyle = GAME_STYLE_CHENGDU
        nMoneyMode = MONEY_MODE_MONEY
    elseif gid == GID_ROOM_HONGZHONG then
        nGameStyle = GAME_STYLE_CHENGDU
        nMoneyMode = ROOM_MODE_SCORE
    end
    LOG_DEBUG("LibLoadConfig.GetGameStyle...nGameStyle=%d, nMoneyMode=%d, gid=%d", nGameStyle, nMoneyMode, gid)

    return nGameStyle, nMoneyMode
end

function LibLoadConfig.ModifyGameConfig(cfg)
    GGameCfg.GameSetting.bSupportHun = (cfg.hun == 1)
    GGameCfg.GameSetting.bSupportChangeCard = (cfg.changecard == 1)
    GGameCfg.GameSetting.bSupportSelfDrawDouble = (cfg.selfdrawdouble == 1)
    --自摸加倍==自摸加底
    GGameCfg.RoomSetting.bZiMoJiaDi = GGameCfg.GameSetting.bSupportSelfDrawDouble
    GGameCfg.GameSetting.bSupportGodGroundWin = (cfg.godgroundhu == 1)
    GGameCfg.GameSetting.bSupportMenQingZhongZhang = (cfg.menzhong == 1)
    GGameCfg.GameSetting.bSupportYaoJiuJiangDui = (cfg.yaodui == 1)
    GGameCfg.GameSetting.bSupportGangDrawGun = (cfg.gangdrawself == 0)
    GGameCfg.GameSetting.bSupportGangDrawSelf = (cfg.gangdrawself == 1)
    GGameCfg.GameSetting.nMaxFan = cfg.maxfan
    GGameCfg.GameSetting.nBuyCodeType = cfg.buycodetype
    --红中麻将暂不支持混牌
    GGameCfg.GameSetting.bSupportHun = false
    --红中麻将暂时不支持风牌
    GGameCfg.GameSetting.bSupportWind = false
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