local _, ns = ...

local defaultAuraSort = {
    DRUID = {
        164812, -- Moonfire
        164815, -- Sunfire
        
        202347, -- Stellar flare

        155722, -- Rake
        1079,   -- Rip
        192090, -- Thrash
        405233, -- Thrash Feral
        155625, -- Moonfire Feral

        391880, -- Adaptive Swarm
    }
}

local function MigrateDB()
    if NamePlatesCompleteAuraSortDB == nil then
        NamePlatesCompleteAuraSortDB = { version = 1 }
    end
end

local function Reload()
    ns.driver:Init(NamePlatesCompleteAuraSortDB)
end

local function Layout(category, spells)
    NamePlatesComplete.CreateSpellList(category, spells, "Aura Sort Order")
end

local function Register()
    MigrateDB()

    local category = Settings.RegisterVerticalLayoutSubcategory(NamePlatesComplete.SettingsCategory, "Aura Sorting")
    local spells = NamePlatesComplete.RegisterSavedSetting(category, NamePlatesCompleteAuraSortDB, "Sorted spells",
        "sortedSpellIDs", defaultAuraSort[UnitClassBase("player")])

    NamePlatesComplete.LayoutSettings(category, Layout, spells)
    Settings.RegisterAddOnCategory(category)

    Settings.SetOnValueChangedCallback(spells:GetVariable(), Reload)
    Reload()
end

-- SettingsRegistrar:AddRegistrant(function() xpcall(Register, geterrorhandler()) end)
SettingsRegistrar:AddRegistrant(Register)
