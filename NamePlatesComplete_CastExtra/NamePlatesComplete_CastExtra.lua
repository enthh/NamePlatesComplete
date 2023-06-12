local function colorUnitClass(unit, text)
    local color = C_ClassColor.GetClassColor(UnitClassBase(unit)):GenerateHexColor()
    return "\124c" .. color .. text
end

NamePlatesComplete_CastExtraDriverMixin = {}

function NamePlatesComplete_CastExtraDriverMixin:OnLoad()
    self.pool = CreateFramePool("Frame", self,
        "NamePlatesComplete_CastExtraTemplate",
        FramePool_HideAndClearAnchorsWithReset)

    self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    self:RegisterEvent("NAME_PLATE_UNIT_ADDED")
    self:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
end

function NamePlatesComplete_CastExtraDriverMixin:OnEvent(event, ...)
    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        self:DispatchCombatLog(CombatLogGetCurrentEventInfo())
    elseif event == "NAME_PLATE_UNIT_ADDED" then
        self:OnNamePlateUnitAdded(select(1, ...))
    elseif event == "NAME_PLATE_UNIT_REMOVED" then
        self:OnNamePlateUnitRemoved(select(1, ...))
    elseif event == "PLAYER_ENTERING_WORLD" then
    end
end

function NamePlatesComplete_CastExtraDriverMixin:OnNamePlateUnitAdded(unit)
    local namePlate = C_NamePlate.GetNamePlateForUnit(unit)
    if not namePlate then
        return
    end

    local parent = namePlate.UnitFrame.castBar
    assert(parent, "CastExtra requires Blizzard Nameplates")

    local extra = self.pool:Acquire()
    extra:SetParent(parent)
    extra:Init(namePlate.namePlateUnitToken)
    extra:Show()
end

function NamePlatesComplete_CastExtraDriverMixin:OnNamePlateUnitRemoved(unit)
    local active = self:FindActive(unit)
    if active then
        self.pool:Release(active)
    end
end

function NamePlatesComplete_CastExtraDriverMixin:FindActive(unit)
    for active in self.pool:EnumerateActive() do
        if active:IsUnit(unit) then
            return active
        end
    end
end

function NamePlatesComplete_CastExtraDriverMixin:DispatchCombatLog(timestamp, subevent, hideCaster, sourceGUID,
                                                                   sourceName,
                                                                   sourceFlags, sourceRaidFlags, destGUID, destName,
                                                                   destFlags,
                                                                   destRaidFlags, ...)
    if subevent == "SPELL_INTERRUPT" then
        local interruptSpellID = ...
        self:DispatchSpellInterrupt(sourceGUID, destGUID, interruptSpellID)
    end
end

function NamePlatesComplete_CastExtraDriverMixin:DispatchSpellInterrupt(sourceGUID, destGUID, interruptSpellID)
    local destUnit = UnitTokenFromGUID(destGUID)
    if not destUnit then
        return
    end

    local sourceUnit = UnitTokenFromGUID(sourceGUID)
    if not sourceUnit or not UnitExists(sourceUnit) then
        return
    end

    local namePlate = C_NamePlate.GetNamePlateForUnit(destUnit)
    if not namePlate or namePlate:IsForbidden() then
        return
    end

    local active = self:FindActive(namePlate.namePlateUnitToken)
    if not active then
        return
    end

    active:OnSpellInterrupted(sourceUnit, interruptSpellID)
end

NamePlatesComplete_CastExtraMixin = {}

function NamePlatesComplete_CastExtraMixin:OnLoad()
    local allInterruptSpellIDs = {
        1766,   -- Rogue Kick
        47528,  -- Death Knight
        183752, -- Demon Hunter
        106839, -- Druid Skull Bash
        78675,  -- Druid Solar Beam
        187707, -- Hunter
        147362, -- Hunter
        116705, -- Monk
        96231,  -- Paladin
        31935,  -- Paladin Avenger's Shield
        304971, -- Paladin Kyrian
        57994,  -- Shaman
        6552,   -- Warrior
        90307,  -- Warrior Disrupting Shout
        2139,   -- Mage
        15487,  -- Priest
        119910, -- Warlock
        132409, -- Warlock Sacrificed Spell Lock
        212619, -- Warlock Felhunter PVP
        119914, -- Warlock Axe Toss
        351338, -- Evoker Quell
    }

    self.interruptIDs = {}
    for _, spellID in ipairs(allInterruptSpellIDs) do
        if IsSpellKnownOrOverridesKnown(spellID) then
            table.insert(self.interruptIDs, spellID)
        end
    end

    DevTool:AddData(self.interruptIDs, "known interrupts")
end

function NamePlatesComplete_CastExtraMixin:IsUnit(unit)
    return self.unit == unit
end

function NamePlatesComplete_CastExtraMixin:Init(unit)
    assert(self:GetParent() ~= nil, "Init CastExtra after parent is set")

    if self.unit ~= unit then
        self.unit = unit

        if unit then
            self:RegisterUnitEvent("UNIT_SPELLCAST_START", unit)
            self:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_START", unit)
            self:RegisterUnitEvent("UNIT_SPELLCAST_EMPOWER_START", unit)
            self:RegisterUnitEvent("UNIT_SPELLCAST_STOP", unit)
            self:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_STOP", unit)
            self:RegisterUnitEvent("UNIT_SPELLCAST_EMPOWER_STOP", unit)
            self:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_UPDATE", unit)
            self:RegisterUnitEvent("UNIT_SPELLCAST_EMPOWER_UPDATE", unit)
            self:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTIBLE", unit)

            self:RegisterEvent("PLAYER_TALENT_UPDATE")
            self:AdjustPosition()

            self:OnLoad()
        else
            self:UnregisterEvent("UNIT_SPELLCAST_START")
            self:UnregisterEvent("UNIT_SPELLCAST_CHANNEL_START")
            self:UnregisterEvent("UNIT_SPELLCAST_EMPOWER_START")
            self:UnregisterEvent("UNIT_SPELLCAST_STOP")
            self:UnregisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")
            self:UnregisterEvent("UNIT_SPELLCAST_EMPOWER_STOP")
            self:UnregisterEvent("UNIT_SPELLCAST_CHANNEL_UPDATE")
            self:UnregisterEvent("UNIT_SPELLCAST_EMPOWER_UPDATE")
            self:UnregisterEvent("UNIT_SPELLCAST_INTERRUPTIBLE")
            self:UnregisterEvent("UNIT_SPELLCAST_NOT_INTERRUPTIBLE")

            self:UnregisterEvent("PLAYER_TALENT_UPDATE")
        end
    end
end

function NamePlatesComplete_CastExtraMixin:Reset()
    self:SetUnit(nil)
end

function NamePlatesComplete_CastExtraMixin:OnEvent(event, ...)
    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        self:OnCombatLog(CombatLogGetCurrentEventInfo())
    elseif event == "UNIT_SPELLCAST_START" then
        self:OnSpellCastStart()
    elseif event == "UNIT_SPELLCAST_CHANNEL_START"
        or event == "UNIT_SPELLCAST_EMPOWER_START" then
        self:OnSpellChannelStart()
    elseif event == "UNIT_SPELLCAST_CHANNEL_UPDATE"
        or event == "UNIT_SPELLCAST_EMPOWER_UPDATE" then
        self:OnSpellChannelUpdate()
    elseif event == "UNIT_SPELLCAST_STOP"
        or event == "UNIT_SPELLCAST_CHANNEL_STOP"
        or event == "UNIT_SPELLCAST_EMPOWER_STOP" then
        self:OnSpellCastStop()
    elseif event == "UNIT_SPELLCAST_INTERRUPTIBLE"
        or event == "UNIT_SPELLCAST_NOT_INTERRUPTIBLE"
    then
        self:OnSpellCastInterruptible(event == "UNIT_SPELLCAST_INTERRUPTIBLE")
    elseif event == "PLAYER_TALENT_UPDATE" then
        self:OnLoad()
    end
end

function NamePlatesComplete_CastExtraMixin:OnSpellInterrupted(sourceUnit, interruptSpellID)
    local _, _, icon = GetSpellInfo(interruptSpellID)
    self.Text:SetFormattedText("|T%s:0|t %s", icon, colorUnitClass(sourceUnit, UnitName(sourceUnit)))
    self:Show()
end

function NamePlatesComplete_CastExtraMixin:OnSpellCastInterruptible(canInterrupt)
    assert(self.cast, "Unexpected interrupt after cast stop")
    self.cast.interruptible = canInterrupt
    self:Refresh()
end

function NamePlatesComplete_CastExtraMixin:OnSpellCastStart()
    self:Hide()

    local name, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible = UnitCastingInfo(self.unit)
    if not name or isTradeSkill then
        return
    end

    self.cast = {
        casting = true,
        channeling = false,
        startTime = startTime / 1000,
        endTime = endTime / 1000,
        interruptible = (not notInterruptible),
    }

    self:Refresh()
end

function NamePlatesComplete_CastExtraMixin:OnSpellChannelStart()
    self:Hide()

    local name, text, texture, startTime, endTime, isTradeSkill, notInterruptible, spellID, _, numStages =
        UnitChannelInfo(self.unit)
    if not name or isTradeSkill then
        return
    end

    self.cast = {
        casting = false,
        channeling = true,
        startTime = startTime / 1000,
        endTime = endTime / 1000,
        interruptible = (not notInterruptible),
    }

    self:Refresh()
end

function NamePlatesComplete_CastExtraMixin:OnSpellChannelUpdate()
    self:Hide()

    local name, text, texture, startTime, endTime, isTradeSkill, notInterruptible, spellID, _, numStages =
        UnitChannelInfo(self.unit)
    if not name or isTradeSkill then
        return
    end

    self.cast = {
        casting = false,
        channeling = true,
        startTime = startTime / 1000,
        endTime = endTime / 1000,
        interruptible = (not notInterruptible),
    }

    self:Refresh()
end

function NamePlatesComplete_CastExtraMixin:OnSpellCastStop()
    self.cast = nil

    self.InterruptGlow:Hide()
end

function NamePlatesComplete_CastExtraMixin:Refresh()
    self:UpdateInterruptible()
    self:UpdateSpellCastTarget()
end

function NamePlatesComplete_CastExtraMixin:UpdateInterruptible()
    if not self.cast then
        return
    end

    self.InterruptGlow:Hide()

    if self.cast.interruptible and #self.interruptIDs > 0 then
        local interruptReady = false
        local interruptReadyTime = self.cast.endTime

        for _, interruptID in ipairs(self.interruptIDs) do
            local startTime, duration = GetSpellCooldown(interruptID)
            interruptReady = interruptReady or (duration == 0)
            interruptReadyTime = math.min(interruptReadyTime, startTime + duration)
        end

        if not interruptReady then
            local parent = self:GetParent()
            local dw = (interruptReadyTime - self.cast.startTime) / (self.cast.endTime - self.cast.startTime)
            local dx = parent:GetWidth() - (parent:GetWidth() * dw)

            self.InterruptGlow:ClearAllPoints()
            self.InterruptGlow:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0)
            self.InterruptGlow:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -dx, 0)
            self.InterruptGlow:Show()
        end
    end
end

function NamePlatesComplete_CastExtraMixin:UpdateSpellCastTarget()
    local target = self.unit .. "target"
    if not UnitExists(target) then
        return ""
    end

    local name = UnitName(target)
    if not name then
        return ""
    end

    local text = ""

    local role = UnitGroupRolesAssigned(target)
    if role == "TANK" then
        text = text .. "|A:roleicon-tiny-tank:0|a"
    elseif role == "HEALER" then
        text = text .. "|A:roleicon-tiny-healer:0|a"
    elseif role == "DAMAGER" then
        text = text .. "|A:roleicon-tiny-dps:0|a"
    end

    local class = UnitClassBase(target)
    if class then
        text = text .. "|c" .. C_ClassColor.GetClassColor(class):GenerateHexColor() .. name .. "|r"
    else
        text = text .. name
    end

    self.Text:SetText(text)
    self:Show()
end

function NamePlatesComplete_CastExtraMixin:AdjustPosition()
    local parent = self:GetParent()
    self:ClearAllPoints()

    self:SetPoint("TOPLEFT", parent, "BOTTOMLEFT", 0, 0)
    self:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", 0, -12)
    self:SetFrameLevel(parent:GetFrameLevel())
end

function NamePlatesComplete_CastExtraMixin:OnHide()
    self.Text:SetText("")
end
