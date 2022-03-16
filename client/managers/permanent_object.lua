if Config.Addons.PermanentObject then
    Citizen.CreateThread(function()
        -- There is a server check that send the callback only if is the first client that try to generate the entity
        local data = TriggerServerCallbackSync("Utility:PermObj:GetSavedData")

        if data ~= nil then
            for i=1, #data do
                data[i].coords = json.decode(data[i].coords)
    
                local obj = CreateObject(data[i].model, vector3(tonumber(data[i].coords[1]), tonumber(data[i].coords[2]), tonumber(data[i].coords[3])), true)  
                
                SetEntityAsMissionEntity(obj, true, true)
                NetworkRegisterEntityAsNetworked(obj)
        
                local NetId = NetworkGetNetworkIdFromEntity(obj)
                SetNetworkIdExistsOnAllMachines(NetId, true)
                SetNetworkIdCanMigrate(NetId, true)
                NetworkSetNetworkIdDynamic(NetId, false)
            end
        end
    end)
end

RegisterCommand("testpermobj", function(source)
    while not HasModelLoaded("prop_weed_01") do
        RequestModel("prop_weed_01")
        Citizen.Wait(1)
    end

    local obj = CreateObject(`prop_weed_01`, GetEntityCoords(PlayerPedId()), true, true)
    local netid = NetworkGetNetworkIdFromEntity(obj)
    NetworkRegisterEntityAsNetworked(obj)

    while not NetworkRequestControlOfEntity(obj) do
        Citizen.Wait(1)
    end

    print(string.format("%d | %d | %s | %s", obj, netid, NetworkGetEntityIsNetworked(obj), GetPlayerName(NetworkGetEntityOwner(obj))))
    
    SetNetworkIdCanMigrate(netid, true)
    
    --Citizen.Wait(5000)

    --DeleteEntity(obj)

end)