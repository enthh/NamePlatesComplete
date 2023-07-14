local _, ns = ...

local _G = _G
local GetNumClasses = _G.GetNumClasses
local GetClassInfo = _G.GetClassInfo

ns.Class = {}

for classID = 1, GetNumClasses() do
    local name, file, id = GetClassInfo(classID)
    ns.Class[file] = {
        name = name,
        file = file,
        id = id,
    }
end

ns.CC = {
    [5246] = ns.Class.WARRIOR,       --  Intimidating Shout
    [132168] = ns.Class.WARRIOR,     --  Shockwave
    [6552] = ns.Class.WARRIOR,       --  Pummel
    [132169] = ns.Class.WARRIOR,     --  Storm Bolt

    [118699] = ns.Class.WARLOCK,     --  Fear
    [6789] = ns.Class.WARLOCK,       --  Mortal Coil
    [19647] = ns.Class.WARLOCK,      --  Spelllock
    [30283] = ns.Class.WARLOCK,      --  Shadowfury
    [710] = ns.Class.WARLOCK,        --  Banish
    [212619] = ns.Class.WARLOCK,     --  Call Fellhunt
    [5484] = ns.Class.WARLOCK,       --  Howl of Terror

    [118] = ns.Class.MAGE,           --  Polymorph
    [61305] = ns.Class.MAGE,         --  Polymorph (black cat)
    [28271] = ns.Class.MAGE,         --  Polymorph Turtle
    [161354] = ns.Class.MAGE,        --  Polymorph Monkey
    [161353] = ns.Class.MAGE,        --  Polymorph Polar Bear Cub
    [126819] = ns.Class.MAGE,        --  Polymorph Porcupine
    [277787] = ns.Class.MAGE,        --  Polymorph Direhorn
    [61721] = ns.Class.MAGE,         --  Polymorph Rabbit
    [28272] = ns.Class.MAGE,         --  Polymorph Pig
    [277792] = ns.Class.MAGE,        --  Polymorph Bumblebee
    [391622] = ns.Class.MAGE,        --  Polymorph Duck
    [2139] = ns.Class.MAGE,          --  Counterspell

    [82691] = ns.Class.MAGE,         --  Ring of Frost
    [122] = ns.Class.MAGE,           --  Frost Nova
    [157997] = ns.Class.MAGE,        --  Ice Nova
    [31661] = ns.Class.MAGE,         --  Dragon's Breath
    [157981] = ns.Class.MAGE,        --  Blast Wave

    [205364] = ns.Class.PRIEST,      --  Mind Control
    [605] = ns.Class.PRIEST,         --  Mind Control
    [8122] = ns.Class.PRIEST,        --  Psychic Scream
    [9484] = ns.Class.PRIEST,        --  Shackle Undead
    [200196] = ns.Class.PRIEST,      --  Holy Word: Chastise
    [200200] = ns.Class.PRIEST,      --  Holy Word: Chastise
    [226943] = ns.Class.PRIEST,      --  Mind Bomb
    [64044] = ns.Class.PRIEST,       --  Psychic Horror
    [15487] = ns.Class.PRIEST,       --  Silence

    [2094] = ns.Class.ROGUE,         --  Blind
    [1833] = ns.Class.ROGUE,         --  Cheap Shot
    [408] = ns.Class.ROGUE,          --  Kidney Shot
    [1766] = ns.Class.ROGUE,         --  Kick
    [6770] = ns.Class.ROGUE,         --  Sap
    [1776] = ns.Class.ROGUE,         --  Gouge

    [853] = ns.Class.PALADIN,        --  Hammer of Justice
    [96231] = ns.Class.PALADIN,      --  Rebuke (tank)
    [20066] = ns.Class.PALADIN,      --  Repentance
    [105421] = ns.Class.PALADIN,     --  Blinding Light
    [31935] = ns.Class.PALADIN,      --  Avengers Shield
    [217824] = ns.Class.PALADIN,     --  Shield of Virtue
    [10326] = ns.Class.PALADIN,      --  Turn Evil

    [221562] = ns.Class.DEATHKNIGHT, --  Asphyxiate
    [108194] = ns.Class.DEATHKNIGHT, --  Asphyxiate
    [47528] = ns.Class.DEATHKNIGHT,  --  Mind Frezer
    [91807] = ns.Class.DEATHKNIGHT,  --  Shab Rush
    [207167] = ns.Class.DEATHKNIGHT, --  Blinding Sleet
    [334693] = ns.Class.DEAHTKNIGHT, --  Absolute Zero (legendary)

    [339] = ns.Class.DRUID,          --  Entangling Roots
    [2637] = ns.Class.DRUID,         --  Hibernate
    [61391] = ns.Class.DRUID,        --  Typhoon
    [102359] = ns.Class.DRUID,       --  Mass Entanglement
    [99] = ns.Class.DRUID,           --  Incapacitating Roar
    [236748] = ns.Class.DRUID,       --  Intimidating Roar
    [5211] = ns.Class.DRUID,         --  Mighty Bash
    [45334] = ns.Class.DRUID,        --  Immobilized
    [203123] = ns.Class.DRUID,       --  Maim
    [50259] = ns.Class.DRUID,        --  Dazed (from Wild Charge)
    [209753] = ns.Class.DRUID,       --  Cyclone (from pvp talent)
    [33786] = ns.Class.DRUID,        --  Cyclone (from pvp talent - resto druid)
    [93985] = ns.Class.DRUID,        --  Skullbash
    [163505] = ns.Class.DRUID,       --  Rake
    [127797] = ns.Class.DRUID,       --  Ursol's Vortex

    [147362] = ns.Class.HUNTER,      --  Countershot
    [187707] = ns.Class.HUNTER,      --  Muzzle
    [3355] = ns.Class.HUNTER,        --  Freezing Trap / Diamond Ice (from pvp talent)
    [19577] = ns.Class.HUNTER,       --  Intimidation
    [190927] = ns.Class.HUNTER,      --  Harpoon
    [162480] = ns.Class.HUNTER,      --  Steel Trap
    [24394] = ns.Class.HUNTER,       --  Intimidation
    [117405] = ns.Class.HUNTER,      --  Binding Shot (trigger)
    [117526] = ns.Class.HUNTER,      --  Binding Shot (triggered)
    [1513] = ns.Class.HUNTER,        --  Scare Beast

    [119381] = ns.Class.MONK,        --  Leg Sweep
    [115078] = ns.Class.MONK,        --  Paralysis
    [198909] = ns.Class.MONK,        --  Song of Chi-Ji
    [116706] = ns.Class.MONK,        --  Disable
    [107079] = ns.Class.MONK,        --  Quaking Palm (racial)
    [116705] = ns.Class.MONK,        --  Spear kick

    [118905] = ns.Class.SHAMAN,      --  Static Charge (Capacitor Totem)
    [51514] = ns.Class.SHAMAN,       --  Hex
    [210873] = ns.Class.SHAMAN,      --  Hex (Compy)
    [211004] = ns.Class.SHAMAN,      --  Hex (Spider)
    [211010] = ns.Class.SHAMAN,      --  Hex (Snake)
    [211015] = ns.Class.SHAMAN,      --  Hex (Cockroach)
    [269352] = ns.Class.SHAMAN,      --  Hex (Skeletal Hatchling)
    [277778] = ns.Class.SHAMAN,      --  Hex (Zandalari Tendonripper)
    [277784] = ns.Class.SHAMAN,      --  Hex (Wicker Mongrel)
    [309328] = ns.Class.SHAMAN,      --  Hex (Living Honey)
    [57994] = ns.Class.SHAMAN,       --  Wind Shear
    [64695] = ns.Class.SHAMAN,       --  Earthgrab
    [197214] = ns.Class.SHAMAN,      --  Sundering

    [179057] = ns.Class.DEMONHUNTER, --  Chaos Nova
    [217832] = ns.Class.DEMONHUNTER, --  Imprison
    [200166] = ns.Class.DEMONHUNTER, --  Metamorphosis
    [207685] = ns.Class.DEMONHUNTER, --  Sigil of Misery
    [211881] = ns.Class.DEMONHUNTER, --   Fel Eruption
    [183752] = ns.Class.DEMONHUNTER, --  Disrupt

    [372245] = ns.Class.EVOKER,      --  Terror of the Skies
    [360806] = ns.Class.EVOKER,      --  Sleep Walk
}

ns.CD = {
    [31884]  = ns.Class.PALADIN,     -- Avenging Wrath
    [216331] = ns.Class.PALADIN,     -- Avenging Crusader
    [498]    = ns.Class.PALADIN,     -- Divine Protection
    [642]    = ns.Class.PALADIN,     -- Divine Shield
    [105809] = ns.Class.PALADIN,     -- Holy Avenger
    [152262] = ns.Class.PALADIN,     -- Seraphim
    [633]    = ns.Class.PALADIN,     -- Lay on Hands
    [1022]   = ns.Class.PALADIN,     -- Blessing of Protection
    [6940]   = ns.Class.PALADIN,     -- Blessing of Sacrifice
    [31821]  = ns.Class.PALADIN,     -- Aura Mastery
    [1044]   = ns.Class.PALADIN,     -- Blessing of Freedom
    [853]    = ns.Class.PALADIN,     -- Hammer of Justice
    [115750] = ns.Class.PALADIN,     -- Blinding Light
    [327193] = ns.Class.PALADIN,     -- Moment of Glory
    [31850]  = ns.Class.PALADIN,     -- Ardent Defender
    [86659]  = ns.Class.PALADIN,     -- Guardian of Ancient Kings
    [204018] = ns.Class.PALADIN,     -- Blessing of Spellwarding
    [231895] = ns.Class.PALADIN,     -- Crusade
    [205191] = ns.Class.PALADIN,     -- Eye for an Eye
    [184662] = ns.Class.PALADIN,     -- Shield of Vengeance

    [107574] = ns.Class.WARRIOR,     -- Avatar
    [227847] = ns.Class.WARRIOR,     -- Bladestorm
    [152277] = ns.Class.WARRIOR,     -- Ravager
    [118038] = ns.Class.WARRIOR,     -- Die by the Sword
    [97462]  = ns.Class.WARRIOR,     -- Rallying Cry
    [1719]   = ns.Class.WARRIOR,     -- Recklessness
    [46924]  = ns.Class.WARRIOR,     -- Bladestorm
    [184364] = ns.Class.WARRIOR,     -- Enraged Regeneration
    [228920] = ns.Class.WARRIOR,     -- Ravager
    [12975]  = ns.Class.WARRIOR,     -- Last Stand
    [871]    = ns.Class.WARRIOR,     -- Shield Wall
    [64382]  = ns.Class.WARRIOR,     -- Shattering Throw
    [5246]   = ns.Class.WARRIOR,     -- Intimidating Shout

    [205180] = ns.Class.WARLOCK,     -- Summon Darkglare
    [342601] = ns.Class.WARLOCK,     -- Ritual of Doom
    [113860] = ns.Class.WARLOCK,     -- Dark Soul: Misery
    [104773] = ns.Class.WARLOCK,     -- Unending Resolve
    [108416] = ns.Class.WARLOCK,     -- Dark Pact
    [265187] = ns.Class.WARLOCK,     -- Summon Demonic Tyrant
    [111898] = ns.Class.WARLOCK,     -- Grimoire: Felguard
    [267171] = ns.Class.WARLOCK,     -- Demonic Strength
    [267217] = ns.Class.WARLOCK,     -- Nether Portal
    [1122]   = ns.Class.WARLOCK,     -- Summon Infernal
    [113858] = ns.Class.WARLOCK,     -- Dark Soul: Instability
    [30283]  = ns.Class.WARLOCK,     -- Shadowfury
    [333889] = ns.Class.WARLOCK,     -- Fel Domination
    [5484]   = ns.Class.WARLOCK,     -- Howl of Terror

    [198067] = ns.Class.SHAMAN,      -- Fire Elemental
    [192249] = ns.Class.SHAMAN,      -- Storm Elemental
    [108271] = ns.Class.SHAMAN,      -- Astral Shift
    [108281] = ns.Class.SHAMAN,      -- Ancestral Guidance
    [51533]  = ns.Class.SHAMAN,      -- Feral Spirit
    [114050] = ns.Class.SHAMAN,      -- Ascendance
    [114051] = ns.Class.SHAMAN,      -- Ascendance
    [114052] = ns.Class.SHAMAN,      -- Ascendance
    [98008]  = ns.Class.SHAMAN,      -- Spirit Link Totem
    [108280] = ns.Class.SHAMAN,      -- Healing Tide Totem
    [207399] = ns.Class.SHAMAN,      -- Ancestral Protection Totem
    [16191]  = ns.Class.SHAMAN,      -- Mana Tide Totem
    [198103] = ns.Class.SHAMAN,      -- Earth Elemental
    [192058] = ns.Class.SHAMAN,      -- Capacitor Totem
    [65992]  = ns.Class.SHAMAN,      -- Tremor Totem
    [192077] = ns.Class.SHAMAN,      -- Wind Rush Totem

    [132578] = ns.Class.MONK,        -- Invoke Niuzao, the Black Ox
    [115080] = ns.Class.MONK,        -- Touch of Death
    [115203] = ns.Class.MONK,        -- Fortifying Brew
    [115176] = ns.Class.MONK,        -- Zen Meditation
    [115399] = ns.Class.MONK,        -- Black Ox brew
    [122278] = ns.Class.MONK,        -- Dampen Harm
    [137639] = ns.Class.MONK,        -- Storm, Earth, and Fire
    [123904] = ns.Class.MONK,        -- Invoke Xuen, the White Tiger
    [152173] = ns.Class.MONK,        -- Serenity
    [122470] = ns.Class.MONK,        -- Touch of Karma
    [322118] = ns.Class.MONK,        -- Invoke Yulon, the Jade serpent
    [198664] = ns.Class.MONK,        -- Invoke Chi-Ji, the Red Crane
    [243435] = ns.Class.MONK,        -- Fortifying Brew
    [122783] = ns.Class.MONK,        -- Diffuse Magic
    [116849] = ns.Class.MONK,        -- Life Cocoon
    [115310] = ns.Class.MONK,        -- Revival
    [197908] = ns.Class.MONK,        -- Mana tea
    [116844] = ns.Class.MONK,        -- Ring of peace
    [119381] = ns.Class.MONK,        -- Leg Sweep

    [193530] = ns.Class.HUNTER,      -- Aspect of the Wild
    [19574]  = ns.Class.HUNTER,      -- Bestial Wrath
    [201430] = ns.Class.HUNTER,      -- Stampede
    [193526] = ns.Class.HUNTER,      -- Trueshot
    [199483] = ns.Class.HUNTER,      -- Camouflage
    [281195] = ns.Class.HUNTER,      -- Survival of the Fittest
    [266779] = ns.Class.HUNTER,      -- Coordinated Assault
    [186265] = ns.Class.HUNTER,      -- Aspect of the Turtle
    [109304] = ns.Class.HUNTER,      -- Exhilaration
    [186257] = ns.Class.HUNTER,      -- Aspect of the cheetah
    [19577]  = ns.Class.HUNTER,      -- Intimidation
    [109248] = ns.Class.HUNTER,      -- Binding Shot
    [187650] = ns.Class.HUNTER,      -- Freezing Trap
    [186289] = ns.Class.HUNTER,      -- Aspect of the eagle

    [22812]  = ns.Class.DRUID,       -- Barkskin
    [61336]  = ns.Class.DRUID,       -- Survival Instincts
    [108238] = ns.Class.DRUID,       -- Renewal
    [77764]  = ns.Class.DRUID,       -- Stampeding Roar
    [5217]   = ns.Class.DRUID,       -- Tiger's Fury
    [29166]  = ns.Class.DRUID,       -- Innervate
    [78675]  = ns.Class.DRUID,       -- Solar Beam
    [106951] = ns.Class.DRUID,       -- Berserk
    [194223] = ns.Class.DRUID,       -- Celestial Alignment
    [102560] = ns.Class.DRUID,       -- Incarnation: Chosen of Elune
    [102543] = ns.Class.DRUID,       -- Incarnation: King of the Jungle
    [102558] = ns.Class.DRUID,       -- Incarnation: Guardian of Ursoc
    [33891]  = ns.Class.DRUID,       -- Incarnation: Tree of Life
    [102342] = ns.Class.DRUID,       -- Ironbark
    [203651] = ns.Class.DRUID,       -- Overgrowth
    [740]    = ns.Class.DRUID,       -- Tranquility
    [197721] = ns.Class.DRUID,       -- Flourish
    [132469] = ns.Class.DRUID,       -- Typhoon
    [319454] = ns.Class.DRUID,       -- Heart of the Wild

    [275699] = ns.Class.DEATHKNIGHT, -- Apocalypse
    [42650]  = ns.Class.DEATHKNIGHT, -- Army of the Dead
    [49206]  = ns.Class.DEATHKNIGHT, -- Summon Gargoyle
    [207289] = ns.Class.DEATHKNIGHT, -- Unholy Assault
    [48743]  = ns.Class.DEATHKNIGHT, -- Death Pact
    [48707]  = ns.Class.DEATHKNIGHT, -- Anti-magic Shell
    [152279] = ns.Class.DEATHKNIGHT, -- Breath of Sindragosa
    [47568]  = ns.Class.DEATHKNIGHT, -- Empower Rune Weapon
    [279302] = ns.Class.DEATHKNIGHT, -- Frostwyrm's Fury
    [49028]  = ns.Class.DEATHKNIGHT, -- Dancing Rune Weapon
    [55233]  = ns.Class.DEATHKNIGHT, -- Vampiric Blood
    [48792]  = ns.Class.DEATHKNIGHT, -- Icebound Fortitude
    [51052]  = ns.Class.DEATHKNIGHT, -- Anti-magic Zone
    [219809] = ns.Class.DEATHKNIGHT, -- Tombstone
    [108199] = ns.Class.DEATHKNIGHT, -- Gorefiend's Grasp
    [207167] = ns.Class.DEATHKNIGHT, -- Blinding Sleet
    [108194] = ns.Class.DEATHKNIGHT, -- Asphyxiate
    [221562] = ns.Class.DEATHKNIGHT, -- Asphyxiate


    [200166] = ns.Class.DEMONHUNTER, -- Metamorphosis
    [198589] = ns.Class.DEMONHUNTER, -- Blur

    [196555] = ns.Class.DEMONHUNTER, -- Netherwalk
    [187827] = ns.Class.DEMONHUNTER, -- Metamorphosis
    [196718] = ns.Class.DEMONHUNTER, -- Darkness
    [188501] = ns.Class.DEMONHUNTER, -- Spectral Sight
    [179057] = ns.Class.DEMONHUNTER, -- Chaos Nova
    [211881] = ns.Class.DEMONHUNTER, -- Fel Eruption
    [320341] = ns.Class.DEMONHUNTER, -- Bulk Extraction
    [204021] = ns.Class.DEMONHUNTER, -- Fiery Brand
    [263648] = ns.Class.DEMONHUNTER, -- Soul Barrier
    [207684] = ns.Class.DEMONHUNTER, -- Sigil of Misery
    [202137] = ns.Class.DEMONHUNTER, -- Sigil of Silence
    [202138] = ns.Class.DEMONHUNTER, -- Sigil of Chains

    [12042]  = ns.Class.MAGE,        -- Arcane Power
    [12051]  = ns.Class.MAGE,        -- Evocation
    [110960] = ns.Class.MAGE,        -- Greater Invisibility
    [235450] = ns.Class.MAGE,        -- Prismatic Barrier
    [235313] = ns.Class.MAGE,        -- Blazing Barrier
    [11426]  = ns.Class.MAGE,        -- Ice Barrier
    [190319] = ns.Class.MAGE,        -- Combustion
    [55342]  = ns.Class.MAGE,        -- Mirror Image
    [66]     = ns.Class.MAGE,        -- Invisibility
    [12472]  = ns.Class.MAGE,        -- Icy Veins
    [205021] = ns.Class.MAGE,        -- Ray of Frost
    [45438]  = ns.Class.MAGE,        -- Ice Block
    [235219] = ns.Class.MAGE,        -- Cold Snap
    [113724] = ns.Class.MAGE,        -- Ring of Frost

    [10060]  = ns.Class.PRIEST,      -- Power Infusion
    [34433]  = ns.Class.PRIEST,      -- Shadowfiend
    [123040] = ns.Class.PRIEST,      -- Mindbender
    [33206]  = ns.Class.PRIEST,      -- Pain Suppression
    [62618]  = ns.Class.PRIEST,      -- Power Word: Barrier
    [271466] = ns.Class.PRIEST,      -- Luminous Barrier
    [47536]  = ns.Class.PRIEST,      -- Rapture
    [19236]  = ns.Class.PRIEST,      -- Desperate Prayer
    [200183] = ns.Class.PRIEST,      -- Apotheosis
    [47788]  = ns.Class.PRIEST,      -- Guardian Spirit
    [64844]  = ns.Class.PRIEST,      -- Divine Hymn
    [64901]  = ns.Class.PRIEST,      -- Symbol of Hope
    [265202] = ns.Class.PRIEST,      -- Holy Word: Salvation
    [109964] = ns.Class.PRIEST,      -- Spirit Shell
    [8122]   = ns.Class.PRIEST,      -- Psychic Scream
    [200174] = ns.Class.PRIEST,      -- Mindbender
    [193223] = ns.Class.PRIEST,      -- Surrender to Madness
    [47585]  = ns.Class.PRIEST,      -- Dispersion
    [15286]  = ns.Class.PRIEST,      -- Vampiric Embrace

    [79140]  = ns.Class.ROGUE,       -- Vendetta
    [1856]   = ns.Class.ROGUE,       -- Vanish
    [5277]   = ns.Class.ROGUE,       -- Evasion
    [31224]  = ns.Class.ROGUE,       -- Cloak of Shadows
    [2094]   = ns.Class.ROGUE,       -- Blind
    [114018] = ns.Class.ROGUE,       -- Shroud of Concealment
    [185311] = ns.Class.ROGUE,       -- Crimson Vial
    [13750]  = ns.Class.ROGUE,       -- Adrenaline Rush
    [51690]  = ns.Class.ROGUE,       -- Killing Spree
    [199754] = ns.Class.ROGUE,       -- Riposte
    [343142] = ns.Class.ROGUE,       -- Dreadblades
    [121471] = ns.Class.ROGUE,       -- Shadow Blades

    [360827] = ns.Class.EVOKER,      -- Blistering Scales
    [395152] = ns.Class.EVOKER,      -- Ebon Might
}

ns.DPS = {
    [391889] = ns.Class.DRUID -- Adaptive Swarm
}

ns.Tank = {
    [135286] = ns.Class.DRUID,       -- Tooth and Claw
    [80313] = ns.Class.DRUID,        -- Pulverize
    [204069] = ns.Class.DRUID,       -- Lunar Beam

    [123725] = ns.Class.MONK,        -- Breath of Fire

    [1160] = ns.Class.WARRIOR,       -- Demoralizing Shout
    [410219] = ns.Class.WARRIOR,     -- Earthen Smash

    [392490] = ns.Class.DEAHTKNIGHT, -- Enfeeble

    [204301] = ns.Class.PALADIN,     -- Blessed Hammer
    [387174] = ns.Class.PALADIN,     -- Eye of Tyr
    [383843] = ns.Class.PALADIN,     -- Crusader's Resolve
}