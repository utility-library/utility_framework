local function GetuPlayer(source)
    local steam = GetPlayerIdentifiers(source)[1]

    return Utility.PlayersData[steam]
end

-- Weapon
    RegisterCommand("giveweapon", function(source, args)
        local uPlayer = GetuPlayer(source)

        if uPlayer.group ~= "user" then
            local uPlayer = GetuPlayer(tonumber(args[1]))

            uPlayer.AddWeapon(args[2], tonumber(args[3]))
            print(uPlayer.HaveWeapon(args[2]))
        end
    end)

    RegisterCommand("removeweapon", function(source, args)
        local uPlayer = GetuPlayer(source)

        if uPlayer.group ~= "user" then
            if args[1] ~= source and args[1] ~= nil then
                local uPlayer = GetuPlayer(tonumber(args[1]))
                uPlayer.RemoveWeapon(args[2])
            else
                uPlayer.RemoveWeapon(args[2])
            end
        end
    end)

    RegisterCommand("clearweapon", function(source, args)
        local uPlayer = GetuPlayer(source)

        if uPlayer.group ~= "user" then
            if args[1] ~= source and args[1] ~= nil then
                local uPlayer = GetuPlayer(tonumber(args[1]))

                for name, ammo in pairs(uPlayer.GetWeapons()) do
                    uPlayer.RemoveWeapon(name)
                end
            else
                for name, ammo in pairs(uPlayer.GetWeapons()) do
                    uPlayer.RemoveWeapon(name)
                end
            end
        end
    end)

-- Death
    RegisterCommand("revive", function(source, args)
        local uPlayer = GetuPlayer(source)

        if uPlayer.group ~= "user" then
            if args[1] ~= source and args[1] ~= nil then
                local uPlayer = GetuPlayer(tonumber(args[1]))
                uPlayer.Revive()
            else
                uPlayer.Revive()
            end
        end
    end)

-- Admin
    RegisterCommand("goto", function(source, args)
        local uPlayer =  GetuPlayer(source)
        
        if uPlayer.group ~= "user" then
            local player = GetPlayerPed(tonumber(args[1]))
            
            SetEntityCoords(GetPlayerPed(source), GetEntityCoords(player))
        end
    end)

    RegisterCommand("bring", function(source, args)
        local uPlayer =  GetuPlayer(source)
        
        if uPlayer.group ~= "user" then
            local player = GetPlayerPed(tonumber(args[1]))

            SetEntityCoords(player, GetEntityCoords(GetPlayerPed(source)))
        end
    end)

-- Item
    RegisterCommand("giveitem", function(source, args)
        local uPlayer = GetuPlayer(source)
        
        if uPlayer.group ~= "user" then
            if args[1] then
                uPlayer = GetuPlayer(tonumber(args[1]))
                uPlayer.AddItem(args[2], tonumber(args[3]), "ciao", {a=true, b="test", c=1})
            else
                uPlayer.AddItem(args[1], tonumber(args[2]), "ciao", {a=true, b="test", c=1})
            end
        end
    end)
    RegisterCommand("getinv", function(source, args)
        local uPlayer = GetuPlayer(source)
        
        if uPlayer.group ~= "user" then
            if args[1] then
                uPlayer = GetuPlayer(tonumber(args[1]))
            end

            local inventory = uPlayer.GetInventory()
            local content = {}

            for name, data in pairs(inventory) do
                local itemCount = 0
                for k, v in pairs(data) do
                    itemCount = itemCount + v[1]
                end

                table.insert(content, {label = uPlayer.GetItem(name).label.." | "..itemCount, value = name})
            end

            TriggerClientEvent("Utility:OpenMenu", source, "<fa-tshirt> Inventory", content)
        end
    end)
    RegisterCommand("getweight", function(source, args)
        local uPlayer = GetuPlayer(source)
        
        if uPlayer.group ~= "user" then
            if args[1] then
                uPlayer = GetuPlayer(tonumber(args[1]))
            end

            -- "MaxWeight = 300 Weight = 5"
            -- print("MaxWeight = "..uPlayer.MaxWeight().." Weight = "..uPlayer.Weight())

            -- "Water Limit = 5, Can carry water = false"
            -- print("Water Limit = "..uPlayer.GetItem("water").limit..", Can carry water = "..tostring(uPlayer.CanCarryItem("water", 6)))
        end
    end)

RegisterCommand("setjob", function(source, args)
    local uPlayer =  GetuPlayer(source)
    
    if uPlayer.group ~= "user" then
        local uPlayer = GetuPlayer(tonumber(args[1]))
        
        uPlayer.SetJob(args[2], tonumber(args[3]))
    end
end)