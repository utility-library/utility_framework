BuildVehicles = function(self)
    for k,v in pairs(Utility.Vehicles) do
        if v.owner == "society:"..self.name then
            table.insert(self.vehicles, v)
        end
    end

    return self
end

BuildFunctions = function(self)
    -- Billing

        --[[
            Create a new billing

            target number = Source of the target
            reason string = Reason of the billing
            amount number = Amount of the billing
        ]]
        self.CreateBill = function(target, reason, amount)
            local uPlayer = Utility.Players[GetPlayerIdentifiers(target)[1]]

            -- Create the bill for the player            
            uPlayer.CreateBill(self.name, reason, amount)
        end
    
    -- Vehicles
        self.BuyVehicle = function(components)
            check({components = "table"})

            MySQL.Sync.execute('INSERT INTO vehicles (owner, plate, data) VALUES (:owner, :plate, :data)', {
                owner = "society:"..self.name,
                plate = components.plate[1],
                data  = json.encode(components),
            })

            uVehicle({
                owner = "society:"..self.name,
                plate = components.plate[1],
                data  = json.encode(components)
            })

            Log("Society", self.name.." have buyed a vehicle with the plate "..components.plate[1])
        end


    -- Stash methods
    for k,v in pairs(self.deposit) do
        if self[k] == nil and self[k] ~= "save" then
            --print("Creating ",k,v)
            self[k] = v
        else
            --print("Skipping",k)
        end
    end

    -- Add to any method the hook execution
    for k,v in pairs(self) do
        if type(v) == "function" then -- If is a method
            self[k] = function(...) -- Hook function
                ExecuteHooks("uSociety", k, self.name, ...) -- Execute all hooks for this method
                
                return v(...) -- Execute the normal method
            end
        end
    end

    return self
end

uSociety = class {
    _Init = function(self)
        local start = os.clock()
        self.__type = "uSociety"

        self.vehicles    = {}

        if DoesStashExist("society:"..self.name) then
            self.deposit = GetStash("society:"..self.name)
        else
            self.deposit = CreateStash("society:"..self.name, nil, true)
        end

        self = BuildVehicles(self)
        self = BuildFunctions(self)

        self.money       = self.datas.money or {}
        self.weapons     = self.datas.weapons or {}
        
        Log("Building", "uSociety created for "..self.name.." in "..((os.clock() - start)*1000).." ms")

        Utility.Societies[self.name] = self
    end
}

GetSociety = function(name)
    if not name or Utility.Societies[name] == nil then
        error("GetSociety: no valid society name provided")
    end

    return Utility.Societies[name]
end

RegisterServerCallback("Utility:Society:GetSocietyVehicles", function(society)
    local society = GetSociety(society)
    return society.vehicles
end)

RegisterServerCallback("Utility:Society:GetSociety", function(society)
    local society = GetSociety(society)
    return {
        name      = society.name,
        money     = society.money,
        weapon    = society.weapon,
        vehicles  = society.vehicles,
    }
end)

CreateSociety = function(name)
    return uSociety({name = name})
end

Citizen.CreateThread(function()
    while not Utility.DatabaseLoaded do
        Citizen.Wait(100)
    end

    for i=1, #Config.Societies do
        local society = CreateSociety(Config.Societies[i])
    end
end)