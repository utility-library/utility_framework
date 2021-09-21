RegisterCommand("dv", function(source, args)
    local uPlayer = Utility.PlayerData
    
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
    local uPlayer = Utility.PlayerData
    
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
    local uPlayer = Utility.PlayerData
    
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
    local uPlayer = Utility.PlayerData
    
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

RegisterCommand("id", function(source)
    print(GetPlayerServerId(PlayerId()))
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