local _, ns = ...

-- Imports
local CreateFrame = _G["CreateFrame"]
local GetTime = _G["GetTime"]
local CreateAndInitFromMixin = _G["CreateAndInitFromMixin"]
local UnitClassBase = _G["UnitClassBase"]
local UnitName = _G["UnitName"]
local UnitIsUnit = _G["UnitIsUnit"]
local UnitGUID = _G["UnitGUID"]
local UnitGroupRolesAssigned = _G["UnitGroupRolesAssigned"]
local CombatLogGetCurrentEventInfo = _G["CombatLogGetCurrentEventInfo"]
local UnitCastingInfo = _G["UnitCastingInfo"]
local UnitChannelInfo = _G["UnitChannelInfo"]
local UnitTokenFromGUID = _G["UnitTokenFromGUID"]
local GetSpellCooldown = _G["GetSpellCooldown"]
local ClampedPercentageBetween = _G["ClampedPercentageBetween"]
local Mixin = _G["Mixin"]
local IsSpellKnownOrOverridesKnown = _G["IsSpellKnownOrOverridesKnown"]
local CreateAtlasMarkup = _G["CreateAtlasMarkup"]

local GRAY_FONT_COLOR = _G["GRAY_FONT_COLOR"]

local C_ClassColor = _G["C_ClassColor"]
local C_Timer = _G["C_Timer"]
local C_NamePlate = _G["C_NamePlate"]

local LAG_TOLERANCE_SECONDS = 0.3
local UPDATE_INTERVAL_SECONDS = 0.07

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

local roleMarkup = {
    TANK = CreateAtlasMarkup("roleicon-tiny-tank"),
    DAMAGER = CreateAtlasMarkup("roleicon-tiny-dps"),
    HEALER = CreateAtlasMarkup("roleicon-tiny-healer"),
    NONE = "",
}

function ns.HookDefaultCompactNamePlateFrameAnchors(frame)
    if frame:IsForbidden() then
        return
    end

    -- BOTTOM is still achored to health top, so offset second anchor by the amount it scales the height
    PixelUtil.SetPoint(frame.name, "TOP", frame.castBar, "BOTTOM", 0, -frame.healthBar:GetHeight() - frame.castBar:GetHeight())

    frame.BuffFrame:ClearAllPoints()
    PixelUtil.SetPoint(frame.BuffFrame, "BOTTOMLEFT", frame.healthBar, "TOPLEFT", 0, 3)
end

function ns:HookNameplateDriverFrame_SetupClassNameplateBars()
    local classBar = self:GetClassNameplateBar()
    if classBar == nil or classBar:IsForbidden() then
        return
    end

    local targetNameplate = C_NamePlate.GetNamePlateForUnit("target")
    if targetNameplate == nil or targetNameplate:IsForbidden() then
        return
    end

    local castBar = targetNameplate.UnitFrame.castBar
    if classBar:IsShown() and classBar:GetParent() == targetNameplate then
        classBar:ClearAllPoints()
        PixelUtil.SetPoint(classBar, "TOP", castBar, "BOTTOM", 0, -3)
    end
end

local NameplateUp_CastExtraDriverMixin = {}

function NameplateUp_CastExtraDriverMixin:OnLoad()
    self:RegisterEvent("NAME_PLATE_UNIT_ADDED")
    self:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
    self:RegisterEvent("PLAYER_ENTERING_WORLD")

    hooksecurefunc("DefaultCompactNamePlateFrameAnchors", ns.HookDefaultCompactNamePlateFrameAnchors)
    hooksecurefunc(NamePlateDriverFrame, "SetupClassNameplateBars", ns.HookNameplateDriverFrame_SetupClassNameplateBars)
end

function NameplateUp_CastExtraDriverMixin:OnEvent(event, ...)
    if event == "NAME_PLATE_UNIT_ADDED" then
        self:OnNamePlateUnitAdded(select(1, ...))
    elseif event == "NAME_PLATE_UNIT_REMOVED" then
        self:OnNamePlateUnitRemoved(select(1, ...))
    elseif event == "PLAYER_ENTERING_WORLD" then
    end
end

function NameplateUp_CastExtraDriverMixin:OnNamePlateUnitAdded(unit)
    local namePlate = C_NamePlate.GetNamePlateForUnit(unit)
    if not namePlate or not namePlate.namePlateUnitToken then
        return
    end

    if not namePlate.castExtra then
        namePlate.castExtra = CreateFrame("Frame", nil, namePlate, "NameplateUp_CastExtraTemplate")
    end

    namePlate.castExtra:Reset()
    namePlate.castExtra:Init(namePlate.namePlateUnitToken, namePlate)
end

function NameplateUp_CastExtraDriverMixin:OnNamePlateUnitRemoved(unit)
    local namePlate = C_NamePlate.GetNamePlateForUnit(unit)
    if not namePlate then
        return
    end

    local castExtra = namePlate.UnitFrame and namePlate.UnitFrame.castBar and namePlate.UnitFrame.castBar.castExtra
    if castExtra then
        castExtra:Reset()
    end
end

local NamePlateUI = {
    Blizzard = {},
}

local function UnitText(name, class, role)
    local text = role and roleMarkup[role] or ""
    local color = class and C_ClassColor.GetClassColor(class) or GRAY_FONT_COLOR
    return text .. color:WrapTextInColorCode(name)
end

function NamePlateUI.Blizzard:Init(namePlate, extra)
    local castBar = namePlate.UnitFrame.castBar
    extra:SetParent(castBar)
    extra:ClearAllPoints()

    extra:SetPoint("TOPLEFT", castBar, "BOTTOMLEFT", 0, 0)
    extra:SetPoint("BOTTOMRIGHT", castBar, "BOTTOMRIGHT", 0, 0)
    extra:SetFrameLevel(castBar:GetFrameLevel())

    extra.Text:SetFont(castBar.Text:GetFont())
end

function NamePlateUI.Blizzard:Update(namePlate, extra, state)
    if not namePlate.UnitFrame then
        return
    end

    local castBar = namePlate.UnitFrame.castBar

    extra.Text:Hide()
    extra.InterruptSpark:Hide()

    if state.casting or state.channeling then
        local castTime = state.startTime + castBar:GetValue()
        if state.interruptible and state.canInterruptTime > castTime then
            if state.canInterruptTime >= state.endTime then
                castBar:SetStatusBarTexture(castBar:GetTypeInfo("uninterruptable").filling)
                castBar:SetHeight(20)
            else
                castBar:SetStatusBarTexture(castBar:GetTypeInfo("applyingcrafting")
                    .filling)

                local scale = ClampedPercentageBetween(state.canInterruptTime, state.startTime, state.endTime)
                local cx = castBar:GetWidth() * scale

                extra.InterruptSpark:ClearAllPoints()
                extra.InterruptSpark:SetPoint("LEFT", castBar, "LEFT", cx, 0)
                extra.InterruptSpark:Show()
            end
        else
            castBar:SetHeight(10)
            castBar:SetStatusBarTexture(castBar:GetTypeInfo(castBar.barType).filling)
            extra.InterruptSpark:Hide()
        end

        if state.targetName then
            extra.Text:SetText(UnitText(state.targetName, state.targetClass, state.targetRole))
            extra.Text:Show()
        end
    elseif state.interruptSourceName then
        extra.Text:SetText(string.format("[%s]", UnitText(state.interruptSourceName, state.interruptSourceClass)))
        extra.Text:Show()
    end
end

local function CreateAdapter(namePlate, extra)
    if namePlate.UnitFrame ~= nil then
        return CreateAndInitFromMixin(NamePlateUI.Blizzard, namePlate, extra)
    end
end

local function CastState(unit)
    local state = {
        unit = unit,
        targetUnit = unit .. "target",
    }

    local name, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible, spellID = UnitCastingInfo(
        unit)

    if not name then
        name, text, texture, startTime, endTime, isTradeSkill, notInterruptible, spellID = UnitChannelInfo(unit)
    end

    if name then
        Mixin(state, {
            name = name,
            text = text,
            casting = (castID ~= nil),
            channeling = (spellID ~= nil),
            startTime = startTime / 1000,
            endTime = endTime / 1000,
            interruptible = (not notInterruptible),
            isTradeSkill = isTradeSkill,
        })
    end

    return state
end

local NameplateUp_CastExtraMixin = {}

function NameplateUp_CastExtraMixin:OnLoad()
    self.interruptIDs = {}
    for _, spellID in ipairs(allInterruptSpellIDs) do
        if IsSpellKnownOrOverridesKnown(spellID) then
            table.insert(self.interruptIDs, spellID)
        end
    end
end

function NameplateUp_CastExtraMixin:Init(unit, namePlate)
    assert(self.unit == nil, "CastExtra Init without Reset - dirty reuse")

    self.namePlate = namePlate
    self.view = CreateAdapter(namePlate, self)

    self.unit = unit
    self.unitGUID = UnitGUID(unit)
    self.state = CastState(unit)
    self.timers = {}

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

    self:OnLoad()
end

function NameplateUp_CastExtraMixin:Reset()
    for _, timer in pairs(self.timers or {}) do
        timer:Cancel()
    end

    self.namePlate = nil
    self.view = nil

    self.unit = nil
    self.unitGUID = nil
    self.timers = {}
    self.state = {}

    self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
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

    self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    self:UnregisterEvent("PLAYER_TALENT_UPDATE")
end

function NameplateUp_CastExtraMixin:OnEvent(event, ...)
    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        self:OnCombatLog(CombatLogGetCurrentEventInfo())
    elseif event == "UNIT_SPELLCAST_START"
        or event == "UNIT_SPELLCAST_CHANNEL_START"
        or event == "UNIT_SPELLCAST_EMPOWER_START" then
        self:OnStart()
    elseif event == "UNIT_SPELLCAST_CHANNEL_UPDATE"
        or event == "UNIT_SPELLCAST_EMPOWER_UPDATE" then
        self:OnSpellUpdate()
    elseif event == "UNIT_SPELLCAST_STOP"
        or event == "UNIT_SPELLCAST_CHANNEL_STOP"
        or event == "UNIT_SPELLCAST_EMPOWER_STOP" then
        self:OnStop()
    elseif event == "UNIT_SPELLCAST_INTERRUPTIBLE"
        or event == "UNIT_SPELLCAST_NOT_INTERRUPTIBLE"
    then
        self:OnSpellCastInterruptible(event == "UNIT_SPELLCAST_INTERRUPTIBLE")
    elseif event == "PLAYER_TALENT_UPDATE" then
        self:OnLoad()
    end
end

function NameplateUp_CastExtraMixin:OnCombatLog(timestamp, subevent, hideCaster,
                                                       sourceGUID, sourceName, sourceFlags, sourceRaidFlags,
                                                       destGUID, destName, destFlags, destRaidFlags, ...)
    if subevent == "SPELL_INTERRUPT" then
        local sourceUnit = UnitTokenFromGUID(sourceGUID)
        if sourceUnit == nil then
            return
        end

        self.state.interruptSourceUnit = sourceUnit
        self.state.interruptSourceName = sourceName
        self.state.interruptSourceGUID = sourceGUID
        self.state.interruptSourceClass = UnitClassBase(sourceUnit)

        self:OnUpdate()
    end
end

function NameplateUp_CastExtraMixin:OnSpellCastInterruptible(canInterrupt)
    self.state.interruptible = canInterrupt
    self:OnUpdate()
end

function NameplateUp_CastExtraMixin:OnSpellUpdate()
    Mixin(self.state, CastState(self.unit))
    self:OnUpdate()
end

function NameplateUp_CastExtraMixin:OnStart()
    self.state = CastState(self.unit)

    self:ReplaceTimer("COMBAT_LOG_EVENT_UNFILTERED")
    self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

    self:ReplaceTimer("casting", C_Timer.NewTicker(UPDATE_INTERVAL_SECONDS, function()
        self:OnUpdate()
    end))
    self:OnUpdate()
end

function NameplateUp_CastExtraMixin:ReplaceTimer(name, timer)
    local old = self.timers[name]
    if old then
        old:Cancel()
    end

    self.timers[name] = timer
end

function NameplateUp_CastExtraMixin:OnStop()
    self.state.casting = false
    self.state.channeling = false
    self.state.interruptible = false

    -- Wait for interrupt combat logs
    self:ReplaceTimer("COMBAT_LOG_EVENT_UNFILTERED", C_Timer.NewTimer(LAG_TOLERANCE_SECONDS, function()
        self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    end))
    self:ReplaceTimer("casting")

    self:OnUpdate()
end

function NameplateUp_CastExtraMixin:OnUpdate()
    if not self.state.name or self.state.isTradeSkill then
        return
    end

    self:UpdateTarget()
    self:UpdateInterruptible()

    self.view:Update(self.namePlate, self, self.state)
end

function NameplateUp_CastExtraMixin:UpdateInterruptible()
    if self.state.interruptible and #self.interruptIDs > 0 then
        local earliest = self.state.endTime
        for _, interruptID in ipairs(self.interruptIDs) do
            local startTime, duration = GetSpellCooldown(interruptID)
            earliest = math.min(earliest, startTime + duration)
        end

        self.state.canInterruptTime = earliest
    else
        self.state.canInterruptTime = self.state.startTime
    end
end

function NameplateUp_CastExtraMixin:UpdateTarget()
    self.state.targetName = UnitName(self.state.targetUnit)
    self.state.targetClass = UnitClassBase(self.state.targetUnit)
    self.state.targetRole = UnitGroupRolesAssigned(self.state.targetUnit)
end

-- Exports
_G["NameplateUp_CastExtraDriverMixin"] = NameplateUp_CastExtraDriverMixin
_G["NameplateUp_CastExtraMixin"] = NameplateUp_CastExtraMixin
