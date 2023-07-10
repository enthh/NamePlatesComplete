local _, ns = ...

NamePlatesComplete_AuraSortDriverMixin = {}

function NamePlatesComplete_AuraSortDriverMixin:OnLoad()
    ns.driver = self

    self.spells = {}
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

function NamePlatesComplete_AuraSortDriverMixin:Init(options)
    self.spellOrder = {}
    for i, spellID in ipairs(options.sortedSpellIDs) do
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
