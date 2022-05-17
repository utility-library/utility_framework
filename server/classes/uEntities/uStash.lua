local function BuildFunctions(self)
    self.UpdateClient = function(property)
        check({property = "string"})

        self.state[property] = self[property]
    end

    self.AddItem = function(name, quantity, data)
        AddItemInternal(name, quantity, data, self)

        Log("Item", "Added "..quantity.." "..name.." to stash "..self.identifier)
        self.UpdateClient("items")
        EmitEvent("StashItemAdded", -1, self.identifier, name, quantity, data)
    end

    self.RemoveItem = function(name, quantity, data)
        RemoveItemInternal(name, quantity, data, self)

        Log("Item", "Removed "..quantity.." "..name.." from stash "..self.identifier)
        self.UpdateClient("items")
        EmitEvent("StashItemRemoved", -1, self.identifier, name, quantity, data)
    end

    self.InsertItem = function(source, name, quantity, data)
        local uPlayer = GetPlayer(source)

        if uPlayer.HaveItemQuantity(name, quantity, data) then
            uPlayer.RemoveItem(name, quantity, data)
            self.AddItem(name, quantity, data)
        end

        Log("Item", "Inserted "..quantity.." "..name.." from "..uPlayer.identifier.." to "..self.identifier)
        EmitEvent("StashItemInserted", uPlayer.source, self.identifier, name, quantity, data)
    end

    self.TakeItem = function(uPlayer, name, quantity, data)
        local uPlayer = GetPlayer(source)

        if self.HaveItemQuantity(name, quantity, data) then
            self.RemoveItem(name, quantity, data)
            uPlayer.AddItem(name, quantity, data)
        end

        Log("Item", "Taken "..quantity.." "..name.." from "..self.identifier.." to "..uPlayer.identifier)
        EmitEvent("StashItemTaken", uPlayer.source, name, quantity, data)
    end

    self.GetItem = function(name, data)
        GetItemInternal(name, data, self.items)
    end

    self.HaveItemQuantity = function(name, quantity, data)
        HaveItemQuantityInternal(name, quantity, data, self.items)
    end

    self.CanCarryItem = function(name, quantity)
        return CanCarryItemInternal(name, quantity, self)
    end

    return self
end

local function BuildWeight(self)
    for _, v in pairs(self.items) do
        self.weight = self.weight + CalculateItemWeight(v[1], v[2])
    end

    return self
end

Stash = class {
    identifier = "none",
    items = {},
    
    -- Constructor
    _Init = function(self)
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
            items = self.items,
            weight = self.weight,
            maxWeight = self.maxWeight,
            save = self.save
        }
    end
}

CreateStash = function(identifier, weight, save)
    if save then
        MySQL.Async.execute("INSERT INTO stashes (identifier, items, weight) VALUES (@identifier, @items, @weight)", {
            identifier = identifier,
            items = "[]",
            weight = weight
        })
    end

    local stash = Stash({
        identifier = identifier,
        maxWeight = weight,
        save = save
    })
    stash:Build()

    return Utility.Stashes[identifier]
end

GetStash = function(id)
    if not Utility.Stashes[id]:IsBuilded() then
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
    local stashes = MySQL.Sync.fetchAll('SELECT identifier, items, weight FROM stashes', {})
    if stashes == nil then error("Unable to connect with the table `stashes`, try to check the MySQL status!") return end

    for i=1, #stashes do
        Stash({
            identifier = stashes[i].identifier,
            items = json.decode(stashes[i].items),
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
            MySQL.Sync.execute('UPDATE stashes SET items = :items WHERE identifier = :identifier', {
                items      = json.encode(v.items),
                identifier = v.identifier
            })
        end
    end
end