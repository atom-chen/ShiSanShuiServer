 GameUtil = GameUtil or {}


function GameUtil.GetScoreRecordName(nType)
    if nType == SCORE_RECORD_TYPE_WIND then
        return  GStringEncoding.zwind
    elseif nType == SCORE_RECORD_TYPE_RAIN then
        return  GStringEncoding.rain
    elseif nType == SCORE_RECORD_TYPE_BUWIND then
        return  GStringEncoding.bwind
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
    elseif nType == SCORE_RECORD_TYPE_GANGMOVE then
        return  GStringEncoding.gang_move
    elseif nType == SCORE_RECORD_TYPE_ADD_DI then
        return  GStringEncoding.selfwin_add
    elseif nType == SCORE_RECORD_BUY_CODE then
        return  GStringEncoding.buycode
    end
    LOG_ERROR("GetScoreRecordName(nType) Error Type:%d ", nType)
    return ""
end




function GameUtil.GetBalanceName(nBalanceType)
    if nBalanceType == BALANCE_TYPE_QUADRUPLET_CONCEALED then
        return  GStringEncoding.rain
    elseif nBalanceType == BALANCE_TYPE_QUADRUPLET then
        return  GStringEncoding.bwind
    elseif nBalanceType == BALANCE_TYPE_QUADRUPLET_REVEALED then
        return  GStringEncoding.zwind
    elseif nBalanceType == BALANCE_TYPE_WIN then
        return  GStringEncoding.hu
    elseif nBalanceType == BALANCE_TYPE_HUAZHU then
        return  GStringEncoding.check_huazhu
    elseif nBalanceType == BALANCE_TYPE_UNTING_TO_TING then
        return  GStringEncoding.no_ting
    elseif nBalanceType == BALANCE_TYPE_RETURN_QUADRUPLET then
        return  GStringEncoding.return_tax
    elseif nBalanceType == BALANCE_TYPE_ADD_DI then
        return  GStringEncoding.selfwin_add
    elseif nBalanceType == BALANCE_TYPE_BUY_CODE then
        return  GStringEncoding.buycode
    end
    LOG_ERROR("GetBalanceName Error nBalanceType:%d ", nBalanceType)
    return ""
end


