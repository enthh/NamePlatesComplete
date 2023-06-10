--[[

NamePlatesComplete_AuraGlow

BlizzardNameplates_NamePlates manages the lifecycle of nameplates and handles
updates for auras (UNIT_AURA). It cannot be easily modified to add behavior
specifically to non-forbidden nameplates.

When UNIT_AURA is processed in the BuffFrame's UpdateBuffs method, it first
calculates a cache of auras. If there are changes in the cache since the last
calculation, the child frames in the Buff's layout are recreated from a frame
pool. After this, the child frames need to be reassigned to the new layout's
frames.

NamePlatesComplete_AuraGlow lifecycle needs to match the buff lifecycle, not the
frame lifecycle. It also needs a delay to begin the glow animations at the right
time.

Buff to Glow lifecycle matches spell details of the buff:

    New Buff      - Acquire and Init Glow
    Existing Buff - Match Active and Reparent Glow
    Missing Buff  - Release Glow

]]
NamePlatesComplete_AuraGlowDriverMixin = {}

function NamePlatesComplete_AuraGlowDriverMixin:OnLoad()
    self.glowPools = CreateFramePoolCollection()
    self.spellIDs = {
        [155722] = true, -- rake
        [1079] = true,   -- rip
        [405233] = true, -- thrash
        [155625] = true, -- moonfire
    }

    self:RegisterEvent("NAME_PLATE_UNIT_ADDED")
    self:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
    self:RegisterEvent("UNIT_AURA")
end

function NamePlatesComplete_AuraGlowDriverMixin:OnEvent(event, ...)
    if event == "UNIT_AURA" then
        local unit, unitAuraUpdateInfo = ...
        local namePlate = C_NamePlate.GetNamePlateForUnit(unit)
        if namePlate then
            -- TODO optimizaiton - could be duplicate for nameplate# / target / player
            self:UpdateBuffs(namePlate.UnitFrame.BuffFrame, namePlate.namePlateUnitToken, unitAuraUpdateInfo)
        end
    elseif event == "NAME_PLATE_UNIT_ADDED" then
        local unit = ...
        local namePlate = C_NamePlate.GetNamePlateForUnit(unit)
        if namePlate then
            self:UpdateBuffs(namePlate.UnitFrame.BuffFrame, namePlate.namePlateUnitToken)
        end
    elseif event == "NAME_PLATE_UNIT_REMOVED" then
        local unit = ...
        local pool = self.glowPools:GetPool("NamePlatesComplete_AuraGlowTemplate", unit)
        pool:ReleaseAll()
    end
end

function NamePlatesComplete_AuraGlowDriverMixin:UpdateBuffs(buffs, unit, unitAuraUpdateInfo, auraSettings)
    local pool = self.glowPools:GetOrCreatePool("Frame", nil, "NamePlatesComplete_AuraGlowTemplate",
        FramePool_HideAndClearAnchorsWithReset, false, unit)

    local function match(pool, buff)
        for glow in pool:EnumerateActive() do
            if glow:Match(buff) then
                return glow
            end
        end
    end

    -- mark all glows for removal
    for glow in pool:EnumerateActive() do
        glow:SetParent(nil)
    end

    -- reuse or init glows on layout changes
    for _, buff in ipairs({ buffs:GetChildren() }) do
        if buff:IsVisible() and self:ShouldGlow(buff) then
            local active = match(pool, buff)
            if active then
                active:Attach(buff)
            else
                active = pool:Acquire()
                active:Attach(buff)
                active:Init()
            end
        end
    end

    -- sweep to release unattached glows
    for glow in pool:EnumerateActive() do
        if not glow:GetParent() then
            pool:Release(glow)
        end
    end
end

function NamePlatesComplete_AuraGlowDriverMixin:ShouldGlow(buff)
    return buff.auraInstanceID and
        buff.spellID and
        self.spellIDs[buff.spellID]
end

local function toAuraTimes(start_ms, duration_ms)
    local expirationTime = (start_ms + duration_ms) / 1000.0
    local duration = duration_ms / 1000.0
    return expirationTime, duration
end

-- Aura is state/memoization from buff aura state
local Aura = {}

function Aura:Create(buff)
    local expirationTime, duration = toAuraTimes(buff.Cooldown:GetCooldownTimes())

    return Mixin({}, self, {
        auraInstanceID = buff.auraInstanceID,
        spellID = buff.spellID,
        expirationTime = expirationTime,
        duration = duration,
    })
end

function Aura:Equals(other)
    return tCompare(self, other)
end

function Aura:PandemicTime()
    return self.expirationTime - (self.duration * 0.30)
end

-- NamePlatesComplete_AuraGlowMixin is the UI for the glow
NamePlatesComplete_AuraGlowMixin = {}

function NamePlatesComplete_AuraGlowMixin:Match(buff)
    return self.state:Equals(Aura:Create(buff))
end

function NamePlatesComplete_AuraGlowMixin:Reset()
    self.state = nil

    if self.timer then
        self.timer:Cancel()
        self.timer = nil
    end

    if self.Flash:IsPlaying() then
        self.Flash:Stop()
    end

    if self.Glow:IsPlaying() then
        self.Glow:Stop()
    end
end

function NamePlatesComplete_AuraGlowMixin:Attach(buff)
    self.state = Aura:Create(buff)

    self:SetParent(buff)
    self:ClearAllPoints()
    self:SetAllPoints(buff)
    self:SetSize(buff:GetSize())
end

function NamePlatesComplete_AuraGlowMixin:Init()
    local pandemicDelay = self.state:PandemicTime() - GetTime()

    if pandemicDelay < 0 then
        self.Glow:Play()
        self:Show()
    else
        self.timer = C_Timer.NewTimer(pandemicDelay, function()
            self.Flash:Play()
            self.Glow:Play()
            self:Show()
        end)
    end
end

function NamePlatesComplete_AuraGlowMixin:OnShow()
    local w, h = self:GetSize()
    self.ProcLoopFlipBook:SetSize(w * 1.4, h * 1.4)
    self.ProcFlashFlipBook:SetSize(w * 3, h * 3)
end
