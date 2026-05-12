local catalog = {}

local function cloneData(data)
    local copy = {}
    for key, value in pairs(data) do
        copy[key] = value
    end
    return copy
end

local function resolveModeEntry(model, entryOrKey)
    if type(entryOrKey) == "table" then
        return entryOrKey
    end
    return model.modeEntryLookup[entryOrKey]
end

local function prepareModeField(model, defaults, entry)
    entry.modeValues = entry.modeValues or defaults.roomModeValues
    entry.modeDisplayValues = entry.modeDisplayValues or defaults.roomModeDisplayValues
    entry.defaultMode = entry.defaultMode or entry.modeValues[1] or "default"
    entry.modeValueLookup = {}
    for index, value in ipairs(entry.modeValues) do
        entry.modeValueLookup[value] = index - 1
    end
    model.modeEntryLookup[entry.modeKey] = entry
    table.insert(model.modeStorageFields, {
        type = "int",
        alias = entry.modeKey,
        default = entry.modeValueLookup[entry.defaultMode] or 0,
        min = 0,
        max = math.max(#entry.modeValues - 1, 0),
    })
end

local function defineRoomControl(model, defaults, biomeMap, data)
    local entry = cloneData(data)
    local regionName = biomeMap[entry.biome] or entry.biome
    entry.region = regionName
    entry.minDefault = entry.min
    entry.maxDefault = entry.max

    if not entry.label then
        if entry.type == "Story" or entry.type == "Trial" or entry.type == "Fountain" or entry.type == "Shop" then
            entry.label = entry.type
        else
            entry.label = string.format("%s (%s)", entry.id, regionName)
        end
    end

    local keyIdentifier = entry.id
    if entry.useRegionInKey then
        if entry.id == entry.type then
            keyIdentifier = regionName
        else
            keyIdentifier = entry.id .. regionName
        end
    end
    entry.rangeMinAlias = entry.rangeMinAlias or ("Packed" .. entry.type .. keyIdentifier .. "Min")
    entry.rangeMaxAlias = entry.rangeMaxAlias or ("Packed" .. entry.type .. keyIdentifier .. "Max")
    entry.modeKey = entry.modeKey or ("Mode" .. entry.type .. keyIdentifier)
    prepareModeField(model, defaults, entry)

    table.insert(model.roomDefinitions, entry)
end

local function defineNPCControl(model, defaults, biomeMap, data)
    local entry = cloneData(data)
    local regionName = biomeMap[entry.biome] or entry.biome
    entry.region = regionName
    entry.minDefault = entry.min
    entry.maxDefault = entry.max
    entry.label = entry.label or entry.id
    entry.groupKey = entry.groupKey or entry.id
    entry.rangeMinAlias = entry.rangeMinAlias or ("PackedNPC" .. entry.id .. regionName .. "Min")
    entry.rangeMaxAlias = entry.rangeMaxAlias or ("PackedNPC" .. entry.id .. regionName .. "Max")
    entry.modeKey = entry.modeKey or ("ModeNPC" .. entry.id .. regionName)
    entry.modeValues = entry.modeValues or defaults.roomModeValues
    entry.modeDisplayValues = entry.modeDisplayValues or defaults.roomModeDisplayValues
    entry.defaultMode = entry.defaultMode or "default"
    prepareModeField(model, defaults, entry)
    table.insert(model.npcDefinitions, entry)
end

local function buildLookups(model)
    for _, def in ipairs(model.roomDefinitions) do
        model.roomLookup[def.id] = model.roomLookup[def.id] or {}
        model.roomLookup[def.id][def.biome] = def

        model.biomeDefinitions[def.biome] = model.biomeDefinitions[def.biome] or {}
        model.biomeDefinitions[def.biome][def.type] = model.biomeDefinitions[def.biome][def.type] or {}
        table.insert(model.biomeDefinitions[def.biome][def.type], def)
    end

    for _, def in ipairs(model.npcDefinitions) do
        model.npcLookup[def.id] = model.npcLookup[def.id] or {}
        model.npcLookup[def.id][def.biome] = def
        if not model.npcGroups[def.groupKey] then
            model.npcGroups[def.groupKey] = {
                id = def.groupKey,
                label = def.label,
                actualNPCName = def.id,
                region = def.region,
                definitions = {},
                lookup = {},
            }
            table.insert(model.npcGroups.orderedIds, def.groupKey)
        end
        table.insert(model.npcGroups[def.groupKey].definitions, def)
        model.npcGroups[def.groupKey].lookup[def.biome] = def
    end

    for _, npcId in ipairs(model.npcGroups.orderedIds) do
        local group = model.npcGroups[npcId]
        table.sort(group.definitions, function(a, b)
            return a.biome < b.biome
        end)
    end
end

local function appendSpecList(target, values)
    for _, value in ipairs(values or {}) do
        target[#target + 1] = value
    end
end

local function appendControlList(target, values)
    for _, value in ipairs(values or {}) do
        target[#target + 1] = value
    end
end

local function appendControlMap(target, source)
    for key, list in pairs(source or {}) do
        target[key] = target[key] or {}
        appendControlList(target[key], list)
    end
end

local function buildDefinitionSpecs(definitions)
    local roomDefinitionSpecs = {}
    local npcDefinitionSpecs = {}

    for _, biome in ipairs(definitions.biomeTabs) do
        local spec = definitions.biomeSpecs[biome.key] or {}
        appendSpecList(roomDefinitionSpecs, spec.rooms)
        appendSpecList(npcDefinitionSpecs, spec.npcs)
    end

    return roomDefinitionSpecs, npcDefinitionSpecs
end

local function getPackedRewardFields(biomeRewards)
    local packedRewardFields = {}

    for _, rewards in pairs(biomeRewards or {}) do
        for _, reward in ipairs(rewards) do
            if reward.kind == "packedCheckboxes" and type(reward.alias) == "string" and reward.alias ~= "" then
                packedRewardFields[reward.alias] = reward
            end
        end
    end

    return packedRewardFields
end

local function getRangeFieldLookup(rangeFields)
    local lookup = {}

    for _, field in ipairs(rangeFields or {}) do
        lookup[field.rangeMinAlias] = field
        lookup[field.rangeMaxAlias] = field
    end

    return lookup
end

function catalog.create(args)
    local definitions = args.definitions
    local extensionControls = args.extensionControls or {}
    local roomDefinitionSpecs, npcDefinitionSpecs = buildDefinitionSpecs(definitions)
    local model = {
        roomDefinitionSpecs = roomDefinitionSpecs,
        npcDefinitionSpecs = npcDefinitionSpecs,
        roomDefinitions = {},
        roomLookup = {},
        biomeDefinitions = {},
        npcDefinitions = {},
        npcLookup = {},
        npcGroups = { orderedIds = {} },
        modeEntryLookup = {},
        modeStorageFields = {},
        stateFields = {},
        rangeFields = {},
        biomeRooms = {},
        biomeRewards = {},
        biomeSpecials = {},
        packedRewardFields = {},
        rangeFieldLookup = {},
    }

    appendControlList(model.stateFields, extensionControls.stateFields)
    appendControlList(model.rangeFields, extensionControls.rangeFields)
    appendControlMap(model.biomeRooms, extensionControls.biomeRooms)
    appendControlMap(model.biomeRewards, extensionControls.biomeRewards)
    appendControlMap(model.biomeSpecials, extensionControls.biomeSpecials)

    for _, biome in ipairs(definitions.biomeTabs) do
        model.biomeRooms[biome.key] = model.biomeRooms[biome.key] or {}
        model.biomeSpecials[biome.key] = model.biomeSpecials[biome.key] or {}
        model.biomeRewards[biome.key] = model.biomeRewards[biome.key] or {}
    end

    model.packedRewardFields = getPackedRewardFields(model.biomeRewards)
    model.rangeFieldLookup = getRangeFieldLookup(model.rangeFields)

    for _, entry in ipairs(roomDefinitionSpecs) do
        defineRoomControl(model, args.defaults, definitions.biomeMap, entry)
    end

    for _, entry in ipairs(npcDefinitionSpecs) do
        defineNPCControl(model, args.defaults, definitions.biomeMap, entry)
    end

    for _, entries in pairs(model.biomeRooms or {}) do
        for _, entry in ipairs(entries) do
            if entry.kind == "modeField" then
                entry.modeKey = entry.modeKey or entry.alias or entry.label
                prepareModeField(model, args.defaults, entry)
            end
        end
    end

    buildLookups(model)

    function model.GetModeValue(readFn, entryOrKey)
        local entry = resolveModeEntry(model, entryOrKey)
        if not entry then return "default" end

        local encoded = readFn(entry.modeKey)
        encoded = math.floor(tonumber(encoded) or 0)
        return entry.modeValues[encoded + 1] or entry.defaultMode
    end

    function model.SetModeValue(session, entryOrKey, value)
        local entry = resolveModeEntry(model, entryOrKey)
        if not entry then return end

        local encoded = entry.modeValueLookup[value]
        if encoded == nil then
            encoded = entry.modeValueLookup[entry.defaultMode] or 0
        end

        session.write(entry.modeKey, encoded)
    end

    function model.GetModeDisplay(entryOrKey, value)
        local entry = resolveModeEntry(model, entryOrKey)
        if not entry then
            return tostring(value)
        end
        return entry.modeDisplayValues[value] or tostring(value)
    end

    return model
end

return catalog
