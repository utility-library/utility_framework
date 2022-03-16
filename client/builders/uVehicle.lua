BuildVehicle = function(self)
    self.GetComponents = function()
        return self.data
    end

    self.IsSpawned = function()
        return DoesEntityExist(self.entity) and self.spawned
    end

    self.Spawn = function(coords, heading, network)
        RequestModel(self.data.model)

        while not HasModelLoaded(self.data.model) do
            Citizen.Wait(1)
        end

        local veh = CreateVehicle(self.data.model, coords, network)
        
        while not DoesEntityExist(veh) do
            Citizen.Wait(1)
        end

        SetModelAsNoLongerNeeded(self.data.model)

        SetVehicleComponents(veh, self.data)
        SetEntityHeading(veh, heading)
        
        self.spawned = true
        self.entity = veh

        return veh
    end

    self.Despawn = function()
        DeleteEntity(self.entity)
        self.spawned = false
    end

    return self
end


exports("GetVehicle", function(plate)
    local veh = nil

    for k,v in pairs(LocalPlayer.state.vehicles) do
        if v.plate == plate then
            veh = BuildVehicle(v)
            break
        end
    end

    return veh
end)