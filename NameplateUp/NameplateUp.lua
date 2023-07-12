local addOnName, priv = ...

local NamePlatesComplete = {}

local NamePlatesCompleteDriverMixin = {}

function NamePlatesCompleteDriverMixin:OnLoad()
end

function NamePlatesCompleteDriverMixin:OnEvent(event, ...)
end

_G["NamePlatesComplete"] = NamePlatesComplete
_G["NamePlatesCompleteDriverMixin"] = NamePlatesCompleteDriverMixin
