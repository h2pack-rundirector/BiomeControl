local data = {}

local definitions = import("mods/data/definitions.lua")
local catalog = import("mods/data/catalog.lua")
local extensionLoader = import("mods/data/extensions.lua")
local storage = import("mods/data/storage.lua")
local extensionControls = extensionLoader.load()

local catalogModel = catalog.create({
    definitions = definitions,
    extensionControls = extensionControls,
    defaults = {
        roomModeValues = definitions.roomModeValues,
        roomModeDisplayValues = definitions.roomModeDisplayValues,
    },
})

data.definitions = definitions
data.catalog = catalogModel

data.storage = {}
function data.storage.build()
    return storage.build(data)
end

return data
