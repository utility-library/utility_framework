-- Weapon
    RegisterCommand("giveweapon", function(source, args)
        local uPlayer = GetPlayer(source)

        if uPlayer.group ~= "user" and args[1] and args[2] and args[3] then
            if args[1] == "0" then args[1] = source end

            local uPlayer = GetPlayer(tonumber(args[1]))
            uPlayer.AddWeapon(args[2], tonumber(args[3]))
        end
    end)

    RegisterCommand("removeweapon", function(source, args)
        local uPlayer = GetPlayer(source)

        if uPlayer.group ~= "user" and args[1] and args[2] then
            if args[1] == "0" then args[1] = source end

            local uPlayer = GetPlayer(tonumber(args[1]))
            uPlayer.RemoveWeapon(args[2])
        end
    end)

    RegisterCommand("clearweapon", function(source, args)
        local uPlayer = GetPlayer(source)

        if uPlayer.group ~= "user" then
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

        print(uPlayer.group)
        if uPlayer.group ~= "user" then
            if args[1] == "0" or args[1] == nil then args[1] = source end

            local uPlayer = GetPlayer(tonumber(args[1]))

            uPlayer.Revive()
        end
    end)

-- Admin
    RegisterCommand("goto", function(source, args)
        local uPlayer = GetPlayer(source)
        
        if uPlayer.group ~= "user" and args[1] then
            local player = GetPlayerPed(tonumber(args[1]))
            
            SetEntityCoords(GetPlayerPed(source), GetEntityCoords(player))
        end
    end)

    RegisterCommand("bring", function(source, args)
        local uPlayer = GetPlayer(source)
        
        if uPlayer.group ~= "user" and args[1] then
            local player = GetPlayerPed(tonumber(args[1]))

            SetEntityCoords(player, GetEntityCoords(GetPlayerPed(source)))
        end
    end)

-- Item
    RegisterCommand("giveitem", function(source, args)
        local uPlayer = GetPlayer(source)
        
        if uPlayer.group ~= "user" then
            if args[1] == "0" then args[1] = source end

            uPlayer = GetPlayer(tonumber(args[1]))
            uPlayer.AddItem(args[2], tonumber(args[3]), args[4] or nil)
        end
    end)
    RegisterCommand("removeitem", function(source, args)
        local uPlayer = GetPlayer(source)
        
        if uPlayer.group ~= "user" then
            if args[1] == "0" then args[1] = source end

            uPlayer.RemoveItem(args[2], tonumber(args[3]), args[4] or "nodata")
        end
    end)



    -- Probably to remove
    RegisterCommand("getinv", function(source, args)
        local uPlayer = GetPlayer(source)
        
        if uPlayer.group ~= "user" then
            if args[1] then
                uPlayer = GetPlayer(tonumber(args[1]))
            end

            local inventory = uPlayer.inventory
            --[[local content = {}

            for name, data in pairs(inventory) do
                local itemCount = 0
                for k, v in pairs(data) do
                    itemCount = itemCount + v[1]
                end

                table.insert(content, {label = uPlayer.GetItem(name).label.." | "..itemCount, value = name})
            end

            TriggerClientEvent("Utility:OpenMenu", source, "<fa-tshirt> Inventory", content)]]

            print(json.encode(inventory, {index = true}))
        end
    end)
    RegisterCommand("getweight", function(source, args)
        local uPlayer = GetPlayer(source)
        
        if uPlayer.group ~= "user" then
            if args[1] then
                uPlayer = GetPlayer(tonumber(args[1]))
            end

            if Config.Inventory.type == "weight" then
                -- "MaxWeight = 300 Weight = 5"
                print("MaxWeight = "..uPlayer.MaxWeight().." Weight = "..uPlayer.Weight())
            elseif Config.Inventory.type == "limit" then
                -- "Water Limit = 5, Can carry water = false"
                print("Water Limit = "..uPlayer.GetItem("water").limit..", Can carry water = "..tostring(uPlayer.CanCarryItem("water", 6)))
            end
        end
    end)

-- Job
    RegisterCommand("setjob", function(source, args)
        local uPlayer = GetPlayer(source)
        
        if uPlayer.group ~= "user" then
            if args[1] == "0" then args[1] = source end

            local uPlayer = GetPlayer(tonumber(args[1]))
            uPlayer.SetJob(args[2], tonumber(args[3]))
        end
    end)

    RegisterCommand("setgrade", function(source, args)
        local uPlayer = GetPlayer(source)
        
        if uPlayer.group ~= "user" then
            if args[1] == "0" then args[1] = source end

            local uPlayer = GetPlayer(tonumber(args[1]))
            uPlayer.SetJobGrade(tonumber(args[2]))
        end
    end)

    RegisterCommand("setduty", function(source, args)
        local uPlayer = GetPlayer(source)
        
        if uPlayer.group ~= "user" then
            if args[1] == "0" then args[1] = source end

            local uPlayer = GetPlayer(tonumber(args[1]))
            uPlayer.SetDuty((args[2] == "true" or args[2] == "1"))
        end
    end)

-- Money
    RegisterCommand("givemoney", function(source, args)
        local uPlayer = GetPlayer(source)
        
        if uPlayer.group ~= "user" then
            if args[1] == "0" then args[1] = source end

            local uPlayer = GetPlayer(tonumber(args[1]))

            
            uPlayer.AddMoney(args[2], tonumber(args[3]))
        end
    end)

    RegisterCommand("removemoney", function(source, args)
        local uPlayer = GetPlayer(source)
        
        if uPlayer.group ~= "user" then
            if args[1] == "0" then args[1] = source end

            local uPlayer = GetPlayer(tonumber(args[1]))
            uPlayer.RemoveMoney(args[2], tonumber(args[3]))
        end
    end)

    RegisterCommand("setmoney", function(source, args)
        local uPlayer = GetPlayer(source)
        
        if uPlayer.group ~= "user" then
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

        local uSociety = Utility.SocietyData[args[2]]
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