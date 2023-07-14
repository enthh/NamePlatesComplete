local _, ns = ...

-- Imports
local _G = _G
local PixelUtil = _G.PixelUtil
local DefaultCompactNamePlatePlayerFrameSetUpOptions = _G.DefaultCompactNamePlatePlayerFrameSetUpOptions

function ns.HookDefaultCompactNamePlateFrameAnchors(frame)
    if frame:IsForbidden() then
        return
    end

    -- BOTTOM is still achored to health top, so offset second anchor by the amount it scales the height
    PixelUtil.SetPoint(frame.name, "TOP", frame.castBar, "BOTTOM", 0,
        -frame.healthBar:GetHeight() - frame.castBar:GetHeight())

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

function ns:HookClassNameplateManaBar_OnSizeChanged()
    if self:IsForbidden() then
        return
    end

    PixelUtil.SetHeight(self, 1.5 * DefaultCompactNamePlatePlayerFrameSetUpOptions.healthBarHeight)
end

local NameplateUp_LayoutDriverMixin = {}

function NameplateUp_LayoutDriverMixin:OnLoad()
    hooksecurefunc("DefaultCompactNamePlateFrameAnchors", ns.HookDefaultCompactNamePlateFrameAnchors)
    hooksecurefunc(NamePlateDriverFrame, "SetupClassNameplateBars", ns.HookNameplateDriverFrame_SetupClassNameplateBars)
    hooksecurefunc(ClassNameplateManaBarFrame, "OnSizeChanged", ns.HookClassNameplateManaBar_OnSizeChanged)
end

function NameplateUp_LayoutDriverMixin:OnEvent(event, ...)
end

-- Exports
_G.NameplateUp_LayoutDriverMixin = NameplateUp_LayoutDriverMixin