local _, ns = ...

ns.spellOrder = {}
ns.hooks = {}

function ns:Init(options)
    self.spellOrder = {}
    for i, spellID in ipairs(options.sortedSpellIDs) do
        self.spellOrder[spellID] = i - #options.sortedSpellIDs
    end
end

function ns:Compare(a, b)
    local aOrder = self.spellOrder[a.spellId]
    local bOrder = self.spellOrder[b.spellId]
    if aOrder or bOrder then
        return (aOrder or a.auraInstanceID) < (bOrder or b.auraInstanceID)
    end

    return AuraUtil.DefaultAuraCompare(a, b)
end

function ns:HookAuras(frame)
    if not self.hooks[frame] then
        self.hooks[frame] = true

        local compare = GenerateClosure(self.Compare, self)
        local ordered = TableUtil.CreatePriorityTable(compare, TableUtil.Constants.AssociativePriorityTable)
        frame.auras = ordered
    end
end

NameplateUp_AuraSortDriverMixin = {}

function NameplateUp_AuraSortDriverMixin:OnLoad()
    self:RegisterEvent("NAME_PLATE_UNIT_ADDED")
end

function NameplateUp_AuraSortDriverMixin:OnEvent(event, ...)
    if event == "NAME_PLATE_UNIT_ADDED" then
        self:OnNamePlateUnitAdded(...)
    end
end

function NameplateUp_AuraSortDriverMixin:OnNamePlateUnitAdded(unit)
    local namePlate = C_NamePlate.GetNamePlateForUnit(unit)
    if namePlate then
        self:SetupHook(namePlate)
    end
end

function NameplateUp_AuraSortDriverMixin:SetupHook(namePlate)
    local buffFrame = namePlate.UnitFrame.BuffFrame
    if not buffFrame then
        return
    end

    ns:HookAuras(buffFrame)

    NamePlateDriverFrame:OnUnitAuraUpdate(namePlate.namePlateUnitToken, { isFullUpdate = true })
end
