-- Utility Internal
    RegisterCommand("utility", function(source, args)
        if source == 0 then
            if args[1] == "exit" then
                for k,v in ipairs(GetPlayers()) do
                    DropPlayer(v, "Server shutted down from the console")
                end
                Citizen.Wait(100)
                SaveVehicles()
                SaveStashes()
                Citizen.Wait(100)
                os.exit()
            elseif args[1] == "save" then
                SaveVehicles()
                SaveStashes()
            elseif args[1] == "create" then
                if not args[2] then
                    print("^1You need to insert the resource name^0 (example: utility create test)")
                    return
                end
                if not args[3] or not Config.ResourceTemplate[args[3]] then
                    args[3] = "default"
                end

                local path = GetResourcePath("utility_framework")
                path = path:gsub("resources/(.*)", "resources/")
                path = path:gsub("/", "\\")
                path = path .. (args[2] or "utility_resource")
                os.execute("mkdir "..path)

                for k,v in pairs(Config.ResourceTemplate[args[3]]) do
                    if type(v) == "string" then -- Create file
                        CreateFile(path.."\\"..k..".lua", v)
                    elseif type(v) == "table" then -- Is a directory
                        os.execute("mkdir "..(path.."\\"..k))

                        for k2, v2 in pairs(v) do -- Create file in directory
                            CreateFile((path.."\\"..k.."\\").. k2..".lua", v2)
                        end
                    end
                end

                print("Resource ^2"..(args[2] or "utility_resource").."^0 created, ^4Happy coding^0!")

            elseif args[1] == "convert" then
                if args[2] == "esx" then
                    if args[3] == "all" then
                        local resources = GetResources()

                        for i=1, #resources do
                            local resource = resources[i]
                            local subd = GetResourceLuaFiles(resource)
                            
                            for i=1, #subd do
                                local output = ConvertFramework(ESXConvertTemplate, resource, subd[i])
                                local relativepath = subd[i]:gsub(GetResourcePath(resource), "")
                                print("Converted ^2"..relativepath.."^0 ("..resource..")")
    
                                SaveResourceFile(resource, subd[i], output)
                            end
                        end

                        print("^1Conversion completed, restart the server!^0")
                    else
                        --print("Started converter esx")
                        local resource = args[3]
    
                        if GetResourceState(resource) ~= "missing" then
                            local subd = GetResourceLuaFiles(resource)
                            --print("Resource Lua Files ^1"..json.encode(subd).."^0")
    
                            for i=1, #subd do
                                local output = ConvertFramework(ESXConvertTemplate, resource, subd[i])
                                local relativepath = subd[i]:gsub(GetResourcePath(resource), "")
                                print("Converted ^2"..relativepath.."^0")
    
                                SaveResourceFile(resource, subd[i], output)
                            end
    
                            print("^1Conversion completed^0")
                        else
                            print(Config.PrintType["error"].." Resource \""..resource.."\" doesn't exist!")
                            --print("Resource dont exist")
                        end
                    end
                end
            elseif args[1] == "unfreeze" then
                local identifier = args[2]
                
                local PlayersFrozen = LoadResourceFile(GetCurrentResourceName(), "files/PlayersFrozen.json")

                local lines = ""
                for line in string.gmatch(PlayersFrozen,'[^\r\n]+') do 
                    if line:find(identifier) then
                        local player = json.decode(line)

                        MySQL.Sync.execute("INSERT INTO users (identifier, name, accounts, identity, jobs, inventory, licenses, weapons, coords) VALUES (:identifier, :name, :accounts, :identity, :jobs, :inventory, :licenses, :weapons, :coords)", player)
                        print("Player ^2"..player.name.."^0 successfully ^4unfrozen^0, good morning sleeping beauty!")
                    else
                        lines = lines .. line .."\n"
                    end
                end

                SaveResourceFile(GetCurrentResourceName(), "files/PlayersFrozen.json", lines)

            elseif args[1] == "freeze" then
                local identifier = args[2]
                local PlayersFrozen = LoadResourceFile(GetCurrentResourceName(), "files/PlayersFrozen.json")

                local player = MySQL.Sync.fetchAll('SELECT name, accounts, identity, jobs, inventory, licenses, weapons, coords FROM users WHERE identifier = :identifier LIMIT 1', {
                    identifier = identifier
                })
                MySQL.Async.execute("DELETE FROM users WHERE identifier = :identifier", {identifier = identifier})

                PlayersFrozen = PlayersFrozen..json.encode(player[1]).."\n"
                SaveResourceFile(GetCurrentResourceName(), "files/PlayersFrozen.json", PlayersFrozen)
                
                print("Player ^2"..player[1].name.."^0 successfully ^4frozen^0, good night!")
            elseif args[1] == "report" then
                os.execute('start "" "https://github.com/XenoS-ITA/utility_framework/issues/new?assignees=&labels=bug&template=bug_report.md&title=%5BBUG%5D"')
                print("^2Report opened, please fill the form^0")
                
            end
        end
    end, true)


-- Weapon
    RegisterCommand("giveweapon", function(source, args)
        local uPlayer = GetPlayer(source)

        if source == 0 or uPlayer.group ~= "user" and args[1] and args[2] and args[3] then
            if args[1] == "0" then args[1] = source end

            local uPlayer = GetPlayer(tonumber(args[1]))

            if uPlayer then
                uPlayer.AddWeapon(args[2], tonumber(args[3]))
            end
        end
    end)

    RegisterCommand("removeweapon", function(source, args)
        local uPlayer = GetPlayer(source)

        if source == 0 or uPlayer.group ~= "user" and args[1] and args[2] then
            if args[1] == "0" then args[1] = source end

            local uPlayer = GetPlayer(tonumber(args[1]))
            uPlayer.RemoveWeapon(args[2])
        end
    end)

    RegisterCommand("clearweapon", function(source, args)
        local uPlayer = GetPlayer(source)

        if source == 0 or uPlayer.group ~= "user" then
            if args[1] == "0" or args[1] == nil then args[1] = source end

            local uPlayer = GetPlayer(tonumber(args[1]))
            
            for name, ammo in pairs(uPlayer.GetWeapons()) do
                uPlayer.RemoveWeapon(name)
            end
        end
    end)

-- Death
    RegisterCommand("revive", function(source, args)
        local uPlayer = GetPlayer(source)

        if source == 0 or uPlayer.group ~= "user" then
            if args[1] == "0" or args[1] == nil then args[1] = source end

            local uTarget = GetPlayer(tonumber(args[1]))

            if uTarget then
                uTarget.Revive()
            else
                uPlayer.ShowNotification("There are no players with that id online")
            end
        end
    end)

-- Admin
    RegisterCommand("goto", function(source, args)
        local uPlayer = GetPlayer(source)
        
        if source == 0 or uPlayer.group ~= "user" and args[1] then
            local player = GetPlayerPed(tonumber(args[1]))
            
            SetEntityCoords(GetPlayerPed(source), GetEntityCoords(player))
        end
    end)

    RegisterCommand("bring", function(source, args)
        local uPlayer = GetPlayer(source)
        
        if source == 0 or uPlayer.group ~= "user" and args[1] then
            local player = GetPlayerPed(tonumber(args[1]))

            SetEntityCoords(player, GetEntityCoords(GetPlayerPed(source)))
        end
    end)

-- Item
    RegisterCommand("giveitem", function(source, args)
        local uPlayer = GetPlayer(source)
        
        if source == 0 or uPlayer.group ~= "user" then
            if args[1] == "0" then 
                args[1] = source 
            else
                uPlayer = GetPlayer(tonumber(args[1]))
            end

            uPlayer.AddItem(args[2], tonumber(args[3]))
        end
    end)
    RegisterCommand("removeitem", function(source, args)
        local uPlayer = GetPlayer(source)
        
        if source == 0 or uPlayer.group ~= "user" then
            if args[1] == "0" then args[1] = source end

            uPlayer.RemoveItem(args[2], tonumber(args[3]))
        end
    end)



    -- Probably to remove
    RegisterCommand("getinv", function(source, args)
        local uPlayer = GetPlayer(source)
        
        if source == 0 or uPlayer.group ~= "user" then
            if args[1] then
                uPlayer = GetPlayer(tonumber(args[1]))
            end

            print(json.encode(uPlayer.inventory, {index = true}))
        end
    end)
    RegisterCommand("getweight", function(source, args)
        local uPlayer = GetPlayer(source)
        
        if source == 0 or uPlayer.group ~= "user" then
            if args[1] then
                uPlayer = GetPlayer(tonumber(args[1]))
            end

            if Config.Inventory.Type == "weight" then
                -- "MaxWeight = 300 Weight = 5"
                print("MaxWeight = "..uPlayer.MaxWeight().." Weight = "..uPlayer.Weight())
            elseif Config.Inventory.Type == "limit" then
                -- "Water Limit = 5, Can carry water = false"
                print("Water Limit = "..uPlayer.GetItem("water").limit..", Can carry water = "..tostring(uPlayer.CanCarryItem("water", 6)))
            end
        end
    end)

-- Job
    RegisterCommand("setjob", function(source, args)
        local uPlayer = GetPlayer(source)
        
        if source == 0 or uPlayer.group ~= "user" then
            if args[1] == "0" then args[1] = source end

            local uPlayer = GetPlayer(tonumber(args[1]))
            uPlayer.SetJob(args[2], tonumber(args[3]))
        end
    end)

    RegisterCommand("setgrade", function(source, args)
        local uPlayer = GetPlayer(source)
        
        if source == 0 or uPlayer.group ~= "user" then
            if args[1] == "0" then args[1] = source end

            local uPlayer = GetPlayer(tonumber(args[1]))
            uPlayer.SetJobGrade(tonumber(args[2]))
        end
    end)

    RegisterCommand("setduty", function(source, args)
        local uPlayer = GetPlayer(source)
        
        if source == 0 or uPlayer.group ~= "user" then
            if args[1] == "0" then args[1] = source end

            local uPlayer = GetPlayer(tonumber(args[1]))
            uPlayer.SetDuty((args[2] == "true" or args[2] == "1"))
        end
    end)

-- Money
    RegisterCommand("givemoney", function(source, args)
        local uPlayer = GetPlayer(source)
        
        if source == 0 or uPlayer.group ~= "user" then
            if args[1] == "0" then args[1] = source end

            local uPlayer = GetPlayer(tonumber(args[1]))

            
            uPlayer.AddMoney(args[2], tonumber(args[3]))
        end
    end)

    RegisterCommand("removemoney", function(source, args)
        local uPlayer = GetPlayer(source)
        
        if source == 0 or uPlayer.group ~= "user" then
            if args[1] == "0" then args[1] = source end

            local uPlayer = GetPlayer(tonumber(args[1]))
            uPlayer.RemoveMoney(args[2], tonumber(args[3]))
        end
    end)

    RegisterCommand("setmoney", function(source, args)
        local uPlayer = GetPlayer(source)
        
        if source == 0 or uPlayer.group ~= "user" then
            if args[1] == "0" then args[1] = source end

            local uPlayer = GetPlayer(tonumber(args[1]))
            uPlayer.SetMoney(args[2], tonumber(args[3]))
        end
    end)

-- Bill
    RegisterCommand("sendbill", function(source, args)
        -- 1 = id
        -- 2 = society
        -- 3 = reason (optional)
        -- 4 = amount
        if args[1] == "0" then args[1] = source end

        local uSociety = Utility.Societies[args[2]]
        if uSociety then
            uSociety.CreateBill(args[1], args[3], args[4])
        end
    end)

    RegisterCommand("getbills", function(source, args)
        local _source = source
        if args[1] == "0" or args[1] == nil then args[1] = source end

        local uPlayer = GetPlayer(args[1])
        local bills = uPlayer.GetBills()
        local content = {}

        for i=1, #bills do
            table.insert(content, {label = bills[i][2].." ("..bills[i][3].."$)", reason = bills[i][2], id = i})
        end

        CreateMenu(_source, "<fa-file-invoice> Bills of id "..args[1], content, function(data, menu)
            menu.sub(data.reason, {
                {label = "Pay"}
            }, function(data2, menu2)
                print("Payed? "..tostring(uPlayer.PayBill(data.id)))
            end)
        end)
    end)

    RegisterCommand("paybill", function(source, args)
        if args[1] == "0" or args[1] == nil then args[1] = source end

        local uPlayer = GetPlayer(source)

        uPlayer.PayBill(tonumber(args[1]))
    end)

-- Vehicle
    RegisterCommand("transferveh", function(source, args)
        local uPlayer = GetPlayer(source)
        local veh = GetVehiclePedIsIn(GetPlayerPed(source))
        local plate = GetVehicleNumberPlateText(veh)

        uPlayer.TransferVehicleToPlayer(plate, args[1])
    end)