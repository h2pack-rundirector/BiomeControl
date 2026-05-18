local storage = {}

local function addDepthStorageNodes(nodes, definitions)
    local seen = {}
    for _, def in ipairs(definitions) do
        if not seen[def.rangeMinAlias] then
            seen[def.rangeMinAlias] = true
            table.insert(nodes, {
                type = "int",
                alias = def.rangeMinAlias,
                default = def.minDefault,
                min = def.minDefault,
                max = def.maxDefault,
            })
        end
        if not seen[def.rangeMaxAlias] then
            seen[def.rangeMaxAlias] = true
            table.insert(nodes, {
                type = "int",
                alias = def.rangeMaxAlias,
                default = def.maxDefault,
                min = def.minDefault,
                max = def.maxDefault,
            })
        end
    end
end

local function addStateFields(nodes, stateFields, packedRewardFields)
    local storageTypeMap = { checkbox = "bool", stepper = "int", dropdown = "string", int32 = "int" }

    for _, field in ipairs(stateFields) do
        if not packedRewardFields[field.alias] then
            local storageType = storageTypeMap[field.type] or field.type
            local default = field.default
            if default == nil then
                if storageType == "bool" then
                    default = false
                elseif storageType == "string" then
                    default = ""
                else
                    default = field.min or 0
                end
            end
            table.insert(nodes, {
                type = storageType,
                alias = field.alias,
                default = default,
                min = field.min,
                max = field.max,
            })
        end
    end
end

local function addPackedRewardFields(nodes, packedRewardFields)
    for _, reward in ipairs(packedRewardFields or {}) do
        local alias = reward.alias
        local bits = {}
        for _, option in ipairs(reward.options or {}) do
            bits[#bits + 1] = {
                alias = alias .. "_" .. tostring(option.name or option.label or option.bit),
                label = option.label or tostring(option.name or option.bit),
                type = "bool",
                offset = option.bit,
                width = 1,
                default = false,
            }
        end
        table.insert(nodes, {
            type = "packedInt",
            alias = alias,
            default = 0,
            bits = bits,
        })
    end
end

local function addRangeFields(nodes, rangeFields)
    for _, field in ipairs(rangeFields) do
        table.insert(nodes, {
            type = "int",
            alias = field.rangeMinAlias,
            default = field.min,
            min = field.min,
            max = field.max,
        })
        table.insert(nodes, {
            type = "int",
            alias = field.rangeMaxAlias,
            default = field.max,
            min = field.min,
            max = field.max,
        })
    end
end

function storage.build(data)
    local catalog = data.catalog
    local nodes = {
        { type = "bool",   alias = "OnlyAllowForcedEncounters",       default = false },
        { type = "bool",   alias = "IgnoreMaxDepth",                 default = false },
        { type = "int",    alias = "NPCSpacing",                     default = 6, min = 1, max = 12 },
        { type = "bool",   alias = "PrioritizeSpecificRewardEnabled", default = false },
        { type = "string", alias = "PriorityBiome1",                 default = "" },
        { type = "string", alias = "PriorityBiome2",                 default = "" },
        { type = "string", alias = "PriorityBiome3",                 default = "" },
        { type = "string", alias = "PriorityBiome4",                 default = "" },
        { type = "bool",   alias = "PrioritizeTrialRewardEnabled",    default = false },
        { type = "string", alias = "PriorityTrial1",                 default = "" },
        { type = "string", alias = "PriorityTrial2",                 default = "" },
        { type = "bool",   alias = "DreamRouteEnabled",              default = false },
        { type = "string", alias = "DreamRouteBiome1",               default = "G" },
        { type = "string", alias = "DreamRouteBiome2",               default = "I" },
        { type = "string", alias = "DreamRouteBiome3",               default = "N" },
        { type = "string", alias = "DreamRouteBiome4",               default = "P" },
        { type = "string", alias = "UnderworldTab", persist = false, hash = false, default = "NPCs", maxLen = 32 },
        { type = "string", alias = "SurfaceTab",    persist = false, hash = false, default = "NPCs", maxLen = 32 },
    }

    local packedRewardFields = catalog.packedRewardFieldsOrdered

    addStateFields(nodes, catalog.stateFields, catalog.packedRewardFields)
    addPackedRewardFields(nodes, packedRewardFields)
    addRangeFields(nodes, catalog.rangeFields)

    for _, field in ipairs(catalog.modeStorageFields) do
        table.insert(nodes, field)
    end

    addDepthStorageNodes(nodes, catalog.roomDefinitions)
    addDepthStorageNodes(nodes, catalog.npcDefinitions)

    return nodes
end

return storage
