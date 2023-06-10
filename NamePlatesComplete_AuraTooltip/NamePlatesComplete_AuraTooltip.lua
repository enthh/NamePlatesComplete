NamePlatesComplete_AuraTooltipDriverMixin = {}

function NamePlatesComplete_AuraTooltipDriverMixin:OnLoad()
    self:RegisterEvent("NAME_PLATE_UNIT_ADDED")
    self:RegisterEvent("UNIT_AURA")
end

function NamePlatesComplete_AuraTooltipDriverMixin:OnEvent(event, ...)
    if event == "NAME_PLATE_UNIT_ADDED" then
        self:OnNamePlateUnitAdded(...)
    elseif event == "UNIT_AURA" then
        self:OnUnitAura(...)
    end
end

function NamePlatesComplete_AuraTooltipDriverMixin:OnNamePlateUnitAdded(unit)
    self:OnUnitAura(unit, { isFullUpdate = true })
end

function NamePlatesComplete_AuraTooltipDriverMixin:OnUnitAura(unit, unitAuraInfo)
    local namePlate = C_NamePlate.GetNamePlateForUnit(unit)
    if namePlate then
        self:UpdateBuffs(namePlate.UnitFrame.BuffFrame, namePlate.namePlateUnitToken, unitAuraInfo)
    end
end

function NamePlatesComplete_AuraTooltipDriverMixin:UpdateBuffs(buffFrame, unit, unitAuraUpdateInfo)
    for _, buff in ipairs({ buffFrame:GetChildren() }) do
        if buff:IsMouseEnabled() then
            buff:EnableMouse(false)
        end
    end
end
