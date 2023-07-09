local addOn, priv = ...

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

priv.defaultGlowSpellIDs = {
    DEATHKNIGHT = {
        55078, -- Blood Plague
    },
    DRUID = {
        155722, -- Rake
        1079,   -- Rip
        405233, -- Thrash Feral
        192090, -- Thrash
        155625, -- Moonfire Feral
        164812, -- Moonfire
        164815, -- Sunfire
        202347, -- Stellar flare
        5217,   -- Tiger's fury (player nameplate)
    },
    EVOKER = {
        357209, -- Fire Breath
    },
    HUNTER = {
        271788, -- Serpent Sting
    },
    MAGE = {
        114923, -- Nether Tempest
    },
    PRIEST = {
        34914,  -- Vampric Touch
        589,    -- Shadow Word: Pain
        335467, -- Devouring Plague
    }
}

NamePlatesComplete_AuraGlowDriverMixin = {}

function NamePlatesComplete_AuraGlowDriverMixin:OnLoad()
    self.spellIDs = {}

    self.pool = CreateFramePool("Frame", self, "NamePlatesComplete_AuraGlowTemplate", function(pool, frame)
        frame:SetParent(self)
        frame:Hide()
        frame:ClearAllPoints()
        frame:Reset()
    end)

    self:RegisterEvent("ADDON_LOADED")
    self:RegisterEvent("NAME_PLATE_UNIT_ADDED")
    self:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
    self:RegisterEvent("UNIT_AURA")
end

function NamePlatesComplete_AuraGlowDriverMixin:InitDB(force)
    if NamePlatesCompleteAuraGlowDB == nil then
        NamePlatesCompleteAuraGlowDB = {
            version = 1,
        }
    end

    if force or (NamePlatesCompleteAuraGlowDB.glowSpellIDs == nil) then
        NamePlatesCompleteAuraGlowDB.glowSpellIDs = priv.defaultGlowSpellIDs[UnitClassBase("player")] or {}
    end
end

function NamePlatesComplete_AuraGlowDriverMixin:Init(options)
    self.spellIDs = {}
    for i, spellID in ipairs(options.glowSpellIDs) do
        self.spellIDs[spellID] = true
    end
end

function NamePlatesComplete_AuraGlowDriverMixin:OnEvent(event, ...)
    if event == "ADDON_LOADED" and select(1, ...) == addOn then
        self:InitDB()
        self:Init(NamePlatesCompleteAuraGlowDB)
    else
        local unit = ...
        local namePlate = C_NamePlate.GetNamePlateForUnit(unit)
        if not namePlate then
            return
        end

        if event == "NAME_PLATE_UNIT_ADDED" then
            self:ResetGlows(namePlate)
            self:UpdateGlows(namePlate)
        elseif event == "NAME_PLATE_UNIT_REMOVED" then
            self:ResetGlows(namePlate)
        elseif event == "UNIT_AURA" then
            self:UpdateGlows(namePlate)
        end
    end
end

function NamePlatesComplete_AuraGlowDriverMixin:ResetGlows(namePlate, glows)
    for _, glow in pairs(namePlate.glows or {}) do
        self.pool:Release(glow)
    end

    namePlate.glows = glows or {}
end

function NamePlatesComplete_AuraGlowDriverMixin:UpdateGlows(namePlate)
    local buffs = { namePlate.UnitFrame.BuffFrame:GetChildren() }
    local currGlows = namePlate.glows
    local nextGlows = {}

    for _, buff in ipairs(buffs) do
        if buff:IsVisible() and self:ShouldGlow(buff) then
            local id = buff.auraInstanceID

            local active = currGlows[id]
            if active and active:Match(buff) then -- keep
                currGlows[id] = nil
                active:Attach(buff)
            else -- create/replace
                active = self.pool:Acquire()
                active:Attach(buff)
                active:Init()
            end
            nextGlows[id] = active
        end
    end

    self:ResetGlows(namePlate, nextGlows)
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
    return self.auraInstanceID == other.auraInstanceID
        and self.expirationTime == other.expirationTime
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

    self.ProcFlashFlipBook:SetAlpha(0)
    self.ProcLoopFlipBook:SetAlpha(0)
end

function NamePlatesComplete_AuraGlowMixin:Attach(buff)
    self.state = Aura:Create(buff)

    self:SetParent(buff)
    self:ClearAllPoints()
    self:SetAllPoints(buff)
    self:SetSize(buff:GetSize())
    self:Show()
end

function NamePlatesComplete_AuraGlowMixin:Init()
    local pandemicDelay = self.state:PandemicTime() - GetTime()

    if pandemicDelay < 0 then
        self:Show()
        self.Glow:Play()
    else
        self.timer = C_Timer.NewTimer(pandemicDelay, function()
            if self:GetParent():IsVisible() then
                self:Show()
                self.Flash:Play()
                self.Glow:Play()
            end
        end)
    end
end

function NamePlatesComplete_AuraGlowMixin:OnShow()
    local w, h = self:GetSize()
    self.ProcLoopFlipBook:SetSize(w * 1.4, h * 1.4)
    self.ProcFlashFlipBook:SetSize(w * 4, h * 4)
end
