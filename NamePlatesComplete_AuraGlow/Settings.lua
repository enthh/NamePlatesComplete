local addOn, priv = ...

local function Save(_, setting, value)
    local variable = setting:GetVariable()
    NamePlatesCompleteAuraGlowDB[variable] = value
    NamePlatesComplete_AuraGlowDriverFrame:Init(NamePlatesCompleteAuraGlowDB)
end

local function CreateSavedSetting(category, name, variable, default)
    local setting = Settings.RegisterAddOnSetting(category, name, variable, type(default), default)
    setting:SetValue(NamePlatesCompleteAuraGlowDB[variable])

    Settings.SetOnValueChangedCallback(variable, Save)

    if setting:GetValue() == nil then
        setting:SetValueToDefault()
    end

    return setting
end

local function Layout(category, spells)
    NamePlatesComplete.CreateSpellList(category, spells, "Add glow")
end

local function Register()
    local category = Settings.RegisterVerticalLayoutSubcategory(NamePlatesComplete.SettingsCategory, "Aura Glows")

    local spells = CreateSavedSetting(category, "Glow Spells", "glowSpellIDs",
        priv.defaultGlowSpellIDs[UnitClassBase("player")])

    local layout = GenerateClosure(Layout, category, spells)
    local reload = GenerateClosure(NamePlatesComplete.ReloadInitializers, category, layout)
    Settings.SetOnValueChangedCallback(spells:GetVariable(), reload)

    layout()

    Settings.RegisterAddOnCategory(category)
end

-- SettingsRegistrar:AddRegistrant(function() xpcall(Register, geterrorhandler()) end)
SettingsRegistrar:AddRegistrant(Register)
