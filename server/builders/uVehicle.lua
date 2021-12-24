local function BuildTrunk(self)
    if Config.Inventory.type == "weight" then
        self.maxWeight = Config.Inventory.maxVehicles[self.data.class] or Config.Inventory.maxVehicles.default
        self.weight = 0
    
        for k,v in pairs(self.trunk) do
            if Config.Actived.ItemData then
                for _, v in pairs(v) do
                    local _weight = (Config.Inventory.itemdata[k] or Config.Inventory.defaultitem)
                    self.trunk[k][_] = v
                    self.weight = self.weight + (_weight * v[1])
                end
            else
                local _weight = (Config.Inventory.itemdata[k] or Config.Inventory.defaultitem)

                self.trunk[k] = tonumber(v)
                self.weight = self.weight + (_weight * v)
            end
        end
    elseif Config.Inventory.type == "limit" then
        self.limit = {}

        for k,v in pairs(self.trunk) do
            if Config.Actived.ItemData then
                for _, v in pairs(v) do
                    -- k = item name
                    -- _ = id of item
                    -- v = quantity and data
                    
                    self.trunk[k][_] = v
                    self.limit[k] = tonumber(v[1])
                end
            else
                self.trunk[k] = tonumber(v)
                self.limit[k] = tonumber(v)
            end
        end
    end

    return self
end

local function BuildFunctions(self)
    self.IsOwner = function(id)
        local steam = GetPlayerIdentifier(id, 0)
        
        for i=1, #Utility.PlayersData[steam].other_info.vehicles do
            if Utility.PlayersData[steam].other_info.vehicles[i] == plate then
                return true
            end
        end

        return false
    end

    self.GetComponents = function()
        return self.data
    end

    self.SetComponents = function(components)
        oxmysql:executeSync('UPDATE vehicles SET data = :data WHERE plate = :plate', {
            plate = self.plate,
            data  = json.encode(components),
        })

        self.data = components
    end

    self.AddItem = function(item, quantity, id, data)
        if Config.Actived.ItemData then
            if id == nil then id = "nodata" end -- Id check
            if not self.trunk[item] then self.trunk[item] = {} end -- Item exist check
            
            if not self.trunk[item][id] then -- If item dont exist
                self.trunk[item][id] = {}
                self.trunk[item][id][1] = tonumber(quantity)

                if data.__type == "item" then
                    self.trunk[item][id][2] = data.data
                else
                    self.trunk[item][id][2] = data
                end
            else
                -- Item already exist (adding new quantity)
                self.trunk[item][id][1] = self.trunk[item][id][1] + tonumber(quantity)
            end
            Log("Trunk", "Added "..quantity.." "..item.." ["..id.."] to "..self.plate)
        else
            if not self.trunk[item] then -- If dont exist create it with the quantity
                self.trunk[item] = quantity
            else -- Else if exist then add the quantity
                self.trunk[item] = self.trunk[item] + quantity 
            end
            Log("Trunk", "Added "..quantity.." "..item.." to "..self.plate)
        end

        -- Weight calculation
        if Config.Inventory.type == "weight" then
            local max = Config.Inventory.itemdata[item] or Config.Inventory.defaultitem
            if self.weight then
                self.weight = self.weight + (max * quantity)
            else
                self.weight = (max * quantity)
            end     
        elseif Config.Inventory.type == "limit" then   
            if self.limit[item] then
                self.limit[item] = self.limit[item] + quantity
            else
                self.limit[item] = quantity
            end
        end
    end

    self.RemoveItem = function(item, quantity, id)
        if self.trunk[item] then -- Item exist in the self.trunk
            if Config.Actived.ItemData then
                if id == nil then id = "nodata" end -- Id check
                
                if self.trunk[item][id] then -- ID exist in the item    
                    -- Item already exist (removing quantity)
                    self.trunk[item][id][1] = self.trunk[item][id][1] - tonumber(quantity)
                    
                    if self.trunk[item][id][1] <= 0 then
                        self.trunk[item][id] = nil
                    end

                    -- Weight calculation
                    if Config.Inventory.type == "weight" then
                        local max = Config.Inventory.itemdata[item] or Config.Inventory.defaultitem
                        if self.weight then
                            self.weight = self.weight + (max * quantity)
                        else
                            self.weight = (max * quantity)
                        end     
                    elseif Config.Inventory.type == "limit" then   
                        if self.limit[item] then
                            self.limit[item] = self.limit[item] + quantity
                        else
                            self.limit[item] = quantity
                        end
                    end                     

                    Log("Trunk", "Removed "..quantity.." "..item.." ["..id.."] from "..self.plate)
                end
            else
                self.trunk[item] = self.trunk[item] - quantity 

                if self.trunk[item] <= 0 then
                    self.trunk[item] = nil
                end

                -- Weight calculation
                if Config.Inventory.type == "weight" then
                    local max = (Config.Inventory.itemdata[item] or Config.Inventory.defaultitem)
                    if self.weight then
                        self.weight = self.weight + (max * quantity)
                    else
                        self.weight = (max * quantity)
                    end     
                elseif Config.Inventory.type == "limit" then   
                    if self.limit[item] then
                        self.limit[item] = self.limit[item] + quantity
                    else
                        self.limit[item] = quantity
                    end
                end 
                Log("Trunk", "Removed "..quantity.." "..item.." from "..self.plate)
            end
        end
    end

    self.CanCarryItem = function(item, quantity)
        local max = Config.Inventory.itemdata[item] or Config.Inventory.defaultitem
        
        if Config.Inventory.type == "weight" then
            if (self.weight + (max * quantity)) > self.maxWeight then
                return false
            else
                return true
            end
        elseif Config.Inventory.type == "limit" then
            if not self.limit[name] then
                return true
            end

            if (self.limit[name] + quantity) <= max then
                return true
            else
                return false
            end
        end
    end

    self.SaveTrunk = function()
        oxmysql:executeSync('UPDATE vehicles SET trunk = :trunk WHERE plate = :plate', {
            plate = self.plate,
            trunk  = json.encode(self.trunk),
        })
    end

    return self
end

CreateVehicle = function(self)
    self.data  = json.decode(self.data)
    self.trunk = json.decode(self.trunk)

    self.Build = function()
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
    return Utility.VehiclesData[plate]
end

LoadVehicles = function()
    local vehicles = oxmysql:fetchSync('SELECT plate, data, trunk FROM vehicles', {})

    if vehicles == nil then error("Unable to connect with the table `vehicles`, try to check the MySQL status!") return end

    for i=1, #vehicles do
        CreateVehicle(vehicles[i])
    end

    return #vehicles
end