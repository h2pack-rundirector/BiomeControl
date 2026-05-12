local thessaly = {
    id = "thessaly",
}

local THESSALY_MINIBOSS_MODE_OPTIONS = { "default", "charybdis", "captain", "disabled" }
local THESSALY_MINIBOSS_MODE_DISPLAY = {
    default = "Default",
    charybdis = "Force Charybdis",
    captain = "Force The Yargonaut",
    disabled = "Disable Both",
}
local THESSALY_MINIBOSS_RANGE_MIN_ALIAS = "PackedForcedThessalyMiniBossMin"
local THESSALY_MINIBOSS_RANGE_MAX_ALIAS = "PackedForcedThessalyMiniBossMax"

thessaly.controls = {
    rangeFields = {
        {
            label = "Forced Range",
            rangeMinAlias = THESSALY_MINIBOSS_RANGE_MIN_ALIAS,
            rangeMaxAlias = THESSALY_MINIBOSS_RANGE_MAX_ALIAS,
            min = 3,
            max = 5,
        },
    },
    biomeRooms = {
        O = {
            {
                kind = "modeField",
                label = "Miniboss",
                roomGroup = "MiniBoss",
                modeKey = "ThessalyMiniBossMode",
                modeValues = THESSALY_MINIBOSS_MODE_OPTIONS,
                modeDisplayValues = THESSALY_MINIBOSS_MODE_DISPLAY,
                defaultMode = "default",
                helpText = "(Default lets the game decide, Forced selects one miniboss, Disabled suppresses both)",
            },
        },
    },
}

return thessaly
