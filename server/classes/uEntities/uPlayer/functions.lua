function uPlayerCreateMethods(self)
    self.UpdateClient = function(property)
        check({property = "string"})

        local player = Player(self.source).state
        player[property] = self[property]
    end

    -- Money

        --[[
            Adds money to the player

            type string = Type of money (cash, bank, black)
            amount number = Amount of money
        ]]
        self.AddMoney = function(type, amount)
            check({type = "string", amount = "number"})
            
            local i = GetAccountIndex(type)
            self.accounts[i] = self.accounts[i] + tonumber(amount)
            
            Log("Money", "Added "..amount.." "..type.." to "..self.source)
            self.UpdateClient("accounts")
            EmitEvent("MoneyAdded", self.source, type, amount)
        end

        --[[
            Sets money of the player

            type string = Type of money (cash, bank, black)
            amount number = Amount of money
        ]]
        self.SetMoney = function(type, amount)
            check({type = "string", amount = "number"})
            
            local i = GetAccountIndex(type)
            self.accounts[i] = tonumber(amount)
            
            Log("Money", "Setted "..amount.." "..type.." to "..self.source)
            self.UpdateClient("accounts")
            EmitEvent("MoneySetted", self.source, type, amount)
        end

        --[[
            Removes money from the player

            type string = Type of money (cash, bank, black)
            amount number = Amount of money
        ]]
        self.RemoveMoney = function(type, amount)
            check({type = "string", amount = "number"})
            
            local i = GetAccountIndex(type)                
            self.accounts[i] = self.accounts[i] - tonumber(amount)
            
            Log("Money", "Removed "..amount.." "..type.." to "..self.source)
            self.UpdateClient("accounts")
            EmitEvent("MoneyRemoved", self.source, type, amount)
        end

        --[[
            Get info from money type

            type string = Type of money (cash, bank, black)

            return [table] = A table with the childs: `quantity` and `label`
        ]]
        self.GetMoney = function(type)
            check({type = "string"})
            local i = GetAccountIndex(type)                

            return {
                quantity = self.accounts[i] or -1, 
                label = Config.Labels["accounts"][type] or type
            }
        end

        --[[
            Check if the player have that money quantity

            type string = Type of money (cash, bank, black)
            quantity number = Quantity to money to check

            return [boolean] = True if have money quantity, false if dont have it
        ]]
        self.HaveMoneyQuantity = function(type, quantity)
            check({type = "string", quantity = "number"})
            local i = GetAccountIndex(type)

            return (self.accounts[i] >= tonumber(quantity))
        end
    -- Item
        --[[
            Add an item to the player

            name string = The name of the item (example: bread)
            quantity number = Quantity to add of that item
            data any [-] = The data to associate to the item
        ]]
        self.AddItem = function(name, quantity, data)
            check({name = "string", quantity = "number"})

            AddItemInternal(name, quantity, data, self)
            
            self.UpdateClient("inventory")
            if Config.Inventory.Type == "weight" then
                self.UpdateClient("weight")
            end
            
            Log("Item", "Added "..quantity.." "..name.." to "..self.source)
            TriggerClientEvent("Utility:ItemNotification", self.source, name, "+ "..quantity)
            EmitEvent("ItemAdded", self.source, name, quantity, data)
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
            check({table = "table"})

            for k,v in pairs(table) do
                if type(v) == "table" then
                    self.AddItem(k, v.quantity, v.data or nil)
                else
                    self.AddItem(k, v)
                end
            end
        end

        --[[
            Remove an item from the player

            name string = The name of the item (example: bread)
            quantity number = Quantity to add of that item
        ]]
        self.RemoveItem = function(name, quantity, data)
            check({name = "string", quantity = "number"})

            local item = self.GetItem(name, data)
            RemoveItemInternal(name, quantity, data, self)

            self.UpdateClient("inventory")
            if Config.Inventory.Type == "weight" then
                self.UpdateClient("weight")
            end
            
            Log("Item", "Removed "..quantity.." "..name.." from "..self.source)
            TriggerClientEvent("Utility:ItemNotification", self.source, name, "- "..quantity)
            EmitEvent("ItemRemoved", self.source, name, quantity, item.data)
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
            check({table = "table"})

            for k,v in pairs(table) do
                self.RemoveItem(k, v)
            end
        end

        --[[
            Get info from item

            name string = The name of the item

            return [table] = A table with the childs: `quantity`, `label`, `data` and `weight` or `limit`  
        ]]
        self.GetItem = function(name, data)
            check({name = "string"})

            return GetItemInternal(name, data, self.inventory)
        end

        self.FindItems = function(name, filter)
            check({name = "string", filter = "table"})

            return FindItems(name, self.inventory, filter)
        end

        --[[
            Use an specific item

            name string = The name of the item
        ]]
        self.UseItem = function(name)
            check({name = "string"})

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
            check({name = "string"})

            return GlobalState.UsableItem[name] or false
        end

        --[[
            Check if the player have an item quantity

            name string = The name of the item
            quantity number = The quantity to check

            return [boolean] = True if the item is usable, false if item isnt usable
        ]]
        self.HaveItemQuantity = function(name, quantity, data)
            check({name = "string", quantity = "number"})
            
            return HaveItemQuantityInternal(name, quantity, data, self.inventory)
        end

        --[[
            Check if the player can carry an item quantity

            name string = The name of the item
            quantity number = The quantity to check

            return [boolean] = True if the item can be carried, false if item cant be carried
        ]]
        self.CanCarryItem = function(name, quantity)
            check({name = "string", quantity = "number"})

            return CanCarryItemInternal(name, quantity, self.inventory)
        end

        --[[
            Send an item to another player

            name string = The name of the item
            quantity number = The quantity to transfer
            target number = The target source (id)
        ]]
        self.SendItem = function(name, quantity, target)
            check({name = "string", quantity = "number", target = "number"})

            if self.HaveItemQuantity(name, quantity) then 
                self.RemoveItem(name, quantity)
                GetPlayer(target).AddItem(name, quantity)
            end
        end
        -- Only weight

        --[[
            Set max weight of the player, can be used for bag or other

            weight number = The new max weight
        ]]
        self.SetMaxWeight = function(weight)
            check({weight = "number"})

            if Config.Inventory.Type == "weight" then
                self.maxWeight = weight

                self.UpdateClient("maxWeight")
                EmitEvent("MaxWeightSetted", self.source, weight)
            end

        end 
    -- Job

        --[[
            Set the job of the player

            name string = The name of the job
            grade number = The grade of the job
            type number = The type of the job (example: 1 is the first job, 2 is the second job)
        ]]
        self.SetJob = function(name, grade, type)
            check({name = "string", grade = "number"})
            tpye = type or 1 -- Default type is 1
            
            local OldJob = self.jobs[type]

            -- Remove from old job
            if OldJob ~= nil then 
                RemoveFromJob(OldJob.name, self.source) 
            end
            
            self.jobs[type] = Job({
                name = name,
                onduty = true,
                grade = {
                    id = grade
                }
            })
            
            AddToJob(self.jobs[type], type, self.source)

            Log("Jobs", self.source.." have changed job "..(type).." from "..(OldJob[type].name or "unknown").." to "..name.." "..grade)
            self.UpdateClient("jobs")
            EmitEvent("JobChange", self.source, OldJob[type], self.jobs[type], type)
        end

        --[[
            Set the job grade of the current player job

            grade number = The grade of the job
            type number = The type of the job (example: 1 is the first job, 2 is the second job)
        ]]
        self.SetJobGrade = function(grade, type)
            check({grade = "number"})
            type = type or 1

            if self.jobs[type] then
                local OldGrade = self.jobs[type].grade.id

                self.jobs[type] = Job({
                    name = self.jobs[type].name,
                    onduty = self.jobs[type].onduty,
                    grade = {
                        id = grade
                    }
                })
                    
                Log("Jobs", self.source.." have changed grade "..type.." from "..OldGrade.." to "..grade)
                self.UpdateClient("jobs")
                EmitEvent("GradeChange", self.source, OldGrade, grade)
            end
        end

        --[[
            Set the player onduty of the current job

            onduty boolean = If true it set in duty, otherwise it is taken out of duty
            type number = The type of the job (example: 1 is the first job, 2 is the second job)
        ]]
        self.SetDuty = function(onduty, type)
            check({onduty = "boolean"})
            type = type or 1

            if self.jobs[type] then
                self.jobs[type].onduty = onduty

                self.UpdateClient("jobs")
                EmitEvent("OnDuty", self.source, onduty)
            end
        end
    -- Identity

        --[[
            Set the player identity

            identity table = a key/value table with the identity information (see example)
        ]]
        self.SetIdentity = function(identity)
            check({identity = "table"})

            for k,v in pairs(identity) do
                for i=1, #Config.Identity do
                    if k == Config.Identity[i] then
                        self.identity[i] = v
                    end
                end
            end

            self.UpdateClient("identity")
            EmitEvent("IdentitySetted", self.source, identity)
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
            check({weapon = "string", ammo = "number"})

            GiveWeaponToPed(GetPlayerPed(self.source), GetHashKey(weapon), ammo, false, equipNow or false)
            
            weapon = CompressWeapon(weapon)
            self.weapons[weapon] = ammo
            
            Log("Weapon", "Adding "..weapon.." with "..ammo.." to "..self.source)
            self.UpdateClient("weapons")
            EmitEvent("WeaponAdded", self.source, weapon, ammo)
        end

        self.AddWeapons = function(weapon)
            check({weapon = "table"})

            for k,v in pairs(weapon) do
                self.AddWeapon(k, v, false)
            end
        end
        
        --[[
            Remove a weapon from the player

            weapon string = The weapon name
        ]]
        self.RemoveWeapon = function(weapon)
            check({weapon = "string"})

            RemoveWeaponFromPed(GetPlayerPed(self.source), GetHashKey(weapon))
            self.weapons[CompressWeapon(weapon)] = nil
            
            
            Log("Weapon", "Removed "..weapon.." from "..self.source)
            self.UpdateClient("weapons")
            EmitEvent("WeaponRemoved", self.source, weapon)
        end

        self.RemoveWeapons = function(weapon)
            check({weapon = "table"})

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
            check({weapon = "string", ammo = "number"})

            local _ammo = self.weapons[CompressWeapon(weapon)]
            SetPedAmmo(GetPlayerPed(self.source), GetHashKey(weapon), _ammo + ammo)

            self.UpdateClient("weapons")
            EmitEvent("WeaponAmmoAdded", self.source, weapon, ammo)
        end
        
        --[[
            Remove ammo from a weapon from the player

            weapon string = The weapon name
            ammo number = The ammo to remove
        ]]
        self.RemoveWeaponAmmo = function(weapon, ammo)
            check({weapon = "string", ammo = "number"})

            local _ammo = self.weapons[CompressWeapon(weapon)]
            SetPedAmmo(GetPlayerPed(self.source), GetHashKey(weapon), _ammo - ammo)

            self.UpdateClient("weapons")
            EmitEvent("WeaponAmmoRemoved", self.source, weapon, ammo)
        end
        
        --[[
            Get the ammo of a weapon from the player

            weapon string = The weapon name

            return [number] = The ammo of the weapon
        ]]
        self.GetWeaponAmmo = function(name)
            check({weapon = "string"})

            return self.weapons[CompressWeapon(weapon)] or 0
        end
        
        --[[
            Check if the player have a weapon

            name string = The weapon name
        ]]
        self.HaveWeapon = function(name)
            check({weapon = "string"})

            return self.weapons[CompressWeapon(weapon)] ~= nil
        end

        --[[
            Get the weapons of the player

            return [table] = The weapons of the player
        ]]
        self.GetWeapons = function()
            return self.weapons or {}
        end

        --[[
            Convert a weapon to a item

            weapon string = The weapon name (weapon_pistol)
        ]]
        self.DisassembleWeapon = function(name)
            check({weapon = "string"})

            local ammo = self.GetWeaponAmmo(name)
            self.RemoveWeapon(name)
            self.AddItem(name, ammo)

            EmitEvent("WeaponDisassembled", self.source, name)
        end
        
        --[[
            Convert a item to a weapon

            name string = The weapon name (weapon_pistol)
        ]]
        self.AssembleWeapon = function(name)
            check({name = "string"})

            local ammo = self.GetItem(name).quantity
            self.RemoveItem(name, ammo)
            self.AddWeapon(name, ammo)

            EmitEvent("WeaponAssembled", self.source, name)
        end

    -- Death
        --[[
            Revive the player
        ]]
        self.Revive = function()
            EmitEvent("OnRevive")
        end

        --[[
            Check if the player is dead

            return [boolean] = If the player is dead
        ]]
        self.IsDead = function()
            return self.external.isdead
        end
        
        --[[
            Get player death count

            return [number] = The death count
        ]]
        self.GetDeaths = function()
            return self.external.death or 0
        end
        
        --[[
            Get player kill count

            return [number] = The kill count
        ]]
        self.GetKills = function()
            return self.external.kill or 0
        end
    -- License
    
        --[[
            Add a license to the player

            name string = The license name
        ]]
        self.AddLicense = function(name)
            check({name = "string"})

            self.licenses[name] = true 

            Log("License", "Adding "..name.." to "..self.source)
            self.UpdateClient("licenses")
            EmitEvent("LicenseAdded", self.source, name)
        end
        
        --[[
            Remove a license from the player

            name string = The license name
        ]]
        self.RemoveLicense = function(name)
            check({name = "string"})

            if self.licenses[name] then
                self.licenses[name] = nil 

                Log("License", "Removing "..name.." from "..self.source)
                self.UpdateClient("licenses")
                EmitEvent("LicenseRemoved", self.source, name)
            end
        end
        
        --[[
            Get the licenses of the player

            return [table] = The licenses of the player
        ]]
        self.GetLicenses = function()                
            return self.licenses
        end

        --[[
            Get the label of a license

            return [string] = The license label
        ]]
        self.GetLicenseLabel = function(name)
            check({name = "string"})

            return Config.Labels["license"][name]
        end

        --[[
            Check if the player have a license

            name string = The license name
        ]]
        self.HaveLicense = function(name)
            check({name = "string"})

            return self.licenses[name] or false
        end

    
    -- Billing
        --[[
            Add a billing to the player

            owner string = The owner of the billing
            reason string = The reason of the billing
            price number = The amount of the billing
        ]]
        self.CreateBill = function(owner, reason, price)
            check({owner = "string", reason = "string", price = "number"})
            table.insert(self.bills, {[1] = owner, [2] = reason, [3] = tonumber(price)})

            self.UpdateClient("bills")
        end
    
        --[[
            Get all the bills of the player

            id number [-] = The id of the bill

            return [table] = The bills of the player
        ]]
        self.GetBill = function(id)
            return id and self.bills[id] or self.bills
        end

        
        --[[
            Pay a bill of the player

            id number = The id of the bill

            return [boolean] = If the bill is paid
        ]]
        self.PayBill = function(id)
            check({id = "number"})
            local bill_info = self.bills[id]

            if bill_info then
                if self.HaveMoneyQuantity("bank", bill_info[3]) then
                    self.RemoveMoney("bank", bill_info[3])
                    Utility.SocietyData[bill_info[1]].AddMoney("bank", bill_info[3])

                    table.remove(self.bills, id)
                    
                    Log("Bills", self.source.." have paid bill "..id.." that cost "..bill_info[3].." and was created by "..bill_info[1])
                    self.UpdateClient("bills")
                    EmitEvent("BillPaid", self.source, id, bill_info)
                    return true
                else
                    return false
                end
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
            check({id = "number"})
            local bill_info = self.bills[id]

            if bill_info then
                
                table.remove(self.bills, id)
                
                Log("Bills", self.source.." have revoked the bill "..id.." info: "..json.encode(bill_info))
                self.UpdateClient("bills")
                EmitEvent("BillRevoked", self.source, id, bill_info)

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
            check({components = "table"})

            if type(components.plate) == "table" then
                MySQL.Async.execute('INSERT INTO vehicles (owner, plate, data) VALUES (:owner, :plate, :data)', {
                    owner = (self.uidentifier),
                    plate = components.plate[1],
                    data  = json.encode(components),
                })

                uVehicle({
                    owner = (self.uidentifier),
                    plate = components.plate[1],
                    data  = json.encode(components),
                    trunk = "[]"
                })
                
                self.vehicles[components.plate[1]] = {
                    owner = self.uidentifier,
                    plate = components.plate[1],
                    data  = components,
                    trunk = {}
                }
    
                Log("Vehicle", self.source.." have buyed a vehicle with the plate "..components.plate[1])
                self.UpdateClient("vehicles")
                EmitEvent("VehicleBought", self.source, vehicles[components.plate[1]])
            else
                error("uPlayer.BuyVehicle: components.plate must be a table")
            end
        end
        
        --[[
            Transfer a vehicle to a player

            plate string = The plate of the vehicle
            target number = The target player id
        ]]
        self.TransferVehicleToPlayer = function(plate, target)
            check({plate = "string", target = "number"})

            if self.IsPlateOwned(plate) then 
                local uTarget = GetPlayer(target)

                if uTarget and uTarget.identifier then
                    local IsSocietyVehicle = false
                    local VehicleData = nil

                    -- Remove the vehicle from the uPlayer
                    for k,v in pairs(self.vehicles) do
                        if v.owner == self.identifier then
                            table.remove(self.vehicles, k)
                            break
                        end
                    end

                    for k,v in pairs(self.societyvehicles) do
                        for i=1, #self.jobs do
                            if v.owner == "society:"..self.jobs[i].name then
                                table.remove(self.societyvehicles, k)
                                IsSocietyVehicle = true
                                break
                            end
                        end
                    end
            
                    -- Set new owner 
                    Utility.VehiclesData[plate].owner = uTarget.identifier
                    
                    if VehicleData then
                        if IsSocietyVehicle then
                            -- Add the vehicle to the uTarget
                            uTarget.societyvehicles[plate] = Utility.VehiclesData[plate]
    
                            uTarget.UpdateClient("societyvehicles")
                            self.UpdateClient("societyvehicles")
                        else
                            -- Add the vehicle to the uTarget
                            uTarget.vehicles[plate] = Utility.VehiclesData[plate]

                            uTarget.UpdateClient("vehicles")
                            self.UpdateClient("vehicles")
                        end
                    end

                    Log("Vehicle", self.source.." have transfered the vehicle with the plate "..plate.." to "..target)
                    EmitEvent("VehicleTransferedToPlayer", self.source, plate, target)
                end
            end
        end
        
        --[[
            Check if a plate is owned by the player

            plate string = The plate of the vehicle

            return [boolean] = If the plate is owned by the player
        ]]
        self.IsPlateOwned = function(plate)
            check({plate = "string"})

            return Utility.VehiclesData[plate].owner == self.owner
        end
    -- Other info integration

        --[[
            Set a value in the other info

            key string = The key of the value
            value any = The value
        ]]
        self.Set = function(id, value)
            check({id = "string"})
            
            if type(value) == "table" then
                self.external[id] = json.encode(value)
            else
                self.external[id] = value
            end

            self.UpdateClient("external")
        end
        
        --[[
            Get a value from the other info

            key string = The key of the value

            return [any] = The value
        ]]
        self.Get = function(id)
            if id == nil then
                return self.external
            else
                check({id = "string"})

                local decoded = json.decode(self.external[id])

                if decoded ~= nil then
                    return decoded
                else
                    return self.external[id] or nil
                end
            end
        end
                
        --[[
            Remove a value from the other info

            key string = The key of the value
        ]]
        self.Del = function(id)
            check({id = "string"})

            if self.external[id] then
                self.external[id] = nil
                self.UpdateClient("external")
            end
        end
    -- Ban
    
        --[[
            Ban a player

            reason string = The reason of the ban
        ]]
        self.Ban = function(reason)
            check({reason = "string"})
            
            if reason:find("[TBP Auto Ban]") then
                if not Config.TriggerBasicProtection.AutoBan then
                    return
                end
            end

            local identifier = {}
            local token = {}

            -- Get the identifiers
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

            -- Get the tokens
            for i=0,GetNumPlayerTokens(self.source) do
                table.insert(token, GetPlayerToken(self.source, i))
            end

            -- Insert in the ban list
            MySQL.Sync.execute("INSERT INTO bans (name, data, token, internal_reason) VALUES (:name, :data, :token, :internal_reason)", {
                name  = self.name,
                data  = json.encode(identifier),
                token = json.encode(token),
                internal_reason = reason,
            })

            Log("Ban", self.source.." ("..self.name..") has been banned")

            table.insert(Utility.Bans, {data = identifier, token = token})
            TriggerClientEvent("Utility:Ban", self.source)

            DropPlayer(self.source, Config.Labels["framework"]["Banned"])
        end
    -- Other function
    
        --[[
            Show a notification to the player

            msg string = The message of the notification
        ]]
        self.ShowNotification = function(msg)
            check({msg = "string"})

            TriggerClientEvent("Utility:Notification", self.source, msg)
        end
        
        --[[
            Show a button message to the player

            msg string = The message of the help
        ]]
        self.ButtonNotification = function(msg, duration)
            check({msg = "string"})
            TriggerClientEvent("Utility:ButtonNotification", self.source, msg, duration or 2000)
        end

        --[[
            Trigger a client event with the player source

            event string = The event name
            ... any = The arguments of the event
        ]]
        self.TriggerEvent = function(event, ...)
            check({event = "string"})
            
            TriggerClientEvent(event, self.source, ...)
        end

        --[[
            Trigger a client event with the player source

            event string = The event name
            ... any = The arguments of the event
        ]]
        self.Trigger = TriggerEvent
        
        -- Add to any method the hook execution
        for k,v in pairs(self) do
            if type(v) == "function" then -- If is a method
                self[k] = function(...) -- Hook function
                    local hook = ExecuteHooks("uPlayer", k, self.source, ...) -- Execute all hooks for this method
                    if hook then return hook end

                    return v(...) -- Execute the normal method
                end
            end
        end

    return self
end


function uPlayerExistInAGroup(identifier)
    if Config.Group[identifier] then
        --print("Have a group: "..Config.Group[identifier])
        ExecuteCommand("add_principal identifier."..identifier.." group."..Config.Group[identifier])
        return Config.Group[identifier]
    else
        return "user"
    end
end

function uPlayerBuildJobs(self)
    for i=1, #self.jobs do
        -- Save the job data from the database
        local name = self.jobs[i][1]
        local grade = self.jobs[i][2]
        local onduty = self.jobs[i][3]

        if name and grade then
            self.jobs[i] = Job({
                name = name,
                onduty = onduty,
                grade = {
                    id = grade
                }
            })
    
            AddToJob(self.jobs[i], i, self.source)
        end
    end

    return self
end

function uPlayerBuildInventory(self)
    if Config.Inventory.Type == "weight" then
        self.maxWeight = Config.Inventory.MaxWeight
        self.weight = 0
    
        for k,v in pairs(self.inventory) do
            self.weight = self.weight + CalculateItemWeight(k, v[2])
        end
    end

    return self
end