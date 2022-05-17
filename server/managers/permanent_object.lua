local PermObj = {
    Objects = GetResourceKvpString("utility_perm_objs"),
    ObjectsPool = {}
}

if PermObj.Objects then
    PermObj.Objects = json.decode(PermObj.Objects)
else
    PermObj.Objects = {}
end

Citizen.CreateThread(function()
    for i=1, #PermObj.Objects do
        local object = PermObj.Objects[i]
        local obj = CreateObject(object.model, object.x, object.y, object.z, true)

        while not DoesEntityExist(obj) do
            Citizen.Wait(1)
        end

        PermObj.ObjectsPool[NetworkGetNetworkIdFromEntity(obj)] = obj
    end
end)

RegisterServerCallback("Utility:CreatePermanentObject", function(model, x, y, z, network, netMissionEntity, doorFlag)
    if type(x) == "vector3" then
        x = x.x
        y = x.y
        z = x.z
        network = y
        netMissionEntity = z
        doorFlag = network
    end

    x = tonumber(x)
    y = tonumber(y)
    z = tonumber(z)
    
    local obj = CreateObject(model, x, y, z, network, netMissionEntity, doorFlag)
    table.insert(PermObj.Objects, {model = model, x = x, y = y, z = z})

    while not DoesEntityExist(obj) do
        Citizen.Wait(1)
    end

    return NetworkGetNetworkIdFromEntity(obj)
end)

RegisterServerEvent("Utility:DeletePermanentObject", function(netId)
    if PermObj.ObjectsPool[netId] then
        DeleteEntity(PermObj.ObjectsPool[netId])
        PermObj.ObjectsPool[netId] = nil
    end
end)