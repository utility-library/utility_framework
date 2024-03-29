local function BuildFunctions(self)
    self.UpdateClient = function(property)
        check({property = "string"})

        self.state[property] = self[property]
    end

    --[[
        Check if a id is owner of the vehicle

        id number = id of the player

        return [boolean] = True if the player is owner
    ]]

    self.IsOwner = function(id)
        local identifier = GetuPlayerIdentifier(id)
        return self.owner == identifier
    end

    --[[
        Get all components of the vehicle

        return [table] = Table of components
    ]]
    self.GetComponents = function()
        return self.data
    end

    --[[
        Set components of the vehicle

        components table = Table of components
    ]]
    self.SetComponents = function(components)
        self.data = components

        self.UpdateClient("data")
    end

    -- Stash methods
    for k,v in pairs(self.trunk) do
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
                ExecuteHooks("uVehicle", k, self.plate, ...) -- Execute all hooks for this method
                
                return v(...) -- Execute the normal method
            end
        end
    end

    return self
end

uVehicle = class {
    _Init = function(self)
        if type(self.data) == "string" then
            self.data = Config.TableCompression == "msgpack" and msgpack.unpack(self.data) or json.decode(self.data)
        end

        Utility.Vehicles[self.plate] = self
    end,

    Build = function(self)
        local start = os.clock()

        self.__type = "uVehicle"
        self.maxWeight = Config.Inventory.Type == "weight" and (Config.Inventory.MaxClassWeight[self.data.class] or Config.Inventory.DefaultMaxClassWeight)
        self.state = NewCustomStateBag("vehicle:"..self.plate)
        self.trunk = GetStash("vehicle:"..self.plate)
        
        if self.trunk == nil then -- Dont have an old trunk
            self.trunk = CreateStash("vehicle:"..self.plate, self.maxWeight, true)
        end

        self = BuildFunctions(self)

        Log("Building", "uVehicle builded for "..self.plate.." in "..((os.clock() - start)*1000).." ms")

        Utility.Vehicles[self.plate] = self
    end,

    IsBuilded = function(self)
        return (self.__type == "uStash")
    end,

    Demolish = function(self)
        Utility.Vehicles[self.plate] = {
            plate     = self.plate,
            data      = self.data,
            Build     = self.Build,
            Demolish  = self.Demolish,
            IsBuilded = self.IsBuilded,
        }
    end
}

GetVehicle = function(plate)
    if not plate or Utility.Vehicles[plate] == nil then
        error("GetVehicle: no valid vehicle plate provided, this uEntity works only with owned vehicles")
    end

    if not Utility.Vehicles[plate]:IsBuilded() then
        Utility.Vehicles[plate]:Build()
    end

    return Utility.Vehicles[plate]
end

LoadVehicles = function()
    local vehicles = MySQL.Sync.fetchAll('SELECT owner, plate, data FROM vehicles', {})
    if vehicles == nil then error("Unable to connect with the table `vehicles`, try to check the MySQL status!") return end

    for i=1, #vehicles do
        if not vehicles[i].owner:find(":") then
            if Config.Database.Identifier == "steam" then
                vehicles[i].owner = "steam:110000"..vehicles[i].owner
            else
                vehicles[i].owner = Config.Database.Identifier..":"..vehicles[i].owner
            end
        end

        uVehicle({
            owner     = vehicles[i].owner,
            plate     = vehicles[i].plate,
            data      = vehicles[i].data
        })
    end

    return #vehicles
end

SaveVehicles = function()
    Log("Save", "Saving automatically vehicles")

    for k,v in pairs(Utility.Vehicles) do        
        MySQL.Sync.execute('UPDATE vehicles SET data = :data WHERE plate = :plate', {
            data   = Config.TableCompression == "msgpack" and msgpack.pack(v.data) or json.encode(v.data),
            plate  = k
        })
    end
end