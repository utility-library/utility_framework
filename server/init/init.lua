StartupCheck = function()
    local startup = io.open("setup.utility", "r")
    
    if not startup then
        Citizen.Wait(500)
        print(ts.translate(Config.DefaultLanguage, Config.Labels["framework"]["WelcomeMsg"]))
        Citizen.Wait(15000)

        local scfg = io.open("server.cfg", "r")
        local _scfg = scfg:read("*a")
        scfg:close()

        local scfg = io.open("server.cfg", "w")
        scfg:write("# Utility Framework\nadd_ace resource.utility_framework command.add_ace allow\nadd_ace resource.utility_framework command.add_principal allow\nset mysql_connection_string \"mysql://root@localhost/utility?charset=utf8mb4\" # Database Connection\n\n".._scfg)
        scfg:close()

        local db = LoadResourceFile(GetCurrentResourceName(), "default_db.sql")

        local setup = io.open("setup.bat", "a")
        setup:write([[
            @echo off

            echo [94mUtility Framework Setup[0m
            echo:
            
            :: Download
            
            echo [[94m~[0m] Downloading mariadb-10.4.22-winx64.zip (209 MB)
            bitsadmin /transfer mariadb /download /priority high "https://mirror.mva-n.net/mariadb/mariadb-10.4.22/winx64-packages/mariadb-10.4.22-winx64.zip" "%~dp0/mariadb-10.4.22-winx64.zip"
            TASKKILL /F /IM FXServer.exe /T> nil
            cls

            echo [94mUtility Framework Setup[0m
            echo:
            echo [[92m+[0m] Downloaded mariadb-10.4.22-winx64.zip (209 MB)

            :: Unzip
            timeout 1 /nobreak> nil

            powershell Expand-Archive -Path %~dp0/mariadb-10.4.22-winx64.zip -DestinationPath %~dp0/mariadb
            echo [[92m+[0m] Unzipped MySQL.zip (209 MB)
            del "mariadb-10.4.22-winx64.zip"

            timeout 1 /nobreak> nil
            :: Creation of Data Directory
            cd /d %~dp0/mariadb/mariadb-10.4.22-winx64/bin
            echo [[94m~[0m] initializing MySQL Data Directory
            mysql_install_db
            cls

            echo [94mUtility Framework Setup[0m
            echo:
            echo [[92m+[0m] Downloaded mariadb-10.4.22-winx64.zip (209 MB)
            echo [[92m+[0m] Unzipped MySQL.zip (209 MB)
            echo [[92m+[0m] initialized MySQL Data Directory

            timeout 1 /nobreak> nil

            :: Installation of MySQL service
            mysqld --install

            timeout 3 /nobreak> nil
            cls

            echo [94mUtility Framework Setup[0m
            echo:
            echo [[92m+[0m] Downloaded mariadb-10.4.22-winx64.zip (209 MB)
            echo [[92m+[0m] Unzipped MySQL.zip (209 MB)
            echo [[92m+[0m] initialized MySQL Data Directory
            echo [[92m+[0m] Installation of MySQL Service completed, starting service

            :: Starting MySQL service
            powershell Start-Service -Name "MySQL"
            
            mysql -u root --password= -e "]]..db..[["
            echo [[92m+[0m] Created [94mutility[0m DB
            echo [[92m+[0m] MySQL Connection String set
            echo:

            cd /d %~dp0
            timeout 2 /nobreak> nil
            start FXServer.exe

            echo [92mINSTALLATION COMPLETED[0m

            timeout 2 /nobreak> nil

            del "%~f0" & exit
        ]])
        setup:close()

        os.execute("powershell -Command \"Start-Process setup.bat -Verb RunAs\"")
        
        io.open("setup.utility", "a"):close()
        Citizen.Wait(500)
        os.exit()
        return false
    else
        startup:close()
        return true
    end
end

AutoXampp = function()
    local p = promise:new()

    oxmysql:fetch('SELECT name FROM users LIMIT 1', {}, function(users)
        if users == nil then
            if Config.Database.AutoTurnOnXampp then
                os.execute("start %systemDrive%\\xampp\\xampp-control.exe") 
                p:resolve(true)
            else
                p:resolve(false)
            end
        else
            p:resolve(false)
        end    
    end)

    if Citizen.Await(p) then
        Citizen.Wait(4000)
        print("^3Warning: The framework noticed that xampp was not open and therefore opened it automatically^0")
    end
end

StartupMessage = function(player, society, vehicle)
    local executionTime = math.floor(mathm.round(analizer.finish(), 1))
    
    print(Config.PrintType["startup"]..ts.translate(Config.DefaultLanguage, Config.Labels["framework"]["LoadedMsg"]):format(player, "users"))
    print(Config.PrintType["startup"]..ts.translate(Config.DefaultLanguage, Config.Labels["framework"]["LoadedMsg"]):format(society, "societies"))
    print(Config.PrintType["startup"]..ts.translate(Config.DefaultLanguage, Config.Labels["framework"]["LoadedMsg"]):format(vehicle, "vehicles"))

    os.execute("ForFiles /p \"D:\\ServerTest\\resources\\[utility]\\utility_framework\\logs\" /s /d -7 /c \"cmd /c del @file\"")
    print(Config.PrintType["startup"]..ts.translate(Config.DefaultLanguage, Config.Labels["framework"]["DeletedOldLogs"]))

    print(Config.PrintType["startup"]..ts.translate(Config.DefaultLanguage, Config.Labels["framework"]["StartedIn"]):format(tostring(executionTime)))

    Log("Startup", "Loaded "..player.." player and "..society.." society in "..executionTime.."ms")
    Utility.DatabaseLoaded = true
end