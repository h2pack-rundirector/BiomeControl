local module = {}
local definitions
local catalog
local components

local function getRewardControl(kindOrAlias)
    for _, control in ipairs(catalog.biomeRewards.N or {}) do
        if control.kind == kindOrAlias or control.alias == kindOrAlias then
            return control
        end
    end
end

local function drawHubReplacement(imgui, session, control)
    if not control then return end

    local hubRewardReplacementOptions = { "" }
    local hubRewardReplacementDisplayValues = {
        [""] = "Hermes (Default)",
    }

    for _, god in ipairs(definitions.priorityGods or {}) do
        hubRewardReplacementOptions[#hubRewardReplacementOptions + 1] = god.lootKey
        hubRewardReplacementDisplayValues[god.lootKey] = god.label
    end

    lib.widgets.dropdown(imgui, session, control.alias, {
        label = control.label or "Hub Hermes Replacement",
        tooltip = control.helpText,
        values = hubRewardReplacementOptions,
        displayValues = hubRewardReplacementDisplayValues,
        labelWidth = 160,
        controlWidth = 180,
    })
end

local function drawPackedRewardList(imgui, session, control)
    if not control then return end

    imgui.Spacing()
    lib.widgets.text(imgui, control.label, {
        tooltip = control.helpText,
    })
    lib.widgets.packedCheckboxList(imgui, session, control.alias, {
        slotCount = #(control.options or {}),
    })
end

local function drawEphyraRewards(imgui, session)
    components.DrawSectionHeading(imgui, "Rewards", { 0.70, 0.84, 0.96, 1.0 })
    drawHubReplacement(imgui, session, getRewardControl("field"))
    drawPackedRewardList(imgui, session, getRewardControl("PackedBannedEphyraSubRoomRewards"))
    drawPackedRewardList(imgui, session, getRewardControl("PackedBannedEphyraSubRoomRewardsHard"))
end

function module.draw(imgui, session)
    components.DrawSectionHeading(imgui, "Rooms", { 0.90, 0.82, 0.56, 1.0 })
    components.DrawModeRow(imgui, session, catalog, "EphyraStoryMode", nil, 150)

    imgui.Spacing()
    components.DrawSectionHeading(imgui, "Minibosses", { 0.88, 0.38, 0.32, 1.0 })
    components.DrawModeRow(imgui, session, catalog, "EphyraMiniBossMode", nil, 250)

    imgui.Spacing()
    drawEphyraRewards(imgui, session)
    return true
end

function module.bind(deps)
    definitions = deps.definitions
    catalog = deps.catalog
    components = deps.components
    return module
end

return module
