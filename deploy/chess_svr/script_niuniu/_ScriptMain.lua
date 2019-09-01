package.cpath = package.cpath .. ";" .. "../script_thirteen/clib/?.so"
-- package.cpath = package.cpath .. ";" .. "../script_thirteen/clib/fzthirteen.so"
package.path = package.path .. ";"  .. "../script_thirteen/?.lua"
-- require "fzthirteen"

require "common/extern"
require "common/array"
require "common/debug_e"
require "common/debug_ext"
require "common/readonly"
require "common/bit"
_FlowTreeCtrl = _GameModule._FlowTreeCtrl
--print(vardump(_G))
local Dealer = import("core.dealer")
import("lib.loader_lib")
import("lib.cs_message")
import("framework.framework")

G_TABLEINFO = {}

local function InitCreateDeaer(tableptr, strFlow)
    --1.创建Dealer
     GDealer = Dealer.new()
    if GDealer:Init() ~= 0 then
        LOG_ERROR("OnGameInit Init Dealer Error.\n")
        --_FlowTreeCtrl.DestoryObject(GDealer)
        GDealer = nil
        return -1
    end

    --2.Dealer行为树
    local stProcess = _FlowTreeCtrl.CreateFlowTree()
    if stProcess:Init(tableptr, strFlow) ~= 0 then
        return -1
    end
    GDealer:AddFlow(stProcess)

    --3.初始化两个全局表
    GGameState = GDealer:GetGameState()
    GRoundInfo = GDealer:GetRoundInfo()
    return 0
end

local function IsAllPlayerFreeFlow()
    for i=1,PLAYER_NUMBER do
        local stPlayer = GGameState:GetPlayerByChair(i)
        if stPlayer then
            local stFlowProcess = stPlayer:GetFlowProcess()
            if stFlowProcess:IsFree()  == false then
                return false
            end
        end
    end
    return true
end

function _ScriptLogic_OnGameInit(tableptr, tableid, _gid, _gsc, level, seat_num, appcfg, extCfg)
    LOG_DEBUG("_ScriptLogic_OnGameInit _gid:%d", tonumber(_gid))
    local str_gsc = appcfg.__Base._gsc or "config.game_cfg_thirteen"
    G_TABLEINFO.tableptr = tableptr
    G_TABLEINFO.tableid = tableid
    G_TABLEINFO._gid = _gid
    G_TABLEINFO._gsc = str_gsc

    LOG_DEBUG("CFG: %s", vardump(extCfg))

    local iRetCode = 0
    --1. 初始化flow 框架
    iRetCode = FlowFramework.Init(str_gsc, _gid, extCfg, appcfg.GameCfg)
    if iRetCode ~= 0 then
        LOG_ERROR(" FlowFramework.Init Failed. _gsc:%s", str_gsc);
        return -1
    end

    --2. 设置全局配置表 replace with spec_cfg;
    GGameCfg = FlowFramework.GetGameCfg()
    GStringEncoding = import(GGameCfg.RoomSetting.stringEncoding)

    --3. 创建 deler
    iRetCode = InitCreateDeaer(tableptr,  GGameCfg.FlowSetting.strFlowDealer)
     if iRetCode ~= 0 then
        LOG_ERROR(" InitCreateDeaer Failed.");
        return -2
    end

    --4. 加载lib
    iRetCode = LoaderLib.LoadAll()
    if iRetCode ~= 0 then
        LOG_ERROR("LoaderLib.LoadAll Failed.");
        return -2
    end
    iRetCode = LoaderLib.CreateInitAll()
    if iRetCode ~= 0 then
        LOG_ERROR(" LoaderLib.CreateInitAll Failed.");
        return -2
    end

    FlowFramework.SetTimer_mi(DEALER_ID, 200, DEALER_TIMER_ID_0, -1)
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
    if stUserObject ~= GDealer then
        SSMessage.WakeupDealer()
    end
end

function _ScriptLogic_OnGameTimer()
    FlowFramework.OnTimer()
   
end

--[[
-- flow 调 step 入口
--
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
