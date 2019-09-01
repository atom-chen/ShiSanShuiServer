local LibBase = import(".lib_base")
local PlayerBlockState = import("core.player_block_state")
local LibGameLogicLuoyang = class("LibGameLogicLuoyang", LibBase)

function LibGameLogicLuoyang:ctor()
end

function LibGameLogicLuoyang:CreateInit()
   return true
end

function LibGameLogicLuoyang:OnGameStart()
    return true
end

function LibGameLogicLuoyang:ProcessOPWin()
    local stWinList = {}
    local nChair = GRoundInfo:GetLastWinner()
    local stPlayer = GGameState:GetPlayerByChair(nChair)
    --杠次处理
    local nGangci = GRoundInfo:GetGangciHu()
    if nGangci > 0 then
        --杠次胡手牌最多只有13张牌,把次牌放进手牌中,DoProcessOPWin需要处理
        local nCard = LibCi:GetCi()
        stPlayer:GetPlayerCardGroup():AddCard(nCard)
        stWinList = { winner = nChair, winWho = nChair, cardWin = nCard }
    else
        local lastTurnChair = GRoundInfo:GetWhoIsOnTurn()
        local nCard = GRoundInfo:GetLastDraw() or 0
        stWinList = { winner = nChair, winWho = lastTurnChair, cardWin = nCard }
    end

    LOG_DEBUG("LibGameLogicLuoyang:ProcessOPWin...nGangci=%d, stWinList=%s\n", nGangci, vardump(stWinList))
    -- 通知胡逻辑 {{}}
   LibGameLogic:DoProcessOPWin({stWinList})
end

function LibGameLogicLuoyang:RewardThisGame()
    LOG_DEBUG("===========BEGIN  LibGameLogicLuoyang:RewardThisGame===============")

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
        for i=1,PLAYER_NUMBER do
            local stPlayer = GGameState:GetPlayerByChair(i)
            local stCardSet = stPlayer:GetPlayerCardSet()
            for n=1,stCardSet:GetCurrentLength() do
                local sets = stCardSet:GetCardSetAt(n)
                
                for j=1,PLAYER_NUMBER do

                    local base_score = 1 -- 底分
                    --玩家i不是庄家，j是庄家时，底分*2
                    if bSupportDealerAdd and ((GRoundInfo:GetBanker() == j) or (GRoundInfo:GetBanker() == i))then 
                        base_score = base_score * 2
                    end

                    if sets.ucFlag == ACTION_QUADRUPLET or sets.ucFlag == ACTION_QUADRUPLET_REVEALED then
                        -- 明杠补杠，只跟输方结算
                        if j ~= i then
                            if j == sets.value then
                                local this_core = base_score
                                --杠跑
                                if bSupportGangPao then
                                    this_core = this_core + LibXiaPao:GetPlayerXiaPao(i) + LibXiaPao:GetPlayerXiaPao(j)
                                end
                                gang_score[j] = gang_score[j] - this_core
                                gang_score[i] = gang_score[i] + this_core
                                -- desc[i] = desc[i] .."明杠+1,"
                                desc_arr[i].ming_gang_count = desc_arr[i].ming_gang_count + 1
                            end
                        end
                    elseif sets.ucFlag == ACTION_QUADRUPLET_CONCEALED then
                        --暗杠和三家都计算杠分
                        if j ~= i then
                            local this_core = base_score
                            if bSupportGangPao then
                                this_core = this_core + LibXiaPao:GetPlayerXiaPao(i) + LibXiaPao:GetPlayerXiaPao(j)
                            end
                            --输方 杠分* 2
                            gang_score[j] = gang_score[j] - this_core
                            --我方 杠分* 2
                            gang_score[i] = gang_score[i] + this_core
                        else
                            desc_arr[i].an_gang_count = desc_arr[i].an_gang_count + 1
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
        --[[
            自摸（软呲）：自己摸牌时，摸到的牌组成胡牌（1分）
            明呲：明杠胡牌时形成杠呲称为明呲（3分）
            暗呲：暗杠胡牌时形成杠呲称为暗呲（3分）
            皮呲：当玩家手中有三张呲牌的时候，不用管手中的其他牌，都可以直接胡牌，称为皮呲（碰的三张呲牌不算，只有自己摸的才算）（3分）
            包呲：当摸牌摸到剩最后5墩（10张）时，如果一名玩家出牌造成其他玩家杠呲，则包所有玩家本局所输的分数（6分）
        --]]
        for i=1,PLAYER_NUMBER do
            local stPlayer = GGameState:GetPlayerByChair(i)
            if stPlayer:IsWin() == true then
                --1. 判断是否是杠次
                local nGangci, nWhoBaoci = GRoundInfo:GetGangciHu()
                local bBaoci = false
                local bPici = false
                if nGangci > 0 then
                    if nGangci == ACTION_QUADRUPLET then
                        --2 是，判断明次(点杠)是否包次
                        local nDealerCardLeft = GDealer:GetDealerCardGroup():GetCurrentLength()
                        if nDealerCardLeft <= 10 then
                            bBaoci = true
                        end
                    end
                else
                    --3 否，判断是否是皮呲
                    local nCard = LibCi:GetCi()
                    local nCiCardCount = stPlayer:GetPlayerCardGroup():GetCardCount(nCard)
                    if nCiCardCount >= 3 then
                        bPici = true
                    end
                end
                LOG_DEBUG("LibGameLogicLuoyang:RewardThisGame...nGangci=%d, nWhoBaoci=%d, bPici=%s", nGangci, nWhoBaoci, tostring(bPici))

                --
                for j=1,PLAYER_NUMBER do
                    if i~= j then
                        if bBaoci then
                            local base_score = 6
                            hu_score[nWhoBaoci] = hu_score[nWhoBaoci] - base_score
                            hu_score[i] = hu_score[i] + base_score
                        else
                            local base_score = 1 -- 底分
                            if nGangci > 0 or bPici then
                                --
                                base_score = 3
                            end
                            hu_score[j] = hu_score[j] - base_score
                            hu_score[i] = hu_score[i] + base_score
                        end
                    end
                end
            end
        end
    end

    if is_no_winner then
        -- --荒庄时不计算杠分
        -- CalcGangScore()
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
            win_type    = win_type[i]
        }

        LOG_DEBUG("LibGameLogicLuoyang:RewardThisGame(): %s", vardump(rec))

        stScoreRecord:SetRecordByChair(i, rec)
    end
    LOG_DEBUG("===========END  LibGameLogicLuoyang:RewardThisGame===============")
end
        
return LibGameLogicLuoyang