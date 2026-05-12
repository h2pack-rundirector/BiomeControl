local fields = {
    id = "fields",
}

fields.controls = {
    stateFields = {
        { type = "checkbox", alias = "PreventEchoScam", label = "Prevent Echo Scam" },
        { type = "checkbox", alias = "ForceTwoRewardFieldsOpeners", label = "Force 2 Rewards In First Two Rooms" },
    },
    biomeSpecials = {
        H = {
            {
                kind = "checkbox",
                alias = "PreventEchoScam",
                label = "Prevent Echo Scam",
                helpText = "(Prevent miniboss from spawning in same depth as Echo, which can prevent it from spawning at all)",
            },
            {
                kind = "checkbox",
                alias = "ForceTwoRewardFieldsOpeners",
                label = "Force 2 Rewards In First Two Rooms",
                helpText = "(Force normal H combat encounters to offer exactly 2 rewards at biome depth 1 and 2; " ..
                    "vanilla 3-reward promotion resumes after depth 2)",
            },
        },
    },
}

return fields
