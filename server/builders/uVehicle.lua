local function BuildTrunk(self)
    if Config.Inventory.Type == "weight" then
        self.maxWeight = Config.Inventory.MaxClassWeight[self.data.class] or Config.Inventory.DefaultMaxClassWeight
        self.weight = 0
    
        for k,v in pairs(self.trunk) do
            local _weight = (Config.Inventory.ItemWeight[k] or Config.Inventory.DefaultItemWeight)
            self.weight = self.weight + (_weight * v[2])
        end
    end

    return self
end

local function BuildFunctions(self)
    --[[
        Check if a id is owner of the vehicle

        id number = id of the player

        return [boolean] = True if the player is owner
    ]]

    self.IsOwner = function(id)
        local steam = GetPlayerIdentifier(id, 0)
        return self.owner == steam
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
    end

    --[[
        Add a item to the vehicle

        name string = Name of the item
        quantity number = Quantity of the item to add
        data any [-] = The data of the item
    ]]
    self.AddItem = function(name, quantity, data)
        AddItemInternal(name, quantity, data, self)
    end

    --[[
        Remove a item from the vehicle

        item string = Name of the item
        quantity number = Quantity of the item to remove
    ]]
    self.RemoveItem = function(item, quantity, data)
        RemoveItemInternal(item, quantity, data, self)
    end

    --[[
        Get info from item

        name string = The name of the item

        return [table] = A table with the childs: `count`, `label`, `data` and `weight` or `limit`  
    ]]
    self.GetItem = function(name, data)
        return GetItemInternal(name, data, self.trunk)
    end

    --[[
        Check if the vehicle have an item quantity

        name string = The name of the item
        quantity number = The quantity to check

        return [boolean] = True if the item is usable, false if item isnt usable
    ]]
    self.HaveItemQuantity = function(name, quantity, data)
        return HaveItemQuantityInternal(name, quantity, data, self.trunk)
    end
    
    --[[
        Check if the vehicle can carry the item quantity

        item string = Name of the item
        quantity number = Quantity of the item

        return [boolean] = True if the vehicle can carry the item
    ]]
    self.CanCarryItem = function(item, quantity)
        local max = Config.Inventory.ItemWeight[item] or Config.Inventory.DefaultItemWeight
        
        if Config.Inventory.Type == "weight" then
            if (self.weight + (max * quantity)) > self.maxWeight then
                return false
            else
                return true
            end
        elseif Config.Inventory.Type == "limit" then
            local item = FindItem(item, self.trunk)

            if (item[2] + quantity) <= max then
                return true
            else
                return false
            end
        end
    end

    return self
end


CreateVehicle = function(self)
    self.owner = "steam:110000"..self.owner

    if type(self.data) == "string" then
        self.data = json.decode(self.data)
    end
    if type(self.trunk) == "string" then
        self.trunk = json.decode(self.trunk)
    end

    self.Build = function()
        Log("Building", "Vehicle "..self.plate.." builded")

        self.__type = "uVehicle"
        self = BuildTrunk(self)
        self = BuildFunctions(self)
        Utility.VehiclesData[self.plate] = self
    end
    self.IsBuilded = function()
        return (Utility.VehiclesData[self.plate].__type ~= nil)
    end
    self.Demolish = function()
        Utility.VehiclesData[self.plate] = {
            plate     = self.plate,
            data      = self.data,
            trunk     = self.trunk,
            Build     = self.Build,
            Demolish  = self.Demolish,
            IsBuilded = self.IsBuilded,
        }
    end

    Utility.VehiclesData[self.plate] = self
end

GetVehicle = function(plate)
    if not plate or Utility.VehiclesData[plate] == nil then
        error("GetVehicle: no valid vehicle plate provided, this uEntity works only with owned vehicles")
    end

    if not Utility.VehiclesData[plate]:IsBuilded() then
        Utility.VehiclesData[plate]:Build()
    end

    return Utility.VehiclesData[plate]
end

LoadVehicles = function()
    local vehicles = MySQL.Sync.fetchAll('SELECT owner, plate, data, trunk FROM vehicles', {})

    if vehicles == nil then error("Unable to connect with the table `vehicles`, try to check the MySQL status!") return end

    for i=1, #vehicles do
        CreateVehicle(vehicles[i])
    end

    return #vehicles
end