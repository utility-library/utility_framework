StartupCheck = function()
    local startup = io.open("setup.utility", "r")
    
    if not startup then
        Citizen.Wait(500)
        print(ts.translate(Config.DefaultLanguage, Config.Labels["framework"]["WelcomeMsg"]))
        Citizen.Wait(15000)

        print("[^3!^0] Dont shutdown the server during this setup")

        local scfg = io.open("server.cfg", "r")
        local _scfg = scfg:read("*a")
        scfg:close()

        local scfg = io.open("server.cfg", "w")
        scfg:write("# Utility Framework\nadd_ace resource.utility_framework command allow\nstart oxmysql\nstart utility_framework\nset mysql_connection_string \"mysql://root@localhost/utility?charset=utf8mb4\" # Database Connection\n\n".._scfg)
        scfg:close()

        print("[^2+^0] Injected ACE Permissions + MySQL connection string in the server.cfg")

        local identifier = tostring(mathm.random(10) + os.time())
        SaveResourceFile(GetCurrentResourceName(), "files/server-identifier.utility", identifier)

        print("[^2+^0] Created server identifier: "..identifier)
        
        io.open("setup.utility", "a"):close()
        Citizen.Wait(500)

        print("[^1!^0] You can now inject the database from ^3files/db.sql^0, in 10 seconds txAdmin will restart the server or you can restart it manually")
        
        Citizen.Wait(1500)
        os.execute("start "..GetResourcePath(GetCurrentResourceName()).."/files")
        Citizen.Wait(8500)
        
        os.exit() -- Restart the server 
        return false
    else
        startup:close()
    end

    if GetConvar("onesync") == "off" then
        Citizen.Wait(500)
        print(Config.PrintType["attention"].."^1OneSync its off, please set it on.^0")
        return false
    end

    return true
end

StartupMessage = function(player, vehicle, stashes)
    local executionTime = math.floor(mathm.round(analizer.finish(), 1))
    
    print(Config.PrintType["startup"]..ts.translate(Config.DefaultLanguage, Config.Labels["framework"]["LoadedMsg"]):format(player, "users"))
    print(Config.PrintType["startup"]..ts.translate(Config.DefaultLanguage, Config.Labels["framework"]["LoadedMsg"]):format(vehicle, "vehicles"))
    print(Config.PrintType["startup"]..ts.translate(Config.DefaultLanguage, Config.Labels["framework"]["LoadedMsg"]):format(stashes, "stashes"))

    local path = GetResourcePath("utility_framework")
    path = path:gsub('//', '/')
    path = path:gsub("/", "\\")

    os.execute('ForFiles /p "'..(path)..'\\logs" /s /d -7 /c "cmd /c del @file"')
    print(Config.PrintType["startup"]..ts.translate(Config.DefaultLanguage, Config.Labels["framework"]["DeletedOldLogs"]))

    print(Config.PrintType["startup"]..ts.translate(Config.DefaultLanguage, Config.Labels["framework"]["StartedIn"]):format(tostring(executionTime)))

    Log("Startup", "Loaded "..player.." player, "..vehicle.." vehicles and "..stashes.." stashes in "..executionTime.."ms")
    
    Utility.DatabaseLoaded = true


    -- Regenerate the static pos     
    local config = LoadResourceFile(GetCurrentResourceName(), "config.lua")

    config = config:gsub("Pos = (%d+)", "Pos = "..math.random(1, 100).."")

    SaveResourceFile(GetCurrentResourceName(), "config.lua", config)
end