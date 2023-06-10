local spells = {
    155722, -- rake = 155722,
    1079,   -- rip = 1079,
    405233, -- thrash = 405233,
    155625, -- moonfire = 155625,
}

NamePlatesComplete_AuraSortDriverMixin = {}

function NamePlatesComplete_AuraSortDriverMixin:OnLoad()
    self:SetSpells(spells)

    hooksecurefunc(NamePlateDriverFrame, "OnNamePlateCreated", function(_, nameplateBase)
        hooksecurefunc(nameplateBase, "OnOptionsUpdated", function(namePlate)
            self:OnNamePlateOptionsUpdated(namePlate)
        end)
    end)
end

function NamePlatesComplete_AuraSortDriverMixin:SetSpells(spells)
    self.spellOrder = {}
    for i, spellID in ipairs(spells) do
        self.spellOrder[spellID] = i - #spells
    end
end

function NamePlatesComplete_AuraSortDriverMixin:OnNamePlateOptionsUpdated(namePlate)
    local unitFrame = namePlate.UnitFrame
    if unitFrame then
        local buffFrame = unitFrame.BuffFrame
        if buffFrame then
            buffFrame.auras = TableUtil.CreatePriorityTable(function(a, b)
                return self:Compare(a, b)
            end, TableUtil.Constants.AssociativePriorityTable)
        end
    end
end

function NamePlatesComplete_AuraSortDriverMixin:Compare(a, b)
    local aOrder = self.spellOrder[a.spellId]
    local bOrder = self.spellOrder[b.spellId]
    if aOrder or bOrder then
        return (aOrder or a.auraInstanceID) < (bOrder or b.auraInstanceID)
    end

    return AuraUtil.DefaultAuraCompare(a,b)
end
