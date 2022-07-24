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
        self.__type = "PreuSociety"

        self.money       = json.decode(self.money) or {bank = 0, black = 0}
        self.weapon      = json.decode(self.weapon)

        self.vehicles    = {}

        Utility.Societies[self.name] = self
    end,

    Build = function(self)
        local start = os.clock()

        self.__type = "uSociety"
        self.deposit     = GetStash("society:"..self.name)

        if self.deposit == nil then -- Dont have an old deposit
            self.deposit = CreateStash("society:"..self.name, nil, true)
        end

        self = BuildVehicles(self)
        self = BuildFunctions(self)
        
        Log("Building", "uSociety builded for "..self.name.." in "..((os.clock() - start)*1000).." ms")

        Utility.Societies[self.name] = self
    end,

    IsBuilded = function(self)
        return (self.__type == "uSociety")
    end,

    Demolish = function(self)
        Utility.Societies[self.name] = {
            name      = self.name,
            money     = self.money,
            weapon    = self.weapon,
            Build     = self.Build,
            Demolish  = self.Demolish,
            IsBuilded = self.IsBuilded,
        }
    end
}

GetSociety = function(name)
    if not name or Utility.Societies[name] == nil then
        error("GetSociety: no valid society name provided")
    end

    print(Utility.Societies[name]:IsBuilded())
    if not Utility.Societies[name]:IsBuilded() then
        Utility.Societies[name]:Build()
    end

    return Utility.Societies[name]
end


LoadSocieties = function()
    local society = MySQL.Sync.fetchAll('SELECT name, money FROM society', {})
    if society == nil then error("Unable to connect with the table `society`, try to check the MySQL status!") return end

    for i=1, #society do
        uSociety({
            name      = society[i].name,
            money     = society[i].money,
        })
    end

    return #society
end

SaveSocieties = function()
    Log("Save", "Saving automatically society")
    
    for k,v in pairs(Utility.Societies) do
        MySQL.Sync.execute('UPDATE society SET money = :money WHERE name = :name', {
            money   = json.encode(v.money),
            name    = k
        })
    end
end