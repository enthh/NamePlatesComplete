local _, ns = ...

local defaultGlowSpellIDs = {
    DEATHKNIGHT = {
        55078, -- Blood Plague
    },
    DRUID = {
        155722, -- Rake
        1079,   -- Rip
        405233, -- Thrash Feral
        192090, -- Thrash
        155625, -- Moonfire Feral
        164812, -- Moonfire
        164815, -- Sunfire
        202347, -- Stellar flare
        5217,   -- Tiger's fury (player nameplate)
    },
    EVOKER = {
        357209, -- Fire Breath
    },
    HUNTER = {
        271788, -- Serpent Sting
    },
    MAGE = {
        114923, -- Nether Tempest
    },
    PRIEST = {
        34914,  -- Vampric Touch
        589,    -- Shadow Word: Pain
        335467, -- Devouring Plague
    }
}


local function MigrateDB()
    if NameplateUp_AuraGlowDB == nil then
        NameplateUp_AuraGlowDB = { version = 1 }
    end
end

local function Reload()
    ns:Init(NameplateUp_AuraGlowDB)
end

local function Layout(category, spells)
    NameplateUp.CreateSpellList(category, spells, "Add glow")
end

local function Register()
    MigrateDB()

    local category = Settings.RegisterVerticalLayoutSubcategory(NameplateUp.SettingsCategory, "Aura Glows")
    local spells = NameplateUp.RegisterSavedSetting(category, NameplateUp_AuraGlowDB, "Glow Spells",
        "glowSpellIDs", defaultGlowSpellIDs[UnitClassBase("player")])

    NameplateUp.LayoutSettings(category, Layout, spells)
    Settings.RegisterAddOnCategory(category)

    Settings.SetOnValueChangedCallback(spells:GetVariable(), Reload)
    Reload()
end

-- SettingsRegistrar:AddRegistrant(function() xpcall(Register, geterrorhandler()) end)
SettingsRegistrar:AddRegistrant(Register)
