--[[
-- 游戏相关的的配置
--]]
import("core.core_define")
local GameCfg =  {
       nMoneyMode = MONEY_MODE_MONEY, --默认是金币场，传配置则是房卡场
       nPlayerNum = 4,      --默认4人
       nJuNum     = 10,     -- 一圈多少局（房卡模式）
       nCurrJu    = 1,      -- 当前是第几局
       rno        = 0,      -- 房号

       --房间设置
       RoomSetting = {
            nChargeMode = CHARGE_MODE_FREE,          -- 扣费方式
            nGameStyle = GAME_STYLE_THIRTEEN,        -- 游戏类型  十三张等
            nSubGameStyle = SUB_GAME_STYLE_NORMAL,   --游戏子类型：普通，水庄等。。。
            nBaseBet = 100,                          -- 底分, 各个地区规则计算完底分后，再计算这里的
            nMaxWaterScore = 8,
            stringEncoding = "flow_config.string_encoding_cn"
        },

        --定时时间
        TimerSetting = {
            readyTimeOut = 180,              -- -1为不超时一直等

            TimeOutLimit = -1,              -- 房卡场除ready外不设置超时
        },

        --游戏设置
        GameSetting = {
          nGamePlay = 1,    --游戏玩法
        },

        --行为树
        FlowSetting = {
            strDealer = "core.dealer",
            strFlowDealer = "../script_fightbull/flow_config/flow_dealer.json",
            strFlowPlayer = "../script_fightbull/flow_config/flow_player.json",
            strFlowPlayerExt = "../script_fightbull/flow_config/flow_player_ext.json",
        },
}

return GameCfg
