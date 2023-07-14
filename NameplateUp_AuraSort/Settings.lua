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
    if NameplateUpAuraSortDB == nil then
        NameplateUpAuraSortDB = { version = 1 }
    end
end

local function Reload()
    ns:Init(NameplateUpAuraSortDB)
end

local function Layout(category, spells)
    NameplateUp.CreateSpellList(category, spells, "Aura Sort Order")
end

local function Register()
    MigrateDB()

    local category = Settings.RegisterVerticalLayoutSubcategory(NameplateUp.SettingsCategory, "Aura Sorting")
    local spells = NameplateUp.RegisterSavedSetting(category, NameplateUpAuraSortDB, "Sorted spells",
        "sortedSpellIDs", defaultAuraSort[UnitClassBase("player")])

    NameplateUp.LayoutSettings(category, Layout, spells)
    Settings.RegisterAddOnCategory(category)

    Settings.SetOnValueChangedCallback(spells:GetVariable(), Reload)
    Reload()
end

-- SettingsRegistrar:AddRegistrant(function() xpcall(Register, geterrorhandler()) end)
SettingsRegistrar:AddRegistrant(Register)
