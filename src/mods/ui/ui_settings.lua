local internal = RunDirectorBiomeControl_Internal

local PRIORITY_LABEL_WIDTH = 160
local GOD_AVAILABILITY_INTEGRATION = "run-director.god-availability"

local function IsGodPoolFilteringActive()
    return lib.integrations.invoke(GOD_AVAILABILITY_INTEGRATION, "isActive", false) == true
end

local function IsPriorityLootAvailable(lootKey)
    if lootKey == "" then
        return true
    end

    local godKey = internal.priorityGodByLootKey and internal.priorityGodByLootKey[lootKey] or nil
    if not godKey then
        return true
    end

    return lib.integrations.invoke(GOD_AVAILABILITY_INTEGRATION, "isAvailable", true, godKey) ~= false
end

local function BuildPriorityOptions()
    if not IsGodPoolFilteringActive() then
        return internal.priorityOptions
    end

    local values = {}
    for _, value in ipairs(internal.priorityOptions or {}) do
        if IsPriorityLootAvailable(value) then
            values[#values + 1] = value
        end
    end
    return values
end

function internal.DrawSettingsTab(imgui, session)
    internal.DrawSectionHeading(imgui, "Route Reward Priorities", { 0.90, 0.82, 0.56, 1.0 })
    lib.widgets.checkbox(imgui, session, "PrioritizeSpecificRewardEnabled", {
        label = "Choose First Boon in Each Biome",
    })

    if session.view["PrioritizeSpecificRewardEnabled"] == true then
        local priorityOptions = BuildPriorityOptions()
        lib.widgets.dropdown(imgui, session, "PriorityBiome1", {
            label = "Biome 1 Choice",
            values = priorityOptions,
            displayValues = internal.priorityDisplayValues,
            valueColors = internal.priorityValueColors,
            labelWidth = PRIORITY_LABEL_WIDTH,
            controlWidth = 180,
        })
        lib.widgets.dropdown(imgui, session, "PriorityBiome2", {
            label = "Biome 2 Choice",
            values = priorityOptions,
            displayValues = internal.priorityDisplayValues,
            valueColors = internal.priorityValueColors,
            labelWidth = PRIORITY_LABEL_WIDTH,
            controlWidth = 180,
        })
        lib.widgets.dropdown(imgui, session, "PriorityBiome3", {
            label = "Biome 3 Choice",
            values = priorityOptions,
            displayValues = internal.priorityDisplayValues,
            valueColors = internal.priorityValueColors,
            labelWidth = PRIORITY_LABEL_WIDTH,
            controlWidth = 180,
        })
        lib.widgets.dropdown(imgui, session, "PriorityBiome4", {
            label = "Biome 4 Choice",
            values = priorityOptions,
            displayValues = internal.priorityDisplayValues,
            valueColors = internal.priorityValueColors,
            labelWidth = PRIORITY_LABEL_WIDTH,
            controlWidth = 180,
        })
    end

    imgui.Spacing()
    internal.DrawSectionHeading(imgui, "Trial Reward Priorities", { 0.70, 0.84, 0.96, 1.0 })
    lib.widgets.checkbox(imgui, session, "PrioritizeTrialRewardEnabled", {
        label = "Choose Boon Priorities in Trial Rooms",
    })

    if session.view["PrioritizeTrialRewardEnabled"] == true then
        local priorityOptions = BuildPriorityOptions()
        lib.widgets.dropdown(imgui, session, "PriorityTrial1", {
            label = "Trial Choice A",
            values = priorityOptions,
            displayValues = internal.priorityDisplayValues,
            valueColors = internal.priorityValueColors,
            labelWidth = PRIORITY_LABEL_WIDTH,
            controlWidth = 180,
        })
        lib.widgets.dropdown(imgui, session, "PriorityTrial2", {
            label = "Trial Choice B",
            values = priorityOptions,
            displayValues = internal.priorityDisplayValues,
            valueColors = internal.priorityValueColors,
            labelWidth = PRIORITY_LABEL_WIDTH,
            controlWidth = 180,
        })
    end

    imgui.Spacing()
    lib.widgets.separator(imgui)
    imgui.Spacing()
    lib.widgets.confirmButton(imgui, "biome_control_reset_all_settings", "Reset All Controls", {
        confirmLabel = "Confirm Reset All",
        onConfirm = function()
            internal.ResetAllControls(session)
        end,
    })
end
