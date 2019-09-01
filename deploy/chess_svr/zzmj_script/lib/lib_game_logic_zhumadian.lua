local LibBase = import(".lib_base")
local PlayerBlockState = import("core.player_block_state")
local LibGameLogicZhumadian = class("LibGameLogicZhumadian", LibBase)

function LibGameLogicZhumadian:ctor()
end

function LibGameLogicZhumadian:CreateInit()
   return true
end

function LibGameLogicZhumadian:OnGameStart()
    return true
end

function LibGameLogicZhumadian:RewardThisGame()
    LOG_DEBUG("===========BEGIN  LibGameLogicZhumadian:RewardThisGame===============")
    local nWinPlayerNums  = 0
    local bSupportGangPao = GGameCfg.GameSetting.bSupportGangPao
    local bSupportDealerAdd = GGameCfg.GameSetting.bSupportDealerAdd
    local bSupportGangFlowAdd = GGameCfg.GameSetting.bSupportGangFlowAdd
    local bSupportSevenDoubleAdd = GGameCfg.GameSetting.bSupportSevenDoubleAdd
    local bGangFlower = 0
    local bQiDui = 0

    local gang_score = {}
    local hu_score = {}      -- 几个人的得分
    local desc = {}   -- 几个人的得失分描述
    local desc_arr = {}  -- 得分详情
    local set_cards = {}
    local cards = {}
    local win_card = {}
    local win_type = {}

    --依次为自摸，点炮、明杠、暗杠、庄家加底、杠上花、七对、杠跑、荒牌次数
    local self_draw_count ={}
    local self_gun_count ={}
    local revealed_gang_count ={}
    local conceled_gang_count ={}
    local dealer_add_count ={}
    local gangflower_count ={}
    local qidui_count ={}
    local gangpao_count ={}
    local huang_pai_count ={}

    local is_no_winner = true
    for i=1,PLAYER_NUMBER do
        gang_score[i] = 0;
        hu_score[i] = 0;
        desc[i] = "";
        desc_arr[i] = {
            ming_gang_count = 0,
            an_gang_count = 0,
            hu_count = 0,
            selfdraw_count = 0
        }
        self_draw_count[i] =0
        self_gun_count[i] =0
        revealed_gang_count[i] =0
        conceled_gang_count[i] =0
        dealer_add_count[i] =0
        gangflower_count[i] =0
        qidui_count[i] =0
        gangpao_count[i] =0
        huang_pai_count[i] =0
        -- win_card[i] = 0 -- 不要用值，后面需要用数组
        win_type[i] = ""
        local stPlayer = GGameState:GetPlayerByChair(i)
        set_cards[i] = stPlayer:GetPlayerCardSet():ToArray()
        cards[i] = stPlayer:GetPlayerCardGroup():ToArray()

        if stPlayer:IsWin() then
            is_no_winner = false;
        end
    end

    local function CalcGangScore()
		local base_score =1
        for i=1,PLAYER_NUMBER do
            local stPlayer = GGameState:GetPlayerByChair(i)
            local stCardSet = stPlayer:GetPlayerCardSet()
            for n=1,stCardSet:GetCurrentLength() do
                local sets = stCardSet:GetCardSetAt(n)                
                for j=1,PLAYER_NUMBER do
                    --玩家i不是庄家，j是庄家时，底分*2
                    local new_base_score = base_score
                    if bSupportDealerAdd and ((GRoundInfo:GetBanker() == j) or (GRoundInfo:GetBanker() == i))then 
                        new_base_score =base_score * 2
                    end

                    if sets.ucFlag == ACTION_QUADRUPLET or sets.ucFlag == ACTION_QUADRUPLET_REVEALED then
                        -- 明杠补杠，只跟输方结算
                        if j ~= i then
                            if j == sets.value then
                                local this_core = new_base_score
                                if bSupportGangPao then
                                    this_core = this_core + LibXiaPao:GetPlayerXiaPao(i) + LibXiaPao:GetPlayerXiaPao(j)
                                end
                                gang_score[j] = gang_score[j] - this_core
                                gang_score[i] = gang_score[i] + this_core
                                -- desc[i] = desc[i] .."明杠+1,"
                                desc_arr[i].ming_gang_count = desc_arr[i].ming_gang_count + 1
                                revealed_gang_count[i] =revealed_gang_count[i] +1
                                if bSupportGangPao then
                                    gangpao_count[i] = gangpao_count[i]+1
                                end
                            end
                        end
                    elseif sets.ucFlag == ACTION_QUADRUPLET_CONCEALED then
                        -- ACTION_QUADRUPLET_CONCEALED --暗杠
                        if j ~= i then
                            local this_core = new_base_score
                            if bSupportGangPao then
                                this_core = this_core + LibXiaPao:GetPlayerXiaPao(i) + LibXiaPao:GetPlayerXiaPao(j)
                            end
                            gang_score[j] = gang_score[j] - this_core * 2
                            gang_score[i] = gang_score[i] + this_core * 2
                        else
                            desc_arr[i].an_gang_count = desc_arr[i].an_gang_count + 1
                            conceled_gang_count[i] = conceled_gang_count[i] +1
                            if bSupportGangPao then
                                gangpao_count[i] = gangpao_count[i]+1
                            end
                        end
                    else
                        -- 其它，不算分
                        -- continue;
                    end
                end
            end
        end
    end

    local function CalcHuScore()
        --[[ 算胡分
        5.3杠上花加倍
           杠上花为玩家开房时的勾选项，玩家勾选后生效
           杠上花为玩家杠牌（包括明杠和暗杠）后，下一次摸牌的时候刚好胡，因此杠上花是胡牌玩家的专利
           当玩家开房时勾选了杠上花，则在牌局结束，结算时，胡牌分*2

        5.4七对加倍
           七对加倍为玩家开房时的勾选项，玩家勾选后生效
           七对为胡牌牌型的一种，即玩家胡牌时，全是对子（14张牌刚好7对）
           当玩家开房时勾选了七对加倍，则在牌局结束，结算时，胡牌分*2

        胡牌分=底分+赢方跑数+输方跑数
        和庄家结算时 ：胡牌分=底分*2+赢方跑数+输方跑数
        --]]
		local base_score =1
        for i=1,PLAYER_NUMBER do
            local stPlayer = GGameState:GetPlayerByChair(i)

            if stPlayer:IsWin() == true then

                win_card[i] = stPlayer:GetPlayerWinCards()[1] -- wins
                
                if GRoundInfo:GetWhoIsOnTurn()==i then
                    win_type[i] = "selfdraw"--"自摸"--"selfdraw"
                    desc_arr[i].selfdraw_count = desc_arr[i].selfdraw_count + 1
                    self_draw_count[i] = self_draw_count[i] +1
                else
                    win_type[i] = "gunwin"--"放枪"--"gunwin"
                    desc_arr[i].hu_count = desc_arr[i].hu_count + 1
                    self_gun_count[i] = self_gun_count[i] +1
                end
                
                -- todo: 杠上花
                bGangFlower = false
                if GRoundInfo:GetGang() and GRoundInfo:GetWhoIsOnTurn()==i then
                    bGangFlower = true;
                    win_type[i] = "gangflower"--"杠上花"--"gangflower"
                    gangflower_count[i] = gangflower_count[i] +1
                end

                -- todo: 七对
                local qiduiType, qiduiName = LibGameLogicZhumadian:CheckQiDuiType(i, win_card[i]);

                bQiDui = 0
                if qiduiType ~= 0 then
                    bQiDui = qiduiType;
                    win_type[i] = qiduiName --"qidui"
                    qidui_count[i] = qidui_count[i]+1
                end

                for j=1,PLAYER_NUMBER do
                    if i ~= j then
                        --玩家i不是庄家，j是庄家时，底分*2
                        local new_base_score = base_score
                        if bSupportDealerAdd and ((GRoundInfo:GetBanker() == j) or (GRoundInfo:GetBanker() == i))then 
                            new_base_score =base_score * 2
                        end
                        local this_core = new_base_score + LibXiaPao:GetPlayerXiaPao(i) + LibXiaPao:GetPlayerXiaPao(j)

                        if bSupportGangFlowAdd and bGangFlower then
                            this_core = this_core * 2
                        end
                        if bSupportSevenDoubleAdd and bQiDui ~= 0 then
                            this_core = this_core * (2 ^ bQiDui)
                        end
                        LOG_DEBUG(" %d + %d + %d = %d", new_base_score, LibXiaPao:GetPlayerXiaPao(i), LibXiaPao:GetPlayerXiaPao(j), this_core)

                        hu_score[j] = hu_score[j] - this_core
                        hu_score[i] = hu_score[i] + this_core
                    end
                end

                -- nWinPlayerNums = nWinPlayerNums + 1
            end
        end-- for player huscore
    end

    if is_no_winner then
        --荒庄 杠分
        CalcGangScore()
    else
        --杠分
        CalcGangScore()
        --胡分
        CalcHuScore()
    end

    --结算显示记录
    local stScoreRecord = LibGameLogic:GetScoreRecord()
    for i=1, PLAYER_NUMBER do
        local stPlayer = GGameState:GetPlayerByChair(i)
        local uinfo = stPlayer:GetUserInfo()
        if desc_arr[i].ming_gang_count ~= 0 then
            if string.len(desc[i]) > 0 then
                desc[i] = desc[i] ..", "
            end
            desc[i] = desc[i] .."明杠+".. desc_arr[i].ming_gang_count
        end
        if desc_arr[i].an_gang_count ~= 0 then
            if string.len(desc[i]) > 0 then
                desc[i] = desc[i] ..", "
            end
            desc[i] = desc[i] .."暗杠+".. desc_arr[i].an_gang_count
        end
        if desc_arr[i].hu_count ~= 0 then
            if string.len(desc[i]) > 0 then
                desc[i] = desc[i] ..", "
            end
            desc[i] = desc[i] .."胡牌+".. desc_arr[i].hu_count
        end
        if desc_arr[i].selfdraw_count ~= 0 then
            if string.len(desc[i]) > 0 then
                desc[i] = desc[i] ..", "
            end
            desc[i] = desc[i] .."自摸+".. desc_arr[i].selfdraw_count
        end
        local rec = {
            _chair       = "p" ..i,
            _uid         = uinfo._uid,
            xiapao      = LibXiaPao:GetPlayerXiaPao(i),
            gang_score  = gang_score[i],
            hu_score    = hu_score[i],
            all_score   = gang_score[i] + hu_score[i],
            score_desc  = desc[i],
            combineTile = set_cards[i],
            discardTile = stPlayer:GetPlayerGiveGroup():ToArray(),
            cards       = cards[i],
            win_card    = {win_card[i]},
            win_type    = win_type[i],
            self_draw_count     =self_draw_count[i],
            self_gun_count      =self_gun_count[i],
            revealed_gang_count =revealed_gang_count[i],
            conceled_gang_count =conceled_gang_count[i],
            huang_pai_count     =huang_pai_count[i],
        }
        if bSupportGangPao then
           rec.gangpao_count    =gangpao_count[i]
        end
        if bSupportDealerAdd then
           rec.dealer_add_count =dealer_add_count[i]
        end 
        if bSupportGangFlowAdd then
           rec.gangflower_count =gangflower_count[i]
        end 
        if bSupportSevenDoubleAdd then
           rec.qidui_count      =qidui_count[i]
        end 
        LOG_DEBUG("WHEN rec==================,  rec=%s",vardump(rec))
        stScoreRecord:SetRecordByChair(i, rec)

        --test 更新金币积分
        local nAdd = gang_score[i] + hu_score[i]
        stPlayer:AddScore(nAdd)
        stPlayer:AddMoney(nAdd * 10)
    end
    LOG_DEBUG("===========END  LibGameLogicZhumadian:RewardThisGame===============")
end

function LibGameLogicZhumadian:CheckQiDuiType(nChair, nCard)
    local env = LibFanCounter:CollectEnv(nChair)
    env.byChair = nChair - 1
    LibFanCounter:SetEnv(env)
    local stFanCount = LibFanCounter:GetCount()
    LOG_DEBUG("chair:%d, card:%d, stFanCount:%s", nChair, nCard, vardump(stFanCount))
    local nFanNum = 0


    local qiduiType = 0
    local qiduiName = ""
    for i=1,#stFanCount do
        nFanNum = nFanNum + stFanCount[i].byFanNumber
        if stFanCount[i].byFanType == 4 then
            if qiduiType < 1 then
                qiduiType = 1
                qiduiName = "qidui"--"七对"
            end
        end
    end
    -- return nFanNum
    return qiduiType, qiduiName
end
        
return LibGameLogicZhumadian