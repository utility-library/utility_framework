local BuildWeight = function(self)
    if Config.Inventory.Type == "weight" then
        self.maxWeight = Config.Inventory.MaxWeight
        self.weight = 0
    
        for k,v in pairs(self.datas.items) do
            self.weight = self.weight + CalculateItemWeight(k, v[2])
        end
    end

    return self
end

local function BuildFunctions(self)
    self.UpdateClient = function(property)
        check({property = "string"})

        self.state[property] = self[property]
    end

    self.AddItem = function(name, quantity, data)
        AddItemInternal(name, quantity, data, self)

        Log("Item", "Added "..quantity.." "..name.." to stash "..self.identifier)
        self.UpdateClient("datas")
        EmitEvent("StashItemAdded", -1, self.identifier, name, quantity, data)
    end

    self.AddItems = function(table)
        check({table = "table"})

        for k,v in pairs(table) do
            if type(v) == "table" then
                self.AddItem(k, v.quantity, v.data or nil)
            else
                self.AddItem(k, v)
            end
        end
    end

    self.RemoveItem = function(name, quantity, data)
        RemoveItemInternal(name, quantity, data, self)

        Log("Item", "Removed "..quantity.." "..name.." from stash "..self.identifier)
        self.UpdateClient("datas")
        EmitEvent("StashItemRemoved", -1, self.identifier, name, quantity, data)
    end

    self.RemoveItems = function(table)
        check({table = "table"})

        for k,v in pairs(table) do
            self.RemoveItem(k, v)
        end
    end

    self.InsertItem = function(source, name, quantity, data)
        local uPlayer = GetPlayer(source)

        if uPlayer.HaveItemQuantity(name, quantity, data) then
            uPlayer.RemoveItem(name, quantity, data)
            self.AddItem(name, quantity, data)

            Log("Item", "Inserted "..quantity.." "..name.." from "..uPlayer.identifier.." to "..self.identifier)
            EmitEvent("StashItemInserted", uPlayer.source, self.identifier, name, quantity, data)
            return true
        else
            return false
        end
    end

    self.TakeItem = function(uPlayer, name, quantity, data)
        local uPlayer = GetPlayer(source)

        if self.HaveItemQuantity(name, quantity, data) then
            self.RemoveItem(name, quantity, data)
            uPlayer.AddItem(name, quantity, data)

            Log("Item", "Taken "..quantity.." "..name.." from "..self.identifier.." to "..uPlayer.identifier)
            EmitEvent("StashItemTaken", uPlayer.source, name, quantity, data)
            return true
        else
            return false
        end
    end

    self.GetItem = function(name, data)
        return GetItemInternal(name, data, self)
    end

    self.FindItems = function(name, filter)
        check({name = "string"})

        return FindItems(name, self, filter)
    end

    self.HaveItemQuantity = function(name, quantity, data)
        return HaveItemQuantityInternal(name, quantity, data, self)
    end

    self.CanCarryItem = function(name, quantity)
        return CanCarryItemInternal(name, quantity, self)
    end

    self.SetMaxWeight = function(weight)
        check({weight = "number"})

        if Config.Inventory.Type == "weight" then
            self.maxWeight = weight

            self.UpdateClient("maxWeight")
            EmitEvent("StashMaxWeightSetted", self.identifier, weight)
        end
    end 



    -- Create the data tables only if its really needed, to save some memory
    self.CheckWeaponsData = function()
        if not self.datas.weapons then self.datas.weapons = {} end
        self.weapons = self.datas.weapons
    end
    self.CheckAccountsData = function(type)
        if not self.datas.accounts then self.datas.accounts = {} end
        if not self.accounts then self.accounts = self.datas.accounts end

        if self.accounts[type] == nil then self.accounts[type] = 0 end
    end

    -- Weapon

        --[[
            Add a weapon to the society

            name string = Name of the weapon
            quantity number = Quantity of the weapon to add
        ]]
        self.AddWeapon = function(name, quantity)
            self.CheckWeaponsData()
            name = name:lower()
    
            if self.weapons[name] then
                self.weapons[name] = self.weapons[name] + quantity
            else
                self.weapons[name] = quantity
            end

            EmitEvent("StashWeaponAdded", self.identifier, name, quantity)
        end

        --[[
            Remove a weapon from the society

            weapon string = Name of the weapon
        ]]
        self.RemoveWeapon = function(name)
            self.CheckWeaponsData()
            name = name:lower()
    
            if self.weapons[name] then
                self.weapons[name] = nil

                EmitEvent("StashWeaponRemoved", self.identifier, name)
            end
        end
        
        --[[
            Check if the society have a weapon

            name string = Name of the weapon

            return [boolean] = True if the society have the weapon
        ]]
        self.HaveWeapon = function(name)
            self.CheckWeaponsData()
            name = name:lower()
            return (self.weapons[name] ~= nil)
        end

    -- Money

        --[[
            Add money to the society

            type string = Type of the money (bank, cash, black)
            amount number = Amount of money to add
        ]]
        self.AddMoney = function(type, amount)
            self.CheckAccountsData(type)
            self.accounts[type] = self.accounts[type] + tonumber(amount)

            EmitEvent("StashMoneyAdded", self.identifier, type, amount)
        end
        
        --[[
            Remove money from the society

            type string = Type of the money (bank, cash, black)
            amount number = Amount of money to remove
        ]]
        self.RemoveMoney = function(type, amount)
            self.CheckAccountsData(type)
            self.accounts[type] = self.accounts[type] - tonumber(amount)

            EmitEvent("StashMoneyRemoved", self.identifier, type, amount)
        end

        self.SetMoney = function(type, amount)
            self.CheckAccountsData(type)
            self.accounts[type] = tonumber(amount)

            EmitEvent("StashMoneySetted", self.identifier, type, amount)
        end
    
        --[[
            Get money from the society

            type string = Type of the money (bank, cash, black)

            return number = Amount of money 
        ]]
        self.GetMoney = function(type)
            self.CheckAccountsData(type)
            return {quantity = self.accounts[type], label = GetLabel("accounts", nil, type) or type}
        end
    
        --[[
            Check if the society has money

            type string = Type of the money (bank, cash, black)
            quantity number = Quantity of money to check

            return [boolean] = True if the society have the money
        ]]
        self.HaveMoneyQuantity = function(type, quantity)
            self.CheckAccountsData(type)
            return self.accounts[type] >= tonumber(quantity)
        end

    return self
end

uStash = class {
    identifier = "none",
    datas = {},
    
    -- Constructor
    _Init = function(self)
        if self.datas.items == nil then self.datas.items = {} end

        if Config.Inventory.Type == "weight" then
            self.weight = 0
            
            if not self.maxWeight then
                self.maxWeight = Config.Inventory.MaxWeight
            end
        end
    
        Utility.Stashes[self.identifier] = self
    end,

    Build = function(self)
        local start = os.clock()

        self.__type = "uStash"
        self.state = NewCustomStateBag("stash:"..self.identifier)
        self = BuildFunctions(self)
        self = BuildWeight(self)

        Utility.Stashes[self.identifier] = self
        Log("Building", "uStash builded for "..self.identifier.." in "..((os.clock() - start)*1000).." ms")
    end,

    IsBuilded = function(self)
        return (self.__type == "uStash")
    end,

    Demolish = function(self)
        Utility.Stashes[self.identifier] = {
            identifier = self.identifier,
            datas = self.datas,
            weight = self.weight,
            maxWeight = self.maxWeight,
            save = self.save
        }
    end
}

CreateStash = function(identifier, weight, save)
    if save then
        MySQL.Async.execute("INSERT INTO stashes (identifier, datas, weight) VALUES (@identifier, @datas, @weight)", {
            identifier = identifier,
            datas = "[]",
            weight = weight
        })
    end

    Log("Building", "Creating stash "..identifier.." with weight "..(weight or 0).." and that "..(save and "need" or "dont need").." to be saved")
    local stash = uStash({
        identifier = identifier,
        maxWeight = weight,
        save = save
    })
    stash:Build()

    return Utility.Stashes[identifier]
end

GetStash = function(id)
    if Utility.Stashes[id] and not Utility.Stashes[id]:IsBuilded() then
        Utility.Stashes[id]:Build()
    end

    return Utility.Stashes[id]
end

DeleteStash = function(id)
    if Utility.Stashes[id] then
        Utility.Stashes[id] = nil
    end
end

DoesStashExist = function(id)
    return Utility.Stashes[id]
end

exports("CreateStash", CreateStash)
exports("GetStash", GetStash)
exports("DeleteStash", DeleteStash)
exports("DoesStashExist", DoesStashExist)

LoadStashes = function()
    local stashes = MySQL.Sync.fetchAll('SELECT identifier, datas, weight FROM stashes', {})
    if stashes == nil then error("Unable to connect with the table `stashes`, try to check the MySQL status!") return end

    for i=1, #stashes do
        uStash({
            identifier = stashes[i].identifier,
            datas = json.decode(stashes[i].datas),
            maxWeight = stashes[i].weight,
            save = true
        })
    end

    return #stashes
end

SaveStashes = function()
    Log("Save", "Saving automatically stashes")
    
    for k,v in pairs(Utility.Stashes) do
        if v.save then
            MySQL.Sync.execute('UPDATE stashes SET datas = :datas WHERE identifier = :identifier', {
                datas      = json.encode(v.datas),
                identifier = v.identifier
            })
        end
    end
end