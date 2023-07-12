local NameplateUp_AuraTooltipDriverMixin = {}

function NameplateUp_AuraTooltipDriverMixin:OnLoad()
    self:RegisterEvent("NAME_PLATE_UNIT_ADDED")
    self:RegisterEvent("UNIT_AURA")
end

function NameplateUp_AuraTooltipDriverMixin:OnEvent(event, ...)
    if event == "NAME_PLATE_UNIT_ADDED" then
        self:OnNamePlateUnitAdded(...)
    elseif event == "UNIT_AURA" then
        self:OnUnitAura(...)
    end
end

function NameplateUp_AuraTooltipDriverMixin:OnNamePlateUnitAdded(unit)
    self:OnUnitAura(unit, { isFullUpdate = true })
end

function NameplateUp_AuraTooltipDriverMixin:OnUnitAura(unit, unitAuraInfo)
    local namePlate = C_NamePlate.GetNamePlateForUnit(unit)
    if namePlate then
        self:UpdateBuffs(namePlate.UnitFrame.BuffFrame, namePlate.namePlateUnitToken, unitAuraInfo)
    end
end

function NameplateUp_AuraTooltipDriverMixin:UpdateBuffs(buffFrame, unit, unitAuraUpdateInfo)
    for _, buff in ipairs({ buffFrame:GetChildren() }) do
        if buff:IsMouseEnabled() or not buff:IsMouseMotionEnabled() then
            buff:EnableMouse(false)
            buff:EnableMouseMotion(true)
        end
    end
end

_G["NameplateUp_AuraTooltipDriverMixin"] = NameplateUp_AuraTooltipDriverMixin