local mathm = addon("math")

    uPlayer = LocalPlayer.state  -- Setting standard data (money, inventory, etc)
    -- Money
        GetMoney = function(type)
            return UtilityExports:GetMoney(type)
        end

        HaveMoneyQuantity = function(type, quantity)
            return UtilityExports:HaveMoneyQuantity(type, quantity)
        end
    -- Item
        GetItem = function(name, itemid)
            return UtilityExports:GetItem(name, itemid)
        end
        GetItemIds = function(name)
            return UtilityExports:GetItemIds(name)
        end
        IsItemUsable = function(name, id)
            return UtilityExports:IsItemUsable(name, id)
        end

        UseItem = function(name, id)
            UtilityExports:UseItem(name, id)
        end
        
        HaveItemQuantity = function(name, quantity)
            return UtilityExports:HaveItemQuantity(name, quantity)
        end
        CanCarryItem = function(name, quantity)
            return UtilityExports:CanCarryItem(name, quantity)
        end
    -- Weapon
        AddWeapon = function(weapon, ammo, equipNow)
            UtilityExports:AddWeapon(weapon, ammo, equipNow)
        end

        RemoveWeapon = function(weapon)
            UtilityExports:RemoveWeapon(weapon)
        end

        GetWeapons = function()
            return UtilityExports:GetWeapons()
        end

        HaveWeapon = function(name)
            return UtilityExports:HaveWeapon(name)
        end
    -- License
        GetLicenses = function()      
            return UtilityExports:GetLicenses()
        end

        HaveLicense = function(name)
            return UtilityExports:HaveLicense(name)
        end
    -- Identity
        GetIdentity = function(data)
            return UtilityExports:GetIdentity(data)
        end
    -- Billing
        GetBills = function()
            return UtilityExports:GetBills()
        end

    -- IsDeath
        IsDeath = function()
            return UtilityExports:IsDeath()
        end

    -- Other info integration
        Get = function(id)
            return UtilityExports:Get(id)
        end

    -- Job
        GetJobInfo = function(name)
            return UtilityExports:GetJobInfo(name)
        end
    -- Vehicle
        IsPlateOwned = function(plate)
            return UtilityExports:IsPlateOwned(plate)
        end

        GetComponents = function(plate)            
            return TriggerServerCallbackAsync("Utility:GetComponents", plate)
        end

        SpawnOwnedVehicle = function(plate, coords, network)
            if IsPlateOwned(plate) then
                local components = GetComponents(plate)
                RequestModel(components.model)
                
                while not HasModelLoaded(components.model) do
                    Citizen.Wait(1)
                end

                local veh = CreateVehicle(components.model, coords, 0.0, true)
                SetVehicleComponents(veh, components)
                return veh, true
            else
                return nil, false
            end
        end

        GetPlateData = function(plate)
            return TriggerServerCallbackSync("Utility:uPlayer:GetPlateData", plate)
        end 

        GetTrunk = function(plate)
            return GetPlateData(plate).trunk
        end


RegisterCommand("unban", function()
    DeleteResourceKvp("utility_ban")
end)

RegisterCommand("dv", function(source, args)    
    if uPlayer.group ~= "user" then
        local veh = GetVehiclePedIsIn(PlayerPedId())
        if veh ~= 0 then     
            DeleteEntity(veh)
        else
            local a = GetGamePool("CVehicle")

            for i=1, #a do
                if GetDistanceBetweenCoords(GetEntityCoords(a[i]), GetEntityCoords(PlayerPedId()), false) < (tonumber(args[1]) or 5.0) then
                    DeleteEntity(a[i])
                end
            end
        end
    end
end)

RegisterCommand("car", function(source, args)    
    if uPlayer.group ~= "user" then
        if not HasModelLoaded(GetHashKey(args[1])) then
            RequestModel(GetHashKey(args[1]));
            while not HasModelLoaded(GetHashKey(args[1])) do Citizen.Wait(1); end  
        end

        local veh = CreateVehicle(GetHashKey(args[1]), GetEntityCoords(PlayerPedId()), GetEntityHeading(PlayerPedId()), true)
        TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
    end
end)

RegisterCommand("tpm", function(source)    
    if uPlayer.group ~= "user" then
        local blip = GetClosestBlipOfType(8)
        local x,y = table.unpack(GetBlipCoords(blip))
        local z = GetGroundZFor_3dCoord(x, y, 999.0)

        for height = 1, 800 do
            SetPedCoordsKeepVehicle(PlayerPedId(), x, y, height + 0.0)

            local foundGround, zPos = GetGroundZFor_3dCoord(x, y, height + 0.0)
            
            if foundGround then
                SetPedCoordsKeepVehicle(PlayerPedId(), x, y, height + 0.0)
                break
            end

            Citizen.Wait(5)
        end
    end
end)

RegisterCommand("tp", function(source, args)    
    if uPlayer.group ~= "user" then
        if args[1]:find("vector3") then
            local coords = {}
            local _vector3 = args[1]:match("%[(%a+)%]")
            for xyz in _vector3:gmatch("%S+") do table.insert(coords, xyz) end

            SetPedCoordsKeepVehicle(PlayerPedId(), tonumber(coords[1]), tonumber(coords[2]), tonumber(coords[3]))
        else
            args[1] = args[1]:gsub(",", "")
            args[2] = args[2]:gsub(",", "")
            args[3] = args[3]:gsub(",", "")

            SetPedCoordsKeepVehicle(PlayerPedId(), tonumber(args[1]), tonumber(args[2]), tonumber(args[3]))
        end
    end
end)

RegisterCommand("clearentattached", function(source)
    local obj = GetGamePool("CObject")

    for i=1, #obj do
        if IsEntityAttachedToEntity(obj[i], player) then
            DeleteEntity(obj[i])
        end
    end
end)

RegisterCommand("spawnobject", function(source, args)    
    if uPlayer.group ~= "user" then
        args[1] = GetHashKey(args[1])

        RequestModel(args[1])
        while not HasModelLoaded(args[1]) do
            Citizen.Wait(1)
        end

        CreateObject(args[1], GetEntityCoords(PlayerPedId()), true)
    end
end)

RegisterCommand("id", function(source)
    print(GetPlayerServerId(PlayerId()))
end)

RegisterCommand("coords", function(source)
    local coord = GetEntityCoords(PlayerPedId())
    
    SendNUIMessage({
        clipboard = true,
        text = "vector3("..mathm.round(coord.x, 2)..", "..mathm.round(coord.y, 2)..", "..mathm.round(coord.z, 2)..")"    
    })
end)

RegisterCommand("rotation", function(source)
    local rotation = GetEntityRotation(PlayerPedId())
    
    SendNUIMessage({
        clipboard = true,
        text = "vector3("..mathm.round(rotation.x, 2)..", "..mathm.round(rotation.y, 2)..", "..mathm.round(rotation.z, 2)..")"    
    })
end)

RegisterCommand("heading", function(source)
    SendNUIMessage({
        clipboard = true,
        text = tostring(GetEntityHeading(PlayerPedId()))
    })
end)

RegisterCommand("die", function(source, args)
    SetEntityHealth(PlayerPedId(), 0)
end)

RegisterCommand("isdeath", function(source, args)
    print(IsDeath())
end)


-- COMMANDS SUGGESTIONS
TriggerEvent('chat:addSuggestion', '/giveweapon', 'Give a weapon from a player', {
    { 
        name = "id", 
        help = "The id of the recipient (0 = yourself)" 
    },
    {   
        name = "weapon", 
        help = "The name of the weapon (example: weapon_pistol)" 
    },
    {   
        name = "ammo", 
        help = "The ammo of the weapon" 
    },
})
TriggerEvent('chat:addSuggestion', '/removeweapon', 'Remove a weapon from a player', {
    { 
        name = "id", 
        help = "The id of the recipient (0 = yourself)" 
    },
    {   
        name = "weapon", 
        help = "The name of the weapon (example: weapon_pistol)" 
    },
})
TriggerEvent('chat:addSuggestion', '/clearweapon', 'Clear all weapon from a player', {
    { 
        name = "id", 
        help = "The id of the recipient (0 or nothing = yourself)" 
    },
})
TriggerEvent('chat:addSuggestion', '/revive', 'Revive a player', {
    { 
        name = "id", 
        help = "The id of the recipient (0 or nothing = yourself)" 
    },
})
TriggerEvent('chat:addSuggestion', '/goto', 'Teleport to a player (you > player)', {
    { 
        name = "id", 
        help = "The id of the player you need to go" 
    },
})
TriggerEvent('chat:addSuggestion', '/bring', 'Teleport a player to you (player > you)', {
    { 
        name = "id", 
        help = "The id of the player you need to bring to you" 
    },
})
TriggerEvent('chat:addSuggestion', '/giveitem', 'Give a item to a player', {
    { 
        name = "id", 
        help = "The id of the recipient (0 = yourself)" 
    },
    { 
        name = "item", 
        help = "The name of the item" 
    },
    { 
        name = "quantity", 
        help = "The quantity of the item" 
    },
    { 
        name = "itemid", 
        help = "The item id of the item (only if you have ItemData turned on) [OPTIONAL]" 
    },
})
TriggerEvent('chat:addSuggestion', '/removeitem', 'Remove a item from a player', {
    { 
        name = "id", 
        help = "The id of the recipient (0 = yourself)" 
    },
    { 
        name = "item", 
        help = "The name of the item" 
    },
    { 
        name = "quantity", 
        help = "The quantity of the item" 
    },
    { 
        name = "itemid", 
        help = "The item id of the item (only if you have ItemData turned on)" 
    },
})
TriggerEvent('chat:addSuggestion', '/setjob', 'Set the job of a player', {
    { 
        name = "id", 
        help = "The id of the recipient (0 = yourself)" 
    },
    { 
        name = "job", 
        help = "The name of the job" 
    },
    { 
        name = "grade", 
        help = "The grade of the job" 
    },
})
TriggerEvent('chat:addSuggestion', '/setgrade', 'Set the grade of a player', {
    { 
        name = "id", 
        help = "The id of the recipient (0 = yourself)" 
    },
    { 
        name = "grade", 
        help = "The grade of the job" 
    },
})
TriggerEvent('chat:addSuggestion', '/setduty', 'Set the duty of a player', {
    { 
        name = "id", 
        help = "The id of the recipient (0 = yourself)" 
    },
    { 
        name = "onduty", 
        help = "true or 1 to set the player on duty, false or 0 to set the player off duty" 
    },
})
TriggerEvent('chat:addSuggestion', '/givemoney', 'Give money to a player', {
    { 
        name = "id", 
        help = "The id of the recipient (0 = yourself)" 
    },
    { 
        name = "type", 
        help = "cash, bank or black" 
    },
    { 
        name = "amount", 
        help = "The amount of money to give" 
    },
})
TriggerEvent('chat:addSuggestion', '/removemoney', 'Remove money from a player', {
    { 
        name = "id", 
        help = "The id of the recipient (0 = yourself)" 
    },
    { 
        name = "type", 
        help = "cash, bank or black" 
    },
    { 
        name = "amount", 
        help = "The amount of money to remove" 
    },
})
TriggerEvent('chat:addSuggestion', '/setmoney', 'Set money of a player', {
    { 
        name = "id", 
        help = "The id of the recipient (0 = yourself)" 
    },
    { 
        name = "type", 
        help = "cash, bank or black" 
    },
    { 
        name = "amount", 
        help = "The amount of money to set" 
    },
})
TriggerEvent('chat:addSuggestion', '/sendbill', 'Send a bill to a player', {
    { 
        name = "id", 
        help = "The id of the recipient (0 = yourself)" 
    },
    { 
        name = "society", 
        help = "The society name (example: police)" 
    },
    { 
        name = "reason", 
        help = "The reason of the bill" 
    },
    { 
        name = "amount", 
        help = "How muc is the bill" 
    },
})
TriggerEvent('chat:addSuggestion', '/getbills', 'Get all bills of a player', {
    { 
        name = "id", 
        help = "The id of the recipient (0 = yourself)" 
    }
})
TriggerEvent('chat:addSuggestion', '/paybill', 'Pay a bill', {
    { 
        name = "id", 
        help = "The id of the recipient (0 = yourself)" 
    }
})
TriggerEvent('chat:addSuggestion', '/transferveh', 'Transfer a vehicle to another player (YOU NEED TO STAY IN THE VEHICLE)', {
    { 
        name = "id", 
        help = "The id of the recipient (0 = yourself)" 
    }
})