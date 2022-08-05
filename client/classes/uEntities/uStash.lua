BuildStash = function(self)
    for k,v in pairs(self.datas) do
        self[k] = v
    end
    self.datas = nil

    self.GetItem = function(name, data)
        check({name = "string"})

        return GetItemInternal(name, data, self.items)
    end

    self.FindItems = function(name, filter)
        check({name = "string"})

        return FindItems(name, self, filter)
    end

    self.HaveItemQuantity = function(name, quantity, data)
        check({name = "string", quantity = "number"})

        return HaveItemQuantityInternal(name, quantity, data, self)
    end

    self.CanCarryItem = function(name, quantity)
        check({name = "string", quantity = "number"})

        return CanCarryItemInternal(name, quantity, self)
    end

    -- Weapon
        --[[
            Check if the society have a weapon

            name string = Name of the weapon

            return [boolean] = True if the society have the weapon
        ]]
        self.HaveWeapon = function(name)
            check({name = "string"})

            if self.weapons then
                name = name:lower()
                return (self.weapons[CompressWeapon(name)] ~= nil)
            end
        end

    -- Money
        --[[
            Get money from the society

            type string = Type of the money (bank, cash, black)

            return number = Amount of money 
        ]]
        self.GetMoney = function(type)
            check({type = "string"})

            if self.accounts then
                return {quantity = (self.accounts[type] or 0), label = Config.Labels["accounts"][type] or type}
            end
        end
    
        --[[
            Check if the society has money

            type string = Type of the money (bank, cash, black)
            quantity number = Quantity of money to check

            return [boolean] = True if the society have the money
        ]]
        self.HaveMoneyQuantity = function(type, quantity)
            check({type = "string", quantity = "number"})

            if self.accounts then
                return (self.data.accounts[type] or 0) >= tonumber(quantity)
            end
        end

    return self        
end

GetStash = function(identifier)
    if not identifier:find(":") then
        identifier = "stash:"..identifier
    end

    local state = NewCustomStateBag(identifier, true)

    print("State: "..json.encode(state))
    return BuildStash(state)
end

exports("GetStash", GetStash)