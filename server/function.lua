-- ServerCallback
    RegisterServerCallback = function(name, _function)
        RegisterServerEvent("Utility_Callback:"..name)
        AddEventHandler("Utility_Callback:"..name, function(...)
            local source = source
            source = source

            function cb(...)
                TriggerClientEvent("Utility_Callback:"..name.."_l", source, ...)
            end
            
            _function(...)
        end)
    end

    CreateMenu = function(id, title, content, cb, close)
        TriggerClientEvent("Utility:OpenMenu", id, title, content, cb, close)
    end

-- Logger
    local logId = math.random(0, 999)
    -- On framework start if the log type is file, create the log file with reading instructions
    if Config.AdvancedLog == "file" or Config.AdvancedLog == "both" then
        local log = io.open(GetResourcePath("utility_framework").."/logs/Utility_log_"..os.date("%y-%m-%d")..";"..logId..".txt", "a")
        log:write("[    Time] [CPUsec] [  Position] | [Message]\n--------------------------------------------\n")
        log:close()
    end

    LogToLogger = function(type, msg)
        if Config.AdvancedLog ~= "disabled" then
            if Config.AdvancedLog == "console" then
                print(string.format("[%s] [%d] [%s] | %s", os.date("%X"), math.floor(os.clock()), type, msg))
            elseif Config.AdvancedLog == "file" then
                local log = io.open(GetResourcePath("utility_framework").."/logs/Utility_log_"..os.date("%y-%m-%d")..";"..logId..".txt", "a")
                log:write(string.format("[%8s] [%6d] [%10s] | %s", os.date("%X"), math.floor(os.clock()), type, msg).."\n")
                log:close()
            elseif Config.AdvancedLog == "both" then
                print(string.format("[%s] [%d] [%s] | %s", os.date("%X"), math.floor(os.clock()), type, msg))
                local log = io.open(GetResourcePath("utility_framework").."/logs/Utility_log_"..os.date("%y-%m-%d")..";"..logId..".txt", "a")
                log:write(string.format("[%8s] [%6d] [%10s] | %s", os.date("%X"), math.floor(os.clock()), type, msg).."\n")
                log:close()
            end
        end
    end

-- Player loading
    ConvertJsonToTable = function(data, type)
        if type == 1 then
            data.identity    = json.decode(data.identity) 
            data.inventory   = json.decode(data.inventory) 
            data.jobs        = json.decode(data.jobs) 
            data.accounts    = json.decode(data.accounts) 
            data.other_info  = json.decode(data.other_info) 
        elseif type == 2 then
            data.money       = json.decode(data.money)
            data.deposit     = json.decode(data.deposit)
            data.weapon      = json.decode(data.weapon)
        end
        
        return data
    end

    GetGroup = function(steam)
        if Config.Group[steam] then
            group = Config.Group[steam]
        else
            group = "user"
        end

        return group
    end

    CopyTable = function(table)
        local NewTable = {}
    
        for k, v in pairs(table) do
            NewTable[k] = v
        end
    
        return NewTable
    end
    
    uPlayerPopulate = function(self)
        self.__type = "uplayer"

        if self.update == nil then
            self.update = function() end
        end

        self.group = GetGroup(self.steam)

        if self.group ~= "user" then
            ExecuteCommand("add_principal identifier.steam:"..self.steam.." group."..self.group)
        end

        if self.other_info.isdeath == nil then self.other_info.isdeath = false end
        if self.other_info.license == nil then self.other_info.license = {} end
        if self.other_info.weapon == nil then self.other_info.weapon = {} end
        if self.other_info.bills == nil then self.other_info.bills = {} end
    
    
        -- Weight 
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
    
        -- Function
            -- Money
                self.AddMoney = function(type, amount)
                    self.accounts[type] = self.accounts[type] + amount
                    self.update("accounts", self.accounts)
                    TriggerClientEvent("Utility:UpdateClient", self.source, "accounts", self.accounts)
                end

                -- New
                self.SetMoney = function(type, amount)
                    self.accounts[type] = tonumber(amount)
                    self.update("accounts", self.accounts)
                    TriggerClientEvent("Utility:UpdateClient", self.source, "accounts", self.accounts)
                end
    
                self.RemoveMoney = function(type, amount)
                    self.accounts[type] = self.accounts[type] - tonumber(amount)
                    self.update("accounts", self.accounts)
                    TriggerClientEvent("Utility:UpdateClient", self.source, "accounts", self.accounts)
                end
    
                self.GetMoney = function(type)
                    return {count = self.accounts[type], label = GetLabel("accounts", nil, type) or type}
                end
    
                self.HaveMoneyQuantity = function(_type, quantity)
                    return (self.accounts[_type] >= tonumber(quantity))
                end
            -- Item
    
                self.AddItem = function(name, quantity, itemid, data)
                    if Config.Actived.ItemData then
                        local itemidgenerated = false
    
                        -- Item name check
                        if not self.inventory[name] then 
                            self.inventory[name] = {} 
                        end
    
                        if itemid == nil then
                            itemid = "nodata"
                        end
                            
    
                        -- Item id check
                        print(json.encode(self.inventory[name]))
    
                        if not self.inventory[name][itemid] then
                            -- Item id dont exist (new item)
                            self.inventory[name][itemid] = {}
                            self.inventory[name][itemid][1] = tonumber(quantity)
                            self.inventory[name][itemid][2] = data or nil
                        else
                            -- Item id already exist (adding new quantity)
                            self.inventory[name][itemid][1] = self.inventory[name][itemid][1] + tonumber(quantity)
                        end
    
                        -- Weight calculation
                        if Config.Inventory.type == "weight" then
                            local _weight = (Config.Inventory.itemdata[name] or Config.Inventory.defaultitem)
                            self.weight = self.weight + (_weight * quantity)
                            TriggerClientEvent("Utility:UpdateClient", self.source, "weight", self.weight)
                        end

                        TriggerClientEvent("Utility:UpdateClient", self.source, "inventory", self.inventory)
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
    
                        TriggerClientEvent("Utility:UpdateClient", self.source, "inventory", self.inventory)

                        if Config.Inventory.type == "weight" then
                            TriggerClientEvent("Utility:UpdateClient", self.source, "weight", self.weight)
                        end
                    end

                    self.update("inventory", self.inventory)
                end
                self.RemoveItem = function(name, quantity, itemid)
                    if Config.Actived.ItemData then
                        if self.inventory[name] and self.inventory[name][itemid] then
                            self.inventory[name][itemid][1] = self.inventory[name][itemid][1] - quantity
    
                            if self.inventory[name][itemid][1] <= 0 then self.inventory[name][itemid] = nil end
    
                            -- Weight calculation
                            if Config.Inventory.type == "weight" then
                                local _weight = (Config.Inventory.itemdata[name] or Config.Inventory.defaultitem)
                                self.weight = self.weight - (_weight * quantity)
                                TriggerClientEvent("Utility:UpdateClient", self.source, "weight", self.weight)
                            end

                            TriggerClientEvent("Utility:UpdateClient", self.source, "inventory", self.inventory)
                            self.update("inventory", self.inventory)
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
        
                            TriggerClientEvent("Utility:UpdateClient", self.source, "inventory", self.inventory)

                            if Config.Inventory.type == "weight" then
                                TriggerClientEvent("Utility:UpdateClient", self.source, "weight", self.weight)
                            end
                            self.update("inventory", self.inventory)
                        end   
                    end
                end
                self.GetItem = function(name, itemid)
                    if Config.Actived.ItemData then
                        if itemid then -- if there is a itemid defined
                            if Config.Inventory.type == "weight" then
                                return {count = self.inventory[name][itemid][1], label = GetLabel("items", nil, name) or name, weight = Config.Inventory.itemdata[name] or Config.Inventory.defaultitem, data = self.inventory[name][itemid][2]}
                            elseif Config.Inventory.type == "limit" then
                                return {count = self.inventory[name][itemid][1], label = GetLabel("items", nil, name) or name, limit = Config.Inventory.itemdata[name] or Config.Inventory.defaultitem, data = self.inventory[name][itemid][2]}
                            end
                        else -- if there isnt (for item label and weight/limit)
                            if Config.Inventory.type == "weight" then
                                return {label = GetLabel("items", nil, name) or name, weight = Config.Inventory.itemdata[name] or Config.Inventory.defaultitem}
                            elseif Config.Inventory.type == "limit" then
                                return {label = GetLabel("items", nil, name) or name, limit = Config.Inventory.itemdata[name] or Config.Inventory.defaultitem}
                            end
                        end
                    else
                        if Config.Inventory.type == "weight" then
                            return {count = self.inventory[name], label = GetLabel("items", nil, name) or name, weight = Config.Inventory.itemdata[name] or Config.Inventory.defaultitem}
                        elseif Config.Inventory.type == "limit" then
                            return {count = self.inventory[name], label = GetLabel("items", nil, name) or name, limit = Config.Inventory.itemdata[name] or Config.Inventory.defaultitem}
                        end
                    end
                end
                
                -- Only ItemData
                self.GetItemCount = function(name)
                    local itemIds = self.GetItemIds(name)
                    local count = 0

                    for i=1, #itemIds do
                        count = count + self.inventory[name][itemIds[i]][1]
                    end

                    return count
                end
                self.GetItemIds = function(name)
                    if Config.Actived.ItemData then
                        local ids = {}
                    
                        for k, v in pairs(self.inventory[name]) do
                            table.insert(ids, k)
                        end
        
                        return ids
                    end
                end


                self.UseItem = function(name)
                    if Utility.UsableItem[name] then
                        TriggerEvent("Utility_Usable:"..name, self)
                    end
                end
                self.IsItemUsable = function(name)
                    return Utility.UsableItem[name] or false
                end
                self.HaveItemQuantity = function(name, id, quantity)
                    if Config.Actived.ItemData then
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

                -- Only weight
                self.SetMaxWeight = function(weight)
                    self.maxWeight = weight
                    self.update("maxWeight", self.maxWeight)
                    TriggerClientEvent("Utility:UpdateClient", self.source, "maxWeight", self.maxWeight)
                end 
            -- Job
                self.SetJob = function(name, grade, type)     
                    local OldJob = self.jobs[type or 1].name
    
                    if self.jobs[type or 1] ~= nil then
                        RemoveFromJob(self.jobs[type or 1].name, self.source)
                    end
                    
                    self.jobs[type or 1].name  = name
                    self.jobs[type or 1].grade = grade
                    
                    AddToJob(self.jobs[type or 1].name, self.source)

                    self.update("jobs", self.jobs)
                    TriggerClientEvent("Utility:UpdateClient", self.source, "jobs", self.jobs)
                    TriggerClientEvent("Utility_Emitter:job_change", self.source, OldJob, name)
                end
    
                self.SetJobGrade = function(grade, type)
                    local OldGrade = self.jobs[type or 1].grade
                    self.jobs[type or 1].grade = grade

                    self.update("jobs", self.jobs)
                    TriggerClientEvent("Utility:UpdateClient", self.source, "jobs", self.jobs)
                    TriggerClientEvent("Utility_Emitter:grade_change", self.source, OldGrade, grade)
                end
    
                self.SetDuty = function(onduty, type)
                    self.jobs[type or 1].onduty = onduty

                    self.update("jobs", self.jobs)
                    TriggerClientEvent("Utility:UpdateClient", self.source, "jobs", self.jobs)
                    TriggerClientEvent("Utility_Emitter:duty_change", self.source, onduty)
                end
    
            -- Identity
                self.SetIdentity = function(identity)
                    for k,v in pairs(identity) do
                        if k == "firstname" or k == "lastname" or k == "height" or k == "sex" or k == "dateofbirth" then
                            self.identity[k] = v
                        end
                    end
                    self.update("identity", self.identity)
                    TriggerClientEvent("Utility:UpdateClient", self.source, "identity", self.identity)
                end
    
                self.GetIdentity = function(data)
                    if data then
                        return self.identity[data]
                    else
                        return self.identity
                    end
                end
            -- Weapon
                self.AddWeapon = function(weapon, ammo, equipNow)
                    if type(weapon) == "table" then    
                        for k,v in pairs(weapon) do
                            GiveWeaponToPed(GetPlayerPed(self.source), GetHashKey(k), v, false, false)
                            self.other_info.weapon[k:lower()] = v
                        end
                    else
                        GiveWeaponToPed(GetPlayerPed(self.source), GetHashKey(weapon), ammo, false, equipNow)
                        self.other_info.weapon[weapon:lower()] = ammo
                    end
                    self.update("other_info", self.other_info)
                    TriggerClientEvent("Utility:UpdateClient", self.source, "other_info", self.other_info)
                end
    
                self.RemoveWeapon = function(weapon)
                    if type(weapon) == "table" then    
                        for i=1, #weapon do
                            RemoveWeaponFromPed(GetPlayerPed(self.source), GetHashKey(weapon[i]))
                            self.other_info.weapon[weapon[i]:lower()] = nil
                        end
                    else
                        RemoveWeaponFromPed(GetPlayerPed(self.source), GetHashKey(weapon))
                        self.other_info.weapon[weapon:lower()] = nil
                    end
    
                    self.update("other_info", self.other_info)
                    TriggerClientEvent("Utility:UpdateClient", self.source, "other_info", self.other_info)
                end
    
                self.GetWeapons = function()
                    return self.other_info.weapon or {}
                end
    
                self.HaveWeapon = function(name)
                    return self.other_info.weapon[name:lower()] ~= nil
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
                    self.update("other_info", self.other_info)
                    TriggerClientEvent("Utility:UpdateClient", self.source, "other_info", self.other_info)
                end
    
                self.RemoveLicense = function(name)
                    if self.other_info.license[name] then
                        self.other_info.license[name] = nil 
                        self.update("other_info", self.other_info)
                        TriggerClientEvent("Utility:UpdateClient", self.source, "other_info", self.other_info)
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
                self.GetBills = function()
                    return self.other_info.bills or {}
                end

                self.PayBill = function(id)
                    local bill_info = self.other_info.bills[id]

                    if self.HaveMoneyQuantity("bank", bill_info[3]) then
                        self.RemoveMoney("bank", bill_info[3])
                        Utility.SocietyData[bill_info[1]].AddMoney("bank", bill_info[3])
                        
                        -- Delete the bill
                        table.remove(self.other_info.bills, id)
                        return true
                    else
                        return false
                    end
                end
                self.RevokeBill = function(id)
                    local bill_info = self.other_info.bills[id]

                    if bill_info then
                        table.remove(self.other_info.bills, id)
                        return true
                    else
                        return false
                    end
                end

            -- Vehicles
                self.BuyVehicle = function(components)
                    oxmysql:executeSync('INSERT INTO vehicles (owner, plate, data) VALUES (:owner, :plate, :data)', {
                        owner = self.steam,
                        plate = components.plate[1],
                        data  = json.encode(components),
                    })

                    Utility.OwnedVehicles[components.plate[1]] = self.steam
                end

                self.TransferVehicleToPlayer = function(plate, target)
                    local target_steam = GetPlayerIdentifiers(target)[1] or target

                    oxmysql:executeSync('UPDATE vehicles SET owner = :owner WHERE plate = :plate', {
                        owner = target_steam,
                        plate = plate,
                    })

                    Utility.OwnedVehicles[plate] = target_steam
                end

        return self
    end
    
    uSocietyPopulate = function(self)
        self.__type = "usociety"
        
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
            end
    
        return self
    end

    GenerateTemplateuPlayer = function(id, identifier)
        local self = {
            steam     = identifier,
            source    = id,
            name      = GetPlayerName(id),
            inventory = {},
            accounts  = {},
            jobs      = {},
            identity  = {},
            other_info = { coords = {[1] = tonumber(Config.Start.Position.x), [2] = tonumber(Config.Start.Position.y), [3] = tonumber(Config.Start.Position.z)} }
        }

        -- Accounts (cash, bank, black)
        if Config.Actived.Accounts then
            for k,v in pairs(Config.Start.Accounts) do
                self.accounts[k] = v
            end
        end

        -- Jobs
        if Config.Actived.Jobs then
            for i=1, #Config.Jobs.Default do
                self.jobs[i] = {}
                self.jobs[i].name  = Config.Jobs.Default[i].name
                self.jobs[i].grade = Config.Jobs.Default[i].grade
                self.jobs[i].onduty = true
            end
        end

        -- Identity
        if Config.Actived.Identity then
            for i=1, #Config.Identity do
                self.identity[Config.Identity[i]] = "unknown"
            end
        end

        if Config.Database.IfNewInstantSave then    
            local query_data = {}
            local query = "steam, other_info, "        
            local query2 = ":steam, :other_info, "        
            
            query_data.steam = self.steam
            query_data.other_info = json.encode(self.other_info)

            if Config.Actived.Identity then
                query_data.identity = json.encode(self.identity)
                query = query.."identity, "
                query2 = query2..":identity, "
            end
            if Config.Actived.Jobs then
                query_data.jobs = json.encode(self.jobs)
                query = query.."jobs, "
                query2 = query2..":jobs, "
            end
            if Config.Actived.Accounts then
                query_data.accounts = json.encode(self.accounts)
                query = query.."accounts, "
                query2 = query2..":accounts, "
            end
            if Config.Actived.Inventory then
                query_data.inventory = json.encode(self.inventory)
                query = query.."inventory, "
                query2 = query2..":inventory, "
            end
        
            if Config.Database.SaveNameInDb then
                query_data.name = self.name
                query = query.."name, "
                query2 = query2..":name, "
            end

            oxmysql:executeSync('INSERT INTO users ('..query:sub(1, -3)..') VALUES ('..query2:sub(1, -3)..')', query_data)
        end
        
        return self
    end

-- Labels
    GetLabel = function(header, language, key)
        if language then
            if Config.Labels[header or "framework"] and Config.Labels[header or "framework"][language or Config.DefaultLanguage] then
                return Config.Labels[header or "framework"][language or Config.DefaultLanguage][key] or nil
            else
                return nil, "Header or language dont exist [Header = '"..header.."' Language = '"..(language or Config.DefaultLanguage).."']"
            end
        else
            if Config.Labels[header] then
                return Config.Labels[header][key] or nil
            else
                return nil
            end
        end
    end

-- Jobs
    RemoveFromJob = function(job, source)
        if Utility.Jobs[job] == nil then
            return
        end

        local i=1
        for k,v in pairs(Utility.Jobs[job]) do
            if v == source then
                table.remove(Utility.Jobs[job], i)
                break
            end
            i=i+1
        end
    end

    AddToJob = function(job, source)
        if Utility.Jobs[job] == nil then
            Utility.Jobs[job] = {}
        end

        table.insert(Utility.Jobs[job], source)
    end

-- Addon
    addon = function(name)
        local module = LoadResourceFile("utility_framework", "server/addons/"..name..".lua")
        
        if module then
            return load(module)()
        end
    end

-- Database
    CreateDb = function()
        Utility.LogToLogger("First Time", "Creating Database...")
        print(ts.translate(Config.DefaultLanguage, Config.Labels["framework"]["WelcomeMsg"]))

        analizer.start() -- Start the analizer
        oxmysql:executeSync([[
            CREATE DATABASE IF NOT EXISTS `utility`
            USE `utility`;
            
            CREATE TABLE IF NOT EXISTS `society` (
            `name` tinytext DEFAULT NULL,
            `money` tinytext DEFAULT NULL,
            `deposit` text DEFAULT NULL,
            `weapon` text DEFAULT NULL
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
            
            CREATE TABLE IF NOT EXISTS `users` (
            `steam` varchar(24) DEFAULT NULL,
            `name` varchar(32) DEFAULT NULL,
            `accounts` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT '[]',
            `inventory` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT '[]',
            `jobs` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT '[]',
            `identity` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT '[]',
            `other_info` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT '[]',
            KEY `Index 1` (`steam`)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='This is the table where the Utility Framework store all the data for any player';

            CREATE TABLE IF NOT EXISTS `vehicles` (
            `owner` varchar(24) DEFAULT NULL,
            `plate` varchar(8) DEFAULT NULL,
            `data` text DEFAULT NULL,
            `trunk` text DEFAULT '[]',
            `coords` tinytext DEFAULT NULL
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
        ]], {})

        Utility.LogToLogger("First Time", "Created database in "..analizer.finish().."ms") -- Log the analizer data
    end

    GetQueryFromuPlayer = function(uPlayer, coords, IsInsert)
        local query = ""
        local query2 = ""

        local query_data = {
            steam = uPlayer.steam
        }
        
        if Config.Actived.Other_info.Position then
            local x2, y2, z2 = string.format("%.2f", coords.x), string.format("%.2f", coords.y), string.format("%.2f", coords.z)
            
            uPlayer.other_info.coords = {
                [1] = tonumber(x2),
                [2] = tonumber(y2),
                [3] = tonumber(z2)
            }
        end
                
        for k, v in pairs(Config.Actived.Other_info) do
            if v then
                local other_info = json.decode(json.encode(uPlayer.other_info))

                for k,v in pairs(other_info) do
                    if type(v) == "table" then
                        if next(v) == nil then
                            other_info[k] = nil
                        end
                    elseif k == "isdeath" and v == false then
                        other_info[k] = nil
                    end
                end

                query_data.other_info = json.encode(other_info)

                if IsInsert then
                    query = query.."other_info,"
                    query2 = query2..":other_info,"
                else
                    query = query.." other_info = :other_info,"
                end
                break
            end
        end
        if Config.Actived.Identity then 
            query_data.identity = json.encode(uPlayer.identity) 

            if IsInsert then
                query = query.."identity,"
                query2 = query2..":identity,"
            else
                query = query.." identity = :identity,"
            end
        end
        if Config.Actived.Jobs then 
            query_data.jobs = json.encode(uPlayer.jobs) 

            if IsInsert then
                query = query.."jobs,"
                query2 = query2..":jobs,"
            else
                query = query.." jobs = :jobs,"
            end
        end
        if Config.Actived.Accounts then 
            query_data.accounts = json.encode(uPlayer.accounts) 

            if IsInsert then
                query = query.."accounts,"
                query2 = query2..":accounts,"
            else
                query = query.." accounts = :accounts,"
            end 
        end
        if Config.Actived.Inventory then 
            query_data.inventory = json.encode(uPlayer.inventory) 

            if IsInsert then
                query = query.."inventory,"
                query2 = query2..":inventory,"
            else
                query = query.." inventory = :inventory,"
            end
        end

        if IsInsert then
            return query, query2, query_data
        else
            return query, query_data
        end
    end