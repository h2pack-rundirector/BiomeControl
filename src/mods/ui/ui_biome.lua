local module = {}
local biomeUis = {}
local components

local BIOME_UI_IMPORTS = {
    F = "mods/ui/biomes/f_erebus.lua",
    G = "mods/ui/biomes/g_oceanus.lua",
    H = "mods/ui/biomes/h_fields.lua",
    I = "mods/ui/biomes/i_tartarus.lua",
    N = "mods/ui/biomes/n_ephyra.lua",
    O = "mods/ui/biomes/o_thessaly.lua",
    P = "mods/ui/biomes/p_olympus.lua",
    Q = "mods/ui/biomes/q_summit.lua",
}

function module.draw(imgui, session, biomeKey)
    local biomeUi = biomeUis[biomeKey]
    if biomeUi and biomeUi.draw(imgui, session) then
        return
    end
    components.DrawPlaceholder(imgui, biomeKey)
end

function module.bind(deps)
    components = deps.components

    local biomeDeps = {
        definitions = deps.definitions,
        catalog = deps.catalog,
        components = components,
    }

    for biomeKey, importPath in pairs(BIOME_UI_IMPORTS) do
        biomeUis[biomeKey] = import(importPath).bind(biomeDeps)
    end

    return module
end

return module
