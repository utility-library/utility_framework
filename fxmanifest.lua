fx_version "cerulean"
game "gta5"

client_scripts {
    "config.lua",
    "configs/*.lua",
    "client/functions.lua",
    "client/variables.lua",
    "client/init/*.lua",
    "client/managers/*.lua",
    "client/builders/*.lua",
    "client/commands.lua",
    "client/events.lua",
    "client/main.lua",
}

server_scripts {
    "@oxmysql/lib/MySQL.lua",
    "config.lua",
    "configs/*.lua",
    "server/functions.lua",
    "server/init/*.lua",
    "server/variables.lua",
    
    "server/managers/*.lua",
    "server/builders/*.lua",
    "server/commands.lua",
    "server/events.lua",

    "server/main.lua",
}


server_export {
    "GetPlayer",
    "GetUtilityPlayers",
    "GetVehicle",
    "GetSociety",
    "Log",
    "GetConfig",
    "SetItemUsable",
    "RegisterSharedFunction",
}

files {
    "server/addons/*.lua",
    "client/addons/*.lua",
    "client/api.lua",
    "client/html/**/*.*"
}

ui_page "client/html/test.html"

dependencies {
    "oxmysql"
}

lua54 "yes"