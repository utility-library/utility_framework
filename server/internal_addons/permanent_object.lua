local PermObj = {
    AlreadyCreated = false
}

RegisterServerEvent("Utility:PermObj:SetEntityPermanent")
AddEventHandler("Utility:PermObj:SetEntityPermanent", function(data)
    if data.permanent then
        oxmysql:executeSync('INSERT INTO objects (model, coords) VALUES (:model, :coords)', {
            model = data.model,
            coords = json.encode({x = data.x, y = data.y, z = data.z})
        })
    else
        oxmysql:executeSync('DELETE FROM objects WHERE model = :model AND coords = :coords', {
            model = data.model,
            coords = json.encode({x = data.x, y = data.y, z = data.z})
        })
    end
end)

RegisterServerCallback("Utility:PermObj:GetSavedData", function()
    if not PermObj.AlreadyCreated then -- If is the first client that generate the entity
        PermObj.AlreadyCreated = true
        oxmysql:fetchSync('SELECT model, coords FROM objects', {}, function(object)
            cb(object)
        end)
    end
end)