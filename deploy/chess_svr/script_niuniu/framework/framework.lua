local FlowEventMng = import("framework.flow_event_mng")
local TimerMng = import("framework.timer_mng")
local stFlowEventMng = nil
local stTimerMng = nil
local stGameCfg = {}
FlowFramework = FlowFramework or {}

function FlowFramework.Init(str_gsc, _gid, cfgjson, gamejson)
    FlowFramework.LoadGameCfg(str_gsc, _gid, cfgjson, gamejson)
    stFlowEventMng = FlowEventMng.new() 
    stTimerMng = TimerMng.new()
    return 0
end

function FlowFramework.ModifyGameConfig(GameCfg, cfg)
    --[[--暂时先这样，具体字段与客户端的为准
    "nGhostAdd" : 0,     --加鬼牌(0不加，1加)
    "nColorAdd" : 0,     --加色(0不加，1加一色，2加二色)
    "pnum" : 4,    --人数
    "rounds" : 8,        --局数
    "nBuyCode": 0,       --买码(0不买，1买)
    "nWaterBanker": 0    --水庄：0不是 1是
    "nMaxMult": 1         --水庄，闲家最大倍数
    --]]
    GameCfg.GameSetting.nSupportAddColor = cfg.nColorAdd
    GameCfg.GameSetting.bSupportGhostCard = (cfg.nGhostAdd == 1)
    GameCfg.GameSetting.bSupportWaterBanker = (cfg.nWaterBanker == 1)
    GameCfg.GameSetting.bSupportBuyCode = (cfg.nBuyCode == 1)
    GameCfg.GameSetting.nSupportMaxMult = cfg.nMaxMult

    --TODO：注意先屏蔽鬼牌，鬼牌算法好了再加上
    -- GameCfg.GameSetting.bSupportGhostCard = false

    if cfg.pnum > 1 and cfg.pnum < 7 then
        GameCfg.nPlayerNum = cfg.pnum
    end
    GameCfg.nJuNum = cfg.rounds
    --根据人数来做判断是否加色  防止客户端传输数据出错
    if GameCfg.nPlayerNum == 5 then
        --5人至少加一色
        if GameCfg.GameSetting.nSupportAddColor == 0 then
            GameCfg.GameSetting.nSupportAddColor = 1
        end
    end
    if GameCfg.nPlayerNum == 6 then
        --6人必须加2色
        GameCfg.GameSetting.nSupportAddColor = 2
    end
    --水庄至少加一色
    if GameCfg.GameSetting.bSupportWaterBanker then
        if GameCfg.GameSetting.nSupportAddColor < 1 then
            GameCfg.GameSetting.nSupportAddColor = 1
        end
    end

    -- GameCfg.rid = cfg.rid
    -- GameCfg.uri = cfg.uri
    -- GameCfg.rno = cfg.rno
    -- GameCfg.gid = cfg.gid
    -- GameCfg.uid = tonumber(cfg.uid)

    return GameCfg
end

function FlowFramework.LoadGameCfg(str_gsc, _gid, cfgjson, gamejson)
    stGameCfg = import(str_gsc)
    stGameCfg._gid = _gid
    stGameCfg.rid = cfgjson.rid
    stGameCfg.uri = cfgjson.uri
    stGameCfg.rno = cfgjson.rno

    LOG_DEBUG("FlowFramework.LoadGameCfg cfgjson: %s \n", vardump(cfgjson));
    
    if cfgjson ~= nil and cfgjson.cfg ~= nil then
        stGameCfg.uid = tonumber(cfgjson.uid) -- 房主
        stGameCfg = FlowFramework.ModifyGameConfig(stGameCfg, cfgjson.cfg)
        LOG_DEBUG("loaded");
    end
    PLAYER_NUMBER = stGameCfg.nPlayerNum
    LOG_DEBUG("FlowFramework.LoadGameCfg...PLAYER_NUMBER:%d", PLAYER_NUMBER)

    --游戏game_config_11.json配置
    gamejson = gamejson or {}
    stGameCfg.nMoneyMode = gamejson.nMoneyMode or stGameCfg.nMoneyMode
    stGameCfg.RoomSetting.nGameStyle = gamejson.RoomSetting_nGameStyle or stGameCfg.RoomSetting.nGameStyle
    stGameCfg.RoomSetting.nChargeMode = gamejson.RoomSetting_nChargeMode or stGameCfg.RoomSetting.nChargeMode
    stGameCfg.RoomSetting.nMaxWaterScore = gamejson.RoomSetting_nMaxWaterScore or stGameCfg.RoomSetting.nMaxWaterScore
    --服务端控制是否下发推荐牌型:0不下发 1下发
    stGameCfg.nNeedRecommend = gamejson.nNeedRecommend or 0

    LOG_DEBUG("cfg: %s", vardump(stGameCfg));
end
function FlowFramework.GetGameCfg()
    return stGameCfg
end


function FlowFramework.FlowEventTrigger(stFlowObj, stEvent)
    stFlowEventMng:AddEvent(stFlowObj, stEvent)
end

function FlowFramework.Dispath()
    stFlowEventMng:Dispath()

end
function FlowFramework.OnTimer()
    stTimerMng:OnTimer()
end
function FlowFramework.SetTimer(nChair, nInterval, nTimerID, nTimers)
    if nInterval < 0 then
        return
    end
    --LOG_ERROR("SetTimer nChair : %d", nChair)
    nTimerID = nTimerID or 0
    nTimers = nTimers or 1
    -- --先删除
    -- stTimerMng:DelTimer(nChair, nTimerID)
    --再添加
    stTimerMng:RegistTimerEvent(nChair, nTimerID, nInterval * 1000, nTimers)
end


function FlowFramework.SetTimer_mi(nChair, nInterval, nTimerID, nTimers)
    if nInterval < 0 then
        return
    end
    --LOG_ERROR("SetTimer nChair : %d", nChair)
    nTimerID = nTimerID or 0
    nTimers = nTimers or 1
    -- --先删除
    -- stTimerMng:DelTimer(nChair, nTimerID)
    --再添加
    stTimerMng:RegistTimerEvent(nChair, nTimerID, nInterval, nTimers)
end


function FlowFramework.DelTimer(nChair, nTimerID)
    --LOG_ERROR("DelTimer nChair : %d", nChair)
    stTimerMng:DelTimer(nChair, nTimerID)
    -- stFlowEventMng:ClearEvent(nChair, nTimerID)
end

function FlowFramework.GetTimerLeftSecond(nChairID , nTimerID)
    nTimerID = nTimerID or 0
    return stTimerMng:GetTimerLeftSecond(nChairID , nTimerID)
end

function FlowFramework.CheckHaveTimer(nChairID , nTimerID)
    nTimerID = nTimerID or 0
    return stTimerMng:CheckHaveTimer(nChairID , nTimerID)
end