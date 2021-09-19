--// Variables
    oxmysql  = exports['oxmysql']      -- MySQL
    analizer = addon("analizer")       -- Addon to analyze runtime
    mathm    = addon("math")           -- Addon to perform some long things like rounding of numbers
    ts       = addon("translate")      -- Addon that allow you to auto translate strings

    Utility = {
        -- Variables
        PlayersData = {},
        SocietyData = {},
        UsableItem = {},
        Jobs = {},
        SocietyAlreadySaved = false,

        -- Updated data for the server
        GetuPlayer = function(steam, update) Utility.PlayersData[steam].update = update return Utility.PlayersData[steam] end,
        GetuSociety = function(name) return Utility.SocietyData[name] end,
        
        
        -- Data to transfer
        Token = math.random(0, 999999999999999999),
        GetConfig = function(name) return Config[name] end,
        
        -- Functions
        LogToLogger = LogToLogger,
        GetPlayersWithJob = function(job)
            return Utility.Jobs[job]
        end
    }

--// Startup
    -- TBP: Trigger Basic Protection
    -- Log the token generated
    Utility.LogToLogger("TBP", 'Token generated => "'..Utility.Token..'"')

    -- Select all the users table and create the uPlayer for any users (preload uPlayer)
    Citizen.CreateThread(function()
        -- Database check
        if Config.Database.CheckIfExistOnStart then
            -- If there isnt a table with the comment of the users table of the utility then create the database
            oxmysql:fetchSync("SELECT TABLE_CATALOG FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_COMMENT = 'This is the table where the Utility Framework store all the data for any player'", {}, function(result)
                if result[1] == nil then -- Data is nil (database dont exist)
                    CreateDb()
                else
                    -- Read the whole config.lua file
                    local config = LoadResourceFile("utility_framework", "config.lua")

                    -- Turn off the check
                    config = config:gsub("    CheckIfExistOnStart = true", "    CheckIfExistOnStart = false")

                    -- Override the config.lua with the new data
                    SaveResourceFile("utility_framework", "config.lua", config)

                    -- Warns the server owner that the config.lua has been auto-modified
                    print(ts.translate(Config.DefaultLanguage, Config.Labels["framework"]["DbCheckTurnedOff"]))
                    Utility.LogToLogger("Startup", "Database already exist, turning off Config.Database.CheckIfExistOnStart")
                end
            end)
        end

        -- Real load of players and companies
        analizer.start()
        local playercount = nil
        local societycount = nil

        -- Each player is taken from the users table and is pre-loaded with all the respective functions to be used in the future 
        oxmysql:fetchSync('SELECT name, accounts, inventory, jobs, identity, other_info, steam FROM users', {}, function(users)
            if users == nil then error("Unable to connect with the table `users`, try to check the MySQL status!") return end
            playercount = #users

            for i=1, #users do
                -- function.lua:41
                users[i] = ConvertJsonToTable(users[i], 1)
                -- function.lua:77
                Utility.PlayersData[users[i].steam] = uPlayerPopulate(users[i])
            end
        end)

        -- Each society is taken from the society table and is pre-loaded with all the respective functions to be used in the future (like uPlayer)
        oxmysql:fetchSync('SELECT name, money, deposit, weapon FROM society', {}, function(society)
            if society == nil then error("Unable to connect with the table `society`, try to check the MySQL status!") return end

            societycount = #society
            for i=1, #society do
                -- function.lua:41
                society[i] = ConvertJsonToTable(society[i], 2)
                
                if next(society[i].money or {}) == nil then -- If is a empty table (probably a newly created company) then create the basic data
                    society[i].money = {bank = 0, black = 0}
                end

                -- function.lua:398
                Utility.SocietyData[society[i].name] = uSocietyPopulate(society[i])
            end
        end)

        -- Loaded Message
        local executionTime = math.floor(mathm.round(analizer.finish(), 1))
        
        print(Config.PrintType["startup"]..ts.translate(Config.DefaultLanguage, Config.Labels["framework"]["LoadedMsg"]):format(playercount, "users"))
        print(Config.PrintType["startup"]..ts.translate(Config.DefaultLanguage, Config.Labels["framework"]["LoadedMsg"]):format(societycount, "society"))
        print(Config.PrintType["startup"]..ts.translate(Config.DefaultLanguage, Config.Labels["framework"]["StartedIn"]):format(tostring(executionTime)))

        Utility.LogToLogger("Startup", "Loaded "..playercount.." player and "..societycount.." society in "..executionTime.."ms")
    end)

--// uPlayer and client framework
    -- Send the Utility table to the any server loader that request it (this is one of the most weighty triggers in the framework why have a list with all the players)
    -- Server
    RegisterServerEvent("Utility:LoadServer")
    AddEventHandler("Utility:LoadServer", function(name, cb)
        Utility.LogToLogger("Main", "Loaded the server loader for the resource ["..name.."]")
        cb(Utility)
    end)

    -- Client
    RegisterServerEvent("Utility:Logger")
    AddEventHandler("Utility:Logger", function(name)
        Utility.LogToLogger("Main", "Loaded the client loader for the resource ["..name.."] [ID:"..source.."]")
    end)

    -- Prepares the data to be sent to the client framework, the client framework will receive only the data relevant to its id. 
    -- Note: the data that will be sent can only be read, but not overwritten.
    RegisterServerCallback("Utility:GetPlayerData", function(name)
        Utility.LogToLogger("Main", "Loaded the client framework for the resource ["..name.."] [ID:"..source.."]")
        local steam = GetPlayerIdentifiers(source)[1]
        local uPlayer = Utility.PlayersData[steam]

        if not uPlayer then -- New Player
            uPlayer = GenerateTemplateuPlayer(source, steam)
            uPlayer.IsNew = true

            -- Log
            if Config.Logs.Connection.NewUser then 
                print(Config.PrintType["new"]..ts.translate(Config.DefaultLanguage, Config.Labels["framework"]["ConnectedUser"]):format(uPlayer.name)) 
                Utility.LogToLogger("Main", "New user "..uPlayer.name.." connected and created")
            end
        else -- Old Player
            uPlayer.source = source
            -- Log
            if Config.Logs.Connection.OldUser then 
                print(Config.PrintType["old"]..ts.translate(Config.DefaultLanguage, Config.Labels["framework"]["ConnectedUser"]):format(uPlayer.name)) 
                Utility.LogToLogger("Main", "Old user "..uPlayer.name.." connected")
            end
        end
        
        -- Add to the job the player
        AddToJob(uPlayer.jobs[1].name, uPlayer.source)

        -- Copy the table for sanificate the function
        local uPlayer = CopyTable(uPlayer)

        -- Sanificate function (remove functions)
        for k,v in pairs(uPlayer) do
            if type(v) == "function" then
                uPlayer[k] = nil
            end
        end

        cb(uPlayer)
    end)


--// Database Saving
    AddEventHandler("playerDropped", function(reason)
        -- Society saving
        if reason:find("Server shutting down") then
            if not Utility.SocietyAlreadySaved then
                Utility.LogToLogger("Main", "Saving automatically society why the server is shutting down")
                Utility.SocietyAlreadySaved = true
                
                for k,v in pairs(Utility.SocietyData) do
                    oxmysql:executeSync('UPDATE society SET money = :money, deposit = :deposit, weapon = :weapon WHERE name = :name', {
                        money   = json.encode(v.money),
                        deposit = json.encode(v.deposit or {}),
                        weapon  = json.encode(v.weapon or {}),
                        name    = k
                    })
                end
            end
        end

        local x,y,z = table.unpack(GetEntityCoords(GetPlayerPed(source)))

        --print("Steam = "..steam)
        --print("Coords = ", x,y,z)

        if x ~= 0.0 and y ~= 0.0 then
            analizer.start()
            local uPlayer = Utility.PlayersData[GetPlayerIdentifiers(source)[1]]

            -- function.lua:649
            local query, query_data = GetQueryFromuPlayer(uPlayer, {x=x, y=y, z=z})

            RemoveFromJob(uPlayer.jobs[1].name, uPlayer.source)

            oxmysql:executeSync('UPDATE users SET '..query:sub(1, -2)..' WHERE steam = :steam', query_data)
            Utility.LogToLogger("Main", (uPlayer.name or "Unkown").." ["..(uPlayer.source or "unkown")..";"..(uPlayer.steam or "error").."] Disconnected, saved in "..analizer.finish().."ms")
        end

    end)

    local exitStopped = false

    -- Manual save
    RegisterCommand("utility", function(_, args)
        if args[1] == "save" then
            local i = 0

            for k,v in pairs(Utility.PlayersData) do
                if v.source ~= nil then
                    i = i + 1
                    if GetPlayerPing(v.source) > 0 then
                        analizer.start()
                        local x,y,z = table.unpack(GetEntityCoords(GetPlayerPed(v.source)))
                        local query, query_data = GetQueryFromuPlayer(v, {x=x, y=y, z=z})
                    
                        
                        oxmysql:executeSync('UPDATE users SET '..query:sub(1, -2)..' WHERE steam = :steam', query_data)
                        Utility.LogToLogger("Main", v.name.." Manually saved in "..analizer.finish().."ms")
                    end
                end
            end

            print("[^3INFO^0] Saved "..i.." players")
        elseif args[1] == "exit" then
            print("[^3INFO^0] The server will be ^1shutdown in 10 seconds^0, all players will be ^1kicked^0.  To ^3stop the shutdown^0 process type the command ^4\"utility cexit\"^0")
            Citizen.Wait(10000)

            if not exitStopped then
                local savedPlayers = 0

                for k,v in pairs(Utility.PlayersData) do
                    if v.source ~= nil then -- Have joined in the server?
                        if GetPlayerPing(v.source) > 0 then -- Is online?
                            savedPlayers = savedPlayers + 1
                            DropPlayer(v.source, "Server shutting down\nSource: \"utility exit\" command")
                            Citizen.Wait(10)
                        end
                    end
                end
                
                print("[^3INFO^0] Saved "..savedPlayers.." players")

                --If there is no player then save the company
                if not Utility.SocietyAlreadySaved then
                    local societySaved = 0
                    Utility.LogToLogger("Main", "Saving society why the server is shutting down")
                    
                    Utility.SocietyAlreadySaved = true
                    for k,v in pairs(Utility.SocietyData) do
                        societySaved = societySaved + 1
                        oxmysql:executeSync('UPDATE society SET money = :money, deposit = :deposit, weapon = :weapon WHERE name = :name', {
                            money   = json.encode(v.money),
                            deposit = json.encode(v.deposit or {}),
                            weapon  = json.encode(v.weapon or {}),
                            name    = k
                        })
                    end
                    print("[^3INFO^0] Saved "..societySaved.." societies")
                end

                Citizen.Wait(1000)
                os.exit()
            else
                exitStopped = false
            end
        elseif args[1] == "cexit" then
            exitStopped = true
        end
    end, true)

--// Ammo sync
    RegisterServerEvent("Utility:Weapon:SyncAmmo")
    AddEventHandler("Utility:Weapon:SyncAmmo", function(steam, weapon, ammo)
        local weapon_data = Utility.PlayersData[steam].other_info.weapon

        weapon_data[weapon] = ammo
    end)

--// Triggers
    -- Weapon
    RegisterServerEvent("Utility:Weapon")
    AddEventHandler("Utility:Weapon", function(steam, type, weapon, ammo)
        local weapon_data = Utility.PlayersData[steam].other_info.weapon

        if type == 1 then -- Give
            if weapon_data == nil then weapon_data = {} end

            weapon_data[weapon] = ammo
        elseif type == 2 then -- Remove
            if weapon_data[weapon] then 
                weapon_data[weapon] = nil 
            end
        end
    end)





RegisterServerEvent("Utility_Usable:SetItemUsable")
AddEventHandler("Utility_Usable:SetItemUsable", function(name)
    Utility.UsableItem[name] = true
end)


RegisterServerEvent("Utility:SetDeath")
AddEventHandler("Utility:SetDeath", function(steam, death, info)
    if Config.Actived.No_Rp.KillDeath then
        if info ~= nil and info.killer ~= 0 then
            local killerSteam = GetPlayerIdentifiers(info.killer)[1]
            if Utility.PlayersData[steam].other_info.kill == nil then Utility.PlayersData[steam].other_info.kill = 0 end


            Utility.PlayersData[killerSteam].other_info.kill = Utility.PlayersData[killerSteam].other_info.kill + 1
        end

        if Utility.PlayersData[steam].other_info.death == nil then Utility.PlayersData[steam].other_info.death = 0 end
        Utility.PlayersData[steam].other_info.death = Utility.PlayersData[steam].other_info.death + 1
    end
    
    Utility.PlayersData[steam].other_info.isdeath = death
end)

RegisterServerCallback("Utility:GetTriggerKey", function()
    cb(Utility.Token)
end)

if Config.Actived.Salaries then
    Citizen.CreateThread(function()
        local Wait = nil
        local WaitMultiplier = 0
        
        if Config.Jobs.Salaries.Interval:find("ms") then
            Wait = tonumber(Config.Jobs.Salaries.Interval:gsub("ms", ""))
            WaitMultiplier = 0
        elseif Config.Jobs.Salaries.Interval:find("s") then
            Wait = tonumber(Config.Jobs.Salaries.Interval:gsub("s", ""))
            WaitMultiplier = 1000
        elseif Config.Jobs.Salaries.Interval:find("m") then
            Wait = tonumber((Config.Jobs.Salaries.Interval:gsub("m", "")))
            WaitMultiplier = 60000
        end

        while true do
            Citizen.Wait(1000)
            for k,v in pairs(Utility.PlayersData) do
                if v.source ~= nil and GetPlayerPing(v.source) > 0 then
                    for i=1, #v.jobs do
                        if Config.Jobs.Salaries[i][v.jobs[i].name] then
                            local moneyToGive = Config.Jobs.Salaries[i][v.jobs[i].name][v.jobs[i].grade]

                            v.accounts["bank"] = v.accounts["bank"] + (moneyToGive or 0)
                        end
                    end
                end
            end

            Utility.LogToLogger("Main", "Given salary to all players, next salary between "..Wait * WaitMultiplier.."ms")
            Citizen.Wait(Wait * WaitMultiplier)
        end
    end)
end

-- Explosion
if Config.Addons.DisableExplosion then
    AddEventHandler('explosionEvent', function(sender, ev)
        Utility.LogToLogger("Explosion", "Cancelled explosion created by ["..sender.."] "..json.encode(ev).."")
        CancelEvent()
    end)
end

-- Steam Check
AddEventHandler("playerConnecting", function(name, setKickReason, deferrals)
    local identifiers = GetPlayerIdentifiers(source)

    if not identifiers[1]:find("steam") then
        Utility.LogToLogger("Main", "The player "..name.." dont have steam opened")

        CancelEvent()
        setKickReason("Utility Framework: Unable to find SteamId, please relaunch FiveM with steam open or restart FiveM & Steam if steam is already open")
    end
end)

function LoadServer()
    return LoadResourceFile("utility_framework", "server/loader.lua")
end

exports(LoadServer)