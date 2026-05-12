local module = {}
local roomModes
local biomeLogic = {}

local BIOME_LOGIC_IMPORTS = {
    F = "mods/logic/biomes/f_erebus.lua",
    G = "mods/logic/biomes/g_oceanus.lua",
    H = "mods/logic/biomes/h_fields.lua",
    N = "mods/logic/biomes/n_ephyra.lua",
    O = "mods/logic/biomes/o_thessaly.lua",
}

local function BindLogic()
    function module.buildPatchPlan(plan, host, store)
        if roomModes.buildPatchPlan then
            roomModes.buildPatchPlan(plan, host, store)
        end
        for _, logic in pairs(biomeLogic) do
            if logic.buildPatchPlan then
                logic.buildPatchPlan(plan, host, store)
            end
        end
    end

    function module.registerHooks(host, store)
        for _, logic in pairs(biomeLogic) do
            if logic.registerHooks then
                logic.registerHooks(host, store)
            end
        end
    end
end

function module.bind(deps)
    roomModes = import("mods/logic/biomes/room_modes.lua").bind(deps)
    for biomeKey, importPath in pairs(BIOME_LOGIC_IMPORTS) do
        biomeLogic[biomeKey] = import(importPath).bind(deps)
    end
    BindLogic()
    return module
end

return module
