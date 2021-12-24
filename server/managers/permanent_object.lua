local PermObj = {
    AlreadyCreated = false
}

RegisterServerEvent("Utility:PermObj:SetEntityPermanent")
AddEventHandler("Utility:PermObj:SetEntityPermanent", function(data)
    if data.permanent then
        oxmysql:executeSync('INSERT INTO objects (model, coords) VALUES (:model, :coords)', {
            model = data.model,
            coords = json.encode({[1] = tonumber(data.x), [2] = tonumber(data.y), [3] = tonumber(data.z)})
        })
    else
        oxmysql:executeSync('DELETE FROM objects WHERE model = :model AND coords = :coords', {
            model = data.model,
            coords = json.encode({[1] = tonumber(data.x), [2] = tonumber(data.y), [3] = tonumber(data.z)})
        })
    end
end)

RegisterServerCallback("Utility:PermObj:GetSavedData", function()
    if not PermObj.AlreadyCreated then -- If is the first client that generate the entity
        PermObj.AlreadyCreated = true

        local obj = oxmysql:fetchSync('SELECT model, coords FROM objects', {})
        return obj
    end
end)