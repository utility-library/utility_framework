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
end)

RegisterCommand("id", function(source)
    print(GetPlayerServerId(PlayerId()))
end)
