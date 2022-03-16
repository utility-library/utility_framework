Config.ResourceTemplate = {
    ["default"] = {
        ["fxmanifest"] = 
[[fx_version "cerulean"
game "gta5"


client_scripts {
"@utility_framework/client/api.lua",
"config.lua",
"client/*.lua",
}

server_scripts {
"@utility_framework/server/api.lua",
"config.lua",
"server/*.lua",
}]],
        ["config"] = "Config = {}\n\n",
        ["client"] = {
            ["main"] = "",
            ["functions"] = "",
            ["events"] = "",
        },
        ["server"] = {
            ["main"] = "",
            ["functions"] = "",
            ["events"] = "",
        },
    }
}
