BuildWeight = function(self)
    self.weight = 0

    if Config.Inventory.Type == "weight" then
        self.maxWeight = Config.Inventory.MaxWeight
        self.weight = 0
    
        for k,v in pairs(self.deposit) do
            local _weight = (Config.Inventory.ItemWeight[k] or Config.Inventory.DefaultItemWeight)
            self.weight = self.weight + (_weight * v[2])
        end
    end

    return self
end

BuildVehicles = function(self)
    for k,v in pairs(Utility.VehiclesData) do
        if v.owner == "steam:110000"..self.name then
            table.insert(self.vehicles, v)
        end
    end

    return self
end

BuildFunctions = function(self)
    -- Money
    
        --[[
            Add money to the society

            type string = Type of the money (bank, cash, black)
            amount number = Amount of money to add
        ]]
        self.AddMoney = function(type, amount)
            self.money[type] = self.money[type] + tonumber(amount)
        end
        
        --[[
            Remove money from the society

            type string = Type of the money (bank, cash, black)
            amount number = Amount of money to remove
        ]]
        self.RemoveMoney = function(type, amount)
            self.money[type] = self.money[type] - tonumber(amount)
        end
    
        --[[
            Get money from the society

            type string = Type of the money (bank, cash, black)

            return number = Amount of money 
        ]]
        self.GetMoney = function(type)
            return {count = self.money[type], label = GetLabel("accounts", nil, type) or type}
        end
    
        --[[
            Check if the society has money

            type string = Type of the money (bank, cash, black)
            quantity number = Quantity of money to check

            return [boolean] = True if the society have the money
        ]]
        self.HaveMoneyQuantity = function(type, quantity)
            return self.money[type] >= tonumber(quantity)
        end
        
    -- Inventory

        --[[
            Add an item to the society

            name string = Name of the item
            quantity number = Quantity of the item to add
        ]]
        self.AddItem = function(name, quantity, data)
            CheckArgument("AddItem", name, "name", "string")
            CheckArgument("AddItem", quantity, "quantity", "number")

            AddItemInternal(name, quantity, data, self)
        end
    
        --[[
            Remove an item from the society

            name string = Name of the item
            quantity number = Quantity of the item to remove
        ]]
        self.RemoveItem = function(name, quantity, data)
            CheckArgument("RemoveItem", name, "name", "string")
            CheckArgument("RemoveItem", quantity, "quantity", "number")

            RemoveItemInternal(name, quantity, data, self)
        end
    
        --[[
            Get an item from the society

            name string = Name of the item
            
            return number = Quantity of the item
        ]]
        self.GetItem = function(name, data)
            return GetItemInternal(name, data, self.deposit)
        end
    
        --[[
            Check if the society have an item

            name string = Name of the item
            quantity number = Quantity of the item to check

            return [boolean] = True if the society have the item
        ]]
        self.HaveItemQuantity = function(name, quantity, data)
            return HaveItemQuantityInternal(name, quantity, data, self.deposit)
        end

    -- Weapon

        --[[
            Add a weapon to the society

            name string = Name of the weapon
            quantity number = Quantity of the weapon to add
        ]]
        self.AddWeapon = function(name, quantity)
            name = name:lower()
    
            if self.weapon[name] then
                self.weapon[name] = self.weapon[name] + quantity
            else
                self.weapon[name] = quantity
            end
        end

        --[[
            Remove a weapon from the society

            weapon string = Name of the weapon
            quantity number = Quantity of the weapon to remove
        ]]
        self.RemoveWeapon = function(name, quantity)
            name = name:lower()
    
            if self.weapon[name] then
                self.weapon[name] = self.weapon[name] - quantity 
                
                if self.weapon[name] <= 0 then 
                    self.weapon[name] = nil 
                end
            end
        end
        
        --[[
            Check if the society have a weapon

            name string = Name of the weapon

            return [boolean] = True if the society have the weapon
        ]]
        self.HaveWeapon = function(name)
            name = name:lower()
            return (self.weapon[name] ~= nil)
        end
    -- Billing

        --[[
            Create a new billing

            target number = Source of the target
            reason string = Reason of the billing
            amount number = Amount of the billing
        ]]
        self.CreateBill = function(target, reason, amount)
            local uPlayer = Utility.PlayersData[GetPlayerIdentifiers(target)[1]]

            -- Create the bill for the player
            table.insert(uPlayer.other_info.bills, {[1] = self.name, [2] = reason, [3] = tonumber(amount)})
            
            local player = Player(self.source).state
            player.other_info = self.other_info
        end
    
    -- Vehicles

        self.BuyVehicle = function(components)
            
        end
    return self
end

CreateSociety = function(self)
    self.money       = json.decode(self.money) or {bank = 0, black = 0}
    self.deposit     = json.decode(self.deposit)
    self.weapon      = json.decode(self.weapon)
    self.vehicles    = {}

    self = BuildWeight(self)
    self = BuildVehicles(self)

    self.Build = function()
        Log("Building", "Society "..self.name.." builded")
        self.__type = "uSociety"
        self = BuildFunctions(self)
        Utility.SocietyData[self.name] = self
    end
    self.IsBuilded = function()
        return (Utility.SocietyData[self.name].__type ~= nil)
    end
    self.Demolish = function()
        Utility.SocietyData[self.name] = {
            name      = self.name,
            money     = self.money,
            deposit   = self.deposit,
            weapon    = self.weapon,
            Build     = self.Build,
            Demolish  = self.Demolish,
            IsBuilded = self.IsBuilded,
        }
    end
    
    Utility.SocietyData[self.name] = self
end

GetSociety = function(name)
    if not name or Utility.SocietyData[name] == nil then
        error("GetSociety: no valid society name provided")
    end

    if not Utility.SocietyData[name]:IsBuilded() then
        Utility.SocietyData[name]:Build()
    end

    return Utility.SocietyData[name]
end


LoadSociety = function()
    local society = MySQL.Sync.fetchAll('SELECT name, money, deposit, weapon FROM society', {})

    if society == nil then error("Unable to connect with the table `society`, try to check the MySQL status!") return end

    for i=1, #society do
        CreateSociety(society[i])
    end

    return #society
end