local addOnName, priv = ...

local NameplateUp = {}

local NameplateUpDriverMixin = {}

function NameplateUpDriverMixin:OnLoad()
end

function NameplateUpDriverMixin:OnEvent(event, ...)
end

_G["NameplateUp"] = NameplateUp
_G["NameplateUpDriverMixin"] = NameplateUpDriverMixin
