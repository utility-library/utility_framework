BuildFunctions = function(self)
    -- Money
        self.AddMoney = function(type, amount)
            self.money[type] = self.money[type] + tonumber(amount)
            --UpdateDatabase(self, "money")
        end
        
        self.RemoveMoney = function(type, amount)
            self.money[type] = self.money[type] - tonumber(amount)
            --UpdateDatabase(self, "money")
        end
    
        self.GetMoney = function(type)
            return {count = self.money[type], label = GetLabel("accounts", nil, type) or type}
        end
    
        self.HaveMoneyQuantity = function(type, quantity)
            return self.money[type] >= tonumber(quantity)
        end
        
    -- Inventory
        self.AddItem = function(name, quantity)
            if self.deposit[name] then
                self.deposit[name] = self.deposit[name] + quantity
            else
                self.deposit[name] = quantity
            end
            --UpdateDatabase(self, "deposit")
        end
    
        self.RemoveItem = function(name, quantity)
            if self.deposit[name] then
                self.deposit[name] = self.deposit[name] - quantity 
                
                if self.deposit[name] <= 0 then 
                    self.deposit[name] = nil 
                end
                
                --UpdateDatabase(self, "deposit")
            end
        end
    
        self.GetItem = function(name)
            return {count = self.deposit[name], label = GetLabel("items", nil, name) or name}
        end
    
        self.HaveItemQuantity = function(name, quantity)
            return self.deposit[name] >= quantity
        end

    -- Weapon
        self.AddWeapon = function(name, quantity)
            name = name:lower()
    
            if self.weapon[name] then
                self.weapon[name] = self.weapon[name] + quantity
            else
                self.weapon[name] = quantity
            end
    
            --UpdateDatabase(self, "weapon")
        end
        self.RemoveWeapon = function(name, quantity)
            name = name:lower()
    
            if self.weapon[name] then
                self.weapon[name] = self.weapon[name] - quantity 
                
                if self.weapon[name] <= 0 then 
                    self.weapon[name] = nil 
                end
    
                --UpdateDatabase(self, "weapon")
            end
        end
        self.HaveWeapon = function(name)
            name = name:lower()
            return (self.weapon[name] ~= nil)
        end
    -- Billing
        self.CreateBill = function(target_source, reason, amount)
            local uPlayer = Utility.PlayersData[GetPlayerIdentifiers(target_source)[1]]

            -- Create the bill for the player
            table.insert(uPlayer.other_info.bills, {[1] = self.name, [2] = reason, [3] = tonumber(amount)})
            TriggerClientEvent("Utility:UpdateClient", self.source, "bills", self.other_info.bills, true)
        end

    return self
end

CreateSociety = function(self)
    self.money       = json.decode(self.money) or {bank = 0, black = 0}
    self.deposit     = json.decode(self.deposit)
    self.weapon      = json.decode(self.weapon)
        

    self.Build = function()
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
    return Utility.SocietyData[name]
end


LoadVehicles = function()
    local society = oxmysql:fetchSync('SELECT name, money, deposit, weapon FROM society', {})

    if society == nil then error("Unable to connect with the table `society`, try to check the MySQL status!") return end

    for i=1, #society do
        CreateSociety(society[i])
    end

    return #society
end