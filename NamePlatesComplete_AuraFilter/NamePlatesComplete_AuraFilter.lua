local addonName, _ = ...

NamePlatesComplete_AuraFilterDriverMixin = {}

function NamePlatesComplete_AuraFilterDriverMixin:OnLoad()
    self:RegisterEvent("NAME_PLATE_UNIT_ADDED")
end

function NamePlatesComplete_AuraFilterDriverMixin:OnEvent(event, ...)
    if event == "NAME_PLATE_UNIT_ADDED" then
        self:OnNamePlateUnitAdded(...)
    end
end

function NamePlatesComplete_AuraFilterDriverMixin:OnNamePlateUnitAdded(unit)
    local namePlate = C_NamePlate.GetNamePlateForUnit(unit)
    if namePlate then
        self:SetupHook(namePlate)
    end
end

function NamePlatesComplete_AuraFilterDriverMixin:SetupHook(namePlate)
    local buffFrame = namePlate.UnitFrame.BuffFrame
    if not buffFrame then
        return
    end

    local name = "ShouldShowBuff"
    if not NamePlatesComplete.IsHooked(buffFrame, name) then
        local defaultFilter = buffFrame[name]
        local addonFilter = function(selfBuffFrame, aura, forceAll)
            if self:ShouldShowBuff(aura, forceAll) then
                return true
            elseif self:ShouldHideBuff(aura, forceAll) then
                return false
            else
                return defaultFilter(selfBuffFrame, aura, forceAll)
            end
        end

        local hooked, message = NamePlatesComplete.Hook(buffFrame, name, addonFilter, true)
        if not hooked then
            print(string.format("%s cannot filter auras, please disable other nameplate addons. %s", addonName, message))
        end
    end
end

function NamePlatesComplete_AuraFilterDriverMixin:ShouldShowBuff(aura, forceAll)
    return aura.spellId == 5217
end

function NamePlatesComplete_AuraFilterDriverMixin:ShouldHideBuff(aura, forceAll)
end