local function ExistInAGroup(steam)
    if Config.Group[steam] then
        --print("Have a group: "..Config.Group[steam])
        ExecuteCommand("add_principal identifier.steam:"..steam.." group."..Config.Group[steam])
        return Config.Group[steam]
    else
        return "user"
    end
end

local function BuildFunctions(self)
    -- Money

        --[[
            Adds money to the player

            type string = Type of money (cash, bank, black)
            amount number = Amount of money
        ]]
        self.AddMoney = function(_type, amount)
            Log("Money", "Added "..amount.." ".._type.." to "..self.source)
            _type = GetAccountIndex(_type)

            self.accounts[_type] = self.accounts[_type] + tonumber(amount)

            local player = Player(self.source).state
            player.accounts = self.accounts
        end

        --[[
            Sets money of the player

            type string = Type of money (cash, bank, black)
            amount number = Amount of money
        ]]
        self.SetMoney = function(type, amount)
            Log("Money", "Setted "..amount.." "..type.." to "..self.source)
            type = GetAccountIndex(type)

            self.accounts[_type] = tonumber(amount)

            local player = Player(self.source).state
            player.accounts = self.accounts
        end

        --[[
            Removes money from the player

            type string = Type of money (cash, bank, black)
            amount number = Amount of money
        ]]
        self.RemoveMoney = function(type, amount)
            Log("Money", "Removed "..amount.." "..type.." to "..self.source)

            type = GetAccountIndex(type)                
            
            self.accounts[_type] = self.accounts[_type] - tonumber(amount)

            local player = Player(self.source).state
            player.accounts = self.accounts
        end

        --[[
            Get info from money type

            type string = Type of money (cash, bank, black)

            return [table] = A table with the childs: `count` and `label`
        ]]
        self.GetMoney = function(type)
            return {count = self.accounts[GetAccountIndex(type)], label = GetLabel("accounts", nil, type) or type}
        end

        --[[
            Check if the player have that money quantity

            type string = Type of money (cash, bank, black)
            quantity number = Quantity to money to check

            return [boolean] = True if have money quantity, false if dont have it
        ]]
        self.HaveMoneyQuantity = function(type, quantity)
            type = GetAccountIndex(type)
            return (self.accounts[type] >= tonumber(quantity))
        end
    -- Item
        --[[
            Add an item to the player

            name string = The name of the item (example: bread)
            quantity number = Quantity to add of that item
            itemid string [-] = The id of the item [Need ItemData]
            data any [-] = The data to associate to the item id [Need ItemData]
        ]]
        self.AddItem = function(name, quantity, itemid, data)
            if Config.Actived.ItemData then    
                -- Item name check
                if itemid == nil then itemid = "nodata" end
                    

                -- Item id check
                if not self.inventory[name] then
                    self.inventory[name] = {}
                end

                if not self.inventory[name][itemid] then
                    -- Item id dont exist (new item)
                    self.inventory[name] = {
                        [itemid] = {
                            [1] = tonumber(quantity),
                            [2] = data or nil,
                        }
                    }
                else
                    -- Item id already exist (adding new quantity)
                    self.inventory[name][itemid][1] = self.inventory[name][itemid][1] + tonumber(quantity)
                end

                -- Weight calculation
                if Config.Inventory.type == "weight" then
                    local _weight = (Config.Inventory.itemdata[name] or Config.Inventory.defaultitem)
                    self.weight = self.weight + (_weight * quantity)
                end

                Log("Item", "Added "..quantity.." "..name.." ["..itemid.."] to "..self.source)
            else
                if type(name) == "table" then
                    for k, v in pairs(name) do
                        if self.inventory[k] then
                            self.inventory[k] = self.inventory[k] + tonumber(string.format("%.0f", v))
                        else
                            self.inventory[k] = tonumber(string.format("%.0f", v))
                        end

                        if Config.Inventory.type == "weight" then
                            self.weight = self.weight + ((Config.Inventory.itemdata[k] or Config.Inventory.defaultitem) * v)
                        end
                    end
                else
                    if self.inventory[name] then
                        self.inventory[name] = self.inventory[name] + tonumber(string.format("%.0f", quantity))
                    else
                        self.inventory[name] = tonumber(string.format("%.0f", quantity))
                    end

                    if Config.Inventory.type == "weight" then
                        self.weight = self.weight + ((Config.Inventory.itemdata[name] or Config.Inventory.defaultitem) * quantity)
                    end
                end

                Log("Item", "Added "..quantity.." "..name.." to "..self.source)
            end

            local player = Player(self.source).state
            player.inventory = self.inventory
            player.weight = self.weight
        end

        --[[
            Remove an item from the player

            name string = The name of the item (example: bread)
            quantity number = Quantity to add of that item
            itemid string [-] = The id of the item [Need ItemData]
        ]]
        self.RemoveItem = function(name, quantity, itemid)
            if Config.Actived.ItemData then
                if itemid == nil then itemid = "nodata" end

                if self.inventory[name] and self.inventory[name][itemid] then
                    self.inventory[name][itemid][1] = self.inventory[name][itemid][1] - quantity

                    if self.inventory[name][itemid][1] <= 0 then self.inventory[name][itemid] = nil end

                    -- Weight calculation
                    if Config.Inventory.type == "weight" then
                        local _weight = (Config.Inventory.itemdata[name] or Config.Inventory.defaultitem)
                        self.weight = self.weight - (_weight * quantity)
                    end

                    Log("Item", "Removed "..quantity.." "..name.." ["..itemid.."] from "..self.source)
                end
            else
                if self.inventory[name] then
                    if type(name) == "table" then
                        for k, v in pairs(name) do
                            self.inventory[k] = self.inventory[k] - v 
                            if self.inventory[k] <= 0 then self.inventory[k] = nil end

                            if Config.Inventory.type == "weight" then
                                self.weight = self.weight - ((Config.Inventory.itemdata[k] or Config.Inventory.defaultitem) * quantity)
                            end
                        end
                    else
                        self.inventory[name] = self.inventory[name] - quantity 
                        if self.inventory[name] <= 0 then self.inventory[name] = nil end

                        if Config.Inventory.type == "weight" then
                            self.weight = self.weight - ((Config.Inventory.itemdata[name] or Config.Inventory.defaultitem) * quantity)
                        end
                    end

                    Log("Item", "Removed "..quantity.." "..name.." from "..self.source)
                end   
            end

            local player = Player(self.source).state
            player.accounts = self.accounts
        end

        --[[
            Get info from item

            name string = The name of the item
            itemid string [-] = The id of the item [Need ItemData]

            return [table] = A table with the childs: `count`, `label`, `data` [Need ItemData] and `weight` or `limit`  
        ]]
        self.GetItem = function(name, itemid)
            if Config.Actived.ItemData then
                if not itemid then -- if there is a itemid defined
                    itemid = "nodata"
                end

                if Config.Inventory.type == "weight" then
                    return {count = self.inventory[name][itemid][1], label = GetLabel("items", nil, name) or name, weight = Config.Inventory.itemdata[name] or Config.Inventory.defaultitem, data = self.inventory[name][itemid][2], __type = "item"}
                elseif Config.Inventory.type == "limit" then
                    return {count = self.inventory[name][itemid][1], label = GetLabel("items", nil, name) or name, limit = Config.Inventory.itemdata[name] or Config.Inventory.defaultitem, data = self.inventory[name][itemid][2], __type = "item"}
                end
            else
                if Config.Inventory.type == "weight" then
                    return {count = self.inventory[name], label = GetLabel("items", nil, name) or name, weight = Config.Inventory.itemdata[name] or Config.Inventory.defaultitem, __type = "item"}
                elseif Config.Inventory.type == "limit" then
                    return {count = self.inventory[name], label = GetLabel("items", nil, name) or name, limit = Config.Inventory.itemdata[name] or Config.Inventory.defaultitem, __type = "item"}
                end
            end
        end
    -- Only ItemData
        --[[
            Get item count for every existing id of that item

            name string = The name of the item

            return [number] = The number of the item founded
        ]]
        self.GetItemCount = function(name)
            local itemIds = self.GetItemIds(name)
            local count = 0

            for i=1, #itemIds do
                count = count + self.inventory[name][itemIds[i]][1]
            end

            return count
        end

        --[[
            Get ids of a item

            name string = The name of the item

            return [table] = A table with every item id as value
        ]]
        self.GetItemIds = function(name)
            if Config.Actived.ItemData then
                local ids = {}
            
                for k, v in pairs(self.inventory[name]) do
                    table.insert(ids, k)
                end

                return ids
            end
        end

        --[[
            Use an specific item

            name string = The name of the item
            id string [-] = The item id [Need ItemData]
        ]]
        self.UseItem = function(name, id)
            if id then
                if GlobalState.UsableItem[name] and GlobalState.UsableItem[name][id] then
                    Log("Item", self.source.." used "..name.." ["..id.."]")

                    TriggerEvent("Utility_Usable:"..name..":"..id, self)
                end
            else
                if GlobalState.UsableItem[name] then
                    Log("Item", self.source.." used "..name)

                    TriggerEvent("Utility_Usable:"..name, self)
                end
            end
        end

        --[[
            Check if a item is usable or no

            name string = The name of the item
            id string [-] = The item id [Need ItemData]

            return [boolean] = True if the item is usable, false if item isnt usable
        ]]
        self.IsItemUsable = function(name, id)
            if id then
                return GlobalState.UsableItem[name][id] or false
            else
                return GlobalState.UsableItem[name] or false
            end
        end

        --[[
            Check if the player have an item quantity

            name string = The name of the item
            id string [-] = The item id [Need ItemData]
            quantity number = The quantity to check

            return [boolean] = True if the item is usable, false if item isnt usable
        ]]
        self.HaveItemQuantity = function(name, id, quantity)
            if Config.Actived.ItemData then
                if not id then
                    id = "nodata"
                end

                if self.inventory[name] and self.inventory[name][id] then
                    return (self.inventory[name][id][1] >= quantity)
                else
                    return nil
                end
            else
                if self.inventory[name] then
                    return (self.inventory[name] >= id)
                else
                    return nil
                end
            end
        end

        --[[
            Check if the player can carry an item quantity

            name string = The name of the item
            quantity number = The quantity to check

            return [boolean] = True if the item can be carried, false if item cant be carried
        ]]
        self.CanCarryItem = function(name, quantity)
            local weight_limit = Config.Inventory.itemdata[name] or Config.Inventory.defaultitem

            if Config.Inventory.type == "weight" then
                if (self.weight + (weight_limit * quantity)) > self.maxWeight then
                    return false
                else
                    return true
                end
            elseif Config.Inventory.type == "limit" then
                if not self.limit[name] then
                    return true
                end

                if (self.limit[name] + quantity) <= weight_limit then
                    return true
                else
                    return false
                end
            end
        end

        --[[
            Send an item to another player

            name string = The name of the item
            quantity number = The quantity to transfer
            id string [-] = The item id [Need ItemData]
            target number = The target source (id)
        ]]
        self.SendItem = function(name, quantity, id, target)
            if Config.Actived.ItemData then
                if self.HaveItemQuantity(name, id, target) then 
                    self.RemoveItem(name, quantity, id)
                    
                    GlobalState.PlayersData[GetPlayerIdentifier(target, 0)].AddItem(name, quantity, id)
                end
            else
                target = id

                if self.HaveItemQuantity(name, quantity) then 
                    self.RemoveItem(name, quantity)
                    GlobalState.PlayersData[GetPlayerIdentifier(target, 0)].AddItem(name, quantity)
                end
            end
        end
        -- Only weight

        --[[
            Set max weight of the player, can be used for bag or other

            weight number = The new max weight
        ]]
        self.SetMaxWeight = function(weight)
            self.maxWeight = weight

            local player = Player(self.source).state
            player.maxWeight = self.maxWeight
        end 
    -- Job

        --[[
            Set the job of the player

            name string = The name of the job
            grade number = The grade of the job
            type number = The type of the job (example: 1 is the first job, 2 is the second job)
        ]]
        self.SetJob = function(name, grade, type)     
            local OldJob = self.jobs[type or 1]

            if self.jobs[type or 1] ~= nil then
                RemoveFromJob(self.jobs[type or 1].name, self.source)
            end
        
            self.jobs[type or 1].name  = name

            local grades = Config.Jobs.Configuration[self.jobs[type or 1].name]

            if grades then
                self.jobs[type or 1].label = Config.Jobs.Configuration[self.jobs[type or 1].name].name

                local _grade = grades.grades[grade]

                if _grade then
                    self.jobs[type or 1].grade = {
                        id     = grade,
                        label  = grades.grades[grade].label,
                        salary = grades.grades[grade].salary,
                        boss   = grades.grades[grade].boss,
                    }
                else
                    self.jobs[type or 1].grade = {
                        id     = grade,
                        label  = "unknown",
                        salary = 0,
                        boss   = false,
                    }
                end
            else
                self.jobs[type or 1].label = name
                self.jobs[type or 1].grade = {
                    id     = grade,
                    label  = "unknown",
                    salary = 0,
                    boss   = false,
                }
            end
            
            AddToJob(self.jobs[type or 1].name, self.source)

            Log("Jobs", self.source.." have changed job "..(type or 1).." from "..(OldJob.name or "unkown").." to "..name.." "..grade)
            
            local player = Player(self.source).state
            player.jobs = self.jobs

            TriggerClientEvent("Utility:Emitter:JobChange", self.source, OldJob, self.jobs)
        end

        --[[
            Set the job grade of the current player job

            grade number = The grade of the job
            type number = The type of the job (example: 1 is the first job, 2 is the second job)
        ]]
        self.SetJobGrade = function(grade, type)
            local OldGrade = self.jobs[type or 1].grade.id
            local grades = Config.Jobs.Configuration[self.jobs[type or 1].name]

            if grades then
                local _grade = grades.grades[grade]

                if _grade then
                    self.jobs[type or 1].grade = {
                        id     = grade,
                        label  = grades.grades[grade].label,
                        salary = grades.grades[grade].salary,
                        boss   = grades.grades[grade].boss,
                    }
                else
                    self.jobs[type or 1].grade = {
                        id     = grade,
                        label  = "unkown",
                        salary = 0,
                        boss   = false,
                    }
                end
            else
                self.jobs[type or 1].grade = {
                    id     = grade,
                    label  = "unkown",
                    salary = 0,
                    boss   = false,
                }
            end
                
            Log("Jobs", self.source.." have changed grade "..(type or 1).." from "..OldGrade.." to "..grade)

            local player = Player(self.source).state
            player.jobs = self.jobs

            TriggerClientEvent("Utility:Emitter:GradeChange", self.source, OldGrade, grade)
        end

        --[[
            Set the player onduty of the current job

            onduty boolean = If true it set in duty, otherwise it is taken out of duty
            type number = The type of the job (example: 1 is the first job, 2 is the second job)
        ]]
        self.SetDuty = function(onduty, type)
            self.jobs[type or 1].onduty = onduty

            local player = Player(self.source).state
            player.jobs = self.jobs

            TriggerClientEvent("Utility:Emitter:OnDuty", self.source, onduty)
        end
    -- Identity
        self.SetIdentity = function(identity)
            for k,v in pairs(identity) do
                for i=1, #Config.Identity do
                    if k == Config.Identity[i] then
                        self.identity[i] = v
                    end
                end
            end

            local player = Player(self.source).state
            player.identity = self.identity
        end
        self.GetIdentity = function(data)
            if data then
                for i=1, #Config.Identity do
                    if Config.Identity[i] == data then
                        return self.identity[i]
                    end
                end
            else
                return self.identity
            end
        end
    -- Weapon
        self.AddWeapon = function(weapon, ammo, equipNow)
            if type(weapon) == "table" then    
                for k,v in pairs(weapon) do
                    GiveWeaponToPed(self.ped, GetHashKey(k), v, false, false)
                    self.other_info.weapon[k:lower()] = v
                end
            else
                GiveWeaponToPed(self.ped, GetHashKey(weapon), ammo, false, equipNow)
                self.other_info.weapon[weapon:lower()] = ammo
            end
            Log("Weapon", "Adding "..weapon.." with "..ammo.." to "..self.source)

            PlayersData.update(self.steam, {other_info = self.other_info})
            TriggerClientEvent("Utility:Refresh", self.source)
        end
        self.RemoveWeapon = function(weapon)
            if type(weapon) == "table" then    
                for i=1, #weapon do
                    RemoveWeaponFromPed(self.ped, GetHashKey(weapon[i]))
                    self.other_info.weapon[weapon[i]:lower()] = nil
                end
            else
                RemoveWeaponFromPed(self.ped, GetHashKey(weapon))
                self.other_info.weapon[weapon:lower()] = nil
            end
            Log("Weapon", "Removed "..weapon.." from "..self.source)

            PlayersData.update(self.steam, {other_info = self.other_info})
            TriggerClientEvent("Utility:Refresh", self.source)
        end

        self.AddWeaponAmmo = function(weapon, ammo)
            local _ammo = self.other_info.weapon[weapon:lower()]
            SetPedAmmo(self.ped, GetHashKey(weapon), _ammo + ammo)

            PlayersData.update(self.steam, {other_info = self.other_info})
            TriggerClientEvent("Utility:Refresh", self.source)
        end
        self.RemoveWeaponAmmo = function(weapon, ammo)
            local _ammo = self.other_info.weapon[weapon:lower()]
            SetPedAmmo(self.ped, GetHashKey(weapon), _ammo - ammo)

            PlayersData.update(self.steam, {other_info = self.other_info})
            TriggerClientEvent("Utility:Refresh", self.source)
        end
        self.GetWeaponAmmo = function(name)
            return self.other_info.weapon[name:lower()] or 0
        end
        self.HaveWeapon = function(name)
            return self.other_info.weapon[name:lower()] ~= nil
        end

        self.GetWeapons = function()
            return self.other_info.weapon or {}
        end

        self.DisassembleWeapon = function(name)
            local ammo = self.GetWeaponAmmo(name)
            self.RemoveWeapon(name)
            self.AddItem(name, ammo)
        end
        self.AssembleWeapon = function(name)
            local ammo = self.GetItem(name).count
            self.RemoveItem(name, ammo)
            self.AddWeapon(name, ammo)
        end

    -- Death
        self.Revive = function()
            TriggerClientEvent("Utility:Revive", self.source)
        end

        self.IsDeath = function()
            return self.other_info.isdeath
        end
        self.GetDeaths = function()
            return self.other_info.death or 0
        end
        self.GetKills = function()
            return self.other_info.kill or 0
        end
    -- License
        self.AddLicense = function(name)
            self.other_info.license[name] = true 
            Log("License", "Adding "..name.." to "..self.source)
            
            PlayersData.update(self.steam, {other_info = self.other_info})
            TriggerClientEvent("Utility:Refresh", self.source)
        end
        self.RemoveLicense = function(name)
            if self.other_info.license[name] then
                self.other_info.license[name] = nil 
                Log("License", "Removing "..name.." from "..self.source)
                
                PlayersData.update(self.steam, {other_info = self.other_info})
                TriggerClientEvent("Utility:Refresh", self.source)
            end
        end
        self.GetLicenses = function()        
            local _ = {}
            
            for k,v in pairs(self.other_info.license) do
                _[k] = {name = v, label = GetLabel("license", nil, v)}
            end

            return _
        end
        self.HaveLicense = function(name)
            return self.other_info.license[name] or false
        end
    -- Billing
        self.GetBill = function(id)
            return id and self.other_info.bills[id] or self.other_info.bills
        end
        self.PayBill = function(id)
            local bill_info = self.other_info.bills[id]

            if self.HaveMoneyQuantity("bank", bill_info[3]) then
                self.RemoveMoney("bank", bill_info[3])
                GlobalState.SocietyData[bill_info[1]].AddMoney("bank", bill_info[3])
                
                -- Delete the bill
                Log("Bills", self.source.." have payed bill "..id.." that cost "..bill_info[3].." and was created by "..bill_info[1])

                
                table.remove(self.other_info.bills, id)

                PlayersData.update(self.steam, {other_info = self.other_info})
                TriggerClientEvent("Utility:Refresh", self.source)
                return true
            else
                return false
            end
        end
        self.RevokeBill = function(id)
            local bill_info = self.other_info.bills[id]

            if bill_info then
                Log("Bills", self.source.." have revoked the bill "..id.." info: "..json.encode(bill_info))

                table.remove(self.other_info.bills, id)

                PlayersData.update(self.steam, {other_info = self.other_info})
                TriggerClientEvent("Utility:Refresh", self.source)
                return true
            else
                return false
            end
        end
    -- Vehicles
        self.BuyVehicle = function(components)
            oxmysql:executeSync('INSERT INTO vehicles (plate, data) VALUES (:plate, :data)', {
                plate = components.plate[1],
                data  = json.encode(components),
            })

            table.remove(self.other_info.bills, id)
            table.insert(self.other_info.vehicles, components.plate[1])

            PlayersData.insert(self.steam, {other_info = self.other_info})
            Vehicles.insert({
                [components.plate[1]] = {
                    owner = self.steam,
                    plate = components.plate[1],
                    data  = components,
                    trunk = {}
                }
            })

            Log("Vehicle", self.source.." have buyed a vehicle with the plate "..components.plate[1])
            TriggerClientEvent("Utility:Refresh", self.source)                
        end
        self.TransferVehicleToPlayer = function(plate, target)
            if self.IsPlateOwned(plate) then 
                local target_steam = GetPlayerIdentifier(target, 0)

                table.remove(self.other_info.vehicles, plate)
                table.insert(GlobalState.PlayersData[target_steam].other_info.vehicles, plate)

                GlobalState.Vehicles[plate].owner = target_steam
                Log("Vehicle", self.source.." have transfered the vehicle with the plate "..plate.." to "..target)
                

                PlayersData.update(self.steam, {other_info = self.other_info})
                PlayersData.update(target_steam, {other_info = self.other_info})

                TriggerClientEvent("Utility:Refresh", self.source)         
                TriggerClientEvent("Utility:Refresh", GlobalState.PlayersData[target_steam].source)                
            end
        end
        self.IsPlateOwned = function(plate)
            for i=1, #self.other_info.vehicles do
                if self.other_info.vehicles[i] == plate then
                    return true
                end
            end

            return false
        end
    -- Other info integration
        self.Set = function(id, value)
            if type(value) == "table" then
                self.other_info.scripts[id] = json.encode(value)
            else
                self.other_info.scripts[id] = value
            end

            PlayersData.update(self.steam, {other_info = self.other_info})
            TriggerClientEvent("Utility:Refresh", self.source)         
        end
        self.Get = function(id)
            if id == nil then
                return self.other_info.scripts
            else
                local decoded = json.decode(self.other_info.scripts[id])

                if decoded ~= nil then
                    return decoded
                else
                    return self.other_info.scripts[id] or nil
                end
            end
        end
        self.Del = function(id)
            self.other_info.scripts[id] = nil

            PlayersData.update(self.steam, {other_info = self.other_info})
            TriggerClientEvent("Utility:Refresh", self.source)  
        end
    -- Ban
        self.Ban = function(reason)
            if reason:find("[TBP Auto Ban]") then
                if not Config.TriggerBasicProtection.AutoBan then
                    return
                end
            end

            local identifier = {}
            local token = {}

            for k,v in pairs(GetPlayerIdentifiers(self.source))do                            
                if v:find("steam:") then
                    identifier[1] = v
                elseif v:find("ip:") then
                    identifier[2] = v
                elseif v:find("discord:") then
                    identifier[3] = v
                elseif v:find("live:") then
                    identifier[4] = v
                elseif v:find("license:") then
                    identifier[5] = v
                elseif v:find("xbl:") then
                    identifier[6] = v
                end
            end

            for i=0,GetNumPlayerTokens(self.source) do
                table.insert(token, GetPlayerToken(self.source, i))
            end

            oxmysql:executeSync("INSERT INTO bans (name, data, token, internal_reason) VALUES (:name, :data, :token, :internal_reason)", {
                name  = self.name,
                data  = json.encode(identifier),
                token = json.encode(token),
                internal_reason = reason,
            })
            table.insert(Utility.Bans, {data = identifier, token = token})
            TriggerClientEvent("Utility:Ban", self.source)

            Log("Ban", self.source.." ("..self.name..") has been banned")
            DropPlayer(self.source, Config.Labels["framework"]["Banned"])
        end
    -- Config
        self.Config = function(field)
            return Config[field]
        end
    -- Other function
        self.ShowNotification = function(msg)
            TriggerClientEvent("Utility:Notification", self.source, msg)
        end
        self.ButtonNotification = function(msg, duration)
            TriggerClientEvent("Utility:ButtonNotification", self.source, msg, duration or 2000)
        end
        self.TriggerEvent = function(event, ...)
            TriggerClientEvent(event, self.source, ...)
        end

    return self
end

local function BuildOtherInfo(self)
    if self.other_info.isdeath == nil then self.other_info.isdeath = false end
    if self.other_info.license == nil then self.other_info.license = {} end
    if self.other_info.weapon == nil then self.other_info.weapon = {} end
    if self.other_info.bills == nil then self.other_info.bills = {} end
    if self.other_info.scripts == nil then self.other_info.scripts = {} end
    if self.other_info.vehicles == nil then self.other_info.vehicles = {} end
    
    --print("Other info builded")
    return self
end

local function BuildJobs(self)
    for i=1, #self.jobs do
        local id = self.jobs[i][2]
        self.jobs[i].name = self.jobs[i][1]
        self.jobs[i].onduty = self.jobs[i][3]

        if Config.Jobs.Configuration[self.jobs[i][1]] ~= nil then
            self.jobs[i].label = Config.Jobs.Configuration[self.jobs[i][1]].name
            self.jobs[i].grade = {
                id = id,
                label  = Config.Jobs.Configuration[self.jobs[i][1]].grades[id].label,
                salary = Config.Jobs.Configuration[self.jobs[i][1]].grades[id].salary,
                boss   = Config.Jobs.Configuration[self.jobs[i][1]].grades[id].boss,
            }
        else
            self.jobs[i].label = self.jobs[i][1]
            self.jobs[i].grade = {
                id = id,
                label  = "unknown",
                salary = 0,
                boss   = false,
            }  
        end

        self.jobs[i][1] = nil
        self.jobs[i][2] = nil
        self.jobs[i][3] = nil
    end

    return self
end

local function BuildInventory(self)
    if Config.Inventory.type == "weight" then
        self.maxWeight = Config.Inventory.max
        self.weight = 0
    
        for k,v in pairs(self.inventory) do
            if Config.Actived.ItemData then
                for _, v in pairs(v) do
                    local _weight = (Config.Inventory.itemdata[k] or Config.Inventory.defaultitem)
                    self.inventory[k][_] = v
                    self.weight = self.weight + (_weight * v[1])
                end
            else
                local _weight = (Config.Inventory.itemdata[k] or Config.Inventory.defaultitem)

                self.inventory[k] = tonumber(v)
                self.weight = self.weight + (_weight * v)
            end
        end
    elseif Config.Inventory.type == "limit" then
        self.limit = {}
    
        for k,v in pairs(self.inventory) do
            if Config.Actived.ItemData then
                for _, v in pairs(v) do
                    -- k = item name
                    -- _ = id of item
                    -- v = quantity and data
                    
                    self.inventory[k][_] = v
                    self.limit[k] = tonumber(v[1])
                end
            else
                self.inventory[k] = tonumber(v)
                self.limit[k] = tonumber(v)
            end
        end
    end

    return self
end



CreatePlayer = function(self)
        -- Need rewrite
    --[=[local vehicles = uPlayer.other_info.vehicles
    for i=1, #vehicles do
        if GlobalState.Vehicles[vehicles[i]] then
            local veh = GlobalState.Vehicles

            veh[vehicles[i]].owner = uPlayer.steam
            GlobalState.Vehicles = veh
        end
    end]=]
    
    self.steam = "steam:110000"..self.steam
    self.identity    = json.decode(self.identity) 
    self.inventory   = json.decode(self.inventory) 
    self.jobs        = json.decode(self.jobs) 
    self.accounts    = json.decode(self.accounts) 
    self.other_info  = json.decode(self.other_info) 

    self.Build = function(self)
        print("Server builded")
        self.__type = "uPlayer"
        self = BuildFunctions(self)

        Utility.PlayersData[self.steam] = self
    end
    self.ClientBuild = function(self, id)
        --[[for k,v in pairs(self) do
            print(k,v)
        end]]
        
        self.__type = "cuPlayer"

        self.source = id
        self.online = true
        self.group = ExistInAGroup(self.steam)
        self = BuildOtherInfo(self)
        self = BuildJobs(self)
        self = BuildInventory(self)

        Utility.PlayersData[self.steam] = self
    end

    self.IsBuilded = function()
        return (Utility.PlayersData[self.steam].__type ~= nil)
    end
    self.Demolish = function()
        Utility.PlayersData[self.steam] = {
            name        = self.name,
            steam       = self.steam,
            identity    = self.identity,
            inventory   = self.inventory,
            jobs        = self.jobs,
            accounts    = self.accounts,
            other_info  = self.other_info,
            Build       = self.Build,
            ClientBuild = self.ClientBuild,
            Demolish    = self.Demolish,
            IsBuilded   = self.IsBuilded,
        }
    end

    Utility.PlayersData[self.steam] = self
end

local steamCache = {}
GetPlayer = function(steam)
    if type(steam) == "string" then
        return Utility.PlayersData[steam]
    else
        if not steamCache[steam] then
            steamCache[steam] = GetPlayerIdentifier(steam, 0)
        end

        return Utility.PlayersData[steamCache[steam]]
    end
end

GetClientPlayer = function(id)
    local player = Player(id).state
    
    local metatable = {
        state = player,
        __newindex = function(self, index, new)
            player[index] = new
            Utility.PlayersData[player.steam][index] = new

            print("Setting \""..tostring(index).."\" to \""..tostring(new).."\" for "..id)
        end,
        setoi = function(k, v)
            local oi = player.other_info
            oi[k] = v

            player.other_info = oi
            Utility.PlayersData[player.steam].other_info[k] = v
            print("Setting other_info \""..tostring(k).."\" to \""..tostring(v).."\" for "..id)
        end
    }

    return setmetatable({}, metatable)
end


LoadPlayers = function()
    local users = oxmysql:fetchSync('SELECT name, accounts, inventory, jobs, identity, other_info, steam FROM users', {})

    if users == nil then error("Unable to connect with the table `users`, try to check the MySQL status!") return end
    for i=1, #users do
        CreatePlayer(users[i])
    end

    return #users
end


GeneratePlayer = function(id, identifier)
    local self = {
        IsNew       = true,
        steam       = identifier,
        name        = GetPlayerName(id),
        inventory   = {},
        accounts    = {},
        jobs        = {},
        identity    = {},
        other_info  = { 
            coords = {[1] = tonumber(Config.Start.Position.x), [2] = tonumber(Config.Start.Position.y), [3] = tonumber(Config.Start.Position.z)},
            isdeath = false,
            license = {},
            weapon = {},
            bills = {},
            scripts = {},
            vehicles = {},
        },
    }
    if next(Config.Start.Items) ~= nil then self.inventory = Config.Start.Items end

    -- Accounts
    if Config.Actived.Accounts then
        for i=1, #Config.Accounts do
            self.accounts[i] = Config.Start.Accounts[Config.Accounts[i]]
        end
    end

    -- Jobs
    if Config.Actived.Jobs then
        for i=1, #Config.Start.Job do
            self.jobs[i] = {
                [1] = Config.Start.Job[i][1],
                [2] = Config.Start.Job[i][2],
                [3] = true,
            }
        end
    end

    -- Identity
    if Config.Actived.Identity then
        for i=1, #Config.Identity do
            self.identity[i] = ""
        end
    end
    
    -- Convert the generated data like a player loaded from the database
    Utility.PlayersData[self.steam] = {
        name        = self.name,
        steam       = self.steam:gsub("steam:110000", ""),
        identity    = json.encode(self.identity),
        inventory   = json.encode(self.inventory),
        jobs        = json.encode(self.jobs),
        accounts    = json.encode(self.accounts),
        other_info  = json.encode(self.other_info),
        IsNew       = true
    }

    CreatePlayer(Utility.PlayersData[self.steam])

    return Utility.PlayersData[self.steam]
end