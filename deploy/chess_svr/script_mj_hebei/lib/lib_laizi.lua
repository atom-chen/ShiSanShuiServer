-- 加载 slot/change_card
local LibBase = import(".lib_base")
local LibLaiZi = class("LibLaiZi", LibBase)
function LibLaiZi:ctor()
	self.sit = {}
	self.card = {}
    self.laizi = {}
end

function LibLaiZi:CreateInit(strSlotName)
	return true
end

function LibLaiZi:OnGameStart()
end

function LibLaiZi:GetSit()
    return self.sit
end

function LibLaiZi:GetCard()
    return self.card
end

function LibLaiZi:GetLaiZi()
    return self.laizi
end

function LibLaiZi:SetLaiZi(sit, card, LaiZi)
	self.sit = sit
	self.card = card
    self.laizi = LaiZi
end

function LibLaiZi:IsGenLaiZi()
	return #self.laizi > 0
end

function LibLaiZi:IsLaiZi(nCard)
    local bRet = false
    for j=1,#self.laizi do
        if self.laizi[j] == nCard then
            bRet = true
            break
        end
    end
    return bRet
end


return LibLaiZi