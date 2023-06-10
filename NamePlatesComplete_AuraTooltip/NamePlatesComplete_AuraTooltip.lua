NamePlatesComplete_AuraTooltipDriverMixin = {}

function NamePlatesComplete_AuraTooltipDriverMixin:OnLoad()
    hooksecurefunc(NamePlateDriverFrame, "OnNamePlateCreated", function(_, nameplateBase)
        hooksecurefunc(nameplateBase, "OnOptionsUpdated", function(namePlate)
            hooksecurefunc(namePlate.UnitFrame.BuffFrame, "UpdateBuffs", function(...)
                self:OnUpdateBuffs(...)
            end)
        end)
    end)
end

function NamePlatesComplete_AuraTooltipDriverMixin:OnUpdateBuffs(buffFrame, ...)
    for _, buff in ipairs({ buffFrame:GetChildren() }) do
        if buff:IsMouseEnabled() then
            buff:EnableMouse(false)
        end
    end
end
