local internal = RunDirectorBiomeControl_Internal
local MODULE_ID = "BiomeControl"

local activeRead = function()
    return nil
end

local activeIsEnabled = function()
    return false
end

local function MakeRead(store)
    return function(key)
        return store.read(key)
    end
end

local function IsEnabled()
    return activeIsEnabled()
end

function internal.GetRunState(read)
    read = read or activeRead
    if not CurrentRun then return nil end
    local state = lib.gameObject.get(CurrentRun, "run-director", MODULE_ID, "run", function()
        return {
            BiomePrioritySatisfied = {},
            ForcedNPCPending = {},
            NPCEncounterSeen = {},
            OnlyAllowForcedEncounters = read("OnlyAllowForcedEncounters"),
        }
    end)
    state.OnlyAllowForcedEncounters = read("OnlyAllowForcedEncounters")
    state.ForcedNPCPending = {}

    for _, groupKey in ipairs(internal.npcGroups.orderedIds or {}) do
        local group = internal.npcGroups[groupKey]
        state.ForcedNPCPending[groupKey] = {}
        for _, def in ipairs(group.definitions or {}) do
            local mode = internal.GetModeValue(read, def)
            if mode == "forced" then
                state.ForcedNPCPending[groupKey][def.biome] = true
            end
        end
    end

    return state
end

import("mods/logic/logic_biome.lua")
import("mods/logic/logic_npc.lua")
import("mods/logic/logic_dream.lua")

function internal.BuildPatchPlan(plan, store)
    local read = MakeRead(store)
    if internal.BuildBiomePatchPlan then
        internal.BuildBiomePatchPlan(plan, read)
    end
    if internal.BuildNPCPatchPlan then
        internal.BuildNPCPatchPlan(plan, read)
    end
end

function internal.RegisterHooks(store, host)
    activeRead = MakeRead(store)
    activeIsEnabled = host.isEnabled

    if internal.RegisterBiomeHooks then
        internal.RegisterBiomeHooks(activeRead, IsEnabled)
    end
    if internal.RegisterNPCHooks then
        internal.RegisterNPCHooks(activeRead, IsEnabled)
    end
    if internal.RegisterDreamHooks then
        internal.RegisterDreamHooks(activeRead, IsEnabled)
    end
end
