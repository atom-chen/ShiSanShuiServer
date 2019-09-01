GameUtil = GameUtil or {}


function GameUtil.GetScoreRecordName(nType)
    if nType == SCORE_RECORD_TYPE_WIND then
        return  GStringEncoding.wind
    elseif nType == SCORE_RECORD_TYPE_RAIN then
        return  GStringEncoding.rain
    elseif nType == SCORE_RECORD_TYPE_GUN then
        return  GStringEncoding.gun
    elseif nType == SCORE_RECORD_TYPE_SELFWIN then
        return  GStringEncoding.selfwin
    elseif nType == SCORE_RECORD_TYPE_HUAZHU then
        return  GStringEncoding.check_huazhu
    elseif nType == SCORE_RECORD_TYPE_DAJIAO then
        return  GStringEncoding.no_ting
    elseif nType == SCORE_RECORD_TYPE_TAX then
        return  GStringEncoding.return_tax
    end
    LOG_ERROR("GetScoreRecordName(nType) Error Type:%d ", nType)
    return ""
end

function GameUtil.GetBalanceName(nBalanceType)
    if nBalanceType == BALANCE_TYPE_QUADRUPLET_CONCEALED then
        return  GStringEncoding.wind
    elseif nBalanceType == BALANCE_TYPE_QUADRUPLET_REVEALED then
        return  GStringEncoding.rain
    elseif nBalanceType == BALANCE_TYPE_WIN then
        return  GStringEncoding.hu
    elseif nBalanceType == BALANCE_TYPE_HUAZHU then
        return  GStringEncoding.check_huazhu
    elseif nBalanceType == BALANCE_TYPE_UNTING_TO_TING then
        return  GStringEncoding.no_ting
    elseif nBalanceType == BALANCE_TYPE_RETURN_QUADRUPLET then
        return  GStringEncoding.return_tax
    end
    LOG_ERROR("GetBalanceName Error nBalanceType:%d ", nBalanceType)
    return ""
end


