local CURRENT_MODULE_NAME = ...

require "common/extern"
require "common/array"
require "common/debug_e"
require "common/debug"
require "common/readonly"
require "common/bit"
_FlowTreeCtrl = _GameModule._FlowTreeCtrl

import("lib.loader_lib")
import("lib.cs_message")
import("framework.framework")

--dealer chairid及定时器id
DEALER_ID = 10000
DEALER_TIMER_ID_0 = 0

G_TABLEINFO = {}
require "framework/log_adapter"
require "common.socket"

local function InitCreateDeaer(tableptr, strDealer, strFlow)
    local Dealer = import(strDealer, CURRENT_MODULE_NAME)
    GDealer = Dealer.new()
    if GDealer:Init() ~= 0 then
        LOG_ERROR("OnGameInit Init Dealer Error.\n")
    
        --_FlowTreeCtrl.DestoryObject(GDealer)
        GDealer = nil
        return -1
    end
    local stProcess = _FlowTreeCtrl.CreateFlowTree()
    if stProcess:Init(tableptr, strFlow) ~= 0 then
        return -1
    end
    GDealer:AddFlow(stProcess)
    -- 初始化两个全局表
    GGameState = GDealer:GetGameState()
    GRoundInfo = GDealer:GetRoundInfo()
    return 0
end

local function IsAllPlayerFreeFlow()
    for i=1,PLAYER_NUMBER do
        local stPlayer = GGameState:GetPlayerByChair(i)
        local stFlowProcess = stPlayer:GetFlowProcess()
        if stFlowProcess:IsFree()  == false then
            return false
        end
    end
    return true
end

function _ScriptLogic_OnGameInit(tableptr, tableid, _gid, _gsc, level, seat_num, appcfg, extCfg)
    local str_gsc = appcfg.__Base._gsc
    G_TABLEINFO.tableptr = tableptr
    G_TABLEINFO.tableid = tableid
    G_TABLEINFO._gid = _gid
    G_TABLEINFO._gsc = str_gsc
    G_TABLEINFO._seat = seat_num
    LOG_DEBUG("CURRENT_MODULE_NAME: %s\n, G_TABLEINFO: %s\n, CFG: %s\n", vardump(CURRENT_MODULE_NAME), vardump(G_TABLEINFO), vardump(extCfg))

    -- save config
    GExtCfg = extCfg
    GAppCfg = appcfg

    -- 初始化flow 框架
    -- 设置全局配置表， 只需要加载RoomSetting FlowSetting
    local iRetCode = FlowFramework.Init(str_gsc, _gid, extCfg, appcfg.GameCfg)
    if iRetCode ~= 0 then
        LOG_ERROR(" FlowFramework.Init Failed. _gsc:%s", str_gsc)
        return -1
    end
    GGameCfg = FlowFramework.GetGameCfg()
    
    -- 加载lib, 在最开始就会执行GGameCfg修正
    iRetCode = LoaderLib.LoadAll()
    if iRetCode ~= 0 then
        LOG_ERROR("LoaderLib.LoadAll Failed.");
        return -2
    end
    -- LOG_DEBUG("FFFFFFFFFFFFFF2")
    GStringEncoding = import(GGameCfg.RoomSetting.stringEncoding)
    -- 创建 deler
    iRetCode = InitCreateDeaer(tableptr, GGameCfg.FlowSetting.strDealer, GGameCfg.FlowSetting.strFlowDealer)
     if iRetCode ~= 0 then
        LOG_ERROR(" InitCreateDeaer Failed.")
        return -2
    end
    --这个必须设置 否则会变默认值
    PLAYER_NUMBER = GGameCfg.nPlayerNum

    -- LOG_DEBUG("FFFFFFFFFFFFFF3")
    iRetCode = LoaderLib.CreateInitAll()
    if iRetCode ~= 0 then
        LOG_ERROR(" LoaderLib.CreateInitAll Failed.");
        return -2
    end
    -- LOG_DEBUG("FFFFFFFFFFFFFF4")
    --dealer定时器  每秒执行一次
    --FlowFramework.SetTimer(DEALER_ID, 1, 0, -1)

    --随机数种子初始化
    local t1 = math.floor(socket.gettime()*1000)
    LOG_DEBUG("socket.gettime()*1000 = %s", tostring(t1))
    math.randomseed(t1)

    --毫秒级定时器200ms
    -- LOG_DEBUG("DEALER_ID:%s, DEALER_TIMER_ID_0:%s", type(DEALER_ID), type(DEALER_TIMER_ID_0))
    FlowFramework.SetTimer_mi(DEALER_ID, 200, DEALER_TIMER_ID_0, -1)
    -- LOG_DEBUG("FFFFFFFFFFFFFF5")
    return 0
end
function _ScriptLogic_OnGameEvent(_seatid, _playerid, _uin, event)
    --
    LOG_DEBUG("ONEVENT: _chair:%d, pid:%d, uin:%d, event:%s, para=%s", _seatid, _playerid, _uin, event._cmd, vardump(event._para));
    event.eUser={_chair=_seatid,_pid=_playerid,_uid=_uin}
    event._cmd = tostring(event._cmd)
    local stUserObject = GGameState:GetPlayerByChair(_seatid)
    if stUserObject == nil then
        stUserObject = GDealer
    end

    FlowFramework.FlowEventTrigger(stUserObject, event)

    FlowFramework.Dispath()
end

function _ScriptLogic_OnGameTimer()
    FlowFramework.OnTimer()
end

--[[
-- flow 调 step 入口
function _ScriptLogic_OnFlowEvent(tGameUser, strStepName, tEvent)
    local stUserObject = GGameState:GetPlayerByChair(tGameUser.nSeatID)
    if stUserObject == nil then
        stUserObject = GDealer
    end
    local stepFunc = import(strStepName)
    if type(stepFunc) ~= 'function' then
        return  STEP_FAILED
    end
    return stepFunc(stUserObject, tEvent)
end
--]]
