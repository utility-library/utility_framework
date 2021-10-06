--————————\ ┌─────────────────────────────────────────────────────────────────┐ /———————————————--
--————————— │ !TURN ON THE "PermanentObject" IN THE CONFIG TO USE THIS ADDON! | ————————————————--
--————————/ └─────────────────────────────────────────────────────────────────┘ \———————————————--

local mathm = addon("math")
local self = {
    set = function(entity, permanent)
        if permanent then -- Add
            if not IsEntityAMissionEntity(entity) then
                SetEntityAsMissionEntity(entity, true, true)
            end
            
            NetworkRegisterEntityAsNetworked(entity)

            local NetId = NetworkGetNetworkIdFromEntity(entity)
            SetNetworkIdExistsOnAllMachines(NetId, true)
            SetNetworkIdCanMigrate(NetId, true)
            NetworkSetNetworkIdDynamic(NetId, false)
            
            local coords = GetEntityCoords(entity)
            TriggerServerEvent("Utility:PermObj:SetEntityPermanent", {
                permanent = true,
                model = GetEntityModel(entity),
                x = mathm.round(coords.x, 2),
                y = mathm.round(coords.y, 2),
                z = mathm.round(coords.z, 2),
            })
        else -- Remove
            local coords = GetEntityCoords(entity)
            TriggerServerEvent("Utility:PermObj:SetEntityPermanent", {
                permanent = false,
                model = GetEntityModel(entity),
                x = coords.x,
                y = coords.y,
                z = coords.z,
            })
        end
    end
}

return self