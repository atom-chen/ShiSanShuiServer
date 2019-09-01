package.path = package.path .. ";" .. "../?.lua;"  .. "libtest/?.lua;".. "libtest/luaunit-3.2/?.lua" .. ";"


package.cpath = package.cpath .. ";" .. "../clib/?.so"


-- test define
require('slot_test_base')
require('common/debug_ext')

GGameCfg = require "config.game_cfg_chengdu"
require "core.card_define"
require "core.core_define"
-- PLAYER_NUMBER = GGameCfg.nPlayerNum

---------- 添加以下测试

-- 定义slot 文件
TSlotTest = TSlotTest or {
    slot_card_deal = "card_deal.slot_card_deal_default",
    slot_card_pool = "card_pool.slot_card_pool_default",
    slot_change_card = "change_card.slot_change_card_random",
    slot_flower_check = "flower_check.flower_check_common",
    slot_get_banker = "get_banker.slot_get_banker_random",
    slot_lack_card = "lack_card.slot_confirm_miss_common",
    slot_rule_collect = "rule_collect.rule_collect_common",
    slot_rule_triplet = "rule_triplet.rule_triplet_common",
    slot_rule_quadruplet = "rule_quadruplet.rule_quadruplet_common",
    slot_fan_chengdu = "fan_counter.slot_fan_chengdu",
     slot_win_normal = "rule_win.rule_win_common",
}
require "auto_test_slot_ext"



-- 测试用例
TestSlotCardDeal = require "libtest/test_slot_card_deal"
TestSlotCardPool = require "libtest/test_slot_card_pool"
TestSlotChangeCard = require "libtest/test_slot_change_card"
TestSlotFlowCheck = require "libtest/test_slot_flower_check"
TestSlotGetBanker = require "libtest/test_slot_get_banker"
TestSlotLackCard =  require "libtest/test_slot_lack_card"
TestSlotRuleCollect = require "libtest/test_slot_rule_collect"
TestSlotRuleTriplet = require "libtest/test_slot_rule_triplet"
TestSlotRuleQuadruplet = require "libtest/test_slot_rule_quadruplet"
TestSlotFanCounterChengdu = require "libtest/test_slot_fan_counter_chengdu"
TestSlotWinNormal = require "libtest/test_slot_win_normal"

LuaUnit:run()
