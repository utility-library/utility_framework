resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

client_scripts {
    "config.lua",
    "client/function.lua",
    "client/framework.lua",
    "client/addons/*.lua",
    "client/commands.lua",
    "client/menu/script.lua",
    "client/internal_addons/skin.lua",
    "client/internal_addons/permanent_object.lua",
}

server_scripts {
    "config.lua",
    "server/function.lua",
    "server/class.lua",
    "server/framework.lua",
    "server/commands.lua",
    "server/internal_addons/permanent_object.lua",
}

ui_page "client/menu/test.html"

files {
    "client/menu/*.*",
    "client/addons/*.*",
    "client/loader.lua",
}

dependencies {
    "oxmysql"
}