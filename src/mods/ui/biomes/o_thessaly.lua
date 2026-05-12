local module = {}
local definitions
local catalog
local components

local ROOM_SECTION = {
    label = "Rooms",
    types = { "Story", "Trial", "Fountain", "Shop" },
    color = { 0.70, 0.64, 0.95, 1.0 },
}

local function getThessalyRangeField()
    for _, field in ipairs(catalog.rangeFields or {}) do
        if field.rangeMinAlias == "PackedForcedThessalyMiniBossMin" then
            return field
        end
    end
end

local function drawThessalyMinibossRow(imgui, session)
    local rangeColumnGap = 20
    components.DrawModeRow(imgui, session, catalog, "ThessalyMiniBossMode", nil, 200)

    local mode = catalog.GetModeValue(function(key)
        return session.view[key]
    end, "ThessalyMiniBossMode")
    local rangeField = getThessalyRangeField()
    if rangeField and (mode == "charybdis" or mode == "captain") then
        imgui.SameLine()
        imgui.SetCursorPosX(imgui.GetCursorPosX() + rangeColumnGap)
        components.DrawRangeDropdowns(
            imgui,
            session,
            rangeField.rangeMinAlias,
            rangeField.rangeMaxAlias,
            rangeField.min,
            rangeField.max
        )
    end
end

function module.draw(imgui, session)
    components.DrawRoomSection(imgui, session, definitions, catalog, "O", ROOM_SECTION)

    components.DrawSectionHeading(imgui, "Minibosses", { 0.88, 0.38, 0.32, 1.0 })
    drawThessalyMinibossRow(imgui, session)
    return true
end

function module.bind(deps)
    definitions = deps.definitions
    catalog = deps.catalog
    components = deps.components
    return module
end

return module
