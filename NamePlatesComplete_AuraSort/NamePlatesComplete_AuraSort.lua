local addonName, _ = ...

NamePlatesComplete_AuraSortDriverMixin = {}

function NamePlatesComplete_AuraSortDriverMixin:OnLoad()
    self.spells = {
        155722, -- rake = 155722,
        1079,   -- rip = 1079,
        405233, -- thrash = 405233,
        155625, -- moonfire = 155625,
    }
    self:Refresh()

    self:RegisterEvent("NAME_PLATE_UNIT_ADDED")
end

function NamePlatesComplete_AuraSortDriverMixin:OnEvent(event, ...)
    if event == "NAME_PLATE_UNIT_ADDED" then
        self:OnNamePlateUnitAdded(...)
    end
end

function NamePlatesComplete_AuraSortDriverMixin:OnNamePlateUnitAdded(unit)
    local namePlate = C_NamePlate.GetNamePlateForUnit(unit)
    if namePlate then
        self:SetupHook(namePlate)
    end
end

function NamePlatesComplete_AuraSortDriverMixin:SetupHook(namePlate)
    local buffFrame = namePlate.UnitFrame.BuffFrame
    if not buffFrame then
        return
    end

    if buffFrame and buffFrame.auras == nil or buffFrame.__np_complete_auras == nil then
        if buffFrame.__np_complete_auras and buffFrame.__np_complete_auras ~= buffFrame.auras then
            print(addonName .. ": An unknown addon modified aura sorting. Please disable other nameplate addons.")
        end

        local ordered = TableUtil.CreatePriorityTable(
            function(a, b)
                return self:Compare(a, b)
            end,
            TableUtil.Constants.AssociativePriorityTable)

        buffFrame.__np_complete_auras = ordered
        buffFrame.auras = ordered

        NamePlateDriverFrame:OnUnitAuraUpdate(namePlate.namePlateUnitToken, { isFullUpdate = true })
    end
end

function NamePlatesComplete_AuraSortDriverMixin:Refresh()
    self.spellOrder = {}
    for i, spellID in ipairs(self.spells) do
        self.spellOrder[spellID] = i - #self.spells
    end
end

function NamePlatesComplete_AuraSortDriverMixin:Compare(a, b)
    local aOrder = self.spellOrder[a.spellId]
    local bOrder = self.spellOrder[b.spellId]
    if aOrder or bOrder then
        return (aOrder or a.auraInstanceID) < (bOrder or b.auraInstanceID)
    end

    return AuraUtil.DefaultAuraCompare(a, b)
end
