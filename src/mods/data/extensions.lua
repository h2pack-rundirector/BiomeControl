local extensions = {}

local EXTENSION_IMPORTS = {
    "mods/data/extensions/fields.lua",
    "mods/data/extensions/ephyra.lua",
    "mods/data/extensions/thessaly.lua",
}

local function appendAll(target, values)
    for _, value in ipairs(values or {}) do
        target[#target + 1] = value
    end
end

local function appendMapped(target, values)
    for key, list in pairs(values or {}) do
        target[key] = target[key] or {}
        appendAll(target[key], list)
    end
end

function extensions.load()
    local controls = {
        stateFields = {},
        rangeFields = {},
        biomeRooms = {},
        biomeRewards = {},
        biomeSpecials = {},
    }

    for _, importPath in ipairs(EXTENSION_IMPORTS) do
        local extension = import(importPath)

        local extensionControls = extension.controls or {}
        appendAll(controls.stateFields, extensionControls.stateFields)
        appendAll(controls.rangeFields, extensionControls.rangeFields)
        appendMapped(controls.biomeRooms, extensionControls.biomeRooms)
        appendMapped(controls.biomeRewards, extensionControls.biomeRewards)
        appendMapped(controls.biomeSpecials, extensionControls.biomeSpecials)
    end

    return controls
end

return extensions
