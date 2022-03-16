local function ExistInAGroup(steam)
    if Config.Group[steam] then
        --print("Have a group: "..Config.Group[steam])
        ExecuteCommand("add_principal identifier."..steam.." group."..Config.Group[steam])
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
        self.AddMoney = function(type, amount)
            Log("Money", "Added "..amount.." "..type.." to "..self.source)
            local newtype = GetAccountIndex(type)

            self.accounts[newtype] = self.accounts[newtype] + tonumber(amount)

            local player = Player(self.source).state
            player.accounts = self.accounts
            self.TriggerEvent("Utility:Emitter:MoneyAdded", type, amount)
        end

        --[[
            Sets money of the player

            type string = Type of money (cash, bank, black)
            amount number = Amount of money
        ]]
        self.SetMoney = function(type, amount)
            Log("Money", "Setted "..amount.." "..type.." to "..self.source)
            local newtype = GetAccountIndex(type)

            self.accounts[newtype] = tonumber(amount)

            local player = Player(self.source).state
            player.accounts = self.accounts
            self.TriggerEvent("Utility:Emitter:MoneySetted", type, amount)
        end

        --[[
            Removes money from the player

            type string = Type of money (cash, bank, black)
            amount number = Amount of money
        ]]
        self.RemoveMoney = function(type, amount)
            Log("Money", "Removed "..amount.." "..type.." to "..self.source)

            local newtype = GetAccountIndex(type)                
            
            self.accounts[newtype] = self.accounts[newtype] - tonumber(amount)

            local player = Player(self.source).state
            player.accounts = self.accounts
            self.TriggerEvent("Utility:Emitter:MoneyRemoved", type, amount)
        end

        --[[
            Get info from money type

            type string = Type of money (cash, bank, black)

            return [table] = A table with the childs: `count` and `label`
        ]]
        self.GetMoney = function(type)
            return {count = self.accounts[GetAccountIndex(type)], label = Config.Labels["accounts"][type] or type}
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
            data any [-] = The data to associate to the item
        ]]
        self.AddItem = function(name, quantity, data)
            if quantity == nil then
                quantity = 1
            end

            quantity = tonumber(string.format("%.0f", quantity))
            AddItemInternal(name, quantity, data, self)

            Log("Item", "Added "..quantity.." "..name.." to "..self.source)
            TriggerClientEvent("Utility:ItemNotification", self.source, name, "+ "..quantity)

            local player = Player(self.source).state
            player.inventory = self.inventory
            player.weight = self.weight

            Citizen.SetTimeout(50, function()
                self.TriggerEvent("Utility:Emitter:ItemAdded", name, quantity, data)
            end)
        end

        --[[
            Equal to AddItem but with a table

            items table = A key/value table with the items to add and the quantity (see example for more info)
        ]]
        self.AddItems = function(table)
            --[[
                uPlayer.AddItems({
                    ["bread"] = 100
                })
                uPlayer.AddItems({
                    ["erba"] = {quantity = 100, data = {}}
                })
            ]]

            if type(table) == "table" then
                for k,v in pairs(table) do
                    if type(v) == "table" then
                        self.AddItem(k, v.quantity, v.data or nil)
                    else
                        self.AddItem(k, v)
                    end
                end
            end
        end

        --[[
            Remove an item from the player

            name string = The name of the item (example: bread)
            quantity number = Quantity to add of that item
        ]]
        self.RemoveItem = function(name, quantity, data)
            if quantity == nil then
                quantity = 1
            end

            RemoveItemInternal(name, quantity, data, self)

            local player = Player(self.source).state
            player.inventory = self.inventory
            player.weight = self.weight
            
            -- Wait that the player state update
            Citizen.SetTimeout(50, function()
                Log("Item", "Removed "..quantity.." "..name.." from "..self.source)

                TriggerClientEvent("Utility:ItemNotification", self.source, name, "- "..quantity)
                --TriggerClientEvent("Utility:ItemNotification", self.source, "-"..quantity.." "..self.GetItem(name).label)

                self.TriggerEvent("Utility:Emitter:ItemRemoved", name, quantity)
            end)
        end

        --[[
            Equal to RemoveItem but with a table

            items table = A key/value table with the items to remove and the quantity (see example for more info)
        ]]
        self.RemoveItems = function(table)
            --[[
                uPlayer.RemoveItems({
                    ["bread"] = 100
                })
            ]]

            if type(table) == "table" then
                for k,v in pairs(table) do
                    self.RemoveItem(k, v)
                end
            end
        end

        --[[
            Get info from item

            name string = The name of the item

            return [table] = A table with the childs: `count`, `label`, `data` and `weight` or `limit`  
        ]]
        self.GetItem = function(name, data)
            return GetItemInternal(name, data, self.inventory)
        end

        --[[
            Use an specific item

            name string = The name of the item
        ]]
        self.UseItem = function(name)
            if GlobalState.UsableItem[name] then
                Log("Item", self.source.." used "..name)

                TriggerEvent("Utility_Usable:"..name, self)
                return true
            else
                return false
            end
        end

        --[[
            Check if a item is usable or no

            name string = The name of the item

            return [boolean] = True if the item is usable, false if item isnt usable
        ]]
        self.IsItemUsable = function(name)
            return GlobalState.UsableItem[name] or false
        end

        --[[
            Check if the player have an item quantity

            name string = The name of the item
            quantity number = The quantity to check

            return [boolean] = True if the item is usable, false if item isnt usable
        ]]
        self.HaveItemQuantity = function(name, quantity, data)
            return HaveItemQuantityInternal(name, quantity, data, self.inventory)
        end

        --[[
            Check if the player can carry an item quantity

            name string = The name of the item
            quantity number = The quantity to check

            return [boolean] = True if the item can be carried, false if item cant be carried
        ]]
        self.CanCarryItem = function(name, quantity, data)
            local weight_limit = Config.Inventory.ItemWeight[name] or Config.Inventory.DefaultItemWeight

            if Config.Inventory.Type == "weight" then
                if (self.weight + (weight_limit * quantity)) > self.maxWeight then
                    return false
                else
                    return true
                end
            elseif Config.Inventory.Type == "limit" then
                local item = FindItem(name, self.inventory, data)

                if (item[2] + quantity) <= weight_limit then
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
            target number = The target source (id)
        ]]
        self.SendItem = function(name, quantity, target)
            if self.HaveItemQuantity(name, quantity) then 
                self.RemoveItem(name, quantity)
                GlobalState.PlayersData[GetPlayerIdentifier(target, 0)].AddItem(name, quantity)
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
            self.TriggerEvent("Utility:Emitter:MaxWeightSetted", weight)
        end 
    -- Job

        --[[
            Set the job of the player

            name string = The name of the job
            grade number = The grade of the job
            type number = The type of the job (example: 1 is the first job, 2 is the second job)
        ]]
        self.SetJob = function(name, grade, type)
            grade = tonumber(grade)
            
            local OldJob = self.jobs

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

            if self.jobs[type or 1].onduty == nil then
                self.jobs[type or 1].onduty = true
            end
            
            AddToJob(self.jobs[type or 1], type or 1, self.source)

            Log("Jobs", self.source.." have changed job "..(type or 1).." from "..(OldJob[type or 1].name or "unkown").." to "..name.." "..grade)
            
            local player = Player(self.source).state
            player.jobs = self.jobs
            
            self.TriggerEvent("Utility:Emitter:JobChange", OldJob, self.jobs)
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

            self.TriggerEvent("Utility:Emitter:GradeChange", OldGrade, grade)
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

            self.TriggerEvent("Utility:Emitter:OnDuty", onduty)
        end
    -- Identity

        --[[
            Set the player identity

            identity table = a key/value table with the identity information (see example)
        ]]
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
            self.TriggerEvent("Utility:Emitter:IdentitySetted", identity)
        end

        --[[
            Get the player identity

            data string [-] = The data to get (example: "firstname")

            return [table] = The identity data
        ]]
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

        --[[
            Add a weapon to the player

            weapon string = The weapon name
            ammo number = The ammo of the weapon
            equipNow boolean = If true it will equip the weapon now
        ]]
        self.AddWeapon = function(weapon, ammo, equipNow)
            GiveWeaponToPed(GetPlayerPed(self.source), GetHashKey(weapon), ammo, false, equipNow)
            Log("Weapon", "Adding "..weapon.." with "..ammo.." to "..self.source)

            weapon = CompressWeapon(weapon)
            self.other_info.weapon[weapon] = ammo

            local player = Player(self.source).state
            player.other_info = self.other_info
            self.TriggerEvent("Utility:Emitter:WeaponAdded", weapon, ammo)
        end

        self.AddWeapons = function(weapon)
            for k,v in pairs(weapon) do
                self.AddWeapon(k, v, false)
            end
        end
        
        --[[
            Remove a weapon from the player

            weapon string = The weapon name
        ]]
        self.RemoveWeapon = function(weapon)
            if type(weapon) == "table" then    
                for i=1, #weapon do
                    RemoveWeaponFromPed(GetPlayerPed(self.source), GetHashKey(weapon[i]))

                    self.other_info.weapon[CompressWeapon(weapon[i])] = nil
                end
            else
                RemoveWeaponFromPed(GetPlayerPed(self.source), GetHashKey(weapon))
                self.other_info.weapon[CompressWeapon(weapon)] = nil
            end
            Log("Weapon", "Removed "..weapon.." from "..self.source)

            local player = Player(self.source).state
            player.other_info = self.other_info

            self.TriggerEvent("Utility:Emitter:WeaponRemoved", weapon)
        end

        self.RemoveWeapons = function(weapon)
            for i=1, #weapon do
                self.RemoveWeapon(weapon[i])
            end
        end

        --[[
            Add ammo to a weapon from the player

            weapon string = The weapon name
            ammo number = The ammo to add
        ]]
        self.AddWeaponAmmo = function(weapon, ammo)
            local _ammo = self.other_info.weapon[CompressWeapon(weapon)]
            SetPedAmmo(GetPlayerPed(self.source), GetHashKey(weapon), _ammo + ammo)

            local player = Player(self.source).state
            player.other_info = self.other_info
            
            self.TriggerEvent("Utility:Emitter:WeaponAmmoAdded", weapon, ammo)
        end
        
        --[[
            Remove ammo from a weapon from the player

            weapon string = The weapon name
            ammo number = The ammo to remove
        ]]
        self.RemoveWeaponAmmo = function(weapon, ammo)
            local _ammo = self.other_info.weapon[CompressWeapon(weapon)]
            SetPedAmmo(GetPlayerPed(self.source), GetHashKey(weapon), _ammo - ammo)

            local player = Player(self.source).state
            player.other_info = self.other_info

            self.TriggerEvent("Utility:Emitter:WeaponAmmoRemoved", weapon, ammo)
        end
        
        --[[
            Get the ammo of a weapon from the player

            weapon string = The weapon name

            return [number] = The ammo of the weapon
        ]]
        self.GetWeaponAmmo = function(name)
            return self.other_info.weapon[CompressWeapon(weapon)] or 0
        end
        
        --[[
            Check if the player have a weapon

            name string = The weapon name
        ]]
        self.HaveWeapon = function(name)
            return self.other_info.weapon[CompressWeapon(weapon)] ~= nil
        end

        --[[
            Get the weapons of the player

            return [table] = The weapons of the player
        ]]
        self.GetWeapons = function()
            return self.other_info.weapon or {}
        end

        --[[
            Convert a weapon to a item

            weapon string = The weapon name (weapon_pistol)
        ]]
        self.DisassembleWeapon = function(name)
            local ammo = self.GetWeaponAmmo(name)
            self.RemoveWeapon(name)
            self.AddItem(name, ammo)

            self.TriggerEvent("Utility:Emitter:WeaponDisassembled", name)
        end
        
        --[[
            Convert a item to a weapon

            name string = The weapon name (weapon_pistol)
        ]]
        self.AssembleWeapon = function(name)
            local ammo = self.GetItem(name).count
            self.RemoveItem(name, ammo)
            self.AddWeapon(name, ammo)

            self.TriggerEvent("Utility:Emitter:WeaponAssembled", name)
        end

    -- Death
        --[[
            Revive the player
        ]]
        self.Revive = function()
            self.TriggerEvent("Utility:Emitter:OnRevive")
        end

        --[[
            Check if the player is dead

            return [boolean] = If the player is dead
        ]]
        self.IsDead = function()
            return self.other_info.isdead
        end
        
        --[[
            Get player death count

            return [number] = The death count
        ]]
        self.GetDeaths = function()
            return self.other_info.death or 0
        end
        
        --[[
            Get player kill count

            return [number] = The kill count
        ]]
        self.GetKills = function()
            return self.other_info.kill or 0
        end
    -- License
    
        --[[
            Add a license to the player

            name string = The license name
        ]]
        self.AddLicense = function(name)
            self.other_info.license[name] = true 
            Log("License", "Adding "..name.." to "..self.source)
            
            local player = Player(self.source).state
            player.other_info = self.other_info

            self.TriggerEvent("Utility:Emitter:LicenseAdded", name)
        end
        
        --[[
            Remove a license from the player

            name string = The license name
        ]]
        self.RemoveLicense = function(name)
            if self.other_info.license[name] then
                self.other_info.license[name] = nil 
                Log("License", "Removing "..name.." from "..self.source)
                
                local player = Player(self.source).state
                player.other_info = self.other_info

                self.TriggerEvent("Utility:Emitter:LicenseRemoved", name)
            end
        end
        
        --[[
            Get the licenses of the player

            return [table] = The licenses of the player
        ]]
        self.GetLicenses = function()                
            return self.other_info.license
        end

        --[[
            Get the label of a license

            return [string] = The license label
        ]]
        self.GetLicenseLabel = function(name)
            return Config.Labels["license"][name]
        end

        --[[
            Check if the player have a license

            name string = The license name
        ]]
        self.HaveLicense = function(name)
            return self.other_info.license[name] or false
        end

    
    -- Billing
    
        --[[
            Get all the bills of the player

            id number [-] = The id of the bill

            return [table] = The bills of the player
        ]]
        self.GetBill = function(id)
            return id and self.other_info.bills[id] or self.other_info.bills
        end

        
        --[[
            Pay a bill of the player

            id number = The id of the bill

            return [boolean] = If the bill is paid
        ]]
        self.PayBill = function(id)
            local bill_info = self.other_info.bills[id]

            if self.HaveMoneyQuantity("bank", bill_info[3]) then
                self.RemoveMoney("bank", bill_info[3])
                Utility.SocietyData[bill_info[1]].AddMoney("bank", bill_info[3])
                
                -- Delete the bill
                Log("Bills", self.source.." have paid bill "..id.." that cost "..bill_info[3].." and was created by "..bill_info[1])

                
                table.remove(self.other_info.bills, id)

                local player = Player(self.source).state
                player.other_info = self.other_info

                self.TriggerEvent("Utility:Emitter:BillPaid", id, bill_info)
                return true
            else
                return false
            end
        end
        
        --[[
            Revoke a bill of the player

            id number = The id of the bill

            return [boolean] = If the bill is revoked
        ]]
        self.RevokeBill = function(id)
            local bill_info = self.other_info.bills[id]

            if bill_info then
                Log("Bills", self.source.." have revoked the bill "..id.." info: "..json.encode(bill_info))

                table.remove(self.other_info.bills, id)

                local player = Player(self.source).state
                player.other_info = self.other_info
                self.TriggerEvent("Utility:Emitter:BillRevoked", id, bill_info)

                return true
            else
                return false
            end
        end
    -- Vehicles

        --[[
            Buy a vehicle

            components table = The components of the vehicle
        ]]
        self.BuyVehicle = function(components)
            MySQL.Sync.fetchAll('INSERT INTO vehicles (owner, plate, data) VALUES (:owner, :plate, :data)', {
                owner = (self.steam:gsub("steam:110000", "")),
                plate = components.plate[1],
                data  = json.encode(components),
            })

            Utility.VehiclesData[components.plate[1]] = {
                owner = self.steam,
                plate = components.plate[1],
                data  = components,
                trunk = {}
            }
            CreateVehicle(Utility.VehiclesData[components.plate[1]])

            local player = Player(self.source).state
            local vehicles = player.vehicles
            vehicles[components.plate[1]] = {
                owner = self.steam,
                plate = components.plate[1],
                data  = components,
                trunk = {}
            }
            player.vehicles = vehicles

            Citizen.SetTimeout(50, function()
                self.TriggerEvent("Utility:Emitter:VehicleBought", vehicles[components.plate[1]])
            end)

            Log("Vehicle", self.source.." have buyed a vehicle with the plate "..components.plate[1])
        end
        
        --[[
            Transfer a vehicle to a player

            plate string = The plate of the vehicle
            target string = The target player
        ]]
        self.TransferVehicleToPlayer = function(plate, target)
            if self.IsPlateOwned(plate) then 
                local target_steam = GetPlayerIdentifier(target, 0)

                Utility.VehiclesData[plate].owner = target_steam
                Log("Vehicle", self.source.." have transfered the vehicle with the plate "..plate.." to "..target)
 
                self.TriggerEvent("Utility:Emitter:VehicleTransferedToPlayer", plate, target)
            end
        end
        
        --[[
            Check if a plate is owned by the player

            plate string = The plate of the vehicle

            return [boolean] = If the plate is owned by the player
        ]]
        self.IsPlateOwned = function(plate)
            return Utility.VehiclesData[plate].owner == self.owner
        end
    -- Other info integration

        --[[
            Set a value in the other info

            key string = The key of the value
            value any = The value
        ]]
        self.Set = function(id, value)
            if type(value) == "table" then
                self.other_info.scripts[id] = json.encode(value)
            else
                self.other_info.scripts[id] = value
            end

            local player = Player(self.source).state
            player.other_info = self.other_info      
        end
        
        --[[
            Get a value from the other info

            key string = The key of the value

            return [any] = The value
        ]]
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
                
        --[[
            Remove a value from the other info

            key string = The key of the value
        ]]
        self.Del = function(id)
            self.other_info.scripts[id] = nil

            local player = Player(self.source).state
            player.other_info = self.other_info
        end
    -- Ban
    
        --[[
            Ban a player

            reason string = The reason of the ban
        ]]
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

            MySQL.Sync.fetchAll("INSERT INTO bans (name, data, token, internal_reason) VALUES (:name, :data, :token, :internal_reason)", {
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
    -- Other function
    
        --[[
            Show a notification to the player

            msg string = The message of the notification
        ]]
        self.ShowNotification = function(msg)
            TriggerClientEvent("Utility:Notification", self.source, msg)
        end
        
        --[[
            Show a button message to the player

            msg string = The message of the help
        ]]
        self.ButtonNotification = function(msg, duration)
            TriggerClientEvent("Utility:ButtonNotification", self.source, msg, duration or 2000)
        end

        --[[
            Trigger a client event with the player source

            event string = The event name
            ... any = The arguments of the event
        ]]
        self.TriggerEvent = function(event, ...)
            TriggerClientEvent(event, self.source, ...)
        end

        --[[
            Trigger a client event with the player source

            event string = The event name
            ... any = The arguments of the event
        ]]
        self.Trigger = function(event, ...)
            TriggerClientEvent(event, self.source, ...)
        end

    return self
end

local function BuildOtherInfo(self)
    if self.other_info.isdead == nil then self.other_info.isdead = false end
    if self.other_info.license == nil then self.other_info.license = {} end
    if self.other_info.weapon == nil then self.other_info.weapon = {} end
    if self.other_info.bills == nil then self.other_info.bills = {} end
    if self.other_info.scripts == nil then self.other_info.scripts = {} end
    
    for k,v in pairs(self.other_info.weapon) do
        --print(k, v)

        if k:find("weapon_") or k:find("gadget_") then
            --print("self.other_info.weapon["..CompressWeapon(k).."] = "..v)
            --print("self.other_info.weapon["..k.."] = nil")

            self.other_info.weapon[CompressWeapon(k)] = v
            self.other_info.weapon[k] = nil
        end
    end
    
    --print(json.encode(self.other_info.weapon))
    return self
end

local function BuildJobs(self)
    for i=1, #self.jobs do
        --print(json.encode(self.jobs[i]))
        local name = self.jobs[i][1]

        if name and self.jobs[i][2] and self.jobs[i][3] then
            local id = self.jobs[i][2]
            self.jobs[i].name = name
            self.jobs[i].onduty = self.jobs[i][3]
    
            if Config.Jobs.Configuration[name] and Config.Jobs.Configuration[name].grades[id] then
                self.jobs[i].label = Config.Jobs.Configuration[name].name
                self.jobs[i].grade = {
                    id = id,
                    label  = Config.Jobs.Configuration[name].grades[id].label,
                    salary = Config.Jobs.Configuration[name].grades[id].salary,
                    boss   = Config.Jobs.Configuration[name].grades[id].boss,
                }
            else
                self.jobs[i].label = name
                self.jobs[i].grade = {
                    id = id,
                    label  = "unknown",
                    salary = 0,
                    boss   = false,
                }  
            end

            name = nil
            self.jobs[i][2] = nil
            self.jobs[i][3] = nil

            for i=1, #self.jobs do
                AddToJob(self.jobs[i], i, self.source)
            end
        end

        --print(json.encode(self.jobs[i]))
    end

    return self
end

local function BuildInventory(self)
    if Config.Inventory.Type == "weight" then
        self.maxWeight = Config.Inventory.MaxWeight
        self.weight = 0
    
        for k,v in pairs(self.inventory) do
            local _weight = (Config.Inventory.ItemWeight[k] or Config.Inventory.DefaultItemWeight)
            self.weight = self.weight + (_weight * v[2])
        end
    end

    return self
end



CreatePlayer = function(self)
    self.usteam = self.steam
    self.steam = "steam:110000"..self.steam
    self.identity    = json.decode(self.identity) 
    self.inventory   = json.decode(self.inventory) 
    self.jobs        = json.decode(self.jobs) 
    self.accounts    = json.decode(self.accounts) 
    self.other_info  = json.decode(self.other_info) 
    self.group       = ExistInAGroup(self.steam)
    self.vehicles    = {}

    for k,v in pairs(Utility.VehiclesData) do
        if v.owner == self.steam then
            table.insert(self.vehicles, v)
        end
    end


    self.Build = function(self)
        Log("Building", "Server uPlayer builded for "..self.steam)
        self.__type = "uPlayer"

        self = BuildFunctions(self)

        Utility.PlayersData[self.steam] = self
    end
    self.ClientBuild = function(self, id)
        Log("Building", "Client uPlayer builded for "..self.steam)

        --[[for k,v in pairs(self) do
            print(k,v)
        end]]
        
        self.__type = "cuPlayer"

        self.source = id

        self.online = true
        self = BuildOtherInfo(self)
        self = BuildJobs(self)
        self = BuildInventory(self)

        Utility.PlayersData[self.steam] = self
    end

    self.IsBuilded = function()
        return (Utility.PlayersData[self.steam].__type ~= nil)
    end
    self.Demolish = function()
        Log("Building", "uPlayer "..self.steam.." has been demolished")

        for i=1, #self.jobs do
            RemoveFromJob(self.jobs[i].name, self.source)
        end

        Utility.PlayersData[self.steam] = {
            name        = self.name,
            steam       = self.steam,
            usteam      = self.usteam,
            identity    = self.identity,
            inventory   = self.inventory,
            jobs        = self.jobs,
            accounts    = self.accounts,
            vehicles    = self.vehicles,
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
        if steam == 0 then
            return nil
        end

        if not steamCache[steam] then
            steamCache[steam] = GetPlayerIdentifier(steam, 0)
        end

        return Utility.PlayersData[steamCache[steam]]
    end
end

GetUtilityPlayers = function()
    local players = {}
    
    for k,v in pairs(Utility.PlayersData) do
        --if v.online then
            local v2 = {}
            for k,v in pairs(v) do v2[k] = v end

            for k,v in pairs(v2) do
                if type(v) == "function" then v2[k] = nil end
            end

            table.insert(players, v2)
        --end
    end

    return players
end

GetClientPlayer = function(id)
    local player = Player(id).state
    
    local metatable = {
        state = player,
        __newindex = function(self, index, new)
            player[index] = new
            Utility.PlayersData[player.steam][index] = new

            --print("Setting \""..tostring(index).."\" to \""..tostring(new).."\" for "..id)
        end,
        setoi = function(k, v)
            local oi = player.other_info
            oi[k] = v

            player.other_info = oi
            Utility.PlayersData[player.steam].other_info[k] = v
            --print("Setting other_info \""..tostring(k).."\" to \""..tostring(v).."\" for "..id)
        end
    }

    return setmetatable({}, metatable)
end


LoadPlayers = function()
    local users = MySQL.Sync.fetchAll('SELECT name, accounts, inventory, jobs, identity, other_info, steam, last_quit FROM users', {})

    if users == nil then error("Unable to connect with the table `users`, try to check the MySQL status!") return end
    for i=1, #users do
        local lastq_year, lastq_month, lastq_day = users[i].last_quit:sub(0, 4), users[i].last_quit:sub(6, 7), users[i].last_quit:sub(9, 10)
        local last_quit = os.time{year = lastq_year, month = lastq_month, day = lastq_day}
        local daysfrom = os.difftime(os.time(), last_quit) / (24 * 60 * 60)
        daysfrom = math.floor(daysfrom)

        if Config.Database.MaxDaysPlayer > 0 and daysfrom >= Config.Database.MaxDaysPlayer then
            local file = io.open(GetResourcePath(GetCurrentResourceName()).."/files/PlayersFrozen.json", "a")
            file:write(json.encode(users[i]))
            file:close()

            MySQL.Sync.fetchAll("DELETE FROM users WHERE steam = :steam", {steam = users[i].steam})
        else
            CreatePlayer(users[i])
        end
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
            isdead = false,
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