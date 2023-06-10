NamePlatesComplete_AuraGlowDriverMixin = {}

function NamePlatesComplete_AuraGlowDriverMixin:OnLoad()
    self.glowPools = CreateFramePoolCollection()

    hooksecurefunc(NamePlateDriverFrame, "OnNamePlateCreated", function(_, nameplateBase)
        hooksecurefunc(nameplateBase, "OnOptionsUpdated", function(namePlate)
            hooksecurefunc(namePlate.UnitFrame.BuffFrame, "UpdateBuffs", function(...)
                self:OnUpdateBuffs(...)
            end)
        end)
    end)
end

function NamePlatesComplete_AuraGlowDriverMixin:OnUpdateBuffs(buffs, unit, unitAuraUpdateInfo, auraSettings)
    local children = 0
    for _, c in ipairs({ buffs:GetChildren() }) do
        if c:IsVisible() then
            children = children + 1
        end
    end

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
        glow:Detatch()
    end

    -- attach to reuse or init glows to prevent removal
    for _, buff in ipairs({ buffs:GetChildren() }) do
        if buff:IsVisible() and self:ShouldGlow(buff) then
            local active = match(pool, buff)
            if active then -- move running pandemic glow to new buff frame
                active:Attach(buff)
            else           -- start new glow on buff frame
                active = pool:Acquire()
                active:Attach(buff)
                active:Init()
            end
        end
    end

    -- sweep active glows on inactive or unmatched buff frames
    for glow in pool:EnumerateActive() do
        if not glow:IsAttached() then
            pool:Release(glow)
        end
    end
end

function NamePlatesComplete_AuraGlowDriverMixin:ShouldGlow(buff)
    return buff.auraInstanceID and (
        buff.spellID == 155722 or
        buff.spellID == 1079
    )
end

local function toAuraTimes(start_ms, duration_ms)
    local expirationTime = (start_ms + duration_ms) / 1000.0
    local duration = duration_ms / 1000.0
    return expirationTime, duration
end

NamePlatesComplete_AuraGlowMixin = {}

function NamePlatesComplete_AuraGlowMixin:Match(buff)
    local expirationTime, duration = toAuraTimes(buff.Cooldown:GetCooldownTimes())

    local match = self.auraInstanceID == buff.auraInstanceID and
        self.expirationTime == expirationTime and
        self.duration == duration

    return match
end

function NamePlatesComplete_AuraGlowMixin:Reset()
    self.auraInstanceID = nil
    self.spellID = nil
    self.expirationTime = nil
    self.duration = nil

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

function NamePlatesComplete_AuraGlowMixin:PlayXXX()
    self:Show()
    self.Flash:Play()
    self.Glow:Play()
end

function NamePlatesComplete_AuraGlowMixin:Attach(buff)
    local expirationTime, duration = toAuraTimes(buff.Cooldown:GetCooldownTimes())

    self.auraInstanceID = buff.auraInstanceID
    self.spellID = buff.spellID
    self.expirationTime = expirationTime
    self.duration = duration

    self:SetParent(buff)
    self:ClearAllPoints()
    self:SetAllPoints(buff)
    self:SetSize(buff:GetSize())
end

function NamePlatesComplete_AuraGlowMixin:IsAttached()
    return self:GetParent()
end

function NamePlatesComplete_AuraGlowMixin:Detatch()
    return self:SetParent(nil)
end

function NamePlatesComplete_AuraGlowMixin:Init()
    local pandemicTime = self.expirationTime - (self.duration * 0.30)
    local pandemicDelay = pandemicTime - GetTime()

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
