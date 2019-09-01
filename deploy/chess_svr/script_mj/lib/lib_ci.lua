-- 加载 slot/change_card
local LibBase = import(".lib_base")
local LibCi = class("LibCi", LibBase)
function LibCi:ctor()
	self.nCard = 0
end

function LibCi:CreateInit(strSlotName)
	return true
end
function LibCi:OnGameStart()
 
end

function LibCi:GetCi()
    return self.nCard
end

function LibCi:SetCi(nCard)
	self.nCard = nCard
end

function LibCi:IsGenCi()
	return self.nCard > 0
end

return LibCi