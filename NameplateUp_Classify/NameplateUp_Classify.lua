local addon, ns = ...

-- Imports
local _G = _G

local function get(tbl, key)
    local val = tbl[key]
    if val == nil then
        val = {}
        tbl[key] = val
        return val
    end
    return val
end

function ns:classifyCast(spell)
    local cast = {}

    local desc = spell:GetSpellDescription()
    if string.find(desc, "in front", 1, true) then
        cast.frontal = true
    end

    if (string.find(desc, " within %d") and not string.find(desc, " impact", 1, true))
        or string.find(desc, " howl", 1, true)
        or string.find(desc, " terror", 1, true)
        or string.find(desc, " fear", 1, true)
        or string.find(desc, " flee", 1, true)
        or string.find(desc, " strun", 1, true)
    then
        cast.aoe = true
    end

    if string.find(desc, " heal", 1, true)
        or string.find(desc, " mend", 1, true)
        or string.find(desc, " restore", 1, true)
    then
        cast.heal = true
    end

    local name, _, _, castTime, _, maxRange = GetSpellInfo(spell:GetSpellID())
    cast.name = name

    if castTime > 0 then
        cast.cast = true
    end

    if maxRange > 0 and maxRange <= 12 then
        cast.kite = true
    end

    return cast
end

function ns:OnLoad()
    if NameplateUp_ClassifyDB == nil then
        NameplateUp_ClassifyDB = {
            version = 1,
        }
    end

    self.db = NameplateUp_ClassifyDB

    hooksecurefunc("CompactUnitFrame_UpdateClassificationIndicator", function(frame)
        ns:Classify(frame)
    end)
end

function ns:AcquireEnemyForUnit(unit)
    if not unit then
        return
    end

    local guid = UnitGUID(unit)
    if not guid then
        return
    end

    local type, _, serverID, instanceID, zoneUID, npcID, spawnID = strsplit("-", guid)
    if type ~= "Creature" then
        return
    end

    return get(get(get(self.db, type), tonumber(instanceID)), tonumber(npcID))
end

function ns:OnCast(unit, castGUID, spellID)
    local npc = self:AcquireEnemyForUnit(unit)
    if not npc then
        return
    end

    local casts = get(npc, "casts")
    local cast = casts[spellID]
    if cast then
        return
    end

    local spell = Spell:CreateFromSpellID(spellID)
    spell:ContinueOnSpellLoad(function()
        cast = self:classifyCast(spell)
        casts[spellID] = cast
        MergeTable(npc, cast)
        ns:UpdateAll()
    end)
end

function ns:UpdateAll()
    for _, namePlate in ipairs(C_NamePlate.GetNamePlates() or {}) do
        ns:Classify(namePlate.UnitFrame)
    end
end

function ns:Classify(unitFrame)
    if unitFrame:IsForbidden() then
        return
    end

    local npc = ns:AcquireEnemyForUnit(unitFrame.displayedUnit)
    if not npc then
        return
    end

    if npc.frontal then
        unitFrame.classificationIndicator:SetAtlas("upgradeitem-32x32")
        unitFrame.classificationIndicator:Show()
    elseif npc.aoe then
        unitFrame.classificationIndicator:SetAtlas("vehicle-trap-red")
        unitFrame.classificationIndicator:Show()
    elseif npc.heal then
        unitFrame.classificationIndicator:SetAtlas("GreenCross")
        unitFrame.classificationIndicator:Show()
    elseif npc.cast then
        unitFrame.classificationIndicator:SetAtlas("VignetteEventElite")
        unitFrame.classificationIndicator:Show()
    end
end

function ns:OnNameplateAdded(unit)
    local namePlate = C_NamePlate.GetNamePlateForUnit(unit)
    if not namePlate or namePlate:IsForbidden() then
        return
    end

    ns:Classify(namePlate)
end

local NameplateUp_ClassifyDriverMixin = {}

function NameplateUp_ClassifyDriverMixin:OnLoad()
    self:RegisterEvent("ADDON_LOADED")
    self:RegisterEvent("NAME_PLATE_UNIT_ADDED")

    self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
    self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
end

function NameplateUp_ClassifyDriverMixin:OnEvent(event, ...)
    if event == "ADDON_LOADED" then
        local loaded = ...
        if loaded == addon then
            ns:OnLoad()
        end
    elseif event == "NAME_PLATE_UNIT_ADDED" then
        local unit = ...
        ns:OnNameplateAdded(unit)
    elseif event == "UNIT_SPELLCAST_SUCCEEDED"
        or event == "UNIT_SPELLCAST_CHANNEL_START" then
        local unit, castGUID, spellID = ...
        if string.find(unit, "nameplate", 1, true) then
            ns:OnCast(unit, castGUID, spellID)
        end
    end
end

-- Exports
_G.NameplateUp_ClassifyDriverMixin = NameplateUp_ClassifyDriverMixin
