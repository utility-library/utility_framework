local PermObj = {
    Loaded = false
}

Citizen.CreateThread(function()
    PermObj.obj = MySQL.Sync.fetchAll('SELECT model, coords FROM objects', {})

    PermObj.Loaded = true
end)

RegisterServerEvent("Utility:PermObj:SetEntityPermanent")
AddEventHandler("Utility:PermObj:SetEntityPermanent", function(data)
    if data.permanent then
        MySQL.Sync.fetchAll('INSERT INTO objects (model, coords) VALUES (:model, :coords)', {
            model = data.model,
            coords = json.encode({[1] = tonumber(data.x), [2] = tonumber(data.y), [3] = tonumber(data.z)})
        })

        table.insert(PermObj.obj, {
            model = data.model,
            coords = json.encode({[1] = tonumber(data.x), [2] = tonumber(data.y), [3] = tonumber(data.z)})
        })
    else
        MySQL.Sync.fetchAll('DELETE FROM objects WHERE model = :model AND coords = :coords', {
            model = data.model,
            coords = json.encode({[1] = tonumber(data.x), [2] = tonumber(data.y), [3] = tonumber(data.z)})
        })

        for i=1, #PermObj.obj do
            if PermObj.obj[i].model == data.model and PermObj.obj[i].coords == json.encode({[1] = tonumber(data.x), [2] = tonumber(data.y), [3] = tonumber(data.z)}) then
                table.remove(PermObj.obj, i)
            end
        end
    end
end)


RegisterServerCallback("Utility:PermObj:GetSavedData", function()
    --print("[permanent_object] Called from "..source)

    while not PermObj.Loaded do
        Citizen.Wait(1)
    end

    --print("[permanent_object] Calling return")
    return PermObj.obj
end)