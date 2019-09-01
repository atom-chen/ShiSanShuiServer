local LibBase = import(".lib_base")
import("core.game_util")
local PlayerCardGroup = import("core.player_cardgroup")
local ScoreRecord = import("core.score_record")

local stGameState = nil
local stRoundInfo = nil
local LibGame = class("LibGame", LibBase)
function LibGame:ctor()
    self.m_stScoreRecord = ScoreRecord.new()
end

function LibGame:CreateInit(strSlotName)
    stGameState = GGameState
    stRoundInfo = GRoundInfo
    return true
end

function LibGame:OnGameStart()
    self.m_stScoreRecord:Init()
    self.m_bGameOver = false
end


function LibGame:GetScoreRecord()
    return self.m_stScoreRecord
end

--普通比牌
function LibGame:CompareTwoPlayerNormal(stPlayer1, stPlayer2)
    local  chairid1 = stPlayer1:GetChairID()
    local  chairid2 = stPlayer2:GetChairID()

    local score1 = {
        toChairid = chairid2,           -- 对方的椅子id
        toUid = stPlayer2:GetUin(),     --对方的uid
        nFirstScore = 0,                -- 前墩积分
        nFirstScoreExt = 0,             -- 前墩额外积分
        nSecondScore = 0,
        nSecondScoreExt = 0,
        nThirdScore = 0,
        nThirdScoreExt = 0,
        nSpecialScore = 0,              --特殊牌积分
        nShoot = 0,                     -- 打枪：-1我被对方打枪 0双方都没有打枪 1我打对方枪
        nShootMult = 2,                 -- 打枪的倍数
        nHasCode = 0,                   --码牌: 0没有 1有
        nCodeMult = 2,                  --码牌的倍数
        nWanterMult = 0,                --选择的倍数(水庄的时候用到)
        nFinalScore = 0,                --和toChairid比最后积分(包括打枪，买码)
    }
    local score2 = {
        toChairid = chairid1,           -- 对方的椅子id 
        toUid = stPlayer1:GetUin(),
        nFirstScore = 0,                -- 前墩积分
        nFirstScoreExt = 0,             -- 前墩额外积分
        nSecondScore = 0,
        nSecondScoreExt = 0,
        nThirdScore = 0,
        nThirdScoreExt = 0,
        nSpecialScore = 0,              --特殊牌积分
        nShoot = 0,                     -- 打枪：-1我被对方打枪 0双方都没有打枪 1我打对方枪
        nShootMult = 2,                 -- 打枪的倍数
        nHasCode = 0,                   --码牌: 0没有 1有
        nCodeMult = 2,                  --码牌的倍数
        nWanterMult = 0,                --选择的倍数(水庄的时候用到)
        nFinalScore = 0,                --和toChairid比最后积分(包括打枪，买码)
    }

    local stPlayerCardGroup1 = stPlayer1:GetPlayerCardGroup()
    local stPlayerCardGroup2 = stPlayer2:GetPlayerCardGroup()

    --先判断是否有特殊牌型
    local nSpType1 = stPlayerCardGroup1:GetSpecialType()
    local nSpType2 = stPlayerCardGroup2:GetSpecialType()
    -- LOG_DEBUG("LibGame:CompareTwoPlayerNormal..chairid1: %d, nSpType1: %d, chairid2: %d, nSpType2: %d \n", chairid1,  nSpType1, chairid2, nSpType2)
    if nSpType1 > GStars_Special_Type.PT_SP_NIL or nSpType2 > GStars_Special_Type.PT_SP_NIL then
        local nSpScore1 = GetSpecialScore(nSpType1)
        local nSpScore2 = GetSpecialScore(nSpType2)
        if nSpScore1 > nSpScore2 then
            score1.nSpecialScore = nSpScore1
            score2.nSpecialScore = 0 - nSpScore1
        end
        if nSpScore1 < nSpScore2 then
            score1.nSpecialScore = 0 - nSpScore2
            score2.nSpecialScore = nSpScore2
        end
    else
        --计算前墩是否有2张鬼牌
        local stFirstCards1 = stPlayerCardGroup1:GetChooseCard(1)
        local stFirstCards2 = stPlayerCardGroup2:GetChooseCard(1)
        local nGhostCount1 = GetGhostCard(stFirstCards1)
        local nGhostCount2 = GetGhostCard(stFirstCards2)

        --牌型
        local type_f1 = stPlayerCardGroup1:GetNormalCardtype(1)
        local type_s1 = stPlayerCardGroup1:GetNormalCardtype(2)
        local type_t1 = stPlayerCardGroup1:GetNormalCardtype(3)

        local type_f2 = stPlayerCardGroup2:GetNormalCardtype(1)
        local type_s2 = stPlayerCardGroup2:GetNormalCardtype(2)
        local type_t2 = stPlayerCardGroup2:GetNormalCardtype(3)

        --基础分
        local base_f1 = GetBaseScore(type_f1)
        local base_s1 = GetBaseScore(type_s1)
        local base_t1 = GetBaseScore(type_t1)

        local base_f2 = GetBaseScore(type_f2)
        local base_s2 = GetBaseScore(type_s2)
        local base_t2 = GetBaseScore(type_t2)

        --额外加成分
        local ext_f1 = GetExtScore(1, type_f1)
        local ext_s1 = GetExtScore(2, type_s1)
        local ext_t1 = GetExtScore(3, type_t1)

        local ext_f2 = GetExtScore(1, type_f2)
        local ext_s2 = GetExtScore(2, type_s2)
        local ext_t2 = GetExtScore(3, type_t2)

        --前中后墩 比牌 计算积分
        local value_f1 = stPlayerCardGroup1:GetChooseValue(1)
        local value_s1 = stPlayerCardGroup1:GetChooseValue(2)
        local value_t1 = stPlayerCardGroup1:GetChooseValue(3)

        local value_f2 = stPlayerCardGroup2:GetChooseValue(1)
        local value_s2 = stPlayerCardGroup2:GetChooseValue(2)
        local value_t2 = stPlayerCardGroup2:GetChooseValue(3)

        local nFirstScore = LibNormalCardLogic:CompareCardsLaizi(type_f1, type_f2, value_f1, value_f2)
        local nSecondScore = LibNormalCardLogic:CompareCardsLaizi(type_s1, type_s2, value_s1, value_s2)
        local nThirdScore = LibNormalCardLogic:CompareCardsLaizi(type_t1, type_t2, value_t1, value_t2)
        --对鬼冲前，现在在这暂时修改  如果以后还有类似的特殊需求  可以用一个文件归类处理
        if nGhostCount1 >= 2 or nGhostCount2 >= 2 then
            if nGhostCount1 >= 2 and nGhostCount2 >= 2 then
                --2人 有对鬼
                --维持原来的
            elseif nGhostCount1 >= 2 and nGhostCount2 < 2 then
                --1人有对鬼
                nFirstScore = 1
            elseif nGhostCount2 >= 2 and nGhostCount1 < 2 then
                --1人有对鬼
                nFirstScore = -1
            end

            if nGhostCount1 >= 2 then
                --前墩有两张鬼牌 特殊分20
                ext_f1 = GetExtScore(1, PT_THREE_GHOST)
            end
            if nGhostCount2 >= 2 then
                --前墩有两张鬼牌 特殊分20
                ext_f2 = GetExtScore(1, PT_THREE_GHOST)
            end
        end


        if nFirstScore > 0 then
            score1.nFirstScore = score1.nFirstScore + base_f1
            score2.nFirstScore = score2.nFirstScore - base_f1
            score1.nFirstScoreExt = score1.nFirstScoreExt + ext_f1
            score2.nFirstScoreExt = score2.nFirstScoreExt - ext_f1
        end
        if nSecondScore > 0 then
            score1.nSecondScore = score1.nSecondScore + base_s1
            score2.nSecondScore = score2.nSecondScore - base_s1
            score1.nSecondScoreExt = score1.nSecondScoreExt + ext_s1
            score2.nSecondScoreExt = score2.nSecondScoreExt - ext_s1
        end
        if nThirdScore > 0 then
            score1.nThirdScore = score1.nThirdScore + base_t1
            score2.nThirdScore = score2.nThirdScore - base_t1
            score1.nThirdScoreExt = score1.nThirdScoreExt + ext_t1
            score2.nThirdScoreExt = score2.nThirdScoreExt - ext_t1
        end

        if nFirstScore < 0 then
            score1.nFirstScore = score1.nFirstScore - base_f2
            score2.nFirstScore = score2.nFirstScore + base_f2
            score1.nFirstScoreExt = score1.nFirstScoreExt - ext_f2
            score2.nFirstScoreExt = score2.nFirstScoreExt + ext_f2
        end
        if nSecondScore < 0 then
            score1.nSecondScore = score1.nSecondScore - base_s2
            score2.nSecondScore = score2.nSecondScore + base_s2
            score1.nSecondScoreExt = score1.nSecondScoreExt - ext_s2
            score2.nSecondScoreExt = score2.nSecondScoreExt + ext_s2
        end
        if nThirdScore < 0 then
            score1.nThirdScore = score1.nThirdScore - base_t2
            score2.nThirdScore = score2.nThirdScore + base_t2
            score1.nThirdScoreExt = score1.nThirdScoreExt - ext_t2
            score2.nThirdScoreExt = score2.nThirdScoreExt + ext_t2
        end

        --打枪判断
        if nFirstScore > 0 and nSecondScore > 0 and nThirdScore > 0 then
            score1.nShoot = 1
            score2.nShoot = -1
            stPlayer1:GetPlayerCompareResult():AddShoot(chairid2)
        end        
        if nFirstScore < 0 and nSecondScore < 0 and nThirdScore < 0 then
            score1.nShoot = -1
            score2.nShoot = 1
            stPlayer2:GetPlayerCompareResult():AddShoot(chairid1)
        end
    end

    --计算输赢积分
    score1.nFinalScore = score1.nFirstScore + score1.nFirstScoreExt + score1.nSecondScore + score1.nSecondScoreExt + score1.nThirdScore + score1.nThirdScoreExt + score1.nSpecialScore
    score2.nFinalScore = score2.nFirstScore + score2.nFirstScoreExt + score2.nSecondScore + score2.nSecondScoreExt + score2.nThirdScore + score2.nThirdScoreExt + score2.nSpecialScore
    --计算打枪
    if score1.nShoot ~= 0 then
        score1.nFinalScore = score1.nFinalScore * 2
        score2.nFinalScore = score2.nFinalScore * 2
    end
    --计算码牌
    local bHasCode1 = stPlayerCardGroup1:IsHasCodeCard()
    local bHasCode2 = stPlayerCardGroup2:IsHasCodeCard()
    -- LOG_DEBUG("===========uid:%d, p%d, bHasCode1:%s", stPlayer1:GetUin(), chairid1, tostring(bHasCode1))
    -- LOG_DEBUG("===========uid:%d, p%d, bHasCode2:%s", stPlayer2:GetUin(), chairid2, tostring(bHasCode2))
    if bHasCode1 and not bHasCode2 then
        score1.nFinalScore = score1.nFinalScore * 2
        score2.nFinalScore = score2.nFinalScore * 2
        score1.nHasCode = 1
        score2.nHasCode = 0
    end
    if bHasCode2 and not bHasCode1 then
        score1.nFinalScore = score1.nFinalScore * 2
        score2.nFinalScore = score2.nFinalScore * 2
        score1.nHasCode = 0
        score2.nHasCode = 1
    end 

    --保存比牌结果
    -- LOG_DEBUG("LibGame:CompareTwoPlayerNormal..chairid1: %s \n", vardump(score1))
    -- LOG_DEBUG("LibGame:CompareTwoPlayerNormal..chairid2: %s \n", vardump(score2))
    stPlayer1:GetPlayerCompareResult():AddScoreResult(score1)
    stPlayer2:GetPlayerCompareResult():AddScoreResult(score2)
end
function LibGame:CompareResultNormal()
    --两两相比
    for i=1, PLAYER_NUMBER do
        local stPlayer1 = stGameState:GetPlayerByChair(i)
        if stPlayer1 then 
            local stPlayerCardGroup1 = stPlayer1:GetPlayerCardGroup()
            -- LOG_DEBUG("LibGame:CompareResultNormal iii...p%d, type(stPlayer1):%s", i, tostring(type(stPlayer1)))
            for j=i+1, PLAYER_NUMBER do
                local stPlayer2 = stGameState:GetPlayerByChair(j)
                if stPlayer2 then
                    -- LOG_DEBUG("LibGame:CompareResultNormal jjj...p%d, type(stPlayer2):%s", j, tostring(type(stPlayer1)))
                    self:CompareTwoPlayerNormal(stPlayer1, stPlayer2)
                end
            end
        end
    end
    --计算打枪次数、判断全垒打, 计算比牌时间需要到
    local nShootCount = 0
    local bAllShoot = false
    local nAllShootChairID = 0
    for i=1, PLAYER_NUMBER do
        local stPlayer = stGameState:GetPlayerByChair(i)
        if stPlayer then
            local stPlayerCompareResult = stPlayer:GetPlayerCompareResult()
            local nCount = stPlayerCompareResult:GetShootCount()
            --4人或以上才会触发是否计算全垒打
            if PLAYER_NUMBER >= ALL_SHOOT_PLAYER_NUM and nCount + 1 == PLAYER_NUMBER then
                stPlayerCompareResult:SetAllShoot(true)
                bAllShoot = true
                nAllShootChairID = i
            end
            nShootCount = nShootCount + nCount
        end
    end
    --
    GDealer:SetAllShoot(bAllShoot)
    --
    GDealer:SetAllShootChairID(nAllShootChairID)
    --
    GDealer:SetShootNums(nShootCount)

    --计算最终积分
    for i=1, PLAYER_NUMBER do
        local stPlayer = stGameState:GetPlayerByChair(i)
        if stPlayer then
            local stPlayerCompareResult = stPlayer:GetPlayerCompareResult()
            if bAllShoot then
                if nAllShootChairID == i then
                    stPlayerCompareResult:SetAllShoot(1)
                else
                    stPlayerCompareResult:SetAllShoot(-1)
                end
            end
            stPlayerCompareResult:CalculateTotallScore()
        end
    end
end

--水庄比牌
function LibGame:CompareTwoPlayerWater(stPlayer1, stPlayer2)
    local  chairid1 = stPlayer1:GetChairID()
    local  chairid2 = stPlayer2:GetChairID()

    local score1 = {
        toChairid = chairid2,           -- 对方的椅子id
        toUid = stPlayer2:GetUin(),     --对方的uid
        nFirstScore = 0,                -- 前墩积分
        nFirstScoreExt = 0,             -- 前墩额外积分
        nSecondScore = 0,
        nSecondScoreExt = 0,
        nThirdScore = 0,
        nThirdScoreExt = 0,
        nSpecialScore = 0,              --特殊牌积分
        nShoot = 0,                     -- 打枪：-1我被对方打枪 0双方都没有打枪 1我打对方枪
        nShootMult = 2,                 -- 打枪的倍数
        nHasCode = 0,                   --码牌: 0没有 1有
        nCodeMult = 2,                  --码牌的倍数
        nWanterMult = 1,                --选择的倍数(水庄的时候用到)
        nFinalScore = 0,                --和toChairid比最后积分(包括打枪，买码)
    }
    local score2 = {
        toChairid = chairid1,           -- 对方的椅子id 
        toUid = stPlayer1:GetUin(),
        nFirstScore = 0,                -- 前墩积分
        nFirstScoreExt = 0,             -- 前墩额外积分
        nSecondScore = 0,
        nSecondScoreExt = 0,
        nThirdScore = 0,
        nThirdScoreExt = 0,
        nSpecialScore = 0,              --特殊牌积分
        nShoot = 0,                     -- 打枪：-1我被对方打枪 0双方都没有打枪 1我打对方枪
        nShootMult = 2,                 -- 打枪的倍数
        nHasCode = 0,                   --码牌: 0没有 1有
        nCodeMult = 2,                  --码牌的倍数
        nWanterMult = 1,                --选择的倍数(水庄的时候用到)
        nFinalScore = 0,                --和toChairid比最后积分(包括打枪，买码)
    }

    local stPlayerCardGroup1 = stPlayer1:GetPlayerCardGroup()
    local stPlayerCardGroup2 = stPlayer2:GetPlayerCardGroup()

    --先判断是否有特殊牌型
    local nSpType1 = stPlayerCardGroup1:GetSpecialType()
    local nSpType2 = stPlayerCardGroup2:GetSpecialType()
    -- LOG_DEBUG("LibGame:CompareTwoPlayerWater..chairid1: %d, nSpType1: %d, chairid2: %d, nSpType2: %d \n", chairid1, nSpType1, chairid2, nSpType2)
    if nSpType1 > GStars_Special_Type.PT_SP_NIL or nSpType2 > GStars_Special_Type.PT_SP_NIL then
        local nSpScore1 = GetSpecialScore(nSpType1)
        local nSpScore2 = GetSpecialScore(nSpType2)
        if nSpScore1 > nSpScore2 then
            score1.nSpecialScore = nSpScore1
            score2.nSpecialScore = 0 - nSpScore1
        end
        if nSpScore1 < nSpScore2 then
            score1.nSpecialScore = 0 - nSpScore2
            score2.nSpecialScore = nSpScore2
        end
    else
        --计算前墩是否有2张鬼牌
        local stFirstCards1 = stPlayerCardGroup1:GetChooseCard(1)
        local stFirstCards2 = stPlayerCardGroup2:GetChooseCard(1)
        local nGhostCount1 = GetGhostCard(stFirstCards1)
        local nGhostCount2 = GetGhostCard(stFirstCards2)
        --基础分
        --牌型
        local type_f1 = stPlayerCardGroup1:GetNormalCardtype(1)
        local type_s1 = stPlayerCardGroup1:GetNormalCardtype(2)
        local type_t1 = stPlayerCardGroup1:GetNormalCardtype(3)

        local type_f2 = stPlayerCardGroup2:GetNormalCardtype(1)
        local type_s2 = stPlayerCardGroup2:GetNormalCardtype(2)
        local type_t2 = stPlayerCardGroup2:GetNormalCardtype(3)

        --基础分
        local base_f1 = GetBaseScore(type_f1)
        local base_s1 = GetBaseScore(type_s1)
        local base_t1 = GetBaseScore(type_t1)

        local base_f2 = GetBaseScore(type_f2)
        local base_s2 = GetBaseScore(type_s2)
        local base_t2 = GetBaseScore(type_t2)

        --额外加成分
        local ext_f1 = GetExtScore(1, type_f1)
        local ext_s1 = GetExtScore(2, type_s1)
        local ext_t1 = GetExtScore(3, type_t1)

        local ext_f2 = GetExtScore(1, type_f2)
        local ext_s2 = GetExtScore(2, type_s2)
        local ext_t2 = GetExtScore(3, type_t2)

        --前中后墩 比牌 计算积分
        local value_f1 = stPlayerCardGroup1:GetChooseValue(1)
        local value_s1 = stPlayerCardGroup1:GetChooseValue(2)
        local value_t1 = stPlayerCardGroup1:GetChooseValue(3)

        local value_f2 = stPlayerCardGroup2:GetChooseValue(1)
        local value_s2 = stPlayerCardGroup2:GetChooseValue(2)
        local value_t2 = stPlayerCardGroup2:GetChooseValue(3)

        local nFirstScore = LibNormalCardLogic:CompareCardsLaizi(type_f1, type_f2, value_f1, value_f2)
        local nSecondScore = LibNormalCardLogic:CompareCardsLaizi(type_s1, type_s2, value_s1, value_s2)
        local nThirdScore = LibNormalCardLogic:CompareCardsLaizi(type_t1, type_t2, value_t1, value_t2)
        --对鬼冲前，现在在这暂时修改  如果以后还有类似的特殊需求  可以用一个文件归类处理
        if nGhostCount1 >= 2 or nGhostCount2 >= 2 then
            if nGhostCount1 >= 2 and nGhostCount2 >= 2 then
                --2人 有对鬼
                --维持原来的
            elseif nGhostCount1 >= 2 and nGhostCount2 < 2 then
                --1人有对鬼
                nFirstScore = 1
            elseif nGhostCount2 >= 2 and nGhostCount1 < 2 then
                --1人有对鬼
                nFirstScore = -1
            end

            if nGhostCount1 >= 2 then
                --前墩有两张鬼牌 特殊分20
                ext_f1 = GetExtScore(1, PT_THREE_GHOST)
            end
            if nGhostCount2 >= 2 then
                --前墩有两张鬼牌 特殊分20
                ext_f2 = GetExtScore(1, PT_THREE_GHOST)
            end
        end

        if nFirstScore > 0 then
            score1.nFirstScore = score1.nFirstScore + base_f1
            score2.nFirstScore = score2.nFirstScore - base_f1
            score1.nFirstScoreExt = score1.nFirstScoreExt + ext_f1
            score2.nFirstScoreExt = score2.nFirstScoreExt - ext_f1
        end
        if nSecondScore > 0 then
            score1.nSecondScore = score1.nSecondScore + base_s1
            score2.nSecondScore = score2.nSecondScore - base_s1
            score1.nSecondScoreExt = score1.nSecondScoreExt + ext_s1
            score2.nSecondScoreExt = score2.nSecondScoreExt - ext_s1
        end
        if nThirdScore > 0 then
            score1.nThirdScore = score1.nThirdScore + base_t1
            score2.nThirdScore = score2.nThirdScore - base_t1
            score1.nThirdScoreExt = score1.nThirdScoreExt + ext_t1
            score2.nThirdScoreExt = score2.nThirdScoreExt - ext_t1
        end

        if nFirstScore < 0 then
            score1.nFirstScore = score1.nFirstScore - base_f2
            score2.nFirstScore = score2.nFirstScore + base_f2
            score1.nFirstScoreExt = score1.nFirstScoreExt - ext_f2
            score2.nFirstScoreExt = score2.nFirstScoreExt + ext_f2
        end
        if nSecondScore < 0 then
            score1.nSecondScore = score1.nSecondScore - base_s2
            score2.nSecondScore = score2.nSecondScore + base_s2
            score1.nSecondScoreExt = score1.nSecondScoreExt - ext_s2
            score2.nSecondScoreExt = score2.nSecondScoreExt + ext_s2
        end
        if nThirdScore < 0 then
            score1.nThirdScore = score1.nThirdScore - base_t2
            score2.nThirdScore = score2.nThirdScore + base_t2
            score1.nThirdScoreExt = score1.nThirdScoreExt - ext_t2
            score2.nThirdScoreExt = score2.nThirdScoreExt + ext_t2
        end

        --打枪判断
        if nFirstScore > 0 and nSecondScore > 0 and nThirdScore > 0 then
            score1.nShoot = 1
            score2.nShoot = -1
            stPlayer1:GetPlayerCompareResult():AddShoot(chairid2)
        end        
        if nFirstScore < 0 and nSecondScore < 0 and nThirdScore < 0 then
            score1.nShoot = -1
            score2.nShoot = 1
            stPlayer2:GetPlayerCompareResult():AddShoot(chairid1)
        end
    end

    --计算输赢积分
    score1.nFinalScore = score1.nFirstScore + score1.nFirstScoreExt + score1.nSecondScore + score1.nSecondScoreExt + score1.nThirdScore + score1.nThirdScoreExt + score1.nSpecialScore
    score2.nFinalScore = score2.nFirstScore + score2.nFirstScoreExt + score2.nSecondScore + score2.nSecondScoreExt + score2.nThirdScore + score2.nThirdScoreExt + score2.nSpecialScore
    --计算打枪
    if score1.nShoot == -1 then
        score1.nFinalScore = score1.nFinalScore - 1
        score2.nFinalScore = score2.nFinalScore + 1
    end
    if score1.nShoot == 1 then
        score1.nFinalScore = score1.nFinalScore + 1
        score2.nFinalScore = score2.nFinalScore - 1
    end
    --闲家倍数算积分
    if math.abs(score2.nFinalScore) > 8 then
        if score2.nFinalScore > 0 then
            score1.nFinalScore = -8
            score2.nFinalScore = 8
        else
            score1.nFinalScore = 8
            score2.nFinalScore = -8
        end
    end
    local nMult = LibMult:GetPlayerMult(chairid2)
    -- LOG_DEBUG("============p%d, nMult:%d", chairid2, nMult)
    if nMult <= 0 then
        nMult = 1
    end
    score1.nWanterMult = nMult
    score2.nWanterMult = nMult
    score1.nFinalScore = score1.nFinalScore * nMult
    score2.nFinalScore = score2.nFinalScore * nMult

    --保存比牌结果
    -- LOG_DEBUG("LibGame:CompareTwoPlayerWater..chairid1: %s \n", vardump(score1))
    -- LOG_DEBUG("LibGame:CompareTwoPlayerWater..chairid2: %s \n", vardump(score2))
    stPlayer1:GetPlayerCompareResult():AddScoreResult(score1)
    stPlayer2:GetPlayerCompareResult():AddScoreResult(score2)
end
function LibGame:CompareResultWater()
    local nBanker = GDealer:GetBanker()
    -- LOG_DEBUG("LibGame:CompareResultWater..nBanker: %d \n", nBanker)
    local stPlayer1 = stGameState:GetPlayerByChair(nBanker)
    if stPlayer1 then
        for i=1, PLAYER_NUMBER do
            if nBanker ~= i then
                local stPlayer2 = stGameState:GetPlayerByChair(i)
                if stPlayer2 then
                    self:CompareTwoPlayerWater(stPlayer1, stPlayer2)
                end
            end
        end
        --计算打枪次数, 计算比牌时间需要到
        local nShootCount = 0
        for i=1, PLAYER_NUMBER do
            local stPlayer = stGameState:GetPlayerByChair(i)
            if stPlayer then
                local stPlayerCompareResult = stPlayer:GetPlayerCompareResult()
                local nCount = stPlayerCompareResult:GetShootCount()
                nShootCount = nShootCount + nCount
            end
        end
        GDealer:SetAllShoot(false)
        GDealer:SetShootNums(nShootCount)

        --计算最终积分
        for i=1, PLAYER_NUMBER do
            local stPlayer = stGameState:GetPlayerByChair(i)
            if stPlayer then
                local stPlayerCompareResult = stPlayer:GetPlayerCompareResult()
                stPlayerCompareResult:CalculateTotallScore()
            end
        end
    end
end

--
function LibGame:CompareOpen()
    local stOpenList = {
        first = {},     --翻牌的先后顺序 比较牌 从小到大   {chairid,....}
        second = {},
        third = {},
    }

    local structseq = {}
    for i=1, PLAYER_NUMBER do
        if structseq[i] == nil then
            structseq[i] = {}
        end
        structseq[i].chairid = 0
        structseq[i].sCore = 0
    end
    -- LOG_DEBUG("structseq: %s\n", vardump(structseq))
    for k=1, 3 do
        for i=1, PLAYER_NUMBER do
            -- 前中后墩 比牌设置
            structseq[i].sCore = 10
            structseq[i].chairid = i
        end
        for i=1, PLAYER_NUMBER do
            local stPlayer1 = stGameState:GetPlayerByChair(i)
            if stPlayer1 then
                local stPlayerCardGroup1 = stPlayer1:GetPlayerCardGroup()
                local typeA = stPlayerCardGroup1:GetNormalCardtype(k)
                local valuesA = stPlayerCardGroup1:GetChooseValue(k)
                for j=1, PLAYER_NUMBER do
                    local stPlayer2 = stGameState:GetPlayerByChair(j)
                    if stPlayer2 then
                        local stPlayerCardGroup2 = stPlayer2:GetPlayerCardGroup()
                        local typeB = stPlayerCardGroup2:GetNormalCardtype(k)
                        local valuesB = stPlayerCardGroup2:GetChooseValue(k)
                        local CompareResult = LibNormalCardLogic:CompareCardsLaizi(typeA, typeB, valuesA, valuesB)
                        --对鬼冲前
                        if k == 1 then
                            local stFirstCards1 = stPlayerCardGroup1:GetChooseCard(1)
                            local nGhostCount1 = GetGhostCard(stFirstCards1)
                            local stFirstCards2 = stPlayerCardGroup2:GetChooseCard(1)
                            local nGhostCount2 = GetGhostCard(stFirstCards2)
                            --对鬼冲前，现在在这暂时修改  如果以后还有类似的特殊需求  可以用一个文件归类处理
                            if nGhostCount1 >= 2 or nGhostCount2 >= 2 then
                                if nGhostCount1 >= 2 and nGhostCount2 >= 2 then
                                    --2人 有对鬼
                                    --维持原来的
                                elseif nGhostCount1 >= 2 and nGhostCount2 < 2 then
                                    --1人有对鬼
                                    CompareResult = 1
                                elseif nGhostCount2 >= 2 and nGhostCount1 < 2 then
                                    --1人有对鬼
                                    CompareResult = -1
                                end
                            end
                        end
                        if CompareResult < 0 then
                            structseq[i].sCore = structseq[i].sCore - 1
                        elseif CompareResult > 0 then
                            structseq[i].sCore = structseq[i].sCore + 1
                        end
                    end
                end
            end
        end
        -- LOG_DEBUG("=======k:%d====structseq:%s", k, vardump(structseq))
        -- table.sort(structseq, function function_name(a, b )
        --     return a.sCore < b.sCore
        -- end)
        --根据sCore排序
        for i=1, PLAYER_NUMBER do
            for j=i+1, PLAYER_NUMBER do
                if structseq[i].sCore > structseq[j].sCore then
                    local tempid = structseq[i].chairid
                    local tempscore = structseq[i].sCore
                    structseq[i].chairid = structseq[j].chairid
                    structseq[i].sCore = structseq[j].sCore
                    structseq[j].chairid = tempid
                    structseq[j].sCore = tempscore
                end
            end
        end
        if k == 1 then
            for i=1, PLAYER_NUMBER do 
                stOpenList.first[i] = structseq[i].chairid   
            end
        elseif k == 2 then
            for i=1, PLAYER_NUMBER do 
                stOpenList.second[i] = structseq[i].chairid   
            end
        else
            for i=1, PLAYER_NUMBER do 
                stOpenList.third[i] = structseq[i].chairid   
            end
        end
        -- LOG_DEBUG("======k:%d, v:%s", k, vardump(stOpenList.first))
        -- LOG_DEBUG("======k:%d, v:%s", k, vardump(stOpenList.second)) 
        -- LOG_DEBUG("======k:%d, v:%s", k, vardump(stOpenList.third))  
    end
    
    -- LOG_DEBUG("stOpenList: %s\n", vardump(stOpenList))
    stRoundInfo:SetOpenList(stOpenList)
    return stOpenList
end

--比牌
function LibGame:CompareResult()
    if GGameCfg.GameSetting.bSupportWaterBanker then
        self:CompareResultWater()
    else
        self:CompareResultNormal()
    end

    --翻牌顺序
    self:CompareOpen()
end

function LibGame:NotifyCompareResult()
    local stOpenList = stRoundInfo:GetOpenList()
    -- LOG_DEBUG("stOpenList: %s\n", vardump(stOpenList))

    --每个玩家各墩开牌顺序
    local firstOpen = {}
    local secondOpen = {}
    local thirdOpen = {}
    for i=1, PLAYER_NUMBER do
        local stPlayer = stGameState:GetPlayerByChair(i)
        if stPlayer then
            local stPlayerCardGroup = stPlayer:GetPlayerCardGroup()
            if stPlayerCardGroup:GetSpecialType() <= 0 then
                for _, v in pairs(stOpenList) do
                    -- LOG_DEBUG("stOpenList.v: %s\n", vardump(v))
                    if v == stOpenList.first then
                        for k, chairid in ipairs(v) do
                            if chairid == i then
                                firstOpen[i] = k
                                break
                            end
                        end
                    end
                    if v == stOpenList.second then
                        for k, chairid in ipairs(v) do
                            if chairid == i then
                                secondOpen[i] = k
                                break
                            end
                        end
                    end
                    if v == stOpenList.third then
                        for k, chairid in ipairs(v) do
                            if chairid == i then
                                thirdOpen[i] = k
                                break
                            end
                        end
                    end
                end
            else
                --特殊牌型
            end
        end
    end

    --每个玩家牌墩信息
    local allCompareData = {}
    for i=1, PLAYER_NUMBER do
        local stPlayer = stGameState:GetPlayerByChair(i)
        if stPlayer then
            local stPlayerCardGroup = stPlayer:GetPlayerCardGroup()
            local stPlayerCompareResult = stPlayer:GetPlayerCompareResult()

            --牌墩及牌型
            local result = {}
            result.chairid = stPlayer:GetChairID()
            result.nSpecialType = stPlayerCardGroup:GetSpecialType()
            result.nFirstType = stPlayerCardGroup:GetNormalCardtype(1)
            result.nSecondType = stPlayerCardGroup:GetNormalCardtype(2)
            result.nThirdType = stPlayerCardGroup:GetNormalCardtype(3)
            result.nOpenFirst = 0
            result.nOpenSecond = 0
            result.nOpenThird = 0
            result.nOpenSpecial = 0
            result.nTotallScore = stPlayerCompareResult:GetTotallScore()

            if result.nSpecialType <= 0 then
                result.nOpenFirst = firstOpen[i]
                result.nOpenSecond = secondOpen[i]
                result.nOpenThird = thirdOpen[i]
            end
          
            --牌墩:1-5是后墩 6-10是中墩 11-13是前墩
            result.stCards = stPlayerCardGroup:GetChooseCardArray()
            -- LOG_DEBUG("NotifyCompareResult, len: %d\n",#result.stCards)
            --打枪列表
            result.stShoots = stPlayerCompareResult:GetShootList()

            table.insert(allCompareData, result)
        end
    end


    local nAllShootChairID = GDealer:GetAllShootChairID() or 0
    local stDealerCardGroup = GDealer:GetDealerCardGroup()
    local stLeftCards = stDealerCardGroup:ToArray()
    for i=1, PLAYER_NUMBER do
        local stPlayer = stGameState:GetPlayerByChair(i)
        if stPlayer then
            local stPlayerCompareResult = stPlayer:GetPlayerCompareResult()

            local notifyData = {
                _chair = "p" .. i,
                _uid = stPlayer:GetUin(),
                nAllShootChairID = nAllShootChairID,    --全垒打玩家
                stAllCompareData = {},     --所有人的牌信息：各个玩家的牌、牌型、打枪列表
                stCompareScores = {},      --我与所有人的比牌详细积分
                stLeftCards = {},
            }
            notifyData.stAllCompareData = allCompareData
            notifyData.stCompareScores = stPlayerCompareResult:GetScoreResult()
            notifyData.stLeftCards = stLeftCards

            -- LOG_DEBUG("LibGame:NotifyCompareResult..uid: %d, p%d, notifyData: %s\n", stPlayer:GetUin(), i, vardump(notifyData))
            CSMessage.NotifyPlayerCompareResult(stPlayer, notifyData)
        end
    end
end

function LibGame:RewardThisGame() 
    --单局结算展示牌型、特殊牌型提示和该局分数 
    --打枪次数  全垒打次数 特殊牌型次数 胜利次数(得分大于零，则为胜利)
    for i=1, PLAYER_NUMBER do
        local stPlayer = GGameState:GetPlayerByChair(i)
        if stPlayer then
            local stPlayerCardGroup = stPlayer:GetPlayerCardGroup()
            local stPlayerCompareResult = stPlayer:GetPlayerCompareResult()

            --特殊牌型 特殊牌型次数
            local nSpecialType = stPlayerCardGroup:GetSpecialType()
            local nSpecialNums = 0
            if nSpecialType > 0 then
                nSpecialNums = 1
            end
            --打枪次数
            local nShootNums = stPlayerCompareResult:GetShootCount()
            --全垒打次数
            local nAllShootNums = 0
            if stPlayerCompareResult:IsAllShoot() then
                nAllShootNums = 1
            end
            --该局分数
            local nTotalScores = stPlayerCompareResult:GetTotallScore()
            --胜利次数(得分大于零，则为胜利)
            local nWinNums, nLoseNums, nEqualNums = 0, 0, 0
            if nTotalScores > 0 then
                nWinNums = 1
            elseif nTotalScores == 0 then
                nEqualNums = 1
            else
                nLoseNums = 1
            end

            local rec = {
                _chair = "p" .. i,
                _uid = stPlayer:GetUin(),
                nSpecialType = nSpecialType,
                nFirstType = stPlayerCardGroup:GetNormalCardtype(1),
                nSecondType = stPlayerCardGroup:GetNormalCardtype(2),
                nThirdType = stPlayerCardGroup:GetNormalCardtype(3),
                --牌墩:1-5是后墩 6-10是中墩 11-13是前墩
                stCards = stPlayerCardGroup:GetChooseCardArray(),
                -- stCompareScores = stPlayerCompareResult:m_stPlayerCompareResult:GetScoreResult(),
                all_score = nTotalScores,
                nSpecialNums = nSpecialNums,
                nShootNums = nShootNums,
                nAllShootNums = nAllShootNums,
                nWinNums = nWinNums,
            }
            self.m_stScoreRecord:SetRecordByChair(i, rec)
            self.m_stScoreRecord:SetPlayerSumScore(i, rec.all_score)
            --
            stPlayer:AddRoomSumScore(nTotalScores)
            stPlayer:UpdataGameScore(nTotalScores, nTotalScores, nWinNums, nLoseNums, nEqualNums)
            -- CSMessage.NotifyPlayerRoomSumScoreToAll(stPlayer)
        end
    end
end

return LibGame