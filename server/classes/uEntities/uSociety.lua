BuildWeight = function(self)
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
        if v.owner == "society:"..self.name then
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
            return {quantity = self.money[type], label = GetLabel("accounts", nil, type) or type}
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
            AddItemInternal(name, quantity, data, self)
        end
    
        --[[
            Remove an item from the society

            name string = Name of the item
            quantity number = Quantity of the item to remove
        ]]
        self.RemoveItem = function(name, quantity, data)
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
                data  = json.encode(components),
                trunk = "[]"
            })

            Log("Society", self.name.." have buyed a vehicle with the plate "..components.plate[1])
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
        self.deposit     = json.decode(self.deposit)
        self.weapon      = json.decode(self.weapon)
        self.vehicles    = {}

        Utility.SocietyData[self.name] = self
    end,

    Build = function(self)
        local start = os.clock()

        self.__type = "uSociety"

        self = BuildWeight(self)
        self = BuildVehicles(self)
        self = BuildFunctions(self)
        
        Log("Building", "uSociety builded for "..self.name.." in "..((os.clock() - start)*1000).." ms")

        Utility.SocietyData[self.name] = self
    end,

    IsBuilded = function(self)
        return (self.__type == "uSociety")
    end,

    Demolish = function(self)
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
}

GetSociety = function(name)
    if not name or Utility.SocietyData[name] == nil then
        error("GetSociety: no valid society name provided")
    end

    print(Utility.SocietyData[name]:IsBuilded())
    if not Utility.SocietyData[name]:IsBuilded() then
        Utility.SocietyData[name]:Build()
    end

    return Utility.SocietyData[name]
end


LoadSociety = function()
    local society = MySQL.Sync.fetchAll('SELECT name, money, deposit, weapon FROM society', {})
    if society == nil then error("Unable to connect with the table `society`, try to check the MySQL status!") return end

    for i=1, #society do
        uSociety({
            name      = society[i].name,
            money     = society[i].money,
            deposit   = society[i].deposit,
            weapon    = society[i].weapon,
        })
    end

    return #society
end