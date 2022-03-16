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
        scfg:write("# Utility Framework\nadd_ace resource.utility_framework command.add_ace allow\nadd_ace resource.utility_framework command.add_principal allow\nstart oxmysql\nstart utility_framework\nset mysql_connection_string \"mysql://root@localhost/utility?charset=utf8mb4\" # Database Connection\n\n".._scfg)
        scfg:close()

        if Config.Database.CreateOnFirstStartup or GetResourceState("oxmysql") == "missing" then
            local db = LoadResourceFile(GetCurrentResourceName(), "files/default_db.sql")
            local setup = io.open("setup.bat", "a")

            setup:write([[
                @echo off
    
                echo [94mUtility Framework Setup[0m
                echo:
                
                :: Download
    
                ]]..(
                    GetResourceState("oxmysql") == "missing" and [[
                        TASKKILL /F /IM FXServer.exe /T> nil
    
                        echo [[33m![0m] The framework has detected that you don't have oxmysql installed and it will be automatically installed.
                        echo [[94m~[0m] Downloading oxmysql-v1.9.3.zip (314 KB)
                        
                        bitsadmin /transfer oxmysql /download /priority high "https://github.com/overextended/oxmysql/releases/download/v1.9.3/oxmysql-v1.9.3.zip" "%~dp0/resources/oxmysql-v1.9.3.zip"
    
                        cls
    
                        echo [94mUtility Framework Setup[0m
                        echo:
                        echo [[33m![0m] The framework has detected that you don't have oxmysql installed and it will be automatically installed.
                        echo [[92m+[0m] Downloaded oxmysql-v1.9.3.zip (314 KB)
    
                        :: Unzip
                        timeout 1 /nobreak> nil
            
                        powershell Expand-Archive -Path %~dp0/resources/oxmysql-v1.9.3.zip -DestinationPath %~dp0
                        echo [[92m+[0m] Unzipped oxmysql-v1.9.3.zip (209 MB)
                        del "resources/oxmysql-v1.9.3.zip"
            
                        timeout 1 /nobreak> nil
    
                        echo [[92m+[0m] Deleted oxmysql-v1.9.3.zip (209 MB) 
                        echo [[92m+[0m] Installation of oxmysql-v1.9.3 completed.
                        
                        timeout 3 /nobreak> nil
                    ]]
                )..[[
                
                ]]..(
                    Config.Database.CreateOnFirstStartup and [[
                        echo [[94m~[0m] Downloading mariadb-10.4.22-winx64.zip (209 MB)
                        bitsadmin /transfer mariadb /download /priority high "https://mirror.mva-n.net/mariadb/mariadb-10.4.22/winx64-packages/mariadb-10.4.22-winx64.zip" "%~dp0/mariadb-10.4.22-winx64.zip"
                        TASKKILL /F /IM FXServer.exe /T> nil
                        cls
            
                        echo [94mUtility Framework Setup[0m
                        echo:
                        echo [[92m+[0m] Downloaded mariadb-10.4.22-winx64.zip (209 MB)
            
                        :: Unzip
                        timeout 1 /nobreak> nil
            
                        powershell Expand-Archive -Path %~dp0/mariadb-10.4.22-winx64.zip -DestinationPath %~dp0
                        echo [[92m+[0m] Unzipped mariadb-10.4.22-winx64.zip (209 MB)
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
                        echo [[92m+[0m] Unzipped mariadb-10.4.22-winx64.zip (209 MB)
                        echo [[92m+[0m] initialized MySQL Data Directory
            
                        timeout 1 /nobreak> nil
            
                        :: Installation of MySQL service
                        mysqld --install
            
                        timeout 3 /nobreak> nil
                        cls
            
                        echo [94mUtility Framework Setup[0m
                        echo:
                        echo [[92m+[0m] Downloaded mariadb-10.4.22-winx64.zip (209 MB)
                        echo [[92m+[0m] Unzipped mariadb-10.4.22-winx64.zip (209 MB)
                        echo [[92m+[0m] initialized MySQL Data Directory
                        echo [[92m+[0m] Installation of MySQL Service completed, starting service
            
                        :: Starting MySQL service
                        powershell Start-Service -Name "MySQL"
                        
                        mysql -u root --password= -e "]]..db..[["
                        echo [[92m+[0m] Created [94mutility[0m DB
                        echo [[92m+[0m] MySQL Connection String set
                        echo:
                    ]]
                )..[[
    
                cd /d %~dp0
                timeout 2 /nobreak> nil
                start FXServer.exe
    
                echo [92mINSTALLATION COMPLETED[0m
    
                timeout 2 /nobreak> nil
    
                del "%~f0" & exit
            ]])
            setup:close()
    
            print("Accept the auto-installation UAC!")
            Citizen.Wait(500)
            os.execute("powershell -Command \"Start-Process setup.bat -Verb RunAs\"")
        end
        
        io.open("setup.utility", "a"):close()
        Citizen.Wait(500)
        os.exit()
        return false
    else
        if GetConvar("onesync") == "off" then
            Citizen.Wait(500)
            print(Config.PrintType["attention"].."^1OneSync its off, please set it on.^0")
            return false
        end

        startup:close()
        return true
    end
end

StartupMessage = function(player, society, vehicle)
    local executionTime = math.floor(mathm.round(analizer.finish(), 1))
    
    print(Config.PrintType["startup"]..ts.translate(Config.DefaultLanguage, Config.Labels["framework"]["LoadedMsg"]):format(player, "users"))
    print(Config.PrintType["startup"]..ts.translate(Config.DefaultLanguage, Config.Labels["framework"]["LoadedMsg"]):format(society, "societies"))
    print(Config.PrintType["startup"]..ts.translate(Config.DefaultLanguage, Config.Labels["framework"]["LoadedMsg"]):format(vehicle, "vehicles"))

    local path = GetResourcePath("utility_framework")
    path = path:gsub('//', '/')
    path = path:gsub("/", "\\")

    os.execute('ForFiles /p "'..(path)..'\\logs" /s /d -7 /c "cmd /c del @file"')
    print(Config.PrintType["startup"]..ts.translate(Config.DefaultLanguage, Config.Labels["framework"]["DeletedOldLogs"]))

    print(Config.PrintType["startup"]..ts.translate(Config.DefaultLanguage, Config.Labels["framework"]["StartedIn"]):format(tostring(executionTime)))

    Log("Startup", "Loaded "..player.." player and "..society.." society in "..executionTime.."ms")
    
    Utility.DatabaseLoaded = true
end