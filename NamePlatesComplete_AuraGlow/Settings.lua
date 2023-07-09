local addOn, priv = ...

local function MigrateDB()
    if NamePlatesCompleteAuraGlowDB == nil then
        NamePlatesCompleteAuraGlowDB = { version = 1 }
    end
end

local function Reload()
    NamePlatesComplete_AuraGlowDriverFrame:Init(NamePlatesCompleteAuraGlowDB)
end

local function Layout(category, spells)
    NamePlatesComplete.CreateSpellList(category, spells, "Add glow")
end

local function Register()
    MigrateDB()

    local category = Settings.RegisterVerticalLayoutSubcategory(NamePlatesComplete.SettingsCategory, "Aura Glows")
    local spells = NamePlatesComplete.RegisterSavedSetting(category, NamePlatesCompleteAuraGlowDB, "Glow Spells",
        "glowSpellIDs", priv.defaultGlowSpellIDs[UnitClassBase("player")])

    NamePlatesComplete.LayoutSettings(category, Layout, spells)
    Settings.RegisterAddOnCategory(category)

    Settings.SetOnValueChangedCallback(spells:GetVariable(), Reload)
    Reload()
end

-- SettingsRegistrar:AddRegistrant(function() xpcall(Register, geterrorhandler()) end)
SettingsRegistrar:AddRegistrant(Register)
