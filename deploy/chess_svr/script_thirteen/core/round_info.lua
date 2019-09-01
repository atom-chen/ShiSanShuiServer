local RoundInfo = class("RoundInfo")
-- 回合内 牌面对局信息
-- 对局内记录  
function RoundInfo:ctor()
    self.m_bCompareWait = false     --比牌阶段等待 客户端有动画展示
    self.m_nCompareExpiredTime = 0  --比牌阶段等待到期时间
    self.m_stOpenList = {
    	first = {},		--翻牌的先后顺序 比较牌 从小到大   {chairid,....}
    	second = {},
    	third = {},
    }
end

function RoundInfo:InitRoundInfo()
    self.m_bCompareWait = false
    self.m_nCompareExpiredTime = 0
end

function RoundInfo:IsCompareWait()
    return self.m_bCompareWait
end

function RoundInfo:SetCompareWait(bWait)
    self.m_bCompareWait = bWait
end

function RoundInfo:GetCompareExpiredTime()
    return self.m_nCompareExpiredTime
end

function RoundInfo:SetCompareExpiredTime(nExpiredTime)
    self.m_nCompareExpiredTime = nExpiredTime
end

function RoundInfo:SetOpenList(stOpenList)
	self.m_stOpenList = stOpenList 
end
function RoundInfo:GetOpenList()
    return self.m_stOpenList
end

return RoundInfo
