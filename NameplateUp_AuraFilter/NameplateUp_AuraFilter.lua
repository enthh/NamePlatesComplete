local addonName, ns = ...

ns.showSpellIDs = {}
ns.hideSpellIDs = {}

function ns:Init(options)
    self.showSpellIDs = {}
    self.hideSpellIDs = {}
end

function ns:HookShouldShowBuff(frame)
    local hook = self.ShouldShowBuff
    local call = frame.ShouldShowBuff

    if not frame.__ShouldShowBuff then
        frame.__ShouldShowBuff = call
        frame.ShouldShowBuff = hook
    elseif hook ~= call then -- hook replaced
        print(string.format("%s cannot filter auras, please disable other nameplate addons.", addonName))
    end
end

function ns.ShouldShowBuff(buffFrame, aura, forceAll)
    if ns:MatchHideBuff(aura, forceAll) then
        return false
    elseif ns:MatchShowBuff(aura, forceAll) then
        return true
    else
        return buffFrame:__ShouldShowBuff(aura, forceAll)
    end
end

function ns:MatchShowBuff(aura, forceAll)
    return (aura.isStealable and aura.duration < 120)
        or (ns.CC[aura.spellId])
        or (ns.CD[aura.spellId])
        or (ns.Tank[aura.spellId])
end

function ns:MatchHideBuff(aura, forceAll)
    return false
end

NameplateUp_AuraFilterDriverMixin = {}

function NameplateUp_AuraFilterDriverMixin:OnLoad()
    self.hooks = {}
    self:RegisterEvent("NAME_PLATE_UNIT_ADDED")
end

function NameplateUp_AuraFilterDriverMixin:OnEvent(event, ...)
    if event == "NAME_PLATE_UNIT_ADDED" then
        self:OnNamePlateUnitAdded(...)
    end
end

function NameplateUp_AuraFilterDriverMixin:OnNamePlateUnitAdded(unit)
    local namePlate = C_NamePlate.GetNamePlateForUnit(unit)
    if namePlate then
        self:SetupHook(namePlate)
    end
end

function NameplateUp_AuraFilterDriverMixin:SetupHook(namePlate)
    local buffFrame = namePlate.UnitFrame.BuffFrame
    if not buffFrame then
        return
    end

    ns:HookShouldShowBuff(buffFrame)
end
