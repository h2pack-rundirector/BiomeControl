local definitions = {}

definitions.DEFAULT_FIELD_MEDIUM = 0.4
definitions.REGION_UNDERWORLD = 1
definitions.REGION_SURFACE = 2
definitions.REGION_OPTIONS = {
    { label = "Underworld", value = definitions.REGION_UNDERWORLD },
    { label = "Surface", value = definitions.REGION_SURFACE },
}

definitions.biomeMap = {
    F = "Erebus",
    G = "Oceanus",
    H = "Fields",
    I = "Tartarus",
    N = "Ephyra",
    O = "Thessaly",
    P = "Olympus",
    Q = "Summit",
}

definitions.biomeTabs = {
    { key = "F", label = "Erebus",   region = "Underworld" },
    { key = "G", label = "Oceanus",  region = "Underworld" },
    { key = "H", label = "Fields",   region = "Underworld" },
    { key = "I", label = "Tartarus", region = "Underworld" },
    { key = "N", label = "Ephyra",   region = "Surface" },
    { key = "O", label = "Thessaly", region = "Surface" },
    { key = "P", label = "Olympus",  region = "Surface" },
    { key = "Q", label = "Summit",   region = "Surface" },
}

definitions.roomModeValues = { "default", "disabled", "forced" }
definitions.roomModeDisplayValues = {
    default = "Default",
    disabled = "Disabled",
    forced = "Forced",
}

definitions.dreamBiomeOptions = { "F", "G", "H", "I", "N", "O", "P", "Q" }
definitions.dreamNaturalNextBiome = {
    F = "G",
    G = "H",
    H = "I",
    N = "O",
    N_SubRooms = "O",
    O = "P",
    P = "Q",
}

definitions.priorityGods = {
    { label = "Aphrodite",  lootKey = "AphroditeUpgrade",  colorKey = "AphroditeVoice" },
    { label = "Apollo",     lootKey = "ApolloUpgrade",     colorKey = "ApolloVoice" },
    { label = "Ares",       lootKey = "AresUpgrade",       colorKey = "AresVoice" },
    { label = "Demeter",    lootKey = "DemeterUpgrade",    colorKey = "DemeterVoice" },
    { label = "Hephaestus", lootKey = "HephaestusUpgrade", colorKey = "HephaestusVoice" },
    { label = "Hera",       lootKey = "HeraUpgrade",       colorKey = "HeraDamage" },
    { label = "Hestia",     lootKey = "HestiaUpgrade",     colorKey = "HestiaVoice" },
    { label = "Poseidon",   lootKey = "PoseidonUpgrade",   colorKey = "PoseidonVoice" },
    { label = "Zeus",       lootKey = "ZeusUpgrade",       colorKey = "ZeusVoice" },
}

definitions.biomeSpecs = {
    F = {
        rooms = {
            { id = "Arachne", type = "Story", biome = "F", min = 4, max = 8 },
            { id = "Trial", type = "Trial", biome = "F", useRegionInKey = true, min = 6, max = 10 },
            { id = "Fountain", type = "Fountain", biome = "F", useRegionInKey = true, min = 4, max = 8 },
            { id = "Shop", type = "Shop", biome = "F", useRegionInKey = true, min = 4, max = 6 },
            { id = "Treant", type = "MiniBoss", biome = "F", roomKey = "F_MiniBoss01", label = "Root-Stalker", min = 4, max = 6 },
            { id = "FogEmitter", type = "MiniBoss", biome = "F", roomKey = "F_MiniBoss02", label = "Shadow-Spiller", min = 4, max = 6 },
            { id = "Assassin", type = "MiniBoss", biome = "F", roomKey = "F_MiniBoss03", label = "Master-Slicer", min = 4, max = 6 },
        },
        npcs = {
            { id = "Artemis", groupKey = "ArtemisUnderworld", biome = "F", min = 4, max = 10 },
            { id = "Nemesis", biome = "F", min = 4, max = 10 },
        },
    },
    G = {
        rooms = {
            { id = "Narcissus", type = "Story", biome = "G", min = 3, max = 6 },
            { id = "Trial", type = "Trial", biome = "G", useRegionInKey = true, min = 3, max = 7 },
            { id = "Fountain", type = "Fountain", biome = "G", useRegionInKey = true, min = 4, max = 6 },
            { id = "Shop", type = "Shop", biome = "G", useRegionInKey = true, min = 3, max = 6 },
            { id = "WaterUnit", type = "MiniBoss", biome = "G", roomKey = "G_MiniBoss01", label = "Deep Serpent", min = 4, max = 7 },
            { id = "Crawler", type = "MiniBoss", biome = "G", roomKey = "G_MiniBoss02", label = "King Vermin", min = 4, max = 7 },
            { id = "Jellyfish", type = "MiniBoss", biome = "G", roomKey = "G_MiniBoss03", label = "Hellifish", min = 4, max = 7 },
        },
        npcs = {
            { id = "Artemis", groupKey = "ArtemisUnderworld", biome = "G", min = 4, max = 10 },
            { id = "Nemesis", biome = "G", min = 4, max = 10 },
        },
    },
    H = {
        rooms = {
            { id = "Vampire", type = "MiniBoss", biome = "H", roomKey = "H_MiniBoss01", label = "Phantom", min = 2, max = 4 },
            { id = "Lamia", type = "MiniBoss", biome = "H", roomKey = "H_MiniBoss02", label = "Queen Lamia", min = 2, max = 4 },
        },
        npcs = {
            { id = "Nemesis", biome = "H", min = 4, max = 10 },
        },
    },
    I = {
        rooms = {
            { id = "RatCatcher", type = "MiniBoss", biome = "I", roomKey = "I_MiniBoss01", label = "The Verminancer", min = 3, max = 7 },
            { id = "GoldElemental", type = "MiniBoss", biome = "I", roomKey = "I_MiniBoss02", label = "Goldwrath", min = 3, max = 7 },
        },
        npcs = {
            { id = "Nemesis", biome = "I", min = 4, max = 10 },
        },
    },
    N = {
        npcs = {
            { id = "Artemis", groupKey = "ArtemisSurface", biome = "N", min = 4, max = 10 },
            { id = "Heracles", biome = "N", min = 0, max = 10 },
        },
    },
    O = {
        rooms = {
            { id = "Circe", type = "Story", biome = "O", min = 4, max = 5 },
            { id = "Trial", type = "Trial", biome = "O", useRegionInKey = true, min = 2, max = 6 },
            { id = "Fountain", type = "Fountain", biome = "O", useRegionInKey = true, min = 3, max = 5 },
            { id = "Shop", type = "Shop", biome = "O", useRegionInKey = true, min = 4, max = 5 },
        },
        npcs = {
            { id = "Heracles", biome = "O", min = 0, max = 10 },
            { id = "Icarus", biome = "O", min = 3, max = 8 },
        },
    },
    P = {
        rooms = {
            { id = "Dionysus", type = "Story", biome = "P", min = 3, max = 7 },
            { id = "Fountain", type = "Fountain", biome = "P", useRegionInKey = true, min = 4, max = 7 },
            { id = "Shop", type = "Shop", biome = "P", useRegionInKey = true, min = 5, max = 7 },
            { id = "Talos", type = "MiniBoss", biome = "P", roomKey = "P_MiniBoss01", label = "Talos", min = 4, max = 7 },
            { id = "Dragon", type = "MiniBoss", biome = "P", roomKey = "P_MiniBoss02", label = "Mega-Dracon", min = 4, max = 7 },
        },
        npcs = {
            { id = "Heracles", biome = "P", min = 0, max = 10 },
            { id = "Athena", biome = "P", min = 4, max = 8 },
            { id = "Icarus", biome = "P", min = 3, max = 8 },
        },
    },
}

return definitions
