local addOnName, priv = ...

local issecurevariable = _G["issecurevariable"]
local origPrefix, hookPrefix = "__np_orig_", "__np_hook_"

local NamePlatesComplete = {}

function NamePlatesComplete.IsHooked(tbl, name)
    return tbl[origPrefix .. name] ~= nil
end

function NamePlatesComplete.Hook(tbl, name, val, force)
    local isSecure, taintAddon = issecurevariable(tbl, name)
    if isSecure and not force then
        return false, "Cannot hook secure variables"
    end

    local origName = origPrefix .. name
    local hookName = hookPrefix .. name

    local orig = tbl[origName]
    local hook = tbl[hookName]

    if orig and hook ~= tbl[name] then
        return false, taintAddon .. " replaced"
    end

    tbl[origName] = tbl[name]
    tbl[hookName] = val
    tbl[name] = val

    return true
end

local NamePlatesCompleteDriverMixin = {}

function NamePlatesCompleteDriverMixin:OnLoad()
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("VARIABLES_LOADED")
end

function NamePlatesCompleteDriverMixin:OnEvent(event, ...)
    if event == "VARIABLES_LOADED" then
        -- priv.RegisterSettings()
    end
end

_G["NamePlatesComplete"] = NamePlatesComplete
_G["NamePlatesCompleteDriverMixin"] = NamePlatesCompleteDriverMixin
